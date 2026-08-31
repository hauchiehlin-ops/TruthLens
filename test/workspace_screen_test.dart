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
import 'package:truthlens/core/detection/model_manager.dart';
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

  testWidgets('desktop automatic mode uses command grid', (tester) async {
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
      WorkspaceMode.cosmicFuture,
      WorkspaceMode.softEducation,
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

  testWidgets('mobile automatic mode uses mission timeline', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pump();

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
    await tester.pumpWidget(_testApp(prefs, orchestrator: orchestrator));
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
}

Future<PreferencesService> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = PreferencesService();
  await prefs.load();
  await prefs.setWorkspaceMode(WorkspaceMode.automatic);
  return prefs;
}

Widget _testApp(
  PreferencesService prefs, {
  EnsembleOrchestrator? orchestrator,
}) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: prefs),
    ChangeNotifierProvider<ModelManager>.value(value: _FakeModelManager()),
    ChangeNotifierProvider<CalibrationService>.value(
      value: CalibrationService(),
    ),
    ChangeNotifierProvider<EnsembleOrchestrator>.value(
      value: orchestrator ?? EnsembleOrchestrator(engines: const []),
    ),
    Provider(create: (_) => ModelCatalogService()),
    Provider(create: (_) => HistoryRepository()),
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
  Future<EngineScore> analyze(PreprocessedText text, AppLocalizations l10n) =>
      Completer<EngineScore>().future;
}
