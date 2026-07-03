import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/preferences_service.dart';

/// 說明下載偵測模型必要性的共用文案。
const String kModelNecessityText =
    '未下載神經網路偵測模型時，TruthLens 仍可運作，但僅使用統計與風格分析，'
    '準確度與多語言支援有限。下載模型後，多語言 Transformer 分類器會加入集成投票，'
    '大幅提升判定準確度與可靠度。模型在裝置端執行，下載後完全離線、不上傳任何內容。';

/// 使用者對再次提示的回應
enum ModelPromptResult { download, skip, dismissed }

/// 顯示「建議下載模型」提示。可關閉（點背景或關閉鈕即 dismissed），
/// 並提供「不再提醒」選項（寫入偏好設定）。
Future<ModelPromptResult> showModelDownloadPrompt(BuildContext context) async {
  final prefs = context.read<PreferencesService>();
  var dontRemind = false;

  final result = await showDialog<ModelPromptResult>(
    context: context,
    barrierDismissible: true, // 點背景可關閉
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Row(
          children: [
            const Expanded(child: Text('建議下載偵測模型以獲得完整分析')),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: '關閉',
              onPressed: () =>
                  Navigator.of(context).pop(ModelPromptResult.dismissed),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(kModelNecessityText),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: dontRemind,
              onChanged: (v) => setState(() => dontRemind = v ?? false),
              title: const Text('不再提醒我'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(ModelPromptResult.skip),
            child: const Text('暫時略過'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(ModelPromptResult.download),
            child: const Text('前往下載'),
          ),
        ],
      ),
    ),
  );

  if (dontRemind) await prefs.setModelPromptSuppressed(true);
  return result ?? ModelPromptResult.dismissed;
}
