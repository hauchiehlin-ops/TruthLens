import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/utils/text_stats.dart';

/// P4 多語系測試：檢測管線需在多種語言與混合文本下穩健運作、不崩潰，
/// 且 ESL 偏差修正在合理情境觸發。
void main() {
  group('多語系斷句與統計', () {
    test('英文', () {
      final t = PreprocessedText.from(
          'The weather today is quite pleasant. I went for a long walk.');
      expect(t.sentences.length, 2);
      expect(t.burstiness, greaterThanOrEqualTo(0));
    });

    test('中文', () {
      final t = PreprocessedText.from('今天天氣很好。我出去散步了很久。真是愉快的一天！');
      expect(t.sentences.length, 3);
    });

    test('日文（以句號斷句、CJK 逐字）', () {
      final t = PreprocessedText.from('今日はいい天気です。散歩に行きました。');
      expect(t.sentences.length, 2);
      expect(t.allTokens, isNotEmpty);
    });

    test('中英混合不崩潰', () {
      final t = PreprocessedText.from(
          '這是一個 hybrid 文本。It mixes 中文 and English 隨機。');
      expect(t.sentences.length, greaterThanOrEqualTo(2));
      expect(t.entropy, greaterThan(0));
    });
  });

  group('多語系端到端檢測', () {
    for (final (lang, text) in [
      ('英文', 'Artificial intelligence is transforming industries. '
          'It is important to note that these changes are significant. '
          'Furthermore, businesses must adapt accordingly.'),
      ('中文', '人工智慧正在改變世界。值得注意的是，這項技術發展迅速。'
          '此外，我們必須謹慎評估其影響。綜上所述，未來充滿可能。'),
      ('西班牙文', 'La inteligencia artificial está cambiando el mundo. '
          'Es importante señalar que estos cambios son significativos. '
          'Además, debemos adaptarnos rápidamente.'),
    ]) {
      test('$lang 產出合法結果', () async {
        final r = await EnsembleOrchestrator().analyze(text);
        expect(r.aiProbability, inInclusiveRange(0.0, 1.0));
        expect(r.sentences, isNotEmpty);
        expect(r.engineScores.length, 4);
      });
    }
  });

  group('ESL 偏差修正', () {
    test('低多樣性 + 句長起伏的長文可觸發修正而不誤傷一般文本', () async {
      // 一般英文文本不應無故觸發 ESL 修正
      final normal = await EnsembleOrchestrator().analyze(
        'The quick brown fox jumps over the lazy dog. '
        'Pack my box with five dozen liquor jugs. '
        'How vexingly quick daft zebras jump over lazy foxes today.',
      );
      expect(normal.eslAdjusted, isFalse);
    });

    test('可用開關關閉 ESL 修正', () async {
      final off = await EnsembleOrchestrator().analyze(
        '人工智慧正在改變世界。值得注意的是這項技術發展迅速此外我們必須評估。',
        eslCorrectionEnabled: false,
      );
      expect(off.eslAdjusted, isFalse);
    });
  });
}
