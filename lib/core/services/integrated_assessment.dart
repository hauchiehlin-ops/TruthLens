/// 將文字模型與作者來源證據整合成一個必定有方向的判讀。
///
/// [aiLikelihood] 是證據融合後的「AI 可能性指數」，不是經母體校準的統計機率。
/// 系統即使在證據稀薄時仍提供較可能方向，但會把 [confidence] 降為 low；
/// [DetectionResult.abstention] 因此保留作為證據限制，而不再取代答案。
///
/// 這裡刻意採不對稱證據規則：缺少引用、偏離任務、整段貼上、很少修訂或
/// 檔案中繼資料異常，都不是 AI 特異性證據，不能把文件推向 AI。它們仍會在
/// [ForensicEvidenceMatrix] 中列為待核查事項。AI 方向必須由文字引擎的直接訊號
/// 與最低共識門檻支撐；真人寫作過程與完整來源紀錄則可以提供反向佐證。
library;

import 'dart:math' as math;

import '../models/detection_result.dart';
import 'citation_evidence.dart';
import 'claim_audit.dart';
import 'forensic_evidence.dart';
import 'revision_evidence.dart';

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

    final hasAssistantArtifact = result.engineScores.any(
      (score) =>
          score.available &&
          score.hasEvidence &&
          (score.features['assistant_response_artifacts'] ?? 0) >= 2,
    );
    final textReliability = hasAssistantArtifact
        ? 0.90
        : _textReliability(result);
    final textProbability = result.aiProbability.clamp(0.02, 0.98);
    final textLogOdds = math.log(textProbability / (1 - textProbability));
    add(
      EvidenceAxisKind.textTrace,
      textLogOdds * textReliability,
      information: textReliability,
    );
    if (result.evasion.indicatesDeliberateEvasion &&
        result.evidenceEngineCount > 0 &&
        result.aiProbability >= DetectionResult.aiFlagThreshold) {
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

    final revision = RevisionEvidence.compare(
      result.previousDraftText,
      result.inputText,
    );
    switch (revision.pattern) {
      case RevisionPattern.incremental:
        add(EvidenceAxisKind.revisionHistory, -0.65, information: 0.70);
      case RevisionPattern.largeReplacement:
      case RevisionPattern.nearDuplicate:
      case RevisionPattern.mixed:
      case RevisionPattern.unavailable:
        break;
    }

    // [citations] 與 [claims] 仍保留在 API，因為呼叫端同時用它們建立六軸矩陣。
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
    final aiSupportingEngines = result.engineScores
        .where(
          (score) =>
              score.available &&
              score.hasEvidence &&
              score.aiProbability >= DetectionResult.aiFlagThreshold,
        )
        .length;
    final passesAiEvidenceGate =
        hasAssistantArtifact ||
        aiSupportingEngines >= 2 ||
        (aiSupportingEngines == 1 && result.aiProbability >= 0.85);

    // 沒有越過高特異性證據門檻時，不允許弱訊號湊成 AI 判定。49% 不是另一個
    // 機率校準，而是讓「偏非 AI」方向與畫面上的指數保持語義一致。
    final aiLikelihood = !passesAiEvidenceGate && fusedLikelihood > 0.49
        ? 0.49
        : fusedLikelihood;

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
    final informationQuality = (information / 2.4).clamp(0.0, 1.0);
    final margin = ((aiLikelihood - 0.5).abs() * 2).clamp(0.0, 1.0);
    final confidenceScore =
        (informationQuality * 0.65 + margin * 0.35) *
        (1 - conflictRatio * 0.55);
    final rawConfidence = confidenceScore >= 0.68
        ? IntegratedConfidence.high
        : confidenceScore >= 0.38
        ? IntegratedConfidence.moderate
        : IntegratedConfidence.low;
    final confidence = result.evidenceEngineCount == 0
        ? IntegratedConfidence.low
        : rawConfidence == IntegratedConfidence.high &&
              aiSupportingEngines < 2 &&
              !provenance.indicatesHumanAuthorship &&
              !writing.consistentWithLiveWriting
        ? IntegratedConfidence.moderate
        : rawConfidence;

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
