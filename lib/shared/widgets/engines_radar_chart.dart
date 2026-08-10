import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/models/detection_result.dart';
import '../../l10n/generated/app_localizations.dart';

/// 雷達圖：展示各引擎的 AI 概率分數
/// 用五邊形雷達圖展現四個引擎（Transformer/Statistical/Stylometry/Adversarial）
class EnginesRadarChart extends StatelessWidget {
  final List<EngineScore> engineScores;
  final double overallProbability;
  final Verdict verdict;

  const EnginesRadarChart({
    super.key,
    required this.engineScores,
    required this.overallProbability,
    required this.verdict,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final size = 280.0;
    final center = Offset(size / 2, size / 2);
    final radius = size / 2 - 30;

    // 確保最多 5 個引擎
    final displayScores = engineScores.take(5).toList();
    final axisCount = displayScores.length;

    return Column(
      children: [
        // 雷達圖區域
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: scheme.surfaceContainerLow,
          ),
          padding: const EdgeInsets.all(16),
          child: CustomPaint(
            size: Size(size, size),
            painter: _RadarChartPainter(
              scores: displayScores,
              axisCount: axisCount,
              radius: radius,
              center: center,
              colorScheme: scheme,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // 圖例
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: displayScores.map((score) {
            final isAvailable = score.available;
            final color = isAvailable
                ? _engineColor(score.engineId, scheme)
                : scheme.outlineVariant;
            return Semantics(
              label:
                  '${score.engineName}：${(score.aiProbability * 100).round()}%${!isAvailable ? '（未安裝）' : ''}',
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    score.engineName,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${(score.aiProbability * 100).round()}%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  if (!isAvailable)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.info_outline,
                        size: 12,
                        color: scheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // 整體判定
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _verdictColor(overallProbability, scheme),
          ),
          child: Column(
            children: [
              Text(
                verdict.label(l10n),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(overallProbability * 100).round()}% AI',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _engineColor(String engineId, ColorScheme scheme) {
    switch (engineId) {
      case 'transformer':
        return Colors.blue;
      case 'statistical':
        return Colors.orange;
      case 'stylometry':
        return Colors.purple;
      case 'adversarial':
        return Colors.red;
      default:
        return scheme.primary;
    }
  }

  Color _verdictColor(double probability, ColorScheme scheme) {
    if (probability < 0.2) return Colors.green.withValues(alpha: 0.12);
    if (probability < 0.4) return Colors.lime.withValues(alpha: 0.12);
    if (probability < 0.6) return Colors.yellow.withValues(alpha: 0.12);
    if (probability < 0.8) return Colors.orange.withValues(alpha: 0.12);
    return Colors.red.withValues(alpha: 0.12);
  }
}

class _RadarChartPainter extends CustomPainter {
  final List<EngineScore> scores;
  final int axisCount;
  final double radius;
  final Offset center;
  final ColorScheme colorScheme;

  _RadarChartPainter({
    required this.scores,
    required this.axisCount,
    required this.radius,
    required this.center,
    required this.colorScheme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..color = colorScheme.outlineVariant.withValues(alpha: 0.3);

    final axisPaint = Paint()
      ..strokeWidth = 0.5
      ..color = colorScheme.outline.withValues(alpha: 0.2);

    // 繪製網格（同心圓）
    for (int i = 1; i <= 5; i++) {
      final r = radius * (i / 5);
      canvas.drawCircle(center, r, paint);
    }

    // 繪製軸線
    for (int i = 0; i < axisCount; i++) {
      final angle = (i / axisCount) * 2 * math.pi - math.pi / 2;
      final dx = math.cos(angle) * radius;
      final dy = math.sin(angle) * radius;
      canvas.drawLine(center, Offset(center.dx + dx, center.dy + dy), axisPaint);
    }

    // 繪製雷達數據多邊形
    final pathPaint = Paint()
      ..strokeWidth = 2
      ..color = colorScheme.primary;

    final fillPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.15);

    final path = Path();
    for (int i = 0; i < scores.length; i++) {
      final angle = (i / axisCount) * 2 * math.pi - math.pi / 2;
      final score =
          scores[i].available ? scores[i].aiProbability : 0.0; // 未安裝引擎設為 0
      final r = radius * score;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, pathPaint);

    // 繪製數據點
    final dotPaint = Paint()
      ..color = colorScheme.primary
      ..strokeWidth = 2;

    for (int i = 0; i < scores.length; i++) {
      final angle = (i / axisCount) * 2 * math.pi - math.pi / 2;
      final score =
          scores[i].available ? scores[i].aiProbability : 0.0;
      final r = radius * score;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }

    // 繪製軸標籤
    final textPaint = TextPainter(
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < scores.length; i++) {
      final angle = (i / axisCount) * 2 * math.pi - math.pi / 2;
      final labelRadius = radius + 20;
      final x = center.dx + math.cos(angle) * labelRadius;
      final y = center.dy + math.sin(angle) * labelRadius;

      textPaint.text = TextSpan(
        text: scores[i].engineId.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      textPaint.layout();
      textPaint.paint(
        canvas,
        Offset(x - textPaint.width / 2, y - textPaint.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(_RadarChartPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.radius != radius;
  }
}
