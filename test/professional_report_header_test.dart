import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';
import 'package:truthlens/shared/widgets/professional_report_header.dart';

void main() {
  DetectionResult sampleResult({String sourceFileName = ''}) => DetectionResult(
    id: 'header-test',
    analyzedAt: DateTime(2026, 8, 12, 21, 21),
    inputText: 'This is a complete sentence for report rendering.',
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
    sentences: const [
      SentenceScore(
        index: 0,
        text: 'This is a complete sentence for report rendering.',
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

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: ProfessionalReportHeader(result: result, onDownloadPdf: () {}),
        ),
      ),
    );

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
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: ProfessionalReportHeader(
            result: sampleResult(sourceFileName: 'paper.md'),
            onDownloadPdf: () {},
          ),
        ),
      ),
    );

    expect(find.text('AI Content Detection Report：paper.md'), findsOneWidget);
  });
}
