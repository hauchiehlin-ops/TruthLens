import 'package:flutter/foundation.dart' show kIsWeb;
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
  static final Uri _geminiKeyUri = Uri.parse(
    'https://aistudio.google.com/app/apikey',
  );
  static final Uri _localOcrProjectUri = Uri.parse(
    'https://github.com/hauchiehlin-ops/ocr',
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
                tooltip: l10n.webOcrSetupGuideButton,
                onPressed: _showSetupGuide,
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
                onPressed: _testingServer ? null : _testLocalServer,
                icon: _testingServer
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.network_check),
                label: Text(l10n.webOcrTestServerButton),
              ),
              OutlinedButton.icon(
                onPressed: _showSetupGuide,
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(l10n.webOcrSetupGuideButton),
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

  Future<void> _showSetupGuide() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.computer_outlined),
            const SizedBox(width: 8),
            Expanded(child: Text(l10n.webOcrSetupGuideTitle)),
          ],
        ),
        content: SingleChildScrollView(
          child: SelectableText(l10n.webOcrSetupGuideBody),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _openUri(_localOcrProjectUri),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.webOcrOpenProjectButton),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonClose),
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
