import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/detection/model_catalog_service.dart';
import '../../core/detection/analysis_profile.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/orchestrator.dart';
import '../../core/models/analysis_request.dart';
import '../../core/models/detection_result.dart';
import '../../core/models/input_quality.dart';
import '../../core/services/writing_session.dart';
import '../../core/services/analysis_readiness.dart';
import '../../core/utils/language_id.dart';
import '../../core/services/document_importer.dart';
import '../../core/services/calibration_service.dart';
import '../../core/services/document_provenance.dart';
import '../../core/services/history_repository.dart';
import '../../core/services/claim_audit.dart';
import '../../core/services/integrated_assessment.dart';
import '../../core/services/ocr_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/publication_evidence.dart';
import '../../core/utils/ocr_post_processor.dart';
import '../../core/utils/text_stats.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/app_copyright_footer.dart';
import '../../shared/widgets/professional_report_header.dart' show EngineGroup;
import '../../shared/widgets/workspace_navigation.dart';
import '../input/input_screen.dart' show InputSettingsDrawer;
import '../onboarding/model_prompt.dart';
import '../report/report_screen.dart';
import 'telemetry_summary.dart';

enum _WorkspacePhase { idle, ready, analyzing, complete }

@visibleForTesting
bool usesSingleColumnWorkspace(BoxConstraints constraints) =>
    constraints.maxWidth < 840 ||
    (constraints.maxHeight < 620 && constraints.maxWidth < 1200);

