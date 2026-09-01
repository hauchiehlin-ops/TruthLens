import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/adaptive_sentence_batcher.dart';

void main() {
  test('batches unique sentences and restores duplicate positions', () async {
    final batcher = AdaptiveSentenceBatcher(initialBatchSize: 2);
    final calls = <List<String>>[];

    final scores = await batcher.classify(
      const ['one', 'three', 'one', 'seven'],
      (batch) async {
        calls.add(List.of(batch));
        return [for (final sentence in batch) sentence.length / 10];
      },
    );

    expect(calls, [
      ['one', 'three'],
      ['seven'],
    ]);
    expect(scores, [0.3, 0.5, 0.3, 0.5]);
  });

  test(
    'groups similarly sized sentences without changing output order',
    () async {
      final batcher = AdaptiveSentenceBatcher(initialBatchSize: 2);
      final batches = <List<String>>[];

      final scores = await batcher.classify(
        const ['very very long', 'x', 'medium', 'yy'],
        (batch) async {
          batches.add(List.of(batch));
          return [for (final sentence in batch) sentence.length.toDouble()];
        },
      );

      expect(batches, [
        ['x', 'yy'],
        ['medium', 'very very long'],
      ]);
      expect(scores, [14, 1, 6, 2]);
    },
  );

  test('falls back to batch size one for fixed-batch models', () async {
    final batcher = AdaptiveSentenceBatcher(initialBatchSize: 8);

    final scores = await batcher.classify(const ['a', 'bb', 'ccc'], (
      batch,
    ) async {
      if (batch.length > 1) throw StateError('fixed batch dimension');
      return [batch.single.length.toDouble()];
    });

    expect(scores, [1, 2, 3]);
    expect(batcher.preferredBatchSize, 1);
  });

  test('rejects a batch result with the wrong number of scores', () async {
    final batcher = AdaptiveSentenceBatcher(initialBatchSize: 2);

    expect(
      () => batcher.classify(const ['a', 'b'], (_) async => const [0.5]),
      throwsStateError,
    );
  });

  test('reuses exact sentence scores across analyses', () async {
    final batcher = AdaptiveSentenceBatcher(initialBatchSize: 2);
    var calls = 0;

    Future<List<double>> classify(List<String> batch) async {
      calls++;
      return batch.map((sentence) => sentence.length / 100).toList();
    }

    await batcher.classify(['alpha', 'beta'], classify);
    final scores = await batcher.classify(['beta', 'alpha'], classify);

    expect(calls, 1);
    expect(scores, [0.04, 0.05]);
  });

  test('yields to the event loop before native inference', () async {
    final batcher = AdaptiveSentenceBatcher(initialBatchSize: 1);
    var eventLoopAdvanced = false;
    Timer.run(() => eventLoopAdvanced = true);

    await batcher.classify(const ['sentence'], (batch) async {
      expect(eventLoopAdvanced, isTrue);
      return const [0.5];
    });
  });
}
