# TruthLens 開發日誌（DEVLOG）

> ## 記錄規則
> 1. **時機**：每完成一項有意義的工作（功能、模組、重大決策、問題排除）即追加一則記錄；小改動可合併為一則
> 2. **順序**：新記錄加在最上方（reverse chronological），日期用 `YYYY-MM-DD`
> 3. **格式**：每則包含 —
>    - **做了什麼**（What）：具體變更與涉及檔案
>    - **為什麼**（Why）：動機或觸發原因
>    - **決策與取捨**（Decisions）：若有技術選型或方向決定，記下理由與被捨棄的選項
>    - **待辦/遺留問題**（Open items）：若有
> 4. **不記**：純格式調整、typo 修正等瑣事
> 5. 對應的階段標籤：`[P1 基礎建設]` `[P2 AI引擎]` `[P3 智慧報告]` `[P4 打磨上架]`

---

## 2026-07-05 — [P4 打磨上架] 全面多語系化：13 種語言 + 首頁語系切換選單

**做了什麼**
- 使用者要求：所有操作介面文字標籤（含提示詞、警告訊息、引擎判定理由、報告敘事）需完全支援 13 種語言——繁體中文、簡體中文、英文、日文、韓文、泰文、馬來文、西班牙文、印尼文、俄文、德文、法文、葡萄牙文，並在首頁提供語系切換下拉選單
- 導入 Flutter 官方 l10n 工具鏈：[l10n.yaml](l10n.yaml)（`nullable-getter: false`）+ [lib/l10n/app_en.arb](lib/l10n/app_en.arb)（模板，325 個 key，含完整 `@key` placeholder metadata）+ 12 個對應語系 ARB 檔（`app_zh_Hant` / `app_zh_Hans` / `app_zh`〔script-qualified locale 必要的 fallback〕/ `app_ja` / `app_ko` / `app_th` / `app_ms` / `app_es` / `app_id` / `app_ru` / `app_de` / `app_fr` / `app_pt`），`flutter gen-l10n` 產生 `lib/l10n/generated/`
- 簡體中文改用 OpenCC（`tw2sp` profile）從繁體版本程式化轉換，而非重新手動翻譯一次；轉換後以 Python 腳本驗證零 placeholder 損毀
- 每個 ARB 檔都經過驗證腳本檢查：JSON 合法性、key 集合與英文模板完全一致（無缺漏／多餘 key）、每個 key 的 `{placeholder}` 名稱集合一致
- **靜態 UI 文字**：[input_screen.dart](lib/features/input/input_screen.dart)（含新增的語系切換 `PopupMenuButton`，`kSupportedLanguageOptions` 14 項含「跟隨系統」）、[analysis_screen.dart](lib/features/analysis/analysis_screen.dart)、[report_screen.dart](lib/features/report/report_screen.dart)、[settings_screen.dart](lib/features/settings/settings_screen.dart)（新增語言下拉選單設定項）、[history_screen.dart](lib/features/history/history_screen.dart)、[model_import_screen.dart](lib/features/settings/model_import_screen.dart)、onboarding 系列畫面、[help_screen.dart](lib/features/help/help_screen.dart)、[privacy_policy_screen.dart](lib/features/help/privacy_policy_screen.dart) 全數改為 `l10n.xxx` 呼叫
- **動態生成內容**（使用者原話明確要求一併完成，而非只做靜態文字）：`DetectionEngine` 介面改為 `name(AppLocalizations l10n)` / `analyze(text, l10n)`，四個引擎實作（[transformer_engine.dart](lib/core/detection/engines/transformer_engine.dart)、[statistical_engine.dart](lib/core/detection/engines/statistical_engine.dart)、[stylometry_engine.dart](lib/core/detection/engines/stylometry_engine.dart)、[adversarial_engine.dart](lib/core/detection/engines/adversarial_engine.dart)）的判定理由字串全部改用 `l10n.engineReasonXxx(...)`；[orchestrator.dart](lib/core/detection/orchestrator.dart) 的 `analyze()` 新增可選的 `AppLocalizations? l10n` 參數（預設 `lookupAppLocalizations(Locale('en'))`，刻意設計成向下相容，避免既有測試呼叫點需要改動）；[report_composer.dart](lib/features/report/report_composer.dart) 的報告敘事模板、[report_llm_service.dart](lib/core/detection/report_llm_service.dart) 給本地 LLM 的 prompt（改用英文撰寫＋明確指令要求輸出指定 BCP-47 語言）全數本地化
- [preferences_service.dart](lib/core/services/preferences_service.dart) 新增 `locale` 欄位持久化（含 script subtag 編解碼），[main.dart](lib/main.dart) 的 `MaterialApp.router` 接上 `supportedLocales`／`localizationsDelegates`／`localeResolutionCallback`（找不到對應語系時 fallback 回 zh_Hant）
- 新增 [test/all_locales_smoke_test.dart](test/all_locales_smoke_test.dart)：對 13 個語系逐一呼叫 `lookupAppLocalizations`，驗證關鍵字串非空、placeholder 代換正確、且各語系文字彼此不同（防止未來語系檔誤植或漏翻）

**為什麼**
- 使用者明確要求「深度掃描應用程式所有文字標籤、提示詞、警告等訊息」需完全符合多語系設定；詢問是否僅需靜態 UI 文字後，使用者回覆「A 和 B 都要，這次做完」，即動態生成內容（引擎理由、報告敘事、LLM prompt）也必須一併涵蓋，不能只做表面的靜態字串抽取

**決策與取捨**
- `DetectionEngine`／`ReportComposer`／`ReportExporter`／`SummaryCard` 的方法簽章改為非可選參數（破壞性變更），而非做成可選＋預設值：這些是內部呼叫鏈的核心節點，強制要求呼叫端明確傳入語系可避免遺漏；但在 `Orchestrator.analyze()` 這個對外公開 API 邊界刻意留可選參數，兩害相權取其輕
- 簡體中文用 OpenCC 程式化轉換而非重新手寫翻譯：325 個 key 手動翻譯兩次成本過高且容易產生繁簡版本語意漂移，OpenCC 轉換後仍逐一驗證 placeholder 完整性
- PDF 匯出內嵌字型 `NotoSansTC-Regular/Bold.ttf` 經 fontTools 實測不含韓文諺文（Hangul）與泰文字母（僅涵蓋拉丁、西里爾、日文假名）；未臨時加入新字型檔（涉及授權來源查證與約 10–20MB 體積增加，非本次範圍能倉促決定），改為在 [report_exporter.dart](lib/core/services/report_exporter.dart) 的類別文件註解中明確記錄此已知限制（僅影響 PDF 匯出的韓文／泰文顯示，畫面呈現、CSV、JSON 匯出不受影響）
- `assets/model_catalog.json` 的模型名稱／備註欄位（技術性專有名詞）刻意排除在翻譯範圍外
- JSON／CSV 匯出的欄位名稱（`version`、`analyzed_at`、`verdict` 等）刻意維持英文，視為穩定的 API schema，不隨語系變動
- 因本次執行環境的 computer-use 工具對這個 session 的滑鼠點擊一律回報「會落在通知中心」而完全無法點擊（含 Dock 圖示，判斷為環境限制而非 App 本身問題），無法用點擊操作實機走過語言切換選單；改以自動化測試（`all_locales_smoke_test.dart`）驗證全部 13 語系皆可正確載入、字串不為空、placeholder 代換正確，並用 `flutter build macos` 確認可正常打包啟動、`open` 直接開啟 .app 目視確認預設語系（zh_Hant）畫面正常顯示

**待辦/遺留問題**
- 語言切換下拉選單尚未由人工在畫面上實際點擊切換驗證（受限於本次環境的 computer-use 點擊限制），建議下次有可互動環境時手動確認選單切換即時生效
- PDF 匯出的韓文／泰文字型缺字問題尚未解決，需要另外尋源合適字型檔案並確認授權後才能修補

---

## 2026-07-05 — [P3 智慧報告] 超連結／文獻驗證新增連線狀態偵測與提示

**做了什麼**
- 使用者要求：App 執行時預設假定有網路連線；若連線不佳，超連結／文獻參考真實性分析應明確提示使用者需要網路連線才能正常判斷
- 新增 [network_status.dart](lib/core/services/network_status.dart)：`NetworkStatus.isOnline()` 以輕量 HEAD 請求探測連線（打 Crossref——本來就是兩項驗證共同依賴的服務，不另外引入新的探測端點），收到任何非 5xx 回應（含 4xx）都視為已連線，只有逾時／連線例外才判定為離線
- [report_screen.dart](lib/features/report/report_screen.dart) 重構驗證流程為單一入口 `_runVerification()`：先確認（或重用已探測過的）連線狀態，離線時直接顯示「網路連線不佳」提示卡片（含「重新檢查連線」按鈕），不會讓每筆連結／文獻各自嘗試逾時；原本的 `_verifyLinks()`／`_verifyBibliography()` 兩個方法合併掉，兩張卡片上的「立即驗證」「立即核實」按鈕也改呼叫同一入口（並強制重新探測連線，而非沿用快取結果）
- 測試：[network_status_test.dart](test/network_status_test.dart)（200/4xx 視為已連線、5xx 與連線例外視為未連線）

**為什麼**
- 使用者指出目前離線時的行為（讓每個連結各自逾時、顯示分散的「無法確認」訊息）不夠清楚，應該有統一、明確的連線狀態提示

**決策與取捨**
- 探測目標選 Crossref 而非另找一個中立的連線探測端點（如 Google/Apple 的 captive portal 偵測位址）：Crossref 本來就是兩項驗證功能唯一依賴的第三方服務，用它探測不會多引入新的外部依賴，且探測失敗與實際驗證失敗的根因是同一個
- 探測結果快取在該次報告畫面的 state 內（`_networkAvailable`），避免自動觸發與手動按鈕重複探測；但手動按鈕與提示卡片的「重新檢查」一律強制重新探測（`forceRecheck: true`），確保使用者主動重試時不會被舊的快取結果卡住
- 未實機模擬離線情境驗證提示卡片畫面（詢問使用者是否要關閉 Wi-Fi 或封鎖 Crossref 網域測試，使用者選擇不模擬、相信單元測試），改以完整測試套件覆蓋連線判定邏輯的四種情境，並實機確認正常連線時不會誤跳出警告、DOI 驗證仍正確運作

**待辦/遺留問題**
- 無

---

## 2026-07-05 — [P4 打磨上架] 首頁新增「操作說明」與「隱私權政策」

**做了什麼**
- 新增 [help_screen.dart](lib/features/help/help_screen.dart)（操作說明）：
  1. 產品介紹 + 與市面五大主流工具（GPTZero、Turnitin、Originality.ai、Copyleaks、Winston AI）逐一比較，並列出 TruthLens 獨有優勢（超連結／文獻真實性驗證、ESL 偏差修正、自訂模型匯入）
  2. 完整操作流程（5 步驟）：模型下載與更新 → 如何選用模型（各引擎權重與目的效果）→ 文檔上傳 → 開始分析 → 查看與匯出結果
  3. 模型下載與調適教學（零基礎，5 步驟）：開啟模型管理 → 依裝置能力挑選 → 下載與套用 → 更新 → 進階自訂模型匯入；並附四個模型角色的官方下載連結（Transformer/統計/對抗式/LLM，取自 `assets/model_catalog.json` 的真實 `page_url`），點擊以 `url_launcher` 開啟系統瀏覽器
