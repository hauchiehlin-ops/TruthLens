# TruthLens LLM 模型 Hosting 指南

## 概述

TruthLens 支援在裝置端執行 LLM 進行報告生成。本文檔說明如何設置、測試與分發 LLM 模型。

## 支援的模型

### 推薦模型

| 模型 | 大小（Q4） | 語言 | 用途 | 狀態 |
|------|-----------|------|------|------|
| **Gemma-2B-IT** | 3.5GB | 多語言 | 輕量報告生成 | ⏳ Hosting |
| **Qwen-7B** | 5.2GB | 中英 | 高質量報告 | ⏳ 待評估 |
| **Phi-3-Mini** | 2.8GB | 英文 | 快速推論 | ⏳ 待評估 |

## 設置步驟

### 1. 下載模型

#### 方案 A：HuggingFace (推薦)

```bash
# 安裝 huggingface-hub
pip install huggingface-hub

# 下載 Gemma-2B-IT GGUF
huggingface-cli download google/gemma-2b-it-gguf \
  gemma-2b-it-q4.gguf \
  --repo-type model \
  --local-dir ./models
```

#### 方案 B：直接下載

```bash
# Ollama 官方模型庫（有 GGUF 版本）
wget https://registry.ollama.ai/v2/google/gemma-2b-it/blobs/sha256:...

# 或從 llama.cpp 社群模型倉庫
# https://github.com/ggerganov/llama.cpp/discussions/3404
```

### 2. 分割大檔案（GitHub 2GB 限制）

```bash
# 使用 split 命令（macOS/Linux）
split -b 1.8G gemma-2b-it-q4.gguf gemma-2b-part-
# 輸出: gemma-2b-part-aa, gemma-2b-part-ab, ...

# 或使用 Python 分割
python3 -c "
import sys
with open('gemma-2b-it-q4.gguf', 'rb') as f:
    data = f.read()
part_size = 1.8 * 1024**3  # 1.8GB
for i, start in enumerate(range(0, len(data), int(part_size))):
    with open(f'gemma-2b-part-{chr(97+i)}{chr(97+i)}', 'wb') as out:
        out.write(data[start:start+int(part_size)])
"
```

### 3. 計算校驗和

```bash
# 用於驗證下載的完整性
sha256sum gemma-2b-it-q4.gguf > gemma-2b.sha256
sha256sum gemma-2b-part-* >> gemma-2b.sha256

# 或單個文件
for f in gemma-2b-part-*; do sha256sum "$f"; done
```

### 4. 上傳到 GitHub Release

```bash
# 創建 Release
gh release create v0.1-models-llm \
  --title "LLM Model Release: Gemma-2B-IT" \
  --notes "Gemma-2B-IT for on-device report generation"

# 上傳分割部分（GitHub Actions 或手動）
gh release upload v0.1-models-llm gemma-2b-part-aa gemma-2b-part-ab ...

# 上傳合併腳本和校驗和
gh release upload v0.1-models-llm merge_model.sh gemma-2b.sha256
```

### 5. 提供合併腳本

**merge_model.sh**：
```bash
#!/bin/bash
# 用戶端合併分割模型的腳本

PART_DIR="${1:-.}"
OUTPUT="gemma-2b-it-q4.gguf"

# 合併所有分割部分
cat "$PART_DIR"/gemma-2b-part-* > "$OUTPUT"

# 驗證校驗和（可選）
if [ -f "$PART_DIR/gemma-2b.sha256" ]; then
    sha256sum -c "$PART_DIR/gemma-2b.sha256"
    if [ $? -eq 0 ]; then
        echo "✅ Model verification passed"
    else
        echo "❌ Checksum mismatch, model may be corrupted"
        rm "$OUTPUT"
        exit 1
    fi
fi

echo "✅ Model merged successfully: $OUTPUT"
```

## 模型集成（App 端）

### model_registry.dart

