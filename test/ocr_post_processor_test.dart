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
      const input = 'The artificial in-\ntelligence model demonstrated high accuracy.';
      final cleaned = OcrPostProcessor.clean(input);
      expect(cleaned, equals('The artificial intelligence model demonstrated high accuracy.'));
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
  });
}
