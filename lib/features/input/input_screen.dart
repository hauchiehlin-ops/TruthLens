import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_catalog_service.dart';
import '../../core/detection/model_manager.dart';
import '../../core/services/document_importer.dart';
import '../../core/services/ocr_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/utils/app_version.dart';
import '../../core/utils/ocr_post_processor.dart';
import '../../l10n/generated/app_localizations.dart';
import '../onboarding/model_prompt.dart';
import '../settings/settings_screen.dart' show ModelManagerScreen;

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

  void _showFloatingSnackBar(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
        margin: const EdgeInsets.only(bottom: 84, left: 16, right: 16),
      ),
    );
  }

  Future<void> _startAnalysis() async {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (text.length < 40) {
      _showFloatingSnackBar(l10n.inputTooShortSnackbar);
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
      _showFloatingSnackBar(l10n.inputOcrUnsupported);
      return;
    }
    final path = await ImagePicker.pick();
    if (path == null || !mounted) return;

    _showFloatingSnackBar(l10n.inputOcrRecognizing);
    final rawText = await ocr.recognize(path);
    if (!mounted) return;
    if (rawText == null || rawText.trim().isEmpty) {
      _showFloatingSnackBar(l10n.inputOcrNoText);
      return;
    }
    final text = OcrPostProcessor.clean(rawText);
    _controller.text = text;
    setState(() {});
    _showFloatingSnackBar(l10n.inputOcrRecognized(text.length));
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
      _showFloatingSnackBar(l10n.inputImportNoText(doc.fileName));
      return;
    }
    _controller.text = doc.text;
    setState(() {});
    _showFloatingSnackBar(l10n.inputImportSuccess(doc.fileName, doc.text.length));
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('TruthLens'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                AppVersion.displayVersion,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: scheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
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
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _SettingsPanel(),
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

class _SettingsPanel extends StatefulWidget {
  const _SettingsPanel();

  @override
  State<_SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<_SettingsPanel> {
  late TextEditingController _apiKeyController;
  late TextEditingController _serverUrlController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _serverUrlController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kIsWeb) {
      try {
        _apiKeyController.text = OcrService.getGeminiApiKey() ?? '';
        _serverUrlController.text = OcrService.getLocalServerUrl() ?? '';
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  void _saveOcrSettings() {
    if (!kIsWeb) return;
    try {
      OcrService.setGeminiApiKey(_apiKeyController.text);
      OcrService.setLocalServerUrl(_serverUrlController.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('設定保存失敗：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesService>();
    final modelManager = context.watch<ModelManager>();
    final scheme = Theme.of(context).colorScheme;

    // 響應式寬度：平板 320px，桌機最多 420px
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth < 600 ? 320.0 : (screenWidth < 900 ? 380.0 : 420.0);

    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primary),
            child: Text(
              l10n.settingsAppBarTitle,
              style: TextStyle(
                color: scheme.onPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            title: Text(l10n.settingsThresholdTitle),
            subtitle: Text(
              l10n.settingsThresholdSubtitle(
                (prefs.confidenceThreshold * 100).round(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: prefs.confidenceThreshold,
              min: 0.4,
              max: 0.9,
              divisions: 10,
              label: '${(prefs.confidenceThreshold * 100).round()}%',
              onChanged: (v) => prefs.setThreshold(v),
            ),
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.settingsEslTitle),
            subtitle: Text(l10n.settingsEslSubtitle),
            value: prefs.eslCorrectionEnabled,
            onChanged: (v) => prefs.setEslCorrection(v),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              l10n.settingsEngineSectionTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          SwitchListTile(
            title: Text(l10n.settingsEngineTransformerTitle),
            subtitle: Text(l10n.settingsEngineTransformerSubtitle),
            value: prefs.isEngineEnabled('transformer'),
            onChanged: (v) => prefs.setEngineEnabled('transformer', v),
          ),
          SwitchListTile(
            title: Text(l10n.settingsEngineStatisticalTitle),
            subtitle: Text(l10n.settingsEngineStatisticalSubtitle),
            value: prefs.isEngineEnabled('statistical'),
            onChanged: (v) => prefs.setEngineEnabled('statistical', v),
          ),
          SwitchListTile(
            title: Text(l10n.settingsEngineStylometryTitle),
            subtitle: Text(l10n.settingsEngineStylometrySubtitle),
            value: prefs.isEngineEnabled('stylometry'),
            onChanged: (v) => prefs.setEngineEnabled('stylometry', v),
          ),
          SwitchListTile(
            title: Text(l10n.settingsEngineAdversarialTitle),
            subtitle: Text(l10n.settingsEngineAdversarialSubtitle),
            value: prefs.isEngineEnabled('adversarial'),
            onChanged: (v) => prefs.setEngineEnabled('adversarial', v),
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.settingsLinkVerificationTitle),
            subtitle: Text(l10n.settingsLinkVerificationSubtitle),
            value: prefs.linkVerificationEnabled,
            onChanged: (v) => prefs.setLinkVerificationEnabled(v),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.settingsThemeTitle),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
              ],
              selected: {prefs.themeMode},
              onSelectionChanged: (s) => prefs.setThemeMode(s.first),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(l10n.settingsLanguageTitle),
            subtitle: Text(l10n.settingsLanguageSubtitle),
            trailing: DropdownButton<Locale?>(
              value: prefs.locale,
              items: [
                for (final option in kSupportedLanguageOptions)
                  DropdownMenuItem(value: option.$1, child: Text(option.$2)),
              ],
              onChanged: (value) => prefs.setLocale(value),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Badge(
              isLabelVisible: modelManager.hasAnyUpdate,
              child: const Icon(Icons.download_outlined),
            ),
            title: Text(l10n.settingsModelManagementTitle),
            subtitle: Text(
              modelManager.hasAnyUpdate
                  ? l10n.settingsModelManagementUpdateSubtitle
                  : l10n.settingsModelManagementSubtitle,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ModelManagerScreen(),
                ),
              );
            },
          ),
          const Divider(),
          if (kIsWeb) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Web OCR 設定',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔑 Gemini API 金鑰',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'sk-proj-...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      suffixIcon: _apiKeyController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _apiKeyController.clear();
                                _saveOcrSettings();
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => _saveOcrSettings(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '🖥️ 本地 OCR 伺服器',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _serverUrlController,
                    decoration: InputDecoration(
                      hintText: 'http://127.0.0.1:5001/ocr',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      suffixIcon: _serverUrlController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _serverUrlController.clear();
                                _saveOcrSettings();
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => _saveOcrSettings(),
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('TruthLens'),
            subtitle: Text(
              '版本 ${AppVersion.displayVersion} (Build ${AppVersion.buildNumber}) · 100% 離線隱私檢測引擎',
            ),
          ),
        ],
        ),
      ),
    );
  }
}

