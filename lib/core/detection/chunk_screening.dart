import 'dart:math' as math;

typedef ChunkClassifier =
    Future<List<double>> Function(
      List<String> chunks, {
      void Function(double progress)? onProgress,
    });

/// 長文件兩階段篩檢的結果。
class ChunkScreeningResult {
  /// 與輸入區塊等長。未逐句推論的區塊以同段落已測區塊的平均值填入，
  /// 供文件層統計（平均、強訊號比例）使用。
  final List<double> chunkScores;

  /// 與輸入區塊等長。未逐句推論的區塊為 `double.nan`，供逐句報告使用——
  /// 估計值不能被畫成「模型對這一句的判斷」。
  final List<double> measuredChunkScores;

  /// 實際送進模型的區塊數。
  final int measuredCount;

  /// 是否啟用了抽樣（短文件或關閉快速篩檢時為 false，所有區塊皆已推論）。
  final bool screened;

  const ChunkScreeningResult({
    required this.chunkScores,
    required this.measuredChunkScores,
    required this.measuredCount,
    required this.screened,
  });

  int get totalCount => chunkScores.length;
}

/// 長文件分段篩檢：先抽樣、再對可疑段落補齊。
///
/// 第一階段在每個段落以固定間隔抽取區塊（每段至少一個）；第二階段只對
/// 抽樣中出現可疑分數的段落及其前後相鄰段落補跑其餘區塊。未見可疑訊號的
/// 段落不逐句推論，因此只能說「抽樣未見訊號」，不能說「逐句檢查過」——
/// 引擎必須在理由中揭露這件事，使用者也可在設定關閉以完整分析。
class ChunkScreening {
  /// 少於此區塊數的文件直接完整分析：抽樣省下的時間不值得證據的損失。
  static const int minChunksForScreening = 120;

  /// 第一階段每段落的抽樣間隔（每 3 個區塊抽 1 個）。
  static const int sampleStride = 3;

  /// 觸發第二階段的可疑分數。刻意低於投票門檻：抽樣只看到部分句子，
  /// 接近門檻的段落仍可能藏著跨過門檻的句子。
  static double suspicionThresholdFor(double aiEvidenceThreshold) =>
      (aiEvidenceThreshold * 0.5).clamp(0.3, 0.5);

  static Future<ChunkScreeningResult> classify({
    required List<String> chunks,
    required List<int> paragraphIndices,
    required ChunkClassifier classifier,
    required double suspicionThreshold,
    bool enabled = true,
    void Function(double progress)? onProgress,
  }) async {
    assert(chunks.length == paragraphIndices.length);
    if (!enabled || chunks.length < minChunksForScreening) {
      final scores = await classifier(chunks, onProgress: onProgress);
      return ChunkScreeningResult(
        chunkScores: scores,
        measuredChunkScores: scores,
        measuredCount: scores.length,
        screened: false,
      );
    }

    // 第一階段：各段落依區塊在段內的位置抽樣，段落首個區塊必定入選。
    final positionInParagraph = <int>[];
    final seenPerParagraph = <int, int>{};
    for (final paragraph in paragraphIndices) {
      final position = seenPerParagraph[paragraph] ?? 0;
      positionInParagraph.add(position);
      seenPerParagraph[paragraph] = position + 1;
    }
    final sampleIndices = [
      for (var i = 0; i < chunks.length; i++)
        if (positionInParagraph[i] % sampleStride == 0) i,
    ];

    final measured = List<double>.filled(chunks.length, double.nan);
    // 依樣本數比例分配進度：第一階段完成時約為整體的一半以下，
    // 第二階段規模要等抽樣結果才知道。
    const stageOneShare = 0.5;
    final sampleScores = await classifier([
      for (final i in sampleIndices) chunks[i],
    ], onProgress: (p) => onProgress?.call(p * stageOneShare));
    for (var k = 0; k < sampleIndices.length; k++) {
      measured[sampleIndices[k]] = sampleScores[k];
    }

    // 第二階段：可疑段落與其相鄰段落全部補齊。AI 段落常跨越段界，
    // 鄰段的成本遠低於漏判的代價。
    final suspicious = <int>{};
    for (final i in sampleIndices) {
      if (measured[i] >= suspicionThreshold)
        suspicious.add(paragraphIndices[i]);
    }
    final expanded = <int>{
      for (final p in suspicious) ...[p - 1, p, p + 1],
    };
    final followUpIndices = [
      for (var i = 0; i < chunks.length; i++)
        if (measured[i].isNaN && expanded.contains(paragraphIndices[i])) i,
    ];
    if (followUpIndices.isNotEmpty) {
      final followUpScores = await classifier(
        [for (final i in followUpIndices) chunks[i]],
        onProgress: (p) =>
            onProgress?.call(stageOneShare + p * (1 - stageOneShare)),
      );
      for (var k = 0; k < followUpIndices.length; k++) {
        measured[followUpIndices[k]] = followUpScores[k];
      }
    }
    onProgress?.call(1);

    // 未推論區塊以同段落已測區塊平均填補。這些段落的樣本全部低於可疑
    // 門檻，填補值因此也低於投票門檻，不會憑空製造強訊號。
    final paragraphSums = <int, double>{};
    final paragraphCounts = <int, int>{};
    for (var i = 0; i < chunks.length; i++) {
      if (measured[i].isNaN) continue;
      final p = paragraphIndices[i];
      paragraphSums[p] = (paragraphSums[p] ?? 0) + measured[i];
      paragraphCounts[p] = (paragraphCounts[p] ?? 0) + 1;
    }
    final imputed = [
      for (var i = 0; i < chunks.length; i++)
        measured[i].isNaN
            ? paragraphSums[paragraphIndices[i]]! /
                  math.max(1, paragraphCounts[paragraphIndices[i]]!)
            : measured[i],
    ];

    return ChunkScreeningResult(
      chunkScores: imputed,
      measuredChunkScores: measured,
      measuredCount: sampleIndices.length + followUpIndices.length,
      screened: true,
    );
  }
}

/// 支援長文件分段篩檢的引擎。由協調器依使用者設定在每次分析前寫入。
mixin ChunkScreeningOption {
  bool fastScreeningEnabled = true;
}