- 新增 [privacy_policy_screen.dart](lib/features/help/privacy_policy_screen.dart)（隱私權政策）：以 `defaultTargetPlatform` 偵測目前執行的作業系統，顯示對應平台措辭的政策內容（iOS／Android／macOS／Windows 各有專屬章節呼應該平台的商店揭露慣例，如 App Store 隱私「營養標籤」、Google Play「資料安全」、macOS App Sandbox 權限），核心資料處理與連線行為說明四平台一致（因為實際行為本來就相同，只是揭露格式不同），並附非法律文件聲明
- [router.dart](lib/app/router.dart) 新增 `/help`、`/privacy` 路由；[input_screen.dart](lib/features/input/input_screen.dart) 首頁 AppBar 新增對應的兩個圖示入口

**為什麼**
- 使用者要求首頁增設這兩個功能分頁，並給出明確內容要求（含與競品比較、完整流程、模型調適零基礎教學含官方連結、依作業系統顯示對應隱私權政策）

**決策與取捨**
- 隱私權政策明確聲明「非律師審閱之正式法律文件」：內容如實反映本 App 目前的實際行為（無帳號、無廣告追蹤、核心運算裝置端執行、僅三項必要連線行為），但正式法遵文件仍應由專業法律意見審查，避免誤導使用者以為這是通過認證的法律文件
- 官方模型連結直接從 `assets/model_catalog.json` 讀取真實 `page_url`／`source` 欄位轉寫，而非重新查找或手動輸入，確保與實際可下載來源一致
- 五大比較工具選用 implementation_plan.md 既有市場分析中最具代表性的獨立標準檢測工具（GPTZero、Turnitin、Originality.ai、Copyleaks、Winston AI），排除 QuillBot（主力為改寫而非偵測）與 ZeroGPT，並在頁面附註「僅供功能定位參考，非第三方認證數據」避免誇大宣稱

**待辦/遺留問題**
- 無。提交當下 computer-use 點擊功能暫時卡住（誤判整個畫面為「通知中心」），先以 `flutter analyze` + 完整測試套件（110 項全過）作為完成標準提交；稍後 computer-use 自行恢復，已補做實機驗證：「操作說明」比較表、五步驟操作流程、模型調適教學與官方連結皆正確顯示，點擊模型連結確實開啟系統瀏覽器；「隱私權政策」正確依 `defaultTargetPlatform` 顯示 macOS 版內容（App Sandbox 權限說明、必要連線行為、非法律文件聲明皆正確顯示）

---

## 2026-07-05 — [P3 智慧報告] 報告預設顯示「超連結真實性」「文獻參考真實性」兩主題

**做了什麼**
- 使用者要求：分析報告應預設顯示「超連結真實性」與「文獻參考真實性」兩個主題。先前 [report_screen.dart](lib/features/report/report_screen.dart) 的 `_linkVerificationCard()`／`_bibliographyCard()` 只在偵測到網址／文獻條目時才出現，未偵測到時整張卡片直接消失
- 移除 `if (_detectedUrls.isNotEmpty)` / `if (_bibEntries.isNotEmpty)` 的外層條件，兩張卡片改為**每份報告都固定顯示**；卡片內部新增「未偵測到」分支：無網址時顯示「超連結真實性／未在文件中偵測到超連結。」、無文獻條目時顯示「文獻參考真實性／未在文件中偵測到參考文獻條目。」，不附按鈕、不連線
- 兩張卡片的標題統一改為使用者指定的用詞「超連結真實性」「文獻參考真實性」（原本分別是「超連結驗證」「參考文獻目錄核實」），並在「尚未驗證／核實中」的過渡狀態也加上同樣的標題，讓卡片在偵測前/中/後三種狀態下標題一致
- **實機驗證**：用 computer-use 貼入一段完全沒有網址、沒有參考文獻的普通英文段落並分析，確認報告底部固定顯示兩張卡片，內容分別為「未在文件中偵測到超連結。」與「未在文件中偵測到參考文獻條目。」

**為什麼**
- 使用者希望這兩個主題成為報告的標準組成部分，讓使用者每次都能看到「這份報告有沒有檢查過連結／文獻真實性」，而不是只在剛好偵測到時才附帶出現

**決策與取捨**
- 沒有直接改變偵測邏輯本身（`extractEntries`/`extractUrls` 的判定規則不變），純粹是報告呈現層級的調整——避免和先前已測試過的偵測/門檻邏輯耦合，降低出錯風險

**待辦/遺留問題**
- 無

---

## 2026-07-05 — [P2 AI引擎] 參考文獻偵測擴及無標題文件

**做了什麼**
- 使用者追問：`extractEntries()` 原本只在找到「References/參考文獻」等標題後才切分條目，但文件可能不會明確標示「這是文獻目錄」，這樣的文件會被完全略過
- 改為兩種路徑：(1) 找得到標題 → 沿用原邏輯，標題本身就是明確訊號，即使只有 1 筆也算數；(2) 找不到標題 → 改為直接對全文掃描作者—年份格式的條目，但新增 `minEntriesWithoutHeading`（= 3）門檻，累積達門檻才視為真正的文獻目錄，避免內文偶然出現一兩筆神似的片段（如敘述中剛好提到「Smith, J., 2020. ...」）被誤判
- 測試：新增「無標題但達門檻」「無標題且未達門檻」兩情境
- **實機驗證**：用 computer-use 貼入完全移除「References」字樣的同一份文獻文字（3 筆真實＋1 筆捏造），確認報告頁仍自動顯示「正在核實參考文獻目錄…」並在完成後正確標記 3 筆綠色「應存在」、1 筆紅色「可能為虛構文獻」——證實無標題文件也能被主動偵測

**為什麼**
- 使用者指出文件不一定會明確標示「這些是參考文獻」，原邏輯依賴標題會漏掉這類文件

**決策與取捨**
- 門檻設為 3 而非 1 或 2：`_entryStart` 正則本身已具一定特異性（需要完整的「姓氏,首字母. ... 四位數年份.」結構），但仍存在內文巧合的風險；3 筆以上緊鄰出現才是真正文獻目錄的可靠訊號，同時维持在合理範圍內不會漏掉真正的短文獻目錄

**待辦/遺留問題**
- 無

---

## 2026-07-05 — [P2 AI引擎] 參考文獻目錄核實（無 DOI 的「作者—年份」引用）

**做了什麼**
- 使用者提供一張學術論文「References」頁截圖（15 筆 Couette 流動研究文獻，純作者—年份格式，無 DOI、無任何超連結），詢問能否為這類條目建立存在性驗證機制。先提出方案與主要取捨（模糊比對而非絕對真偽判定）供使用者確認，取得同意後實作
- 新增 [bibliography_verifier.dart](lib/core/services/bibliography_verifier.dart)：
  - `extractEntries()`：偵測文件中的「References/Bibliography/參考文獻/參考書目/引用文獻」標題，並依條目切分——條目起始樣式為一位以上作者「Surname, Initials.」（可用純逗號、"and"、"&" 任意組合連接，如 `A, B., C, D., and E, F.,`）後接四位數年份與句點；正則設計中途踩過一次坑：一開始用「逗號後接 and 才算連接詞」的寫法，導致像 `Ahlers, G., Cannell, D.S., and Lerma, M.A.D., 1983.`（前兩位作者純逗號分隔、最後一位才用 and）這種常見學術格式會在「Cannell」處誤判斷點——改成「連接詞可以是純逗號、純 and、或逗號+and」三選一才修正，並用使用者截圖原文的完整 15 筆逐一驗證切分結果全部正確
  - `verifyAll()`：對每筆條目查詢 Crossref 的**書目搜尋**端點（`api.crossref.org/works?query.bibliographic=...`，直接送出整條參考文獻文字，不需自行做複雜的欄位比對查詢），取得最相近的一筆候選後，用篇名相似度（詞彙 Jaccard 相似度）＋年份是否吻合（容許 ±1，因印刷版/線上版年份可能差一年）＋第一作者姓氏是否吻合三項綜合判定，分三檔：高可信度應存在／查無相近匹配可能虛構／相似度中等或連線失敗故無法確定
- [report_screen.dart](lib/features/report/report_screen.dart) 新增「參考文獻目錄核實」卡片，觸發邏輯與既有超連結驗證卡片一致（沿用同一個 `linkVerificationEnabled` 開關：開啟時自動核實，關閉時顯示提示與「立即核實」單次按鈕）
- [settings_screen.dart](lib/features/settings/settings_screen.dart) 說明文字同步更新，涵蓋「沒有連結的作者—年份參考文獻」
- 測試：[bibliography_verifier_test.dart](test/bibliography_verifier_test.dart)（條目切分含單/雙/三作者與純逗號/and 混合連接、中英文標題偵測、Crossref 高可信度/查無匹配/篇名不符/連線失敗四種情境）
- **實機驗證**：用 computer-use 貼入使用者截圖原文的其中 4 筆真實文獻＋1 筆刻意捏造的假文獻（"Fakerman, Q.Z., 2024. A completely fabricated study..."），執行分析後「參考文獻目錄核實」卡片正確將 3 筆真實文獻標記綠色「高可信度：應存在（登記於《期刊名》）」、捏造文獻標記紅色「查無相近匹配，可能為虛構文獻」

**為什麼**
- 使用者提供的截圖顯示的參考文獻格式（純作者—年份，無 DOI）是先前 DOI-only 的期刊核實規則涵蓋不到的常見情況，因此需要另一套規則來處理

**決策與取捨**
- Crossref 書目搜尋是模糊匹配（非 DOI 查詢那種精確存在性判定），因此明確採用「高可信度／查無匹配／無法確定」三檔而非二元「存在/不存在」，並在卡片上加註「非絕對保證」的提醒，避免使用者誤將「無法確定」當作「已核實不存在」
- 沿用既有的 `linkVerificationEnabled` 開關而非另開新設定：使用者的心智模型是「超連結／引用驗證」同一件事，拆成兩個開關只會增加設定頁複雜度

**待辦/遺留問題**
- 無

---

## 2026-07-05 — [P2 AI引擎][P4 打磨上架] 取消「完全離線」原則、主動模型更新偵測、期刊文獻目錄核實

