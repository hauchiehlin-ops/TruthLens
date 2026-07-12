# 計劃完成度對照（對 implementation_plan.md）

狀態：✅ 完成 · 🟡 部分/可運作但待強化 · ❌ 未做

## 模組 1：多層級檢測引擎（Ensemble）
| 子項 | 狀態 | 說明 |
| :--- | :--- | :--- |
| A. Transformer 分類器 | ✅ | 真實 ONNX Runtime 端上推論；WordPiece + RoBERTa BPE tokenizer（皆逐 id 對齊原生、macOS 實測） |
| B. 統計分析（Perplexity/Burstiness） | 🟡 | Burstiness/TTR/Entropy 啟發式可用；真 DistilGPT2 困惑度未接 |
| C. 風格特徵（Stylometry） | 🟡 | 規則式特徵庫（過渡詞、句式重複）可用；XGBoost 未加 |
| D. 對抗防禦（改寫偵測） | ❌ | 專用改寫分類器未訓練（stub，unavailable） |
| 集成加權投票 | ✅ | 40/25/20/15，不可用引擎自動重分配權重 |
| ESL 偏差修正 | ✅ | 啟發式偵測 + 統計權重降半（可關） |
| 逐句熱力分數 | ✅ | 已改用神經模型逐句機率（本次強化） |

## 模組 2：AI 動態報告生成
| 子項 | 狀態 | 說明 |
| :--- | :--- | :--- |
| 確定性回退（模板+規則生成） | ✅ | ReportComposer 選版面 + 中文解讀 |
| 動態版面決策 | ✅ | 依判定/混合/改寫選模板 |
| 本地 LLM（Gemma, llama.cpp） | 🟡 | FFI 載入與推論已整合、<4GB RAM 保護、缺庫平台優雅退回模板。macOS/iOS/Android arm64-v8a/x86_64 已打包 TruthLens bridge；Windows 已提供建置/打包腳本但仍需 Windows host 實機驗證（見 [llm_platform.md](llm_platform.md)） |

## 模組 3：OCR
| 平台 | 狀態 |
| :--- | :--- |
| macOS（Vision） | ✅ 實測可辨識中英 |
| iOS（Vision） | ✅ 原生實作（Vision 框架） |
| Android（ML Kit） | ✅ 原生實作（Google ML Kit） |
| Windows（Windows.Media.Ocr） | ✅ 原生實作（Windows.Media.Ocr） |

## 模組 4：本地資料管理
| 子項 | 狀態 |
| :--- | :--- |
| SQLite 歷史紀錄 | ✅ |
| 偏好設定 | ✅ |
| 模型檔管理（分層下載 + 多變體 + 硬體選型 + 更新/刪除/切換） | ✅ |
| 匯出（PDF/CSV/JSON/PNG） | ✅ PNG 摘要卡已實作（SummaryCard，macOS 實測） |
| 自訂 ONNX 模型匯入 | ✅ 支持本機 ONNX 模型匯入、Tokenizer 設定、與匯入前推論測試 |

## UI/UX
| 子項 | 狀態 |
| :--- | :--- |
| 五大畫面 + 首啟引導 | ✅ |
| Material 3 深色優先、Inter/Noto | ✅ |
| 分析動畫（粒子/波形） | ✅ AnalysisWave（脈動環 + 流動正弦波 CustomPainter） |
| 無障礙（螢幕閱讀器語意） | 🟡 輸入/分析/報告/歷史已加 Semantics；設定/模型頁待補 |
| 自訂模型匯入頁面 | ✅ 包含完整匯入設定、測試推論與儲存流程 |

## 其他
| 項目 | 狀態 |
| :--- | :--- |
| 模型更新機制（遠端 catalog + 版本更新 + 熱替換） | ✅ |
| 效能基準量測（第十節目標） | ✅ 500 字 0.35s、5000 字 1.06s（macOS 真實推論，遠低於目標） |
| 報告匯出 PNG 摘要卡 | ✅ SummaryCard（macOS 實測渲染正確） |

## 四大作業系統支援
| 面向 | iOS | Android | macOS | Windows |
| :--- | :--- | :--- | :--- | :--- |
| 專案 runner 已建立 | ✅ | ✅ | ✅ | ✅ |
| 核心檢測 + ONNX 推論（onnxruntime 全平台） | 應可 | 應可 | ✅ 實測 | 應可 |
| 儲存/匯入/匯出/報告 | 應可 | 應可 | ✅ | 應可 |
| OCR 原生端 | ✅ | ✅ | ✅ | ✅ |
| 裝置 RAM 偵測原生端 | ✅ | ✅ | ✅ | ✅ |
| 實機建置驗證 | ❌ | ❌ | ✅ | ❌（無法於 macOS 建置） |

**結論**：架構與核心功能（含真實 ONNX 推論）設計為四平台通用，理論上四平台皆可運作；但目前**僅 macOS 經實機建置與端上推論驗證**。要「同時滿足四大 OS」尚需：各平台實機建置測試、補 OCR 與裝置偵測的原生端、各平台簽章與權限設定。

## 建議優先強化（可再優化）
1. **準確性**：接真 DistilGPT2 困惑度（B）、訓練對抗改寫模型（D）、集成權重校準；多語言模型上架 host
2. **跨平台**：iOS 共用 Vision OCR、Android ML Kit、Windows OCR；各平台實機建置
3. **體驗**：無障礙、分析動畫、PNG 摘要卡、更清楚的模型下載/切換回饋
4. **智慧報告**：接 llama.cpp 讓 LLM 真正生成報告
