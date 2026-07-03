# TruthLens 發佈與上架檢查清單（P4）

依 implementation_plan.md 第四階段。標記說明：✅ 完成 · 🟡 進行中 · ⬜ 未開始 · ⚠️ 阻塞（需決策）

## 0. 待拍板事項（阻塞上架）

- ⚠️ **正式 App 名稱**（TruthLens 為暫定；影響 bundle id、商標、商店頁）
- ⚠️ **定價**（一次買斷區間；影響商店設定與稅務）
- ⚠️ **檢測模型訓練數據授權**（第一版用 HC3，需確認其授權是否允許商用散布）

## 1. 功能完整度

- ✅ 五大畫面（輸入 / 分析 / 報告 / 歷史 / 設定）
- ✅ 文件匯入（txt/md）、圖片 OCR（macOS Vision）
- ✅ 報告匯出 PDF / CSV / JSON
- ✅ 檢測引擎集成投票 + 信心閾值 + ESL 修正
- 🟡 檢測模型（第一版訓練中；需上傳並填入 registry）
- ⬜ 本地 LLM 智慧報告（llama.cpp 原生端未實作，目前用模板回退）
- ⬜ OCR：iOS / Android / Windows 原生端
- ⬜ 檢測原生推論：iOS(CoreML) / Android(TFLite) / Windows(ONNX) 的 ONNX Runtime plugin

## 2. 各平台適配

| 平台 | 建置 | 原生 OCR | 原生推論 | 備註 |
| :--- | :--- | :--- | :--- | :--- |
| macOS | ✅ 綠燈 | ✅ Vision | ⬜ | 主要開發驗證平台 |
| iOS | ⬜ 未驗證 | ⬜ | ⬜ | 需 Files/Share Extension |
| Android | ⬜ 未驗證 | ⬜ | ⬜ | doctor 有 SDK licenses 警告待處理 |
| Windows | ⬜ 未驗證 | ⬜ | ⬜ | 需大螢幕自適應佈局 |

## 3. 商店資產與中繼資料

- ⬜ App 圖示（各平台尺寸）
- ⬜ 商店截圖 / 預覽影片
- ⬜ App 描述、關鍵字、分類（Utilities / Education）
- ⬜ 隱私政策頁（強調 100% 離線、無資料上傳——本 App 主要賣點）
- ✅ macOS 顯示名稱設為 TruthLens（暫定）

## 4. 隱私與權限

- ✅ macOS 沙盒 entitlement：`files.user-selected.read-write`（選檔/存檔/OCR 選圖）
- ⬜ iOS Info.plist：相機權限說明（相機 OCR 用）
- ⬜ Apple 隱私清單（PrivacyInfo.xcprivacy）+ App Store 隱私問卷
  - 本 App 不收集資料、無網路傳輸（模型下載除外）——填報應極簡
- ⬜ Android：宣告無網路權限或僅模型下載用途

## 5. 效能驗證（對照 plan 第十節目標）

- ⬜ 500 字分析 < 5 秒
- ⬜ 5000 字分析 < 30 秒
- ⬜ 冷啟動 < 3 秒
- ⬜ 記憶體峰值 < 2GB（含 LLM）
- 註：目前啟發式引擎極快；待真模型與 LLM 整合後重新量測

## 6. 品質

- ✅ 單元測試（檢測 / 匯出 / 報告 / 模型管理 / 多語系 / OCR，39 項）
- ✅ `flutter analyze` 零問題
- ⬜ 整合測試（integration_test）涵蓋主要流程
- ⬜ 無障礙：螢幕閱讀器標籤、高對比、可調字級（plan 有列，尚未系統性處理）

## 7. 簽章與發佈

- ⬜ Apple Developer 帳號、憑證、Provisioning / Notarization
- ⬜ Google Play 開發者帳號、簽章金鑰
- ⬜ 模型 CDN / GitHub Releases（`ModelManager` 差量下載已就緒，待實際 host）
