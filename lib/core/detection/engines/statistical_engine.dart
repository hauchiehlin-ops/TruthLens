import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/language_id.dart';
import '../../utils/text_stats.dart';
import '../perplexity_calibration.dart';
import '../detection_engine.dart';
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
    AppLocalizations l10n,
  ) async {
    final burstiness = text.burstiness;
    final ttr = text.typeTokenRatio;
    final entropy = text.entropy;

    final reasons = <String>[];
    final features = <String, double>{
      'burstiness': burstiness,
      'type_token_ratio': ttr,
      'entropy': entropy,
    };
    var score = 0.5;
    // 本引擎的中性點是 0.5，可正可負；moved 記錄有沒有任何指標真的把它推離中性。
    // 三個指標全部落在中間帶時輸出的 0.5 是「沒有意見」，不是「一半像 AI」。
    var moved = false;

    // 困惑度只在「這個語言有實測門檻」時採計。門檻來自 PerplexityCalibration
    // 查表，而不是寫死的常數：困惑度的尺度隨語言而變（同一顆 DistilGPT2，
    // production 量到英文真人 304、中文 41），套錯門檻就是製造偽陽性。
    // 語言由 PreprocessedText 統一提供，不各自重算——各引擎若拿到不同的
    // 語言判定，校準查表與模型路由就會互相矛盾。
    final language = text.language;
    // 門檻綁定「模型 × 語言」，所以要查的是**目前使用中**那顆模型的門檻。
    // 使用者自行匯入的模型沒有校準資料，查不到就不採計此指標——
    // 沿用別顆模型的門檻等於在未知尺度上下結論。
    final calibration = PerplexityCalibration.of(
      language.code,
      modelId: modelManager?.activeVariant('statistical')?.variantId ??
          defaultPerplexityModelId,
    );
    final ppl = calibration != null ? await _tryPerplexity(text.raw) : null;
    if (calibration == null) {
      // 三種「不採計」的原因對使用者的意義完全不同，必須分開講。
      // 先前一律套用中日韓文那段說明，結果一篇英文論文被告知
      // 「對中日韓文而言……」——訊息本身就在誤導。
      final modelId =
          modelManager?.activeVariant('statistical')?.variantId ??
          defaultPerplexityModelId;
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
        score += 0.28;
        moved = true;
        reasons.add(l10n.engineReasonPplLow(ppl.toStringAsFixed(0)));
      } else if (ppl > calibration.humanCut) {
        score -= 0.25;
        moved = true;
        reasons.add(l10n.engineReasonPplHigh(ppl.toStringAsFixed(0)));
      } else {
        reasons.add(l10n.engineReasonPplMid(ppl.toStringAsFixed(0)));
      }
    }

    // Burstiness：人類句長起伏大；AI 節奏均勻
    if (text.sentences.length >= 4) {
      if (burstiness < 0.30) {
        score += 0.20;
        moved = true;
        reasons.add(
          l10n.engineReasonBurstinessLow(burstiness.toStringAsFixed(2)),
        );
      } else if (burstiness > 0.55) {
        score -= 0.20;
        moved = true;
        reasons.add(
          l10n.engineReasonBurstinessHigh(burstiness.toStringAsFixed(2)),
        );
      }
    }

    // 詞彙多樣性：AI 文本 TTR 常偏低
    if (text.allTokens.length >= 50) {
      if (ttr < 0.40) {
        score += 0.10;
        moved = true;
        reasons.add(l10n.engineReasonTtrLow(ttr.toStringAsFixed(2)));
      } else if (ttr > 0.65) {
        score -= 0.10;
        moved = true;
        reasons.add(l10n.engineReasonTtrHigh(ttr.toStringAsFixed(2)));
      }
    }

    final clampedScore = score.clamp(0.0, 1.0);
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

    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: clampedScore,
      weight: defaultWeight,
      hasEvidence: moved,
      features: features,
      reasons: reasons,
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
  }) => PerplexityCalibration.of(detectLanguage(raw).code, modelId: modelId) !=
      null;

  Future<double?> _tryPerplexity(String text) async {
    final mm = modelManager;
    if (mm == null) return null;
    final active = mm.activeVariant('statistical');
    if (active == null) return null;
    final modelPath = await mm.activeModelPath('statistical');
    final tokPath = await mm.activeTokenizerPath('statistical');
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
