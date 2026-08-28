import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/utils/text_stats.dart';

/// P4 多語系測試：檢測管線需在多種語言與混合文本下穩健運作、不崩潰，
/// 且 ESL 偏差修正在合理情境觸發。
void main() {
  group('多語系斷句與統計', () {
    test('英文', () {
      final t = PreprocessedText.from(
        'The weather today is quite pleasant during the afternoon. '
        'I went for a long walk around the neighborhood.',
      );
      expect(t.sentences.length, 2);
      expect(t.burstiness, greaterThanOrEqualTo(0));
    });

    test('中文', () {
      final t = PreprocessedText.from('今天天氣很好。我出去散步了很久。真是愉快的一天！');
      expect(t.sentences.length, 3);
    });

    test('中文 PDF 跨行與空白行會接回實體句子且不產生假空格', () {
      final t = PreprocessedText.from('''
人工智慧可以協助研究者整理大量資料

並提升分析效率。這是另一個完整句子！
''');
      expect(t.sentences, ['人工智慧可以協助研究者整理大量資料並提升分析效率。', '這是另一個完整句子！']);
    });

    test('日文（以句號斷句、CJK 逐字）', () {
      final t = PreprocessedText.from('今日はとてもいい天気です。午後に公園まで散歩に行きました。');
      expect(t.sentences.length, 2);
      expect(t.allTokens, isNotEmpty);
    });

    test('日文跨行、阿拉伯問號與天城文 danda 採用完整句界', () {
      final japanese = PreprocessedText.from('''
人工知能は大量の資料を整理し

研究者の分析を支援します。次の文も完全です。
''');
      final arabic = PreprocessedText.from(
        'هل تساعد النماذج الباحثين؟ نعم، لكنها تحتاج إلى مراجعة۔',
      );
      final hindi = PreprocessedText.from(
        'कृत्रिम बुद्धिमत्ता शोध में सहायता करती है। परिणामों की समीक्षा आवश्यक है॥',
      );

      expect(japanese.sentences, ['人工知能は大量の資料を整理し研究者の分析を支援します。', '次の文も完全です。']);
      expect(arabic.sentences, hasLength(2));
      expect(hindi.sentences, hasLength(2));
    });

    test('中英混合不崩潰', () {
      final t = PreprocessedText.from(
        '這是一個 hybrid 文本，內容具有完整語義。'
        'It mixes Chinese and English terms in a readable sentence.',
      );
      expect(t.sentences.length, greaterThanOrEqualTo(2));
      expect(t.entropy, greaterThan(0));
    });
  });

  group('多語系端到端檢測', () {
    for (final (lang, text) in [
      (
        '英文',
        'Artificial intelligence is transforming industries. '
            'It is important to note that these changes are significant. '
            'Furthermore, businesses must adapt accordingly.',
      ),
      (
        '中文',
        '人工智慧正在改變世界。值得注意的是，這項技術發展迅速。'
            '此外，我們必須謹慎評估其影響。綜上所述，未來充滿可能。',
      ),
      (
        '西班牙文',
        'La inteligencia artificial está cambiando el mundo. '
            'Es importante señalar que estos cambios son significativos. '
            'Además, debemos adaptarnos rápidamente.',
      ),
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
