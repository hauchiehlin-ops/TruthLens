# Binoculars 離線驗證（六項升級第 6 項・階段一）

## 這一階段要回答的唯一問題

**在你自己的語料上，Binoculars 是否真的優於現有引擎 B 所用的裸 perplexity？**

若全尺寸模型都贏不了，縮到瀏覽器可跑的尺寸只會更差——直接停止，把資源投回
本地基準校準（支柱 2）。這個決策點就是階段一存在的理由。

## 三步驟

```bash
cd training

# 1. 準備語料（支援 .pdf / .txt / .md / .docx）
.venv/bin/python binoculars/prepare_corpus.py \
    --human-dir "/path/to/student_essays" \
    --ai-dir    "/path/to/ai_generated" \
    --out       binoculars/data/corpus.jsonl

# 2. 計分（階段一用全尺寸模型；需要下載約 15GB，或改用 --device cpu 較慢）
.venv/bin/python binoculars/run_binoculars.py \
    --observer  tiiuae/falcon-7b \
    --performer tiiuae/falcon-7b-instruct

# 3. 評測與報表
.venv/bin/python binoculars/evaluate.py
```

先跑通流程可用已快取的小模型煙霧測試（**不是**有效的科學配對，只是驗證管線）：

```bash
.venv/bin/python binoculars/run_binoculars.py \
    --observer gpt2 --performer distilgpt2 \
    --device cpu --dtype float32 --limit 4
```

## 由 App 實戰累積語料（推薦，邊跑邊蒐集）

不必另外辦一次資料蒐集。教師日常使用時：

1. 設定 → 開啟「**保留原文以供離線驗證**」（預設關閉）
2. 分析確定由學生本人撰寫的作業 → 報告頁按「加入為人類撰寫基準」
3. 分析貼上的 AI 產出 → 按「加入為 AI 產出樣本」
4. 累積夠了 → 設定 → 「**匯出校準語料**」→ 得到 `truthlens_corpus.jsonl`

匯出格式與 `prepare_corpus.py` 的輸出**完全一致**，因此可跳過語料準備步驟，
直接進計分：

```bash
.venv/bin/python binoculars/run_binoculars.py --corpus /path/to/truthlens_corpus.jsonl
.venv/bin/python binoculars/evaluate.py --scores binoculars/data/scores.jsonl
```

這條路徑的好處是**語料就是真實使用場景本身**——非母語學生原稿、真實題型、
真實長度，不需要找代理樣本。設定頁會即時顯示「人類 N 份、AI M 份」，
達到每類 30 份就能跑評測。

匯出後可立即用「清除已保存的原文」移除敏感內容；清除**不影響**共形預測，
因為它只需要分數。

## 生成 AI 對照組

human 那組必須自己蒐集，但 AI 那組可以自動化：

```bash
export ANTHROPIC_API_KEY=sk-ant-...

# 先看會送出什麼、不花錢
.venv/bin/python binoculars/generate_ai_corpus.py \
    --from-human binoculars/data/corpus.jsonl --dry-run

# 實際生成
.venv/bin/python binoculars/generate_ai_corpus.py \
    --from-human binoculars/data/corpus.jsonl \
    --provider anthropic --model claude-sonnet-5 \
    --out-dir binoculars/data/ai_generated
```

支援 `anthropic` / `openai` / `gemini` / `groq` / `together`。**建議至少跑兩個不同
供應商並把輸出混在同一資料夾**——真實情境裡學生用的是各種工具，只用單一生成器
會讓評測結果無法外推。可續跑：已存在的檔案會自動略過。

### 三個會讓結果假性樂觀的陷阱（腳本已內建對策）

| 陷阱 | 後果 | 對策 |
|---|---|---|
| 題材不對齊 | 模型只要認出主題就能分開兩組 | `--from-human` 由 human 語料反推題目 |
| **流暢度混淆** | human 是非母語原稿、AI 一律母語級散文，測到的是「流暢度」不是「AI 生成」；上線後會把英文好的學生全誤判 | 預設同時生成 `nonnative` 語域 |
| 生成器單一 | 只認得出某一家的文風 | 換 `--provider` 多跑幾輪 |

### 隱私

`--from-human` 會把每份 human 樣本的**開頭約 45 字**送到第三方 API 以反推題目。
腳本會自動濾除標題、作者列與 PDF 連字，並在執行前要求確認。若不接受，改用
`--topics-file` 自備題目清單即可**完全不外送學生文字**。

`binoculars/data/` 已列入 .gitignore，語料不會進版控。

## 語料要求（這是目前的瓶頸）

| 類別 | 需要 | 為什麼 |
|---|---|---|
| human | **≥30 份獨立文件**，非母語英文的**學生作業原稿** | 已出版論文經過審稿與編輯，正好把要檢驗的非母語特徵磨掉了，不是合適的代理樣本 |
| ai | **≥30 份獨立文件**，同題目、同長度 | 題材不對齊的話，模型學到的是「主題」而不是「來源」 |

**獨立文件數才算數**。把同一份文件切成很多塊不會增加獨立資訊量，卻會讓 AUC
看起來漂亮得多——同一位作者、同一個主題的切塊彼此高度相關，模型只要認出
「這是誰寫的」就能拿高分。`evaluate.py` 會在文件數不足時**直接拒絕出具結論**，
這與 App 本身的棄權設計是同一個精神。

另外，要讓 5% 偽陽性率這個操作點存在，human 至少需要 20 份。

## 兩個模型必須共用 tokenizer

交叉困惑度是在比較兩個模型對**同一個詞彙表**的機率分布。詞彙表對不齊的話，
數字算得出來但沒有意義，因此 `run_binoculars.py` 會在載入時檢查並直接中止。
請選同系列的 base / instruct 配對。

## 分數方向

**Binoculars 分數越低越像機器產出**（與直覺相反）。

```
B = log-perplexity(觀察者對實際詞元的困惑度) ÷ cross-perplexity(兩模型分歧程度)
```

分子單獨使用就是裸 perplexity，也就是現有引擎 B 的作法。分母提供「這段文字
本來就有多難預測」的基準，正是它讓 Binoculars 對用詞平實的非母語寫作比較
不會誤判。

## 後續階段

- **階段二**：換小模型配對量衰減曲線（Qwen2.5-0.5B → SmolLM2-360M → SmolLM2-135M），
  找出「效果仍可接受的最小配對」。下載預算已確認可接受 700MB–1GB 的選擇性下載。
- **階段三**：以驗證集重新校準門檻，並**分語言各求一組**（中文與英文分布不同）。
  `BinocularsScorer.placeholderThreshold` 目前只是佔位值。
- **階段四**：匯出 ONNX INT8 → `verify_onnx.py` 驗證數值一致 → 在 Web 量測
  500 字的實際耗時與記憶體峰值。若超過 5 秒目標，就只掛在瀑布第 3 層。
