import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/document_provenance.dart';

/// Word 實際寫出的設定與字型表內容（相容性設定、至少一個字型），
/// 空殼部件會被判為洗滌痕跡
const _wordSettings =
    '<w:settings><w:compat><w:compatSetting w:name="compatibilityMode" w:uri="http://schemas.microsoft.com/office/word" w:val="15"/></w:compat></w:settings>';
const _wordFonts =
    '<w:fonts><w:font w:name="Calibri"><w:panose1 w:val="020F0502020204030204"/></w:font></w:fonts>';

/// 以真實的 zip 容器結構組出 DOCX，確保解析走的是與實際檔案相同的路徑
List<int> _docx({
  int? totalMinutes,
  int? revision,
  int? declaredWords,
  String application = 'Microsoft Office Word',
  String? created,
  String? modified,
  List<String> rsids = const [],
  String bodyText = '',
  String coreExtra = '',
  // 真實 Word 存檔一定帶設定與字型表；設 false 模擬程式一次性封裝
  bool wordParts = true,
  Map<String, List<int>> extraFiles = const {},
  String documentExtra = '',
}) {
  final appXml = StringBuffer('<Properties>')
    ..write('<Application>$application</Application>');
  if (totalMinutes != null) {
    appXml.write('<TotalTime>$totalMinutes</TotalTime>');
  }
  if (declaredWords != null) appXml.write('<Words>$declaredWords</Words>');
  appXml.write('</Properties>');

  final coreXml = StringBuffer('<cp:coreProperties>');
  if (revision != null) coreXml.write('<cp:revision>$revision</cp:revision>');
  if (created != null) {
    coreXml.write('<dcterms:created>$created</dcterms:created>');
  }
  if (modified != null) {
    coreXml.write('<dcterms:modified>$modified</dcterms:modified>');
  }
  coreXml
    ..write(coreExtra)
    ..write('</cp:coreProperties>');

  // 每個 rsid 產生一個帶該批次標記的段落
  final paragraphs = rsids
      .map((r) => '<w:p w:rsidR="$r" w:rsidRDefault="$r"><w:t>x</w:t></w:p>')
      .join();
  final documentXml =
      '<w:document><w:body>$paragraphs$documentExtra'
      '<w:p><w:t>$bodyText</w:t></w:p></w:body></w:document>';

  final archive = Archive()
    ..addFile(_entry('docProps/app.xml', appXml.toString()))
    ..addFile(_entry('docProps/core.xml', coreXml.toString()))
    ..addFile(_entry('word/document.xml', documentXml));
  if (wordParts) {
    archive
      ..addFile(_entry('word/settings.xml', _wordSettings))
      ..addFile(_entry('word/fontTable.xml', _wordFonts));
  }
  for (final e in extraFiles.entries) {
    archive.addFile(ArchiveFile(e.key, e.value.length, e.value));
  }
  return ZipEncoder().encode(archive);
}

List<int> _odt({
  String? editingDuration,
  int? cycles,
  String generator = 'LibreOffice/7.6',
  String? creationDate,
}) {
  final meta = StringBuffer('<office:document-meta><office:meta>')
    ..write('<meta:generator>$generator</meta:generator>');
  if (editingDuration != null) {
    meta.write(
      '<meta:editing-duration>$editingDuration</meta:editing-duration>',
    );
  }
  if (cycles != null) {
    meta.write('<meta:editing-cycles>$cycles</meta:editing-cycles>');
  }
  if (creationDate != null) {
    meta.write('<meta:creation-date>$creationDate</meta:creation-date>');
  }
  meta.write('</office:meta></office:document-meta>');

  final archive = Archive()..addFile(_entry('meta.xml', meta.toString()));
  return ZipEncoder().encode(archive);
}

ArchiveFile _entry(String path, String content) {
  final bytes = utf8.encode(content);
  return ArchiveFile(path, bytes.length, bytes);
}

/// 產生指定字數的英文正文
String _body(int words) => List.filled(words, 'alpha').join(' ');

