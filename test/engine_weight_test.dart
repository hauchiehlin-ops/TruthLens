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

    expect(result.aiProbability, closeTo(0.10, 0.0001));
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
}

class _FixedEngine implements DetectionEngine {
  @override
  final String id;
  final double probability;

  const _FixedEngine(this.id, this.probability);

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
  );
}
