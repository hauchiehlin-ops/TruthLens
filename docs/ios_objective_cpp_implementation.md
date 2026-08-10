# iOS Objective-C++ 推論實裝詳解

## 概述

本文檔詳述 iOS 原生推論層的完整實裝方案，包括三層架構與具體實現細節。

## 架構設計

### 層次划分

```
┌─────────────────────────────────────────────┐
│ Flutter Dart 層                              │
│ (lib/core/detection/native_inference_...)   │
└──────────────┬──────────────────────────────┘
               │ MethodChannel
               │ ("com.truthlens/inference")
               ↓
┌─────────────────────────────────────────────┐
│ Swift 層 (InferencePlugin.swift)             │
│ - MethodCall 路由                            │
│ - 檔案路徑解析                               │
│ - 非同步任務分派                             │
└──────────────┬──────────────────────────────┘
               │ 呼叫
               ↓
┌─────────────────────────────────────────────┐
│ Objective-C 層 (InferenceHelper.h/mm)        │
│ - 公開 API                                   │
│ - 全局會話管理                               │
│ - Objective-C++ 橋接                         │
└──────────────┬──────────────────────────────┘
               │ 呼叫
               ↓
┌─────────────────────────────────────────────┐
│ C++ 層 (InferenceHelper.mm 內嵌)             │
│ - SimpleWordPieceTokenizer                   │
│ - SimpleOnnxSession                          │
│ - ONNX Runtime 推論                          │
└──────────────┬──────────────────────────────┘
               │ 使用
               ↓
┌─────────────────────────────────────────────┐
│ ONNX Runtime C++ API                         │
│ - Ort::Session 推論                          │
│ - CoreML / CPU 執行                          │
└─────────────────────────────────────────────┘
```

## 文件清單

| 文件 | 類型 | 職責 |
|------|------|------|
| `ios/Runner/InferencePlugin.swift` | Swift | MethodChannel 處理、檔案解析 |
| `ios/Runner/InferenceHelper.h` | Objective-C | 公開 API 定義 |
| `ios/Runner/InferenceHelper.mm` | Objective-C++ | C++ 實裝與橋接 |
| `ios/Runner/TokenizerCore.hpp` | C++ Header | 完整 Tokenizer 實現參考 |
| `ios/Runner/OnnxRuntime.hpp` | C++ Header | ONNX 會話包裝參考 |
| `ios/Runner/OnnxBridge.mm` | Objective-C++ | 備用：完整實裝版本 |
| `ios/Runner/Runner-Bridging-Header.h` | 配置 | Swift ↔ Objective-C 橋接 |

## 核心實裝詳解

### 1. Tokenizer 實裝

#### 簡化版（當前使用）
```cpp
class SimpleWordPieceTokenizer {
  // JSON 配置加載（簡化）
  bool loadFromJson(const std::string& jsonPath);
  
  // 文本編碼：[CLS] token1 token2 ... [SEP]
  EncodedTokens encode(const std::string& text, int maxLen = 192);
};
```

**特性**：
- ✅ 基本空白符切分
- ✅ UNK（未知詞）處理
- ✅ CLS/SEP 特殊 token 追加
- ❌ 標點符號分割（簡化）
- ❌ WordPiece 子詞匹配（簡化）

#### 完整版（TokenizerCore.hpp）
如需完整實裝，參考 `TokenizerCore.hpp`：
- ✅ 完整 JSON vocab 解析（nlohmann/json）
- ✅ CJK 字符逐字分隔
- ✅ 標點符號切分（Punct Split）
- ✅ WordPiece 貪心匹配（##subword）
- ✅ RoBERTa BPE 支援（備用）

### 2. ONNX Runtime 會話

```cpp
class SimpleOnnxSession {
  // 模型 + Tokenizer 初始化
  bool load(const std::string& modelPath,
            const std::string& tokenizerPath,
            const std::string& tokenizerType);
  
  // 推論：文本 → AI 機率 [0.0, 1.0]
  double classify(const std::string& text);
};
```

**推論流程**：
1. **Tokenization**：`text` → `[CLS, token_1, ..., token_n, SEP]`
2. **張量準備**：`[input_ids, attention_mask]` → Ort::Value
3. **推論執行**：`session->Run()` → 輸出張量
4. **機率提取**：輸出 `[logits_class_0, logits_class_1]` → Softmax → `logits[1]` ≈ AI 機率

### 3. Objective-C 包裝

```objc
@interface InferenceHelper : NSObject
+ (InferenceHelper*)sharedInstance;
- (BOOL)loadModel:(NSString*)modelId ... ;
- (double)classify:(NSString*)modelId text:(NSString*)text;
- (BOOL)isLoaded:(NSString*)modelId;
- (void)unload:(NSString*)modelId;
@end
```

