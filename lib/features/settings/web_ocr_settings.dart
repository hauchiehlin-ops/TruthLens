import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/ocr_config_notifier.dart';
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

  @override
  void initState() {
    super.initState();
    final notifier = context.read<OcrConfigNotifier>();
    _apiKeyController = TextEditingController(text: notifier.geminiApiKey);
    _serverUrlController = TextEditingController(text: notifier.localServerUrl);
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
    final notifier = context.watch<OcrConfigNotifier>();
    final titleStyle = widget.compact
        ? theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)
        : theme.textTheme.titleSmall;
    final fieldPadding = widget.compact
        ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
        : const EdgeInsets.all(12);

    // 外部（如安裝精靈）改動了設定值時，同步回輸入框，避免顯示落後於實際狀態。
    if (_serverUrlController.text != notifier.localServerUrl) {
      _serverUrlController.text = notifier.localServerUrl;
    }

    final geminiStatus = _geminiStatus(notifier);
    final localStatus = _localStatus(notifier);

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
                      icon: Icon(LucideIcons.x),
                      tooltip: l10n.commonDelete,
                      onPressed: () {
                        _apiKeyController.clear();
                        notifier.setGeminiApiKey('');
                      },
                    ),
            ),
            onChanged: (value) => notifier.setGeminiApiKey(value),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LocalOcrStatusLight(
                status: geminiStatus,
                compact: widget.compact,
                label: _geminiStatusLabel(l10n, geminiStatus),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: notifier.testingGemini ? null : _testGeminiKey,
                icon: notifier.testingGemini
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(LucideIcons.wifi, size: 16),
                label: Text(l10n.webOcrTestServerButton),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(l10n.webOcrLocalServerTitle, style: titleStyle),
              ),
              IconButton(
                icon: Icon(LucideIcons.helpCircle),
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
                      icon: Icon(LucideIcons.x),
                      tooltip: l10n.commonDelete,
                      onPressed: () {
                        _serverUrlController.clear();
                        notifier.setLocalServerUrl('');
                      },
                    ),
            ),
            onChanged: (value) => notifier.setLocalServerUrl(value),
          ),
          const SizedBox(height: 8),
          _LocalOcrStatusLight(
            status: localStatus,
            compact: widget.compact,
            label: _localOcrStatusLabel(l10n, localStatus),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: _configureLocalOcrAssistant,
                icon: Icon(LucideIcons.wand),
                label: Text(_assistantButtonLabel(l10n)),
              ),
              FilledButton.tonalIcon(
                onPressed: notifier.testingLocal ? null : _testLocalServer,
                icon: notifier.testingLocal
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(LucideIcons.wifi),
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
                const SizedBox(height: 8),
                Text(
                  _activeEngineSummary(l10n, notifier),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
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
    final notifier = context.read<OcrConfigNotifier>();
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

    notifier.setLocalServerUrl(_defaultLocalOcrEndpoint);
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
            Icon(LucideIcons.wand),
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
    final notifier = context.read<OcrConfigNotifier>();
    if (_serverUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.webOcrTestServerMissingUrl)));
      return;
    }
    final connected = await notifier.testLocal();
    if (!mounted) return;
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

  Future<void> _testGeminiKey() async {
    final l10n = AppLocalizations.of(context);
    final notifier = context.read<OcrConfigNotifier>();
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.ocrGeminiKeyRequired,
          ),
        ),
      );
      return;
    }
    final connected = await notifier.testGemini();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          connected
              ? (l10n.ocrGeminiKeyValid)
              : (l10n.ocrGeminiKeyUnreachable),
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
        isWindows: false,
      ),
      TargetPlatform.windows => _LocalOcrInstaller(
        osName: 'Windows',
        fileName: 'setup_and_run_ocr.bat',
        downloadUri: _windowsInstallerUri,
        isWindows: true,
      ),
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.linux ||
      TargetPlatform.fuchsia => null,
    };
  }

  _LocalOcrStatus _localStatus(OcrConfigNotifier notifier) {
    if (notifier.testingLocal) return _LocalOcrStatus.checking;
    if (notifier.localServerUrl.isEmpty) return _LocalOcrStatus.notConfigured;
    if (notifier.localVerified) return _LocalOcrStatus.ready;
    if (notifier.localLastTestOk == false) return _LocalOcrStatus.unavailable;
    return _LocalOcrStatus.needsTest;
  }

  _LocalOcrStatus _geminiStatus(OcrConfigNotifier notifier) {
    if (notifier.testingGemini) return _LocalOcrStatus.checking;
    if (notifier.geminiApiKey.isEmpty) return _LocalOcrStatus.notConfigured;
    if (notifier.geminiVerified) return _LocalOcrStatus.ready;
    if (notifier.geminiLastTestOk == false) return _LocalOcrStatus.unavailable;
    return _LocalOcrStatus.needsTest;
  }

  String _localOcrStatusLabel(AppLocalizations l10n, _LocalOcrStatus status) {
    return switch (status) {
      _LocalOcrStatus.notConfigured =>
        l10n.ocrStatusLocalUnset,
      _LocalOcrStatus.needsTest =>
        l10n.ocrStatusLocalUntested,
      _LocalOcrStatus.checking =>
        l10n.ocrStatusLocalTesting,
      _LocalOcrStatus.ready => l10n.ocrStatusLocalReady,
      _LocalOcrStatus.unavailable =>
        l10n.ocrStatusLocalUnreachable,
    };
  }

  String _geminiStatusLabel(AppLocalizations l10n, _LocalOcrStatus status) {
    return switch (status) {
      _LocalOcrStatus.notConfigured =>
        l10n.ocrStatusGeminiUnset,
      _LocalOcrStatus.needsTest =>
        l10n.ocrStatusGeminiUntested,
      _LocalOcrStatus.checking =>
        l10n.ocrStatusGeminiVerifying,
      _LocalOcrStatus.ready => l10n.ocrStatusGeminiValid,
      _LocalOcrStatus.unavailable =>
        l10n.ocrStatusGeminiInvalid,
    };
  }

  String _activeEngineSummary(
    AppLocalizations l10n,
    OcrConfigNotifier notifier,
  ) {
    return switch (notifier.activeEngine) {
      OcrEngineKind.local =>
        notifier.localVerified
            ? (l10n.ocrActiveLocalVerified)
            : (l10n.ocrActiveLocalUntested),
      OcrEngineKind.gemini =>
        notifier.geminiVerified
            ? (l10n.ocrActiveGeminiVerified)
            : (l10n.ocrActiveGeminiUntested),
      OcrEngineKind.none =>
        l10n.ocrActiveNone,
    };
  }

  String _assistantButtonLabel(AppLocalizations l10n) =>
      l10n.ocrDetectAndDownload;

  String _assistantUnsupportedTitle(AppLocalizations l10n) =>
      l10n.ocrAutoInstallUnavailable;

  String _assistantUnsupportedBody(AppLocalizations l10n) => l10n.ocrUnsupportedPlatformBody;

  String _assistantDownloadedTitle(AppLocalizations l10n, String osName) =>
      l10n.ocrInstallerReady(osName);

  String _assistantDownloadedBody(
    AppLocalizations l10n,
    _LocalOcrInstaller installer,
  ) => l10n.ocrAssistantDownloadedBody(
    installer.osName,
    _defaultLocalOcrEndpoint,
    installer.fileName,
    installer.isWindows
        ? l10n.ocrRunInstructionWindows
        : l10n.ocrRunInstructionMac,
    l10n.webOcrTestServerButton,
  );
}