**做了什麼**
- **取消「完全離線」核心原則**：使用者指示移除此限制，因為模型更新偵測與超連結真偽判斷本質上需要連線才能「主動」進行。更新 [CLAUDE.md](CLAUDE.md)、[AGENTS.md](AGENTS.md)、[docs/implementation_plan.md](docs/implementation_plan.md) 的核心設計原則：由「完全離線：零伺服器、零隱私顧慮」改為「本地優先＋必要連線」——核心 AI 推論與使用者文件內容仍一律留在裝置端、不上傳；僅模型更新偵測與超連結／期刊文獻目錄驗證會視需要連線，且只送出版本號、網址或 DOI，使用者仍可在設定關閉
- **主動模型更新偵測**（先前為「僅在使用者手動開啟『AI 模型管理』時被動檢查」，見 2026-07-03 的相關記錄）：
  - [model_manager.dart](lib/core/detection/model_manager.dart) 新增 `checkForUpdates()`：連線抓取最新 catalog，比對所有已安裝角色的使用中版本，找出落後者；`hasAnyUpdate` / `roleHasUpdate()` 供 UI 查詢；連線失敗（離線）時靜默略過、不拋例外
  - [input_screen.dart](lib/features/input/input_screen.dart) 在首頁 `initState` 主動呼叫一次；設定齒輪圖示與 [settings_screen.dart](lib/features/settings/settings_screen.dart) 的「AI 模型管理」項目上以 `Badge` 顯示提示點，不強制彈窗打斷使用者
- **期刊文獻目錄核實規則**（使用者要求「定義判斷規則」）：判定依據為 **DOI**（`doi.org` / `dx.doi.org` 開頭且符合 `10.xxxx/...` 格式）——DOI 是出版社向 Crossref／DataCite 登記的學術文獻標準身分證，等同於該文獻在其期刊目錄中的正式登記。規則：
  1. 偵測到 DOI 連結 → 查詢 Crossref 公開 metadata API（`api.crossref.org/works/{doi}`），**不下載全文**
  2. 查得到（200）→ 判定「期刊目錄已核實」，回傳期刊名稱與篇名供比對
  3. 查無此 DOI（404）→ 判定「查無登記紀錄，可能為虛構引用」（AI 幻覺引用的強訊號）
  4. 連線失敗 → 「無法確認」
  5. 非 DOI 的一般網址（如期刊首頁網址）→ 退回純連線可達性檢查，**不宣稱**「已列於目錄」，因為那需要逐一期刊網站的專屬解析，不具通用性、也超出本次範圍
  - [link_verifier.dart](lib/core/services/link_verifier.dart) 新增 `isDoiUrl()`、Crossref 查詢邏輯與 `LinkCheckResult` 的 `isCitationVerified`/`journalName`/`articleTitle` 欄位；[report_screen.dart](lib/features/report/report_screen.dart) 依 `isCitationVerified` 顯示不同措辭
- **超連結驗證改為預設開啟**：[preferences_service.dart](lib/core/services/preferences_service.dart) 的 `linkVerificationEnabled` 預設值由 `false` 改為 `true`（呼應「不再要求完全離線」），設定頁說明文字同步更新，移除「本 App 唯一需要連線的功能」的過時措辭（現在還有模型更新偵測）
- 測試：[model_manager_test.dart](test/model_manager_test.dart) 新增 `checkForUpdates` 三種情境（有更新／版本相同／離線失敗）；[link_verifier_test.dart](test/link_verifier_test.dart) 新增 `isDoiUrl` 判定與 Crossref 查詢三種情境（查得到／404／非 DOI 網址）。全數 99 個單元測試通過，`flutter analyze` 乾淨

**為什麼**
- 使用者認為「完全離線」與「模型更新偵測」「超連結主動分析」兩項需求互相矛盾，指示取消該原則；並要求為「期刊文獻目錄格式」超連結定義具體判斷規則

**決策與取捨**
- 期刊目錄核實選擇 DOI + Crossref 作為唯一可靠依據，而非嘗試對任意期刊網址做通用性判斷：Crossref 是絕大多數主流期刊/出版社共同登記的中立公開資料庫，查詢結果具權威性且免費、無需授權；相較之下，逐一解析各期刊網站的搜尋結果頁面既不可靠也難以維護，因此明確排除在此規則之外
- 「不需要有下載功能」→ 僅查詢 Crossref 的 metadata JSON（篇名、期刊名），不下載或顯示全文，符合使用者要求的範圍
- 超連結驗證預設改為開啟，但保留設定開關（而非直接移除選項）：使用者仍可能因頻寬/隱私考量想關閉，維持一致於既有「使用者可覆蓋」的設定慣例（ESL 修正、各偵測引擎開關皆是「預設開、可關」）

**待辦/遺留問題**
- 無

---

## 2026-07-05 — [P4 打磨上架] 輸入清除按鈕、選擇性超連結驗證、修正 PDF 匯出崩潰

**做了什麼**
- **清除輸入內容**：[input_screen.dart](lib/features/input/input_screen.dart) 文字框右上角新增「X」清除按鈕（僅在有內容時顯示），一鍵清空貼上或匯入的文字，不需手動全選刪除
- **選擇性超連結驗證**（新功能，預設關閉）：
  - 新增 [link_verifier.dart](lib/core/services/link_verifier.dart)：`extractUrls()` 離線抽取文字中的網址（不連線）；`verifyAll()` 對網址發出 HEAD（405 時退回 GET）請求確認是否可解析，逾時／例外歸類為 unreachable，404/410 歸類為 notFound
  - [preferences_service.dart](lib/core/services/preferences_service.dart) 新增 `linkVerificationEnabled`（持久化，預設 `false`）
  - [settings_screen.dart](lib/features/settings/settings_screen.dart) 新增對應開關，說明文字明確告知「這是本 App 唯一需要連線的功能，僅傳送網址本身」
  - [report_screen.dart](lib/features/report/report_screen.dart) 報告頁若偵測到網址：開關已開啟時自動連線驗證並顯示結果卡片；開關關閉時僅顯示「偵測到 N 個超連結，尚未驗證」的離線提示 + 「立即驗證（需連線）」單次按鈕，不會擅自連線
  - 測試：[link_verifier_test.dart](test/link_verifier_test.dart)（抽取/去重/尾隨標點/HTTP 狀態分類/上限節流，含 `http/testing.dart` MockClient）
- **修正 PDF 匯出崩潰**：使用者回報「分析完後的文件匯出功能當機」。用 `flutter test` 直接重現（而非臆測）：建立一個近 10 萬字元、幾乎無標點（模擬誤貼入的原始 OOXML 標記）的檢測結果餵給 `ReportExporter.buildPdf`，即時重現 `PdfTooBigPageException: This widget created more than 20 pages`——單一句子過長或句子數過多，都會讓 `pw.Table` 逐句渲染撐爆 pdf 套件內建的 20 頁分頁安全上限
  - 根因不在「當機」字面意義的閃退，而是這個例外雖被 `report_screen.dart._export()` 的 try/catch 捕捉，但使用者實際遇到的情境（貼上大量無斷句內容）原本就不該讓 PDF 報告嘗試塞入所有原始資料
  - 修正：[report_exporter.dart](lib/core/services/report_exporter.dart) 新增 `_pdfMaxTableRows`（300）與 `_pdfMaxCellChars`（600）上限，逐句表格超過列數上限時僅取前 300 句並附註「請改用 CSV/JSON 匯出取得完整資料」，每格文字超過字數上限則截斷加「…」
  - 測試：[report_exporter_test.dart](test/report_exporter_test.dart) 新增超長單句與 2000 句兩種情境的迴歸測試
- **實機驗證**（用 computer-use，非僅程式碼推理）：
  - 清除按鈕：輸入文字後按 X，確認文字框正確清空
  - 超連結驗證：貼入含一個 404 網址與一個不存在網域的文字並分析，於報告頁點擊「立即驗證（需連線）」，正確顯示「網址不存在（404），可能為虛構引用」與「無法確認（連線逾時或伺服器無回應）」
  - PDF 匯出：用 pbcopy 灌入近 10.5 萬字元、幾乎無標點的內容（重現使用者回報的情境，分析後確實只切出「共 1 句」），執行「匯出 PDF 報告」，成功產生有效單頁 PDF（無崩潰、無錯誤訊息）

**為什麼**
- 使用者要求新增清除按鈕、超連結真實性驗證，並修正匯出崩潰的回報問題

**決策與取捨**
- 超連結驗證需要對外連線，與 CLAUDE.md 明定的「完全離線、零伺服器」核心原則有直接衝突；因此改為使用者詢問後選擇的「預設關閉、可在設定手動開啟」方案，且開啟後僅送出網址本身（不含文件內容），未開啟時仍能離線抽取並列出網址供使用者參考
- PDF 修正選擇「限制表格列數/字數＋提示改用 CSV/JSON」而非單純調高 pdf 套件的 `maxPages`：後者只是延後問題發生點，遇到真正病態輸入（如本例）仍可能造成長時間的版面計算而非乾淨報錯；CSV/JSON 本來就無分頁限制，適合作為完整資料的匯出管道

**待辦/遺留問題**
- 無

---

## 2026-07-05 — [P4 打磨上架] 清理重複自訂匯入 + 匯入前重複偵測

**做了什麼**
- 使用者回報「AI 模型管理」的「自訂匯入的模型」下顯示三筆完全相同的 `adversarial_paraphrase_quantized` 項目，查證後確認**不是畫面顯示錯誤**：`installed.json` 裡真的有三筆獨立記錄（各自佔一份 67.6MB 實體檔案），是我先前多輪驗證沙盒修復時反覆點擊「確認匯入」留下的測試殘留（`importLocalModel()` 本來就沒有去重機制，每次點擊都會產生新的 `custom_<timestamp>` 項目）
- **踩雷**：第一次直接編輯容器內 `installed.json` 清理後，重新讀取發現改的東西「消失」了——查出來是有一個 **Release 版本**的 App 仍在背景執行（PID 4282），它持有自己記憶體內的舊狀態，某個時機點又把舊資料寫回覆蓋了我的編輯（這也解釋了使用者截圖其實來自 Release 版而非我一直在測的 Debug 版）。確認關閉該 process 後才重新清理，這次核對「無執行中 process」的前提下寫入才真正生效
- 順便發現**第 4 筆**同源重複——在 `adversarial` 角色底下也有一筆匯入且**目前為使用中變體**，先不動、留待使用者決定是否也要處理
- **後續已處理**：詢問使用者後，選擇「改回正式版並刪除該筆匯入」——將 `adversarial` 角色的使用中變體改回已上架的 `truthlens-adversarial-distil-int8`（GitHub Releases 版），並移除 `custom_1783205696118` 的 manifest 項目與實體檔案。用 computer-use 重新啟動 App 檢查「對抗式防禦（改寫偵測）」區塊，確認顯示的使用中模型正確為官方 INT8 版、自訂匯入清單中不再有重複項
- **清理**：保留最新一筆（`custom_1783177871987`），刪除另外兩筆的 manifest 項目與實體檔案（`.onnx` + `.tokenizer.json`）
- **匯入前去重偵測**（新功能）：
  - `InstalledModel` 新增 `sha256` 欄位（持久化於 manifest）
  - `importLocalModel()` 匯入時計算並儲存模型檔的 sha256
  - 新增 `ModelManager.hashOf()`（公開的雜湊計算）與 `findByHash()`（跨角色搜尋內容相同的已安裝模型）
  - `refreshInstallStates()` 新增自動回填邏輯：對本功能上線前就已匯入、尚無 sha256 的舊資料，開機時自動補算並持久化，不需使用者重新匯入即可納入去重比對
  - [model_import_screen.dart](lib/features/settings/model_import_screen.dart) 在使用者選好模型檔後立即比對，若發現重複則顯示提示卡片（說明對應的既有模型名稱/角色、建議改用「設為使用中」），**不阻擋**使用者仍可繼續匯入
