import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/services/calibration_service.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';
import 'package:truthlens/shared/widgets/professional_report_header.dart';

/// 報告頁頭內含共形校準卡，需要 CalibrationService provider 才能建構
Widget _testApp(Widget child) => MultiProvider(
  providers: [ChangeNotifierProvider.value(value: _calibration)],
  child: MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Scaffold(body: child),
  ),
);

late CalibrationService _calibration;

/// 足以通過棄權門檻的正文
final _sampleBody = List.filled(200, 'alpha').join(' ');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _calibration = CalibrationService();
    await _calibration.load();
  });

  DetectionResult sampleResult({String sourceFileName = ''}) => DetectionResult(
    id: 'header-test',
    analyzedAt: DateTime(2026, 8, 12, 21, 21),
    // 需超過棄權門檻（>=100 字、>=5 可分析句），否則報告會改顯示棄權而非判定
    inputText: _sampleBody,
    sourceFileName: sourceFileName,
    aiProbability: 0.22,
    verdict: Verdict.likelyHuman,
    engineScores: const [
      EngineScore(
        engineId: 'statistical',
        engineName: 'Statistical analysis',
        aiProbability: 0.68,
        weight: 0.25,
        reasons: ['Statistical signal is elevated'],
      ),
      EngineScore(
        engineId: 'stylometry',
        engineName: 'Stylometry analysis',
        aiProbability: 0.12,
        weight: 0.20,
        reasons: ['No obvious AI writing style markers'],
      ),
    ],
    sentences: [
      for (var i = 0; i < 8; i++)
        SentenceScore(
          index: i,
          text:
              'This is a complete and sufficiently long sentence for report '
              'rendering, numbered $i.',
          aiProbability: 0.22,
        ),
    ],
  );

  testWidgets('engine layer verdict text follows the English locale', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final result = sampleResult();

    await tester.pumpWidget(_testApp(ProfessionalReportHeader(result: result, onDownloadPdf: () {})));

    final scrollable = find.byType(Scrollable).first;
    for (
      var i = 0;
      i < 8 && find.text('Overall verdict').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(scrollable, const Offset(0, -500));
      await tester.pumpAndSettle();
    }

    expect(find.text('Overall verdict'), findsOneWidget);
    expect(find.text('Overall AI probability 22%'), findsOneWidget);
    expect(
      find.textContaining('Overall verdict: Likely human'),
      findsOneWidget,
    );
    expect(find.textContaining('Strongest single signal'), findsOneWidget);
    expect(find.text('綜合判定'), findsNothing);
    expect(find.textContaining('整體 AI 機率'), findsNothing);
  });

  testWidgets('report title includes the imported source file name', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(ProfessionalReportHeader(
            result: sampleResult(sourceFileName: 'paper.md'),
            onDownloadPdf: () {},
          )));

    // 主題與檔名必須各自成行，不再串成一行
    expect(find.text('AI Content Detection Report'), findsOneWidget);
    expect(find.text('paper.md'), findsOneWidget);
    expect(find.text('AI Content Detection Report：paper.md'), findsNothing);

    // 檔名字級為主題的 70%
    final title = tester.widget<Text>(
      find.text('AI Content Detection Report'),
    );
    final fileName = tester.widget<Text>(find.text('paper.md'));
    expect(
      fileName.style!.fontSize,
      closeTo(title.style!.fontSize! * 0.7, 0.01),
    );
  });

  testWidgets(
    'verdict card shows threshold and all five tiers, no confidence badge, no overflow on a narrow screen',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 1600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final result = sampleResult();

      await tester.pumpWidget(_testApp(ProfessionalReportHeader(
              result: result,
              onDownloadPdf: () {},
            )));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // 標題列改為 AI index 公式：22% / 60% = 37%
      expect(
        find.textContaining('AI index 37%', findRichText: true),
        findsOneWidget,
      );
      // 五級區間改以 AI index 表達，門檻 60% 時第一個切點為 40%
      expect(find.text('AI index < 40%'), findsOneWidget);
      // "Likely human" is the active verdict, so it also appears as the
      // headline label and in the radar-panel badge, not just the tier chip.
      expect(find.text('Human-written'), findsOneWidget);
      expect(find.text('Likely human'), findsWidgets);
      expect(find.text('Mixed content'), findsOneWidget);
      expect(find.text('Likely AI'), findsOneWidget);
      expect(find.text('AI-generated'), findsOneWidget);
      expect(find.textContaining('confidence'), findsNothing);
    },
  );
}
