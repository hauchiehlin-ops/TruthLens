import 'package:flutter/foundation.dart';
import 'device_capabilities.dart';
import 'llama_ffi.dart';
import 'model_manager.dart';

/// 管理本地端 LLM 模型的生命週期與記憶體。
/// 支援低記憶體保護：小於 4GB RAM 的裝置自動拒絕載入 LLM。
class LlmManager extends ChangeNotifier {
  final ModelManager modelManager;
  final LlamaInference _inference = LlamaInference();
  bool _loading = false;
  String? _error;

  LlmManager({required this.modelManager});

  bool get isLoaded => _inference.isLoaded;
  bool get isLoading => _loading;
  String? get error => _error;
  LlamaInference get inference => _inference;

  /// 嘗試載入使用中的 LLM 模型
  Future<bool> loadIfAvailable() async {
    if (isLoaded) return true;
    if (_loading) return false;

    // 1. 檢查硬體限制
    final device = await DeviceCapabilities.detect();
    if (device.totalRamMb < 4096) {
      _error = '裝置記憶體不足 4GB，已停用本地 LLM 以保護系統穩定';
      notifyListeners();
      return false;
    }

    // 2. 檢查 LLM 模型是否已安裝
    final active = modelManager.activeVariant('llm');
    if (active == null) {
      _error = '尚未安裝或選擇報告生成 LLM 模型';
      return false;
    }

    final modelPath = await modelManager.activeModelPath('llm');
    if (modelPath == null) {
      _error = 'LLM 模型檔案不存在';
      return false;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _inference.loadModel(modelPath);
      if (success) {
        _error = null;
      } else {
        _error = 'LLM 模型載入失敗';
      }
      return success;
    } catch (e) {
      _error = '載入過程發生異常: $e';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
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
