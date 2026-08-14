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
    },
  );
}
