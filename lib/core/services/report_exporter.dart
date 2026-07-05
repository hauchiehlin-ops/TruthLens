import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/report/report_composer.dart';
import '../../features/report/summary_card.dart';
import '../../l10n/generated/app_localizations.dart';
import '../models/detection_result.dart';

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

  /// 結構化 JSON（plan 第九節：LMS / 系統整合）。欄位名稱為固定的英文 API schema，
  /// 不隨語系翻譯，僅 headline／reasons 等自然語言內容依 [l10n] 呈現。
  static String buildJson(DetectionResult r, AppLocalizations l10n) {
    final doc = _composer.compose(r, l10n);
    final map = {
      'version': 1,
      'analyzed_at': r.analyzedAt.toIso8601String(),
      'headline': doc.headline,
      'overall': {
        'ai_probability': r.aiProbability,
        'verdict': r.verdict.name,
        'flagged_as_ai': r.flaggedAsAi,
        'threshold': r.threshold,
      },
      'esl_adjusted': r.eslAdjusted,
      'sentence_count': r.sentences.length,
      'ai_sentences': r.aiSentenceCount,
      'human_sentences': r.humanSentenceCount,
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
          }
      ],
      'sentences': [
        for (final s in r.sentences)
          {
            'index': s.index,
            'text': s.text,
            'ai_probability': s.aiProbability,
            'patterns': s.patterns,
          }
      ],
    };
    return const JsonEncoder.withIndent('  ').convert(map);
  }

  /// 逐句數據表。`#` 開頭為摘要註解列，方便試算表與程式兩用。
  static String buildCsv(DetectionResult r, AppLocalizations l10n) {
    final buf = StringBuffer()
      ..writeln('# ${l10n.exportReportTitle}')
      ..writeln('# analyzed_at,${r.analyzedAt.toIso8601String()}')
      ..writeln(
          '# overall_ai_probability,${r.aiProbability.toStringAsFixed(4)}')
      ..writeln('# verdict,${r.verdict.name}')
      ..writeln('# esl_adjusted,${r.eslAdjusted}')
      ..writeln('index,sentence,ai_probability,patterns');
    for (final s in r.sentences) {
      buf.writeln([
        s.index.toString(),
        _csvEscape(s.text),
        s.aiProbability.toStringAsFixed(4),
        _csvEscape(s.patterns.join('; ')),
      ].join(','));
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
  }) async {
    final regular = pw.Font.ttf(regularFont);
    final bold = pw.Font.ttf(boldFont);
    final theme = pw.ThemeData.withFont(base: regular, bold: bold);

    PdfColor scoreColor(double p) {
      if (p < 0.2) return PdfColor.fromInt(0xFF4CAF50);
      if (p < 0.4) return PdfColor.fromInt(0xFFCDDC39);
      if (p < 0.6) return PdfColor.fromInt(0xFFFF9800);
      if (p < 0.8) return PdfColor.fromInt(0xFFFF5722);
      return PdfColor.fromInt(0xFFF44336);
    }

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
          pw.Text(l10n.exportReportTitle,
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(
            l10n.pdfAnalyzedAtElapsed(
                r.analyzedAt.toLocal().toString().substring(0, 19),
                (r.elapsed.inMilliseconds / 1000).toStringAsFixed(1)),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.Divider(),

          // 整體判定
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: scoreColor(r.aiProbability)),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(l10n.reportOverallVerdictLabel(r.verdict.label(l10n)),
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  '${l10n.reportAiProbabilityLabel} '
                  '${(r.aiProbability * 100).round()}%'
                  '${r.eslAdjusted ? l10n.pdfEslAppliedSuffix : ''}',
                  style: pw.TextStyle(
                      fontSize: 14, color: scoreColor(r.aiProbability)),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            l10n.pdfSentenceCounts(
                r.sentences.length, r.aiSentenceCount, r.humanSentenceCount),
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),

          // 分析解讀（與 App 內報告同一套 composer 生成）
          pw.Text(l10n.composerNarrativeTitle,
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(_composer.compose(r, l10n).headline,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          for (final c in _composer.compose(r, l10n).components)
            if ((c.body ?? '').isNotEmpty &&
                c.type.name != 'thresholdBanner')
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text(
                  c.title != null ? '${c.title}：${c.body}' : c.body!,
                  style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
                ),
              ),
          pw.SizedBox(height: 14),

          // 引擎明細
          pw.Text(l10n.reportEngineBreakdownTitle,
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          for (final e in r.engineScores)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    e.available
                        ? '${e.engineName} — ${(e.aiProbability * 100).round()}%'
                        : '${e.engineName} — ${l10n.reportEngineNotInstalled}',
                    style: pw.TextStyle(
                        fontSize: 11, fontWeight: pw.FontWeight.bold),
                  ),
                  for (final reason in e.reasons)
                    pw.Bullet(
                        text: reason,
                        style: const pw.TextStyle(fontSize: 9),
                        bulletSize: 1.5),
                ],
              ),
            ),
          pw.SizedBox(height: 10),

          // 逐句分析（超過上限僅顯示前段，避免大量/超長句子撐爆 PDF 分頁）
          pw.Text(l10n.reportSentenceAnalysisTitle,
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          if (r.sentences.length > _pdfMaxTableRows)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(
                l10n.pdfTruncationNotice(_pdfMaxTableRows, r.sentences.length,
                    l10n.reportExportCsv, l10n.reportExportJson),
                style: const pw.TextStyle(
                    fontSize: 9, color: PdfColors.grey700),
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
              for (final s in r.sentences.take(_pdfMaxTableRows))
                pw.TableRow(children: [
                  _cell('${s.index + 1}'),
                  _cell(_truncateForPdf(s.patterns.isEmpty
                      ? s.text
                      : '${s.text}\n→ ${s.patterns.join('、')}')),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(4),
                    child: pw.Text(
                      '${(s.aiProbability * 100).round()}',
                      style: pw.TextStyle(
                          fontSize: 9, color: scoreColor(s.aiProbability)),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ]),
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

  // ---- 存檔（UI 層呼叫）----

  static String _timestamp(DateTime t) =>
      '${t.year}${t.month.toString().padLeft(2, '0')}${t.day.toString().padLeft(2, '0')}'
      '_${t.hour.toString().padLeft(2, '0')}${t.minute.toString().padLeft(2, '0')}';

  /// 回傳儲存路徑；使用者取消時回傳 null。
  /// 加 UTF-8 BOM 讓 Excel 正確辨識中文編碼。
  static Future<String?> exportCsv(DetectionResult r, AppLocalizations l10n) async {
    final bytes = Uint8List.fromList(
        [0xEF, 0xBB, 0xBF, ...utf8.encode(buildCsv(r, l10n))]);
    return _save(
      bytes: bytes,
      fileName: 'truthlens_${_timestamp(r.analyzedAt)}.csv',
      extension: 'csv',
      l10n: l10n,
    );
  }

  static Future<String?> exportJson(DetectionResult r, AppLocalizations l10n) async {
    final bytes = Uint8List.fromList(
        [0xEF, 0xBB, 0xBF, ...utf8.encode(buildJson(r, l10n))]);
    return _save(
      bytes: bytes,
      fileName: 'truthlens_${_timestamp(r.analyzedAt)}.json',
      extension: 'json',
      l10n: l10n,
    );
  }

  static Future<String?> exportPng(DetectionResult r, AppLocalizations l10n) async {
    final bytes = await SummaryCard.renderPng(r, l10n);
    return _save(
      bytes: bytes,
      fileName: 'truthlens_${_timestamp(r.analyzedAt)}.png',
      extension: 'png',
      l10n: l10n,
    );
  }

  static Future<String?> exportPdf(DetectionResult r, AppLocalizations l10n) async {
    final bytes = await buildPdf(
      r,
      l10n,
      regularFont: await rootBundle.load('assets/fonts/NotoSansTC-Regular.ttf'),
      boldFont: await rootBundle.load('assets/fonts/NotoSansTC-Bold.ttf'),
    );
    return _save(
      bytes: bytes,
      fileName: 'truthlens_${_timestamp(r.analyzedAt)}.pdf',
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
