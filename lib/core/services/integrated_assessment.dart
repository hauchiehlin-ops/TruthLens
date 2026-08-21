/// 將文字模型與文件鑑識證據整合成一個必定有方向的判讀。
///
/// [aiLikelihood] 是證據融合後的「AI 可能性指數」，不是經母體校準的統計機率。
/// 系統即使在證據稀薄時仍提供較可能方向，但會把 [confidence] 降為 low；
/// [DetectionResult.abstention] 因此保留作為證據限制，而不再取代答案。
library;

import 'dart:math' as math;

import '../models/detection_result.dart';
import 'citation_evidence.dart';
import 'claim_audit.dart';
import 'document_provenance.dart';
import 'forensic_evidence.dart';
import 'revision_evidence.dart';
import 'task_alignment.dart';

enum IntegratedDirection { likelyAi, likelyHuman }

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
  final List<IntegratedEvidenceContribution> contributions;

  const IntegratedAssessment({
    required this.aiLikelihood,
    required this.direction,
    required this.confidence,
    required this.confidenceScore,
    required this.textReliability,
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

    final textReliability = _textReliability(result);
    final textProbability = result.aiProbability.clamp(0.02, 0.98);
    final textLogOdds = math.log(textProbability / (1 - textProbability));
    add(
      EvidenceAxisKind.textTrace,
      textLogOdds * textReliability,
      information: textReliability,
    );
    if (result.evasion.indicatesDeliberateEvasion) {
      add(EvidenceAxisKind.textTrace, 1.10, information: 1.0);
    }

    final writing = result.writingSession;
    if (writing.hasData) {
      if (writing.hasBulkPaste) {
        add(EvidenceAxisKind.writingProcess, 0.70, information: 0.75);
      } else if (writing.consistentWithLiveWriting) {
        add(EvidenceAxisKind.writingProcess, -1.15, information: 1.0);
      } else {
        add(EvidenceAxisKind.writingProcess, 0, information: 0.25);
      }
    }

    final provenance = result.provenance;
    if (provenance.indicatesHumanAuthorship) {
      add(EvidenceAxisKind.documentOrigin, -1.35, information: 1.0);
    } else {
      switch (provenance.risk) {
        case ProvenanceRisk.high:
          add(EvidenceAxisKind.documentOrigin, 1.00, information: 0.90);
        case ProvenanceRisk.medium:
          add(EvidenceAxisKind.documentOrigin, 0.55, information: 0.65);
        case ProvenanceRisk.low:
          add(EvidenceAxisKind.documentOrigin, 0, information: 0.30);
        case ProvenanceRisk.unknown:
          break;
      }
    }

    final revision = RevisionEvidence.compare(
      result.previousDraftText,
      result.inputText,
    );
    switch (revision.pattern) {
      case RevisionPattern.largeReplacement:
        add(EvidenceAxisKind.revisionHistory, 0.55, information: 0.60);
      case RevisionPattern.incremental:
        add(EvidenceAxisKind.revisionHistory, -0.65, information: 0.70);
      case RevisionPattern.nearDuplicate:
        add(EvidenceAxisKind.revisionHistory, 0, information: 0.25);
      case RevisionPattern.mixed:
        add(EvidenceAxisKind.revisionHistory, 0, information: 0.30);
      case RevisionPattern.unavailable:
        break;
    }

    final task = TaskAlignment.analyze(result.taskPrompt, result.inputText);
    switch (task.risk) {
      case TaskAlignmentRisk.high:
        add(EvidenceAxisKind.taskAlignment, 0.18, information: 0.20);
      case TaskAlignmentRisk.medium:
        add(EvidenceAxisKind.taskAlignment, 0.08, information: 0.12);
      case TaskAlignmentRisk.low:
        add(EvidenceAxisKind.taskAlignment, 0, information: 0.10);
      case TaskAlignmentRisk.unknown:
        break;
    }

    var sourceLogOdds = 0.0;
    var sourceInformation = 0.0;
    switch (citations.risk) {
      case CitationRisk.high:
        sourceLogOdds += 0.90;
        sourceInformation = 0.75;
      case CitationRisk.medium:
        sourceLogOdds += 0.45;
        sourceInformation = 0.50;
      case CitationRisk.low:
        sourceInformation = 0.25;
      case CitationRisk.unknown:
        break;
    }
    switch (claims.risk) {
      case ClaimSourceRisk.high:
        sourceLogOdds += 0.28;
        sourceInformation = math.max(sourceInformation, 0.30);
      case ClaimSourceRisk.medium:
        sourceLogOdds += 0.12;
        sourceInformation = math.max(sourceInformation, 0.18);
      case ClaimSourceRisk.low:
        sourceInformation = math.max(sourceInformation, 0.12);
      case ClaimSourceRisk.unknown:
        break;
    }
    if (sourceInformation > 0) {
      add(
        EvidenceAxisKind.sourceIntegrity,
        sourceLogOdds,
        information: sourceInformation,
      );
    }

    final contributions = [
      for (final entry in contributionByAxis.entries)
        IntegratedEvidenceContribution(kind: entry.key, logOdds: entry.value),
    ];
    final combinedLogOdds = contributions.fold<double>(
      0,
      (sum, contribution) => sum + contribution.logOdds,
    );
    final aiLikelihood = 1 / (1 + math.exp(-combinedLogOdds));

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
    final informationQuality = (information / 2.8).clamp(0.0, 1.0);
    final margin = ((aiLikelihood - 0.5).abs() * 2).clamp(0.0, 1.0);
    final confidenceScore =
        (informationQuality * 0.65 + margin * 0.35) *
        (1 - conflictRatio * 0.55);
    final confidence = confidenceScore >= 0.68
        ? IntegratedConfidence.high
        : confidenceScore >= 0.38
        ? IntegratedConfidence.moderate
        : IntegratedConfidence.low;

    return IntegratedAssessment(
      aiLikelihood: aiLikelihood,
      direction: aiLikelihood > 0.5
          ? IntegratedDirection.likelyAi
          : IntegratedDirection.likelyHuman,
      confidence: confidence,
      confidenceScore: confidenceScore,
      textReliability: textReliability,
      contributions: contributions,
    );
  }

  static double _textReliability(DetectionResult result) {
    if (result.effectiveAvailableEngineCount == 0) return 0.05;
    return switch (result.abstention) {
      AbstentionReason.none => result.singleEvidenceSource ? 0.55 : 1.0,
      AbstentionReason.noEvidenceFound => 0.12,
      AbstentionReason.singleWeakEvidenceSource => 0.35,
      AbstentionReason.enginesConflict => 0.30,
      AbstentionReason.tooFewEngines => 0.30,
      AbstentionReason.tooFewSentences || AbstentionReason.tooFewWords => 0.25,
    };
  }
}
