import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;
import 'package:omnitrace/core/detection/evasion_scanner.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/core/services/citation_evidence.dart';
import 'package:omnitrace/core/services/document_provenance.dart';
import 'package:omnitrace/core/services/report_exporter.dart';
import 'package:omnitrace/features/report/ai_signal_inventory.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';
import 'package:omnitrace/shared/widgets/ai_signal_inventory_card.dart';

final _l10n = lookupAppLocalizations(const Locale('en'));

DetectionResult _result({
  DocumentProvenance provenance = DocumentProvenance.none,
  EvasionScan evasion = EvasionScan.clean,
  List<EngineScore> engines = const [],
  List<SentenceScore> sentences = const [],
}) => DetectionResult(
  id: 'inventory',
  analyzedAt: DateTime(2026, 10, 24),
  inputText: List.filled(200, 'alpha').join(' '),
  aiProbability: 0.5,
  verdict: Verdict.mixed,
  provenance: provenance,
  evasion: evasion,
  engineScores: engines,
  sentences: sentences,
);

/// 檔案原生、洗滌、歷程與資訊四族各一，加上規避字元、文字引擎、逐句與引用
DetectionResult _full() => _result(
  provenance: const DocumentProvenance(
    sourceFormat: 'docx',
    signals: [
      ProvenanceSignal(
        kind: ProvenanceSignalKind.webPasteResidue,
        severity: ProvenanceSeverity.notable,
        values: {'count': 4},
      ),
      ProvenanceSignal(
        kind: ProvenanceSignalKind.embeddedC2pa,
        severity: ProvenanceSeverity.info,
        label: 'ChatGPT',
      ),
      ProvenanceSignal(
        kind: ProvenanceSignalKind.editingTimeExceedsLifetime,
        severity: ProvenanceSeverity.strong,
        values: {'minutes': 218, 'lifetime': 4},
      ),
      ProvenanceSignal(
        kind: ProvenanceSignalKind.chatCitationArtifact,
        severity: ProvenanceSeverity.strong,
        values: {'count': 3},
      ),
    ],
  ),
  evasion: const EvasionScan(
    findings: [EvasionFinding(kind: EvasionKind.zeroWidth, count: 9)],
    characterCount: 1000,
  ),
  engines: const [
    EngineScore(
      engineId: 'stylometry',
      engineName: 'Stylometry',
      aiProbability: 0.86,
      weight: 0.2,
      reasons: ['Assistant-style closing', 'Uniform sentence openers'],
    ),
    // 偏人類的引擎不是 AI 訊號，不得列入
    EngineScore(
      engineId: 'statistical',
      engineName: 'Statistical',
      aiProbability: 0.2,
      weight: 0.25,
      reasons: ['High perplexity'],
    ),
  ],
  sentences: const [
    SentenceScore(
      index: 0,
      text: 'a',
      aiProbability: 0.9,
      patterns: ['Generic transition “Moreover”'],
    ),
    SentenceScore(index: 1, text: 'b', aiProbability: 0.1),
    SentenceScore(
      index: 2,
      text: 'c',
      aiProbability: 0.8,
      patterns: ['Generic transition “Moreover”'],
    ),
    // 沒有神經模型支撐的逐句值是棄權，不是 AI 判定
    SentenceScore(index: 3, text: 'd', aiProbability: 0.95, modelBacked: false),
  ],
);

const _citations = CitationEvidence(total: 10, verified: 4, notFound: 6);

