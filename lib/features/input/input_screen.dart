import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_catalog_service.dart';
import '../../core/detection/model_manager.dart';
import '../../core/services/document_importer.dart';
import '../../core/services/ocr_service.dart';
import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../onboarding/model_prompt.dart';

/// 首頁：極簡輸入區 + 三個快捷入口（貼上 / 拍照 OCR / 匯入文件）
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

/// 語言切換下拉選單的選項清單：null 代表「跟隨系統語言」。
const List<(Locale?, String)> kSupportedLanguageOptions = [
  (null, 'System default'),
  (Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), '繁體中文'),
  (Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), '简体中文'),
  (Locale('en'), 'English'),
  (Locale('ja'), '日本語'),
  (Locale('ko'), '한국어'),
  (Locale('th'), 'ไทย'),
  (Locale('ms'), 'Bahasa Melayu'),
  (Locale('es'), 'Español'),
  (Locale('id'), 'Bahasa Indonesia'),
  (Locale('ru'), 'Русский'),
  (Locale('de'), 'Deutsch'),
  (Locale('fr'), 'Français'),
  (Locale('pt'), 'Português'),
];

class _InputScreenState extends State<InputScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 主動、靜默地檢查模型是否有更新；離線或失敗時不影響任何功能。
    context
        .read<ModelManager>()
        .checkForUpdates(context.read<ModelCatalogService>());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (text.length < 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.inputTooShortSnackbar)),
      );
      return;
    }

    // 需模型分析：核心偵測模型未安裝且使用者未關閉提醒時，再次說明必要性
    final prefs = context.read<PreferencesService>();
    final manager = context.read<ModelManager>();
    await manager.refreshInstallStates();
    if (!manager.isInstalled('transformer') && !prefs.modelPromptSuppressed) {
      if (!mounted) return;
      final choice = await showModelDownloadPrompt(context);
      if (!mounted) return;
      if (choice == ModelPromptResult.download) {
        context.push('/models'); // 前往下載，不繼續本次分析
        return;
      }
      // skip / dismissed → 以現有引擎（統計/風格）繼續分析
    }
    if (!mounted) return;
    context.push('/analysis', extra: text);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!;
      setState(() {});
    }
  }

  Future<void> _scanImage() async {
    final l10n = AppLocalizations.of(context);
    final ocr = context.read<OcrService>();
    if (!await ocr.isSupported) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.inputOcrUnsupported)),
      );
      return;
    }
    final path = await ImagePicker.pick();
    if (path == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.inputOcrRecognizing)),
    );
    final text = await ocr.recognize(path);
    if (!mounted) return;
    if (text == null || text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.inputOcrNoText)),
      );
      return;
    }
    _controller.text = text.trim();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.inputOcrRecognized(text.trim().length))),
    );
  }

  void _clearInput() {
    _controller.clear();
    setState(() {});
  }

  Future<void> _importDocument() async {
    final l10n = AppLocalizations.of(context);
    final doc = await DocumentImporter.pick();
    if (doc == null || !mounted) return;
    if (doc.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.inputImportNoText(doc.fileName))),
      );
      return;
    }
    _controller.text = doc.text;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(l10n.inputImportSuccess(doc.fileName, doc.text.length)),
      ),
    );
  }

  /// 顯示目前使用中的偵測模型，或提示未安裝（僅統計/風格分析）
  Widget _activeModelChip(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = context.watch<ModelManager>().activeVariant('transformer');
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(active != null ? Icons.memory : Icons.info_outline,
            size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          active != null
              ? l10n.inputActiveModel(active.variantId)
              : l10n.inputNoModel,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _languageMenu(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    return PopupMenuButton<Locale?>(
      icon: const Icon(Icons.translate),
      tooltip: 'Language',
      initialValue: prefs.locale,
      onSelected: (value) => context.read<PreferencesService>().setLocale(value),
      itemBuilder: (context) => [
        for (final option in kSupportedLanguageOptions)
          PopupMenuItem(
            value: option.$1,
            child: Text(option.$2),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TruthLens'),
        actions: [
          _languageMenu(context),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.inputHistoryTooltip,
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.inputHelpTooltip,
            onPressed: () => context.push('/help'),
          ),
          IconButton(
            icon: const Icon(Icons.privacy_tip_outlined),
            tooltip: l10n.inputPrivacyTooltip,
            onPressed: () => context.push('/privacy'),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: context.watch<ModelManager>().hasAnyUpdate,
              child: const Icon(Icons.settings_outlined),
            ),
            tooltip: l10n.inputSettingsTooltip,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.inputSubtitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: l10n.inputHint,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_controller.text.isNotEmpty)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: l10n.inputClearTooltip,
                            onPressed: _clearInput,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                MergeSemantics(
                  child: Row(
                    children: [
                      _activeModelChip(context),
                      const Spacer(),
                      Text(
                        l10n.inputCharCount(_controller.text.trim().length),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.content_paste),
                      label: Text(l10n.inputPasteButton),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _scanImage,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: Text(l10n.inputOcrButton),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _importDocument,
                      icon: const Icon(Icons.folder_open_outlined),
                      label: Text(l10n.inputImportButton),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _controller.text.trim().isEmpty
                      ? null
                      : _startAnalysis,
                  icon: const Icon(Icons.search),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(l10n.inputStartButton,
                        style: const TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
