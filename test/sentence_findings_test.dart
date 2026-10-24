import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/detection_engine.dart';
import 'package:omnitrace/core/detection/orchestrator.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/core/services/text_discriminability.dart';
import 'package:omnitrace/core/utils/text_stats.dart';
import 'package:omnitrace/features/workspace/sentence_findings_view.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';
import 'package:omnitrace/shared/widgets/professional_report_header.dart';

final _l10n = lookupAppLocalizations(const Locale('en'));

const _text =
    'The first complete sentence provides enough content for a reliable analysis. '
    'The second complete sentence also provides enough content for the analysis.\n\n'
    'References\n\n'
    'Smith, J. (2020). A study of detectors. Journal of Testing, 3(2), 1-10.';

/// 以分析區塊為單位給分的假神經引擎；`null` 代表該區塊未送模型（NaN）
class _ChunkEngine implements DetectionEngine {
  @override
  final String id;
  final List<double?> chunkScores;
  final bool hasEvidence;
  final EngineApplicability applicability;

  const _ChunkEngine(
    this.id,
    this.chunkScores, {
    this.hasEvidence = false,
    this.applicability = EngineApplicability.validated,
  });

  @override
  double get defaultWeight => 0.4;

  @override
  Future<bool> isAvailable() async => true;

  @override
  String name(AppLocalizations l10n) => id;

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n, {
    EngineProgressCallback? onProgress,
  }) async {
    final chunks = [
      for (var i = 0; i < text.analysisChunks.length; i++)
        i < chunkScores.length ? chunkScores[i] ?? double.nan : double.nan,
    ];
    return EngineScore(
      engineId: id,
      engineName: id,
      aiProbability: hasEvidence ? 0.9 : 0.05,
      weight: defaultWeight,
      hasEvidence: hasEvidence,
      applicability: applicability,
      sentenceScores: text.expandChunkScoresToSentences(chunks),
    );
  }
}

class _SilentEngine implements DetectionEngine {
  @override
  final String id;

  const _SilentEngine(this.id);

  @override
  double get defaultWeight => 0.2;

  @override
  Future<bool> isAvailable() async => true;

  @override
  String name(AppLocalizations l10n) => id;

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n, {
    EngineProgressCallback? onProgress,
  }) async => EngineScore(
    engineId: id,
    engineName: id,
    aiProbability: 0.5,
    weight: defaultWeight,
    hasEvidence: false,
  );
}

