# TruthLens 多語言翻譯計劃

**狀態**：Phase 1 完成 | Phase 2 進行中  
**基礎文檔**：14 語言介面 + 5 份教育指南  
**更新日期**：2026-08-10

---

## 翻譯優先級

### 🔴 第一優先級（立即翻譯）
| 語言 | 代碼 | 文件 | 狀態 | 預計完成 |
|------|------|------|------|--------|
| 簡體中文 | zh_Hans | quick-start, FAQ, troubleshooting | 🔄 進行中 | 2026-08-11 |
| 日本語 | ja | quick-start, FAQ | 🔄 進行中 | 2026-08-11 |
| 한국어 | ko | quick-start, FAQ | 🔄 進行中 | 2026-08-12 |

### 🟡 第二優先級（1 週內）
| 語言 | 代碼 | 原生使用者估計 | 預計完成 |
|------|------|-------------|--------|
| Deutsch | de | ~800M | 2026-08-13 |
| Español | es | ~500M | 2026-08-13 |
| Français | fr | ~280M | 2026-08-13 |
| 中文（通用） | zh | 亞洲全球 | 2026-08-12 |

### 🟢 第三優先級（2 週內）
| 語言 | 代碼 | 原生使用者估計 | 預計完成 |
|------|------|-------------|--------|
| Português | pt | ~250M | 2026-08-17 |
| Русский | ru | ~258M | 2026-08-17 |
| Bahasa Indonesia | id | ~200M | 2026-08-18 |
| Bahasa Melayu | ms | ~76M | 2026-08-18 |
| ไทย | th | ~70M | 2026-08-19 |

---

## 待翻譯文件（5 份）

### 1. quick-start-XX.md
```
位置：docs/quick-start-{lang}.md
字數：~2,500 字（英文）
內容：7 步驟 + 5 個常見場景 + 設定指南
難度：中（需技術術語本地化）
優先級：🔴 高
```

**翻譯檢查清單**：
- [ ] 技術術語已標準化（e.g., "model" → 本地術語）
- [ ] 步驟序號一致性檢查
- [ ] 代碼區塊保持英文（不翻譯）
- [ ] 表格格式對齊
- [ ] 連結檢查

### 2. faq-XX.md
```
位置：docs/faq-{lang}.md
字數：~3,000 字（英文）
內容：45+ 問答（11 大類別）
難度：高（需保留專業措辭）
優先級：🔴 高
```

**翻譯檢查清單**：
- [ ] Q&A 配對無遺漏
- [ ] 代碼範例/命令保持英文
- [ ] 技術術語一致
- [ ] 音調適當（教育性但親切）

### 3. troubleshooting-XX.md
```
位置：docs/troubleshooting-{lang}.md
字數：~3,500 字（英文）
內容：35+ 解決方案（7 大分類）
難度：最高（技術細節 + 同情心平衡）
優先級：🟡 中
```

**翻譯檢查清單**：
- [ ] 錯誤訊息與原文對齐
- [ ] 命令/代碼區塊保持英文
- [ ] 表格格式無損壞
- [ ] 連結有效

### 4. README.md（非英文部分）
```
位置：README.md（三語已包含）
字數：已有繁體/簡體/英文版本
內容：5 分鐘快速開始 + 特色 + 隱私
難度：中
優先級：✅ 已完成（快速開始已有）
```

### 5. docs/model_integration_testing.md（技術文檔）
```
位置：docs/model_integration_testing.md
字數：~5,000 字
內容：5 個 AI 模型詳細說明
難度：最高（技術專有名詞）
優先級：🟢 低（針對開發者，多數英文讀者）
```

---

## 語言特定的翻譯指南

### 中文（簡體 zh_Hans）
**字幕代碼格式**：使用 Simplified Chinese Pinyin
```
- 技術術語保留英文（e.g., ONNX Runtime, Transformer）
- 術語表：
  • Model = 模型
  • Engine = 引擎
  • Perplexity = 困惑度
  • Burstiness = 突發性
  • Tokenizer = 分詞器
  • Paraphrase = 改寫
  • Adversarial = 對抗式/對抗
```

**標準格式**：
- 標題：「# TruthLens —快速開始指南（簡體中文）」
- 表格：保留 Markdown 格式
- 代碼區塊：保持英文

### 日本語 (ja)
**字幕代碼格式**：Use Japanese characters
```
- 技術術語用カタカナ（e.g., オントロジー, トークナイザー）
- 術語表：
  • Model = モデル
  • Detection = 検出
  • Engine = エンジン
  • Confidence = 信頼度
```

**標準格式**：
- 標題：「# TruthLens — クイックスタートガイド（日本語）」

