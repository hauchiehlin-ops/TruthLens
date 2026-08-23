/// 將文字模型與作者來源證據整合成一個必定有方向的判讀。
///
/// [aiLikelihood] 是證據融合後的「AI 可能性指數」，不是經母體校準的統計機率。
/// 系統即使在證據稀薄時仍提供較可能方向，但會把 [confidence] 降為 low；
/// [DetectionResult.abstention] 因此保留作為證據限制，而不再取代答案。
///
/// 這裡刻意採不對稱證據規則：缺少引用、整段貼上或檔案中繼資料異常，
/// 都不是 AI 特異性證據，不能把文件推向 AI。它們仍會在
/// [ForensicEvidenceMatrix] 中列為待核查事項。AI 方向必須由文字引擎的直接訊號
/// 提供方向；最低共識門檻另外標示該方向是否已有足夠獨立證據。真人寫作過程與
/// 完整來源紀錄則可以提供反向佐證。
library;

import 'dart:math' as math;

import '../models/detection_result.dart';
import '../detection/analysis_profile.dart';
import '../detection/evidence_fusion.dart';
import 'citation_evidence.dart';
import 'claim_audit.dart';
import 'forensic_evidence.dart';

enum IntegratedDirection { likelyAi, likelyHuman, likelyMixed, balanced }

enum IntegratedConfidence { low, moderate, high }

class IntegratedEvidenceContribution {
  final EvidenceAxisKind kind;

  /// 對 AI 對數勝算的修正；正值偏 AI，負值偏人類。
  final double logOdds;

  const IntegratedEvidenceContribution({
    required this.kind,
    required this.logOdds,
  });

  bool get supportsAi => logOdds > 0;
  bool get supportsHuman => logOdds < 0;
}

class IntegratedAssessment {
  final double aiLikelihood;
  final IntegratedDirection direction;
  final IntegratedConfidence confidence;
  final double confidenceScore;
  final double textReliability;
  final TextAuthorshipClass textAuthorshipClass;
  final AnalysisDomain analysisDomain;
  final int independentEvidenceFamilies;
  final double applicabilityCoverage;
  final double evidenceCoverage;
  final bool passesAiEvidenceGate;
  final double stabilityScore;
  final double lowerBound;
  final double upperBound;
  final double confidenceCeiling;
  final List<IntegratedEvidenceContribution> contributions;

  const IntegratedAssessment({
    required this.aiLikelihood,
    required this.direction,
    required this.confidence,
    required this.confidenceScore,
    required this.textReliability,
    required this.textAuthorshipClass,
    required this.analysisDomain,
    required this.independentEvidenceFamilies,
    required this.applicabilityCoverage,
    required this.evidenceCoverage,
    required this.passesAiEvidenceGate,
    required this.stabilityScore,
    required this.lowerBound,
    required this.upperBound,
    required this.confidenceCeiling,
    required this.contributions,
  });