**實作細節**：
- 使用全局 `std::unordered_map<string, unique_ptr<SimpleOnnxSession>>` 管理會話
- 每個 modelId 對應一個獨立的會話（模型 + Tokenizer）
- 推論在後臺線程執行（`DispatchQueue.global(qos: .userInitiated)`）

## 集成步驟

### 1. 確保依賴

在 `ios/Podfile` 中確認：
```ruby
pod 'onnxruntime-objc'  # ONNX Runtime Objective-C 包裝
```

### 2. Xcode 配置

**Build Settings**：
- `SWIFT_OBJC_BRIDGING_HEADER = "Runner/Runner-Bridging-Header.h"`
- `OTHER_CPLUSPLUSFLAGS = -fPIC` （如需要）
- `ENABLE_BITCODE = NO` （ONNX Runtime 要求）

**Build Phases**：
- 確保 `InferenceHelper.mm` 編譯到 Compile Sources（Objective-C++ 源）

### 3. 測試

```swift
// Swift 測試：
let helper = InferenceHelper.sharedInstance()
let success = helper.loadModel("transformer_v1", 
                               modelPath: "...",
                               tokenizerPath: "...",
                               tokenizerType: "bert-wordpiece")
if success {
  let prob = helper.classify("test model", text: "Some text")
  print("AI probability: \(prob)")
}
```

## 已知限制與改進方向

### 當前限制

1. **Tokenizer 簡化**
   - 不支援標點分割、WordPiece 子詞匹配
   - 僅用於測試與驗證架構
   - 完整版見 `TokenizerCore.hpp`

2. **模型推論假設**
   - 假設輸出為 `[batch=1, classes=2]`
   - 某些模型可能輸出 logits、softmax、sigmoid 等不同格式
   - 需根據實際模型驗證與調整

3. **錯誤處理**
   - 簡化實裝無詳細錯誤診斷
   - 推論失敗時返回 0.5（中立值）

### 改進方向

| 優先級 | 項目 | 工作量 | 預期效益 |
|--------|------|--------|----------|
| 🔴 高 | 完整 Tokenizer 實裝 | ~200 行 | 準確的文本編碼 |
| 🔴 高 | 模型輸出格式檢測 | ~50 行 | 支援更多模型類型 |
| 🟡 中 | CoreML 轉換支援 | ~100 行 | 性能優化 (GPU 推論) |
| 🟡 中 | 詳細錯誤診斷 | ~100 行 | 用戶友好的診斷信息 |
| 🟢 低 | 批量推論支援 | ~150 行 | 性能優化 |
| 🟢 低 | 模型預熱機制 | ~50 行 | 降低首次推論延遲 |

## 性能考量

### 推論延遲目標
- **首次推論**（含模型加載）：< 2 秒
- **後續推論**（模型已加載）：< 500 毫秒
- **文本長度**：最多 192 token

### 內存使用
- 單個 BERT 模型：~300 MB
- Tokenizer 緩存：~ 5 MB
- 每個會話開銷：~ 50 MB

### 優化建議
1. 延遲加載：第一次使用時才加載模型
2. 模型共享：多個引擎共享同一模型會話
3. 輸入緩存：避免重複編碼相同文本

## 後續平台適配

### Android
- 使用 TFLite (LiteRT) 或 ONNX Runtime JNI
- 類似架構：Dart → Kotlin → C++ JNI

### Windows
- 使用 ONNX Runtime C++ API 直接集成
- 不需要 Objective-C++ 橋接

### macOS
- 已完成（Phase 4：llama.cpp + Core ML）

## 參考資源

- [ONNX Runtime iOS 官方文檔](https://onnxruntime.ai/docs/build/ios.html)
- [Dart FFI vs MethodChannel](https://flutter.dev/docs/development/platform-integration/platform-channels)
- [Objective-C++ 混編指南](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocLanguageOverview.html)
- [BERT Tokenizer 實裝參考](https://github.com/google-research/bert)

## 技術支援

如遇構建或執行問題：

1. **符號未解析**（`OrtGetApiBase`）
   - 檢查 `onnxruntime-objc` 版本
   - 確認 CocoaPods 已執行 `pod install`
   - 清潔構建：`flutter clean && flutter pub get`

2. **Tokenizer JSON 解析失敗**
   - 驗證 tokenizer.json 檔案存在性
   - 檢查檔案編碼（應為 UTF-8）
   - 嘗試使用完整版 Tokenizer (`TokenizerCore.hpp`)

3. **推論返回 0.5（失敗信號）**
   - 檢查模型輸出格式（是否為 `[1, 2]`）
   - 驗證 tokenizer 是否正確初始化
   - 查看 iOS 系統日誌：`NSLog` 輸出
