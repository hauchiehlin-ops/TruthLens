import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/services/calibration_service.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/services/citation_evidence.dart';
import 'package:truthlens/core/services/document_provenance.dart';
import 'package:truthlens/core/services/integrated_assessment.dart';
import 'package:truthlens/core/services/writing_session.dart';
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

  testWidgets(
    'engine layer uses the integrated verdict in the English locale',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final result = sampleResult();

      await tester.pumpWidget(
        _testApp(
          ProfessionalReportHeader(result: result, onDownloadPdf: () {}),
        ),
      );

      final scrollable = find.byType(Scrollable).first;
      for (
        var i = 0;
        i < 8 &&
            find.text('Integrated authorship assessment').evaluate().isEmpty;
        i++
      ) {
        await tester.drag(scrollable, const Offset(0, -500));
        await tester.pumpAndSettle();
      }

      expect(find.text('Overall verdict'), findsOneWidget);
      expect(find.text('Integrated AI likelihood: 22%'), findsNWidgets(2));
      expect(
        find.textContaining('After weighting the available evidence'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Four-engine text-model raw score: 22%'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Strongest text-engine signal'),
        findsOneWidget,
      );
      expect(find.text('Overall AI probability 22%'), findsNothing);
      expect(find.text('綜合判定'), findsNothing);
      expect(find.textContaining('整體 AI 機率'), findsNothing);
    },
  );

  testWidgets(
    'non-authorship concerns cannot flip a human-leaning text score to AI',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1500));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final result = DetectionResult(
        id: 'integrated-conflict-regression',
        analyzedAt: DateTime(2026, 8, 21),
        inputText: _sampleBody,
        aiProbability: 0.13,
        verdict: Verdict.human,
        engineScores: const [
          EngineScore(
            engineId: 'transformer',
            engineName: 'Transformer classifier',
            aiProbability: 0,
            weight: 0.40,
            hasEvidence: false,
          ),
          EngineScore(
            engineId: 'statistical',
            engineName: 'Statistical analysis',
            aiProbability: 0.50,
            weight: 0.25,
            hasEvidence: false,
          ),
          EngineScore(
            engineId: 'stylometry',
            engineName: 'Stylometry analysis',
            aiProbability: 0,
            weight: 0.20,
            hasEvidence: false,
          ),
          EngineScore(
            engineId: 'adversarial',
            engineName: 'Adversarial defense',
            aiProbability: 0.02,
            weight: 0.15,
            hasEvidence: false,
          ),
        ],
        sentences: [
          for (var i = 0; i < 8; i++)
            SentenceScore(
              index: i,
              text: 'A complete sentence numbered $i for the regression test.',
              aiProbability: 0.13,
            ),
        ],
        writingSession: const WritingSession(
          events: [
            InputEvent(
              kind: InputEventKind.paste,
              characters: 1800,
              elapsedMs: 500,
            ),
          ],
        ),
        provenance: const DocumentProvenance(
          sourceFormat: 'docx',
          bodyWordCount: 1800,
          signals: [
            ProvenanceSignal(
              kind: ProvenanceSignalKind.negligibleEditingTime,
              severity: ProvenanceSeverity.strong,
            ),
            ProvenanceSignal(
              kind: ProvenanceSignalKind.fewRevisions,
              severity: ProvenanceSeverity.strong,
            ),
          ],
        ),
      );
      final assessment = IntegratedAssessment.assess(result);
      final integratedPercent = (assessment.aiLikelihood * 100).round();
      expect(assessment.direction, IntegratedDirection.likelyHuman);

      await tester.pumpWidget(
        _testApp(
          ProfessionalReportHeader(result: result, onDownloadPdf: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('More likely not AI-generated'), findsNWidgets(2));
      expect(
        find.text('Integrated AI likelihood: $integratedPercent%'),
        findsNWidgets(2),
      );
      expect(
        find.textContaining('Four-engine text-model raw score: 13%'),
        findsOneWidget,
      );
      expect(find.text('More likely AI-generated'), findsNothing);
      expect(find.text('Human-written'), findsNothing);
      expect(find.text('Overall AI probability 13%'), findsNothing);
      expect(
        find.textContaining('Overall verdict: Human-written'),
        findsNothing,
      );
    },
  );

  testWidgets('report title includes the imported source file name', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        ProfessionalReportHeader(
          result: sampleResult(sourceFileName: 'paper.md'),
          onDownloadPdf: () {},
        ),
      ),
    );

    // 主題與檔名必須各自成行，不再串成一行
    expect(find.text('AI Content Detection Report'), findsOneWidget);
    expect(find.text('paper.md'), findsOneWidget);
    expect(find.text('AI Content Detection Report：paper.md'), findsNothing);

    // 檔名字級為主題的 70%
    final title = tester.widget<Text>(find.text('AI Content Detection Report'));
    final fileName = tester.widget<Text>(find.text('paper.md'));
    expect(
      fileName.style!.fontSize,
      closeTo(title.style!.fontSize! * 0.7, 0.01),
    );
  });

  testWidgets('整合作者判讀置於可查證事實與多證據矩陣之前', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _testApp(
        ProfessionalReportHeader(
          result: sampleResult(),
          onDownloadPdf: () {},
          citations: const CitationEvidence(total: 5, verified: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final verdictTop = tester
        .getTopLeft(find.text('Integrated authorship assessment'))
        .dy;
    final findingsTop = tester.getTopLeft(find.text('What can be verified')).dy;
    final matrixTop = tester
        .getTopLeft(find.text('Multi-evidence assessment'))
        .dy;

    expect(verdictTop, lessThan(findingsTop));
    expect(findingsTop, lessThan(matrixTop));
  });

  testWidgets('整合判讀卡同時顯示方向、指數、原始分數與信心，窄畫面不溢位', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final result = sampleResult();

    await tester.pumpWidget(
      _testApp(ProfessionalReportHeader(result: result, onDownloadPdf: () {})),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Integrated authorship assessment'), findsOneWidget);
    expect(find.text('More likely not AI-generated'), findsNWidgets(2));
    expect(find.text('Integrated AI likelihood: 22%'), findsNWidgets(2));
    expect(find.textContaining('Text-model score: 22%'), findsOneWidget);
    expect(find.textContaining('Confidence: Moderate'), findsNWidgets(2));
    expect(find.text('AI probability < 20%'), findsNothing);
  });
}
