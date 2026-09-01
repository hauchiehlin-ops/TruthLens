import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/report/report_composer.dart';
import '../../features/report/report_document.dart';
import '../../features/report/bibliography_presentation.dart';
import '../../features/report/summary_card.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/verdict_palette.dart';
import '../models/detection_result.dart';
import 'bibliography_verifier.dart';
import 'citation_evidence.dart';
import 'claim_audit.dart';
import 'forensic_evidence.dart';
import 'integrated_assessment.dart';
import 'publication_evidence.dart';
import '../utils/text_stats.dart';

/// 報告匯出：CSV（逐句數據）、JSON（系統整合）與 PDF（完整報告）。
/// 產生邏輯（buildCsv / buildJson / buildPdf）與存檔對話框分離，前者可單元測試。
///
/// 已知限制：PDF 內嵌字型為 Noto Sans TC（含完整拉丁/西里爾/日文假名/中日韓表意
/// 文字），但**不含韓文諺文（Hangul）與泰文字母**；若報告語系為韓文或泰文，
/// PDF 匯出中對應文字可能顯示為缺字方框，畫面顯示與 CSV/JSON 匯出不受影響。
class ReportExporter {
  static final _composer = ReportComposer();

  /// PDF「逐句分析」表格的列數上限。超長或含大量句子的文件（例如誤貼入原始
  /// OOXML 標記、缺乏標點導致斷句失敗）逐句渲染會讓 pdf 套件的 MultiPage
  /// 分頁安全機制丟出 PdfTooBigPageException；改用 CSV/JSON 匯出可取得完整資料。
  static const _pdfMaxTableRows = 300;

  /// 單一句子在 PDF 表格中顯示的字元數上限，避免單一儲存格內容過長
  /// （例如缺乏斷句標點的超長字串）撐爆分頁演算法。
  static const _pdfMaxCellChars = 600;

  static String _truncateForPdf(String text) {
    if (text.length <= _pdfMaxCellChars) return text;
    return '${text.substring(0, _pdfMaxCellChars)}…';
  }

  static List<SentenceScore> _analyzableSentences(DetectionResult r) => r
      .sentences
      .where((s) => PreprocessedText.isAnalyzableSentence(s.text))
      .toList();

  static ({String label, String body}) _privacySealParts(
    AppLocalizations l10n,
  ) {
    final text = l10n.privacySealNoticeText;
    final separator = RegExp(r'[:：]').firstMatch(text);
    if (separator == null) return (label: text, body: '');
    return (
      label: text.substring(0, separator.start).trim(),
      body: text.substring(separator.end).trim(),
    );
  }

  static String _integratedDirectionLabel(
    IntegratedAssessment assessment,
    AppLocalizations l10n,
  ) => switch (assessment.conclusion) {
    IntegratedConclusion.insufficientEvidence =>
      l10n.integratedInsufficientEvidence,
    IntegratedConclusion.preliminaryAi => l10n.integratedPreliminaryAi,
    IntegratedConclusion.preliminaryHuman => l10n.integratedPreliminaryHuman,
    IntegratedConclusion.likelyAi => l10n.integratedLikelyAi,
    IntegratedConclusion.likelyHuman => l10n.integratedLikelyHuman,
    IntegratedConclusion.likelyMixed => l10n.integratedLikelyMixed,
    IntegratedConclusion.noClearDominance => l10n.integratedBalanced,
  };

  static String _integratedConfidenceLabel(
    IntegratedAssessment assessment,
    AppLocalizations l10n,
  ) => switch (assessment.confidence) {
    IntegratedConfidence.low => l10n.integratedConfidenceLow,
    IntegratedConfidence.moderate => l10n.integratedConfidenceModerate,
    IntegratedConfidence.high => l10n.integratedConfidenceHigh,
  };

  static String _integratedEvidenceTierLabel(
    IntegratedAssessment assessment,
    AppLocalizations l10n,
  ) => switch (assessment.confidence) {
    IntegratedConfidence.low => l10n.integratedEvidenceTierScreening,
    IntegratedConfidence.moderate => l10n.integratedEvidenceTierReference,
    IntegratedConfidence.high => l10n.integratedEvidenceTierStrong,
  };

