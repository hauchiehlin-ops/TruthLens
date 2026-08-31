import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/language_id.dart';
import '../../utils/text_stats.dart';
import '../lexical_calibration.dart';
import '../perplexity_calibration.dart';
import '../detection_engine.dart';
import '../compression_profile.dart';
import '../model_manager.dart';
import '../perplexity_scorer.dart';

/// 子模型 B：統計特徵分析器。
/// 若 DistilGPT2 困惑度模型（statistical role）已安裝，納入真 Perplexity（ONNX 端上）；
/// 否則以 Burstiness / Entropy / TTR 的啟發式組合運作。此引擎恆可用（有回退）。
class StatisticalEngine implements DetectionEngine {
  final ModelManager? modelManager;

  PerplexityScorer? _scorer;
  String? _loadedPath;

  StatisticalEngine({this.modelManager});

  @override
  String get id => 'statistical';
  @override
  String name(AppLocalizations l10n) => l10n.analysisEngineStatistical;
  @override
  double get defaultWeight => 0.25;

  @override
  Future<bool> isAvailable() async => true; // 啟發式回退，恆可用

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n, {
    EngineProgressCallback? onProgress,
  }) async {
    onProgress?.call(0.05);
    final burstiness = text.burstiness;
    final ttr = text.typeTokenRatio;
    final entropy = text.entropy;
    onProgress?.call(0.16);

    final reasons = <String>[];
    final features = <String, double>{
      'burstiness': burstiness,
      'type_token_ratio': ttr,
      'entropy': entropy,
    };
    final signals = <({String feature, double aiRatio, double weight})>[];

    void addSignal(String feature, double aiRatio, double weight) {
      final value = aiRatio.clamp(0.02, 0.98);
      signals.add((feature: feature, aiRatio: value, weight: weight));
      // 保留既有欄位供舊報告讀取，並新增可重算線性累積結果的分量。
      features['${feature}_probability'] = value;
      features['${feature}_weight'] = weight;
      features['${feature}_weighted_ai_mass'] = value * weight;
      features['${feature}_signed_contribution'] = (value - 0.5) * weight;
    }

    // 困惑度只在「這個語言有實測門檻」時採計。門檻來自 PerplexityCalibration
    // 查表，而不是寫死的常數：困惑度的尺度隨語言而變（同一顆 DistilGPT2，
    // production 量到英文真人 304、中文 41），套錯門檻就是製造偽陽性。
    // 語言由 PreprocessedText 統一提供，不各自重算——各引擎若拿到不同的
    // 語言判定，校準查表與模型路由就會互相矛盾。
    final language = text.language;
    // 門檻綁定「模型 × 語言」，而差距可以很極端：DistilGPT2 對中文的 AUC 是
    // 0.50（等於亂猜），Qwen2.5-0.5B 是 0.965。沿用使用者手動設定的「使用中」
    // 變體，會讓一份中文文件配上 DistilGPT2 時整個角色空轉，而介面看不出原因。
    //
    // 因此改為逐文件挑選：在**已安裝**的變體中選第一個對本文件語言查得到
    // 可用門檻的。挑不到就不採計——沿用別顆模型的門檻等於在未知尺度上下結論。
    final installedIds = [
      for (final v
          in modelManager?.installedVariants('statistical') ??
              const <InstalledModel>[])
        v.variantId,
    ];
    final activeId = modelManager?.activeVariant('statistical')?.variantId;
    final routedModelId = language.isUndetermined
        ? null
        : PerplexityCalibration.bestModelFor(language.code, [
            // 使用者的選擇優先——它適用時就不換，尊重手動設定。
            ?activeId,
            ...installedIds,
            defaultPerplexityModelId,
          ]);
    final calibration = routedModelId == null
        ? null
        : PerplexityCalibration.of(language.code, modelId: routedModelId);
    onProgress?.call(0.28);
    final ppl = calibration != null
        ? await _tryPerplexity(text.analysisText, routedModelId)
        : null;
    onProgress?.call(0.58);
    features['perplexity_calibrated'] = ppl == null ? 0 : 1;
    if (calibration == null) {
      // 三種「不採計」的原因對使用者的意義完全不同，必須分開講。
      // 先前一律套用中日韓文那段說明，結果一篇英文論文被告知
      // 「對中日韓文而言……」——訊息本身就在誤導。
      final modelId = activeId ?? defaultPerplexityModelId;
      if (language.isUndetermined) {
        reasons.add(l10n.engineReasonPplLanguageUndetermined);
      } else if (PerplexityCalibration.hasRecord(
        language.code,
        modelId: modelId,
      )) {
        // 量測過但鑑別力不足——DistilGPT2 對中文就是這種情況
        reasons.add(l10n.engineReasonPplUncalibratedLanguage);
      } else {
        // 這個「模型 × 語言」組合根本還沒量過。點名兩者，
        // 使用者才知道是換模型還是補語料才能恢復這項指標。
        reasons.add(
          l10n.engineReasonPplNoCalibrationForModel(modelId, language.code),
        );
      }
    }
    if (ppl != null && calibration != null) {
      features['perplexity'] = ppl;
      if (ppl < calibration.aiCut) {
        final distance = ((calibration.aiCut - ppl) / calibration.aiCut).clamp(
          0.0,
          1.0,
        );
        addSignal('perplexity', 0.64 + distance * 0.31, 0.50);
        reasons.add(l10n.engineReasonPplLow(ppl.toStringAsFixed(0)));
      } else if (calibration.humanCut != null && ppl > calibration.humanCut!) {
        final distance = ((ppl - calibration.humanCut!) / calibration.humanCut!)
            .clamp(0.0, 1.0);
        addSignal('perplexity', 0.36 - distance * 0.26, 0.50);
        reasons.add(l10n.engineReasonPplHigh(ppl.toStringAsFixed(0)));
      } else {
        reasons.add(l10n.engineReasonPplMid(ppl.toStringAsFixed(0)));
      }
    }

    // Burstiness：人類句長起伏大；AI 節奏均勻
    if (text.sentences.length >= 4) {
      if (burstiness < 0.30) {
        final distance = ((0.30 - burstiness) / 0.30).clamp(0.0, 1.0);
        addSignal('burstiness', 0.60 + distance * 0.24, 0.30);
        reasons.add(
          l10n.engineReasonBurstinessLow(burstiness.toStringAsFixed(2)),
        );
      } else if (burstiness > 0.55) {
        final distance = ((burstiness - 0.55) / 0.55).clamp(0.0, 1.0);
        addSignal('burstiness', 0.40 - distance * 0.22, 0.30);
        reasons.add(
          l10n.engineReasonBurstinessHigh(burstiness.toStringAsFixed(2)),
        );
      } else {
        reasons.add(
          l10n.engineReasonBurstinessMid(burstiness.toStringAsFixed(2)),
        );
      }
    }

    // 詞彙多樣性：改用長度不變的 MATTR，門檻逐語言校準。
    //
    // 原本用原始 TTR 加固定門檻 0.40／0.65，有兩個獨立的缺陷：
    // 1. TTR 隨文件長度下降（同一篇論文 0.584 → 0.405），判定會隨長度漂移
    // 2. 門檻是英文詞級的值，套在中文字級上——`ttr < 0.40` 對中文真人的
    //    誤觸率 42.5%，對英文是 0%
    //
    // 只保留 AI 側：現代 LLM 的中文輸出 MATTR 0.783–0.802，高於真人中位
    // 0.669，把高多樣性當成人類證據會主動把 AI 推向人類。
    final lexical = LexicalCalibration.of(language.code);
    features['lexical_calibrated'] = lexical == null ? 0 : 1;
    if (lexical != null && text.allTokens.length >= 50) {
      final mattr = text.movingAverageTypeTokenRatio;
      features['mattr'] = mattr;
      if (mattr < lexical.aiCut) {
        final span = lexical.aiCut * 0.45;
        final distance = ((lexical.aiCut - mattr) / span).clamp(0.0, 1.0);
        addSignal('mattr', 0.61 + distance * 0.24, 0.20);
        reasons.add(l10n.engineReasonTtrLow(mattr.toStringAsFixed(2)));
      } else {
        reasons.add(
          l10n.engineReasonMattrNoAiSignal(
            mattr.toStringAsFixed(2),
            lexical.aiCut.toStringAsFixed(2),
          ),
        );
      }
    }

    // PAN 2025 corpus-calibrated compression coherence. This is independent of
    // vocabulary and logits, but intentionally one-sided and low weight.
    if (language.code == 'en') {
      final compression = CompressionProfile.analyze(text.analysisText);
      if (compression != null) {
        features['compression_coherence'] = compression.coherence;
        features['compression_human_95_cut'] =
            CompressionProfile.pan25Human95thPercentile;
        if (compression.supportsAi) {
          addSignal('compression', compression.aiRatio, 0.20);
          reasons.add(
            l10n.engineReasonCompressionCoherence(
              compression.coherence.toStringAsFixed(3),
            ),
          );
        }
      }
    }
    onProgress?.call(0.86);

    final fusion = _fuseSignals(signals);
    final clampedScore = fusion.aiRatio;
    features['statistical_signal_count'] = signals.length.toDouble();
    features['statistical_weighted_sum'] = fusion.weightedSum;
    features['statistical_active_weight'] = fusion.activeWeight;
    features['statistical_linear_ai_ratio'] = fusion.aiRatio;
    features['statistical_signal_strength'] = ((clampedScore - 0.5).abs() * 2)
        .clamp(0.0, 1.0);
    final summaryPercent = (clampedScore * 100).round();

    if (clampedScore >= 0.60) {
      reasons.insert(
        0,
        l10n.engineReasonStatisticalSummaryAi(summaryPercent.toString()),
      );
    } else if (clampedScore <= 0.40) {
      reasons.insert(
        0,
        l10n.engineReasonStatisticalSummaryHuman(summaryPercent.toString()),
      );
    } else if (reasons.isNotEmpty) {
      reasons.insert(
        0,
        l10n.engineReasonStatisticalSummaryNeutral(summaryPercent.toString()),
      );
    } else {
      reasons.add(l10n.engineReasonNeutral);
    }

    onProgress?.call(1);
    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: clampedScore,
      weight: defaultWeight,
      hasEvidence: signals.isNotEmpty,
      applicability: ppl != null
          ? EngineApplicability.validated
          : lexical != null
          ? EngineApplicability.plausible
          : EngineApplicability.unknown,
      // 裸困惑度即使有逐語言門檻，跨領域穩健度仍有限；只有啟發式回退時
      // 更不能和經驗證分類器等量齊觀。
      calibrationReliability: ppl != null
          ? 0.78
          : lexical != null
          ? 0.52
          : 0.32,
      features: features,
      reasons: reasons,
      // 這個角色底下同時可能跑兩個獨立模組：語言模型困惑度與詞彙指紋。
      // 只有實際算出結果的才列出——沒有模型時困惑度是缺席，不是「跑了但中性」。
      modules: [
        if (ppl != null)
          routedModelId ?? l10n.engineStatisticalPerplexityModule,
        if (lexical != null) l10n.engineStatisticalLexicalModule,
        if (ppl == null && lexical == null)
          l10n.engineStatisticalHeuristicModule,
      ],
    );
  }

  /// 將各統計矩陣的連續方向作線性累積。分子為 Σ(訊號比率 × 權重)，
  /// 分母只納入本次實際有效的矩陣權重；無效矩陣不會以 0.5 稀釋結果。
  static ({double aiRatio, double weightedSum, double activeWeight})
  _fuseSignals(
    List<({String feature, double aiRatio, double weight})> signals,
  ) {
    if (signals.isEmpty) {
      return (aiRatio: 0.5, weightedSum: 0, activeWeight: 0);
    }
    var weightedSum = 0.0;
    var activeWeight = 0.0;
    for (final signal in signals) {
      if (signal.weight <= 0) continue;
      weightedSum += signal.aiRatio * signal.weight;
      activeWeight += signal.weight;
    }
    if (activeWeight <= 0) {
      return (aiRatio: 0.5, weightedSum: 0, activeWeight: 0);
    }
    return (
      aiRatio: (weightedSum / activeWeight).clamp(0.0, 1.0),
      weightedSum: weightedSum,
      activeWeight: activeWeight,
    );
  }

  /// 這段文字的語言是否有可用的困惑度校準。
  ///
  /// 判斷完全交給 [PerplexityCalibration] 查表，不再由本引擎寫死語言清單：
  /// 新增一個語言＝跑一次 training/calibrate_perplexity.py 再加一列資料，
  /// 不必動判定邏輯。查不到就棄權——拿英文門檻去量中文，正是要杜絕的錯誤。
  static bool supportsPerplexity(
    String raw, {
    String modelId = defaultPerplexityModelId,
  }) =>
      PerplexityCalibration.of(detectLanguage(raw).code, modelId: modelId) !=
      null;

  /// 載入 [variantId] 指定的變體並計算困惑度。
  ///
  /// 刻意接受變體 id 而不是沿用「使用中」：路由已依文件語言挑過，這裡若再讀
  /// activeVariant，選出來的門檻與實際跑的模型就會是兩顆不同的東西。
  Future<double?> _tryPerplexity(String text, String? variantId) async {
    final mm = modelManager;
    if (mm == null || variantId == null) return null;
    final active = mm
        .installedVariants('statistical')
        .where((v) => v.variantId == variantId)
        .firstOrNull;
    if (active == null) return null;
    final modelPath = await mm.variantModelPath('statistical', variantId);
    final tokPath = await mm.variantTokenizerPath('statistical', variantId);
    if (modelPath == null || tokPath == null) return null;
    try {
      if (_scorer == null || _loadedPath != modelPath) {
        _scorer?.dispose();
        _scorer = await PerplexityScorer.load(
          modelPath: modelPath,
          tokenizerJsonPath: tokPath,
          // 多語 causal LM（Qwen 等）另需 KV cache 空張量的靜態維度；
          // DistilGPT2 不宣告 KV cache，此欄為 null。
          runtimeJson: active.runtimeJson,
        );
        _loadedPath = modelPath;
      }
      return await _scorer!.perplexity(text);
    } catch (_) {
      return null; // 載入/推論失敗 → 回退啟發式
    }
  }
}
