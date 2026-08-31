import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/adaptive_sentence_batcher.dart';
import 'package:truthlens/core/detection/detection_engine.dart';
import 'package:truthlens/core/detection/perplexity_calibration.dart';
import 'package:truthlens/core/detection/engines/statistical_engine.dart';
import 'package:truthlens/core/detection/engines/stylometry_engine.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/utils/text_stats.dart';
import 'package:truthlens/features/workspace/telemetry_summary.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';
import 'package:truthlens/shared/widgets/professional_report_header.dart';

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
    AppLocalizations l10n, {
    EngineProgressCallback? onProgress,
  }) async {
    onProgress?.call(1);
    return EngineScore(
      engineId: id,
      engineName: id,
      aiProbability: probability,
      weight: defaultWeight,
      hasEvidence: evidence,
      features: features,
    );
  }
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

  test(
    'ONNX sentence classifier uses deterministic single-sentence batches',
    () {
      expect(kDeterministicOnnxSentenceBatchSize, 1);
    },
  );

  group('沉默的引擎不投票', () {
    test('單一家族不被沉默引擎稀釋，但不能冒充跨家族共識', () async {
      final result = await EnsembleOrchestrator(
        engines: const [
          _Engine('transformer', 0, evidence: false),
          _Engine('statistical', 0.78),
          _Engine('stylometry', 0, evidence: false),
          _Engine('adversarial', 0, evidence: false),
        ],
      ).analyze(_text, eslCorrectionEnabled: false);

      // 單一統計家族保留完整連續方向；是否足以升級由獨立證據閘門與
      // 整合信心控制，不再把政策門檻偽裝成 59% 的量測值。
      expect(result.aiProbability, closeTo(0.78, 0.0001));
      expect(result.verdict, Verdict.likelyAi);
    });

    test('兩個獨立家族同向時依預先設定可靠度融合', () async {
      final result = await EnsembleOrchestrator(
        engines: const [
          _Engine(
            'transformer',
            0.80,
            features: {'ai_analysis_chunk_ratio': 0.80},
          ),
          _Engine('statistical', 0.75),
          _Engine('stylometry', 0, evidence: false),
          _Engine('adversarial', 0, evidence: false),
        ],
      ).analyze(_text, eslCorrectionEnabled: false);

      expect(result.aiProbability, closeTo(0.782, 0.002));
      // 強訊號比例不再提高自己的權重；差異只來自預先設定的家族權重。
      expect(result.effectiveWeightFor(result.engineScores[0]), 0.40);
      expect(result.effectiveWeightFor(result.engineScores[1]), 0.25);
    });

    test('四個引擎全部沉默時回到中性並標示證據限制', () async {
      final result = await EnsembleOrchestrator(
        engines: const [
          _Engine('transformer', 0, evidence: false),
          _Engine('statistical', 0.5, evidence: false),
          _Engine('stylometry', 0, evidence: false),
          _Engine('adversarial', 0, evidence: false),
        ],
      ).analyze(_longText, eslCorrectionEnabled: false);

      expect(result.aiProbability, closeTo(0.5, 0.0001));
      expect(result.verdict, Verdict.mixed);
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
    expect(text, contains('single analysis axis'));
    expect(text, contains('formed no directional signal'));
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
    expect(text, contains('No quantifiable authorship signal'));
    expect(text, contains('no numeric index was issued'));
    expect(text, isNot(contains('More likely not AI-generated')));
    expect(text, contains('Low confidence'));
    expect(text, contains('none found usable evidence'));
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

    test('版面密度不是助理特徵，語篇招呼才是', () async {
      // 實測：人類撰寫的技術文件在標題比例（18.6% 對 8.3%）、粗體數（142 對 27）
      // 與 emoji 數（41 對 5）上都高於受測的 AI 回覆。用版面密度當特徵只會在
      // 專案自己的 README 上誤報，因此版面只在已有語句招呼時才小幅加分。
      const humanTechnicalDoc =
          '## 架構決策\n\n'
          '- **推論平台**：瀏覽器端 Dart 推論，不依賴原生層\n'
          '- **模型下載**：HTTP 206 續傳支援\n'
          '- **儲存**：OPFS，文件內容不上傳\n\n'
          '### 效能目標\n\n'
          '1. 500 字文件在 5 秒內完成分析\n'
          '2. 冷啟動 3 秒內\n'
          '3. 記憶體峰值低於 2GB\n\n'
          '這些目標來自實機量測，不是估算值。後續若要調整，必須附上新的量測數據。\n';

      final score = await StylometryEngine().analyze(
        PreprocessedText.from(humanTechnicalDoc),
        l10n,
      );
      expect(score.features['assistant_response_artifacts'], 0.0);
      expect(
        score.hasEvidence,
        isFalse,
        reason: '密集的標題與條列是技術寫作常態，不得單獨構成 AI 證據',
      );
    });

    test('多條獨立助理招呼語構成高特異性證據', () async {
      const assistantReply =
          '撰寫關於從眾心理學的期刊論文是一個極具價值的選擇。\n\n'
          '以下為您整理目前最新的研究成果：\n\n'
          '**1. 社群電商下的從眾機制**\n'
          '消費者依賴他人的評論或購買數量來做決策。\n\n'
          '建議您的論文可以先透過結構方程模型進行問卷數據分析。\n\n'
          '希望這些趨勢能幫助您的論文找到亮點！'
          '如果您對其中某個方向特別感興趣，我們可以進一步討論。\n';

      final score = await StylometryEngine().analyze(
        PreprocessedText.from(assistantReply),
        l10n,
      );
      expect(
        score.features['assistant_response_artifacts']!,
        greaterThanOrEqualTo(2),
      );
      expect(score.hasEvidence, isTrue);
      expect(score.votes, isTrue);
    });

    test('助理招呼語長在版面結構上，剝掉結構就會連證據一起剝掉', () async {
      // 真實回報：一份 Gemini 回覆被判為「未取得可量化的作者訊號」。原因是
      // 助理殘留樣式比對的是 analysisText，而 analysisText 刻意剝除標題、
      // 條列與以冒號結尾的引導句——招呼語正好長在那裡。實測該文件原文命中
      // 1 次、analysisText 命中 0 次，全 App 特異性最高的訊號就此消失。
      //
      // 直接痕跡必須在原文上找；統計特徵才需要乾淨的 analysisText。
      const document =
          '### 一、 目前世界最新的研究成果\n\n'
          '以下為您整理目前世界上最新的研究成果，以及尚待開發的研究缺口：\n\n'
          '**1. 社群電商下的雙軌從眾機制**\n'
          '消費者依賴他人的評論或購買數量來做決策，這在資訊過載的情況下特別明顯。\n'
          '為了獲得群體認同、避免被邊緣化而跟風購買，是另一條獨立的路徑。\n';

      final text = PreprocessedText.from(document);
      // 前提：該行確實不在 analysisText 裡，否則這條測試就失去意義。
      expect(text.analysisText.contains('以下為您整理'), isFalse);
      expect(text.raw.contains('以下為您整理'), isTrue);

      final score = await StylometryEngine().analyze(text, l10n);
      expect(score.features['assistant_response_artifacts'], 1.0);
      expect(score.hasEvidence, isTrue);
      expect(score.votes, isTrue);
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

    test('統計分數依句長起伏離門檻的距離連續變化', () async {
      const uniform =
          'Alpha beta gamma delta epsilon zeta eta theta. '
          'Iota kappa lambda mu nu xi omicron pi. '
          'Rho sigma tau upsilon phi chi psi omega. '
          'River stone window paper signal method value result.';
      const moderatelyUniform =
          'Alpha beta gamma delta epsilon zeta. '
          'Iota kappa lambda mu nu xi omicron pi. '
          'Rho sigma tau upsilon phi chi psi omega value method. '
          'River stone window paper signal method value result field sample data note.';
      const highlyVaried =
          'Alpha beta gamma delta. '
          'Iota kappa lambda mu. '
          'Rho sigma tau upsilon. '
          'River stone window paper signal method value result field sample data note '
          'analysis evidence context design process outcome review conclusion detail.';

      final engine = StatisticalEngine();
      final uniformScore = await engine.analyze(
        PreprocessedText.from(uniform),
        l10n,
      );
      final moderateScore = await engine.analyze(
        PreprocessedText.from(moderatelyUniform),
        l10n,
      );
      final variedScore = await engine.analyze(
        PreprocessedText.from(highlyVaried),
        l10n,
      );

      expect(
        uniformScore.aiProbability,
        greaterThan(moderateScore.aiProbability),
      );
      expect(moderateScore.aiProbability, greaterThan(0.60));
      expect(variedScore.aiProbability, lessThan(0.40));
      expect(uniformScore.features['burstiness_probability'], isNotNull);
      expect(variedScore.features['burstiness_probability'], isNotNull);
    });

    test('統計矩陣以有效權重線性累積且可由分量重算', () async {
      const mixedSignals =
          'The result is in the report. '
          'The method is in the report. '
          'The evidence is in the report. '
          'The result is in the report and the method is in the report '
          'and the evidence is in the report and the result is in the report '
          'and the method is in the report and the evidence is in the report '
          'and the result is in the report and the method is in the report.';

      final score = await StatisticalEngine().analyze(
        PreprocessedText.from(mixedSignals),
        l10n,
      );
      final features = score.features;
      final burstinessMass = features['burstiness_weighted_ai_mass']!;
      final mattrMass = features['mattr_weighted_ai_mass']!;
      final activeWeight = features['statistical_active_weight']!;
      final expectedSum = burstinessMass + mattrMass;

      expect(features['burstiness_signed_contribution'], lessThan(0));
      expect(features['mattr_signed_contribution'], greaterThan(0));
      expect(activeWeight, closeTo(0.50, 1e-9));
      expect(features['statistical_weighted_sum'], closeTo(expectedSum, 1e-9));
      expect(score.aiProbability, closeTo(expectedSum / activeWeight, 1e-9));
      expect(
        features['statistical_linear_ai_ratio'],
        closeTo(score.aiProbability, 1e-9),
      );
    });

    test('統計引擎無合格訊號時報告層不得顯示成 50%', () {
      final group = EngineGroup.fromScores(const [
        EngineScore(
          engineId: 'statistical',
          engineName: 'Statistical',
          aiProbability: 0.50,
          weight: 0.25,
          hasEvidence: false,
        ),
      ], l10n).firstWhere((group) => group.role == 'statistical');

      expect(group.hasDirectionalSignal, isFalse);
      expect(group.probability, 0);
      expect(group.relationshipText, contains('found no evidence'));
    });
  });

  _perplexityLanguageGate();
}

/// 困惑度只在模型看得懂的語言上採計。
/// 依據：HC3 中文語料實測，門檻 60 之下真人與 AI 各佔 100%，區別力 0.0%；
/// production 管線量到中文真人 41、中文 AI 46，兩者皆低於 60 且順序相反。
void _perplexityLanguageGate() {
  group('困惑度模型依語言路由', () {
    test('中文挑得出 Qwen，挑不到 DistilGPT2', () {
      // 同一個指標換模型，可分性天差地遠：DistilGPT2 對中文 AUC 0.50
      // （等於亂猜，被 isUsable 擋下），Qwen2.5-0.5B 是 0.965。
      expect(
        PerplexityCalibration.bestModelFor('zh', const [
          'distilgpt2-ppl-int8',
          'qwen05b-ppl-int8',
        ]),
        'qwen05b-ppl-int8',
      );
    });

    test('英文兩顆都可用時，尊重候選順序（使用者選擇優先）', () {
      expect(
        PerplexityCalibration.bestModelFor('en', const [
          'distilgpt2-ppl-int8',
          'qwen05b-ppl-int8',
        ]),
        'distilgpt2-ppl-int8',
      );
    });

    test('只裝了對該語言無效的模型時回傳 null，由呼叫端棄權', () {
      expect(
        PerplexityCalibration.bestModelFor('zh', const ['distilgpt2-ppl-int8']),
        isNull,
      );
    });

    test('未量測過的語言一律回傳 null，不拿別的語言門檻頂替', () {
      expect(
        PerplexityCalibration.bestModelFor('th', const [
          'distilgpt2-ppl-int8',
          'qwen05b-ppl-int8',
        ]),
        isNull,
      );
    });
  });

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
