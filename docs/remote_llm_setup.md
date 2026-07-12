# 遠程 LLM API 集成指南

TruthLens App 支援多個遠程 LLM 提供商，作為本地 llama.cpp 推論的自動 fallback。

## 快速開始

### 方案 A：Ollama（本地開發，推薦）

**優勢**：完全離線、無需認證、速度快、開發友善

1. **安裝 Ollama**：https://ollama.ai
   ```bash
   # macOS / Linux / Windows 都支援
   ```

2. **啟動 Gemma 2B IT**
   ```bash
   ollama run gemma:2b-it-q4
   # 首次啟動會自動下載 ~5GB 模型
   # 後續啟動秒級完成
   ```

3. **在 Flutter App 中設定**
   ```dart
   import 'package:truthlens/core/detection/remote_llm_provider.dart';

   // 在 App 初始化時
   final ollamaProvider = OllamaProvider(
     baseUrl: 'http://localhost:11434',
     model: 'gemma:2b-it-q4',
   );
   llmManager.setRemoteProvider(ollamaProvider);

   // App 會自動：
   // 1. 嘗試本地 llama.cpp 模型
   // 2. 失敗 → 檢查 Ollama 連接
   // 3. 連接成功 → 使用 Ollama 進行推論
   ```

4. **測試**
   ```bash
   flutter run -d <device>
   # 在設定中測試文本分析
   # 查看 debugPrint 日誌驗證 API 呼叫
   ```

---

### 方案 B：Groq（快速雲服務）

**優勢**：超快（<1秒回應）、便宜、生產級穩定

1. **獲取 API Key**
   - 訪問 https://console.groq.com
   - 註冊並申請 API key
   - 配額：免費 30 req/min（足夠測試）

2. **在 Flutter App 中設定**
   ```dart
   import 'package:truthlens/core/detection/remote_llm_provider.dart';

   final groqProvider = GroqProvider(
     apiKey: 'gsk_YOUR_API_KEY_HERE',
     model: 'gemma-7b-it',  // 或其他 Groq 支援的模型
   );
   llmManager.setRemoteProvider(groqProvider);
   ```

3. **環境變數設定（可選）**
   ```bash
   export GROQ_API_KEY="gsk_YOUR_API_KEY_HERE"
   # App 可自動從環境讀取
   ```

4. **支援的模型**
   - `gemma-7b-it` — 語義理解好
   - `mixtral-8x7b-32768` — 更強模型
   - `llama2-70b-4096` — 高質量生成

---

### 方案 C：Together AI（多模型選擇）

**優勢**：模型選擇多、成本低、社區友善

1. **獲取 API Key**
   - 訪問 https://www.together.ai
   - 註冊獲取免費額度與 API key

2. **在 Flutter App 中設定**
   ```dart
   import 'package:truthlens/core/detection/remote_llm_provider.dart';

   final togetherProvider = TogetherAiProvider(
     apiKey: 'YOUR_TOGETHER_API_KEY',
     model: 'mistralai/Mistral-7B-Instruct-v0.1',
   );
   llmManager.setRemoteProvider(togetherProvider);
   ```

3. **支援的模型列表**
   - Mistral-7B 系列（推薦）
   - Llama-2 系列
   - GPT-J 系列
   - 完整列表：https://www.together.ai/docs/inference/models

---

### 方案 D：Anthropic Claude（最高品質）

**優勢**：最強模型、最穩定、最詳細回應

1. **獲取 API Key**
   - 訪問 https://console.anthropic.com
   - 申請 API key（付費服務）

2. **在 Flutter App 中設定**
   ```dart
   import 'package:truthlens/core/detection/remote_llm_provider.dart';

   final claudeProvider = AnthropicProvider(
     apiKey: 'sk-ant-YOUR_API_KEY_HERE',
     model: 'claude-3-haiku-20240307',  // 輕量級，適合成本控制
   );
   llmManager.setRemoteProvider(claudeProvider);
   ```

3. **推薦模型（按成本排序）**
   - `claude-3-haiku` — 最便宜、快速
   - `claude-3-sonnet` — 平衡方案
   - `claude-3-opus` — 最強、最貴

---

## 自動 Fallback 機制

App 會自動按優先順序嘗試：

```
1. 本地 llama.cpp 模型 (if available)
   ↓ 失敗/未安裝
2. 配置的遠程 API (Ollama/Groq/Together/Anthropic)
   ↓ API 不可用/無連接
3. ReportComposer 模板回退 (確定性結果，無 AI)
```

## 性能對比

| 方案 | 首次延遲 | 推論速度 | 成本 | 連接需求 | 適合場景 |
|------|---------|---------|------|---------|---------|
| **本地 llama.cpp** | 5-10s 載入 | 3-5s | ₩0 | 無 | 生產、隱私優先 |
| **Ollama** | 0s | 1-3s | ₩0 | 本地網路 | 開發測試 |
| **Groq** | 200ms | <1s | ¢ 低廉 | 網際網路 | 快速回應 |
| **Together** | 300ms | 1-2s | ¢ 低廉 | 網際網路 | 靈活選擇 |
| **Claude** | 500ms | 2-3s | $ 中等 | 網際網路 | 高品質 |

## 故障排除

### Ollama 連接失敗

```dart
// 檢查 Ollama 伺服器是否運行
final ok = await ollamaProvider.healthCheck();
if (!ok) {
  // Ollama 未運行
  // 1. 確認 ollama run gemma:2b-it-q4 在運行
  // 2. 檢查防火牆設定
  // 3. 驗證 http://localhost:11434 可訪問
}
```

### API Key 無效

```dart
// 檢查 API 連接
final ok = await groqProvider.healthCheck();
if (!ok) {
  // 1. 驗證 API key 正確性
  // 2. 檢查 API key 配額是否用盡
  // 3. 確認 API endpoint 可訪問
}
```

### 網路延遲

- 遠程 API 有 30 秒超時
- 超時自動回退至模板模式
- 檢查網路連接品質

## 開發建議

1. **本地開發**：用 Ollama
   ```bash
   ollama run gemma:2b-it-q4 &
   flutter run -d <device>
   ```

2. **CI/CD 測試**：用 Groq（自動化友善）
   ```bash
   export GROQ_API_KEY="${{ secrets.GROQ_API_KEY }}"
   flutter test
   ```

3. **生產部署**
   - 優先本地 GGUF 模型（隱私、成本）
   - 備用雲服務（Groq 最便宜/快）
   - 用戶可在設定手動選擇

## 相關文件

- `lib/core/detection/remote_llm_provider.dart` — 提供商實現
- `lib/core/detection/llm_manager.dart` — 管理器與 Fallback
- `test/core/detection/remote_llm_provider_test.dart` — 單元測試
- `docs/llm_model_hosting.md` — 完整模型指南
