import 'package:flutter/material.dart';

import '../../core/models/detection_result.dart';
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
        .where((e) => e.value.aiProbability > 0.5) // 只保留可疑句子
        .map((e) => _SuspiciousSentenceItem(
              index: e.key,
              sentence: e.value.text,
              aiProbability: e.value.aiProbability,
              patterns: e.value.patterns,
            ))
        .toList();

    // 按 AI 概率排序（高到低）
    _items.sort((a, b) => b.aiProbability.compareTo(a.aiProbability));
  }

  List<_SuspiciousSentenceItem> _getFilteredItems() {
    return _items.where((item) {
      if (_filterLevel == 'high') return item.aiProbability >= 0.8;
      if (_filterLevel == 'medium') return 0.5 <= item.aiProbability < 0.8;
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
          child: Row(
            children: [
              _buildFilterButton('全部', 'all'),
              const SizedBox(width: 8),
              _buildFilterButton('高危', 'high'),
              const SizedBox(width: 8),
              _buildFilterButton('中等', 'medium'),
              const Spacer(),
              Text(
                '${filteredItems.length} 項',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),

        // 句子列表
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            return _SuspiciousSentenceCard(
              item: item,
              index: index + 1,
              totalCount: filteredItems.length,
            );
          },
        ),

        if (filteredItems.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                '無可疑內容',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isActive = _filterLevel == value;
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) {
        setState(() => _filterLevel = value);
      },
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF6B5B95).withValues(alpha: 0.2),
      side: BorderSide(
        color: isActive ? const Color(0xFF6B5B95) : Colors.grey[300]!,
      ),
      labelStyle: TextStyle(
        color: isActive ? const Color(0xFF6B5B95) : Colors.grey[600],
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
    // 假設每頁 ~300 字（可根據實際文檔配置調整）
    const charsPerPage = 300;
    return ((index * 15) ~/ charsPerPage + 1).toString();
  }

  String get riskLevel {
    if (aiProbability >= 0.8) return '高危';
    if (aiProbability >= 0.65) return '中等';
    return '低危';
  }

  Color get riskColor {
    if (aiProbability >= 0.8) return const Color(0xFFD4AF37); // 金 - 高危
    if (aiProbability >= 0.65) return const Color(0xFF6B5B95); // 紫 - 中等
    return const Color(0xFF1E3A5F); // 深青 - 低危
  }
}

/// 單個可疑句子卡片
class _SuspiciousSentenceCard extends StatelessWidget {
  final _SuspiciousSentenceItem item;
  final int index;
  final int totalCount;

  const _SuspiciousSentenceCard({
    required this.item,
    required this.index,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: item.riskColor.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: item.riskColor.withValues(alpha: 0.1),
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
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: item.riskColor.withValues(alpha: 0.08),
            ),
            child: Row(
              children: [
                // 序號圈
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.riskColor,
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: const TextStyle(
                        color: Colors.white,
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
                        '第 ${item.pageNumber} 頁',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: item.riskColor,
                            ),
                      ),
                      Text(
                        '句子 #${item.index + 1}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
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
                        color: item.riskColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.riskLevel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: item.riskColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(item.aiProbability * 100).round()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: item.riskColor,
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
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    item.sentence,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          height: 1.6,
                          color: const Color(0xFF1E3A5F),
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
                    '判定依據：',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
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
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          pattern,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[700],
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
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '📄 第 ${item.pageNumber} 頁',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  '${index}/$totalCount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[400],
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
