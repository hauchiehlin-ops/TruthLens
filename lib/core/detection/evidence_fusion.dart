/// 以適用性、證據家族與獨立校準可靠度融合文字引擎。
///
/// 這不是另一個手工堆分器：同一家族先合併，避免相關模型重複投票；權重只由
/// 驗證範圍與覆蓋率決定，絕不因本次分數較高而自動變重。
library;

import 'dart:math' as math;

import '../models/detection_result.dart';
import 'analysis_profile.dart';

enum TextAuthorshipClass { likelyHuman, likelyAiAssisted, likelyAiGenerated }

class FamilyEvidence {
  final EvidenceFamily family;
  final double probability;
  final double reliability;
  final double configuredWeight;
  final int engineCount;
  final bool supportsAi;
  final bool supportsHuman;
  final bool directTrace;

  const FamilyEvidence({
    required this.family,
    required this.probability,
    required this.reliability,
    required this.configuredWeight,
    required this.engineCount,
    required this.supportsAi,
    required this.supportsHuman,
    required this.directTrace,
  });
}

class TextEvidenceFusion {
  final double probability;
  final double reliability;
  final double applicabilityCoverage;
  final double evidenceCoverage;
  final double conflictRatio;
  final double aiWindowRatio;
  final double stabilityScore;
  final double lowerBound;
  final double upperBound;
  final int stabilitySegmentCount;
  final int aiSupportingFamilies;
  final int humanSupportingFamilies;
  final bool passesAiEvidenceGate;
  final bool mixedAuthorship;
  final bool hasDirectTrace;
  final TextAuthorshipClass authorshipClass;
  final List<FamilyEvidence> families;

  const TextEvidenceFusion({
    required this.probability,
    required this.reliability,
    required this.applicabilityCoverage,
    required this.evidenceCoverage,
    required this.conflictRatio,
    required this.aiWindowRatio,
    required this.stabilityScore,
    required this.lowerBound,
    required this.upperBound,
    required this.stabilitySegmentCount,
    required this.aiSupportingFamilies,
    required this.humanSupportingFamilies,
    required this.passesAiEvidenceGate,
    required this.mixedAuthorship,
    required this.hasDirectTrace,
    required this.authorshipClass,
    required this.families,
  });