- 測試：[model_import_test.dart](test/model_import_test.dart) 新增 4 項（sha256 儲存、跨角色 findByHash 命中/不命中、舊資料自動回填雜湊），共 82 單元測試全過
- **實機驗證**：用 computer-use 對同一份已匯入過的檔案再次操作「瀏覽」選擇，確認提示卡片正確顯示、且不阻擋後續步驟

**為什麼**
- 使用者要求清理三筆重複並加上匯入前去重提示，避免以後不小心重複匯入

**決策與取捨**
- 去重比對用 sha256（內容雜湊）而非檔名/大小：檔名可能不同但內容相同（如本例），只有內容雜湊才能可靠判斷「是否為同一模型」
- 提示不做成阻擋式（不強制取消），因為使用者可能有意匯入同一檔案做不同設定測試（例如換不同 AI Label Index），保留彈性

**待辦/遺留問題**
- 無（`adversarial` 角色的重複項已依使用者決定處理完畢）

---

## 2026-07-04 — [P2 AI引擎] 對抗模組 D 正式上架 GitHub Releases，首個真實可下載模型

**做了什麼**
- 使用者授權將 `adversarial_int8.onnx`（135,729,550 bytes）與對應 `tokenizer.json` 上傳至 GitHub Releases
- **權限排查**：`gh` CLI 當時登入帳號對 `hauchiehlin-ops/TruthLens` 只有 `push: false`（唯讀），儘管同一 session 稍早的 `git push` 確實成功過（兩者用的認證路徑不同，具體原因未完全查明）。請使用者改用 `gh auth login` 切換到有 write 權限的帳號（`hauchiehlin-ops` 本人），切換後 `gh api` 確認 `push: true`/`admin: true` 才繼續
- 建立 release `models-v1`，上傳兩檔案；下載 URL 經 `curl -IL` 確認可公開存取（200，content-length 與檔案大小完全吻合）；本地與下載回來的檔案 sha256 皆為 `fc17982...e41b`，確認上傳無損毀
- 更新 [assets/model_catalog.json](assets/model_catalog.json)：`adversarial` 角色的 `url`/`tokenizer_url` 填入真實 GitHub Releases 網址、`sha256` 填入實際雜湊、`size_bytes` 校正為精確位元組數、`page_url` 指向 release 頁面
- **端到端實機驗證**：用 computer-use 啟動 App，在「AI 模型管理」對「改寫偵測模型」按下真實下載——完整走過下載進度顯示（54%→100%）、sha256 驗證、寫入 manifest、自動設為使用中變體；事後核對容器內檔案位元組數與 sha256 皆與 catalog 記錄一致
- 擴充 [model_catalog_asset_test.dart](test/model_catalog_asset_test.dart) 的迴歸測試在此次修改後仍全數通過（含先前為此問題新增的 127.0.0.1 檢查，證明真實網址不會誤觸）
- 驗證：78 單元測試全過、analyze 零問題、macOS build 綠燈，加上上述實機下載全流程確認

**為什麼**
- 使用者明確授權上傳，用以解決先前「對抗模組 D 尚未上架」的已知缺口

**決策與取捨**
- 權限請求走「使用者自行 gh auth login 切換帳號」而非直接在對話中傳遞 token 明文，降低憑證外洩風險
- 上傳前後皆做 sha256 比對（本地檔案 vs 下載回來的檔案 vs 填入 catalog 的值），三方一致才視為完成，而非只信任上傳指令回傳成功

**待辦/遺留問題**
- 多語言偵測器（`truthlens-multilingual-distil-int8`）仍待比照本次流程上傳
- LLM（Gemma/Qwen GGUF）與其餘模型的來源網址維持現狀（非本次範圍）

---

## 2026-07-04 — [修正] catalog 對抗模組 D 的下載網址指向開發機本地伺服器

**做了什麼**
- 使用者回報「AI 模型管理」畫面點「改寫偵測模型（INT8）」的下載時出現 `ClientException with SocketException: Connection refused ... address = 127.0.0.1, port = 60228`
- 根因：[assets/model_catalog.json](assets/model_catalog.json) 的 `adversarial` 角色變體 `url`/`tokenizer_url` 指向 `http://127.0.0.1:8000/...`——這是開發機本地測試伺服器的位址，對任何真實使用者的裝置永遠是 Connection refused，這是我先前體檢時就注意到、當時判斷「非我本次異動範圍」而暫緩處理的項目，這次使用者實際回報了失敗畫面，故一併修正
- **修法**：比照先前修正「多語言偵測器誤填情感分析模型網址」的方式，將 `url`/`tokenizer_url` 設回 `null`（誠實顯示「尚未上架」，UI 對應顯示「即將推出」而非會失敗的下載按鈕），note 註明模型本地已訓練驗證（98.1% 準確率）但尚未上架
- 加強 [model_catalog_asset_test.dart](test/model_catalog_asset_test.dart) 的迴歸測試：新增「url/tokenizer_url 不得含 127.0.0.1/localhost/0.0.0.0/::1」的檢查，防止此類問題再發生
- **實機驗證**：用 computer-use 重新啟動 App，捲到「對抗式防禦」區塊，確認按鈕已從會失敗的下載鈕變成「即將推出」，且不再嘗試連線
- 驗證：78 單元測試全過（新增 1 項）、analyze 零問題、macOS build 綠燈，加上實機畫面確認

**為什麼**
- 使用者這次把實際失敗畫面秀出來，屬於「已授權處理的既知問題」正式浮現，故修正

**決策與取捨**
- 延續先前建立的「url 未上架時設 null」慣例，維持一致性，而非嘗試修復或移除本地伺服器依賴（那需要真正 host 到公開可存取的位置，超出目前範圍）

## 2026-07-04 — [修正] 模型匯入畫面第二個沙盒 bug：FilePicker 未帶 withData

**做了什麼**
- 上一則修正（移除硬編碼自動偵測路徑）後，使用者用**正常的手動選檔流程**（點「瀏覽」選 .onnx 與 tokenizer.json）仍重現同樣的 `PathAccessException...errno=1`，證明還有第二個獨立的沙盒問題
- 根因：`_pickModel()`/`_pickTokenizer()` 呼叫 `FilePicker.pickFiles()` 時沒有帶 `withData: true`。macOS App Sandbox 下，NSOpenPanel 授予的檔案存取權只在選檔當下短暫有效；只保留 `path` 字串、之後（`_runTest`/`_import` 按鈕觸發時）才用 `dart:io` 讀取/複製，會因授權已過期而失敗——這與 App 內另一個既有的正確流程（[document_importer.dart](lib/core/services/document_importer.dart) 已用 `withData: true`）形成對照
- **修法**：新增 `_pickIntoSandbox()`，選檔當下立即以 `withData: true` 取得 bytes、寫入 `getTemporaryDirectory()`（App 沙盒內可寫目錄），之後一律對這個副本操作；另加 `_modelFileDisplayName`/`_tokenizerFileDisplayName` 避免 UI 顯示帶時間戳記前綴的醜檔名
- **實機驗證**（非僅程式碼推理）：用 computer-use 工具實際啟動 build 出的 App、走使用者回報的完整重現步驟（選 `adversarial_paraphrase_quantized.onnx` → 選 `tokenizer.json` → 執行測試推論）：
  - 測試推論成功，AI 機率 99.9%（先前為權限錯誤）
  - 「確認匯入並啟用模型」也成功，首頁隨即顯示新匯入的 `custom_178317...` 已設為使用中模型
- 驗證：77 單元測試全過、analyze 零問題、macOS build 綠燈，加上前述實機操作驗證

**為什麼**
- 使用者用手動選檔流程回報同一錯誤，證明第一次的修正（移除硬編碼路徑）只解決了一半問題

**決策與取捨**
- 這次沒有只憑程式碼推理就回報完成——先前的修正被同一個錯誤打臉過一次，這次改用 computer-use 實際點過完整流程再收尾，確保回報的是「已驗證」而非「應該可以」

---

## 2026-07-04 — [修正] 模型匯入畫面「偵測到本機微調目錄」導致沙盒權限錯誤

**做了什麼**
- 使用者回報 [model_import_screen.dart](lib/features/settings/model_import_screen.dart) 的「匯入自訂 ONNX 模型」畫面出現「模型匯入失敗，請檢查權限或日誌」
- 根因：畫面的 `_autoDetectLocalModel()` 直接用硬編碼絕對路徑（`/Users/barretlin/GitProjects/TruthLens/training_tools/adversarial_paraphrase_quantized.onnx`）建立 `File` 物件，**繞過了 `FilePicker`**。macOS App Sandbox（`com.apple.security.app-sandbox`）下只有透過系統選檔對話框挑選的檔案才有讀取權限（`files.user-selected.read-write`），硬編碼路徑完全沒有授權，導致 `ModelManager.importLocalModel` 內的 `modelFile.copy(target.path)` 擲出權限例外
- **驗證根因**：用不受沙盒限制的 `dart run` 直接讀該檔案成功（67MB 正常讀出），證明檔案本身無恙，問題確實出在沙盒化 App 對此路徑無存取權限；並確認 entitlements 檔只有 `files.user-selected.read-write`，無任何廣域檔案系統權限
- **修法**：移除整段硬編碶自動偵測（`_autoDetectLocalModel`、`_hasLocalUpdate`/`_localFileTime` 狀態、對應的「一鍵下載安裝」提示卡片 UI），保留原本正確使用 `FilePicker` 的手動選檔流程（模型/tokenizer 皆經選檔對話框，此路徑本就正常運作，已由既有 model_import_test.dart 覆蓋）；並在類別上加註解說明為何不可用硬編碼路徑
- 驗證：77 單元測試全過、analyze 零問題、macOS build 綠燈

**為什麼**
- 這個偵測功能即使排除沙盒問題也寫死指向單一開發者機器路徑，對任何真實使用者都不可能存在，屬於開發階段殘留的除錯輔助，非可上架功能

**決策與取捨**
- 未嘗試放寬 entitlements 讓沙盒能讀任意路徑：那需要更廣的檔案系統存取權限（如全碟存取），對一般消費性 App 是不必要的安全性倒退；正確做法就是一律經使用者主動選檔
- 未改寫成「自動導向選檔對話框」：因為原本手動流程已經存在且正常，沒有必要為了保留「自動偵測」的形式而增加複雜度

---

## 2026-07-04 — [P2 AI引擎] 對抗式防禦模組 D 訓練完成，並排除 MPS 記憶體暴衝

