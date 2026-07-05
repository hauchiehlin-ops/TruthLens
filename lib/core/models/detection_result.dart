/// 檢測結果資料模型 — 對應 docs/implementation_plan.md 模組 1 的輸出結構。
library;

import '../../l10n/generated/app_localizations.dart';

/// 五級分類（依整體 AI 機率劃分）
enum Verdict {
  human, // 🟢 人類撰寫 (aiProbability < 0.20)
  likelyHuman, // 🟡 可能人類 (0.20 - 0.40)
  mixed, // 🟠 混合內容 (0.40 - 0.60)
  likelyAi, // 🔴 可能 AI (0.60 - 0.80)
  ai; // ⛔ AI 生成 (> 0.80)

  static Verdict fromProbability(double p) {
    if (p < 0.20) return Verdict.human;
    if (p < 0.40) return Verdict.likelyHuman;
    if (p < 0.60) return Verdict.mixed;
    if (p < 0.80) return Verdict.likelyAi;
    return Verdict.ai;
  }

  /// 判定結果的顯示文字，依 [l10n] 語系呈現。
  String label(AppLocalizations l10n) => switch (this) {
        Verdict.human => l10n.verdictHuman,
        Verdict.likelyHuman => l10n.verdictLikelyHuman,
        Verdict.mixed => l10n.verdictMixed,
        Verdict.likelyAi => l10n.verdictLikelyAi,
        Verdict.ai => l10n.verdictAi,
      };
}

/// 單一子模型（引擎）的評分結果
class EngineScore {
  final String engineId; // transformer / statistical / stylometry / adversarial
  final String engineName;
  final double aiProbability; // 0.0 (人類) - 1.0 (AI)
  final double weight; // 集成投票權重
  final bool available; // 模型是否已安裝可用
  final Map<String, double> features; // 可解釋特徵值（供報告呈現）
  final List<String> reasons; // 人類可讀的判定理由
  final List<double>? sentenceScores; // 句子級 AI 機率（有神經模型時提供）

  const EngineScore({
    required this.engineId,
    required this.engineName,
    required this.aiProbability,
    required this.weight,
    this.available = true,
    this.features = const {},
    this.reasons = const [],
    this.sentenceScores,
  });
}

/// 句子級分析結果
class SentenceScore {
  final int index;
  final String text;
  final double aiProbability;
  final List<String> patterns; // 命中的 AI 寫作模式

  const SentenceScore({
    required this.index,
    required this.text,
    required this.aiProbability,
    this.patterns = const [],
  });
}

/// 完整檢測結果
class DetectionResult {
  final String id;
  final DateTime analyzedAt;
  final String inputText;
  final double aiProbability; // 加權投票後的整體 AI 機率
  final Verdict verdict;
  final List<EngineScore> engineScores;
  final List<SentenceScore> sentences;
  final List<String> dominantPatterns;
  final bool eslAdjusted; // 是否套用了 ESL 偏差修正
  final double threshold; // 本次採用的 AI 判定信心閾值
  final Duration elapsed;

  const DetectionResult({
    required this.id,
    required this.analyzedAt,
    required this.inputText,
    required this.aiProbability,
    required this.verdict,
    required this.engineScores,
    required this.sentences,
    this.dominantPatterns = const [],
    this.eslAdjusted = false,
    this.threshold = 0.6,
    this.elapsed = Duration.zero,
  });

  /// 是否越過使用者設定的信心閾值而被明確標記為 AI。
  /// 閾值調高 → 需更高信心才標記 → 降低偽陽性（誤判人類文章）。
  bool get flaggedAsAi => aiProbability >= threshold;

  int get aiSentenceCount =>
      sentences.where((s) => s.aiProbability >= 0.6).length;
  int get humanSentenceCount =>
      sentences.where((s) => s.aiProbability < 0.4).length;
}
