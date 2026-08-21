/// 多證據鑑識矩陣。
///
/// 各軸回答不同問題，因此矩陣本身不做簡單平均：文本軸是統計推論；
/// 寫作過程與文件來源是行為／中繼資料；來源完整性是可查核主張與引用品質。
/// 整合判讀服務會另外以保守似然權重融合可用訊號，矩陣則負責保留
/// 每一軸的方向、強度與可追溯性。
library;

import '../models/detection_result.dart';
import 'citation_evidence.dart';
import 'claim_audit.dart';
import 'document_provenance.dart';
import 'revision_evidence.dart';
import 'task_alignment.dart';

enum EvidenceAxisKind {
  textTrace,
  writingProcess,
  documentOrigin,
  revisionHistory,
  taskAlignment,
  sourceIntegrity,
}

enum EvidenceAxisState { unavailable, inconclusive, reassuring, concern }

enum EvidenceStrength { none, limited, moderate, strong }

class EvidenceAxisAssessment {
  final EvidenceAxisKind kind;
  final EvidenceAxisState state;
  final EvidenceStrength strength;

  const EvidenceAxisAssessment({
    required this.kind,
    required this.state,
    required this.strength,
  });

  bool get available => state != EvidenceAxisState.unavailable;
}

class ForensicEvidenceMatrix {
  final List<EvidenceAxisAssessment> axes;

  const ForensicEvidenceMatrix({required this.axes});

  factory ForensicEvidenceMatrix.assess(
    DetectionResult result, {
    CitationEvidence citations = CitationEvidence.none,
    ClaimAudit claims = ClaimAudit.none,
  }) => ForensicEvidenceMatrix(
    axes: [
      _textAxis(result),
      _writingAxis(result),
      _originAxis(result),
      _revisionAxis(result),
      _taskAxis(result),
      _sourceAxis(citations, claims),
    ],
  );

  int get availableAxisCount => axes.where((axis) => axis.available).length;
  int get totalAxisCount => axes.length;
  double get coverage =>
      totalAxisCount == 0 ? 0 : availableAxisCount / totalAxisCount;
  bool get textOnly =>
      availableAxisCount == 1 &&
      axes
          .firstWhere((axis) => axis.kind == EvidenceAxisKind.textTrace)
          .available;
  bool get hasStrongConcern => axes.any(
    (axis) =>
        axis.state == EvidenceAxisState.concern &&
        axis.strength == EvidenceStrength.strong,
  );