**做了什麼**
- **對抗式資料**：以 T5 改寫模型（humarin/chatgpt_paraphraser_on_T5_base）改寫 3000 筆 HC3 ChatGPT 答案，與原生 AI(10000)、人類(10000) 組成對抗訓練集（train 20700 / val 2300）
- **訓練結果**：distilbert-multilingual 微調 2 epochs，**驗證準確率 98.1%、F1 98.4%、召回率 99.9%**；匯出 INT8 ONNX（541MB → 136MB）
- **關鍵驗證（模組 D 存在的意義）**：用同一句改寫文字比較「無對抗訓練的一般偵測器」vs「對抗模組 D」——
  - 一般偵測器：原生 AI 0.980 → 改寫後 **0.016**（幾乎被完全規避，掉了 96 個百分點）
  - 對抗模組 D：原生 AI 0.999 → 改寫後 **0.994**（幾乎不受影響，只掉 0.5 個百分點）
  - 證明 plan 描述的「被改寫工具輕易繞過」問題真實存在，且對抗訓練確實解決它
  - [compare_baseline_vs_adversarial.py](training/compare_baseline_vs_adversarial.py) 留存此比較；[verify_adversarial.py](training/verify_adversarial.py) 做單模型的規避測試
- **macOS 整合測試**：新增對抗模組 D 案例於 [onnx_detector_test.dart](integration_test/onnx_detector_test.dart)，實測 Dart 端 OnnxDetector 載入此模型：原生 0.999、改寫 0.992、人類 0.0009——與 Python 端結果一致

**排除的重大問題：MPS 記憶體暴衝（非邏輯卡死）**
- 首次跑改寫資料準備時，process 跑了 1h40m 完全無進度輸出。用 macOS `sample` 工具直接對 process 取樣，發現：
  - 實體記憶體佔用飆到 **21.6GB**（機器總記憶體 24GB，已嚴重逼近上限造成系統換頁）
  - GPU 執行緒卡在 `_pthread_cond_wait`，並非真的在運算
  - 根因：PyTorch MPS 對 seq2seq beam search `generate()` 重複呼叫（迴圈跑約 188 批）不會自動釋放快取，記憶體線性累積
- **修法**：
  1. 改寫步驟固定用 CPU（實測 CPU 與 MPS 單批耗時相近，此模型量級下無需 MPS）
  2. 加上第二道防線：每批強制 `torch.mps.empty_cache()`（若未來改回 MPS/CUDA）
  3. 程式內建記憶體防護：單批超過 2 分鐘或 RSS 超過 8GB 自動中止並保留已完成部分
  4. 外部獨立 watchdog（每 15-20 秒檢查 RSS，超過門檻強制 kill），作為腳本內防護失效時的最後防線
  5. 所有 print 加 `flush=True` 並以 `python -u` 執行，避免「有在跑但看不到輸出」與「真的卡死」混淆不清
- 重跑後：CPU 版本全程 RSS 穩定於 4-5GB，79 分鐘乾淨完成，watchdog 全程未觸發

**為什麼**
- 使用者指示接續完成對抗式防禦模組 D 的訓練管線

**決策與取捨**
- 診斷優先於盲目重跑：先用 `sample` 取樣證實是記憶體問題而非其他原因，才對症下藥，避免同樣的等待再發生一次
- 選擇 CPU 而非繼續嘗試修 MPS 快取問題：診斷顯示兩者單批耗時相近，CPU 路徑更簡單可靠、風險更低
- watchdog 用外部獨立 shell script 而非僅信任程式內防護：雙重保險，即使程式內邏輯有 bug 也不會讓系統再次被拖垮

**待辦/遺留問題**
- 對抗模組 D 的模型需 host 才能從 app 內下載（本地已訓練驗證，路徑同其他模型）
- catalog 目前 adversarial 變體的 url 指向本地測試位址（非我本次異動範圍，留給進行中的相關工作處理）

---

## 2026-07-04 — [修正] 解決體檢發現的三個風險

**做了什麼**
- **風險 2/3（tokenizer='none' + 自動掃描孤兒模型）**：Transformer 引擎移除 'none' 支援（分類器必須有 tokenizer），並抽出 `_resolvePaths()` 統一檢查「使用中模型 + tokenizer 檔皆真的存在於磁碟」；isAvailable 據此判斷。自動掃描也改為只有在同目錄真有 `tokenizer.json` 時才登記該分類器。新增 [transformer_engine_test.dart](test/transformer_engine_test.dart)（4 項）鎖定行為
- **風險 1（LLM 平台覆蓋）**：載入本已優雅降級（缺庫→模板，不崩潰）。補上誠實化：plan_status LLM 改標 🟡 並註明僅 macOS+Android(arm64)；catalog LLM note 加平台說明（UI 可見）；新增 [docs/llm_platform.md](docs/llm_platform.md)（平台矩陣 + 各平台補庫方式 + macOS bundle 嵌入注意）
- 驗證：analyze 零問題、host 73 測試全過、macOS 完整分析管線再測通過（Transformer 引擎仍正常參與）

**為什麼**
- 使用者要求解決體檢發現的三個風險

**決策與取捨**
- 風險 1 無法在本機補 iOS/Windows/Linux 的 llama 庫（需各自工具鏈），故以「robust 降級 + 誠實標示 + 補庫文件」處理
- isAvailable 改為做檔案存在性檢查（輕量 existsSync），根治「登記了但檔案缺失」的孤兒模型問題

---

## 2026-07-04 — [檢查] 合併版體檢 + 修正

**做了什麼**
- 對併行加入的變更（跨平台 OCR、llama.cpp FFI、模型匯入）做完整體檢：analyze 零問題、69 單元測試全過、macOS build 綠燈
- **端到端驗證**：新增 [integration_test/full_analysis_test.dart](integration_test/full_analysis_test.dart)——匯入本機模型 → 完整 orchestrator 分析 → Transformer 引擎確實參與投票並產出逐句分數（macOS 實測通過，整體 AI 0.43）
- **確認實作屬實**：iOS Vision / Android ML Kit / Windows.Media.Ocr 皆為真實原生 OCR；report_llm_service 已接 llama 生成並回退模板；importLocalModel / testModel 完整
- **修正**：
  - `plan_status.md` 被還原成舊狀態（分析動畫/無障礙/PNG/效能被標回未完成）→ 更正為實際狀態
  - `testModel` 改為「先複製進容器再載入」：原生 ONNX Runtime 在 macOS 沙盒下無法直接開容器外的使用者選取檔（system error 1），複製後穩定，且與匯入走同一路徑

**發現但未改（風險/建議，交由後續決定）**
- **LLM 僅 macOS + Android(arm64) 有 libllama**；iOS/Windows/Linux 無對應庫，會回退模板（plan_status 的 LLM ✅ 實為部分平台）。Android 僅 arm64-v8a，無模擬器 x86_64
- transformer_engine 允許 tokenizer='none' 時 isAvailable 為 true，但分類器無 tokenizer 實際無法推論（會優雅回退 unavailable，僅浪費一次嘗試）
- model_manager 自動掃描硬編碼 `tokenizer.json` 裸檔名，若不存在該檔則掃描到的模型無法實際載入（優雅降級）

**為什麼**
- 使用者要求檢查合併後有無需修正/優化/未完成

---

## 2026-07-04 — [P2 AI引擎 / P3 智慧報告 / P4 打磨上架] 跨平台 OCR + llama.cpp 原生端整合 + 自訂 ONNX 模型匯入與測試

**做了什麼**
- **跨平台 OCR & 記憶體偵測**：
  - iOS: 於 [AppDelegate.swift](ios/Runner/AppDelegate.swift) 實作 Vision 框架的 `VNRecognizeTextRequest` 與 `ProcessInfo` 實體記憶體獲取。
  - Android: 於 [MainActivity.kt](android/app/src/main/kotlin/com/truthlens/truthlens/MainActivity.kt) 整合 Google ML Kit 繁中/日文/拉丁文 Text Recognition 與 `ActivityManager.MemoryInfo`。並於 [build.gradle.kts](android/app/build.gradle.kts) 新增 ML Kit 依賴。
  - Windows: 於 [flutter_window.cpp](windows/runner/flutter_window.cpp) 整合 C++/WinRT 的 `Windows.Media.Ocr` OCR 引擎與 `GetPhysicallyInstalledSystemMemory`。並於 [CMakeLists.txt](windows/runner/CMakeLists.txt) 連結 `windowsapp` 函式庫。
- **llama.cpp FFI 整合**：
  - 新增 [llama_ffi.dart](lib/core/detection/llama_ffi.dart)：建立 `dart:ffi` 對 `llama.cpp` 的 C API 繫結 (GGUF 載入與推論)，且對 struct/opaque 符合 Dart 3 `base`/`final` 修飾符。
  - 新增 [llm_manager.dart](lib/core/detection/llm_manager.dart)：處理記憶體限制 (RAM < 4GB 自動拒絕載入) 與熱卸載，保護行動端。
  - 修改 [report_llm_service.dart](lib/core/detection/report_llm_service.dart) 以呼叫 `LlmManager` / `LlamaInference` 代替原 `MethodChannel`。
  - 新增 [llm_manager_test.dart](test/llm_manager_test.dart) 進行 FFI 與管理載入單元測試。
- **自訂 ONNX 模型匯入與測試**：
  - 新增 [model_import_screen.dart](lib/features/settings/model_import_screen.dart)：支援模型匯入設定 ( ONNX 模型與 Tokenizer 檔案選擇、類型設定 bert-wordpiece / roberta-bpe / none、標籤索引)，且具備匯入前「執行測試推論」與驗證功能，解決 Flutter 3.33 FormField 棄用警告。
  - 更新 [settings_screen.dart](lib/features/settings/settings_screen.dart) 整合開啟匯入入口。
  - 新增 [NoneTokenizer](lib/core/detection/text_tokenizer.dart) 供不需 Tokenizer 的模型 (Unicode code units 映射)，並修改 [transformer_engine.dart](lib/core/detection/engines/transformer_engine.dart) 與 [onnx_detector.dart](lib/core/detection/onnx_detector.dart) 支援。
  - 新增 [model_import_test.dart](test/model_import_test.dart) 驗證檔案複製與 manifest 更新。
  - **微調工具整合與路徑規範化**：已將原本位於 `Downloads` 的微調訓練環境移動至專案根目錄的 `training_tools/`，並在 `.gitignore` 與 `adversarial_training_guide.md` 中同步更新路徑，確保開發工具鏈版本可控且安全。
- **並行推論與自訂引擎勾選 (Ensemble Optimization)**：
  - 修改 [orchestrator.dart](lib/core/detection/orchestrator.dart)：重構原本依序執行的分析迴圈，改為使用 `Future.wait` 進行**多引擎並行推論 (Parallel Execution)**，極大化利用多核心與 GPU 硬體算力。
  - 修改 [preferences_service.dart](lib/core/services/preferences_service.dart) 與 [settings_screen.dart](lib/features/settings/settings_screen.dart)：實作了對 4 個子引擎（分類器、統計、風格、對抗）的獨立啟用/禁用（Toggle）設定 UI。當某個引擎被使用者關閉時，分析協調器會自動將其排除並平滑重新分配加權權重。
