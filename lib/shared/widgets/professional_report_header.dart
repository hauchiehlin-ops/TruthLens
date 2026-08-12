import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/models/detection_result.dart';
import '../../l10n/generated/app_localizations.dart';

/// 專業級報告頁頭：判定摘要 + 詳細指標
class ProfessionalReportHeader extends StatelessWidget {
  final DetectionResult result;
  final VoidCallback onDownloadPdf;

  const ProfessionalReportHeader({
    super.key,
    required this.result,
    required this.onDownloadPdf,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. 頂部工具欄
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI 內容檢測報告',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A5F), // 深青
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '分析時間：${DateTime.now().toString().split('.')[0]}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                // 下載按鈕（簡約樣式）
                FilledButton.icon(
                  onPressed: onDownloadPdf,
                  icon: const Icon(Icons.file_download_outlined),
                  label: const Text('下載 PDF'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5B95), // 紫
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 2),

          // 2. 判定摘要卡片（大卡）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _VerdictSummaryCard(result: result, l10n: l10n),
          ),

          // 3. 三列指標卡
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _MetricsRow(result: result, l10n: l10n),
          ),

          // 4. 引擎貢獻度卡
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _EngineContributionCard(result: result, l10n: l10n),
          ),

          const Divider(thickness: 1, height: 24),

          // 5. 可疑句子清單標題
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Color(0xFFD4AF37), // 金
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '可疑內容位置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
                const Spacer(),
                Text(
                  '共 ${result.aiSentenceCount} 句',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 判定摘要卡片（大）
class _VerdictSummaryCard extends StatelessWidget {
  final DetectionResult result;
  final AppLocalizations l10n;

  const _VerdictSummaryCard({required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final isAI = result.aiProbability > 0.5;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isAI
              ? [
                  const Color(0xFF6B5B95).withValues(alpha: 0.9),
                  const Color(0xFF6B5B95),
                ]
              : [
                  const Color(0xFF1E3A5F).withValues(alpha: 0.9),
                  const Color(0xFF1E3A5F),
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: (isAI ? const Color(0xFF6B5B95) : const Color(0xFF1E3A5F))
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 左側圖示（實體化圖標）
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Center(
              child: isAI
                  ? const Icon(
                      Icons.smart_toy_outlined,
                      size: 40,
                      color: Colors.white,
                    )
                  : const Icon(
                      Icons.edit_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
            ),
          ),
          const SizedBox(width: 20),

          // 右側文字
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.verdict.label(l10n),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'AI 概率：',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                      TextSpan(
                        text: '${(result.aiProbability * 100).round()}%',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Tooltip(
                  message: result.isLowConfidence
                      ? '信心度低：可用模型權重不足 60%（${(result.threshold * 100).round()}% 閾值）。${result.availableEngineCount}/${result.totalEngineCount} 引擎參與投票。建議參考各引擎詳細分析結果。'
                      : '信心度高：${result.availableEngineCount}/${result.totalEngineCount} 個檢測模型達成共識（${((result.threshold) * 100).round()}% 以上權重同意此判定）',
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result.isLowConfidence
                          ? '⚠️ 信心度低（${result.availableEngineCount}/${result.totalEngineCount}）'
                          : '✓ 信心度高（${result.availableEngineCount}/${result.totalEngineCount}）',
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 三列指標卡
class _MetricsRow extends StatelessWidget {
  final DetectionResult result;
  final AppLocalizations l10n;

  const _MetricsRow({required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 卡 1：AI 判定比例
        Expanded(
          child: _MetricCard(
            icon: Icons.assessment_outlined,
            iconColor: const Color(0xFF6B5B95),
            title: 'AI 句子比例',
            value:
                '${((result.aiSentenceCount / result.sentences.length) * 100).toStringAsFixed(1)}%',
            subtitle: '${result.aiSentenceCount}/${result.sentences.length} 句',
          ),
        ),
        const SizedBox(width: 12),

        // 卡 2：分析耗時
        Expanded(
          child: _MetricCard(
            icon: Icons.schedule_outlined,
            iconColor: const Color(0xFF1E3A5F),
            title: '分析耗時',
            value:
                '${(result.elapsed.inMilliseconds / 1000).toStringAsFixed(2)}s',
            subtitle: '0.5-5s 正常',
          ),
        ),
        const SizedBox(width: 12),

        // 卡 3：可信度
        Expanded(
          child: _MetricCard(
            icon: Icons.verified_user_outlined,
            iconColor: const Color(0xFFD4AF37),
            title: '可信度',
            value: result.isLowConfidence ? '低' : '高',
            subtitle: result.isLowConfidence ? '需人工驗證' : '高度可信',
          ),
        ),
      ],
    );
  }
}

/// 單個指標卡
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

/// 引擎貢獻度卡
class _EngineContributionCard extends StatelessWidget {
  final DetectionResult result;
  final AppLocalizations l10n;

  const _EngineContributionCard({required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final engineGroups = _EngineGroup.fromScores(result.engineScores);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.layers_outlined,
                color: Color(0xFF6B5B95),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '引擎分析層級',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 雷達圖：顯示各引擎 AI 概率
          if (engineGroups.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _EngineRadarChart(engineGroups: engineGroups),
            ),
            _EngineSynthesisSummary(
              groups: engineGroups,
              overallProbability: result.aiProbability,
              verdictLabel: result.verdict.label(l10n),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 引擎詳細列表
          Text(
            '詳細分析',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),

          // 引擎列表
          if (engineGroups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '尚無引擎分析數據',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
            )
          else
            for (final group in engineGroups)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 可用狀態指示
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: group.available
                            ? const Color(0xFF6B5B95)
                            : Colors.grey[300],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 引擎名 + 評分
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  group.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                group.available
                                    ? '${(group.probability * 100).round()}%'
                                    : '未參與',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: group.available
                                          ? const Color(0xFF1E3A5F)
                                          : Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: group.available ? group.probability : 0,
                              minHeight: 4,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                !group.available
                                    ? Colors.grey[300]!
                                    : group.probability > 0.7
                                    ? const Color(0xFF6B5B95)
                                    : const Color(0xFF1E3A5F),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            group.relationshipText,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey[600],
                                  height: 1.25,
                                ),
                          ),
                          if (group.reasons.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            for (final reason in group.reasons.take(2))
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  reason,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                        height: 1.25,
                                      ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

/// 引擎 AI 概率雷達圖
class _EngineRadarChart extends StatelessWidget {
  final List<_EngineGroup> engineGroups;

  const _EngineRadarChart({required this.engineGroups});

  @override
  Widget build(BuildContext context) {
    if (engineGroups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '無引擎數據',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
        ),
      );
    }

    final displayGroups = engineGroups.take(5).toList();
    final chartSize = math
        .min(MediaQuery.sizeOf(context).width - 96, 280.0)
        .clamp(220.0, 280.0);

    return Center(
      child: SizedBox(
        width: chartSize,
        height: chartSize,
        child: CustomPaint(painter: _ReportRadarPainter(groups: displayGroups)),
      ),
    );
  }
}

class _ReportRadarPainter extends CustomPainter {
  final List<_EngineGroup> groups;

  const _ReportRadarPainter({required this.groups});

  @override
  void paint(Canvas canvas, Size size) {
    if (groups.length < 3) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 42;
    const axisColor = Color(0xFFE3E1EA);
    const valueColor = Color(0xFF6B5B95);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = axisColor;
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = axisColor.withValues(alpha: 0.75);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = valueColor.withValues(alpha: 0.20);
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = valueColor;
    final disabledDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFBDBDBD);
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = valueColor;

    for (var ring = 1; ring <= 4; ring++) {
      final ringPath = Path();
      for (var i = 0; i < groups.length; i++) {
        final p = _point(center, radius * ring / 4, i, groups.length);
        if (i == 0) {
          ringPath.moveTo(p.dx, p.dy);
        } else {
          ringPath.lineTo(p.dx, p.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    for (var i = 0; i < groups.length; i++) {
      canvas.drawLine(
        center,
        _point(center, radius, i, groups.length),
        axisPaint,
      );
    }

    final valuePath = Path();
    for (var i = 0; i < groups.length; i++) {
      final value = groups[i].available
          ? groups[i].probability.clamp(0.0, 1.0)
          : 0.0;
      final p = _point(center, radius * value, i, groups.length);
      if (i == 0) {
        valuePath.moveTo(p.dx, p.dy);
      } else {
        valuePath.lineTo(p.dx, p.dy);
      }
    }
    valuePath.close();
    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, outlinePaint);

    for (var i = 0; i < groups.length; i++) {
      final value = groups[i].available
          ? groups[i].probability.clamp(0.0, 1.0)
          : 0.0;
      final p = _point(center, radius * value, i, groups.length);
      canvas.drawCircle(
        p,
        4,
        groups[i].available ? dotPaint : disabledDotPaint,
      );
    }

    for (var i = 0; i < groups.length; i++) {
      final p = _point(center, radius + 24, i, groups.length);
      final painter = TextPainter(
        text: TextSpan(
          text: groups[i].axisLabel,
          style: const TextStyle(
            color: Color(0xFF55515D),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 78);
      painter.paint(
        canvas,
        Offset(p.dx - painter.width / 2, p.dy - painter.height / 2),
      );
    }
  }

  Offset _point(Offset center, double radius, int index, int total) {
    final angle = (index / total) * 2 * math.pi - math.pi / 2;
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  @override
  bool shouldRepaint(covariant _ReportRadarPainter oldDelegate) {
    return oldDelegate.groups != groups;
  }
}

class _EngineSynthesisSummary extends StatelessWidget {
  final List<_EngineGroup> groups;
  final double overallProbability;
  final String verdictLabel;

  const _EngineSynthesisSummary({
    required this.groups,
    required this.overallProbability,
    required this.verdictLabel,
  });

  @override
  Widget build(BuildContext context) {
    final available = groups.where((g) => g.available).toList();
    final strongestSignal = available.isEmpty
        ? null
        : available.reduce((a, b) => a.probability >= b.probability ? a : b);
    final strongestContribution = available.isEmpty
        ? null
        : available.reduce((a, b) => a.contribution >= b.contribution ? a : b);
    _EngineGroup? style;
    for (final group in groups) {
      if (group.role == 'stylometry') {
        style = group;
        break;
      }
    }
    final hasModelGap = groups.any((g) => !g.available);

    final lines = <String>[
      '綜合判定：$verdictLabel，整體 AI 機率 ${(overallProbability * 100).round()}%。',
    ];
    if (strongestSignal != null) {
      lines.add(
        '最高單項訊號是 ${strongestSignal.label}（${(strongestSignal.probability * 100).round()}%），但最終結果會依各引擎權重合併，不等於單一引擎結論。',
      );
    }
    if (strongestContribution != null) {
      lines.add(
        '目前最大加權貢獻來自 ${strongestContribution.label}（約 ${(strongestContribution.contribution * 100).round()} 個百分點）。',
      );
    }
    if (style != null &&
        style.probability < 0.45 &&
        overallProbability >= 0.45) {
      lines.add(
        '「未偵測到明顯 AI 寫作風格」只代表風格引擎沒有抓到固定句式或過渡詞模式；其他模型仍可能因語言規律、句級分類或改寫特徵把整體分數拉高。',
      );
    }
    if (hasModelGap) {
      lines.add(
        'Transformer 是端上神經網路文字分類器，負責句級 AI 機率與多語言語意特徵；若未參與，請到模型管理使用「補齊推薦分析模型」。',
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E1EA)),
      ),
      child: Text(
        lines.join('\n'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF3F3A4A),
          height: 1.35,
        ),
      ),
    );
  }
}

class _EngineGroup {
  final String role;
  final String label;
  final String axisLabel;
  final double probability;
  final double weight;
  final double contribution;
  final bool available;
  final int variantCount;
  final List<String> reasons;

  const _EngineGroup({
    required this.role,
    required this.label,
    required this.axisLabel,
    required this.probability,
    required this.weight,
    required this.contribution,
    required this.available,
    required this.variantCount,
    required this.reasons,
  });

  String get relationshipText {
    final weightText = '${(weight * 100).round()}%';
    if (!available) {
      return '$label 未參與本次加權投票，該面向暫以 0% 顯示。';
    }
    final contributionText = '${(contribution * 100).round()} 個百分點';
    final variantText = variantCount > 1 ? '（已合併 $variantCount 個模型變體）' : '';
    return '角色權重 $weightText，對整體分數貢獻約 $contributionText$variantText。';
  }

  static List<_EngineGroup> fromScores(List<EngineScore> scores) {
    const order = ['transformer', 'statistical', 'stylometry', 'adversarial'];
    final grouped = <String, List<EngineScore>>{
      for (final role in order) role: <EngineScore>[],
    };
    for (final score in scores) {
      grouped[_roleOf(score.engineId)]?.add(score);
    }

    final availableWeight = order.fold<double>(
      0,
      (sum, role) =>
          sum +
          (grouped[role]!.any((s) => s.available) ? _roleWeight(role) : 0),
    );

    return [
      for (final role in order)
        _fromRole(role, grouped[role]!, availableWeight: availableWeight),
    ];
  }

  static _EngineGroup _fromRole(
    String role,
    List<EngineScore> scores, {
    required double availableWeight,
  }) {
    final availableScores = scores.where((s) => s.available).toList();
    final available = availableScores.isNotEmpty;
    final probability = available
        ? availableScores.fold<double>(0, (sum, s) => sum + s.aiProbability) /
              availableScores.length
        : 0.0;
    final weight = _roleWeight(role);
    final contribution = available && availableWeight > 0
        ? probability * weight / availableWeight
        : 0.0;
    final reasons = [
      for (final score in scores)
        ...score.reasons.where((reason) => reason.trim().isNotEmpty),
    ];

    return _EngineGroup(
      role: role,
      label: _roleLabel(role),
      axisLabel: _axisLabel(role),
      probability: probability,
      weight: weight,
      contribution: contribution,
      available: available,
      variantCount: math.max(scores.length, 1),
      reasons: reasons.isEmpty ? [_fallbackReason(role, available)] : reasons,
    );
  }

  static String _roleOf(String engineId) {
    if (engineId.startsWith('transformer')) return 'transformer';
    if (engineId.startsWith('statistical')) return 'statistical';
    if (engineId.startsWith('stylometry')) return 'stylometry';
    if (engineId.startsWith('adversarial')) return 'adversarial';
    return engineId;
  }

  static double _roleWeight(String role) => switch (role) {
    'transformer' => 0.40,
    'statistical' => 0.25,
    'stylometry' => 0.20,
    'adversarial' => 0.15,
    _ => 0.0,
  };

  static String _roleLabel(String role) => switch (role) {
    'transformer' => 'Transformer 分類器',
    'statistical' => '統計特徵分析',
    'stylometry' => '風格特徵分析',
    'adversarial' => '對抗式防禦',
    _ => role,
  };

  static String _axisLabel(String role) => switch (role) {
    'transformer' => '句級分類',
    'statistical' => '語言規律',
    'stylometry' => '寫作風格',
    'adversarial' => '改寫防禦',
    _ => role,
  };

  static String _fallbackReason(String role, bool available) {
    if (!available) return '${_roleLabel(role)}未參與本次投票。';
    return '${_roleLabel(role)}未回傳額外文字說明。';
  }
}
