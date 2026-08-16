import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/calibration_service.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';
import 'package:truthlens/shared/widgets/calibration_card.dart';

Widget _app(ConformalResult result) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(
    body: SingleChildScrollView(child: CalibrationCard(result: result)),
  ),
);

void main() {
  testWidgets('尚未建立基準集時說明用途與蒐集方式', (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _app(CalibrationService.conformal(0.5, const [], 0.05)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Local baseline calibration'), findsOneWidget);
    expect(find.textContaining('No baseline set yet'), findsOneWidget);
    // 未建立時不該出現任何標記結論
    expect(find.textContaining('is flagged'), findsNothing);
  });

  testWidgets('樣本不足時明說沒有統計保證，且不給標記結論', (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _app(CalibrationService.conformal(0.99, List.filled(5, 0.1), 0.05)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('needs at least 19'), findsOneWidget);
    expect(find.textContaining('is flagged'), findsNothing);
  });

  testWidgets('樣本充足且分數異常時給出標記結論與 p 值', (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final calib = List.generate(30, (i) => i / 200); // 0.00–0.145
    await tester.pumpWidget(_app(CalibrationService.conformal(0.9, calib, 0.05)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('is flagged'), findsOneWidget);
    expect(find.textContaining('Conservative p-value'), findsOneWidget);
    expect(find.textContaining('100th percentile'), findsOneWidget);
    // 可交換性前提的免責說明必須一直都在
    expect(find.textContaining('exchangeable'), findsOneWidget);
  });

  test('p 值顯示不得出現 0.000 造成絕對確定的錯覺', () {
    expect(CalibrationCard.formatPValue(0.0001), '<0.001');
    expect(CalibrationCard.formatPValue(0.05), '0.050');
  });
}
