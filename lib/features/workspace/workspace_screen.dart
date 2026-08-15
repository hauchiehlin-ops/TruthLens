import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
import '../../shared/widgets/app_copyright_footer.dart';
import '../../shared/widgets/professional_report_header.dart' show EngineGroup;
import '../../shared/widgets/workspace_navigation.dart';
import '../input/input_screen.dart' show InputSettingsDrawer;
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
  final _activeEngines = <String>{};
  final _scores = <String, EngineScore>{};

  // 各工作台模式下的面板可拖曳調整大小（使用者手動調整後的期望尺寸，
  // 未調整則為 null，走各自的預設比例／尺寸）。
  double? _commandGridSourceWidth;
  double? _commandGridTelemetryWidth;
  double? _compactGridSourceHeight;
  double? _compactGridTelemetryHeight;
  double? _compactGridFindingsHeight;
  double? _timelineNarrowMainHeight;
  double? _timelineWideMainWidth;
  double? _evidenceRailWidth;
  double? _evidenceTelemetryWidth;
  double? _evidenceDocumentHeight;
  double? _compactEvidenceDocumentHeight;

  String _sourceFileName = '';
  _WorkspacePhase _phase = _WorkspacePhase.idle;
  DetectionResult? _result;
  int _selectedEvidence = 0;
  int _analysisRun = 0;
  Timer? _analysisTicker;
  DateTime? _analysisStartedAt;
  DateTime? _lastProgressAt;
  int _elapsedSeconds = 0;

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
    _analysisTicker?.cancel();
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

  int get _secondsSinceProgress {
    final last = _lastProgressAt;
    return last == null ? 0 : DateTime.now().difference(last).inSeconds;
  }

  void _startAnalysisTicker() {
    _analysisTicker?.cancel();
    _analysisTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isAnalyzing) return;
      setState(() {
        _elapsedSeconds = DateTime.now()
            .difference(_analysisStartedAt!)
            .inSeconds;
      });
    });
  }

  void _stopAnalysisTicker() {
    _analysisTicker?.cancel();
    _analysisTicker = null;
  }

  Future<void> _confirmStopAnalysis() async {
    if (!_isAnalyzing) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.workspaceStopAnalysisTitle),
        content: Text(l10n.workspaceStopAnalysisBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.workspaceStopAnalysis),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted || !_isAnalyzing) return;

    _analysisRun++;
    _stopAnalysisTicker();
    setState(() {
      _phase = _WorkspacePhase.ready;
      _result = null;
      _done.clear();
      _activeEngines.clear();
      _scores.clear();
      _selectedEvidence = 0;
      _elapsedSeconds = 0;
    });
    _showMessage(l10n.workspaceAnalysisStopped);
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
      _activeEngines.clear();
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
          DocumentImporter.effectiveMaxPdfOcrPages,
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
    final startedAt = DateTime.now();
    setState(() {
      _phase = _WorkspacePhase.analyzing;
      _result = null;
      _done.clear();
      _activeEngines.clear();
      _scores.clear();
      _selectedEvidence = 0;
      _analysisStartedAt = startedAt;
      _lastProgressAt = startedAt;
      _elapsedSeconds = 0;
    });
    _startAnalysisTicker();
    await WidgetsBinding.instance.endOfFrame;

    try {
      final result = await orchestrator.analyze(
        text,
        sourceFileName: _sourceFileName,
        eslCorrectionEnabled: prefs.eslCorrectionEnabled,
        threshold: prefs.confidenceThreshold,
        prefs: prefs,
        l10n: l10n,
        onEngineStarted: (id) {
          if (mounted && run == _analysisRun) {
            setState(() => _activeEngines.add(_engineRole(id)));
          }
        },
        onEngineDone: (id) {
          if (mounted && run == _analysisRun) {
            final role = _engineRole(id);
            setState(() {
              _done.add(role);
              _activeEngines.remove(role);
              _lastProgressAt = DateTime.now();
            });
          }
        },
        onEngineScore: (score) {
          if (mounted && run == _analysisRun) {
            setState(() => _scores[_engineRole(score.engineId)] = score);
          }
        },
      );
      if (run != _analysisRun) return;
      await history.save(result);
      if (run != _analysisRun) {
        await history.delete(result.id);
        return;
      }
      if (!mounted) return;
      setState(() {
        _result = result;
        _phase = _WorkspacePhase.complete;
        _done.addAll(PreferencesService.engineRoles);
        _activeEngines.clear();
      });
    } catch (_) {
      if (!mounted || run != _analysisRun) return;
      setState(() {
        _phase = _WorkspacePhase.ready;
        _activeEngines.clear();
      });
      _showMessage(l10n.workspaceAnalysisFailed);
    } finally {
      if (run == _analysisRun) _stopAnalysisTicker();
    }
  }

  void _newAnalysis() {
    _analysisRun++;
    _stopAnalysisTicker();
    _controller.clear();
    _sourceFileName = '';
    setState(() {
      _phase = _WorkspacePhase.idle;
      _result = null;
      _done.clear();
      _activeEngines.clear();
      _scores.clear();
      _selectedEvidence = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const InputSettingsDrawer(),
      appBar: AppBar(
        titleSpacing: 16,
        title: const AppIdentityTitle(),
        actions: [
          AppOverflowMenu(
            activeMode: prefs.workspaceMode,
            analysisActive: _isAnalyzing,
            onSettings: compact
                ? () => _scaffoldKey.currentState?.openEndDrawer()
                : () => context.push('/settings'),
            onHistory: () => context.push('/history'),
            onHelp: () => context.push('/help'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
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
                      WorkspaceMode.cosmicFuture => _cosmicFutureLayout(),
                      WorkspaceMode.softEducation => _softEducationLayout(),
                    },
                  ),
                );
              },
            ),
          ),
          const AppCopyrightFooter(),
        ],
      ),
    );
  }

  Widget _commandGrid() {
    final completed = _result != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) return _compactCommandGrid();
        const dividerWidth = 14.0;
        const minPanelWidth = 220.0;
        final available = constraints.maxWidth - dividerWidth * 2 - 20;
        final maxSource = math.max(
          minPanelWidth,
          available - minPanelWidth * 2,
        );
        final sourceWidth = (_commandGridSourceWidth ?? 330).clamp(
          minPanelWidth,
          maxSource,
        );
        final remaining = available - sourceWidth;
        final maxTelemetry = math.max(minPanelWidth, remaining - minPanelWidth);
        final telemetryWidth = (_commandGridTelemetryWidth ?? remaining * 5 / 8)
            .clamp(minPanelWidth, maxTelemetry);
        final findingsWidth = remaining - telemetryWidth;
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: completed ? 360 : constraints.maxHeight - 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: sourceWidth,
                      child: _sourcePanel(compact: true),
                    ),
                    _PanelDragHandle(
                      onDrag: (dx) => setState(() {
                        _commandGridSourceWidth = (sourceWidth + dx).clamp(
                          minPanelWidth,
                          maxSource,
                        );
                      }),
                    ),
                    SizedBox(
                      width: telemetryWidth,
                      child: _telemetryPanel(showTimeline: true),
                    ),
                    _PanelDragHandle(
                      onDrag: (dx) => setState(() {
                        _commandGridTelemetryWidth = (telemetryWidth + dx)
                            .clamp(minPanelWidth, maxTelemetry);
                      }),
                    ),
                    SizedBox(width: findingsWidth, child: _liveFindingsPanel()),
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
    const minSectionHeight = 160.0;
    const maxSectionHeight = 640.0;
    final sourceHeight = (_compactGridSourceHeight ?? 390).clamp(
      minSectionHeight,
      maxSectionHeight,
    );
    final telemetryHeight = (_compactGridTelemetryHeight ?? 300).clamp(
      minSectionHeight,
      maxSectionHeight,
    );
    final findingsHeight = (_compactGridFindingsHeight ?? 230).clamp(
      minSectionHeight,
      maxSectionHeight,
    );
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          SizedBox(height: sourceHeight, child: _sourcePanel(compact: false)),
          _PanelDragHandleVertical(
            onDrag: (dy) => setState(() {
              _compactGridSourceHeight = (sourceHeight + dy).clamp(
                minSectionHeight,
                maxSectionHeight,
              );
            }),
          ),
          SizedBox(
            height: telemetryHeight,
            child: _telemetryPanel(showTimeline: true),
          ),
          _PanelDragHandleVertical(
            onDrag: (dy) => setState(() {
              _compactGridTelemetryHeight = (telemetryHeight + dy).clamp(
                minSectionHeight,
                maxSectionHeight,
              );
            }),
          ),
          SizedBox(height: findingsHeight, child: _liveFindingsPanel()),
          if (_result != null) ...[
            _PanelDragHandleVertical(
              onDrag: (dy) => setState(() {
                _compactGridFindingsHeight = (findingsHeight + dy).clamp(
                  minSectionHeight,
                  maxSectionHeight,
                );
              }),
            ),
            SizedBox(height: 720, child: _reportPanel()),
          ],
        ],
      ),
    );
  }

  Widget _missionTimeline() {
    return Padding(padding: const EdgeInsets.all(10), child: _timelineBody());
  }

  /// 宇宙未來風：純黑背景、青紫霓虹發光懸浮面板，內容與任務時間軸模式相同，
  /// 只是外觀套上 [_WorkspaceVisualTheme.cosmic]。
  Widget _cosmicFutureLayout() {
    return _WorkspaceThemeScope(
      theme: _WorkspaceVisualTheme.cosmic,
      child: Stack(
        children: [
          const Positioned.fill(child: _CosmicBackground()),
          Padding(padding: const EdgeInsets.all(10), child: _timelineBody()),
        ],
      ),
    );
  }

  /// 教育文柔風：深色毛玻璃卡片 + 動態流體漸層背景，內容配置與任務時間軸
  /// 模式相同，只是外觀套上 [_WorkspaceVisualTheme.soft]。
  Widget _softEducationLayout() {
    return _WorkspaceThemeScope(
      theme: _WorkspaceVisualTheme.soft,
      child: Stack(
        children: [
          const Positioned.fill(child: _FluidBackground()),
          Padding(padding: const EdgeInsets.all(10), child: _timelineBody()),
        ],
      ),
    );
  }

  Widget _timelineBody() {
    return Column(
      children: [
        _timelineStrip(),
        const SizedBox(height: 10),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 760;
              if (narrow) {
                const minMain = 160.0;
                const minTelemetry = 160.0;
                final available = constraints.maxHeight - 14;
                final maxMain = math.max(minMain, available - minTelemetry);
                final mainHeight =
                    (_timelineNarrowMainHeight ?? available * 0.65).clamp(
                      minMain,
                      maxMain,
                    );
                final telemetryHeight = available - mainHeight;
                return Column(
                  children: [
                    SizedBox(
                      height: mainHeight,
                      child: _result == null
                          ? _sourcePanel(compact: false)
                          : _reportPanel(),
                    ),
                    _PanelDragHandleVertical(
                      onDrag: (dy) => setState(() {
                        _timelineNarrowMainHeight = (mainHeight + dy).clamp(
                          minMain,
                          maxMain,
                        );
                      }),
                    ),
                    SizedBox(height: telemetryHeight, child: _telemetryPanel()),
                  ],
                );
              }
              const minMain = 300.0;
              const minTelemetry = 220.0;
              final available = constraints.maxWidth - 14;
              final maxMain = math.max(minMain, available - minTelemetry);
              final mainWidth = (_timelineWideMainWidth ?? available * 0.7)
                  .clamp(minMain, maxMain);
              final telemetryWidth = available - mainWidth;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: mainWidth,
                    child: _result == null
                        ? _sourcePanel(compact: false)
                        : _reportPanel(),
                  ),
                  _PanelDragHandle(
                    onDrag: (dx) => setState(() {
                      _timelineWideMainWidth = (mainWidth + dx).clamp(
                        minMain,
                        maxMain,
                      );
                    }),
                  ),
                  SizedBox(width: telemetryWidth, child: _telemetryPanel()),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _evidenceCanvas() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 820) return _compactEvidenceCanvas();

          const minRail = 200.0;
          const minCenter = 320.0;
          const minTelemetry = 220.0;
          final availableW = constraints.maxWidth - 14 * 2;
          final maxRail = math.max(
            minRail,
            availableW - minCenter - minTelemetry,
          );
          final railWidth = (_evidenceRailWidth ?? 240).clamp(minRail, maxRail);
          final remainingW = availableW - railWidth;
          final maxTelemetry = math.max(minTelemetry, remainingW - minCenter);
          final telemetryWidth = (_evidenceTelemetryWidth ?? 290).clamp(
            minTelemetry,
            maxTelemetry,
          );
          final centerWidth = remainingW - telemetryWidth;

          return Column(
            children: [
              _timelineStrip(),
              const SizedBox(height: 10),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(width: railWidth, child: _sourceActionsRail()),
                    _PanelDragHandle(
                      onDrag: (dx) => setState(() {
                        _evidenceRailWidth = (railWidth + dx).clamp(
                          minRail,
                          maxRail,
                        );
                      }),
                    ),
                    SizedBox(
                      width: centerWidth,
                      child: _result == null
                          ? _evidenceDocument()
                          : LayoutBuilder(
                              builder: (context, centerConstraints) {
                                const minDoc = 160.0;
                                const minReport = 160.0;
                                final availableH =
                                    centerConstraints.maxHeight - 14;
                                final maxDoc = math.max(
                                  minDoc,
                                  availableH - minReport,
                                );
                                final docHeight =
                                    (_evidenceDocumentHeight ??
                                            availableH * 0.55)
                                        .clamp(minDoc, maxDoc);
                                final reportHeight = availableH - docHeight;
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: docHeight,
                                      child: _evidenceDocument(),
                                    ),
                                    _PanelDragHandleVertical(
                                      onDrag: (dy) => setState(() {
                                        _evidenceDocumentHeight =
                                            (docHeight + dy).clamp(
                                              minDoc,
                                              maxDoc,
                                            );
                                      }),
                                    ),
                                    SizedBox(
                                      height: reportHeight,
                                      child: _reportPanel(),
                                    ),
                                  ],
                                );
                              },
                            ),
                    ),
                    _PanelDragHandle(
                      onDrag: (dx) => setState(() {
                        _evidenceTelemetryWidth = (telemetryWidth - dx).clamp(
                          minTelemetry,
                          maxTelemetry,
                        );
                      }),
                    ),
                    SizedBox(width: telemetryWidth, child: _telemetryPanel()),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        const minDoc = 160.0;
        const minTelemetry = 160.0;
        const fixedHeaderHeight = 112 + 10 + 96 + 10 + 14; // 時間軸 + 動作列 + 拖曳把手
        final available = math.max(
          minDoc + minTelemetry,
          constraints.maxHeight - fixedHeaderHeight,
        );
        final maxDoc = math.max(minDoc, available - minTelemetry);
        final docHeight = (_compactEvidenceDocumentHeight ?? available - 270)
            .clamp(minDoc, maxDoc);
        final telemetryHeight = available - docHeight;
        return _compactEvidenceCanvasBody(
          l10n: l10n,
          docHeight: docHeight,
          telemetryHeight: telemetryHeight,
          onDrag: (dy) => setState(() {
            _compactEvidenceDocumentHeight = (docHeight + dy).clamp(
              minDoc,
              maxDoc,
            );
          }),
        );
      },
    );
  }

  Widget _compactEvidenceCanvasBody({
    required AppLocalizations l10n,
    required double docHeight,
    required double telemetryHeight,
    required ValueChanged<double> onDrag,
  }) {
    return Column(
      children: [
        _timelineStrip(),
        const SizedBox(height: 10),
        SizedBox(
          height: 96,
          child: _Panel(
            title: l10n.workspaceModeEvidence,
            icon: LucideIcons.checkSquare,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Builder(
              builder: (context) {
                // 同 _sourcePanel：裸 IconButton 會退回淺色系調校的
                // onSurfaceVariant 灰階，在本面板深色背景下對比不足。
                final scheme = Theme.of(context).colorScheme;
                final iconColor = switch (_WorkspaceThemeScope.of(context)) {
                  _WorkspaceVisualTheme.cosmic => _cosmicCyan,
                  _WorkspaceVisualTheme.soft => Colors.white,
                  _WorkspaceVisualTheme.standard => scheme.onSurface,
                };
                return Row(
                  children: [
                    Expanded(
                      child: IconButton.filledTonal(
                        onPressed: _isAnalyzing ? null : _importDocument,
                        icon: Icon(LucideIcons.folderOpen),
                        tooltip: l10n.inputImportButton,
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: _isAnalyzing ? null : _pasteFromClipboard,
                        icon: Icon(LucideIcons.clipboard, color: iconColor),
                        tooltip: l10n.inputPasteButton,
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: _isAnalyzing ? null : _scanImage,
                        icon: Icon(LucideIcons.scanLine, color: iconColor),
                        tooltip: l10n.inputOcrButton,
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        onPressed: _isAnalyzing
                            ? _confirmStopAnalysis
                            : (_result != null
                                  ? _newAnalysis
                                  : _startAnalysis),
                        icon: Icon(
                          _isAnalyzing
                              ? LucideIcons.stopCircle
                              : (_result != null
                                    ? LucideIcons.plus
                                    : LucideIcons.play),
                          color: iconColor,
                        ),
                        tooltip: _isAnalyzing
                            ? l10n.workspaceStopAnalysis
                            : (_result != null
                                  ? l10n.workspaceNewAnalysis
                                  : l10n.inputStartButton),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(height: docHeight, child: _evidenceDocument()),
        _PanelDragHandleVertical(onDrag: onDrag),
        SizedBox(height: telemetryHeight, child: _telemetryPanel()),
      ],
    );
  }

  Widget _sourceActionsRail() {
    final l10n = AppLocalizations.of(context);
    return _Panel(
      title: l10n.workspaceModeEvidence,
      icon: LucideIcons.checkSquare,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton.icon(
            onPressed: _isAnalyzing ? null : _importDocument,
            icon: Icon(LucideIcons.folderOpen),
            label: Text(l10n.inputImportButton),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : _pasteFromClipboard,
            icon: Icon(LucideIcons.clipboard),
            label: Text(l10n.inputPasteButton),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isAnalyzing ? null : _scanImage,
            icon: Icon(LucideIcons.scanLine),
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
          if (_isAnalyzing)
            FilledButton.tonalIcon(
              onPressed: _confirmStopAnalysis,
              icon: Icon(LucideIcons.stopCircle),
              label: Text(l10n.workspaceStopAnalysis),
            )
          else if (_result != null)
            OutlinedButton.icon(
              onPressed: _newAnalysis,
              icon: Icon(LucideIcons.plus),
              label: Text(l10n.workspaceNewAnalysis),
            )
          else
            FilledButton.icon(
              onPressed: _startAnalysis,
              icon: Icon(LucideIcons.play),
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
      icon: LucideIcons.fileText,
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
          Builder(
            builder: (context) {
              // 這三個動作按鈕裸用 IconButton 時會退回 M3 預設的
              // onSurfaceVariant 灰階，是為一般淺色 Material 介面調校的，
              // 在本面板較深的背景（含 cosmic/soft 主題）下對比不足；
              // 依目前視覺主題明確指定顏色，與同面板其他圖示一致。
              final scheme = Theme.of(context).colorScheme;
              final iconColor = switch (_WorkspaceThemeScope.of(context)) {
                _WorkspaceVisualTheme.cosmic => _cosmicCyan,
                _WorkspaceVisualTheme.soft => Colors.white,
                _WorkspaceVisualTheme.standard => scheme.onSurface,
              };
              return Row(
                children: [
                  Text(
                    l10n.inputCharCount(_controller.text.trim().length),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _isAnalyzing ? null : _pasteFromClipboard,
                    icon: Icon(LucideIcons.clipboard, color: iconColor),
                    tooltip: l10n.inputPasteButton,
                  ),
                  IconButton(
                    onPressed: _isAnalyzing ? null : _scanImage,
                    icon: Icon(LucideIcons.scanLine, color: iconColor),
                    tooltip: l10n.inputOcrButton,
                  ),
                  IconButton(
                    onPressed: _isAnalyzing ? null : _importDocument,
                    icon: Icon(LucideIcons.folderOpen, color: iconColor),
                    tooltip: l10n.inputImportButton,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: _isAnalyzing
                ? FilledButton.tonalIcon(
                    onPressed: _confirmStopAnalysis,
                    icon: Icon(LucideIcons.stopCircle),
                    label: Text(l10n.workspaceStopAnalysis),
                  )
                : _result != null
                ? OutlinedButton.icon(
                    onPressed: _newAnalysis,
                    icon: Icon(LucideIcons.plus),
                    label: Text(l10n.workspaceNewAnalysis),
                  )
                : FilledButton.icon(
                    onPressed: _controller.text.trim().isEmpty
                        ? null
                        : _startAnalysis,
                    icon: Icon(LucideIcons.play),
                    label: Text(l10n.inputStartButton),
                  ),
          ),
        ],
      ),
    );
  }

  /// 取得指定引擎角色的詳細說明（權重貢獻 + 判定理由），僅完整結果可用時有值
  EngineGroup? _engineGroupFor(String role, AppLocalizations l10n) {
    final result = _result;
    if (result == null) return null;
    for (final group in EngineGroup.fromScores(
      result.engineScores,
      l10n,
      eslAdjusted: result.eslAdjusted,
      contributionPointsByEngineId: result.roundedEngineContributionPoints,
    )) {
      if (group.role == role) return group;
    }
    return null;
  }

  Widget _telemetryPanel({bool showTimeline = false}) {
    final l10n = AppLocalizations.of(context);
    final labels = _engineLabels(l10n);
    final probability = _result?.aiProbability ?? _runningProbability ?? 0;
    final activeNames = _activeEngines
        .map((role) => labels[role])
        .whereType<String>()
        .toList();
    final waitingTooLong = _isAnalyzing && _secondsSinceProgress >= 20;
    return _Panel(
      title: l10n.workspaceTelemetry,
      icon: LucideIcons.activity,
      trailing: Text(
        _isAnalyzing
            ? '${_done.length}/4 · ${_elapsedSeconds}s'
            : '${(_overallProgress * 100).round()}%',
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 分析完成後一律顯示完整詳細列表（可捲動），避免壓縮版看不到逐模組說明
          final condensed = _result == null && constraints.maxHeight < 310;
          return Column(
            children: [
              Row(
                children: [
                  _ProbabilityGauge(
                    probability: probability,
                    progress: _overallProgress,
                    analyzing: _isAnalyzing,
                    compact: condensed,
                    engineStates: [
                      for (final role in PreferencesService.engineRoles)
                        _done.contains(role)
                            ? 2
                            : _activeEngines.contains(role)
                            ? 1
                            : 0,
                    ],
                  ),
                  SizedBox(width: condensed ? 10 : 16),
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
                        LinearProgressIndicator(
                          value: _isAnalyzing ? null : _overallProgress,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isAnalyzing) ...[
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      waitingTooLong
                          ? LucideIcons.hourglass
                          : LucideIcons.activity,
                      size: 16,
                      color: waitingTooLong
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        waitingTooLong
                            ? l10n.workspaceAnalysisSlow(_secondsSinceProgress)
                            : l10n.workspaceAnalysisActivity(
                                _done.length,
                                4,
                                _elapsedSeconds,
                                activeNames.join('、'),
                              ),
                        maxLines: condensed ? 2 : null,
                        overflow: condensed ? TextOverflow.ellipsis : null,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: condensed ? 6 : 12),
              Expanded(
                child: condensed
                    ? Row(
                        children: [
                          for (final entry in labels.entries)
                            Expanded(
                              child: _EngineTelemetryPulse(
                                role: entry.key,
                                label: entry.value,
                                active: _activeEngines.contains(entry.key),
                                done: _done.contains(entry.key),
                              ),
                            ),
                        ],
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: labels.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final entry = labels.entries.elementAt(index);
                          final group = _engineGroupFor(entry.key, l10n);
                          return _EngineTelemetryRow(
                            role: entry.key,
                            label: entry.value,
                            active: _activeEngines.contains(entry.key),
                            done: _done.contains(entry.key),
                            score: _scores[entry.key]?.aiProbability,
                            relationshipText: group?.relationshipText,
                            reasons: group?.reasons,
                          );
                        },
                      ),
              ),
              if (showTimeline && !condensed) ...[
                const Divider(height: 14),
                _timelineStrip(compact: true),
              ],
            ],
          );
        },
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
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 112,
      child: _Panel(
        title: l10n.workspaceOverallProgress,
        icon: LucideIcons.map,
        trailing: Text(
          l10n.workspaceProgressStatusSummary(
            active + 1,
            labels[active],
            labels.length,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.right,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              for (var i = 0; i < labels.length; i++)
                _StageChip(label: labels[i], index: i, active: active),
            ],
          ),
        ),
      ),
    );
  }

  Widget _liveFindingsPanel() {
    final l10n = AppLocalizations.of(context);
    final evidence = _evidenceRows();
    return _Panel(
      title: l10n.workspaceLiveFindings,
      icon: LucideIcons.target,
      infoTooltip: evidence.isEmpty
          ? null
          : l10n.workspaceSentenceSignalTooltip,
      child: evidence.isEmpty
          ? Center(
              child: Text(
                l10n.workspaceNoEvidence,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          : ListView.separated(
              itemCount: evidence.length,
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
      icon: LucideIcons.fileText,
      infoTooltip: evidence.isEmpty
          ? null
          : l10n.workspaceSentenceSignalTooltip,
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 28),
                      Expanded(
                        child: Text(
                          l10n.workspaceSentenceColumnHeader,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.workspaceSentenceSignalHeader,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
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
    // standard 主題的 _Panel 不會像 cosmic/soft 那樣自動包一層
    // IconTheme 覆蓋 trailing 顏色，裸 IconButton 在此仍會退回對比不足的
    // onSurfaceVariant，因此在此明確依主題指定顏色。
    final scheme = Theme.of(context).colorScheme;
    final trailingIconColor = switch (_WorkspaceThemeScope.of(context)) {
      _WorkspaceVisualTheme.cosmic => _cosmicCyan,
      _WorkspaceVisualTheme.soft => Colors.white,
      _WorkspaceVisualTheme.standard => scheme.onSurface,
    };
    return _Panel(
      title: AppLocalizations.of(context).workspaceAnalysisComplete,
      icon: LucideIcons.barChart,
      trailing: IconButton(
        onPressed: _newAnalysis,
        icon: Icon(LucideIcons.plus, color: trailingIconColor),
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

/// 面板之間的可拖曳分隔線，用於調整相鄰欄寬
class _PanelDragHandle extends StatelessWidget {
  final ValueChanged<double> onDrag;

  const _PanelDragHandle({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) => onDrag(details.delta.dx),
        child: SizedBox(
          width: 14,
          child: Center(
            child: Container(
              width: 3,
              height: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 面板之間的可拖曳分隔線（垂直排列版，用於調整相鄰列高）
class _PanelDragHandleVertical extends StatelessWidget {
  final ValueChanged<double> onDrag;

  const _PanelDragHandleVertical({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
        child: SizedBox(
          height: 14,
          child: Center(
            child: Container(
              height: 3,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 工作台視覺主題：標準（沿用 Material 配色）、宇宙未來風（純黑 + 青紫霓虹發光）、
/// 教育文柔風（深色毛玻璃 + 柔霓虹）。透過 InheritedWidget 往下傳遞，讓
/// [_Panel] 等既有內容元件不必改動呼叫方式即可套用截然不同的外觀。
enum _WorkspaceVisualTheme { standard, cosmic, soft }

class _WorkspaceThemeScope extends InheritedWidget {
  final _WorkspaceVisualTheme theme;

  const _WorkspaceThemeScope({required this.theme, required super.child});

  static _WorkspaceVisualTheme of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_WorkspaceThemeScope>()
            ?.theme ??
        _WorkspaceVisualTheme.standard;
  }

  @override
  bool updateShouldNotify(_WorkspaceThemeScope oldWidget) =>
      theme != oldWidget.theme;
}

const _cosmicCyan = Color(0xFF00F0FF);
const _cosmicMagenta = Color(0xFFFF2FE0);
const _softTeal = Color(0xFF5EEAD4);
const _softViolet = Color(0xFFC084FC);

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;
  final String? infoTooltip;

  const _Panel({
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(12),
    this.infoTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return switch (_WorkspaceThemeScope.of(context)) {
      _WorkspaceVisualTheme.cosmic => _buildCosmic(context),
      _WorkspaceVisualTheme.soft => _buildSoft(context),
      _WorkspaceVisualTheme.standard => _buildStandard(context),
    };
  }

  Widget _buildStandard(BuildContext context) {
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
                  if (infoTooltip != null)
                    Tooltip(
                      message: infoTooltip!,
                      triggerMode: TooltipTriggerMode.tap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          LucideIcons.helpCircle,
                          size: 15,
                          color: scheme.onSurfaceVariant,
                        ),
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

  Widget _buildCosmic(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _cosmicCyan.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: _cosmicCyan.withValues(alpha: 0.22),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: _cosmicMagenta.withValues(alpha: 0.14),
            blurRadius: 28,
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 44,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Icon(icon, size: 17, color: _cosmicCyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            letterSpacing: 1.4,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (infoTooltip != null)
                        Tooltip(
                          message: infoTooltip!,
                          triggerMode: TooltipTriggerMode.tap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              LucideIcons.helpCircle,
                              size: 15,
                              color: _cosmicCyan.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      if (trailing != null)
                        Flexible(
                          child: DefaultTextStyle.merge(
                            style: const TextStyle(color: Colors.white70),
                            child: IconTheme.merge(
                              data: const IconThemeData(color: _cosmicCyan),
                              child: trailing!,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _cosmicCyan.withValues(alpha: 0.6),
                      _cosmicMagenta.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: padding,
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(color: Colors.white),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoft(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: _softTeal.withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: -6,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 46,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _softTeal.withValues(alpha: 0.35),
                              _softViolet.withValues(alpha: 0.35),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(icon, size: 15, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.quicksand(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (infoTooltip != null)
                        Tooltip(
                          message: infoTooltip!,
                          triggerMode: TooltipTriggerMode.tap,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              LucideIcons.helpCircle,
                              size: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      if (trailing != null)
                        Flexible(
                          child: DefaultTextStyle.merge(
                            style: const TextStyle(color: Colors.white70),
                            child: IconTheme.merge(
                              data: const IconThemeData(color: _softTeal),
                              child: trailing!,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Colors.white.withValues(alpha: 0.14)),
              Expanded(
                child: Padding(
                  padding: padding,
                  child: DefaultTextStyle.merge(
                    style: GoogleFonts.quicksand(color: Colors.white),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 宇宙未來風背景：純黑底 + 緩慢漂移的青紫霓虹光暈、透視格線與閃爍星點。
class _CosmicBackground extends StatefulWidget {
  const _CosmicBackground();

  @override
  State<_CosmicBackground> createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<_CosmicBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_CosmicStar> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 48),
    )..repeat();
    final rng = math.Random(7);
    _stars = List.generate(
      90,
      (_) => _CosmicStar(
        dx: rng.nextDouble(),
        dy: rng.nextDouble(),
        radius: rng.nextDouble() * 1.6 + 0.4,
        phase: rng.nextDouble() * math.pi * 2,
        speed: rng.nextDouble() * 0.6 + 0.4,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return CustomPaint(
        painter: _CosmicPainter(t: 0, stars: _stars),
        size: Size.infinite,
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _CosmicPainter(t: _controller.value, stars: _stars),
        size: Size.infinite,
      ),
    );
  }
}

class _CosmicStar {
  final double dx;
  final double dy;
  final double radius;
  final double phase;
  final double speed;

  const _CosmicStar({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
    required this.speed,
  });
}

class _CosmicPainter extends CustomPainter {
  final double t;
  final List<_CosmicStar> stars;

  const _CosmicPainter({required this.t, required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    canvas.drawRect(bounds, Paint()..color = const Color(0xFF020006));

    final angle = t * 2 * math.pi;
    final glow1 = Offset(
      size.width * (0.22 + 0.08 * math.sin(angle)),
      size.height * (0.28 + 0.06 * math.cos(angle)),
    );
    final glow2 = Offset(
      size.width * (0.8 + 0.07 * math.cos(angle * 0.7)),
      size.height * (0.72 + 0.07 * math.sin(angle * 0.7)),
    );
    final glowRadius = size.shortestSide * 0.38;
    canvas.drawCircle(
      glow1,
      glowRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [_cosmicCyan.withValues(alpha: 0.18), Colors.transparent],
        ).createShader(Rect.fromCircle(center: glow1, radius: glowRadius)),
    );
    canvas.drawCircle(
      glow2,
      glowRadius * 0.9,
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                _cosmicMagenta.withValues(alpha: 0.15),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: glow2, radius: glowRadius * 0.9),
            ),
    );

    final gridPaint = Paint()
      ..color = _cosmicCyan.withValues(alpha: 0.05)
      ..strokeWidth = 1;
    const lines = 10;
    for (var i = 0; i <= lines; i++) {
      final y = size.height * (i / lines);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (final star in stars) {
      final twinkle =
          0.35 + 0.65 * (0.5 + 0.5 * math.sin(angle * star.speed + star.phase));
      canvas.drawCircle(
        Offset(size.width * star.dx, size.height * star.dy),
        star.radius,
        Paint()..color = Colors.white.withValues(alpha: twinkle * 0.85),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CosmicPainter oldDelegate) =>
      oldDelegate.t != t;
}

/// 教育文柔風背景：深色底 + 數個緩慢漂移、模糊柔化的漸層光斑，
/// 以 2D 動畫近似「流體動力學」流動質感，搭配前景毛玻璃卡片使用。
class _FluidBackground extends StatefulWidget {
  const _FluidBackground();

  @override
  State<_FluidBackground> createState() => _FluidBackgroundState();
}

class _FluidBackgroundState extends State<_FluidBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 34),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) {
      return CustomPaint(painter: _FluidPainter(t: 0), size: Size.infinite);
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _FluidPainter(t: _controller.value),
        size: Size.infinite,
      ),
    );
  }
}

class _FluidPainter extends CustomPainter {
  final double t;

  const _FluidPainter({required this.t});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF0B0F1A),
    );

    final angle = t * 2 * math.pi;
    final blobs = <(Color, double, double, double, double)>[
      (_softTeal, 0.25, 0.3, 1.0, 0.0),
      (_softViolet, 0.75, 0.25, 0.85, 1.4),
      (const Color(0xFFF472B6), 0.35, 0.75, 0.9, 2.6),
      (_softTeal, 0.72, 0.72, 0.7, 4.1),
    ];
    for (final (color, bx, by, scale, phase) in blobs) {
      final dx = bx + 0.07 * math.sin(angle + phase);
      final dy = by + 0.07 * math.cos(angle * 0.8 + phase);
      final center = Offset(size.width * dx, size.height * dy);
      final radius = size.shortestSide * 0.32 * scale;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color.withValues(alpha: 0.32), color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FluidPainter oldDelegate) => oldDelegate.t != t;
}

class _ProbabilityGauge extends StatelessWidget {
  final double probability;
  final double progress;
  final bool analyzing;
  final bool compact;
  final List<int> engineStates;

  const _ProbabilityGauge({
    required this.probability,
    required this.progress,
    required this.analyzing,
    required this.compact,
    required this.engineStates,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final complete = progress >= 1;
    final color = complete
        ? AppTheme.verdictColor(
            probability,
            brightness: Theme.of(context).brightness,
          )
        : scheme.primary;
    final segmentColors = [
      for (final role in PreferencesService.engineRoles)
        _engineColor(context, role),
    ];
    return SizedBox.square(
      dimension: compact ? 82 : 104,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: progress),
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 420),
        builder: (context, value, _) => Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _SegmentedEngineRingPainter(
                states: engineStates,
                colors: segmentColors,
                pendingColor: scheme.outlineVariant,
              ),
            ),
            if (analyzing)
              Padding(
                padding: const EdgeInsets.all(3),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary.withValues(alpha: 0.7),
                  backgroundColor: Colors.transparent,
                ),
              ),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.1),
                ),
                child: SizedBox.square(
                  dimension: compact ? 50 : 66,
                  child: Center(
                    // 完成前不顯示百分比數字：與最終 AI 機率同樣的粗體樣式容易讓使用者
                    // 誤以為「解析/分析中」階段的工作流程進度就是 AI 機率（曾造成混淆）。
                    // 完成前改以圖示表示狀態，機率數字只在真正判定完成後才出現。
                    child: complete
                        ? Text(
                            '${(probability * 100).round()}%',
                            style:
                                (compact
                                        ? Theme.of(
                                            context,
                                          ).textTheme.titleMedium
                                        : Theme.of(
                                            context,
                                          ).textTheme.titleLarge)
                                    ?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w800,
                                    ),
                          )
                        : Icon(
                            analyzing
                                ? LucideIcons.hourglass
                                : LucideIcons.hourglass,
                            size: compact ? 24 : 30,
                            color: color,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Color _engineColor(BuildContext context, String role) {
  final scheme = Theme.of(context).colorScheme;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return switch (role) {
    'transformer' => scheme.primary,
    'statistical' => dark ? const Color(0xFF58D7D0) : const Color(0xFF087F7A),
    'stylometry' => scheme.tertiary,
    _ => dark ? const Color(0xFFFF9A6C) : const Color(0xFFC45127),
  };
}

IconData _engineIcon(String role) => switch (role) {
  'transformer' => LucideIcons.network,
  'statistical' => LucideIcons.chartLine,
  'stylometry' => LucideIcons.fingerprint,
  _ => LucideIcons.shield,
};

class _SegmentedEngineRingPainter extends CustomPainter {
  final List<int> states;
  final List<Color> colors;
  final Color pendingColor;

  const _SegmentedEngineRingPainter({
    required this.states,
    required this.colors,
    required this.pendingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 0.14;
    final sweep = math.pi / 2 - gap;
    final rect = Offset.zero & size;
    for (var i = 0; i < 4; i++) {
      final state = i < states.length ? states[i] : 0;
      final color = i < colors.length ? colors[i] : pendingColor;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = state == 1 ? 10 : 8
        ..strokeCap = StrokeCap.round
        ..color = switch (state) {
          2 => color,
          1 => color.withValues(alpha: 0.72),
          _ => pendingColor.withValues(alpha: 0.7),
        };
      canvas.drawArc(
        rect.deflate(10),
        -math.pi / 2 + i * math.pi / 2 + gap / 2,
        sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SegmentedEngineRingPainter oldDelegate) =>
      oldDelegate.pendingColor != pendingColor ||
      oldDelegate.states.toString() != states.toString() ||
      oldDelegate.colors.toString() != colors.toString();
}

class _EngineTelemetryPulse extends StatelessWidget {
  final String role;
  final String label;
  final bool active;
  final bool done;

  const _EngineTelemetryPulse({
    required this.role,
    required this.label,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final color = _engineColor(context, role);
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: 34,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (active)
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.12),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(
                        alpha: done || active ? 0.18 : 0.08,
                      ),
                      border: Border.all(
                        color: done || active ? color : scheme.outlineVariant,
                      ),
                    ),
                    child: Icon(_engineIcon(role), size: 17, color: color),
                  ),
                  if (done)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        LucideIcons.checkCircle,
                        size: 13,
                        color: color,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: done || active ? color : scheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EngineTelemetryRow extends StatelessWidget {
  final String role;
  final String label;
  final bool active;
  final bool done;
  final double? score;
  final String? relationshipText;
  final List<String>? reasons;

  const _EngineTelemetryRow({
    required this.role,
    required this.label,
    required this.active,
    required this.done,
    required this.score,
    this.relationshipText,
    this.reasons,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _engineColor(context, role);
    final icon = _engineIcon(role);
    final showDetail =
        done && (relationshipText != null || (reasons?.isNotEmpty ?? false));
    // cosmic/soft 主題面板背景較深，內文若沿用淺色主題的 onSurfaceVariant
    // 會呈現深灰字疊深色底、對比不足；改用半透明白字確保可讀性。
    final isOverlayTheme =
        _WorkspaceThemeScope.of(context) != _WorkspaceVisualTheme.standard;
    final detailColor = isOverlayTheme
        ? Colors.white.withValues(alpha: 0.82)
        : scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 42,
            child: _buildRow(context, scheme, color, icon, isOverlayTheme),
          ),
          if (showDetail)
            Padding(
              padding: const EdgeInsets.only(left: 54, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (relationshipText != null)
                    Text(
                      relationshipText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: detailColor,
                        height: 1.25,
                      ),
                    ),
                  for (final reason in (reasons ?? const []).take(2))
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        reason,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: detailColor,
                          height: 1.25,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    ColorScheme scheme,
    Color color,
    IconData icon,
    bool isOverlayTheme,
  ) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          width: 4,
          height: active ? 42 : 30,
          decoration: BoxDecoration(
            color: done || active ? color : scheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: active ? 0.2 : 0.1),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: active ? null : (done ? 1 : 0),
                  minHeight: 4,
                  color: color,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 46,
          child: done
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(LucideIcons.checkCircle, size: 17, color: color),
                    if (score != null)
                      Text(
                        '${(score! * 100).round()}%',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isOverlayTheme ? Colors.white : scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                )
              : active
              ? Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  ),
                )
              : Icon(
                  LucideIcons.moreHorizontal,
                  color: isOverlayTheme
                      ? Colors.white.withValues(alpha: 0.7)
                      : scheme.onSurfaceVariant,
                ),
        ),
      ],
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
                ? Icon(LucideIcons.check, size: 15, color: scheme.onPrimary)
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

/// 寬螢幕「整體進度」面板使用的左靠步驟膠囊：依內容寬度自動收攏，
/// 避免 5 個步驟被平均撐開成充滿空隙的等寬格。
class _StageChip extends StatelessWidget {
  final String label;
  final int index;
  final int active;

  const _StageChip({
    required this.label,
    required this.index,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final complete = index < active;
    final current = index == active;
    final scheme = Theme.of(context).colorScheme;
    final background = complete || current
        ? scheme.primary
        : scheme.surfaceContainerHighest;
    final foreground = complete || current
        ? scheme.onPrimary
        : scheme.onSurfaceVariant;
    return Semantics(
      selected: current,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: current ? scheme.onSurface : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (complete)
              Icon(LucideIcons.check, size: 13, color: foreground)
            else
              Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(width: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: current ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
