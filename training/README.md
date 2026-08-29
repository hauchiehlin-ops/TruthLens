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
.venv/bin/python -m pip install torch transformers datasets scikit-learn onnx onnxruntime accelerate opencc-python-reimplemented 'numpy<3'
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

## 現代 AI／人類化輸出更新流程

HC3 的 ChatGPT 樣本來自 2022 年，不可再單獨代表現代模型。新一輪模型更新先用
`binoculars/generate_ai_corpus.py` 從至少兩家供應商產生 `standard`、`nonnative`、
`humanized`、`light_edit` 等語域，再與同題的人類文件合併。切分必須使用
`prepare_modern_training_data.py`，它會按原始題目 `group_id` 分組，避免同題改寫
同時落入訓練與驗證集。

```bash
.venv/bin/python binoculars/prepare_corpus.py \
  --human-dir /path/to/controlled-human \
  --ai-dir binoculars/data/ai_generated \
  --out binoculars/data/modern_corpus.jsonl

.venv/bin/python prepare_modern_training_data.py \
  --corpus binoculars/data/modern_corpus.jsonl \
  --out-dir data

.venv/bin/python train_classifier.py --modern
```

模型不得只看整體 accuracy。發布前需按供應商、語域、語言分組回報召回率，並保留
從未進入訓練的供應商作為真正的外部測試集；否則量到的只是模型記住生成器指紋。

### 高特異性操作點與學術 hard negatives

「95% 可信」不能由單篇分數或整體 accuracy 宣告。先把已知來源文件分成互斥的
`calibration`／`test`，推論結果逐列保存 `doc_id`、`label`、`score`、`split`，並建議
在 manifest 標示 `domain`（例如 `academic_stem`、`academic_humanities`、`essay`）與
`language`。再以 1% 偽陽性率選操作點：

```bash
.venv/bin/python evaluate_operating_point.py \
  --predictions data/held_out_predictions.jsonl \
  --target-fpr 0.01 \
  --report data/operating_point.json \
  --hard-negatives data/hard_negative_humans.jsonl \
  --hard-positives data/missed_ai.jsonl \
  --min-recall 0.50 \
  --independent-test \
  --benchmark-id raid \
  --benchmark-id semeval-2024-task8 \
  --detector-signature truthlens-v4.5.0-fusion-v3 \
  --required-language en --required-language zh \
  --required-domain academic --required-domain general
```

腳本會先把同一文件的多個切塊合併，避免把切塊數誤當獨立樣本，並拒絕任何
`group_id` 跨越 calibration／test；門檻只由 calibration 選定，FPR、95% 上界與
AI recall 只在 test 計算。公平性按 domain／language 檢查，
韌性按 provider／style／attack／human-AI 混合類別檢查。`release_gate_passed` 必須同時
通過整體、所有樣本量足夠的分組及明列的 required 語言／領域；缺少足量 required
分組會直接失敗。calibration 中的獨立真人文件數也必須至少為
`ceil(1 / target_fpr)`。被誤判的真人文件與漏判的 AI 文件都會保留原文輸出，供下一輪
hard-negative／hard-positive 訓練；重訓後仍須換一批未見 test 文件重測。

發布聲明另受 `training/benchmark_contract.json` 約束，CI 會以
`training/validate_release_evidence.py` 驗證 `training/validation/current.json`。
未提供 `--independent-test`、benchmark ID 與 detector signature 時，評測仍會產生
診斷報告，但 `status` 保持 `not_yet_externally_validated`，不得用來宣稱產品已驗證。

每個腳本都支援 `--quick`（小資料、1 epoch）用於快速驗證流程可跑通。

### 第一版 vs production 模型

| | 第一版（預設） | production 目標 |
| :--- | :--- | :--- |
| 基底模型 | distilbert-base-multilingual-cased | xlm-roberta-base（plan 指定） |
| MPS 速度 | ~1.3s/step | ~2s/step |
| 8 萬樣本 1 epoch | ~55 分 | 數小時（建議 CUDA / 過夜） |

切換只需改 [config.py](config.py) 的 `base_model`。第一版用較輕的 distilbert 先建立可運作基準；
品質衝刺時換回 xlm-roberta-base 並提高 epoch。

## 中文詞彙指紋（字元 SVM）

