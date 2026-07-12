# TruthLens 模型集成測試指南

## 概述

本文檔說明如何測試 TruthLens 中的模型下載、加載與推論集成。

## 測試環境設置

### 前置要求

```bash
# 確保已安裝依賴
cd /Users/barretlin/GitProjects/TruthLens
flutter pub get

# 啟動開發伺服器（Web）或仿真器（移動平台）
flutter run -d macos  # 或 -d chrome, -d ios
```

## 模型集成測試檢查表

### 1️⃣ 多語言偵測器（xlmr_detector_int8.onnx）

**測試場景**：App 下載並使用多語言檢測模型

```dart
// test/core/detection/model_integration_test.dart

import 'package:truthlens/core/detection/model_manager.dart';

void main() {
  group('Model Integration - Detector', () {
    late ModelManager modelManager;

    setUp(() {
      modelManager = ModelManager();
    });

    test('Download and load xlmr_detector_int8', () async {
      // 1. 檢查模型是否已可下載
      final model = await modelManager.getAvailableModels('detector');
      expect(model, isNotNull);
      expect(model?.url, contains('xlmr_detector_int8'));

      // 2. 下載模型
      final success = await modelManager.downloadModel(
        model!,
        onProgress: (progress) {
          print('Download progress: ${progress.toStringAsFixed(1)}%');
        },
      );
      expect(success, isTrue);

      // 3. 驗證檔案
      final localPath = await modelManager.getLocalModelPath(model.id);
      expect(File(localPath).existsSync(), isTrue);

      // 4. 驗證 SHA256
      final hash = await modelManager.calculateFileHash(localPath);
      expect(hash, model.sha256);
    });

    test('Run inference on detector model', () async {
      final model = await modelManager.getAvailableModels('detector');
      final session = await modelManager.loadModelSession(model!);

      final testTexts = [
        'This is AI-generated content.',
        'I went to the store yesterday.',
      ];

      for (final text in testTexts) {
        final result = await session.run({'input': text});
        expect(result, isNotNull);
        // 預期輸出：[not_ai_score, ai_score]
        expect(result.length, 2);
        expect(result.reduce((a, b) => a + b), closeTo(1.0, 0.01));
      }
    });
  });
}
```

### 2️⃣ 困惑度計算器（distilgpt2_int8.onnx）

**測試場景**：驗證困惑度計算精確度

```dart
test('Calculate perplexity with statistical model', () async {
  final modelManager = ModelManager();
  
  // 1. 加載困惑度模型
  final model = await modelManager.getAvailableModels('statistical');
  final scorer = PerplexityScorer.load(
    modelPath: model!.url!,
    tokenizerJsonPath: model.tokenizerUrl,
  );

  // 2. 測試已知文本
  final testCases = [
    ('The quick brown fox jumps over the lazy dog.', 400.0, 700.0),
    ('I went to the store and bought groceries.', 60.0, 150.0),
  ];

  for (final (text, minPpl, maxPpl) in testCases) {
    final ppl = await scorer.perplexity(text);
    expect(ppl, isNotNull);
    expect(ppl, greaterThanOrEqualTo(minPpl));
    expect(ppl, lessThanOrEqualTo(maxPpl));
  }
});
```

### 3️⃣ LLM 模型（Gemma-2B-IT GGUF）

**測試場景**：加載與推論 GGUF 模型

```dart
test('Load and infer with Gemma LLM', () async {
  final modelManager = ModelManager();
  
  // 1. 檢查 LLM 模型
  final llmModel = await modelManager.getAvailableModels('llm');
  expect(llmModel, isNotNull);
  expect(llmModel?.backend, 'languageModel');

  // 2. 處理分割模型
  if (llmModel!.isSplitModel) {
    final success = await modelManager.downloadAndMergeSplitModel(
      llmModel,
      onProgress: (progress) => print('Download: $progress%'),
    );
    expect(success, isTrue);
  }

  // 3. 加載 LLM
  final llm = await LlamaInference.load(
    modelPath: await modelManager.getLocalModelPath(llmModel.id),
  );
  expect(llm, isNotNull);

  // 4. 測試推論
  const prompt = 'This text appears to be AI-generated because:';
  final response = await llm.generate(prompt, maxTokens: 128);
  expect(response.isNotEmpty, isTrue);
  expect(response.length, greaterThan(50)); // 合理的回應長度
});
```