  factory TextEvidenceFusion.evaluate({
    required List<EngineScore> scores,
    required String inputText,
    List<SentenceScore> sentences = const [],
    AnalysisProfile? profile,
    double extractionQuality = 1,
    bool eslAdjusted = false,
  }) {
    final documentProfile = profile ?? AnalysisProfile.fromText(inputText);
    final usable = scores
        .where(
          (score) =>
              score.available &&
              score.applicability != EngineApplicability.unsupported &&
              score.calibrationReliability > 0,
        )
        .toList();
    final grouped = <EvidenceFamily, List<EngineScore>>{};
    for (final score in usable) {
      grouped.putIfAbsent(score.resolvedEvidenceFamily, () => []).add(score);
    }

    final familyEvidence = <FamilyEvidence>[];
    var applicabilityWeight = 0.0;
    var evidenceWeight = 0.0;

    for (final entry in grouped.entries) {
      final family = entry.key;
      final engines = entry.value;
      // 使用者設定的是家族權重上限。同一家族即使有多顆變體，也只能取一次
      // 設定值，不能把相關模型的權重相加後放大。
      final cap = engines
          .map((score) => score.weight)
          .fold<double>(0, math.max)
          .clamp(0.0, 1.0);
      final domainFactor = documentProfile.domainReliability(family);
      final availableReliability = engines
          .map((score) => score.evidenceWeightMultiplier * domainFactor)
          .fold<double>(0, math.max)
          .clamp(0.0, 1.0);
      applicabilityWeight += cap * availableReliability;

      final evidential = engines.where((score) => score.votes).toList();
      if (evidential.isEmpty) continue;
      var weightedProbability = 0.0;
      var totalReliability = 0.0;
      var direct = false;
      for (final score in evidential) {
        final eslFactor = eslAdjusted && family == EvidenceFamily.distributional
            ? 0.5
            : 1.0;
        final engineReliability =
            score.evidenceWeightMultiplier * domainFactor * eslFactor;
        weightedProbability +=
            _normalizedProbability(score) * engineReliability;
        totalReliability += engineReliability;
        direct =
            direct ||
            (score.features['assistant_response_artifacts'] ?? 0) >= 2 ||
            (score.features['verified_watermark'] ?? 0) >= 1 ||
            (score.features['verified_ai_provenance'] ?? 0) >= 1;
      }
      if (totalReliability <= 0) continue;
      final rawProbability = weightedProbability / totalReliability;
      final familyReliability = (totalReliability / evidential.length).clamp(
        0.0,
        1.0,
      );
      final probability = (0.5 + (rawProbability - 0.5) * familyReliability)
          .clamp(0.0, 1.0);
      final supportsAi = probability >= 0.62;
      final supportsHuman = probability <= 0.38;
      if (!supportsAi && !supportsHuman && !direct) continue;
      evidenceWeight += cap * familyReliability;
      familyEvidence.add(
        FamilyEvidence(
          family: family,
          probability: direct ? math.max(probability, 0.98) : probability,
          reliability: familyReliability,
          configuredWeight: cap,
          engineCount: evidential.length,
          supportsAi: supportsAi || direct,
          supportsHuman: supportsHuman && !direct,
          directTrace: direct,
        ),
      );
    }

    final aiFamilies = familyEvidence.where((family) => family.supportsAi);
    final humanFamilies = familyEvidence.where(
      (family) => family.supportsHuman,
    );
    final directTrace = familyEvidence.any((family) => family.directTrace);
    final strongSingleFamily = familyEvidence.any(
      (family) =>
          family.supportsAi &&
          family.probability >= 0.90 &&
          family.reliability >= 0.80 &&
          (family.family == EvidenceFamily.supervisedClassifier ||
              family.family == EvidenceFamily.distributional),
    );
    final passesGate =
        directTrace || aiFamilies.length >= 2 || strongSingleFamily;

    var probability = 0.5;
    if (familyEvidence.isNotEmpty) {
      var weightedLogOdds = 0.0;
      var totalWeight = 0.0;
      for (final family in familyEvidence) {
        final p = family.probability.clamp(0.02, 0.98);
        final weight = family.configuredWeight * family.reliability;
        weightedLogOdds += math.log(p / (1 - p)) * weight;
        totalWeight += weight;
      }
      if (totalWeight > 0) {
        probability = 1 / (1 + math.exp(-(weightedLogOdds / totalWeight)));
      }
    }
    final positive = familyEvidence
        .where((family) => family.supportsAi)
        .fold<double>(0, (sum, family) => sum + family.reliability);
    final negative = familyEvidence
        .where((family) => family.supportsHuman)
        .fold<double>(0, (sum, family) => sum + family.reliability);
    final directional = positive + negative;
    final conflict = directional == 0
        ? 0.0
        : 2 * math.min(positive, negative) / directional;

    final window = _windowEvidence(scores, sentences);
    final mixed =
        passesGate &&
        window.analyzable >= 5 &&
        window.aiRatio >= 0.15 &&
        window.aiRatio <= 0.78 &&
        window.humanRatio >= 0.15;
    final diversity = switch (familyEvidence.length) {
      >= 3 => 1.0,
      2 => 0.78,
      1 => directTrace ? 0.90 : 0.46,
      _ => 0.15,
    };
    final applicabilityCoverage = applicabilityWeight.clamp(0.0, 1.0);
    final evidenceCoverage = evidenceWeight.clamp(0.0, 1.0);
    final reportedSentenceQuality = switch (sentences.length) {
      >= 10 => 1.0,
      >= 5 => 0.78,
      >= 3 => 0.48,
      _ => 0.0,
    };
    final reportedLengthQuality = switch (documentProfile.wordCount) {
      >= 500 => 1.0,
      >= 250 => 0.90,
      >= 100 => 0.72,
      >= 50 => 0.42,
      _ => 0.18,
    };
    final textualInputQuality = math.max(
      documentProfile.inputQuality,
      reportedSentenceQuality * reportedLengthQuality,
    );
    final inputQuality =
        textualInputQuality * extractionQuality.clamp(0.0, 1.0);
    final reliability =
        (inputQuality *
                (0.45 +
                    applicabilityCoverage * 0.30 +
                    evidenceCoverage * 0.25) *
                diversity *
                (0.65 + window.stability * 0.35) *
                (1 - conflict * 0.65))
            .clamp(0.0, 1.0);
    final authorshipClass = mixed
        ? TextAuthorshipClass.likelyAiAssisted
        : probability > 0.5
        ? TextAuthorshipClass.likelyAiGenerated
        : TextAuthorshipClass.likelyHuman;

    return TextEvidenceFusion(
      probability: probability,
      reliability: reliability,
      applicabilityCoverage: applicabilityCoverage,
      evidenceCoverage: evidenceCoverage,
      conflictRatio: conflict,
      aiWindowRatio: window.aiRatio,
      stabilityScore: window.stability,
      lowerBound: window.lowerBound,
      upperBound: window.upperBound,
      stabilitySegmentCount: window.analyzable,
      aiSupportingFamilies: aiFamilies.length,
      humanSupportingFamilies: humanFamilies.length,
      passesAiEvidenceGate: passesGate,
      mixedAuthorship: mixed,
      hasDirectTrace: directTrace,
      authorshipClass: authorshipClass,
      families: familyEvidence,
    );
  }

