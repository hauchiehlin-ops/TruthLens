import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/models/detection_result.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/verdict_palette.dart';

/// 逐句發現的一列。
///
/// 每一列都要能回答「為什麼是這個數字」或「為什麼沒有數字」：
/// 只顯示破折號會讓使用者以為工具壞了。
class SentenceFindingRow {
  /// 原文中的句號（從 1 起算），排序後仍保留，方便回原文對照
  final int number;
  final String text;

  /// 要顯示的分數；沒有任何模型看過這一句時為 null
  final double? score;
  final SentenceFindingStatus status;

  const SentenceFindingRow({
    required this.number,
    required this.text,
    required this.score,
    required this.status,
  });

  bool get measured => score != null;

  /// 由分析結果建立：投票引擎的分數優先，其次是引擎未投票時的實測分數
  static List<SentenceFindingRow> fromResult(DetectionResult result) => [
    for (final s in result.sentences)
      SentenceFindingRow(
        number: s.index + 1,
        text: s.text,
        score: switch (s.status) {
          SentenceScoreStatus.voted => s.aiProbability,
          SentenceScoreStatus.measuredBelowEvidence => s.measuredProbability,
          _ => null,
        },
        status: switch (s.status) {
          SentenceScoreStatus.voted => SentenceFindingStatus.voted,
          SentenceScoreStatus.measuredBelowEvidence =>
            SentenceFindingStatus.belowEvidence,
          SentenceScoreStatus.screenedOut => SentenceFindingStatus.screenedOut,
          SentenceScoreStatus.notSentToModel => SentenceFindingStatus.notSent,
          SentenceScoreStatus.noNeuralModel => SentenceFindingStatus.noModel,
          SentenceScoreStatus.notAnalyzable =>
            SentenceFindingStatus.notAnalyzable,
        },
      ),
  ];
}

enum SentenceFindingStatus {
  /// 參與投票的模型分數
  voted,

  /// 模型實測分數，但引擎未達證據門檻、不計入判讀
  belowEvidence,

  /// 長文件快速篩檢沒有抽到
  screenedOut,

  /// 參考文獻、標題等不送模型
  notSent,

  /// 沒有適用此語言的神經模型
  noModel,

  /// 太短或不是完整句子
  notAnalyzable,

  /// 分析進行中，尚無分數
  pending,
}

enum _SortOrder { score, document }

/// 逐句發現清單：摘要、篩檢提示、排序與篩選，以及每列的分數或缺分原因。
class SentenceFindingsView extends StatefulWidget {
  final List<SentenceFindingRow> rows;

  /// 預設依分數排序（分析完成後找最可疑的句子）；分析中依原文順序
  final bool sortByScoreInitially;

  /// 以「不抽樣」重新分析。null 時不顯示按鈕（例如分析進行中）。
  final VoidCallback? onFullAnalysis;

  const SentenceFindingsView({
    super.key,
    required this.rows,
    this.sortByScoreInitially = true,
    this.onFullAnalysis,
  });

  @override
  State<SentenceFindingsView> createState() => _SentenceFindingsViewState();
}

class _SentenceFindingsViewState extends State<SentenceFindingsView> {
  late _SortOrder _order = widget.sortByScoreInitially
      ? _SortOrder.score
      : _SortOrder.document;
  bool _measuredOnly = false;
  final Set<int> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final rows = widget.rows;
    final measured = rows.where((r) => r.measured).length;
    final flagged = rows
        .where((r) => (r.score ?? 0) >= DetectionResult.aiFlagThreshold)
        .length;
    final screenedOut = rows
        .where((r) => r.status == SentenceFindingStatus.screenedOut)
        .length;

