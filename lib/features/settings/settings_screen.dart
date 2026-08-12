import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/ocr_service.dart';
import '../../core/utils/app_version.dart';
import '../../l10n/generated/app_localizations.dart';
import '../input/input_screen.dart' show kSupportedLanguageOptions;
import '../onboarding/model_options_list.dart';
import 'model_import_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 設定頁：信心閾值、ESL 修正、主題、語言；模型管理（P2）與語言包（P4）後續加入
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesService>();
    final modelManager = context.watch<ModelManager>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAppBarTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: Text(l10n.settingsThresholdTitle),
            subtitle: Text(
              l10n.settingsThresholdSubtitle(
                (prefs.confidenceThreshold * 100).round(),
              ),
            ),
          ),
          Slider(
            value: prefs.confidenceThreshold,
            min: 0.4,
            max: 0.9,
            divisions: 10,
            label: '${(prefs.confidenceThreshold * 100).round()}%',
            onChanged: (v) => prefs.setThreshold(v),
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
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModelManagerScreen()),
              ),
              child: Text(l10n.settingsOpenButton),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: Text(l10n.settingsCustomImportTitle),
            subtitle: Text(l10n.settingsCustomImportSubtitle),
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModelImportScreen()),
              ),
              child: Text(l10n.settingsOpenButton),
            ),
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
            _WebOcrSettings(),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.settingsLanguagePackTitle),
            subtitle: Text(l10n.settingsLanguagePackSubtitle),
            trailing: TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Row(
                      children: [
                        const Icon(Icons.language),
                        const SizedBox(width: 8),
                        Text(l10n.settingsLanguagePackTitle),
                      ],
                    ),
                    content: const Text(
                      'TruthLens 內建之 XLM-RoBERTa 核心檢測模型已原生支援 104+ 種語言（包含中文、英文、日文、韓文、法文、德文、西班牙文等）。\n\n若您需要探索或下載特定語言之強化微調模型（例如 HuggingFace 社群微調變體），請至「AI 模型管理」中進行管理與下載。',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('關閉'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ModelManagerScreen(),
                            ),
                          );
                        },
                        child: Text(l10n.settingsOpenButton),
                      ),
                    ],
                  ),
                );
              },
              child: Text(l10n.settingsOpenButton),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('TruthLens'),
            subtitle: Text(
              '版本 ${AppVersion.displayVersion} (Build ${AppVersion.buildNumber}) · 100% 離線隱私檢測引擎',
            ),
          ),
        ],
      ),
    );
  }
}

/// Web 版本專用：Gemini API 金鑰與本地伺服器 URL 設定（localStorage 持久化）
class _WebOcrSettings extends StatefulWidget {
  const _WebOcrSettings();

  @override
  State<_WebOcrSettings> createState() => _WebOcrSettingsState();
}

class _WebOcrSettingsState extends State<_WebOcrSettings> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _serverUrlController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    // 從 localStorage 讀取已保存的設定（Web 版本）
    if (kIsWeb) {
      try {
        _apiKeyController.text = OcrService.getGeminiApiKey() ?? '';
        _serverUrlController.text = OcrService.getLocalServerUrl() ?? '';
      } catch (e) {
        // 如果讀取失敗，使用空值
        _apiKeyController.text = '';
        _serverUrlController.text = '';
      }
    }
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔑 Gemini API 金鑰（可選）',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '無金鑰時改用本地伺服器。需 Free Tier（1500 req/day）或付費計畫。'
                '\n獲取金鑰：https://ai.google.dev/gemini-api',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'AIza...',
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
                '🖥️ 本地 OCR 伺服器（可選）',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(
                '若已在本機運行 OCR 伺服器（見 https://github.com/hauchiehlin-ops/ocr），'
                '填入 URL。格式：http://127.0.0.1:5001/ocr。'
                '\nWeb 版不具備瀏覽器標準原生 OCR；本地伺服器應在你的電腦上使用系統 OCR 或高效 OCR 引擎，'
                '並接受 JSON：{image: dataURL, languages: [...]}，回傳 {text: "..."} 或 {results:[{text:"..."}]}。',
                style: Theme.of(context).textTheme.bodySmall,
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
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚡ 優先順序',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1️⃣ 本地伺服器（若已設定 URL）\n'
                      '2️⃣ Gemini API（若已提供金鑰）\n'
                      '3️⃣ 顯示具體診斷原因（未設定、金鑰錯誤、伺服器不可用或圖片無文字）',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 保存設定到 localStorage（Web 版本）
  void _saveOcrSettings() {
    if (!kIsWeb) return;

    try {
      OcrService.setGeminiApiKey(_apiKeyController.text);
      OcrService.setLocalServerUrl(_serverUrlController.text);
      setState(() {}); // 刷新 UI 以顯示清除按鈕
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('設定保存失敗：$e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

/// 模型管理頁：依裝置能力列出各 role 的多個開源模型選項與安裝狀態，提供下載 / 移除。
class ModelManagerScreen extends StatefulWidget {
  const ModelManagerScreen({super.key});

  @override
  State<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

class _ModelManagerScreenState extends State<ModelManagerScreen> {
  DeviceCapabilities? _device;
  List<ProvisionPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provisioner = context.read<ModelProvisioner>();
    final device = await DeviceCapabilities.detect();
    final plans = await provisioner.plan(device);
    if (mounted) {
      setState(() {
        _device = device;
        _plans = plans;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsModelManagerAppBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: l10n.settingsImportTooltip,
            onPressed: () async {
              final imported = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const ModelImportScreen()),
              );
              if (imported == true) {
                _load();
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.modelNecessityText),
                        if (_device != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.settingsDeviceLabel(_device!.summary),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ModelOptionsList(plans: _plans),
              ],
            ),
    );
  }
}