  static String? _integratedBoundaryExplanation(
    IntegratedAssessment assessment,
    AppLocalizations l10n,
  ) => switch (assessment.conclusion) {
    IntegratedConclusion.preliminaryAi => l10n.integratedBoundaryAi(
      assessment.evidenceIndex,
      assessment.aiEscalationGap,
    ),
    IntegratedConclusion.preliminaryHuman => l10n.integratedBoundaryHuman(
      assessment.evidenceIndex,
      assessment.aiEscalationGap,
    ),
    _ => null,
  };

  static String _pdfAbstentionReason(
    DetectionResult result,
    AppLocalizations l10n,
  ) => switch (result.abstention) {
    AbstentionReason.none => '',
    AbstentionReason.tooFewSentences => l10n.abstentionTooFewSentences(
      result.analyzableSentenceCount,
      DetectionResult.minAnalyzableSentences,
    ),
    AbstentionReason.tooFewWords => l10n.abstentionTooFewWords(
      result.wordCount,
      DetectionResult.minWords,
    ),
    AbstentionReason.tooFewEngines => l10n.abstentionTooFewEngines(
      result.effectiveAvailableEngineCount,
      result.effectiveTotalEngineCount,
    ),
    AbstentionReason.enginesConflict => l10n.abstentionEnginesConflict(
      result.engineSpreadPoints,
    ),
    AbstentionReason.noEvidenceFound => l10n.abstentionNoEvidenceFound,
    AbstentionReason.singleWeakEvidenceSource =>
      l10n.abstentionSingleWeakEvidenceSource(result.evidenceEngineCount),
  };

