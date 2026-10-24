import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/document_provenance.dart';
import 'package:omnitrace/core/services/file_forensics.dart';

/// Word 實際寫出的設定與字型表內容（相容性設定、至少一個字型），
/// 空殼部件會被判為洗滌痕跡
const _wordSettings =
    '<w:settings><w:compat><w:compatSetting w:name="compatibilityMode" w:uri="http://schemas.microsoft.com/office/word" w:val="15"/></w:compat></w:settings>';
const _wordFonts =
    '<w:fonts><w:font w:name="Calibri"><w:panose1 w:val="020F0502020204030204"/></w:font></w:fonts>';

String _body(int words) => List.filled(words, 'word').join(' ');

/// 最小但結構合法的 PDF：資訊字典放在未壓縮物件中
List<int> _pdf({String info = '', String xmp = ''}) => latin1.encode(
  '%PDF-1.4\n'
  '1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj\n'
  '2 0 obj << /Type /Pages /Kids [] /Count 0 >> endobj\n'
  '3 0 obj << $info >> endobj\n'
  '${xmp.isEmpty ? '' : '4 0 obj << /Type /Metadata /Subtype /XML >> stream\n$xmp\nendstream endobj\n'}'
  'trailer << /Root 1 0 R /Info 3 0 R >>\n%%EOF',
);

/// UTF-16BE 十六進位字串，PDF 寫入非 ASCII 產生器名稱的方式
String _hexUtf16(String value) {
  final buffer = StringBuffer('<FEFF');
  for (final unit in value.codeUnits) {
    buffer.write(unit.toRadixString(16).padLeft(4, '0').toUpperCase());
  }
  return '$buffer>';
}

List<int> _docx({
  String application = 'Microsoft Office Word',
  String core = '',
  String document = '',
  String styles = '',
  bool wordParts = true,
  Map<String, List<int>> media = const {},
}) {
  List<int> b(String s) => utf8.encode(s);
  final archive = Archive()
    ..addFile(
      ArchiveFile.bytes(
        'docProps/app.xml',
        b(
          '<Properties><Application>$application</Application>'
          '<TotalTime>120</TotalTime></Properties>',
        ),
      ),
    )
    ..addFile(
      ArchiveFile.bytes(
        'docProps/core.xml',
        b(
          '<cp:coreProperties><cp:revision>9</cp:revision>$core'
          '</cp:coreProperties>',
        ),
      ),
    )
    ..addFile(
      ArchiveFile.bytes(
        'word/document.xml',
        b(
          '<w:document><w:body>'
          '<w:p w:rsidR="00A1"><w:t>a</w:t></w:p>'
          '<w:p w:rsidR="00B2"><w:t>b</w:t></w:p>'
          '<w:p w:rsidR="00C3"><w:t>c</w:t></w:p>'
          '$document</w:body></w:document>',
        ),
      ),
    );
  if (styles.isNotEmpty) {
    archive.addFile(ArchiveFile.bytes('word/styles.xml', b(styles)));
  }
  if (wordParts) {
    archive
      ..addFile(ArchiveFile.bytes('word/settings.xml', b(_wordSettings)))
      ..addFile(ArchiveFile.bytes('word/fontTable.xml', b(_wordFonts)));
  }
  for (final e in media.entries) {
    archive.addFile(ArchiveFile.bytes('word/media/${e.key}', e.value));
  }
  return ZipEncoder().encode(archive);
}

/// 帶有 C2PA 清單的 PNG 片段：caBX 區塊中的 JUMBF，標籤 c2pa，
/// claim_generator 以 CBOR 文字字串保存
List<int> _pngWithC2pa(String generator) {
  final cbor = [0x60 + generator.length, ...latin1.encode(generator)];
  return [
    ...[0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A],
    ...latin1.encode('caBXjumb'),
    ...latin1.encode('jumdc2pa'),
    ...latin1.encode('claim_generator'),
    ...cbor,
  ];
}

Set<ProvenanceSignalKind> _kinds(DocumentProvenance p) =>
    p.signals.map((s) => s.kind).toSet();

