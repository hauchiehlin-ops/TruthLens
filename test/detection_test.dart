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

    test('PDF 硬換行與分號會重建為完整英文句子', () {
      final t = PreprocessedText.from('''
C
ircular Couette flow or Taylor-Couette flow
1,2
is
a classical problem of hydrodynamic stability; it
is an important paradigm for determining the
dynamics of sheared flows.
Donnelly et al. reported the same experimental result.
''');

      expect(t.sentences, hasLength(2));
      expect(
        t.sentences.first,
        'Circular Couette flow or Taylor-Couette flow is a classical problem '
        'of hydrodynamic stability; it is an important paradigm for '
        'determining the dynamics of sheared flows.',
      );
      expect(t.sentences.last, contains('Donnelly et al. reported'));
    });

    test('PDF 空白行不是絕對句界，續寫片段會合併且殘句與表格列不分析', () {
      final t = PreprocessedText.from('''
Removal efficiencies for the proposed dust collector at the airflow rate of 20 m3/min Wet scrubber for removal of fine particles from exhaust gas 69 Table 1 Removal efficiency by SGS and corresponding pressure loss Inlet concentration 20.9 2.15 89.71 539 1600 1.86 99.88 1323 7680 2.04 99.97 1764

Table 1 shows the removal efficiency and pressure loss at the airflow rate of

The inner structure of proposed wet scrubber is same

with the shape of the Venturi scrubber.

Particle removal efficiency increases with increasing pressure drop because of increased turbulence due to high gas velocity in the throat.
''');

      expect(t.sentences, [
        'The inner structure of proposed wet scrubber is same with the shape of the Venturi scrubber.',
        'Particle removal efficiency increases with increasing pressure drop because of increased turbulence due to high gas velocity in the throat.',
      ]);
      expect(t.analysisText, isNot(contains('airflow rate of')));
      expect(t.analysisText, isNot(contains('89.71 539 1600')));
      expect(
        t.analysisChunks.join(' '),
        t.analysisText.replaceAll('\n\n', ' '),
      );
    });

    test('英文大寫新句不會被前一個缺字殘句錯誤吞併', () {
      final t = PreprocessedText.from('''
Table 1 shows the removal efficiency at the airflow rate of

The next complete sentence starts with a capital letter and remains independent.
''');

      expect(t.sentences, [
        'The next complete sentence starts with a capital letter and remains independent.',
      ]);
    });

    test('學術縮寫、姓名縮寫與小數點不會被誤判為句尾', () {
      final t = PreprocessedText.from(
        'W. M. Yang et al. measured the response in Fig. 3 at 3.14. '
        'The next complete sentence reports the resulting flow state.',
      );

      expect(t.sentences, hasLength(2));
      expect(t.sentences.first, contains('W. M. Yang et al.'));
      expect(t.sentences.first, endsWith('3.14.'));
    });

    test('無空格姓名縮寫、電子郵件與段落標題不會污染正文句子', () {
      final t = PreprocessedText.from('''
LOWEST STABILITY BOUNDARY ON FLOW
DOI:10.1142/S0218127410026678
andW.M.YANG
author.name@example.com
Received June 5, 2009; Revised August 7, 2009
In this study, we investigate a complete academic sentence across the page.
1. Introduction
The first body paragraph starts with a complete sentence for analysis.
''');

      expect(t.sentences, [
        'In this study, we investigate a complete academic sentence across the page.',
        'The first body paragraph starts with a complete sentence for analysis.',
      ]);
    });

    test('內文剛好含 review／research 等字不得被整句移除', () {
      // 書目過濾在句子層是孤立判斷，沒有「前一段已是書目」的上下文可倚賴。
      // 裸詞表原本讓這句（含 review）被整句刪掉，句長起伏因此歸零，統計引擎
      // 連帶失去可用訊號——掉的是真實內文，不只是測試數字。
      final t = PreprocessedText.from(
        'Alpha beta gamma delta. '
        'Iota kappa lambda mu. '
        'Rho sigma tau upsilon. '
        'River stone window paper signal method value result field sample data note '
        'analysis evidence context design process outcome review conclusion detail.',
      );

      expect(t.sentences.length, 4);
      expect(t.sentences.last, contains('review conclusion detail'));
    });

    test('真正的書目條目仍然被排除（帶卷頁或作者樣式）', () {
      final withLocator = PreprocessedText.from(
        'Interaction Studies, 24(1), 45-67.',
      );
      expect(withLocator.sentences, isEmpty);

      final withAuthors = PreprocessedText.from('Wullur, P., & Kim, J.');
      expect(withAuthors.sentences, isEmpty);
    });

    test('參考文獻跨行條目不會被拆成逐句 AI 證據', () {
      final t = PreprocessedText.from('''
This body paragraph remains available for detection because it contains a complete contextual sentence.

References

Wullur, P., & Kim, J.

Gender performance in social exchange robots.

Interaction Studies, 24(1), 45–67.

Yadav, R., & Pathak, G. S.

Young consumers' intention towards buying green products.

Ecological Economics, 131, 65–72.

Yang, J., & Lee, S. S.

Caught in the act: Natural recognition of deepfake UGC ad, expectancy violation and consumer responses.

Yim, M. Y. C., Cicchirillo, V. J., & Drumwright, M. E.

The impact of stereoscopic 3D advertising: The role of presence.
''');

      expect(t.sentences, [
        'This body paragraph remains available for detection because it contains a complete contextual sentence.',
      ]);
      expect(t.analysisText, isNot(contains('Wullur')));
      expect(t.analysisText, isNot(contains('Interaction Studies')));
      expect(t.analysisText, isNot(contains('deepfake UGC ad')));
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

    test('超長完整句只在模型層分片，畫面與報告仍保留完整句', () {
      final sentence = '${List.filled(150, 'context').join(' ')}.';
      final t = PreprocessedText.from(sentence);

      expect(t.sentences, [sentence]);
      expect(t.analysisChunks, hasLength(2));
      expect(t.sentenceAnalysisChunkIndices, [
        [0, 1],
      ]);
      expect(t.expandChunkScoresToSentences([0.2, 0.8]), [0.5]);
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
    test('五級分類使用固定切點 0.2／0.4／0.6／0.8', () {
      expect(Verdict.cutPoints, [0.20, 0.40, 0.60, 0.80]);
      expect(Verdict.fromProbability(0.1), Verdict.human);
      expect(Verdict.fromProbability(0.3), Verdict.likelyHuman);
      expect(Verdict.fromProbability(0.5), Verdict.mixed);
      expect(Verdict.fromProbability(0.7), Verdict.likelyAi);
      expect(Verdict.fromProbability(0.9), Verdict.ai);
    });

    test('切點邊界歸屬下一級（左閉右開）', () {
      expect(Verdict.fromProbability(0.20), Verdict.likelyHuman);
      expect(Verdict.fromProbability(0.40), Verdict.mixed);
      expect(Verdict.fromProbability(0.60), Verdict.likelyAi);
      expect(Verdict.fromProbability(0.80), Verdict.ai);
    });

    test('標記門檻為固定值，且與「混合內容→可能 AI」的分界一致', () {
      expect(DetectionResult.aiFlagThreshold, Verdict.cutPoints[2]);

      DetectionResult withScore(double p) => DetectionResult(
        id: 'f',
        analyzedAt: DateTime(2026, 8, 17),
        inputText: 'x',
        aiProbability: p,
        verdict: Verdict.fromProbability(p),
        engineScores: const [],
        sentences: const [],
      );
      expect(withScore(0.59).flaggedAsAi, isFalse);
      expect(withScore(0.60).flaggedAsAi, isTrue);
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
      final started = <String>[];
      final done = <String>[];
      await EnsembleOrchestrator().analyze(
        'A sentence for testing callbacks. Another one here.',
        onEngineStarted: started.add,
        onEngineDone: done.add,
      );
      expect(started.length, 4);
      expect(done.length, 4);
      expect(started.toSet(), done.toSet());
    });

    test('OCR/PDF 碎片與標題不進入句級結果', () async {
      final result = await EnsembleOrchestrator().analyze(
        'J. S. C. 第一章 緒論（Introduction） 1. , 2025)',
      );

      expect(result.sentences, isEmpty);
    });
  });
}
