import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/document_provenance.dart';

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
}) {
  final appXml = StringBuffer('<Properties>')
    ..write('<Application>$application</Application>');
  if (totalMinutes != null) appXml.write('<TotalTime>$totalMinutes</TotalTime>');
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
  coreXml.write('</cp:coreProperties>');

  // 每個 rsid 產生一個帶該批次標記的段落
  final paragraphs = rsids
      .map((r) => '<w:p w:rsidR="$r" w:rsidRDefault="$r"><w:t>x</w:t></w:p>')
      .join();
  final documentXml =
      '<w:document><w:body>$paragraphs<w:p><w:t>$bodyText</w:t></w:p>'
      '</w:body></w:document>';

  final archive = Archive()
    ..addFile(_entry('docProps/app.xml', appXml.toString()))
    ..addFile(_entry('docProps/core.xml', coreXml.toString()))
    ..addFile(_entry('word/document.xml', documentXml));
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
    meta.write('<meta:editing-duration>$editingDuration</meta:editing-duration>');
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

      expect(provenance.editingDuration, const Duration(hours: 1, minutes: 24, seconds: 30));
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

  group('字數計算', () {
    test('CJK 逐字計、拉丁語系以詞計', () {
      expect(DocumentProvenance.countWords('這是一份報告'), 6);
      expect(DocumentProvenance.countWords('hello world again'), 3);
      expect(DocumentProvenance.countWords('   '), 0);
    });
  });
}