Future<List<SentenceScore>> _sentences(List<DetectionEngine> engines) async {
  final result = await EnsembleOrchestrator(
    engines: engines,
  ).analyze(_text, eslCorrectionEnabled: false, l10n: _l10n);
  return result.sentences;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('逐句分數的來歷', () {
    test('引擎未投票時保留模型實測分數；未抽樣與參考文獻各自標明原因', () async {
      final sentences = await _sentences(const [
        _ChunkEngine('transformer', [0.12, null]),
        _SilentEngine('stylometry'),
      ]);
      expect(sentences.first.status, SentenceScoreStatus.measuredBelowEvidence);
      expect(sentences.first.modelBacked, isFalse);
      expect(sentences.first.measuredProbability, closeTo(0.12, 1e-9));
      expect(sentences[1].status, SentenceScoreStatus.screenedOut);
      expect(sentences[1].measuredProbability, isNull);
      // 參考文獻區的句子從未送進模型
      expect(
        sentences.skip(2).map((s) => s.status),
        everyElement(
          anyOf(
            SentenceScoreStatus.notSentToModel,
            SentenceScoreStatus.notAnalyzable,
          ),
        ),
      );
      expect(
        sentences.skip(2).map((s) => s.status),
        contains(SentenceScoreStatus.notSentToModel),
      );
    });

    test('投票引擎的分數標為已投票', () async {
      final sentences = await _sentences(const [
        _ChunkEngine('transformer', [0.92, 0.88], hasEvidence: true),
      ]);
      expect(sentences.first.status, SentenceScoreStatus.voted);
      expect(sentences.first.modelBacked, isTrue);
    });

    test('沒有神經模型，或模型不支援此語言時，不顯示實測分數', () async {
      for (final engines in [
        const <DetectionEngine>[_SilentEngine('stylometry')],
        const <DetectionEngine>[
          _ChunkEngine('adversarial', [
            0.3,
            0.3,
          ], applicability: EngineApplicability.unsupported),
        ],
      ]) {
        final first = (await _sentences(engines)).first;
        expect(first.status, SentenceScoreStatus.noNeuralModel);
        expect(first.measuredProbability, isNull);
      }
    });
  });

  group('逐句發現清單', () {
    final rows = [
      const SentenceFindingRow(
        number: 1,
        text: 'alpha sentence',
        score: 0.12,
        status: SentenceFindingStatus.belowEvidence,
      ),
      const SentenceFindingRow(
        number: 2,
        text: 'beta sentence',
        score: null,
        status: SentenceFindingStatus.screenedOut,
      ),
      const SentenceFindingRow(
        number: 3,
        text: 'gamma sentence',
        score: 0.91,
        status: SentenceFindingStatus.voted,
      ),
    ];

    Future<void> pump(WidgetTester tester, {VoidCallback? onFull}) =>
        tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('en'),
            home: Scaffold(
              body: SizedBox(
                width: 600,
                height: 600,
                child: SentenceFindingsView(rows: rows, onFullAnalysis: onFull),
              ),
            ),
          ),
        );

    double top(WidgetTester tester, String text) =>
        tester.getTopLeft(find.text(text)).dy;

    testWidgets('摘要、未達門檻標示與缺分原因', (tester) async {
      await pump(tester);
      expect(
        find.text(_l10n.workspaceFindingsSummary(2, 3, 1, 60)),
        findsOneWidget,
      );
      expect(find.text('91%'), findsOneWidget);
      expect(find.text('12%'), findsOneWidget);
      expect(find.text(_l10n.sentenceScoreBelowEvidenceLabel), findsOneWidget);
      expect(find.text(_l10n.sentenceStatusScreenedOut), findsOneWidget);
      // 沒有任何一列只剩破折號
      expect(find.text('—'), findsNothing);
    });

    testWidgets('預設依分數排序，可切回原文順序並只看已量測', (tester) async {
      await pump(tester);
      expect(
        top(tester, 'gamma sentence'),
        lessThan(top(tester, 'alpha sentence')),
      );
      expect(
        top(tester, 'alpha sentence'),
        lessThan(top(tester, 'beta sentence')),
      );

      await tester.tap(find.text(_l10n.workspaceFindingsSortOrder));
      await tester.pump();
      expect(
        top(tester, 'alpha sentence'),
        lessThan(top(tester, 'beta sentence')),
      );
      expect(
        top(tester, 'beta sentence'),
        lessThan(top(tester, 'gamma sentence')),
      );

      await tester.tap(find.text(_l10n.workspaceFindingsMeasuredOnly));
      await tester.pump();
      expect(find.text('beta sentence'), findsNothing);
      expect(find.text('alpha sentence'), findsOneWidget);
    });

    testWidgets('有未抽樣的句子時提供完整逐句分析', (tester) async {
      var requested = false;
      await pump(tester, onFull: () => requested = true);
      expect(
        find.text(_l10n.workspaceFindingsScreenedBanner(2, 3)),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('findings-full-analysis')));
      expect(requested, isTrue);
    });
  });

  testWidgets('篩檢提示的送模型句數與摘要的已量測一致（不含參考文獻）', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(
          body: SizedBox(
            width: 600,
            height: 600,
            child: SentenceFindingsView(
              rows: [
                SentenceFindingRow(
                  number: 1,
                  text: 'a',
                  score: 0.2,
                  status: SentenceFindingStatus.belowEvidence,
                ),
                SentenceFindingRow(
                  number: 2,
                  text: 'b',
                  score: null,
                  status: SentenceFindingStatus.screenedOut,
                ),
                SentenceFindingRow(
                  number: 3,
                  text: 'Smith (2020). Journal.',
                  score: null,
                  status: SentenceFindingStatus.notSent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    expect(
      find.text(_l10n.workspaceFindingsSummary(1, 3, 0, 60)),
      findsOneWidget,
    );
    expect(
      find.text(_l10n.workspaceFindingsScreenedBanner(1, 3)),
      findsOneWidget,
    );
  });

  group('判別力不足的原因與可行做法', () {
    DetectionResult result(List<EngineScore> scores) => DetectionResult(
      id: 'd',
      analyzedAt: DateTime(2026, 10, 24),
      inputText: '這是一段用來測試的中文內容。' * 20,
      aiProbability: 0.1,
      verdict: Verdict.likelyHuman,
      engineScores: scores,
      sentences: const [],
    );

    test('分開記錄「語言不支援」與「未安裝」', () {
      final d = TextDiscriminability.assess(
        result(const [
          EngineScore(
            engineId: 'adversarial',
            engineName: 'adversarial',
            aiProbability: 0.1,
            weight: 0.15,
            hasEvidence: false,
            applicability: EngineApplicability.unsupported,
          ),
          EngineScore(
            engineId: 'transformer',
            engineName: 'transformer',
            aiProbability: 0.5,
            weight: 0.4,
            available: false,
          ),
        ]),
      );
      expect(d.languageUnsupportedRoles, ['adversarial']);
      expect(d.notInstalledRoles, ['transformer']);
      expect(d.language, 'zh');
      expect(d.gaps, contains(DiscriminabilityGap.enginesUnavailable));
    });

    test('語言不支援時不建議重新下載', () {
      final groups = EngineGroup.fromScores(const [
        EngineScore(
          engineId: 'adversarial',
          engineName: 'adversarial',
          aiProbability: 0.1,
          weight: 0.15,
          hasEvidence: false,
          applicability: EngineApplicability.unsupported,
        ),
      ], _l10n);
      final adversarial = groups.firstWhere((g) => g.role == 'adversarial');
      expect(adversarial.languageUnsupported, isTrue);
      expect(
        adversarial.relationshipText,
        contains(_l10n.reportEngineResolutionLanguage),
      );
      expect(
        adversarial.relationshipText,
        isNot(contains(_l10n.reportEngineResolutionAdversarial)),
      );
    });
  });
}
