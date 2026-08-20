import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/detection/detection_engine.dart';
import 'package:truthlens/core/detection/engines/stylometry_engine.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/services/preferences_service.dart';
import 'package:truthlens/core/utils/text_stats.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('saved user weights are used by the ensemble vote', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    await prefs.load();
    await prefs.setEngineWeights(const {
      'transformer': 0.10,
      'statistical': 0.20,
      'stylometry': 0.30,
      'adversarial': 0.40,
    });
    final orchestrator = EnsembleOrchestrator(
      engines: const [
        _FixedEngine('transformer', 1),
        _FixedEngine('statistical', 0),
        _FixedEngine('stylometry', 0),
        _FixedEngine('adversarial', 0),
      ],
    );

    final result = await orchestrator.analyze(
      'This complete sentence provides enough content for reliable analysis.',
      prefs: prefs,
      eslCorrectionEnabled: false,
    );

    expect(result.aiProbability, closeTo(0.08, 0.0001));
    expect(
      result.engineScores.firstWhere((s) => s.engineId == 'transformer').weight,
      0.10,
    );
  });

  test(
    'an engine disabled in settings does not participate in the vote',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService();
      await prefs.load();
      await prefs.setEngineEnabled('transformer', false);
      final orchestrator = EnsembleOrchestrator(
        engines: const [
          _FixedEngine('transformer', 1),
          _FixedEngine('statistical', 0),
          _FixedEngine('stylometry', 0),
          _FixedEngine('adversarial', 0),
        ],
      );

      final result = await orchestrator.analyze(
        'This complete sentence provides enough content for reliable analysis.',
        prefs: prefs,
        eslCorrectionEnabled: false,
      );

      expect(result.aiProbability, 0);
      expect(result.engineScores.first.available, isFalse);
    },
  );

  test(
    'stylometry returns zero AI signal when no style markers are found',
    () async {
      final score = await StylometryEngine().analyze(
        PreprocessedText.from(
          'The committee reviewed evidence from several sources. '
          'Members then discussed the findings during a public meeting.',
        ),
        lookupAppLocalizations(const Locale('en')),
      );

      expect(score.aiProbability, 0);
    },
  );

  test('displayed contribution points always sum to overall percentage', () {
    const scores = [
      EngineScore(
        engineId: 'transformer',
        engineName: 'Transformer',
        aiProbability: 0.115,
        weight: 0.40,
      ),
      EngineScore(
        engineId: 'statistical',
        engineName: 'Statistical',
        aiProbability: 0.384,
        weight: 0.25,
      ),
      EngineScore(
        engineId: 'stylometry',
        engineName: 'Stylometry',
        aiProbability: 0.23,
        weight: 0.20,
      ),
      EngineScore(
        engineId: 'adversarial',
        engineName: 'Adversarial',
        aiProbability: 0.1066666667,
        weight: 0.15,
      ),
    ];
    final overall =
        (0.115 * 0.40) + (0.384 * 0.25) + (0.23 * 0.20) + (0.1066666667 * 0.15);
    final result = DetectionResult(
      id: 'rounding',
      analyzedAt: DateTime(2026, 8, 13),
      inputText: 'A complete sentence is available for analysis.',
      aiProbability: overall,
      verdict: Verdict.fromProbability(overall),
      engineScores: scores,
      sentences: const [],
    );

    final displayedPoints = result.roundedEngineContributionPoints;
    final independentlyRounded = scores.fold<int>(
      0,
      (sum, score) => sum + (score.aiProbability * score.weight * 100).round(),
    );
    expect(independentlyRounded, isNot((overall * 100).round()));
    expect(
      displayedPoints.values.fold<int>(0, (sum, value) => sum + value),
      (overall * 100).round(),
    );
  });

  test('AI sentence ratio uses the same 60 percent strong threshold', () {
    final result = DetectionResult(
      id: 'sentence-threshold',
      analyzedAt: DateTime(2026, 8, 13),
      inputText: 'Two complete sentences are available for analysis.',
      aiProbability: 0.30,
      verdict: Verdict.likelyHuman,
      engineScores: const [],
      sentences: const [
        SentenceScore(
          index: 0,
          text: 'This sentence remains below the strong signal threshold.',
          aiProbability: 0.59,
        ),
        SentenceScore(
          index: 1,
          text: 'This sentence crosses the strong signal threshold clearly.',
          aiProbability: 0.60,
        ),
      ],
    );

    expect(result.aiSentenceCount, 1);
    expect(result.humanSentenceCount, 1);
  });

  test(
    'sentence-level neural scores respect configured engine weights',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService();
      await prefs.load();
      await prefs.setEngineWeights(const {
        'transformer': 0.80,
        'statistical': 0,
        'stylometry': 0,
        'adversarial': 0.20,
      });
      final orchestrator = EnsembleOrchestrator(
        engines: const [
          _FixedEngine('transformer', 0.40, sentenceScores: [0.40]),
          _FixedEngine('statistical', 0),
          _FixedEngine('stylometry', 0),
          _FixedEngine('adversarial', 0.80, sentenceScores: [0.80]),
        ],
      );

      final result = await orchestrator.analyze(
        'This complete sentence provides enough content for reliable analysis.',
        prefs: prefs,
        eslCorrectionEnabled: false,
      );

      expect(result.sentences.single.aiProbability, closeTo(0.48, 0.0001));
      expect(result.aiSentenceCount, 0);
    },
  );
}

class _FixedEngine implements DetectionEngine {
  @override
  final String id;
  final double probability;
  final List<double>? sentenceScores;

  const _FixedEngine(this.id, this.probability, {this.sentenceScores});

  @override
  double get defaultWeight => PreferencesService.defaultEngineWeights[id]!;

  @override
  Future<bool> isAvailable() async => true;

  @override
  String name(AppLocalizations l10n) => id;

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n,
  ) async => EngineScore(
    engineId: id,
    engineName: id,
    aiProbability: probability,
    weight: defaultWeight,
    sentenceScores: sentenceScores,
  );
}
