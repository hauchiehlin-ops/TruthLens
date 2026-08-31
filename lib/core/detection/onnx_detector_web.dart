import 'dart:math' as math;

import 'adaptive_sentence_batcher.dart';
import 'text_tokenizer.dart';
import 'web_js_bridge.dart';

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
  // batch. Use the same deterministic one-sentence semantics as native so the
  // same model stack produces comparable sentence scores across platforms.
  final AdaptiveSentenceBatcher _batcher = AdaptiveSentenceBatcher(
    initialBatchSize: kDeterministicOnnxSentenceBatchSize,
  );

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
    // ignore: avoid_print
    print('[OnnxDetector.web] 已載入 $modelPath（execution provider: $ep）');
    return OnnxDetector._(session, tokenizer, maxLen, aiLabelIndex);
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
