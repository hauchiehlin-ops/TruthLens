import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// 首頁與分析報告底部共用的版權宣告列；置中、可換行，符合小螢幕響應式版面。
class AppCopyrightFooter extends StatelessWidget {
  const AppCopyrightFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        l10n.commonCopyrightNotice(DateTime.now().year),
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}
