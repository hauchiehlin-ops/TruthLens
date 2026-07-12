import 'package:flutter/foundation.dart';
import 'device_capabilities.dart';
import 'llama_ffi.dart';
import 'model_manager.dart';
import 'remote_llm_provider.dart';

/// 管理 LLM 推論：優先本地端（llama.cpp），fallback 遠程 API。
/// 支援低記憶體保護與自動 API 切換。
class LlmManager extends ChangeNotifier {
  final ModelManager modelManager;
  final LlamaInference _inference = LlamaInference();
  RemoteLlmProvider? _remoteProvider;
  bool _loading = false;
  String? _error;
  bool _useRemote = false;

  // ignore: prefer_initializing_formals — 具名參數不可用底線命名，故無法用 this._remoteProvider
  LlmManager({required this.modelManager, RemoteLlmProvider? remoteProvider})
      : _remoteProvider = remoteProvider;

  bool get isLoaded => _inference.isLoaded || _useRemote;
  bool get isLoading => _loading;
  bool get isRemote => _useRemote;
  String? get error => _error;
  LlamaInference get inference => _inference;
  RemoteLlmProvider? get remoteProvider => _remoteProvider;

  /// 嘗試載入 LLM：優先本地端，失敗則自動 fallback 遠程 API
  Future<bool> loadIfAvailable() async {
    if (isLoaded) return true;
    if (_loading) return false;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. 嘗試本地端 LLM
      final localSuccess = await _tryLoadLocal();
      if (localSuccess) {
        _useRemote = false;
        return true;
      }

      // 2. Fallback 遠程 API
      if (_remoteProvider != null) {
        final remoteSuccess = await _tryLoadRemote();
        if (remoteSuccess) {
          _useRemote = true;
          _error = null;
          return true;
        }
      }

      // 3. 無可用方案
      _error = '本地 LLM 未安裝，且無可用遠程 API';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> _tryLoadLocal() async {
    try {
      // 檢查硬體限制
      final device = await DeviceCapabilities.detect();
      if (device.totalRamMb < 4096) {
        debugPrint('Device memory < 4GB, skipping local LLM');
        return false;
      }

      final active = modelManager.activeVariant('llm');
      if (active == null) return false;

      final modelPath = await modelManager.activeModelPath('llm');
      if (modelPath == null) return false;

      final success = await _inference.loadModel(modelPath);
      if (!success) {
        _error = '本地 LLM 載入失敗，嘗試遠程 API...';
      }
      return success;
    } catch (e) {
      debugPrint('Local LLM loading failed: $e');
      return false;
    }
  }

  Future<bool> _tryLoadRemote() async {
    try {
      if (_remoteProvider == null) return false;
      final ok = await _remoteProvider!.healthCheck();
      if (ok) {
        _error = null;
        debugPrint('Remote LLM API ready');
      } else {
        _error = '遠程 API 無可用連接';
      }
      return ok;
    } catch (e) {
      _error = '遠程 API 連接失敗: $e';
      debugPrint('Remote API check failed: $e');
      return false;
    }
  }

  /// 設置遠程 API 提供商
  void setRemoteProvider(RemoteLlmProvider provider) {
    _remoteProvider = provider;
    _useRemote = false;
    notifyListeners();
  }

  /// 釋放 LLM 佔用的記憶體
  void unload() {
    if (isLoaded) {
      _inference.unload();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _inference.dispose();
    super.dispose();
  }
}
