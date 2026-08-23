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

  double get effectiveWeight => configuredWeight * reliability;
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
  final bool stabilityAvailable;
  final int aiSupportingFamilies;
  final int humanSupportingFamilies;
  final bool passesAiEvidenceGate;
  final bool mixedAuthorship;
  final bool hasDirectTrace;
  final double weightedAiMass;
  final double activeFamilyWeight;
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
    required this.stabilityAvailable,
    required this.aiSupportingFamilies,
    required this.humanSupportingFamilies,
    required this.passesAiEvidenceGate,
    required this.mixedAuthorship,
    required this.hasDirectTrace,
    required this.weightedAiMass,
    required this.activeFamilyWeight,
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
          .map((score) => _directionalReliability(score) * domainFactor)
          .fold<double>(0, math.max)
          .clamp(0.0, 1.0);
      applicabilityWeight += cap * availableReliability;

      final directional = <({EngineScore score, double probability})>[];
      for (final score in engines) {
        final probability = _directionalProbability(score);
        if (probability != null) {
          directional.add((score: score, probability: probability));
        }
      }
      if (directional.isEmpty) continue;
      var weightedProbability = 0.0;
      var totalReliability = 0.0;
      var direct = false;
      for (final candidate in directional) {
        final score = candidate.score;
        final eslFactor = eslAdjusted && family == EvidenceFamily.distributional
            ? 0.5
            : 1.0;
        final engineReliability =
            _directionalReliability(score) * domainFactor * eslFactor;
        weightedProbability += candidate.probability * engineReliability;
        totalReliability += engineReliability;
        direct =
            direct ||
            (score.features['assistant_response_artifacts'] ?? 0) >= 2 ||
            (score.features['verified_watermark'] ?? 0) >= 1 ||
            (score.features['verified_ai_provenance'] ?? 0) >= 1;
      }
      if (totalReliability <= 0) continue;
      final rawProbability = weightedProbability / totalReliability;
      final familyReliability = (totalReliability / directional.length).clamp(
        0.0,
        1.0,
      );
      // 機率與可靠度是兩個不同量：機率回答方向，可靠度只決定話語權。
      // 先把分數折回 0.5、再以可靠度加權會重複懲罰同一項限制，並把所有
      // 有用訊號人為擠在 49／51 附近。
      final probability = rawProbability.clamp(0.0, 1.0);
      final supportsAi = probability >= 0.62;
      final supportsHuman = probability <= 0.38;
      // 強證據門檻與方向性篩查必須分開。即使一個家族尚未跨過
      // 38%／62%，只要它確實偏離中性，就應保留其方向；否則多個
      // 一致的弱訊號會被全部刪掉，最後錯誤回到固定 50%。
      final deviation = (probability - 0.5).abs();
      if (deviation < 0.015 && !direct) continue;
      final directionalStrength = (deviation / 0.12).clamp(0.0, 1.0);
      evidenceWeight += cap * familyReliability * directionalStrength;
      familyEvidence.add(
        FamilyEvidence(
          family: family,
          probability: direct ? math.max(probability, 0.98) : probability,
          reliability: familyReliability,
          configuredWeight: cap,
          engineCount: directional.length,
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
              family.family == EvidenceFamily.lexicalFingerprint ||
              family.family == EvidenceFamily.distributional),
    );
    final passesGate =
        directTrace || aiFamilies.length >= 2 || strongSingleFamily;

    var probability = 0.5;
    var weightedAiMass = 0.0;
    var activeFamilyWeight = 0.0;
    if (familyEvidence.isNotEmpty) {
      for (final family in familyEvidence) {
        weightedAiMass += family.probability * family.effectiveWeight;
        activeFamilyWeight += family.effectiveWeight;
      }
      if (activeFamilyWeight > 0) {
        probability = (weightedAiMass / activeFamilyWeight).clamp(0.0, 1.0);
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
      stabilityAvailable: window.analyzable >= 3 && _hasSegmentEvidence(scores),
      aiSupportingFamilies: aiFamilies.length,
      humanSupportingFamilies: humanFamilies.length,
      passesAiEvidenceGate: passesGate,
      mixedAuthorship: mixed,
      hasDirectTrace: directTrace,
      weightedAiMass: weightedAiMass,
      activeFamilyWeight: activeFamilyWeight,
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

  /// 取得可用於「方向性篩查」的雙向分數。
  ///
  /// 只有真的找到證據並參與投票的引擎才能提供方向。診斷欄位
  /// `raw_avg_prob` 不具有獨立校準，不得再把沉默模型的原始值包裝成人類票。
  static double? _directionalProbability(EngineScore score) {
    final direct =
        (score.features['assistant_response_artifacts'] ?? 0) >= 2 ||
        (score.features['verified_watermark'] ?? 0) >= 1 ||
        (score.features['verified_ai_provenance'] ?? 0) >= 1;
    if (direct) return 0.99;
    return switch (score.resolvedEvidenceFamily) {
      EvidenceFamily.supervisedClassifier ||
      EvidenceFamily.lexicalFingerprint ||
      EvidenceFamily.distributional =>
        score.votes ? score.aiProbability.clamp(0.0, 1.0) : null,
      EvidenceFamily.stylometric || EvidenceFamily.rewriteTrace =>
        score.votes ? _normalizedProbability(score) : null,
      EvidenceFamily.unknown =>
        score.votes ? score.aiProbability.clamp(0.0, 1.0) : null,
    };
  }

  /// 本次方向分數的事前可靠度，只由適用性、外部校準與覆蓋率決定。
  static double _directionalReliability(EngineScore score) {
    final applicability = switch (score.applicability) {
      EngineApplicability.validated => 1.0,
      EngineApplicability.plausible => 0.72,
      EngineApplicability.unknown => 0.45,
      EngineApplicability.unsupported => 0.0,
    };
    final chunks = score.features['analysis_chunk_count'];
    final coverage = chunks == null
        ? 1.0
        : chunks >= 4
        ? 1.0
        : chunks >= 2
        ? 0.82
        : chunks > 0
        ? 0.65
        : 0.75;
    return (applicability *
            score.calibrationReliability.clamp(0.0, 1.0) *
            coverage)
        .clamp(0.0, 1.0);
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
    // 聚合後的 fallback 句分數只有在至少一個引擎真的投票時才具有證據
    // 意義。全體沉默時它只是 UI 診斷值，不能製造 100% 穩定的 0–0% 區間。
    final hasVotingEngine = scores.any((score) => score.votes);
    final usableFallback = hasVotingEngine ? fallback : const <SentenceScore>[];
    final length = perEngine.isEmpty
        ? usableFallback.length
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
      if (values.isEmpty && i < usableFallback.length) {
        values.add(usableFallback[i].aiProbability);
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

  static bool _hasSegmentEvidence(List<EngineScore> scores) => scores.any(
    (score) =>
        score.votes &&
        score.sentenceScores != null &&
        score.sentenceScores!.isNotEmpty,
  );

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
