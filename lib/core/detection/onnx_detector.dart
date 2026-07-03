import 'dart:io';
import 'dart:math' as math;

import 'package:onnxruntime/onnxruntime.dart';

import 'wordpiece_tokenizer.dart';

/// 以 ONNX Runtime 執行 Transformer 分類器的端上推論。
/// 底層為各平台原生 ONNX Runtime（onnxruntime 套件），支援 macOS/Windows/iOS/Android/Linux。
///
/// 流程：文字 → WordPiece 編碼 → ONNX 推論 → softmax → AI 機率。
class OnnxDetector {
  final OrtSession _session;
  final WordPieceTokenizer _tokenizer;
  final int maxLen;

  OnnxDetector._(this._session, this._tokenizer, this.maxLen);

  static bool _envReady = false;

  /// 載入模型與對應 tokenizer。tokenizerJson 為 HuggingFace tokenizer.json。
  static Future<OnnxDetector> load({
    required String modelPath,
    required String tokenizerJsonPath,
    int maxLen = 192,
  }) async {
    if (!_envReady) {
      OrtEnv.instance.init();
      _envReady = true;
    }
    final options = OrtSessionOptions();
    final session = OrtSession.fromFile(File(modelPath), options);
    final tokenizer = WordPieceTokenizer.fromTokenizerJson(
        await File(tokenizerJsonPath).readAsString());
    return OnnxDetector._(session, tokenizer, maxLen);
  }

  /// 對單句推論，回傳 AI 機率（0..1）。
  Future<double> classify(String text) async {
    final enc = _tokenizer.encode(text, maxLen: maxLen);
    final shape = [1, enc.inputIds.length];
    final inputIds =
        OrtValueTensor.createTensorWithDataList([enc.inputIds], shape);
    final attentionMask =
        OrtValueTensor.createTensorWithDataList([enc.attentionMask], shape);
    final runOptions = OrtRunOptions();
    try {
      final outputs = _session.run(
        runOptions,
        {'input_ids': inputIds, 'attention_mask': attentionMask},
        ['logits'],
      );
      // logits 形狀 [1,2] → 取第一列
      final raw = outputs.first?.value as List;
      final row = (raw.first as List).cast<num>();
      final probs = _softmax([row[0].toDouble(), row[1].toDouble()]);
      for (final o in outputs) {
        o?.release();
      }
      return probs[1]; // class 1 = AI
    } finally {
      inputIds.release();
      attentionMask.release();
      runOptions.release();
    }
  }

  /// 逐句推論，回傳每句 AI 機率
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

  void dispose() => _session.release();
}
