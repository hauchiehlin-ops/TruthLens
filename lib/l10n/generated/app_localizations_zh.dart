// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonClose => '關閉';

  @override
  String get verdictHuman => '人類撰寫';

  @override
  String get verdictLikelyHuman => '可能人類';

  @override
  String get verdictMixed => '混合內容';

  @override
  String get verdictLikelyAi => '可能 AI';

  @override
  String get verdictAi => 'AI 生成';

  @override
  String get inputSubtitle => '貼上或輸入文本，偵測 AI 生成內容';

  @override
  String get inputHint => '在此輸入或貼上要檢測的文字…';

  @override
  String get inputHistoryTooltip => '歷史紀錄';

  @override
  String get inputHelpTooltip => '操作說明';

  @override
  String get inputPrivacyTooltip => '隱私權政策';

  @override
  String get inputSettingsTooltip => '設定';

  @override
  String get inputPasteButton => '貼上';

  @override
  String get inputOcrButton => '圖片辨識';

  @override
  String get inputImportButton => '匯入文件';

  @override
  String get inputStartButton => '開始檢測';

  @override
  String get inputClearTooltip => '清除內容';

  @override
  String get inputTooShortSnackbar => '請輸入至少 40 個字元的文本以獲得可靠分析';

  @override
  String get inputOcrUnsupported => '此平台尚未支援 OCR 文字辨識';

  @override
  String get inputOcrRecognizing => '辨識中…';

  @override
  String get inputOcrNoText => '未從圖片中辨識到文字';

  @override
  String inputOcrRecognized(int count) {
    return '已辨識 $count 個字元';
  }

  @override
  String inputImportNoText(String fileName) {
    return '「$fileName」沒有可讀取的文字內容';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '已匯入「$fileName」（$count 字元）';
  }

  @override
  String inputActiveModel(String modelId) {
    return '模型：$modelId';
  }

  @override
  String get inputNoModel => '未安裝模型（僅統計/風格分析）';

  @override
  String inputCharCount(int count) {
    return '$count 字元';
  }

  @override
  String get analysisAppBarTitle => '分析中';

  @override
  String get analysisEngineTransformer => 'Transformer 分類器';

  @override
  String get analysisEngineStatistical => '統計特徵分析';

  @override
  String get analysisEngineStylometry => '風格特徵分析';

  @override
  String get analysisEngineAdversarial => '對抗式防禦';

  @override
  String analysisProgressSemantics(int done, int total) {
    return '分析進行中，已完成 $done / $total 個引擎';
  }

  @override
  String get analysisDoneSemantics => '已完成';

  @override
  String get engineNameAdversarialFull => '對抗式防禦（改寫偵測）';

  @override
  String get modelNecessityText =>
      '未下載神經網路偵測模型時，TruthLens 仍可運作，但僅使用統計與風格分析，準確度與多語言支援有限。下載模型後，多語言 Transformer 分類器會加入集成投票，大幅提升判定準確度與可靠度。模型在裝置端執行，下載後不會上傳任何內容。';

  @override
  String get modelPromptTitle => '建議下載偵測模型以獲得完整分析';

  @override
  String get modelPromptDontRemind => '不再提醒我';

  @override
  String get modelPromptSkip => '暫時略過';

  @override
  String get modelPromptDownload => '前往下載';

  @override
  String get onboardingWelcomeTitle => '歡迎使用 TruthLens';

  @override
  String get onboardingHeadline => '裝置端 AI 內容檢測';

  @override
  String get onboardingDetectedDevice => '偵測到的裝置';

  @override
  String get onboardingChooseModel => '選擇要下載的模型';

  @override
  String get onboardingRecommendHint => '已依你的硬體標示「推薦」；也可自行選擇其他選項。';

  @override
  String get onboardingSkipButton => '稍後再說（先用免模型的統計/風格分析）';

  @override
  String get onboardingSkipHint => '略過後仍可隨時到「設定 → AI 模型管理」下載；使用需要模型的分析時也會再次提醒。';

  @override
  String get modelListCustomImportedLabel => '自訂匯入的模型：';

  @override
  String get modelListActiveChip => '使用中';

  @override
  String get modelListRecommendedChip => '推薦';

  @override
  String get modelListCustomChip => '自訂';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · 需 ${ram}GB RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return '大小: $size · Tokenizer: $tokenizer · AI Label Index: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return '下載中… $percent%（$downloaded / $total）';
  }

  @override
  String modelListDownloadButton(String size) {
    return '下載（$size）';
  }

  @override
  String get modelListComingSoonChip => '即將推出';

  @override
  String get modelListSetActiveButton => '設為使用中';

  @override
  String get modelListUpdateButton => '更新';

  @override
  String get modelListDeleteTooltip => '刪除';

  @override
  String get modelListPageButton => '模型頁面';

  @override
  String get modelListMayExceedMemory => '可能超出裝置記憶體';

  @override
  String modelListFailedPrefix(String error) {
    return '失敗：$error';
  }

  @override
  String get modelListDeleteConfirmTitle => '刪除模型？';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return '將刪除「$name」（$size）。刪除後需重新下載才能再次使用。';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return '將刪除自訂匯入的「$name」（$size）。刪除後需重新匯入才能再次使用。';
  }

  @override
  String get modelImportAppBarTitle => '匯入自訂 ONNX 模型';

  @override
  String get modelImportStep1Title => '1. 選擇 ONNX 模型檔案';

  @override
  String modelImportSelectedFile(String name) {
    return '已選擇: $name';
  }

  @override
  String get modelImportNoFileSelected => '未選擇模型檔案 (.onnx)';

  @override
  String get modelImportBrowseButton => '瀏覽';

  @override
  String get modelImportCheckingDuplicate => '偵測是否已匯入過相同檔案…';

  @override
  String get modelImportDuplicateTitle => '偵測到相同內容的模型已匯入過';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return '此檔案與「$name」（角色：$role）內容完全相同。如果只是想切換使用中模型，可以到「AI 模型管理」直接設為使用中，不需要重新匯入。仍可繼續完成以下步驟。';
  }

  @override
  String get modelImportStep2Title => '2. 參數設定';

  @override
  String get modelImportNameLabel => '模型顯示名稱';

  @override
  String get modelImportNameRequired => '名稱不能為空';

  @override
  String get modelImportRoleLabel => '目標引擎角色';

  @override
  String get modelImportTokenizerTypeLabel => 'Tokenizer 類型';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => 'None (無 Tokenizer/逐字)';

  @override
  String get modelImportNoTokenizerSelected => '未選擇 Tokenizer 檔案 (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return '已選擇: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'AI 類別輸出索引 (AI Label Index)';

  @override
  String get modelImportIndex0 => 'Index 0 (例如 RoBERTa)';

  @override
  String get modelImportIndex1 => 'Index 1 (例如 DistilBERT)';

  @override
  String get modelImportStep3Title => '3. 測試與驗證';

  @override
  String get modelImportTestInputLabel => '測試輸入文本';

  @override
  String get modelImportRunTestButton => '執行測試推論';

  @override
  String get modelImportResultLabel => '推論結果 (AI 機率):';

  @override
  String modelImportTestFailed(String error) {
    return '測試失敗: $error';
  }

  @override
  String get modelImportConfirmButton => '確認匯入並啟用模型';

  @override
  String get modelImportSelectTokenizerFirst => '請先選擇 Tokenizer 檔案';

  @override
  String get modelImportSelectTokenizer => '請選擇 Tokenizer 檔案';

  @override
  String get modelImportSuccessSnackbar => '模型匯入成功！已自動啟用為使用中模型。';

  @override
  String get modelImportFailedSnackbar => '模型匯入失敗，請檢查權限或日誌';

  @override
  String get settingsAppBarTitle => '設定';

  @override
  String get settingsThresholdTitle => 'AI 判定信心閾值';

  @override
  String settingsThresholdSubtitle(int percent) {
    return '目前：$percent% — 調高可降低偽陽性（誤判人類文章為 AI）';
  }

  @override
  String get settingsEslTitle => 'ESL 非母語者偏差修正';

  @override
  String get settingsEslSubtitle => '偵測到非母語寫作風格時，自動降低統計模型權重';

  @override
  String get settingsEngineSectionTitle => '子偵測引擎啟用設定 (Ensemble)';

  @override
  String get settingsEngineTransformerTitle => '多語言 AI 分類器 (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      '使用 Transformer 神經網路模型進行端上 AI 機率預測';

  @override
  String get settingsEngineStatisticalTitle => '統計分析引擎 (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      '透過句長波動度、Burstiness 及 PPL 判定語言規律';

  @override
  String get settingsEngineStylometryTitle => '風格特徵分析 (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle => '分析語意流暢度、重複句式與過渡詞等寫作特徵';

  @override
  String get settingsEngineAdversarialTitle => '對抗式改寫偵測 (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle => '辨識是否經過機器改寫或去 AI 痕跡處理';

  @override
  String get settingsLinkVerificationTitle => '超連結與參考文獻目錄驗證';

  @override
  String get settingsLinkVerificationSubtitle =>
      '分析報告會對文件中偵測到的網址與參考文獻條目發出連線請求，確認是否真的存在（AI 生成內容常附上看似合理但實際不存在的引用連結或文獻）。DOI 格式的學術連結、以及沒有連結的「作者—年份」參考文獻，都會查詢 Crossref 公開登記資料比對。核心 AI 偵測模型仍完全在裝置端執行，不會傳送文件內容，連線僅用於此驗證與模型更新偵測，可在此關閉。';

  @override
  String get settingsThemeTitle => '外觀主題';

  @override
  String get settingsLanguageTitle => '語言';

  @override
  String get settingsLanguageSubtitle => '選擇應用程式顯示語言';

  @override
  String get settingsModelManagementTitle => 'AI 模型管理';

  @override
  String get settingsModelManagementSubtitle => '下載檢測模型與報告 LLM，啟用完整推論能力';

  @override
  String get settingsModelManagementUpdateSubtitle => '偵測到模型更新，建議前往查看';

  @override
  String get settingsOpenButton => '開啟';

  @override
  String get settingsCustomImportTitle => '自訂 ONNX 模型匯入與測試';

  @override
  String get settingsCustomImportSubtitle =>
      '匯入本機的自訂 ONNX 模型與 Tokenizer 設定並進行推論測試';

  @override
  String get settingsLanguagePackTitle => '語言包';

  @override
  String get settingsLanguagePackSubtitle => '額外語言微調模型（第四階段開放）';

  @override
  String get settingsModelManagerAppBarTitle => 'AI 模型管理';

  @override
  String get settingsImportTooltip => '匯入本機 ONNX 模型';

  @override
  String settingsDeviceLabel(String summary) {
    return '裝置：$summary';
  }

  @override
  String get historyAppBarTitle => '歷史紀錄';

  @override
  String get historyClearAllTooltip => '清空全部';

  @override
  String get historySearchHint => '搜尋歷史紀錄…';

  @override
  String get historyDeletedSnackbar => '已刪除該筆紀錄';

  @override
  String get historyClearAllTitle => '清空所有歷史紀錄？';

  @override
  String historyClearAllBody(int count) {
    return '將刪除全部 $count 筆紀錄，此動作無法復原。';
  }

  @override
  String get historyClearButton => '清空';

  @override
  String get historyDeleteEntryTitle => '刪除這筆紀錄？';

  @override
  String get historyReanalyzeTooltip => '重新分析';

  @override
  String get historyEmptyDefault => '尚無檢測紀錄';

  @override
  String historyEmptySearch(String query) {
    return '找不到符合「$query」的紀錄';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict，AI 機率 $percent%，$time。$text';
  }

  @override
  String get reportAppBarTitle => '檢測報告';

  @override
  String get reportExportTooltip => '匯出報告';

  @override
  String get reportHomeTooltip => '回首頁';

  @override
  String get reportGeneratingTitle => '正在生成報告…';

  @override
  String get reportSourceLlm => 'AI 智慧生成報告';

  @override
  String get reportSourceTemplate => '模板生成報告';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '共 $total 句 · 疑似 AI $ai 句 · 人類 $human 句 · 耗時 $seconds 秒';
  }

  @override
  String get reportExportPdf => '匯出 PDF 報告';

  @override
  String get reportExportCsv => '匯出 CSV 數據';

  @override
  String get reportExportJson => '匯出 JSON（系統整合）';

  @override
  String get reportExportPng => '匯出摘要卡（PNG）';

  @override
  String reportExported(String path) {
    return '已匯出：$path';
  }

  @override
  String reportExportFailed(String error) {
    return '匯出失敗：$error';
  }

  @override
  String get reportEngineBreakdownTitle => '引擎明細';

  @override
  String get reportEngineNotInstalled => '未安裝';

  @override
  String get reportSentenceAnalysisTitle => '逐句分析';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text。AI 機率 $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => '超連結真實性';

  @override
  String get reportLinkNoneDetected => '未在文件中偵測到超連結。';

  @override
  String get reportLinkCheckingProgress => '正在驗證連結…';

  @override
  String reportLinkDetectedPending(int count) {
    return '偵測到 $count 個超連結，尚未驗證是否存在';
  }

  @override
  String get reportLinkDisabledHint =>
      'AI 生成內容常附上看似合理但實際不存在的引用連結。你已在「設定」關閉超連結驗證；可重新開啟以自動驗證，或點擊下方按鈕做單次驗證。';

  @override
  String get reportVerifyNowButton => '立即驗證（需連線）';

  @override
  String get reportLinkReachable => '可連線，網址存在';

  @override
  String get reportLinkNotFound => '網址不存在（404），可能為虛構引用';

  @override
  String get reportLinkUnreachable => '無法確認（連線逾時或伺服器無回應）';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return '期刊目錄核實：已登記於$journal$title';
  }

  @override
  String get reportLinkCitationNotFound => '查無此 DOI 登記紀錄，可能為虛構引用';

  @override
  String get reportLinkCitationUnreachable => '無法確認（連線逾時或 Crossref 無回應）';

  @override
  String reportLinkTruncated(int max, int count) {
    return '僅驗證前 $max 個連結（共偵測到 $count 個）';
  }

  @override
  String get reportBibAuthenticityTitle => '文獻參考真實性';

  @override
  String get reportBibNoneDetected => '未在文件中偵測到參考文獻條目。';

  @override
  String get reportBibCheckingProgress => '正在核實參考文獻目錄…';

  @override
  String reportBibDetectedPending(int count) {
    return '偵測到參考文獻目錄（$count 筆），尚未核實是否存在';
  }

  @override
  String get reportBibDisabledHint =>
      'AI 生成內容常附上看似合理但實際不存在的參考文獻。你已在「設定」關閉超連結驗證；可重新開啟以自動核實，或點擊下方按鈕做單次核實。';

  @override
  String get reportVerifyNowBibButton => '立即核實（需連線）';

  @override
  String get reportBibResultHint =>
      '依作者、年份與篇名相似度比對 Crossref 公開登記資料，非絕對保證，「無法確定」時建議自行核對。';

  @override
  String reportBibHighConfidence(String journal) {
    return '高可信度：應存在$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（登記於《$journal》）';
  }

  @override
  String get reportBibNotFound => '查無相近匹配，可能為虛構文獻';

  @override
  String get reportBibUncertain => '相似度中等或連線失敗，無法確定，建議自行核對';

  @override
  String reportBibTruncated(int max, int count) {
    return '僅核實前 $max 筆（共偵測到 $count 筆）';
  }

  @override
  String get reportNetworkWarningTitle => '網路連線不佳';

  @override
  String get reportNetworkWarningBody =>
      '本 App 執行時預設為有網路連線的狀態；超連結真實性與文獻參考真實性分析都需要網路連線才能判斷結果。偵測到目前無法連線，請檢查網路狀態後重試。';

  @override
  String get reportRetryConnectionButton => '重新檢查連線';

  @override
  String get reportAiProbabilityLabel => 'AI 機率';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '共 $total 句\n疑似 AI $ai 句\n人類 $human 句';
  }

  @override
  String get summaryCardFooter => '核心 AI 推論皆在裝置端執行';

  @override
  String get exportReportTitle => 'TruthLens 檢測報告';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · 第 $page / $total 頁';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return '分析時間：$datetime · 耗時 $seconds 秒';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return '整體判定：$verdict';
  }

  @override
  String get pdfEslAppliedSuffix => '（已套用 ESL 修正）';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '共 $total 句 · 疑似 AI $ai 句 · 人類 $human 句';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return '為維持 PDF 可讀性，僅顯示前 $max 句（共 $count 句）；如需完整逐句資料，請改用「$csvLabel」或「$jsonLabel」。';
  }

  @override
  String get pdfSentenceColumnHeader => '句子（附命中模式）';

  @override
  String composerHeadlineAi(int percent) {
    return '這段文字極可能由 AI 生成（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return '這段文字傾向 AI 生成，建議進一步檢視（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return '這段文字呈現人類與 AI 混合的特徵（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return '這段文字傾向人類撰寫（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return '這段文字極可能為人類撰寫（AI 機率 $percent%）';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return '整體 AI 機率越過你設定的 $percent% 閾值，被標記為 AI。';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '整體 AI 機率未達 $percent% 標記閾值。';
  }

  @override
  String get composerNarrativeTitle => '分析解讀';

  @override
  String get composerParaphraseTitle => '偵測到改寫痕跡';

  @override
  String get composerParaphraseBody =>
      '本文可能經過改寫工具（如 QuillBot、Undetectable.ai）處理以規避偵測。此類文本即使逐句讀來自然，其整體統計特徵仍與原生人類寫作不同，請特別留意。';

  @override
  String get composerPatternListTitle => '主要 AI 寫作特徵';

  @override
  String get composerEslTitle => 'ESL 非母語者偏差修正';

  @override
  String get composerEslBody =>
      '偵測到本文可能出自非母語寫作者。非母語者常見的低困惑度與規律句式並非 AI 特徵，因此系統已降低統計模型的權重，以避免誤判。';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return '全文共 $total 句，其中 $ai 句呈現較強的 AI 特徵、$human 句偏向人類撰寫。';
  }

  @override
  String get composerNarrativeAiPattern =>
      '多數句子在句長節奏、用詞與過渡詞使用上高度規律，這是 AI 生成文本的常見指紋。';

  @override
  String get composerNarrativeMixedPattern =>
      '文中同時存在規律化與自然起伏的段落，顯示可能為人類初稿再經 AI 潤飾，或人機協作而成。';

  @override
  String get composerNarrativeHumanPattern =>
      '句長與用詞展現自然的變化與個人風格，未見明顯的 AI 規律化痕跡。';

  @override
  String engineReasonPplLow(String ppl) {
    return '語言模型困惑度偏低（$ppl），文本高度可預測，是 AI 生成的指標';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return '語言模型困惑度偏高（$ppl），符合人類寫作的不可預測性';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return '語言模型困惑度中等（$ppl）';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return '句子長度高度一致（burstiness $value），節奏均勻是 AI 生成文本的典型統計特徵';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return '句長起伏明顯（burstiness $value），符合人類自然寫作的節奏變化';
  }

  @override
  String engineReasonTtrLow(String value) {
    return '詞彙多樣性偏低（TTR $value），用詞重複度高';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return '詞彙多樣性高（TTR $value）';
  }

  @override
  String get engineReasonNeutral => '統計指標未呈現顯著傾向，維持中性判定';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return '高頻使用通用過渡詞（$words），每句平均 $density 次，人類寫作極少如此密集';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return '多個相鄰句子以相同詞語開頭（$count 處），句式重複';
  }

  @override
  String get engineReasonNoStyleMarkers => '未偵測到顯著的 AI 寫作風格模式';

  @override
  String get engineReasonAdversarialNotInstalled => '改寫偵測模型尚未安裝，未參與本次投票';

  @override
  String get engineReasonTransformerNotInstalled => '模型尚未安裝或使用中模型未支援，未參與本次投票';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return '模型載入失敗，未參與本次投票（$error）';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model 判定 $total 句中有 $aiCount 句呈現 AI 特徵';
  }

  @override
  String get engineReasonAdversarialDetected =>
      '對抗模型偵測到疑似經改寫工具（如 QuillBot / Undetectable.ai）洗過的 AI 特徵';

  @override
  String get engineReasonAdversarialClean => '未偵測到明顯的改寫規避特徵';

  @override
  String get engineReasonDisabledByUser => '使用者在設定中關閉此引擎';

  @override
  String get engineReasonGenericNotInstalled => '模型尚未安裝，未參與本次投票';

  @override
  String patternGenericTransition(String word) {
    return '通用過渡詞「$word」';
  }

  @override
  String get helpAppBarTitle => '操作說明';

  @override
  String get helpAboutTitle => '關於 TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens 是一款核心 AI 推論完全在裝置端執行的跨平台內容檢測應用程式（iOS / Android / macOS / Windows）。透過四個獨立子模型——Transformer 神經網路分類器、統計特徵分析、風格特徵分析、對抗式改寫偵測——加權投票判定文字是否為 AI 生成，並提供逐句、可解釋的分析理由：不是只給一個「像 AI」的百分比，而是說明「為什麼」。';

  @override
  String get helpComparisonTitle => '與市面主流工具比較';

  @override
  String get helpComparisonDisclaimer =>
      '以下比較依各工具官方公開資訊與一般市場認知整理，僅供功能定位參考，非第三方認證的效能實測數據。';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero 的運算主要在雲端進行、文件需上傳；TruthLens 四個偵測引擎皆在裝置端執行。';

  @override
  String get helpVsGptZero2 =>
      'GPTZero 首創的 Perplexity／Burstiness 指標與逐句高亮，TruthLens 已納入，並疊加 Transformer 分類器、風格特徵分析與對抗式防禦，形成四模型集成投票，而非單一指標判定。';

  @override
  String get helpVsGptZero3 => 'GPTZero 為訂閱制；TruthLens 無需訂閱、無使用次數限制。';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin 僅開放機構採購，個人無法直接購買；TruthLens 任何人皆可安裝使用。';

  @override
  String get helpVsTurnitin2 =>
      'Turnitin 的判定過程接近黑箱；TruthLens 提供逐句 AI 機率、命中的寫作模式，以及四引擎個別評分與理由明細。';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin 主要判斷二元「是否為 AI」；TruthLens 支援段落／句子級的人類／AI／混合標示。';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai 為按篇計費的訂閱制，且需將文件上傳雲端；TruthLens 核心運算在裝置端執行，無需持續付費使用偵測功能。';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai 有事實查核與可讀性分析概念；TruthLens 以本地端風格特徵模組呼應，且離線也能完成基礎分析。';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks 以雲端 API 為主，強項是低偽陽性率與多語系支援；TruthLens 採用同樣理念的 XLM-RoBERTa 多語言基底模型與多模型集成投票，但文件內容不會上傳至任何伺服器。';

  @override
  String get helpVsCopyleaks2 => 'Copyleaks 依方案而定有 API 用量限制；TruthLens 沒有用量限制。';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'Winston AI 的 OCR 圖片辨識需上傳圖片至雲端；TruthLens 使用各平台原生框架（iOS／macOS 的 Vision、Android 的 ML Kit、Windows 的 Windows.Media.Ocr）在裝置端完成辨識。';

  @override
  String get helpVsWinston2 =>
      'Winston AI 以報告排版精美著稱；TruthLens 提供 AI 動態生成排版報告（未安裝 LLM 時自動退回模板），可匯出 PDF／CSV／JSON／PNG 四種格式。';

  @override
  String get helpAdvantagesTitle => 'TruthLens 的獨有優勢';

  @override
  String get helpAdvantage1 =>
      '超連結真實性驗證：自動偵測文件中的網址是否可連線存在；DOI 格式的學術連結會進一步查詢 Crossref 公開登記資料，確認期刊目錄是否確實收錄這筆文獻。';

  @override
  String get helpAdvantage2 =>
      '文獻參考真實性核實：即使參考文獻沒有超連結（純作者—年份格式），也能透過書目比對抓出可能虛構的引用——這正是 AI 幻覺內容常見的破綻。';

  @override
  String get helpAdvantage3 =>
      'ESL（非母語寫作者）偏差修正：自動偵測非母語寫作特徵並降低統計模型權重，避免將非母語人士的自然寫作誤判為 AI。';

  @override
  String get helpAdvantage4 => '自訂模型匯入：進階使用者可自行匯入本機 ONNX 模型，取代或補充內建偵測引擎。';

  @override
  String get helpWorkflowTitle => '完整操作流程';

  @override
  String get helpWorkflowStep1Title => '模型下載與更新';

  @override
  String get helpWorkflowStep1Body =>
      '首次啟動會引導安裝核心偵測模型；之後可隨時至「設定 → AI 模型管理」查看、下載、更新或移除。App 會在啟動時主動比對最新版本，若有更新，設定齒輪圖示與「AI 模型管理」項目會出現紅點提示。';

  @override
  String get helpWorkflowStep2Title => '如何選用模型（目的與效果）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      '多語言 AI 分類器（權重 40%）：整體判定主力，句子級 AI 機率預測，對準確度提升最明顯。';

  @override
  String get helpWorkflowStep2Bullet2 =>
      '統計分析引擎（權重 25%）：困惑度與 Burstiness 滑動窗口分析，捕捉 AI 文本規律的節奏與用詞可預測性。';

  @override
  String get helpWorkflowStep2Bullet3 =>
      '風格特徵分析（權重 20%）：語意流暢度、重複句式、過渡詞使用，可解釋性最高，最容易看懂「為什麼」。';

  @override
  String get helpWorkflowStep2Bullet4 =>
      '對抗式防禦（權重 15%）：辨識是否經改寫工具（如 QuillBot、Undetectable.ai）洗過的文本。';

  @override
  String get helpWorkflowStep2Bullet5 =>
      '報告生成 LLM（選用）：安裝後報告文字由本地端 LLM 動態生成解說；未安裝時自動退回固定模板，分析功能不受影響。';

  @override
  String get helpWorkflowStep2Bullet6 =>
      '可在「設定」個別啟用／停用引擎、調整 AI 判定信心閾值（調高可降低誤判人類文章為 AI 的機率）。';

  @override
  String get helpWorkflowStep3Title => '文檔上傳';

  @override
  String get helpWorkflowStep3Body =>
      '三種輸入方式：直接貼上文字、圖片辨識（OCR，各平台原生框架離線辨識）、匯入文件（txt / md / pdf / docx / doc）。文字需達 40 字元以上才能送出分析。';

  @override
  String get helpWorkflowStep4Title => '開始分析';

  @override
  String get helpWorkflowStep4Body =>
      '點擊「開始檢測」，四個引擎並行執行，畫面即時顯示各引擎完成進度。若偵測到非母語寫作特徵，會自動套用 ESL 偏差修正（可在設定關閉）。';

  @override
  String get helpWorkflowStep5Title => '查看與匯出結果';

  @override
  String get helpWorkflowStep5Body =>
      '報告頁包含：整體 AI 機率環狀圖、逐句熱力圖、四引擎明細評分與理由、超連結真實性、文獻參考真實性。可匯出 PDF 完整報告、CSV 逐句數據、JSON（供系統整合）、PNG 摘要卡（社群分享用）。每次分析結果自動保存於「歷史紀錄」，可隨時回顧。';

  @override
  String get helpTuningTitle => '模型下載與調適教學（零基礎）';

  @override
  String get helpTuningStep1Title => '開啟模型管理畫面';

  @override
  String get helpTuningStep1Body => '從首頁點齒輪圖示進入「設定」，再點「AI 模型管理」旁的「開啟」。';

  @override
  String get helpTuningStep2Title => '依裝置能力挑選模型';

  @override
  String get helpTuningStep2Body =>
      '畫面會依你的裝置效能（RAM、處理器核心數）自動建議合適的模型層級，並列出每個角色（多語言分類器／統計分析／對抗式防禦／報告 LLM）的所有可用變體。';

  @override
  String get helpTuningStep3Title => '下載與套用';

  @override
  String get helpTuningStep3Body =>
      '點選想要的模型旁的「下載」，等待進度完成——下載完成的第一個模型會自動設為使用中。若已有多個變體，可點「設為使用中」隨時切換；點垃圾桶圖示可移除不需要的模型以釋放空間。';

  @override
  String get helpTuningStep4Title => '更新模型';

  @override
  String get helpTuningStep4Body =>
      '之後若有新版本，「AI 模型管理」與設定齒輪圖示會出現紅點提示，回到此畫面即可看到新版本並下載更新（會保留原本安裝的版本，除非手動移除）。';

  @override
  String get helpTuningStep5Title => '進階：匯入自訂模型';

  @override
  String get helpTuningStep5Body =>
      '若你已在其他地方取得或自行微調過相容的 .onnx 模型，可透過「設定 → 自訂 ONNX 模型匯入與測試」匯入——需提供模型檔、對應的 Tokenizer 設定（或選擇「不需要」）與 AI 類別索引；匯入前會自動偵測是否為重複匯入的相同檔案，避免不小心重複安裝。';

  @override
  String get helpOfficialLinksTitle => '官方模型下載連結';

  @override
  String get helpOfficialLinksHint => '點擊項目會以系統瀏覽器開啟該模型的官方頁面。';

  @override
  String get helpLinkRoleTransformer => '多語言 AI 分類器（Transformer，權重 40%）';

  @override
  String get helpLinkRoleStatistical => '困惑度統計模型（Statistical，權重 25%）';

  @override
  String get helpLinkRoleAdversarial => '對抗式改寫偵測模型（Adversarial，權重 15%）';

  @override
  String get helpLinkRoleLlm => '報告生成 LLM（選用）';

  @override
  String get privacyAppBarTitle => '隱私權政策';

  @override
  String privacyPlatformTitle(String platform) {
    return '$platform版隱私權政策';
  }

  @override
  String privacyLastUpdated(String date) {
    return '最後更新：$date';
  }

  @override
  String get privacyIosOverview1 =>
      'TruthLens 不收集任何與您的身分連結的資料，也不將任何資料用於追蹤，因此不需要 App 追蹤透明度（ATT）權限。';

  @override
  String get privacyIosOverview2 =>
      '本 App 使用系統提供的檔案選擇器存取您主動選擇的文件或圖片；未經您選擇的檔案，App 無法存取（iOS App Sandbox 限制）。';

  @override
  String get privacyAndroidOverview1 => 'TruthLens 不收集個人資料，也不與任何第三方分享使用者資料。';

  @override
  String get privacyAndroidOverview2 =>
      '本 App 僅在您主動選擇匯入文件或圖片時存取對應的儲存權限，不會背景掃描或存取其他檔案。';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens 在 macOS App Sandbox 下執行，僅能存取您透過系統檔案對話框主動選擇的檔案（files.user-selected.read-write），無法自行瀏覽或存取其他檔案或資料夾。';

  @override
  String get privacyMacosOverview2 =>
      '網路存取權限（network.client）僅用於下方「必要的連線行為」所列的功能。';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens 為單機桌面應用程式，資料儲存於您本機使用者資料夾內（如 AppData／Documents），不會同步至雲端。';

  @override
  String get privacyWindowsOverview2 =>
      '本 App 僅在您主動選擇匯入文件或圖片時存取對應檔案，不會背景掃描其他檔案。';

  @override
  String get privacyDataHandling1 =>
      'TruthLens 沒有使用者帳號、不需登入，也沒有任何形式的廣告或第三方追蹤 SDK。';

  @override
  String get privacyDataHandling2 =>
      '您輸入、貼上或匯入的文件內容，皆在您的裝置上由本機 AI 模型完成分析，不會上傳到 TruthLens 或任何第三方伺服器。';

  @override
  String get privacyDataHandling3 =>
      '分析結果與歷史紀錄僅儲存在您裝置本機的資料庫中；解除安裝 App 或清除歷史紀錄即會一併移除，TruthLens 不持有任何副本。';

  @override
  String get privacyNetworkIntro => '本 App 的核心 AI 偵測完全在裝置端執行，但下列三項功能需要連線：';

  @override
  String get privacyNetwork1 =>
      '1. 模型目錄與下載：連至 GitHub Releases／Hugging Face 下載您選擇的偵測模型檔案，僅為下載模型，不會上傳任何使用者資料。';

  @override
  String get privacyNetwork2 => '2. 模型更新偵測：App 啟動時會連線比對版本號，僅傳送版本資訊，用於提示是否有新版本。';

  @override
  String get privacyNetwork3 =>
      '3. 超連結與參考文獻真實性驗證：預設開啟，可在「設定」關閉。開啟時，會將文件中偵測到的網址或參考文獻文字，直接送往該網址本身或 Crossref 公開 API 查詢，僅傳送網址／DOI／書目文字本身，不含文件中的其他內容。';

  @override
  String get privacyRightsIntro => '您可隨時於「歷史紀錄」清除本機分析紀錄，或於「設定」關閉超連結／文獻驗證功能，或直接';

  @override
  String get privacyRemoveIos => '刪除 App';

  @override
  String get privacyRemoveAndroid => '解除安裝 App';

  @override
  String get privacyRemoveMacos => '將 App 移到垃圾桶';

  @override
  String get privacyRemoveWindows => '解除安裝 App';

  @override
  String get privacyDisclaimer =>
      '本頁內容為 TruthLens 依實際功能行為撰寫的隱私權說明，非律師審閱之正式法律文件；如需與您所在地區的法規進行正式合規審查，建議另行諮詢專業法律意見。';

  @override
  String get privacySectionOverviewIos => '概要（對應 App Store 隱私權「營養標籤」）';

  @override
  String get privacySectionOverviewAndroid => '概要（對應 Google Play「資料安全」揭露）';

  @override
  String get privacySectionOverviewMacos => '概要（App Sandbox 權限說明）';

  @override
  String get privacySectionOverviewWindows => '概要';

  @override
  String get privacySectionDataHandling => '我們如何處理您的資料';

  @override
  String get privacySectionNetwork => '必要的連線行為';

  @override
  String get privacySectionRights => '您的權利';

  @override
  String get privacyGenericPlatformName => '本平台';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '删除';

  @override
  String get commonClose => '关闭';

  @override
  String get verdictHuman => '人类撰写';

  @override
  String get verdictLikelyHuman => '可能人类';

  @override
  String get verdictMixed => '混合内容';

  @override
  String get verdictLikelyAi => '可能 AI';

  @override
  String get verdictAi => 'AI 生成';

  @override
  String get inputSubtitle => '粘贴或输入文本，侦测 AI 生成内容';

  @override
  String get inputHint => '在此输入或粘贴要检测的文本…';

  @override
  String get inputHistoryTooltip => '历史纪录';

  @override
  String get inputHelpTooltip => '操作说明';

  @override
  String get inputPrivacyTooltip => '隐私权政策';

  @override
  String get inputSettingsTooltip => '设置';

  @override
  String get inputPasteButton => '粘贴';

  @override
  String get inputOcrButton => '图片辨识';

  @override
  String get inputImportButton => '导入文档';

  @override
  String get inputStartButton => '开始检测';

  @override
  String get inputClearTooltip => '清除内容';

  @override
  String get inputTooShortSnackbar => '请输入至少 40 个字符的文本以获得可靠分析';

  @override
  String get inputOcrUnsupported => '此平台尚未支持 OCR 文本辨识';

  @override
  String get inputOcrRecognizing => '辨识中…';

  @override
  String get inputOcrNoText => '未从图片中辨识到文本';

  @override
  String inputOcrRecognized(int count) {
    return '已辨识 $count 个字符';
  }

  @override
  String inputImportNoText(String fileName) {
    return '「$fileName」没有可读取的文本内容';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '已导入「$fileName」（$count 字符）';
  }

  @override
  String inputActiveModel(String modelId) {
    return '模型：$modelId';
  }

  @override
  String get inputNoModel => '未安装模型（仅统计/风格分析）';

  @override
  String inputCharCount(int count) {
    return '$count 字符';
  }

  @override
  String get analysisAppBarTitle => '分析中';

  @override
  String get analysisEngineTransformer => 'Transformer 分类器';

  @override
  String get analysisEngineStatistical => '统计特征分析';

  @override
  String get analysisEngineStylometry => '风格特征分析';

  @override
  String get analysisEngineAdversarial => '对抗式防御';

  @override
  String analysisProgressSemantics(int done, int total) {
    return '分析进行中，已完成 $done / $total 个引擎';
  }

  @override
  String get analysisDoneSemantics => '已完成';

  @override
  String get engineNameAdversarialFull => '对抗式防御（改写侦测）';

  @override
  String get modelNecessityText =>
      '未下载神经网络侦测模型时，TruthLens 仍可运作，但仅使用统计与风格分析，准确度与多语言支持有限。下载模型后，多语言 Transformer 分类器会加入集成投票，大幅提升判定准确度与可靠度。模型在设备端运行，下载后不会上传任何内容。';

  @override
  String get modelPromptTitle => '建议下载侦测模型以获得完整分析';

  @override
  String get modelPromptDontRemind => '不再提醒我';

  @override
  String get modelPromptSkip => '暂时略过';

  @override
  String get modelPromptDownload => '前往下载';

  @override
  String get onboardingWelcomeTitle => '欢迎使用 TruthLens';

  @override
  String get onboardingHeadline => '设备端 AI 内容检测';

  @override
  String get onboardingDetectedDevice => '侦测到的设备';

  @override
  String get onboardingChooseModel => '选择要下载的模型';

  @override
  String get onboardingRecommendHint => '已依你的硬件标示「推荐」；也可自行选择其他选项。';

  @override
  String get onboardingSkipButton => '稍后再说（先用免模型的统计/风格分析）';

  @override
  String get onboardingSkipHint => '略过后仍可随时到「设置 → AI 模型管理」下载；使用需要模型的分析时也会再次提醒。';

  @override
  String get modelListCustomImportedLabel => '自订导入的模型：';

  @override
  String get modelListActiveChip => '使用中';

  @override
  String get modelListRecommendedChip => '推荐';

  @override
  String get modelListCustomChip => '自订';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · 需 ${ram}GB RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return '大小: $size · Tokenizer: $tokenizer · AI Label Index: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return '下载中… $percent%（$downloaded / $total）';
  }

  @override
  String modelListDownloadButton(String size) {
    return '下载（$size）';
  }

  @override
  String get modelListComingSoonChip => '即将推出';

  @override
  String get modelListSetActiveButton => '设为使用中';

  @override
  String get modelListUpdateButton => '更新';

  @override
  String get modelListDeleteTooltip => '删除';

  @override
  String get modelListPageButton => '模型页面';

  @override
  String get modelListMayExceedMemory => '可能超出设备内存';

  @override
  String modelListFailedPrefix(String error) {
    return '失败：$error';
  }

  @override
  String get modelListDeleteConfirmTitle => '删除模型？';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return '将删除「$name」（$size）。删除后需重新下载才能再次使用。';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return '将删除自订导入的「$name」（$size）。删除后需重新导入才能再次使用。';
  }

  @override
  String get modelImportAppBarTitle => '导入自订 ONNX 模型';

  @override
  String get modelImportStep1Title => '1. 选择 ONNX 模型文件';

  @override
  String modelImportSelectedFile(String name) {
    return '已选择: $name';
  }

  @override
  String get modelImportNoFileSelected => '未选择模型文件 (.onnx)';

  @override
  String get modelImportBrowseButton => '浏览';

  @override
  String get modelImportCheckingDuplicate => '侦测是否已导入过相同文件…';

  @override
  String get modelImportDuplicateTitle => '侦测到相同内容的模型已导入过';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return '此文件与「$name」（角色：$role）内容完全相同。如果只是想切换使用中模型，可以到「AI 模型管理」直接设为使用中，不需要重新导入。仍可继续完成以下步骤。';
  }

  @override
  String get modelImportStep2Title => '2. 参数设置';

  @override
  String get modelImportNameLabel => '模型显示名称';

  @override
  String get modelImportNameRequired => '名称不能为空';

  @override
  String get modelImportRoleLabel => '目标引擎角色';

  @override
  String get modelImportTokenizerTypeLabel => 'Tokenizer 类型';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => 'None (无 Tokenizer/逐字)';

  @override
  String get modelImportNoTokenizerSelected => '未选择 Tokenizer 文件 (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return '已选择: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'AI 类别输出索引 (AI Label Index)';

  @override
  String get modelImportIndex0 => 'Index 0 (例如 RoBERTa)';

  @override
  String get modelImportIndex1 => 'Index 1 (例如 DistilBERT)';

  @override
  String get modelImportStep3Title => '3. 测试与验证';

  @override
  String get modelImportTestInputLabel => '测试输入文本';

  @override
  String get modelImportRunTestButton => '运行测试推论';

  @override
  String get modelImportResultLabel => '推论结果 (AI 几率):';

  @override
  String modelImportTestFailed(String error) {
    return '测试失败: $error';
  }

  @override
  String get modelImportConfirmButton => '确认导入并激活模型';

  @override
  String get modelImportSelectTokenizerFirst => '请先选择 Tokenizer 文件';

  @override
  String get modelImportSelectTokenizer => '请选择 Tokenizer 文件';

  @override
  String get modelImportSuccessSnackbar => '模型导入成功！已自动激活为使用中模型。';

  @override
  String get modelImportFailedSnackbar => '模型导入失败，请检查权限或日志';

  @override
  String get settingsAppBarTitle => '设置';

  @override
  String get settingsThresholdTitle => 'AI 判定信心阈值';

  @override
  String settingsThresholdSubtitle(int percent) {
    return '目前：$percent% — 调高可降低伪阳性（误判人类文章为 AI）';
  }

  @override
  String get settingsEslTitle => 'ESL 非母语者偏差修正';

  @override
  String get settingsEslSubtitle => '侦测到非母语写作风格时，自动降低统计模型权重';

  @override
  String get settingsEngineSectionTitle => '子侦测引擎激活设置 (Ensemble)';

  @override
  String get settingsEngineTransformerTitle => '多语言 AI 分类器 (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      '使用 Transformer 神经网络模型进行端上 AI 几率预测';

  @override
  String get settingsEngineStatisticalTitle => '统计分析引擎 (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      '通过句长波动度、Burstiness 及 PPL 判定语言规律';

  @override
  String get settingsEngineStylometryTitle => '风格特征分析 (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle => '分析语意流畅度、重复句式与过渡词等写作特征';

  @override
  String get settingsEngineAdversarialTitle => '对抗式改写侦测 (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle => '辨识是否经过机器改写或去 AI 痕迹处理';

  @override
  String get settingsLinkVerificationTitle => '超链接与参考文献目录验证';

  @override
  String get settingsLinkVerificationSubtitle =>
      '分析报告会对文档中侦测到的网址与参考文献条目发出连接请求，确认是否真的存在（AI 生成内容常附上看似合理但实际不存在的引用链接或文献）。DOI 格式的学术链接、以及没有链接的「作者—年份」参考文献，都会查找 Crossref 公开登记数据比对。内核 AI 侦测模型仍完全在设备端运行，不会发送文档内容，连接仅用于此验证与模型更新侦测，可在此关闭。';

  @override
  String get settingsThemeTitle => '外观主题';

  @override
  String get settingsLanguageTitle => '语言';

  @override
  String get settingsLanguageSubtitle => '选择应用程序显示语言';

  @override
  String get settingsModelManagementTitle => 'AI 模型管理';

  @override
  String get settingsModelManagementSubtitle => '下载检测模型与报告 LLM，激活完整推论能力';

  @override
  String get settingsModelManagementUpdateSubtitle => '侦测到模型更新，建议前往查看';

  @override
  String get settingsOpenButton => '打开';

  @override
  String get settingsCustomImportTitle => '自订 ONNX 模型导入与测试';

  @override
  String get settingsCustomImportSubtitle =>
      '导入本机的自订 ONNX 模型与 Tokenizer 设置并进行推论测试';

  @override
  String get settingsLanguagePackTitle => '语言包';

  @override
  String get settingsLanguagePackSubtitle => '额外语言微调模型（第四阶段开放）';

  @override
  String get settingsModelManagerAppBarTitle => 'AI 模型管理';

  @override
  String get settingsImportTooltip => '导入本机 ONNX 模型';

  @override
  String settingsDeviceLabel(String summary) {
    return '设备：$summary';
  }

  @override
  String get historyAppBarTitle => '历史纪录';

  @override
  String get historyClearAllTooltip => '清空全部';

  @override
  String get historySearchHint => '搜索历史纪录…';

  @override
  String get historyDeletedSnackbar => '已删除该笔纪录';

  @override
  String get historyClearAllTitle => '清空所有历史纪录？';

  @override
  String historyClearAllBody(int count) {
    return '将删除全部 $count 笔纪录，此动作无法复原。';
  }

  @override
  String get historyClearButton => '清空';

  @override
  String get historyDeleteEntryTitle => '删除这笔纪录？';

  @override
  String get historyReanalyzeTooltip => '重新分析';

  @override
  String get historyEmptyDefault => '尚无检测纪录';

  @override
  String historyEmptySearch(String query) {
    return '找不到符合「$query」的纪录';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict，AI 几率 $percent%，$time。$text';
  }

  @override
  String get reportAppBarTitle => '检测报告';

  @override
  String get reportExportTooltip => '导出报告';

  @override
  String get reportHomeTooltip => '回首页';

  @override
  String get reportGeneratingTitle => '正在生成报告…';

  @override
  String get reportSourceLlm => 'AI 智能生成报告';

  @override
  String get reportSourceTemplate => '模板生成报告';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '共 $total 句 · 疑似 AI $ai 句 · 人类 $human 句 · 耗时 $seconds 秒';
  }

  @override
  String get reportExportPdf => '导出 PDF 报告';

  @override
  String get reportExportCsv => '导出 CSV 数据';

  @override
  String get reportExportJson => '导出 JSON（系统集成）';

  @override
  String get reportExportPng => '导出摘要卡（PNG）';

  @override
  String reportExported(String path) {
    return '已导出：$path';
  }

  @override
  String reportExportFailed(String error) {
    return '导出失败：$error';
  }

  @override
  String get reportEngineBreakdownTitle => '引擎明细';

  @override
  String get reportEngineNotInstalled => '未安装';

  @override
  String get reportSentenceAnalysisTitle => '逐句分析';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text。AI 几率 $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => '超链接真实性';

  @override
  String get reportLinkNoneDetected => '未在文档中侦测到超链接。';

  @override
  String get reportLinkCheckingProgress => '正在验证链接…';

  @override
  String reportLinkDetectedPending(int count) {
    return '侦测到 $count 个超链接，尚未验证是否存在';
  }

  @override
  String get reportLinkDisabledHint =>
      'AI 生成内容常附上看似合理但实际不存在的引用链接。你已在「设置」关闭超链接验证；可重新打开以自动验证，或点击下方按钮做单次验证。';

  @override
  String get reportVerifyNowButton => '立即验证（需连接）';

  @override
  String get reportLinkReachable => '可连接，网址存在';

  @override
  String get reportLinkNotFound => '网址不存在（404），可能为虚构引用';

  @override
  String get reportLinkUnreachable => '无法确认（连接逾时或服务器无回应）';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return '期刊目录核实：已登记于$journal$title';
  }

  @override
  String get reportLinkCitationNotFound => '查无此 DOI 登记纪录，可能为虚构引用';

  @override
  String get reportLinkCitationUnreachable => '无法确认（连接逾时或 Crossref 无回应）';

  @override
  String reportLinkTruncated(int max, int count) {
    return '仅验证前 $max 个链接（共侦测到 $count 个）';
  }

  @override
  String get reportBibAuthenticityTitle => '文献参考真实性';

  @override
  String get reportBibNoneDetected => '未在文档中侦测到参考文献条目。';

  @override
  String get reportBibCheckingProgress => '正在核实参考文献目录…';

  @override
  String reportBibDetectedPending(int count) {
    return '侦测到参考文献目录（$count 笔），尚未核实是否存在';
  }

  @override
  String get reportBibDisabledHint =>
      'AI 生成内容常附上看似合理但实际不存在的参考文献。你已在「设置」关闭超链接验证；可重新打开以自动核实，或点击下方按钮做单次核实。';

  @override
  String get reportVerifyNowBibButton => '立即核实（需连接）';

  @override
  String get reportBibResultHint =>
      '依作者、年份与篇名相似度比对 Crossref 公开登记数据，非绝对保证，「无法确定」时建议自行核对。';

  @override
  String reportBibHighConfidence(String journal) {
    return '高可信度：应存在$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（登记于《$journal》）';
  }

  @override
  String get reportBibNotFound => '查无相近匹配，可能为虚构文献';

  @override
  String get reportBibUncertain => '相似度中等或连接失败，无法确定，建议自行核对';

  @override
  String reportBibTruncated(int max, int count) {
    return '仅核实前 $max 笔（共侦测到 $count 笔）';
  }

  @override
  String get reportNetworkWarningTitle => '网络连接不佳';

  @override
  String get reportNetworkWarningBody =>
      '本 App 运行时缺省为有网络连接的状态；超链接真实性与文献参考真实性分析都需要网络连接才能判断结果。侦测到目前无法连接，请检查网络状态后重试。';

  @override
  String get reportRetryConnectionButton => '重新检查连接';

  @override
  String get reportAiProbabilityLabel => 'AI 几率';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '共 $total 句\n疑似 AI $ai 句\n人类 $human 句';
  }

  @override
  String get summaryCardFooter => '内核 AI 推论皆在设备端运行';

  @override
  String get exportReportTitle => 'TruthLens 检测报告';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · 第 $page / $total 页';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return '分析时间：$datetime · 耗时 $seconds 秒';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return '整体判定：$verdict';
  }

  @override
  String get pdfEslAppliedSuffix => '（已套用 ESL 修正）';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '共 $total 句 · 疑似 AI $ai 句 · 人类 $human 句';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return '为维持 PDF 可读性，仅显示前 $max 句（共 $count 句）；如需完整逐句数据，请改用「$csvLabel」或「$jsonLabel」。';
  }

  @override
  String get pdfSentenceColumnHeader => '句子（附命中模式）';

  @override
  String composerHeadlineAi(int percent) {
    return '这段文本极可能由 AI 生成（AI 几率 $percent%）';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return '这段文本倾向 AI 生成，建议进一步查看（AI 几率 $percent%）';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return '这段文本呈现人类与 AI 混合的特征（AI 几率 $percent%）';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return '这段文本倾向人类撰写（AI 几率 $percent%）';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return '这段文本极可能为人类撰写（AI 几率 $percent%）';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return '整体 AI 几率越过你设置的 $percent% 阈值，被标记为 AI。';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '整体 AI 几率未达 $percent% 标记阈值。';
  }

  @override
  String get composerNarrativeTitle => '分析解读';

  @override
  String get composerParaphraseTitle => '侦测到改写痕迹';

  @override
  String get composerParaphraseBody =>
      '本文可能经过改写工具（如 QuillBot、Undetectable.ai）处理以规避侦测。此类文本即使逐句读来自然，其整体统计特征仍与原生人类写作不同，请特别留意。';

  @override
  String get composerPatternListTitle => '主要 AI 写作特征';

  @override
  String get composerEslTitle => 'ESL 非母语者偏差修正';

  @override
  String get composerEslBody =>
      '侦测到本文可能出自非母语写作者。非母语者常见的低困惑度与规律句式并非 AI 特征，因此系统已降低统计模型的权重，以避免误判。';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return '全文共 $total 句，其中 $ai 句呈现较强的 AI 特征、$human 句偏向人类撰写。';
  }

  @override
  String get composerNarrativeAiPattern =>
      '多数句子在句长节奏、用词与过渡词使用上高度规律，这是 AI 生成文本的常见指纹。';

  @override
  String get composerNarrativeMixedPattern =>
      '文中同时存在规律化与自然起伏的段落，显示可能为人类初稿再经 AI 润饰，或人机协作而成。';

  @override
  String get composerNarrativeHumanPattern =>
      '句长与用词展现自然的变化与个人风格，未见明显的 AI 规律化痕迹。';

  @override
  String engineReasonPplLow(String ppl) {
    return '语言模型困惑度偏低（$ppl），文本高度可预测，是 AI 生成的指针';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return '语言模型困惑度偏高（$ppl），符合人类写作的不可预测性';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return '语言模型困惑度中等（$ppl）';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return '句子长度高度一致（burstiness $value），节奏均匀是 AI 生成文本的典型统计特征';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return '句长起伏明显（burstiness $value），符合人类自然写作的节奏变化';
  }

  @override
  String engineReasonTtrLow(String value) {
    return '词汇多样性偏低（TTR $value），用词重复度高';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return '词汇多样性高（TTR $value）';
  }

  @override
  String get engineReasonNeutral => '统计指针未呈现显著倾向，维持中性判定';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return '高频使用通用过渡词（$words），每句平均 $density 次，人类写作极少如此密集';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return '多个相邻句子以相同词语开头（$count 处），句式重复';
  }

  @override
  String get engineReasonNoStyleMarkers => '未侦测到显著的 AI 写作风格模式';

  @override
  String get engineReasonAdversarialNotInstalled => '改写侦测模型尚未安装，未参与本次投票';

  @override
  String get engineReasonTransformerNotInstalled => '模型尚未安装或使用中模型未支持，未参与本次投票';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return '模型加载失败，未参与本次投票（$error）';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model 判定 $total 句中有 $aiCount 句呈现 AI 特征';
  }

  @override
  String get engineReasonAdversarialDetected =>
      '对抗模型侦测到疑似经改写工具（如 QuillBot / Undetectable.ai）洗过的 AI 特征';

  @override
  String get engineReasonAdversarialClean => '未侦测到明显的改写规避特征';

  @override
  String get engineReasonDisabledByUser => '用户在设置中关闭此引擎';

  @override
  String get engineReasonGenericNotInstalled => '模型尚未安装，未参与本次投票';

  @override
  String patternGenericTransition(String word) {
    return '通用过渡词「$word」';
  }

  @override
  String get helpAppBarTitle => '操作说明';

  @override
  String get helpAboutTitle => '关于 TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens 是一款内核 AI 推论完全在设备端运行的跨平台内容检测应用程序（iOS / Android / macOS / Windows）。通过四个独立子模型——Transformer 神经网络分类器、统计特征分析、风格特征分析、对抗式改写侦测——加权投票判定文本是否为 AI 生成，并提供逐句、可解释的分析理由：不是只给一个「像 AI」的百分比，而是说明「为什么」。';

  @override
  String get helpComparisonTitle => '与市面主流工具比较';

  @override
  String get helpComparisonDisclaimer =>
      '以下比较依各工具官方公开信息与一般市场认知整理，仅供功能定位参考，非第三方认证的性能实测数据。';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero 的运算主要在云端进行、文档需上传；TruthLens 四个侦测引擎皆在设备端运行。';

  @override
  String get helpVsGptZero2 =>
      'GPTZero 首创的 Perplexity／Burstiness 指针与逐句高亮，TruthLens 已纳入，并叠加 Transformer 分类器、风格特征分析与对抗式防御，形成四模型集成投票，而非单一指针判定。';

  @override
  String get helpVsGptZero3 => 'GPTZero 为订阅制；TruthLens 无需订阅、无使用次数限制。';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin 仅开放机构采购，个人无法直接购买；TruthLens 任何人皆可安装使用。';

  @override
  String get helpVsTurnitin2 =>
      'Turnitin 的判定过程接近黑箱；TruthLens 提供逐句 AI 几率、命中的写作模式，以及四引擎个别评分与理由明细。';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin 主要判断二元「是否为 AI」；TruthLens 支持段落／句子级的人类／AI／混合标示。';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai 为按篇计费的订阅制，且需将文档上传云端；TruthLens 内核运算在设备端运行，无需持续付费使用侦测功能。';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai 有事实查核与可读性分析概念；TruthLens 以本地端风格特征模块呼应，且脱机也能完成基础分析。';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks 以云端 API 为主，强项是低伪阳性率与多语系支持；TruthLens 采用同样理念的 XLM-RoBERTa 多语言基底模型与多模型集成投票，但文档内容不会上传至任何服务器。';

  @override
  String get helpVsCopyleaks2 => 'Copyleaks 依方案而定有 API 用量限制；TruthLens 没有用量限制。';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'Winston AI 的 OCR 图片辨识需上传图片至云端；TruthLens 使用各平台原生框架（iOS／macOS 的 Vision、Android 的 ML Kit、Windows 的 Windows.Media.Ocr）在设备端完成辨识。';

  @override
  String get helpVsWinston2 =>
      'Winston AI 以报告排版精美著称；TruthLens 提供 AI 动态生成排版报告（未安装 LLM 时自动退回模板），可导出 PDF／CSV／JSON／PNG 四种格式。';

  @override
  String get helpAdvantagesTitle => 'TruthLens 的独有优势';

  @override
  String get helpAdvantage1 =>
      '超链接真实性验证：自动侦测文档中的网址是否可连接存在；DOI 格式的学术链接会进一步查找 Crossref 公开登记数据，确认期刊目录是否确实收录这笔文献。';

  @override
  String get helpAdvantage2 =>
      '文献参考真实性核实：即使参考文献没有超链接（纯作者—年份格式），也能通过书目比对抓出可能虚构的引用——这正是 AI 幻觉内容常见的破绽。';

  @override
  String get helpAdvantage3 =>
      'ESL（非母语写作者）偏差修正：自动侦测非母语写作特征并降低统计模型权重，避免将非母语人士的自然写作误判为 AI。';

  @override
  String get helpAdvantage4 => '自订模型导入：高端用户可自行导入本机 ONNX 模型，取代或补充内置侦测引擎。';

  @override
  String get helpWorkflowTitle => '完整操作流程';

  @override
  String get helpWorkflowStep1Title => '模型下载与更新';

  @override
  String get helpWorkflowStep1Body =>
      '首次启动会引导安装内核侦测模型；之后可随时至「设置 → AI 模型管理」查看、下载、更新或移除。App 会在启动时主动比对最新版本，若有更新，设置齿轮图标与「AI 模型管理」项目会出现红点提示。';

  @override
  String get helpWorkflowStep2Title => '如何选用模型（目的与效果）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      '多语言 AI 分类器（权重 40%）：整体判定主力，句子级 AI 几率预测，对准确度提升最明显。';

  @override
  String get helpWorkflowStep2Bullet2 =>
      '统计分析引擎（权重 25%）：困惑度与 Burstiness 滑动窗口分析，捕捉 AI 文本规律的节奏与用词可预测性。';

  @override
  String get helpWorkflowStep2Bullet3 =>
      '风格特征分析（权重 20%）：语意流畅度、重复句式、过渡词使用，可解释性最高，最容易看懂「为什么」。';

  @override
  String get helpWorkflowStep2Bullet4 =>
      '对抗式防御（权重 15%）：辨识是否经改写工具（如 QuillBot、Undetectable.ai）洗过的文本。';

  @override
  String get helpWorkflowStep2Bullet5 =>
      '报告生成 LLM（选用）：安装后报告文本由本地端 LLM 动态生成解说；未安装时自动退回固定模板，分析功能不受影响。';

  @override
  String get helpWorkflowStep2Bullet6 =>
      '可在「设置」个别激活／停用引擎、调整 AI 判定信心阈值（调高可降低误判人类文章为 AI 的几率）。';

  @override
  String get helpWorkflowStep3Title => '文档上传';

  @override
  String get helpWorkflowStep3Body =>
      '三种输入方式：直接粘贴文本、图片辨识（OCR，各平台原生框架脱机辨识）、导入文档（txt / md / pdf / docx / doc）。文本需达 40 字符以上才能送出分析。';

  @override
  String get helpWorkflowStep4Title => '开始分析';

  @override
  String get helpWorkflowStep4Body =>
      '点击「开始检测」，四个引擎并行运行，画面即时显示各引擎完成进度。若侦测到非母语写作特征，会自动套用 ESL 偏差修正（可在设置关闭）。';

  @override
  String get helpWorkflowStep5Title => '查看与导出结果';

  @override
  String get helpWorkflowStep5Body =>
      '报告页包含：整体 AI 几率环状图、逐句热力图、四引擎明细评分与理由、超链接真实性、文献参考真实性。可导出 PDF 完整报告、CSV 逐句数据、JSON（供系统集成）、PNG 摘要卡（社群分享用）。每次分析结果自动保存于「历史纪录」，可随时回顾。';

  @override
  String get helpTuningTitle => '模型下载与调适教学（零基础）';

  @override
  String get helpTuningStep1Title => '打开模型管理画面';

  @override
  String get helpTuningStep1Body => '从首页点齿轮图标进入「设置」，再点「AI 模型管理」旁的「打开」。';

  @override
  String get helpTuningStep2Title => '依设备能力挑选模型';

  @override
  String get helpTuningStep2Body =>
      '画面会依你的设备性能（RAM、处理器内核数）自动建议合适的模型层级，并列出每个角色（多语言分类器／统计分析／对抗式防御／报告 LLM）的所有可用变体。';

  @override
  String get helpTuningStep3Title => '下载与套用';

  @override
  String get helpTuningStep3Body =>
      '点击想要的模型旁的「下载」，等待进度完成——下载完成的第一个模型会自动设为使用中。若已有多个变体，可点「设为使用中」随时切换；点垃圾桶图标可移除不需要的模型以释放空间。';

  @override
  String get helpTuningStep4Title => '更新模型';

  @override
  String get helpTuningStep4Body =>
      '之后若有新版本，「AI 模型管理」与设置齿轮图标会出现红点提示，回到此画面即可看到新版本并下载更新（会保留原本安装的版本，除非手动移除）。';

  @override
  String get helpTuningStep5Title => '高端：导入自订模型';

  @override
  String get helpTuningStep5Body =>
      '若你已在其他地方取得或自行微调过兼容的 .onnx 模型，可通过「设置 → 自订 ONNX 模型导入与测试」导入——需提供模型档、对应的 Tokenizer 设置（或选择「不需要」）与 AI 类别索引；导入前会自动侦测是否为重复导入的相同文件，避免不小心重复安装。';

  @override
  String get helpOfficialLinksTitle => '官方模型下载链接';

  @override
  String get helpOfficialLinksHint => '点击项目会以系统浏览器打开该模型的官方页面。';

  @override
  String get helpLinkRoleTransformer => '多语言 AI 分类器（Transformer，权重 40%）';

  @override
  String get helpLinkRoleStatistical => '困惑度统计模型（Statistical，权重 25%）';

  @override
  String get helpLinkRoleAdversarial => '对抗式改写侦测模型（Adversarial，权重 15%）';

  @override
  String get helpLinkRoleLlm => '报告生成 LLM（选用）';

  @override
  String get privacyAppBarTitle => '隐私权政策';

  @override
  String privacyPlatformTitle(String platform) {
    return '$platform版隐私权政策';
  }

  @override
  String privacyLastUpdated(String date) {
    return '最后更新：$date';
  }

  @override
  String get privacyIosOverview1 =>
      'TruthLens 不收集任何与您的身分链接的数据，也不将任何数据用于追踪，因此不需要 App 追踪透明度（ATT）权限。';

  @override
  String get privacyIosOverview2 =>
      '本 App 使用系统提供的文件选择器访问您主动选择的文档或图片；未经您选择的文件，App 无法访问（iOS App Sandbox 限制）。';

  @override
  String get privacyAndroidOverview1 => 'TruthLens 不收集个人数据，也不与任何第三方分享用户数据。';

  @override
  String get privacyAndroidOverview2 =>
      '本 App 仅在您主动选择导入文档或图片时访问对应的保存权限，不会背景扫描或访问其他文件。';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens 在 macOS App Sandbox 下运行，仅能访问您通过系统文件对话框主动选择的文件（files.user-selected.read-write），无法自行浏览或访问其他文件或文件夹。';

  @override
  String get privacyMacosOverview2 =>
      '网络访问权限（network.client）仅用于下方「必要的连接行为」所列的功能。';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens 为单机桌面应用程序，数据保存于您本机用户文件夹内（如 AppData／Documents），不会同步至云端。';

  @override
  String get privacyWindowsOverview2 =>
      '本 App 仅在您主动选择导入文档或图片时访问对应文件，不会背景扫描其他文件。';

  @override
  String get privacyDataHandling1 =>
      'TruthLens 没有用户帐号、不需登录，也没有任何形式的广告或第三方追踪 SDK。';

  @override
  String get privacyDataHandling2 =>
      '您输入、粘贴或导入的文档内容，皆在您的设备上由本机 AI 模型完成分析，不会上传到 TruthLens 或任何第三方服务器。';

  @override
  String get privacyDataHandling3 =>
      '分析结果与历史纪录仅保存在您设备本机的数据库中；卸载 App 或清除历史纪录即会一并移除，TruthLens 不持有任何副本。';

  @override
  String get privacyNetworkIntro => '本 App 的内核 AI 侦测完全在设备端运行，但下列三项功能需要连接：';

  @override
  String get privacyNetwork1 =>
      '1. 模型目录与下载：连至 GitHub Releases／Hugging Face 下载您选择的侦测模型文件，仅为下载模型，不会上传任何用户数据。';

  @override
  String get privacyNetwork2 => '2. 模型更新侦测：App 启动时会连接比对版本号，仅发送版本信息，用于提示是否有新版本。';

  @override
  String get privacyNetwork3 =>
      '3. 超链接与参考文献真实性验证：缺省打开，可在「设置」关闭。打开时，会将文档中侦测到的网址或参考文献文本，直接送往该网址本身或 Crossref 公开 API 查找，仅发送网址／DOI／书目文本本身，不含文档中的其他内容。';

  @override
  String get privacyRightsIntro => '您可随时于「历史纪录」清除本机分析纪录，或于「设置」关闭超链接／文献验证功能，或直接';

  @override
  String get privacyRemoveIos => '删除 App';

  @override
  String get privacyRemoveAndroid => '卸载 App';

  @override
  String get privacyRemoveMacos => '将 App 移到垃圾桶';

  @override
  String get privacyRemoveWindows => '卸载 App';

  @override
  String get privacyDisclaimer =>
      '本页内容为 TruthLens 依实际功能行为撰写的隐私权说明，非律师审阅之正式法律文档；如需与您所在地区的法规进行正式合规审查，建议另行咨询专业法律意见。';

  @override
  String get privacySectionOverviewIos => '概要（对应 App Store 隐私权「营养标签」）';

  @override
  String get privacySectionOverviewAndroid => '概要（对应 Google Play「数据安全」揭露）';

  @override
  String get privacySectionOverviewMacos => '概要（App Sandbox 权限说明）';

  @override
  String get privacySectionOverviewWindows => '概要';

  @override
  String get privacySectionDataHandling => '我们如何处理您的数据';

  @override
  String get privacySectionNetwork => '必要的连接行为';

  @override
  String get privacySectionRights => '您的权利';

  @override
  String get privacyGenericPlatformName => '本平台';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get commonCancel => '取消';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonClose => '關閉';

  @override
  String get verdictHuman => '人類撰寫';

  @override
  String get verdictLikelyHuman => '可能人類';

  @override
  String get verdictMixed => '混合內容';

  @override
  String get verdictLikelyAi => '可能 AI';

  @override
  String get verdictAi => 'AI 生成';

  @override
  String get inputSubtitle => '貼上或輸入文本，偵測 AI 生成內容';

  @override
  String get inputHint => '在此輸入或貼上要檢測的文字…';

  @override
  String get inputHistoryTooltip => '歷史紀錄';

  @override
  String get inputHelpTooltip => '操作說明';

  @override
  String get inputPrivacyTooltip => '隱私權政策';

  @override
  String get inputSettingsTooltip => '設定';

  @override
  String get inputPasteButton => '貼上';

  @override
  String get inputOcrButton => '圖片辨識';

  @override
  String get inputImportButton => '匯入文件';

  @override
  String get inputStartButton => '開始檢測';

  @override
  String get inputClearTooltip => '清除內容';

  @override
  String get inputTooShortSnackbar => '請輸入至少 40 個字元的文本以獲得可靠分析';

  @override
  String get inputOcrUnsupported => '此平台尚未支援 OCR 文字辨識';

  @override
  String get inputOcrRecognizing => '辨識中…';

  @override
  String get inputOcrNoText => '未從圖片中辨識到文字';

  @override
  String inputOcrRecognized(int count) {
    return '已辨識 $count 個字元';
  }

  @override
  String inputImportNoText(String fileName) {
    return '「$fileName」沒有可讀取的文字內容';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '已匯入「$fileName」（$count 字元）';
  }

  @override
  String inputActiveModel(String modelId) {
    return '模型：$modelId';
  }

  @override
  String get inputNoModel => '未安裝模型（僅統計/風格分析）';

  @override
  String inputCharCount(int count) {
    return '$count 字元';
  }

  @override
  String get analysisAppBarTitle => '分析中';

  @override
  String get analysisEngineTransformer => 'Transformer 分類器';

  @override
  String get analysisEngineStatistical => '統計特徵分析';

  @override
  String get analysisEngineStylometry => '風格特徵分析';

  @override
  String get analysisEngineAdversarial => '對抗式防禦';

  @override
  String analysisProgressSemantics(int done, int total) {
    return '分析進行中，已完成 $done / $total 個引擎';
  }

  @override
  String get analysisDoneSemantics => '已完成';

  @override
  String get engineNameAdversarialFull => '對抗式防禦（改寫偵測）';

  @override
  String get modelNecessityText =>
      '未下載神經網路偵測模型時，TruthLens 仍可運作，但僅使用統計與風格分析，準確度與多語言支援有限。下載模型後，多語言 Transformer 分類器會加入集成投票，大幅提升判定準確度與可靠度。模型在裝置端執行，下載後不會上傳任何內容。';

  @override
  String get modelPromptTitle => '建議下載偵測模型以獲得完整分析';

  @override
  String get modelPromptDontRemind => '不再提醒我';

  @override
  String get modelPromptSkip => '暫時略過';

  @override
  String get modelPromptDownload => '前往下載';

  @override
  String get onboardingWelcomeTitle => '歡迎使用 TruthLens';

  @override
  String get onboardingHeadline => '裝置端 AI 內容檢測';

  @override
  String get onboardingDetectedDevice => '偵測到的裝置';

  @override
  String get onboardingChooseModel => '選擇要下載的模型';

  @override
  String get onboardingRecommendHint => '已依你的硬體標示「推薦」；也可自行選擇其他選項。';

  @override
  String get onboardingSkipButton => '稍後再說（先用免模型的統計/風格分析）';

  @override
  String get onboardingSkipHint => '略過後仍可隨時到「設定 → AI 模型管理」下載；使用需要模型的分析時也會再次提醒。';

  @override
  String get modelListCustomImportedLabel => '自訂匯入的模型：';

  @override
  String get modelListActiveChip => '使用中';

  @override
  String get modelListRecommendedChip => '推薦';

  @override
  String get modelListCustomChip => '自訂';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · 需 ${ram}GB RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return '大小: $size · Tokenizer: $tokenizer · AI Label Index: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return '下載中… $percent%（$downloaded / $total）';
  }

  @override
  String modelListDownloadButton(String size) {
    return '下載（$size）';
  }

  @override
  String get modelListComingSoonChip => '即將推出';

  @override
  String get modelListSetActiveButton => '設為使用中';

  @override
  String get modelListUpdateButton => '更新';

  @override
  String get modelListDeleteTooltip => '刪除';

  @override
  String get modelListPageButton => '模型頁面';

  @override
  String get modelListMayExceedMemory => '可能超出裝置記憶體';

  @override
  String modelListFailedPrefix(String error) {
    return '失敗：$error';
  }

  @override
  String get modelListDeleteConfirmTitle => '刪除模型？';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return '將刪除「$name」（$size）。刪除後需重新下載才能再次使用。';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return '將刪除自訂匯入的「$name」（$size）。刪除後需重新匯入才能再次使用。';
  }

  @override
  String get modelImportAppBarTitle => '匯入自訂 ONNX 模型';

  @override
  String get modelImportStep1Title => '1. 選擇 ONNX 模型檔案';

  @override
  String modelImportSelectedFile(String name) {
    return '已選擇: $name';
  }

  @override
  String get modelImportNoFileSelected => '未選擇模型檔案 (.onnx)';

  @override
  String get modelImportBrowseButton => '瀏覽';

  @override
  String get modelImportCheckingDuplicate => '偵測是否已匯入過相同檔案…';

  @override
  String get modelImportDuplicateTitle => '偵測到相同內容的模型已匯入過';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return '此檔案與「$name」（角色：$role）內容完全相同。如果只是想切換使用中模型，可以到「AI 模型管理」直接設為使用中，不需要重新匯入。仍可繼續完成以下步驟。';
  }

  @override
  String get modelImportStep2Title => '2. 參數設定';

  @override
  String get modelImportNameLabel => '模型顯示名稱';

  @override
  String get modelImportNameRequired => '名稱不能為空';

  @override
  String get modelImportRoleLabel => '目標引擎角色';

  @override
  String get modelImportTokenizerTypeLabel => 'Tokenizer 類型';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => 'None (無 Tokenizer/逐字)';

  @override
  String get modelImportNoTokenizerSelected => '未選擇 Tokenizer 檔案 (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return '已選擇: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'AI 類別輸出索引 (AI Label Index)';

  @override
  String get modelImportIndex0 => 'Index 0 (例如 RoBERTa)';

  @override
  String get modelImportIndex1 => 'Index 1 (例如 DistilBERT)';

  @override
  String get modelImportStep3Title => '3. 測試與驗證';

  @override
  String get modelImportTestInputLabel => '測試輸入文本';

  @override
  String get modelImportRunTestButton => '執行測試推論';

  @override
  String get modelImportResultLabel => '推論結果 (AI 機率):';

  @override
  String modelImportTestFailed(String error) {
    return '測試失敗: $error';
  }

  @override
  String get modelImportConfirmButton => '確認匯入並啟用模型';

  @override
  String get modelImportSelectTokenizerFirst => '請先選擇 Tokenizer 檔案';

  @override
  String get modelImportSelectTokenizer => '請選擇 Tokenizer 檔案';

  @override
  String get modelImportSuccessSnackbar => '模型匯入成功！已自動啟用為使用中模型。';

  @override
  String get modelImportFailedSnackbar => '模型匯入失敗，請檢查權限或日誌';

  @override
  String get settingsAppBarTitle => '設定';

  @override
  String get settingsThresholdTitle => 'AI 判定信心閾值';

  @override
  String settingsThresholdSubtitle(int percent) {
    return '目前：$percent% — 調高可降低偽陽性（誤判人類文章為 AI）';
  }

  @override
  String get settingsEslTitle => 'ESL 非母語者偏差修正';

  @override
  String get settingsEslSubtitle => '偵測到非母語寫作風格時，自動降低統計模型權重';

  @override
  String get settingsEngineSectionTitle => '子偵測引擎啟用設定 (Ensemble)';

  @override
  String get settingsEngineTransformerTitle => '多語言 AI 分類器 (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      '使用 Transformer 神經網路模型進行端上 AI 機率預測';

  @override
  String get settingsEngineStatisticalTitle => '統計分析引擎 (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      '透過句長波動度、Burstiness 及 PPL 判定語言規律';

  @override
  String get settingsEngineStylometryTitle => '風格特徵分析 (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle => '分析語意流暢度、重複句式與過渡詞等寫作特徵';

  @override
  String get settingsEngineAdversarialTitle => '對抗式改寫偵測 (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle => '辨識是否經過機器改寫或去 AI 痕跡處理';

  @override
  String get settingsLinkVerificationTitle => '超連結與參考文獻目錄驗證';

  @override
  String get settingsLinkVerificationSubtitle =>
      '分析報告會對文件中偵測到的網址與參考文獻條目發出連線請求，確認是否真的存在（AI 生成內容常附上看似合理但實際不存在的引用連結或文獻）。DOI 格式的學術連結、以及沒有連結的「作者—年份」參考文獻，都會查詢 Crossref 公開登記資料比對。核心 AI 偵測模型仍完全在裝置端執行，不會傳送文件內容，連線僅用於此驗證與模型更新偵測，可在此關閉。';

  @override
  String get settingsThemeTitle => '外觀主題';

  @override
  String get settingsLanguageTitle => '語言';

  @override
  String get settingsLanguageSubtitle => '選擇應用程式顯示語言';

  @override
  String get settingsModelManagementTitle => 'AI 模型管理';

  @override
  String get settingsModelManagementSubtitle => '下載檢測模型與報告 LLM，啟用完整推論能力';

  @override
  String get settingsModelManagementUpdateSubtitle => '偵測到模型更新，建議前往查看';

  @override
  String get settingsOpenButton => '開啟';

  @override
  String get settingsCustomImportTitle => '自訂 ONNX 模型匯入與測試';

  @override
  String get settingsCustomImportSubtitle =>
      '匯入本機的自訂 ONNX 模型與 Tokenizer 設定並進行推論測試';

  @override
  String get settingsLanguagePackTitle => '語言包';

  @override
  String get settingsLanguagePackSubtitle => '額外語言微調模型（第四階段開放）';

  @override
  String get settingsModelManagerAppBarTitle => 'AI 模型管理';

  @override
  String get settingsImportTooltip => '匯入本機 ONNX 模型';

  @override
  String settingsDeviceLabel(String summary) {
    return '裝置：$summary';
  }

  @override
  String get historyAppBarTitle => '歷史紀錄';

  @override
  String get historyClearAllTooltip => '清空全部';

  @override
  String get historySearchHint => '搜尋歷史紀錄…';

  @override
  String get historyDeletedSnackbar => '已刪除該筆紀錄';

  @override
  String get historyClearAllTitle => '清空所有歷史紀錄？';

  @override
  String historyClearAllBody(int count) {
    return '將刪除全部 $count 筆紀錄，此動作無法復原。';
  }

  @override
  String get historyClearButton => '清空';

  @override
  String get historyDeleteEntryTitle => '刪除這筆紀錄？';

  @override
  String get historyReanalyzeTooltip => '重新分析';

  @override
  String get historyEmptyDefault => '尚無檢測紀錄';

  @override
  String historyEmptySearch(String query) {
    return '找不到符合「$query」的紀錄';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict，AI 機率 $percent%，$time。$text';
  }

  @override
  String get reportAppBarTitle => '檢測報告';

  @override
  String get reportExportTooltip => '匯出報告';

  @override
  String get reportHomeTooltip => '回首頁';

  @override
  String get reportGeneratingTitle => '正在生成報告…';

  @override
  String get reportSourceLlm => 'AI 智慧生成報告';

  @override
  String get reportSourceTemplate => '模板生成報告';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '共 $total 句 · 疑似 AI $ai 句 · 人類 $human 句 · 耗時 $seconds 秒';
  }

  @override
  String get reportExportPdf => '匯出 PDF 報告';

  @override
  String get reportExportCsv => '匯出 CSV 數據';

  @override
  String get reportExportJson => '匯出 JSON（系統整合）';

  @override
  String get reportExportPng => '匯出摘要卡（PNG）';

  @override
  String reportExported(String path) {
    return '已匯出：$path';
  }

  @override
  String reportExportFailed(String error) {
    return '匯出失敗：$error';
  }

  @override
  String get reportEngineBreakdownTitle => '引擎明細';

  @override
  String get reportEngineNotInstalled => '未安裝';

  @override
  String get reportSentenceAnalysisTitle => '逐句分析';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text。AI 機率 $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => '超連結真實性';

  @override
  String get reportLinkNoneDetected => '未在文件中偵測到超連結。';

  @override
  String get reportLinkCheckingProgress => '正在驗證連結…';

  @override
  String reportLinkDetectedPending(int count) {
    return '偵測到 $count 個超連結，尚未驗證是否存在';
  }

  @override
  String get reportLinkDisabledHint =>
      'AI 生成內容常附上看似合理但實際不存在的引用連結。你已在「設定」關閉超連結驗證；可重新開啟以自動驗證，或點擊下方按鈕做單次驗證。';

  @override
  String get reportVerifyNowButton => '立即驗證（需連線）';

  @override
  String get reportLinkReachable => '可連線，網址存在';

  @override
  String get reportLinkNotFound => '網址不存在（404），可能為虛構引用';

  @override
  String get reportLinkUnreachable => '無法確認（連線逾時或伺服器無回應）';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return '期刊目錄核實：已登記於$journal$title';
  }

  @override
  String get reportLinkCitationNotFound => '查無此 DOI 登記紀錄，可能為虛構引用';

  @override
  String get reportLinkCitationUnreachable => '無法確認（連線逾時或 Crossref 無回應）';

  @override
  String reportLinkTruncated(int max, int count) {
    return '僅驗證前 $max 個連結（共偵測到 $count 個）';
  }

  @override
  String get reportBibAuthenticityTitle => '文獻參考真實性';

  @override
  String get reportBibNoneDetected => '未在文件中偵測到參考文獻條目。';

  @override
  String get reportBibCheckingProgress => '正在核實參考文獻目錄…';

  @override
  String reportBibDetectedPending(int count) {
    return '偵測到參考文獻目錄（$count 筆），尚未核實是否存在';
  }

  @override
  String get reportBibDisabledHint =>
      'AI 生成內容常附上看似合理但實際不存在的參考文獻。你已在「設定」關閉超連結驗證；可重新開啟以自動核實，或點擊下方按鈕做單次核實。';

  @override
  String get reportVerifyNowBibButton => '立即核實（需連線）';

  @override
  String get reportBibResultHint =>
      '依作者、年份與篇名相似度比對 Crossref 公開登記資料，非絕對保證，「無法確定」時建議自行核對。';

  @override
  String reportBibHighConfidence(String journal) {
    return '高可信度：應存在$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（登記於《$journal》）';
  }

  @override
  String get reportBibNotFound => '查無相近匹配，可能為虛構文獻';

  @override
  String get reportBibUncertain => '相似度中等或連線失敗，無法確定，建議自行核對';

  @override
  String reportBibTruncated(int max, int count) {
    return '僅核實前 $max 筆（共偵測到 $count 筆）';
  }

  @override
  String get reportNetworkWarningTitle => '網路連線不佳';

  @override
  String get reportNetworkWarningBody =>
      '本 App 執行時預設為有網路連線的狀態；超連結真實性與文獻參考真實性分析都需要網路連線才能判斷結果。偵測到目前無法連線，請檢查網路狀態後重試。';

  @override
  String get reportRetryConnectionButton => '重新檢查連線';

  @override
  String get reportAiProbabilityLabel => 'AI 機率';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '共 $total 句\n疑似 AI $ai 句\n人類 $human 句';
  }

  @override
  String get summaryCardFooter => '核心 AI 推論皆在裝置端執行';

  @override
  String get exportReportTitle => 'TruthLens 檢測報告';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · 第 $page / $total 頁';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return '分析時間：$datetime · 耗時 $seconds 秒';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return '整體判定：$verdict';
  }

  @override
  String get pdfEslAppliedSuffix => '（已套用 ESL 修正）';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '共 $total 句 · 疑似 AI $ai 句 · 人類 $human 句';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return '為維持 PDF 可讀性，僅顯示前 $max 句（共 $count 句）；如需完整逐句資料，請改用「$csvLabel」或「$jsonLabel」。';
  }

  @override
  String get pdfSentenceColumnHeader => '句子（附命中模式）';

  @override
  String composerHeadlineAi(int percent) {
    return '這段文字極可能由 AI 生成（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return '這段文字傾向 AI 生成，建議進一步檢視（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return '這段文字呈現人類與 AI 混合的特徵（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return '這段文字傾向人類撰寫（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return '這段文字極可能為人類撰寫（AI 機率 $percent%）';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return '整體 AI 機率越過你設定的 $percent% 閾值，被標記為 AI。';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '整體 AI 機率未達 $percent% 標記閾值。';
  }

  @override
  String get composerNarrativeTitle => '分析解讀';

  @override
  String get composerParaphraseTitle => '偵測到改寫痕跡';

  @override
  String get composerParaphraseBody =>
      '本文可能經過改寫工具（如 QuillBot、Undetectable.ai）處理以規避偵測。此類文本即使逐句讀來自然，其整體統計特徵仍與原生人類寫作不同，請特別留意。';

  @override
  String get composerPatternListTitle => '主要 AI 寫作特徵';

  @override
  String get composerEslTitle => 'ESL 非母語者偏差修正';

  @override
  String get composerEslBody =>
      '偵測到本文可能出自非母語寫作者。非母語者常見的低困惑度與規律句式並非 AI 特徵，因此系統已降低統計模型的權重，以避免誤判。';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return '全文共 $total 句，其中 $ai 句呈現較強的 AI 特徵、$human 句偏向人類撰寫。';
  }

  @override
  String get composerNarrativeAiPattern =>
      '多數句子在句長節奏、用詞與過渡詞使用上高度規律，這是 AI 生成文本的常見指紋。';

  @override
  String get composerNarrativeMixedPattern =>
      '文中同時存在規律化與自然起伏的段落，顯示可能為人類初稿再經 AI 潤飾，或人機協作而成。';

  @override
  String get composerNarrativeHumanPattern =>
      '句長與用詞展現自然的變化與個人風格，未見明顯的 AI 規律化痕跡。';

  @override
  String engineReasonPplLow(String ppl) {
    return '語言模型困惑度偏低（$ppl），文本高度可預測，是 AI 生成的指標';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return '語言模型困惑度偏高（$ppl），符合人類寫作的不可預測性';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return '語言模型困惑度中等（$ppl）';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return '句子長度高度一致（burstiness $value），節奏均勻是 AI 生成文本的典型統計特徵';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return '句長起伏明顯（burstiness $value），符合人類自然寫作的節奏變化';
  }

  @override
  String engineReasonTtrLow(String value) {
    return '詞彙多樣性偏低（TTR $value），用詞重複度高';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return '詞彙多樣性高（TTR $value）';
  }

  @override
  String get engineReasonNeutral => '統計指標未呈現顯著傾向，維持中性判定';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return '高頻使用通用過渡詞（$words），每句平均 $density 次，人類寫作極少如此密集';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return '多個相鄰句子以相同詞語開頭（$count 處），句式重複';
  }

  @override
  String get engineReasonNoStyleMarkers => '未偵測到顯著的 AI 寫作風格模式';

  @override
  String get engineReasonAdversarialNotInstalled => '改寫偵測模型尚未安裝，未參與本次投票';

  @override
  String get engineReasonTransformerNotInstalled => '模型尚未安裝或使用中模型未支援，未參與本次投票';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return '模型載入失敗，未參與本次投票（$error）';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model 判定 $total 句中有 $aiCount 句呈現 AI 特徵';
  }

  @override
  String get engineReasonAdversarialDetected =>
      '對抗模型偵測到疑似經改寫工具（如 QuillBot / Undetectable.ai）洗過的 AI 特徵';

  @override
  String get engineReasonAdversarialClean => '未偵測到明顯的改寫規避特徵';

  @override
  String get engineReasonDisabledByUser => '使用者在設定中關閉此引擎';

  @override
  String get engineReasonGenericNotInstalled => '模型尚未安裝，未參與本次投票';

  @override
  String patternGenericTransition(String word) {
    return '通用過渡詞「$word」';
  }

  @override
  String get helpAppBarTitle => '操作說明';

  @override
  String get helpAboutTitle => '關於 TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens 是一款核心 AI 推論完全在裝置端執行的跨平台內容檢測應用程式（iOS / Android / macOS / Windows）。透過四個獨立子模型——Transformer 神經網路分類器、統計特徵分析、風格特徵分析、對抗式改寫偵測——加權投票判定文字是否為 AI 生成，並提供逐句、可解釋的分析理由：不是只給一個「像 AI」的百分比，而是說明「為什麼」。';

  @override
  String get helpComparisonTitle => '與市面主流工具比較';

  @override
  String get helpComparisonDisclaimer =>
      '以下比較依各工具官方公開資訊與一般市場認知整理，僅供功能定位參考，非第三方認證的效能實測數據。';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero 的運算主要在雲端進行、文件需上傳；TruthLens 四個偵測引擎皆在裝置端執行。';

  @override
  String get helpVsGptZero2 =>
      'GPTZero 首創的 Perplexity／Burstiness 指標與逐句高亮，TruthLens 已納入，並疊加 Transformer 分類器、風格特徵分析與對抗式防禦，形成四模型集成投票，而非單一指標判定。';

  @override
  String get helpVsGptZero3 => 'GPTZero 為訂閱制；TruthLens 無需訂閱、無使用次數限制。';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin 僅開放機構採購，個人無法直接購買；TruthLens 任何人皆可安裝使用。';

  @override
  String get helpVsTurnitin2 =>
      'Turnitin 的判定過程接近黑箱；TruthLens 提供逐句 AI 機率、命中的寫作模式，以及四引擎個別評分與理由明細。';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin 主要判斷二元「是否為 AI」；TruthLens 支援段落／句子級的人類／AI／混合標示。';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai 為按篇計費的訂閱制，且需將文件上傳雲端；TruthLens 核心運算在裝置端執行，無需持續付費使用偵測功能。';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai 有事實查核與可讀性分析概念；TruthLens 以本地端風格特徵模組呼應，且離線也能完成基礎分析。';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks 以雲端 API 為主，強項是低偽陽性率與多語系支援；TruthLens 採用同樣理念的 XLM-RoBERTa 多語言基底模型與多模型集成投票，但文件內容不會上傳至任何伺服器。';

  @override
  String get helpVsCopyleaks2 => 'Copyleaks 依方案而定有 API 用量限制；TruthLens 沒有用量限制。';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'Winston AI 的 OCR 圖片辨識需上傳圖片至雲端；TruthLens 使用各平台原生框架（iOS／macOS 的 Vision、Android 的 ML Kit、Windows 的 Windows.Media.Ocr）在裝置端完成辨識。';

  @override
  String get helpVsWinston2 =>
      'Winston AI 以報告排版精美著稱；TruthLens 提供 AI 動態生成排版報告（未安裝 LLM 時自動退回模板），可匯出 PDF／CSV／JSON／PNG 四種格式。';

  @override
  String get helpAdvantagesTitle => 'TruthLens 的獨有優勢';

  @override
  String get helpAdvantage1 =>
      '超連結真實性驗證：自動偵測文件中的網址是否可連線存在；DOI 格式的學術連結會進一步查詢 Crossref 公開登記資料，確認期刊目錄是否確實收錄這筆文獻。';

  @override
  String get helpAdvantage2 =>
      '文獻參考真實性核實：即使參考文獻沒有超連結（純作者—年份格式），也能透過書目比對抓出可能虛構的引用——這正是 AI 幻覺內容常見的破綻。';

  @override
  String get helpAdvantage3 =>
      'ESL（非母語寫作者）偏差修正：自動偵測非母語寫作特徵並降低統計模型權重，避免將非母語人士的自然寫作誤判為 AI。';

  @override
  String get helpAdvantage4 => '自訂模型匯入：進階使用者可自行匯入本機 ONNX 模型，取代或補充內建偵測引擎。';

  @override
  String get helpWorkflowTitle => '完整操作流程';

  @override
  String get helpWorkflowStep1Title => '模型下載與更新';

  @override
  String get helpWorkflowStep1Body =>
      '首次啟動會引導安裝核心偵測模型；之後可隨時至「設定 → AI 模型管理」查看、下載、更新或移除。App 會在啟動時主動比對最新版本，若有更新，設定齒輪圖示與「AI 模型管理」項目會出現紅點提示。';

  @override
  String get helpWorkflowStep2Title => '如何選用模型（目的與效果）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      '多語言 AI 分類器（權重 40%）：整體判定主力，句子級 AI 機率預測，對準確度提升最明顯。';

  @override
  String get helpWorkflowStep2Bullet2 =>
      '統計分析引擎（權重 25%）：困惑度與 Burstiness 滑動窗口分析，捕捉 AI 文本規律的節奏與用詞可預測性。';

  @override
  String get helpWorkflowStep2Bullet3 =>
      '風格特徵分析（權重 20%）：語意流暢度、重複句式、過渡詞使用，可解釋性最高，最容易看懂「為什麼」。';

  @override
  String get helpWorkflowStep2Bullet4 =>
      '對抗式防禦（權重 15%）：辨識是否經改寫工具（如 QuillBot、Undetectable.ai）洗過的文本。';

  @override
  String get helpWorkflowStep2Bullet5 =>
      '報告生成 LLM（選用）：安裝後報告文字由本地端 LLM 動態生成解說；未安裝時自動退回固定模板，分析功能不受影響。';

  @override
  String get helpWorkflowStep2Bullet6 =>
      '可在「設定」個別啟用／停用引擎、調整 AI 判定信心閾值（調高可降低誤判人類文章為 AI 的機率）。';

  @override
  String get helpWorkflowStep3Title => '文檔上傳';

  @override
  String get helpWorkflowStep3Body =>
      '三種輸入方式：直接貼上文字、圖片辨識（OCR，各平台原生框架離線辨識）、匯入文件（txt / md / pdf / docx / doc）。文字需達 40 字元以上才能送出分析。';

  @override
  String get helpWorkflowStep4Title => '開始分析';

  @override
  String get helpWorkflowStep4Body =>
      '點擊「開始檢測」，四個引擎並行執行，畫面即時顯示各引擎完成進度。若偵測到非母語寫作特徵，會自動套用 ESL 偏差修正（可在設定關閉）。';

  @override
  String get helpWorkflowStep5Title => '查看與匯出結果';

  @override
  String get helpWorkflowStep5Body =>
      '報告頁包含：整體 AI 機率環狀圖、逐句熱力圖、四引擎明細評分與理由、超連結真實性、文獻參考真實性。可匯出 PDF 完整報告、CSV 逐句數據、JSON（供系統整合）、PNG 摘要卡（社群分享用）。每次分析結果自動保存於「歷史紀錄」，可隨時回顧。';

  @override
  String get helpTuningTitle => '模型下載與調適教學（零基礎）';

  @override
  String get helpTuningStep1Title => '開啟模型管理畫面';

  @override
  String get helpTuningStep1Body => '從首頁點齒輪圖示進入「設定」，再點「AI 模型管理」旁的「開啟」。';

  @override
  String get helpTuningStep2Title => '依裝置能力挑選模型';

  @override
  String get helpTuningStep2Body =>
      '畫面會依你的裝置效能（RAM、處理器核心數）自動建議合適的模型層級，並列出每個角色（多語言分類器／統計分析／對抗式防禦／報告 LLM）的所有可用變體。';

  @override
  String get helpTuningStep3Title => '下載與套用';

  @override
  String get helpTuningStep3Body =>
      '點選想要的模型旁的「下載」，等待進度完成——下載完成的第一個模型會自動設為使用中。若已有多個變體，可點「設為使用中」隨時切換；點垃圾桶圖示可移除不需要的模型以釋放空間。';

  @override
  String get helpTuningStep4Title => '更新模型';

  @override
  String get helpTuningStep4Body =>
      '之後若有新版本，「AI 模型管理」與設定齒輪圖示會出現紅點提示，回到此畫面即可看到新版本並下載更新（會保留原本安裝的版本，除非手動移除）。';

  @override
  String get helpTuningStep5Title => '進階：匯入自訂模型';

  @override
  String get helpTuningStep5Body =>
      '若你已在其他地方取得或自行微調過相容的 .onnx 模型，可透過「設定 → 自訂 ONNX 模型匯入與測試」匯入——需提供模型檔、對應的 Tokenizer 設定（或選擇「不需要」）與 AI 類別索引；匯入前會自動偵測是否為重複匯入的相同檔案，避免不小心重複安裝。';

  @override
  String get helpOfficialLinksTitle => '官方模型下載連結';

  @override
  String get helpOfficialLinksHint => '點擊項目會以系統瀏覽器開啟該模型的官方頁面。';

  @override
  String get helpLinkRoleTransformer => '多語言 AI 分類器（Transformer，權重 40%）';

  @override
  String get helpLinkRoleStatistical => '困惑度統計模型（Statistical，權重 25%）';

  @override
  String get helpLinkRoleAdversarial => '對抗式改寫偵測模型（Adversarial，權重 15%）';

  @override
  String get helpLinkRoleLlm => '報告生成 LLM（選用）';

  @override
  String get privacyAppBarTitle => '隱私權政策';

  @override
  String privacyPlatformTitle(String platform) {
    return '$platform版隱私權政策';
  }

  @override
  String privacyLastUpdated(String date) {
    return '最後更新：$date';
  }

  @override
  String get privacyIosOverview1 =>
      'TruthLens 不收集任何與您的身分連結的資料，也不將任何資料用於追蹤，因此不需要 App 追蹤透明度（ATT）權限。';

  @override
  String get privacyIosOverview2 =>
      '本 App 使用系統提供的檔案選擇器存取您主動選擇的文件或圖片；未經您選擇的檔案，App 無法存取（iOS App Sandbox 限制）。';

  @override
  String get privacyAndroidOverview1 => 'TruthLens 不收集個人資料，也不與任何第三方分享使用者資料。';

  @override
  String get privacyAndroidOverview2 =>
      '本 App 僅在您主動選擇匯入文件或圖片時存取對應的儲存權限，不會背景掃描或存取其他檔案。';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens 在 macOS App Sandbox 下執行，僅能存取您透過系統檔案對話框主動選擇的檔案（files.user-selected.read-write），無法自行瀏覽或存取其他檔案或資料夾。';

  @override
  String get privacyMacosOverview2 =>
      '網路存取權限（network.client）僅用於下方「必要的連線行為」所列的功能。';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens 為單機桌面應用程式，資料儲存於您本機使用者資料夾內（如 AppData／Documents），不會同步至雲端。';

  @override
  String get privacyWindowsOverview2 =>
      '本 App 僅在您主動選擇匯入文件或圖片時存取對應檔案，不會背景掃描其他檔案。';

  @override
  String get privacyDataHandling1 =>
      'TruthLens 沒有使用者帳號、不需登入，也沒有任何形式的廣告或第三方追蹤 SDK。';

  @override
  String get privacyDataHandling2 =>
      '您輸入、貼上或匯入的文件內容，皆在您的裝置上由本機 AI 模型完成分析，不會上傳到 TruthLens 或任何第三方伺服器。';

  @override
  String get privacyDataHandling3 =>
      '分析結果與歷史紀錄僅儲存在您裝置本機的資料庫中；解除安裝 App 或清除歷史紀錄即會一併移除，TruthLens 不持有任何副本。';

  @override
  String get privacyNetworkIntro => '本 App 的核心 AI 偵測完全在裝置端執行，但下列三項功能需要連線：';

  @override
  String get privacyNetwork1 =>
      '1. 模型目錄與下載：連至 GitHub Releases／Hugging Face 下載您選擇的偵測模型檔案，僅為下載模型，不會上傳任何使用者資料。';

  @override
  String get privacyNetwork2 => '2. 模型更新偵測：App 啟動時會連線比對版本號，僅傳送版本資訊，用於提示是否有新版本。';

  @override
  String get privacyNetwork3 =>
      '3. 超連結與參考文獻真實性驗證：預設開啟，可在「設定」關閉。開啟時，會將文件中偵測到的網址或參考文獻文字，直接送往該網址本身或 Crossref 公開 API 查詢，僅傳送網址／DOI／書目文字本身，不含文件中的其他內容。';

  @override
  String get privacyRightsIntro => '您可隨時於「歷史紀錄」清除本機分析紀錄，或於「設定」關閉超連結／文獻驗證功能，或直接';

  @override
  String get privacyRemoveIos => '刪除 App';

  @override
  String get privacyRemoveAndroid => '解除安裝 App';

  @override
  String get privacyRemoveMacos => '將 App 移到垃圾桶';

  @override
  String get privacyRemoveWindows => '解除安裝 App';

  @override
  String get privacyDisclaimer =>
      '本頁內容為 TruthLens 依實際功能行為撰寫的隱私權說明，非律師審閱之正式法律文件；如需與您所在地區的法規進行正式合規審查，建議另行諮詢專業法律意見。';

  @override
  String get privacySectionOverviewIos => '概要（對應 App Store 隱私權「營養標籤」）';

  @override
  String get privacySectionOverviewAndroid => '概要（對應 Google Play「資料安全」揭露）';

  @override
  String get privacySectionOverviewMacos => '概要（App Sandbox 權限說明）';

  @override
  String get privacySectionOverviewWindows => '概要';

  @override
  String get privacySectionDataHandling => '我們如何處理您的資料';

  @override
  String get privacySectionNetwork => '必要的連線行為';

  @override
  String get privacySectionRights => '您的權利';

  @override
  String get privacyGenericPlatformName => '本平台';
}
