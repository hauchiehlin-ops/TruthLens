import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/binoculars_scorer.dart';

/// 由機率分布轉為 log 機率
List<double> _log(List<double> probs) =>
    probs.map((p) => p <= 0 ? -50.0 : math.log(p)).toList();

void main() {
  group('log-perplexity', () {
    test('平均負對數機率；完全確定的預測為 0', () {
      // log(1) = 0 → 困惑度 0
      expect(BinocularsScorer.logPerplexity([0.0, 0.0]), 0);
      // 每個位置 log p = -2 → 平均負對數機率 = 2
      expect(
        BinocularsScorer.logPerplexity([-2.0, -2.0, -2.0]),
        closeTo(2, 1e-12),
      );
    });

    test('空輸入回傳 0 而非 NaN', () {
      expect(BinocularsScorer.logPerplexity(const []), 0);
    });
  });

  group('cross-perplexity', () {
    test('兩模型分布相同時等於該分布自身的熵', () {
      final p = [0.5, 0.5];
      final h = BinocularsScorer.crossPerplexity([p], [_log(p)]);
      expect(h, closeTo(math.log(2), 1e-12)); // 均勻二元分布的熵
    });

    test('兩模型分歧越大交叉熵越高', () {
      final p = [0.9, 0.1];
      final agree = BinocularsScorer.crossPerplexity([p], [_log(p)]);
      final disagree = BinocularsScorer.crossPerplexity(
        [p],
        [
          _log([0.1, 0.9]),
        ],
      );
      expect(disagree, greaterThan(agree));
    });

    test('機率為 0 的詞元不產生 NaN', () {
      final h = BinocularsScorer.crossPerplexity(
        [
          [0.0, 1.0],
        ],
        [
          [-50.0, 0.0],
        ],
      );
      expect(h.isFinite, isTrue);
      expect(h, closeTo(0, 1e-12));
    });

    test('位置數或詞彙維度不一致時明確報錯，不靜默對齊', () {
      expect(
        () => BinocularsScorer.crossPerplexity([
          [0.5, 0.5],
        ], const []),
        throwsArgumentError,
      );
      expect(
        () => BinocularsScorer.crossPerplexity(
          [
            [0.5, 0.5],
          ],
          [
            [-1.0, -1.0, -1.0],
          ],
        ),
        throwsArgumentError,
      );
    });
  });

  group('Binoculars 分數', () {
    test('分數 = log-perplexity ÷ cross-perplexity', () {
      final s = BinocularsScorer.score(
        logPerplexityValue: 2.0,
        crossPerplexityValue: 4.0,
      );
      expect(s, closeTo(0.5, 1e-12));
    });

    test('分母為 0 或非有限時回傳 null，讓呼叫端棄權', () {
      expect(
        BinocularsScorer.score(logPerplexityValue: 2, crossPerplexityValue: 0),
        isNull,
      );
      expect(
        BinocularsScorer.score(
          logPerplexityValue: 2,
          crossPerplexityValue: double.nan,
        ),
        isNull,
      );
    });
  });

  group('映射為 AI 機率', () {
    test('方向正確：分數越低越像機器產出', () {
      final machineLike = BinocularsScorer.toAiProbability(0.5);
      final humanLike = BinocularsScorer.toAiProbability(1.4);
      expect(machineLike, greaterThan(0.9));
      expect(humanLike, lessThan(0.1));
      expect(machineLike, greaterThan(humanLike));
    });

    test('恰在門檻上時為 0.5（不偏向任一方）', () {
      expect(
        BinocularsScorer.toAiProbability(BinocularsScorer.placeholderThreshold),
        closeTo(0.5, 1e-12),
      );
    });

    test('極端輸入不產生 NaN，且恆落在 0–1', () {
      for (final s in [-1e9, -5.0, 0.0, 1.0, 5.0, 1e9]) {
        final p = BinocularsScorer.toAiProbability(s);
        expect(p.isFinite, isTrue, reason: 'score=$s 產生非有限值');
        expect(p, inInclusiveRange(0.0, 1.0));
      }
      expect(BinocularsScorer.toAiProbability(double.nan), 0.5);
      // temperature 為 0 不得除以零
      expect(
        BinocularsScorer.toAiProbability(0.5, temperature: 0).isFinite,
        isTrue,
      );
    });
  });
}
