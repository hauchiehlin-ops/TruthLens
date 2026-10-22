import 'dart:math' as math;

import 'adaptive_sentence_batcher.dart';
import 'text_tokenizer.dart';
import 'web_js_bridge.dart';
import 'web_runtime.dart';

/// 以 onnxruntime-web 執行 Transformer 分類器的瀏覽器端推論。
/// [modelPath]/[tokenizerJsonPath] 在 web 上是 OPFS 儲存鍵（即 ModelManager 的
/// fileName），不是真實檔案系統路徑——由 [WebFs] 讀出 bytes/文字後在瀏覽器內運算，
/// 不經任何伺服器。
///
/// 流程與原生版一致：文字 → tokenizer 編碼（WordPiece / BPE，純 Dart，兩平台共用）→
/// ONNX 推論（WebGPU 優先，退回 WASM）→ softmax → AI 機率。
class OnnxDetector {
  final WebOrtSession _session;
  final TextTokenizer _tokenizer;
  final int maxLen;
  final int aiLabelIndex;
  // Dynamic INT8 activation scales can vary when unrelated sentences share a
  // batch, so such models run one sentence per call. Models without dynamic
  // quantization are switched to batched inference by [_enableBatchingIfSafe].
  AdaptiveSentenceBatcher _batcher = _newBatcher(
    kDeterministicOnnxSentenceBatchSize,
  );

  static AdaptiveSentenceBatcher _newBatcher(int batchSize) =>
      AdaptiveSentenceBatcher(
        initialBatchSize: batchSize,
        interBatchDelay: isConstrainedMobileWebRuntime
            ? const Duration(milliseconds: 12)
            : Duration.zero,
      );

  /// 本次載入實際使用的每批句數（1 = 逐句）。
  int get sentenceBatchSize => _batcher.preferredBatchSize;

  OnnxDetector._(
    this._session,
    this._tokenizer,
    this.maxLen,
    this.aiLabelIndex,
  );

  static Future<OnnxDetector> load({
    required String modelPath,
    required String tokenizerJsonPath,
    String tokenizerType = 'bert-wordpiece',
    int aiLabelIndex = 1,
    int maxLen = 192,
  }) async {
    final bytes = await WebFs.readBytes(modelPath);
    if (bytes == null) {
      throw StateError('模型檔案不存在於瀏覽器儲存：$modelPath');
    }
    final tokenizerJson = (tokenizerType == 'none' || tokenizerJsonPath.isEmpty)
        ? '{}'
        : await WebFs.readText(tokenizerJsonPath) ?? '{}';
    final tokenizer = buildTokenizer(tokenizerType, tokenizerJson);

    final session = WebOrtSession(modelPath);
    final ep = await session.load(bytes);
    final detector = OnnxDetector._(session, tokenizer, maxLen, aiLabelIndex);
    await detector._enableBatchingIfSafe();
    // ignore: avoid_print
    print(
      '[OnnxDetector.web] 已載入 $modelPath（execution provider: $ep，'
      '每批 ${detector.sentenceBatchSize} 句）',
    );
    return detector;
  }

  /// 長短、語言各異的探針句：長度差異讓批次內出現 padding，最能暴露
  /// 「同批句子互相影響」的問題。
  static const _batchProbeSentences = [
    'Short probe.',
    'The committee reviewed the proposal and asked for a revised budget before the next meeting.',
    '研究團隊在三個城市進行了為期兩年的田野調查，並比較不同年齡層的消費行為。',
    'Results were mixed.',
  ];

  /// 模型圖中沒有動態量化時，再以探針實測單句與批次分數是否一致；
  /// 兩項都通過才啟用批次推論，否則維持逐句。
  Future<void> _enableBatchingIfSafe() async {
    if (!_session.isBatchInvariant) return;
    try {
      final single = [
        for (final sentence in _batchProbeSentences)
          (await _classifyBatch([sentence])).first,
      ];
      final batched = await _classifyBatch(_batchProbeSentences);
      var maxDiff = 0.0;
      for (var i = 0; i < single.length; i++) {
        maxDiff = math.max(maxDiff, (single[i] - batched[i]).abs());
      }
      if (maxDiff > kBatchInvarianceTolerance) {
        // ignore: avoid_print
        print('[OnnxDetector.web] 批次探針差異 $maxDiff 超過容許值，維持逐句推論');
        return;
      }
      _batcher = _newBatcher(
        isConstrainedMobileWebRuntime
            ? kConstrainedBatchInvariantOnnxSentenceBatchSize
            : kBatchInvariantOnnxSentenceBatchSize,
      );
    } catch (e) {
      // 固定 batch 維度的模型會在批次探針失敗；逐句仍可正常使用。
      // ignore: avoid_print
      print('[OnnxDetector.web] 批次探針失敗，維持逐句推論：$e');
    }
  }

  Future<double> classify(String text) async {
    return (await _classifyBatch([text])).first;
  }

  Future<List<double>> _classifyBatch(List<String> texts) async {
    final batch = encodeTextBatch(_tokenizer, texts, maxLen: maxLen);
    final (data, dims) = await _session.runBatch(
      batch.flatInputIds,
      batch.flatAttentionMasks,
      batch.batchSize,
      batch.sequenceLength,
    );
    // 輸出形狀 [batch,2]，扁平資料每兩個 logits 對應一句。
    assert(dims.isEmpty || dims.last == 2, '預期分類器輸出最後一維為 2，實際為 $dims');
    if (data.length != batch.batchSize * 2) {
      throw StateError(
        'Expected ${batch.batchSize * 2} logits, received ${data.length}.',
      );
    }
    return [
      for (var index = 0; index < batch.batchSize; index++)
        _softmax([data[index * 2], data[index * 2 + 1]])[aiLabelIndex],
    ];
  }

  Future<List<double>> classifySentences(
    List<String> sentences, {
    void Function(double progress)? onProgress,
  }) async {
    return _batcher.classify(sentences, _classifyBatch, onProgress: onProgress);
  }

  static List<double> _softmax(List<double> x) {
    final maxX = x.reduce(math.max);
    final exps = x.map((v) => math.exp(v - maxX)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  void dispose() => _session.dispose();
}
