/// 可查證事實的彙整。
///
/// 報告原本以機率為頭條、把可查證的事實放在下方卡片。這個順序是反的：
///
/// - 「三篇文獻查無此文」是**事實**，模型再強也不會讓不存在的論文變成存在
/// - 「編輯總時長 0 分鐘但正文 2462 字」是**事實**，記在檔案自己身上
/// - 「AI 機率 32%」是**推論**，而且今天已證實它對現代模型的輸出分辨力有限
///
/// 一份報告若能說「這三篇文獻查無此文」，它的說服力不需要任何機率來支撐。
/// 因此把事實抽出來獨立呈現，機率退為輔助。
library;

import '../../core/models/detection_result.dart';
import '../../core/services/citation_evidence.dart';
import '../../core/services/claim_audit.dart';
import '../../core/services/revision_evidence.dart';
import '../../core/services/task_alignment.dart';
import '../../shared/widgets/provenance_card.dart';
import '../../l10n/generated/app_localizations.dart';

/// 單一項可查證的發現
class VerifiableFinding {
  /// 白話陳述
  final String statement;

  /// 是否為需要解釋的發現（true）或是支持文件正常的觀察（false）
  final bool isConcern;

  const VerifiableFinding({required this.statement, required this.isConcern});
}

/// 彙整本次分析中**可查證**的發現，依證據力由強到弱排序。
///
/// 刻意不含任何機率或分數：這份清單的價值在於每一條都能被獨立驗證，
/// 混進推論會讓整份清單降級成「又一個判斷」。
List<VerifiableFinding> collectVerifiableFindings(
  DetectionResult result,
  AppLocalizations l10n, {
  CitationEvidence citations = CitationEvidence.none,
  ClaimAudit claims = ClaimAudit.none,
}) {
  final findings = <VerifiableFinding>[];

  // 1. 刻意規避的痕跡——最直接，因為它顯示有人動過手腳
  if (result.evasion.indicatesDeliberateEvasion) {
    findings.add(
      VerifiableFinding(
        statement: l10n.findingEvasionDetected(result.evasion.totalHits),
        isConcern: true,
      ),
    );
  }

  // 2. 捏造引用——可查證的二元事實
  if (citations.hasData) {
    if (citations.notFound > 0) {
      findings.add(
        VerifiableFinding(
          statement: l10n.findingCitationsNotFound(
            citations.notFound,
            citations.total,
          ),
          isConcern: citations.contradictsHumanAuthorship,
        ),
      );
    } else {
      findings.add(
        VerifiableFinding(
          statement: l10n.findingCitationsAllVerified(citations.total),
          isConcern: false,
        ),
      );
    }
  }

  // 3. 可查核主張缺少同句來源。這不是「內容為假」的結論，只是可重現地
  //    指出哪一批主張應先查；因此只有達到中高覆蓋風險才列為警訊。
  if (claims.risk == ClaimSourceRisk.medium ||
      claims.risk == ClaimSourceRisk.high) {
    findings.add(
      VerifiableFinding(
        statement: l10n.findingUnsupportedClaims(
          claims.unsupported,
          claims.total,
        ),
        isConcern: true,
      ),
    );
  }

  final revision = RevisionEvidence.compare(
    result.previousDraftText,
    result.inputText,
  );
  if (revision.indicatesLargeReplacement) {
    findings.add(
      VerifiableFinding(
        statement: l10n.findingLargeDraftReplacement(
          ((1 - revision.shingleSimilarity) * 100).round(),
          result.previousDraftFileName,
        ),
        isConcern: true,
      ),
    );
  }

  final task = TaskAlignment.analyze(result.taskPrompt, result.inputText);
  if (task.risk == TaskAlignmentRisk.high) {
    findings.add(
      VerifiableFinding(
        statement: l10n.findingTaskMismatch(
          (task.conceptCoverage * 100).round(),
        ),
        isConcern: true,
      ),
    );
  }

  // 4. 寫作過程——若文字是在應用程式內寫成的，過程本身就是最強的證據，
  //    因為它記錄的不是文字，而是文字如何出現在編輯器裡
  final session = result.writingSession;
  if (session.hasData) {
    if (session.hasBulkPaste) {
      findings.add(
        VerifiableFinding(
          statement: l10n.findingBulkPaste(session.largestPaste),
          isConcern: true,
        ),
      );
    } else if (session.consistentWithLiveWriting) {
      findings.add(
        VerifiableFinding(
          statement: l10n.findingWrittenInApp(
            session.duration.inMinutes,
            session.deletedCharacters,
          ),
          isConcern: false,
        ),
      );
    }
  }

  // 5. 檔案自身的編輯紀錄
  final provenance = result.provenance;
  for (final signal in provenance.signals) {
    findings.add(
      VerifiableFinding(
        statement: ProvenanceCard.describeSignal(signal, l10n),
        isConcern: true,
      ),
    );
  }
  if (provenance.signals.isEmpty && provenance.indicatesHumanAuthorship) {
    findings.add(
      VerifiableFinding(
        statement: l10n.findingEditingRecordNormal(
          provenance.editingDuration?.inMinutes ?? 0,
          provenance.revisionCount ?? 0,
        ),
        isConcern: false,
      ),
    );
  }

  return findings;
}
