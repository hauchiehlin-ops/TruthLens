import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/ocr_service.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shared Web OCR settings used by the settings page and both input-screen
/// settings panels. Keeping one implementation prevents locale and behavior
/// from drifting between layouts.
class WebOcrSettingsCard extends StatefulWidget {
  final bool compact;

  const WebOcrSettingsCard({super.key, this.compact = false});

  @override
  State<WebOcrSettingsCard> createState() => _WebOcrSettingsCardState();
}

class _WebOcrSettingsCardState extends State<WebOcrSettingsCard> {
  static const String _defaultLocalOcrEndpoint = 'http://127.0.0.1:5001/ocr';

  static final Uri _geminiKeyUri = Uri.parse(
    'https://aistudio.google.com/app/apikey',
  );
  static final Uri _localOcrProjectUri = Uri.parse(
    'https://github.com/hauchiehlin-ops/ocr',
  );
  static final Uri _macInstallerUri = Uri.parse(
    'https://github.com/hauchiehlin-ops/ocr/raw/refs/heads/main/setup_and_run_ocr.sh',
  );
  static final Uri _windowsInstallerUri = Uri.parse(
    'https://github.com/hauchiehlin-ops/ocr/raw/refs/heads/main/setup_and_run_ocr.bat',
  );

  late final TextEditingController _apiKeyController;
  late final TextEditingController _serverUrlController;
  bool _testingServer = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _serverUrlController = TextEditingController();
    _loadSettings();
  }

  void _loadSettings() {
    if (!kIsWeb) return;
    try {
      _apiKeyController.text = OcrService.getGeminiApiKey() ?? '';
      _serverUrlController.text = OcrService.getLocalServerUrl() ?? '';
    } catch (_) {
      _apiKeyController.clear();
      _serverUrlController.clear();
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final titleStyle = widget.compact
        ? theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)
        : theme.textTheme.titleSmall;
    final fieldPadding = widget.compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
        : const EdgeInsets.all(12);

    return Padding(
      padding: widget.compact
          ? const EdgeInsets.symmetric(vertical: 8)
          : const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.webOcrSettingsTitle,
            style: titleStyle?.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(l10n.webOcrPurpose, style: theme.textTheme.bodySmall),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(l10n.webOcrGeminiKeyTitle, style: titleStyle),
              ),
              TextButton(
                onPressed: () => _openUri(_geminiKeyUri),
                child: Text(l10n.webOcrGetKeyButton),
              ),
            ],
          ),
          Text(l10n.webOcrGeminiDescription, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          TextField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'AIza...',
              border: const OutlineInputBorder(),
              contentPadding: fieldPadding,
              isDense: widget.compact,
              suffixIcon: _apiKeyController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.commonDelete,
                      onPressed: () {
                        _apiKeyController.clear();
                        _saveSettings();
                      },
                    ),
            ),
            onChanged: (_) => _saveSettings(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(l10n.webOcrLocalServerTitle, style: titleStyle),
              ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                tooltip: _assistantButtonLabel(l10n),
                onPressed: _configureLocalOcrAssistant,
              ),
            ],
          ),
          Text(
            l10n.webOcrLocalServerDescription,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _serverUrlController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'http://127.0.0.1:5001/ocr',
              border: const OutlineInputBorder(),
              contentPadding: fieldPadding,
              isDense: widget.compact,
              suffixIcon: _serverUrlController.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.commonDelete,
                      onPressed: () {
                        _serverUrlController.clear();
                        _saveSettings();
                      },
                    ),
            ),
            onChanged: (_) => _saveSettings(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: _configureLocalOcrAssistant,
                icon: const Icon(Icons.auto_fix_high_outlined),
                label: Text(_assistantButtonLabel(l10n)),
              ),
              FilledButton.tonalIcon(
                onPressed: _testingServer ? null : _testLocalServer,
                icon: _testingServer
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.network_check),
                label: Text(l10n.webOcrTestServerButton),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.webOcrPriorityTitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.webOcrPriorityDescription,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _configureLocalOcrAssistant() async {
    final l10n = AppLocalizations.of(context);
    final installer = _detectLocalOcrInstaller();

    if (installer == null) {
      await _showAssistantResultDialog(
        title: _assistantUnsupportedTitle(l10n),
        body: _assistantUnsupportedBody(l10n),
        primaryLabel: l10n.webOcrOpenProjectButton,
        onPrimary: () => _openUri(_localOcrProjectUri),
      );
      return;
    }

    _serverUrlController.text = _defaultLocalOcrEndpoint;
    _saveSettings();
    await _openUri(installer.downloadUri);

    if (!mounted) return;
    await _showAssistantResultDialog(
      title: _assistantDownloadedTitle(l10n, installer.osName),
      body: _assistantDownloadedBody(l10n, installer),
      primaryLabel: l10n.webOcrTestServerButton,
      onPrimary: _testLocalServer,
    );
  }

  Future<void> _showAssistantResultDialog({
    required String title,
    required String body,
    required String primaryLabel,
    required Future<void> Function() onPrimary,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_fix_high_outlined),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: SingleChildScrollView(child: SelectableText(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppLocalizations.of(context).commonClose),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await onPrimary();
            },
            child: Text(primaryLabel),
          ),
        ],
      ),
    );
  }

  Future<void> _testLocalServer() async {
    final l10n = AppLocalizations.of(context);
    if (_serverUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.webOcrTestServerMissingUrl)));
      return;
    }
    _saveSettings();
    setState(() => _testingServer = true);
    final connected = await OcrService.testLocalServer();
    if (!mounted) return;
    setState(() => _testingServer = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          connected
              ? l10n.webOcrTestServerSuccess
              : l10n.webOcrTestServerFailure,
        ),
        backgroundColor: connected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.error,
      ),
    );
  }

  Future<void> _openUri(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  _LocalOcrInstaller? _detectLocalOcrInstaller() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.macOS => _LocalOcrInstaller(
        osName: 'macOS',
        fileName: 'setup_and_run_ocr.sh',
        downloadUri: _macInstallerUri,
        zhRunInstruction: 'bash ~/Downloads/setup_and_run_ocr.sh',
        enRunInstruction: 'bash ~/Downloads/setup_and_run_ocr.sh',
      ),
      TargetPlatform.windows => _LocalOcrInstaller(
        osName: 'Windows',
        fileName: 'setup_and_run_ocr.bat',
        downloadUri: _windowsInstallerUri,
        zhRunInstruction: '按兩下 Downloads 資料夾中的 setup_and_run_ocr.bat',
        enRunInstruction: 'double-click setup_and_run_ocr.bat in Downloads',
      ),
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => null,
    };
  }

  bool _isZh(AppLocalizations l10n) =>
      l10n.localeName.toLowerCase().startsWith('zh');

  String _assistantButtonLabel(AppLocalizations l10n) =>
      _isZh(l10n) ? '偵測系統並下載安裝檔' : 'Detect OS & download installer';

  String _assistantUnsupportedTitle(AppLocalizations l10n) =>
      _isZh(l10n) ? '此系統無法自動安裝' : 'Automatic install is not available';

  String _assistantUnsupportedBody(AppLocalizations l10n) => _isZh(l10n)
      ? '已偵測到目前平台不是支援的一鍵安裝桌面環境。Web 瀏覽器不能直接在 iOS、Android、Linux 或未知系統上安裝並啟動本機 OCR 服務。\n\n可用做法：\n1. 在 macOS 或 Windows 桌面瀏覽器使用此精靈。\n2. 或改用 Gemini API 金鑰作為 Web OCR 備援。\n3. 進階使用者可開啟 OCR 專案，自行部署相容的 /ocr 端點，再回到此處填入 URL 並測試連線。'
      : 'The current platform is not a supported one-click desktop install target. A web browser cannot install and start a local OCR service on iOS, Android, Linux, or an unknown system.\n\nOptions:\n1. Use this assistant from a macOS or Windows desktop browser.\n2. Use a Gemini API key as the Web OCR fallback.\n3. Advanced users can open the OCR project, run a compatible /ocr endpoint manually, then enter the URL here and test the connection.';

  String _assistantDownloadedTitle(AppLocalizations l10n, String osName) =>
      _isZh(l10n) ? '已準備 $osName 安裝檔' : '$osName installer is ready';

  String _assistantDownloadedBody(
    AppLocalizations l10n,
    _LocalOcrInstaller installer,
  ) {
    if (_isZh(l10n)) {
      return '已偵測到 ${installer.osName}，並已自動填入本地端點：\n$_defaultLocalOcrEndpoint\n\n瀏覽器已開始下載 ${installer.fileName}。基於瀏覽器安全限制，TruthLens Web 不能直接替您執行安裝檔或修改系統啟動項目。\n\n請完成以下步驟：\n1. 執行下載的安裝檔：${installer.zhRunInstruction}\n2. 等待終端機或視窗顯示 OCR 服務已就緒。\n3. 回到此視窗按「${l10n.webOcrTestServerButton}」。\n\n測試成功後，圖片 OCR 會優先使用這個本地服務；圖片內容不會送往 Gemini，除非您另外設定 Gemini API 金鑰作為備援。';
    }
    return '${installer.osName} was detected, and the local endpoint has been filled in automatically:\n$_defaultLocalOcrEndpoint\n\nYour browser has started downloading ${installer.fileName}. For browser security reasons, TruthLens Web cannot execute the installer or change startup settings directly.\n\nNext steps:\n1. Run the downloaded installer: ${installer.enRunInstruction}\n2. Wait until the terminal or window says the OCR service is ready.\n3. Return here and select “${l10n.webOcrTestServerButton}”.\n\nAfter the test succeeds, Image OCR will use this local service first. Images will not be sent to Gemini unless you also configure a Gemini API key as fallback.';
  }

  void _saveSettings() {
    if (!kIsWeb) return;
    try {
      OcrService.setGeminiApiKey(_apiKeyController.text);
      OcrService.setLocalServerUrl(_serverUrlController.text);
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).settingsSaveFailed('$error'),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _LocalOcrInstaller {
  final String osName;
  final String fileName;
  final Uri downloadUri;
  final String zhRunInstruction;
  final String enRunInstruction;

  const _LocalOcrInstaller({
    required this.osName,
    required this.fileName,
    required this.downloadUri,
    required this.zhRunInstruction,
    required this.enRunInstruction,
  });
}
