import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/models/detection_result.dart';

/// 整體判定儀表：環形進度 + 五級分類標籤
class ScoreGauge extends StatelessWidget {
  final double aiProbability;
  final Verdict verdict;
  const ScoreGauge({
    super.key,
    required this.aiProbability,
    required this.verdict,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.verdictColor(aiProbability);
    return Semantics(
      container: true,
      label: '整體判定：${verdict.labelZh}，AI 機率 ${(aiProbability * 100).round()} %',
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              width: 160,
              height: 160,
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: aiProbability,
                    strokeWidth: 12,
                    color: color,
                    backgroundColor: color.withValues(alpha: 0.15),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(aiProbability * 100).round()}%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                  color: color, fontWeight: FontWeight.bold),
                        ),
                        Text('AI 機率',
                            style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(verdict.labelZh),
              backgroundColor: color.withValues(alpha: 0.18),
              side: BorderSide(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