  /// 風格與改寫引擎的原始分數是「命中特徵的強度」，0 代表沉默而不是人類。
  /// 一旦有證據，將其映射到 AI 側；統計與二元分類器則保留原機率方向。
  static double _normalizedProbability(EngineScore score) {
    if ((score.features['assistant_response_artifacts'] ?? 0) >= 2) {
      return 0.99;
    }
    return switch (score.resolvedEvidenceFamily) {
      EvidenceFamily.stylometric || EvidenceFamily.rewriteTrace =>
        0.5 + score.aiProbability.clamp(0.0, 1.0) * 0.5,
      _ => score.aiProbability.clamp(0.0, 1.0),
    };
  }

  static ({
    int analyzable,
    double aiRatio,
    double humanRatio,
    double stability,
    double lowerBound,
    double upperBound,
  })
  _windowEvidence(List<EngineScore> scores, List<SentenceScore> fallback) {
    final perEngine = scores
        .where(
          (score) =>
              score.votes &&
              score.sentenceScores != null &&
              score.sentenceScores!.isNotEmpty,
        )
        .toList();
    final length = perEngine.isEmpty
        ? fallback.length
        : perEngine
              .map((score) => score.sentenceScores!.length)
              .reduce(math.max);
    if (length == 0) {
      return (
        analyzable: 0,
        aiRatio: 0,
        humanRatio: 0,
        stability: 0,
        lowerBound: 0,
        upperBound: 1,
      );
    }
    var ai = 0;
    var human = 0;
    var analyzable = 0;
    final segmentProbabilities = <double>[];
    for (var i = 0; i < length; i++) {
      final values = <double>[];
      for (final score in perEngine) {
        if (i < score.sentenceScores!.length) {
          values.add(score.sentenceScores![i]);
        }
      }
      if (values.isEmpty && i < fallback.length) {
        values.add(fallback[i].aiProbability);
      }
      if (values.isEmpty) continue;
      analyzable++;
      final average = values.reduce((a, b) => a + b) / values.length;
      segmentProbabilities.add(average);
      if (average >= 0.65) ai++;
      if (average <= 0.35) human++;
    }
    final interval = _bootstrapInterval(segmentProbabilities);
    return (
      analyzable: analyzable,
      aiRatio: analyzable == 0 ? 0 : ai / analyzable,
      humanRatio: analyzable == 0 ? 0 : human / analyzable,
      stability: interval.stability,
      lowerBound: interval.lower,
      upperBound: interval.upper,
    );
  }

  /// 以固定種子的分段 bootstrap 估計文件內部穩定性。固定種子讓同一份文件
  /// 在任何平台都得到相同區間；重抽樣單位是句段，不把 token 當獨立樣本。
  static ({double lower, double upper, double stability}) _bootstrapInterval(
    List<double> values,
  ) {
    if (values.length < 3) {
      return (lower: 0, upper: 1, stability: 0.15);
    }
    var state = 0x5f3759df ^ values.length;
    int nextIndex() {
      state = (1664525 * state + 1013904223) & 0x7fffffff;
      return state % values.length;
    }

    final means = <double>[];
    for (var replicate = 0; replicate < 240; replicate++) {
      var sum = 0.0;
      for (var i = 0; i < values.length; i++) {
        sum += values[nextIndex()];
      }
      means.add(sum / values.length);
    }
    means.sort();
    final lower = means[(means.length * 0.025).floor()].clamp(0.0, 1.0);
    final upper = means[(means.length * 0.975).floor()].clamp(0.0, 1.0);
    final width = upper - lower;
    final directionalConsistency =
        values.where((value) => value >= 0.5).length / values.length;
    final majorityConsistency = math.max(
      directionalConsistency,
      1 - directionalConsistency,
    );
    final stability =
        ((1 - width / 0.60).clamp(0.0, 1.0) * 0.70 + majorityConsistency * 0.30)
            .clamp(0.0, 1.0);
    return (lower: lower, upper: upper, stability: stability);
  }
}
