import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omnitrace/core/detection/domain_evidence.dart';
import 'package:omnitrace/core/detection/model_manager_types.dart';
import 'package:omnitrace/core/detection/variant_router.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/core/services/calibration_service.dart';
import 'package:omnitrace/core/services/document_provenance.dart';
import 'package:omnitrace/core/services/text_discriminability.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';
import 'package:omnitrace/shared/widgets/professional_report_header.dart';

// 全形括號引文足以讓文體判為學術
final _academic = List.filled(
  12,
  '本研究以結構方程模式檢驗消費者異質性（Wedel & Kannan, 2016）。',
).join();

/// 路由到一顆「學術文體只有單篇探針、且漏判」的中文分類器
Map<String, double> _routing() {
  final model = InstalledModel(
    role: 'transformer',
    variantId: 'zh',
    fileName: 'zh.onnx',
    version: '1',
    sizeBytes: 1,
    languages: const ['zh'],
    domains: const [
      DomainEvidence(
        domain: 'general',
        language: 'zh',
        corpus: 'c',
        recall: 0.73,
        aiDocuments: 6000,
        humanDocuments: 6000,
        fprUpper95: 0.002,
      ),
      DomainEvidence(
        domain: 'academic',
        language: 'zh',
        corpus: 'probe',
        recall: 0,
        aiDocuments: 1,
      ),
    ],
  );
  return chooseVariant(
    installed: [model],
    language: 'zh',
    domain: 'academic',
  ).routingFeatures;
}

DetectionResult _silentResult({
  DocumentProvenance provenance = DocumentProvenance.none,
  bool transformerVotes = false,
}) => DetectionResult(
  id: 'disc',
  analyzedAt: DateTime(2026, 10, 21),
  inputText: _academic,
  aiProbability: 0.5,
  verdict: Verdict.fromProbability(0.5),
  provenance: provenance,
  engineScores: [
    EngineScore(
      engineId: 'transformer',
      engineName: 'Transformer',
      aiProbability: transformerVotes ? 0.9 : 0.02,
      weight: 0.4,
      hasEvidence: transformerVotes,
      features: _routing(),
    ),
    const EngineScore(
      engineId: 'statistical',
      engineName: 'Statistical',
      aiProbability: 0.5,
      weight: 0.25,
      hasEvidence: false,
      features: {'perplexity_calibrated': 1},
    ),
    const EngineScore(
      engineId: 'stylometry',
      engineName: 'Stylometry',
      aiProbability: 0.5,
      weight: 0.2,
      hasEvidence: false,
    ),
    const EngineScore(
      engineId: 'adversarial',
      engineName: 'Adversarial',
      aiProbability: 0.5,
      weight: 0.15,
      available: false,
      applicability: EngineApplicability.unsupported,
      calibrationReliability: 0,
    ),
  ],
  sentences: [
    for (var i = 0; i < 8; i++)
      SentenceScore(
        index: i,
        text: '本研究以結構方程模式檢驗消費者異質性的第 $i 個面向。',
        aiProbability: 0.5,
      ),
  ],
);

void main() {
  group('判別力評估', () {
    test('實際情境：學術中文、全部沉默 → 列出漏判、困惑度過時、引擎不適用', () {
      final d = TextDiscriminability.assess(_silentResult());
      expect(d.domain, 'academic');
      expect(d.textEnginesSilent, isTrue);
      expect(d.isLimited, isTrue);
      expect(d.gaps, [
        DiscriminabilityGap.domainKnownMiss,
        DiscriminabilityGap.domainUnmeasured,
        DiscriminabilityGap.perplexityOutdated,
        DiscriminabilityGap.enginesUnavailable,
      ]);
      expect(d.probeDocuments, 1);
      expect(d.probeDetected, 0);
      expect(d.unavailableEngines, 1);
    });

    test('有任何文字引擎形成證據時不警示', () {
      final d = TextDiscriminability.assess(
        _silentResult(transformerVotes: true),
      );
      expect(d.textEnginesSilent, isFalse);
      expect(d.isLimited, isFalse);
    });

    test('舊紀錄沒有路由特徵時不猜測文體實測狀況', () {
      final result = _silentResult();
      final legacy = DetectionResult(
        id: result.id,
        analyzedAt: result.analyzedAt,
        inputText: result.inputText,
        aiProbability: result.aiProbability,
        verdict: result.verdict,
        sentences: result.sentences,
        engineScores: [
          const EngineScore(
            engineId: 'transformer',
            engineName: 'Transformer',
            aiProbability: 0.02,
            weight: 0.4,
            hasEvidence: false,
          ),
        ],
      );
      final d = TextDiscriminability.assess(legacy);
      expect(d.gaps, isNot(contains(DiscriminabilityGap.domainUnmeasured)));
      expect(d.gaps, isNot(contains(DiscriminabilityGap.domainKnownMiss)));
    });
  });

  group('報告呈現', () {
    late CalibrationService calibration;
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      calibration = CalibrationService();
      await calibration.load();
    });

    Future<void> pump(WidgetTester tester, DetectionResult result) async {
      await tester.binding.setSurfaceSize(const Size(420, 2400));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MultiProvider(
          providers: [ChangeNotifierProvider.value(value: calibration)],
          child: MaterialApp(
            locale: const Locale('zh', 'TW'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              body: SingleChildScrollView(
                child: ProfessionalReportHeader(
                  result: result,
                  onDownloadPdf: () {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('引擎都跑了卻分辨不了時，顯示判別力警示而非「請補齊模型」', (tester) async {
      await pump(tester, _silentResult());
      expect(tester.takeException(), isNull);
      expect(find.text('文字引擎對這類文件判別力不足'), findsOneWidget);
      expect(find.textContaining('漏判 1/1 份 AI 文件'), findsOneWidget);
      expect(find.textContaining('代表工具分辨不了'), findsOneWidget);
      expect(find.textContaining('核心文字引擎未完整參與'), findsNothing);
    });

    testWidgets('結論由來源證據撐起時明說', (tester) async {
      await pump(
        tester,
        _silentResult(
          provenance: const DocumentProvenance(
            sourceFormat: 'docx',
            application: 'Claude Docs',
            bodyWordCount: 2000,
            signals: [
              ProvenanceSignal(
                kind: ProvenanceSignalKind.aiGeneratorDeclared,
                severity: ProvenanceSeverity.strong,
                label: 'Claude Docs',
              ),
            ],
          ),
        ),
      );
      expect(find.textContaining('本次結論主要依據文件來源證據'), findsOneWidget);
    });
  });
}
