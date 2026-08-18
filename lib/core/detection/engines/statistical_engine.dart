import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
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

    // 若真困惑度模型可用，優先納入（低困惑度 → 偏 AI）。
    // 但只在困惑度模型看得懂的語言上採計——見 [supportsPerplexity]。
    final pplUsable = supportsPerplexity(text.raw);
    final ppl = pplUsable ? await _tryPerplexity(text.raw) : null;
    if (!pplUsable) {
      reasons.add(l10n.engineReasonPplUncalibratedLanguage);
    }
    if (ppl != null) {
      features['perplexity'] = ppl;
      // 門檻沿用英文校準值。以 HC3 英文語料實測（training/calibrate_perplexity.py）：
      // 門檻 60 之下有 100% 的 AI 樣本與 40.7% 的真人樣本，區別力 59.3 個百分點。
      // 註：舊註解宣稱「人類口語 ~500+」，實測不成立，英文真人中位數為 65.6（fp32）。
      if (ppl < 60) {
        score += 0.28;
        moved = true;
        reasons.add(l10n.engineReasonPplLow(ppl.toStringAsFixed(0)));
      } else if (ppl > 150) {
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

  /// 困惑度模型（DistilGPT2）是否看得懂這段文字。
  ///
  /// DistilGPT2 只在英文語料上訓練，tokenizer 是英文 byte-level BPE。中日韓文
  /// 進去只會被拆成 UTF-8 位元組，算出來的是「位元組有多好預測」，不是
  /// 「語言有多好預測」——兩者無關。
  ///
  /// 這不是保守起見，是實測結論。以 HC3 中文語料實測（training/calibrate_perplexity.py，
  /// 每類 300 筆）：現行門檻 60 之下，真人樣本佔 100%、AI 樣本也佔 100%，
  /// 區別力 0.0%。production 管線同樣如此——一篇中文真人文章量到 41、
  /// 一篇中文 AI 文章量到 46，兩者皆低於 60 且順序相反。
  ///
  /// 因此 CJK 文本一律不採計困惑度：一個對 100% 真人文章都喊「偏 AI」的指標，
  /// 留著只會製造偽陽性。要恢復這項指標，需要換上看得懂中文的語言模型，
  /// 並用同一條 production 推論管線重新校準門檻。
  static bool supportsPerplexity(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return false;
    final cjk = RegExp(r'[㐀-䶿一-鿿぀-ヿ가-힯]').allMatches(trimmed).length;
    // 少量 CJK（引用的專有名詞、夾雜的詞彙）不影響英文本文的困惑度判讀
    return cjk / trimmed.length < 0.10;
  }

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
