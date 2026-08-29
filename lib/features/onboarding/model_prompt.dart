import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_catalog.dart';
import '../../core/detection/model_display_names.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'model_options_list.dart';

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

/// 首次啟動提示的結果：使用者的決定，加上他勾選的變體。
class FirstRunModelChoice {
  final ModelPromptResult result;

  /// 使用者勾選要下載的變體，依 (role, variant) 成對保存。
  /// 只有 [result] 為 download 時才有意義。
  final List<({String role, ModelVariant variant})> selected;

  const FirstRunModelChoice(this.result, {this.selected = const []});
}

/// 首次啟動的一次性提示：先讓使用者看到主畫面，再問要不要下載模型。
///
/// 與 [showModelDownloadPrompt] 的差別在時機與語氣——這裡是「歡迎，順帶一提」，
/// 不是「你正要分析但缺模型」，因此不提供「不再提醒」（本來就只出現一次），
/// 也明講沒有模型仍然可用。
///
/// 這裡直接列出待下載清單並預先勾選，而不是把人丟到模型管理頁自己找：首次啟動的
/// 使用者還不知道哪些 role 是必要的、哪一顆變體適合自己的硬體。預設勾選的依據是
/// [ModelProvisioner.recommendBundle]，它已經按「每 MB 換到多少判讀能力」排序，
/// 並把報告用 LLM 標為 skipOptional——那顆 1.6 GB 且完全不影響判讀結論，因此
/// 預設不勾，但仍然列出讓使用者自己決定。
Future<FirstRunModelChoice> showFirstRunModelPrompt(BuildContext context) async {
  final result = await showDialog<FirstRunModelChoice>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const _FirstRunModelDialog(),
  );
  return result ?? const FirstRunModelChoice(ModelPromptResult.dismissed);
}

class _FirstRunModelDialog extends StatefulWidget {
  const _FirstRunModelDialog();

  @override
  State<_FirstRunModelDialog> createState() => _FirstRunModelDialogState();
}

class _FirstRunModelDialogState extends State<_FirstRunModelDialog> {
  RecommendedBundle? _bundle;
  bool _loading = true;

  /// 勾選狀態以變體 id 為鍵。
  final _checked = <String, bool>{};

  bool _loadStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 這裡而不是 initState：_load 要讀 Localizations.localeOf 才知道該補哪個
    // 語言的專用變體，而 inherited widget 在 initState 完成前不可依賴。
    if (_loadStarted) return;
    _loadStarted = true;
    _load();
  }

  Future<void> _load() async {
    final provisioner = context.read<ModelProvisioner>();
    final languageCode = Localizations.localeOf(context).languageCode;
    final device = await DeviceCapabilities.detect();
    final bundle = await provisioner.recommendBundle(
      device,
      languageCode: languageCode,
    );
    if (!mounted) return;
    setState(() {
      _bundle = bundle;
      for (final e in bundle.entries) {
        // 預設勾選＝建議套組的判斷。RAM 不足的不能勾（勾了也載不起來），
        // 選用的 LLM 與空間可能不足的預設不勾，但使用者可以自己勾。
        _checked[e.variant.id] = e.included;
      }
      _loading = false;
    });
  }

  bool _selectable(BundleEntry e) =>
      e.variant.isDownloadable && e.decision != BundleDecision.skipRam;

  List<({String role, ModelVariant variant})> get _selection => [
    for (final e in _bundle?.entries ?? const <BundleEntry>[])
      if (_checked[e.variant.id] == true && _selectable(e))
        (role: e.role, variant: e.variant),
  ];

  int get _selectedBytes =>
      _selection.fold(0, (sum, s) => sum + s.variant.sizeBytes);

  String? _reasonFor(BundleEntry e, AppLocalizations l10n) => switch (e.decision) {
    BundleDecision.include => null,
    BundleDecision.skipOptional => l10n.firstRunModelOptionalReason,
    BundleDecision.skipStorage => l10n.firstRunModelStorageReason,
    BundleDecision.skipRam => l10n.firstRunModelRamReason(
      (e.variant.minRamMb / 1024).toStringAsFixed(1),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = _bundle?.entries ?? const <BundleEntry>[];

    return AlertDialog(
      title: Row(
        children: [
          Expanded(child: Text(l10n.firstRunModelPromptTitle)),
          IconButton(
            icon: Icon(LucideIcons.x),
            tooltip: l10n.commonClose,
            onPressed: () => Navigator.of(
              context,
            ).pop(const FirstRunModelChoice(ModelPromptResult.dismissed)),
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.firstRunModelPromptBody),
                    const SizedBox(height: 12),
                    Text(
                      l10n.firstRunModelListTitle,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    for (final e in entries)
                      _entryTile(e, l10n),
                    const Divider(),
                    Text(
                      l10n.firstRunModelSelectionSummary(
                        _selection.length,
                        ModelOptionsList.sizeLabel(_selectedBytes),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(const FirstRunModelChoice(ModelPromptResult.skip)),
          child: Text(l10n.firstRunModelCancel),
        ),
        FilledButton(
          // 一顆都沒勾就等同取消，讓按鈕維持可按只會產生沒有動作的「確認」。
          onPressed: _selection.isEmpty
              ? null
              : () => Navigator.of(context).pop(
                  FirstRunModelChoice(
                    ModelPromptResult.download,
                    selected: _selection,
                  ),
                ),
          child: Text(l10n.firstRunModelConfirm),
        ),
      ],
    );
  }

  Widget _entryTile(BundleEntry e, AppLocalizations l10n) {
    final selectable = _selectable(e);
    final reason = _reasonFor(e, l10n);
    final subtitleParts = [
      '${ModelOptionsList.roleLabel(e.role, e.roleName, l10n)} · '
          '${ModelOptionsList.sizeLabel(e.variant.sizeBytes)}',
      if (!e.variant.isDownloadable) l10n.modelListComingSoonChip,
      ?reason,
    ];

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      value: selectable && (_checked[e.variant.id] ?? false),
      onChanged: selectable
          ? (v) => setState(() => _checked[e.variant.id] = v ?? false)
          : null,
      title: Text(localizedModelName(e.variant.id, e.variant.name, l10n)),
      subtitle: Text(subtitleParts.join('\n')),
      isThreeLine: subtitleParts.length > 1,
    );
  }
}

/// 使用者選擇不下載時，說明之後要去哪裡自己下載。
///
/// 只講「可以稍後下載」而不說路徑，等於要使用者自己在設定裡翻找。
Future<void> showManualModelDownloadHint(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.firstRunModelManualTitle),
      content: Text(l10n.firstRunModelManualBody),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonGotIt),
        ),
      ],
    ),
  );
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
