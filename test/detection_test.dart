import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/utils/text_stats.dart';

void main() {
  group('PreprocessedText', () {
    test('英文斷句與斷詞', () {
      final t = PreprocessedText.from(
          'This is a test. It has three sentences! Right?');
      expect(t.sentences.length, 3);
      expect(t.sentenceTokens.first, ['this', 'is', 'a', 'test']);
    });

    test('中文斷句與逐字斷詞', () {
      final t = PreprocessedText.from('這是測試。第二句話！');
      expect(t.sentences.length, 2);
      expect(t.sentenceTokens.first, ['這', '是', '測', '試']);
    });

    test('空文本不崩潰', () {
      final t = PreprocessedText.from('');
      expect(t.sentences, isEmpty);
      expect(t.burstiness, 0);
      expect(t.typeTokenRatio, 0);
      expect(t.entropy, 0);
    });

    test('burstiness：均勻句長低於起伏句長', () {
      final uniform = PreprocessedText.from(
          'One two three four five. Six seven eight nine ten. '
          'Ala bee cee dee eee. Fff ggg hhh iii jjj.');
      final varied = PreprocessedText.from(
          'Short. This sentence is quite a bit longer than the previous one indeed. '
          'Hm. Another moderately sized sentence follows here now.');
      expect(uniform.burstiness, lessThan(varied.burstiness));
    });
  });

  group('Verdict', () {
    test('五級分類界線', () {
      expect(Verdict.fromProbability(0.1), Verdict.human);
      expect(Verdict.fromProbability(0.3), Verdict.likelyHuman);
      expect(Verdict.fromProbability(0.5), Verdict.mixed);
      expect(Verdict.fromProbability(0.7), Verdict.likelyAi);
      expect(Verdict.fromProbability(0.9), Verdict.ai);
    });
  });

  group('EnsembleOrchestrator', () {
    test('產出完整結果且分數在合法區間', () async {
      final result = await EnsembleOrchestrator().analyze(
        '此外，人工智慧正在改變世界。值得注意的是，這項技術發展迅速。'
        '首先，我們需要了解其原理。其次，我們必須評估其影響。'
        '綜上所述，人工智慧的未來充滿可能性。',
      );
      expect(result.aiProbability, inInclusiveRange(0.0, 1.0));
      expect(result.engineScores.length, 4);
      expect(result.sentences.length, 5);
    });

    test('不可用引擎不參與投票', () async {
      final result = await EnsembleOrchestrator().analyze(
        'The quick brown fox jumps over the lazy dog. '
        'Pack my box with five dozen liquor jugs today.',
      );
      final unavailable =
          result.engineScores.where((s) => !s.available).toList();
      expect(unavailable.map((s) => s.engineId),
          containsAll(['transformer', 'adversarial']));
    });

    test('進度回呼依引擎觸發', () async {
      final done = <String>[];
      await EnsembleOrchestrator().analyze(
        'A sentence for testing callbacks. Another one here.',
        onEngineDone: done.add,
      );
      expect(done.length, 4);
    });

    test('信心閾值影響 flaggedAsAi 但不影響機率', () async {
      const text = '此外，人工智慧正在改變世界。值得注意的是，這項技術發展迅速。'
          '首先，我們需要了解其原理。其次，我們必須評估其影響。'
          '綜上所述，人工智慧的未來充滿可能性。';
      final low = await EnsembleOrchestrator().analyze(text, threshold: 0.3);
      final high = await EnsembleOrchestrator().analyze(text, threshold: 0.95);

      expect(low.aiProbability, closeTo(high.aiProbability, 0.0001));
      expect(low.threshold, 0.3);
      expect(high.threshold, 0.95);
      // 高閾值更難被標記為 AI（降低偽陽性）
      expect(low.flaggedAsAi, isTrue);
      expect(high.flaggedAsAi, isFalse);
    });
  });
}
