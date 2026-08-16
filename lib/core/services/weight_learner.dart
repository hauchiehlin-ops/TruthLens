/// 由本地基準集學出引擎權重。
///
/// 為什麼不是邏輯迴歸：現有集成是「加權平均」
/// （overall = Σ wᵢ·pᵢ / Σ wᵢ，且 wᵢ ≥ 0、總和為 1），而邏輯迴歸的係數可正可負、
/// 尺度也不受限，硬塞回加權平均會失去原本的意義與可解釋性。
///
/// 這裡改用**效果量（Cohen's d）**衡量每個引擎把「已知人類」與「已知 AI」
/// 兩組分開的能力：分得越開、組內越穩定的引擎，權重越高。優點是小樣本下
/// 穩定、不需迭代最佳化、而且一句話就能解釋給使用者聽。
library;

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'calibration_service.dart';

@immutable
class EngineSeparation {
  final String engineId;

  /// Cohen's d：(AI 組平均 − 人類組平均) / 合併標準差。
  /// 為正代表該引擎確實把 AI 判得比人類高；為負代表方向相反（判反了）。
  final double effectSize;

  final double humanMean;
  final double aiMean;

  /// 由效果量正規化而得的建議權重（總和為 1）
  final double suggestedWeight;

  const EngineSeparation({
    required this.engineId,
    required this.effectSize,
    required this.humanMean,
    required this.aiMean,
    required this.suggestedWeight,
  });
}

@immutable
class LearnedWeights {
  final Map<String, double> weights;
  final List<EngineSeparation> separations;
  final int humanCount;
  final int aiCount;

  const LearnedWeights({
    required this.weights,
    required this.separations,
    required this.humanCount,
    required this.aiCount,
  });

  bool get isEmpty => weights.isEmpty;
}

class WeightLearner {
  /// 每一類至少需要的樣本數。低於此值時效果量的估計太不穩定，
  /// 學出來的權重可能比手調的還差，因此寧可不學。
  static const int minSamplesPerClass = 10;

  /// 兩類樣本數是否足以學習
  static bool canLearn(int humanCount, int aiCount) =>
      humanCount >= minSamplesPerClass && aiCount >= minSamplesPerClass;

  /// 從基準集學出權重；樣本不足或沒有任何引擎有正向鑑別力時回傳 null。
  ///
  /// [engineIds] 為要學習的引擎清單（通常是 PreferencesService.engineRoles）。
  static LearnedWeights? learn(
    List<CalibrationSample> samples,
    List<String> engineIds,
  ) {
    final human = samples.where((s) => !s.isAi).toList();
    final ai = samples.where((s) => s.isAi).toList();
    if (!canLearn(human.length, ai.length)) return null;

    final separations = <EngineSeparation>[];
    for (final id in engineIds) {
      final humanScores = human
          .map((s) => s.engineScores[id])
          .whereType<double>()
          .toList();
      final aiScores = ai
          .map((s) => s.engineScores[id])
          .whereType<double>()
          .toList();
      // 舊樣本沒存逐引擎分數，資料不足的引擎直接跳過
      if (humanScores.length < minSamplesPerClass ||
          aiScores.length < minSamplesPerClass) {
        continue;
      }

      final hMean = _mean(humanScores);
      final aMean = _mean(aiScores);
      separations.add(
        EngineSeparation(
          engineId: id,
          effectSize: cohensD(humanScores, aiScores),
          humanMean: hMean,
          aiMean: aMean,
          suggestedWeight: 0, // 稍後正規化
        ),
      );
    }
    if (separations.isEmpty) return null;

    // 只有正向鑑別力才配得到權重；方向判反的引擎給 0，不倒扣
    // （負權重會讓加權平均失去「機率」的語意）。
    final positive = separations
        .map((s) => math.max(0.0, s.effectSize))
        .toList();
    final total = positive.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return null;

    final weights = <String, double>{};
    final withWeights = <EngineSeparation>[];
    for (var i = 0; i < separations.length; i++) {
      final w = positive[i] / total;
      weights[separations[i].engineId] = w;
      withWeights.add(
        EngineSeparation(
          engineId: separations[i].engineId,
          effectSize: separations[i].effectSize,
          humanMean: separations[i].humanMean,
          aiMean: separations[i].aiMean,
          suggestedWeight: w,
        ),
      );
    }

    return LearnedWeights(
      weights: weights,
      separations: withWeights,
      humanCount: human.length,
      aiCount: ai.length,
    );
  }

  /// Cohen's d，以合併標準差正規化。兩組都無變異時退回 0（無從判斷鑑別力）。
  static double cohensD(List<double> human, List<double> ai) {
    if (human.isEmpty || ai.isEmpty) return 0;
    final hVar = _variance(human);
    final aVar = _variance(ai);
    final n1 = human.length;
    final n2 = ai.length;
    if (n1 + n2 <= 2) return 0;
    final pooled = math.sqrt(
      ((n1 - 1) * hVar + (n2 - 1) * aVar) / (n1 + n2 - 2),
    );
    final diff = _mean(ai) - _mean(human);
    if (pooled <= 1e-12) {
      // 完全沒有組內變異：只要平均有差就是完美分離，給一個大但有限的值
      return diff == 0 ? 0 : (diff > 0 ? 10.0 : -10.0);
    }
    return diff / pooled;
  }

  static double _mean(List<double> xs) =>
      xs.fold<double>(0, (a, b) => a + b) / xs.length;

  static double _variance(List<double> xs) {
    if (xs.length < 2) return 0;
    final m = _mean(xs);
    return xs.fold<double>(0, (a, b) => a + (b - m) * (b - m)) /
        (xs.length - 1);
  }
}