App 打包的 `assets/models/detectrl_zh_char_svm.json` 由此流程產出。刻意做成單向閘門：
只有跨過開發集真人分數分位數的樣本才會投 AI 票，低分**不**反向投人類票——分布外或
經改寫的生成文不該變成一張假的人類票。

### 取得資料

```bash
# NLPCC-2025（約 71MB）
mkdir -p data/nlpcc2025 && cd data/nlpcc2025
for f in train.json dev.json test_with_label.json; do
  curl -sL -O "https://raw.githubusercontent.com/NLP2CT/NLPCC-2025-Task1/main/data/$f"
done

# DetectRL-X 的通用切分（838MB，MIT）——涵蓋 DeepSeek-V3／Gemini-2.5-Flash／
# GPT-4o／Qwen-Max，且每筆記錄自帶配對的人類文本
mkdir -p ../detectrl_x && cd ../detectrl_x
curl -sL -O "https://huggingface.co/datasets/WUJUNCHAO/DetectRL-X/resolve/main/Binary/binary_general_open.json"
```

`data/` 已在 `.gitignore` 內，不會進版控。

### 抽取與合併

```bash
.venv/bin/python prepare_detectrl_x_language.py --lang chinese --code zh
```

抽取時依「記錄」而非「樣本」切分——每筆記錄的人類與 LLM 兩半來自同一份原始文件，
分到不同側就會讓模型背來源而不是學作者訊號。

合併 DetectRL-X 與 NLPCC 的 train/dev（見 DEVLOG 第一百五十一次更新的腳本），
兩者互補：前者提供 2026 生成器，後者提供另一種人類寫作分布（問答式）。

### 匯出

```bash
.venv/bin/python export_detectrl_zh_char_svm.py \
  --train data/zh_combined/train.json --dev data/zh_combined/dev.json \
  --test data/detectrl_x/zh/test_with_label.json \
  --language zh --human-quantile 0.995 \
  --source "DetectRL-X (WUJUNCHAO/DetectRL-X, MIT) + NLPCC 2025 Shared Task 1 / DetectRL-ZH" \
  --source-url "https://huggingface.co/datasets/WUJUNCHAO/DetectRL-X" \
  --training-generators "DeepSeek-V3,Gemini-2.5-Flash,GPT-4o,Qwen-Max,GLM-4-flash,Qwen-turbo" \
  --independent-test-generator "DeepSeek-V3,Gemini-2.5-Flash,GPT-4o,Qwen-Max" \
  --output ../assets/models/detectrl_zh_char_svm.json
```

`--human-quantile` 是誤報預算的旋鈕。0.99 在開發集上約當 1% 誤報，但那是「在這份
開發集上」；實測 NLPCC test 會跑到 1.73%，超出合約預算。0.995 買到跨語料的安全邊際。

### 出貨模型的實測（v2，2026-08-29）

| 語料 | 舊模型 | 新模型 |
|---|---|---|
| DetectRL-X test（2026 生成器） | 誤報 3.88% ❌／召回 64.9% | **誤報 0.00% ✅／召回 94.9%** |
| SemEval 中文（2023 生成器） | 0.83% ✅／33.1% | 0.10% ✅／9.1% |
| NLPCC test | 1.83% ❌／63.7% | **0.82% ✅／67.5%** |

分生成器召回：Gemini-2.5-Flash **66.6% → 96.5%**、GPT-4o 71.7% → 94.6%、
DeepSeek-V3 33.9% → 89.8%、Qwen-Max 87.3% → 98.8%；真人誤報 0/6000。

舊模型在三份語料中有兩份超出 1% 誤報預算，新模型三份全過。SemEval 的退步是唯一
代價，而那份語料的生成器是 2023 年的 chatGPT／davinci。

### 兩個必須記住的教訓

**只用 DetectRL-X 訓練會產生一個看似完美的廢模型。** 語料內 AUC 0.9999、召回 99.9%，
但在 NLPCC 上把 **67% 的真人中文指控成 AI**。已驗證不是資料洩漏（train/test 人類文本
重疊僅 1 筆／約 14000），純粹是它的人類文本分布（News/Novel/SEO/Wiki，全是專業寫作）
太窄。合併 NLPCC 的問答式人類文本才解決。

