import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/services/calibration_service.dart';
import 'package:truthlens/core/detection/model_catalog_service.dart';
import 'package:truthlens/core/detection/llm_manager.dart';
import 'package:truthlens/core/detection/model_manager.dart';
import 'package:truthlens/core/detection/report_llm_service.dart';
import 'package:truthlens/core/detection/detection_engine.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/services/history_repository.dart';
import 'package:truthlens/core/services/preferences_service.dart';
import 'package:truthlens/core/utils/text_stats.dart';
import 'package:truthlens/core/utils/app_version.dart';
import 'package:truthlens/features/workspace/workspace_screen.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('responsive workspace includes phone landscape and medium portrait', () {
    expect(
      usesSingleColumnWorkspace(
        const BoxConstraints(maxWidth: 844, maxHeight: 326),
      ),
      isTrue,
    );
    expect(
      usesSingleColumnWorkspace(
        const BoxConstraints(maxWidth: 915, maxHeight: 348),
      ),
      isTrue,
    );
    expect(
      usesSingleColumnWorkspace(
        const BoxConstraints(maxWidth: 768, maxHeight: 960),
      ),
      isTrue,
    );
    expect(
      usesSingleColumnWorkspace(
        const BoxConstraints(maxWidth: 1024, maxHeight: 704),
      ),
      isFalse,
    );
  });

  test('evidence index badges reserve width for three-digit numbering', () {
    expect(evidenceIndexBadgeWidthFor(1), 26);
    expect(evidenceIndexBadgeWidthFor(99), 26);
    expect(evidenceIndexBadgeWidthFor(100), 34);
    expect(evidenceIndexBadgeWidthFor(111), 34);
    expect(evidenceIndexBadgeWidthFor(1000), 42);
  });

  testWidgets('desktop default mode uses command grid', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pump();

    expect(find.text('Document workspace'), findsOneWidget);
    expect(find.text(AppVersion.displayVersion), findsOneWidget);
    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(find.text('Live findings'), findsOneWidget);
    expect(find.byTooltip('Add assignment requirements'), findsNothing);
    expect(
      find.byTooltip('Import a previous draft for version comparison'),
      findsNothing,
    );
  });

  testWidgets('desktop workspace modes share the command header', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();

    await tester.pumpWidget(_testApp(prefs));

    for (final mode in [
      WorkspaceMode.commandGrid,
      WorkspaceMode.missionTimeline,
      WorkspaceMode.evidenceCanvas,
    ]) {
      await prefs.setWorkspaceMode(mode);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Overall progress:'), findsOneWidget);
      expect(find.text('Document workspace:'), findsOneWidget);
      expect(find.text('Live findings:'), findsOneWidget);
      expect(find.byTooltip('Import File'), findsWidgets);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('mobile default mode uses the responsive single-column flow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pump();

    expect(prefs.workspaceMode, WorkspaceMode.commandGrid);
    expect(find.byKey(const ValueKey('mobile-workspace-flow')), findsOneWidget);
    expect(find.text('Overall progress'), findsOneWidget);
    expect(find.text('Document workspace'), findsOneWidget);
    expect(find.text('Analysis telemetry'), findsOneWidget);
  });

  testWidgets('mobile modes converge on the responsive single-column flow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();
    await prefs.setWorkspaceMode(WorkspaceMode.commandGrid);

    await tester.pumpWidget(_testApp(prefs));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('mobile-workspace-flow')), findsOneWidget);
    expect(find.text('Overall progress'), findsOneWidget);
    expect(find.text('Document workspace'), findsOneWidget);
    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await prefs.setWorkspaceMode(WorkspaceMode.evidenceCanvas);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('mobile-workspace-flow')), findsOneWidget);
    expect(find.text('Overall progress'), findsOneWidget);
    expect(find.byTooltip('Import File'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320px mobile workspace scrolls without clipped fixed cards', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pumpAndSettle();

    final flow = find.byKey(const ValueKey('mobile-workspace-flow'));
    expect(flow, findsOneWidget);
    expect(find.byTooltip('Import File'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.drag(flow, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'phone landscape can scroll through the complete telemetry card',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(844, 390));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final prefs = await _preferences();

      await tester.pumpWidget(_testApp(prefs));
      await tester.pumpAndSettle();

      final flow = find.byKey(const ValueKey('mobile-workspace-flow'));
      expect(flow, findsOneWidget);
      await tester.drag(flow, const Offset(0, -420));
      await tester.pumpAndSettle();
      expect(find.text('Analysis telemetry'), findsOneWidget);

      final lastEngine = find.text('Adversarial defense');
      await tester.ensureVisible(lastEngine);
      await tester.pumpAndSettle();

      final rect = tester.getRect(lastEngine);
      expect(rect.top, greaterThanOrEqualTo(0));
      expect(rect.bottom, lessThanOrEqualTo(390));
      expect(find.text('Transformer classifier'), findsOneWidget);
      expect(find.text('Statistical analysis'), findsOneWidget);
      expect(find.text('Stylometry analysis'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('medium portrait uses the complete single-column card flow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(768, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('mobile-workspace-flow')), findsOneWidget);
    expect(find.text('Document workspace'), findsOneWidget);
    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('320px workspace remains scrollable with enlarged system text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.4;
    addTearDown(() {
      tester.binding.setSurfaceSize(null);
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    final prefs = await _preferences();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pumpAndSettle();

    final flow = find.byKey(const ValueKey('mobile-workspace-flow'));
    expect(flow, findsOneWidget);
    await tester.drag(flow, const Offset(0, -560));
    await tester.pumpAndSettle();
    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching layouts preserves imported text state', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();
    await tester.pumpWidget(_testApp(prefs));
    await tester.pump();

    const source =
        'This document remains available while the situation center layout changes.';
    await tester.enterText(find.byType(TextField).first, source);
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Switch workspace mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evidence canvas').last);
    await tester.pumpAndSettle();

    expect(prefs.workspaceMode, WorkspaceMode.evidenceCanvas);
    expect(find.text('Evidence canvas'), findsWidgets);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      source,
    );
  });

  testWidgets('analysis remains observable while switching layouts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();
    await prefs.setModelPromptSuppressed(true);
    final orchestrator = EnsembleOrchestrator(
      engines: [
        for (final role in PreferencesService.engineRoles)
          _BlockingEngine(role),
      ],
    );
    await tester.pumpWidget(
      _testApp(
        prefs,
        orchestrator: orchestrator,
        historyRepository: _MemoryHistoryRepository(),
      ),
    );
    await tester.pump();

    const source =
        'This document remains available while a deliberately long local '
        'analysis keeps all four detection modules active.';
    await tester.enterText(find.byType(TextField).first, source);
    await tester.pump();
    await tester.tap(find.text('Start Detection'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.textContaining('0/4 ·'), findsOneWidget);
    expect(find.textContaining('Running:'), findsOneWidget);
    expect(find.text('39%'), findsWidgets);

    await tester.tap(find.byTooltip('More options'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Switch workspace mode'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Evidence canvas').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Evidence canvas'), findsWidgets);
    expect(find.textContaining('0/4 ·'), findsWidgets);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      source,
    );

    expect(find.text('Stop analysis'), findsOneWidget);
    await tester.tap(find.text('Stop analysis'));
    await tester.pump();
    expect(find.text('Stop the current analysis?'), findsOneWidget);
    expect(
      find.textContaining('unfinished results will not be saved'),
      findsOneWidget,
    );
    await tester.tap(find.text('Stop analysis').last);
    await tester.pump();

    expect(find.text('Start Detection'), findsOneWidget);
    expect(find.textContaining('Analysis stopped.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      source,
    );
  });

  testWidgets('completed desktop workspace emphasizes report and telemetry', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();
    await prefs.setModelPromptSuppressed(true);
    final orchestrator = EnsembleOrchestrator(
      engines: [
        for (final role in PreferencesService.engineRoles)
          _CompletingEngine(
            role,
            probability: role == 'statistical' ? 0.62 : 0.35,
          ),
      ],
    );

    await tester.pumpWidget(
      _testApp(
        prefs,
        orchestrator: orchestrator,
        historyRepository: _MemoryHistoryRepository(),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, _completedSource());
    await tester.pump();
    await tester.tap(find.text('Start Detection'));
    await _pumpCompletedAnalysis(tester);

    expect(
      find.byKey(const ValueKey('workspace-report-panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('workspace-telemetry-panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('workspace-live-findings-panel')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('workspace-source-preview-panel')),
      findsOneWidget,
    );
    expect(find.byTooltip('New analysis'), findsOneWidget);

    final reportSize = tester.getSize(
      find.byKey(const ValueKey('workspace-report-panel')),
    );
    final telemetrySize = tester.getSize(
      find.byKey(const ValueKey('workspace-telemetry-panel')),
    );
    final sourceSize = tester.getSize(
      find.byKey(const ValueKey('workspace-source-preview-panel')),
    );
    expect(
      reportSize.width * reportSize.height,
      greaterThan(telemetrySize.width * telemetrySize.height),
    );
    expect(telemetrySize.height, greaterThan(sourceSize.height));
    expect(tester.takeException(), isNull);
  });

  testWidgets('completed workspace modes reuse the focused responsive layout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();
    await prefs.setModelPromptSuppressed(true);
    final orchestrator = EnsembleOrchestrator(
      engines: [
        for (final role in PreferencesService.engineRoles)
          _CompletingEngine(role, probability: 0.42),
      ],
    );

    await tester.pumpWidget(
      _testApp(
        prefs,
        orchestrator: orchestrator,
        historyRepository: _MemoryHistoryRepository(),
      ),
    );
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, _completedSource());
    await tester.pump();
    await tester.tap(find.text('Start Detection'));
    await _pumpCompletedAnalysis(tester);

    final expectedModeKeys = {
      WorkspaceMode.commandGrid: 'completed-command-grid',
      WorkspaceMode.missionTimeline: 'completed-mission-timeline',
      WorkspaceMode.evidenceCanvas: 'completed-evidence-canvas',
    };

    for (final entry in expectedModeKeys.entries) {
      final mode = entry.key;
      await prefs.setWorkspaceMode(mode);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.byKey(ValueKey(entry.value)), findsOneWidget);
      expect(
        find.byKey(const ValueKey('workspace-report-panel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('workspace-telemetry-panel')),
        findsOneWidget,
      );
      expect(find.byTooltip('New analysis'), findsOneWidget);
      final reportRect = tester.getRect(
        find.byKey(const ValueKey('workspace-report-panel')),
      );
      final telemetryRect = tester.getRect(
        find.byKey(const ValueKey('workspace-telemetry-panel')),
      );
      expect(reportRect.width, greaterThan(0));
      expect(telemetryRect.width, greaterThan(0));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('completed mobile workspace leads with telemetry before report', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();
    await prefs.setModelPromptSuppressed(true);
    final orchestrator = EnsembleOrchestrator(
      engines: [
        for (final role in PreferencesService.engineRoles)
          _CompletingEngine(role, probability: 0.42),
      ],
    );

    await tester.pumpWidget(
      _testApp(
        prefs,
        orchestrator: orchestrator,
        historyRepository: _MemoryHistoryRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, _completedSource());
    await tester.pump();
    await tester.tap(find.text('Start Detection'));
    await _pumpCompletedAnalysis(tester);

    final flow = find.byKey(const ValueKey('mobile-completed-workspace-flow'));
    expect(flow, findsOneWidget);
    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Analysis telemetry')).dy,
      lessThan(360),
    );
    expect(find.text('New analysis'), findsOneWidget);

    await tester.ensureVisible(
      find.byKey(const ValueKey('workspace-report-panel')),
    );
    await tester.pump(const Duration(milliseconds: 350));
    expect(
      find.byKey(const ValueKey('workspace-report-panel')),
      findsOneWidget,
    );

    await tester.drag(flow, const Offset(0, 900));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('New analysis'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const ValueKey('mobile-workspace-flow')), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Start Detection'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpCompletedAnalysis(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (find
            .byKey(const ValueKey('workspace-report-panel'))
            .evaluate()
            .isNotEmpty ||
        find
            .byKey(const ValueKey('mobile-completed-workspace-flow'))
            .evaluate()
            .isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
      return;
    }
  }
}

Future<PreferencesService> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = PreferencesService();
  await prefs.load();
  return prefs;
}

Widget _testApp(
  PreferencesService prefs, {
  EnsembleOrchestrator? orchestrator,
  HistoryRepository? historyRepository,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: prefs),
    ChangeNotifierProvider<ModelManager>.value(value: _FakeModelManager()),
    ChangeNotifierProvider<LlmManager>(
      create: (context) =>
          LlmManager(modelManager: context.read<ModelManager>()),
    ),
    Provider<ReportLlmService>(
      create: (context) =>
          ReportLlmService(llmManager: context.read<LlmManager>()),
    ),
    ChangeNotifierProvider<CalibrationService>.value(
      value: CalibrationService(),
    ),
    ChangeNotifierProvider<EnsembleOrchestrator>.value(
      value: orchestrator ?? EnsembleOrchestrator(engines: const []),
    ),
    Provider(create: (_) => ModelCatalogService()),
    Provider(create: (_) => historyRepository ?? HistoryRepository()),
  ],
  child: const MaterialApp(
    locale: Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: WorkspaceScreen(),
  ),
);

class _FakeModelManager extends ModelManager {
  _FakeModelManager()
    : super(client: MockClient((_) async => http.Response('', 404)));

  @override
  Future<void> checkForUpdates(ModelCatalogService catalogService) async {}

  @override
  Future<void> refreshInstallStates() async {}

  @override
  bool isInstalled(String role) => false;

  @override
  bool isVariantInstalled(String role, String variantId) => false;

  @override
  InstalledModel? activeVariant(String role) => null;

  @override
  Future<String?> activeModelPath(String role) async => null;
}

class _MemoryHistoryRepository extends HistoryRepository {
  final List<DetectionResult> _saved = [];

  @override
  Future<void> save(DetectionResult result) async {
    _saved.add(result);
  }

  @override
  Future<void> delete(String id) async {
    _saved.removeWhere((result) => result.id == id);
  }

  @override
  Future<List<HistoryEntry>> list({String? query}) async => const [];

  @override
  Future<void> clearAll() async {
    _saved.clear();
  }
}

class _BlockingEngine implements DetectionEngine {
  @override
  final String id;

  _BlockingEngine(this.id);

  @override
  double get defaultWeight => PreferencesService.defaultEngineWeights[id]!;

  @override
  Future<bool> isAvailable() async => true;

  @override
  String name(AppLocalizations l10n) => id;

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n, {
    EngineProgressCallback? onProgress,
  }) {
    onProgress?.call(0.39);
    return Completer<EngineScore>().future;
  }
}

class _CompletingEngine implements DetectionEngine {
  @override
  final String id;

  final double probability;

  _CompletingEngine(this.id, {required this.probability});

  @override
  double get defaultWeight => PreferencesService.defaultEngineWeights[id]!;

  @override
  Future<bool> isAvailable() async => true;

  @override
  String name(AppLocalizations l10n) => id;

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n, {
    EngineProgressCallback? onProgress,
  }) async {
    onProgress?.call(0.35);
    await Future<void>.delayed(const Duration(milliseconds: 1));
    onProgress?.call(1);
    return EngineScore(
      engineId: id,
      engineName: id,
      aiProbability: probability,
      weight: defaultWeight,
      features: {'coverage': 1},
      reasons: const ['Test evidence produced a directional signal.'],
      sentenceScores: List<double>.filled(text.sentences.length, probability),
      modules: ['$id-test-module'],
      hasEvidence: true,
    );
  }
}

String _completedSource() => List.generate(
  10,
  (index) =>
      'This completed workspace sample sentence number $index has enough '
      'detail for local analysis and keeps the generated report available.',
).join(' ');
