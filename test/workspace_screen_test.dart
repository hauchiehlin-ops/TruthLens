import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/detection/model_catalog_service.dart';
import 'package:truthlens/core/detection/model_manager.dart';
import 'package:truthlens/core/services/preferences_service.dart';
import 'package:truthlens/features/workspace/workspace_screen.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('desktop automatic mode uses command grid', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pump();

    expect(find.text('Document workspace'), findsOneWidget);
    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(find.text('Live findings'), findsOneWidget);
  });

  testWidgets('mobile automatic mode uses mission timeline', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pump();

    expect(find.text('Overall progress'), findsOneWidget);
    expect(find.text('Four-engine analysis'), findsOneWidget);
    expect(find.text('Analysis telemetry'), findsOneWidget);
  });

  testWidgets('mobile manual modes retain distinct compact layouts', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final prefs = await _preferences();
    await prefs.setWorkspaceMode(WorkspaceMode.commandGrid);

    await tester.pumpWidget(_testApp(prefs));
    await tester.pumpAndSettle();

    expect(find.text('Live findings'), findsOneWidget);
    expect(find.text('Overall progress'), findsNothing);
    expect(tester.takeException(), isNull);

    await prefs.setWorkspaceMode(WorkspaceMode.evidenceCanvas);
    await tester.pumpAndSettle();

    expect(find.text('Evidence canvas'), findsWidgets);
    expect(find.text('Overall progress'), findsOneWidget);
    expect(find.byTooltip('Import File'), findsOneWidget);
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
    await tester.tap(find.byTooltip('Switch situation center layout'));
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
}

Future<PreferencesService> _preferences() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = PreferencesService();
  await prefs.load();
  await prefs.setWorkspaceMode(WorkspaceMode.automatic);
  return prefs;
}

Widget _testApp(PreferencesService prefs) => MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: prefs),
    ChangeNotifierProvider<ModelManager>.value(value: _FakeModelManager()),
    Provider(create: (_) => ModelCatalogService()),
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
}
