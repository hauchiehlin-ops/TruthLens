import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart' show Rect;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:truthlens/core/utils/language_id.dart';
import 'package:truthlens/core/utils/text_stats.dart';

/// PDF 抽取必須保留單字之間的空白。
///
/// 實際發生過：Syncfusion 的預設抽取模式會把空白全部吃掉，
/// 同一篇論文抽出 `InternationalJournalofBifurcationandChaos`。後果是全面性的，
/// 而且**不會有任何錯誤訊息**——分析照跑，只是每個環節都吃到黏在一起的文字：
///
/// - 語言辨識判為未定 → 困惑度整項被棄用 → 一份支持人類的證據消失，分數往 AI 漂
/// - 詞彙多樣性虛高（每個黏字串都是唯一詞）→ 誤觸「偏人類」規則
/// - 突發性與 Transformer 斷詞同樣失真
///
/// 因此以「平均詞長」與「功能詞佔比」把關：這兩個指標對黏字極度敏感，
/// 而正常英文散文的值相當穩定。
void main() {
  const sentence =
      'The lowest stability boundary on the flow of concentric rotating '
      'cylinders was examined across a range of radius ratios, and the '
      'results are compared with the predictions of the linear theory.';

  List<String> wordsOf(String text) =>
      RegExp(r'[A-Za-zÀ-ÿĀ-ſ]+').allMatches(text).map((m) => m[0]!).toList();

  double averageWordLength(String text) {
    final words = wordsOf(text);
    if (words.isEmpty) return 0;
    return words.fold<int>(0, (sum, w) => sum + w.length) / words.length;
  }

  test('自建 PDF 抽取後仍保留單字邊界', () {
    final document = PdfDocument();
    final page = document.pages.add();
    page.graphics.drawString(
      sentence,
      PdfStandardFont(PdfFontFamily.helvetica, 12),
      bounds: const Rect.fromLTWH(0, 0, 500, 400),
    );
    final bytes = document.saveSync();
    document.dispose();

    final reopened = PdfDocument(inputBytes: bytes);
    final extracted = PdfTextExtractor(reopened).extractText(layoutText: true);
    reopened.dispose();

    expect(extracted, contains('stability boundary'));
    expect(
      averageWordLength(extracted),
      lessThan(8),
      reason: '平均詞長偏高代表單字被黏在一起，正常英文散文約 4–6',
    );
  });

  group('真實學術 PDF 的抽取結果（以 App 實際路徑產生）', () {
    late String paper;

    setUpAll(() {
      paper = File('test/fixtures/ijbc_paper.txt').readAsStringSync();
    });

    test('平均詞長落在正常英文散文的範圍', () {
      // 黏字時此值為 12.4；保留空白時為 4.5
      expect(averageWordLength(paper), lessThan(7));
    });

    test('英文功能詞佔比足以支撐語言辨識', () {
      const functionWords = {
        'the',
        'of',
        'and',
        'to',
        'in',
        'is',
        'that',
        'for',
        'it',
        'as',
        'with',
        'was',
        'this',
        'be',
        'are',
        'from',
        'which',
        'have',
        'not',
        'on',
      };
      final words = wordsOf(paper).map((w) => w.toLowerCase()).toList();
      final share = words.where(functionWords.contains).length / words.length;
      // 黏字時僅 1.42%，遠低於辨識所需的 6%
      expect(share, greaterThan(0.10));
    });

    test('語言判為英文，困惑度才不會被整項棄用', () {
      expect(detectLanguage(paper).code, 'en');
      expect(PreprocessedText.from(paper).language.code, 'en');
    });
  });
}
