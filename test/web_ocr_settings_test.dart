import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:truthlens/core/services/ocr_config_notifier.dart';
import 'package:truthlens/features/settings/web_ocr_settings.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('local OCR assistant detects unsupported mobile platforms', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => OcrConfigNotifier(),
          child: const MaterialApp(
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
        ),
      );

      expect(find.text('Web OCR settings'), findsOneWidget);
      expect(find.text('Local OCR: endpoint not set'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField).at(1),
        'http://127.0.0.1:5001/ocr',
      );
      await tester.pump();
      expect(find.text('Local OCR: endpoint set, not tested'), findsOneWidget);

      expect(find.text('Detect OS & download installer'), findsOneWidget);
      await tester.tap(find.text('Detect OS & download installer'));
      await tester.pumpAndSettle();

      expect(find.text('Automatic install is not available'), findsOneWidget);
      expect(
        find.textContaining('macOS or Windows desktop browser'),
        findsOneWidget,
      );
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}