  factory IntegratedAssessment.assess(
    DetectionResult result, {
    CitationEvidence citations = CitationEvidence.none,
    ClaimAudit claims = ClaimAudit.none,
  }) {
    final contributionByAxis = <EvidenceAxisKind, double>{};
    final informationByAxis = <EvidenceAxisKind, double>{};

    void add(
      EvidenceAxisKind kind,
      double logOdds, {
      required double information,
    }) {
      contributionByAxis.update(
        kind,
        (value) => value + logOdds,
        ifAbsent: () => logOdds,
      );
      informationByAxis.update(
        kind,
        (value) => math.max(value, information),
        ifAbsent: () => information,
      );
    }

    final profile = AnalysisProfile.fromText(result.inputText);
    final fusion = TextEvidenceFusion.evaluate(
      scores: result.engineScores,
      inputText: result.inputText,
      sentences: result.sentences,
      profile: profile,
      extractionQuality: result.inputQuality.extractionQuality,
      eslAdjusted: result.eslAdjusted,
    );
    final calibratedAiOutlier = result.calibration.isFlagged;
    final passesAiEvidenceGate =
        fusion.passesAiEvidenceGate || calibratedAiOutlier;
    final hasAssistantArtifact = fusion.hasDirectTrace;
    final textReliability = hasAssistantArtifact
        ? 0.95
        : calibratedAiOutlier
        ? math.max(0.82, fusion.reliability)
        : fusion.passesAiEvidenceGate
        ? math.max(0.80, fusion.reliability)
        : result.evidenceEngineCount == 0
        ? 0.18
        : (0.25 + fusion.reliability * 0.50).clamp(0.25, 0.70);
    // 引擎全部沉默時，家族融合本身只能回到 50% 中性值。此時保留四引擎原始
    // 診斷分數的方向，但以低可靠度收縮，避免把「無正式證據」誤寫成固定 50%。
    final textProbability =
        (fusion.families.isEmpty ? result.aiProbability : fusion.probability)
            .clamp(0.02, 0.98);
    final textLogOdds = math.log(textProbability / (1 - textProbability));
    add(
      EvidenceAxisKind.textTrace,
      textLogOdds * textReliability,
      information: textReliability,
    );
    if (result.evasion.indicatesDeliberateEvasion &&
        fusion.passesAiEvidenceGate &&
        fusion.probability >= DetectionResult.aiFlagThreshold) {
      // 規避字元本身不等於 AI；只有文字模型已找到 AI 訊號時才作弱佐證。
      add(EvidenceAxisKind.textTrace, 0.45, information: 0.45);
    }

    final writing = result.writingSession;
    if (writing.hasData) {
      if (writing.consistentWithLiveWriting) {
        add(EvidenceAxisKind.writingProcess, -1.15, information: 1.0);
      }
    }

    final provenance = result.provenance;
    if (provenance.indicatesHumanAuthorship) {
      add(EvidenceAxisKind.documentOrigin, -1.35, information: 1.0);
    }

    // [citations] 與 [claims] 仍保留在 API，因為呼叫端同時用它們建立四軸矩陣。
    // 它們衡量來源品質，不衡量作者身分，因此不進入作者勝算。

    final contributions = [
      for (final entry in contributionByAxis.entries)
        IntegratedEvidenceContribution(kind: entry.key, logOdds: entry.value),
    ];
    final combinedLogOdds = contributions.fold<double>(
      0,
      (sum, contribution) => sum + contribution.logOdds,
    );
    final fusedLikelihood = 1 / (1 + math.exp(-combinedLogOdds));
    final aiLikelihood = fusedLikelihood;

    final positive = contributions
        .where((item) => item.logOdds > 0)
        .fold<double>(0, (sum, item) => sum + item.logOdds);
    final negative = contributions
        .where((item) => item.logOdds < 0)
        .fold<double>(0, (sum, item) => sum - item.logOdds);
    final directionalTotal = positive + negative;
    final conflictRatio = directionalTotal == 0
        ? 0.0
        : 2 * math.min(positive, negative) / directionalTotal;
    final information = informationByAxis.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );
    final informationQuality = math.max(
      (information / 2.4).clamp(0.0, 1.0),
      fusion.reliability,
    );
    final margin = ((aiLikelihood - 0.5).abs() * 2).clamp(0.0, 1.0);
    final calibrationQuality = calibratedAiOutlier
        ? (1 - result.calibration.alpha).clamp(0.0, 1.0)
        : 0.0;
    final rawConfidenceScore =
        (informationQuality * 0.42 +
            fusion.stabilityScore * 0.30 +
            margin * 0.18 +
            calibrationQuality * 0.10) *
        (1 - conflictRatio * 0.55);
    final provenanceSupportsHuman =
        provenance.indicatesHumanAuthorship ||
        writing.consistentWithLiveWriting;
    final weakAiScreeningOnly =
        aiLikelihood > 0.5 && !passesAiEvidenceGate && !provenanceSupportsHuman;
    final evidenceConfidenceCeiling = weakAiScreeningOnly
        ? 0.37
        : hasAssistantArtifact || provenanceSupportsHuman
        ? 1.0
        : result.calibration.isApplicable
        ? 0.90
        : 0.67;
    final confidenceCeiling = math.min(
      result.inputQuality.confidenceCeiling,
      math.min(
        fusion.stabilitySegmentCount < 3 ? 0.45 : 1.0,
        evidenceConfidenceCeiling,
      ),
    );
    final confidenceScore = math.min(rawConfidenceScore, confidenceCeiling);
    final rawConfidence = confidenceScore >= 0.68
        ? IntegratedConfidence.high
        : confidenceScore >= 0.38
        ? IntegratedConfidence.moderate
        : IntegratedConfidence.low;
    var confidence = result.evidenceEngineCount == 0
        ? IntegratedConfidence.low
        : rawConfidence == IntegratedConfidence.high &&
              fusion.aiSupportingFamilies < 2 &&
              !provenance.indicatesHumanAuthorship &&
              !writing.consistentWithLiveWriting
        ? IntegratedConfidence.moderate
        : rawConfidence;
    // 文字證據越過 AI 門檻，卻被可靠的真人寫作過程／來源推回人類方向時，
    // 兩類證據存在實質衝突，不能顯示高信心。
    if (passesAiEvidenceGate && aiLikelihood <= 0.5) {
      confidence = confidence == IntegratedConfidence.high
          ? IntegratedConfidence.moderate
          : confidence;
    }

    final displayedAiPercent = (aiLikelihood * 100).round();
    final direction = displayedAiPercent > 50 && fusion.mixedAuthorship
        ? IntegratedDirection.likelyMixed
        : displayedAiPercent > 50
        ? IntegratedDirection.likelyAi
        : displayedAiPercent < 50
        ? IntegratedDirection.likelyHuman
        : IntegratedDirection.balanced;
    final textAuthorshipClass = fusion.mixedAuthorship
        ? TextAuthorshipClass.likelyAiAssisted
        : textProbability >= 0.5
        ? TextAuthorshipClass.likelyAiGenerated
        : TextAuthorshipClass.likelyHuman;

    return IntegratedAssessment(
      aiLikelihood: aiLikelihood,
      direction: direction,
      confidence: confidence,
      confidenceScore: confidenceScore,
      textReliability: textReliability,
      textAuthorshipClass: textAuthorshipClass,
      analysisDomain: profile.domain,
      independentEvidenceFamilies: fusion.families.length,
      applicabilityCoverage: fusion.applicabilityCoverage,
      evidenceCoverage: fusion.evidenceCoverage,
      passesAiEvidenceGate: passesAiEvidenceGate,
      stabilityScore: fusion.stabilityScore,
      lowerBound: fusion.lowerBound,
      upperBound: fusion.upperBound,
      confidenceCeiling: confidenceCeiling,
      contributions: contributions,
    );
  }
}
