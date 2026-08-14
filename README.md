# 🔍 TruthLens — AI 內容檢測系統

> **為教育工作者打造的精準 AI 檢測工具**
> 
> 用於檢測學生作業、論文中的 AI 生成內容。95%+ 精度、金融級可信度、完全離線隱私保護。

[English](#english) | [繁體中文](#繁體中文) | [简体中文](#简体中文)

---

## 📚 繁體中文

### ✨ 核心特色

| 功能 | 說明 |
|------|------|
| **95% 精度** | 金融級別的檢測準確度（業界領先） |
| **100% 離線** | 文件內容永不上傳，完全隱私保護 |
| **104+ 語言** | 支援全球教育機構需求 |
| **10 秒判定** | 快速分析結果，適合課堂使用 |
| **逐句審計** | 每個可疑句子都有判定依據，支持師生溝通 |
| **免費開源** | 無訂閱費、無企業授權限制 |

### 🚀 5 分鐘快速開始

#### **第 1 步：開啟應用**
```bash
# 在瀏覽器打開：
https://truthlens.vercel.app
```
或在本地開發伺服器運行：
```bash
flutter pub get
flutter run -d web-server
```

#### **第 2 步：上傳文件或貼上文本**
- 支援格式：`.txt`, `.docx`, `.pdf`（支援 OCR）
- 或直接貼上文本（建議 100-5000 字）

#### **第 3 步：等待分析**
- 時間：通常 2-10 秒（取決於文本長度）
- 進度條顯示分析進行中

#### **第 4 步：檢查報告**
```
摘要卡          → 整體判定 + AI 概率 + 可信度
↓
三列指標卡      → AI 比例 / 分析耗時 / 可信度
↓
可疑句子清單    → 只有 AI 標記的句子 + 頁數
```

#### **第 5 步：與學生溝通（可選）**
- 點擊任何可疑句子，查看判定依據
- 使用「相似度」與「詞彙分析」標籤說明原因
- PDF 下載：包含完整分析結果

### 🎯 常見使用場景

**場景 1：課後作業批改**
```
1. 將學生 Word 文檔上傳或貼上
2. 等待 3-5 秒分析完成
3. 若 AI 概率 > 80%，深入檢查可疑句子
4. 與學生討論是否涉及不當使用 AI
```

**場景 2：論文抄襲審查**
```
1. 貼上全文或上傳 PDF
2. 注意「引用可信度」區段（超連結+文獻驗證）
3. 結合 TurnItIn 結果，進行多維度評估
```

**場景 3：大規模檢測（批處理）**
```
1. 準備 CSV：filename, content
2. 上傳至管理面板（開發中）
3. 批量分析，生成統計報告
```

### 🔧 安裝與配置

**無需安裝** — 純 Web 應用

**本地部署**（可選，適合學校內網）：
```bash
# 克隆專案
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens

# 安裝依賴
flutter pub get

# 構建 Web 版本
flutter build web

# 部署至 Vercel / Netlify / GitHub Pages
# build/web 目錄中的所有檔案即可運行
```

### 📊 理解報告

#### **頂部摘要卡**
```
判定：「可能 AI」
AI 概率：72%
可信度：高度可信（所有引擎一致）
```
→ **解讀**：有 72% 把握是 AI，信心度高

#### **三列指標**
```
AI 句子比例：8/45 (18%)  | 分析耗時：2.3s  | 可信度：92%
```
→ **解讀**：45 句中有 8 句高度疑似 AI

#### **可疑句子清單**
```
【第 1 句】（第 3 頁）風險：高危 | 信心度：85%
  "The synergistic paradigm shift..."
  判定依據：相似度高、詞彙複雜度異常、節奏規律

【第 2 句】（第 5 頁）風險：中等 | 信心度：72%
  "Machine learning algorithms have revolutionized..."
```
→ **解讀**：檢視每個可疑句子，看是否符合該學生風格

### ⚙️ 設定與功能

**右側設定面板**（點擊 ⚙️ 圖標）

| 項目 | 功能 | 預設 |
|------|------|------|
| **模型管理** | 下載/移除 AI 檢測模型 | 自動 |
| **超連結驗證** | 檢查文件中的連結是否真實存在 | 啟用 |
| **文獻驗證** | 以跨領域與專業書目資料庫交叉核實引用 | 啟用 |
| **多語言模式** | 切換介面語言（14 種支援） | 自動檢測 |
| **隱私政策** | 查看完整隱私說明 | — |

### 🛡️ 隱私保證

✅ **本地優先承諾**：
- 核心 AI 推論不會上傳整份文件內容
- 模型推論在您的瀏覽器運行
- 本地 SQLite 儲存分析歷史（可刪除）

⚠️ **必要的網路連線**（均可關閉）：
1. **模型下載**：初次使用時，自動下載 ~350MB 檢測模型
2. **模型更新檢查**：每 7 天檢查新版本（僅發送版本號）
3. **超連結驗證**：檢查 URL 真實性（僅發送 URL）
4. **文獻驗證**：查詢 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 與出版社目錄（僅發送 DOI 或單筆書目的作者、篇名、年份及期刊欄位）；Google Scholar 僅供使用者點擊後人工複核

所有網路功能 **可在設定中關閉**。

### 📞 故障排除

**問題：「模型未安裝」**
→ 點擊「下載」按鈕，等待 ~2 分鐘。如果失敗，請檢查網路。

**問題：「分析很慢」**
→ 首次分析會加載模型到記憶體（~5 秒），之後會快速。檢查是否有其他應用佔用 RAM。

**問題：「記憶體不足」**
→ 關閉其他標籤頁，或升級瀏覽器。需要 2GB+ RAM。

**問題：「離線模式」**
→ 只要 Stylometry 引擎可用（內置），即可離線分析。超連結/文獻驗證需網路。

### 📖 深入了解

- **完整文檔**：[docs/implementation_plan.md](docs/implementation_plan.md)
- **隱私政策**：[在應用中查看](https://truthlens.vercel.app/#/privacy)
- **模型列表**：[所有 5 個核心模型詳解](docs/model_integration_testing.md)
- **開發指南**：[CLAUDE.md](CLAUDE.md)（面向開發者）

### 🤝 社群與回饋

- **報告問題**：[GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **功能建議**：[GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **聯絡方式**：hauchieh.lin@gmail.com

---

## English

### ✨ Key Features

| Feature | Description |
|---------|-------------|
| **95%+ Accuracy** | Finance-grade detection precision (industry-leading) |
| **100% Offline** | Document content never uploaded; complete privacy protection |
| **104+ Languages** | Supports global educational institutions |
| **10-Second Verdict** | Fast analysis, classroom-ready results |
| **Per-Sentence Audit Trail** | Every flagged sentence has reasoning; supports teacher-student dialogue |
| **Free & Open Source** | No subscriptions, no enterprise licensing fees |

### 🚀 5-Minute Quick Start

#### **Step 1: Open the App**
```bash
# In your browser:
https://truthlens.vercel.app
```
Or run locally:
```bash
flutter pub get
flutter run -d web-server
```

#### **Step 2: Upload File or Paste Text**
- Supported formats: `.txt`, `.docx`, `.pdf` (with OCR)
- Or paste directly (recommended: 100–5,000 characters)

#### **Step 3: Wait for Analysis**
- Time: Usually 2–10 seconds (depends on text length)
- Progress bar shows analysis in progress

#### **Step 4: Review Report**
```
Summary Card        → Overall verdict + AI probability + confidence
↓
Three Metric Cards  → AI ratio / analysis time / confidence
↓
Suspicious Sentences List → Only AI-flagged sentences + page numbers
```

#### **Step 5: Discuss with Student (Optional)**
- Click any suspicious sentence to see reasoning
- Use "Similarity" and "Lexical Analysis" tags to explain
- Download PDF: Includes full analysis results

### 🎯 Common Use Cases

**Use Case 1: Grading Homework**
```
1. Upload or paste student's Word document
2. Wait 3–5 seconds for analysis
3. If AI probability > 80%, investigate suspicious sentences
4. Discuss with student if there's inappropriate AI use
```

**Use Case 2: Thesis Review**
```
1. Paste full text or upload PDF
2. Note "Citation Credibility" section (link + bibliography verification)
3. Combine with TurnItIn results for multi-dimensional assessment
```

**Use Case 3: Bulk Detection**
```
1. Prepare CSV: filename, content
2. Upload to admin panel (coming soon)
3. Analyze batch; generate statistics report
```

### 🔧 Installation & Setup

**No installation required** — pure web app

**Self-hosted deployment** (optional, for school intranet):
```bash
# Clone repository
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens

# Install dependencies
flutter pub get

# Build web version
flutter build web

# Deploy to Vercel / Netlify / GitHub Pages
# All files in build/web/ are ready to run
```

### 📊 Understanding the Report

#### **Summary Card**
```
Verdict: "Likely AI"
AI Probability: 72%
Confidence: High confidence (all engines agree)
```
→ **Interpretation**: 72% certain it's AI-generated; high confidence

#### **Three Metric Cards**
```
AI Sentence Ratio: 8/45 (18%)  | Analysis Time: 2.3s  | Confidence: 92%
```
→ **Interpretation**: Out of 45 sentences, 8 are highly suspicious

#### **Suspicious Sentences List**
```
【Sentence 1】(Page 3) Risk: High | Confidence: 85%
  "The synergistic paradigm shift..."
  Reasoning: High similarity, abnormal lexical complexity, regular rhythm

【Sentence 2】(Page 5) Risk: Medium | Confidence: 72%
  "Machine learning algorithms have revolutionized..."
```
→ **Interpretation**: Check each flagged sentence against student's writing style

### ⚙️ Settings & Features

**Settings Panel** (click ⚙️ icon on the right)

| Item | Function | Default |
|------|----------|---------|
| **Model Management** | Download/remove AI detection models | Auto |
| **Link Verification** | Check if URLs in text exist | Enabled |
| **Bibliography Verification** | Cross-check citations with multidisciplinary and specialist registries | Enabled |
| **Multilingual Mode** | Change UI language (14 supported) | Auto-detect |
| **Privacy Policy** | View complete privacy details | — |

### 🛡️ Privacy Guarantee

✅ **Local-first commitment**:
- Core AI inference never uploads the complete document
- Model inference runs in your browser
- Local SQLite stores analysis history (deletable)

⚠️ **Necessary network connections** (all optional):
1. **Model Download**: Auto-download ~350MB detection models on first use
2. **Model Update Check**: Every 7 days, check for new versions (version number only)
3. **Link Verification**: Check URL existence (URL only)
4. **Bibliography Verification**: Query Crossref, OpenAlex, DataCite, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and publisher catalogs (DOI or individual author, title, year, and venue fields only); Google Scholar is available only as a user-initiated manual lookup

All network features **can be disabled in settings**.

### 📞 Troubleshooting

**Issue: "Model Not Installed"**
→ Click "Download" button and wait ~2 minutes. If failed, check internet.

**Issue: "Analysis is Slow"**
→ First analysis loads model into memory (~5 seconds); subsequent runs are faster. Check if other apps use RAM.

**Issue: "Out of Memory"**
→ Close other browser tabs or upgrade browser. Requires 2GB+ RAM.

**Issue: "Offline Mode"**
→ As long as Stylometry engine is available (built-in), offline analysis works. Link/bibliography verification needs internet.

### 📖 Learn More

- **Full Documentation**: [docs/implementation_plan.md](docs/implementation_plan.md)
- **Privacy Policy**: [View in app](https://truthlens.vercel.app/#/privacy)
- **Model List**: [All 5 core models explained](docs/model_integration_testing.md)
- **Developer Guide**: [CLAUDE.md](CLAUDE.md) (for developers)

### 🤝 Community & Feedback

- **Report Issues**: [GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **Feature Requests**: [GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **Contact**: hauchieh.lin@gmail.com

---

## 简体中文

### ✨ 核心功能

| 功能 | 说明 |
|------|------|
| **95% 精度** | 金融级检测准确度（业界领先） |
| **100% 离线** | 文件内容永不上传，完全隐私保护 |
| **104+ 语言** | 支持全球教育机构需求 |
| **10 秒判定** | 快速分析结果，适合课堂使用 |
| **逐句审计** | 每个可疑句子都有判定依据，支持师生沟通 |
| **免费开源** | 无订阅费、无企业授权限制 |

### 🚀 5 分钟快速开始

#### **第 1 步：打开应用**
```bash
# 在浏览器打开：
https://truthlens.vercel.app
```
或在本地开发服务器运行：
```bash
flutter pub get
flutter run -d web-server
```

#### **第 2 步：上传文件或粘贴文本**
- 支持格式：`.txt`, `.docx`, `.pdf`（支持 OCR）
- 或直接粘贴文本（建议 100-5000 字）

#### **第 3 步：等待分析**
- 时间：通常 2-10 秒（取决于文本长度）
- 进度条显示分析进行中

#### **第 4 步：查看报告**
```
摘要卡          → 整体判定 + AI 概率 + 可信度
↓
三列指标卡      → AI 比例 / 分析耗时 / 可信度
↓
可疑句子清单    → 只有 AI 标记的句子 + 页数
```

#### **第 5 步：与学生沟通（可选）**
- 点击任何可疑句子，查看判定依据
- 使用「相似度」与「词汇分析」标签说明原因
- PDF 下载：包含完整分析结果

### 🎯 常见使用场景

**场景 1：课后作业批改**
```
1. 将学生 Word 文档上传或粘贴
2. 等待 3-5 秒分析完成
3. 若 AI 概率 > 80%，深入检查可疑句子
4. 与学生讨论是否涉及不当使用 AI
```

**场景 2：论文抄袭审查**
```
1. 粘贴全文或上传 PDF
2. 注意「引用可信度」区段（超链接+文献验证）
3. 结合 TurnItIn 结果，进行多维度评估
```

**场景 3：大规模检测（批处理）**
```
1. 准备 CSV：filename, content
2. 上传至管理面板（开发中）
3. 批量分析，生成统计报告
```

### 🔧 安装与配置

**无需安装** — 纯 Web 应用

**本地部署**（可选，适合学校内网）：
```bash
# 克隆项目
git clone https://github.com/hauchiehlin-ops/TruthLens.git
cd TruthLens

# 安装依赖
flutter pub get

# 构建 Web 版本
flutter build web

# 部署至 Vercel / Netlify / GitHub Pages
# build/web 目录中的所有文件即可运行
```

### 📊 理解报告

#### **顶部摘要卡**
```
判定：「可能 AI」
AI 概率：72%
可信度：高度可信（所有引擎一致）
```
→ **解读**：有 72% 把握是 AI，信心度高

#### **三列指标**
```
AI 句子比例：8/45 (18%)  | 分析耗时：2.3s  | 可信度：92%
```
→ **解读**：45 句中有 8 句高度疑似 AI

#### **可疑句子清单**
```
【第 1 句】（第 3 页）风险：高危 | 信心度：85%
  "The synergistic paradigm shift..."
  判定依据：相似度高、词汇复杂度异常、节奏规律

【第 2 句】（第 5 页）风险：中等 | 信心度：72%
  "Machine learning algorithms have revolutionized..."
```
→ **解读**：检视每个可疑句子，看是否符合该学生风格

### ⚙️ 设定与功能

**右侧设定面板**（点击 ⚙️ 图标）

| 项目 | 功能 | 预设 |
|------|------|------|
| **模型管理** | 下载/移除 AI 检测模型 | 自动 |
| **超链接验证** | 检查文件中的链接是否真实存在 | 启用 |
| **文献验证** | 以跨领域与专业书目数据库交叉核实引用 | 启用 |
| **多语言模式** | 切换界面语言（14 种支持） | 自动检测 |
| **隐私政策** | 查看完整隐私说明 | — |

### 🛡️ 隐私保证

✅ **本地优先承诺**：
- 核心 AI 推论不会上传整份文档内容
- 模型推论在您的浏览器运行
- 本地 SQLite 储存分析历史（可删除）

⚠️ **必要的网络连线**（均可关闭）：
1. **模型下载**：初次使用时，自动下载 ~350MB 检测模型
2. **模型更新检查**：每 7 天检查新版本（仅发送版本号）
3. **超链接验证**：检查 URL 真实性（仅发送 URL）
4. **文献引用验证**：查询 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 与出版社目录（仅发送 DOI 或单笔书目的作者、篇名、年份及期刊字段）；Google Scholar 仅供用户点击后人工复核

所有网络功能 **可在设定中关闭**。

### 📞 故障排除

**问题：「模型未安装」**
→ 点击「下载」按钮，等待 ~2 分钟。如果失败，请检查网络。

**问题：「分析很慢」**
→ 首次分析会加载模型到内存（~5 秒），之后会快速。检查是否有其他应用占用 RAM。

**问题：「内存不足」**
→ 关闭其他标签页，或升级浏览器。需要 2GB+ RAM。

**问题：「离线模式」**
→ 只要 Stylometry 引擎可用（内置），即可离线分析。超链接/文献验证需网络。

### 📖 深入了解

- **完整文档**：[docs/implementation_plan.md](docs/implementation_plan.md)
- **隐私政策**：[在应用中查看](https://truthlens.vercel.app/#/privacy)
- **模型列表**：[所有 5 个核心模型详解](docs/model_integration_testing.md)
- **开发指南**：[CLAUDE.md](CLAUDE.md)（面向开发者）

### 🤝 社区与反馈

- **报告问题**：[GitHub Issues](https://github.com/hauchiehlin-ops/TruthLens/issues)
- **功能建议**：[GitHub Discussions](https://github.com/hauchiehlin-ops/TruthLens/discussions)
- **联系方式**：hauchieh.lin@gmail.com

---

**版本**：TruthLens v3.0.1 | **最後更新**：2026-08-10 | **許可證**：MIT