**還有一個尚未涵蓋的語域。** 「助理回覆」——聊天模型針對提問給出的、帶標題與編號
建議、以第二人稱稱呼使用者的回應——目前兩份語料都沒有。實際使用者文件在這個語域下
重訓前後都是 0/100。DetectRL-X 的五個領域全是「改寫／續寫既有文件」，不是「回答提問」。

## 中文 Transformer 的外部驗證

風格引擎的詞彙通道只佔 20% 權重；中文真正吃重的是權重 40% 的
`aigc-detector-zhv3-int8`。`evaluate_external_zh_transformer.py` 以 App 的推論契約
（WordPiece 截斷至 192 token、只餵 `input_ids` 與 `attention_mask`、softmax 取
`ai_label_index`）重放出貨模型：

```bash
# 取得模型（catalog 內的 sha256 需一致）
mkdir -p artifacts/zhv3 && cd artifacts/zhv3
curl -sLO "https://huggingface.co/hauchieh/truthlens-models/resolve/main/aigc_detector_zhv3_int8.onnx"
curl -sLO "https://huggingface.co/hauchieh/truthlens-models/resolve/main/aigc_detector_zhv3_tokenizer.json"

.venv/bin/python evaluate_external_zh_transformer.py \
  --corpus data/semeval2024/semeval_zh.json \
  --corpus-id semeval-2024-task8-zh \
  --json-out validation/external_zh_semeval_transformer.json
```

在**先前**出貨的 0.99 門檻下：真人誤報 0/6000（Wilson 95% 上界 0.045%），但召回只有
**9.0%**。catalog note 曾宣稱的 48.7% 是語料內數字，不會轉移。

### 正當的門檻校準

要改門檻就不能拿報告語料來挑——那正是合約 `prohibited_shortcuts` 列的
「拿校準集的數字當測試集數字」。腳本因此支援分離的校準集，並在兩者相同時直接拒絕執行：

```bash
.venv/bin/python evaluate_external_zh_transformer.py \
  --calibration-corpus data/nlpcc2025/dev.json \
  --corpus data/semeval2024/semeval_zh.json \
  --corpus-id semeval-2024-task8-zh \
  --json-out validation/external_zh_semeval_transformer_calibrated.json
```

門檻在 NLPCC-2025 **dev**（shared task 指定保留給校準的分割）上選出：取誤報 Wilson 95%
上界 ≤ 1% 的候選中最低者（門檻愈低召回愈高）。結果為 **0.97**，隨後在 SemEval 中文上
只報告一次。

| 門檻 | 來源 | 外部召回 | 誤報上界 |
|---|---|---|---|
| 0.99 | 先前出貨 | 9.0% | 0.05% |
| **0.97** | **NLPCC dev 校準（現行）** | **27.4%** | **0.22%** |
| 0.90 | 直接掃報告語料（**無效**） | 50.0% | 0.65% |

第三列是反面教材，保留在此作為警示：同一顆模型、同一份報告語料，用「掃報告集挑最佳點」
讀出來的召回率虛高將近兩倍。正當校準選出 0.97 而非 0.90，因為 NLPCC dev 的真人分數
分布比 SemEval 緊得多，校準集預測不了報告集的操作點。

**現行門檻 0.97 仍未通過發布門檻**（召回 27.4% < 合約要求的 50%）。它的意義是在誤報
預算內盡量少漏——只用掉 1% 預算中的 0.22%——不是宣稱中文已可靠。真正的瓶頸仍是訓練
語料的生成器涵蓋。

## 中文 Transformer 自行微調（truthlens-zh-detector）

上游的 `aigc-detector-zhv3` 在助理回覆語域只有 31.4% 召回，且在 DetectRL-X 上誤報
1.09%、超出合約的 1% 預算。改以本專案的三語料自行微調。

```bash
# 1. 微調（MPS 約 45 分鐘，40,000 樣本）
.venv/bin/python train_zh_detector.py --max-train 40000

# 2. 匯出 INT8 ONNX（符合 App 推論契約：input_ids + attention_mask、兩個 logit）
.venv/bin/python export_hf_sequence_classifier.py \
  artifacts/zh_detector artifacts/zh_detector_onnx/truthlens_zh_detector_int8.onnx

# 3. 校準門檻並在三份未參與訓練的語料各報告一次
.venv/bin/python evaluate_external_zh_transformer.py \
  --model artifacts/zh_detector_onnx/truthlens_zh_detector_int8.onnx \
  --tokenizer artifacts/zh_detector_onnx/tokenizer.json \
  --calibration-corpus data/zh_combined3/dev.json \
  --corpus data/detectrl_x/zh/test_with_label.json --corpus-id detectrl-x-zh-test
```

