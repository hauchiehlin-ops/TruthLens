import 'dart:math' as math;

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

  OnnxDetector._(this._session, this._tokenizer, this.maxLen, this.aiLabelIndex);

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
    final enc = _tokenizer.encode(text, maxLen: maxLen);
    final (data, dims) = await _session.run(enc.inputIds, enc.attentionMask);
    // 輸出形狀 [1,2]（batch=1）→ data 即為該列的兩個 logits。
    assert(dims.isEmpty || dims.last == 2,
        '預期分類器輸出最後一維為 2，實際為 $dims');
    final probs = _softmax([data[0], data[1]]);
    return probs[aiLabelIndex];
  }

  Future<List<double>> classifySentences(List<String> sentences) async {
    final out = <double>[];
    for (final s in sentences) {
      out.add(await classify(s));
    }
    return out;
  }

  static List<double> _softmax(List<double> x) {
    final maxX = x.reduce(math.max);
    final exps = x.map((v) => math.exp(v - maxX)).toList();
    final sum = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / sum).toList();
  }

  void dispose() => _session.dispose();
}
