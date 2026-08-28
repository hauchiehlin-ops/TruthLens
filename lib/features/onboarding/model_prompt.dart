import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';

/// 使用者對再次提示的回應
enum ModelPromptResult { download, skip, dismissed }

const modernChineseDetectorId = 'aigc-detector-zhv3-int8';

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
              icon: Icon(LucideIcons.x),
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
            onPressed: () => Navigator.of(context).pop(ModelPromptResult.skip),
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

/// 首次啟動的一次性提示：先讓使用者看到主畫面，再問要不要去挑模型。
///
/// 與 [showModelDownloadPrompt] 的差別在時機與語氣——這裡是「歡迎，順帶一提」，
/// 不是「你正要分析但缺模型」，因此不提供「不再提醒」（本來就只出現一次），
/// 也明講沒有模型仍然可用。
Future<ModelPromptResult> showFirstRunModelPrompt(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<ModelPromptResult>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(l10n.firstRunModelPromptTitle)),
          IconButton(
            icon: Icon(LucideIcons.x),
            tooltip: l10n.commonClose,
            onPressed: () =>
                Navigator.of(context).pop(ModelPromptResult.dismissed),
          ),
        ],
      ),
      content: Text(l10n.firstRunModelPromptBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ModelPromptResult.skip),
          child: Text(l10n.firstRunModelPromptLater),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(ModelPromptResult.download),
          child: Text(l10n.firstRunModelPromptGo),
        ),
      ],
    ),
  );
  return result ?? ModelPromptResult.dismissed;
}

/// 中文文件需要與英文不同的現代生成文校準。缺少專用變體時先明確告知，
/// 讓使用者選擇補齊模型或以較弱的跨語言備援繼續，避免靜默產生中性結果。
Future<ModelPromptResult> showModernChineseModelPrompt(
  BuildContext context,
) async {
  final l10n = AppLocalizations.of(context);
  final result = await showDialog<ModelPromptResult>(
    context: context,
    barrierDismissible: true,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(l10n.modernChineseModelPromptTitle)),
          IconButton(
            icon: Icon(LucideIcons.x),
            tooltip: l10n.commonClose,
            onPressed: () =>
                Navigator.of(context).pop(ModelPromptResult.dismissed),
          ),
        ],
      ),
      content: Text(l10n.modernChineseModelPromptBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ModelPromptResult.skip),
          child: Text(l10n.modelPromptSkip),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(ModelPromptResult.download),
          child: Text(l10n.modelPromptDownload),
        ),
      ],
    ),
  );
  return result ?? ModelPromptResult.dismissed;
}
