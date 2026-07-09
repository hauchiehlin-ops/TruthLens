import 'dart:math' as math;

import 'bpe_tokenizer.dart';
import 'web_js_bridge.dart';

/// 以 onnxruntime-web 執行 distilgpt2（causal LM）計算文本困惑度（統計引擎 B）。
/// [modelPath]/[tokenizerJsonPath] 為 OPFS 儲存鍵，語意與 [onnx_detector_web.dart] 相同。
class PerplexityScorer {
  final WebOrtSession _session;
  final BpeTokenizer _tokenizer;
  final int maxLen;

  PerplexityScorer._(this._session, this._tokenizer, this.maxLen);

  static Future<PerplexityScorer> load({
    required String modelPath,
    required String tokenizerJsonPath,
    int maxLen = 192,
  }) async {
    final bytes = await WebFs.readBytes(modelPath);
    if (bytes == null) {
      throw StateError('模型檔案不存在於瀏覽器儲存：$modelPath');
    }
    final tokenizerJson = await WebFs.readText(tokenizerJsonPath) ?? '{}';
    final tokenizer = BpeTokenizer.fromTokenizerJson(tokenizerJson);
    final session = WebOrtSession(modelPath);
    await session.load(bytes);
    return PerplexityScorer._(session, tokenizer, maxLen);
  }

  /// 計算困惑度；文本過短回傳 null。
  Future<double?> perplexity(String text) async {
    final ids = _tokenizer.encodeRaw(text, maxLen: maxLen);
    if (ids.length < 2) return null;

    final mask = List.filled(ids.length, 1);
    final (data, dims) = await _session.run(ids, mask);
    // logits 形狀 [1, seq, vocab] → data 為攤平陣列，依 dims 還原每個 token 位置的一列 vocab。
    final seq = dims.length >= 2 ? dims[dims.length - 2] : ids.length;
    final vocab = dims.isNotEmpty ? dims.last : (data.length ~/ seq);

    var nll = 0.0;
    var n = 0;
    for (var i = 0; i < ids.length - 1; i++) {
      final base = i * vocab;
      final next = ids[i + 1];
      var maxv = double.negativeInfinity;
      for (var v = 0; v < vocab; v++) {
        final x = data[base + v];
        if (x > maxv) maxv = x;
      }
      var sum = 0.0;
      for (var v = 0; v < vocab; v++) {
        sum += math.exp(data[base + v] - maxv);
      }
      final logsumexp = maxv + math.log(sum);
      nll += logsumexp - data[base + next];
      n++;
    }
    return math.exp(nll / n);
  }

  void dispose() => _session.dispose();
}
