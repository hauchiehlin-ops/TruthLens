import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/services/calibration_service.dart';
import 'package:truthlens/core/services/document_provenance.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';
import 'package:truthlens/shared/widgets/professional_report_header.dart';

/// 今天實際踩到的失敗模式：一篇 ChatGPT 中文被判為「可能人類」。
/// 成因不是 bug——2026 世代 LLM 的中文散文困惑度落在真人分布內
/// （實測 36.8–58，真人中位數 56.3），文本統計只能指認罐頭式寫作。
///
/// 因此偏人類的低分，在沒有來源證據時**不得被讀成人類撰寫的確認**。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CalibrationService calibration;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    calibration = CalibrationService();
    await calibration.load();
  });

  final body = List.filled(200, 'alpha').join(' ');

  DetectionResult result({
    required double ai,
    DocumentProvenance provenance = DocumentProvenance.none,
  }) => DetectionResult(
    id: 'caveat',
    analyzedAt: DateTime(2026, 8, 19),
    inputText: body,
    aiProbability: ai,
    verdict: Verdict.fromProbability(ai),
    provenance: provenance,
    engineScores: const [
      EngineScore(
        engineId: 'statistical',
        engineName: 'Statistical',
        aiProbability: 0.35,
        weight: 0.25,
      ),
      EngineScore(
        engineId: 'adversarial',
        engineName: 'Adversarial',
        aiProbability: 0.31,
        weight: 0.15,
      ),
    ],
    sentences: [
      for (var i = 0; i < 8; i++)
        SentenceScore(
          index: i,
          text: 'This is a complete and sufficiently long sentence $i.',
          aiProbability: 0.3,
        ),
    ],
  );

  Widget app(DetectionResult r) => MultiProvider(
    providers: [ChangeNotifierProvider.value(value: calibration)],
    child: MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: ProfessionalReportHeader(result: r, onDownloadPdf: () {}),
      ),
    ),
  );

  Future<bool> hasCaveat(WidgetTester tester, DetectionResult r) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(r));
    await tester.pumpAndSettle();
    return find
        .textContaining('not confirmation that a person wrote this')
        .evaluate()
        .isNotEmpty;
  }

  testWidgets('偏人類且無來源證據時，必須附上「低分不等於確認由人撰寫」', (tester) async {
    expect(await hasCaveat(tester, result(ai: 0.33)), isTrue);
  });

  testWidgets('人類撰寫（更低分）同樣要附警語', (tester) async {
    expect(await hasCaveat(tester, result(ai: 0.10)), isTrue);
  });

  testWidgets('偏 AI 的判定不加此警語——它談的是低分的解讀', (tester) async {
    expect(await hasCaveat(tester, result(ai: 0.70)), isFalse);
  });

  testWidgets('混合內容不加：它本來就沒有宣稱偏人類', (tester) async {
    expect(await hasCaveat(tester, result(ai: 0.50)), isFalse);
  });

  testWidgets('來源證據可疑卻得到低分時，改用矛盾警語而非「沒有來源證據」', (tester) async {
    // 實際案例：一份 .docx，編輯總時長 0 分鐘、正文 2462 字、存檔 3 次，
    // 文本統計卻給 32%「可能人類」。說成「沒有可用的來源證據」是錯的
    // ——有證據，而且正在示警。
    const suspicious = DocumentProvenance(
      sourceFormat: 'docx',
      editingDuration: Duration.zero,
      revisionCount: 3,
      bodyWordCount: 2462,
      application: 'Microsoft Office Word',
      signals: [
        ProvenanceSignal(
          kind: ProvenanceSignalKind.negligibleEditingTime,
          severity: ProvenanceSeverity.strong,
        ),
        ProvenanceSignal(
          kind: ProvenanceSignalKind.implausibleTypingSpeed,
          severity: ProvenanceSeverity.strong,
        ),
      ],
    );

    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      app(result(ai: 0.32, provenance: suspicious)),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining("editing record contradicts this low score"),
      findsOneWidget,
    );
    // 不得再宣稱沒有來源證據
    expect(
      find.textContaining('With no origin evidence available'),
      findsNothing,
    );
  });

  testWidgets('單一 strong 訊號（實際檔案的形狀）即足以觸發矛盾警語', (tester) async {
    // A1969-意見陳述書-211206.docx 的實際狀態：只有「編輯時長接近 0」一條訊號。
    // risk 需 strong>=1 才到 medium，這裡確認邊界剛好涵蓋，
    // 而不是要湊兩條訊號才會示警。
    const oneSignal = DocumentProvenance(
      sourceFormat: 'docx',
      editingDuration: Duration.zero,
      revisionCount: 3,
      bodyWordCount: 2462,
      application: 'Microsoft Office Word',
      signals: [
        ProvenanceSignal(
          kind: ProvenanceSignalKind.negligibleEditingTime,
          severity: ProvenanceSeverity.strong,
          values: {'words': 2462, 'minutes': 0},
        ),
      ],
    );

    expect(oneSignal.risk, ProvenanceRisk.medium);
    expect(oneSignal.indicatesHumanAuthorship, isFalse);

    await tester.binding.setSurfaceSize(const Size(1200, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(app(result(ai: 0.32, provenance: oneSignal)));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('editing record contradicts this low score'),
      findsOneWidget,
    );
    expect(
      find.textContaining('With no origin evidence available'),
      findsNothing,
    );
  });
}
