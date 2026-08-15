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
    home: HomeScreen(),
  ),
);

class _FakeModelManager extends ModelManager {
  _FakeModelManager()
    : super(client: MockClient((_) async => http.Response('', 404)));

  @override
  Future<void> checkForUpdates(ModelCatalogService catalogService) async {}
}
