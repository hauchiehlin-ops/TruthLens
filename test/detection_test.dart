import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/utils/text_stats.dart';

void main() {
  group('PreprocessedText', () {
    test('英文斷句與斷詞', () {
      final t = PreprocessedText.from(
        'This is a complete test sentence. It has another complete sentence! '
        'The final sentence still contains enough semantic content.',
      );
      expect(t.sentences.length, 3);
      expect(t.sentenceTokens.first.take(4), ['this', 'is', 'a', 'complete']);
    });

    test('中文斷句與逐字斷詞', () {
      final t = PreprocessedText.from('這是一段可分析的測試句子。第二句話也具有完整語義！');
      expect(t.sentences.length, 2);
      expect(t.sentenceTokens.first.take(4), ['這', '是', '一', '段']);
    });

    test('空文本不崩潰', () {
      final t = PreprocessedText.from('');
      expect(t.sentences, isEmpty);
      expect(t.analysisChunks, isEmpty);
      expect(t.sentenceChunkIndices, isEmpty);
      expect(t.burstiness, 0);
      expect(t.typeTokenRatio, 0);
      expect(t.entropy, 0);
    });

    test('同段句子合併為分析區塊且不跨越段落', () {
      final t = PreprocessedText.from(
        'This first sentence contains enough words for reliable analysis. '
        'This second sentence keeps the same paragraph context intact.\n\n'
        'This final sentence begins a separate paragraph for analysis.',
      );

      expect(t.sentences, hasLength(3));
      expect(t.analysisChunks, hasLength(2));
      expect(t.sentenceChunkIndices, [0, 0, 1]);
      expect(t.analysisChunks.first, contains('same paragraph context'));
    });

    test('分析區塊最多容納五句', () {
      final sentences = List.generate(
        6,
        (index) =>
            'Sentence number $index contains several useful words for contextual analysis.',
      ).join(' ');
      final t = PreprocessedText.from(sentences);

      expect(t.sentences, hasLength(6));
      expect(t.analysisChunks, hasLength(2));
      expect(t.sentenceChunkIndices, [0, 0, 0, 0, 0, 1]);
    });

    test('分析區塊遵守詞元上限並可映射回逐句分數', () {
      final longSentence = List.filled(70, 'context').join(' ');
      final t = PreprocessedText.from('$longSentence. $longSentence.');

      expect(t.analysisChunks, hasLength(2));
      expect(t.sentenceChunkIndices, [0, 1]);
      expect(t.expandChunkScoresToSentences([0.2, 0.8]), [0.2, 0.8]);
      expect(() => t.expandChunkScoresToSentences([0.2]), throwsArgumentError);
    });

    test('單一字母、頁碼、標題與引用殘片不作 AI 句級判讀', () {
      expect(PreprocessedText.isAnalyzableSentence('J.'), isFalse);
      expect(PreprocessedText.isAnalyzableSentence('S.'), isFalse);
      expect(PreprocessedText.isAnalyzableSentence('29'), isFalse);
      expect(PreprocessedText.isAnalyzableSentence('1.'), isFalse);
      expect(PreprocessedText.isAnalyzableSentence(', 2025)'), isFalse);
      expect(
        PreprocessedText.isAnalyzableSentence('第一章 緒論（Introduction） 1.'),
        isFalse,
      );
      expect(
        PreprocessedText.isAnalyzableSentence(
          '1 研究背景與動機（Research Background & Motivation） 1.',
        ),
        isFalse,
      );
      expect(
        PreprocessedText.isAnalyzableSentence(
          'The Dark Side of Virtual Agents: Oh No!',
        ),
        isFalse,
      );
      expect(
        PreprocessedText.isAnalyzableSentence(
          '生成式 AI 與綠色行銷的本體論張力近年來，生成式人工智慧（generative AI, GenAI）技術快速發展，已成為行銷與廣告產製的重要工具。',
        ),
        isTrue,
      );
    });

    test('burstiness：均勻句長低於起伏句長', () {
      final uniform = PreprocessedText.from(
        'One two three four five. Six seven eight nine ten. '
        'Ala bee cee dee eee. Fff ggg hhh iii jjj.',
      );
      final varied = PreprocessedText.from(
        'This opening sentence has enough semantic content. '
        'This sentence is quite a bit longer than the previous one and includes several additional descriptive words for variation. '
        'Another moderately sized sentence follows here now.',
      );
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
      final unavailable = result.engineScores
          .where((s) => !s.available)
          .toList();
      expect(
        unavailable.map((s) => s.engineId),
        containsAll(['transformer', 'adversarial']),
      );
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
      const text =
          '此外，人工智慧正在改變世界。值得注意的是，這項技術發展迅速。'
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

    test('OCR/PDF 碎片與標題不進入句級結果', () async {
      final result = await EnsembleOrchestrator().analyze(
        'J. S. C. 第一章 緒論（Introduction） 1. , 2025)',
      );

      expect(result.sentences, isEmpty);
    });
  });
}
