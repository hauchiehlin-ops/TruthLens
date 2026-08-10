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
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A5F), // 深青
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '分析時間：${DateTime.now().toString().split('.')[0]}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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

/// 判定摘要卡片（大）
class _VerdictSummaryCard extends StatelessWidget {
  final DetectionResult result;
  final AppLocalizations l10n;

  const _VerdictSummaryCard({
    required this.result,
    required this.l10n,
  });

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
              ? [const Color(0xFF6B5B95).withValues(alpha: 0.9), const Color(0xFF6B5B95)]
              : [const Color(0xFF1E3A5F).withValues(alpha: 0.9), const Color(0xFF1E3A5F)],
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
                  ? const Icon(Icons.smart_toy_outlined, size: 40, color: Colors.white)
                  : const Icon(Icons.edit_outlined, size: 40, color: Colors.white),
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
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
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
                      ? '信心度低：部分檢測模型未啟用或結果分散，建議人工審核'
                      : '信心度高：多個檢測模型一致同意此判定，結果可信度高',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result.isLowConfidence
                          ? '⚠️ 信心度低（需人工審核）'
                          : '✓ 信心度高（多引擎一致）',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                          ),
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

  const _MetricsRow({
    required this.result,
    required this.l10n,
  });

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
            value: '${((result.aiSentenceCount / result.sentences.length) * 100).toStringAsFixed(1)}%',
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
            value: '${(result.elapsed.inMilliseconds / 1000).toStringAsFixed(2)}s',
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
            ),
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

  const _EngineContributionCard({
    required this.result,
    required this.l10n,
  });

  /// 根據引擎 ID 返回顯示名稱
  static String _getEngineDisplayName(String engineId) {
    switch (engineId) {
      case 'transformer':
        return '🧠 Transformer 模型';
      case 'statistical':
        return '📊 統計分析';
      case 'stylometry':
        return '✒️ 風格分析';
      case 'adversarial':
        return '🛡️ 對抗防禦';
      default:
        return '⚙️ ${engineId.toUpperCase()}';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.layers_outlined, color: Color(0xFF6B5B95), size: 20),
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

          // 引擎列表
          if (result.engineScores.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '尚無引擎分析數據',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            )
          else
            for (final score in result.engineScores)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  // 可用狀態指示
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: score.available ? const Color(0xFF6B5B95) : Colors.grey[300],
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
                            Text(
                              score.engineName.isNotEmpty
                                  ? score.engineName
                                  : _getEngineDisplayName(score.engineId),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              score.available
                                  ? '${(score.aiProbability * 100).round()}%'
                                  : '未安裝',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: score.available
                                        ? const Color(0xFF1E3A5F)
                                        : Colors.grey[400],
                                    fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (score.available) ...[
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: score.aiProbability,
                              minHeight: 4,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                score.aiProbability > 0.7
                                    ? const Color(0xFF6B5B95)
                                    : const Color(0xFF1E3A5F),
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
