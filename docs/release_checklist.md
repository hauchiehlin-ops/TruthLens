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
- 🟡 本地 LLM 智慧報告（Gemma / llama.cpp 已接 `truthlens_llama` bridge；macOS、iOS、Android arm64-v8a/x86_64 已打包，Windows 需 Windows host 編譯驗證；缺模型或缺庫時透明模板回退）
- ⬜ OCR：iOS / Android / Windows 原生端
- ⬜ 檢測原生推論：iOS(CoreML) / Android(TFLite) / Windows(ONNX) 的 ONNX Runtime plugin

## 2. 各平台適配

| 平台 | 建置 | 原生 OCR | 原生推論 | 備註 |
| :--- | :--- | :--- | :--- | :--- |
| macOS | ✅ 綠燈 | ✅ Vision | 🟡 ONNX + LLM bridge | 主要開發驗證平台 |
| iOS | 🟡 `--no-codesign` build 通過 | ⬜ | 🟡 LLM bridge 已打包；CoreML 檢測 bridge 待補 | 需 Files/Share Extension / 實機簽章驗證 |
| Android | 🟡 debug APK build 通過 | ⬜ | 🟡 LLM bridge 已打包；TFLite 檢測 bridge 待補 | arm64-v8a/x86_64 LLM ABI；不宣稱 armeabi-v7a LLM |
| Windows | ⬜ macOS 主機不可建置 | ⬜ | 🟡 LLM bridge 建置/打包腳本已補 | 需 Windows host 執行 build + smoke test |

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
- ⬜ Android：宣告僅必要網路用途（模型更新偵測、模型下載、URL/DOI 驗證可關閉）

## 5. 效能驗證（對照 plan 第十節目標）

實測（macOS，distilbert 分類器 + distilgpt2 困惑度，INT8）：
- ✅ 500 字分析 **0.35 秒**（目標 < 5 秒）
- ✅ 5000 字分析（66 句）**1.06 秒**（目標 < 30 秒）
- ✅ 純 Dart 熱路徑（前處理+啟發式+報告）5000 字約 1ms
- ⬜ 冷啟動 < 3 秒（未系統量測）
- ⬜ 記憶體峰值 < 2GB（含 LLM；需跨平台實機量測）
- 基準測試：test/perf_benchmark_test.dart（host）、integration_test/perf_benchmark_test.dart（macOS 真實推論）

## 6. 品質

- ✅ 單元測試（檢測 / 匯出 / 報告 / 模型管理 / 多語系 / OCR，39 項）
- ✅ `flutter analyze` 零問題
- 🟡 整合測試（integration_test）涵蓋 ONNX 推論 + 效能基準
- 🟡 無障礙：螢幕閱讀器語意標籤已加於輸入/分析/報告/歷史；設定/模型頁待補

## 7. 簽章與發佈

- ⬜ Apple Developer 帳號、憑證、Provisioning / Notarization
- ⬜ Google Play 開發者帳號、簽章金鑰
- ⬜ 模型 CDN / GitHub Releases（`ModelManager` 差量下載已就緒，待實際 host）