  /// 結構化 JSON（plan 第九節：LMS / 系統整合）。欄位名稱為固定的英文 API schema，
  /// 不隨語系翻譯，僅 headline／reasons 等自然語言內容依 [l10n] 呈現。
  static String buildJson(
    DetectionResult r,
    AppLocalizations l10n, {
    ReportDocument? reportDocument,
    List<BibliographyCheckResult>? bibliographyChecks,
    PublicationEvidence publicationEvidence = PublicationEvidence.none,
  }) {
    final doc = reportDocument ?? _composer.compose(r, l10n);
    final orderedBibliographyChecks = bibliographyChecks == null
        ? null
        : orderBibliographyChecks(bibliographyChecks);
    final citations = CitationEvidence.fromChecks(
      orderedBibliographyChecks ?? const [],
    );
    final claims = ClaimAudit.analyze(r.inputText);
    final matrix = ForensicEvidenceMatrix.assess(
      r,
      citations: citations,
      claims: claims,
      publication: publicationEvidence,
    );
    final integrated = IntegratedAssessment.assess(
      r,
      citations: citations,
      claims: claims,
      publication: publicationEvidence,
    );
    final map = {
      'version': 4,
      'analyzed_at': r.analyzedAt.toIso8601String(),
      'source_file_name': r.sourceFileName,
      'headline': doc.headline,
      'report_source': doc.source.name,
      'template_id': doc.templateId,
      'report_components': [
        for (final c in doc.components)
          {
            'type': c.type.name,
            if (c.title != null) 'title': c.title,
            if (c.body != null) 'body': c.body,
          },
      ],
      'overall': {
        'integrated_ai_likelihood': integrated.aiLikelihood,
        'ai_evidence_index': integrated.pointEstimateAvailable
            ? integrated.evidenceIndex
            : null,
        'integrated_direction': integrated.direction.name,
        'integrated_conclusion': integrated.conclusion.name,
        'integrated_confidence': integrated.confidence.name,
        'integrated_confidence_score': integrated.confidenceScore,
        'evidence_sufficiency': integrated.evidenceSufficiency,
        'text_model_reliability': integrated.textReliability,
        'text_authorship_class': integrated.textAuthorshipClass.name,
        'analysis_domain': integrated.analysisDomain.name,
        'independent_evidence_families': integrated.independentEvidenceFamilies,
        'applicability_coverage': integrated.applicabilityCoverage,
        'evidence_coverage': integrated.evidenceCoverage,
        'ai_evidence_gate_passed': integrated.passesAiEvidenceGate,
        'has_authorship_evidence': integrated.hasAuthorshipEvidence,
        'segment_stability_available': integrated.stabilityAvailable,
        'segment_stability': integrated.stabilityScore,
        'segment_interval': {
          'lower': integrated.lowerBound,
          'upper': integrated.upperBound,
        },
        'confidence_ceiling': integrated.confidenceCeiling,
        'source_publication': {
          'status': publicationEvidence.status.name,
          'doi': publicationEvidence.doi,
          'title': publicationEvidence.articleTitle,
          'journal': publicationEvidence.journalName,
          'year': publicationEvidence.publicationYear,
          'title_similarity': publicationEvidence.titleSimilarity,
          'supports_human_authorship':
              publicationEvidence.supportsHumanAuthorship,
        },
        'input_quality': {
          'method': r.inputQuality.method.name,
          'extraction_quality': r.inputQuality.extractionQuality,
          'limitations': r.inputQuality.limitations,
        },
        'local_calibration': {
          'applicable': r.calibration.isApplicable,
          'flagged': r.calibration.isFlagged,
          'p_value': r.calibration.pValue,
          'percentile': r.calibration.percentile,
          'sample_count': r.calibration.calibrationSize,
          'alpha': r.calibration.alpha,
          'analysis_signature': r.calibration.analysisSignature,
          'language': r.calibration.language,
          'domain': r.calibration.domain,
          'length_bucket': r.calibration.lengthBucket,
        },
        'evidence_contributions': [
          for (final contribution in integrated.contributions)
            {'axis': contribution.kind.name, 'log_odds': contribution.logOdds},
        ],
        'text_model_ai_probability': r.aiProbability,
        'ai_probability': r.aiProbability,
        'verdict': r.verdict.name,
        'flagged_as_ai': r.flaggedAsAi,
        'threshold': DetectionResult.aiFlagThreshold,
      },
      'esl_adjusted': r.eslAdjusted,
      'sentence_count': r.analyzableSentenceCount,
      'ai_sentences': r.aiSentenceCount,
      'human_sentences': r.humanSentenceCount,
      'evidence_matrix': {
        'available_axes': matrix.availableAxisCount,
        'total_axes': matrix.totalAxisCount,
        'axes': [
          for (final axis in matrix.axes)
            {
              'id': axis.kind.name,
              'state': axis.state.name,
              'strength': axis.strength.name,
            },
        ],
      },
      'claim_source_audit': {
        'total': claims.total,
        'sourced': claims.sourced,
        'unsupported': claims.unsupported,
        'risk': claims.risk.name,
      },
      'engines': [
        for (final e in r.engineScores)
          {
            'id': e.engineId,
            'name': e.engineName,
            'available': e.available,
            'ai_probability': e.aiProbability,
            'weight': e.weight,
            'reasons': e.reasons,
            'features': e.features,
          },
      ],
      'sentences': [
        for (final s in _analyzableSentences(r))
          {
            'index': s.index,
            'text': PreprocessedText.normalizeSentenceForAnalysis(s.text),
            'ai_probability': s.aiProbability,
            'patterns': s.patterns,
          },
      ],
      if (orderedBibliographyChecks != null)
        'bibliography_verification': [
          for (final check in orderedBibliographyChecks)
            {
              'citation': check.entry.rawText,
              'status': check.confidence.name,
              'status_label': _bibliographyStatus(check, l10n),
              if (check.matchedTitle != null)
                'matched_title': check.matchedTitle,
              if (check.matchedJournal != null)
                'matched_journal': check.matchedJournal,
              if (check.verificationSource != null)
                'verification_source': check.verificationSource,
              'journal_name_mismatch': check.journalNameMismatch,
              if (check.journalNameMismatch)
                'journal_name_warning': l10n.reportBibJournalMismatch(
                  check.entry.venueTitle ?? '',
                  check.matchedJournal ?? '',
                ),
              if (check.matchedYear != null) 'matched_year': check.matchedYear,
            },
        ],
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// 逐句數據表。`#` 開頭為摘要註解列，方便試算表與程式兩用。
  static String buildCsv(
    DetectionResult r,
    AppLocalizations l10n, {
    PublicationEvidence publicationEvidence = PublicationEvidence.none,
  }) {
    final claims = ClaimAudit.analyze(r.inputText);
    final integrated = IntegratedAssessment.assess(
      r,
      claims: claims,
      publication: publicationEvidence,
    );
    final buf = StringBuffer()
      ..writeln('# ${l10n.exportReportTitle}')
      ..writeln('# analyzed_at,${r.analyzedAt.toIso8601String()}')
      ..writeln(
        '# overall_ai_probability,${r.aiProbability.toStringAsFixed(4)}',
      )
      ..writeln(
        '# integrated_ai_likelihood,${integrated.pointEstimateAvailable ? integrated.aiLikelihood.toStringAsFixed(4) : ''}',
      )
      ..writeln(
        '# integrated_point_estimate_available,${integrated.pointEstimateAvailable}',
      )
      ..writeln('# integrated_direction,${integrated.direction.name}')
      ..writeln('# integrated_confidence,${integrated.confidence.name}')
      ..writeln(
        '# text_model_reliability,${integrated.textReliability.toStringAsFixed(4)}',
      )
      ..writeln(
        '# text_authorship_class,${integrated.textAuthorshipClass.name}',
      )
      ..writeln('# analysis_domain,${integrated.analysisDomain.name}')
      ..writeln(
        '# independent_evidence_families,${integrated.independentEvidenceFamilies}',
      )
      ..writeln(
        '# applicability_coverage,${integrated.applicabilityCoverage.toStringAsFixed(4)}',
      )
      ..writeln(
        '# evidence_coverage,${integrated.evidenceCoverage.toStringAsFixed(4)}',
      )
      ..writeln('# ai_evidence_gate_passed,${integrated.passesAiEvidenceGate}')
      ..writeln('# has_authorship_evidence,${integrated.hasAuthorshipEvidence}')
      ..writeln(
        '# segment_stability_available,${integrated.stabilityAvailable}',
      )
      ..writeln(
        '# segment_stability,${integrated.stabilityScore.toStringAsFixed(4)}',
      )
      ..writeln(
        '# segment_interval,${integrated.lowerBound.toStringAsFixed(4)}-${integrated.upperBound.toStringAsFixed(4)}',
      )
      ..writeln(
        '# input_extraction_quality,${r.inputQuality.extractionQuality.toStringAsFixed(4)}',
      )
      ..writeln('# local_calibration_applicable,${r.calibration.isApplicable}')
      ..writeln('# local_calibration_flagged,${r.calibration.isFlagged}')
      ..writeln('# local_calibration_p_value,${r.calibration.pValue}')
      ..writeln('# verdict,${r.verdict.name}')
      ..writeln('# esl_adjusted,${r.eslAdjusted}')
      ..writeln('# checkable_claims,${claims.total}')
      ..writeln('# unsupported_claims,${claims.unsupported}')
      ..writeln(
        '# source_publication_status,${publicationEvidence.status.name}',
      )
      ..writeln('# source_publication_doi,${publicationEvidence.doi ?? ''}')
      ..writeln(
        '# source_publication_year,${publicationEvidence.publicationYear ?? ''}',
      )
      ..writeln('index,sentence,ai_probability,patterns');
    for (final s in _analyzableSentences(r)) {
      buf.writeln(
        [
          s.index.toString(),
          _csvEscape(PreprocessedText.normalizeSentenceForAnalysis(s.text)),
          s.aiProbability.toStringAsFixed(4),
          _csvEscape(s.patterns.join('; ')),
        ].join(','),
      );
    }
    return buf.toString();
  }

  static String _csvEscape(String value) {
    if (value.contains(RegExp(r'[",\n]'))) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// 產生 PDF 位元組。字型由呼叫端注入（App 走 rootBundle，測試直接讀檔）。
  static Future<Uint8List> buildPdf(
    DetectionResult r,
    AppLocalizations l10n, {
    required ByteData regularFont,
    required ByteData boldFont,
    ReportDocument? reportDocument,
    List<BibliographyCheckResult>? bibliographyChecks,
    PublicationEvidence publicationEvidence = PublicationEvidence.none,
  }) async {
    final orderedBibliographyChecks = bibliographyChecks == null
        ? null
        : orderBibliographyChecks(bibliographyChecks);
    final reportDoc = reportDocument ?? _composer.compose(r, l10n);
    final claims = ClaimAudit.analyze(r.inputText);
    final citations = CitationEvidence.fromChecks(
      orderedBibliographyChecks ?? const [],
    );
    final evidenceMatrix = ForensicEvidenceMatrix.assess(
      r,
      citations: citations,
      claims: claims,
      publication: publicationEvidence,
    );
    final integrated = IntegratedAssessment.assess(
      r,
      citations: citations,
      claims: claims,
      publication: publicationEvidence,
    );
    final regular = pw.Font.ttf(regularFont);
    final bold = pw.Font.ttf(boldFont);
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);

    // 與畫面共用同一套判定色階，並經 Verdict.fromProbability 取級距——
    // 原本這裡自己寫死 0.2/0.4/0.6/0.8 並用另一組顏色，切點一改就會與
    // 畫面不一致，同一份判定在 PDF 與 App 裡看起來也是兩回事。
    PdfColor scoreColor(double p) =>
        PdfColor.fromInt(verdictColor(Verdict.fromProbability(p)).toARGB32());

    final analyzableSentences = _analyzableSentences(r);
    final privacySeal = _privacySealParts(l10n);
    final contributionPoints = r.roundedEngineContributionPoints;

    final doc = pw.Document(theme: theme);
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            l10n.pdfPageFooter(ctx.pageNumber, ctx.pagesCount),
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
        build: (ctx) => [
          pw.Text(
            l10n.exportReportTitle,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            l10n.pdfAnalyzedAtElapsed(
              r.analyzedAt.toLocal().toString().substring(0, 19),
              (r.elapsed.inMilliseconds / 1000).toStringAsFixed(1),
            ),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Divider(),

          // 整體判定
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: scoreColor(integrated.aiLikelihood)),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  _integratedDirectionLabel(integrated, l10n),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  '${integrated.pointEstimateAvailable ? l10n.integratedLikelihoodLabel(integrated.evidenceIndex) : l10n.integratedLikelihoodUnavailable}\n'
                  '${l10n.integratedConfidenceLabel(_integratedConfidenceLabel(integrated, l10n))}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: scoreColor(integrated.aiLikelihood),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            l10n.integratedEvidenceSufficiency(
              integrated.evidenceSufficiency,
              _integratedEvidenceTierLabel(integrated, l10n),
            ),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          if (_integratedBoundaryExplanation(integrated, l10n)
              case final explanation?)
            pw.Text(
              explanation,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${l10n.integratedTextScoreLabel((r.aiProbability * 100).round())} '
            '${r.eslAdjusted ? l10n.pdfEslAppliedSuffix : ''}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            integrated.stabilityAvailable
                ? l10n.integratedStabilityLabel(
                    (integrated.stabilityScore * 100).round(),
                    (integrated.lowerBound * 100).round(),
                    (integrated.upperBound * 100).round(),
                  )
                : l10n.integratedStabilityUnavailable,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          if (r.inputQuality.extractionQuality < 0.95)
            pw.Text(
              l10n.integratedInputQualityLabel(
                (r.inputQuality.extractionQuality * 100).round(),
              ),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          if (r.calibration.isApplicable)
            pw.Text(
              l10n.integratedCalibrationLabel(
                r.calibration.pValue.toStringAsFixed(3),
                r.calibration.calibrationSize,
              ),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          pw.SizedBox(height: 3),
          pw.Text(
            l10n.integratedIndexCaveat,
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
          ),
          if (r.hasEvidenceLimitations) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              l10n.integratedQualifiedWarning(_pdfAbstentionReason(r, l10n)),
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.grey700,
              ),
            ),
          ],
          pw.SizedBox(height: 6),
          pw.Text(
            l10n.pdfSentenceCounts(
              r.analyzableSentenceCount,
              r.aiSentenceCount,
              r.humanSentenceCount,
            ),
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),

          // MVP 3: Zero-Cloud Privacy Audit Seal
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF0F4F8),
              border: pw.Border.all(
                color: PdfColor.fromInt(0xFFB0BEC5),
                width: 0.8,
              ),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  '[ ${privacySeal.label} ] ',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromInt(0xFF1565C0),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    privacySeal.body,
                    style: const pw.TextStyle(
                      fontSize: 8.5,
                      color: PdfColor.fromInt(0xFF37474F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),

          pw.Text(
            l10n.evidenceMatrixTitle,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            '${l10n.evidenceMatrixSubtitle} ${l10n.evidenceMatrixCoverage(evidenceMatrix.availableAxisCount, evidenceMatrix.totalAxisCount)}',
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 6),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.2),
              1: pw.FlexColumnWidth(1.2),
              2: pw.FlexColumnWidth(1.0),
            },
            children: [
              for (final axis in evidenceMatrix.axes)
                pw.TableRow(
                  children: [
                    _cell(_evidenceAxisLabel(axis.kind, l10n), bold: true),
                    _cell(_evidenceStateLabel(axis.state, l10n)),
                    _cell(_evidenceStrengthLabel(axis.strength, l10n)),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 12),

          // 分析解讀（與 App 內報告同一份 ReportDocument，可能來自 LLM）
          pw.Text(
            l10n.composerNarrativeTitle,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            reportDoc.headline,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          for (final c in reportDoc.components)
            if ((c.body ?? '').isNotEmpty && c.type.name != 'thresholdBanner')
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  c.title != null ? '${c.title}：${c.body}' : c.body!,
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
                ),
              ),
          pw.SizedBox(height: 14),

          // 引擎明細
          pw.Text(
            l10n.reportEngineBreakdownTitle,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            l10n.reportTextEngineSignalExplanation,
            style: const pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey700,
              lineSpacing: 1.5,
            ),
          ),
          pw.SizedBox(height: 6),
          for (final e in r.engineScores)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    e.available
                        ? '${e.engineName} — ${l10n.reportEngineSignalLabel((e.aiProbability * 100).round())}'
                        : '${e.engineName} — ${l10n.reportEngineNotParticipated}',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (e.available)
                    pw.Text(
                      l10n.reportEngineRelationshipAvailable(
                        (e.weight * 100).round(),
                        contributionPoints[e.engineId] ?? 0,
                        '',
                      ),
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  for (final reason in e.reasons)
                    pw.Bullet(
                      text: reason,
                      style: const pw.TextStyle(fontSize: 9),
                      bulletSize: 1.5,
                    ),
                ],
              ),
            ),
          pw.SizedBox(height: 10),

          if (orderedBibliographyChecks != null) ...[
            pw.Text(
              l10n.reportBibAuthenticityTitle,
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              l10n.reportBibResultHint,
              style: const pw.TextStyle(
                fontSize: 8.5,
                color: PdfColors.grey700,
              ),
            ),
            pw.SizedBox(height: 6),
            if (orderedBibliographyChecks.isEmpty)
              pw.Text(
                l10n.reportBibNoneDetected,
                style: const pw.TextStyle(fontSize: 9),
              )
            else
              for (var i = 0; i < orderedBibliographyChecks.length; i++)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 7),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '${i + 1}. ${_truncateForPdf(orderedBibliographyChecks[i].entry.rawText)}',
                        style: pw.TextStyle(
                          fontSize: 9.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      ..._bibliographyStatusWidgets(
                        orderedBibliographyChecks[i],
                        l10n,
                      ),
                    ],
                  ),
                ),
            pw.SizedBox(height: 10),
          ],

          // 逐句分析（超過上限僅顯示前段，避免大量/超長句子撐爆 PDF 分頁）
          pw.Text(
            l10n.reportSentenceAnalysisTitle,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          if (analyzableSentences.length > _pdfMaxTableRows)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(
                l10n.pdfTruncationNotice(
                  _pdfMaxTableRows,
                  analyzableSentences.length,
                  l10n.reportExportCsv,
                  l10n.reportExportJson,
                ),
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
            ),
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(24),
              1: const pw.FlexColumnWidth(),
              2: const pw.FixedColumnWidth(40),
            },
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _cell('#', bold: true),
                  _cell(l10n.pdfSentenceColumnHeader, bold: true),
                  _cell('AI%', bold: true),
                ],
              ),
              for (final s in analyzableSentences.take(_pdfMaxTableRows))
                pw.TableRow(
                  children: [
                    _cell('${s.index + 1}'),
                    _cell(
                      _truncateForPdf(
                        s.patterns.isEmpty
                            ? PreprocessedText.normalizeSentenceForAnalysis(
                                s.text,
                              )
                            : '${PreprocessedText.normalizeSentenceForAnalysis(s.text)}\n→ ${s.patterns.join('、')}',
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text(
                        '${(s.aiProbability * 100).round()}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: scoreColor(s.aiProbability),
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
    return doc.save();
  }

  static pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 9,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );

  static String _evidenceAxisLabel(
    EvidenceAxisKind kind,
    AppLocalizations l10n,
  ) => switch (kind) {
    EvidenceAxisKind.textTrace => l10n.evidenceAxisText,
    EvidenceAxisKind.writingProcess => l10n.evidenceAxisProcess,
    EvidenceAxisKind.documentOrigin => l10n.evidenceAxisOrigin,
    EvidenceAxisKind.sourceIntegrity => l10n.evidenceAxisSources,
  };

  static String _evidenceStateLabel(
    EvidenceAxisState state,
    AppLocalizations l10n,
  ) => switch (state) {
    EvidenceAxisState.unavailable => l10n.evidenceStateUnavailable,
    EvidenceAxisState.inconclusive => l10n.evidenceStateInconclusive,
    EvidenceAxisState.reassuring => l10n.evidenceStateReassuring,
    EvidenceAxisState.concern => l10n.evidenceStateConcern,
  };

  static String _evidenceStrengthLabel(
    EvidenceStrength strength,
    AppLocalizations l10n,
  ) => switch (strength) {
    EvidenceStrength.none => l10n.evidenceStrengthNone,
    EvidenceStrength.limited => l10n.evidenceStrengthLimited,
    EvidenceStrength.moderate => l10n.evidenceStrengthModerate,
    EvidenceStrength.strong => l10n.evidenceStrengthStrong,
  };

  static String _bibliographyStatus(
    BibliographyCheckResult check,
    AppLocalizations l10n,
  ) {
    final presentation = presentBibliographyCheck(check, l10n);
    return [
      presentation.status,
      if (presentation.source != null) presentation.source!,
      if (presentation.warning != null) presentation.warning!,
    ].join('\n');
  }

  static List<pw.Widget> _bibliographyStatusWidgets(
    BibliographyCheckResult check,
    AppLocalizations l10n,
  ) {
    final presentation = presentBibliographyCheck(check, l10n);
    pw.Widget line(String value, BibliographyDisplayTone tone) => pw.Text(
      value,
      style: pw.TextStyle(fontSize: 9, color: _bibliographyPdfColor(tone)),
    );

    return [
      line(presentation.status, presentation.tone),
      if (presentation.source != null)
        pw.Text(presentation.source!, style: const pw.TextStyle(fontSize: 9)),
      if (presentation.warning != null)
        line(
          presentation.warning!,
          presentation.warningTone ?? BibliographyDisplayTone.mismatch,
        ),
    ];
  }

  static PdfColor _bibliographyPdfColor(BibliographyDisplayTone tone) =>
      switch (tone) {
        BibliographyDisplayTone.success => PdfColors.green700,
        BibliographyDisplayTone.warning => PdfColors.orange800,
        BibliographyDisplayTone.mismatch => PdfColors.blue700,
        BibliographyDisplayTone.error => PdfColors.red700,
      };

  // ---- 存檔（UI 層呼叫）----

  static String _timestamp(DateTime t) =>
      '${t.year}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}'
      '_${t.hour.toString().padLeft(2, '0')}${t.minute.toString().padLeft(2, '0')}';

  /// 回傳儲存路徑；使用者取消時回傳 null。
  /// 加 UTF-8 BOM 讓 Excel 正確辨識中文編碼。
  static Future<String?> exportCsv(
    DetectionResult r,
    AppLocalizations l10n, {
    ReportDocument? reportDocument,
    List<BibliographyCheckResult>? bibliographyChecks,
    PublicationEvidence? publicationEvidence,
  }) async {
    final bytes = Uint8List.fromList([
      0xEF,
      0xBB,
      0xBF,
      ...utf8.encode(
        buildCsv(
          r,
          l10n,
          publicationEvidence: publicationEvidence ?? PublicationEvidence.none,
        ),
      ),
    ]);
    return _save(
      bytes: bytes,
      fileName: 'omnitrace_${_timestamp(r.analyzedAt)}.csv',
      extension: 'csv',
      l10n: l10n,
    );
  }

  static Future<String?> exportJson(
    DetectionResult r,
    AppLocalizations l10n, {
    ReportDocument? reportDocument,
    List<BibliographyCheckResult>? bibliographyChecks,
    PublicationEvidence? publicationEvidence,
  }) async {
    final bytes = Uint8List.fromList([
      0xEF,
      0xBB,
      0xBF,
      ...utf8.encode(
        buildJson(
          r,
          l10n,
          reportDocument: reportDocument,
          bibliographyChecks: bibliographyChecks,
          publicationEvidence: publicationEvidence ?? PublicationEvidence.none,
        ),
      ),
    ]);
    return _save(
      bytes: bytes,
      fileName: 'omnitrace_${_timestamp(r.analyzedAt)}.json',
      extension: 'json',
      l10n: l10n,
    );
  }

  static Future<String?> exportPng(
    DetectionResult r,
    AppLocalizations l10n, {
    ReportDocument? reportDocument,
    List<BibliographyCheckResult>? bibliographyChecks,
    PublicationEvidence? publicationEvidence,
  }) async {
    final bytes = await SummaryCard.renderPng(
      r,
      l10n,
      publicationEvidence: publicationEvidence ?? PublicationEvidence.none,
    );
    return _save(
      bytes: bytes,
      fileName: 'omnitrace_${_timestamp(r.analyzedAt)}.png',
      extension: 'png',
      l10n: l10n,
    );
  }

  static Future<String?> exportPdf(
    DetectionResult r,
    AppLocalizations l10n, {
    ReportDocument? reportDocument,
    List<BibliographyCheckResult>? bibliographyChecks,
    PublicationEvidence? publicationEvidence,
  }) async {
    final bytes = await buildPdf(
      r,
      l10n,
      regularFont: await rootBundle.load('assets/fonts/NotoSansTC-Regular.ttf'),
      boldFont: await rootBundle.load('assets/fonts/NotoSansTC-Bold.ttf'),
      reportDocument: reportDocument,
      bibliographyChecks: bibliographyChecks,
      publicationEvidence: publicationEvidence ?? PublicationEvidence.none,
    );
    return _save(
      bytes: bytes,
      fileName: 'omnitrace_${_timestamp(r.analyzedAt)}.pdf',
      extension: 'pdf',
      l10n: l10n,
    );
  }

  static Future<String?> _save({
    required Uint8List bytes,
    required String fileName,
    required String extension,
    required AppLocalizations l10n,
  }) async {
    // file_picker 11：提供 bytes 時，行動/桌面平台皆由 picker 寫入檔案
    return FilePicker.saveFile(
      dialogTitle: l10n.reportExportTooltip,
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [extension],
      bytes: bytes,
    );
  }
}
