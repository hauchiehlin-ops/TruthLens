import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/core/services/artifact_trace.dart';
import 'package:omnitrace/core/services/document_provenance.dart';
import 'package:omnitrace/core/services/file_forensics.dart';
import 'package:omnitrace/core/services/integrated_assessment.dart';

List<int> _b(String s) => utf8.encode(s);

String _rsid(int i) => (0x00A10000 + i * 7919).toRadixString(16).toUpperCase();

/// 以真實 zip 結構組出 DOCX。[registered] 是 settings.xml `<w:rsids>` 登記表
/// 的內容；null 代表登記表與正文一致。
List<int> _docx({
  required int sessions,
  required int totalMinutes,
  required int revision,
  required String created,
  required String modified,
  Iterable<String>? registered,
  String body = '',
  String rels = '',
}) {
  final rsids = [for (var i = 0; i < sessions; i++) _rsid(i)];
  final registry = (registered ?? rsids)
      .map((r) => '<w:rsid w:val="$r"/>')
      .join();
  // 每個批次一段，平均分散——模擬洗滌工具把隨機 RSID 打散到各段，
  // 讓「批次過度集中」的舊檢查看不到
  final filler = List.filled(12, 'research').join(' ');
  final paragraphs = rsids
      .map(
        (r) =>
            '<w:p w:rsidR="$r" w:rsidRDefault="$r"><w:r><w:t>$filler</w:t></w:r></w:p>',
      )
      .join();
  final archive = Archive()
    ..addFile(
      ArchiveFile.bytes(
        'docProps/app.xml',
        _b(
          '<Properties><Application>Microsoft Office Word</Application>'
          '<AppVersion>16.0000</AppVersion><TotalTime>$totalMinutes</TotalTime>'
          '</Properties>',
        ),
      ),
    )
    ..addFile(
      ArchiveFile.bytes(
        'docProps/core.xml',
        _b(
          '<cp:coreProperties><cp:revision>$revision</cp:revision>'
          '<dcterms:created>$created</dcterms:created>'
          '<dcterms:modified>$modified</dcterms:modified></cp:coreProperties>',
        ),
      ),
    )
    ..addFile(
      ArchiveFile.bytes(
        'word/document.xml',
        _b(
          '<w:document><w:body>$paragraphs'
          '<w:p><w:r><w:t>$body</w:t></w:r></w:p></w:body></w:document>',
        ),
      ),
    )
    ..addFile(
      ArchiveFile.bytes(
        'word/settings.xml',
        _b(
          '<w:settings><w:rsids><w:rsidRoot w:val="${rsids.first}"/>'
          '$registry</w:rsids></w:settings>',
        ),
      ),
    )
    ..addFile(ArchiveFile.bytes('word/fontTable.xml', _b('<w:fonts/>')))
    ..addFile(
      ArchiveFile.bytes(
        'word/_rels/document.xml.rels',
        _b('<Relationships>$rels</Relationships>'),
      ),
    );
  return ZipEncoder().encode(archive);
}

DocumentProvenance _parse(List<int> bytes, {String body = ''}) {
  final filler = List.filled(25 * 12, 'research').join(' ');
  return DocumentProvenance.fromBytes(
    bytes,
    extension: 'docx',
    bodyText: '$filler $body',
  );
}

Set<ProvenanceSignalKind> _kinds(DocumentProvenance p) =>
    p.signals.map((s) => s.kind).toSet();

DetectionResult _result(DocumentProvenance provenance) => DetectionResult(
  id: 'artifact',
  analyzedAt: DateTime(2026, 10, 24),
  inputText: List.filled(180, 'word').join(' '),
  aiProbability: 0.13,
  verdict: Verdict.fromProbability(0.13),
  provenance: provenance,
  engineScores: const [
    EngineScore(
      engineId: 'transformer',
      engineName: 'Transformer',
      aiProbability: 0.13,
      weight: 0.4,
      hasEvidence: false,
    ),
  ],
  sentences: [
    for (var i = 0; i < 8; i++)
      SentenceScore(
        index: i,
        text: 'This is a complete and sufficiently long sentence number $i.',
        aiProbability: 0.13,
      ),
  ],
);

