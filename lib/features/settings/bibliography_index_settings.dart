import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';

class BibliographyIndexSettingsScreen extends StatefulWidget {
  const BibliographyIndexSettingsScreen({super.key});

  @override
  State<BibliographyIndexSettingsScreen> createState() =>
      _BibliographyIndexSettingsScreenState();
}

class _BibliographyIndexSettingsScreenState
    extends State<BibliographyIndexSettingsScreen> {
  static final _wosKeyUri = Uri.parse(
    'https://developer.clarivate.com/apis/wos-starter',
  );
  static final _eiKeyUri = Uri.parse('https://dev.elsevier.com/ev_apis.html');

  late final TextEditingController _wosController;
  late final TextEditingController _eiController;
  late final TextEditingController _eiInstitutionController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final prefs = context.read<PreferencesService>();
    _wosController = TextEditingController(text: prefs.webOfScienceApiKey);
    _eiController = TextEditingController(text: prefs.engineeringVillageApiKey);
    _eiInstitutionController = TextEditingController(
      text: prefs.engineeringVillageInstitutionToken,
    );
  }

  @override
  void dispose() {
    _wosController.dispose();
    _eiController.dispose();
    _eiInstitutionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<PreferencesService>().setBibliographyApiCredentials(
      webOfScienceKey: _wosController.text,
      engineeringVillageKey: _eiController.text,
      engineeringVillageInstitutionTokenValue: _eiInstitutionController.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).settingsBibliographyCredentialsSaved,
        ),
      ),
    );
  }

  Future<void> _open(Uri uri) async {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsBibliographyCredentialsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            l10n.settingsBibliographyCredentialsDescription,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.public),
            title: Text(l10n.settingsTaiwanIndexTitle),
            subtitle: Text(l10n.settingsTaiwanIndexSubtitle),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          ),
          const Divider(),
          _CredentialSection(
            title: l10n.settingsWosApiKeyTitle,
            description: l10n.settingsWosApiKeyDescription,
            controller: _wosController,
            hintText: 'X-ApiKey',
            openLabel: l10n.settingsWosFreePlanButton,
            onOpen: () => _open(_wosKeyUri),
          ),
          const Divider(height: 32),
          _CredentialSection(
            title: l10n.settingsEiApiKeyTitle,
            description: l10n.settingsEiApiKeyDescription,
            controller: _eiController,
            hintText: 'X-ELS-APIKey',
            openLabel: l10n.settingsGetApiKeyButton,
            onOpen: () => _open(_eiKeyUri),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _eiInstitutionController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.settingsEiInstitutionTokenLabel,
              helperText: l10n.settingsEiInstitutionTokenHelper,
              helperMaxLines: 2,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.settingsSaveBibliographyCredentialsButton),
          ),
        ],
      ),
    );
  }
}

class _CredentialSection extends StatelessWidget {
  final String title;
  final String description;
  final TextEditingController controller;
  final String hintText;
  final String openLabel;
  final VoidCallback onOpen;

  const _CredentialSection({
    required this.title,
    required this.description,
    required this.controller,
    required this.hintText,
    required this.openLabel,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.titleSmall),
            ),
            TextButton.icon(
              onPressed: onOpen,
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(openLabel),
            ),
          ],
        ),
        Text(description, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
