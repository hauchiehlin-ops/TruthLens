import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/detection_engine.dart';
import 'package:truthlens/core/detection/engines/statistical_engine.dart';
import 'package:truthlens/core/detection/engines/stylometry_engine.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/utils/text_stats.dart';
import 'package:truthlens/features/workspace/telemetry_summary.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

/// 假引擎：可指定分數與「有沒有找到證據」
class _Engine implements DetectionEngine {
  @override
  final String id;
  final double probability;
  final bool evidence;
  final Map<String, double> features;

  const _Engine(
    this.id,
    this.probability, {
    this.evidence = true,
    this.features = const {},
  });

  @override
  double get defaultWeight => const {
    'transformer': 0.40,
    'statistical': 0.25,
    'stylometry': 0.20,
    'adversarial': 0.15,
  }[id]!;

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
    hasEvidence: evidence,
    features: features,
  );
}

/// 重現回報案例：Transformer/風格/對抗三個引擎沉默（0%），
/// 只有統計引擎找到證據（78%）
List<EngineScore> _reportedCase() => const [
  EngineScore(
    engineId: 'transformer',
    engineName: 'Transformer',
    aiProbability: 0,
    weight: 0.40,
    hasEvidence: false,
  ),
  EngineScore(
    engineId: 'statistical',
    engineName: 'Statistical',
    aiProbability: 0.78,
    weight: 0.25,
  ),
  EngineScore(
    engineId: 'stylometry',
    engineName: 'Stylometry',
    aiProbability: 0,
    weight: 0.20,
    hasEvidence: false,
  ),
  EngineScore(
    engineId: 'adversarial',
    engineName: 'Adversarial',
    aiProbability: 0,
    weight: 0.15,
    hasEvidence: false,
  ),
];

DetectionResult _result(List<EngineScore> scores, double overall) =>
    DetectionResult(
      id: 'e',
      analyzedAt: DateTime(2026, 8, 18),
      inputText: List.filled(400, 'alpha').join(' '),
      aiProbability: overall,
      verdict: Verdict.fromProbability(overall),
      engineScores: scores,
      sentences: [
        for (var i = 0; i < 10; i++)
          SentenceScore(
            index: i,
            text:
                'This is a complete and sufficiently long analysable sentence '
                'numbered $i for the purposes of this test.',
            aiProbability: 0.3,
          ),
      ],
      availableEngineCount: scores.where((s) => s.available).length,
      totalEngineCount: scores.length,
    );

const _text =
    'This complete sentence provides enough content for a reliable analysis. '
    'A second sentence keeps the paragraph intact for the engines to read.';

