import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/features/help/help_screen.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('workflow chips follow the English locale', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: HelpScreen(),
      ),
    );

    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 8 && find.text('Paste text').evaluate().isEmpty; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pumpAndSettle();
    }

    expect(find.text('Paste text'), findsOneWidget);
    expect(find.text('Four-engine ensemble'), findsOneWidget);
    expect(find.text('AI overview gauge'), findsOneWidget);
    expect(find.text('直接貼上'), findsNothing);
    expect(find.text('四引擎並列推論'), findsNothing);
    expect(find.text('AI 總覽儀表'), findsNothing);
  });
}
