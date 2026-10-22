import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/chunk_screening.dart';
import 'package:omnitrace/core/utils/text_stats.dart';

void main() {
  group('ChunkScreening', () {
    Future<List<double>> Function(
      List<String>, {
      void Function(double)? onProgress,
    })
    recorder(List<String> seen, double Function(String) score) =>
        (chunks, {onProgress}) async {
          seen.addAll(chunks);
          return [for (final c in chunks) score(c)];
        };

    test('短文件或關閉時完整推論', () async {
      final chunks = [for (var i = 0; i < 10; i++) 'c$i'];
      final seen = <String>[];
      final result = await ChunkScreening.classify(
        chunks: chunks,
        paragraphIndices: List.filled(10, 0),
        classifier: recorder(seen, (_) => 0.1),
        suspicionThreshold: 0.4,
      );
      expect(result.screened, isFalse);
      expect(seen, chunks);
      expect(result.measuredCount, 10);
    });

    test('長文件只對可疑段落與鄰段補齊，其餘以段落平均估計', () async {
      // 40 段 × 4 區塊 = 160 區塊；第 20 段含一個高分區塊（段內位置 0，會被抽到）。
      final chunks = <String>[];
      final paragraphs = <int>[];
      for (var p = 0; p < 40; p++) {
        for (var k = 0; k < 4; k++) {
          chunks.add('p${p}k$k');
          paragraphs.add(p);
        }
      }
      final seen = <String>[];
      final result = await ChunkScreening.classify(
        chunks: chunks,
        paragraphIndices: paragraphs,
        classifier: recorder(seen, (c) => c == 'p20k0' ? 0.99 : 0.1),
        suspicionThreshold: 0.4,
      );
      expect(result.screened, isTrue);
      // 抽樣：每段位置 0、3 → 80；補齊：第 19–21 段各剩 2 個 → 6。
      expect(result.measuredCount, 86);
      expect(seen.toSet().length, 86);
      expect(result.measuredChunkScores[chunks.indexOf('p20k1')], 0.1);
      expect(result.measuredChunkScores[chunks.indexOf('p5k1')].isNaN, isTrue);
      expect(result.chunkScores[chunks.indexOf('p5k1')], closeTo(0.1, 1e-9));
      expect(result.chunkScores.where((s) => s.isNaN), isEmpty);
    });

    test('關閉快速篩檢時長文件也完整推論', () async {
      final chunks = [for (var i = 0; i < 200; i++) 'c$i'];
      final seen = <String>[];
      final result = await ChunkScreening.classify(
        chunks: chunks,
        paragraphIndices: [for (var i = 0; i < 200; i++) i ~/ 5],
        classifier: recorder(seen, (_) => 0.1),
        suspicionThreshold: 0.4,
        enabled: false,
      );
      expect(result.screened, isFalse);
      expect(seen, hasLength(200));
    });
  });

  test('參考文獻句不送模型，逐句分數為 NaN', () {
    final t = PreprocessedText.from(
      'This opening sentence contains enough words for reliable analysis.\n\n'
      'References\n\n'
      'Smith, J. (2020). A study of things that matter. Journal of Studies, 4(2), 1-10.',
    );
    expect(t.analysisChunks, hasLength(1));
    expect(t.analysisChunkParagraphIndices, hasLength(1));
    final scores = t.expandChunkScoresToSentences([0.7]);
    expect(scores.first, 0.7);
    expect(scores.skip(1).every((s) => s.isNaN), isTrue);
    expect(t.sentenceChunkIndices.skip(1).every((i) => i == -1), isTrue);
  });
}