void main() {
  test('沒有任何訊號時清單是空的', () {
    expect(collectAiSignals(_result(), _l10n), isEmpty);
  });

  test('每一項訊號逐條列出，依類別再依強度排序', () {
    final entries = collectAiSignals(_full(), _l10n, citations: _citations);
    expect(entries.map((e) => e.category).toList(), [
      AiSignalCategory.fileNative,
      AiSignalCategory.concealment,
      AiSignalCategory.evasion,
      AiSignalCategory.textEngine,
      AiSignalCategory.sentencePattern,
      AiSignalCategory.sentencePattern,
      AiSignalCategory.writingProcess,
      AiSignalCategory.sourceIntegrity,
      AiSignalCategory.informational,
    ]);
  });

  test('每條標明作用與出處', () {
    final entries = collectAiSignals(_full(), _l10n, citations: _citations);
    AiSignalEntry of(AiSignalCategory c) =>
        entries.firstWhere((e) => e.category == c);

    final native = of(AiSignalCategory.fileNative);
    expect(native.role, AiSignalRole.identity);
    expect(native.strength, AiSignalStrength.strong);
    expect(native.location, _l10n.aiSignalLocationBody);

    final concealment = of(AiSignalCategory.concealment);
    expect(concealment.role, AiSignalRole.concealment);
    expect(concealment.statement, contains('218'));
    expect(concealment.location, 'docProps/app.xml · docProps/core.xml');

    final evasion = of(AiSignalCategory.evasion);
    expect(evasion.role, AiSignalRole.evasion);
    expect(evasion.statement, contains('9'));

    final engine = of(AiSignalCategory.textEngine);
    expect(engine.statement, contains('Stylometry'));
    expect(engine.statement, contains('86%'));
    // 引擎列出的全部理由都要出現，不是只取第一條
    expect(engine.statement, contains('Assistant-style closing'));
    expect(engine.statement, contains('Uniform sentence openers'));

    expect(of(AiSignalCategory.writingProcess).role, AiSignalRole.vetoesHuman);
    expect(
      of(AiSignalCategory.sourceIntegrity).role,
      AiSignalRole.sourceQuality,
    );
    expect(of(AiSignalCategory.informational).role, AiSignalRole.informational);
  });

  test('逐句訊號以 1 起算列出句號；棄權句與偏人類引擎不列入', () {
    final entries = collectAiSignals(_full(), _l10n);
    final sentence = entries
        .where((e) => e.category == AiSignalCategory.sentencePattern)
        .toList();
    expect(sentence[0].statement, contains('2 sentence'));
    expect(sentence[0].statement, endsWith('sentence 1, 3'));
    expect(sentence[1].statement, contains('Moreover'));
    expect(sentence[1].statement, contains('(sentence 1, 3)'));
    expect(entries.any((e) => e.statement.contains('Statistical')), isFalse);
  });

  test('句號過多時截斷並標示', () {
    final many = _result(
      sentences: [
        for (var i = 0; i < maxListedSentences + 5; i++)
          SentenceScore(index: i, text: 's$i', aiProbability: 0.9),
      ],
    );
    final entry = collectAiSignals(many, _l10n).single;
    expect(entry.statement, endsWith('…'));
    expect(entry.statement, contains('${maxListedSentences + 5} sentence'));
  });

  test('每一種檔案訊號在各格式都有出處與白話陳述', () {
    for (final format in ['docx', 'pdf', 'odt', 'doc']) {
      for (final kind in ProvenanceSignalKind.values) {
        final entries = collectAiSignals(
          _result(
            provenance: DocumentProvenance(
              sourceFormat: format,
              signals: [
                ProvenanceSignal(
                  kind: kind,
                  severity: ProvenanceSeverity.notable,
                  label: 'x',
                ),
              ],
            ),
          ),
          _l10n,
        );
        expect(entries.single.location, isNotEmpty, reason: '$format $kind');
        expect(entries.single.statement, isNotEmpty, reason: '$format $kind');
      }
    }
  });

  test('JSON 與 CSV 匯出列出與畫面相同的清單', () {
    final result = _full();
    final json =
        jsonDecode(ReportExporter.buildJson(result, _l10n))
            as Map<String, dynamic>;
    final inventory = json['ai_signal_inventory'] as List;
    final expected = collectAiSignals(result, _l10n);
    expect(inventory, hasLength(expected.length));
    expect(inventory.first['number'], 1);
    expect(inventory.first['statement'], expected.first.statement);
    expect(inventory.first['location'], expected.first.location);

    final csv = ReportExporter.buildCsv(result, _l10n);
    final rows = csv
        .split('\n')
        .where((l) => l.startsWith('# ai_signal,'))
        .toList();
    expect(
      rows.first,
      '# ai_signal,number,category,strength,role,statement,location',
    );
    expect(rows.length - 1, expected.length);
  });

  test('PDF 匯出以表格逐條列出', () async {
    final regular = File(
      'assets/fonts/NotoSansTC-Regular.ttf',
    ).readAsBytesSync().buffer.asByteData();
    final bold = File(
      'assets/fonts/NotoSansTC-Bold.ttf',
    ).readAsBytesSync().buffer.asByteData();
    final bytes = await ReportExporter.buildPdf(
      _full(),
      _l10n,
      regularFont: regular,
      boldFont: bold,
    );
    final document = sf.PdfDocument(inputBytes: bytes);
    final text = sf.PdfTextExtractor(
      document,
    ).extractText().replaceAll(RegExp(r'\s+'), ' ');
    document.dispose();
    // 表格儲存格會在字中換行，比對時去掉所有空白
    final compact = text.replaceAll(' ', '');
    String squeeze(String s) => s.replaceAll(RegExp(r'\s+'), '');
    expect(text, contains(_l10n.aiSignalInventoryTitle));
    expect(text, contains(_l10n.aiSignalColumnRole));
    for (final entry in collectAiSignals(_full(), _l10n)) {
      expect(
        compact,
        contains(squeeze(aiSignalCategoryLabel(entry.category, _l10n))),
        reason: entry.statement,
      );
    }
    expect(compact, contains('docProps/app.xml'));
    expect(text, contains('Assistant-style closing'));

    // 中文語系同樣能產出有效的 PDF（CJK 子集字型的文字無法由抽取器還原，
    // 這裡只驗證檔案有效）
    final zh = await ReportExporter.buildPdf(
      _full(),
      lookupAppLocalizations(const Locale('zh', 'Hant')),
      regularFont: regular,
      boldFont: bold,
    );
    expect(String.fromCharCodes(zh.take(4)), '%PDF');
  });

  testWidgets('報告卡逐條編號呈現；沒有訊號時明確告知', (tester) async {
    Future<void> pump(List<AiSignalEntry> entries) => tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: AiSignalInventoryCard(entries: entries),
          ),
        ),
      ),
    );

    final entries = collectAiSignals(_full(), _l10n, citations: _citations);
    await pump(entries);
    expect(find.text(_l10n.aiSignalInventoryTitle), findsOneWidget);
    expect(
      find.text(_l10n.aiSignalInventoryCount(entries.length)),
      findsOneWidget,
    );
    for (var i = 1; i <= entries.length; i++) {
      expect(find.text('#$i'), findsOneWidget);
    }
    expect(find.text(entries.first.statement), findsOneWidget);

    await pump(const []);
    expect(find.text(_l10n.aiSignalInventoryEmpty), findsOneWidget);
  });
}
