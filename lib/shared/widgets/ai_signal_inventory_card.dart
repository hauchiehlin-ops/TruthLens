import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../features/report/ai_signal_inventory.dart';
import '../../l10n/generated/app_localizations.dart';

/// 報告中的 AI 訊號清單：逐條列出本次擷取到的每一項 AI 訊號。
///
/// 每一條獨立成列並附編號，標明類別、強度、在判讀中的作用與出處。
/// 窄螢幕放不下五欄表格，因此改為每條一個區塊；PDF 匯出則用表格。
class AiSignalInventoryCard extends StatelessWidget {
  final List<AiSignalEntry> entries;

  const AiSignalInventoryCard({super.key, required this.entries});

  static Color strengthColor(AiSignalStrength s, ColorScheme scheme) =>
      switch (s) {
        AiSignalStrength.strong => scheme.error,
        AiSignalStrength.notable => const Color(0xFFB7791F),
        AiSignalStrength.info => scheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.listChecks, size: 20, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.aiSignalInventoryTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                l10n.aiSignalInventoryCount(entries.length),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.aiSignalInventorySubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            Text(l10n.aiSignalInventoryEmpty, style: theme.textTheme.bodyMedium)
          else
            for (var i = 0; i < entries.length; i++)
              _EntryTile(number: i + 1, entry: entries[i], l10n: l10n),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final int number;
  final AiSignalEntry entry;
  final AppLocalizations l10n;

  const _EntryTile({
    required this.number,
    required this.entry,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = AiSignalInventoryCard.strengthColor(entry.strength, scheme);
    final small = theme.textTheme.bodySmall?.copyWith(height: 1.4);

    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label  ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
        style: small?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '#$number',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _Chip(
                text: aiSignalCategoryLabel(entry.category, l10n),
                color: scheme.primary,
              ),
              _Chip(
                text: aiSignalStrengthLabel(entry.strength, l10n),
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            entry.statement,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 4),
          field(l10n.aiSignalColumnRole, aiSignalRoleLabel(entry.role, l10n)),
          field(l10n.aiSignalColumnLocation, entry.location),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;

  const _Chip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