  static EvidenceAxisAssessment _textAxis(DetectionResult result) {
    if (result.evasion.indicatesDeliberateEvasion) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.textTrace,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.strong,
      );
    }
    if (result.effectiveAvailableEngineCount == 0) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.textTrace,
        state: EvidenceAxisState.unavailable,
        strength: EvidenceStrength.none,
      );
    }
    if (result.hasEvidenceLimitations) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.textTrace,
        state: EvidenceAxisState.inconclusive,
        strength: EvidenceStrength.limited,
      );
    }
    if (result.aiProbability >= 0.80) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.textTrace,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.strong,
      );
    }
    if (result.flaggedAsAi) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.textTrace,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.moderate,
      );
    }
    // 低文本分數只代表「未找到 AI 痕跡」，不能反向當成人類撰寫證據。
    return const EvidenceAxisAssessment(
      kind: EvidenceAxisKind.textTrace,
      state: EvidenceAxisState.inconclusive,
      strength: EvidenceStrength.limited,
    );
  }

  static EvidenceAxisAssessment _writingAxis(DetectionResult result) {
    final session = result.writingSession;
    if (!session.hasData) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.writingProcess,
        state: EvidenceAxisState.unavailable,
        strength: EvidenceStrength.none,
      );
    }
    if (session.hasBulkPaste) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.writingProcess,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.strong,
      );
    }
    if (session.consistentWithLiveWriting) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.writingProcess,
        state: EvidenceAxisState.reassuring,
        strength: EvidenceStrength.strong,
      );
    }
    return const EvidenceAxisAssessment(
      kind: EvidenceAxisKind.writingProcess,
      state: EvidenceAxisState.inconclusive,
      strength: EvidenceStrength.moderate,
    );
  }

  static EvidenceAxisAssessment _originAxis(DetectionResult result) {
    final risk = result.provenance.risk;
    return switch (risk) {
      ProvenanceRisk.unknown => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.documentOrigin,
        state: EvidenceAxisState.unavailable,
        strength: EvidenceStrength.none,
      ),
      ProvenanceRisk.high => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.documentOrigin,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.strong,
      ),
      ProvenanceRisk.medium => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.documentOrigin,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.moderate,
      ),
      ProvenanceRisk.low when result.provenance.indicatesHumanAuthorship =>
        const EvidenceAxisAssessment(
          kind: EvidenceAxisKind.documentOrigin,
          state: EvidenceAxisState.reassuring,
          strength: EvidenceStrength.strong,
        ),
      ProvenanceRisk.low => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.documentOrigin,
        state: EvidenceAxisState.inconclusive,
        strength: EvidenceStrength.moderate,
      ),
    };
  }

  static EvidenceAxisAssessment _sourceAxis(
    CitationEvidence citations,
    ClaimAudit claims,
  ) {
    if (!citations.hasData && !claims.hasData) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.sourceIntegrity,
        state: EvidenceAxisState.unavailable,
        strength: EvidenceStrength.none,
      );
    }
    if (citations.risk == CitationRisk.high) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.sourceIntegrity,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.strong,
      );
    }
    if (citations.risk == CitationRisk.medium ||
        claims.risk == ClaimSourceRisk.high) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.sourceIntegrity,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.moderate,
      );
    }
    if (claims.risk == ClaimSourceRisk.medium) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.sourceIntegrity,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.limited,
      );
    }
    if (citations.risk == CitationRisk.low && citations.verified > 0) {
      return const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.sourceIntegrity,
        state: EvidenceAxisState.reassuring,
        strength: EvidenceStrength.strong,
      );
    }
    return const EvidenceAxisAssessment(
      kind: EvidenceAxisKind.sourceIntegrity,
      state: EvidenceAxisState.inconclusive,
      strength: EvidenceStrength.limited,
    );
  }

  static EvidenceAxisAssessment _revisionAxis(DetectionResult result) {
    final revision = RevisionEvidence.compare(
      result.previousDraftText,
      result.inputText,
    );
    return switch (revision.pattern) {
      RevisionPattern.unavailable => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.revisionHistory,
        state: EvidenceAxisState.unavailable,
        strength: EvidenceStrength.none,
      ),
      RevisionPattern.largeReplacement => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.revisionHistory,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.moderate,
      ),
      RevisionPattern.incremental => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.revisionHistory,
        state: EvidenceAxisState.reassuring,
        strength: EvidenceStrength.moderate,
      ),
      RevisionPattern.nearDuplicate => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.revisionHistory,
        state: EvidenceAxisState.reassuring,
        strength: EvidenceStrength.limited,
      ),
      RevisionPattern.mixed => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.revisionHistory,
        state: EvidenceAxisState.inconclusive,
        strength: EvidenceStrength.moderate,
      ),
    };
  }

  static EvidenceAxisAssessment _taskAxis(DetectionResult result) {
    final task = TaskAlignment.analyze(result.taskPrompt, result.inputText);
    return switch (task.risk) {
      TaskAlignmentRisk.unknown => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.taskAlignment,
        state: EvidenceAxisState.unavailable,
        strength: EvidenceStrength.none,
      ),
      TaskAlignmentRisk.high => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.taskAlignment,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.moderate,
      ),
      TaskAlignmentRisk.medium => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.taskAlignment,
        state: EvidenceAxisState.concern,
        strength: EvidenceStrength.limited,
      ),
      TaskAlignmentRisk.low => const EvidenceAxisAssessment(
        kind: EvidenceAxisKind.taskAlignment,
        state: EvidenceAxisState.reassuring,
        strength: EvidenceStrength.moderate,
      ),
    };
  }
}