### 한국어 (ko)
**字幕代碼格式**：Use Korean Hangul
```
- 技術術語用 한글 음차 (e.g., 모델, 엔진)
- 術語表：
  • Model = 모델
  • Detection = 탐지/검출
  • Engine = 엔진
```

**標準格式**：
- 標題：「# TruthLens — 빠른 시작 가이드（한국어）」

---

## 翻譯工作流

### 步驟 1：準備
```bash
# 克隆英文版本
cp docs/quick-start-en.md docs/quick-start-{lang}.md
cp docs/faq-en.md docs/faq-{lang}.md
cp docs/troubleshooting-en.md docs/troubleshooting-{lang}.md
```

### 步驟 2：翻譯
```
1. 使用翻譯工具（Google Translate / DeepL）作為起點
2. 手動審閱每個句子（保留專業術語）
3. 檢查技術準確性
4. 在原生使用者身上測試（如可能）
```

### 步驟 3：質量檢查
```
檢查清單：
☑ 拼寫/語法無誤
☑ 術語一致（使用上方術語表）
☑ 代碼區塊未修改
☑ 連結有效
☑ 表格格式完整
☑ 文化差異調整（如適用）
```

### 步驟 4：提交
```bash
git add docs/quick-start-{lang}.md docs/faq-{lang}.md ...
git commit -m "📚 翻譯：{語言} 版本快速開始 + FAQ + 故障排除

✅ 已翻譯：
  • quick-start-{lang}.md
  • faq-{lang}.md
  • troubleshooting-{lang}.md

🔍 已通過質量檢查：
  • 術語一致性
  • 代碼區塊保留
  • 連結驗證
  • 文化適配

Co-Authored-By: [譯者名稱] <email>"
```

---

## 術語表（跨語言標準化）

### 核心概念
| 英文 | 繁體中文 | 簡體中文 | 日本語 | 한국어 |
|------|--------|--------|-------|-------|
| AI Detection | AI 檢測 | AI 检测 | AI検出 | AI 탐지 |
| Model | 模型 | 模型 | モデル | 모델 |
| Engine | 引擎 | 引擎 | エンジン | 엔진 |
| Confidence | 可信度/信心度 | 置信度 | 信頼度 | 신뢰도 |
| Download | 下載 | 下载 | ダウンロード | 다운로드 |
| Analyze | 分析 | 分析 | 分析 | 분석 |
| Report | 報告 | 报告 | レポート | 보고서 |

### 技術術語
| 英文 | 繁體中文 | 簡體中文 | 日本語 | 한국어 |
|------|--------|--------|-------|-------|
| Perplexity | 困惑度 | 困惑度 | パープレキシティ | 혼란도 |
| Burstiness | 突發性 | 突发性 | バースト性 | 폭발성 |
| Tokenizer | 分詞器 | 分词器 | トークナイザー | 토크나이저 |
| Ensemble | 集成 | 集成 | アンサンブル | 앙상블 |
| Paraphrase | 改寫 | 改写 | 言い換え | 의역 |
| Adversarial | 對抗式 | 对抗式 | 敵対的 | 대적적 |

---

## 社群翻譯機制

### 貢獻者指南

**想要幫助翻譯嗎？**

1. **認領語言**：在 [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues) 中留言
   ```
   "I want to help translate to [Language]. Assigning to myself."
   ```

2. **翻譯流程**：
   - Fork 專案
   - 建立分支：`translate/{lang}`
   - 翻譯文件（使用上述指南）
   - 提交 Pull Request

3. **質量保證**：
   - 1+ 原生使用者審閱
   - 2+ 技術審查者驗證
   - 完成後合併至 main

### 翻譯團隊
```
🇨🇳 簡體中文：[待認領]
🇯🇵 日本語：[待認領]
🇰🇷 한국어：[待認領]
🇩🇪 Deutsch：[待認領]
🇪🇸 Español：[待認領]
🇫🇷 Français：[待認領]
🇵🇹 Português：[待認領]
🇷🇺 Русский：[待認領]
🇮🇩 Bahasa Indonesia：[待認領]
🇲🇾 Bahasa Melayu：[待認領]
🇹🇭 ไทย：[待認領]
```

---

## 完成條件

✅ **翻譯完成標準**：
1. 所有 5 份文件已翻譯
2. 通過質量檢查
3. 至少 1 個原生使用者審閱
4. 部署至主分支
5. README.md 更新以指向新文檔

✅ **Phase 2 完成條件**：
- [ ] 3 語言完成（簡體中文、日本語、한국어）
- [ ] 8 語言進行中
- [ ] 翻譯指南已發佈

---

**進度追蹤**：[GitHub Projects - Translation](https://github.com/hauchiehlin-ops/TruthLens/projects)  
**截止日期**：2026-08-31（所有 14 語言完成）