void main() {
  group('A. PDF 產生器欄位', () {
    test('資訊字典宣告 AI 產品 → 產生器強訊號', () {
      final p = DocumentProvenance.fromBytes(
        _pdf(info: '/Creator (Claude Docs) /Producer (Skia/PDF m128)'),
        extension: 'pdf',
        bodyText: _body(600),
      );
      expect(p.declaredAiGenerator, 'Claude Docs');
      expect(p.risk, ProvenanceRisk.medium);
      expect(p.availability, ProvenanceAvailability.available);
    });

    test('UTF-16 十六進位字串與跳脫字元都能解碼', () {
      final meta = PdfMetadata.parse(
        _pdf(
          info:
              '/Creator ${_hexUtf16('通義千問 匯出')} '
              r'/Producer (ReportLab PDF Library \050www.reportlab.com\051)',
        ),
      );
      expect(meta.creator, '通義千問 匯出');
      expect(meta.producer, 'ReportLab PDF Library (www.reportlab.com)');
    });

    test('程式庫產生 → 只是佐證，不推向 AI', () {
      final p = DocumentProvenance.fromBytes(
        _pdf(info: '/Producer (ReportLab PDF Library - www.reportlab.com)'),
        extension: 'pdf',
        bodyText: _body(600),
      );
      expect(_kinds(p), {ProvenanceSignalKind.programmaticLibrary});
      expect(p.signals.single.label, 'ReportLab');
      expect(p.declaresAiGenerator, isFalse);
      expect(p.risk, ProvenanceRisk.low);
    });

    test('XMP CreatorTool 也能讀到', () {
      final p = DocumentProvenance.fromBytes(
        _pdf(
          xmp:
              '<x:xmpmeta><xmp:CreatorTool>ChatGPT</xmp:CreatorTool></x:xmpmeta>',
        ),
        extension: 'pdf',
        bodyText: _body(600),
      );
      expect(p.declaredAiGenerator, 'ChatGPT');
    });

    test('真人常用工具（Chrome 列印、LaTeX、Word 轉存）不產生訊號', () {
      for (final info in const [
        '/Producer (Skia/PDF m128)',
        '/Creator (LaTeX with hyperref) /Producer (pdfTeX-1.40.25)',
        '/Creator (Microsoft Word for Microsoft 365) /Producer (Microsoft Word for Microsoft 365)',
        '/Producer (macOS Version 15.0 \\(Build 24A335\\) Quartz PDFContext)',
        // 出版社加下載浮水印與 Word 外掛：實測 503 份論文中誤標 40 篇的來源
        '/Producer (Acrobat Distiller 9.0 \\(Windows\\); modified using iText 4.2.0 by 1T3XT)',
        '/Creator (Acrobat PDFMaker 23 for Word) /Producer (Adobe PDF Library 23.1.175)',
        '/Producer (pdftk 1.12 - www.pdftk.com)',
      ]) {
        final p = DocumentProvenance.fromBytes(
          _pdf(info: info),
          extension: 'pdf',
          bodyText: _body(600),
        );
        expect(p.signals, isEmpty, reason: info);
      }
    });

    test('PDF 函式庫補上的值（壓縮物件串流）優先採用', () {
      final p = DocumentProvenance.fromBytes(
        _pdf(),
        extension: 'pdf',
        bodyText: _body(600),
        pdfMetadata: const PdfMetadata(
          producer: 'pdf-lib (https://github.com/Hopding/pdf-lib)',
        ),
      );
      expect(_kinds(p), contains(ProvenanceSignalKind.programmaticLibrary));
    });

    test('沒有任何產生器欄位時仍標示格式不帶編輯紀錄', () {
      final p = DocumentProvenance.fromBytes(
        latin1.encode('%PDF-1.4\n%%EOF'),
        extension: 'pdf',
        bodyText: _body(600),
      );
      expect(p.hasMetadata, isFalse);
      expect(p.availability, ProvenanceAvailability.unsupportedFormat);
    });
  });

  group('B. DOCX 封裝指紋', () {
    test('宣稱 Word 卻缺少設定與字型表 → 名稱冒用', () {
      final p = DocumentProvenance.fromBytes(
        _docx(wordParts: false),
        extension: 'docx',
        bodyText: _body(600),
      );
      final mismatch = p.signals.firstWhere(
        (s) => s.kind == ProvenanceSignalKind.generatorMismatch,
      );
      expect(mismatch.label, 'Microsoft Office Word');
    });

    test('非 Word 且只有最少部件 → 程式產生（即使有 RSID 與編輯時間）', () {
      final p = DocumentProvenance.fromBytes(
        _docx(application: 'SomeExporter', wordParts: false),
        extension: 'docx',
        bodyText: _body(600),
      );
      expect(
        _kinds(p),
        contains(ProvenanceSignalKind.programmaticallyGenerated),
      );
    });

    test('python-docx 寫出的檔案標示程式庫', () {
      final p = DocumentProvenance.fromBytes(
        _docx(core: '<dc:creator>python-docx</dc:creator>'),
        extension: 'docx',
        bodyText: _body(600),
      );
      expect(p.signals.single.kind, ProvenanceSignalKind.programmaticLibrary);
      expect(p.signals.single.label, 'python-docx');
    });

    test('完整的 Word 封裝不產生封裝訊號', () {
      final p = DocumentProvenance.fromBytes(
        _docx(),
        extension: 'docx',
        bodyText: _body(600),
      );
      expect(p.signals, isEmpty);
    });
  });

  group('C. 網頁貼上殘留', () {
    test('三段以上 Normal (Web) → 網頁貼上', () {
      final p = DocumentProvenance.fromBytes(
        _docx(
          document: List.filled(
            4,
            '<w:p><w:pPr><w:pStyle w:val="NormalWeb"/></w:pPr><w:t>x</w:t></w:p>',
          ).join(),
        ),
        extension: 'docx',
        bodyText: _body(600),
      );
      final paste = p.signals.firstWhere(
        (s) => s.kind == ProvenanceSignalKind.webPasteResidue,
      );
      expect(paste.values['count'], 4);
      expect(p.declaresAiGenerator, isFalse);
    });

    test('一兩段手動套用的 Normal (Web) 不算', () {
      final residue = WebPasteResidue.scan(
        document: '<w:pStyle w:val="NormalWeb"/><w:pStyle w:val="NormalWeb"/>',
      );
      expect(residue.indicatesWebPaste, isFalse);
    });

    test('altChunk 或 CSS 字型堆疊即構成貼上跡象', () {
      expect(
        WebPasteResidue.scan(
          document: '<w:altChunk r:id="x"/>',
        ).indicatesWebPaste,
        isTrue,
      );
      expect(
        WebPasteResidue.scan(
          document:
              '<w:rFonts w:ascii="ui-sans-serif" w:hAnsi="ui-sans-serif"/>',
        ).webFontStack,
        'ui-sans-serif',
      );
    });

    test('對話介面字型（Söhne）另列一項', () {
      final p = DocumentProvenance.fromBytes(
        _docx(styles: '<w:rFonts w:ascii="Söhne" w:hAnsi="Söhne"/>'),
        extension: 'docx',
        bodyText: _body(600),
      );
      final font = p.signals.firstWhere(
        (s) => s.kind == ProvenanceSignalKind.chatInterfaceFont,
      );
      expect(font.label, 'Söhne');
      // 字型只說明貼上來源，不足以單獨推向 AI
      expect(p.declaresAiGenerator, isFalse);
    });

    test('Word 內建字型不誤判', () {
      final residue = WebPasteResidue.scan(
        document:
            '<w:rFonts w:ascii="Calibri" w:eastAsia="新細明體" w:cs="Segoe UI"/>',
      );
      expect(residue.indicatesWebPaste, isFalse);
      expect(residue.chatInterfaceFont, isNull);
    });
  });

  group('D. C2PA 內容憑證', () {
    test('內嵌圖片的 C2PA 讀出產生工具，但只列為資訊、不影響風險', () {
      final p = DocumentProvenance.fromBytes(
        _docx(media: {'image1.png': _pngWithC2pa('ChatGPT/1.0')}),
        extension: 'docx',
        bodyText: _body(600),
      );
      final c2pa = p.signals.single;
      expect(c2pa.kind, ProvenanceSignalKind.embeddedC2pa);
      expect(c2pa.severity, ProvenanceSeverity.info);
      expect(c2pa.label, 'ChatGPT/1.0');
      expect(p.risk, ProvenanceRisk.low);
      expect(p.declaresAiGenerator, isFalse);
    });

    test('沒有 JUMBF 方塊時不誤報（文字中提到 c2pa 不算）', () {
      expect(
        C2paFinding.scan(latin1.encode('this paper discusses c2pa')),
        isNull,
      );
    });

    test('一般 PNG 沒有憑證', () {
      expect(
        C2paFinding.scan([
          0x89,
          0x50,
          0x4E,
          0x47,
          ...latin1.encode('IHDRIDATIEND'),
        ]),
        isNull,
      );
    });
  });
}
