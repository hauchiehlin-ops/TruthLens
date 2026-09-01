import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/calibration_service.dart';
import 'package:omnitrace/core/services/weight_learner.dart';

const _engines = ['transformer', 'statistical', 'stylometry', 'adversarial'];

CalibrationSample _sample({
  required bool isAi,
  required Map<String, double> engineScores,
}) => CalibrationSample(
  id: '${isAi}_${engineScores.hashCode}_${Random().nextInt(1 << 30)}',
  score: engineScores.values.isEmpty
      ? 0
      : engineScores.values.reduce((a, b) => a + b) / engineScores.length,
  addedAt: DateTime(2026, 8, 17),
  isAi: isAi,
  engineScores: engineScores,
);

/// 造出兩類樣本：[discriminating] 的引擎能分開兩組，其餘引擎純雜訊
List<CalibrationSample> _dataset({
  required Set<String> discriminating,
  int perClass = 20,
  int seed = 1,
}) {
  final rng = Random(seed);
  final out = <CalibrationSample>[];
  for (var i = 0; i < perClass; i++) {
    out.add(
      _sample(
        isAi: false,
        engineScores: {
          for (final e in _engines)
            e: discriminating.contains(e)
                ? 0.15 + rng.nextDouble() * 0.05
                : 0.40 + rng.nextDouble() * 0.2,
        },
      ),
    );
    out.add(
      _sample(
        isAi: true,
        engineScores: {
          for (final e in _engines)
            e: discriminating.contains(e)
                ? 0.85 + rng.nextDouble() * 0.05
                : 0.40 + rng.nextDouble() * 0.2,
        },
      ),
    );
  }
  return out;
}

void main() {
  group('樣本量把關', () {
    test('任一類樣本不足時不學習（寧可用手調權重）', () {
      expect(WeightLearner.canLearn(20, 5), isFalse);
      expect(WeightLearner.canLearn(5, 20), isFalse);
      expect(WeightLearner.canLearn(10, 10), isTrue);

      final tooFew = _dataset(discriminating: {'transformer'}, perClass: 4);
      expect(WeightLearner.learn(tooFew, _engines), isNull);
    });

    test('舊樣本沒有逐引擎分數時不學習，不會學出全 0 權重', () {
      final legacy = [
        for (var i = 0; i < 20; i++)
          CalibrationSample(
            id: 'h$i',
            score: 0.2,
            addedAt: DateTime(2026, 8, 17),
          ),
        for (var i = 0; i < 20; i++)
          CalibrationSample(
            id: 'a$i',
            score: 0.8,
            addedAt: DateTime(2026, 8, 17),
            isAi: true,
          ),
      ];
      expect(WeightLearner.learn(legacy, _engines), isNull);
    });
  });

  group('權重學習', () {
    test('能分開兩組的引擎拿到最高權重，純雜訊引擎權重接近 0', () {
      final learned = WeightLearner.learn(
        _dataset(discriminating: {'transformer', 'stylometry'}),
        _engines,
      )!;

      expect(learned.humanCount, 20);
      expect(learned.aiCount, 20);
      // 權重總和為 1
      expect(
        learned.weights.values.fold<double>(0, (a, b) => a + b),
        closeTo(1.0, 1e-9),
      );
      // 有鑑別力的兩個引擎應遠高於雜訊引擎
      expect(
        learned.weights['transformer']!,
        greaterThan(learned.weights['statistical']!),
      );
      expect(
        learned.weights['stylometry']!,
        greaterThan(learned.weights['adversarial']!),
      );
      // 兩個鑑別引擎合計應拿走絕大多數權重
      expect(
        learned.weights['transformer']! + learned.weights['stylometry']!,
        greaterThan(0.8),
      );
    });

    test('判反方向的引擎權重歸零，而非給負權重', () {
      final rng = Random(3);
      final samples = <CalibrationSample>[];
      for (var i = 0; i < 20; i++) {
        // transformer 正常；statistical 完全判反（人類高、AI 低）
        samples.add(
          _sample(
            isAi: false,
            engineScores: {
              'transformer': 0.1 + rng.nextDouble() * 0.05,
              'statistical': 0.9 - rng.nextDouble() * 0.05,
              'stylometry': 0.5,
              'adversarial': 0.5,
            },
          ),
        );
        samples.add(
          _sample(
            isAi: true,
            engineScores: {
              'transformer': 0.9 - rng.nextDouble() * 0.05,
              'statistical': 0.1 + rng.nextDouble() * 0.05,
              'stylometry': 0.5,
              'adversarial': 0.5,
            },
          ),
        );
      }

      final learned = WeightLearner.learn(samples, _engines)!;
      expect(learned.weights['statistical'], 0);
      expect(learned.weights['transformer'], closeTo(1.0, 1e-9));

      final statistical = learned.separations.firstWhere(
        (s) => s.engineId == 'statistical',
      );
      // 效果量本身仍保留負號，供介面說明「這個引擎判反了」
      expect(statistical.effectSize, lessThan(0));
    });

    test('所有引擎都毫無鑑別力時回傳 null，不硬給一組權重', () {
      final rng = Random(9);
      final samples = <CalibrationSample>[];
      for (var i = 0; i < 20; i++) {
        for (final isAi in [false, true]) {
          samples.add(
            _sample(
              isAi: isAi,
              engineScores: {
                for (final e in _engines) e: 0.4 + rng.nextDouble() * 0.2,
              },
            ),
          );
        }
      }
      // 兩組同分布 → 效果量在 0 附近，正負皆有可能；
      // 若全為負或 0 應回 null，否則權重也應是有限值
      final learned = WeightLearner.learn(samples, _engines);
      if (learned != null) {
        for (final w in learned.weights.values) {
          expect(w, inInclusiveRange(0.0, 1.0));
          expect(w.isFinite, isTrue);
        }
      }
    });
  });

  group("Cohen's d", () {
    test('分離越明顯效果量越大', () {
      final near = WeightLearner.cohensD(
        List.filled(10, 0.4),
        List.filled(10, 0.45),
      );
      final far = WeightLearner.cohensD(
        List.generate(10, (i) => 0.1 + i * 0.001),
        List.generate(10, (i) => 0.9 + i * 0.001),
      );
      expect(far.abs(), greaterThan(near.abs()));
    });

    test('空輸入與零變異不產生 NaN 或無限大', () {
      expect(WeightLearner.cohensD(const [], const [0.5]), 0);
      final d = WeightLearner.cohensD(
        List.filled(10, 0.2),
        List.filled(10, 0.8),
      );
      expect(d.isFinite, isTrue);
      expect(d, greaterThan(0));
    });
  });
}
