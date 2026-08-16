/// 檢測結果資料模型 — 對應 docs/implementation_plan.md 模組 1 的輸出結構。
library;

import '../../l10n/generated/app_localizations.dart';
import '../utils/text_stats.dart';

/// 五級分類（依整體 AI 機率與使用者可調的 AI 標記門檻閾值劃分）
enum Verdict {
  human, // 🟢 人類撰寫
  likelyHuman, // 🟡 可能人類
  mixed, // 🟠 混合內容
  likelyAi, // 🔴 可能 AI
  ai; // ⛔ AI 生成

  /// 四個分級切點，以 [threshold]（AI 標記門檻閾值）為中心、按左右兩側可用
  /// 空間等比例縮放，確保無論門檻設在哪裡，五個等級永遠都有非零區間。
  /// 門檻為 0.5（預設值）時，切點恰為原本寫死的 0.2/0.4/0.6/0.8。
  static List<double> cutPoints(double threshold) {
    final t = threshold.clamp(0.0, 1.0);
    return [t * 0.4, t * 0.8, t + (1 - t) * 0.2, t + (1 - t) * 0.6];
  }

  static Verdict fromProbability(double p, double threshold) {
    final cuts = cutPoints(threshold);
    if (p < cuts[0]) return Verdict.human;
    if (p < cuts[1]) return Verdict.likelyHuman;
    if (p < cuts[2]) return Verdict.mixed;
    if (p < cuts[3]) return Verdict.likelyAi;
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

  EngineScore copyWith({double? weight}) => EngineScore(
    engineId: engineId,
    engineName: engineName,
    aiProbability: aiProbability,
    weight: weight ?? this.weight,
    available: available,
    features: features,
    reasons: reasons,
    sentenceScores: sentenceScores,
  );
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
  final String sourceFileName;
  final double aiProbability; // 加權投票後的整體 AI 機率
  final Verdict verdict;
  final List<EngineScore> engineScores;
  final List<SentenceScore> sentences;
  final List<String> dominantPatterns;
  final bool eslAdjusted; // 是否套用了 ESL 偏差修正
  final double threshold; // 本次採用的 AI 判定信心閾值
  final Duration elapsed;
  final int availableEngineCount; // 本次參與投票的引擎數
  final int totalEngineCount; // 註冊的引擎總數

  const DetectionResult({
    required this.id,
    required this.analyzedAt,
    required this.inputText,
    this.sourceFileName = '',
    required this.aiProbability,
    required this.verdict,
    required this.engineScores,
    required this.sentences,
    this.dominantPatterns = const [],
    this.eslAdjusted = false,
    this.threshold = 0.6,
    this.elapsed = Duration.zero,
    this.availableEngineCount = 0,
    this.totalEngineCount = 0,
  });

  /// 計算可用引擎數（available=true 的引擎）
  int get _computeAvailableCount =>
      engineScores.where((e) => e.available).length;

  /// 計算使用中的總權重（只計算 available 引擎的權重）
  double get _computeUsedWeight => engineScores
      .where((e) => e.available)
      .fold<double>(0, (sum, e) => sum + e.weight);

  /// 計算理想的總權重（所有引擎）
  double get _computeTotalWeight =>
      engineScores.fold<double>(0, (sum, e) => sum + e.weight);

  /// 檢查是否為低信心分析：
  /// 只有在引擎投票數極度不足時才認為信心度低
  /// - 可用引擎 < 2 個（無法多角度驗證）
  bool get isLowConfidence {
    final availableCount = _computeAvailableCount;

    // 只有在引擎數量不足時才判為低信心度
    // （權重不平衡屬於正常情況，不應降低信心度）
    if (availableCount < 2) return true;

    return false;
  }

  /// 是否越過使用者設定的信心閾值而被明確標記為 AI。
  /// 閾值調高 → 需更高信心才標記 → 降低偽陽性（誤判人類文章）。
  bool get flaggedAsAi => aiProbability >= threshold;

  double effectiveWeightFor(EngineScore score) {
    final statistical =
        score.engineId == 'statistical' ||
        score.engineId.startsWith('statistical_');
    return eslAdjusted && statistical ? score.weight * 0.5 : score.weight;
  }

  double get _activeEffectiveWeight => engineScores
      .where((score) => score.available)
      .fold<double>(0, (sum, score) => sum + effectiveWeightFor(score));

  double contributionFor(EngineScore score) {
    final total = _activeEffectiveWeight;
    if (!score.available || total <= 0) return 0;
    return score.aiProbability * effectiveWeightFor(score) / total;
  }

  /// 將各引擎的完整精度貢獻換算為整數百分點，同時保證加總恰好等於
  /// 畫面顯示的整體 AI 百分比，避免逐列四捨五入造成 20% 對 23% 的矛盾。
  Map<String, int> get roundedEngineContributionPoints {
    final active = engineScores.where((score) => score.available).toList();
    if (active.isEmpty || _activeEffectiveWeight <= 0) return const {};

    final exact = <String, double>{
      for (final score in active) score.engineId: contributionFor(score) * 100,
    };
    final points = <String, int>{
      for (final entry in exact.entries) entry.key: entry.value.floor(),
    };
    var remaining =
        (aiProbability * 100).round() -
        points.values.fold<int>(0, (sum, value) => sum + value);
    final order = exact.keys.toList()
      ..sort((a, b) {
        final aFraction = exact[a]! - exact[a]!.floor();
        final bFraction = exact[b]! - exact[b]!.floor();
        return bFraction.compareTo(aFraction);
      });

    for (var i = 0; remaining > 0 && order.isNotEmpty; i++, remaining--) {
      final id = order[i % order.length];
      points[id] = points[id]! + 1;
    }
    for (var i = 0; remaining < 0 && order.isNotEmpty; i++) {
      final id = order.reversed.elementAt(i % order.length);
      if (points[id]! <= 0) {
        if (points.values.every((value) => value <= 0)) break;
        continue;
      }
      points[id] = points[id]! - 1;
      remaining++;
    }
    return points;
  }

  /// 生成低信心分析的警告消息（用戶友好）
  String lowConfidenceWarning() {
    final reasons = <String>[];

    final availableCount = _computeAvailableCount;
    final usedWeight = _computeUsedWeight;
    final totalWeight = _computeTotalWeight;
    final confidenceRatio = totalWeight > 0 ? (usedWeight / totalWeight) : 0.0;

    if (availableCount < 2) {
      reasons.add('只有 $availableCount 個模型參與分析（建議至少 2 個）');
    }

    if (totalWeight > 0 && confidenceRatio < 0.60) {
      reasons.add(
        '引擎權重覆蓋不足：${(confidenceRatio * 100).toStringAsFixed(0)}% '
        '（建議 ≥60%）',
      );
    }

    if (reasons.isEmpty) {
      return '';
    }

    return '⚠️ 此分析信心度較低，原因：${reasons.join('；')}。'
        '建議查看「設定」中的模型狀態，下載或修復缺失的模型。';
  }

  int get aiSentenceCount => sentences
      .where(
        (s) =>
            PreprocessedText.isAnalyzableSentence(s.text) &&
            s.aiProbability >= 0.6,
      )
      .length;
  int get analyzableSentenceCount => sentences
      .where((s) => PreprocessedText.isAnalyzableSentence(s.text))
      .length;
  int get humanSentenceCount => sentences
      .where(
        (s) =>
            PreprocessedText.isAnalyzableSentence(s.text) &&
            s.aiProbability < 0.6,
      )
      .length;
  int get strictAiSentenceCount => sentences
      .where(
        (s) =>
            PreprocessedText.isAnalyzableSentence(s.text) &&
            s.aiProbability >= 0.6,
      )
      .length;
  int get strictHumanSentenceCount => sentences
      .where(
        (s) =>
            PreprocessedText.isAnalyzableSentence(s.text) &&
            s.aiProbability < 0.4,
      )
      .length;
}
