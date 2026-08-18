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
    final language = detectLanguage(text.raw);
    final calibration = PerplexityCalibration.of(language.code);
    final ppl = calibration != null ? await _tryPerplexity(text.raw) : null;
    if (calibration == null) {
      reasons.add(l10n.engineReasonPplUncalibratedLanguage);
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
  static bool supportsPerplexity(String raw) =>
      PerplexityCalibration.of(detectLanguage(raw).code) != null;

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
        );
        _loadedPath = modelPath;
      }
      return await _scorer!.perplexity(text);
    } catch (_) {
      return null; // 載入/推論失敗 → 回退啟發式
    }
  }
}
