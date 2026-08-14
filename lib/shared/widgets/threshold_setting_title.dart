import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

class ThresholdSettingTitle extends StatelessWidget {
  final TextStyle? style;

  const ThresholdSettingTitle({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(l10n.settingsThresholdTitle, style: style)),
        const SizedBox(width: 2),
        IconButton(
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          padding: EdgeInsets.zero,
          iconSize: 18,
          tooltip: l10n.settingsThresholdInfoTooltip,
          onPressed: () => showDialog<void>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(l10n.settingsThresholdTitle),
              content: Text(l10n.settingsThresholdInfoBody),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.commonClose),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.info_outline),
        ),
      ],
    );
  }
}
