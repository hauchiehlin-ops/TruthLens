import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/models/detection_result.dart';
import '../../l10n/generated/app_localizations.dart';

/// 以 Canvas 繪製社群分享用的摘要卡並輸出 PNG（plan 第九節）。
/// 純繪製、不需 widget 樹，因此可單元測試。
class SummaryCard {
  static const double _w = 640;
  static const double _h = 360;

  static Color _verdictColor(double p) {
    if (p < 0.2) return const Color(0xFF4CAF50);
    if (p < 0.4) return const Color(0xFFCDDC39);
    if (p < 0.6) return const Color(0xFFFF9800);
    if (p < 0.8) return const Color(0xFFFF5722);
    return const Color(0xFFF44336);
  }

  static Future<Uint8List> renderPng(
    DetectionResult r,
    AppLocalizations l10n, {
    double scale = 2,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(scale);

    final color = _verdictColor(r.aiProbability);
    final pct = (r.aiProbability * 100).round();

    // 背景
    final bgRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, _w, _h), const Radius.circular(28));
    canvas.drawRRect(bgRect, Paint()..color = const Color(0xFF15171C));
    canvas.drawRRect(
        bgRect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: 0.6));

    _text(canvas, 'TruthLens', const Offset(36, 30), 22, Colors.white,
        weight: FontWeight.bold);
    _text(canvas, l10n.reportSourceTemplate, const Offset(36, 62), 14,
        Colors.white70);

    // 圓環（AI 機率）
    const center = Offset(150, 210);
    const radius = 78.0;
    final ringBg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..color = color.withValues(alpha: 0.18);
    canvas.drawCircle(center, radius, ringBg);
    final ringFg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -1.5708,
        6.2832 * r.aiProbability, false, ringFg);
    _textCentered(canvas, '$pct%', center.translate(0, -22), 40, color,
        weight: FontWeight.bold, width: radius * 2);
    _textCentered(canvas, l10n.reportAiProbabilityLabel, center.translate(0, 24), 14,
        Colors.white70, width: radius * 2);

    // 右側判定與統計
    _pill(canvas, const Offset(280, 150), r.verdict.label(l10n), color);
    _text(
        canvas,
        l10n.summaryCardStats(
            r.sentences.length, r.aiSentenceCount, r.humanSentenceCount),
        const Offset(284, 210),
        16,
        Colors.white,
        height: 1.6);

    _text(canvas, l10n.summaryCardFooter, const Offset(36, 320), 12,
        Colors.white54);

    final picture = recorder.endRecording();
    final img =
        await picture.toImage((_w * scale).round(), (_h * scale).round());
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    img.dispose();
    return bytes!.buffer.asUint8List();
  }

  static void _pill(Canvas c, Offset o, String text, Color color) {
    final para = _para(text, 16, Colors.white, weight: FontWeight.bold);
    final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(o.dx, o.dy, para.maxIntrinsicWidth + 28, 34),
        const Radius.circular(17));
    c.drawRRect(rect, Paint()..color = color.withValues(alpha: 0.22));
    c.drawRRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color);
    c.drawParagraph(para, Offset(o.dx + 14, o.dy + 7));
  }

  static ui.Paragraph _para(String s, double size, Color color,
      {FontWeight weight = FontWeight.normal,
      double height = 1.2,
      double width = 400}) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontSize: size, fontWeight: weight, height: height))
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(s);
    return pb.build()..layout(ui.ParagraphConstraints(width: width));
  }

  static void _text(Canvas c, String s, Offset o, double size, Color color,
      {FontWeight weight = FontWeight.normal, double height = 1.2}) {
    c.drawParagraph(_para(s, size, color, weight: weight, height: height), o);
  }

  static void _textCentered(Canvas c, String s, Offset center, double size,
      Color color,
      {FontWeight weight = FontWeight.normal, double width = 200}) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
        fontSize: size, fontWeight: weight, textAlign: TextAlign.center))
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(s);
    final p = pb.build()..layout(ui.ParagraphConstraints(width: width));
    c.drawParagraph(p, Offset(center.dx - width / 2, center.dy));
  }
}