- **整合測試**：69 項測試全過，`flutter analyze` 零問題。

**為什麼**
- 執行三階段同步實作，並針對強大硬體配置支援多引擎並行加速與自訂選用。

**決策與取捨**
- 行動端 (iOS/Android) 插件全採用 inline 實作於 Runner AppDelegate / MainActivity，避免污染專案與 Xcode 專案檔設定。
- 測試推論採用載入暫時的 `OnnxDetector` 執行，以保證與實際運作環境一致且不影響使用中模型。

**待辦/遺留問題**
- Windows 與 iOS 上的 `libllama.so` / `llama.dll` 預編譯庫發佈。

---

## 2026-07-04 — [P4 打磨上架] 效能基準 + 無障礙擴展

**做了什麼**
- **效能基準**（對照 plan 第十節）：
  - [test/perf_benchmark_test.dart](test/perf_benchmark_test.dart)（host）：純 Dart 熱路徑——5000 字前處理+啟發式分析約 1ms、模板報告 13µs
  - [integration_test/perf_benchmark_test.dart](integration_test/perf_benchmark_test.dart)（macOS 真實推論）：**500 字 0.35s、5000 字(66 句) 1.06s**，遠低於 5s / 30s 目標
  - 結果記入 [docs/release_checklist.md](docs/release_checklist.md)
- **無障礙擴展**：報告逐句熱力（每句唸出文字 + AI 機率 + 命中模式）、歷史列表項（合併語意：判定+機率+時間+內容）、輸入頁狀態列（MergeSemantics）
- 測試：65 單元測試全過（含 4 項效能基準）；macOS build 綠燈、analyze 零問題

**為什麼**
- 使用者指定續做效能量測與無障礙擴展

**決策與取捨**
- 效能分兩層量測：純 Dart（host 可 CI）+ 真實推論（macOS 整合）
- 無障礙用 Semantics label + ExcludeSemantics/MergeSemantics 整併裝飾與零散節點

**待辦/遺留問題**
- 冷啟動/記憶體峰值未系統量測（LLM 未整合）；無障礙可再擴及設定/模型頁
- 對抗 D、LLM、跨平台 OCR/建置 仍待（需外部資源/工具鏈）

---

## 2026-07-04 — [P4 打磨上架] 無障礙 + 分析動畫 + PNG 摘要卡

**做了什麼**
- **PNG 摘要卡匯出**（plan 第九節）：[summary_card.dart](lib/features/report/summary_card.dart) 以 Canvas 直接繪製社群分享卡（環形 AI%、判定 pill、句數統計、離線標語）→ PNG；`ReportExporter.exportPng` + 報告匯出選單新增。匯出格式現達 PDF/CSV/JSON/PNG。**在 macOS app 內以真實字型產圖驗證**，中英文與數字皆正確渲染
- **分析動畫**：[analysis_wave.dart](lib/shared/widgets/analysis_wave.dart)（AnimationController + CustomPainter）——脈動外圈 + 流動正弦波，取代分析頁靜態進度圈
- **無障礙**：ScoreGauge 加 `Semantics` 語意標籤（唸出判定+機率）並 ExcludeSemantics 內部裝飾；分析頁波形與完成圖示加語意標籤/進度描述
- 測試：summary_card PNG 位元組驗證；共 61 單元測試全過，analyze 零問題，macOS build 綠燈

**為什麼**
- 使用者指定把「可現在做完」的 UX 批次一次完成

**決策與取捨**
- PNG 用純 Canvas 繪製（非擷取 widget）：可單元測試、不需離屏 render，且版面可控
- 分析動畫用 CustomPainter 自繪，無額外套件依賴

**待辦/遺留問題**
- 無障礙可再擴及更多畫面（歷史/設定的細項）；效能量測、對抗 D、LLM、跨平台 OCR/建置 仍待

---

## 2026-07-04 — [P2 AI引擎] 統計 B 接真困惑度（DistilGPT2 端上）

**做了什麼**
- **真 Perplexity 端上計算**（統計引擎 B，plan 指定）：
  - [export_gpt2.py](training/export_gpt2.py) 匯出 distilgpt2 為 ONNX + INT8（482MB→121MB）；transformers 5.x cache 追蹤問題以 LogitsOnly wrapper + use_cache=False 解決
  - [perplexity_scorer.dart](lib/core/detection/perplexity_scorer.dart)：載入 distilgpt2、逐位置 logsumexp 計算負對數似然 → 困惑度；tokenizer 複用 BpeTokenizer 的 `encodeRaw`（byte-level BPE，不加特殊 token）
  - StatisticalEngine 改用 PerplexityScorer（依 statistical role 使用中模型延遲載入、失敗回退啟發式），閾值以 distilgpt2 校準（<60 偏 AI、>150 偏人類）
  - catalog 新增 statistical role（distilgpt2）
- **macOS 整合測試驗證**：困惑度 AI 風格 **60.7** vs 人類口語 **542.7**（與 Python 參考 52/549 相符，清楚區分）；連同 WordPiece / RoBERTa 分類推論共 3 項整合測試全過
- BpeTokenizer 加 `encodeRaw`（供困惑度）；單元測試涵蓋

**為什麼**
- 使用者要求補齊統計 B 的真困惑度，強化輸入內容判斷準確性

**決策與取捨**
- 困惑度用 distilgpt2（輕量、Apache-2.0）；byte-level BPE 複用既有實作
- 閾值以實測校準（distilgpt2 困惑度整體偏高）；仍為啟發式映射，未來可學習式校準
- 統計 B 維持「恆可用 + 有困惑度模型時增強」的降級設計

**待辦/遺留問題**
- distilgpt2 模型需 host 才能 app 內下載（本地已驗證）
- 對抗 D、LLM、跨平台 OCR/建置、無障礙、動畫、PNG 匯出、效能量測 仍待（見 plan_status.md）

---

## 2026-07-04 — [P2 AI引擎] RoBERTa BPE tokenizer + 準確性/體驗強化 + 計劃核對

**做了什麼**
- **byte-level BPE tokenizer** [bpe_tokenizer.dart](lib/core/detection/bpe_tokenizer.dart)（GPT-2/RoBERTa）：GPT-2 前處理正則、bytes_to_unicode、BPE 合併；**與真實 RoBERTa tokenizer 逐 id 對齊**（英/標點/CJK 位元組/前導空白，單元測試比對）。抽出 [text_tokenizer.dart](lib/core/detection/text_tokenizer.dart) 介面，WordPiece/BPE 皆實作
- **RoBERTa 端上推論打通**：發現 onnxruntime 套件不吃「輸出名 logits」硬編碼（roberta 輸出名為 `output`）→ 改讀全部輸出第一個；且 roberta label 0=AI（distilbert 1=AI）→ 加 `aiLabelIndex`（catalog/InstalledModel/engine 全鏈路）。托管檔宣告多餘 opset(ai.onnx.ml:5) 舊版 ORT 拒載 → 加 [fix_onnx_opset.py](training/fix_onnx_opset.py) 清未使用 opset；macOS 整合測試以清理後 roberta 驗證推論成功
- **準確性強化**：EngineScore 新增 `sentenceScores`；Transformer 逐句機率餵入 orchestrator 的句子級評分（熱力圖改用神經模型逐句分數而非僅啟發式）
- **體驗強化**：輸入頁加即時字元數 + 使用中模型指示（未安裝顯示「僅統計/風格分析」）
- **健壯性**：模型載入失敗（opset 不相容/損毀）優雅回報 unavailable，不再讓分析崩潰
- **計劃核對** [docs/plan_status.md](docs/plan_status.md)：逐模組完成度 + 四平台支援評估
- 測試：BPE（2，逐 id 對照）、59 單元 + macOS 雙模型（WordPiece + RoBERTa）推論整合測試全過

**為什麼**
- 使用者要求補 BPE 讓 roberta 真正參與檢測、強化輸入內容判斷準確性與操作體驗、核對計劃與四平台

**決策與取捨**
- OnnxDetector 不再硬編碼輸出名、加 aiLabelIndex：支援不同 label 慣例的開源模型
- roberta 托管檔的多餘 opset 是該檔問題（無實際節點使用）；提供清理工具，正式上架需清理後重新 host
- 句子級改以神經逐句機率為基準、風格模式只微調（+0.05）：準確與可解釋兼顧

**待辦/遺留問題**
- 可下載的 roberta / 多語言模型都需 host 相容檔才能在 app 內下載即用（本地已驗證可跑）
- 統計 B 真 perplexity、對抗 D 訓練、LLM llama.cpp、跨平台 OCR/裝置偵測、無障礙 仍待補（見 plan_status.md）

**做了什麼**
- **多變體並存管理**：ModelManager 由「每 role 單一變體」升級為「每 role 可並存多變體 + 使用中(active)指標」；installed.json 改記 `{role: {active, installed:{variantId:...}}}`。支援下載多個、`setActive` 切換使用中、`removeVariant` 刪除（刪到使用中會自動改用其餘）、`hasUpdate` 版本比對更新、原子熱替換
- **UI（共用 ModelOptionsList）**：每 role 列出所有變體，標「推薦/使用中」、硬體是否吃得下；動作含下載/更新/設為使用中/刪除/「模型頁面」外連（url_launcher）。首啟引導與設定模型管理頁共用
- **模型頁面連結**：catalog 變體新增 `page_url`（HF 模型頁）與 `tokenizer` 類型欄位
- **真實 ONNX 端上推論**（需求 2/3 最後一塊）：
  - 採用 `onnxruntime` Flutter 套件（底層各平台原生 ONNX Runtime，支援 macOS/Win/iOS/Android/Linux）——比手寫四份 plugin 更可攜、同為原生
  - [wordpiece_tokenizer.dart](lib/core/detection/wordpiece_tokenizer.dart)：純 Dart BERT WordPiece，**與原生 tokenizer 逐 id 對齊**（英文+標點、中文逐字、## 續接，單元測試比對真實輸出）
  - [onnx_detector.dart](lib/core/detection/onnx_detector.dart)：文字→編碼→ONNX 推論→softmax→AI 機率
  - [transformer_engine.dart](lib/core/detection/engines/transformer_engine.dart) 改用 OnnxDetector，依「使用中」模型延遲載入、逐句推論、參與集成投票
- 測試：WordPiece tokenizer（6，逐 id 對齊原生）、多變體管理/切換/更新/刪除；共 **57 項單元測試全過** + **macOS 整合測試以真實模型驗證端上推論通過**（AI 風格文本 0.269 vs 人類口語 0.0003，中文亦可推論）

**為什麼**
- 使用者要求：多模型並存/切換/更新、連模型頁面；並把「下載的模型實際參與檢測」做到真的能跑

**決策與取捨**
- ONNX Runtime 走 `onnxruntime` pub 套件（原生底層）而非手寫 Swift plugin：一份 Dart 碼涵蓋四平台，維護成本低
- 第一版 tokenizer 先實作 WordPiece（BERT 系，對應本專案多語言模型）；RoBERTa BPE（catalog 的 roberta-large）待補，該類模型暫回報 unavailable
- macOS 沙盒下模型須在 App 容器內（正式流程即下載到容器）；整合測試把模型放進容器以模擬