    final visible = [
      for (final row in rows)
        if (!_measuredOnly || row.measured) row,
    ];
    if (_order == _SortOrder.score) {
      // 有分數的在前、分數高者在前；沒有分數的保持原文順序
      visible.sort((a, b) {
        final sa = a.score, sb = b.score;
        if (sa == null && sb == null) return a.number.compareTo(b.number);
        if (sa == null) return 1;
        if (sb == null) return -1;
        final byScore = sb.compareTo(sa);
        return byScore != 0 ? byScore : a.number.compareTo(b.number);
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.workspaceFindingsSummary(
            measured,
            rows.length,
            flagged,
            (DetectionResult.aiFlagThreshold * 100).round(),
          ),
          key: const ValueKey('findings-summary'),
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (screenedOut > 0) ...[
          const SizedBox(height: 8),
          _ScreeningBanner(
            // 與上方摘要同一個數字：真的拿到模型分數的句子
            measured: measured,
            total: rows.length,
            onFullAnalysis: widget.onFullAnalysis,
          ),
        ],
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<_SortOrder>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: [
                ButtonSegment(
                  value: _SortOrder.score,
                  label: Text(l10n.workspaceFindingsSortScore),
                ),
                ButtonSegment(
                  value: _SortOrder.document,
                  label: Text(l10n.workspaceFindingsSortOrder),
                ),
              ],
              selected: {_order},
              onSelectionChanged: (s) => setState(() => _order = s.first),
            ),
            FilterChip(
              label: Text(l10n.workspaceFindingsMeasuredOnly),
              selected: _measuredOnly,
              visualDensity: VisualDensity.compact,
              onSelected: (v) => setState(() => _measuredOnly = v),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Expanded(
          child: visible.isEmpty
              ? Center(
                  child: Text(
                    l10n.workspaceNoEvidence,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                )
              : ListView.separated(
                  key: const ValueKey('workspace-live-findings-list'),
                  itemCount: visible.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: scheme.outlineVariant),
                  itemBuilder: (context, index) {
                    final row = visible[index];
                    final expanded = _expanded.contains(row.number);
                    return InkWell(
                      onTap: () => setState(() {
                        expanded
                            ? _expanded.remove(row.number)
                            : _expanded.add(row.number);
                      }),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _NumberBadge(number: row.number, score: row.score),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                row.text,
                                maxLines: expanded ? null : 3,
                                overflow: expanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.45,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _ScoreCell(row: row),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _ScreeningBanner extends StatelessWidget {
  final int measured;
  final int total;
  final VoidCallback? onFullAnalysis;

  const _ScreeningBanner({
    required this.measured,
    required this.total,
    required this.onFullAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                LucideIcons.filter,
                size: 16,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.workspaceFindingsScreenedBanner(measured, total),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSecondaryContainer,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          if (onFullAnalysis != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                key: const ValueKey('findings-full-analysis'),
                onPressed: onFullAnalysis,
                icon: const Icon(LucideIcons.scanLine, size: 16),
                label: Text(l10n.workspaceFindingsFullAnalysis),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  final double? score;

  const _NumberBadge({required this.number, required this.score});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = score == null
        ? scheme.onSurfaceVariant
        : verdictColor(Verdict.fromProbability(score!));
    return Container(
      constraints: const BoxConstraints(minWidth: 36),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$number',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 分數欄：有分數顯示百分比（未達證據門檻者以淡色並附說明），
/// 沒有分數則顯示原因標籤，滑過或點按可看完整說明。
class _ScoreCell extends StatelessWidget {
  final SentenceFindingRow row;

  const _ScoreCell({required this.row});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final score = row.score;

    if (score != null) {
      final voted = row.status == SentenceFindingStatus.voted;
      final text = Text(
        '${(score * 100).round()}%',
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: voted ? FontWeight.w700 : FontWeight.w500,
          color: voted
              ? verdictColor(Verdict.fromProbability(score))
              : scheme.onSurfaceVariant,
        ),
      );
      if (voted) return text;
      return Tooltip(
        message: l10n.sentenceScoreBelowEvidenceHint,
        triggerMode: TooltipTriggerMode.tap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            text,
            Text(
              l10n.sentenceScoreBelowEvidenceLabel,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final (label, hint) = switch (row.status) {
      SentenceFindingStatus.screenedOut => (
        l10n.sentenceStatusScreenedOut,
        l10n.sentenceStatusScreenedOutHint,
      ),
      SentenceFindingStatus.notSent => (
        l10n.sentenceStatusNotSent,
        l10n.sentenceStatusNotSentHint,
      ),
      SentenceFindingStatus.noModel => (
        l10n.sentenceStatusNoModel,
        l10n.sentenceStatusNoModelHint,
      ),
      SentenceFindingStatus.notAnalyzable => (
        l10n.sentenceStatusNotAnalyzable,
        l10n.sentenceStatusNotAnalyzableHint,
      ),
      SentenceFindingStatus.pending ||
      SentenceFindingStatus.voted ||
      SentenceFindingStatus.belowEvidence => ('…', l10n.workspaceAnalyzing),
    };
    return Tooltip(
      message: hint,
      triggerMode: TooltipTriggerMode.tap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
