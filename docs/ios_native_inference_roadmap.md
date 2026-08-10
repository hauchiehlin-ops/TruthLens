# iOS 原生推論實現路線圖

## 當前狀態（2026-08-10）

### ✅ 已完成
- `ios/Runner/InferencePlugin.swift`：MethodChannel 基層框架
- `ios/Runner/OnnxInferenceHelper.swift`：ONNX Runtime 模型管理層
- iOS AppDelegate 中已註冊 `com.truthlens/inference` channel

### ⚠️ 占位實作（需後續完成）

#### InferencePlugin
- `loadModel()` — 已支援 ONNX 檔案偵測，但未實現 ORTSession 初始化
- `classify()` — 暫時回傳 0.5（占位值），需要：
  1. Tokenizer 初始化（BERT WordPiece 或 RoBERTa BPE）
  2. 文本 → Token ID 轉換
  3. 張量準備（輸入 shape 對應）
  4. ORTSession::Run() 推論
  5. Softmax 或 Sigmoid 解析

#### OnnxInferenceHelper
- `classify()` — 目前只檢查檔案存在性，需實現上述完整推論邏輯
- `perplexity()` — 返回 nil（困惑度用統計模型，不需 ONNX）

---

## 完整實現計劃

### Phase 1：ONNX Runtime Objective-C 橋接
**優先級**：最高（阻止目前所有模型推論）

1. **驗證 Podfile 配置**
   ```ruby
   # ios/Podfile 應包含
   pod 'onnxruntime-objc'  # 確保已安裝
   ```

2. **建立 Objective-C++ 橋接層** → `ios/Runner/OnnxBridge.mm`
   ```objc
   // 職責：C++ 的 ort_cxx_api.h <→> Swift OnnxInferenceHelper
   #import <onnxruntime/ort_cxx_api.h>
   
   class OnnxSessionManager {
     std::unordered_map<std::string, Ort::Session*> sessions;
     Ort::Env env{ORT_LOGGING_LEVEL_WARNING, "truthlens-ios"};
   };
   ```

3. **實裝 OnnxInferenceHelper 的完整推論邏輯**
   - 初始化 ONNX Runtime 環境（Env, SessionOptions）
   - 載入模型並檢查輸入/輸出 shape
   - 實作 Tokenizer（共用 tokenizer_registry）
   - 執行推論並解析機率輸出

### Phase 2：Core ML 轉換支援（可選，長期）
如果要支援 Apple 的 Core ML 優化：
1. 在 CI/CD 中新增 ONNX → Core ML 轉換步驟（coreml-tools）
2. InferencePlugin 優先使用 Core ML（更快），回退到 ONNX

### Phase 3：Metal 加速（未來）
- ONNX Runtime 支援 Metal（GPU 推論），自動啟用
- 無需額外配置，已包含在 onnxruntime-objc 中

---

## 為什麼目前返回占位值？

### 原因
1. **動態庫鏈接問題**：當前 iOS 構建中，ONNX Runtime C 庫的符號 (`OrtGetApiBase`) 無法正確解析
2. **Objective-C++ 複雜性**：直接在 Swift 中無法使用 C++ API，需要 `.mm` 橋接
3. **時間優先排序**：Dart Fallback 已實現完整的統計引擎與風格分析，部分功能可用

### 使用者體驗
- Transformer 模型：「未安裝」(因為推論失敗被隔離)
- Adversarial 模型：「未安裝」
- 統計分析 ✅：可用（無需原生）
- 風格特徵 ✅：可用（純 Dart）

**結果**：權重覆蓋 ~45%，標記為「低信心」（正確行為）

---

## 下一步行動

### 優先級順序

1. **立即（本周）**
   - [ ] 驗證 iOS Podfile 中 onnxruntime-objc 版本
   - [ ] 確認 iOS 構建 log 中是否有符號未解析的警告
   - [ ] 測試 Android 是否有同樣問題（可能是 Podfile 配置缺陷）

2. **短期（1-2 周）**
   - [ ] 實現 Objective-C++ 橋接 (`OnnxBridge.mm`)
   - [ ] 整合 tokenizer 到 OnnxInferenceHelper
   - [ ] 完成 `classify()` 的推論邏輯

3. **中期（2-4 周）**
   - [ ] Android TFLite 推論橋接
   - [ ] Windows ONNX Runtime 推論橋接
   - [ ] 統一的模型管理介面

---

## 技術參考

### ONNX Runtime iOS 支援
- 官方文件：https://onnxruntime.ai/docs/build/ios.html
- Pod: `onnxruntime-objc` (CocoaPods)
- 版本：根據 Podfile.lock 確認

### Objective-C++ 使用
- 檔案後綴：`.mm` (不是 `.swift` 或 `.m`)
- 可同時 `#import <onnxruntime/...>` 和 `#import "OnnxInferenceHelper.h"`
- 需要 Bridging Header 或在 SwiftUI 中暴露 Objective-C 介面

### 文本 Tokenization
- 共用 `lib/core/utils/tokenizer_registry.dart`（Dart 端已實現 BERT/RoBERTa）
- iOS 端：複製相同邏輯或透過 channel 呼叫 Dart tokenizer（慢但穩妥）

---

## 風險與回退

### 如果 ONNX Runtime iOS 無法順利集成
**回退方案**：
1. 使用純 Dart ONNX Runtime（存在，但慢）
2. 暫時使用 HTTP 推論服務（需後端，違反離線原則）
3. 轉換所有模型為 Core ML（需時間，不是所有模型都支援）

### 已驗證的替代方案
- ✅ 統計分析引擎（不需原生，已可用）
- ✅ 風格特徵引擎（Dart，已可用）
- ❌ LLM 生成報告（待 llama.cpp Metal 實裝）