void main() {
  group('容器解析', () {
    test('DOCX 讀出編輯時長、存檔次數、產生軟體與時間戳', () {
      final provenance = DocumentProvenance.fromBytes(
        _docx(
          totalMinutes: 95,
          revision: 12,
          declaredWords: 800,
          created: '2026-08-01T09:00:00Z',
          modified: '2026-08-03T11:30:00Z',
          rsids: const ['00A1', '00B2', '00C3'],
        ),
        extension: 'docx',
        bodyText: _body(800),
      );

      expect(provenance.hasMetadata, isTrue);
      expect(provenance.editingDuration, const Duration(minutes: 95));
      expect(provenance.revisionCount, 12);
      expect(provenance.declaredWordCount, 800);
      expect(provenance.application, 'Microsoft Office Word');
      expect(provenance.createdAt, DateTime.utc(2026, 8, 1, 9));
      expect(provenance.modifiedAt, DateTime.utc(2026, 8, 3, 11, 30));
      expect(provenance.distinctBodyRsids, 3);
      expect(provenance.rsidMap.paragraphCount, 3);
      expect(provenance.rsidMap.batches, isNotEmpty);
      // 95 分鐘寫 800 字很正常，不該有任何訊號
      expect(provenance.signals, isEmpty);
      expect(provenance.risk, ProvenanceRisk.low);
    });

    test('ODT 讀出 ISO 8601 編輯時長與編輯次數', () {
      final provenance = DocumentProvenance.fromBytes(
        _odt(
          editingDuration: 'PT1H24M30S',
          cycles: 9,
          creationDate: '2026-08-01T09:00:00',
        ),
        extension: 'odt',
        bodyText: _body(600),
      );

      expect(
        provenance.editingDuration,
        const Duration(hours: 1, minutes: 24, seconds: 30),
      );
      expect(provenance.revisionCount, 9);
      expect(provenance.application, 'LibreOffice/7.6');
      expect(provenance.signals, isEmpty);
    });

    test('非 zip 容器或不支援的副檔名安全回傳 none，不丟例外', () {
      expect(
        DocumentProvenance.fromBytes(
          const [1, 2, 3, 4],
          extension: 'docx',
          bodyText: 'x',
        ).hasMetadata,
        isFalse,
      );
      expect(
        DocumentProvenance.fromBytes(
          _docx(totalMinutes: 5),
          extension: 'pdf',
          bodyText: 'x',
        ).hasMetadata,
        isFalse,
      );
      expect(DocumentProvenance.none.risk, ProvenanceRisk.unknown);
    });

    test('ISO 8601 期間解析涵蓋常見寫法', () {
      expect(DocumentProvenance.parseIso8601Duration('PT0S'), Duration.zero);
      expect(
        DocumentProvenance.parseIso8601Duration('PT45M'),
        const Duration(minutes: 45),
      );
      expect(DocumentProvenance.parseIso8601Duration('P0D'), Duration.zero);
      expect(DocumentProvenance.parseIso8601Duration('garbage'), isNull);
      expect(DocumentProvenance.parseIso8601Duration(''), isNull);
    });
  });

  group('訊號推導', () {
    test('編輯時長近乎 0 但有大量內容 → 強訊號', () {
      final provenance = DocumentProvenance.fromBytes(
        _docx(totalMinutes: 0, rsids: const ['00A1', '00B2', '00C3']),
        extension: 'docx',
        bodyText: _body(1200),
      );

      expect(
        provenance.signals.map((s) => s.kind),
        contains(ProvenanceSignalKind.negligibleEditingTime),
      );
      expect(provenance.risk, isNot(ProvenanceRisk.low));
    });

    test('打字速度超過常人上限 → 強訊號', () {
      // 1500 字 / 5 分鐘 = 300 wpm
      final provenance = DocumentProvenance.fromBytes(
        _docx(totalMinutes: 5, rsids: const ['00A1', '00B2', '00C3']),
        extension: 'docx',
        bodyText: _body(1500),
      );

      final signal = provenance.signals.firstWhere(
        (s) => s.kind == ProvenanceSignalKind.implausibleTypingSpeed,
      );
      expect(signal.values['wpm'], 300);
      expect(signal.severity, ProvenanceSeverity.strong);
    });

    test('正文編輯批次高度集中 + 只存檔一次 → 綜合判為高', () {
      final provenance = DocumentProvenance.fromBytes(
        _docx(totalMinutes: 60, revision: 1, rsids: const ['00A1']),
        extension: 'docx',
        bodyText: _body(1000),
      );

      final kinds = provenance.signals.map((s) => s.kind).toList();
      expect(kinds, contains(ProvenanceSignalKind.singleEditingSession));
      expect(kinds, contains(ProvenanceSignalKind.fewRevisions));
      expect(provenance.risk, ProvenanceRisk.high);
    });

    test('內容過短時不做任何推論，避免對短文誤報', () {
      final provenance = DocumentProvenance.fromBytes(
        _docx(totalMinutes: 0, revision: 1, rsids: const ['00A1']),
        extension: 'docx',
        bodyText: _body(20),
      );

      expect(provenance.signals, isEmpty);
      expect(provenance.risk, ProvenanceRisk.low);
    });

    test('正常寫作歷程不產生訊號（避免對真人作業誤報）', () {
      final provenance = DocumentProvenance.fromBytes(
        _docx(
          totalMinutes: 240,
          revision: 18,
          rsids: const ['00A1', '00B2', '00C3', '00D4', '00E5', '00F6'],
        ),
        extension: 'docx',
        bodyText: _body(2000),
      );

      expect(provenance.signals, isEmpty);
      expect(provenance.risk, ProvenanceRisk.low);
    });
  });

  group('AI 產生器宣告', () {
    test('Claude Docs 產生的 docx：產生器強訊號 + 程式產生，綜合判為高', () {
      // 實際案例：Application=Claude Docs、description 帶 node 簽章、
      // 正文沒有任何 RSID、沒有 TotalTime，但 revision=61。
      final provenance = DocumentProvenance.fromBytes(
        _docx(
          application: 'Claude Docs',
          revision: 61,
          wordParts: false,
          coreExtra:
              '<dc:description>Claude Docs node/c250b5e7@61 docx-w7'
              '</dc:description>',
        ),
        extension: 'docx',
        bodyText: _body(2000),
      );

      final kinds = provenance.signals.map((s) => s.kind).toList();
      expect(kinds, contains(ProvenanceSignalKind.aiGeneratorDeclared));
      expect(kinds, contains(ProvenanceSignalKind.programmaticallyGenerated));
      expect(provenance.declaredAiGenerator, 'Claude Docs');
      expect(provenance.risk, ProvenanceRisk.high);
      expect(provenance.indicatesHumanAuthorship, isFalse);
    });

    test('產生器宣告不受字數門檻限制', () {
      final provenance = DocumentProvenance.fromBytes(
        _docx(application: 'ChatGPT', rsids: const ['00A1']),
        extension: 'docx',
        bodyText: _body(20),
      );
      expect(provenance.declaresAiGenerator, isTrue);
    });

    test('描述欄位只認開頭的工具簽章，內文提到 AI 產品不算', () {
      final signature = DocumentProvenance.fromBytes(
        _docx(
          totalMinutes: 90,
          rsids: const ['00A1', '00B2', '00C3'],
          coreExtra: '<dc:description>ChatGPT export</dc:description>',
        ),
        extension: 'docx',
        bodyText: _body(600),
      );
      expect(signature.declaredAiGenerator, 'ChatGPT');

      final mention = DocumentProvenance.fromBytes(
        _docx(
          totalMinutes: 90,
          rsids: const ['00A1', '00B2', '00C3'],
          coreExtra:
              '<dc:description>大學生使用 ChatGPT 的研究</dc:description>'
              '<dc:creator>Claude Monet</dc:creator>',
        ),
        extension: 'docx',
        bodyText: _body(600),
      );
      expect(mention.declaresAiGenerator, isFalse);
      expect(mention.signals, isEmpty);
    });

    test('ODT generator 欄位與中文產品名稱也能比對', () {
      final provenance = DocumentProvenance.fromBytes(
        _odt(generator: '通義千問 文件匯出', editingDuration: 'PT2H', cycles: 9),
        extension: 'odt',
        bodyText: _body(600),
      );
      expect(provenance.declaresAiGenerator, isTrue);
    });

    test('宣稱是 Word 卻沒有 RSID 屬於紀錄被清除，不標為程式產生', () {
      final provenance = DocumentProvenance.fromBytes(
        _docx(revision: 8),
        extension: 'docx',
        bodyText: _body(800),
      );
      expect(
        provenance.signals.map((s) => s.kind),
        isNot(contains(ProvenanceSignalKind.programmaticallyGenerated)),
      );
    });
  });

  _formatCoverageTests();
  _legacyDocTests();

  group('字數計算', () {
    test('CJK 逐字計、拉丁語系以詞計', () {
      expect(DocumentProvenance.countWords('這是一份報告'), 6);
      expect(DocumentProvenance.countWords('hello world again'), 3);
      expect(DocumentProvenance.countWords('   '), 0);
    });
  });
}

