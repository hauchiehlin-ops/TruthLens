import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../features/report/report_composer.dart';
import '../models/detection_result.dart';

/// 報告匯出：CSV（逐句數據）、JSON（系統整合）與 PDF（完整報告）。
/// 產生邏輯（buildCsv / buildJson / buildPdf）與存檔對話框分離，前者可單元測試。
class ReportExporter {
  static final _composer = ReportComposer();

  /// 結構化 JSON（plan 第九節：LMS / 系統整合）。
  static String buildJson(DetectionResult r) {
    final doc = _composer.compose(r);
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
  static String buildCsv(DetectionResult r) {
    final buf = StringBuffer()
      ..writeln('# TruthLens 檢測報告')
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
    DetectionResult r, {
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
            'TruthLens · 第 ${ctx.pageNumber} / ${ctx.pagesCount} 頁',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
          ),
        ),
        build: (ctx) => [
          pw.Text('TruthLens 檢測報告',
              style:
                  pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(
            '分析時間：${r.analyzedAt.toLocal().toString().substring(0, 19)}'
            ' · 耗時 ${(r.elapsed.inMilliseconds / 1000).toStringAsFixed(1)} 秒',
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
                pw.Text('整體判定：${r.verdict.labelZh}',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(
                  'AI 機率 ${(r.aiProbability * 100).round()}%'
                  '${r.eslAdjusted ? '（已套用 ESL 修正）' : ''}',
                  style: pw.TextStyle(
                      fontSize: 14, color: scoreColor(r.aiProbability)),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            '共 ${r.sentences.length} 句 · 疑似 AI ${r.aiSentenceCount} 句 · '
            '人類 ${r.humanSentenceCount} 句',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),

          // 分析解讀（與 App 內報告同一套 composer 生成）
          pw.Text('分析解讀',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(_composer.compose(r).headline,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          for (final c in _composer.compose(r).components)
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
          pw.Text('引擎明細',
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
                        : '${e.engineName} — 未安裝',
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

          // 逐句分析
          pw.Text('逐句分析',
              style:
                  pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
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
                  _cell('句子（附命中模式）', bold: true),
                  _cell('AI%', bold: true),
                ],
              ),
              for (final s in r.sentences)
                pw.TableRow(children: [
                  _cell('${s.index + 1}'),
                  _cell(s.patterns.isEmpty
                      ? s.text
                      : '${s.text}\n→ ${s.patterns.join('、')}'),
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
  static Future<String?> exportCsv(DetectionResult r) async {
    final bytes =
        Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(buildCsv(r))]);
    return _save(
      bytes: bytes,
      fileName: 'truthlens_${_timestamp(r.analyzedAt)}.csv',
      extension: 'csv',
    );
  }

  static Future<String?> exportJson(DetectionResult r) async {
    final bytes =
        Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode(buildJson(r))]);
    return _save(
      bytes: bytes,
      fileName: 'truthlens_${_timestamp(r.analyzedAt)}.json',
      extension: 'json',
    );
  }

  static Future<String?> exportPdf(DetectionResult r) async {
    final bytes = await buildPdf(
      r,
      regularFont: await rootBundle.load('assets/fonts/NotoSansTC-Regular.ttf'),
      boldFont: await rootBundle.load('assets/fonts/NotoSansTC-Bold.ttf'),
    );
    return _save(
      bytes: bytes,
      fileName: 'truthlens_${_timestamp(r.analyzedAt)}.pdf',
      extension: 'pdf',
    );
  }

  static Future<String?> _save({
    required Uint8List bytes,
    required String fileName,
    required String extension,
  }) async {
    // file_picker 11：提供 bytes 時，行動/桌面平台皆由 picker 寫入檔案
    return FilePicker.saveFile(
      dialogTitle: '匯出報告',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: [extension],
      bytes: bytes,
    );
  }
}