final _longText = List.generate(
  8,
  (i) =>
      'This complete sentence provides enough content for a reliable analysis '
      'while keeping the prose ordinary and easy for the test harness to parse '
      'as sentence number $i.',
).join(' ');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('沉默的引擎不投票', () {
    test('三個引擎沒有證據時，不稀釋唯一有證據的引擎', () async {
      final result = await EnsembleOrchestrator(
        engines: const [
          _Engine('transformer', 0, evidence: false),
          _Engine('statistical', 0.78),
          _Engine('stylometry', 0, evidence: false),
          _Engine('adversarial', 0, evidence: false),
        ],
      ).analyze(_text, eslCorrectionEnabled: false);

      // 舊的加權平均會得到 0.78×0.25 = 0.195（回報案例中的 20%）
      expect(result.aiProbability, closeTo(0.78, 0.0001));
      expect(result.verdict, Verdict.likelyAi);
    });

    test('多個引擎都有證據時，依證據品質調整有效權重', () async {
      final result = await EnsembleOrchestrator(
        engines: const [
          _Engine(
            'transformer',
            0.80,
            features: {'ai_analysis_chunk_ratio': 0.80},
          ),
          _Engine('statistical', 0.60),
          _Engine('stylometry', 0, evidence: false),
          _Engine('adversarial', 0, evidence: false),
        ],
      ).analyze(_text, eslCorrectionEnabled: false);

      // transformer: 0.40 × (0.70 + 0.80×1.10) = 0.632
      // statistical: 0.25 × (0.75 + |0.60-0.50|×2×0.75) = 0.225
      expect(result.aiProbability, closeTo(0.7475, 0.0005));
      expect(
        result.effectiveWeightFor(result.engineScores[0]),
        greaterThan(result.effectiveWeightFor(result.engineScores[1])),
      );
    });

    test('四個引擎全部沉默時保留 fallback 分數但必須棄權', () async {
      final result = await EnsembleOrchestrator(
        engines: const [
          _Engine('transformer', 0, evidence: false),
          _Engine('statistical', 0.5, evidence: false),
          _Engine('stylometry', 0, evidence: false),
          _Engine('adversarial', 0, evidence: false),
        ],
      ).analyze(_longText, eslCorrectionEnabled: false);

      expect(result.aiProbability, closeTo(0.125, 0.0001));
      expect(result.verdict, Verdict.human);
      expect(result.abstention, AbstentionReason.noEvidenceFound);
      expect(result.shouldAbstain, isTrue);
    });
  });

  group('棄權：沉默不是分歧', () {
    test('回報案例不再因「引擎分歧」棄權', () {
      final result = _result(_reportedCase(), 0.78);
      expect(result.engineSpreadPoints, 0);
      expect(result.abstention, AbstentionReason.none);
      expect(result.shouldAbstain, isFalse);
      expect(result.singleEvidenceSource, isTrue);
      expect(result.evidenceEngineCount, 1);
    });

    test('單一弱證據不得被顯示成人類側判定', () {
      final result = _result(const [
        EngineScore(
          engineId: 'transformer',
          engineName: 'Transformer',
          aiProbability: 0.03,
          weight: 0.40,
          hasEvidence: false,
        ),
        EngineScore(
          engineId: 'statistical',
          engineName: 'Statistical',
          aiProbability: 0.50,
          weight: 0.25,
          hasEvidence: false,
        ),
        EngineScore(
          engineId: 'stylometry',
          engineName: 'Stylometry',
          aiProbability: 0,
          weight: 0.20,
          hasEvidence: false,
        ),
        EngineScore(
          engineId: 'adversarial',
          engineName: 'Adversarial',
          aiProbability: 0.23,
          weight: 0.15,
        ),
      ], 0.23);

      expect(result.verdict, Verdict.likelyHuman);
      expect(result.abstention, AbstentionReason.singleWeakEvidenceSource);
      expect(result.shouldAbstain, isTrue);
      expect(result.singleEvidenceSource, isTrue);
    });

    test('兩個引擎都有證據且真的對立時，仍要棄權', () {
      final result = _result(const [
        EngineScore(
          engineId: 'transformer',
          engineName: 'Transformer',
          aiProbability: 0.95,
          weight: 0.40,
        ),
        EngineScore(
          engineId: 'statistical',
          engineName: 'Statistical',
          aiProbability: 0.05,
          weight: 0.25,
        ),
      ], 0.60);

      expect(result.engineSpreadPoints, 90);
      expect(result.abstention, AbstentionReason.enginesConflict);
    });
  });

  test('各引擎貢獻點數加總仍等於整體百分比', () {
    final result = _result(_reportedCase(), 0.78);
    final points = result.roundedEngineContributionPoints;
    expect(points.keys, ['statistical']);
    expect(points.values.fold<int>(0, (a, b) => a + b), 78);
  });

  test('遙測總結講明單一證據來源與沉默的引擎', () {
    final lines = buildTelemetrySummary(_result(_reportedCase(), 0.78), l10n);
    final text = lines.join(' ');

    expect(text, contains('Only'));
    expect(text, contains('single line of evidence'));
    expect(text, contains('found no evidence'));
    expect(text, isNot(contains('Not enough evidence to judge')));
  });

  test('遙測總結在全引擎沉默時不得回報人類判定', () {
    final result = _result(const [
      EngineScore(
        engineId: 'transformer',
        engineName: 'Transformer',
        aiProbability: 0,
        weight: 0.40,
        hasEvidence: false,
      ),
      EngineScore(
        engineId: 'statistical',
        engineName: 'Statistical',
        aiProbability: 0.50,
        weight: 0.25,
        hasEvidence: false,
      ),
      EngineScore(
        engineId: 'stylometry',
        engineName: 'Stylometry',
        aiProbability: 0,
        weight: 0.20,
        hasEvidence: false,
      ),
      EngineScore(
        engineId: 'adversarial',
        engineName: 'Adversarial',
        aiProbability: 0.02,
        weight: 0.15,
        hasEvidence: false,
      ),
    ], 0.13);

    final text = buildTelemetrySummary(result, l10n).join(' ');

    expect(result.verdict, Verdict.human);
    expect(result.abstention, AbstentionReason.noEvidenceFound);
    expect(text, contains('More likely not AI-generated'));
    expect(text, contains('Low confidence'));
    expect(text, contains('none found usable evidence'));
    expect(text, isNot(contains('Not enough evidence to judge')));
  });

  group('各引擎自陳有無證據', () {
    test('風格引擎沒命中任何特徵時視為沉默', () async {
      final score = await StylometryEngine().analyze(
        PreprocessedText.from(
          'The committee reviewed evidence from several sources. '
          'Members then discussed the findings during a public meeting.',
        ),
        l10n,
      );
      expect(score.aiProbability, 0);
      expect(score.hasEvidence, isFalse);
    });

    test('風格引擎命中特徵時算有證據', () async {
      final score = await StylometryEngine().analyze(
        PreprocessedText.from(
          'Moreover, the system is efficient. Furthermore, it is reliable. '
          'In addition, it is scalable. Additionally, it is maintainable. '
          'Moreover, the design is elegant and consistent throughout.',
        ),
        l10n,
      );
      expect(score.hasEvidence, isTrue);
      expect(score.aiProbability, greaterThan(0));
    });

    test('聊天助理回覆殘留是高特異性文字證據', () async {
      final score = await StylometryEngine().analyze(
        PreprocessedText.from(
          '您好！以下為您撰寫一篇完整文章。文章正文會從歷史背景開始，'
          '再討論區域安全與經濟發展。如果您的原意不同，請告訴我，我會調整內容。',
        ),
        l10n,
      );

      expect(score.hasEvidence, isTrue);
      expect(score.aiProbability, greaterThanOrEqualTo(0.85));
      expect(score.features['assistant_response_artifacts'], 2);
      expect(score.reasons.join(' '), contains('assistant'));
    });

    test('統計引擎所有指標都落在中間帶時視為沉默', () async {
      final score = await StatisticalEngine().analyze(
        PreprocessedText.from('Short text. Another one.'),
        l10n,
      );
      expect(score.aiProbability, 0.5);
      expect(score.hasEvidence, isFalse);
    });
  });

  _perplexityLanguageGate();
}

