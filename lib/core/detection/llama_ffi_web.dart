/// llama.cpp 在 web 上沒有 dart:ffi 可用，也還沒有 WASM 版推論引擎（見
/// docs/implementation_plan.md 後續階段規劃）。此 stub 讓 [LlmManager] 的既有
/// 「嘗試載入 → 失敗則回退模板報告」邏輯在瀏覽器上自然生效，不需要另外改
/// report_llm_service.dart：isLoaded 恆為 false，loadModel 恆回傳 false。
class LlamaFfi {
  static bool get isAvailable => false;
}

class LlamaInference {
  bool get isLoaded => false;

  Future<bool> loadModel(String modelPath) async => false;

  Future<String> generate(String prompt, {int maxTokens = 256}) async => '';

  void unload() {}

  void dispose() {}
}