基礎模型為 `hfl/chinese-roberta-wwm-ext`（Apache-2.0）。**注意它雖名為 RoBERTa，
分詞器仍是 BERT WordPiece**（`model.type=WordPiece`、`BertPreTokenizer`、21128 字表），
因此 catalog 的 `tokenizer` 必須標 `bert-wordpiece`；標成 `roberta-bpe` 會分詞錯誤。

### 實測（門檻 0.98，由合併開發集選出）

| 語料 | aigc-detector-zhv3 | truthlens-zh-detector |
|---|---|---|
| DetectRL-X 文件語域 | 誤報 1.09% ❌／召回 76.7% | **0.13% ✅／73.1%** |
| HC3 助理語域 | 0.34% ✅／**31.4%** | 0.17% ✅／**89.8%** |
| SemEval 中文 | ／9.0% | 0.15% ✅／**54.4%** |

分生成器召回：Gemini-2.5-Flash 71.1%、GPT-4o 77.5%、Qwen-Max 88.9%、DeepSeek-V3 54.9%。

主要進步在助理回覆語域（31.4% → 89.8%）。DetectRL-X 召回略降是誤報從 1.09% 收到
0.13% 的代價。

**這仍不等於通過發布門檻**：合約同時要求英文涵蓋（尚未量測），且三份報告語料與訓練
語料同源（雖然切分無重疊）。

## 擴充到其他語言（現況：資料擋住了，不是流程擋住了）

`export_detectrl_zh_char_svm.py` 本身與語言無關，加上 `--no-script-augment`
（繁簡增強只對中文有意義）就能直接套用到其他語料。
`prepare_m4gt_language.py` 負責把 M4GT／SemEval 的某個語言抽成同樣的格式。

```bash
.venv/bin/python prepare_m4gt_language.py --language indonesian --code id
.venv/bin/python export_detectrl_zh_char_svm.py \
  --train data/m4gt/id/train.json --dev data/m4gt/id/dev.json \
  --test data/m4gt/id/test_with_label.json \
  --language id --no-script-augment --output /tmp/svm_id.json
```

### 語料完整性：三個語言不能用

`prepare_m4gt_language.py` 會交叉檢查 `label` 與 `model` 欄位並在矛盾時拒絕執行。
`SubtaskA_multilingual.jsonl` 確實有這個問題：

| 語言 | 樣本數 | 標籤與生成器矛盾 |
|---|---|---|
| 德文 | 7,000 | **3,000**（標為人類但 model=chatGPT） |
| 義大利文 | 6,075 | **3,037** |
| 阿拉伯文 | 3,103 | **1,001** |
| 保加利亞文／中文／印尼文／俄文／烏爾都文 | — | 0 |

拿德文那份訓練，等於直接教模型「ChatGPT 德文是人類寫的」，而且驗證集同樣髒，
AUC 還會很好看。所以是拒絕，不是猜哪個欄位才對。

### 實測結果與它真正的意義

| 語言 | 訓練樣本 | 語料內 AUC | 語料內 FPR | 語料內召回 |
|---|---|---|---|---|
| 印尼文 | 4,191 | 0.9983 | 0.99% | 99.7% |
| 俄文 | 1,400 | 0.9894 | 5.34% | 93.8% |

**不要把這兩行當成可用的成績。** 這裡的 `independent_test` 只是同一份語料的隨機切分，
生成器同樣是 chatGPT、領域同樣單一——與中文當初「語料內 AUC 0.94」是同一種數字。
而中文後來在真正的外部語料上是：SVM 召回 62.6% → 33.1%，Transformer 48.7% → 9.0%。

所以正確的讀法是「流程對其他語言可以跑通」，不是「印尼文可以偵測了」。要真的宣稱，
需要第二份不同生成器的印尼文語料，而認可來源裡沒有。俄文另外還有兩個問題：
1,400 筆訓練樣本太少，且語料內 FPR 已經 5.34%，遠超 1% 目標。

**結論：目前不上架任何新語言模型。** 缺的是資料，不是流程。

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
