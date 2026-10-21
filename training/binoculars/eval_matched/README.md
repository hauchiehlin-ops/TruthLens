# 同題材、同語域的 Binoculars 對照語料（2026-10-21）

用途：比較 Binoculars 與裸困惑度在**題材與語域對齊**時的判別力。結果見
[../../validation/binoculars_matched_registers.json](../../validation/binoculars_matched_registers.json)。

| 檔案 | 內容 | 來源與授權 |
|---|---|---|
| `csl_human_zh.jsonl` | 30 篇中文期刊摘要（隨機種子 20261021，180–400 字），OpenCC `s2twp` 轉繁 | CSL 中文科學文獻資料集（Li et al., COLING 2022；Hugging Face `neuclir/csl`，Apache-2.0）。收錄 2022 年前發表的期刊論文，必為真人撰寫 |
| `ai_zh_claude.jsonl` | 依上列 30 個標題撰寫的摘要 | Claude Opus 5.5（2026-10-21 於本專案對話中產生） |
| `human_en_titles.jsonl` | 17 篇 2022 年前英文期刊論文的標題與年份 | 原文為出版社著作，**不收錄摘要本文**；評估時由使用者本機的論文 PDF 抽取 |
| `ai_en_claude.jsonl` | 依上列 17 個標題撰寫的摘要 | Claude Opus 5.5。部分為知名論文，生成內容可能接近原摘要的改寫，對應「請 AI 改寫既有文字」的情境 |

限制：每組 17–30 份，AUROC 的信賴區間約 ±0.1；AI 樣本只來自單一模型。
