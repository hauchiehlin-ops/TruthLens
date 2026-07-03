import 'package:flutter/services.dart';

/// 原生推論橋接（Dart 端）。透過 MethodChannel 呼叫各平台的原生實作：
///   iOS/macOS → Core ML + llama.cpp
///   Android   → TFLite (LiteRT) + llama.cpp
///   Windows   → ONNX Runtime + llama.cpp
///
/// 原生端尚未實作前，呼叫會拋 [MissingPluginException]，此處捕捉後回傳 null，
/// 讓對應引擎自動回報 unavailable、退出加權投票（行為與現況一致）。
///
/// 契約（原生端需實作的 method）：
///   loadModel   { modelId, path, backend } → bool
///   classify    { modelId, text }          → double  (AI 機率 0..1)
///   perplexity  { modelId, text }          → double  (每 token 困惑度)
///   unload      { modelId }                → void
class NativeInferenceService {
  static const _channel = MethodChannel('com.truthlens/inference');

  final Set<String> _loaded = {};

  /// 原生推論是否在此平台可用（原生端有回應即為 true）
  Future<bool> get isSupported async {
    try {
      final ok = await _channel.invokeMethod<bool>('ping');
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> loadModel({
    required String modelId,
    required String path,
    required String backend,
  }) async {
    try {
      final ok = await _channel.invokeMethod<bool>('loadModel', {
        'modelId': modelId,
        'path': path,
        'backend': backend,
      });
      if (ok ?? false) _loaded.add(modelId);
      return ok ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  bool isLoaded(String modelId) => _loaded.contains(modelId);

  /// 回傳 AI 機率（0..1）；原生不可用時回傳 null
  Future<double?> classify(String modelId, String text) async {
    try {
      return await _channel.invokeMethod<double>('classify', {
        'modelId': modelId,
        'text': text,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// 回傳文本困惑度；原生不可用時回傳 null
  Future<double?> perplexity(String modelId, String text) async {
    try {
      return await _channel.invokeMethod<double>('perplexity', {
        'modelId': modelId,
        'text': text,
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<void> unload(String modelId) async {
    try {
      await _channel.invokeMethod('unload', {'modelId': modelId});
    } on MissingPluginException {
      // 無原生端，忽略
    }
    _loaded.remove(modelId);
  }
}
