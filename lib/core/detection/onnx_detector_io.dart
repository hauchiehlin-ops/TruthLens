import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:onnxruntime/onnxruntime.dart';

import 'adaptive_sentence_batcher.dart';
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
  // Dynamic INT8 activation scales can vary when unrelated sentences share a
  // batch. Native inference therefore keeps exact one-sentence semantics while
  // still benefiting from duplicate elimination and the in-memory LRU cache.
  final AdaptiveSentenceBatcher _batcher = AdaptiveSentenceBatcher(
    initialBatchSize: 1,
  );

  OnnxDetector._(
    this._session,
    this._tokenizer,
    this.maxLen,
    this.aiLabelIndex,
  );

  static bool _envReady = false;

  static void _initOrtEnv() {
    if (_envReady) return;
    try {
      OrtEnv.instance.init();
      _envReady = true;
    } catch (_) {
      final candidates = Platform.isMacOS || Platform.isIOS
          ? [
              'onnxruntime.framework/onnxruntime',
              'onnxruntime_c.framework/onnxruntime_c',
              'onnxruntime_objc.framework/onnxruntime_objc',
              'libonnxruntime.dylib',
              '@rpath/onnxruntime.framework/onnxruntime',
            ]
          : Platform.isAndroid || Platform.isLinux
          ? ['libonnxruntime.so']
          : Platform.isWindows
          ? ['onnxruntime.dll']
          : <String>[];
      for (final candidate in candidates) {
        try {
          DynamicLibrary.open(candidate);
          break;
        } catch (_) {}
      }
      try {
        OrtEnv.instance.init();
      } catch (_) {}
      _envReady = true;
    }
  }

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
    _initOrtEnv();
    final modelFile = File(modelPath);
    final modelName = modelFile.path.split('/').last;
    debugPrint('[OnnxDetector] 載入模型: $modelName');

    final options = OrtSessionOptions()
      ..setSessionGraphOptimizationLevel(GraphOptimizationLevel.ortEnableAll);
    OrtSession session;
    try {
      session = OrtSession.fromFile(modelFile, options);
      debugPrint('[OnnxDetector] ✓ 模型載入成功: $modelName');
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('opset') ||
          errorMsg.contains('Opset') ||
          errorMsg.contains('ValidateOpsetForDomain')) {
        debugPrint('[OnnxDetector] ❌ ONNX opset 版本不支援: $modelName');
        debugPrint('[OnnxDetector]    錯誤: $errorMsg');
        debugPrint(
          '[OnnxDetector]    提示: ONNX Runtime 只支援官方發布的 opset 版本（通常 ≤3），opset 5+ 尚在開發中',
        );
      } else {
        debugPrint('[OnnxDetector] ❌ 模型載入失敗: $modelName');
        debugPrint('[OnnxDetector]    錯誤: $errorMsg');
      }
      rethrow;
    } finally {
      options.release();
    }

    final String tokenizerJson =
        (tokenizerType == 'none' || tokenizerJsonPath.isEmpty)
        ? '{}'
        : await File(tokenizerJsonPath).readAsString();
    final tokenizer = buildTokenizer(tokenizerType, tokenizerJson);
    return OnnxDetector._(session, tokenizer, maxLen, aiLabelIndex);
  }

  /// 對單句推論，回傳 AI 機率（0..1）。
  Future<double> classify(String text) async {
    return (await _classifyBatch([text])).first;
  }

  Future<List<double>> _classifyBatch(List<String> texts) async {
    final batch = encodeTextBatch(_tokenizer, texts, maxLen: maxLen);
    final shape = [batch.batchSize, batch.sequenceLength];
    final inputIds = OrtValueTensor.createTensorWithDataList(
      batch.inputIds,
      shape,
    );
    final attentionMask = OrtValueTensor.createTensorWithDataList(
      batch.attentionMasks,
      shape,
    );
    final runOptions = OrtRunOptions();
    List<OrtValue?>? outputs;
    try {
      // 不指定輸出名稱 → 回傳模型全部輸出（輸出名稱因模型而異：logits / output）
      outputs = _session.run(runOptions, {
        'input_ids': inputIds,
        'attention_mask': attentionMask,
      });
      // 輸出形狀 [batch,2] → 每列轉成 AI 機率。
      final raw = outputs.first?.value as List;
      if (raw.length != batch.batchSize) {
        throw StateError(
          'Expected ${batch.batchSize} output rows, received ${raw.length}.',
        );
      }
      return [
        for (final value in raw)
          () {
            final row = (value as List).cast<num>();
            final probs = _softmax([row[0].toDouble(), row[1].toDouble()]);
            return probs[aiLabelIndex];
          }(),
      ];
    } finally {
      for (final output in outputs ?? const <OrtValue?>[]) {
        output?.release();
      }
      inputIds.release();
      attentionMask.release();
      runOptions.release();
    }
  }

  /// 逐句推論，回傳每句 AI 機率；重複內容由記憶體快取直接回傳。
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

  void dispose() => _session.release();
}