/// 困惑度只在模型看得懂的語言上採計。
/// 依據：HC3 中文語料實測，門檻 60 之下真人與 AI 各佔 100%，區別力 0.0%；
/// production 管線量到中文真人 41、中文 AI 46，兩者皆低於 60 且順序相反。
void _perplexityLanguageGate() {
  group('困惑度的語言適用範圍', () {
    test('中文文本不採計困惑度', () {
      expect(
        StatisticalEngine.supportsPerplexity(
          '本研究採用泰勒庫埃特流場作為實驗載體，透過改變內外圓筒的轉速比，'
          '觀察環狀渦漩在臨界雷諾數附近的形態轉換過程與穩定性邊界的變化。',
        ),
        isFalse,
      );
    });

    test('日文與韓文同樣不採計', () {
      expect(
        StatisticalEngine.supportsPerplexity('これは日本語の文章です。かなり長い文章を書いています。'),
        isFalse,
      );
      expect(
        StatisticalEngine.supportsPerplexity('이것은 한국어 문장입니다. 꽤 긴 문장을 쓰고 있습니다.'),
        isFalse,
      );
    });

    test('英文本文採計困惑度', () {
      expect(
        StatisticalEngine.supportsPerplexity(
          'The lowest stability boundary on the flow of concentric rotating '
          'cylinders was examined across a range of radius ratios, and the '
          'results are compared with the predictions that follow from the '
          'linear theory of the problem as it is usually stated.',
        ),
        isTrue,
      );
    });

    test('文字太短時寧可棄權也不猜語言', () {
      // 語言判不準就會套錯門檻，那正是這套機制要杜絕的事。
      // 應用程式本身的棄權門檻是 100 字，實際文件不會落到這裡。
      expect(
        StatisticalEngine.supportsPerplexity('The flow was examined.'),
        isFalse,
      );
    });

    test('英文本文夾雜少量中文專有名詞時仍採計', () {
      expect(
        StatisticalEngine.supportsPerplexity(
          'The Taylor-Couette apparatus described by Lin (林) and colleagues '
          'was rebuilt for this study, with the outer cylinder held stationary '
          'throughout every run reported in the following sections.',
        ),
        isTrue,
      );
    });

    test('空字串不崩潰', () {
      expect(StatisticalEngine.supportsPerplexity('   '), isFalse);
    });
  });
}
