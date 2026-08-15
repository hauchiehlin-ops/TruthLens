import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/services/preferences_service.dart';
import 'package:truthlens/features/settings/engine_weight_settings.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'weight editor is localized and exposes four engine help dialogs',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = PreferencesService();
      await prefs.load();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: prefs,
          child: const MaterialApp(
            locale: Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: SingleChildScrollView(child: EngineWeightSettingsCard()),
            ),
          ),
        ),
      );

      expect(find.text('AI model weights'), findsOneWidget);
      expect(find.byType(Slider), findsNothing);
      expect(find.byType(TextField), findsNWidgets(4));
      expect(find.text('Total: 100% — ready to save'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsNWidgets(4));

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '10');
      await tester.enterText(fields.at(1), '20');
      await tester.enterText(fields.at(2), '30');
      await tester.enterText(fields.at(3), '40');
      await tester.pump();
      expect(find.text('Total: 100% — ready to save'), findsOneWidget);
      await tester.enterText(fields.at(3), '250');
      await tester.pump();
      expect(tester.widget<TextField>(fields.at(3)).controller!.text, '40');
      await tester.tap(find.text('Save weights'));
      await tester.pump();
      expect(prefs.engineWeight('transformer'), 0.10);
      expect(prefs.engineWeight('adversarial'), 0.40);

      await tester.tap(find.byIcon(Icons.info_outline).first);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('context-preserving paragraph blocks'),
        findsOneWidget,
      );
    },
  );
}