## 集成測試執行

### 命令行

```bash
# 運行所有模型集成測試
flutter test test/core/detection/model_integration_test.dart -v

# 或針對特定測試
flutter test test/core/detection/model_integration_test.dart \
  -k "Download and load xlmr_detector_int8"
```

### 在 IDE 中

1. 開啟 VS Code / Android Studio
2. 在測試檔案中右鍵點擊測試函數
3. 選擇「Run Test」或「Debug Test」

## 性能基準測試

### 推論延遲測試

```dart
test('Measure inference latency', () async {
  final modelManager = ModelManager();
  final detector = await modelManager.loadModel('detector');

  const testText = 'Sample text for latency measurement ' * 10;
  final stopwatch = Stopwatch()..start();

  for (int i = 0; i < 10; i++) {
    await detector.run({'input': testText});
  }

  stopwatch.stop();
  final avgLatency = stopwatch.elapsedMilliseconds / 10;
  
  print('Average latency: ${avgLatency.toStringAsFixed(2)}ms');
  
  // 預期：
  // - Detector: < 500ms
  // - Perplexity: < 1000ms
  // - LLM: < 5000ms (取決於硬體)
  expect(avgLatency, lessThan(500));
});
```

### 記憶體使用測試

```dart
test('Monitor memory usage during inference', () async {
  final modelManager = ModelManager();
  final detector = await modelManager.loadModel('detector');

  final info = await DeviceInfo.getMemoryInfo();
  final beforeMem = info.usedMemory;

  // 執行推論
  const testText = 'Sample text' * 100;
  await detector.run({'input': testText});

  final afterMem = info.usedMemory;
  final memUsed = afterMem - beforeMem;

  print('Memory used: ${(memUsed / 1024 / 1024).toStringAsFixed(2)}MB');
  
  // 預期：< 500MB per model
  expect(memUsed, lessThan(500 * 1024 * 1024));
});
```

## 測試覆蓋檢查表

- [ ] **模型下載**
  - [ ] 檢查 manifest 或 catalog 中的 URL
  - [ ] 驗證 SHA256 校驗和
  - [ ] 測試中斷恢復（pause/resume）

- [ ] **模型加載**
  - [ ] 驗證 ONNX Runtime 初始化
  - [ ] 檢查 session 狀態
  - [ ] 測試多個模型並行加載

- [ ] **推論**
  - [ ] 測試有效輸入
  - [ ] 測試邊界情況（空文本、超長文本）
  - [ ] 驗證輸出形狀與範圍

- [ ] **性能**
  - [ ] 推論延遲 < 預期值
  - [ ] 記憶體峰值 < 裝置限制
  - [ ] 模型卸載後成功釋放記憶體

- [ ] **錯誤處理**
  - [ ] 網路中斷時的下載重試
  - [ ] 磁盤空間不足的處理
  - [ ] 損壞模型檔案的檢測

## 已知限制與注意事項

1. **LLM 模型大小**：Gemma-2B-IT (~3.5GB) 需要良好的網路和充足磁盤空間
2. **推論速度**：CPU 推論較慢；建議優先使用 GPU（若可用）
3. **記憶體需求**：LLM 推論可能需要 4GB+ RAM；低端設備可能無法使用

## 參考資源

- [Model Manager 源代碼](../lib/core/detection/model_manager.dart)
- [ONNX Runtime Flutter 綁定](https://pub.dev/packages/onnx_runtime)
- [llama.cpp 文檔](https://github.com/ggerganov/llama.cpp)
