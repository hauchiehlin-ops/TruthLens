/// 將文字模型與作者來源證據整合成可追溯的作者判讀。
///
/// [aiLikelihood] 是證據融合後的「AI 可能性指數」，不是經母體校準的統計機率。
/// 沒有方向性證據時不製造 49／50／51 的假精度；此時保留中性內部值，
/// 並以 [pointEstimateAvailable] 告知呈現層不得輸出數字判定。
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
import 'publication_evidence.dart';

enum IntegratedDirection { likelyAi, likelyHuman, likelyMixed, balanced }

enum IntegratedConfidence { low, moderate, high }

enum IntegratedConclusion {
  insufficientEvidence,
  preliminaryAi,
  preliminaryHuman,
  likelyAi,
  likelyHuman,
  likelyMixed,
  noClearDominance,
}

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
  final bool hasAuthorshipEvidence;
  final double stabilityScore;
  final double lowerBound;
  final double upperBound;
  final double confidenceCeiling;
  final bool stabilityAvailable;
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
    required this.hasAuthorshipEvidence,
    required this.stabilityScore,
    required this.lowerBound,
    required this.upperBound,
    required this.confidenceCeiling,
    required this.stabilityAvailable,
    required this.contributions,
  });

  /// 50 是方向中點，不是 AI 升級線。接近中點且信心低時仍提供方向，
  /// 但以「暫偏向」呈現，避免把 49／51 包裝成穩健的二元判定。
  bool get isNearDirectionalMidpoint => (aiLikelihood - 0.5).abs() <= 0.08;

  int get evidenceIndex => (aiLikelihood * 100).round();

  /// 是否有足以產生數字點估計的作者特異性證據。
  bool get pointEstimateAvailable =>
      hasAuthorshipEvidence && contributions.isNotEmpty;

  int get evidenceSufficiency => (confidenceScore * 100).round();

  int get aiEscalationGap => math.max(
    0,
    ((DetectionResult.aiFlagThreshold - aiLikelihood) * 100).ceil(),
  );

  IntegratedConclusion get conclusion {
    if (!pointEstimateAvailable) {
      return IntegratedConclusion.insufficientEvidence;
    }
    if (direction == IntegratedDirection.likelyMixed) {
      return IntegratedConclusion.likelyMixed;
    }
    if (direction == IntegratedDirection.balanced) {
      return IntegratedConclusion.noClearDominance;
    }
    if (confidence == IntegratedConfidence.low && isNearDirectionalMidpoint) {
      return direction == IntegratedDirection.likelyAi
          ? IntegratedConclusion.preliminaryAi
          : IntegratedConclusion.preliminaryHuman;
    }
    return direction == IntegratedDirection.likelyAi
        ? IntegratedConclusion.likelyAi
        : IntegratedConclusion.likelyHuman;
  }

  factory IntegratedAssessment.assess(
    DetectionResult result, {
    CitationEvidence citations = CitationEvidence.none,
    ClaimAudit claims = ClaimAudit.none,
    PublicationEvidence publication = PublicationEvidence.none,
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
    // 只有本次實際形成方向的家族或校準離群值能建立文字票。歷史總分可能
    // 只是多顆沉默引擎的 fallback，不能拿來填補證據空缺。
    final textProbability =
        (calibratedAiOutlier ? result.aiProbability : fusion.probability).clamp(
          0.02,
          0.98,
        );
    if (fusion.families.isNotEmpty || calibratedAiOutlier) {
      final textLogOdds = math.log(textProbability / (1 - textProbability));
      add(
        EvidenceAxisKind.textTrace,
        textLogOdds * textReliability,
        information: textReliability,
      );
    }
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
    if (publication.supportsHumanAuthorship) {
      // DOI、篇名與出版年代共同吻合，表示這份出版品早於現代生成式 AI。
      // 這是來源身分證據，不是文風猜測，因此證據力高於沉默的文字引擎。
      add(EvidenceAxisKind.documentOrigin, -2.20, information: 2.0);
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
    // 沒有句級輸出代表「無法量分段穩定性」，不是穩定性為零。已有兩個
    // 獨立家族越過門檻時，以保守中性值代替，讓充分的文件級證據可達中信心；
    // 高信心仍需要實際分段證據或可靠來源／寫作過程。
    final stabilityQuality = fusion.stabilityAvailable
        ? fusion.stabilityScore
        : passesAiEvidenceGate && fusion.aiSupportingFamilies >= 2
        ? 0.55
        : 0.0;
    final rawConfidenceScore =
        (informationQuality * 0.42 +
            stabilityQuality * 0.30 +
            margin * 0.18 +
            calibrationQuality * 0.10) *
        (1 - conflictRatio * 0.55);
    final provenanceSupportsHuman =
        provenance.indicatesHumanAuthorship ||
        writing.consistentWithLiveWriting ||
        publication.supportsHumanAuthorship;
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
        !fusion.stabilityAvailable && !provenanceSupportsHuman
            ? passesAiEvidenceGate && fusion.aiSupportingFamilies >= 2
                  ? 0.72
                  : 0.45
            : 1.0,
        evidenceConfidenceCeiling,
      ),
    );
    final confidenceScore = math.min(rawConfidenceScore, confidenceCeiling);
    final rawConfidence = confidenceScore >= 0.68
        ? IntegratedConfidence.high
        : confidenceScore >= 0.38
        ? IntegratedConfidence.moderate
        : IntegratedConfidence.low;
    var confidence = result.evidenceEngineCount == 0 && !provenanceSupportsHuman
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

    // 「分數低於中點」不等於「證據指向人類」。Transformer、風格與對抗三個引擎
    // 的中性點是 0——它們只在命中特徵時加分，因此偏低的分數代表證據不足，而不是
    // 它們認為這是人寫的。實測案例：一篇 100% ChatGPT 的英文文章，三個引擎全部
    // 給出**正向** AI 證據（11 句 AI 特徵、21 句改寫痕跡），加總 44/100 仍低於
    // 中點，於是被報成「較可能不是 AI 生成」——把證據不足說成了反向結論。
    //
    // 因此人類方向必須有人類側的實質證據才能成立：某個證據家族真的往人類側傾斜
    // （對數勝算為負），或寫作過程、文件來源、出版紀錄支持真人撰寫。都沒有時，
    // 低分只能是「沒有明確方向」。
    final hasHumanSideEvidence =
        fusion.families.any((family) => family.supportsHuman) ||
        writing.consistentWithLiveWriting ||
        provenance.indicatesHumanAuthorship ||
        publication.supportsHumanAuthorship;

    final direction = aiLikelihood > 0.5 && fusion.mixedAuthorship
        ? IntegratedDirection.likelyMixed
        : aiLikelihood > 0.5
        ? IntegratedDirection.likelyAi
        : aiLikelihood < 0.5 && hasHumanSideEvidence
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
      hasAuthorshipEvidence:
          fusion.families.any(
            (family) =>
                family.supportsAi || family.supportsHuman || family.directTrace,
          ) ||
          calibratedAiOutlier ||
          writing.consistentWithLiveWriting ||
          provenance.indicatesHumanAuthorship ||
          publication.supportsHumanAuthorship,
      stabilityScore: fusion.stabilityScore,
      lowerBound: fusion.lowerBound,
      upperBound: fusion.upperBound,
      confidenceCeiling: confidenceCeiling,
      stabilityAvailable: fusion.stabilityAvailable,
      contributions: contributions,
    );
  }
}
