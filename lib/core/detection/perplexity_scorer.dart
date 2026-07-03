import 'dart:io';
import 'dart:math' as math;

import 'package:onnxruntime/onnxruntime.dart';

import 'bpe_tokenizer.dart';

/// 以 distilgpt2（causal LM）計算文本困惑度（統計引擎 B 的真指標）。
/// 困惑度低 = 文本高度可預測 = 偏 AI；高 = 偏人類。
class PerplexityScorer {
  final OrtSession _session;
  final BpeTokenizer _tokenizer;
  final int maxLen;

  PerplexityScorer._(this._session, this._tokenizer, this.maxLen);

  static bool _envReady = false;

  static Future<PerplexityScorer> load({
    required String modelPath,
    required String tokenizerJsonPath,
    int maxLen = 192,
  }) async {
    if (!_envReady) {
      OrtEnv.instance.init();
      _envReady = true;
    }
    final session = OrtSession.fromFile(File(modelPath), OrtSessionOptions());
    final tokenizer = BpeTokenizer.fromTokenizerJson(
        await File(tokenizerJsonPath).readAsString());
    return PerplexityScorer._(session, tokenizer, maxLen);
  }

  /// 計算困惑度；文本過短回傳 null。
  Future<double?> perplexity(String text) async {
    final ids = _tokenizer.encodeRaw(text, maxLen: maxLen);
    if (ids.length < 2) return null;

    final shape = [1, ids.length];
    final inputIds = OrtValueTensor.createTensorWithDataList([ids], shape);
    final mask = OrtValueTensor.createTensorWithDataList(
        [List.filled(ids.length, 1)], shape);
    final runOptions = OrtRunOptions();
    try {
      final outputs = _session
          .run(runOptions, {'input_ids': inputIds, 'attention_mask': mask});
      // logits 形狀 [1, seq, vocab]
      final rows = (outputs.first?.value as List).first as List;
      var nll = 0.0;
      var n = 0;
      for (var i = 0; i < ids.length - 1; i++) {
        final row = (rows[i] as List).cast<num>();
        final next = ids[i + 1];
        // logsumexp
        var maxv = double.negativeInfinity;
        for (final v in row) {
          if (v > maxv) maxv = v.toDouble();
        }
        var sum = 0.0;
        for (final v in row) {
          sum += math.exp(v.toDouble() - maxv);
        }
        final logsumexp = maxv + math.log(sum);
        nll += logsumexp - row[next].toDouble();
        n++;
      }
      for (final o in outputs) {
        o?.release();
      }
      return math.exp(nll / n);
    } finally {
      inputIds.release();
      mask.release();
      runOptions.release();
    }
  }

  void dispose() => _session.release();
}
