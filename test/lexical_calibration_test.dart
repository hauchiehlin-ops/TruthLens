import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/lexical_calibration.dart';
import 'package:truthlens/core/utils/text_stats.dart';

/// 原始 TTR 有兩個獨立的缺陷，兩個都會讓判定與內容無關：
/// 1. 隨文件長度下降（同一篇論文 0.584 → 0.405）
/// 2. 門檻是英文詞級的值，套在中文字級上（`ttr<0.40` 對中文真人誤觸 42.5%）
void main() {
  late String paper;

  setUpAll(() {
    paper = File('test/fixtures/ijbc_paper.txt').readAsStringSync();
  });

  group('MATTR 的長度不變性', () {
    test('同一份文件在不同長度下 MATTR 幾乎不變，TTR 則明顯漂移', () {
      final fractions = [0.15, 0.35, 0.6, 1.0];
      final mattr = <double>[];
      final ttr = <double>[];
      for (final f in fractions) {
        final t = PreprocessedText.from(
          paper.substring(0, (paper.length * f).round()),
        );
        mattr.add(t.movingAverageTypeTokenRatio);
        ttr.add(t.typeTokenRatio);
      }

      final mattrSpread =
          mattr.reduce((a, b) => a > b ? a : b) -
          mattr.reduce((a, b) => a < b ? a : b);
      final ttrSpread =
          ttr.reduce((a, b) => a > b ? a : b) -
          ttr.reduce((a, b) => a < b ? a : b);

      expect(mattrSpread, lessThan(0.05), reason: 'MATTR 應與長度無關');
      expect(ttrSpread, greaterThan(0.15), reason: 'TTR 確實隨長度漂移');
      expect(mattrSpread, lessThan(ttrSpread / 3));
    });

    test('詞元數不足一個窗口時退回 TTR，不崩潰', () {
      final short = PreprocessedText.from(
        'This is a short passage with fewer tokens than the window.',
      );
      expect(short.movingAverageTypeTokenRatio, short.typeTokenRatio);
      expect(PreprocessedText.from('').movingAverageTypeTokenRatio, 0);
    });
  });

  group('逐語言門檻', () {
    test('中英文各有實測門檻，且中文較低（字級計詞的基準本就不同）', () {
      final zh = LexicalCalibration.of('zh');
      final en = LexicalCalibration.of('en');
      expect(zh, isNotNull);
      expect(en, isNotNull);
      expect(zh!.aiCut, lessThan(en!.aiCut));
    });

    test('未校準的語言查不到，呼叫端必須不採計此指標', () {
      for (final code in ['ja', 'ko', 'th', 'ru', 'fr', 'de', 'und']) {
        expect(LexicalCalibration.of(code), isNull, reason: code);
      }
    });

    test('沒有人類側門檻——高詞彙多樣性不作為人類證據', () {
      // 現代 LLM 中文輸出 MATTR 0.783–0.802，高於真人中位 0.669。
      // 若把高多樣性當成人類證據，等於主動把 AI 推向人類。
      for (final lang in LexicalCalibration.calibratedLanguages) {
        final t = LexicalCalibration.of(lang);
        if (t == null) continue;
        // 型別上就沒有 humanCut 欄位可用，這裡確認門檻落在合理區間
        expect(t.aiCut, inInclusiveRange(0.3, 0.9));
        expect(t.auc, greaterThanOrEqualTo(LexicalThresholds.minimumUsableAuc));
      }
    });
  });

  test('真實英文論文的 MATTR 高於 AI 側切點，不會被誤判', () {
    final t = PreprocessedText.from(paper);
    expect(t.language.code, 'en');
    expect(
      t.movingAverageTypeTokenRatio,
      greaterThan(LexicalCalibration.of('en')!.aiCut),
      reason: '一篇真人論文不該因用詞多樣性被推向 AI',
    );
    // 對照：原始 TTR 全文時為 0.405，逼近舊門檻 0.40，
    // 再長一點就會純粹因為長度被判為偏 AI
    expect(t.typeTokenRatio, lessThan(0.45));
  });
}