@visibleForTesting
double evidenceIndexBadgeWidthFor(int index) {
  final digits = math.max(1, index).toString().length;
  return digits <= 2 ? 26.0 : 34.0 + (digits - 3) * 8.0;
}

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
  final _engineProgress = <String, double>{};

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

  /// 使用者直接輸入時的寫作過程紀錄，隨分析請求一併帶入
  WritingSession _writingSession = WritingSession.empty;
  final WritingSessionRecorder _writingRecorder = WritingSessionRecorder();
  DocumentProvenance _sourceProvenance = DocumentProvenance.none;
  InputQualityEvidence _inputQuality = InputQualityEvidence.directText;
  _WorkspacePhase _phase = _WorkspacePhase.idle;
  DetectionResult? _result;
  PublicationEvidence _publicationEvidence = PublicationEvidence.none;
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
      _writingSession = request.writingSession;
      _sourceProvenance = request.provenance;
      _inputQuality = request.inputQuality;
      _writingRecorder.resume(
        currentLength: request.text.length,
        session: request.writingSession,
      );
      _phase = request.text.trim().isEmpty
          ? _WorkspacePhase.idle
          : _WorkspacePhase.ready;
      if (widget.autoStart && request.text.trim().isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startAnalysis();
        });
      }
    }
    final manager = context.read<ModelManager>();
    final catalogService = context.read<ModelCatalogService>();
    manager.checkForUpdates(catalogService);
    // 同上：校準修正直接同步，不要求重新下載。
    manager.syncCalibrationFromCatalog(catalogService);
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
    _WorkspacePhase.analyzing => 0.22 + (_meanEngineProgress * 0.68),
    _WorkspacePhase.complete => 1,
  };

  double get _meanEngineProgress {
    var total = 0.0;
    for (final role in PreferencesService.engineRoles) {
      total += _done.contains(role)
          ? 1
          : (_engineProgress[role] ?? (_activeEngines.contains(role) ? 0 : 0));
    }
    return total / PreferencesService.engineRoles.length;
  }

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
      _publicationEvidence = PublicationEvidence.none;
      _done.clear();
      _activeEngines.clear();
      _scores.clear();
      _engineProgress.clear();
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
      _publicationEvidence = PublicationEvidence.none;
      _done.clear();
      _activeEngines.clear();
      _scores.clear();
      _engineProgress.clear();
      _selectedEvidence = 0;
    });
  }

  void _recordWorkspaceEdit(String value) {
    _writingRecorder.record(value.length);
    _writingSession = _writingRecorder.session;
    if (_sourceFileName.isNotEmpty) _sourceFileName = '';
    // 一旦在匯入後修改文字，檔案內的中繼資料已不再精確描述目前內容。
    _sourceProvenance = DocumentProvenance.none;
    _inputQuality = InputQualityEvidence.directText;
    _markInputReady();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text == null || data!.text!.isEmpty) return;
    _controller.text = data.text!;
    _sourceFileName = '';
    _sourceProvenance = DocumentProvenance.none;
    _inputQuality = InputQualityEvidence.clipboard;
    _writingRecorder.reset();
    _writingRecorder.record(data.text!.length);
    _writingSession = _writingRecorder.session;
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
      _showMessage(
        OcrService.lastFailure?.localize(l10n) ?? l10n.inputOcrNoText,
      );
      return;
    }
    final text = OcrPostProcessor.clean(rawText);
    _controller.text = text;
    _sourceFileName = '';
    _sourceProvenance = DocumentProvenance.none;
    _inputQuality = InputQualityEvidence(
      method: InputAcquisitionMethod.ocr,
      extractionQuality: DocumentImporter.pdfTextQuality(text) * 0.85,
      limitations: const ['ocr_transcription'],
    );
    _writingRecorder.reset(initialLength: text.length);
    _writingSession = WritingSession.empty;
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
        PdfImportIssue.legacyDocUnreadable => l10n.inputDocLegacyUnreadable(
          doc.fileName,
        ),
        PdfImportIssue.none => l10n.inputImportNoText(doc.fileName),
      };
      _showMessage(message);
      return;
    }
    _controller.text = doc.text;
    _sourceFileName = doc.fileName;
    _sourceProvenance = doc.provenance;
    _inputQuality = doc.inputQuality;
    _writingRecorder.reset(initialLength: doc.text.length);
    _writingSession = WritingSession.empty;
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
    final calibration = context.read<CalibrationService>();
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
    if (detectLanguage(text).code == 'zh' &&
        !manager.isVariantInstalled('transformer', modernChineseDetectorId)) {
      if (!mounted) return;
      final choice = await showModernChineseModelPrompt(context);
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
      _publicationEvidence = PublicationEvidence.none;
      _done.clear();
      _activeEngines.clear();
      _scores.clear();
      _engineProgress.clear();
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
        provenance: _sourceProvenance,
        writingSession: _writingSession,
        inputQuality: _inputQuality,
        calibration: calibration,
        eslCorrectionEnabled: prefs.eslCorrectionEnabled,
        prefs: prefs,
        l10n: l10n,
        onEngineStarted: (id) {
          if (mounted && run == _analysisRun) {
            final role = _engineRole(id);
            setState(() {
              _activeEngines.add(role);
              _engineProgress[role] = 0;
            });
          }
        },
        onEngineProgress: (id, progress) {
          if (mounted && run == _analysisRun) {
            final role = _engineRole(id);
            setState(() {
              _engineProgress[role] = progress.clamp(0.0, 1.0);
              _lastProgressAt = DateTime.now();
            });
          }
        },
        onEngineDone: (id) {
          if (mounted && run == _analysisRun) {
            final role = _engineRole(id);
            setState(() {
              _done.add(role);
              _activeEngines.remove(role);
              _engineProgress[role] = 1;
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

      // 背景自動蒐集校準樣本。標籤依據是**文件編輯紀錄**（獨立於文字分類器），
      // 而非本次的判定結果——用判定結果自我標註會造成循環論證，讓偵測器
      // 永遠無法發現自己的偏差。無獨立依據時只收為描述性樣本，不進虛無分布。
      final canCalibrate =
          result.wordCount >= DetectionResult.minWords &&
          result.analyzableSentenceCount >=
              DetectionResult.minAnalyzableSentences &&
          result.effectiveAvailableEngineCount >= 2;
      if (calibration.autoCollectEnabled && canCalibrate) {
        await calibration.autoCollect(
          score: result.aiProbability,
          provenanceIndicatesHuman: result.provenance.indicatesHumanAuthorship,
          // 語言必須在收樣當下記下：原文預設不保存，事後無從補算。
          // 不同語言的分數分布不同，混在一起會讓共形預測的 α 失去意義。
          language: detectLanguage(result.inputText).code,
          engineScores: {
            for (final e in result.engineScores)
              if (e.available) e.engineId: e.aiProbability,
          },
          text: result.inputText,
          label: result.sourceFileName,
          analysisSignature: result.calibration.analysisSignature,
          domain: result.calibration.domain,
          lengthBucket: result.calibration.lengthBucket,
        );
      }
      if (!mounted) return;

      setState(() {
        _result = result;
        _phase = _WorkspacePhase.complete;
        _done.addAll(PreferencesService.engineRoles);
        _activeEngines.clear();
        for (final role in PreferencesService.engineRoles) {
          _engineProgress[role] = 1;
        }
      });
    } catch (_) {
      if (!mounted || run != _analysisRun) return;
      setState(() {
        _phase = _WorkspacePhase.ready;
        _activeEngines.clear();
        _engineProgress.clear();
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
    _sourceProvenance = DocumentProvenance.none;
    _inputQuality = InputQualityEvidence.directText;
    _writingRecorder.reset();
    _writingSession = WritingSession.empty;
    setState(() {
      _phase = _WorkspacePhase.idle;
      _result = null;
      _publicationEvidence = PublicationEvidence.none;
      _done.clear();
      _activeEngines.clear();
      _scores.clear();
      _engineProgress.clear();
      _selectedEvidence = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    final viewport = MediaQuery.sizeOf(context);
    final compact =
        viewport.width < 840 ||
        (viewport.height < 700 && viewport.width < 1200);
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
                // 手機橫向的 CSS 寬度常達 844–915px；只看寬度會誤切成桌面
                // 分割面板，將遙測與來源卡壓進固定高度。中型直向裝置與低高度
                // 橫向裝置都改走單一外層捲動，確保每張卡可完整檢視。
                if (usesSingleColumnWorkspace(constraints)) {
                  return _mobileWorkspace();
                }
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
          ),
          if (!compact) const AppCopyrightFooter(),
        ],
      ),
    );
  }

  Widget _mobileWorkspace() {
    return SafeArea(
      top: false,
      child: _result != null
          ? ListView(
              key: const ValueKey('mobile-completed-workspace-flow'),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              children: [
                _mobileProgressPanel(),
                const SizedBox(height: 8),
                SizedBox(height: 430, child: _telemetryPanel()),
                const SizedBox(height: 8),
                SizedBox(height: 760, child: _reportPanel()),
                const SizedBox(height: 8),
                SizedBox(height: 280, child: _liveFindingsPanel()),
                const SizedBox(height: 8),
                SizedBox(
                  height: 220,
                  child: _sourcePreviewPanel(compact: true),
                ),
                const AppCopyrightFooter(),
              ],
            )
          : ListView(
              key: const ValueKey('mobile-workspace-flow'),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
              children: [
                _mobileSourcePanel(),
                const SizedBox(height: 8),
                _mobileProgressPanel(),
                const SizedBox(height: 8),
                _mobileTelemetryPanel(),
                if (_evidenceRows().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _mobileEvidencePanel(),
                ],
                const AppCopyrightFooter(),
              ],
            ),
    );
  }

  Widget _mobileProgressPanel() {
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
    return _Panel(
      title: l10n.workspaceOverallProgress,
      icon: LucideIcons.map,
      expandBody: false,
      trailing: Text(
        '${active + 1}/${labels.length}',
        style: Theme.of(context).textTheme.labelMedium,
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Divider(
                      color: i <= active
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      thickness: 2,
                    ),
                  ),
                _MobileStageDot(index: i, active: active),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            labels[active],
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _mobileSourcePanel() {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final shortViewport = MediaQuery.sizeOf(context).height < 700;
    return _Panel(
      title: l10n.workspaceDocument,
      icon: LucideIcons.fileText,
      expandBody: false,
      trailing: _sourceFileName.isEmpty
          ? null
          : ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                _sourceFileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            readOnly: _isAnalyzing,
            minLines: shortViewport ? 4 : 8,
            maxLines: shortViewport ? 8 : 14,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(color: _workspacePrimaryText(context)),
            decoration: InputDecoration(
              hintText: l10n.inputHint,
              hintStyle: TextStyle(color: _workspaceTertiaryText(context)),
              contentPadding: const EdgeInsets.all(12),
            ),
            onChanged: _recordWorkspaceEdit,
          ),
          const SizedBox(height: 8),
          Row(
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
                  icon: Icon(LucideIcons.clipboard, color: scheme.onSurface),
                  tooltip: l10n.inputPasteButton,
                ),
              ),
              Expanded(
                child: IconButton(
                  onPressed: _isAnalyzing ? null : _scanImage,
                  icon: Icon(LucideIcons.scanLine, color: scheme.onSurface),
                  tooltip: l10n.inputOcrButton,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                l10n.inputCharCount(_controller.text.trim().length),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Spacer(),
              if (_controller.text.trim().isNotEmpty)
                Flexible(child: _analysisReadinessLine()),
            ],
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _isAnalyzing
                ? _confirmStopAnalysis
                : (_controller.text.trim().isEmpty ? null : _startAnalysis),
            icon: Icon(
              _isAnalyzing ? LucideIcons.stopCircle : LucideIcons.play,
            ),
            label: Text(
              _isAnalyzing ? l10n.workspaceStopAnalysis : l10n.inputStartButton,
            ),
          ),
        ],
      ),
    );
  }

  Widget _mobileTelemetryPanel() {
    final l10n = AppLocalizations.of(context);
    final labels = _engineLabels(l10n);
    final probability = _runningProbability ?? 0;
    return _Panel(
      title: l10n.workspaceTelemetry,
      icon: LucideIcons.activity,
      expandBody: false,
      trailing: Text(
        _isAnalyzing
            ? '${_done.length}/4 · ${_elapsedSeconds}s'
            : '${(_overallProgress * 100).round()}%',
      ),
      child: Column(
        children: [
          Row(
            children: [
              _ProbabilityGauge(
                probability: probability,
                progress: _overallProgress,
                analyzing: _isAnalyzing,
                compact: true,
                engineStates: [
                  for (final role in PreferencesService.engineRoles)
                    _done.contains(role)
                        ? 2
                        : _activeEngines.contains(role)
                        ? 1
                        : 0,
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isAnalyzing
                          ? l10n.workspaceAnalyzing
                          : l10n.workspaceStageParse,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _overallProgress,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0)
              Divider(height: 1, color: _workspaceDividerColor(context)),
            _EngineTelemetryRow(
              role: labels.keys.elementAt(i),
              label: labels.values.elementAt(i),
              active: _activeEngines.contains(labels.keys.elementAt(i)),
              done: _done.contains(labels.keys.elementAt(i)),
              score: _scores[labels.keys.elementAt(i)]?.aiProbability,
              progress: _engineProgress[labels.keys.elementAt(i)] ?? 0,
            ),
          ],
        ],
      ),
    );
  }

  Widget _mobileEvidencePanel() {
    final l10n = AppLocalizations.of(context);
    final evidence = _evidenceRows();
    return _Panel(
      title: l10n.workspaceLiveFindings,
      icon: LucideIcons.target,
      expandBody: false,
      infoTooltip: l10n.workspaceSentenceSignalTooltip,
      child: SelectionArea(
        child: Column(
          children: [
            for (var i = 0; i < evidence.length; i++) ...[
              if (i > 0)
                Divider(height: 1, color: _workspaceDividerColor(context)),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: _EvidenceIndexBadge(
                  index: i + 1,
                  probability: evidence[i].$2,
                ),
                title: Text(evidence[i].$1),
                trailing: Text(
                  _sentenceSignalLabel(evidence[i].$2, evidence[i].$3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _workspaceCommandHeader({required bool compact}) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final evidenceCount = _evidenceRows().length;
    final phaseLabel = switch (_phase) {
      _WorkspacePhase.idle => l10n.workspaceWaiting,
      _WorkspacePhase.ready => l10n.workspaceStageParse,
      _WorkspacePhase.analyzing => l10n.workspaceAnalyzing,
      _WorkspacePhase.complete => l10n.workspaceAnalysisComplete,
    };
    final canAnalyze = _controller.text.trim().isNotEmpty && !_isAnalyzing;
    final actionTooltip = _isAnalyzing
        ? l10n.workspaceStopAnalysis
        : (_result != null ? l10n.workspaceNewAnalysis : l10n.inputStartButton);
    final actionButton = IconButton.filled(
      onPressed: _isAnalyzing
          ? _confirmStopAnalysis
          : (canAnalyze
                ? _startAnalysis
                : (_result != null ? _newAnalysis : null)),
      icon: Icon(
        _isAnalyzing
            ? LucideIcons.stopCircle
            : (_result != null ? LucideIcons.plus : LucideIcons.play),
      ),
      tooltip: actionTooltip,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, compact ? 10 : 12, 12, 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tight = compact || constraints.maxWidth < 760;
            final metrics = [
              _HeaderMetric(
                icon: LucideIcons.activity,
                label: l10n.workspaceOverallProgress,
                value: phaseLabel,
                accent: scheme.primary,
              ),
              _HeaderMetric(
                icon: LucideIcons.fileText,
                label: l10n.workspaceDocument,
                value: l10n.inputCharCount(_controller.text.trim().length),
              ),
              _HeaderMetric(
                icon: LucideIcons.target,
                label: l10n.workspaceLiveFindings,
                value: '$evidenceCount',
              ),
            ];
            final actions = Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: tight ? WrapAlignment.start : WrapAlignment.end,
              children: [
                IconButton.filledTonal(
                  onPressed: _isAnalyzing ? null : _importDocument,
                  icon: Icon(LucideIcons.folderOpen),
                  tooltip: l10n.inputImportButton,
                ),
                IconButton(
                  onPressed: _isAnalyzing ? null : _pasteFromClipboard,
                  icon: Icon(LucideIcons.clipboard),
                  tooltip: l10n.inputPasteButton,
                ),
                IconButton(
                  onPressed: _isAnalyzing ? null : _scanImage,
                  icon: Icon(LucideIcons.scanLine),
                  tooltip: l10n.inputOcrButton,
                ),
                actionButton,
              ],
            );

            if (tight) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(spacing: 8, runSpacing: 8, children: metrics),
                  const SizedBox(height: 8),
                  actions,
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Wrap(spacing: 8, runSpacing: 8, children: metrics),
                ),
                const SizedBox(width: 12),
                actions,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _commandGrid() {
    final completed = _result != null;
    if (completed) {
      return _completedWorkspace(
        modeKey: 'completed-command-grid',
        includeTimeline: false,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 980) return _compactCommandGrid();
        const dividerWidth = 14.0;
        const minPanelWidth = 220.0;
        final headerHeight = _result == null ? 104.0 : 84.0;
        final available = constraints.maxWidth - dividerWidth * 2 - 20;
        final maxSource = math.max(
          minPanelWidth,
          available - minPanelWidth * 2,
        );
        final sourceWidth = (_commandGridSourceWidth ?? 440).clamp(
          minPanelWidth,
          maxSource,
        );
        final remaining = available - sourceWidth;
        final maxTelemetry = math.max(minPanelWidth, remaining - minPanelWidth);
        final telemetryWidth = (_commandGridTelemetryWidth ?? 380).clamp(
          minPanelWidth,
          maxTelemetry,
        );
        final findingsWidth = remaining - telemetryWidth;
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: headerHeight,
                child: _workspaceCommandHeader(compact: false),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: completed
                    ? math.min(360, constraints.maxHeight - headerHeight - 40)
                    : constraints.maxHeight - headerHeight - 30,
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
    if (_result != null) {
      return _completedWorkspace(
        modeKey: 'completed-command-grid-compact',
        includeTimeline: false,
      );
    }
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
          _workspaceCommandHeader(compact: true),
          const SizedBox(height: 10),
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
    if (_result != null) {
      return _completedWorkspace(
        modeKey: 'completed-mission-timeline',
        includeTimeline: true,
      );
    }
    return Padding(padding: const EdgeInsets.all(10), child: _timelineBody());
  }

  Widget _timelineBody() {
    return Column(
      children: [
        _workspaceCommandHeader(compact: false),
        const SizedBox(height: 10),
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
    if (_result != null) {
      return _completedWorkspace(
        modeKey: 'completed-evidence-canvas',
        includeTimeline: true,
        evidenceReferenceRail: true,
      );
    }
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
              _workspaceCommandHeader(compact: false),
              const SizedBox(height: 10),
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

  Widget _completedWorkspace({
    required String modeKey,
    required bool includeTimeline,
    bool evidenceReferenceRail = false,
  }) {
    return KeyedSubtree(
      key: ValueKey(modeKey),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 980;
            final headerHeight = compact ? 112.0 : 84.0;
            if (compact || constraints.maxHeight < 720) {
              return ListView(
                key: ValueKey('$modeKey-flow'),
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: _workspaceCommandHeader(compact: true),
                  ),
                  if (includeTimeline) ...[
                    const SizedBox(height: 10),
                    _timelineStrip(),
                  ],
                  const SizedBox(height: 10),
                  SizedBox(height: 380, child: _telemetryPanel()),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: math.max(700.0, constraints.maxHeight * 0.9),
                    child: _reportPanel(),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(height: 280, child: _liveFindingsPanel()),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 220,
                    child: _sourcePreviewPanel(compact: true),
                  ),
                ],
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: headerHeight,
                  child: _workspaceCommandHeader(compact: false),
                ),
                if (includeTimeline) ...[
                  const SizedBox(height: 10),
                  _timelineStrip(),
                ],
                const SizedBox(height: 10),
                Expanded(
                  child: evidenceReferenceRail
                      ? _completedEvidenceBody(constraints)
                      : _completedReportTelemetryBody(constraints),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _completedReportTelemetryBody(BoxConstraints constraints) {
    final sidebarWidth = constraints.maxWidth >= 1500 ? 480.0 : 420.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 7, child: _reportPanel()),
        const SizedBox(width: 10),
        SizedBox(
          width: sidebarWidth
              .clamp(360.0, constraints.maxWidth * 0.36)
              .toDouble(),
          child: Column(
            children: [
              Expanded(flex: 5, child: _telemetryPanel()),
              const SizedBox(height: 10),
              Expanded(flex: 3, child: _liveFindingsPanel()),
              const SizedBox(height: 10),
              SizedBox(height: 190, child: _sourcePreviewPanel(compact: true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _completedEvidenceBody(BoxConstraints constraints) {
    final railWidth = constraints.maxWidth >= 1500 ? 300.0 : 260.0;
    final telemetryWidth = constraints.maxWidth >= 1500 ? 420.0 : 360.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: railWidth.clamp(220.0, constraints.maxWidth * 0.24).toDouble(),
          child: Column(
            children: [
              Expanded(child: _liveFindingsPanel()),
              const SizedBox(height: 10),
              SizedBox(height: 210, child: _sourcePreviewPanel(compact: true)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(flex: 6, child: _reportPanel()),
        const SizedBox(width: 10),
        SizedBox(
          width: telemetryWidth
              .clamp(320.0, constraints.maxWidth * 0.3)
              .toDouble(),
          child: _telemetryPanel(),
        ),
      ],
    );
  }

  Widget _compactEvidenceCanvas() {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const minDoc = 160.0;
        const minTelemetry = 160.0;
        const fixedHeaderHeight =
            96 + 10 + 112 + 10 + 96 + 10 + 14; // 指揮列 + 時間軸 + 動作列 + 拖曳把手
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
        _workspaceCommandHeader(compact: true),
        const SizedBox(height: 10),
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
                final iconColor = Theme.of(context).colorScheme.onSurface;
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
                            : (_result != null ? _newAnalysis : _startAnalysis),
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
          Divider(height: 28, color: _workspaceDividerColor(context)),
          Text(
            _sourceFileName.isEmpty ? l10n.workspaceWaiting : _sourceFileName,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          _analysisReadinessLine(),
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
              style: TextStyle(color: _workspacePrimaryText(context)),
              decoration: InputDecoration(
                hintText: l10n.inputHint,
                hintStyle: TextStyle(color: _workspaceTertiaryText(context)),
                contentPadding: const EdgeInsets.all(12),
              ),
              onChanged: _recordWorkspaceEdit,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final iconColor = Theme.of(context).colorScheme.onSurface;
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
          if (_controller.text.trim().isNotEmpty) ...[
            _analysisReadinessLine(),
            const SizedBox(height: 6),
          ],
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

  Widget _sourcePreviewPanel({required bool compact}) {
    final l10n = AppLocalizations.of(context);
    return _Panel(
      key: const ValueKey('workspace-source-preview-panel'),
      title: l10n.workspaceDocument,
      icon: LucideIcons.fileText,
      trailing: _sourceFileName.isEmpty
          ? null
          : Tooltip(
              message: _sourceFileName,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: compact ? 150 : 220),
                child: Text(
                  _sourceFileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              readOnly: true,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: TextStyle(color: _workspacePrimaryText(context)),
              decoration: InputDecoration(
                hintText: l10n.inputHint,
                hintStyle: TextStyle(color: _workspaceTertiaryText(context)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.inputCharCount(_controller.text.trim().length),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _workspaceSecondaryText(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisReadinessLine() {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesService>();
    final manager = context.watch<ModelManager>();
    final calibration = context.watch<CalibrationService>();
    final profile = AnalysisProfile.fromText(_controller.text);
    final matchingSamples = calibration.potentialSampleCountFor(
      language: profile.language,
      domain: profile.domain.name,
      lengthBucket: CalibrationService.lengthBucketFor(profile.wordCount),
    );
    final enabled = PreferencesService.engineRoles
        .where(prefs.isEngineEnabled)
        .length;
    final readiness = AnalysisReadiness.assess(
      text: _controller.text,
      inputQuality: _inputQuality,
      coreModelInstalled: manager.isInstalled('transformer'),
      enabledEngineCount: enabled,
      matchingBaselineSamples: matchingSamples,
      requiredBaselineSamples: calibration.requiredSamples,
    );
    final level = switch (readiness.ceiling) {
      ReadinessLevel.low => l10n.integratedConfidenceLow,
      ReadinessLevel.moderate => l10n.integratedConfidenceModerate,
      ReadinessLevel.high => l10n.integratedConfidenceHigh,
    };
    final limitation = readiness.limitations.isEmpty
        ? null
        : switch (readiness.limitations.first) {
            ReadinessLimitation.shortText => l10n.analysisReadinessShortText,
            ReadinessLimitation.fewSentences =>
              l10n.analysisReadinessFewSentences,
            ReadinessLimitation.coreModelMissing =>
              l10n.analysisReadinessCoreModel,
            ReadinessLimitation.tooFewEngines =>
              l10n.analysisReadinessFewEngines,
            ReadinessLimitation.lowExtractionQuality =>
              l10n.analysisReadinessExtraction,
            ReadinessLimitation.localBaselineMissing =>
              l10n.analysisReadinessBaseline,
          };
    final color = switch (readiness.ceiling) {
      ReadinessLevel.low => Theme.of(context).colorScheme.error,
      ReadinessLevel.moderate => Theme.of(context).colorScheme.tertiary,
      ReadinessLevel.high => Theme.of(context).colorScheme.primary,
    };
    return Row(
      children: [
        Icon(LucideIcons.gauge, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '${l10n.analysisReadinessLabel(level)}'
            '${limitation == null ? '' : ' · $limitation'}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
    final completedAssessment = _result == null
        ? null
        : IntegratedAssessment.assess(
            _result!,
            claims: ClaimAudit.analyze(_result!.inputText),
            publication: _publicationEvidence,
          );
    final probability =
        completedAssessment?.aiLikelihood ?? _runningProbability ?? 0;
    final activeNames = _activeEngines
        .map((role) => labels[role])
        .whereType<String>()
        .toList();
    final waitingTooLong = _isAnalyzing && _secondsSinceProgress >= 20;
    return _Panel(
      key: const ValueKey('workspace-telemetry-panel'),
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
                          value: _overallProgress,
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
                          color: _workspaceSecondaryText(context),
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
                                progress: _engineProgress[entry.key] ?? 0,
                              ),
                            ),
                        ],
                      )
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          if (!_isAnalyzing)
                            Builder(
                              builder: (context) {
                                final summary = buildTelemetrySummary(
                                  _result,
                                  l10n,
                                  publication: _publicationEvidence,
                                );
                                if (summary.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return _TelemetrySummaryCard(
                                  title: l10n.telemetrySummaryTitle,
                                  lines: summary,
                                );
                              },
                            ),
                          for (final entry in labels.entries) ...[
                            Divider(
                              height: 1,
                              color: _workspaceDividerColor(context),
                            ),
                            Builder(
                              builder: (context) {
                                final group = _engineGroupFor(entry.key, l10n);
                                final liveScore = _scores[entry.key];
                                final displayedScore = group != null
                                    ? group.hasDirectionalSignal
                                          ? group.probability
                                          : null
                                    : liveScore?.hasEvidence == true
                                    ? liveScore?.aiProbability
                                    : null;
                                return _EngineTelemetryRow(
                                  role: entry.key,
                                  label: entry.value,
                                  active: _activeEngines.contains(entry.key),
                                  done: _done.contains(entry.key),
                                  score: displayedScore,
                                  progress: _engineProgress[entry.key] ?? 0,
                                  relationshipText: group?.relationshipText,
                                  reasons: group?.reasons,
                                  modules: group?.modules,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
              ),
              if (showTimeline && !condensed) ...[
                Divider(height: 14, color: _workspaceDividerColor(context)),
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
                  : _workspaceDividerColor(context),
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _workspaceSecondaryText(context),
          ),
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
      key: const ValueKey('workspace-live-findings-panel'),
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
              key: const ValueKey('workspace-live-findings-list'),
              itemCount: evidence.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: _workspaceDividerColor(context)),
              itemBuilder: (context, index) {
                final item = evidence[index];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: _EvidenceIndexBadge(
                    index: index + 1,
                    probability: item.$2,
                  ),
                  title: Text(item.$1),
                  trailing: Text(_sentenceSignalLabel(item.$2, item.$3)),
                );
              },
            ),
    );
  }

  /// 第三個欄位：這句的數值是否真的由神經模型支撐。為 false 時介面顯示棄權，
  /// 不顯示百分比——沒有模型投票時的逐句數值只是文件級分數的估計，把它當成
  /// 「模型判定這句 1% 像 AI」會直接誤導讀者。
  List<(String, double, bool)> _evidenceRows() {
    if (_result != null) {
      return [
        for (final sentence in _result!.sentences)
          (sentence.text, sentence.aiProbability, sentence.modelBacked),
      ];
    }
    final text = PreprocessedText.from(_controller.text);
    if (text.sentences.isEmpty || _scores.isEmpty) return const [];
    final hasNeural = _scores.values.any(
      (score) => score.available && (score.sentenceScores?.isNotEmpty ?? false),
    );
    return [
      for (var i = 0; i < text.sentences.length; i++)
        (text.sentences[i], _runningSentenceScore(i), hasNeural),
    ];
  }

  /// 逐句訊號的顯示字串。棄權以破折號呈現，與報告其他地方的棄權標示一致。
  static String _sentenceSignalLabel(double probability, bool modelBacked) =>
      modelBacked ? '${(probability * 100).round()}%' : '—';

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
              style: TextStyle(color: _workspacePrimaryText(context)),
              decoration: InputDecoration(
                hintText: l10n.inputHint,
                hintStyle: TextStyle(color: _workspaceTertiaryText(context)),
              ),
              onChanged: _recordWorkspaceEdit,
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
                                color: _workspaceTertiaryText(context),
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.workspaceSentenceSignalHeader,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: _workspaceTertiaryText(context),
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
                                Text(_sentenceSignalLabel(item.$2, item.$3)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (evidence.isNotEmpty) ...[
                  Divider(height: 14, color: _workspaceDividerColor(context)),
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
      key: const ValueKey('workspace-report-panel'),
      title: AppLocalizations.of(context).workspaceAnalysisComplete,
      icon: LucideIcons.barChart,
      padding: EdgeInsets.zero,
      child: ReportScreen(
        key: ValueKey(result.id),
        result: result,
        embedded: true,
        onPublicationEvidenceChanged: (evidence) {
          if (!mounted || evidence == _publicationEvidence) return;
          setState(() => _publicationEvidence = evidence);
        },
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

class _HeaderMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? accent;

  const _HeaderMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = accent ?? scheme.onSurfaceVariant;
    final labelColor = scheme.onSurfaceVariant;
    final valueColor = scheme.onSurface;
    final fillColor = scheme.surfaceContainerHighest.withValues(alpha: 0.48);
    final borderColor = scheme.outlineVariant;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 132, maxWidth: 220),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$label:',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: labelColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: valueColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

Color _workspacePrimaryText(BuildContext context) =>
    Theme.of(context).colorScheme.onSurface;

Color _workspaceSecondaryText(BuildContext context) =>
    Theme.of(context).colorScheme.onSurfaceVariant;

Color _workspaceTertiaryText(BuildContext context) =>
    Theme.of(context).colorScheme.onSurfaceVariant;

Color _workspaceDividerColor(BuildContext context) =>
    Theme.of(context).dividerColor;

class _Panel extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;
  final String? infoTooltip;
  final bool expandBody;

  const _Panel({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(12),
    this.infoTooltip,
    this.expandBody = true,
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
                  // 不可包 Flexible：標題已是 Expanded，兩者都吃彈性空間會把
                  // 剩餘寬度五五對分，trailing 因此停在面板中央而非靠右。
                  ?trailing,
                ],
              ),
            ),
          ),
          Divider(height: 1, color: scheme.outlineVariant),
          if (expandBody)
            Expanded(
              child: Padding(padding: padding, child: child),
            )
          else
            Padding(padding: padding, child: child),
        ],
      ),
    );
  }
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
    final l10n = AppLocalizations.of(context);
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
                    // 完成前不顯示指數數字：與最終 AI 證據指數同樣的粗體樣式容易讓使用者
                    // 誤以為「解析/分析中」階段的工作流程進度就是判讀結果（曾造成混淆）。
                    // 完成前改以圖示表示狀態，證據指數只在真正判定完成後才出現。
                    child: complete
                        ? FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(probability * 100).round()}',
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
                                ),
                                Text(
                                  l10n.workspaceAiEvidenceIndexShort,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
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

/// 分析完成後的白話總結卡：逐行條列，內容由 [_telemetrySummaryLines] 依實際數據組出
class _TelemetrySummaryCard extends StatelessWidget {
  final String title;
  final List<String> lines;

  const _TelemetrySummaryCard({required this.title, required this.lines});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.colorScheme.primary;
    final titleColor = theme.colorScheme.primary;
    final bodyColor = theme.colorScheme.onSurfaceVariant;
    final backgroundColor = theme.colorScheme.surfaceContainerHighest
        .withValues(alpha: 0.5);
    final borderColor = theme.dividerColor;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.messageSquare, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                line,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: bodyColor,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EvidenceIndexBadge extends StatelessWidget {
  final int index;
  final double probability;

  const _EvidenceIndexBadge({required this.index, required this.probability});

  @override
  Widget build(BuildContext context) {
    final label = '$index';
    final color = AppTheme.verdictColor(
      probability,
      brightness: Theme.of(context).brightness,
    );
    final width = evidenceIndexBadgeWidthFor(index);
    return Semantics(
      label: label,
      child: SizedBox(
        key: ValueKey('evidence-index-$index'),
        width: width,
        height: 26,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EngineTelemetryPulse extends StatelessWidget {
  final String role;
  final String label;
  final bool active;
  final bool done;
  final double progress;

  const _EngineTelemetryPulse({
    required this.role,
    required this.label,
    required this.active,
    required this.done,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final color = _engineColor(context, role);
    final scheme = Theme.of(context).colorScheme;
    final pendingColor = scheme.outlineVariant;
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
                      value: progress > 0 ? progress.clamp(0.0, 1.0) : null,
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
                        color: done || active ? color : pendingColor,
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
                color: done || active ? color : pendingColor,
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
  final double progress;
  final String? relationshipText;
  final List<String>? reasons;

  /// 本次實際使用的模組。一個角色底下可能有多個（統計會同時跑困惑度與詞彙
  /// 指紋），而 Transformer 的變體又由路由逐次決定——只看角色名稱看不出來。
  final List<String>? modules;

  const _EngineTelemetryRow({
    required this.role,
    required this.label,
    required this.active,
    required this.done,
    required this.score,
    required this.progress,
    this.relationshipText,
    this.reasons,
    this.modules,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _engineColor(context, role);
    final icon = _engineIcon(role);
    final showDetail =
        done &&
        (relationshipText != null ||
            (reasons?.isNotEmpty ?? false) ||
            (modules?.isNotEmpty ?? false));
    final detailColor = _workspaceSecondaryText(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 42, child: _buildRow(context, scheme, color, icon)),
          if (showDetail)
            Padding(
              padding: const EdgeInsets.only(left: 54, top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (modules?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final module in modules!)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                module,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: color,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _workspacePrimaryText(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: done ? 1 : progress.clamp(0.0, 1.0),
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
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text(
                        '—',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                )
              : active
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        value: progress > 0 ? progress.clamp(0.0, 1.0) : null,
                        strokeWidth: 2,
                        color: color,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    Text(
                      '${(progress.clamp(0.0, 1.0) * 100).round()}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _workspaceSecondaryText(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Icon(
                  LucideIcons.moreHorizontal,
                  color: scheme.onSurfaceVariant,
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
    final inactiveBackground = scheme.surfaceContainerHighest;
    final inactiveText = scheme.onSurface;
    final inactiveBorder = scheme.outlineVariant;
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
              color: complete || current ? scheme.primary : inactiveBackground,
              border: Border.all(
                color: current
                    ? _workspacePrimaryText(context)
                    : inactiveBorder,
                width: current ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: complete
                ? Icon(LucideIcons.check, size: 15, color: scheme.onPrimary)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: current ? scheme.onPrimary : inactiveText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: current
                  ? _workspacePrimaryText(context)
                  : _workspaceSecondaryText(context),
              fontWeight: current ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileStageDot extends StatelessWidget {
  final int index;
  final int active;

  const _MobileStageDot({required this.index, required this.active});

  @override
  Widget build(BuildContext context) {
    final complete = index < active;
    final current = index == active;
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      selected: current,
      label: '${index + 1}',
      child: AnimatedContainer(
        duration: MediaQuery.of(context).disableAnimations
            ? Duration.zero
            : const Duration(milliseconds: 180),
        width: current ? 30 : 24,
        height: current ? 30 : 24,
        alignment: Alignment.center,
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
        child: complete
            ? Icon(LucideIcons.check, size: 14, color: scheme.onPrimary)
            : Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: current ? scheme.onPrimary : scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
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
            color: current
                ? _workspacePrimaryText(context)
                : Colors.transparent,
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
