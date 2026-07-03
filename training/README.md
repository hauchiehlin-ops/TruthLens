# TruthLens 檢測模型訓練

第一版 AI 內容檢測分類器的訓練流程，使用公開資料集微調多語言 Transformer，
輸出可在四平台部署的 INT8 量化 ONNX 模型。

## 為何走這條路

正式的訓練數據來源尚未拍板（見 [../docs/implementation_plan.md](../docs/implementation_plan.md) 審核項目）。
第一版先用公開資料集 **HC3**（Human ChatGPT Comparison Corpus，含英文與中文）建立可運作的基準，
待有專屬資料集後再擴充（加入更多 LLM 來源、改寫文本以訓練對抗模組 D 等）。

## 環境

- Python 3.14（venv 已建於 `.venv/`）
- PyTorch 2.12（Apple Silicon 自動用 MPS 加速）、Transformers 5、ONNX Runtime 1.27
- 首次執行會自動下載基底模型與資料集（需網路）

```bash
# 若要重建環境
python3.14 -m venv .venv
.venv/bin/python -m pip install torch transformers datasets scikit-learn onnx onnxruntime accelerate 'numpy<3'
```

## 流程

```bash
# 1. 下載並整理資料（HC3 英文 + 中文 → data/train.jsonl, data/val.jsonl）
#    預設每類別上限 3 萬，兼作類別平衡（原始 human 7.7 萬 / ai 4.4 萬）
.venv/bin/python prepare_data.py

# 2. 微調分類器（第一版 distilbert-multilingual，human/AI 二元 → artifacts/classifier）
.venv/bin/python train_classifier.py

# 3. 匯出 ONNX + INT8 量化（→ artifacts/detector_int8.onnx，約 135MB）
.venv/bin/python export_onnx.py

# 4. 驗證量化模型推論正確
.venv/bin/python verify_onnx.py
```

每個腳本都支援 `--quick`（小資料、1 epoch）用於快速驗證流程可跑通。

### 第一版 vs production 模型

| | 第一版（預設） | production 目標 |
| :--- | :--- | :--- |
| 基底模型 | distilbert-base-multilingual-cased | xlm-roberta-base（plan 指定） |
| MPS 速度 | ~1.3s/step | ~2s/step |
| 8 萬樣本 1 epoch | ~55 分 | 數小時（建議 CUDA / 過夜） |

切換只需改 [config.py](config.py) 的 `base_model`。第一版用較輕的 distilbert 先建立可運作基準；
品質衝刺時換回 xlm-roberta-base 並提高 epoch。

## 設定

所有超參數與資料集選擇集中在 [config.py](config.py)：基底模型、epoch、batch、
最大序列長度、每類別取樣上限、中文開關等。

## 部署到 App

1. 產出的 `xlmr_detector_int8.onnx` 是四平台通用格式（ONNX Runtime）
2. 上傳到 GitHub Releases，把 URL 與 sha256 填入
   [../lib/core/detection/model_registry.dart](../lib/core/detection/model_registry.dart) 的 `transformer` 項
3. 各平台原生端以 ONNX Runtime 載入並實作 `classify`
   （契約見 [../docs/native_inference_bridge.md](../docs/native_inference_bridge.md)）
4. 前/後處理（tokenizer 編碼 → logits → softmax 取 AI 機率）以
   [verify_onnx.py](verify_onnx.py) 為原生端的參考實作

> **注意**：registry 目前登記的檔名為 `.tflite`。第一版改用可攜的 ONNX，
> 部署前需將 `transformer` 的 `fileName` 改為 `xlmr_detector_int8.onnx`、`backend` 維持 transformer。

## 後續擴充

- **統計模型 B**：改用 DistilGPT2 計算真困惑度（另一套 pipeline）
- **對抗模組 D**：以改寫工具處理 HC3 的 AI 文本，標記為「改寫 AI」類別再訓練
- **資料多樣性**：加入 RAID、更多 LLM（Claude/Gemini/Llama）生成文本，降低單一來源偏差
- **ESL 偏差**：加入非母語者人類寫作樣本，校準偽陽性
