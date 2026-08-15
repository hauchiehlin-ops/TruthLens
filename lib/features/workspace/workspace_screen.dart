import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/detection/model_catalog_service.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/orchestrator.dart';
import '../../core/models/analysis_request.dart';
import '../../core/models/detection_result.dart';
import '../../core/services/document_importer.dart';
import '../../core/services/history_repository.dart';
import '../../core/services/ocr_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/utils/ocr_post_processor.dart';
import '../../core/utils/text_stats.dart';
import '../../l10n/generated/app_localizations.dart';
import '../input/input_screen.dart'
    show InputSettingsDrawer, kSupportedLanguageOptions;
import '../onboarding/model_prompt.dart';
import '../report/report_screen.dart';

enum _WorkspacePhase { idle, ready, analyzing, complete }

/// 單頁戰情中心：匯入、分析進度與完整報告共用同一份狀態。
class WorkspaceScreen extends StatefulWidget {
  final AnalysisRequest? initialRequest;
  final bool autoStart;

  const WorkspaceScreen({
    super.key,
    this.initialRequest,
    this.autoStart = false,
  });

  @override
  State<WorkspaceScreen> createState() => _WorkspaceScreenState();
}

class _WorkspaceScreenState extends State<WorkspaceScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = TextEditingController();
  final _done = <String>{};
  final _scores = <String, EngineScore>{};

  String _sourceFileName = '';
  _WorkspacePhase _phase = _WorkspacePhase.idle;
  DetectionResult? _result;
  int _selectedEvidence = 0;
  int _analysisRun = 0;

  bool get _isAnalyzing => _phase == _WorkspacePhase.analyzing;

  @override
  void initState() {
    super.initState();
    final request = widget.initialRequest;
    if (request != null) {
      _controller.text = request.text;
      _sourceFileName = request.sourceFileName;
      _phase = request.text.trim().isEmpty
          ? _WorkspacePhase.idle
          : _WorkspacePhase.ready;
      if (widget.autoStart && request.text.trim().isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startAnalysis();
        });
      }
    }
    context.read<ModelManager>().checkForUpdates(
      context.read<ModelCatalogService>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, String> _engineLabels(AppLocalizations l10n) => {
    'transformer': l10n.analysisEngineTransformer,
    'statistical': l10n.analysisEngineStatistical,
    'stylometry': l10n.analysisEngineStylometry,
    'adversarial': l10n.analysisEngineAdversarial,
  };

  String _engineRole(String id) {
    for (final role in PreferencesService.engineRoles) {
      if (id == role || id.startsWith('${role}_')) return role;
    }
    return id;
  }

  double? get _runningProbability {
    final available = _scores.values.where((score) => score.available);
    if (available.isEmpty) return null;
    final totalWeight = available.fold<double>(
      0,
      (sum, score) => sum + score.weight,
    );
    if (totalWeight <= 0) return null;
    return available.fold<double>(
          0,
          (sum, score) => sum + score.aiProbability * score.weight,
        ) /
        totalWeight;
  }

  double get _overallProgress => switch (_phase) {
    _WorkspacePhase.idle => 0,
    _WorkspacePhase.ready => 0.16,
    _WorkspacePhase.analyzing => 0.22 + (_done.length / 4 * 0.68),
    _WorkspacePhase.complete => 1,
  };

  WorkspaceMode _effectiveMode(PreferencesService prefs, double width) {
    if (prefs.workspaceMode == WorkspaceMode.original) {
      return WorkspaceMode.commandGrid;
    }
    if (prefs.workspaceMode != WorkspaceMode.automatic) {
      return prefs.workspaceMode;
    }
    return width < 980
        ? WorkspaceMode.missionTimeline
        : WorkspaceMode.commandGrid;
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 2200),
        ),
      );
  }

  void _markInputReady() {
    setState(() {
      _phase = _controller.text.trim().isEmpty
          ? _WorkspacePhase.idle
          : _WorkspacePhase.ready;
      _result = null;
      _done.clear();
      _scores.clear();
      _selectedEvidence = 0;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.isEmpty) return;
    _controller.text = data.text!;
    _sourceFileName = '';
    _markInputReady();
  }

  Future<void> _scanImage() async {
    final l10n = AppLocalizations.of(context);
    final ocr = context.read<OcrService>();
    if (!await ocr.isSupported) {
      if (mounted) _showMessage(l10n.inputOcrUnsupported);
      return;
    }
    final path = await ImagePicker.pick();
    if (path == null || !mounted) return;
    _showMessage(l10n.inputOcrRecognizing);
    final rawText = await ocr.recognize(path);
    if (!mounted) return;
    if (rawText == null || rawText.trim().isEmpty) {
      _showMessage(OcrService.lastErrorMessage ?? l10n.inputOcrNoText);
      return;
    }
    final text = OcrPostProcessor.clean(rawText);
    _controller.text = text;
    _sourceFileName = '';
    _markInputReady();
    _showMessage(l10n.inputOcrRecognized(text.length));
  }

  Future<void> _importDocument() async {
    final l10n = AppLocalizations.of(context);
    final ocr = context.read<OcrService>();
    final canUsePdfOcr = await ocr.isReadyForPdfOcr;
    final doc = await DocumentImporter.pick(
      pdfOcr: canUsePdfOcr
          ? (imageBytes, pageNumber, pageCount) async {
              if (mounted) {
                _showMessage(l10n.inputPdfOcrProgress(pageNumber, pageCount));
              }
              return ocr.recognizeBytes(imageBytes);
            }
          : null,
    );
    if (doc == null || !mounted) return;
    if (doc.text.isEmpty) {
      final message = switch (doc.pdfImportIssue) {
        PdfImportIssue.needsOcr => l10n.inputPdfNeedsOcr(doc.fileName),
        PdfImportIssue.tooManyPages => l10n.inputPdfTooManyPages(
          doc.fileName,
          DocumentImporter.maxPdfOcrPages,
        ),
        PdfImportIssue.unreadable => l10n.inputPdfUnreadable(doc.fileName),
        PdfImportIssue.none => l10n.inputImportNoText(doc.fileName),
      };
      _showMessage(message);
      return;
    }
    _controller.text = doc.text;
    _sourceFileName = doc.fileName;
    _markInputReady();
    _showMessage(
      doc.usedPdfOcr
          ? l10n.inputPdfOcrSuccess(doc.fileName, doc.text.length)
          : l10n.inputImportSuccess(doc.fileName, doc.text.length),
    );
  }

  Future<void> _startAnalysis() async {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (text.length < 40) {
      _showMessage(l10n.inputTooShortSnackbar);
      return;
    }

    final prefs = context.read<PreferencesService>();
    final manager = context.read<ModelManager>();
    final orchestrator = context.read<EnsembleOrchestrator>();
    final history = context.read<HistoryRepository>();
    await manager.refreshInstallStates();
    if (!manager.isInstalled('transformer') && !prefs.modelPromptSuppressed) {
      if (!mounted) return;
      final choice = await showModelDownloadPrompt(context);
      if (!mounted) return;
      if (choice == ModelPromptResult.download) {
        context.push('/models');
        return;
      }
    }

    final run = ++_analysisRun;
    setState(() {
      _phase = _WorkspacePhase.analyzing;
      _result = null;
      _done.clear();
      _scores.clear();
      _selectedEvidence = 0;
    });

    final result = await orchestrator.analyze(
      text,
      sourceFileName: _sourceFileName,
      eslCorrectionEnabled: prefs.eslCorrectionEnabled,
      threshold: prefs.confidenceThreshold,
      prefs: prefs,
      l10n: l10n,
      onEngineDone: (id) {
        if (mounted && run == _analysisRun) {
          setState(() => _done.add(_engineRole(id)));
        }
      },
      onEngineScore: (score) {
        if (mounted && run == _analysisRun) {
          setState(() => _scores[_engineRole(score.engineId)] = score);
        }
      },
    );
    await history.save(result);
    if (!mounted || run != _analysisRun) return;
    setState(() {
      _result = result;
      _phase = _WorkspacePhase.complete;
      _done.addAll(PreferencesService.engineRoles);
    });
  }

  void _newAnalysis() {
    _analysisRun++;
    _controller.clear();
    _sourceFileName = '';
    setState(() {
      _phase = _WorkspacePhase.idle;
      _result = null;
      _done.clear();
      _scores.clear();
      _selectedEvidence = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesService>();
    final width = MediaQuery.sizeOf(context).width;
    final appBarMode = _effectiveMode(prefs, width);
    final compact = width < 760;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const InputSettingsDrawer(),
      appBar: AppBar(
        titleSpacing: 16,
        title: const Text(
          'TruthLens',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          _WorkspaceModeMenu(activeMode: appBarMode),
          if (!compact) _languageMenu(),
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: l10n.inputHistoryTooltip,
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.inputSettingsTooltip,
            onPressed: compact
                ? () => _scaffoldKey.currentState?.openEndDrawer()
                : () => context.push('/settings'),
          ),
          if (!compact)
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: l10n.inputHelpTooltip,
              onPressed: () => context.push('/help'),
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mode = prefs.workspaceMode == WorkspaceMode.automatic
              ? (constraints.maxWidth < 980
                    ? WorkspaceMode.missionTimeline
                    : WorkspaceMode.commandGrid)
              : prefs.workspaceMode;
          return AnimatedSwitcher(
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: KeyedSubtree(
              key: ValueKey(mode),
              child: switch (mode) {
                WorkspaceMode.commandGrid => _commandGrid(),
                WorkspaceMode.missionTimeline => _missionTimeline(),
                WorkspaceMode.evidenceCanvas => _evidenceCanvas(),
                WorkspaceMode.original => _commandGrid(),
                WorkspaceMode.automatic => _commandGrid(),
              },
            ),
          );
        },
      ),
    );
  }

  Widget _languageMenu() {
    final prefs = context.watch<PreferencesService>();
    return PopupMenuButton<Locale?>(
      icon: const Icon(Icons.translate),
      tooltip: 'Language',
      initialValue: prefs.locale,
      onSelected: prefs.setLocale,
      itemBuilder: (context) => [
        for (final option in kSupportedLanguageOptions)
          PopupMenuItem(value: option.$1, child: Text(option.$2)),
      ],
    );
  }

  Widget _commandGrid() {
    final completed = _result != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) return _compactCommandGrid();
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: completed ? 360 : constraints.maxHeight - 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 330, child: _sourcePanel(compact: true)),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 5,
                      child: _telemetryPanel(showTimeline: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(flex: 3, child: _liveFindingsPanel()),
                  ],
                ),
              ),
              if (completed) ...[
                const SizedBox(height: 10),
                Expanded(child: _reportPanel()),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _compactCommandGrid() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          SizedBox(height: 390, child: _sourcePanel(compact: false)),
          const SizedBox(height: 10),
          SizedBox(height: 270, child: _telemetryPanel(showTimeline: true)),
          const SizedBox(height: 10),
          SizedBox(height: 230, child: _liveFindingsPanel()),
          if (_result != null) ...[
            const SizedBox(height: 10),
            SizedBox(height: 720, child: _reportPanel()),
          ],
        ],
      ),
    );
  }

  Widget _missionTimeline() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _timelineStrip(),
          const SizedBox(height: 10),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 760;
                if (narrow) {
                  return Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: _result == null
                            ? _sourcePanel(compact: false)
                            : _reportPanel(),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(height: 210, child: _telemetryPanel()),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _result == null
                          ? _sourcePanel(compact: false)
                          : _reportPanel(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(flex: 3, child: _telemetryPanel()),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _evidenceCanvas() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 820) return _compactEvidenceCanvas();
          return Column(
            children: [
              _timelineStrip(),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: 240, child: _sourceActionsRail()),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          Expanded(flex: 5, child: _evidenceDocument()),
                          if (_result != null) ...[
                            const SizedBox(height: 10),
                            Expanded(flex: 4, child: _reportPanel()),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(width: 290, child: _telemetryPanel()),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _compactEvidenceCanvas() {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _timelineStrip(),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: _Panel(
            title: l10n.workspaceModeEvidence,
            icon: Icons.fact_check_outlined,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: IconButton.filledTonal(
                    onPressed: _isAnalyzing ? null : _importDocument,
                    icon: const Icon(Icons.folder_open_outlined),
                    tooltip: l10n.inputImportButton,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: _isAnalyzing ? null : _pasteFromClipboard,
                    icon: const Icon(Icons.content_paste_outlined),
                    tooltip: l10n.inputPasteButton,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: _isAnalyzing ? null : _scanImage,
                    icon: const Icon(Icons.document_scanner_outlined),
                    tooltip: l10n.inputOcrButton,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: _result != null
                        ? _newAnalysis
                        : (_isAnalyzing ? null : _startAnalysis),
                    icon: Icon(_result != null ? Icons.add : Icons.play_arrow),
                    tooltip: _result != null
                        ? l10n.workspaceNewAnalysis
                        : l10n.inputStartButton,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(child: _evidenceDocument()),
        const SizedBox(height: 10),
        SizedBox(height: 180, child: _telemetryPanel()),
      ],
    );
  }

  Widget _sourceActionsRail() {
    final l10n = AppLocalizations.of(context);
    return _Panel(
      title: l10n.workspaceModeEvidence,
      icon: Icons.fact_check_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _isAnalyzing ? null : _importDocument,
            icon: const Icon(Icons.folder_open_outlined),
            label: Text(l10n.inputImportButton),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : _pasteFromClipboard,
            icon: const Icon(Icons.content_paste_outlined),
            label: Text(l10n.inputPasteButton),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : _scanImage,
            icon: const Icon(Icons.document_scanner_outlined),
            label: Text(l10n.inputOcrButton),
          ),
          const Divider(height: 28),
          Text(
            _sourceFileName.isEmpty ? l10n.workspaceWaiting : _sourceFileName,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const Spacer(),
          if (_result != null)
            OutlinedButton.icon(
              onPressed: _newAnalysis,
              icon: const Icon(Icons.add),
              label: Text(l10n.workspaceNewAnalysis),
            )
          else
            FilledButton.icon(
              onPressed: _isAnalyzing ? null : _startAnalysis,
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.inputStartButton),
            ),
        ],
      ),
    );
  }

  Widget _sourcePanel({required bool compact}) {
    final l10n = AppLocalizations.of(context);
    return _Panel(
      title: l10n.workspaceDocument,
      icon: Icons.description_outlined,
      trailing: _sourceFileName.isEmpty
          ? null
          : Tooltip(
              message: _sourceFileName,
              child: Text(
                _sourceFileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
      child: Column(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              readOnly: _isAnalyzing,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: l10n.inputHint,
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: (_) {
                if (_sourceFileName.isNotEmpty) _sourceFileName = '';
                _markInputReady();
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                l10n.inputCharCount(_controller.text.trim().length),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Spacer(),
              IconButton(
                onPressed: _isAnalyzing ? null : _pasteFromClipboard,
                icon: const Icon(Icons.content_paste_outlined),
                tooltip: l10n.inputPasteButton,
              ),
              IconButton(
                onPressed: _isAnalyzing ? null : _scanImage,
                icon: const Icon(Icons.document_scanner_outlined),
                tooltip: l10n.inputOcrButton,
              ),
              IconButton(
                onPressed: _isAnalyzing ? null : _importDocument,
                icon: const Icon(Icons.folder_open_outlined),
                tooltip: l10n.inputImportButton,
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: _result != null
                ? OutlinedButton.icon(
                    onPressed: _newAnalysis,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.workspaceNewAnalysis),
                  )
                : FilledButton.icon(
                    onPressed: _isAnalyzing || _controller.text.trim().isEmpty
                        ? null
                        : _startAnalysis,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      _isAnalyzing
                          ? l10n.workspaceAnalyzing
                          : l10n.inputStartButton,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _telemetryPanel({bool showTimeline = false}) {
    final l10n = AppLocalizations.of(context);
    final labels = _engineLabels(l10n);
    final probability = _result?.aiProbability ?? _runningProbability ?? 0;
    return _Panel(
      title: l10n.workspaceTelemetry,
      icon: Icons.monitor_heart_outlined,
      trailing: Text('${(_overallProgress * 100).round()}%'),
      child: Column(
        children: [
          Row(
            children: [
              _ProbabilityGauge(
                probability: probability,
                progress: _overallProgress,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(switch (_phase) {
                      _WorkspacePhase.idle => l10n.workspaceWaiting,
                      _WorkspacePhase.ready => l10n.workspaceStageParse,
                      _WorkspacePhase.analyzing => l10n.workspaceAnalyzing,
                      _WorkspacePhase.complete =>
                        l10n.workspaceAnalysisComplete,
                    }, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(end: _overallProgress),
                      duration: MediaQuery.of(context).disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 350),
                      builder: (context, value, child) =>
                          LinearProgressIndicator(
                            value: value,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: labels.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = labels.entries.elementAt(index);
                return _EngineTelemetryRow(
                  label: entry.value,
                  done: _done.contains(entry.key),
                  score: _scores[entry.key]?.aiProbability,
                );
              },
            ),
          ),
          if (showTimeline) ...[
            const Divider(height: 14),
            _timelineStrip(compact: true),
          ],
        ],
      ),
    );
  }

  Widget _timelineStrip({bool compact = false}) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.workspaceStageImport,
      l10n.workspaceStageParse,
      l10n.workspaceStageAnalyze,
      l10n.workspaceStageVerify,
      l10n.workspaceStageReport,
    ];
    final active = switch (_phase) {
      _WorkspacePhase.idle => 0,
      _WorkspacePhase.ready => 1,
      _WorkspacePhase.analyzing => 2,
      _WorkspacePhase.complete => 4,
    };
    final strip = Row(
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          if (i > 0)
            Container(
              width: 8,
              height: 2,
              color: i <= active
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
            ),
          Expanded(
            child: _StageNode(label: labels[i], index: i, active: active),
          ),
        ],
      ],
    );
    if (compact) return strip;
    return SizedBox(
      height: 112,
      child: _Panel(
        title: l10n.workspaceOverallProgress,
        icon: Icons.route_outlined,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: strip,
        ),
      ),
    );
  }

  Widget _liveFindingsPanel() {
    final l10n = AppLocalizations.of(context);
    final evidence = _evidenceRows();
    return _Panel(
      title: l10n.workspaceLiveFindings,
      icon: Icons.radar_outlined,
      child: evidence.isEmpty
          ? Center(
              child: Text(
                l10n.workspaceNoEvidence,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          : ListView.separated(
              itemCount: evidence.take(8).length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = evidence[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.verdictColor(
                      item.$2,
                      brightness: Theme.of(context).brightness,
                    ).withValues(alpha: 0.18),
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    item.$1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text('${(item.$2 * 100).round()}%'),
                );
              },
            ),
    );
  }

  List<(String, double)> _evidenceRows() {
    if (_result != null) {
      return [
        for (final sentence in _result!.sentences)
          (sentence.text, sentence.aiProbability),
      ];
    }
    final text = PreprocessedText.from(_controller.text);
    if (text.sentences.isEmpty || _scores.isEmpty) return const [];
    return [
      for (var i = 0; i < text.sentences.length; i++)
        (text.sentences[i], _runningSentenceScore(i)),
    ];
  }

  double _runningSentenceScore(int index) {
    var weighted = 0.0;
    var totalWeight = 0.0;
    for (final score in _scores.values.where((score) => score.available)) {
      final sentenceScores = score.sentenceScores;
      if (sentenceScores == null || index >= sentenceScores.length) continue;
      weighted += sentenceScores[index] * score.weight;
      totalWeight += score.weight;
    }
    return totalWeight == 0
        ? (_runningProbability ?? 0)
        : weighted / totalWeight;
  }

  Widget _evidenceDocument() {
    final l10n = AppLocalizations.of(context);
    final evidence = _evidenceRows();
    return _Panel(
      title: l10n.workspaceDocument,
      icon: Icons.article_outlined,
      trailing: _runningProbability == null
          ? null
          : Text(
              l10n.workspacePreliminaryVerdict(
                (_runningProbability! * 100).round(),
              ),
              style: Theme.of(context).textTheme.labelSmall,
            ),
      child: evidence.isEmpty
          ? TextField(
              controller: _controller,
              readOnly: _isAnalyzing,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(hintText: l10n.inputHint),
              onChanged: (_) => _markInputReady(),
            )
          : Column(
              children: [
                Expanded(
                  child: SelectionArea(
                    child: ListView.separated(
                      itemCount: evidence.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final item = evidence[index];
                        final selected = index == _selectedEvidence;
                        final color = AppTheme.verdictColor(
                          item.$2,
                          brightness: Theme.of(context).brightness,
                        );
                        return InkWell(
                          onTap: () =>
                              setState(() => _selectedEvidence = index),
                          child: AnimatedContainer(
                            duration: MediaQuery.of(context).disableAnimations
                                ? Duration.zero
                                : const Duration(milliseconds: 220),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(
                                alpha: selected ? 0.18 : 0.07,
                              ),
                              border: Border(
                                left: BorderSide(color: color, width: 3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text('${index + 1}'),
                                ),
                                Expanded(child: Text(item.$1)),
                                const SizedBox(width: 8),
                                Text('${(item.$2 * 100).round()}%'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (evidence.isNotEmpty) ...[
                  const Divider(height: 14),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      '${l10n.workspaceSelectedEvidence} · ${_selectedEvidence + 1}',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _reportPanel() {
    final result = _result;
    if (result == null) return const SizedBox.shrink();
    return _Panel(
      title: AppLocalizations.of(context).workspaceAnalysisComplete,
      icon: Icons.assessment_outlined,
      trailing: IconButton(
        onPressed: _newAnalysis,
        icon: const Icon(Icons.add),
        tooltip: AppLocalizations.of(context).workspaceNewAnalysis,
      ),
      padding: EdgeInsets.zero,
      child: ReportScreen(
        key: ValueKey(result.id),
        result: result,
        embedded: true,
      ),
    );
  }
}

class _WorkspaceModeMenu extends StatelessWidget {
  final WorkspaceMode activeMode;

  const _WorkspaceModeMenu({required this.activeMode});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.read<PreferencesService>();
    return PopupMenuButton<WorkspaceMode>(
      icon: Icon(_modeIcon(activeMode)),
      tooltip: l10n.workspaceModeTooltip,
      onSelected: prefs.setWorkspaceMode,
      itemBuilder: (context) => [
        for (final mode in WorkspaceMode.values)
          PopupMenuItem(
            value: mode,
            child: ListTile(
              dense: true,
              leading: Icon(_modeIcon(mode)),
              title: Text(_modeLabel(mode, l10n)),
            ),
          ),
      ],
    );
  }

  static IconData _modeIcon(WorkspaceMode mode) => switch (mode) {
    WorkspaceMode.original => Icons.view_agenda_outlined,
    WorkspaceMode.automatic => Icons.auto_awesome_mosaic_outlined,
    WorkspaceMode.commandGrid => Icons.grid_view_outlined,
    WorkspaceMode.missionTimeline => Icons.route_outlined,
    WorkspaceMode.evidenceCanvas => Icons.fact_check_outlined,
  };

  static String _modeLabel(WorkspaceMode mode, AppLocalizations l10n) =>
      switch (mode) {
        WorkspaceMode.original => l10n.workspaceModeOriginal,
        WorkspaceMode.automatic => l10n.workspaceModeAuto,
        WorkspaceMode.commandGrid => l10n.workspaceModeCommandGrid,
        WorkspaceMode.missionTimeline => l10n.workspaceModeTimeline,
        WorkspaceMode.evidenceCanvas => l10n.workspaceModeEvidence,
      };
}

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;

  const _Panel({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 42,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (trailing != null)
                    Flexible(child: trailing!)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          Expanded(
            child: Padding(padding: padding, child: child),
          ),
        ],
      ),
    );
  }
}

class _ProbabilityGauge extends StatelessWidget {
  final double probability;
  final double progress;

  const _ProbabilityGauge({required this.probability, required this.progress});

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.verdictColor(
      probability,
      brightness: Theme.of(context).brightness,
    );
    return SizedBox.square(
      dimension: 86,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress),
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 420),
        builder: (context, value, _) => Stack(
          fit: StackFit.expand,
          children: [
            CircularProgressIndicator(
              value: value,
              strokeWidth: 7,
              color: color,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            ),
            Center(
              child: Text(
                '${(probability * 100).round()}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
}

class _EngineTelemetryRow extends StatelessWidget {
  final String label;
  final bool done;
  final double? score;

  const _EngineTelemetryRow({
    required this.label,
    required this.done,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: done
                ? Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Theme.of(context).colorScheme.tertiary,
                  )
                : score != null
                ? const CircularProgressIndicator(strokeWidth: 2)
                : Icon(
                    Icons.radio_button_unchecked,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline,
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (score != null) Text('${(score! * 100).round()}%'),
        ],
      ),
    );
  }
}

class _StageNode extends StatelessWidget {
  final String label;
  final int index;
  final int active;

  const _StageNode({
    required this.label,
    required this.index,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final complete = index < active;
    final current = index == active;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: current,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: complete || current
                  ? scheme.primary
                  : scheme.surfaceContainerHighest,
              border: Border.all(
                color: current ? scheme.onSurface : scheme.outlineVariant,
                width: current ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: complete
                ? Icon(Icons.check, size: 15, color: scheme.onPrimary)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: current ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
