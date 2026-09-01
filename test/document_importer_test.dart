import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:truthlens/core/services/document_importer.dart';

void main() {
  group(
    'DocumentImporter (MVP 1 Code & Formula Shield, MVP 2 Noise Stripping)',
    () {
      test('MVP 1: 程式碼區塊與行內程式碼能被自動隔離抹除', () {
        const input = '''
這是一段常規說明文字。
```python
def calculate_loss(x, y):
    return (x - y) ** 2
```
這裡包含行內程式碼 `int main()` 與進一步討論。
''';
        expect(input, contains('calculate_loss'));

        final cleaned = input
            .replaceAll(RegExp(r'```[\s\S]*?```'), '')
            .replaceAll(RegExp(r'`[^`]+`'), '')
            .trim();
        expect(cleaned, isNot(contains('calculate_loss')));
        expect(cleaned, isNot(contains('int main()')));
        expect(cleaned, contains('這是一段常規說明文字。'));
      });

      test('MVP 1: LaTeX 數學公式與方程式區塊能被自動過濾', () {
        const input = '''
根據能量守恆定律，
公式如下：
\\begin{equation}
E = mc^2
\\end{equation}
結果如上所示。
''';
        final cleaned = input
            .replaceAll(
              RegExp(r'\\begin\{equation\}[\s\S]*?\\end\{equation\}'),
              '',
            )
            .trim();

        expect(cleaned, isNot(contains('mc^2')));
        expect(cleaned, contains('根據能量守恆定律，'));
        expect(cleaned, contains('結果如上所示。'));
      });

      test('MVP 2: PDF/DOCX 頁首頁尾與頁碼噪音可精準剔除', () {
        const input = '''
Page 1 of 12
第一章 緒論
本文針對內容檢測進行探討。
第 1 頁，共 12 頁
L105
Line 12
結論如上。
''';
        final cleaned = input
            .replaceAll(
              RegExp(
                r'^\s*(?:Page\s*\|?\s*\d+(?:\s*of\s*\d+)?|第\s*\d+\s*頁(?:\s*，?\s*共\s*\d+\s*頁)?)\s*$',
                caseSensitive: false,
                multiLine: true,
              ),
              '',
            )
            .replaceAll(
              RegExp(
                r'^\s*(?:Line|L)\s*\d+[\s:]*$',
                caseSensitive: false,
                multiLine: true,
              ),
              '',
            )
            .trim();

        expect(cleaned, isNot(contains('Page 1 of 12')));
        expect(cleaned, isNot(contains('第 1 頁，共 12 頁')));
        expect(cleaned, isNot(contains('L105')));
        expect(cleaned, contains('第一章 緒論'));
      });

      test('PDF 文字層可被抽取為可分析正文', () {
        final pdf = PdfDocument();
        final page = pdf.pages.add();
        page.graphics.drawString(
          'TruthLens PDF import should extract this readable paragraph for analysis.',
          PdfStandardFont(PdfFontFamily.helvetica, 12),
        );
        final bytes = pdf.saveSync();
        pdf.dispose();

        final text = DocumentImporter.parseBytes(bytes, extension: 'pdf');

        expect(text, contains('TruthLens PDF import'));
        expect(text, isNot(contains('startxref')));
        expect(text, isNot(contains('endobj')));
      });

      test('PDF 解析失敗時不應回退匯入原始 xref / obj 結構', () {
        final rawPdfLikeBytes =
            '''
%PDF-1.7
1 0 obj
<< /Type /Catalog >>
endobj
xref
0 2
0000000000 65535 f
0000000015 00000 n
0000000768 00000 n
0000000935 00000 n
0000000992 00000 n
trailer
<< /Root 1 0 R >>
startxref
935
%%EOF
'''
                .codeUnits;

        final text = DocumentImporter.parseBytes(
          rawPdfLikeBytes,
          extension: 'pdf',
        );

        expect(text, isEmpty);
      });

      test('正常中英文正文應通過 PDF 文字品質檢查', () {
        const text = '''
本研究探討人工智慧內容檢測的可靠度，並比較不同分析方法的結果。
The analysis includes readable words, complete sentences, and meaningful context
for validating an imported academic document before content detection begins.
''';

        expect(
          DocumentImporter.pdfTextQuality(text),
          greaterThanOrEqualTo(0.62),
        );
      });

      test('常見 UTF-8 誤解碼亂碼應被 PDF 文字品質檢查拒絕', () {
        const mojibake = '''
Ã¤Â¸Â­Ã¦â€“â€¡ Ã¥â€¦Â§Ã¥Â®Â¹ Ã¦ÂªÂ¢Ã¦Â¸Â¬ Ã§ÂµÂÃ¦Å¾Å“
â€œThis textâ€ contains repeated mojibake markers and broken punctuation.
Ã©Â€™â„¢Ã¨ÂªÂ¤ Ã¥Â­â€”Ã¥Å¾â€¹ Ã¦ËœÂ Ã¥Â°â€ž Ã¨Â®Â“Ã¥â€¦Â§Ã¥Â®Â¹Ã§â€žÂ¡Ã¦Â³â€¢Ã©â€“Â±Ã¨Â®â‚¬Ã£â‚¬â€š
''';

        expect(DocumentImporter.pdfTextQuality(mojibake), lessThan(0.62));
      });

      test('大量私用字元與單字碎片應被視為不可靠文字層', () {
        final fragmented = List.filled(24, '\uE001 x \uE002 y').join(' ');

        expect(DocumentImporter.pdfTextQuality(fragmented), lessThan(0.62));
      });

      test('舊版 .doc 二進位結構位元組不得被誤判為可用文字（避免亂碼進入分析）', () {
        // 模擬真實 OLE2/CFB 檔案的隨機結構性位元組（磁區表、屬性集等），
        // 而非任何有意義的文字內容。
        final random = List<int>.generate(4000, (i) => (i * 2654435761) % 256);

        final text = DocumentImporter.parseBytes(random, extension: 'doc');

        expect(text, isEmpty);
      });

      test('.doc 若能還原出通順文字仍應正常匯入', () {
        // 長度需超過 _parseLegacyDoc 內建的 50 字元下限，否則會回退到只掃
        // ASCII 可列印字元的 Heuristic 2，把中文內容整段清空。
        const original =
            '本研究探討人工智慧內容檢測的可靠度，並比較不同分析方法在中英文語料上的判定結果，'
            '同時討論後續可能的改進方向與應用建議，供後續研究者參考。';
        final utf16leBytes = <int>[];
        for (final rune in original.runes) {
          utf16leBytes.add(rune & 0xff);
          utf16leBytes.add((rune >> 8) & 0xff);
        }

        final text = DocumentImporter.parseBytes(
          utf16leBytes,
          extension: 'doc',
        );

        expect(text, contains('本研究探討人工智慧內容檢測'));
      });

      test('舊版 .doc 只從 OLE WordDocument 串流抽取候選正文', () {
        const original =
            'This WordDocument stream contains a readable academic paragraph '
            'about local document analysis, import reliability, and evidence '
            'quality. It should be selected instead of binary container data.';
        final encoded = <int>[];
        for (final codePoint in original.runes) {
          encoded.add(codePoint & 0xff);
          encoded.add((codePoint >> 8) & 0xff);
        }

        final bytes = _minimalOleDocWithWordDocumentStream(encoded);
        final text = DocumentImporter.parseBytes(bytes, extension: 'doc');

        expect(text, contains('This WordDocument stream contains'));
        expect(text, isNot(contains('Root Entry')));
      });

      test('舊版 .doc 透過 Word Binary piece table 抽取 Unicode 主文', () {
        const original =
            '第一章 緒論\n本研究探討人工智慧內容檢測的可靠度，並比較不同分析方法在中文與英文文件上的判讀結果。'
            '這段文字放在 WordDocument 的正文區，必須由 0Table 的 CLX piece table 指回來。';

        final bytes = _minimalOleDocWithPieceTable(original);
        final text = DocumentImporter.parseBytes(bytes, extension: 'doc');

        expect(text, contains('第一章 緒論'));
        expect(text, contains('必須由 0Table 的 CLX piece table 指回來'));
      });

      test('舊版 .doc 透過 Word Binary piece table 抽取壓縮英文主文', () {
        const original =
            'Chapter one introduces local document analysis and explains why '
            'legacy Word files need a piece table parser instead of raw stream '
            'scanning. This paragraph should be recovered as the main body.';

        final bytes = _minimalOleDocWithPieceTable(original, compressed: true);
        final text = DocumentImporter.parseBytes(bytes, extension: 'doc');

        expect(
          text,
          contains('Chapter one introduces local document analysis'),
        );
        expect(text, contains('piece table parser instead of raw stream'));
      });

      test('ODT（Google 文件匯出的 OpenDocument）可正確抽取分段文字', () {
        const contentXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<office:document-content xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0">
  <office:body>
    <office:text>
      <text:h text:style-name="Heading_1">研究標題：AI 內容檢測</text:h>
      <text:p>第一段說明研究背景與動機。</text:p>
      <text:p>第二段包含<text:span text:style-name="T1">粗體強調文字</text:span>與換行<text:line-break/>接續內容。</text:p>
    </office:text>
  </office:body>
</office:document-content>
''';

        final contentBytes = utf8.encode(contentXml);
        final archive = Archive()
          ..addFile(
            ArchiveFile('content.xml', contentBytes.length, contentBytes),
          );
        final bytes = ZipEncoder().encode(archive);

        final text = DocumentImporter.parseBytes(bytes, extension: 'odt');

        expect(text, contains('研究標題：AI 內容檢測'));
        expect(text, contains('第一段說明研究背景與動機。'));
        expect(text, contains('粗體強調文字'));
        expect(text, contains('接續內容。'));
        expect(text, isNot(contains('<text:')));
      });

      test('DOCX 保留實體段落、行內樣式與手動換行', () {
        const documentXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>第一段具有</w:t></w:r><w:r><w:t>粗體文字。</w:t></w:r></w:p>
    <w:p><w:r><w:t>Second paragraph keeps</w:t></w:r><w:r><w:tab/></w:r><w:r><w:t>its structure.</w:t></w:r></w:p>
    <w:p><w:r><w:t>Third line</w:t><w:br/><w:t>continues here.</w:t></w:r></w:p>
  </w:body>
</w:document>
''';
        final contentBytes = utf8.encode(documentXml);
        final archive = Archive()
          ..addFile(
            ArchiveFile('word/document.xml', contentBytes.length, contentBytes),
          );
        final bytes = ZipEncoder().encode(archive);

        final text = DocumentImporter.parseBytes(bytes, extension: 'docx');

        expect(text, contains('第一段具有粗體文字。\n\nSecond paragraph'));
        expect(text, contains('keeps\tits structure.'));
        expect(text, contains('Third line\ncontinues here.'));
      });

      test('DOCX 會還原十進位與十六進位 XML 字元實體', () {
        const documentXml = '''
<?xml version="1.0" encoding="UTF-8"?>
<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
  <w:body>
    <w:p><w:r><w:t>AI &#20839;&#23481; &#x6AA2;&#x6E2C;</w:t></w:r></w:p>
  </w:body>
</w:document>
''';
        final contentBytes = utf8.encode(documentXml);
        final archive = Archive()
          ..addFile(
            ArchiveFile('word/document.xml', contentBytes.length, contentBytes),
          );
        final bytes = ZipEncoder().encode(archive);

        final text = DocumentImporter.parseBytes(bytes, extension: 'docx');

        expect(text, 'AI 內容 檢測');
      });
    },
  );
}

