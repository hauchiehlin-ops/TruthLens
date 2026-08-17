import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/services/calibration_service.dart';
import '../../l10n/generated/app_localizations.dart';

/// 本地基準校準卡：以共形預測把原始分數換成「有偽陽性率保證」的陳述。
///
/// 與 AI 機率的差別在於**參照對象**：AI 機率是相對於訓練資料裡的普世分布，
/// 這裡是相對於使用者自己蒐集的族群基準，因此能吸收非母語寫作等系統性偏移。
class CalibrationCard extends StatelessWidget {
  final ConformalResult result;

  /// 加入為已知人類樣本（共形預測的虛無分布）
  final VoidCallback? onAddHuman;

  /// 加入為已知 AI 樣本（僅供權重學習，不進虛無分布）
  final VoidCallback? onAddAi;

  /// 目前兩類樣本數，供顯示
  final int humanCount;
  final int aiCount;

  /// 由編輯紀錄自動納入的份數
  final int autoAdmittedCount;

  /// 僅供參考、未進入虛無分布的份數
  final int observedCount;

  /// 本文在所有已分析文件中的描述性百分位（無統計保證）
  final int? observedPercentile;

  /// 背景自動蒐集是否啟用
  final bool autoCollectEnabled;

  const CalibrationCard({
    super.key,
    required this.result,
    this.onAddHuman,
    this.onAddAi,
    this.humanCount = 0,
    this.aiCount = 0,
    this.autoAdmittedCount = 0,
    this.observedCount = 0,
    this.observedPercentile,
    this.autoCollectEnabled = false,
  });

  /// p 值顯示：小數點後三位，並避免顯示成 0.000 造成「絕對確定」的錯覺
  static String formatPValue(double p) =>
      p < 0.001 ? '<0.001' : p.toStringAsFixed(3);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final alphaPercent = (result.alpha * 100).round();

    final empty = result.calibrationSize == 0;
    final usable = result.hasEnoughSamples;

    final accent = !usable
        ? Colors.grey.shade600
        : result.isFlagged
        ? const Color(0xFFC0392B)
        : const Color(0xFF1E8449);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.scale, size: 20, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.calibrationTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (empty)
            Text(
              l10n.calibrationEmpty,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
            )
          else if (!usable)
            Text(
              l10n.calibrationNotEnough(
                result.calibrationSize,
                CalibrationService.requiredSamplesFor(result.alpha),
                alphaPercent,
              ),
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  result.isFlagged
                      ? LucideIcons.alertTriangle
                      : LucideIcons.checkCircle,
                  size: 16,
                  color: accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    result.isFlagged
                        ? l10n.calibrationFlagged(alphaPercent)
                        : l10n.calibrationNotFlagged(alphaPercent),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: accent,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (!empty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.calibrationPValue(
                formatPValue(result.pValue),
                result.calibrationSize,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            Text(
              l10n.calibrationPercentile(result.percentile),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],

          if (autoCollectEnabled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.refreshCw,
                        size: 14,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.calibrationAutoTitle,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.calibrationAutoStatus(autoAdmittedCount, observedCount),
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
                  ),
                  if (observedPercentile != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.calibrationObservedPercentile(
                        observedPercentile!,
                        humanCount + aiCount + observedCount,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    l10n.calibrationAutoWhy,
                    style: theme.textTheme.labelSmall?.copyWith(
                      height: 1.5,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (onAddHuman != null || onAddAi != null) ...[
            const SizedBox(height: 10),
            Text(
              l10n.calibrationCounts(humanCount, aiCount),
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (onAddHuman != null)
                  OutlinedButton.icon(
                    onPressed: onAddHuman,
                    icon: Icon(LucideIcons.userCheck, size: 16),
                    label: Text(l10n.calibrationAddHuman),
                  ),
                if (onAddAi != null)
                  OutlinedButton.icon(
                    onPressed: onAddAi,
                    icon: Icon(LucideIcons.bot, size: 16),
                    label: Text(l10n.calibrationAddAi),
                  ),
              ],
            ),
          ],

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.calibrationCaveat,
              style: theme.textTheme.labelSmall?.copyWith(
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
