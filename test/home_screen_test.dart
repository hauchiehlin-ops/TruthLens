import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/detection/model_catalog_service.dart';
import 'package:truthlens/core/detection/model_manager.dart';
import 'package:truthlens/core/detection/model_provisioner.dart';
import 'package:truthlens/core/services/ocr_config_notifier.dart';
import 'package:truthlens/core/services/preferences_service.dart';
import 'package:truthlens/core/utils/app_version.dart';
import 'package:truthlens/features/home/home_screen.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // rootBundle 是全域的 CachingAssetBundle，快取的是 Future 而非結果。
  // testWidgets 的 fake async 下，某個測試中途啟動、卻隨測試結束而未完成的
  // asset 讀取，會把那個永不完成的 future 留在快取裡——後續測試再讀同一個
  // asset 就只能一直等它。先在 fake async 之外讀一次，快取的就是已完成的 future。
  setUpAll(() async {
    await rootBundle.loadString('assets/model_catalog.json');
  });

  // 首次啟動提示會呼叫 DeviceCapabilities.detect() 決定推薦哪些變體，
  // 那是一次 MethodChannel 往返；widget test 的 fake async 下若沒有 handler
  // 就不會有回覆，對話框永遠停在載入中。
  setUp(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.truthlens/device'),
      (call) async => call.method == 'physicalMemoryMb' ? 16384 : null,
    );
  });

  tearDown(() {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('com.truthlens/device'),
      null,
    );
  });

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

  testWidgets('首次啟動先進主畫面，提示內直接列出待下載模型並預先勾選', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    await prefs.load();
    expect(prefs.firstRunHandled, isFalse);

    await tester.pumpWidget(_testApp(prefs, promptModelOnFirstRun: true));
    await _pumpUntilPromptLoaded(tester);

    // 主畫面必須已經在後面渲染——提示是覆蓋層，不是攔截頁。
    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(find.text('Add a detection model?'), findsOneWidget);
    expect(find.text('Models to download'), findsOneWidget);

    // 首次啟動的使用者不知道哪些 role 必要，所以清單要預先勾好核心模型；
    // 1.6GB 的報告 LLM 只影響報告文字，預設不勾但仍列出讓使用者自己決定。
    final tiles = tester
        .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
        .toList();
    expect(tiles, isNotEmpty);
    final llm = tester.widget<CheckboxListTile>(
      find.ancestor(
        of: find.textContaining('Gemma 2'),
        matching: find.byType(CheckboxListTile),
      ),
    );
    expect(llm.value, isFalse, reason: '報告用 LLM 不影響判讀結論，不該預設勾選');
    expect(llm.onChanged, isNotNull, reason: '預設不勾不等於不能選');
    expect(
      tiles.where((t) => t.value == true),
      isNotEmpty,
      reason: '核心偵測模型應預先勾選，否則清單等於要使用者自己認',
    );
  });

  testWidgets('取消時說明之後自行下載的路徑，而不是靜默關閉', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    await prefs.load();

    await tester.pumpWidget(_testApp(prefs, promptModelOnFirstRun: true));
    await _pumpUntilPromptLoaded(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Add a detection model?'), findsNothing);
    expect(find.text('Downloading models later'), findsOneWidget);
    // 只說「可以稍後下載」而不說去哪，等於要使用者自己在設定裡翻找。
    expect(find.textContaining('AI Model Management'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
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

/// 等首次啟動提示把清單載出來。
///
/// 這裡不能用 pumpAndSettle：內容備妥前畫面上是 CircularProgressIndicator，
/// 它每一幀都排下一幀，而 pumpAndSettle 的內圈不讓出真正的事件迴圈——
/// DeviceCapabilities 那次 MethodChannel 往返的回覆因此永遠抵達不了，
/// 結果是穩定逾時而不是穩定通過。runAsync 才會真的推進真實的非同步。
Future<void> _pumpUntilPromptLoaded(WidgetTester tester) async {
  for (var i = 0; i < 40; i++) {
    if (find.byType(CheckboxListTile).evaluate().isNotEmpty) return;
    // runAsync 讓真正的非同步（asset 讀取、MethodChannel 回覆）推進，
    // pump 才把回來的結果畫成一幀——只做其中一樣都會停在載入中。
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Widget _testApp(PreferencesService prefs, {bool promptModelOnFirstRun = false}) {
  // 明確共用同一組實例：catalog 若沒拿到 MockClient 就會去打真實網路
  // （8 秒逾時），首次啟動提示的載入時間會跟著變成不可預測。
  final modelManager = _FakeModelManager();
  final catalogService = ModelCatalogService(
    client: MockClient((_) async => http.Response('', 404)),
  );
  final provisioner = ModelProvisioner(
    catalogService: catalogService,
    modelManager: modelManager,
  );

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: prefs),
      ChangeNotifierProvider<ModelManager>.value(value: modelManager),
      Provider.value(value: catalogService),
      Provider.value(value: provisioner),
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
}

class _FakeModelManager extends ModelManager {
  _FakeModelManager()
    : super(client: MockClient((_) async => http.Response('', 404)));

  @override
  Future<void> checkForUpdates(ModelCatalogService catalogService) async {}
}