List<int> _minimalOleDocWithPieceTable(String text, {bool compressed = false}) {
  const textOffset = 768;
  final textBytes = compressed ? text.codeUnits : _utf16Le(text);
  final wordDocument = Uint8List(textOffset + textBytes.length);
  final wordData = ByteData.sublistView(wordDocument);
  wordData.setUint16(0, 0xA5EC, Endian.little);
  wordData.setUint16(0x0A, 0, Endian.little); // 使用 0Table
  wordData.setUint32(0x01A2, 0, Endian.little); // fcClx
  final clx = _wordBinaryClx(
    charCount: text.length,
    fileOffset: textOffset,
    compressed: compressed,
  );
  wordData.setUint32(0x01A6, clx.length, Endian.little); // lcbClx
  wordDocument.setRange(textOffset, textOffset + textBytes.length, textBytes);

  return _minimalOleDocWithStreams({
    'WordDocument': wordDocument,
    '0Table': clx,
  });
}

Uint8List _wordBinaryClx({
  required int charCount,
  required int fileOffset,
  required bool compressed,
}) {
  const pieceTableLength = 16;
  final bytes = Uint8List(1 + 4 + pieceTableLength);
  final data = ByteData.sublistView(bytes);
  bytes[0] = 0x02;
  data.setUint32(1, pieceTableLength, Endian.little);
  data.setUint32(5, 0, Endian.little);
  data.setUint32(9, charCount, Endian.little);
  final rawFc = compressed ? 0x40000000 | (fileOffset * 2) : fileOffset;
  data.setUint32(15, rawFc, Endian.little);
  return bytes;
}