void main() {
  group('洗滌痕跡（截圖中 NonAI 作業鏈的 DOCX 產物）', () {
    test('對照組：欄位彼此一致的同規格檔案，舊規則判定為「由人撰寫」', () {
      // 這是要堵的漏洞：25 個批次、218 分鐘、Word 16 都超過自動納入門檻。
      // 欄位一致時這是合理的人類檔案，不得被新檢查誤傷。
      final p = _parse(
        _docx(
          sessions: 25,
          totalMinutes: 218,
          revision: 9,
          created: '2026-10-01T08:00:00Z',
          modified: '2026-10-03T17:00:00Z',
        ),
      );
      expect(p.signals, isEmpty);
      expect(p.indicatesHumanAuthorship, isTrue);
      expect(ArtifactTraceReport.evaluate(p).aiLogOdds, 0);
    });

    test('注入的 RSID 沒登記、編輯時長超過檔案存在時間 → 洗滌痕跡並否決人類證據', () {
      final p = _parse(
        _docx(
          sessions: 25,
          totalMinutes: 218,
          revision: 9,
          // AI 匯出檔建立與修改只差幾分鐘，洗滌工具只改了 TotalTime
          created: '2026-10-24T09:00:00Z',
          modified: '2026-10-24T09:04:00Z',
          // 登記表只留原本的單一批次，注入的 24 個沒有登記
          registered: [_rsid(0)],
        ),
      );
      expect(
        _kinds(p),
        containsAll([
          ProvenanceSignalKind.unregisteredRsids,
          ProvenanceSignalKind.editingTimeExceedsLifetime,
        ]),
      );
      expect(p.indicatesHumanAuthorship, isFalse);

      final report = ArtifactTraceReport.evaluate(p);
      expect(report.concealmentDetected, isTrue);
      expect(report.hasIdentityTrace, isFalse);
      // 同一次洗滌的多個破綻有上限，不會疊成壓倒性證據
      expect(report.aiLogOdds, ArtifactTraceReport.concealmentCap);
    });

    test('批次數遠多於存檔次數 → 欄位矛盾', () {
      final p = _parse(
        _docx(
          sessions: 25,
          totalMinutes: 218,
          revision: 3,
          created: '2026-10-01T08:00:00Z',
          modified: '2026-10-03T17:00:00Z',
        ),
      );
      expect(_kinds(p), {ProvenanceSignalKind.sessionsExceedRevisions});
      expect(p.indicatesHumanAuthorship, isFalse);
    });

    test('少量未登記（從別份文件複製段落）不視為注入', () {
      final p = _parse(
        _docx(
          sessions: 25,
          totalMinutes: 218,
          revision: 9,
          created: '2026-10-01T08:00:00Z',
          modified: '2026-10-03T17:00:00Z',
          registered: [for (var i = 0; i < 21; i++) _rsid(i)],
        ),
      );
      expect(p.signals, isEmpty);
    });
  });

  test('缺建立日期時不推論存在時間', () {
    const base = DocumentProvenance(
      sourceFormat: 'odt',
      editingDuration: Duration(minutes: 218),
      revisionCount: 9,
    );
    final p = DocumentProvenance.fromBytes(
      ZipEncoder().encode(
        Archive()..addFile(
          ArchiveFile.bytes(
            'meta.xml',
            _b(
              '<office:meta><meta:editing-duration>PT3H38M</meta:editing-duration>'
              '<meta:editing-cycles>9</meta:editing-cycles>'
              '<dc:date>2026-10-24T09:04:00</dc:date></office:meta>',
            ),
          ),
        ),
      ),
      extension: base.sourceFormat,
      bodyText: 'short',
    );
    expect(p.editingDuration, base.editingDuration);
    expect(p.signals, isEmpty);
  });

  group('原生 AI 痕跡（未經洗滌）', () {
    test('對話引用標記是作者身分證據', () {
      final p = _parse(
        _docx(
          sessions: 25,
          totalMinutes: 218,
          revision: 9,
          created: '2026-10-01T08:00:00Z',
          modified: '2026-10-03T17:00:00Z',
        ),
        body: '研究指出學習動機與成效正相關【4†source】。',
      );
      expect(_kinds(p), contains(ProvenanceSignalKind.chatCitationArtifact));
      final report = ArtifactTraceReport.evaluate(p);
      expect(report.hasIdentityTrace, isTrue);
      expect(report.aiLogOdds, ArtifactTraceReport.identityLogOdds);
    });

    test('超連結目標帶 utm_source=chatgpt.com → 佐證，不是身分證據', () {
      final p = _parse(
        _docx(
          sessions: 25,
          totalMinutes: 218,
          revision: 9,
          created: '2026-10-01T08:00:00Z',
          modified: '2026-10-03T17:00:00Z',
          rels:
              '<Relationship Id="rId9" Type="hyperlink" '
              'Target="https://example.org/paper?utm_source=chatgpt.com"/>',
        ),
      );
      expect(_kinds(p), {ProvenanceSignalKind.aiReferralLink});
      final report = ArtifactTraceReport.evaluate(p);
      expect(report.hasNativeTrace, isTrue);
      expect(report.hasIdentityTrace, isFalse);
      expect(report.aiLogOdds, ArtifactTraceReport.supportingNativeLogOdds);
    });

    test('對話引用標記的各種形態', () {
      expect(ChatCitationArtifacts.count('結果如下【12†L34-L40】'), 1);
      expect(ChatCitationArtifacts.count('growth citeturn0search3'), 1);
      expect(
        ChatCitationArtifacts.count(
          'rate :contentReference[oaicite:2]{index=2}',
        ),
        1,
      );
      // 一般中文方括號註記與數學符號不算
      expect(ChatCitationArtifacts.count('見【註1】與【表 2】，誤差 ±3'), 0);
    });
  });

  group('PDF 產生器偽裝', () {
    test('Quartz Producer 格式核對', () {
      // 截圖：洗滌前的原始值 → 一致
      expect(
        QuartzProducer.check(
          'macOS Version 12.6 (Build 21G115) Quartz PDFContext',
        ),
        QuartzProducerCheck.consistent,
      );
      // 截圖：洗滌後的偽裝值，缺組建號
      expect(
        QuartzProducer.check('macOS Version 15.3.1 Quartz PDFContext'),
        QuartzProducerCheck.missingBuild,
      );
      // 只改版本號、沿用舊組建號
      expect(
        QuartzProducer.check(
          'macOS Version 15.3.1 (Build 21G115) Quartz PDFContext',
        ),
        QuartzProducerCheck.buildMismatch,
      );
      // 舊式命名本來就沒有組建號
      expect(
        QuartzProducer.check('Mac OS X 10.10.5 Quartz PDFContext'),
        QuartzProducerCheck.notApplicable,
      );
      expect(
        QuartzProducer.check('Microsoft® Word for Microsoft 365'),
        QuartzProducerCheck.notApplicable,
      );
    });

    test('偽裝的 Producer 成為洗滌痕跡', () {
      final p = DocumentProvenance.fromBytes(
        _b('%PDF-1.4\n%%EOF'),
        extension: 'pdf',
        bodyText: 'body',
        pdfMetadata: const PdfMetadata(
          creator: 'Pages',
          producer: 'macOS Version 15.3.1 Quartz PDFContext',
        ),
      );
      final forged = p.signals.singleWhere(
        (s) => s.kind == ProvenanceSignalKind.forgedPdfProducer,
      );
      expect(forged.severity, ProvenanceSeverity.notable);
      expect(ArtifactTraceReport.evaluate(p).concealmentDetected, isTrue);
    });

    test('真實的系統輸出不產生訊號', () {
      final p = DocumentProvenance.fromBytes(
        _b('%PDF-1.4\n%%EOF'),
        extension: 'pdf',
        bodyText: 'body',
        pdfMetadata: const PdfMetadata(
          creator: 'Pages',
          producer: 'macOS Version 12.6 (Build 21G115) Quartz PDFContext',
        ),
      );
      expect(p.signals, isEmpty);
    });
  });

  group('作者判讀', () {
    test('文字引擎沉默時，對話引用標記可單獨形成 AI 方向', () {
      const provenance = DocumentProvenance(
        sourceFormat: 'docx',
        signals: [
          ProvenanceSignal(
            kind: ProvenanceSignalKind.chatCitationArtifact,
            severity: ProvenanceSeverity.strong,
            values: {'count': 3},
          ),
        ],
      );
      final assessment = IntegratedAssessment.assess(_result(provenance));
      expect(assessment.passesAiEvidenceGate, isTrue);
      expect(assessment.direction, IntegratedDirection.likelyAi);
    });

    test('只有洗滌痕跡時加強 AI 方向，但不單獨形成結論', () {
      const provenance = DocumentProvenance(
        sourceFormat: 'docx',
        editingDuration: Duration(minutes: 218),
        revisionCount: 9,
        distinctBodyRsids: 25,
        signals: [
          ProvenanceSignal(
            kind: ProvenanceSignalKind.editingTimeExceedsLifetime,
            severity: ProvenanceSeverity.strong,
            values: {'minutes': 218, 'lifetime': 4},
          ),
        ],
      );
      final assessment = IntegratedAssessment.assess(_result(provenance));
      expect(assessment.passesAiEvidenceGate, isFalse);
      expect(assessment.pointEstimateAvailable, isFalse);
      expect(assessment.aiLikelihood, greaterThan(0.5));
      // 偽造的編輯歷程不再抵銷 AI 嫌疑
      expect(assessment.contributions.every((c) => c.logOdds >= 0), isTrue);
    });
  });
}
