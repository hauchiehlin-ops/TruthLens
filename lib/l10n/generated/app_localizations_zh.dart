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
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

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
  String inputPdfOcrProgress(int page, int total) {
    return 'PDF 文字層無法使用，正在以 OCR 辨識第 $page/$total 頁…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return '已透過 PDF OCR 匯入「$fileName」（$count 字元）';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '「$fileName」沒有可靠的文字層。請先設定 Web OCR，或改用支援原生 OCR 的安裝版，再重新匯入。';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '「$fileName」需要 OCR，但超過 $max 頁安全上限。請先分割 PDF 後分批匯入。';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return '無法可靠讀取「$fileName」。檔案可能已損壞、受密碼保護，或目前設定的 OCR 服務不支援。';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '「$fileName」是舊版 .doc 格式，無法可靠擷取文字內容。請在 Word 另存為 .docx 或匯出成 PDF 後再重新匯入。';
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
  String analysisPreliminaryResult(int percent) {
    return '初步結果：AI 機率 $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return '初步結果：AI 機率 $percent%（精修中…）';
  }

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
  String get modelCatalogLoadFailed => '無法載入模型目錄';

  @override
  String get modelCatalogEmpty => '暫無可用模型';

  @override
  String modelDownloadPathChip(String label) {
    return '$label下載路徑';
  }

  @override
  String get modelDownloadPathModelFile => '模型檔';

  @override
  String get modelDownloadPathCopied => '下載路徑已複製';

  @override
  String settingsSaveFailed(String error) {
    return '設定保存失敗：$error';
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
  String get settingsEngineWeightsTitle => 'AI 模型權重';

  @override
  String get settingsEngineWeightsSubtitle => '設定各引擎影響綜合結果的比例；合計必須為 100% 才能儲存。';

  @override
  String get settingsEngineInfoTooltip => '查看此引擎功能';

  @override
  String get settingsEngineTransformerHelp =>
      '使用多語言 Transformer 評估保留上下文的段落區塊，再將區塊分數映射回逐句報告。設定權重決定影響比例；AI 訊號決定實際貢獻。';

  @override
  String get settingsEngineStatisticalHelp =>
      '分析困惑度、可預測性、Burstiness 與句長變化。規律文字可能提高訊號，因此 ESL 修正可能降低其有效權重。';

  @override
  String get settingsEngineStylometryHelp =>
      '檢查重複開頭、公式化轉折與過度條列等可解釋風格特徵；未命中特徵時訊號為 0%。';

  @override
  String get settingsEngineAdversarialHelp =>
      '偵測可能經改寫或去除 AI 痕跡的文字。低分僅代表微弱殘餘訊號，不代表偵測成立。';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return '合計：$total% — 可以儲存';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return '合計：$total% — 請調整為正好 100%';
  }

  @override
  String get settingsEngineWeightsSave => '儲存權重';

  @override
  String get settingsEngineWeightsSaved => 'AI 模型權重已儲存於此裝置';

  @override
  String get settingsEngineWeightsRestoreDefaults => '恢復預設值';

  @override
  String get engineReasonDisabledByUser => '使用者在設定中關閉此引擎';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model：$total 句均未跨越強 AI 閾值；校準後的微弱訊號為 $percent%';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'AI 訊號指數 $percent/100';
  }

  @override
  String reportEngineDirectionalIndex(int percent) {
    return '弱方向 $percent/100';
  }

  @override
  String get reportEngineNoDirectionalSignal => '未形成方向性訊號';

  @override
  String get reportEngineSignalExplanation =>
      '各數值是診斷用證據指數，不是準確率。設定權重決定影響比例；沒有跨過門檻或折扣後方向的引擎顯示「未形成方向性訊號」，不再以 50% 冒充量測結果。';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return '$total 句均未跨越強改寫訊號閾值；校準後的微弱訊號為 $percent%';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$total 句中有 $count 句跨越強改寫訊號閾值；校準後的文件訊號為 $percent%';
  }

  @override
  String get settingsLinkVerificationTitle => '超連結與參考文獻目錄驗證';

  @override
  String get settingsLinkVerificationSubtitle =>
      '分析報告會將偵測到的網址與參考文獻條目比對 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 與可辨識的出版社目錄。查詢只會送出網址、DOI 或單筆書目的作者、篇名、年份及期刊欄位，不會傳送文件其餘內容。核心 AI 偵測仍在裝置端執行，此驗證可在此關閉。';

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
  String get modelImportWebUnsupported => '匯入自訂模型尚未支援於網頁版，請使用 App 版本。';

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
  String get reportEngineWeightLabel => '權重';

  @override
  String get privacySealNoticeText =>
      'TruthLens 零上傳安全認證：本檢測 100% 於裝置端離線計算，未經雲端傳輸與資料庫儲存。';

  @override
  String get reportModelCalibrationTitle => '模型基準自動校準';

  @override
  String get reportCommunityDiscoveredTag => '社群探尋 (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => '引擎明細';

  @override
  String get reportEngineNotInstalled => '未安裝';

  @override
  String get reportEngineLoadFailedBadge => '載入失敗';

  @override
  String get reportEngineAnalysisLevelTitle => '引擎分析層級';

  @override
  String get reportVerdictAiLikelihood => 'AI 傾向';

  @override
  String get reportVerdictHumanLikelihood => '人類自然寫作';

  @override
  String get reportRadarRoleTransformer => 'Transformer 分類器';

  @override
  String get reportRadarRoleStatistical => '統計特徵分析';

  @override
  String get reportRadarRoleStylometry => '風格特徵分析';

  @override
  String get reportRadarRoleAdversarial => '對抗式防禦';

  @override
  String get reportRadarAxisTransformer => '句級分類';

  @override
  String get reportRadarAxisStatistical => '語言規律';

  @override
  String get reportRadarAxisStylometry => '寫作風格';

  @override
  String get reportRadarAxisAdversarial => '改寫防禦';

  @override
  String get reportVerdictBadgeTitle => '綜合判定';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return '整體 AI 機率 $percent%';
  }

  @override
  String get reportVerdictHintHuman => '多數引擎訊號偏向自然人類寫作。';

  @override
  String get reportVerdictHintLikelyHuman => '整體偏人類，但仍保留少量模型不確定性。';

  @override
  String get reportVerdictHintMixed => '不同引擎訊號分歧，需搭配詳細分析判讀。';

  @override
  String get reportVerdictHintLikelyAi => '多個指標偏向 AI，建議檢查高分片段。';

  @override
  String get reportVerdictHintAi => '整體訊號高度偏向 AI 生成或改寫。';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return '綜合判定：$verdict，整體 AI 機率 $percent%。';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return '最高單項訊號是 $label（$percent%），但最終結果會依各引擎權重合併，不等於單一引擎結論。';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return '目前最大加權貢獻來自 $label（約 $points 個百分點）。';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '「未偵測到明顯 AI 寫作風格」只代表風格引擎沒有抓到固定句式或過渡詞模式；其他模型仍可能因語言規律、句級分類或改寫特徵把整體分數拉高。';

  @override
  String get reportSynthesisModelGap =>
      '有引擎未參與時，請先到模型管理使用「補齊推薦分析模型」；若仍失敗，詳細分析會列出是模型缺失、tokenizer 不支援、檔案遺失或 Web/ONNX Runtime 相容性限制。';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label 未參與本次加權投票，該面向暫以 0% 顯示。$hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return '角色權重 $weight%，對整體分數貢獻約 $points 個百分點$variantText。';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return '（已合併 $count 個模型變體）';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label 未參與本次投票。';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label 未回傳額外文字說明。';
  }

  @override
  String get reportEngineResolutionTransformer =>
      '解法：在模型管理下載並啟用多語言 Transformer；若已下載，重新下載模型與 tokenizer。';

  @override
  String get reportEngineResolutionAdversarial =>
      '解法：在模型管理重新下載改寫偵測模型與 tokenizer；Web 端請更新到已修補 BigInt 相容性的版本後重新分析。';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason。原因：Web 端 ONNX Runtime 回傳 BigInt 張量，舊版橋接無法轉換；已修補為 JS 端先轉 Number，請更新後重新分析。';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason。解法：切換到 catalog 內建模型，或重新下載模型與 tokenizer。';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason。解法：到模型管理點「補齊推薦分析模型」，並確認多語言 Transformer 標示為使用中。';
  }

  @override
  String get reportDetailAnalysisTitle => '詳細分析';

  @override
  String get reportNoEngineData => '尚無引擎分析數據';

  @override
  String get reportEngineNotParticipated => '未參與';

  @override
  String get reportAiContentReportTitle => 'AI 內容檢測報告';

  @override
  String reportAnalysisTimeLabel(String time) {
    return '分析時間：$time';
  }

  @override
  String get reportDownloadPdfButton => '下載 PDF';

  @override
  String get reportSuspiciousLocationsTitle => '可疑內容位置';

  @override
  String reportSentenceCount(int count) {
    return '共 $count 句';
  }

  @override
  String get reportAiProbabilityPrefix => 'AI 機率：';

  @override
  String get helpAdvantage5 =>
      '文件來源鑑識：讀取 .docx／.odt／.doc 的編輯紀錄（編輯時長、存檔次數、編輯批次分散度），這是獨立於文字判定的證據，與 AI 機率分開呈現。PDF 與圖片本身不帶編輯歷程，因此無法提供這類證據。';

  @override
  String get helpAdvantage6 =>
      '永遠提供最可能的 AI／非 AI 方向，並把方向與信心分開。文字太短、模型沉默、引擎不足或分歧過大時會降低信心，而不是把答案整個拿掉。';

  @override
  String get settingsAiSampleTitle => '新增 AI 產出樣本';

  @override
  String get settingsAiSampleSubtitle =>
      '背景校準只會自動蒐集人類樣本。要啟用學習式引擎權重，需另外提供已知由 AI 產出的文章——貼上或匯入後會立即分析並標記為 AI 樣本。';

  @override
  String get settingsAiSampleFromClipboard => '從剪貼簿貼上';

  @override
  String get settingsAiSampleFromFile => '匯入文件';

  @override
  String get settingsAiSampleAnalyzing => '分析中…';

  @override
  String settingsAiSampleAdded(int count) {
    return '已加入 AI 樣本，目前共 $count 份';
  }

  @override
  String get settingsAiSampleTooShort => '內容太短，無法作為樣本（至少需 100 字）';

  @override
  String get settingsAiSampleFailed => '沒有取得可用的內容';

  @override
  String get helpFormatCoverageTitle => '二之一、來源證據的格式限制';

  @override
  String get helpFormatCoverage =>
      '**重要限制：只有 .docx、.odt 與舊版 .doc 帶編輯紀錄。**\n\n| 來源 | 編輯紀錄 |\n|---|---|\n| .docx／.odt | ✅ 有 |\n| .pdf | ❌ 格式本質上沒有編輯歷程 |\n| .doc（舊版） | ✅ 有（OLE2 SummaryInformation） |\n| .txt／.md | ❌ 無容器 |\n| 圖片 OCR | ❌ 只剩像素 |\n| 直接貼上 | ❌ 沒有檔案 |\n\n這對第 3 支柱有直接影響：**只有帶編輯紀錄的文件會自動累積進「有統計保證」的基準集**。若你的收件流程全是 PDF，有保證的基準集永遠不會成長，只會累積無保證的參考樣本。\n\n若要讓來源證據與自動校準真正發揮作用，請取得 .docx 或 .odt 原始檔，而不是列印或轉存的 PDF。這是流程上的要求，不是軟體能繞過的限制——PDF 是輸出格式，本來就不記錄「怎麼寫出來的」。';

  @override
  String provenanceUnsupportedFormat(String format) {
    return '$format 這種格式本身就不攜帶編輯歷程，因此不是「紀錄被清除」，而是從來就沒有。只有 .docx 與 .odt 會記錄編輯時長、存檔次數與編輯批次。';
  }

  @override
  String get provenanceStripped =>
      '這是支援的格式，但檔案裡找不到編輯紀錄——通常代表它被另存新檔、線上轉檔，或從 Google 文件匯出過，這些動作都會把紀錄重置。';

  @override
  String get provenanceHowToGetRecord =>
      '若要讓來源證據發揮作用，請取得 **.docx、.odt 或 .doc 原始檔**（不是列印或轉存的 PDF）。只有原始檔才留有編輯歷程，也才能自動累積進有統計保證的基準集。';

  @override
  String get calibrationAutoTitle => '背景自動蒐集中';

  @override
  String get calibrationAutoSubtitle => '分析完成的文件會自動納入基準集，你不需要手動標註。';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return '已由編輯紀錄認定為人類撰寫：$auto 份；僅供參考的樣本：$observed 份';
  }

  @override
  String get calibrationAutoWhy =>
      '只有帶編輯紀錄（編輯時長、存檔次數、編輯批次分散）的文件才會納入統計保證的基準集，因為那是**獨立於文字判定**的證據。若改用本工具自己的判定結果來自動標註，等於拿自己的答案當標準答案——被誤判的真人作業永遠進不了基準集，門檻會越調越嚴，反而標記更多真人作業。貼上的純文字沒有編輯紀錄，因此只計入下方的參考百分位。';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return '參考：本文分數落在你已分析的 $count 份文件中的第 $percentile 百分位（此數值無統計保證）';
  }

  @override
  String get settingsAutoCollectTitle => '背景自動蒐集校準樣本';

  @override
  String get settingsAutoCollectSubtitle =>
      '分析完成後自動納入基準集。標籤依據為文件編輯紀錄，不會使用本工具自己的判定結果。';

  @override
  String get settingsStoreTextTitle => '保留原文以供離線驗證';

  @override
  String get settingsStoreTextSubtitle =>
      '開啟後，加入基準集的文章會連同原文一起保存在本機，之後可匯出成語料檔進行離線評測。';

  @override
  String get settingsStoreTextWarning =>
      '原文多為他人作品，屬敏感資料。僅在你確實要蒐集離線驗證語料時開啟，匯出後可用下方「清除已保存的原文」立即移除；清除不影響共形預測（它只需要分數）。';

  @override
  String get settingsExportCorpusTitle => '匯出校準語料';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return '可匯出：人類 $human 份、AI $ai 份（離線評測每類需 $required 份）';
  }

  @override
  String get settingsExportCorpusButton => '匯出為 JSONL';

  @override
  String get settingsExportCorpusEmpty => '沒有可匯出的樣本——請先開啟「保留原文」再累積基準集';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return '已匯出 $count 份（略過 $skipped 份未保留原文的樣本）';
  }

  @override
  String get settingsClearStoredText => '清除已保存的原文';

  @override
  String get settingsClearStoredTextDone => '已清除所有原文，分數與校準結果保留不變';

  @override
  String get helpDesignTitle => '設計理念與已知限制';

  @override
  String get helpShiftTitle => '一、核心定位轉換：不比誰的分數準';

  @override
  String get helpShiftBody =>
      '市面上的偵測器幾乎都在回答同一個問題：「這段文字看起來像不像 AI 寫的？」\n\n這是一場必輸的軍備競賽。模型越強，生成文字的統計特徵就越接近人類；而改寫工具的進步速度遠快於偵測器。在這條路上，伺服器端的大模型只是輸得慢一點。\n\nTruthLens 改問另一個問題：「關於這份文件是怎麼產生的，我們手上有哪些證據？各自有多強？」\n\n也就是從「文字風格推測」轉向「來源證據 ＋ 統計上誠實的結論」。這是為什麼本工具刻意不追求單一分數的準確度排名，而是把每一項證據分開攤給你看，並在證據不足時明白說不知道。瀏覽器端執行帶來的真正優勢不是推論速度，而是它看得到伺服器看不到的東西——完整的檔案，以及你自己蒐集的族群基準。';

  @override
  String get helpPillarsTitle => '二、五個支柱';

  @override
  String get helpPillarsBody =>
      '1. 文件來源鑑識（已上線）\n讀取 DOCX／ODT 容器內的編輯紀錄：編輯總時長、存檔次數、建立與修改時間，以及正文的編輯批次標記（RSID）。整篇文章只有一兩組 RSID，通常代表內容是一次寫入的；3000 字卻只編輯 4 分鐘，這個證據比任何困惑度分數都硬。這屬於來源證據，與 AI 機率分開呈現，刻意不併入分數。\n\n2. 本地基準校準與共形預測（已上線）\n你可以把確定由作者本人撰寫的文章加入基準集，系統改以這個族群自己的分布判斷，而非全球通用門檻。共形預測提供分布無關的保證：若基準與待測樣本可交換，偽陽性率不超過你設定的 α。這是降低非母語寫作誤判的關鍵，也是商用產品做不到的——它們沒有這批作者的基準寫作。\n\n3. 學習式引擎權重（已上線）\n當基準集同時累積人類與 AI 兩類樣本後，系統以 Cohen\'s d 效果量衡量每個引擎分開這兩組的能力，據此建議權重，取代手調的固定比例。需你按下「套用」才會生效，不會靜默改動設定。\n\n4. 交叉困惑度 Binoculars（評分核心已完成，尚未上線）\n裸 perplexity 把「文字好不好預測」直接當成「像不像 AI」，因此對用詞平實的非母語寫作有系統性偽陽性。Binoculars 改以「好預測的程度相對於兩個模型彼此分歧的程度」來衡量。評分數學已實作並通過測試，但要真正啟用還需要一組能在瀏覽器執行的小型語言模型配對，以及標註資料的效果驗證。\n\n5. 浮水印偵測（經查證不可行，未實作）\nSynthID-Text 的偵測綁定金鑰：偵測器必須用與生成時相同的金鑰計算，而 Google 生產環境的金鑰並未公開。在瀏覽器端做這件事，對 ChatGPT、Claude、Gemini 的真實輸出永遠不會命中，只會變成永不觸發卻讓人誤以為有在檢查的假功能，因此主動不做。';

  @override
  String get helpCascadeTitle => '三、分級分析與整合判讀';

  @override
  String get helpCascadeBody =>
      '分析依序執行文件來源、統計與風格特徵、Transformer 句級分類，以及必要時才啟動的交叉困惑度。\n\n六個證據面向各自回答不同問題，因此分開呈現。作者判讀只接受直接文字痕跡，並可由確定的逐步寫作、文件來源或漸進草稿證據向非 AI 修正。缺少引用、偏離任務、整段貼上、修訂很少或中繼資料異常仍列為待核查事項，但不能單獨把文件判成 AI。\n\n信心會獨立計算。可分析句少於 5 句、內容少於 100 字、引擎少於 2 個、模型沉默或分歧過大時，都會降低信心並顯示限制警告。方向仍可用於篩查，但低信心結果不得當成定案證明。';

  @override
  String get helpRisksTitle => '四、必須誠實面對的風險';

  @override
  String get helpRisksBody =>
      '以下每一項都是本工具真實存在的限制，請在做出任何決定前一併考慮：\n\n1. 來源證據可以被清除或偽造\n另存新檔、線上轉檔、從 Google 文件匯出、或複製到新檔案，都會讓編輯紀錄歸零。因此有訊號只是佐證，沒有訊號也絕不代表文件必然由人撰寫。\n\n2. 共形保證依賴「可交換性」\n保證成立的前提是基準樣本與待測文章出自同一群人、同一類寫作任務。作者寫作能力明顯進步、或換了完全不同的任務類型，前提就不再成立，需要重建基準集。\n\n3. 基準集本身可能被汙染\n如果拿來當基準的作業其實是 AI 代寫的，整個校準都會偏掉。基準樣本必須在可控環境下蒐集，例如在可控環境下當場完成的作品。\n\n4. 瀏覽器端小模型的原始準度不如伺服器端大模型\n這是 Web-only 決策換取隱私的必然代價。本工具的價值不是神奇地給出精準單一分數，而是提供可解釋的方向、明確信心與證據限制。\n\n5. 任何分數都不應單獨作為指控的依據\n請務必搭配逐句證據、文件來源，以及你對這位作者既有的了解一起判讀。本工具的設計目標是輔助你進行對話，不是代替你做出裁決。';

  @override
  String get calibrationAddHuman => '加入為「人類撰寫」基準';

  @override
  String get calibrationAddAi => '加入為「AI 產出」樣本';

  @override
  String calibrationCounts(int human, int ai) {
    return '基準集：人類 $human 份、AI $ai 份';
  }

  @override
  String get learnedWeightsTitle => '學習式引擎權重';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return '目前人類 $human 份、AI $ai 份。兩類各需至少 $required 份才能學出可靠的權重；在此之前沿用你手動設定的權重。';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return '已可依你的 $human 份人類樣本與 $ai 份 AI 樣本學出權重。';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine：建議權重 $weight%（分離度 $effect）';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return '注意：$engine 把兩組判反了（AI 樣本反而拿到較低分數），因此權重歸零。這通常代表該引擎不適用於你這類文本。';
  }

  @override
  String get learnedWeightsApply => '套用學習到的權重';

  @override
  String get learnedWeightsApplied => '已套用學習到的權重';

  @override
  String get learnedWeightsExplain =>
      '權重依各引擎「把你的人類樣本與 AI 樣本分開」的程度計算（Cohen\'s d 效果量）：分得越開、組內越穩定的引擎權重越高。這會取代手調的固定權重，讓集成貼合你自己的文本類型。';

  @override
  String get calibrationTitle => '本地基準校準';

  @override
  String get calibrationEmpty =>
      '尚未建立基準集。加入若干份「確定由作者本人撰寫」的文章後（例如在可控環境下當場完成的作品），系統就能改用這個族群自己的分布來判斷，而不是套用全球通用的門檻——這正是降低非母語寫作偽陽性的關鍵。';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return '基準集目前 $count 份，要讓 $alpha% 的偽陽性率上限真的成立，至少需要 $required 份。在補齊之前只顯示參考數值，不會據此標記任何文章。';
  }

  @override
  String calibrationFlagged(int alpha) {
    return '在 $alpha% 偽陽性率上限的設定下，本文**被標記**。';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return '在 $alpha% 偽陽性率上限的設定下，本文**未被標記**。';
  }

  @override
  String calibrationPValue(String value, int count) {
    return '保守 p 值 $value（相對於 $count 份基準樣本）';
  }

  @override
  String calibrationPercentile(int percentile) {
    return '分數落在基準集的第 $percentile 百分位';
  }

  @override
  String get calibrationCaveat =>
      '這個保證的前提是「基準樣本與待測文章可交換」——也就是出自同一群人、同一類寫作任務。若作者的寫作能力明顯進步、或換了完全不同的任務類型，前提就不再成立，需要重新建立基準集。另請注意：若基準樣本本身就是 AI 代寫的，整個校準都會偏掉，取樣必須在可控環境下進行。';

  @override
  String get calibrationAddButton => '把這份加入基準集';

  @override
  String calibrationAdded(int count) {
    return '已加入基準集，目前共 $count 份';
  }

  @override
  String get settingsCalibrationTitle => '本地基準校準集';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return '目前 $count 份（此 α 需要 $required 份）';
  }

  @override
  String get settingsCalibrationClear => '清空基準集';

  @override
  String get settingsCalibrationCleared => '基準集已清空';

  @override
  String get settingsAlphaTitle => '偽陽性率上限（α）';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return '目前 $alpha% — 數值越低越保守，但需要越多基準樣本（至少 $required 份）';
  }

  @override
  String get abstentionHeadline => '證據不足，不做判定';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return '只有 $count 個可分析句段（至少需要 $required 個才能衡量句段穩定度）。因此會降低信心，但符合條件的文件級訊號仍可參與判讀。';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return '內容只有 $count 字（至少需要 $required 字）。文字量太少時，任何寫作特徵都可能只是偶然。';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return '只有 $available/$total 個引擎參與投票，無法多角度交叉驗證。請到模型管理補齊後重跑。';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return '各引擎的看法相差 $spread 個百分點，分歧大到加權平均已失去意義。請改用逐句證據與文件來源自行判讀。';
  }

  @override
  String get abstentionNoEvidenceFound =>
      '所有引擎都有執行，但沒有任何一個找到可用證據。這個低分只是診斷用的 fallback 輸出，不是人類撰寫的證據。';

  @override
  String abstentionSingleWeakEvidenceSource(int count) {
    return '只有 $count 個引擎找到可用證據，而且整體分數仍低於 AI 標記門檻。這代表本次證據覆蓋不足，不代表已證明由人類撰寫。';
  }

  @override
  String get abstentionScoreStillShown => '下方仍保留完整的分數與逐句證據供你自行參考，但請不要把它當成結論。';

  @override
  String get provenanceTitle => '文件來源證據';

  @override
  String get provenanceRiskHigh => '編輯紀錄明顯不尋常';

  @override
  String get provenanceRiskMedium => '編輯紀錄有可疑之處';

  @override
  String get provenanceRiskLow => '編輯紀錄看起來正常';

  @override
  String get provenanceRiskUnknown => '沒有可用的編輯紀錄';

  @override
  String get provenanceNoMetadata =>
      '這份輸入沒有夾帶編輯紀錄（直接貼上的文字、PDF、或紀錄已被清除），因此無法從來源判斷，只能看文字本身的分析。';

  @override
  String provenanceEditingDuration(int minutes) {
    return '檔案記錄的編輯總時長：$minutes 分鐘';
  }

  @override
  String provenanceRevisionCount(int count) {
    return '存檔次數：$count 次';
  }

  @override
  String provenanceApplication(String name) {
    return '產生軟體：$name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return '正文的編輯批次標記只有 $count 組，但內容有 $words 字。正常一邊想一邊寫會留下數十組，這種高度集中通常代表整段是一次寫入的（例如貼上）。';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words 字對上 $minutes 分鐘的編輯時長，平均每分鐘 $wpm 字，遠高於一般人能持續維持的打字速度。';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return '檔案記錄的編輯總時長接近 0，但正文有 $words 字。';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return '$words 字的內容只存檔過 $count 次。';
  }

  @override
  String get provenanceCaveat =>
      '請注意：這些紀錄可以被清除或重置——另存新檔、線上轉檔、從 Google 文件匯出、或複製到新檔案都會讓它歸零。因此有訊號只能當作佐證，不能單獨當成結論；沒有訊號也不代表文件必然由人撰寫。';

  @override
  String get telemetrySummaryTitle => '分析總結';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '$total 個引擎中有 $engines 個跑完了，整體 AI 機率 $percent%，判定為「$verdict」。';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return '各引擎看法蠻一致的，最高 $high%、最低 $low%，這個結論算站得住腳。';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return '引擎之間看法不太一樣：$highLabel給了 $high%，$lowLabel卻只有 $low%，這種時候別只看總分，往下翻逐句證據會準得多。';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return '把分數拉上來的主要是$label，大約貢獻了 $points 個百分點。';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return '逐句掃過 $total 句，沒有任何一句踩到強 AI 訊號線。';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return '逐句掃過 $total 句，其中 $count 句踩到強 AI 訊號線，值得一句一句看過。';
  }

  @override
  String get telemetrySummaryAdviceHuman => '整體讀起來就是人自己寫的，沒有特別需要追查的地方。';

  @override
  String get telemetrySummaryAdviceMixed =>
      '這份落在灰色地帶，光憑分數下結論太冒險，建議搭配逐句證據和文件來源一起看。';

  @override
  String get telemetrySummaryAdviceAi => '訊號明顯偏向 AI 生成或改寫，建議把標紅的句子逐一核對過再做決定。';

  @override
  String telemetrySummaryModelGap(int count) {
    return '另外有 $count 個引擎這次沒參與投票，把握度會打點折；到模型管理補齊後重跑會更準。';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'AI 機率 < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'AI 機率 $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'AI 機率 ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return '信心度低：可用模型權重不足 60%（$threshold% 閾值）。$available/$total 引擎參與投票。建議參考各引擎詳細分析結果。';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return '信心度高：$available/$total 個檢測模型達成共識（$threshold% 以上權重同意此判定）';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return '信心度低（$available/$total）';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return '信心度高（$available/$total）';
  }

  @override
  String get reportMetricAiSentenceRatio => '強 AI 訊號句比例';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$total 句中有 $count 句跨越 60% 強訊號閾值';
  }

  @override
  String get reportMetricElapsed => '分析耗時';

  @override
  String get reportMetricElapsedNormal => '0.5-5s 正常';

  @override
  String get reportMetricReliability => '可信度';

  @override
  String get reportReliabilityLow => '低';

  @override
  String get reportReliabilityHigh => '高';

  @override
  String get reportReliabilityNeedsReview => '需人工驗證';

  @override
  String get reportReliabilityHighTrust => '高度可信';

  @override
  String get reportSentenceAnalysisTitle => '逐句分析';

  @override
  String get suspiciousFilterAll => '可疑';

  @override
  String get suspiciousFilterHigh => '高危';

  @override
  String get suspiciousFilterMedium => '中等';

  @override
  String get suspiciousExcludedTooltip => '已排除單一字母、頁碼、章節序號與過短 OCR/PDF 片段。';

  @override
  String suspiciousCount(int count) {
    return '$count 項';
  }

  @override
  String get suspiciousEmpty => '無可疑內容';

  @override
  String get suspiciousRiskHigh => '高';

  @override
  String get suspiciousRiskMedium => '中';

  @override
  String get suspiciousReasonHighModelSignals => '多個模型訊號高度偏向 AI';

  @override
  String get suspiciousReasonSentenceSignal => '句級模型訊號偏高';

  @override
  String suspiciousOriginalLocation(String location) {
    return '原文位置 $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return '原文位置 $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return '句子 #$number';
  }

  @override
  String get suspiciousEvidenceLabel => '判定依據：';

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
  String get reportLinkCitationUnreachable => '無法確認（連線逾時或書目服務無回應）';

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
  String get reportBibRecheckAllUnreliableButton => '重新查核全部未通過文獻';

  @override
  String get reportBibRecheckOneTooltip => '重新查核此筆文獻';

  @override
  String get reportBibResultHint =>
      '依作者、年份、篇名與期刊資訊交叉比對 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 與可辨識的出版社目錄；高可信度結果必須有 DOI 登記或多個一致的書目欄位，未達可靠匹配者標示為未通過核實。Google Scholar 因未提供自動查詢 API，僅供使用者主動人工複核。';

  @override
  String reportBibVerificationSource(String source) {
    return '核實依據：$source';
  }

  @override
  String get reportBibGoogleScholarManualLookup => '前往 Google Scholar 人工複核';

  @override
  String reportBibHighConfidence(String journal) {
    return '高可信度：應存在$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（登記於《$journal》）';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return '期刊名稱不一致：文件載為《$reported》，查核登記為《$registered》，請核對此筆文獻。';
  }

  @override
  String get reportBibNotFound => '查無相近匹配，可能為虛構文獻';

  @override
  String get reportBibUncertain => '疑似不可靠，未通過登記資料核實';

  @override
  String reportBibTruncated(int max, int count) {
    return '將逐筆核實全部文獻（共偵測到 $count 筆）';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return '已完成 $count 筆，結果會持續更新。';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return '進度 $completed/$total，$current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return '目前：$text';
  }

  @override
  String get reportBibProgressFinalizing => '正在整理結果';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base：找到相似候選「$candidate」，但作者、年份或篇名未達可靠匹配門檻。';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base：查核來源無可靠回應或條目資訊不足，系統不將此文獻視為已核實存在。';
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
    return '本文較可能是 AI 生成，建議進一步審查（整合 AI 可能性 $percent%）';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return '這段文字呈現人類與 AI 混合的特徵（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return '本文較可能不是 AI 生成（整合 AI 可能性 $percent%）';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return '這段文字極可能為人類撰寫（AI 機率 $percent%）';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return '整體 AI 機率越過固定的 $percent% 閾值，被標記為 AI。';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '整體 AI 機率未達 $percent% 標記閾值。';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return '整體 AI 機率為 $aiPercent%，已達固定的 $thresholdPercent% AI 標記門檻，因此報告會標記為 AI。建議搭配句級證據與各引擎理由再做最終判斷。';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '整體 AI 機率為 $aiPercent%，低於固定的 $thresholdPercent% AI 標記門檻，因此報告不會正式標記為 AI；機率與證據仍會保留供你檢視。';
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
    return '語言模型困惑度偏低（$ppl）[偏 AI 特徵]，文本規律性與可預測度高';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return '語言模型困惑度偏高（$ppl）[偏人類特徵]，符合人類寫作不可預測性';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return '語言模型困惑度中等（$ppl）[中性特徵]';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return '句子長度高度一致（burstiness $value）[偏 AI 特徵]，節奏平穩均勻';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return '句長起伏顯著（burstiness $value）[偏人類特徵]，節奏變化豐富';
  }

  @override
  String engineReasonBurstinessMid(String value) {
    return '句長變化（burstiness $value）落在 0.30–0.55 中性帶，未形成方向性證據';
  }

  @override
  String engineReasonTtrLow(String value) {
    return '詞彙重複度較高（TTR $value）[偏 AI 模板/固定格式特徵]';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return '詞彙多樣性豐富（TTR $value）[偏人類特徵]';
  }

  @override
  String engineReasonMattrNoAiSignal(String value, String cut) {
    return '詞彙多樣性（MATTR $value）未跨過校準後的 AI 訊號切點 $cut';
  }

  @override
  String engineReasonStatisticalSummaryAi(String percent) {
    return '綜合統計分析：合格指標偏向 AI 生成特徵（訊號指數 $percent/100）';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return '綜合統計分析：合格指標偏向人類自然寫作（AI 訊號指數 $percent/100）';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return '綜合統計分析：合格指標方向互有消長（AI 訊號指數 $percent/100）';
  }

  @override
  String get reportFormulaTitle => '加權計算透明度與參數解析';

  @override
  String get reportFormulaExplanation => '整體 AI 機率係由各可用引擎之判定機率依其指定權重加權平均計算得出：';

  @override
  String get reportFormulaActiveEngines => '參與投票引擎與權重';

  @override
  String get reportFormulaCalculation => '加權計算公式';

  @override
  String get reportFormulaFinalResult => '最終加權 AI 機率';

  @override
  String get reportFormulaEslApplied => '已套用 ESL 非母語寫作偏差修正（統計模型權重已減半）';

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
  String engineReasonPan25LexicalAi(int percent) {
    return 'PAN 2025 詞彙指紋偏向 AI（$percent/100）；這項獨立英文基準偵測到詞語與片語分布不同於其人類語料';
  }

  @override
  String engineReasonPan25LexicalHuman(int percent) {
    return 'PAN 2025 詞彙指紋偏向真人（$percent/100）；這仍是模型證據，不是作者身分證明';
  }

  @override
  String engineReasonPan25LexicalNeutral(int percent) {
    return 'PAN 2025 詞彙指紋落在中性區（$percent/100），不提供方向';
  }

  @override
  String engineReasonCompressionCoherence(String value) {
    return '跨半段壓縮一致性（$value）超過 PAN 2025 人類語料第 95 百分位篩線［弱 AI 方向訊號］';
  }

  @override
  String engineReasonAssistantResponseArtifact(int count) {
    return '偵測到 $count 處聊天助理回覆殘留，例如稱呼提問者或主動表示可修改受託文字';
  }

  @override
  String get engineReasonAdversarialNotInstalled => '改寫偵測模型尚未安裝，未參與本次投票';

  @override
  String get engineReasonTransformerNotInstalled => '模型尚未安裝或使用中模型未支援，未參與本次投票';

  @override
  String get modelRepairNoActiveVariant => '未找到使用中的模型；請在模型管理下載推薦模型。';

  @override
  String get modelRepairCustomRemoved =>
      '已移除載入失敗的自訂模型。自訂模型無法自動重新下載，請重新匯入模型與 tokenizer。';

  @override
  String get modelRepairNoSource =>
      '已移除載入失敗的模型檔，但目前找不到可重新下載的 catalog 來源；請到模型管理重新下載推薦模型。';

  @override
  String modelRepairRedownloaded(Object name) {
    return '偵測到模型檔可能損毀或不相容，已自動重新下載 $name；請重新執行分析。';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return '已移除載入失敗的模型檔，但自動重新下載未完成；請確認網路後在模型管理重新下載 $name。';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      '未找到使用中的 Transformer 模型；請到模型管理下載或設為使用中';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return '使用中模型的 tokenizer 類型不支援（$tokenizer）；請切換到支援 bert-wordpiece 或 roberta-bpe 的模型';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Transformer 模型或 tokenizer 路徑缺失；請在模型管理重新下載';

  @override
  String get engineTransformerMissingFiles =>
      'Transformer 模型或 tokenizer 檔案不存在；請在模型管理重新下載';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'ONNX opset 版本不支援（該模型版本太新，需更新應用）: $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Tokenizer 格式損毀: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      '模型載入或推論失敗，且自動修復未完成；請到模型管理重新下載使用中的 Transformer 模型與 tokenizer。';

  @override
  String get engineAdversarialNoActiveVariant => '未找到使用中的改寫偵測模型';

  @override
  String get engineAdversarialMissingFiles => '模型或 tokenizer 檔案不存在，請在模型管理重新下載';

  @override
  String get engineAdversarialRepairFailed =>
      '模型載入或推論失敗，且自動修復未完成；請到模型管理重新下載改寫偵測模型與 tokenizer。';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return '模型未參與本次投票。$error';
  }

  @override
  String get patternNotAnalyzable => '片段過短或疑似 PDF/OCR 噪音，未作 AI 句級判讀';

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
      'TruthLens 是一款**完全在瀏覽器端執行**的 AI 內容檢測工具。四個文字分析引擎檢查直接文字痕跡；寫作過程、文件來源及來源完整性則作為分開呈現的鑑識證據，文件內容不會上傳到任何伺服器。\n\n只有具作者特異性的訊號能提高 AI 判定。報告固定提供較可能是 AI／較可能不是 AI 的方向、整合可能性指數與獨立信心等級。文字模型原始分數及每一條證據仍會分開顯示，避免低信心方向被包裝成確定證明。';

  @override
  String get helpComparisonTitle => '與市面主流工具比較';

  @override
  String get helpComparisonDisclaimer =>
      '以下比較依各工具官方公開資訊與一般市場認知整理，僅供功能定位參考，非第三方認證的效能實測數據。';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero 的運算主要在雲端進行、文件需上傳；TruthLens 四個偵測引擎皆在你的瀏覽器內執行，文件內容不外傳。';

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
      'Originality.ai 為按篇計費的訂閱制，且需將文件上傳雲端；TruthLens 核心運算在瀏覽器端完成，無需訂閱也無使用次數限制。';

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
      'Winston AI 的 OCR 圖片辨識需上傳圖片至雲端；TruthLens 的 OCR 優先使用你自行設定的本地 OCR 伺服器，只有在你主動提供 Gemini API 金鑰時才會使用雲端備援——用不用雲端由你決定。';

  @override
  String get helpVsWinston2 =>
      'Winston AI 以報告排版精美著稱；TruthLens 提供 AI 動態生成排版報告（未安裝 LLM 時自動退回模板），可匯出 PDF／CSV／JSON／PNG 四種格式。';

  @override
  String get helpAdvantagesTitle => 'TruthLens 的獨有優勢';

  @override
  String get helpAdvantage1 =>
      '超連結與文獻真實性驗證：檢查網址是否可連線，以 Crossref／DataCite 核實 DOI 登記，並透過 OpenAlex、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 與出版社目錄交叉比對書目資料；每筆通過核實的文獻會標示證據來源，Google Scholar 僅供人工複核。';

  @override
  String get helpAdvantage2 =>
      '文獻參考真實性核實：即使參考文獻沒有超連結（純作者—年份格式），也能透過書目比對抓出可能虛構的引用——這正是 AI 幻覺內容常見的破綻。';

  @override
  String get helpAdvantage3 =>
      'ESL（非母語寫作者）偏差修正：自動偵測非母語寫作特徵並降低統計模型權重，避免將非母語人士的自然寫作誤判為 AI。';

  @override
  String get helpAdvantage4 =>
      '本機紀錄與匯出：報告可匯出 PDF／CSV／JSON／PNG，歷史紀錄只保存在本機，並在有匯入檔案時保留來源檔名，方便重新分析或回顧。';

  @override
  String get helpWorkflowTitle => '完整操作流程';

  @override
  String helpWorkflowStepLabel(int step) {
    return '第 $step 步';
  }

  @override
  String get helpWorkflowStep1Title => '模型下載與更新';

  @override
  String get helpWorkflowStep1Body =>
      '首次啟動會引導安裝核心偵測模型；之後可隨時至「設定 → AI 模型管理」查看、下載、更新或移除。App 會在啟動時主動比對最新版本，若有更新，設定齒輪圖示與「AI 模型管理」項目會出現紅點提示。';

  @override
  String get helpWorkflowStep2Title => '如何選用模型（目的與效果）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      '多語言 AI 分類器（權重 40%）：以受控段落區塊保留上下文，再將機率映射回逐句證據。';

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
      '可在「設定」個別啟用／停用引擎、調整引擎權重。五個判定級距採固定切點（20%／40%／60%／80%），不提供調整，因此同一份文件在任何人手上都會得到相同判定。';

  @override
  String get helpWorkflowStep3Title => '加入內容';

  @override
  String get helpWorkflowStep3Body =>
      '三種輸入方式：直接貼上文字、圖片辨識 OCR、匯入文件（txt / md / pdf / docx / doc / odt）。PDF 匯入會比較兩套文字層解析結果並排除亂碼；掃描型 PDF 在 OCR 可用時會自動逐頁辨識。匯入文件時，檔名會顯示在輸入頁標題下方，並單獨成行出現在報告標題；貼上或手動輸入文字時，檔名維持空白。\n\nOCR 會優先使用你設定的本地伺服器，只有在你自行提供 Gemini API 金鑰時才使用雲端備援。';

  @override
  String get helpWorkflowStep4Title => '開始分析';

  @override
  String get helpWorkflowStep4Body =>
      '點擊「開始檢測」，四個引擎並行執行，畫面即時顯示各引擎完成進度。若偵測到非母語寫作特徵，會自動套用 ESL 偏差修正（可在設定關閉）。分析進行中可隨時從工具列中止；文件文字會保留，但未完成的結果不會被儲存。';

  @override
  String get helpWorkflowStep5Title => '查看與匯出結果';

  @override
  String get helpWorkflowStep5Body =>
      '文件匯入、四引擎即時進度與完整報告現在都保留在同一個戰情中心工作台。可隨時切換「指揮網格」、「任務時間軸」與「證據畫布」，不會中斷或重新分析；自動模式在桌面使用指揮網格、手機使用任務時間軸。結果包含整體判定、AI 機率、信心度、耗時、逐句證據、引擎貢獻、連結與文獻核實，並可匯出 PDF、CSV、JSON、PNG及保存至本機歷史。';

  @override
  String get helpWorkflowStep1ChipOnboarding => '首次啟動引導';

  @override
  String get helpWorkflowStep1ChipModelManager => '模型管理中心';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => '自動版本偵測';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => '統計分析 (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => '風格特徵 (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => '對抗防禦 (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => '報告 LLM (選用)';

  @override
  String get helpWorkflowStep3ChipPaste => '直接貼上';

  @override
  String get helpWorkflowStep3ChipImageOcr => '圖片 OCR';

  @override
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation => '碼段/公式隔離';

  @override
  String get helpWorkflowStep4ChipEnsemble => '四引擎並列推論';

  @override
  String get helpWorkflowStep4ChipLiveProgress => '即時動態進度';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'ESL 非母語寫作校正';

  @override
  String get helpWorkflowStep4ChipStoppable => '隨時可中止';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'AI 總覽儀表';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => '句級熱力圖';

  @override
  String get helpWorkflowStep5ChipCitationVerification => '文獻驗證';

  @override
  String get helpWorkflowStep5ChipExportFormats => 'PDF / CSV / JSON / PNG 匯出';

  @override
  String get helpTuningTitle => '模型下載與調適教學（零基礎）';

  @override
  String get helpTuningStep1Title => '開啟模型管理畫面';

  @override
  String get helpTuningStep1Body =>
      '可從完整「設定」頁，或寬螢幕首頁右側設定面板，開啟「AI 模型管理」來下載、更新、啟用或移除本機模型。';

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
      '若你已在其他地方取得或自行微調過相容的 .onnx 模型，可透過「設定 → 自訂 ONNX 模型匯入與測試」匯入——需提供模型檔、對應的 Tokenizer 設定（或選擇「不需要」）與 AI 類別索引；匯入前會自動偵測是否為重複匯入的相同檔案，避免不小心重複安裝。也可在設定中調整四引擎權重。';

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
  String get privacyWebOverview1 =>
      'TruthLens 完全以網頁應用程式的形式在您的瀏覽器分頁中執行，不需要安裝；文件文字與分析結果不會離開您的裝置，下載的偵測模型也只快取在瀏覽器自身的沙盒儲存空間（OPFS）中，不在任何伺服器上。';

  @override
  String get privacyWebOverview2 =>
      '只有在您主動選擇匯入、掃描或貼上時，本頁才會讀取對應的檔案、圖片或剪貼簿內容；不會讀取其他分頁、其他網站的資料，或您未選擇的檔案。';

  @override
  String get privacySectionOverviewWeb => '概要';

  @override
  String get privacyRemoveWeb => '在瀏覽器設定中清除本網站的資料（或直接關閉分頁即可，因為沒有任何內容儲存在伺服器上）';

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
      '您輸入、貼上或匯入的文字內容，皆在您的裝置上由本機 AI 模型完成分析。TruthLens 不會將文件文字上傳到自有伺服器或第三方 AI 偵測服務。';

  @override
  String get privacyDataHandling3 =>
      '分析結果與歷史紀錄僅儲存在您瀏覽器裝置本機的儲存空間中；紀錄包含分析文字、分數、時間，以及匯入文件時的來源檔名。在 App 內清除歷史紀錄，或在瀏覽器中清除本網站資料，即會移除此本機副本，TruthLens 不持有任何副本。';

  @override
  String get privacyNetworkIntro => '本 App 的核心 AI 偵測完全在裝置端執行，但下列支援或選用功能需要連線：';

  @override
  String get privacyNetwork1 =>
      '1. 模型目錄與下載：連至 GitHub Releases／Hugging Face 下載您選擇的偵測模型檔案，僅為下載模型，不會上傳任何使用者資料。';

  @override
  String get privacyNetwork2 => '2. 模型更新偵測：App 啟動時會連線比對版本號，僅傳送版本資訊，用於提示是否有新版本。';

  @override
  String get privacyNetwork3 =>
      '3. 超連結與參考文獻真實性驗證：預設開啟，可在「設定」關閉。開啟時，會將偵測到的網址、DOI 或單筆書目的作者、篇名、年份與期刊欄位送往目標網站及／或 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 與可辨識的出版社目錄查詢，不會傳送文件其餘內容。只有使用者按下人工複核按鈕時，才會將該筆查詢送往 Google Scholar。';

  @override
  String get privacyNetwork4 =>
      '4. Web OCR 備援：僅 Web 版適用。OCR 會優先使用您設定的本地 OCR 伺服器；若您選擇輸入 Gemini API 金鑰，所選圖片及需要 OCR 的 PDF 頁面影像會由瀏覽器直接送往 Google Gemini API，金鑰只儲存在該瀏覽器的 localStorage。';

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

  @override
  String settingsVersionSubtitle(String version, String build) {
    return '版本 $version（Build $build）· 本地優先的隱私檢測引擎';
  }

  @override
  String get webOcrSettingsTitle => 'Web OCR 設定';

  @override
  String get webOcrPurpose => '在分析前辨識上傳圖片中的印刷或手寫文字。';

  @override
  String get webOcrGeminiKeyTitle => 'Gemini API 金鑰（可選）';

  @override
  String get webOcrGetKeyButton => '取得金鑰';

  @override
  String get webOcrGeminiDescription => '僅在本地 OCR 伺服器無法使用時啟用，金鑰只儲存在此瀏覽器。';

  @override
  String get webOcrLocalServerTitle => '本地 OCR 伺服器（建議）';

  @override
  String get webOcrLocalServerDescription =>
      '在您的電腦上執行 OCR；macOS 使用 Apple Vision，Windows 使用 Windows OCR。請在下方填入本地端點。';

  @override
  String get webOcrSetupGuideButton => '零基礎設定指引';

  @override
  String get webOcrPriorityTitle => '辨識順序';

  @override
  String get webOcrPriorityDescription =>
      '1. 已設定 URL 時優先使用本地 OCR\n2. 已設定金鑰時改用 Gemini\n3. 兩者皆失敗時顯示具體診斷原因';

  @override
  String get webOcrSetupGuideTitle => '設定本地 OCR 伺服器';

  @override
  String get webOcrSetupGuideBody =>
      '1. 點選下方「開啟 OCR 專案」。\n2. macOS：下載 setup_and_run_ocr.sh，開啟「終端機」，執行：bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows：下載 setup_and_run_ocr.bat，按兩下執行並允許安裝要求。\n4. 等待安裝程式顯示 OCR 已就緒；它也會設定登入後自動啟動。\n5. 回到此處，填入 http://127.0.0.1:5001/ocr，再按「測試連線」。\n6. 開啟圖片 OCR，選一張清晰圖片確認能辨識文字。\n\n使用 127.0.0.1 時，瀏覽器與 OCR 伺服器必須在同一台電腦執行。測試失敗時，請確認安裝已完成、連接埠 5001 未被封鎖，且網址以 /ocr 結尾。';

  @override
  String get webOcrOpenProjectButton => '開啟 OCR 專案';

  @override
  String get webOcrTestServerButton => '測試連線';

  @override
  String get webOcrTestServerMissingUrl => '請先輸入本地 OCR 伺服器網址。';

  @override
  String get webOcrTestServerSuccess => '本地 OCR 伺服器已啟動並可使用。';

  @override
  String get webOcrTestServerFailure => '無法連上本地 OCR 伺服器，請開啟設定指引並檢查安裝程式、防火牆與網址。';

  @override
  String get workspaceModeSectionTitle => '工作台模式';

  @override
  String get workspaceModeSectionSubtitle => '選擇文件、即時分析與最終證據在同一工作台的呈現方式。';

  @override
  String get workspaceModeOriginal => '原始版面';

  @override
  String get workspaceModeAuto => '自動選擇';

  @override
  String get workspaceModeCommandGrid => '指揮網格';

  @override
  String get workspaceModeTimeline => '任務時間軸';

  @override
  String get workspaceModeEvidence => '證據畫布';

  @override
  String get workspaceModeCosmicFuture => '宇宙未來風';

  @override
  String get workspaceModeSoftEducation => '教育文柔風';

  @override
  String get workspaceModeTooltip => '切換工作台模式';

  @override
  String get workspaceMoreMenuTooltip => '更多功能';

  @override
  String get workspaceLanguageMenuTitle => '語言';

  @override
  String get workspaceStageImport => '匯入';

  @override
  String get workspaceStageParse => '解析';

  @override
  String get workspaceStageAnalyze => '四引擎分析';

  @override
  String get workspaceStageVerify => '核實';

  @override
  String get workspaceStageReport => '報告';

  @override
  String get workspaceLiveFindings => '即時發現';

  @override
  String get workspaceTelemetry => '分析遙測';

  @override
  String get workspaceDocument => '文件工作區';

  @override
  String get workspaceOverallProgress => '整體進度';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return '步驟 $current/$total・$stage';
  }

  @override
  String get workspaceWaiting => '等待匯入文件';

  @override
  String get workspaceAnalyzing => '分析進行中';

  @override
  String get workspaceAnalysisComplete => '分析完成';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '已完成 $done/$total 個模組 · 經過 $seconds 秒 · 執行中：$engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return '分析仍在進行，介面可正常操作。過去 $seconds 秒尚無模組完成；大型文件或本機模型可能需要較長時間。';
  }

  @override
  String get workspaceAnalysisFailed => '分析意外停止，請重試或檢查模型設定。';

  @override
  String get workspaceNewAnalysis => '新的分析';

  @override
  String get workspaceStopAnalysis => '停止分析';

  @override
  String get workspaceStopAnalysisTitle => '停止目前的分析？';

  @override
  String get workspaceStopAnalysisBody => '目前的分析仍在進行。停止後會保留文件文字，但未完成的結果不會儲存。';

  @override
  String get workspaceAnalysisStopped => '分析已停止，文件文字仍保留在工作台。';

  @override
  String get workspaceSelectedEvidence => '選取證據';

  @override
  String get workspaceNoEvidence => '各引擎完成後，句子證據會依序顯示於此。';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return '初步 AI 證據指數：$percent/100';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      '此百分比是「這一句」自己的 AI 訊號強度，不是整份文件的最終判定。數字越高代表這句的用字模式越接近 AI 生成；越低則越接近一般人類寫作習慣。最終報告會依各引擎權重綜合所有句子後得出。';

  @override
  String get workspaceSentenceSignalHeader => '逐句 AI 訊號';

  @override
  String get workspaceSentenceColumnHeader => '句子內容';

  @override
  String get workspaceAiEvidenceIndexShort => '指數';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine 本次沒有找到證據，未參與投票（角色權重 $weight%）。這代表它在自己負責的面向沒有發現 AI 痕跡，不等於它認為本文是人類撰寫。';
  }

  @override
  String reportEngineRelationshipDirectionalOnly(String engine, int weight) {
    return '$engine 本次只有弱方向性訊號，已折扣納入初步篩查，但未達可投票的證據門檻（角色權重上限 $weight%）。';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return '本次只有$engine形成可用方向，其餘引擎沒有方向性訊號。結論僅由單一面向支撐，信心請相應打折。';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return '另有 $count 個引擎有執行但未形成方向性訊號，已排除在外，避免把「沒話說」誤算成「看起來像人寫的」。';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      '本次未採計語言模型困惑度：困惑度模型（DistilGPT2）只在英文語料上訓練，對中日韓文而言它量到的是位元組的可預測性，不是語言的可預測性。以標註語料實測，它在這些語言上區分真人與 AI 的能力為 0%，採計只會製造偽陽性。';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return '各語言基準集：$breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return '另有 $count 份較早的樣本沒有語言標記，無法歸入任何語言的基準集——原文預設不保存，事後無從補算語言。隨著新文件分析會逐步替換。';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return '本次改用「$variant」：你選用的變體未針對 $language 驗證，而這一顆有。';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '「$variant」是多語言模型，但未在 $language 上驗證過，其分數的證據強度應低於已驗證的語言。';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '「$variant」不涵蓋 $language。其分數僅供參考，不應被當成任何方向的證據。';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      '本次未採計語言模型困惑度：無法判定這份文件的語言，因此沒有可比對的校準門檻。猜一個語言就會套錯尺度，而那正是這道檢查要避免的錯誤。';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return '本次未採計語言模型困惑度：目前使用的模型「$model」尚未量測過 $language 的門檻。沒有校準尺度時，原始數值不代表任何意義，因此寧可不採計也不猜。';
  }

  @override
  String get inputNoEditingRecordHint =>
      '這個格式不含編輯紀錄。PDF、圖片與直接貼上的文字都沒有「怎麼寫出來的」歷程，因此分析完全依賴文本統計。若能取得 .docx、.odt 或 .doc 原始檔，其編輯歷程是強得多的證據——而且不像文本統計，它不會隨語言模型進步而失效。';

  @override
  String get reportLowScoreNotProofOfHuman =>
      '低分不等於確認由人撰寫。本次沒有可用的來源證據，判定僅來自文本統計；文本統計能穩定指認罐頭式寫作，但指認不了現代模型寫得好的輸出。';

  @override
  String get reportProvenanceContradictsLowScore =>
      '檔案自身的編輯紀錄與這個低分互相矛盾。來源證據不會隨語言模型進步而失效，而文本統計指認不了現代模型寫得好的輸出。請先看下方的來源證據，再決定要不要採信上面的分數。';

  @override
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  ) {
    return '$total 段中有 $paragraphs 段屬於同一個編輯批次，佔全文 $percent% 的字數——這與「該區塊是一次寫入或貼上的」相符，即使檔案本身另有其他編輯批次。';
  }

  @override
  String findingEvasionDetected(int count) {
    return '發現 $count 處字元層級的規避痕跡（零寬字元、外觀相同的異體字母、或方向控制字元）。正常的寫作工具不會產生這些——有人為了規避偵測而處理過這份文字。';
  }

  @override
  String findingCitationsNotFound(int notFound, int total) {
    return '引用的 $total 篇文獻中，有 $notFound 篇在所有查核的資料庫中都查無此文。捏造引用是語言模型的行為特徵，而且與文風不同，一篇文獻存不存在是可以查證的事實。';
  }

  @override
  String findingCitationsAllVerified(int total) {
    return '引用的 $total 篇文獻全數在公開資料庫中找到。';
  }

  @override
  String findingEditingRecordNormal(int minutes, int revisions) {
    return '檔案記錄了 $minutes 分鐘的編輯時間、$revisions 次存檔，與「這份文字是在本文件中寫成的」相符。';
  }

  @override
  String findingPublicationPredatesGenerativeAi(String doi, int year) {
    return '來源 DOI $doi 與本文件篇名吻合，且於 $year 年完成登記，早於現代生成式 AI 寫作系統。';
  }

  @override
  String findingPublicationIdentityMismatch(String doi) {
    return '來源 DOI $doi 雖可解析，但登記篇名與本文件不符；採信前應先核對文件身分。';
  }

  @override
  String get integratedStabilityUnavailable => '分段穩定性無法計算 · 沒有逐句證據參與投票';

  @override
  String get integratedNeutralBaseline =>
      '本次未找到足以升級處理的作者特異性證據；畫面呈現的是目前最佳方向性篩查，不代表 AI 與真人證據各半。';

  @override
  String get reportVerifiableFindingsTitle => '可查證的事實';

  @override
  String get reportVerifiableFindingsSubtitle =>
      '以下每一項都可以獨立查證。與機率不同，這些不會隨語言模型進步而失效。';

  @override
  String findingBulkPaste(int characters) {
    return '輸入過程中記錄到一次貼上 $characters 個字元。語言模型無法偽造文字如何出現在編輯器裡——這一段不是在這裡打出來的。';
  }

  @override
  String findingWrittenInApp(int minutes, int deleted) {
    return '這份文字在本應用程式內經過 $minutes 分鐘打成，過程中修改了 $deleted 個字元。在這裡發生的寫作會留下語言模型無法重現的紀錄。';
  }

  @override
  String get evidenceMatrixTitle => '多證據鑑識矩陣';

  @override
  String get evidenceMatrixSubtitle =>
      '六個面向分開呈現；只有具作者特異性的證據影響作者判讀，覆蓋率表示本次能檢查哪些證據。';

  @override
  String evidenceMatrixCoverage(int available, int total) {
    return '證據覆蓋：$available/$total 個面向';
  }

  @override
  String get evidenceAxisText => '文本生成痕跡';

  @override
  String get evidenceAxisTextNote => '四個本機偵測引擎提供的機率型文字模式';

  @override
  String get evidenceAxisProcess => '寫作過程';

  @override
  String get evidenceAxisProcessNote => '不記錄內容的打字、修改與貼上事件';

  @override
  String get evidenceAxisOrigin => '文件來源';

  @override
  String get evidenceAxisOriginNote => '編輯時間、存檔次數與 DOCX／ODT／RSID 中繼資料';

  @override
  String get evidenceAxisSources => '主張與來源完整性';

  @override
  String get evidenceAxisSourcesNote => '可查核主張、引用錨點與文獻資料庫核實';

  @override
  String get evidenceStateUnavailable => '無法取得';

  @override
  String get evidenceStateInconclusive => '不足判斷';

  @override
  String get evidenceStateReassuring => '相符';

  @override
  String get evidenceStateConcern => '需檢視';

  @override
  String get evidenceStrengthNone => '沒有證據';

  @override
  String get evidenceStrengthLimited => '有限';

  @override
  String get evidenceStrengthModerate => '中等';

  @override
  String get evidenceStrengthStrong => '強';

  @override
  String get evidenceMatrixTextOnlyWarning =>
      '本次只有文本模式可用。現代 AI 能模仿人類文風，因此不能只靠這個分數確認作者身分。';

  @override
  String get evidenceMatrixStrongConcern =>
      '至少一個獨立面向出現強烈的檢視訊號。採信文本分數前，請先查看該項證據。';

  @override
  String findingUnsupportedClaims(int unsupported, int total) {
    return '$total 個可查核主張中，有 $unsupported 個包含數字、比較或研究歸因，卻未在同一句提供來源錨點。這不代表內容必然錯誤，但指出了最該優先核實的主張。';
  }

  @override
  String get integratedAssessmentTitle => '整合作者判讀';

  @override
  String get integratedInsufficientEvidence => '未取得可量化的作者訊號';

  @override
  String get integratedLikelyAi => '較可能是 AI 生成';

  @override
  String get integratedLikelyMixed => '較可能是人機混合';

  @override
  String get integratedLikelyHuman => '較可能不是 AI 生成';

  @override
  String get integratedBalanced => '未檢出明確 AI 主導訊號';

  @override
  String get integratedPreliminaryAi => '目前偏向 AI，但接近分界';

  @override
  String get integratedPreliminaryHuman => '目前偏向真人，但接近分界';

  @override
  String integratedLikelihoodLabel(int percent) {
    return 'AI 證據指數：$percent/100';
  }

  @override
  String get integratedLikelihoodUnavailable => 'AI 證據指數：無法估算';

  @override
  String integratedTextScoreLabel(int percent) {
    return '文字模型原始分數：$percent%';
  }

  @override
  String integratedConfidenceLabel(String confidence) {
    return '判讀信心：$confidence';
  }

  @override
  String get integratedConfidenceLow => '低';

  @override
  String get integratedConfidenceModerate => '中';

  @override
  String get integratedConfidenceHigh => '高';

  @override
  String integratedEvidenceSufficiency(int percent, String tier) {
    return '證據充分度：$percent/100 · $tier';
  }

  @override
  String get integratedEvidenceTierScreening => '初步篩查';

  @override
  String get integratedEvidenceTierReference => '具參考性';

  @override
  String get integratedEvidenceTierStrong => '支持較充分';

  @override
  String integratedBoundaryAi(int index, int gap) {
    return '指數 $index 只呈現微弱 AI 方向，距 60 分 AI 升級線仍有 $gap 分；目前不足以認定 AI 撰寫。';
  }

  @override
  String integratedBoundaryHuman(int index, int gap) {
    return '指數 $index 目前偏向真人，且距 60 分 AI 升級線仍有 $gap 分；但證據有限，仍不能排除 AI 協作。';
  }

  @override
  String integratedEvidenceCoverage(int families, int coverage) {
    return '方向性訊號家族：$families/4 · 適用性覆蓋 $coverage%';
  }

  @override
  String get integratedEvidenceGatePassed => 'AI 證據門檻：已通過';

  @override
  String get integratedEvidenceGateNotPassed => 'AI 證據門檻：未通過・僅供方向篩查';

  @override
  String integratedQualifiedWarning(String reason) {
    return '$reason 系統仍提供最可能方向，但已降低信心；請把它視為篩查結果，而不是定案證明。';
  }

  @override
  String get integratedIndexCaveat =>
      '獨立的 AI 證據門檻表示是否已有足夠跨來源支持可升級處理。引用品質、貼上行為與異常中繼資料不能單獨產生 AI 判定。本指數是證據分數，不是經母體校準的統計機率。';

  @override
  String get reportTextEngineSignalExplanation =>
      '以下呈現四個文字引擎的診斷訊號。相關引擎會先按家族合併，納入保守折扣後的分類器真人方向，再套用語言／領域適用性與校準可靠度。方向結論回答哪一種解釋較受支持；獨立的 AI 證據門檻則回答支持是否已足以升級處理。';

  @override
  String reportSynthesisTextScoreContext(int percent) {
    return '四引擎文字模型原始分數為 $percent%；它只是整合判讀的一項輸入，不是另一個綜合判定。';
  }

  @override
  String reportSynthesisStrongestTextSignal(String label, int percent) {
    return '最高文字引擎訊號是 $label（$percent%）；它可影響文字模型分數，但不能單獨覆蓋整合判讀。';
  }

  @override
  String composerTextScoreThresholdReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '文字模型原始分數為 $aiPercent%，已達 $thresholdPercent% 診斷標記。這只代表文字訊號；報告的作者方向仍以整合判讀為準。';
  }

  @override
  String composerTextScoreThresholdNotReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '文字模型原始分數為 $aiPercent%，低於 $thresholdPercent% 診斷標記。未達標記不代表人類撰寫；報告的作者方向仍以整合判讀為準。';
  }

  @override
  String telemetryIntegratedVerdict(
    String direction,
    int percent,
    String confidence,
  ) {
    return '依本次可用證據加權後，本文「$direction」（AI 證據指數 $percent/100，$confidence信心）。';
  }

  @override
  String telemetryIntegratedUnavailable(String direction, String confidence) {
    return '本次可用模組未形成可量化的作者方向（「$direction」、$confidence信心），因此不提供數字指數。';
  }

  @override
  String integratedStabilityLabel(int percent, int lower, int upper) {
    return '分段穩定性 $percent% · 區間 $lower–$upper%';
  }

  @override
  String integratedInputQualityLabel(int percent) {
    return '輸入抽取品質：$percent%';
  }

  @override
  String integratedCalibrationLabel(String value, int count) {
    return '同條件本地基準：p=$value · n=$count';
  }

  @override
  String analysisReadinessLabel(String level) {
    return '分析前信心基準：$level';
  }

  @override
  String get analysisReadinessShortText => '需要更多文字';

  @override
  String get analysisReadinessFewSentences => '可分析句段不足';

  @override
  String get analysisReadinessCoreModel => '核心分類模型不可用';

  @override
  String get analysisReadinessFewEngines => '啟用引擎少於兩個';

  @override
  String get analysisReadinessExtraction => '文字抽取品質受限';

  @override
  String get analysisReadinessBaseline => '沒有同條件本地基準';
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
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

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
  String inputPdfOcrProgress(int page, int total) {
    return 'PDF 文本层无法使用，正在以 OCR 识别第 $page/$total 页…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return '已通过 PDF OCR 导入「$fileName」（$count 字符）';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '「$fileName」没有可靠的文本层。请先设置 Web OCR，或改用支持原生 OCR 的安装版，再重新导入。';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '「$fileName」需要 OCR，但超过 $max 页安全上限。请先拆分 PDF 后分批导入。';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return '无法可靠读取「$fileName」。文件可能已损坏、受密码保护，或当前设置的 OCR 服务不支持。';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '「$fileName」是旧版 .doc 格式，无法可靠提取文字内容。请在 Word 另存为 .docx 或导出成 PDF 后再重新导入。';
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
  String analysisPreliminaryResult(int percent) {
    return '初步结果：AI 几率 $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return '初步结果：AI 几率 $percent%（精修中…）';
  }

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
  String get modelCatalogLoadFailed => '无法加载模型目录';

  @override
  String get modelCatalogEmpty => '暂无可用模型';

  @override
  String modelDownloadPathChip(String label) {
    return '$label下载路径';
  }

  @override
  String get modelDownloadPathModelFile => '模型文件';

  @override
  String get modelDownloadPathCopied => '下载路径已复制';

  @override
  String settingsSaveFailed(String error) {
    return '设置保存失败：$error';
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
  String get settingsEngineWeightsTitle => 'AI 模型权重';

  @override
  String get settingsEngineWeightsSubtitle => '设置各引擎影响综合结果的比例；合计必须为 100% 才能保存。';

  @override
  String get settingsEngineInfoTooltip => '查看此引擎功能';

  @override
  String get settingsEngineTransformerHelp =>
      '使用多语言 Transformer 评估保留上下文的段落区块，再将区块分数映射回逐句报告。设置权重决定影响比例；AI 信号决定实际贡献。';

  @override
  String get settingsEngineStatisticalHelp =>
      '分析困惑度、可预测性、Burstiness 与句长变化。规律文字可能提高信号，因此 ESL 修正可能降低其有效权重。';

  @override
  String get settingsEngineStylometryHelp =>
      '检查重复开头、公式化转折与过度列表等可解释风格特征；未命中特征时信号为 0%。';

  @override
  String get settingsEngineAdversarialHelp =>
      '检测可能经改写或去除 AI 痕迹的文字。低分仅代表微弱残余信号，不代表检测成立。';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return '合计：$total% — 可以保存';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return '合计：$total% — 请调整为正好 100%';
  }

  @override
  String get settingsEngineWeightsSave => '保存权重';

  @override
  String get settingsEngineWeightsSaved => 'AI 模型权重已保存于此设备';

  @override
  String get settingsEngineWeightsRestoreDefaults => '恢复默认值';

  @override
  String get engineReasonDisabledByUser => '用户在设置中关闭此引擎';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model：$total 句均未跨越强 AI 阈值；校准后的微弱信号为 $percent%';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'AI 信号指数 $percent/100';
  }

  @override
  String reportEngineDirectionalIndex(int percent) {
    return '弱方向 $percent/100';
  }

  @override
  String get reportEngineNoDirectionalSignal => '未形成方向性信号';

  @override
  String get reportEngineSignalExplanation =>
      '各数值是诊断用证据指数，不是准确率。设置权重决定影响比例；没有跨过阈值或折扣后方向的引擎显示“未形成方向性信号”，不再以 50% 冒充量测结果。';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return '$total 个句子均未跨越强改写信号阈值；校准后的微弱信号为 $percent%';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$total 个句子中有 $count 个跨越强改写信号阈值；校准后的文档信号为 $percent%';
  }

  @override
  String get settingsLinkVerificationTitle => '超链接与参考文献目录验证';

  @override
  String get settingsLinkVerificationSubtitle =>
      '分析报告会将侦测到的网址与参考文献条目比对 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 与可识别的出版社目录。查询只会发送网址、DOI 或单笔书目的作者、篇名、年份及期刊字段，不会发送文档其余内容。核心 AI 侦测仍在设备端运行，此验证可在此关闭。';

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
  String get modelImportWebUnsupported => '导入自定义模型尚未支持网页版，请使用 App 版本。';

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
  String get reportEngineWeightLabel => '权重';

  @override
  String get privacySealNoticeText =>
      'TruthLens 零上传离线隐私认证：内容 100% 于设备端完成运算，无云端数据库存储。';

  @override
  String get reportModelCalibrationTitle => '模型基准自动校准';

  @override
  String get reportCommunityDiscoveredTag => '社区模型 (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => '引擎明细';

  @override
  String get reportEngineNotInstalled => '未安装';

  @override
  String get reportEngineLoadFailedBadge => '加载失败';

  @override
  String get reportEngineAnalysisLevelTitle => '引擎分析层级';

  @override
  String get reportVerdictAiLikelihood => 'AI 倾向';

  @override
  String get reportVerdictHumanLikelihood => '人类自然写作';

  @override
  String get reportRadarRoleTransformer => 'Transformer 分類器';

  @override
  String get reportRadarRoleStatistical => '统计特徵分析';

  @override
  String get reportRadarRoleStylometry => '风格特徵分析';

  @override
  String get reportRadarRoleAdversarial => '对抗式防御';

  @override
  String get reportRadarAxisTransformer => '句級分類';

  @override
  String get reportRadarAxisStatistical => '语言規律';

  @override
  String get reportRadarAxisStylometry => '写作风格';

  @override
  String get reportRadarAxisAdversarial => '改写防御';

  @override
  String get reportVerdictBadgeTitle => '综合判定';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return '整體 AI 几率 $percent%';
  }

  @override
  String get reportVerdictHintHuman => '多數引擎信号偏向自然人类写作。';

  @override
  String get reportVerdictHintLikelyHuman => '整體偏人类，但仍保留少量模型不確定性。';

  @override
  String get reportVerdictHintMixed => '不同引擎信号分歧，需搭配詳細分析判讀。';

  @override
  String get reportVerdictHintLikelyAi => '多个指標偏向 AI，建議检查高分片段。';

  @override
  String get reportVerdictHintAi => '整體信号高度偏向 AI 生成或改写。';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return '综合判定：$verdict，整體 AI 几率 $percent%。';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return '最高单项信号是 $label（$percent%），但最終結果會依各引擎权重合併，不等於單一引擎結論。';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return '目前最大加權贡献來自 $label（約 $points 个百分點）。';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '「未侦测到明顯 AI 写作风格」只代表风格引擎沒有抓到固定句式或过渡词模式；其他模型仍可能因语言規律、句級分類或改写特徵把整體分數拉高。';

  @override
  String get reportSynthesisModelGap =>
      '有引擎未参与時，請先到模型管理使用「补齐推荐分析模型」；若仍失敗，詳細分析會列出是模型缺失、tokenizer 不支援、檔案丢失或 Web/ONNX Runtime 兼容性限制。';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label 未参与本次加權投票，該面向暫以 0% 顯示。$hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return '角色权重 $weight%，對整體分數贡献約 $points 个百分點$variantText。';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return '（已合併 $count 个模型变体）';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label 未参与本次投票。';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label 未回傳额外文字說明。';
  }

  @override
  String get reportEngineResolutionTransformer =>
      '解法：在模型管理下載並启用多语言 Transformer；若已下載，重新下载模型與 tokenizer。';

  @override
  String get reportEngineResolutionAdversarial =>
      '解法：在模型管理重新下载改写侦测模型與 tokenizer；Web 端請更新到已修補 BigInt 兼容性的版本後重新分析。';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason。原因：Web 端 ONNX Runtime 回傳 BigInt 张量，旧版橋接無法转换；已修補為 JS 端先轉 Number，請更新後重新分析。';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason。解法：切換到 catalog 內建模型，或重新下载模型與 tokenizer。';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason。解法：到模型管理點「补齐推荐分析模型」，並确认多语言 Transformer 标示為使用中。';
  }

  @override
  String get reportDetailAnalysisTitle => '详细分析';

  @override
  String get reportNoEngineData => '暂无引擎分析数据';

  @override
  String get reportEngineNotParticipated => '未参与';

  @override
  String get reportAiContentReportTitle => 'AI 内容检测报告';

  @override
  String reportAnalysisTimeLabel(String time) {
    return '分析时间：$time';
  }

  @override
  String get reportDownloadPdfButton => '下载 PDF';

  @override
  String get reportSuspiciousLocationsTitle => '可疑内容位置';

  @override
  String reportSentenceCount(int count) {
    return '共 $count 句';
  }

  @override
  String get reportAiProbabilityPrefix => 'AI 几率：';

  @override
  String get helpAdvantage5 =>
      '文件来源鉴识：读取 .docx／.odt／.doc 的编辑记录（编辑时长、存档次数、编辑批次分散度），这是独立于文字判定的证据，与 AI 几率分开呈现。PDF 与图片本身不带编辑历程，因此无法提供这类证据。';

  @override
  String get helpAdvantage6 =>
      '始终提供最可能的 AI／非 AI 方向，并把方向与信心分开。文字太短、模型沉默、引擎不足或分歧过大时会降低信心，而不是把答案整个拿掉。';

  @override
  String get settingsAiSampleTitle => '新增 AI 产出样本';

  @override
  String get settingsAiSampleSubtitle =>
      '背景校准只会自动收集人类样本。要启用学习式引擎权重，需另外提供已知由 AI 产出的文章——粘贴或导入后会立即分析并标记为 AI 样本。';

  @override
  String get settingsAiSampleFromClipboard => '从剪贴板粘贴';

  @override
  String get settingsAiSampleFromFile => '导入文件';

  @override
  String get settingsAiSampleAnalyzing => '分析中…';

  @override
  String settingsAiSampleAdded(int count) {
    return '已加入 AI 样本，目前共 $count 份';
  }

  @override
  String get settingsAiSampleTooShort => '内容太短，无法作为样本（至少需 100 字）';

  @override
  String get settingsAiSampleFailed => '没有取得可用的内容';

  @override
  String get helpFormatCoverageTitle => '二之一、来源证据的格式限制';

  @override
  String get helpFormatCoverage =>
      '**重要限制：只有 .docx、.odt 与旧版 .doc 带编辑记录。**\n\n| 来源 | 编辑记录 |\n|---|---|\n| .docx／.odt | ✅ 有 |\n| .pdf | ❌ 格式本质上没有编辑历程 |\n| .doc（旧版） | ✅ 有（OLE2 SummaryInformation） |\n| .txt／.md | ❌ 无容器 |\n| 图片 OCR | ❌ 只剩像素 |\n| 直接粘贴 | ❌ 没有文件 |\n\n这对第 3 支柱有直接影响：**只有带编辑记录的文件会自动累积进「有统计保证」的基准集**。若你的收件流程全是 PDF，有保证的基准集永远不会成长，只会累积无保证的参考样本。\n\n若要让来源证据与自动校准真正发挥作用，请取得 .docx 或 .odt 原始档，而不是打印或转存的 PDF。这是流程上的要求，不是软件能绕过的限制——PDF 是输出格式，本来就不记录「怎么写出来的」。';

  @override
  String provenanceUnsupportedFormat(String format) {
    return '$format 这种格式本身就不携带编辑历程，因此不是「记录被清除」，而是从来就没有。只有 .docx 与 .odt 会记录编辑时长、存档次数与编辑批次。';
  }

  @override
  String get provenanceStripped =>
      '这是支持的格式，但文件里找不到编辑记录——通常代表它被另存新档、在线转档，或从 Google 文档导出过，这些动作都会把记录重置。';

  @override
  String get provenanceHowToGetRecord =>
      '若要让来源证据发挥作用，请取得 **.docx、.odt 或 .doc 原始档**（不是打印或转存的 PDF）。只有原始档才留有编辑历程，也才能自动累积进有统计保证的基准集。';

  @override
  String get calibrationAutoTitle => '后台自动收集中';

  @override
  String get calibrationAutoSubtitle => '分析完成的文件会自动纳入基准集，你不需要手动标注。';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return '已由编辑记录认定为人类撰写：$auto 份；仅供参考的样本：$observed 份';
  }

  @override
  String get calibrationAutoWhy =>
      '只有带编辑记录（编辑时长、存档次数、编辑批次分散）的文件才会纳入统计保证的基准集，因为那是**独立于文字判定**的证据。若改用本工具自己的判定结果来自动标注，等于拿自己的答案当标准答案——被误判的真人作业永远进不了基准集，门槛会越调越严，反而标记更多真人作业。粘贴的纯文字没有编辑记录，因此只计入下方的参考百分位。';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return '参考：本文分数落在你已分析的 $count 份文件中的第 $percentile 百分位（此数值无统计保证）';
  }

  @override
  String get settingsAutoCollectTitle => '后台自动收集校准样本';

  @override
  String get settingsAutoCollectSubtitle =>
      '分析完成后自动纳入基准集。标签依据为文件编辑记录，不会使用本工具自己的判定结果。';

  @override
  String get settingsStoreTextTitle => '保留原文以供离线验证';

  @override
  String get settingsStoreTextSubtitle =>
      '开启后，加入基准集的文章会连同原文一起保存在本机，之后可导出成语料档进行离线评测。';

  @override
  String get settingsStoreTextWarning =>
      '原文多为他人作品，属敏感数据。仅在你确实要收集离线验证语料时开启，导出后可用下方「清除已保存的原文」立即移除；清除不影响共形预测（它只需要分数）。';

  @override
  String get settingsExportCorpusTitle => '导出校准语料';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return '可导出：人类 $human 份、AI $ai 份（离线评测每类需 $required 份）';
  }

  @override
  String get settingsExportCorpusButton => '导出为 JSONL';

  @override
  String get settingsExportCorpusEmpty => '没有可导出的样本——请先开启「保留原文」再累积基准集';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return '已导出 $count 份（略过 $skipped 份未保留原文的样本）';
  }

  @override
  String get settingsClearStoredText => '清除已保存的原文';

  @override
  String get settingsClearStoredTextDone => '已清除所有原文，分数与校准结果保留不变';

  @override
  String get helpDesignTitle => '设计理念与已知限制';

  @override
  String get helpShiftTitle => '一、核心定位转换：不比谁的分数准';

  @override
  String get helpShiftBody =>
      '市面上的检测器几乎都在回答同一个问题：「这段文字看起来像不像 AI 写的？」\n\n这是一场必输的军备竞赛。模型越强，生成文字的统计特征就越接近人类；而改写工具的进步速度远快于检测器。在这条路上，服务器端的大模型只是输得慢一点。\n\nTruthLens 改问另一个问题：「关于这份文件是怎么产生的，我们手上有哪些证据？各自有多强？」\n\n也就是从「文字风格推测」转向「来源证据 ＋ 统计上诚实的结论」。这是为什么本工具刻意不追求单一分数的准确度排名，而是把每一项证据分开摊给你看，并在证据不足时明白说不知道。浏览器端执行带来的真正优势不是推论速度，而是它看得到服务器看不到的东西——完整的文件，以及你自己收集的族群基准。';

  @override
  String get helpPillarsTitle => '二、五个支柱';

  @override
  String get helpPillarsBody =>
      '1. 文件来源鉴识（已上线）\n读取 DOCX／ODT 容器内的编辑记录：编辑总时长、存档次数、创建与修改时间，以及正文的编辑批次标记（RSID）。整篇文章只有一两组 RSID，通常代表内容是一次写入的；3000 字却只编辑 4 分钟，这个证据比任何困惑度分数都硬。这属于来源证据，与 AI 几率分开呈现，刻意不并入分数。\n\n2. 本地基准校准与共形预测（已上线）\n你可以把确定由作者本人撰写的文章加入基准集，系统改以这个族群自己的分布判断，而非全球通用门槛。共形预测提供分布无关的保证：若基准与待测样本可交换，伪阳性率不超过你设定的 α。这是降低非母语写作误判的关键，也是商用产品做不到的——它们没有这批作者的基准写作。\n\n3. 学习式引擎权重（已上线）\n当基准集同时累积人类与 AI 两类样本后，系统以 Cohen\'s d 效果量衡量每个引擎分开这两组的能力，据此建议权重，取代手调的固定比例。需你按下「套用」才会生效，不会静默改动设定。\n\n4. 交叉困惑度 Binoculars（评分核心已完成，尚未上线）\n裸 perplexity 把「文字好不好预测」直接当成「像不像 AI」，因此对用词平实的非母语写作有系统性伪阳性。Binoculars 改以「好预测的程度相对于两个模型彼此分歧的程度」来衡量。评分数学已实作并通过测试，但要真正启用还需要一组能在浏览器执行的小型语言模型配对，以及标注数据的效果验证。\n\n5. 水印检测（经查证不可行，未实作）\nSynthID-Text 的检测绑定密钥：检测器必须用与生成时相同的密钥计算，而 Google 生产环境的密钥并未公开。在浏览器端做这件事，对 ChatGPT、Claude、Gemini 的真实输出永远不会命中，只会变成永不触发却让人误以为有在检查的假功能，因此主动不做。';

  @override
  String get helpCascadeTitle => '三、分级分析与整合判读';

  @override
  String get helpCascadeBody =>
      '分析依序执行文件来源、统计与风格特征、Transformer 句级分类，以及必要时才启动的交叉困惑度。\n\n六个证据方面各自回答不同问题，因此分开呈现。作者判读只接受直接文字痕迹，并可由确定的逐步写作、文件来源或渐进草稿证据向非 AI 修正。缺少引用、偏离任务、整段贴上、修订很少或元数据异常仍列为待核查事项，但不能单独把文件判成 AI。\n\n信心会独立计算。可分析句少于 5 句、内容少于 100 字、引擎少于 2 个、模型沉默或分歧过大时，都会降低信心并显示限制警告。方向仍可用于筛查，但低信心结果不得当成定案证明。';

  @override
  String get helpRisksTitle => '四、必须诚实面对的风险';

  @override
  String get helpRisksBody =>
      '以下每一项都是本工具真实存在的限制，请在做出任何决定前一并考虑：\n\n1. 来源证据可以被清除或伪造\n另存新档、在线转档、从 Google 文档导出、或复制到新文件，都会让编辑记录归零。因此有信号只是佐证，没有信号也绝不代表文件必然由人撰写。\n\n2. 共形保证依赖「可交换性」\n保证成立的前提是基准样本与待测文章出自同一群人、同一类写作任务。作者写作能力明显进步、或换了完全不同的任务类型，前提就不再成立，需要重建基准集。\n\n3. 基准集本身可能被污染\n如果拿来当基准的作业其实是 AI 代写的，整个校准都会偏掉。基准样本必须在可控环境下收集，例如在可控环境下当场完成的作品。\n\n4. 浏览器端小模型的原始准度不如服务器端大模型\n这是 Web-only 决策换取隐私的必然代价。本工具的价值不是神奇地给出精准单一分数，而是提供可解释的方向、明确信心与证据限制。\n\n5. 任何分数都不应单独作为指控的依据\n请务必搭配逐句证据、文件来源，以及你对这位作者既有的了解一起判读。本工具的设计目标是辅助你进行对话，不是代替你做出裁决。';

  @override
  String get calibrationAddHuman => '加入为「人类撰写」基准';

  @override
  String get calibrationAddAi => '加入为「AI 产出」样本';

  @override
  String calibrationCounts(int human, int ai) {
    return '基准集：人类 $human 份、AI $ai 份';
  }

  @override
  String get learnedWeightsTitle => '学习式引擎权重';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return '目前人类 $human 份、AI $ai 份。两类各需至少 $required 份才能学出可靠的权重；在此之前沿用你手动设定的权重。';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return '已可依你的 $human 份人类样本与 $ai 份 AI 样本学出权重。';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine：建议权重 $weight%（分离度 $effect）';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return '注意：$engine 把两组判反了（AI 样本反而拿到较低分数），因此权重归零。这通常代表该引擎不适用于你这类文本。';
  }

  @override
  String get learnedWeightsApply => '套用学习到的权重';

  @override
  String get learnedWeightsApplied => '已套用学习到的权重';

  @override
  String get learnedWeightsExplain =>
      '权重依各引擎「把你的人类样本与 AI 样本分开」的程度计算（Cohen\'s d 效果量）：分得越开、组内越稳定的引擎权重越高。这会取代手调的固定权重，让集成贴合你自己的文本类型。';

  @override
  String get calibrationTitle => '本地基准校准';

  @override
  String get calibrationEmpty =>
      '尚未建立基准集。加入若干份「确定由作者本人撰写」的文章后（例如在可控环境下当场完成的作品），系统就能改用这个群体自己的分布来判断，而不是套用全球通用的门槛——这正是降低非母语写作伪阳性的关键。';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return '基准集目前 $count 份，要让 $alpha% 的伪阳性率上限真的成立，至少需要 $required 份。在补齐之前只显示参考数值，不会据此标记任何文章。';
  }

  @override
  String calibrationFlagged(int alpha) {
    return '在 $alpha% 伪阳性率上限的设定下，本文**被标记**。';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return '在 $alpha% 伪阳性率上限的设定下，本文**未被标记**。';
  }

  @override
  String calibrationPValue(String value, int count) {
    return '保守 p 值 $value（相对于 $count 份基准样本）';
  }

  @override
  String calibrationPercentile(int percentile) {
    return '分数落在基准集的第 $percentile 百分位';
  }

  @override
  String get calibrationCaveat =>
      '这个保证的前提是「基准样本与待测文章可交换」——也就是出自同一群人、同一类写作任务。若作者的写作能力明显进步、或换了完全不同的任务类型，前提就不再成立，需要重新建立基准集。另请注意：若基准样本本身就是 AI 代写的，整个校准都会偏掉，取样必须在可控环境下进行。';

  @override
  String get calibrationAddButton => '把这份加入基准集';

  @override
  String calibrationAdded(int count) {
    return '已加入基准集，目前共 $count 份';
  }

  @override
  String get settingsCalibrationTitle => '本地基准校准集';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return '目前 $count 份（此 α 需要 $required 份）';
  }

  @override
  String get settingsCalibrationClear => '清空基准集';

  @override
  String get settingsCalibrationCleared => '基准集已清空';

  @override
  String get settingsAlphaTitle => '伪阳性率上限（α）';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return '目前 $alpha% — 数值越低越保守，但需要越多基准样本（至少 $required 份）';
  }

  @override
  String get abstentionHeadline => '证据不足，不做判定';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return '只有 $count 个可分析句段（至少需要 $required 个才能衡量句段稳定度）。因此会降低信心，但符合条件的文件级信号仍可参与判读。';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return '内容只有 $count 字（至少需要 $required 字）。文字量太少时，任何写作特征都可能只是偶然。';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return '只有 $available/$total 个引擎参与投票，无法多角度交叉验证。请到模型管理补齐后重跑。';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return '各引擎的看法相差 $spread 个百分点，分歧大到加权平均已失去意义。请改用逐句证据与文件来源自行判读。';
  }

  @override
  String get abstentionNoEvidenceFound =>
      '所有引擎都有执行，但没有任何一个找到可用证据。这个低分只是诊断用的 fallback 输出，不是人类撰写的证据。';

  @override
  String abstentionSingleWeakEvidenceSource(int count) {
    return '只有 $count 个引擎找到可用证据，而且整体分数仍低于 AI 标记门槛。这代表本次证据覆盖不足，不代表已证明由人类撰写。';
  }

  @override
  String get abstentionScoreStillShown => '下方仍保留完整的分数与逐句证据供你自行参考，但请不要把它当成结论。';

  @override
  String get provenanceTitle => '文件来源证据';

  @override
  String get provenanceRiskHigh => '编辑记录明显不寻常';

  @override
  String get provenanceRiskMedium => '编辑记录有可疑之处';

  @override
  String get provenanceRiskLow => '编辑记录看起来正常';

  @override
  String get provenanceRiskUnknown => '没有可用的编辑记录';

  @override
  String get provenanceNoMetadata =>
      '这份输入没有夹带编辑记录（直接粘贴的文字、PDF、或记录已被清除），因此无法从来源判断，只能看文字本身的分析。';

  @override
  String provenanceEditingDuration(int minutes) {
    return '文件记录的编辑总时长：$minutes 分钟';
  }

  @override
  String provenanceRevisionCount(int count) {
    return '存档次数：$count 次';
  }

  @override
  String provenanceApplication(String name) {
    return '生成软件：$name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return '正文的编辑批次标记只有 $count 组，但内容有 $words 字。正常一边想一边写会留下数十组，这种高度集中通常代表整段是一次写入的（例如粘贴）。';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words 字对上 $minutes 分钟的编辑时长，平均每分钟 $wpm 字，远高于一般人能持续维持的打字速度。';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return '文件记录的编辑总时长接近 0，但正文有 $words 字。';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return '$words 字的内容只存档过 $count 次。';
  }

  @override
  String get provenanceCaveat =>
      '请注意：这些记录可以被清除或重置——另存新档、在线转档、从 Google 文档导出、或复制到新文件都会让它归零。因此有信号只能当作佐证，不能单独当成结论；没有信号也不代表文件必然由人撰写。';

  @override
  String get telemetrySummaryTitle => '分析总结';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '$total 个引擎中有 $engines 个跑完了，整体 AI 几率 $percent%，判定为「$verdict」。';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return '各引擎看法挺一致的，最高 $high%、最低 $low%，这个结论算站得住脚。';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return '引擎之间看法不太一样：$highLabel给了 $high%，$lowLabel却只有 $low%，这种时候别只看总分，往下翻逐句证据会准得多。';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return '把分数拉上来的主要是$label，大约贡献了 $points 个百分点。';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return '逐句扫过 $total 句，没有任何一句踩到强 AI 信号线。';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return '逐句扫过 $total 句，其中 $count 句踩到强 AI 信号线，值得一句一句看过。';
  }

  @override
  String get telemetrySummaryAdviceHuman => '整体读起来就是人自己写的，没有特别需要追查的地方。';

  @override
  String get telemetrySummaryAdviceMixed =>
      '这份落在灰色地带，光凭分数下结论太冒险，建议搭配逐句证据和文件来源一起看。';

  @override
  String get telemetrySummaryAdviceAi => '信号明显偏向 AI 生成或改写，建议把标红的句子逐一核对过再做决定。';

  @override
  String telemetrySummaryModelGap(int count) {
    return '另外有 $count 个引擎这次没参与投票，把握度会打点折；到模型管理补齐后重跑会更准。';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'AI 几率 < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'AI 几率 $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'AI 几率 ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return '信心度低：可用模型权重不足 60%（$threshold% 阈值）。$available/$total 引擎参与投票。建议参考各引擎详细分析结果。';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return '信心度高：$available/$total 个检测模型达成共识（$threshold% 以上权重同意此判定）';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return '信心度低（$available/$total）';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return '信心度高（$available/$total）';
  }

  @override
  String get reportMetricAiSentenceRatio => '强 AI 信号句比例';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$total 个句子中有 $count 个跨越 60% 强信号阈值';
  }

  @override
  String get reportMetricElapsed => '分析耗时';

  @override
  String get reportMetricElapsedNormal => '0.5-5s 正常';

  @override
  String get reportMetricReliability => '可信度';

  @override
  String get reportReliabilityLow => '低';

  @override
  String get reportReliabilityHigh => '高';

  @override
  String get reportReliabilityNeedsReview => '需人工验证';

  @override
  String get reportReliabilityHighTrust => '高度可信';

  @override
  String get reportSentenceAnalysisTitle => '逐句分析';

  @override
  String get suspiciousFilterAll => '可疑';

  @override
  String get suspiciousFilterHigh => '高危';

  @override
  String get suspiciousFilterMedium => '中等';

  @override
  String get suspiciousExcludedTooltip => '已排除单一字母、页码、章节序号与过短 OCR/PDF 片段。';

  @override
  String suspiciousCount(int count) {
    return '$count 项';
  }

  @override
  String get suspiciousEmpty => '无可疑内容';

  @override
  String get suspiciousRiskHigh => '高';

  @override
  String get suspiciousRiskMedium => '中';

  @override
  String get suspiciousReasonHighModelSignals => '多个模型信号高度偏向 AI';

  @override
  String get suspiciousReasonSentenceSignal => '句级模型信号偏高';

  @override
  String suspiciousOriginalLocation(String location) {
    return '原文位置 $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return '原文位置 $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return '句子 #$number';
  }

  @override
  String get suspiciousEvidenceLabel => '判定依据：';

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
  String get reportLinkCitationUnreachable => '无法确认（连接逾时或书目服务无回应）';

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
  String get reportBibRecheckAllUnreliableButton => '重新查核全部未通过文献';

  @override
  String get reportBibRecheckOneTooltip => '重新查核此条文献';

  @override
  String get reportBibResultHint =>
      '依作者、年份、篇名与期刊信息交叉比对 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 与可识别的出版社目录；高可信度结果必须有 DOI 登记或多个一致的书目字段，未达可靠匹配者标示为未通过核实。Google Scholar 因未提供自动查询 API，仅供用户主动人工复核。';

  @override
  String reportBibVerificationSource(String source) {
    return '核实依据：$source';
  }

  @override
  String get reportBibGoogleScholarManualLookup => '前往 Google Scholar 人工复核';

  @override
  String reportBibHighConfidence(String journal) {
    return '高可信度：应存在$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（登记于《$journal》）';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return '期刊名称不一致：文档载为《$reported》，查核登记为《$registered》，请核对此笔文献。';
  }

  @override
  String get reportBibNotFound => '查无相近匹配，可能为虚构文献';

  @override
  String get reportBibUncertain => '疑似不可靠，未通过登记数据核实';

  @override
  String reportBibTruncated(int max, int count) {
    return '将逐笔核实全部文献（共侦测到 $count 笔）';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return '已完成 $count 笔，结果会持续更新。';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return '进度 $completed/$total，$current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return '目前：$text';
  }

  @override
  String get reportBibProgressFinalizing => '正在整理结果';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base：找到相似候选「$candidate」，但作者、年份或篇名未达可靠匹配门槛。';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base：查核来源无可靠响应或条目信息不足，系统不将此文献视为已核实存在。';
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
    return '本文较可能是 AI 生成，建议进一步审查（整合 AI 可能性 $percent%）';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return '这段文本呈现人类与 AI 混合的特征（AI 几率 $percent%）';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return '本文较可能不是 AI 生成（整合 AI 可能性 $percent%）';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return '这段文本极可能为人类撰写（AI 几率 $percent%）';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return '整体 AI 几率越过固定的 $percent% 阈值，被标记为 AI。';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '整体 AI 几率未达 $percent% 标记阈值。';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return '整体 AI 几率为 $aiPercent%，已达固定的 $thresholdPercent% AI 标记门槛，因此报告会标记为 AI。建议搭配句级证据与各引擎理由再做最终判断。';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '整体 AI 几率为 $aiPercent%，低于固定的 $thresholdPercent% AI 标记门槛，因此报告不会正式标记为 AI；几率与证据仍会保留供你查看。';
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
    return '语言模型困惑度偏低（$ppl）[偏 AI 特征]，文本规律性与可预测度高';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return '语言模型困惑度偏高（$ppl）[偏人类特征]，符合人类写作不可预测性';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return '语言模型困惑度中等（$ppl）[中性特征]';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return '句子长度高度一致（burstiness $value）[偏 AI 特征]，节奏平稳均匀';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return '句长起伏显著（burstiness $value）[偏人类特征]，节奏变化丰富';
  }

  @override
  String engineReasonBurstinessMid(String value) {
    return '句长变化（burstiness $value）落在 0.30–0.55 中性带，未形成方向性证据';
  }

  @override
  String engineReasonTtrLow(String value) {
    return '词汇重复度较高（TTR $value）[偏 AI 模板/固定格式特征]';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return '词汇多样性丰富（TTR $value）[偏人类特征]';
  }

  @override
  String engineReasonMattrNoAiSignal(String value, String cut) {
    return '词汇多样性（MATTR $value）未跨过校准后的 AI 信号切点 $cut';
  }

  @override
  String engineReasonStatisticalSummaryAi(String percent) {
    return '综合统计分析：合格指标偏向 AI 生成特征（信号指数 $percent/100）';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return '综合统计分析：合格指标偏向人类自然写作（AI 信号指数 $percent/100）';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return '综合统计分析：合格指标方向互有消长（AI 信号指数 $percent/100）';
  }

  @override
  String get reportFormulaTitle => '加权计算透明度与参数解析';

  @override
  String get reportFormulaExplanation => '整体 AI 概率系由各可用引擎之判定概率依其指定权重加权平均计算得出：';

  @override
  String get reportFormulaActiveEngines => '参与投票引擎与权重';

  @override
  String get reportFormulaCalculation => '加权计算公式';

  @override
  String get reportFormulaFinalResult => '最终加权 AI 概率';

  @override
  String get reportFormulaEslApplied => '已套用 ESL 非母语写作偏差修正（统计模型权重已减半）';

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
  String engineReasonPan25LexicalAi(int percent) {
    return 'PAN 2025 词汇指纹偏向 AI（$percent/100）；这项独立英文基准检测到词语与短语分布不同于其人类语料';
  }

  @override
  String engineReasonPan25LexicalHuman(int percent) {
    return 'PAN 2025 词汇指纹偏向真人（$percent/100）；这仍是模型证据，不是作者身份的证明';
  }

  @override
  String engineReasonPan25LexicalNeutral(int percent) {
    return 'PAN 2025 词汇指纹落在中性区（$percent/100），不提供方向';
  }

  @override
  String engineReasonCompressionCoherence(String value) {
    return '跨半段压缩一致性（$value）超过 PAN 2025 人类语料第 95 百分位筛线［弱 AI 方向信号］';
  }

  @override
  String engineReasonAssistantResponseArtifact(int count) {
    return '侦测到 $count 处聊天助理回复残留，例如称呼提问者或主动表示可修改受托文字';
  }

  @override
  String get engineReasonAdversarialNotInstalled => '改写侦测模型尚未安装，未参与本次投票';

  @override
  String get engineReasonTransformerNotInstalled => '模型尚未安装或使用中模型未支持，未参与本次投票';

  @override
  String get modelRepairNoActiveVariant => '未找到使用中的模型；请在模型管理下载推荐模型。';

  @override
  String get modelRepairCustomRemoved =>
      '已移除载入失败的自定义模型。自定义模型无法自动重新下载，请重新汇入模型与 tokenizer。';

  @override
  String get modelRepairNoSource =>
      '已移除载入失败的模型档，但目前找不到可重新下载的 catalog 来源；请到模型管理重新下载推荐模型。';

  @override
  String modelRepairRedownloaded(Object name) {
    return '侦测到模型档可能损毁或不相容，已自动重新下载 $name；请重新执行分析。';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return '已移除载入失败的模型档，但自动重新下载未完成；请确认网路后在模型管理重新下载 $name。';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      '未找到使用中的 Transformer 模型；请到模型管理下载或设为使用中';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return '使用中模型的 tokenizer 类型不支持（$tokenizer）；请切换到支持 bert-wordpiece 或 roberta-bpe 的模型';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Transformer 模型或 tokenizer 路径缺失；请在模型管理重新下载';

  @override
  String get engineTransformerMissingFiles =>
      'Transformer 模型或 tokenizer 档案不存在；请在模型管理重新下载';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'ONNX opset 版本不支持（该模型版本太新，需更新应用）: $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Tokenizer 格式损毁: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      '模型载入或推论失败，且自动修复未完成；请到模型管理重新下载使用中的 Transformer 模型与 tokenizer。';

  @override
  String get engineAdversarialNoActiveVariant => '未找到使用中的改写侦测模型';

  @override
  String get engineAdversarialMissingFiles => '模型或 tokenizer 档案不存在，请在模型管理重新下载';

  @override
  String get engineAdversarialRepairFailed =>
      '模型载入或推论失败，且自动修复未完成；请到模型管理重新下载改写侦测模型与 tokenizer。';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return '模型未参与本次投票。$error';
  }

  @override
  String get patternNotAnalyzable => '片段过短或疑似 PDF/OCR 噪音，未作 AI 句级判读';

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
      'TruthLens 是一款**完全在浏览器端执行**的 AI 内容检测工具。四个文字分析引擎检查直接文字痕迹；写作过程、文件来源、草稿演进、任务契合及来源完整性则作为分开呈现的鉴识证据，文件内容不会上传到任何服务器。\n\n只有具作者特异性的信号能提高 AI 判定。报告固定提供较可能是 AI／较可能不是 AI 的方向、整合可能性指数与独立信心等级。文字模型原始分数及每一条证据仍会分开显示，避免低信心方向被包装成确定证明。';

  @override
  String get helpComparisonTitle => '与市面主流工具比较';

  @override
  String get helpComparisonDisclaimer =>
      '以下比较依各工具官方公开信息与一般市场认知整理，仅供功能定位参考，非第三方认证的性能实测数据。';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero 的运算主要在云端进行、文件需上传；TruthLens 四个检测引擎皆在你的浏览器内执行，文件内容不外传。';

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
      'Originality.ai 为按篇计费的订阅制，且需将文件上传云端；TruthLens 核心运算在浏览器端完成，无需订阅也无使用次数限制。';

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
      'Winston AI 的 OCR 图片识别需上传图片至云端；TruthLens 的 OCR 优先使用你自行设定的本地 OCR 服务器，只有在你主动提供 Gemini API 密钥时才会使用云端备援——用不用云端由你决定。';

  @override
  String get helpVsWinston2 =>
      'Winston AI 以报告排版精美著称；TruthLens 提供 AI 动态生成排版报告（未安装 LLM 时自动退回模板），可导出 PDF／CSV／JSON／PNG 四种格式。';

  @override
  String get helpAdvantagesTitle => 'TruthLens 的独有优势';

  @override
  String get helpAdvantage1 =>
      '超链接与文献真实性验证：检查网址是否可连接，以 Crossref／DataCite 核实 DOI 登记，并通过 OpenAlex、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 与出版社目录交叉比对书目数据；每笔通过核实的文献会标示证据来源，Google Scholar 仅供人工复核。';

  @override
  String get helpAdvantage2 =>
      '文献参考真实性核实：即使参考文献没有超链接（纯作者—年份格式），也能通过书目比对抓出可能虚构的引用——这正是 AI 幻觉内容常见的破绽。';

  @override
  String get helpAdvantage3 =>
      'ESL（非母语写作者）偏差修正：自动侦测非母语写作特征并降低统计模型权重，避免将非母语人士的自然写作误判为 AI。';

  @override
  String get helpAdvantage4 =>
      '本机纪录与导出：报告可导出 PDF／CSV／JSON／PNG，历史纪录只保存在本机，并在有导入文件时保留来源文件名，方便重新分析或回顾。';

  @override
  String get helpWorkflowTitle => '完整操作流程';

  @override
  String helpWorkflowStepLabel(int step) {
    return '第 $step 步';
  }

  @override
  String get helpWorkflowStep1Title => '模型下载与更新';

  @override
  String get helpWorkflowStep1Body =>
      '首次启动会引导安装内核侦测模型；之后可随时至「设置 → AI 模型管理」查看、下载、更新或移除。App 会在启动时主动比对最新版本，若有更新，设置齿轮图标与「AI 模型管理」项目会出现红点提示。';

  @override
  String get helpWorkflowStep2Title => '如何选用模型（目的与效果）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      '多语言 AI 分类器（权重 40%）：以受控段落区块保留上下文，再将几率映射回逐句证据。';

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
      '可在「设置」个别激活／停用引擎、调整引擎权重。五个判定级距采固定切点（20%／40%／60%／80%），不提供调整，因此同一份文件在任何人手上都会得到相同判定。';

  @override
  String get helpWorkflowStep3Title => '加入内容';

  @override
  String get helpWorkflowStep3Body =>
      '三种输入方式：直接粘贴文字、图片识别 OCR、导入文件（txt / md / pdf / docx / doc / odt）。PDF 导入会比较两套文字层解析结果并排除乱码；扫描型 PDF 在 OCR 可用时会自动逐页识别。导入文件时，档名会显示在输入页标题下方，并单独成行出现在报告标题；粘贴或手动输入文字时，档名维持空白。\n\nOCR 会优先使用你设定的本地服务器，只有在你自行提供 Gemini API 密钥时才使用云端备援。';

  @override
  String get helpWorkflowStep4Title => '开始分析';

  @override
  String get helpWorkflowStep4Body =>
      '点击「开始检测」，四个引擎并行运行，画面即时显示各引擎完成进度。若侦测到非母语写作特征，会自动套用 ESL 偏差修正（可在设置关闭）。分析进行中可随时从工具栏中止；文档文本会保留，但未完成的结果不会被保存。';

  @override
  String get helpWorkflowStep5Title => '查看与导出结果';

  @override
  String get helpWorkflowStep5Body =>
      '文档导入、四引擎实时进度与完整报告现在都保留在同一个战情中心工作台。可随时切换“指挥网格”“任务时间轴”与“证据画布”，不会中断或重新分析；自动模式在桌面使用指挥网格、手机使用任务时间轴。结果包含整体判定、AI 概率、信心度、耗时、逐句证据、引擎贡献、链接与文献核实，并可导出 PDF、CSV、JSON、PNG及保存至本机历史。';

  @override
  String get helpWorkflowStep1ChipOnboarding => '首次启动引导';

  @override
  String get helpWorkflowStep1ChipModelManager => '模型管理中心';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => '自动版本侦测';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => '统计分析 (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => '风格特征 (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => '对抗防御 (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => '报告 LLM (选用)';

  @override
  String get helpWorkflowStep3ChipPaste => '直接粘贴';

  @override
  String get helpWorkflowStep3ChipImageOcr => '图片 OCR';

  @override
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation => '代码/公式隔离';

  @override
  String get helpWorkflowStep4ChipEnsemble => '四引擎并行推理';

  @override
  String get helpWorkflowStep4ChipLiveProgress => '实时动态进度';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'ESL 非母语写作校正';

  @override
  String get helpWorkflowStep4ChipStoppable => '随时可中止';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'AI 总览仪表';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => '句级热力图';

  @override
  String get helpWorkflowStep5ChipCitationVerification => '文献验证';

  @override
  String get helpWorkflowStep5ChipExportFormats => 'PDF / CSV / JSON / PNG 导出';

  @override
  String get helpTuningTitle => '模型下载与调适教学（零基础）';

  @override
  String get helpTuningStep1Title => '打开模型管理画面';

  @override
  String get helpTuningStep1Body =>
      '可从完整「设置」页，或宽屏首页右侧设置面板，打开「AI 模型管理」来下载、更新、激活或移除本机模型。';

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
      '若你已在其他地方取得或自行微调过兼容的 .onnx 模型，可通过「设置 → 自订 ONNX 模型导入与测试」导入——需提供模型档、对应的 Tokenizer 设置（或选择「不需要」）与 AI 类别索引；导入前会自动侦测是否为重复导入的相同文件，避免不小心重复安装。也可在设置中调整四引擎权重。';

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
  String get privacyWebOverview1 =>
      'TruthLens 完全以网页应用程序的形式在您的浏览器标签页中运行，不需要安装；文档文本与分析结果不会离开您的设备，下载的检测模型也只缓存在浏览器自身的沙盒存储空间（OPFS）中，不在任何服务器上。';

  @override
  String get privacyWebOverview2 =>
      '只有在您主动选择导入、扫描或粘贴时，本页才会读取对应的文件、图片或剪贴板内容；不会读取其他标签页、其他网站的数据，或您未选择的文件。';

  @override
  String get privacySectionOverviewWeb => '概要';

  @override
  String get privacyRemoveWeb => '在浏览器设置中清除本网站的数据（或直接关闭标签页即可，因为没有任何内容存储在服务器上）';

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
      '您输入、粘贴或导入的文本内容，皆在您的设备上由本机 AI 模型完成分析。TruthLens 不会将文档文本上传到自有服务器或第三方 AI 检测服务。';

  @override
  String get privacyDataHandling3 =>
      '分析结果与历史纪录仅保存在您浏览器设备本机的存储空间中；纪录包含分析文本、分数、时间，以及导入文档时的来源文件名。在 App 内清除历史纪录，或在浏览器中清除本网站数据，即会移除此本机副本，TruthLens 不持有任何副本。';

  @override
  String get privacyNetworkIntro => '本 App 的内核 AI 侦测完全在设备端运行，但下列支持或选用功能需要连接：';

  @override
  String get privacyNetwork1 =>
      '1. 模型目录与下载：连至 GitHub Releases／Hugging Face 下载您选择的侦测模型文件，仅为下载模型，不会上传任何用户数据。';

  @override
  String get privacyNetwork2 => '2. 模型更新侦测：App 启动时会连接比对版本号，仅发送版本信息，用于提示是否有新版本。';

  @override
  String get privacyNetwork3 =>
      '3. 超链接与参考文献真实性验证：默认打开，可在「设置」关闭。打开时，会将侦测到的网址、DOI 或单笔书目的作者、篇名、年份与期刊字段发送至目标网站及／或 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 与可识别的出版社目录查询，不会发送文档其余内容。只有用户按下人工复核按钮时，才会将该笔查询发送至 Google Scholar。';

  @override
  String get privacyNetwork4 =>
      '4. Web OCR 备用：仅 Web 版适用。OCR 会优先使用您设置的本地 OCR 服务器；若您选择输入 Gemini API 密钥，所选图片及需要 OCR 的 PDF 页面图像会由浏览器直接送往 Google Gemini API，密钥只保存在该浏览器的 localStorage。';

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

  @override
  String settingsVersionSubtitle(String version, String build) {
    return '版本 $version（Build $build）· 本地优先的隐私检测引擎';
  }

  @override
  String get webOcrSettingsTitle => 'Web OCR 设置';

  @override
  String get webOcrPurpose => '在分析前识别上传图片中的印刷或手写文字。';

  @override
  String get webOcrGeminiKeyTitle => 'Gemini API 密钥（可选）';

  @override
  String get webOcrGetKeyButton => '获取密钥';

  @override
  String get webOcrGeminiDescription => '仅在本地 OCR 服务器不可用时启用，密钥只保存在此浏览器。';

  @override
  String get webOcrLocalServerTitle => '本地 OCR 服务器（推荐）';

  @override
  String get webOcrLocalServerDescription =>
      '在您的电脑上运行 OCR；macOS 使用 Apple Vision，Windows 使用 Windows OCR。请在下方填写本地端点。';

  @override
  String get webOcrSetupGuideButton => '零基础设置指南';

  @override
  String get webOcrPriorityTitle => '识别顺序';

  @override
  String get webOcrPriorityDescription =>
      '1. 已设置 URL 时优先使用本地 OCR\n2. 已设置密钥时改用 Gemini\n3. 两者均失败时显示具体诊断原因';

  @override
  String get webOcrSetupGuideTitle => '设置本地 OCR 服务器';

  @override
  String get webOcrSetupGuideBody =>
      '1. 点击下方“打开 OCR 项目”。\n2. macOS：下载 setup_and_run_ocr.sh，打开“终端”，执行：bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows：下载 setup_and_run_ocr.bat，双击运行并允许安装请求。\n4. 等待安装程序显示 OCR 已就绪；它也会设置登录后自动启动。\n5. 返回此处，填写 http://127.0.0.1:5001/ocr，再点击“测试连接”。\n6. 打开图片 OCR，选择一张清晰图片确认能识别文字。\n\n使用 127.0.0.1 时，浏览器和 OCR 服务器必须在同一台电脑运行。测试失败时，请确认安装已完成、端口 5001 未被阻止，且网址以 /ocr 结尾。';

  @override
  String get webOcrOpenProjectButton => '打开 OCR 项目';

  @override
  String get webOcrTestServerButton => '测试连接';

  @override
  String get webOcrTestServerMissingUrl => '请先输入本地 OCR 服务器网址。';

  @override
  String get webOcrTestServerSuccess => '本地 OCR 服务器已启动并可使用。';

  @override
  String get webOcrTestServerFailure => '无法连接本地 OCR 服务器，请打开设置指南并检查安装程序、防火墙和网址。';

  @override
  String get workspaceModeSectionTitle => '工作台模式';

  @override
  String get workspaceModeSectionSubtitle => '选择文件、实时分析与最终证据在同一工作台的呈现方式。';

  @override
  String get workspaceModeOriginal => '原始版面';

  @override
  String get workspaceModeAuto => '自动选择';

  @override
  String get workspaceModeCommandGrid => '指挥网格';

  @override
  String get workspaceModeTimeline => '任务时间轴';

  @override
  String get workspaceModeEvidence => '证据画布';

  @override
  String get workspaceModeCosmicFuture => '宇宙未来风';

  @override
  String get workspaceModeSoftEducation => '教育文柔风';

  @override
  String get workspaceModeTooltip => '切换工作台模式';

  @override
  String get workspaceMoreMenuTooltip => '更多功能';

  @override
  String get workspaceLanguageMenuTitle => '语言';

  @override
  String get workspaceStageImport => '导入';

  @override
  String get workspaceStageParse => '解析';

  @override
  String get workspaceStageAnalyze => '四引擎分析';

  @override
  String get workspaceStageVerify => '核实';

  @override
  String get workspaceStageReport => '报告';

  @override
  String get workspaceLiveFindings => '实时发现';

  @override
  String get workspaceTelemetry => '分析遥测';

  @override
  String get workspaceDocument => '文件工作区';

  @override
  String get workspaceOverallProgress => '整体进度';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return '步骤 $current/$total・$stage';
  }

  @override
  String get workspaceWaiting => '等待导入文件';

  @override
  String get workspaceAnalyzing => '分析进行中';

  @override
  String get workspaceAnalysisComplete => '分析完成';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '已完成 $done/$total 个模块 · 经过 $seconds 秒 · 运行中：$engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return '分析仍在进行，界面可正常操作。过去 $seconds 秒尚无模块完成；大型文件或本机模型可能需要更长时间。';
  }

  @override
  String get workspaceAnalysisFailed => '分析意外停止，请重试或检查模型设置。';

  @override
  String get workspaceNewAnalysis => '新的分析';

  @override
  String get workspaceStopAnalysis => '停止分析';

  @override
  String get workspaceStopAnalysisTitle => '停止当前分析？';

  @override
  String get workspaceStopAnalysisBody => '当前分析仍在进行。停止后会保留文档文字，但未完成的结果不会保存。';

  @override
  String get workspaceAnalysisStopped => '分析已停止，文档文字仍保留在工作台。';

  @override
  String get workspaceSelectedEvidence => '选取证据';

  @override
  String get workspaceNoEvidence => '各引擎完成后，句子证据会依序显示于此。';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return '初步 AI 证据指数：$percent/100';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      '此百分比是「这一句」自己的 AI 信号强度，不是整份文件的最终判定。数字越高代表这句的用字模式越接近 AI 生成；越低则越接近一般人类写作习惯。最终报告会依各引擎权重综合所有句子后得出。';

  @override
  String get workspaceSentenceSignalHeader => '逐句 AI 信号';

  @override
  String get workspaceSentenceColumnHeader => '句子内容';

  @override
  String get workspaceAiEvidenceIndexShort => '指数';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine 本次没有找到证据，未参与投票（角色权重 $weight%）。这代表它在自己负责的面向没有发现 AI 痕迹，不等于它认为本文是人类撰写。';
  }

  @override
  String reportEngineRelationshipDirectionalOnly(String engine, int weight) {
    return '$engine 本次只有弱方向性信号，已折扣纳入初步筛查，但未达可投票的证据阈值（角色权重上限 $weight%）。';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return '本次只有$engine形成可用方向，其余引擎没有方向性信号。结论仅由单一面向支撑，信心请相应打折。';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return '另有 $count 个引擎有执行但未形成方向性信号，已排除在外，避免把「没话说」误算成「看起来像人写的」。';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      '本次未采计语言模型困惑度：困惑度模型（DistilGPT2）只在英文语料上训练，对中日韩文而言它量到的是字节的可预测性，不是语言的可预测性。以标注语料实测，它在这些语言上区分真人与 AI 的能力为 0%，采计只会制造伪阳性。';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return '各语言基准集：$breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return '另有 $count 份较早的样本没有语言标记，无法归入任何语言的基准集——原文默认不保存，事后无从补算语言。随着新文件分析会逐步替换。';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return '本次改用「$variant」：你选用的变体未针对 $language 验证，而这一颗有。';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '「$variant」是多语言模型，但未在 $language 上验证过，其分数的证据强度应低于已验证的语言。';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '「$variant」不涵盖 $language。其分数仅供参考，不应被当成任何方向的证据。';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      '本次未采计语言模型困惑度：无法判定这份文件的语言，因此没有可比对的校准门槛。猜一个语言就会套错尺度，而那正是这道检查要避免的错误。';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return '本次未采计语言模型困惑度：目前使用的模型「$model」尚未量测过 $language 的门槛。没有校准尺度时，原始数值不代表任何意义，因此宁可不采计也不猜。';
  }

  @override
  String get inputNoEditingRecordHint =>
      '这个格式不含编辑记录。PDF、图片与直接粘贴的文字都没有「怎么写出来的」历程，因此分析完全依赖文本统计。若能取得 .docx、.odt 或 .doc 原始档，其编辑历程是强得多的证据——而且不像文本统计，它不会随语言模型进步而失效。';

  @override
  String get reportLowScoreNotProofOfHuman =>
      '低分不等于确认由人撰写。本次没有可用的来源证据，判定仅来自文本统计；文本统计能稳定指认罐头式写作，但指认不了现代模型写得好的输出。';

  @override
  String get reportProvenanceContradictsLowScore =>
      '档案自身的编辑记录与这个低分互相矛盾。来源证据不会随语言模型进步而失效，而文本统计指认不了现代模型写得好的输出。请先看下方的来源证据，再决定要不要采信上面的分数。';

  @override
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  ) {
    return '$total 段中有 $paragraphs 段属于同一个编辑批次，占全文 $percent% 的字数——这与「该区块是一次写入或粘贴的」相符，即使档案本身另有其他编辑批次。';
  }

  @override
  String findingEvasionDetected(int count) {
    return '发现 $count 处字符层级的规避痕迹（零宽字符、外观相同的异体字母、或方向控制字符）。正常的写作工具不会产生这些——有人为了规避检测而处理过这份文字。';
  }

  @override
  String findingCitationsNotFound(int notFound, int total) {
    return '引用的 $total 篇文献中，有 $notFound 篇在所有查核的数据库中都查无此文。捏造引用是语言模型的行为特征，而且与文风不同，一篇文献存不存在是可以查证的事实。';
  }

  @override
  String findingCitationsAllVerified(int total) {
    return '引用的 $total 篇文献全数在公开数据库中找到。';
  }

  @override
  String findingEditingRecordNormal(int minutes, int revisions) {
    return '档案记录了 $minutes 分钟的编辑时间、$revisions 次存档，与「这份文字是在本文件中写成的」相符。';
  }

  @override
  String findingPublicationPredatesGenerativeAi(String doi, int year) {
    return '来源 DOI $doi 与本文档篇名吻合，且于 $year 年完成登记，早于现代生成式 AI 写作系统。';
  }

  @override
  String findingPublicationIdentityMismatch(String doi) {
    return '来源 DOI $doi 虽可解析，但登记篇名与本文档不符；采信前应先核对文档身份。';
  }

  @override
  String get integratedStabilityUnavailable => '分段稳定性无法计算 · 没有逐句证据参与投票';

  @override
  String get integratedNeutralBaseline =>
      '本次未找到足以升级处理的作者特异性证据；画面呈现的是目前最佳方向性筛查，不代表 AI 与真人证据各半。';

  @override
  String get reportVerifiableFindingsTitle => '可查证的事实';

  @override
  String get reportVerifiableFindingsSubtitle =>
      '以下每一项都可以独立查证。与概率不同，这些不会随语言模型进步而失效。';

  @override
  String findingBulkPaste(int characters) {
    return '输入过程中记录到一次粘贴 $characters 个字符。语言模型无法伪造文字如何出现在编辑器里——这一段不是在这里打出来的。';
  }

  @override
  String findingWrittenInApp(int minutes, int deleted) {
    return '这份文字在本应用程序内经过 $minutes 分钟打成，过程中修改了 $deleted 个字符。在这里发生的写作会留下语言模型无法重现的记录。';
  }

  @override
  String get evidenceMatrixTitle => '多证据鉴识矩阵';

  @override
  String get evidenceMatrixSubtitle =>
      '六个方面分开呈现；只有具作者特异性的证据影响作者判读，覆盖率表示本次能检查哪些证据。';

  @override
  String evidenceMatrixCoverage(int available, int total) {
    return '证据覆盖：$available/$total 个方面';
  }

  @override
  String get evidenceAxisText => '文本生成痕迹';

  @override
  String get evidenceAxisTextNote => '四个本地检测引擎提供的概率型文字模式';

  @override
  String get evidenceAxisProcess => '写作过程';

  @override
  String get evidenceAxisProcessNote => '不记录内容的输入、修改与粘贴事件';

  @override
  String get evidenceAxisOrigin => '文档来源';

  @override
  String get evidenceAxisOriginNote => '编辑时间、保存次数与 DOCX／ODT／RSID 元数据';

  @override
  String get evidenceAxisSources => '主张与来源完整性';

  @override
  String get evidenceAxisSourcesNote => '可核查主张、引用锚点与文献数据库核实';

  @override
  String get evidenceStateUnavailable => '无法取得';

  @override
  String get evidenceStateInconclusive => '不足判断';

  @override
  String get evidenceStateReassuring => '相符';

  @override
  String get evidenceStateConcern => '需检查';

  @override
  String get evidenceStrengthNone => '没有证据';

  @override
  String get evidenceStrengthLimited => '有限';

  @override
  String get evidenceStrengthModerate => '中等';

  @override
  String get evidenceStrengthStrong => '强';

  @override
  String get evidenceMatrixTextOnlyWarning =>
      '本次只有文本模式可用。现代 AI 能模仿人类文风，因此不能只靠这个分数确认作者身份。';

  @override
  String get evidenceMatrixStrongConcern =>
      '至少一个独立方面出现强烈的检查信号。采信文本分数前，请先查看该项证据。';

  @override
  String findingUnsupportedClaims(int unsupported, int total) {
    return '$total 个可核查主张中，有 $unsupported 个包含数字、比较或研究归因，却未在同一句提供来源锚点。这不代表内容必然错误，但指出了最该优先核实的主张。';
  }

  @override
  String get integratedAssessmentTitle => '整合作者判读';

  @override
  String get integratedInsufficientEvidence => '未取得可量化的作者信号';

  @override
  String get integratedLikelyAi => '较可能是 AI 生成';

  @override
  String get integratedLikelyMixed => '较可能是人机混合';

  @override
  String get integratedLikelyHuman => '较可能不是 AI 生成';

  @override
  String get integratedBalanced => '未检出明确 AI 主导信号';

  @override
  String get integratedPreliminaryAi => '目前偏向 AI，但接近分界';

  @override
  String get integratedPreliminaryHuman => '目前偏向真人，但接近分界';

  @override
  String integratedLikelihoodLabel(int percent) {
    return 'AI 证据指数：$percent/100';
  }

  @override
  String get integratedLikelihoodUnavailable => 'AI 证据指数：无法估算';

  @override
  String integratedTextScoreLabel(int percent) {
    return '文字模型原始分数：$percent%';
  }

  @override
  String integratedConfidenceLabel(String confidence) {
    return '判读信心：$confidence';
  }

  @override
  String get integratedConfidenceLow => '低';

  @override
  String get integratedConfidenceModerate => '中';

  @override
  String get integratedConfidenceHigh => '高';

  @override
  String integratedEvidenceSufficiency(int percent, String tier) {
    return '证据充分度：$percent/100 · $tier';
  }

  @override
  String get integratedEvidenceTierScreening => '初步筛查';

  @override
  String get integratedEvidenceTierReference => '具参考性';

  @override
  String get integratedEvidenceTierStrong => '支持较充分';

  @override
  String integratedBoundaryAi(int index, int gap) {
    return '指数 $index 只呈现微弱 AI 方向，距 60 分 AI 升级线仍有 $gap 分；目前不足以认定 AI 撰写。';
  }

  @override
  String integratedBoundaryHuman(int index, int gap) {
    return '指数 $index 目前偏向真人，且距 60 分 AI 升级线仍有 $gap 分；但证据有限，仍不能排除 AI 协作。';
  }

  @override
  String integratedEvidenceCoverage(int families, int coverage) {
    return '方向性信号家族：$families/4 · 适用性覆盖 $coverage%';
  }

  @override
  String get integratedEvidenceGatePassed => 'AI 证据门槛：已通过';

  @override
  String get integratedEvidenceGateNotPassed => 'AI 证据门槛：未通过・仅供方向筛查';

  @override
  String integratedQualifiedWarning(String reason) {
    return '$reason 系统仍提供最可能方向，但已降低信心；请把它视为筛查结果，而不是定案证明。';
  }

  @override
  String get integratedIndexCaveat =>
      '独立的 AI 证据门槛表示是否已有足够跨来源支持可升级处理。引用质量、任务契合、贴上行为与异常元数据不能单独产生 AI 判定。本指数是证据分数，不是经总体校准的统计概率。';

  @override
  String get reportTextEngineSignalExplanation =>
      '以下呈现四个文字引擎的诊断信号。相关引擎会先按家族合并，纳入保守折扣后的分类器真人方向，再套用语言／领域适用性与校准可靠度。方向结论回答哪一种解释较受支持；独立的 AI 证据门槛则回答支持是否已足以升级处理。';

  @override
  String reportSynthesisTextScoreContext(int percent) {
    return '四引擎文字模型原始分数为 $percent%；它只是整合判读的一项输入，不是另一个综合判定。';
  }

  @override
  String reportSynthesisStrongestTextSignal(String label, int percent) {
    return '最高文字引擎信号是 $label（$percent%）；它可影响文字模型分数，但不能单独覆盖整合判读。';
  }

  @override
  String composerTextScoreThresholdReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '文字模型原始分数为 $aiPercent%，已达 $thresholdPercent% 诊断标记。这只代表文字信号；报告的作者方向仍以整合判读为准。';
  }

  @override
  String composerTextScoreThresholdNotReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '文字模型原始分数为 $aiPercent%，低于 $thresholdPercent% 诊断标记。未达标记不代表人类撰写；报告的作者方向仍以整合判读为准。';
  }

  @override
  String telemetryIntegratedVerdict(
    String direction,
    int percent,
    String confidence,
  ) {
    return '依本次可用证据加权后，本文“$direction”（AI 证据指数 $percent/100，$confidence信心）。';
  }

  @override
  String telemetryIntegratedUnavailable(String direction, String confidence) {
    return '本次可用模块未形成可量化的作者方向（“$direction”、$confidence信心），因此不提供数字指数。';
  }

  @override
  String integratedStabilityLabel(int percent, int lower, int upper) {
    return '分段稳定性 $percent% · 区间 $lower–$upper%';
  }

  @override
  String integratedInputQualityLabel(int percent) {
    return '输入抽取质量：$percent%';
  }

  @override
  String integratedCalibrationLabel(String value, int count) {
    return '同条件本地基准：p=$value · n=$count';
  }

  @override
  String analysisReadinessLabel(String level) {
    return '分析前信心基准：$level';
  }

  @override
  String get analysisReadinessShortText => '需要更多文字';

  @override
  String get analysisReadinessFewSentences => '可分析句段不足';

  @override
  String get analysisReadinessCoreModel => '核心分类模型不可用';

  @override
  String get analysisReadinessFewEngines => '启用引擎少于两个';

  @override
  String get analysisReadinessExtraction => '文字抽取质量受限';

  @override
  String get analysisReadinessBaseline => '没有同条件本地基准';
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
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

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
  String inputPdfOcrProgress(int page, int total) {
    return 'PDF 文字層無法使用，正在以 OCR 辨識第 $page/$total 頁…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return '已透過 PDF OCR 匯入「$fileName」（$count 字元）';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '「$fileName」沒有可靠的文字層。請先設定 Web OCR，或改用支援原生 OCR 的安裝版，再重新匯入。';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '「$fileName」需要 OCR，但超過 $max 頁安全上限。請先分割 PDF 後分批匯入。';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return '無法可靠讀取「$fileName」。檔案可能已損壞、受密碼保護，或目前設定的 OCR 服務不支援。';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '「$fileName」是舊版 .doc 格式，無法可靠擷取文字內容。請在 Word 另存為 .docx 或匯出成 PDF 後再重新匯入。';
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
  String analysisPreliminaryResult(int percent) {
    return '初步結果：AI 機率 $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return '初步結果：AI 機率 $percent%（精修中…）';
  }

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
  String get modelCatalogLoadFailed => '無法載入模型目錄';

  @override
  String get modelCatalogEmpty => '暫無可用模型';

  @override
  String modelDownloadPathChip(String label) {
    return '$label下載路徑';
  }

  @override
  String get modelDownloadPathModelFile => '模型檔';

  @override
  String get modelDownloadPathCopied => '下載路徑已複製';

  @override
  String settingsSaveFailed(String error) {
    return '設定保存失敗：$error';
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
  String get settingsEngineWeightsTitle => 'AI 模型權重';

  @override
  String get settingsEngineWeightsSubtitle => '設定各引擎影響綜合結果的比例；合計必須為 100% 才能儲存。';

  @override
  String get settingsEngineInfoTooltip => '查看此引擎功能';

  @override
  String get settingsEngineTransformerHelp =>
      '使用多語言 Transformer 評估保留上下文的段落區塊，再將區塊分數映射回逐句報告。設定權重決定影響比例；AI 訊號決定實際貢獻。';

  @override
  String get settingsEngineStatisticalHelp =>
      '分析困惑度、可預測性、Burstiness 與句長變化。規律文字可能提高訊號，因此 ESL 修正可能降低其有效權重。';

  @override
  String get settingsEngineStylometryHelp =>
      '檢查重複開頭、公式化轉折與過度條列等可解釋風格特徵；未命中特徵時訊號為 0%。';

  @override
  String get settingsEngineAdversarialHelp =>
      '偵測可能經改寫或去除 AI 痕跡的文字。低分僅代表微弱殘餘訊號，不代表偵測成立。';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return '合計：$total% — 可以儲存';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return '合計：$total% — 請調整為正好 100%';
  }

  @override
  String get settingsEngineWeightsSave => '儲存權重';

  @override
  String get settingsEngineWeightsSaved => 'AI 模型權重已儲存於此裝置';

  @override
  String get settingsEngineWeightsRestoreDefaults => '恢復預設值';

  @override
  String get engineReasonDisabledByUser => '使用者在設定中關閉此引擎';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model：$total 句均未跨越強 AI 閾值；校準後的微弱訊號為 $percent%';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'AI 訊號指數 $percent/100';
  }

  @override
  String reportEngineDirectionalIndex(int percent) {
    return '弱方向 $percent/100';
  }

  @override
  String get reportEngineNoDirectionalSignal => '未形成方向性訊號';

  @override
  String get reportEngineSignalExplanation =>
      '各數值是診斷用證據指數，不是準確率。設定權重決定影響比例；沒有跨過門檻或折扣後方向的引擎顯示「未形成方向性訊號」，不再以 50% 冒充量測結果。';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return '$total 句均未跨越強改寫訊號閾值；校準後的微弱訊號為 $percent%';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$total 句中有 $count 句跨越強改寫訊號閾值；校準後的文件訊號為 $percent%';
  }

  @override
  String get settingsLinkVerificationTitle => '超連結與參考文獻目錄驗證';

  @override
  String get settingsLinkVerificationSubtitle =>
      '分析報告會將偵測到的網址與參考文獻條目比對 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 與可辨識的出版社目錄。查詢只會送出網址、DOI 或單筆書目的作者、篇名、年份及期刊欄位，不會傳送文件其餘內容。核心 AI 偵測仍在裝置端執行，此驗證可在此關閉。';

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
  String get modelImportWebUnsupported => '匯入自訂模型尚未支援於網頁版，請使用 App 版本。';

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
  String get reportEngineWeightLabel => '權重';

  @override
  String get privacySealNoticeText =>
      'TruthLens 零上傳安全認證：本檢測 100% 於裝置端離線計算，未經雲端傳輸與資料庫儲存。';

  @override
  String get reportModelCalibrationTitle => '模型基準自動校準';

  @override
  String get reportCommunityDiscoveredTag => '社群探尋 (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => '引擎明細';

  @override
  String get reportEngineNotInstalled => '未安裝';

  @override
  String get reportEngineLoadFailedBadge => '載入失敗';

  @override
  String get reportEngineAnalysisLevelTitle => '引擎分析層級';

  @override
  String get reportVerdictAiLikelihood => 'AI 傾向';

  @override
  String get reportVerdictHumanLikelihood => '人類自然寫作';

  @override
  String get reportRadarRoleTransformer => 'Transformer 分類器';

  @override
  String get reportRadarRoleStatistical => '統計特徵分析';

  @override
  String get reportRadarRoleStylometry => '風格特徵分析';

  @override
  String get reportRadarRoleAdversarial => '對抗式防禦';

  @override
  String get reportRadarAxisTransformer => '句級分類';

  @override
  String get reportRadarAxisStatistical => '語言規律';

  @override
  String get reportRadarAxisStylometry => '寫作風格';

  @override
  String get reportRadarAxisAdversarial => '改寫防禦';

  @override
  String get reportVerdictBadgeTitle => '綜合判定';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return '整體 AI 機率 $percent%';
  }

  @override
  String get reportVerdictHintHuman => '多數引擎訊號偏向自然人類寫作。';

  @override
  String get reportVerdictHintLikelyHuman => '整體偏人類，但仍保留少量模型不確定性。';

  @override
  String get reportVerdictHintMixed => '不同引擎訊號分歧，需搭配詳細分析判讀。';

  @override
  String get reportVerdictHintLikelyAi => '多個指標偏向 AI，建議檢查高分片段。';

  @override
  String get reportVerdictHintAi => '整體訊號高度偏向 AI 生成或改寫。';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return '綜合判定：$verdict，整體 AI 機率 $percent%。';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return '最高單項訊號是 $label（$percent%），但最終結果會依各引擎權重合併，不等於單一引擎結論。';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return '目前最大加權貢獻來自 $label（約 $points 個百分點）。';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '「未偵測到明顯 AI 寫作風格」只代表風格引擎沒有抓到固定句式或過渡詞模式；其他模型仍可能因語言規律、句級分類或改寫特徵把整體分數拉高。';

  @override
  String get reportSynthesisModelGap =>
      '有引擎未參與時，請先到模型管理使用「補齊推薦分析模型」；若仍失敗，詳細分析會列出是模型缺失、tokenizer 不支援、檔案遺失或 Web/ONNX Runtime 相容性限制。';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label 未參與本次加權投票，該面向暫以 0% 顯示。$hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return '角色權重 $weight%，對整體分數貢獻約 $points 個百分點$variantText。';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return '（已合併 $count 個模型變體）';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label 未參與本次投票。';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label 未回傳額外文字說明。';
  }

  @override
  String get reportEngineResolutionTransformer =>
      '解法：在模型管理下載並啟用多語言 Transformer；若已下載，重新下載模型與 tokenizer。';

  @override
  String get reportEngineResolutionAdversarial =>
      '解法：在模型管理重新下載改寫偵測模型與 tokenizer；Web 端請更新到已修補 BigInt 相容性的版本後重新分析。';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason。原因：Web 端 ONNX Runtime 回傳 BigInt 張量，舊版橋接無法轉換；已修補為 JS 端先轉 Number，請更新後重新分析。';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason。解法：切換到 catalog 內建模型，或重新下載模型與 tokenizer。';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason。解法：到模型管理點「補齊推薦分析模型」，並確認多語言 Transformer 標示為使用中。';
  }

  @override
  String get reportDetailAnalysisTitle => '詳細分析';

  @override
  String get reportNoEngineData => '尚無引擎分析數據';

  @override
  String get reportEngineNotParticipated => '未參與';

  @override
  String get reportAiContentReportTitle => 'AI 內容檢測報告';

  @override
  String reportAnalysisTimeLabel(String time) {
    return '分析時間：$time';
  }

  @override
  String get reportDownloadPdfButton => '下載 PDF';

  @override
  String get reportSuspiciousLocationsTitle => '可疑內容位置';

  @override
  String reportSentenceCount(int count) {
    return '共 $count 句';
  }

  @override
  String get reportAiProbabilityPrefix => 'AI 機率：';

  @override
  String get helpAdvantage5 =>
      '文件來源鑑識：讀取 .docx／.odt／.doc 的編輯紀錄（編輯時長、存檔次數、編輯批次分散度），這是獨立於文字判定的證據，與 AI 機率分開呈現。PDF 與圖片本身不帶編輯歷程，因此無法提供這類證據。';

  @override
  String get helpAdvantage6 =>
      '永遠提供最可能的 AI／非 AI 方向，並把方向與信心分開。文字太短、模型沉默、引擎不足或分歧過大時會降低信心，而不是把答案整個拿掉。';

  @override
  String get settingsAiSampleTitle => '新增 AI 產出樣本';

  @override
  String get settingsAiSampleSubtitle =>
      '背景校準只會自動蒐集人類樣本。要啟用學習式引擎權重，需另外提供已知由 AI 產出的文章——貼上或匯入後會立即分析並標記為 AI 樣本。';

  @override
  String get settingsAiSampleFromClipboard => '從剪貼簿貼上';

  @override
  String get settingsAiSampleFromFile => '匯入文件';

  @override
  String get settingsAiSampleAnalyzing => '分析中…';

  @override
  String settingsAiSampleAdded(int count) {
    return '已加入 AI 樣本，目前共 $count 份';
  }

  @override
  String get settingsAiSampleTooShort => '內容太短，無法作為樣本（至少需 100 字）';

  @override
  String get settingsAiSampleFailed => '沒有取得可用的內容';

  @override
  String get helpFormatCoverageTitle => '二之一、來源證據的格式限制';

  @override
  String get helpFormatCoverage =>
      '**重要限制：只有 .docx、.odt 與舊版 .doc 帶編輯紀錄。**\n\n| 來源 | 編輯紀錄 |\n|---|---|\n| .docx／.odt | ✅ 有 |\n| .pdf | ❌ 格式本質上沒有編輯歷程 |\n| .doc（舊版） | ✅ 有（OLE2 SummaryInformation） |\n| .txt／.md | ❌ 無容器 |\n| 圖片 OCR | ❌ 只剩像素 |\n| 直接貼上 | ❌ 沒有檔案 |\n\n這對第 3 支柱有直接影響：**只有帶編輯紀錄的文件會自動累積進「有統計保證」的基準集**。若你的收件流程全是 PDF，有保證的基準集永遠不會成長，只會累積無保證的參考樣本。\n\n若要讓來源證據與自動校準真正發揮作用，請取得 .docx 或 .odt 原始檔，而不是列印或轉存的 PDF。這是流程上的要求，不是軟體能繞過的限制——PDF 是輸出格式，本來就不記錄「怎麼寫出來的」。';

  @override
  String provenanceUnsupportedFormat(String format) {
    return '$format 這種格式本身就不攜帶編輯歷程，因此不是「紀錄被清除」，而是從來就沒有。只有 .docx 與 .odt 會記錄編輯時長、存檔次數與編輯批次。';
  }

  @override
  String get provenanceStripped =>
      '這是支援的格式，但檔案裡找不到編輯紀錄——通常代表它被另存新檔、線上轉檔，或從 Google 文件匯出過，這些動作都會把紀錄重置。';

  @override
  String get provenanceHowToGetRecord =>
      '若要讓來源證據發揮作用，請取得 **.docx、.odt 或 .doc 原始檔**（不是列印或轉存的 PDF）。只有原始檔才留有編輯歷程，也才能自動累積進有統計保證的基準集。';

  @override
  String get calibrationAutoTitle => '背景自動蒐集中';

  @override
  String get calibrationAutoSubtitle => '分析完成的文件會自動納入基準集，你不需要手動標註。';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return '已由編輯紀錄認定為人類撰寫：$auto 份；僅供參考的樣本：$observed 份';
  }

  @override
  String get calibrationAutoWhy =>
      '只有帶編輯紀錄（編輯時長、存檔次數、編輯批次分散）的文件才會納入統計保證的基準集，因為那是**獨立於文字判定**的證據。若改用本工具自己的判定結果來自動標註，等於拿自己的答案當標準答案——被誤判的真人作業永遠進不了基準集，門檻會越調越嚴，反而標記更多真人作業。貼上的純文字沒有編輯紀錄，因此只計入下方的參考百分位。';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return '參考：本文分數落在你已分析的 $count 份文件中的第 $percentile 百分位（此數值無統計保證）';
  }

  @override
  String get settingsAutoCollectTitle => '背景自動蒐集校準樣本';

  @override
  String get settingsAutoCollectSubtitle =>
      '分析完成後自動納入基準集。標籤依據為文件編輯紀錄，不會使用本工具自己的判定結果。';

  @override
  String get settingsStoreTextTitle => '保留原文以供離線驗證';

  @override
  String get settingsStoreTextSubtitle =>
      '開啟後，加入基準集的文章會連同原文一起保存在本機，之後可匯出成語料檔進行離線評測。';

  @override
  String get settingsStoreTextWarning =>
      '原文多為他人作品，屬敏感資料。僅在你確實要蒐集離線驗證語料時開啟，匯出後可用下方「清除已保存的原文」立即移除；清除不影響共形預測（它只需要分數）。';

  @override
  String get settingsExportCorpusTitle => '匯出校準語料';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return '可匯出：人類 $human 份、AI $ai 份（離線評測每類需 $required 份）';
  }

  @override
  String get settingsExportCorpusButton => '匯出為 JSONL';

  @override
  String get settingsExportCorpusEmpty => '沒有可匯出的樣本——請先開啟「保留原文」再累積基準集';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return '已匯出 $count 份（略過 $skipped 份未保留原文的樣本）';
  }

  @override
  String get settingsClearStoredText => '清除已保存的原文';

  @override
  String get settingsClearStoredTextDone => '已清除所有原文，分數與校準結果保留不變';

  @override
  String get helpDesignTitle => '設計理念與已知限制';

  @override
  String get helpShiftTitle => '一、核心定位轉換：不比誰的分數準';

  @override
  String get helpShiftBody =>
      '市面上的偵測器幾乎都在回答同一個問題：「這段文字看起來像不像 AI 寫的？」\n\n這是一場必輸的軍備競賽。模型越強，生成文字的統計特徵就越接近人類；而改寫工具的進步速度遠快於偵測器。在這條路上，伺服器端的大模型只是輸得慢一點。\n\nTruthLens 改問另一個問題：「關於這份文件是怎麼產生的，我們手上有哪些證據？各自有多強？」\n\n也就是從「文字風格推測」轉向「來源證據 ＋ 統計上誠實的結論」。這是為什麼本工具刻意不追求單一分數的準確度排名，而是把每一項證據分開攤給你看，並在證據不足時明白說不知道。瀏覽器端執行帶來的真正優勢不是推論速度，而是它看得到伺服器看不到的東西——完整的檔案，以及你自己蒐集的族群基準。';

  @override
  String get helpPillarsTitle => '二、五個支柱';

  @override
  String get helpPillarsBody =>
      '1. 文件來源鑑識（已上線）\n讀取 DOCX／ODT 容器內的編輯紀錄：編輯總時長、存檔次數、建立與修改時間，以及正文的編輯批次標記（RSID）。整篇文章只有一兩組 RSID，通常代表內容是一次寫入的；3000 字卻只編輯 4 分鐘，這個證據比任何困惑度分數都硬。這屬於來源證據，與 AI 機率分開呈現，刻意不併入分數。\n\n2. 本地基準校準與共形預測（已上線）\n你可以把確定由作者本人撰寫的文章加入基準集，系統改以這個族群自己的分布判斷，而非全球通用門檻。共形預測提供分布無關的保證：若基準與待測樣本可交換，偽陽性率不超過你設定的 α。這是降低非母語寫作誤判的關鍵，也是商用產品做不到的——它們沒有這批作者的基準寫作。\n\n3. 學習式引擎權重（已上線）\n當基準集同時累積人類與 AI 兩類樣本後，系統以 Cohen\'s d 效果量衡量每個引擎分開這兩組的能力，據此建議權重，取代手調的固定比例。需你按下「套用」才會生效，不會靜默改動設定。\n\n4. 交叉困惑度 Binoculars（評分核心已完成，尚未上線）\n裸 perplexity 把「文字好不好預測」直接當成「像不像 AI」，因此對用詞平實的非母語寫作有系統性偽陽性。Binoculars 改以「好預測的程度相對於兩個模型彼此分歧的程度」來衡量。評分數學已實作並通過測試，但要真正啟用還需要一組能在瀏覽器執行的小型語言模型配對，以及標註資料的效果驗證。\n\n5. 浮水印偵測（經查證不可行，未實作）\nSynthID-Text 的偵測綁定金鑰：偵測器必須用與生成時相同的金鑰計算，而 Google 生產環境的金鑰並未公開。在瀏覽器端做這件事，對 ChatGPT、Claude、Gemini 的真實輸出永遠不會命中，只會變成永不觸發卻讓人誤以為有在檢查的假功能，因此主動不做。';

  @override
  String get helpCascadeTitle => '三、分級分析與整合判讀';

  @override
  String get helpCascadeBody =>
      '分析依序執行文件來源、統計與風格特徵、Transformer 句級分類，以及必要時才啟動的交叉困惑度。\n\n六個證據面向各自回答不同問題，因此分開呈現。作者判讀只接受直接文字痕跡，並可由確定的逐步寫作、文件來源或漸進草稿證據向非 AI 修正。缺少引用、偏離任務、整段貼上、修訂很少或中繼資料異常仍列為待核查事項，但不能單獨把文件判成 AI。\n\n信心會獨立計算。可分析句少於 5 句、內容少於 100 字、引擎少於 2 個、模型沉默或分歧過大時，都會降低信心並顯示限制警告。方向仍可用於篩查，但低信心結果不得當成定案證明。';

  @override
  String get helpRisksTitle => '四、必須誠實面對的風險';

  @override
  String get helpRisksBody =>
      '以下每一項都是本工具真實存在的限制，請在做出任何決定前一併考慮：\n\n1. 來源證據可以被清除或偽造\n另存新檔、線上轉檔、從 Google 文件匯出、或複製到新檔案，都會讓編輯紀錄歸零。因此有訊號只是佐證，沒有訊號也絕不代表文件必然由人撰寫。\n\n2. 共形保證依賴「可交換性」\n保證成立的前提是基準樣本與待測文章出自同一群人、同一類寫作任務。作者寫作能力明顯進步、或換了完全不同的任務類型，前提就不再成立，需要重建基準集。\n\n3. 基準集本身可能被汙染\n如果拿來當基準的作業其實是 AI 代寫的，整個校準都會偏掉。基準樣本必須在可控環境下蒐集，例如在可控環境下當場完成的作品。\n\n4. 瀏覽器端小模型的原始準度不如伺服器端大模型\n這是 Web-only 決策換取隱私的必然代價。本工具的價值不是神奇地給出精準單一分數，而是提供可解釋的方向、明確信心與證據限制。\n\n5. 任何分數都不應單獨作為指控的依據\n請務必搭配逐句證據、文件來源，以及你對這位作者既有的了解一起判讀。本工具的設計目標是輔助你進行對話，不是代替你做出裁決。';

  @override
  String get calibrationAddHuman => '加入為「人類撰寫」基準';

  @override
  String get calibrationAddAi => '加入為「AI 產出」樣本';

  @override
  String calibrationCounts(int human, int ai) {
    return '基準集：人類 $human 份、AI $ai 份';
  }

  @override
  String get learnedWeightsTitle => '學習式引擎權重';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return '目前人類 $human 份、AI $ai 份。兩類各需至少 $required 份才能學出可靠的權重；在此之前沿用你手動設定的權重。';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return '已可依你的 $human 份人類樣本與 $ai 份 AI 樣本學出權重。';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine：建議權重 $weight%（分離度 $effect）';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return '注意：$engine 把兩組判反了（AI 樣本反而拿到較低分數），因此權重歸零。這通常代表該引擎不適用於你這類文本。';
  }

  @override
  String get learnedWeightsApply => '套用學習到的權重';

  @override
  String get learnedWeightsApplied => '已套用學習到的權重';

  @override
  String get learnedWeightsExplain =>
      '權重依各引擎「把你的人類樣本與 AI 樣本分開」的程度計算（Cohen\'s d 效果量）：分得越開、組內越穩定的引擎權重越高。這會取代手調的固定權重，讓集成貼合你自己的文本類型。';

  @override
  String get calibrationTitle => '本地基準校準';

  @override
  String get calibrationEmpty =>
      '尚未建立基準集。加入若干份「確定由作者本人撰寫」的文章後（例如在可控環境下當場完成的作品），系統就能改用這個族群自己的分布來判斷，而不是套用全球通用的門檻——這正是降低非母語寫作偽陽性的關鍵。';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return '基準集目前 $count 份，要讓 $alpha% 的偽陽性率上限真的成立，至少需要 $required 份。在補齊之前只顯示參考數值，不會據此標記任何文章。';
  }

  @override
  String calibrationFlagged(int alpha) {
    return '在 $alpha% 偽陽性率上限的設定下，本文**被標記**。';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return '在 $alpha% 偽陽性率上限的設定下，本文**未被標記**。';
  }

  @override
  String calibrationPValue(String value, int count) {
    return '保守 p 值 $value（相對於 $count 份基準樣本）';
  }

  @override
  String calibrationPercentile(int percentile) {
    return '分數落在基準集的第 $percentile 百分位';
  }

  @override
  String get calibrationCaveat =>
      '這個保證的前提是「基準樣本與待測文章可交換」——也就是出自同一群人、同一類寫作任務。若作者的寫作能力明顯進步、或換了完全不同的任務類型，前提就不再成立，需要重新建立基準集。另請注意：若基準樣本本身就是 AI 代寫的，整個校準都會偏掉，取樣必須在可控環境下進行。';

  @override
  String get calibrationAddButton => '把這份加入基準集';

  @override
  String calibrationAdded(int count) {
    return '已加入基準集，目前共 $count 份';
  }

  @override
  String get settingsCalibrationTitle => '本地基準校準集';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return '目前 $count 份（此 α 需要 $required 份）';
  }

  @override
  String get settingsCalibrationClear => '清空基準集';

  @override
  String get settingsCalibrationCleared => '基準集已清空';

  @override
  String get settingsAlphaTitle => '偽陽性率上限（α）';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return '目前 $alpha% — 數值越低越保守，但需要越多基準樣本（至少 $required 份）';
  }

  @override
  String get abstentionHeadline => '證據不足，不做判定';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return '只有 $count 個可分析句段（至少需要 $required 個才能衡量句段穩定度）。因此會降低信心，但符合條件的文件級訊號仍可參與判讀。';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return '內容只有 $count 字（至少需要 $required 字）。文字量太少時，任何寫作特徵都可能只是偶然。';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return '只有 $available/$total 個引擎參與投票，無法多角度交叉驗證。請到模型管理補齊後重跑。';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return '各引擎的看法相差 $spread 個百分點，分歧大到加權平均已失去意義。請改用逐句證據與文件來源自行判讀。';
  }

  @override
  String get abstentionNoEvidenceFound =>
      '所有引擎都有執行，但沒有任何一個找到可用證據。這個低分只是診斷用的 fallback 輸出，不是人類撰寫的證據。';

  @override
  String abstentionSingleWeakEvidenceSource(int count) {
    return '只有 $count 個引擎找到可用證據，而且整體分數仍低於 AI 標記門檻。這代表本次證據覆蓋不足，不代表已證明由人類撰寫。';
  }

  @override
  String get abstentionScoreStillShown => '下方仍保留完整的分數與逐句證據供你自行參考，但請不要把它當成結論。';

  @override
  String get provenanceTitle => '文件來源證據';

  @override
  String get provenanceRiskHigh => '編輯紀錄明顯不尋常';

  @override
  String get provenanceRiskMedium => '編輯紀錄有可疑之處';

  @override
  String get provenanceRiskLow => '編輯紀錄看起來正常';

  @override
  String get provenanceRiskUnknown => '沒有可用的編輯紀錄';

  @override
  String get provenanceNoMetadata =>
      '這份輸入沒有夾帶編輯紀錄（直接貼上的文字、PDF、或紀錄已被清除），因此無法從來源判斷，只能看文字本身的分析。';

  @override
  String provenanceEditingDuration(int minutes) {
    return '檔案記錄的編輯總時長：$minutes 分鐘';
  }

  @override
  String provenanceRevisionCount(int count) {
    return '存檔次數：$count 次';
  }

  @override
  String provenanceApplication(String name) {
    return '產生軟體：$name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return '正文的編輯批次標記只有 $count 組，但內容有 $words 字。正常一邊想一邊寫會留下數十組，這種高度集中通常代表整段是一次寫入的（例如貼上）。';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words 字對上 $minutes 分鐘的編輯時長，平均每分鐘 $wpm 字，遠高於一般人能持續維持的打字速度。';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return '檔案記錄的編輯總時長接近 0，但正文有 $words 字。';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return '$words 字的內容只存檔過 $count 次。';
  }

  @override
  String get provenanceCaveat =>
      '請注意：這些紀錄可以被清除或重置——另存新檔、線上轉檔、從 Google 文件匯出、或複製到新檔案都會讓它歸零。因此有訊號只能當作佐證，不能單獨當成結論；沒有訊號也不代表文件必然由人撰寫。';

  @override
  String get telemetrySummaryTitle => '分析總結';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '$total 個引擎中有 $engines 個跑完了，整體 AI 機率 $percent%，判定為「$verdict」。';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return '各引擎看法蠻一致的，最高 $high%、最低 $low%，這個結論算站得住腳。';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return '引擎之間看法不太一樣：$highLabel給了 $high%，$lowLabel卻只有 $low%，這種時候別只看總分，往下翻逐句證據會準得多。';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return '把分數拉上來的主要是$label，大約貢獻了 $points 個百分點。';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return '逐句掃過 $total 句，沒有任何一句踩到強 AI 訊號線。';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return '逐句掃過 $total 句，其中 $count 句踩到強 AI 訊號線，值得一句一句看過。';
  }

  @override
  String get telemetrySummaryAdviceHuman => '整體讀起來就是人自己寫的，沒有特別需要追查的地方。';

  @override
  String get telemetrySummaryAdviceMixed =>
      '這份落在灰色地帶，光憑分數下結論太冒險，建議搭配逐句證據和文件來源一起看。';

  @override
  String get telemetrySummaryAdviceAi => '訊號明顯偏向 AI 生成或改寫，建議把標紅的句子逐一核對過再做決定。';

  @override
  String telemetrySummaryModelGap(int count) {
    return '另外有 $count 個引擎這次沒參與投票，把握度會打點折；到模型管理補齊後重跑會更準。';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'AI 機率 < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'AI 機率 $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'AI 機率 ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return '信心度低：可用模型權重不足 60%（$threshold% 閾值）。$available/$total 引擎參與投票。建議參考各引擎詳細分析結果。';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return '信心度高：$available/$total 個檢測模型達成共識（$threshold% 以上權重同意此判定）';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return '信心度低（$available/$total）';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return '信心度高（$available/$total）';
  }

  @override
  String get reportMetricAiSentenceRatio => '強 AI 訊號句比例';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$total 句中有 $count 句跨越 60% 強訊號閾值';
  }

  @override
  String get reportMetricElapsed => '分析耗時';

  @override
  String get reportMetricElapsedNormal => '0.5-5s 正常';

  @override
  String get reportMetricReliability => '可信度';

  @override
  String get reportReliabilityLow => '低';

  @override
  String get reportReliabilityHigh => '高';

  @override
  String get reportReliabilityNeedsReview => '需人工驗證';

  @override
  String get reportReliabilityHighTrust => '高度可信';

  @override
  String get reportSentenceAnalysisTitle => '逐句分析';

  @override
  String get suspiciousFilterAll => '可疑';

  @override
  String get suspiciousFilterHigh => '高危';

  @override
  String get suspiciousFilterMedium => '中等';

  @override
  String get suspiciousExcludedTooltip => '已排除單一字母、頁碼、章節序號與過短 OCR/PDF 片段。';

  @override
  String suspiciousCount(int count) {
    return '$count 項';
  }

  @override
  String get suspiciousEmpty => '無可疑內容';

  @override
  String get suspiciousRiskHigh => '高';

  @override
  String get suspiciousRiskMedium => '中';

  @override
  String get suspiciousReasonHighModelSignals => '多個模型訊號高度偏向 AI';

  @override
  String get suspiciousReasonSentenceSignal => '句級模型訊號偏高';

  @override
  String suspiciousOriginalLocation(String location) {
    return '原文位置 $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return '原文位置 $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return '句子 #$number';
  }

  @override
  String get suspiciousEvidenceLabel => '判定依據：';

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
  String get reportLinkCitationUnreachable => '無法確認（連線逾時或書目服務無回應）';

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
  String get reportBibRecheckAllUnreliableButton => '重新查核全部未通過文獻';

  @override
  String get reportBibRecheckOneTooltip => '重新查核此筆文獻';

  @override
  String get reportBibResultHint =>
      '依作者、年份、篇名與期刊資訊交叉比對 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 與可辨識的出版社目錄；高可信度結果必須有 DOI 登記或多個一致的書目欄位，未達可靠匹配者標示為未通過核實。Google Scholar 因未提供自動查詢 API，僅供使用者主動人工複核。';

  @override
  String reportBibVerificationSource(String source) {
    return '核實依據：$source';
  }

  @override
  String get reportBibGoogleScholarManualLookup => '前往 Google Scholar 人工複核';

  @override
  String reportBibHighConfidence(String journal) {
    return '高可信度：應存在$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（登記於《$journal》）';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return '期刊名稱不一致：文件載為《$reported》，查核登記為《$registered》，請核對此筆文獻。';
  }

  @override
  String get reportBibNotFound => '查無相近匹配，可能為虛構文獻';

  @override
  String get reportBibUncertain => '疑似不可靠，未通過登記資料核實';

  @override
  String reportBibTruncated(int max, int count) {
    return '將逐筆核實全部文獻（共偵測到 $count 筆）';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return '已完成 $count 筆，結果會持續更新。';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return '進度 $completed/$total，$current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return '目前：$text';
  }

  @override
  String get reportBibProgressFinalizing => '正在整理結果';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base：找到相似候選「$candidate」，但作者、年份或篇名未達可靠匹配門檻。';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base：查核來源無可靠回應或條目資訊不足，系統不將此文獻視為已核實存在。';
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
    return '本文較可能是 AI 生成，建議進一步審查（整合 AI 可能性 $percent%）';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return '這段文字呈現人類與 AI 混合的特徵（AI 機率 $percent%）';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return '本文較可能不是 AI 生成（整合 AI 可能性 $percent%）';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return '這段文字極可能為人類撰寫（AI 機率 $percent%）';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return '整體 AI 機率越過固定的 $percent% 閾值，被標記為 AI。';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '整體 AI 機率未達 $percent% 標記閾值。';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return '整體 AI 機率為 $aiPercent%，已達固定的 $thresholdPercent% AI 標記門檻，因此報告會標記為 AI。建議搭配句級證據與各引擎理由再做最終判斷。';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '整體 AI 機率為 $aiPercent%，低於固定的 $thresholdPercent% AI 標記門檻，因此報告不會正式標記為 AI；機率與證據仍會保留供你檢視。';
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
    return '語言模型困惑度偏低（$ppl）[偏 AI 特徵]，文本規律性與可預測度高';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return '語言模型困惑度偏高（$ppl）[偏人類特徵]，符合人類寫作不可預測性';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return '語言模型困惑度中等（$ppl）[中性特徵]';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return '句子長度高度一致（burstiness $value）[偏 AI 特徵]，節奏平穩均勻';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return '句長起伏顯著（burstiness $value）[偏人類特徵]，節奏變化豐富';
  }

  @override
  String engineReasonBurstinessMid(String value) {
    return '句長變化（burstiness $value）落在 0.30–0.55 中性帶，未形成方向性證據';
  }

  @override
  String engineReasonTtrLow(String value) {
    return '詞彙重複度較高（TTR $value）[偏 AI 模板/固定格式特徵]';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return '詞彙多樣性豐富（TTR $value）[偏人類特徵]';
  }

  @override
  String engineReasonMattrNoAiSignal(String value, String cut) {
    return '詞彙多樣性（MATTR $value）未跨過校準後的 AI 訊號切點 $cut';
  }

  @override
  String engineReasonStatisticalSummaryAi(String percent) {
    return '綜合統計分析：合格指標偏向 AI 生成特徵（訊號指數 $percent/100）';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return '綜合統計分析：合格指標偏向人類自然寫作（AI 訊號指數 $percent/100）';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return '綜合統計分析：合格指標方向互有消長（AI 訊號指數 $percent/100）';
  }

  @override
  String get reportFormulaTitle => '加權計算透明度與參數解析';

  @override
  String get reportFormulaExplanation => '整體 AI 機率係由各可用引擎之判定機率依其指定權重加權平均計算得出：';

  @override
  String get reportFormulaActiveEngines => '參與投票引擎與權重';

  @override
  String get reportFormulaCalculation => '加權計算公式';

  @override
  String get reportFormulaFinalResult => '最終加權 AI 機率';

  @override
  String get reportFormulaEslApplied => '已套用 ESL 非母語寫作偏差修正（統計模型權重已減半）';

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
  String engineReasonPan25LexicalAi(int percent) {
    return 'PAN 2025 詞彙指紋偏向 AI（$percent/100）；這項獨立英文基準偵測到詞語與片語分布不同於其人類語料';
  }

  @override
  String engineReasonPan25LexicalHuman(int percent) {
    return 'PAN 2025 詞彙指紋偏向真人（$percent/100）；這仍是模型證據，不是作者身分證明';
  }

  @override
  String engineReasonPan25LexicalNeutral(int percent) {
    return 'PAN 2025 詞彙指紋落在中性區（$percent/100），不提供方向';
  }

  @override
  String engineReasonCompressionCoherence(String value) {
    return '跨半段壓縮一致性（$value）超過 PAN 2025 人類語料第 95 百分位篩線［弱 AI 方向訊號］';
  }

  @override
  String engineReasonAssistantResponseArtifact(int count) {
    return '偵測到 $count 處聊天助理回覆殘留，例如稱呼提問者或主動表示可修改受託文字';
  }

  @override
  String get engineReasonAdversarialNotInstalled => '改寫偵測模型尚未安裝，未參與本次投票';

  @override
  String get engineReasonTransformerNotInstalled => '模型尚未安裝或使用中模型未支援，未參與本次投票';

  @override
  String get modelRepairNoActiveVariant => '未找到使用中的模型；請在模型管理下載推薦模型。';

  @override
  String get modelRepairCustomRemoved =>
      '已移除載入失敗的自訂模型。自訂模型無法自動重新下載，請重新匯入模型與 tokenizer。';

  @override
  String get modelRepairNoSource =>
      '已移除載入失敗的模型檔，但目前找不到可重新下載的 catalog 來源；請到模型管理重新下載推薦模型。';

  @override
  String modelRepairRedownloaded(Object name) {
    return '偵測到模型檔可能損毀或不相容，已自動重新下載 $name；請重新執行分析。';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return '已移除載入失敗的模型檔，但自動重新下載未完成；請確認網路後在模型管理重新下載 $name。';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      '未找到使用中的 Transformer 模型；請到模型管理下載或設為使用中';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return '使用中模型的 tokenizer 類型不支援（$tokenizer）；請切換到支援 bert-wordpiece 或 roberta-bpe 的模型';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Transformer 模型或 tokenizer 路徑缺失；請在模型管理重新下載';

  @override
  String get engineTransformerMissingFiles =>
      'Transformer 模型或 tokenizer 檔案不存在；請在模型管理重新下載';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'ONNX opset 版本不支援（該模型版本太新，需更新應用）: $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Tokenizer 格式損毀: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      '模型載入或推論失敗，且自動修復未完成；請到模型管理重新下載使用中的 Transformer 模型與 tokenizer。';

  @override
  String get engineAdversarialNoActiveVariant => '未找到使用中的改寫偵測模型';

  @override
  String get engineAdversarialMissingFiles => '模型或 tokenizer 檔案不存在，請在模型管理重新下載';

  @override
  String get engineAdversarialRepairFailed =>
      '模型載入或推論失敗，且自動修復未完成；請到模型管理重新下載改寫偵測模型與 tokenizer。';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return '模型未參與本次投票。$error';
  }

  @override
  String get patternNotAnalyzable => '片段過短或疑似 PDF/OCR 噪音，未作 AI 句級判讀';

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
      'TruthLens 是一款**完全在瀏覽器端執行**的 AI 內容檢測工具。四個文字分析引擎檢查直接文字痕跡；寫作過程、文件來源及來源完整性則作為分開呈現的鑑識證據，文件內容不會上傳到任何伺服器。\n\n只有具作者特異性的訊號能提高 AI 判定。相關引擎會先合併為獨立證據家族，高分不會反過來增加自身權重。報告區分較可能真人、人機混合及較可能 AI 生成，並提供整合可能性指數與獨立信心等級；原始引擎訊號及每一條證據仍會分開顯示，避免低信心方向被包裝成確定證明。';

  @override
  String get helpComparisonTitle => '與市面主流工具比較';

  @override
  String get helpComparisonDisclaimer =>
      '以下比較依各工具官方公開資訊與一般市場認知整理，僅供功能定位參考，非第三方認證的效能實測數據。';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero 的運算主要在雲端進行、文件需上傳；TruthLens 四個偵測引擎皆在你的瀏覽器內執行，文件內容不外傳。';

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
      'Originality.ai 為按篇計費的訂閱制，且需將文件上傳雲端；TruthLens 核心運算在瀏覽器端完成，無需訂閱也無使用次數限制。';

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
      'Winston AI 的 OCR 圖片辨識需上傳圖片至雲端；TruthLens 的 OCR 優先使用你自行設定的本地 OCR 伺服器，只有在你主動提供 Gemini API 金鑰時才會使用雲端備援——用不用雲端由你決定。';

  @override
  String get helpVsWinston2 =>
      'Winston AI 以報告排版精美著稱；TruthLens 提供 AI 動態生成排版報告（未安裝 LLM 時自動退回模板），可匯出 PDF／CSV／JSON／PNG 四種格式。';

  @override
  String get helpAdvantagesTitle => 'TruthLens 的獨有優勢';

  @override
  String get helpAdvantage1 =>
      '超連結與文獻真實性驗證：檢查網址是否可連線，以 Crossref／DataCite 核實 DOI 登記，並透過 OpenAlex、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 與出版社目錄交叉比對書目資料；每筆通過核實的文獻會標示證據來源，Google Scholar 僅供人工複核。';

  @override
  String get helpAdvantage2 =>
      '文獻參考真實性核實：即使參考文獻沒有超連結（純作者—年份格式），也能透過書目比對抓出可能虛構的引用——這正是 AI 幻覺內容常見的破綻。';

  @override
  String get helpAdvantage3 =>
      'ESL（非母語寫作者）偏差修正：自動偵測非母語寫作特徵並降低統計模型權重，避免將非母語人士的自然寫作誤判為 AI。';

  @override
  String get helpAdvantage4 =>
      '本機紀錄與匯出：報告可匯出 PDF／CSV／JSON／PNG，歷史紀錄只保存在本機，並在有匯入檔案時保留來源檔名，方便重新分析或回顧。';

  @override
  String get helpWorkflowTitle => '完整操作流程';

  @override
  String helpWorkflowStepLabel(int step) {
    return '第 $step 步';
  }

  @override
  String get helpWorkflowStep1Title => '模型下載與更新';

  @override
  String get helpWorkflowStep1Body =>
      '首次啟動會引導安裝核心偵測模型；之後可隨時至「設定 → AI 模型管理」查看、下載、更新或移除。App 會在啟動時主動比對最新版本，若有更新，設定齒輪圖示與「AI 模型管理」項目會出現紅點提示。';

  @override
  String get helpWorkflowStep2Title => '如何選用模型（目的與效果）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      '多語言 AI 分類器（權重 40%）：以受控段落區塊保留上下文，再將機率映射回逐句證據。';

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
      '可在「設定」個別啟用／停用引擎並調整證據家族的權重上限。模型若未經該語言或領域驗證、校準較弱或文字覆蓋不足，本次有效權重就會下修；相關引擎會先在同一家族內合併，不能重複放大相同訊號。';

  @override
  String get helpWorkflowStep3Title => '加入內容';

  @override
  String get helpWorkflowStep3Body =>
      '三種輸入方式：直接貼上文字、圖片辨識 OCR、匯入文件（txt / md / pdf / docx / doc / odt）。PDF 匯入會比較兩套文字層解析結果並排除亂碼；掃描型 PDF 在 OCR 可用時會自動逐頁辨識。匯入文件時，檔名會顯示在輸入頁標題下方，並單獨成行出現在報告標題；貼上或手動輸入文字時，檔名維持空白。\n\nOCR 會優先使用你設定的本地伺服器，只有在你自行提供 Gemini API 金鑰時才使用雲端備援。';

  @override
  String get helpWorkflowStep4Title => '開始分析';

  @override
  String get helpWorkflowStep4Body =>
      '點擊「開始檢測」，四個引擎並行執行，畫面即時顯示各引擎完成進度。若偵測到非母語寫作特徵，會自動套用 ESL 偏差修正（可在設定關閉）。分析進行中可隨時從工具列中止；文件文字會保留，但未完成的結果不會被儲存。';

  @override
  String get helpWorkflowStep5Title => '查看與匯出結果';

  @override
  String get helpWorkflowStep5Body =>
      '文件匯入、四引擎即時進度與完整報告現在都保留在同一個戰情中心工作台。可隨時切換「指揮網格」、「任務時間軸」與「證據畫布」，不會中斷或重新分析；自動模式在桌面使用指揮網格、手機使用任務時間軸。結果包含整體判定、AI 機率、信心度、耗時、逐句證據、引擎貢獻、連結與文獻核實，並可匯出 PDF、CSV、JSON、PNG及保存至本機歷史。';

  @override
  String get helpWorkflowStep1ChipOnboarding => '首次啟動引導';

  @override
  String get helpWorkflowStep1ChipModelManager => '模型管理中心';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => '自動版本偵測';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => '統計分析 (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => '風格特徵 (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => '對抗防禦 (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => '報告 LLM (選用)';

  @override
  String get helpWorkflowStep3ChipPaste => '直接貼上';

  @override
  String get helpWorkflowStep3ChipImageOcr => '圖片 OCR';

  @override
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation => '碼段/公式隔離';

  @override
  String get helpWorkflowStep4ChipEnsemble => '四引擎並列推論';

  @override
  String get helpWorkflowStep4ChipLiveProgress => '即時動態進度';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'ESL 非母語寫作校正';

  @override
  String get helpWorkflowStep4ChipStoppable => '隨時可中止';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'AI 總覽儀表';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => '句級熱力圖';

  @override
  String get helpWorkflowStep5ChipCitationVerification => '文獻驗證';

  @override
  String get helpWorkflowStep5ChipExportFormats => 'PDF / CSV / JSON / PNG 匯出';

  @override
  String get helpTuningTitle => '模型下載與調適教學（零基礎）';

  @override
  String get helpTuningStep1Title => '開啟模型管理畫面';

  @override
  String get helpTuningStep1Body =>
      '可從完整「設定」頁，或寬螢幕首頁右側設定面板，開啟「AI 模型管理」來下載、更新、啟用或移除本機模型。';

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
      '若你已在其他地方取得或自行微調過相容的 .onnx 模型，可透過「設定 → 自訂 ONNX 模型匯入與測試」匯入——需提供模型檔、對應的 Tokenizer 設定（或選擇「不需要」）與 AI 類別索引；匯入前會自動偵測是否為重複匯入的相同檔案，避免不小心重複安裝。也可在設定中調整四引擎權重。';

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
  String get privacyWebOverview1 =>
      'TruthLens 完全以網頁應用程式的形式在您的瀏覽器分頁中執行，不需要安裝；文件文字與分析結果不會離開您的裝置，下載的偵測模型也只快取在瀏覽器自身的沙盒儲存空間（OPFS）中，不在任何伺服器上。';

  @override
  String get privacyWebOverview2 =>
      '只有在您主動選擇匯入、掃描或貼上時，本頁才會讀取對應的檔案、圖片或剪貼簿內容；不會讀取其他分頁、其他網站的資料，或您未選擇的檔案。';

  @override
  String get privacySectionOverviewWeb => '概要';

  @override
  String get privacyRemoveWeb => '在瀏覽器設定中清除本網站的資料（或直接關閉分頁即可，因為沒有任何內容儲存在伺服器上）';

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
      '您輸入、貼上或匯入的文字內容，皆在您的裝置上由本機 AI 模型完成分析。TruthLens 不會將文件文字上傳到自有伺服器或第三方 AI 偵測服務。';

  @override
  String get privacyDataHandling3 =>
      '分析結果與歷史紀錄僅儲存在您瀏覽器裝置本機的儲存空間中；紀錄包含分析文字、分數、時間，以及匯入文件時的來源檔名。在 App 內清除歷史紀錄，或在瀏覽器中清除本網站資料，即會移除此本機副本，TruthLens 不持有任何副本。';

  @override
  String get privacyNetworkIntro => '本 App 的核心 AI 偵測完全在裝置端執行，但下列支援或選用功能需要連線：';

  @override
  String get privacyNetwork1 =>
      '1. 模型目錄與下載：連至 GitHub Releases／Hugging Face 下載您選擇的偵測模型檔案，僅為下載模型，不會上傳任何使用者資料。';

  @override
  String get privacyNetwork2 => '2. 模型更新偵測：App 啟動時會連線比對版本號，僅傳送版本資訊，用於提示是否有新版本。';

  @override
  String get privacyNetwork3 =>
      '3. 超連結與參考文獻真實性驗證：預設開啟，可在「設定」關閉。開啟時，會將偵測到的網址、DOI 或單筆書目的作者、篇名、年份與期刊欄位送往目標網站及／或 Crossref、OpenAlex、DataCite、Semantic Scholar、Europe PMC／PubMed／AGRICOLA、ERIC、DOAJ 與可辨識的出版社目錄查詢，不會傳送文件其餘內容。只有使用者按下人工複核按鈕時，才會將該筆查詢送往 Google Scholar。';

  @override
  String get privacyNetwork4 =>
      '4. Web OCR 備援：僅 Web 版適用。OCR 會優先使用您設定的本地 OCR 伺服器；若您選擇輸入 Gemini API 金鑰，所選圖片及需要 OCR 的 PDF 頁面影像會由瀏覽器直接送往 Google Gemini API，金鑰只儲存在該瀏覽器的 localStorage。';

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

  @override
  String settingsVersionSubtitle(String version, String build) {
    return '版本 $version（Build $build）· 本地優先的隱私檢測引擎';
  }

  @override
  String get webOcrSettingsTitle => 'Web OCR 設定';

  @override
  String get webOcrPurpose => '在分析前辨識上傳圖片中的印刷或手寫文字。';

  @override
  String get webOcrGeminiKeyTitle => 'Gemini API 金鑰（可選）';

  @override
  String get webOcrGetKeyButton => '取得金鑰';

  @override
  String get webOcrGeminiDescription => '僅在本地 OCR 伺服器無法使用時啟用，金鑰只儲存在此瀏覽器。';

  @override
  String get webOcrLocalServerTitle => '本地 OCR 伺服器（建議）';

  @override
  String get webOcrLocalServerDescription =>
      '在您的電腦上執行 OCR；macOS 使用 Apple Vision，Windows 使用 Windows OCR。請在下方填入本地端點。';

  @override
  String get webOcrSetupGuideButton => '零基礎設定指引';

  @override
  String get webOcrPriorityTitle => '辨識順序';

  @override
  String get webOcrPriorityDescription =>
      '1. 已設定 URL 時優先使用本地 OCR\n2. 已設定金鑰時改用 Gemini\n3. 兩者皆失敗時顯示具體診斷原因';

  @override
  String get webOcrSetupGuideTitle => '設定本地 OCR 伺服器';

  @override
  String get webOcrSetupGuideBody =>
      '1. 點選下方「開啟 OCR 專案」。\n2. macOS：下載 setup_and_run_ocr.sh，開啟「終端機」，執行：bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows：下載 setup_and_run_ocr.bat，按兩下執行並允許安裝要求。\n4. 等待安裝程式顯示 OCR 已就緒；它也會設定登入後自動啟動。\n5. 回到此處，填入 http://127.0.0.1:5001/ocr，再按「測試連線」。\n6. 開啟圖片 OCR，選一張清晰圖片確認能辨識文字。\n\n使用 127.0.0.1 時，瀏覽器與 OCR 伺服器必須在同一台電腦執行。測試失敗時，請確認安裝已完成、連接埠 5001 未被封鎖，且網址以 /ocr 結尾。';

  @override
  String get webOcrOpenProjectButton => '開啟 OCR 專案';

  @override
  String get webOcrTestServerButton => '測試連線';

  @override
  String get webOcrTestServerMissingUrl => '請先輸入本地 OCR 伺服器網址。';

  @override
  String get webOcrTestServerSuccess => '本地 OCR 伺服器已啟動並可使用。';

  @override
  String get webOcrTestServerFailure => '無法連上本地 OCR 伺服器，請開啟設定指引並檢查安裝程式、防火牆與網址。';

  @override
  String get workspaceModeSectionTitle => '工作台模式';

  @override
  String get workspaceModeSectionSubtitle => '選擇文件、即時分析與最終證據在同一工作台的呈現方式。';

  @override
  String get workspaceModeOriginal => '原始版面';

  @override
  String get workspaceModeAuto => '自動選擇';

  @override
  String get workspaceModeCommandGrid => '指揮網格';

  @override
  String get workspaceModeTimeline => '任務時間軸';

  @override
  String get workspaceModeEvidence => '證據畫布';

  @override
  String get workspaceModeCosmicFuture => '宇宙未來風';

  @override
  String get workspaceModeSoftEducation => '教育文柔風';

  @override
  String get workspaceModeTooltip => '切換工作台模式';

  @override
  String get workspaceMoreMenuTooltip => '更多功能';

  @override
  String get workspaceLanguageMenuTitle => '語言';

  @override
  String get workspaceStageImport => '匯入';

  @override
  String get workspaceStageParse => '解析';

  @override
  String get workspaceStageAnalyze => '四引擎分析';

  @override
  String get workspaceStageVerify => '核實';

  @override
  String get workspaceStageReport => '報告';

  @override
  String get workspaceLiveFindings => '即時發現';

  @override
  String get workspaceTelemetry => '分析遙測';

  @override
  String get workspaceDocument => '文件工作區';

  @override
  String get workspaceOverallProgress => '整體進度';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return '步驟 $current/$total・$stage';
  }

  @override
  String get workspaceWaiting => '等待匯入文件';

  @override
  String get workspaceAnalyzing => '分析進行中';

  @override
  String get workspaceAnalysisComplete => '分析完成';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '已完成 $done/$total 個模組 · 經過 $seconds 秒 · 執行中：$engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return '分析仍在進行，介面可正常操作。過去 $seconds 秒尚無模組完成；大型文件或本機模型可能需要較長時間。';
  }

  @override
  String get workspaceAnalysisFailed => '分析意外停止，請重試或檢查模型設定。';

  @override
  String get workspaceNewAnalysis => '新的分析';

  @override
  String get workspaceStopAnalysis => '停止分析';

  @override
  String get workspaceStopAnalysisTitle => '停止目前的分析？';

  @override
  String get workspaceStopAnalysisBody => '目前的分析仍在進行。停止後會保留文件文字，但未完成的結果不會儲存。';

  @override
  String get workspaceAnalysisStopped => '分析已停止，文件文字仍保留在工作台。';

  @override
  String get workspaceSelectedEvidence => '選取證據';

  @override
  String get workspaceNoEvidence => '各引擎完成後，句子證據會依序顯示於此。';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return '初步 AI 證據指數：$percent/100';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      '此百分比是「這一句」自己的 AI 訊號強度，不是整份文件的最終判定。數字越高代表這句的用字模式越接近 AI 生成；越低則越接近一般人類寫作習慣。最終報告會依各引擎權重綜合所有句子後得出。';

  @override
  String get workspaceSentenceSignalHeader => '逐句 AI 訊號';

  @override
  String get workspaceSentenceColumnHeader => '句子內容';

  @override
  String get workspaceAiEvidenceIndexShort => '指數';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine 本次沒有找到證據，未參與投票（角色權重 $weight%）。這代表它在自己負責的面向沒有發現 AI 痕跡，不等於它認為本文是人類撰寫。';
  }

  @override
  String reportEngineRelationshipDirectionalOnly(String engine, int weight) {
    return '$engine 本次只有弱方向性訊號，已折扣納入初步篩查，但未達可投票的證據門檻（角色權重上限 $weight%）。';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return '本次只有$engine形成可用方向，其餘引擎沒有方向性訊號。結論僅由單一面向支撐，信心請相應打折。';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return '另有 $count 個引擎有執行但未形成方向性訊號，已排除在外，避免把「沒話說」誤算成「看起來像人寫的」。';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      '本次未採計語言模型困惑度：困惑度模型（DistilGPT2）只在英文語料上訓練，對中日韓文而言它量到的是位元組的可預測性，不是語言的可預測性。以標註語料實測，它在這些語言上區分真人與 AI 的能力為 0%，採計只會製造偽陽性。';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return '各語言基準集：$breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return '另有 $count 份較早的樣本沒有語言標記，無法歸入任何語言的基準集——原文預設不保存，事後無從補算語言。隨著新文件分析會逐步替換。';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return '本次改用「$variant」：你選用的變體未針對 $language 驗證，而這一顆有。';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '「$variant」是多語言模型，但未在 $language 上驗證過，其分數的證據強度應低於已驗證的語言。';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '「$variant」不涵蓋 $language。其分數僅供參考，不應被當成任何方向的證據。';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      '本次未採計語言模型困惑度：無法判定這份文件的語言，因此沒有可比對的校準門檻。猜一個語言就會套錯尺度，而那正是這道檢查要避免的錯誤。';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return '本次未採計語言模型困惑度：目前使用的模型「$model」尚未量測過 $language 的門檻。沒有校準尺度時，原始數值不代表任何意義，因此寧可不採計也不猜。';
  }

  @override
  String get inputNoEditingRecordHint =>
      '這個格式不含編輯紀錄。PDF、圖片與直接貼上的文字都沒有「怎麼寫出來的」歷程，因此分析完全依賴文本統計。若能取得 .docx、.odt 或 .doc 原始檔，其編輯歷程是強得多的證據——而且不像文本統計，它不會隨語言模型進步而失效。';

  @override
  String get reportLowScoreNotProofOfHuman =>
      '低分不等於確認由人撰寫。本次沒有可用的來源證據，判定僅來自文本統計；文本統計能穩定指認罐頭式寫作，但指認不了現代模型寫得好的輸出。';

  @override
  String get reportProvenanceContradictsLowScore =>
      '檔案自身的編輯紀錄與這個低分互相矛盾。來源證據不會隨語言模型進步而失效，而文本統計指認不了現代模型寫得好的輸出。請先看下方的來源證據，再決定要不要採信上面的分數。';

  @override
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  ) {
    return '$total 段中有 $paragraphs 段屬於同一個編輯批次，佔全文 $percent% 的字數——這與「該區塊是一次寫入或貼上的」相符，即使檔案本身另有其他編輯批次。';
  }

  @override
  String findingEvasionDetected(int count) {
    return '發現 $count 處字元層級的規避痕跡（零寬字元、外觀相同的異體字母、或方向控制字元）。正常的寫作工具不會產生這些——有人為了規避偵測而處理過這份文字。';
  }

  @override
  String findingCitationsNotFound(int notFound, int total) {
    return '引用的 $total 篇文獻中，有 $notFound 篇在所有查核的資料庫中都查無此文。捏造引用是語言模型的行為特徵，而且與文風不同，一篇文獻存不存在是可以查證的事實。';
  }

  @override
  String findingCitationsAllVerified(int total) {
    return '引用的 $total 篇文獻全數在公開資料庫中找到。';
  }

  @override
  String findingEditingRecordNormal(int minutes, int revisions) {
    return '檔案記錄了 $minutes 分鐘的編輯時間、$revisions 次存檔，與「這份文字是在本文件中寫成的」相符。';
  }

  @override
  String findingPublicationPredatesGenerativeAi(String doi, int year) {
    return '來源 DOI $doi 與本文件篇名吻合，且於 $year 年完成登記，早於現代生成式 AI 寫作系統。';
  }

  @override
  String findingPublicationIdentityMismatch(String doi) {
    return '來源 DOI $doi 雖可解析，但登記篇名與本文件不符；採信前應先核對文件身分。';
  }

  @override
  String get integratedStabilityUnavailable => '分段穩定性無法計算 · 沒有逐句證據參與投票';

  @override
  String get integratedNeutralBaseline =>
      '本次未找到足以升級處理的作者特異性證據；畫面呈現的是目前最佳方向性篩查，不代表 AI 與真人證據各半。';

  @override
  String get reportVerifiableFindingsTitle => '可查證的事實';

  @override
  String get reportVerifiableFindingsSubtitle =>
      '以下每一項都可以獨立查證。與機率不同，這些不會隨語言模型進步而失效。';

  @override
  String findingBulkPaste(int characters) {
    return '輸入過程中記錄到一次貼上 $characters 個字元。語言模型無法偽造文字如何出現在編輯器裡——這一段不是在這裡打出來的。';
  }

  @override
  String findingWrittenInApp(int minutes, int deleted) {
    return '這份文字在本應用程式內經過 $minutes 分鐘打成，過程中修改了 $deleted 個字元。在這裡發生的寫作會留下語言模型無法重現的紀錄。';
  }

  @override
  String get evidenceMatrixTitle => '多證據鑑識矩陣';

  @override
  String get evidenceMatrixSubtitle =>
      '六個面向分開呈現；只有具作者特異性的證據影響作者判讀，覆蓋率表示本次能檢查哪些證據。';

  @override
  String evidenceMatrixCoverage(int available, int total) {
    return '證據覆蓋：$available/$total 個面向';
  }

  @override
  String get evidenceAxisText => '文本生成痕跡';

  @override
  String get evidenceAxisTextNote => '四個本機偵測引擎提供的機率型文字模式';

  @override
  String get evidenceAxisProcess => '寫作過程';

  @override
  String get evidenceAxisProcessNote => '不記錄內容的打字、修改與貼上事件';

  @override
  String get evidenceAxisOrigin => '文件來源';

  @override
  String get evidenceAxisOriginNote => '編輯時間、存檔次數與 DOCX／ODT／RSID 中繼資料';

  @override
  String get evidenceAxisSources => '主張與來源完整性';

  @override
  String get evidenceAxisSourcesNote => '可查核主張、引用錨點與文獻資料庫核實';

  @override
  String get evidenceStateUnavailable => '無法取得';

  @override
  String get evidenceStateInconclusive => '不足判斷';

  @override
  String get evidenceStateReassuring => '相符';

  @override
  String get evidenceStateConcern => '需檢視';

  @override
  String get evidenceStrengthNone => '沒有證據';

  @override
  String get evidenceStrengthLimited => '有限';

  @override
  String get evidenceStrengthModerate => '中等';

  @override
  String get evidenceStrengthStrong => '強';

  @override
  String get evidenceMatrixTextOnlyWarning =>
      '本次只有文本模式可用。現代 AI 能模仿人類文風，因此不能只靠這個分數確認作者身分。';

  @override
  String get evidenceMatrixStrongConcern =>
      '至少一個獨立面向出現強烈的檢視訊號。採信文本分數前，請先查看該項證據。';

  @override
  String findingUnsupportedClaims(int unsupported, int total) {
    return '$total 個可查核主張中，有 $unsupported 個包含數字、比較或研究歸因，卻未在同一句提供來源錨點。這不代表內容必然錯誤，但指出了最該優先核實的主張。';
  }

  @override
  String get integratedAssessmentTitle => '整合作者判讀';

  @override
  String get integratedInsufficientEvidence => '未取得可量化的作者訊號';

  @override
  String get integratedLikelyAi => '較可能是 AI 生成';

  @override
  String get integratedLikelyMixed => '較可能是人機混合';

  @override
  String get integratedLikelyHuman => '較可能不是 AI 生成';

  @override
  String get integratedBalanced => '未檢出明確 AI 主導訊號';

  @override
  String get integratedPreliminaryAi => '目前偏向 AI，但接近分界';

  @override
  String get integratedPreliminaryHuman => '目前偏向真人，但接近分界';

  @override
  String integratedLikelihoodLabel(int percent) {
    return 'AI 證據指數：$percent/100';
  }

  @override
  String get integratedLikelihoodUnavailable => 'AI 證據指數：無法估算';

  @override
  String integratedTextScoreLabel(int percent) {
    return '文字模型原始分數：$percent%';
  }

  @override
  String integratedConfidenceLabel(String confidence) {
    return '判讀信心：$confidence';
  }

  @override
  String get integratedConfidenceLow => '低';

  @override
  String get integratedConfidenceModerate => '中';

  @override
  String get integratedConfidenceHigh => '高';

  @override
  String integratedEvidenceSufficiency(int percent, String tier) {
    return '證據充分度：$percent/100 · $tier';
  }

  @override
  String get integratedEvidenceTierScreening => '初步篩查';

  @override
  String get integratedEvidenceTierReference => '具參考性';

  @override
  String get integratedEvidenceTierStrong => '支持較充分';

  @override
  String integratedBoundaryAi(int index, int gap) {
    return '指數 $index 只呈現微弱 AI 方向，距 60 分 AI 升級線仍有 $gap 分；目前不足以認定 AI 撰寫。';
  }

  @override
  String integratedBoundaryHuman(int index, int gap) {
    return '指數 $index 目前偏向真人，且距 60 分 AI 升級線仍有 $gap 分；但證據有限，仍不能排除 AI 協作。';
  }

  @override
  String integratedEvidenceCoverage(int families, int coverage) {
    return '方向性訊號家族：$families/4 · 適用性覆蓋 $coverage%';
  }

  @override
  String get integratedEvidenceGatePassed => 'AI 證據門檻：已通過';

  @override
  String get integratedEvidenceGateNotPassed => 'AI 證據門檻：未通過・僅供方向篩查';

  @override
  String integratedQualifiedWarning(String reason) {
    return '$reason 系統仍提供最可能方向，但已降低信心；請把它視為篩查結果，而不是定案證明。';
  }

  @override
  String get integratedIndexCaveat =>
      '獨立的 AI 證據門檻表示是否已有足夠跨來源支持可升級處理。引用品質、貼上行為與異常中繼資料不能單獨產生 AI 判定。本指數是證據分數，不是經母體校準的統計機率。';

  @override
  String get reportTextEngineSignalExplanation =>
      '以下呈現四個文字引擎的診斷訊號。相關引擎會先按家族合併，納入保守折扣後的分類器真人方向，再套用語言／領域適用性與校準可靠度。方向結論回答哪一種解釋較受支持；獨立的 AI 證據門檻則回答支持是否已足以升級處理。';

  @override
  String reportSynthesisTextScoreContext(int percent) {
    return '四引擎文字模型原始分數為 $percent%；它只是整合判讀的一項輸入，不是另一個綜合判定。';
  }

  @override
  String reportSynthesisStrongestTextSignal(String label, int percent) {
    return '最高文字引擎訊號是 $label（$percent%）；它可影響文字模型分數，但不能單獨覆蓋整合判讀。';
  }

  @override
  String composerTextScoreThresholdReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '文字模型原始分數為 $aiPercent%，已達 $thresholdPercent% 診斷標記。這只代表文字訊號；報告的作者方向仍以整合判讀為準。';
  }

  @override
  String composerTextScoreThresholdNotReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '文字模型原始分數為 $aiPercent%，低於 $thresholdPercent% 診斷標記。未達標記不代表人類撰寫；報告的作者方向仍以整合判讀為準。';
  }

  @override
  String telemetryIntegratedVerdict(
    String direction,
    int percent,
    String confidence,
  ) {
    return '依本次可用證據加權後，本文「$direction」（AI 證據指數 $percent/100，$confidence信心）。';
  }

  @override
  String telemetryIntegratedUnavailable(String direction, String confidence) {
    return '本次可用模組未形成可量化的作者方向（「$direction」、$confidence信心），因此不提供數字指數。';
  }

  @override
  String integratedStabilityLabel(int percent, int lower, int upper) {
    return '分段穩定性 $percent% · 區間 $lower–$upper%';
  }

  @override
  String integratedInputQualityLabel(int percent) {
    return '輸入抽取品質：$percent%';
  }

  @override
  String integratedCalibrationLabel(String value, int count) {
    return '同條件本地基準：p=$value · n=$count';
  }

  @override
  String analysisReadinessLabel(String level) {
    return '分析前信心基準：$level';
  }

  @override
  String get analysisReadinessShortText => '需要更多文字';

  @override
  String get analysisReadinessFewSentences => '可分析句段不足';

  @override
  String get analysisReadinessCoreModel => '核心分類模型不可用';

  @override
  String get analysisReadinessFewEngines => '啟用引擎少於兩個';

  @override
  String get analysisReadinessExtraction => '文字抽取品質受限';

  @override
  String get analysisReadinessBaseline => '沒有同條件本地基準';
}
