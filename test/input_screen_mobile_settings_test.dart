import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/detection/model_manager.dart';
import 'package:truthlens/core/services/preferences_service.dart';
import 'package:truthlens/features/input/input_screen.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mobile settings drawer exposes the full settings entry set', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    SharedPreferences.setMockInitialValues({});
    final prefs = PreferencesService();
    await prefs.load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: prefs),
          ChangeNotifierProvider<ModelManager>.value(
            value: _FakeModelManager(),
          ),
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
          home: Scaffold(body: InputSettingsDrawer()),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('AI Model Management'), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('Custom ONNX model import & test'),
      scrollable,
      const Offset(0, -300),
    );
    expect(find.text('Custom ONNX model import & test'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Language packs'),
      scrollable,
      const Offset(0, -300),
    );
    expect(find.text('Language packs'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('AI flagging threshold'),
      scrollable,
      const Offset(0, -300),
    );
    expect(find.text('AI flagging threshold'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('AI model weights'),
      scrollable,
      const Offset(0, -300),
    );
    expect(find.text('AI model weights'), findsOneWidget);
  });
}

class _FakeModelManager extends ModelManager {
  _FakeModelManager()
    : super(client: MockClient((_) async => http.Response('', 404)));

  @override
  bool get hasAnyUpdate => false;
}
