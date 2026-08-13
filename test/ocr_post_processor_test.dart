import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/utils/ocr_post_processor.dart';

void main() {
  group('OcrPostProcessor', () {
    test('消除 CJK 中文字元間的多餘空格', () {
      const input = '這 是 一 個 標 準 的 中 文 研 究 報 告 內 文';
      final cleaned = OcrPostProcessor.clean(input);
      expect(cleaned, equals('這是一個標準的中文研究報告內文'));
    });

    test('保留中英文混排中英文單字前後的正常空格', () {
      const input = '本 研究 使用 了 ChatGPT 與 Claude 進行 實驗';
      final cleaned = OcrPostProcessor.clean(input);
      expect(cleaned, equals('本研究使用了 ChatGPT 與 Claude 進行實驗'));
    });

    test('修復英文跨行連字號', () {
      const input =
          'The artificial in-\ntelligence model demonstrated high accuracy.';
      final cleaned = OcrPostProcessor.clean(input);
      expect(
        cleaned,
        equals('The artificial intelligence model demonstrated high accuracy.'),
      );
    });

    test('清理 CJK 與全形標點符號間的空格', () {
      const input = '結論 如下 ： 第一 ， 數據 顯著 ； 第二 ， 結果 成立 。';
      final cleaned = OcrPostProcessor.clean(input);
      expect(cleaned, equals('結論如下：第一，數據顯著；第二，結果成立。'));
    });

    test('限制過多連續空行', () {
      const input = '第一段\n\n\n\n\n第二段';
      final cleaned = OcrPostProcessor.clean(input);
      expect(cleaned, equals('第一段\n\n第二段'));
    });

    test('修復學術 OCR/PDF 常見連寫與標點漏空格', () {
      const input =
          '```text\n'
          'Taylor,G.I.,“Stabilityofa Viscous Liquid Containedbetween Two Rotating Cylinders,”'
          'Journalof Fluid Mechanics 7:401-418(1960).\n'
          'Lope,J.M.,“Dynamics of Three-tori ina Periodically Forced Navier-Stokes Flow,”'
          'Physical Review Letters 85:972-975(2001).\n'
          '```';
      final cleaned = OcrPostProcessor.clean(input);

      expect(cleaned, isNot(contains('```')));
      expect(cleaned, contains('Taylor, G. I.'));
      expect(
        cleaned,
        contains(
          'Stability of a Viscous Liquid Contained between Two Rotating Cylinders',
        ),
      );
      expect(cleaned, contains('Journal of Fluid Mechanics 7: 401-418'));
      expect(cleaned, contains('Dynamics of Three-tori In a Periodically'));
      expect(cleaned, contains('Physical Review Letters 85: 972-975'));
    });

    test('保留正常英文單字，不把 Transition 或 Simon 誤切成尾隨介詞', () {
      const input =
          'Transition in circular Couette flow. Simon, N.J., and Donnelly, R.J. '
          'Plain language remains intact within the final report.';
      final cleaned = OcrPostProcessor.clean(input);

      expect(cleaned, contains('Transition in circular Couette flow'));
      expect(cleaned, contains('Simon'));
      expect(cleaned, isNot(contains('Transiti on')));
      expect(cleaned, isNot(contains('Sim on')));
      expect(cleaned, contains('Plain language'));
      expect(cleaned, contains('within the final report'));
    });

    test('正規化 OCR 常見 ligature 與不可斷行空格', () {
      const input = 'The ﬁnal ﬂow model uses non\u00A0reversing modulation.';
      final cleaned = OcrPostProcessor.clean(input);
      expect(
        cleaned,
        equals('The final flow model uses non reversing modulation.'),
      );
    });
  });
}
