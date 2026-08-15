import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';
import '../../core/utils/app_version.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/threshold_setting_title.dart';
import '../../shared/widgets/workspace_navigation.dart'
    show kSupportedLanguageOptions;
import '../onboarding/model_options_list.dart';
import 'model_import_screen.dart';
import 'engine_weight_settings.dart';
import 'web_ocr_settings.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// 設定頁：信心閾值、ESL 修正、主題、語言、模型管理
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
            leading: Icon(LucideIcons.layoutGrid),
            title: Text(l10n.workspaceModeSectionTitle),
            subtitle: Text(l10n.workspaceModeSectionSubtitle),
            trailing: DropdownButton<WorkspaceMode>(
              value: prefs.workspaceMode,
              items: [
                for (final mode in WorkspaceMode.values)
                  DropdownMenuItem(
                    value: mode,
                    child: Text(_workspaceModeLabel(mode, l10n)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) prefs.setWorkspaceMode(value);
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const ThresholdSettingTitle(),
            subtitle: Text(
              l10n.settingsThresholdSubtitle(
                (prefs.confidenceThreshold * 100).round(),
              ),
            ),
          ),
          Slider(
            value: prefs.confidenceThreshold,
            min: PreferencesService.minConfidenceThreshold,
            max: PreferencesService.maxConfidenceThreshold,
            divisions: PreferencesService.confidenceThresholdDivisions,
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
          const EngineWeightSettingsCard(),
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
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(LucideIcons.sunMoon),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(LucideIcons.sun),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(LucideIcons.moon),
                ),
              ],
              selected: {prefs.themeMode},
              onSelectionChanged: (s) => prefs.setThemeMode(s.first),
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(LucideIcons.languages),
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
              child: Icon(LucideIcons.download),
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
            leading: Icon(LucideIcons.upload),
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
          if (kIsWeb) ...[const WebOcrSettingsCard(), const Divider()],
          ListTile(
            leading: Icon(LucideIcons.info),
            title: const Text('TruthLens'),
            subtitle: Text(
              l10n.settingsVersionSubtitle(
                AppVersion.displayVersion,
                AppVersion.buildNumber,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _workspaceModeLabel(WorkspaceMode mode, AppLocalizations l10n) =>
      switch (mode) {
        WorkspaceMode.original => l10n.workspaceModeOriginal,
        WorkspaceMode.automatic => l10n.workspaceModeAuto,
        WorkspaceMode.commandGrid => l10n.workspaceModeCommandGrid,
        WorkspaceMode.missionTimeline => l10n.workspaceModeTimeline,
        WorkspaceMode.evidenceCanvas => l10n.workspaceModeEvidence,
        WorkspaceMode.cosmicFuture => l10n.workspaceModeCosmicFuture,
        WorkspaceMode.softEducation => l10n.workspaceModeSoftEducation,
      };
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
            icon: Icon(LucideIcons.upload),
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
                            l10n.settingsDeviceLabel(
                              _localizedDeviceSummary(_device!),
                            ),
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

  String _localizedDeviceSummary(DeviceCapabilities device) {
    final ram = (device.totalRamMb / 1024).toStringAsFixed(
      device.totalRamMb % 1024 == 0 ? 0 : 1,
    );
    return '${device.platform.toUpperCase()} · ${device.processors} CPU · '
        '$ram GB RAM · ${device.tier.name.toUpperCase()}';
  }
}