```dart
// 在 lib/core/detection/model_registry.dart 中添加

const llmModelEntry = ModelEntry(
  id: 'gemma-2b-it-q4',
  name: 'Gemma 2B IT',
  version: '1.0.0',
  fileSize: 3.5 * 1024 * 1024 * 1024, // 3.5GB
  isSplitModel: true,  // 標記為分割模型
  parts: ['gemma-2b-part-aa', 'gemma-2b-part-ab', ...],  // 各分割大小
  downloadUrl: 'https://github.com/hauchiehlin-ops/TruthLens/releases/download/v0.1-models-llm/',
  mergeScript: 'https://github.com/.../merge_model.sh',
  hash: 'sha256:...',
  description: 'Lightweight LLM for on-device report generation',
);
```

### 模型下載管理器

```dart
// lib/core/models/model_downloader.dart

class ModelDownloader {
  /// 下載分割模型並自動合併
  Future<String> downloadSplitModel(ModelEntry entry) async {
    final parts = <String>[];
    
    // 下載各分割部分
    for (final part in entry.parts) {
      final url = '${entry.downloadUrl}$part';
      final bytes = await _downloadFile(url);
      parts.add(bytes);
    }
    
    // 合併分割部分
    final merged = BytesBuilder();
    for (final bytes in parts) {
      merged.add(bytes);
    }
    
    // 驗證校驗和
    final data = merged.toBytes();
    final computed = sha256.convert(data);
    if (computed.toString() != entry.hash.split(':').last) {
      throw StateError('Model hash mismatch');
    }
    
    // 保存到本地儲存
    final path = await _getSavedModelPath(entry.id);
    await File(path).writeAsBytes(data);
    
    return path;
  }
}
```

## 測試

### 本地測試

```python
# training/test_llm_inference.py

import onnxruntime as rt
from llama_cpp import Llama

def test_gemma_inference():
    # 加載模型
    llm = Llama(
        model_path="models/gemma-2b-it-q4.gguf",
        n_gpu_layers=-1,  # 完全 GPU 加速（如果可用）
        verbose=False,
    )
    
    # 測試推論
    prompt = "The following text is suspicious. Explain why:\n\n"
    prompt += "This is definitely AI-generated content."
    
    response = llm(
        prompt,
        max_tokens=256,
        temperature=0.7,
    )
    
    print("Generated report:")
    print(response['choices'][0]['text'])
```

### 大小與性能

| 平台 | RAM | 推論時間（256 tokens） | 狀態 |
|------|-----|--------|--------|
| macOS M1 | 8GB | ~3.5s | ✅ 可用 |
| iPhone 14+ | 6GB | ~8-10s | ⏳ 測試中 |
| Android (Snapdragon 8 Gen 2) | 8GB | ~5-7s | ⏳ 測試中 |

## 已知限制

1. **大檔案**：Gemma-2B-IT 3.5GB 需要良好的網路連接
2. **存儲空間**：裝置需要 ~5GB 可用空間（下載 + 解壓縮）
3. **記憶體**：推論時需要 ~4GB RAM（Q4 量化版本）
4. **推論速度**：CPU 推論較慢，建議 GPU 加速

## 替代方案

### 遠程推論（將來）

若裝置存儲/性能不足，考慮遠程推論：

```dart
// 使用遠程 API（如 Replicate、Together AI）
final client = ReplicateApi(apiKey: userApiKey);
final output = await client.run(
  model: 'google/gemma-2b-it',
  input: {'prompt': reportText},
);
```

### 模型蒸餾

針對更小的設備，可考慮：
- Phi-2 (2.7B)
- TinyLLama (1.1B)
- MobileLLM (125M-350M)

## 參考資源

- [Gemma 官方指南](https://ai.google.dev/gemma)
- [llama.cpp 模型支援](https://github.com/ggerganov/llama.cpp/discussions/3404)
- [HuggingFace GGUF 模型](https://huggingface.co/models?library=gguf)