class _LocalOcrInstaller {
  final String osName;
  final String fileName;
  final Uri downloadUri;
  /// 執行指令依作業系統而異，且需在地化——原本把中英兩份文字寫死在資料模型裡，
  /// 其餘 12 個語系一律拿到英文。改為只保留判別旗標，文字交給 l10n。
  final bool isWindows;

  const _LocalOcrInstaller({
    required this.osName,
    required this.fileName,
    required this.downloadUri,
    required this.isWindows,
  });
}

enum _LocalOcrStatus { notConfigured, needsTest, checking, ready, unavailable }

class _LocalOcrStatusLight extends StatelessWidget {
  final _LocalOcrStatus status;
  final bool compact;
  final String label;

  const _LocalOcrStatusLight({
    required this.status,
    required this.compact,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _statusColor(theme.colorScheme);

    return Semantics(
      label: label,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 12,
          vertical: compact ? 7 : 8,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.45)),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(ColorScheme scheme) {
    return switch (status) {
      _LocalOcrStatus.notConfigured => scheme.onSurfaceVariant,
      _LocalOcrStatus.needsTest => Colors.amber.shade700,
      _LocalOcrStatus.checking => scheme.primary,
      _LocalOcrStatus.ready => Colors.green.shade700,
      _LocalOcrStatus.unavailable => scheme.error,
    };
  }
}
