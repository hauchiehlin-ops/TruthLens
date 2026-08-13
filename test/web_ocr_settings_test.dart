import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/features/settings/web_ocr_settings.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('local OCR beginner guide opens in the selected locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(child: WebOcrSettingsCard()),
        ),
      ),
    );

    expect(find.text('Web OCR settings'), findsOneWidget);
    await tester.tap(find.text('Beginner setup guide'));
    await tester.pumpAndSettle();

    expect(find.text('Set up the local OCR server'), findsOneWidget);
    expect(find.textContaining('setup_and_run_ocr.sh'), findsOneWidget);
    expect(find.textContaining('setup_and_run_ocr.bat'), findsOneWidget);
  });
}
