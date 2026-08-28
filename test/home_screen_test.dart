import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/detection/model_catalog_service.dart';
import 'package:truthlens/core/detection/model_manager.dart';
import 'package:truthlens/core/services/ocr_config_notifier.dart';
import 'package:truthlens/core/services/preferences_service.dart';
import 'package:truthlens/core/utils/app_version.dart';
import 'package:truthlens/features/home/home_screen.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'automatic workspace is default and original remains selectable',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService();
      await prefs.load();

      await tester.pumpWidget(_testApp(prefs));
      await tester.pump();

      expect(prefs.workspaceMode, WorkspaceMode.automatic);
      expect(find.text(AppVersion.displayVersion), findsOneWidget);
      expect(find.text('Analysis telemetry'), findsOneWidget);
      expect(find.text('Live findings'), findsOneWidget);

      await prefs.setWorkspaceMode(WorkspaceMode.original);
      await tester.pumpAndSettle();

      expect(
        find.text('Paste or type text to detect AI-generated content'),
        findsOneWidget,
      );
      expect(find.text(AppVersion.displayVersion), findsOneWidget);
      expect(find.byTooltip('More options'), findsOneWidget);
      await tester.tap(find.byTooltip('More options'));
      await tester.pumpAndSettle();
      expect(find.text('Switch workspace mode'), findsOneWidget);
      expect(find.text('Analysis telemetry'), findsNothing);
    },
  );

  testWidgets('首次啟動先進主畫面，再以提示詢問是否前往模型頁', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    await prefs.load();
    expect(prefs.firstRunHandled, isFalse);

    await tester.pumpWidget(_testApp(prefs, promptModelOnFirstRun: true));
    await tester.pumpAndSettle();

    // 主畫面必須已經在後面渲染——提示是覆蓋層，不是攔截頁。
    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(find.text('Add a detection model?'), findsOneWidget);
    expect(find.text('Choose a model'), findsOneWidget);

    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(find.text('Add a detection model?'), findsNothing);
    expect(find.text('Analysis telemetry'), findsOneWidget);
    // 婉拒也算處理過：下次啟動不再打擾。
    expect(prefs.firstRunHandled, isTrue);
  });

  testWidgets('未要求提示時首次啟動不出現任何對話框', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    await prefs.load();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Analysis telemetry'), findsOneWidget);
  });
}

Widget _testApp(PreferencesService prefs, {bool promptModelOnFirstRun = false}) =>
    MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: prefs),
    ChangeNotifierProvider<ModelManager>.value(value: _FakeModelManager()),
    Provider(create: (_) => ModelCatalogService()),
    ChangeNotifierProvider(create: (_) => OcrConfigNotifier()),
  ],
  child: MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: HomeScreen(promptModelOnFirstRun: promptModelOnFirstRun),
  ),
);

class _FakeModelManager extends ModelManager {
  _FakeModelManager()
    : super(client: MockClient((_) async => http.Response('', 404)));

  @override
  Future<void> checkForUpdates(ModelCatalogService catalogService) async {}
}
