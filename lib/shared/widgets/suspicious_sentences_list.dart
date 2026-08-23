import 'package:flutter/material.dart';

import '../../core/models/detection_result.dart';
import '../../core/utils/text_stats.dart';
import '../../l10n/generated/app_localizations.dart';

/// 可疑句子清單：句子 + 頁數 + 評分
class SuspiciousSentencesList extends StatefulWidget {
  final List<SentenceScore> sentences;
  final AppLocalizations l10n;

  const SuspiciousSentencesList({
    super.key,
    required this.sentences,
    required this.l10n,
  });

  @override
  State<SuspiciousSentencesList> createState() =>
      _SuspiciousSentencesListState();
}

class _SuspiciousSentencesListState extends State<SuspiciousSentencesList> {
  late List<_SuspiciousSentenceItem> _items;
  String _filterLevel = 'all'; // all, high, medium

  @override
  void initState() {
    super.initState();
    _buildItems();
  }

  void _buildItems() {
    _items = widget.sentences
        .asMap()
        .entries
        .where(
          (e) =>
              e.value.aiProbability >= 0.6 &&
              PreprocessedText.isAnalyzableSentence(e.value.text),
        )
        .map(
          (e) => _SuspiciousSentenceItem(
            index: e.key,
            sentence: _truncateSentence(e.value.text),
            aiProbability: e.value.aiProbability,
            patterns: e.value.patterns,
          ),
        )
        .toList();

    // 按 AI 概率排序（高到低）
    _items.sort((a, b) => b.aiProbability.compareTo(a.aiProbability));
  }

  /// 截斷長句子：限制為 300 字元，超過則加 ...
  static String _truncateSentence(String text) {
    const maxLength = 300;
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  List<_SuspiciousSentenceItem> _getFilteredItems() {
    return _items.where((item) {
      if (_filterLevel == 'high') return item.aiProbability >= 0.8;
      if (_filterLevel == 'medium') {
        return item.aiProbability >= 0.5 && item.aiProbability < 0.8;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _getFilteredItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 篩選按鈕
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final filters = Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterButton(widget.l10n.suspiciousFilterAll, 'all'),
                  _buildFilterButton(widget.l10n.suspiciousFilterHigh, 'high'),
                  _buildFilterButton(
                    widget.l10n.suspiciousFilterMedium,
                    'medium',
                  ),
                ],
              );
              final count = Tooltip(
                message: widget.l10n.suspiciousExcludedTooltip,
                child: Text(
                  widget.l10n.suspiciousCount(filteredItems.length),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );

              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    filters,
                    const SizedBox(height: 8),
                    Align(alignment: Alignment.centerRight, child: count),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: filters),
                  const SizedBox(width: 12),
                  count,
                ],
              );
            },
          ),
        ),

        // 句子列表
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredItems.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return _SuspiciousSentenceCard(
              item: item,
              index: index + 1,
              totalCount: filteredItems.length,
              l10n: widget.l10n,
            );
          },
        ),

        if (filteredItems.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                widget.l10n.suspiciousEmpty,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isActive = _filterLevel == value;
    final scheme = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) {
        setState(() => _filterLevel = value);
      },
      backgroundColor: scheme.surfaceContainerHigh,
      selectedColor: scheme.secondaryContainer,
      side: BorderSide(
        color: isActive ? scheme.secondary : scheme.outlineVariant,
      ),
      labelStyle: TextStyle(
        color: isActive ? scheme.onSecondaryContainer : scheme.onSurfaceVariant,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

/// 可疑句子項目資料
class _SuspiciousSentenceItem {
  final int index;
  final String sentence;
  final double aiProbability;
  final List<String> patterns;

  _SuspiciousSentenceItem({
    required this.index,
    required this.sentence,
    required this.aiProbability,
    required this.patterns,
  });

  String get pageNumber {
    return '#${index + 1}';
  }

  String riskLevel(AppLocalizations l10n) {
    if (aiProbability >= 0.8) return l10n.suspiciousRiskHigh;
    return l10n.suspiciousRiskMedium;
  }

  Color riskColor(Brightness brightness) {
    if (aiProbability >= 0.8) {
      return brightness == Brightness.dark
          ? const Color(0xFFFFD166)
          : const Color(0xFF7A5700);
    }
    return brightness == Brightness.dark
        ? const Color(0xFFC4B5FD)
        : const Color(0xFF59418F);
  }

  String reasonSummary(AppLocalizations l10n) {
    final cleaned = patterns
        .map((p) => p.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (cleaned.isNotEmpty) {
      final first = cleaned.first;
      return first.length > 34 ? '${first.substring(0, 34)}...' : first;
    }
    if (aiProbability >= 0.8) return l10n.suspiciousReasonHighModelSignals;
    return l10n.suspiciousReasonSentenceSignal;
  }
}

/// 單個可疑句子卡片
class _SuspiciousSentenceCard extends StatelessWidget {
  final _SuspiciousSentenceItem item;
  final int index;
  final int totalCount;
  final AppLocalizations l10n;

  const _SuspiciousSentenceCard({
    required this.item,
    required this.index,
    required this.totalCount,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final riskColor = item.riskColor(Theme.of(context).brightness);
    final onRisk =
        ThemeData.estimateBrightnessForColor(riskColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: scheme.surfaceContainerLow,
        border: Border.all(color: riskColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 頭部：序號 + 頁數 + 風險級別
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
              color: riskColor.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                // 序號圈
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: riskColor,
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        color: onRisk,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // 頁數資訊
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.suspiciousOriginalLocationWithReason(
                          item.pageNumber,
                          item.reasonSummary(l10n),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: riskColor,
                        ),
                      ),
                      Text(
                        l10n.suspiciousSentenceNumber(item.index + 1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // 風險級別 + 信心度
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: riskColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.riskLevel(l10n),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(item.aiProbability * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 內文
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: Text(
                    item.sentence,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.6,
                      color: scheme.onSurface,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 判定特徵（如果有）
          if (item.patterns.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.suspiciousEvidenceLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: item.patterns.take(3).map((pattern) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Text(
                          pattern,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // 頁碼指示（底部）
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              border: Border(top: BorderSide(color: scheme.outlineVariant)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.suspiciousOriginalLocation(item.pageNumber),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$index/$totalCount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
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
