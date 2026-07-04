# TruthLens — 本地優先的 AI 內容檢測應用程式

跨平台（iOS / Android / macOS / Windows）Flutter 應用，核心 AI 推論一律在裝置端完成、
文件內容不上傳、不落地任何伺服器。少數輔助功能（模型更新偵測、超連結與期刊文獻目錄驗證）
會視需要連線，僅傳送必要的中介資料（版本號、網址或 DOI 本身），使用者可在設定關閉
（2026-07-05 起不再要求「完全離線、零伺服器」，因為模型更新偵測與超連結真偽判斷
本質上需要對外連線才能主動進行，詳見 DEVLOG）。
完整設計架構見 [docs/implementation_plan.md](docs/implementation_plan.md)（本檔只放摘要，細節以該文件為準）。

## 核心設計原則

1. **本地優先＋必要連線**：核心 AI 推論與使用者輸入的文件內容一律留在裝置端處理、
   不上傳；僅模型更新偵測、超連結存在性與期刊文獻目錄驗證（DOI → Crossref）等
   主動分析功能會連線，且只送出版本號／網址／DOI，不含文件內容，使用者可在設定關閉
2. **透明可解釋**：每個判定附帶逐句理由，杜絕黑箱
3. **多層級分析**：文件 → 段落 → 句子 → 詞彙
4. **抗規避**：對抗改寫工具、同義詞替換、同形字攻擊
5. **多語系優先**：架構底層即支援多語言（XLM-RoBERTa，104+ 語言）

## 系統架構速覽

- **UI 層**（Flutter/Dart）：輸入（文字/OCR/文件）→ 分析進度 → AI 動態報告 → 歷史 → 設定
- **檢測引擎**（Ensemble 四子模型加權投票）：
  - A. XLM-RoBERTa 分類器（權重 40%）— 句子級
  - B. 統計分析 Perplexity/Burstiness（25%）— 滑動窗口
  - C. 風格特徵 Stylometry + XGBoost（20%）— 可解釋性最高
  - D. 對抗式防禦/改寫偵測（15%）
  - ESL 偏差修正：偵測到非母語寫作時自動降低模型 B 權重
- **報告生成**：本地端 LLM（Gemma 2B / Phi-4-Mini，llama.cpp）決定版面 + 生成解說；低階裝置回退至模板
- **OCR**：Google ML Kit（on-device）
- **儲存**：SQLite（sqflite）+ SharedPreferences/Hive，無後端

## 專案結構（Flutter）

```
lib/
├── main.dart
├── app/          # App 設定、路由、主題
├── core/         # detection/（引擎協調器）、models/、services/、utils/
├── features/     # input/、analysis/、report/、history/、settings/
└── shared/       # 共用 Widget
assets/models/    # 隨 App 打包的小型模型
assets/templates/ # 報告版面模板
native/           # 各平台原生推論橋接（TFLite / Core ML / ONNX + llama.cpp）
```

## 技術約定

- Material Design 3，深色模式優先；字體 Inter + Noto Sans
- 平台推論：iOS/macOS 用 Core ML，Android 用 TFLite（LiteRT），Windows 用 ONNX Runtime；LLM 一律 llama.cpp
- 模型分層下載：核心 ~400MB 隨首次啟動，LLM ~1.2GB 選擇性下載
- 效能目標：500 字 < 5 秒、冷啟動 < 3 秒、記憶體峰值 < 2GB

## 開發流程規則

- **每次有意義的開發進展（新功能、重大決策、問題解決）都要在 [DEVLOG.md](DEVLOG.md) 追加記錄**，格式見該檔案開頭的記錄規則
- 開發階段依 implementation_plan.md 第十一節：①基礎建設 → ②AI 引擎 → ③智慧報告 → ④打磨上架
- 尚未確認的事項（見 plan 第「使用者審核項目」節）：訓練數據來源、定價、正式名稱（TruthLens 為暫定代號）

## 模型訓練子專案（`training/`）

第一版檢測模型用公開資料集 HC3（英+中）微調 xlm-roberta-base，產出 INT8 量化 ONNX（四平台通用）。
獨立的 Python 環境（`training/.venv`，Python 3.14 + PyTorch/MPS），不屬 Flutter 建置。
流程與部署方式見 [training/README.md](training/README.md) 與 [docs/native_inference_bridge.md](docs/native_inference_bridge.md)。

```bash
cd training
.venv/bin/python prepare_data.py      # 下載整理資料（--quick 煙霧測試）
.venv/bin/python train_classifier.py  # 微調（自動用 MPS）
.venv/bin/python export_onnx.py       # 匯出 + INT8 量化
.venv/bin/python verify_onnx.py       # ONNX Runtime 推論驗證
```

## 常用指令

```bash
flutter pub get          # 安裝依賴
flutter run              # 執行（-d macos / -d ios / -d android）
flutter test             # 跑測試
flutter analyze          # 靜態分析
```
