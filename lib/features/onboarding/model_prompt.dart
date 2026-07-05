import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';

/// 使用者對再次提示的回應
enum ModelPromptResult { download, skip, dismissed }

/// 顯示「建議下載模型」提示。可關閉（點背景或關閉鈕即 dismissed），
/// 並提供「不再提醒」選項（寫入偏好設定）。
Future<ModelPromptResult> showModelDownloadPrompt(BuildContext context) async {
  final prefs = context.read<PreferencesService>();
  final l10n = AppLocalizations.of(context);
  var dontRemind = false;

  final result = await showDialog<ModelPromptResult>(
    context: context,
    barrierDismissible: true, // 點背景可關閉
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(l10n.modelPromptTitle)),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.commonClose,
              onPressed: () =>
                  Navigator.of(context).pop(ModelPromptResult.dismissed),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.modelNecessityText),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: dontRemind,
              onChanged: (v) => setState(() => dontRemind = v ?? false),
              title: Text(l10n.modelPromptDontRemind),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(ModelPromptResult.skip),
            child: Text(l10n.modelPromptSkip),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(ModelPromptResult.download),
            child: Text(l10n.modelPromptDownload),
          ),
        ],
      ),
    ),
  );

  if (dontRemind) await prefs.setModelPromptSuppressed(true);
  return result ?? ModelPromptResult.dismissed;
}
