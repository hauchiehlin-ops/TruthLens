import 'dart:convert';

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
    },
  );
}