**做了什麼**（補齊使用者對佈建流程的完整需求）
- **多模型選項**：`ProvisionPlan` 改帶該 role 的**所有變體**（非只推薦）；抽出共用 [model_options_list.dart](lib/features/onboarding/model_options_list.dart)，首啟引導與設定模型管理頁皆列出全部變體、標「推薦」、標示硬體是否吃得下，使用者可自選下載
- **必要性說明**：共用文案 `kModelNecessityText`（[model_prompt.dart](lib/features/onboarding/model_prompt.dart)）——說明未裝模型僅有統計/風格分析、裝了神經模型大幅提升準確度；顯示於引導頁、模型管理頁、提示對話框
- **略過後再提醒**：input 的「開始檢測」若核心偵測模型未安裝且未關閉提醒 → 彈出 `showModelDownloadPrompt`；選「前往下載」導向 `/models`、選「暫時略過/關閉」則以現有引擎繼續
- **提示可關閉（預設）**：對話框 `barrierDismissible: true` + 右上關閉鈕 + 「不再提醒我」勾選（寫入 `prefs.modelPromptSuppressed`）
- 安裝檢查沿用 installed.json manifest；新增 `/models` 路由指向模型管理頁
- 測試：downloadVariant 以 MockClient 驗證「下載→寫檔→寫 manifest→標記已安裝→重掃仍已安裝」端到端；plan 選項/推薦/fits 邏輯；共 **50 項全過**，analyze 零問題，macOS build 綠燈

**為什麼**
- 使用者要求：首啟提供多下載選項、說明下載必要性、略過後在需模型的分析時再提醒、提示預設可關閉

**決策與取捨**
- 略過後分析不阻擋——仍以統計/風格引擎產出結果（優雅降級），只是提示可下載以提升準確度
- 提示抑制用單一「不再提醒」旗標；使用者仍可隨時到設定→模型管理下載
- 變體 UI 抽成共用元件，引導頁與設定頁一致、避免重複

**做了什麼**
- **採用開源預訓練模型**：確認可直接下載的開源偵測器 `joaopn/roberta-large-openai-detector-onnx-fp16`（現成 ONNX，710MB，HTTP 200 可下載），免自行訓練即有高品質英文偵測；搭配本專案 HC3 微調的多語言輕量版
- **模型 catalog** [model_catalog.dart](lib/core/detection/model_catalog.dart) + [assets/model_catalog.json](assets/model_catalog.json)：各 role 列多個變體（含 min_ram_mb、tier、languages、url、來源、授權），`bestFor(tier, ram)` 依硬體挑最適且可下載者
- **遠端 catalog** [model_catalog_service.dart](lib/core/detection/model_catalog_service.dart)：首啟抓遠端「目前最新」清單（GitHub raw，無伺服器，對應 plan 第八節），失敗回退打包的 asset
- **裝置能力偵測** [device_capabilities.dart](lib/core/detection/device_capabilities.dart) + macOS 原生 [DevicePlugin.swift](macos/Runner/DevicePlugin.swift)（ProcessInfo 實體記憶體）→ low/mid/high tier
- **佈建協調** [model_provisioner.dart](lib/core/detection/model_provisioner.dart)：結合 catalog + 裝置 + 安裝狀態產生計畫、執行下載
- **安裝檢查機制**：ModelManager 改用 `installed.json` 清單（role→變體/檔名/版本），`refreshInstallStates` 檢查「清單有紀錄且檔案存在」；下載走 `.part`+原子 rename 熱替換、可選 sha256、tokenizer 另檔
- **首次啟動引導** [onboarding_screen.dart](lib/features/onboarding/onboarding_screen.dart)：偵測硬體→顯示推薦模型→下載(進度)或略過；`prefs.firstRunHandled` + 核心模型未安裝才進引導（router 動態 initialLocation）
- 設定的模型管理頁改用 catalog/provisioner（顯示裝置摘要 + 各 role 推薦變體）
- 第一版訓練完成：**驗證準確率 98.4%、F1 0.983**（distilbert-multilingual，HC3 英+中，1 epoch）
- 測試新增 catalog 選型 + manifest 安裝檢查，共 **44 項全過**，analyze 零問題

**為什麼**
- 使用者提議用開源模型並要求「首次啟動連結最新、適用本地硬體的模型 + 安裝檢查」。開源預訓練模型品質高於臨時訓練，且免等待

**決策與取捨**
- catalog 以「品質優先排序 + RAM 門檻」選型；無可下載變體時回退顯示「即將推出」
- 安裝判定改 manifest（知道裝了哪個變體/版本），比純檔案存在更可靠、支援多變體與更新
- 遠端 catalog 讓「最新模型」可不改 App 即更新（GitHub raw / CDN）
- roberta-large 英文為主且 710MB；多語言輕量版（本專案訓練，待上傳）補中文與低階裝置

**待辦/遺留問題**
- 多語言輕量版與 LLM 尚未上傳 host（catalog url 待填）；填入即可下載
- 下載後的實際推論仍需各平台 ONNX Runtime 原生 plugin（契約已定）
- roberta tokenizer 為 HF tokenizer.json，原生端需對應的 tokenizer 實作

---

## 2026-07-03 — [P4 打磨上架] 多語系測試 + 上架準備起步

**做了什麼**
- **多語系測試** [multilingual_test.dart](test/multilingual_test.dart)：斷句/統計涵蓋英/中/日/中英混合；端到端檢測涵蓋英/中/西；ESL 修正觸發與開關驗證。全過
- **上架準備**：macOS 顯示名稱設為 TruthLens（暫定）；撰寫 [docs/release_checklist.md](docs/release_checklist.md)——依 plan 第四階段的完整發佈檢查清單（功能完整度、四平台適配、商店資產、隱私權限、效能目標、簽章發佈），並標出阻塞上架的三個待拍板項（名稱/定價/HC3 商用授權）
- 全專案 **35 項測試全過**、analyze 零問題

**為什麼**
- 使用者指示續推 P3、P4。多語系測試對照 plan 的全球多語系定位；release checklist 讓上架所需事項一目了然

**決策與取捨**
- 上架準備先以「檢查清單 + 名稱佔位」落地，實體資產（圖示/截圖/簽章）待功能凍結與名稱拍板再做
- 效能基準（plan 第十節）待真模型 + LLM 整合後才有意義，暫列未量測

**待辦/遺留問題**
- iOS/Android/Windows 實機建置與適配未驗證
- 無障礙（螢幕閱讀器/高對比/字級）尚未系統性處理
- 整合測試（integration_test）未建

---

## 2026-07-03 — [P3 智慧報告] OCR 圖像文字辨識（macOS 原生實作）

**做了什麼**
- [ocr_service.dart](lib/core/services/ocr_service.dart)：OCR 橋接（`MethodChannel('com.truthlens/ocr')`，ping/recognize），不支援的平台優雅回退
- **macOS 原生實作** [OcrPlugin.swift](macos/Runner/OcrPlugin.swift)：用 Apple Vision（`VNRecognizeTextRequest`，on-device、無需下載模型、支援中英多語），註冊於 MainFlutterWindow；手動把 Swift 檔加入 Xcode 專案 4 處引用（pbxproj）
- 首頁「圖片辨識」按鈕啟用：選圖 → OCR → 填入文字框（`ImagePicker` 用 file_picker 選圖）
- **實測驗證**：獨立 Swift 腳本畫「測試文字 Hello OCR 123」→ Vision 正確辨識中英混合；macOS build 綠燈

**為什麼**
- 使用者指示續推 P3。OCR 為 plan 模組 3，macOS 內建 Vision 可直接做出真正可用的功能，不必等模型

**決策與取捨**
- macOS 走 Vision 框架（非 ML Kit，ML Kit 僅行動端）——on-device、零依賴、即刻可用
- 其餘平台契約已定：iOS Vision、Android ML Kit、Windows Windows.Media.Ocr（原生端待補）
- 圖片來源用 file_picker 選檔（桌面適用）；行動端相機擷取待後續 image_picker

**待辦/遺留問題**
- iOS/Android/Windows 的 OCR 原生端未實作
- 行動端相機即時擷取、PDF 掃描檔 OCR 未做

---

## 2026-07-03 — [P3 智慧報告] 動態報告引擎（確定性回退 + LLM 接點）

**做了什麼**
- **報告文件模型** [report_document.dart](lib/features/report/report_document.dart)：`ReportDocument`（版面模板 id、headline、有序元件清單、生成來源 llm/template）+ 8 種 `ReportComponentType`
- **確定性報告生成器** [report_composer.dart](lib/features/report/report_composer.dart)：規則式選版面（ai_alert / mixed_detailed / human_clean / paraphrase_alert）+ 中文自然語言解讀（分佈、主要特徵、引擎理由、改寫警告、ESL 說明）。完全離線，即 plan 模組 2 的「確定性回退」
- **LLM 報告橋接** [report_llm_service.dart](lib/core/detection/report_llm_service.dart)：`MethodChannel('com.truthlens/report_llm')`，LLM 就緒時生成、逾時（30 秒）或原生不可用時**透明回退**至確定性生成器——確保任何裝置都能出報告
- **報告頁動態化**：改 StatefulWidget，依 `ReportDocument` 元件順序渲染，標示「AI 智慧生成 / 模板生成」徽章
- 測試：新增 `report_composer_test.dart`（7 項，版面選擇/警告元件/閾值文字）；共 **24 項全過**，analyze 零問題，macOS build 綠燈

**為什麼**
- 使用者指示繼續完成各階段。報告生成是 plan 標榜的最大差異化亮點，其確定性回退層可完全離線先行實作，同時備好 LLM 接點

**決策與取捨**
- 第一版 LLM 整合策略：LLM 只替換 headline/narrative 文字，版面骨架仍由確定性器決定（穩定、可控），日後再開放 LLM 完全主導版面
- 沿用檢測橋接同一套模式（MethodChannel + 優雅回退），架構一致

**待辦/遺留問題**
- PDF/CSV 匯出尚未納入 composer 的 narrative（目前自建版面，可後續統一）
- OCR 模組（plan 模組 3）尚未做——ML Kit 為行動端，桌面需另解，屬較大平台工程
- llama.cpp 原生端未實作（同檢測原生端，待模型與橋接）

---

## 2026-07-03 — [P2 AI引擎] 第一版檢測模型訓練管線（公開資料集）

