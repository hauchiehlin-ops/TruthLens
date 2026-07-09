import 'dart:io';
import 'dart:math' as math;

import 'package:onnxruntime/onnxruntime.dart';

import 'text_tokenizer.dart';

/// 以 ONNX Runtime 執行 Transformer 分類器的端上推論。
/// 底層為各平台原生 ONNX Runtime（onnxruntime 套件），支援 macOS/Windows/iOS/Android/Linux。
///
/// 流程：文字 → tokenizer 編碼（WordPiece / BPE）→ ONNX 推論 → softmax → AI 機率。
class OnnxDetector {
  final OrtSession _session;
  final TextTokenizer _tokenizer;
  final int maxLen;
  final int aiLabelIndex; // 輸出中對應「AI」的類別索引（依模型 id2label）

  OnnxDetector._(this._session, this._tokenizer, this.maxLen, this.aiLabelIndex);

  static bool _envReady = false;

  /// 載入模型與對應 tokenizer。
  /// [tokenizerType]：bert-wordpiece / roberta-bpe。tokenizerJson 為 HuggingFace tokenizer.json。
  /// [aiLabelIndex]：輸出兩類中哪一個代表 AI（distilbert=1、roberta-openai-detector=0）。
  static Future<OnnxDetector> load({
    required String modelPath,
    required String tokenizerJsonPath,
    String tokenizerType = 'bert-wordpiece',
    int aiLabelIndex = 1,
    int maxLen = 192,
  }) async {
    if (!_envReady) {
      OrtEnv.instance.init();
      _envReady = true;
    }
    final options = OrtSessionOptions();
    final session = OrtSession.fromFile(File(modelPath), options);
    final String tokenizerJson = (tokenizerType == 'none' || tokenizerJsonPath.isEmpty)
        ? '{}'
        : await File(tokenizerJsonPath).readAsString();
    final tokenizer = buildTokenizer(tokenizerType, tokenizerJson);
    return OnnxDetector._(session, tokenizer, maxLen, aiLabelIndex);
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
      // 不指定輸出名稱 → 回傳模型全部輸出（輸出名稱因模型而異：logits / output）
      final outputs = _session.run(
        runOptions,
        {'input_ids': inputIds, 'attention_mask': attentionMask},
      );
      // 輸出形狀 [1,2] → 取第一列
      final raw = outputs.first?.value as List;
      final row = (raw.first as List).cast<num>();
      final probs = _softmax([row[0].toDouble(), row[1].toDouble()]);
      for (final o in outputs) {
        o?.release();
      }
      return probs[aiLabelIndex];
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
