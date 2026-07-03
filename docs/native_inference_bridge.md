# 原生推論橋接契約

Dart 端已完成（[native_inference_service.dart](../lib/core/detection/native_inference_service.dart)），
透過 `MethodChannel('com.truthlens/inference')` 呼叫各平台原生實作。原生端尚未實作，
呼叫時會拋 `MissingPluginException`，Dart 端捕捉後讓對應引擎回報 unavailable（優雅降級）。

## 需要各平台實作的 method

| method | 參數 | 回傳 | 說明 |
| :--- | :--- | :--- | :--- |
| `ping` | — | `bool` | 原生端是否就緒（回 true 即啟用真推論） |
| `loadModel` | `{modelId, path, backend}` | `bool` | 載入模型檔到記憶體 |
| `classify` | `{modelId, text}` | `double` | AI 機率 0..1（分類器 A / D） |
| `perplexity` | `{modelId, text}` | `double` | 每 token 困惑度（統計模型 B / DistilGPT2） |
| `unload` | `{modelId}` | — | 釋放模型 |

`backend` 值來自 [model_registry.dart](../lib/core/detection/model_registry.dart) 的 `InferenceBackend`：
`transformer`（TFLite/CoreML/ONNX 分類器）或 `languageModel`（llama.cpp）。

## 各平台實作對應（plan 第七節）

| 平台 | 檔案位置 | 推論引擎 | 硬體加速 |
| :--- | :--- | :--- | :--- |
| Android | `android/app/src/main/kotlin/.../InferencePlugin.kt` | TFLite (LiteRT) + llama.cpp | NNAPI + GPU Delegate |
| iOS | `ios/Runner/InferencePlugin.swift` | Core ML + llama.cpp | Neural Engine (A14+) |
| macOS | `macos/Runner/InferencePlugin.swift` | Core ML + llama.cpp | Neural Engine (M1+) |
| Windows | `windows/runner/inference_plugin.cpp` | ONNX Runtime + llama.cpp | DirectML |

## 尚缺的前置條件

1. **訓練好的模型檔**（審核項目：訓練數據來源未定）——分類器 A、統計 B、對抗 D、LLM
2. 模型發佈到 GitHub Releases / CDN 後，將 URL 與 sha256 填入 `kModelRegistry`，
   `ModelManager` 即可下載安裝（下載/校驗/熱替換邏輯已完成）
3. 各平台原生 plugin 註冊到對應的 `AppDelegate` / `MainActivity` / plugin registrant

## 資料流

```
使用者文本 → EnsembleOrchestrator
  → 各 DetectionEngine.isAvailable()  (檢查 ModelManager.canRunEngine + native.isSupported)
  → 可用引擎 analyze() → native.classify/perplexity()  (原生推論)
  → 加權投票（不可用引擎權重按比例重分配；ESL 修正）
  → DetectionResult
```
