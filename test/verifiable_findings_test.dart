import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/evasion_scanner.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/core/services/citation_evidence.dart';
import 'package:omnitrace/core/services/document_provenance.dart';
import 'package:omnitrace/features/report/verifiable_findings.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

/// 這份清單的價值在於**每一條都能被獨立驗證**。
/// 混進機率或分數會讓整份清單降級成「又一個判斷」。
void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  DetectionResult result({
    DocumentProvenance provenance = DocumentProvenance.none,
    EvasionScan evasion = EvasionScan.clean,
  }) => DetectionResult(
    id: 'f',
    analyzedAt: DateTime(2026, 8, 19),
    inputText: List.filled(200, 'alpha').join(' '),
    aiProbability: 0.32,
    verdict: Verdict.likelyHuman,
    provenance: provenance,
    evasion: evasion,
    engineScores: const [],
    sentences: const [],
  );

  test('沒有任何可查證的證據時，清單是空的——不硬湊', () {
    expect(collectVerifiableFindings(result(), l10n), isEmpty);
  });

  test('捏造引用會列為需要解釋的發現', () {
    final findings = collectVerifiableFindings(
      result(),
      l10n,
      citations: const CitationEvidence(
        total: 12,
        verified: 8,
        uncertain: 0,
        notFound: 4,
      ),
    );
    expect(findings, hasLength(1));
    expect(findings.single.isConcern, isTrue);
    expect(findings.single.statement, contains('4 of 12'));
  });

  test('引用全數可核實時列為正面觀察，不是警訊', () {
    final findings = collectVerifiableFindings(
      result(),
      l10n,
      citations: const CitationEvidence(total: 9, verified: 9),
    );
    expect(findings.single.isConcern, isFalse);
  });

  test('少量查無此文仍列出，但不標為需解釋——收錄不全是常態', () {
    final findings = collectVerifiableFindings(
      result(),
      l10n,
      citations: const CitationEvidence(total: 20, verified: 19, notFound: 1),
    );
    expect(findings.single.isConcern, isFalse);
  });

  test('規避痕跡排在最前面——它顯示有人動過手腳', () {
    final findings = collectVerifiableFindings(
      result(
        evasion: const EvasionScan(
          findings: [EvasionFinding(kind: EvasionKind.homoglyph, count: 7)],
          characterCount: 1000,
        ),
        provenance: const DocumentProvenance(
          sourceFormat: 'docx',
          editingDuration: Duration.zero,
          bodyWordCount: 2462,
          signals: [
            ProvenanceSignal(
              kind: ProvenanceSignalKind.negligibleEditingTime,
              severity: ProvenanceSeverity.strong,
              values: {'words': 2462},
            ),
          ],
        ),
      ),
      l10n,
      citations: const CitationEvidence(total: 10, verified: 6, notFound: 4),
    );

    expect(findings.length, 3);
    expect(findings.first.statement, contains('evasion'));
    expect(findings[1].statement, contains('cited works'));
    expect(findings.every((f) => f.isConcern), isTrue);
  });

  test('編輯紀錄正常時列為正面觀察', () {
    final findings = collectVerifiableFindings(
      result(
        provenance: const DocumentProvenance(
          sourceFormat: 'docx',
          editingDuration: Duration(minutes: 95),
          revisionCount: 14,
          distinctBodyRsids: 22,
          bodyWordCount: 1800,
        ),
      ),
      l10n,
    );
    expect(findings, hasLength(1));
    expect(findings.single.isConcern, isFalse);
    expect(findings.single.statement, contains('95'));
  });

  _orderMatters();
}

/// 順序本身就是設計：事實在前、機率在後。
void _orderMatters() {
  test('清單依證據力排序：規避痕跡 → 引用 → 編輯紀錄', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final findings = collectVerifiableFindings(
      DetectionResult(
        id: 'o',
        analyzedAt: DateTime(2026, 8, 19),
        inputText: List.filled(200, 'alpha').join(' '),
        aiProbability: 0.30,
        verdict: Verdict.likelyHuman,
        evasion: const EvasionScan(
          findings: [EvasionFinding(kind: EvasionKind.bidiControl, count: 2)],
          characterCount: 900,
        ),
        provenance: const DocumentProvenance(
          sourceFormat: 'docx',
          editingDuration: Duration.zero,
          bodyWordCount: 1500,
          signals: [
            ProvenanceSignal(
              kind: ProvenanceSignalKind.negligibleEditingTime,
              severity: ProvenanceSeverity.strong,
              values: {'words': 1500},
            ),
          ],
        ),
        engineScores: const [],
        sentences: const [],
      ),
      l10n,
      citations: const CitationEvidence(total: 10, verified: 5, notFound: 5),
    );

    // 規避痕跡最直接（有人動過手腳），其次是可查證的引用，最後是檔案紀錄
    expect(findings[0].statement, contains('evasion'));
    expect(findings[1].statement, contains('cited works'));
    expect(findings.length, 3);
  });
}
