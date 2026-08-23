/// Binoculars 式交叉困惑度評分（引擎 B 的現代化核心）。
///
/// 裸 perplexity 的問題在於：它把「文字好不好預測」直接當成「像不像 AI」，
/// 因此對用詞平實、句構規律的**非母語寫作**有系統性偽陽性。
///
/// Binoculars 的作法是把分數除以一個「基準難度」：
///
///   B = log-perplexity(觀察者模型 M1 對文字的困惑度)
///       ────────────────────────────────────────────
///       cross-perplexity(M1 與 M2 對下一個詞的看法差多少)
///
/// 直覺是：一段文字對 M1 來說很好預測，本身不代表什麼——真正有訊號的是
/// 「它好預測的程度，相對於兩個模型彼此分歧的程度」。人類寫作即使平實，
/// 兩個模型仍會在許多位置分歧；機器生成的文字則同時對兩者都很好預測，
/// 於是分子小、分母也小但比值更低。**分數越低越像機器產出**（與直覺相反，
/// 實作時必須小心方向）。
///
/// 注意：本檔只實作評分數學，不含模型推論。要真正上線還需要一組可在瀏覽器
/// 執行的小型因果語言模型配對，並以標註資料驗證縮小模型後的效果——那是獨立
/// 的實證工作，尚未完成，因此本評分器目前未接上任何引擎。
library;

import 'dart:math' as math;

class BinocularsScorer {
  /// 觀察者模型對實際出現詞元的平均負對數機率（即 log-perplexity）。
  ///
  /// [observedLogProbs] 是每個位置上「實際出現的那個詞元」的 log 機率
  /// （自然對數，數值為負）。空輸入回傳 0。
  static double logPerplexity(List<double> observedLogProbs) {
    if (observedLogProbs.isEmpty) return 0;
    final sum = observedLogProbs.fold<double>(0, (a, b) => a + b);
    return -sum / observedLogProbs.length;
  }

  /// 兩個模型在每個位置上的交叉熵平均值。
  ///
  /// [observerProbs] 為 M1 在各位置對整個詞彙表的機率分布；
  /// [performerLogProbs] 為 M2 在對應位置的 log 機率分布。
  /// 兩者長度與各位置的詞彙表維度必須一致，否則丟出 [ArgumentError]——
  /// 靜默對齊只會產生看似合理但無意義的分數。
  static double crossPerplexity(
    List<List<double>> observerProbs,
    List<List<double>> performerLogProbs,
  ) {
    if (observerProbs.length != performerLogProbs.length) {
      throw ArgumentError(
        '兩個模型的位置數不一致：'
        '${observerProbs.length} vs ${performerLogProbs.length}',
      );
    }
    if (observerProbs.isEmpty) return 0;

    var total = 0.0;
    for (var i = 0; i < observerProbs.length; i++) {
      final p = observerProbs[i];
      final logQ = performerLogProbs[i];
      if (p.length != logQ.length) {
        throw ArgumentError(
          '第 $i 個位置的詞彙表維度不一致：'
          '${p.length} vs ${logQ.length}',
        );
      }
      var h = 0.0;
      for (var v = 0; v < p.length; v++) {
        // 機率為 0 的詞元對交叉熵貢獻為 0（0·log0 取極限為 0）
        if (p[v] > 0) h -= p[v] * logQ[v];
      }
      total += h;
    }
    return total / observerProbs.length;
  }

  /// Binoculars 分數 = log-perplexity ÷ cross-perplexity。
  /// 分母為 0（兩模型完全一致，理論上不會發生）時回傳 null，
  /// 讓呼叫端據此棄權，而不是回一個無限大的假分數。
  static double? score({
    required double logPerplexityValue,
    required double crossPerplexityValue,
  }) {
    if (!crossPerplexityValue.isFinite || crossPerplexityValue.abs() < 1e-9) {
      return null;
    }
    final s = logPerplexityValue / crossPerplexityValue;
    return s.isFinite ? s : null;
  }

  /// 論文建議的判定方向：**分數低於門檻即判為機器產出**。
  /// [threshold] 需以標註資料校準，此處的預設值僅為佔位，
  /// 未經本專案模型驗證前不應當成定論。
  static const double placeholderThreshold = 0.9;

  /// 把 Binoculars 分數映射為 0–1 的 AI 機率，供集成投票使用。
  ///
  /// 以 logistic 曲線平滑轉換並**反向**（分數越低→機率越高）：
  ///   p = 1 / (1 + exp((score − threshold) / temperature))
  /// [temperature] 控制過渡帶寬度，越小越接近硬性切斷。
  static double toAiProbability(
    double score, {
    double threshold = placeholderThreshold,
    double temperature = 0.05,
  }) {
    if (!score.isFinite) return 0.5;
    final t = temperature.abs() < 1e-9 ? 1e-9 : temperature;
    final z = (score - threshold) / t;
    // 先夾住指數的輸入，避免極端值造成 overflow 產生 NaN
    final clamped = z.clamp(-40.0, 40.0);
    return 1 / (1 + math.exp(clamped));
  }
}