**做了什麼**
- 建立 `training/` 子專案（獨立 Python 3.14 venv，PyTorch 2.12 + MPS、Transformers 5、ONNX Runtime 1.27）
- 完整訓練管線並**端到端驗證通過**：
  - [prepare_data.py](training/prepare_data.py)：以 `hf_hub_download` 抓 HC3 英文 + 中文 `all.jsonl`，拆 human_answers→0 / chatgpt_answers→1，輸出 train/val jsonl。實測 **12.1 萬筆**（訓練 10.9 萬 / 驗證 1.2 萬）
  - [train_classifier.py](training/train_classifier.py)：微調 xlm-roberta-base 二元分類，自動選 MPS/CUDA/CPU，回報 accuracy/precision/recall/F1
  - [export_onnx.py](training/export_onnx.py)：匯出 ONNX（傳統匯出器 dynamo=False）+ INT8 動態量化。實測 fp32 541MB → **int8 136MB**
  - [verify_onnx.py](training/verify_onnx.py)：ONNX Runtime 載入量化模型推論，兼作原生端前/後處理參考
  - [config.py](training/config.py)：超參數集中管理，`--quick` 煙霧模式
- **煙霧測試全綠**：400 筆/1 epoch/distilbert-multilingual → 訓練 26 秒（MPS）→ 匯出量化 → ONNX Runtime 推論成功
- **訓練調校**：xlm-roberta-base 實測 MPS 上 1.95s/step、2 epochs 需 ~7.4 小時，不切實際。第一版改 distilbert-multilingual + max_len 192 + batch 32 + 每類別上限 3 萬（順帶把 64/36 不平衡修正為 53/47）+ 1 epoch ≈ 55 分。production 換回 xlm-roberta-base 只需改 config 一行。正式訓練已啟動（8.4 萬筆，背景執行）
- registry 的 transformer 檔名改為 `detector_int8.onnx`（與模型無關的通用名，ONNX 四平台通用）；[training/README.md](training/README.md) 記載第一版 vs production 對照
- **JSON 匯出**（plan 第九節，LMS/系統整合）：`ReportExporter.buildJson` 輸出結構化結果（overall/engines/sentences/headline），報告頁匯出選單新增 JSON；PDF 也納入 composer 的 headline+解讀，匯出與畫面一致。匯出格式現達 PDF/CSV/JSON

**為什麼**
- 使用者選擇「先用公開資料集做第一版」。HC3 含英文與中文，契合多語系定位，可立即建立可運作基準

**決策與取捨**
- 部署格式選 **ONNX**（而非 plan 原訂的 per-platform TFLite/CoreML）：ONNX Runtime 單一格式跑四平台，第一版最省事；日後要極致效能再轉 CoreML/TFLite
- datasets v4 停用腳本式載入 → 改 `hf_hub_download` 直抓 jsonl
- transformers 5 移除 `use_mps_device`（改自動偵測）；ONNX 匯出走傳統 exporter（dynamo 圖量化會 shape inference 失敗）
- 基底模型可在 config 換成 distilbert-multilingual 快速迭代

**待辦/遺留問題**
- 正式訓練完成後：填 registry 的 URL + sha256（需上傳 GitHub Releases）、寫各平台 ONNX Runtime 原生 plugin
- **類別不平衡**：human 7.7 萬 vs ai 4.4 萬（約 64/36），第一版可接受，後續可加 class weight / 平衡取樣
- 統計 B（DistilGPT2 困惑度）、對抗 D（改寫文本）為獨立 pipeline，尚未建
- 資料多樣性：目前僅 ChatGPT 來源，應加入 Claude/Gemini/Llama 與 RAID 降低單一來源偏差

---

## 2026-07-03 — [P2 AI引擎] 檢測引擎基礎架構（模型管理 + 原生橋接）

**做了什麼**
- **模型登記表** [model_registry.dart](lib/core/detection/model_registry.dart)：四子模型 + LLM 的規格（分層 tier、後端 backend、檔名、大小、版本、URL/sha256 佔位），對應 plan 第五/八節
- **模型管理器** [model_manager.dart](lib/core/detection/model_manager.dart)（ChangeNotifier）：安裝狀態偵測、http 串流下載含進度、sha256 校驗、`.part` 暫存 + 原子 rename 熱替換、移除；目錄與 http client 可注入以供測試
- **原生推論橋接** [native_inference_service.dart](lib/core/detection/native_inference_service.dart)：Dart 端 `MethodChannel('com.truthlens/inference')`，契約 ping/loadModel/classify/perplexity/unload；原生端未實作時捕捉 `MissingPluginException` → 引擎優雅降級。契約文件見 [docs/native_inference_bridge.md](docs/native_inference_bridge.md)
- **引擎重構**：Transformer(A)、對抗(D) 改走 ModelManager + NativeInferenceService（未安裝→unavailable）；統計(B) 在 DistilGPT2 就緒時納入真困惑度、否則保留啟發式（恆可用）
- **信心閾值落地**：設定頁滑桿的閾值真正接進判定，DetectionResult 新增 `flaggedAsAi`（越過閾值才標記 AI，調高可降偽陽性）；報告頁顯示閾值判定 chip
- **模型管理 UI**：設定頁「AI 模型管理」從佔位改成可運作的 `ModelManagerScreen`（列出安裝狀態、下載進度、移除；未發佈者顯示「即將推出」）
- 測試：新增 `model_manager_test.dart`（6 項）、閾值測試；共 **17 項全過**，analyze 零問題，macOS build 成功

**為什麼**
- 使用者指示進入下一階段。真模型訓練受阻於未定的訓練數據來源（審核項目），故先把「放進真模型」所需的全部基礎架構做完做穩，使日後整合成為設定變更而非重寫

**決策與取捨**
- 選擇先建基礎架構（模型管理 + 原生橋接契約）而非直接訓練模型：訓練數據來源未拍板、且非本環境可自主完成
- 原生端（Kotlin/Swift/C++ 實際推論）暫不實作，僅定義 MethodChannel 契約並讓 Dart 端優雅降級——保持現有行為（引擎 unavailable）不變，同時零風險地備妥橋接
- 下載/校驗邏輯已完整可用，只差 `kModelRegistry` 填入真實 URL + sha256（模型發佈後）
- 統計引擎維持「恆可用 + 啟發式回退」，符合 plan 對低階裝置的保護原則

**待辦/遺留問題**
- **關鍵阻塞**：分類器 A/統計 B/對抗 D 的訓練數據來源與訓練流程（審核項目未回覆）
- 各平台原生 plugin 實作（TFLite/CoreML/ONNX/llama.cpp）+ 註冊
- ESL 偵測目前為簡化啟發式，正式版應改專用分類器
- 句子級評分尚未使用 Transformer 的逐句輸出（模型就緒後接上）

---

## 2026-07-03 — [P1 基礎建設] 文件匯入 + 報告匯出（PDF/CSV）

**做了什麼**
- **文件匯入**：`DocumentImporter`（file_picker），支援 txt/md/markdown，UTF-8 容錯解碼；首頁「匯入文件」按鈕啟用
- **報告匯出**：`ReportExporter` — CSV（UTF-8 BOM 讓 Excel 正確辨識中文；`#` 註解列放摘要 + 逐句資料表，含引號/逗號跳脫）與 PDF（pdf 套件，A4 多頁：整體判定、引擎明細、逐句表格附命中模式與分數配色）；報告頁新增匯出選單
- **CJK 字型**：下載 Noto Sans TC Regular/Bold TTF（各 ~6.8MB）進 `assets/fonts/`，PDF 內嵌，離線可用
- **macOS entitlements**：Debug/Release 皆加 `files.user-selected.read-write`（沙盒下存/選檔必需）
- 測試：新增 `report_exporter_test.dart`（CSV 結構/跳脫、PDF 魔術數字與字型內嵌），共 11 項全過；analyze 零問題

**為什麼**
- 使用者指示繼續 P1 剩餘項目

**決策與取捨**
- file_picker 11 起 `pickFiles`/`saveFile` 為靜態方法（非 `FilePicker.platform.*`），且提供 bytes 時桌面端也由 picker 直接寫檔
- PDF 走純 Dart `pdf` 套件而非 `printing`：少一層原生依賴，離線友善；日後要「列印」再評估 printing
- 匯入暫僅純文字格式；PDF 文字抽取/docx 解析延後（可與 P3 OCR 一起做）
- PDF 內避免用罕見符號（如 U+27F6），Noto Sans TC 無此字形

**待辦/遺留問題**
- 歷史紀錄尚未保存完整逐句結果（重新分析可還原，屬可接受妥協，待 P1 收尾評估）
- 匯出 JSON / PNG 摘要卡（plan 第九節）尚未做

---

## 2026-07-03 — [P1 基礎建設] 專案啟動

**做了什麼**
- 讀取使用者提供的整體設計架構文件，存入 `docs/implementation_plan.md` 作為專案正式規格
- 建立記憶與記錄體系：`CLAUDE.md`（專案文件，每次 session 自動載入）、本檔 `DEVLOG.md`（含記錄規則）、Claude 跨 session 記憶（MEMORY.md + memory 檔）
- 環境盤點：macOS（Darwin 27）、Xcode 與 Android Studio 已安裝；Flutter/Dart 原本未安裝，透過 Homebrew cask 安裝 Flutter 3.44.4（stable）
- `flutter create`（ios/android/macos/windows 四平台，package 名 `truthlens`，org `com.truthlens`），依規格建立目錄結構並實作第一版可運行骨架：
  - **檢測引擎**：`DetectionEngine` 介面 + 四子引擎。統計引擎（B）與風格引擎（C）已有可運作的啟發式實作（burstiness/TTR/entropy、過渡詞密度、句式重複）；Transformer（A）與對抗模組（D）為 stub，回報 unavailable
  - **協調器** `EnsembleOrchestrator`：加權投票（40/25/20/15），不可用引擎自動按比例重新分配權重；ESL 偏差修正（偵測到非母語風格時統計引擎權重減半，可在設定關閉）；句子級評分
  - **五大畫面**：輸入（貼上/OCR/匯入，後兩者為 P1/P3 待辦）、分析進度（四引擎即時狀態）、報告（儀表 + 引擎明細 + 逐句熱力高亮）、歷史（SQLite + 搜尋 + 重新分析）、設定（閾值滑桿/ESL 開關/主題）
  - **儲存**：sqflite（桌面走 FFI）+ shared_preferences
  - **主題**：Material 3 深色優先，Inter 字體，五級判定語意色
- 測試：`test/detection_test.dart` 8 項單元測試全過；`flutter analyze` 零問題
- 初始化 git repository（尚未 commit，待使用者指示）

**為什麼**
- 依使用者指示啟動專案建置，並確保後續每個 session 都有完整脈絡可接續

**決策與取捨**
- Flutter 安裝走 Homebrew cask（相對於官方 zip / git clone）：方便日後 `brew upgrade` 管理版本
- 設計文件複製進 repo 的 `docs/`（而非只留在 Downloads）：讓規格與程式碼一起版本控管

**待辦/遺留問題**
- implementation_plan.md「使用者審核項目」六題尚未獲使用者回覆：App 體積接受度、訓練數據來源、LLM 推論等待時間、定價策略、正式 App 名稱、團隊配置
- `flutter doctor`：Android toolchain 有警告（SDK 36.1.0，可能缺 licenses），iOS/macOS 正常
- P1 待補：文件匯入（file_picker）、報告匯出（PDF/CSV）、歷史紀錄保存完整逐句結果
- P2 起點：Transformer 分類器（A）與對抗模組（D）的模型訓練與原生橋接
