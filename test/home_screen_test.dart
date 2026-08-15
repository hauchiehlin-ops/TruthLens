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
import 'package:truthlens/features/home/home_screen.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('original layout is the default home and mode changes in place', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    await prefs.load();

    await tester.pumpWidget(_testApp(prefs));
    await tester.pump();

    expect(prefs.workspaceMode, WorkspaceMode.original);
    expect(
      find.text('Paste or type text to detect AI-generated content'),
      findsOneWidget,
    );
    expect(find.text('Analysis telemetry'), findsNothing);

    await prefs.setWorkspaceMode(WorkspaceMode.commandGrid);
    await tester.pumpAndSettle();

    expect(find.text('Analysis telemetry'), findsOneWidget);
    expect(find.text('Live findings'), findsOneWidget);
  });
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
