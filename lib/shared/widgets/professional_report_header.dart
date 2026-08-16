import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/models/detection_result.dart';
import '../../core/services/calibration_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'calibration_card.dart';
import 'provenance_card.dart';


/// 把棄權原因轉成該語系的白話說明
String describeAbstention(DetectionResult result, AppLocalizations l10n) {
  return switch (result.abstention) {
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
    AbstentionReason.enginesConflict => l10n.abstentionEnginesConflict(result.engineSpreadPoints),
  };
}

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.sourceFileName.isEmpty
                            ? l10n.reportAiContentReportTitle
                            : '${l10n.reportAiContentReportTitle}：${result.sourceFileName}',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A5F), // 深青
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.reportAnalysisTimeLabel(
                          DateTime.now().toString().split('.')[0],
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // 下載按鈕（簡約樣式）
                FilledButton.icon(
                  onPressed: onDownloadPdf,
                  icon: Icon(LucideIcons.download),
                  label: Text(l10n.reportDownloadPdfButton),
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

          // 4. 本地基準校準卡（共形預測：把分數換成有偽陽性率保證的陳述）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Consumer<CalibrationService>(
              builder: (context, calibration, _) => CalibrationCard(
                result: calibration.evaluate(result.aiProbability),
                onAddToBaseline: () async {
                  await calibration.addSample(result.aiProbability);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.calibrationAdded(calibration.size)),
                    ),
                  );
                },
              ),
            ),
          ),

          // 5. 文件來源證據卡（與 AI 機率分開的另一類證據；沒有可用紀錄時
          //    仍顯示，明確告訴使用者「這份無從由來源判斷」而非默默略過）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ProvenanceCard(provenance: result.provenance),
          ),

          // 6. 引擎貢獻度卡
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _EngineContributionCard(result: result, l10n: l10n),
          ),

          const Divider(thickness: 1, height: 24),

          // 7. 可疑句子清單標題
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(
                  LucideIcons.alertTriangle,
                  color: Color(0xFFD4AF37), // 金
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.reportSuspiciousLocationsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A5F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.reportSentenceCount(result.aiSentenceCount),
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
                  ? Icon(LucideIcons.fileText, size: 40, color: Colors.white)
                  : Icon(LucideIcons.pencil, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),

          // 右側文字
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.shouldAbstain
                      ? l10n.abstentionHeadline
                      : result.verdict.label(l10n),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (result.shouldAbstain) ...[
                  const SizedBox(height: 8),
                  Text(
                    describeAbstention(result, l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.abstentionScoreStillShown,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                // AI index ＝ AI 機率 ÷ 標記門檻閾值。同時列出兩個運算元與
                // 結果，讓「離門檻多遠」可以直接讀出來，而非自行心算。
                Text(
                  l10n.reportAiIndexFormula(
                    (result.aiProbability * 100).round(),
                    (result.threshold * 100).round(),
                    result.aiIndexPercent,
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!result.shouldAbstain) ...[
                  const SizedBox(height: 12),
                  _VerdictTierList(result: result, l10n: l10n),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 五個判定等級清單，標示各等級對應的 AI 機率區間，目前等級以高亮呈現。
/// 使用 [Wrap] 讓區塊在窄螢幕自動換行，符合響應式設計。
class _VerdictTierList extends StatelessWidget {
  final DetectionResult result;
  final AppLocalizations l10n;

  const _VerdictTierList({required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    // 切點同樣換算成 AI index，與上方公式的單位一致
    final cutPercents = Verdict.cutPointIndexPercents(result.threshold);

    final ranges = <Verdict, String>{
      Verdict.human: l10n.reportVerdictRangeBelow(cutPercents[0]),
      Verdict.likelyHuman: l10n.reportVerdictRangeBetween(
        cutPercents[0],
        cutPercents[1],
      ),
      Verdict.mixed: l10n.reportVerdictRangeBetween(
        cutPercents[1],
        cutPercents[2],
      ),
      Verdict.likelyAi: l10n.reportVerdictRangeBetween(
        cutPercents[2],
        cutPercents[3],
      ),
      Verdict.ai: l10n.reportVerdictRangeAbove(cutPercents[3]),
    };

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Verdict.values.map((verdict) {
        final active = verdict == result.verdict;
        return Container(
          constraints: const BoxConstraints(minWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: active ? 0.25 : 0.08),
            borderRadius: BorderRadius.circular(8),
            border: active
                ? Border.all(color: Colors.white.withValues(alpha: 0.6))
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                verdict.label(l10n),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ranges[verdict]!,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withValues(alpha: active ? 0.95 : 0.7),
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
    final analyzableSentenceCount = result.analyzableSentenceCount;
    final aiSentenceRatio = analyzableSentenceCount == 0
        ? 0.0
        : result.aiSentenceCount / analyzableSentenceCount;
    return Row(
      children: [
        // 卡 1：AI 判定比例
        Expanded(
          child: _MetricCard(
            icon: LucideIcons.barChart,
            iconColor: const Color(0xFF6B5B95),
            title: l10n.reportMetricAiSentenceRatio,
            value: '${(aiSentenceRatio * 100).toStringAsFixed(1)}%',
            subtitle: l10n.reportStrongAiSentenceCount(
              result.aiSentenceCount,
              analyzableSentenceCount,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 卡 2：分析耗時
        Expanded(
          child: _MetricCard(
            icon: LucideIcons.clock,
            iconColor: const Color(0xFF1E3A5F),
            title: l10n.reportMetricElapsed,
            value:
                '${(result.elapsed.inMilliseconds / 1000).toStringAsFixed(2)}s',
            subtitle: l10n.reportMetricElapsedNormal,
          ),
        ),
        const SizedBox(width: 12),

        // 卡 3：可信度
        Expanded(
          child: _MetricCard(
            icon: LucideIcons.shieldCheck,
            iconColor: const Color(0xFFD4AF37),
            title: l10n.reportMetricReliability,
            value: result.isLowConfidence
                ? l10n.reportReliabilityLow
                : l10n.reportReliabilityHigh,
            subtitle: result.isLowConfidence
                ? l10n.reportReliabilityNeedsReview
                : l10n.reportReliabilityHighTrust,
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
    final engineGroups = EngineGroup.fromScores(
      result.engineScores,
      l10n,
      eslAdjusted: result.eslAdjusted,
      contributionPointsByEngineId: result.roundedEngineContributionPoints,
    );

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
              Icon(LucideIcons.layers, color: Color(0xFF6B5B95), size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.reportEngineAnalysisLevelTitle,
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
            _RadarWithVerdict(
              engineGroups: engineGroups,
              result: result,
              l10n: l10n,
            ),
            _EngineSynthesisSummary(
              groups: engineGroups,
              overallProbability: result.aiProbability,
              verdictLabel: result.verdict.label(l10n),
              l10n: l10n,
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 引擎詳細列表
          Text(
            l10n.reportDetailAnalysisTitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.reportEngineSignalExplanation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),

          // 引擎列表
          if (engineGroups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.reportNoEngineData,
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.axisLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1E3A5F),
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      group.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                group.available
                                    ? l10n.reportEngineSignalLabel(
                                        (group.probability * 100).round(),
                                      )
                                    : l10n.reportEngineNotParticipated,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: group.available
                                          ? const Color(0xFF1E3A5F)
                                          : Colors.grey[600],
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

class _RadarWithVerdict extends StatelessWidget {
  final List<EngineGroup> engineGroups;
  final DetectionResult result;
  final AppLocalizations l10n;

  const _RadarWithVerdict({
    required this.engineGroups,
    required this.result,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _EngineRadarChart(engineGroups: engineGroups),
              ),
              const SizedBox(height: 8),
              _VerdictSignalBadge(result: result, l10n: l10n),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _EngineRadarChart(engineGroups: engineGroups),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _VerdictSignalBadge(result: result, l10n: l10n),
            ),
          ],
        );
      },
    );
  }
}

class _VerdictSignalBadge extends StatelessWidget {
  final DetectionResult result;
  final AppLocalizations l10n;

  const _VerdictSignalBadge({required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final meta = _meta(result.verdict);
    final probability = (result.aiProbability * 100).round();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: meta.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: meta.color.withValues(alpha: 0.16),
                ),
                child: Icon(meta.icon, color: meta.color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportVerdictBadgeTitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      result.verdict.label(l10n),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: meta.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.reportVerdictBadgeProbability(probability),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1E3A5F),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _verdictHint(result.verdict, l10n),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  static _VerdictMeta _meta(Verdict verdict) => switch (verdict) {
    Verdict.human => _VerdictMeta(
      icon: LucideIcons.shieldCheck,
      color: Color(0xFF2E7D32),
    ),
    Verdict.likelyHuman => _VerdictMeta(
      icon: LucideIcons.checkCircle,
      color: Color(0xFF558B2F),
    ),
    Verdict.mixed => _VerdictMeta(
      icon: LucideIcons.scale,
      color: Color(0xFF6B5B95),
    ),
    Verdict.likelyAi => _VerdictMeta(
      icon: LucideIcons.alertTriangle,
      color: Color(0xFFC47F17),
    ),
    Verdict.ai => _VerdictMeta(
      icon: LucideIcons.alertTriangle,
      color: Color(0xFFC62828),
    ),
  };

  static String _verdictHint(Verdict verdict, AppLocalizations l10n) =>
      switch (verdict) {
        Verdict.human => l10n.reportVerdictHintHuman,
        Verdict.likelyHuman => l10n.reportVerdictHintLikelyHuman,
        Verdict.mixed => l10n.reportVerdictHintMixed,
        Verdict.likelyAi => l10n.reportVerdictHintLikelyAi,
        Verdict.ai => l10n.reportVerdictHintAi,
      };
}

class _VerdictMeta {
  final IconData icon;
  final Color color;

  _VerdictMeta({required this.icon, required this.color});
}

/// 引擎 AI 概率雷達圖
class _EngineRadarChart extends StatelessWidget {
  final List<EngineGroup> engineGroups;

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
  final List<EngineGroup> groups;

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
  final List<EngineGroup> groups;
  final double overallProbability;
  final String verdictLabel;
  final AppLocalizations l10n;

  const _EngineSynthesisSummary({
    required this.groups,
    required this.overallProbability,
    required this.verdictLabel,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final available = groups.where((g) => g.available).toList();
    final strongestSignal = available.isEmpty
        ? null
        : available.reduce((a, b) => a.probability >= b.probability ? a : b);
    final strongestContribution = available.isEmpty
        ? null
        : available.reduce(
            (a, b) => a.contributionPoints >= b.contributionPoints ? a : b,
          );
    EngineGroup? style;
    for (final group in groups) {
      if (group.role == 'stylometry') {
        style = group;
        break;
      }
    }
    final hasModelGap = groups.any((g) => !g.available);

    final lines = <String>[
      l10n.reportSynthesisOverall(
        verdictLabel,
        (overallProbability * 100).round(),
      ),
    ];
    if (strongestSignal != null) {
      lines.add(
        l10n.reportSynthesisStrongestSignal(
          strongestSignal.label,
          (strongestSignal.probability * 100).round(),
        ),
      );
    }
    if (strongestContribution != null) {
      lines.add(
        l10n.reportSynthesisStrongestContribution(
          strongestContribution.label,
          strongestContribution.contributionPoints,
        ),
      );
    }
    if (style != null &&
        style.probability < 0.45 &&
        overallProbability >= 0.45) {
      lines.add(l10n.reportSynthesisStyleCaveat);
    }
    if (hasModelGap) {
      lines.add(l10n.reportSynthesisModelGap);
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

class EngineGroup {
  final String role;
  final String label;
  final String axisLabel;
  final double probability;
  final double weight;
  final double contribution;
  final int contributionPoints;
  final bool available;
  final int variantCount;
  final List<String> reasons;
  final AppLocalizations l10n;

  const EngineGroup({
    required this.role,
    required this.label,
    required this.axisLabel,
    required this.probability,
    required this.weight,
    required this.contribution,
    required this.contributionPoints,
    required this.available,
    required this.variantCount,
    required this.reasons,
    required this.l10n,
  });

  String get relationshipText {
    final weightPercent = (weight * 100).round();
    if (!available) {
      return l10n.reportEngineRelationshipUnavailable(
        label,
        _resolutionHint(role, l10n),
      );
    }
    final variantText = variantCount > 1
        ? l10n.reportEngineVariantMerged(variantCount)
        : '';
    return l10n.reportEngineRelationshipAvailable(
      weightPercent,
      contributionPoints,
      variantText,
    );
  }

  static List<EngineGroup> fromScores(
    List<EngineScore> scores,
    AppLocalizations l10n, {
    bool eslAdjusted = false,
    Map<String, int> contributionPointsByEngineId = const {},
  }) {
    const order = ['transformer', 'statistical', 'stylometry', 'adversarial'];
    final grouped = <String, List<EngineScore>>{
      for (final role in order) role: <EngineScore>[],
    };
    for (final score in scores) {
      grouped[_roleOf(score.engineId)]?.add(score);
    }

    double configuredWeight(String role) => grouped[role]!.isNotEmpty
        ? grouped[role]!.first.weight
        : _roleWeight(role);
    double effectiveWeight(String role) {
      final configured = configuredWeight(role);
      return eslAdjusted && role == 'statistical'
          ? configured * 0.5
          : configured;
    }

    final availableWeight = order.fold<double>(0, (sum, role) {
      if (!grouped[role]!.any((s) => s.available)) return sum;
      return sum + effectiveWeight(role);
    });

    return [
      for (final role in order)
        _fromRole(
          role,
          grouped[role]!,
          availableWeight: availableWeight,
          effectiveWeight: effectiveWeight(role),
          contributionPoints: grouped[role]!.fold<int>(
            0,
            (sum, score) =>
                sum + (contributionPointsByEngineId[score.engineId] ?? 0),
          ),
          l10n: l10n,
        ),
    ];
  }

  static EngineGroup _fromRole(
    String role,
    List<EngineScore> scores, {
    required double availableWeight,
    required double effectiveWeight,
    required int contributionPoints,
    required AppLocalizations l10n,
  }) {
    final availableScores = scores.where((s) => s.available).toList();
    final available = availableScores.isNotEmpty;
    final probability = available
        ? availableScores.fold<double>(0, (sum, s) => sum + s.aiProbability) /
              availableScores.length
        : 0.0;
    final weight = scores.isNotEmpty ? scores.first.weight : _roleWeight(role);
    final contribution = available && availableWeight > 0
        ? probability * effectiveWeight / availableWeight
        : 0.0;
    final reasons = <String>[
      for (final score in scores)
        ...score.reasons.where((reason) => reason.trim().isNotEmpty),
    ];
    final uniqueReasons = <String>[
      for (final reason in reasons.toSet()) _explainReason(role, reason, l10n),
    ];

    return EngineGroup(
      role: role,
      label: _roleLabel(role, l10n),
      axisLabel: _axisLabel(role, l10n),
      probability: probability,
      weight: weight,
      contribution: contribution,
      contributionPoints: contributionPoints,
      available: available,
      variantCount: math.max(scores.length, 1),
      reasons: uniqueReasons.isEmpty
          ? [_fallbackReason(role, available, l10n)]
          : uniqueReasons,
      l10n: l10n,
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

  static String _roleLabel(String role, AppLocalizations l10n) =>
      switch (role) {
        'transformer' => l10n.reportRadarRoleTransformer,
        'statistical' => l10n.reportRadarRoleStatistical,
        'stylometry' => l10n.reportRadarRoleStylometry,
        'adversarial' => l10n.reportRadarRoleAdversarial,
        _ => role,
      };

  static String _axisLabel(String role, AppLocalizations l10n) =>
      switch (role) {
        'transformer' => l10n.reportRadarAxisTransformer,
        'statistical' => l10n.reportRadarAxisStatistical,
        'stylometry' => l10n.reportRadarAxisStylometry,
        'adversarial' => l10n.reportRadarAxisAdversarial,
        _ => role,
      };

  static String _fallbackReason(
    String role,
    bool available,
    AppLocalizations l10n,
  ) {
    final label = _roleLabel(role, l10n);
    if (!available) return l10n.reportEngineFallbackUnavailable(label);
    return l10n.reportEngineFallbackAvailable(label);
  }

  static String _resolutionHint(String role, AppLocalizations l10n) =>
      switch (role) {
        'transformer' => l10n.reportEngineResolutionTransformer,
        'adversarial' => l10n.reportEngineResolutionAdversarial,
        _ => '',
      };

  static String _explainReason(
    String role,
    String reason,
    AppLocalizations l10n,
  ) {
    if (role == 'adversarial' &&
        reason.contains('Cannot convert a BigInt value to a number')) {
      return l10n.reportEngineReasonBigInt(reason);
    }
    if (role == 'transformer' && reason.contains('tokenizer')) {
      return l10n.reportEngineReasonTokenizer(reason);
    }
    if (role == 'transformer' && reason.contains('未找到使用中的')) {
      return l10n.reportEngineReasonNoActiveTransformer(reason);
    }
    return reason;
  }
}
