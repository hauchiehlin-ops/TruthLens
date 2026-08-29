import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_display_names.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/model_provisioner.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/services/calibration_exporter.dart';
import 'package:flutter/services.dart';
import '../../core/detection/orchestrator.dart';
import '../../core/models/detection_result.dart';
import '../../core/services/document_importer.dart';
import '../../core/services/document_provenance.dart';
import '../../core/services/calibration_service.dart';
import '../../core/services/weight_learner.dart';
import '../../core/services/preferences_service.dart';
import '../../core/utils/app_version.dart';
import '../../l10n/generated/app_localizations.dart';
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
          const Divider(),
          // 本地基準校準（共形預測）：α 與基準集管理
          Consumer<CalibrationService>(
            builder: (context, calibration, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListTile(
                  title: Text(l10n.settingsAlphaTitle),
                  subtitle: Text(
                    l10n.settingsAlphaSubtitle(
                      (calibration.alpha * 100).round(),
                      calibration.requiredSamples,
                    ),
                  ),
                ),
                Slider(
                  value: calibration.alpha,
                  min: CalibrationService.minAlpha,
                  max: CalibrationService.maxAlpha,
                  divisions: 19,
                  label: '${(calibration.alpha * 100).round()}%',
                  onChanged: (v) => calibration.setAlpha(v),
                ),
                // 學習式權重：由基準集的兩類樣本學出各引擎鑑別力
                Builder(
                  builder: (context) {
                    final learned = WeightLearner.learn(
                      calibration.samples,
                      PreferencesService.engineRoles,
                    );
                    final humanCount = calibration.size;
                    final aiCount = calibration.aiSamples.length;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Text(l10n.learnedWeightsTitle),
                          subtitle: Text(
                            learned == null
                                ? l10n.learnedWeightsNeedMore(
                                    humanCount,
                                    aiCount,
                                    WeightLearner.minSamplesPerClass,
                                  )
                                : l10n.learnedWeightsReady(
                                    learned.humanCount,
                                    learned.aiCount,
                                  ),
                          ),
                        ),
                        if (learned != null) ...[
                          for (final sep in learned.separations)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 2,
                              ),
                              child: Text(
                                l10n.learnedWeightsRow(
                                  sep.engineId,
                                  (sep.suggestedWeight * 100).round(),
                                  sep.effectSize.toStringAsFixed(2),
                                ),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          for (final sep in learned.separations)
                            if (sep.effectSize < 0)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  6,
                                  16,
                                  0,
                                ),
                                child: Text(
                                  l10n.learnedWeightsReversed(sep.engineId),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                ),
                              ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: Text(
                              l10n.learnedWeightsExplain,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: FilledButton.tonal(
                              onPressed: () async {
                                await prefs.setEngineWeights(learned.weights);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.learnedWeightsApplied),
                                  ),
                                );
                              },
                              child: Text(l10n.learnedWeightsApply),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                // 離線驗證語料蒐集：讓實戰使用自然累積出評測語料
                SwitchListTile(
                  title: Text(l10n.settingsAutoCollectTitle),
                  subtitle: Text(l10n.settingsAutoCollectSubtitle),
                  value: calibration.autoCollectEnabled,
                  onChanged: (v) => calibration.setAutoCollect(v),
                ),
                const _AiSampleTile(),
                SwitchListTile(
                  title: Text(l10n.settingsStoreTextTitle),
                  subtitle: Text(l10n.settingsStoreTextSubtitle),
                  value: calibration.storeText,
                  onChanged: (v) => calibration.setStoreText(v),
                ),
                if (calibration.storeText)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      l10n.settingsStoreTextWarning,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                        height: 1.5,
                      ),
                    ),
                  ),
                Builder(
                  builder: (context) {
                    final payload = CalibrationExporter.buildJsonl(
                      calibration.samples,
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ListTile(
                          title: Text(l10n.settingsExportCorpusTitle),
                          subtitle: Text(
                            l10n.settingsExportCorpusSubtitle(
                              payload.humanCount,
                              payload.aiCount,
                              ExportPayload.minDocsPerClass,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              FilledButton.tonal(
                                onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  if (payload.isEmpty) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.settingsExportCorpusEmpty,
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  await FilePicker.saveFile(
                                    dialogTitle: l10n.settingsExportCorpusTitle,
                                    fileName: 'truthlens_corpus.jsonl',
                                    bytes: payload.bytes,
                                  );
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.settingsExportCorpusDone(
                                          payload.exported,
                                          payload.skippedMissingText,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(l10n.settingsExportCorpusButton),
                              ),
                              if (calibration.samplesWithText > 0)
                                TextButton(
                                  onPressed: () async {
                                    await calibration.clearStoredText();
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          l10n.settingsClearStoredTextDone,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(l10n.settingsClearStoredText),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
                ListTile(
                  title: Text(l10n.settingsCalibrationTitle),
                  isThreeLine: true,
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.settingsCalibrationSubtitle(
                          calibration.size,
                          calibration.requiredSamples,
                        ),
                      ),
                      // 基準集逐語言分開，總數不代表任何一個語言已經夠用。
                      // 不逐語言列出，使用者會誤以為收滿 30 份就全語言可用。
                      Builder(
                        builder: (context) {
                          final byLanguage =
                              calibration.humanSampleCountByLanguage;
                          final legacy = calibration.unlabelledLanguageCount;
                          if (byLanguage.isEmpty && legacy == 0) {
                            return const SizedBox.shrink();
                          }
                          final entries = byLanguage.entries.toList()
                            ..sort((a, b) => b.value.compareTo(a.value));
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (entries.isNotEmpty)
                                  Text(
                                    l10n.settingsCalibrationByLanguage(
                                      entries
                                          .map(
                                            (e) =>
                                                '${e.key} ${e.value}/'
                                                '${calibration.requiredSamples}',
                                          )
                                          .join('、'),
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                if (legacy > 0)
                                  Text(
                                    l10n.settingsCalibrationLegacySamples(
                                      legacy,
                                    ),
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline,
                                        ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: calibration.size == 0
                        ? null
                        : () async {
                            await calibration.clear();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.settingsCalibrationCleared),
                              ),
                            );
                          },
                    child: Text(l10n.settingsCalibrationClear),
                  ),
                ),
              ],
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
            subtitle: ValueListenableBuilder<AppVersionInfo>(
              valueListenable: AppVersion.listenable,
              builder: (context, info, _) => Text(
                l10n.settingsVersionSubtitle(
                  info.displayVersion,
                  info.buildNumber,
                ),
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

  /// 函式原本叫「localized」卻寫死英文的 CPU / GB RAM，介面切到其他語系
  /// 仍是英文。改為呼叫共用的在地化版本，與 onboarding 走同一條路徑。
  String _localizedDeviceSummary(DeviceCapabilities device) =>
      localizedDeviceSummary(device, AppLocalizations.of(context));
}

/// 手動新增「已知由 AI 產出」的樣本。
///
/// 背景自動蒐集刻意只收人類樣本——AI 標籤沒有任何獨立證據可依循，
/// 靠判定結果自我標註會造成循環論證。因此 AI 樣本只能由使用者明確提供，
/// 這也是**第 4 項學習式引擎權重**唯一的資料來源。
///
/// 放在設定頁而非報告頁：這是偶爾為之的建置動作，不該出現在日常判讀流程裡。
class _AiSampleTile extends StatefulWidget {
  const _AiSampleTile();

  @override
  State<_AiSampleTile> createState() => _AiSampleTileState();
}

class _AiSampleTileState extends State<_AiSampleTile> {
  bool _busy = false;

  Future<void> _addFrom(Future<String?> Function() source) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final calibration = context.read<CalibrationService>();
    final orchestrator = context.read<EnsembleOrchestrator>();
    final prefs = context.read<PreferencesService>();

    setState(() => _busy = true);
    try {
      final text = (await source())?.trim() ?? '';
      if (text.isEmpty) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsAiSampleFailed)),
        );
        return;
      }
      // 與棄權門檻同一個標準：太短的樣本對權重學習沒有意義
      if (DocumentProvenance.countWords(text) < DetectionResult.minWords) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsAiSampleTooShort)),
        );
        return;
      }

      final result = await orchestrator.analyze(
        text,
        calibration: calibration,
        eslCorrectionEnabled: prefs.eslCorrectionEnabled,
        prefs: prefs,
        l10n: l10n,
      );
      await calibration.addSample(
        result.aiProbability,
        isAi: true,
        engineScores: {
          for (final e in result.engineScores)
            if (e.available) e.engineId: e.aiProbability,
        },
        text: text,
        analysisSignature: result.calibration.analysisSignature,
        domain: result.calibration.domain,
        lengthBucket: result.calibration.lengthBucket,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            l10n.settingsAiSampleAdded(calibration.aiSamples.length),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: Text(l10n.settingsAiSampleTitle),
          subtitle: Text(l10n.settingsAiSampleSubtitle),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: _busy
              ? Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.settingsAiSampleAnalyzing),
                  ],
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _addFrom(() async {
                        final data = await Clipboard.getData(
                          Clipboard.kTextPlain,
                        );
                        return data?.text;
                      }),
                      icon: Icon(LucideIcons.clipboard, size: 16),
                      label: Text(l10n.settingsAiSampleFromClipboard),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _addFrom(() async {
                        final doc = await DocumentImporter.pick();
                        return doc?.text;
                      }),
                      icon: Icon(LucideIcons.folderOpen, size: 16),
                      label: Text(l10n.settingsAiSampleFromFile),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