void _formatCoverageTests() {
  group('格式覆蓋率', () {
    test('PDF／doc／txt 屬「格式本身不帶紀錄」，而非「被清除」', () {
      for (final ext in ['pdf', 'txt', 'md']) {
        final p = DocumentProvenance.fromBytes(
          const [1, 2, 3],
          extension: ext,
          bodyText: _body(500),
        );
        expect(
          p.availability,
          ProvenanceAvailability.unsupportedFormat,
          reason: '$ext 應標為格式不支援',
        );
        expect(p.sourceFormat, ext, reason: '需保留格式名以便向使用者說明');
        expect(p.hasMetadata, isFalse);
      }
    });

    test('docx 是支援格式但無紀錄時，屬「被清除」', () {
      // 有效 zip，但缺 docProps（模擬轉檔後被重置）
      final archive = Archive()
        ..addFile(_entry('word/document.xml', '<w:document/>'));
      final p = DocumentProvenance.fromBytes(
        ZipEncoder().encode(archive),
        extension: 'docx',
        bodyText: _body(500),
      );
      expect(p.availability, ProvenanceAvailability.stripped);
    });

    test('貼上文字／OCR 沒有副檔名，仍歸為格式不支援', () {
      expect(
        DocumentProvenance.none.availability,
        ProvenanceAvailability.unsupportedFormat,
      );
      expect(DocumentProvenance.none.sourceFormat, isEmpty);
    });

    test('有完整紀錄時為 available，且格式名保留', () {
      final p = DocumentProvenance.fromBytes(
        _docx(totalMinutes: 120, revision: 9, rsids: const ['A1', 'B2', 'C3']),
        extension: 'docx',
        bodyText: _body(800),
      );
      expect(p.availability, ProvenanceAvailability.available);
      expect(p.sourceFormat, 'docx');
    });

    test('帶編輯紀錄的格式為 docx／odt／doc', () {
      // .doc 走 OLE2 而非 zip，但同樣能取得編輯紀錄
      expect(DocumentProvenance.formatsWithEditingRecord, {
        'docx',
        'odt',
        'doc',
      });
    });
  });

  group('自動納入基準集的獨立證據', () {
    test('編輯歷程充足且無可疑訊號 → 可自動納入', () {
      final p = DocumentProvenance.fromBytes(
        _docx(
          totalMinutes: 240,
          revision: 18,
          rsids: const ['A1', 'B2', 'C3', 'D4', 'E5', 'F6'],
        ),
        extension: 'docx',
        bodyText: _body(2000),
      );
      expect(p.indicatesHumanAuthorship, isTrue);
    });

    test('任一可疑訊號存在即不納入', () {
      final p = DocumentProvenance.fromBytes(
        _docx(
          totalMinutes: 0,
          revision: 18,
          rsids: const ['A1', 'B2', 'C3', 'D4', 'E5', 'F6'],
        ),
        extension: 'docx',
        bodyText: _body(2000),
      );
      expect(p.signals, isNotEmpty);
      expect(p.indicatesHumanAuthorship, isFalse);
    });

    test('編輯時長或存檔次數不足即不納入', () {
      final short = DocumentProvenance.fromBytes(
        _docx(
          totalMinutes: 5,
          revision: 18,
          rsids: const ['A1', 'B2', 'C3', 'D4', 'E5', 'F6'],
        ),
        extension: 'docx',
        bodyText: _body(300),
      );
      expect(short.indicatesHumanAuthorship, isFalse, reason: '5 分鐘不足 20 分門檻');

      final fewSaves = DocumentProvenance.fromBytes(
        _docx(
          totalMinutes: 240,
          revision: 2,
          rsids: const ['A1', 'B2', 'C3', 'D4', 'E5', 'F6'],
        ),
        extension: 'docx',
        bodyText: _body(2000),
      );
      expect(fewSaves.indicatesHumanAuthorship, isFalse, reason: '2 次不足 3 次門檻');
    });

    test('無紀錄的格式一律不納入（PDF 不可能自動進基準集）', () {
      final p = DocumentProvenance.fromBytes(
        const [1, 2, 3],
        extension: 'pdf',
        bodyText: _body(2000),
      );
      expect(p.indicatesHumanAuthorship, isFalse);
    });
  });
}

/// 舊版 .doc 走的是 OLE2 而非 zip，需確認它真的接進了同一條來源證據管線
void _legacyDocTests() {
  group('舊版 .doc（OLE2）', () {
    test('.doc 已列入帶編輯紀錄的格式', () {
      expect(DocumentProvenance.formatsWithEditingRecord, contains('doc'));
    });

    test('無法解析的 .doc 歸為「紀錄被清除」而非「格式不支援」', () {
      // 已是支援格式，只是這份檔案讀不出紀錄
      final p = DocumentProvenance.fromBytes(
        List.filled(1024, 0x41),
        extension: 'doc',
        bodyText: _body(500),
      );
      expect(p.availability, ProvenanceAvailability.stripped);
      expect(p.sourceFormat, 'doc');
      expect(p.indicatesHumanAuthorship, isFalse);
    });

    test('壞掉的 .doc 不會讓匯入流程丟出例外', () {
      expect(
        () => DocumentProvenance.fromBytes(
          const [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1, 0x00],
          extension: 'doc',
          bodyText: _body(300),
        ),
        returnsNormally,
      );
    });
  });
}
