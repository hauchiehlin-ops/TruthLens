import 'dart:collection';
import 'dart:math' as math;

typedef SentenceBatchClassifier =
    Future<List<double>> Function(List<String> sentences);

/// INT8 Transformer classifiers must run with one sentence per ONNX call for
/// cross-platform parity. Dynamic activation scales can otherwise depend on
/// unrelated sentences that happen to share the same batch.
const int kDeterministicOnnxSentenceBatchSize = 1;

/// Runs sentence inference in small batches while preserving sentence order.
///
/// Exact duplicates are evaluated once. Models exported with a fixed batch
/// dimension are supported by automatically reducing the batch size down to
/// one when a larger batch is rejected.
class AdaptiveSentenceBatcher {
  int _preferredBatchSize;
  final int cacheCapacity;
  final Duration interBatchDelay;
  final LinkedHashMap<String, double> _scoreCache = LinkedHashMap();

  AdaptiveSentenceBatcher({
    int initialBatchSize = 8,
    this.cacheCapacity = 2048,
    this.interBatchDelay = Duration.zero,
  }) : assert(initialBatchSize > 0),
       assert(cacheCapacity >= 0),
       _preferredBatchSize = initialBatchSize;

  int get preferredBatchSize => _preferredBatchSize;

  Future<List<double>> classify(
    List<String> sentences,
    SentenceBatchClassifier runBatch, {
    void Function(double progress)? onProgress,
  }) async {
    if (sentences.isEmpty) return const [];

    final uniqueSentences = <String>[];
    final uniqueIndexBySentence = <String, int>{};
    final originalToUnique = <int>[];
    for (final sentence in sentences) {
      final existing = uniqueIndexBySentence[sentence];
      if (existing != null) {
        originalToUnique.add(existing);
        continue;
      }
      final next = uniqueSentences.length;
      uniqueIndexBySentence[sentence] = next;
      uniqueSentences.add(sentence);
      originalToUnique.add(next);
    }

    // Similar-length sentences share a batch to reduce padding work. Scores
    // are written back by unique index, so the caller still receives the
    // original document order.
    final orderedUniqueIndices =
        [for (var index = 0; index < uniqueSentences.length; index++) index]
          ..sort(
            (a, b) =>
                uniqueSentences[a].length.compareTo(uniqueSentences[b].length),
          );
    final uniqueScores = List<double>.filled(uniqueSentences.length, 0);
    final pendingUniqueIndices = <int>{};
    for (var index = 0; index < uniqueSentences.length; index++) {
      final sentence = uniqueSentences[index];
      if (_scoreCache.containsKey(sentence)) {
        final cached = _scoreCache.remove(sentence)!;
        _scoreCache[sentence] = cached;
        uniqueScores[index] = cached;
      } else {
        pendingUniqueIndices.add(index);
      }
    }
    final orderedPendingIndices = orderedUniqueIndices
        .where(pendingUniqueIndices.contains)
        .toList();
    final totalPending = orderedPendingIndices.length;
    final cachedCount = uniqueSentences.length - totalPending;
    if (uniqueSentences.isNotEmpty && cachedCount > 0) {
      onProgress?.call(cachedCount / uniqueSentences.length);
    }

    var offset = 0;
    while (offset < orderedPendingIndices.length) {
      final size = math.min(
        _preferredBatchSize,
        orderedPendingIndices.length - offset,
      );
      final batchIndices = orderedPendingIndices.sublist(offset, offset + size);
      final batch = [for (final index in batchIndices) uniqueSentences[index]];

      List<double> scores;
      try {
        // Native ONNX inference is synchronous. Yield between batches so the
        // UI can repaint progress and process workspace-mode changes.
        await Future<void>.delayed(interBatchDelay);
        scores = await runBatch(batch);
      } catch (_) {
        if (size == 1) rethrow;
        _preferredBatchSize = math.max(1, size ~/ 2);
        continue;
      }
      if (scores.length != size) {
        throw StateError(
          'Sentence batch returned ${scores.length} scores for $size inputs.',
        );
      }
      for (var index = 0; index < size; index++) {
        final uniqueIndex = batchIndices[index];
        final score = scores[index];
        uniqueScores[uniqueIndex] = score;
        _cache(uniqueSentences[uniqueIndex], score);
      }
      offset += size;
      onProgress?.call((cachedCount + offset) / uniqueSentences.length);
    }

    return [for (final index in originalToUnique) uniqueScores[index]];
  }

  void _cache(String sentence, double score) {
    if (cacheCapacity == 0) return;
    _scoreCache.remove(sentence);
    _scoreCache[sentence] = score;
    while (_scoreCache.length > cacheCapacity) {
      _scoreCache.remove(_scoreCache.keys.first);
    }
  }
}