Uint8List _utf16Le(String text) {
  final bytes = Uint8List(text.runes.length * 2);
  final data = ByteData.sublistView(bytes);
  var index = 0;
  for (final rune in text.runes) {
    data.setUint16(index, rune, Endian.little);
    index += 2;
  }
  return bytes;
}

List<int> _minimalOleDocWithWordDocumentStream(List<int> streamBytes) {
  return _minimalOleDocWithStreams({
    'WordDocument': Uint8List.fromList(streamBytes),
  });
}

List<int> _minimalOleDocWithStreams(Map<String, Uint8List> streams) {
  const sectorSize = 512;
  const fatSector = 0;
  const directorySector = 1;
  const firstStreamSector = 2;
  final streamSectorCounts = streams.map(
    (name, bytes) =>
        MapEntry(name, (bytes.length + sectorSize - 1) ~/ sectorSize),
  );
  final sectorCount =
      2 + streamSectorCounts.values.fold<int>(0, (sum, count) => sum + count);
  final bytes = Uint8List((1 + sectorCount) * sectorSize);
  final data = ByteData.sublistView(bytes);

  const signature = [0xD0, 0xCF, 0x11, 0xE0, 0xA1, 0xB1, 0x1A, 0xE1];
  for (var i = 0; i < signature.length; i++) {
    bytes[i] = signature[i];
  }
  data.setUint16(30, 9, Endian.little);
  data.setUint16(32, 6, Endian.little);
  data.setUint32(44, 1, Endian.little);
  data.setUint32(48, directorySector, Endian.little);
  data.setUint32(56, 1, Endian.little);
  data.setUint32(60, 0xFFFFFFFE, Endian.little);
  data.setUint32(68, 0xFFFFFFFE, Endian.little);
  data.setUint32(76, fatSector, Endian.little);

  final fatOffset = sectorSize;
  for (var i = 0; i < sectorSize ~/ 4; i++) {
    data.setUint32(fatOffset + i * 4, 0xFFFFFFFF, Endian.little);
  }
  data.setUint32(fatOffset, 0xFFFFFFFD, Endian.little);
  data.setUint32(fatOffset + 4, 0xFFFFFFFE, Endian.little);

  final directoryOffset = (1 + directorySector) * sectorSize;
  _writeOleDirectoryEntry(
    bytes,
    data,
    directoryOffset,
    'Root Entry',
    type: 5,
    startSector: 0xFFFFFFFE,
    size: 0,
  );
  var index = 0;
  var nextSector = firstStreamSector;
  for (final entry in streams.entries) {
    final sector = nextSector;
    final streamBytes = entry.value;
    final count = streamSectorCounts[entry.key] ?? 0;
    for (var i = 0; i < count; i++) {
      final current = sector + i;
      final next = i == count - 1 ? 0xFFFFFFFE : current + 1;
      data.setUint32(fatOffset + current * 4, next, Endian.little);
    }
    _writeOleDirectoryEntry(
      bytes,
      data,
      directoryOffset + 128 * (index + 1),
      entry.key,
      type: 2,
      startSector: sector,
      size: streamBytes.length,
    );
    var sourceOffset = 0;
    var remaining = streamBytes.length;
    for (var i = 0; i < count; i++) {
      final chunkLength = remaining < sectorSize ? remaining : sectorSize;
      final streamOffset = (1 + sector + i) * sectorSize;
      bytes.setRange(
        streamOffset,
        streamOffset + chunkLength,
        streamBytes,
        sourceOffset,
      );
      sourceOffset += chunkLength;
      remaining -= chunkLength;
    }
    index += 1;
    nextSector += count;
  }
  return bytes;
}

void _writeOleDirectoryEntry(
  Uint8List bytes,
  ByteData data,
  int offset,
  String name, {
  required int type,
  required int startSector,
  required int size,
}) {
  final chars = [...name.codeUnits, 0];
  for (var i = 0; i < chars.length && i * 2 < 64; i++) {
    data.setUint16(offset + i * 2, chars[i], Endian.little);
  }
  data.setUint16(offset + 64, chars.length * 2, Endian.little);
  bytes[offset + 66] = type;
  data.setUint32(offset + 116, startSector, Endian.little);
  data.setUint32(offset + 120, size, Endian.little);
}
