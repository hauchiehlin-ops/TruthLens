// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get verdictHuman => 'Human-written';

  @override
  String get verdictLikelyHuman => 'Likely human';

  @override
  String get verdictMixed => 'Mixed content';

  @override
  String get verdictLikelyAi => 'Likely AI';

  @override
  String get verdictAi => 'AI-generated';

  @override
  String get inputSubtitle =>
      'Paste or type text to detect AI-generated content';

  @override
  String get inputHint => 'Type or paste the text to analyze…';

  @override
  String get inputHistoryTooltip => 'History';

  @override
  String get inputHelpTooltip => 'User Guide';

  @override
  String get inputPrivacyTooltip => 'Privacy Policy';

  @override
  String get inputSettingsTooltip => 'Settings';

  @override
  String get inputPasteButton => 'Paste';

  @override
  String get inputOcrButton => 'Image OCR';

  @override
  String get inputImportButton => 'Import File';

  @override
  String get inputStartButton => 'Start Detection';

  @override
  String get inputClearTooltip => 'Clear content';

  @override
  String get inputTooShortSnackbar =>
      'Please enter at least 40 characters for reliable analysis';

  @override
  String get inputOcrUnsupported =>
      'OCR text recognition is not supported on this platform';

  @override
  String get inputOcrRecognizing => 'Recognizing…';

  @override
  String get inputOcrNoText => 'No text was recognized in the image';

  @override
  String inputOcrRecognized(int count) {
    return 'Recognized $count characters';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\" has no readable text content';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return 'Imported \"$fileName\" ($count characters)';
  }

  @override
  String inputActiveModel(String modelId) {
    return 'Model: $modelId';
  }

  @override
  String get inputNoModel =>
      'No model installed (statistical/style analysis only)';

  @override
  String inputCharCount(int count) {
    return '$count characters';
  }

  @override
  String get analysisAppBarTitle => 'Analyzing';

  @override
  String get analysisEngineTransformer => 'Transformer classifier';

  @override
  String get analysisEngineStatistical => 'Statistical analysis';

  @override
  String get analysisEngineStylometry => 'Stylometry analysis';

  @override
  String get analysisEngineAdversarial => 'Adversarial defense';

  @override
  String analysisProgressSemantics(int done, int total) {
    return 'Analysis in progress, $done of $total engines completed';
  }

  @override
  String get analysisDoneSemantics => 'Done';

  @override
  String get engineNameAdversarialFull =>
      'Adversarial defense (paraphrase detection)';

  @override
  String get modelNecessityText =>
      'Without a downloaded neural detection model, TruthLens still works, but only using statistical and stylistic analysis with limited accuracy and language coverage. After downloading a model, the multilingual Transformer classifier joins the ensemble vote, significantly improving accuracy and reliability. The model runs on-device; once downloaded, it never uploads any content.';

  @override
  String get modelPromptTitle => 'Download a detection model for full analysis';

  @override
  String get modelPromptDontRemind => 'Don\'t remind me again';

  @override
  String get modelPromptSkip => 'Skip for now';

  @override
  String get modelPromptDownload => 'Go to download';

  @override
  String get onboardingWelcomeTitle => 'Welcome to TruthLens';

  @override
  String get onboardingHeadline => 'On-device AI content detection';

  @override
  String get onboardingDetectedDevice => 'Detected device';

  @override
  String get onboardingChooseModel => 'Choose a model to download';

  @override
  String get onboardingRecommendHint =>
      '\"Recommended\" is marked based on your hardware; you may also pick another option.';

  @override
  String get onboardingSkipButton =>
      'Decide later (use statistical/stylistic analysis without a model)';

  @override
  String get onboardingSkipHint =>
      'You can still download later from \"Settings → AI Model Management\"; you\'ll be reminded again when an analysis needs a model.';

  @override
  String get modelListCustomImportedLabel => 'Custom imported models:';

  @override
  String get modelListActiveChip => 'Active';

  @override
  String get modelListRecommendedChip => 'Recommended';

  @override
  String get modelListCustomChip => 'Custom';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · needs ${ram}GB RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'Size: $size · Tokenizer: $tokenizer · AI Label Index: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'Downloading… $percent% ($downloaded / $total)';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'Download ($size)';
  }

  @override
  String get modelListComingSoonChip => 'Coming soon';

  @override
  String get modelListSetActiveButton => 'Set active';

  @override
  String get modelListUpdateButton => 'Update';

  @override
  String get modelListDeleteTooltip => 'Delete';

  @override
  String get modelListPageButton => 'Model page';

  @override
  String get modelListMayExceedMemory => 'May exceed device memory';

  @override
  String modelListFailedPrefix(String error) {
    return 'Failed: $error';
  }

  @override
  String get modelListDeleteConfirmTitle => 'Delete this model?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return 'This will delete \"$name\" ($size). You\'ll need to download it again to use it.';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'This will delete the custom-imported \"$name\" ($size). You\'ll need to import it again to use it.';
  }

  @override
  String get modelImportAppBarTitle => 'Import Custom ONNX Model';

  @override
  String get modelImportStep1Title => '1. Select an ONNX model file';

  @override
  String modelImportSelectedFile(String name) {
    return 'Selected: $name';
  }

  @override
  String get modelImportNoFileSelected => 'No model file selected (.onnx)';

  @override
  String get modelImportBrowseButton => 'Browse';

  @override
  String get modelImportCheckingDuplicate =>
      'Checking whether this file was already imported…';

  @override
  String get modelImportDuplicateTitle =>
      'An identical model has already been imported';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'This file has exactly the same content as \"$name\" (role: $role). If you just want to switch the active model, go to \"AI Model Management\" and set it active there — no need to re-import. You can still continue the steps below.';
  }

  @override
  String get modelImportStep2Title => '2. Configuration';

  @override
  String get modelImportNameLabel => 'Model display name';

  @override
  String get modelImportNameRequired => 'Name cannot be empty';

  @override
  String get modelImportRoleLabel => 'Target engine role';

  @override
  String get modelImportTokenizerTypeLabel => 'Tokenizer type';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => 'None (no tokenizer / char-level)';

  @override
  String get modelImportNoTokenizerSelected =>
      'No tokenizer file selected (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return 'Selected: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'AI label output index';

  @override
  String get modelImportIndex0 => 'Index 0 (e.g. RoBERTa)';

  @override
  String get modelImportIndex1 => 'Index 1 (e.g. DistilBERT)';

  @override
  String get modelImportStep3Title => '3. Test & verify';

  @override
  String get modelImportTestInputLabel => 'Test input text';

  @override
  String get modelImportRunTestButton => 'Run test inference';

  @override
  String get modelImportResultLabel => 'Inference result (AI probability):';

  @override
  String modelImportTestFailed(String error) {
    return 'Test failed: $error';
  }

  @override
  String get modelImportConfirmButton => 'Confirm import and activate model';

  @override
  String get modelImportSelectTokenizerFirst =>
      'Please select a tokenizer file first';

  @override
  String get modelImportSelectTokenizer => 'Please select a tokenizer file';

  @override
  String get modelImportSuccessSnackbar =>
      'Model imported successfully and set as active!';

  @override
  String get modelImportFailedSnackbar =>
      'Model import failed. Please check permissions or logs';

  @override
  String get settingsAppBarTitle => 'Settings';

  @override
  String get settingsThresholdTitle => 'AI detection confidence threshold';

  @override
  String settingsThresholdSubtitle(int percent) {
    return 'Current: $percent% — raising it lowers false positives (human text misjudged as AI)';
  }

  @override
  String get settingsEslTitle => 'ESL non-native writer bias correction';

  @override
  String get settingsEslSubtitle =>
      'Automatically lowers the statistical model\'s weight when non-native writing style is detected';

  @override
  String get settingsEngineSectionTitle => 'Sub-detection engines (Ensemble)';

  @override
  String get settingsEngineTransformerTitle =>
      'Multilingual AI classifier (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Uses a Transformer neural network model for on-device AI probability prediction';

  @override
  String get settingsEngineStatisticalTitle => 'Statistical analysis engine';

  @override
  String get settingsEngineStatisticalSubtitle =>
      'Determines language regularity via sentence-length variance, burstiness, and perplexity';

  @override
  String get settingsEngineStylometryTitle => 'Stylometry analysis';

  @override
  String get settingsEngineStylometrySubtitle =>
      'Analyzes semantic fluency, repeated sentence patterns, and transition-word usage';

  @override
  String get settingsEngineAdversarialTitle =>
      'Adversarial paraphrase detection';

  @override
  String get settingsEngineAdversarialSubtitle =>
      'Detects whether text has been machine-paraphrased or AI-trace-scrubbed';

  @override
  String get settingsLinkVerificationTitle =>
      'Hyperlink & bibliography verification';

  @override
  String get settingsLinkVerificationSubtitle =>
      'The report will connect to check whether URLs and bibliography entries detected in a document actually exist (AI-generated content often includes plausible-looking but fabricated citations). DOI-style academic links, and \"author-year\" references without any link, are both checked against Crossref\'s public registry. Core AI detection still runs entirely on-device and never sends document content; connectivity is used only for this verification and for model update checks, and can be turned off here.';

  @override
  String get settingsThemeTitle => 'Appearance';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSubtitle => 'Choose the app display language';

  @override
  String get settingsModelManagementTitle => 'AI Model Management';

  @override
  String get settingsModelManagementSubtitle =>
      'Download detection models and the report-writing LLM to enable full inference';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'A model update was detected — check it out';

  @override
  String get settingsOpenButton => 'Open';

  @override
  String get settingsCustomImportTitle => 'Custom ONNX model import & test';

  @override
  String get settingsCustomImportSubtitle =>
      'Import a local custom ONNX model and tokenizer configuration, and run a test inference';

  @override
  String get settingsLanguagePackTitle => 'Language packs';

  @override
  String get settingsLanguagePackSubtitle =>
      'Additional fine-tuned language models (available in phase 4)';

  @override
  String get settingsModelManagerAppBarTitle => 'AI Model Management';

  @override
  String get settingsImportTooltip => 'Import a local ONNX model';

  @override
  String settingsDeviceLabel(String summary) {
    return 'Device: $summary';
  }

  @override
  String get historyAppBarTitle => 'History';

  @override
  String get historyClearAllTooltip => 'Clear all';

  @override
  String get historySearchHint => 'Search history…';

  @override
  String get historyDeletedSnackbar => 'Entry deleted';

  @override
  String get historyClearAllTitle => 'Clear all history?';

  @override
  String historyClearAllBody(int count) {
    return 'This will delete all $count entries. This cannot be undone.';
  }

  @override
  String get historyClearButton => 'Clear';

  @override
  String get historyDeleteEntryTitle => 'Delete this entry?';

  @override
  String get historyReanalyzeTooltip => 'Re-analyze';

  @override
  String get historyEmptyDefault => 'No analysis history yet';

  @override
  String historyEmptySearch(String query) {
    return 'No entries match \"$query\"';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, AI probability $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => 'Detection Report';

  @override
  String get reportExportTooltip => 'Export report';

  @override
  String get reportHomeTooltip => 'Back to home';

  @override
  String get reportGeneratingTitle => 'Generating report…';

  @override
  String get reportSourceLlm => 'AI-generated report';

  @override
  String get reportSourceTemplate => 'Template-generated report';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '$total sentences · $ai likely AI · $human likely human · ${seconds}s elapsed';
  }

  @override
  String get reportExportPdf => 'Export PDF report';

  @override
  String get reportExportCsv => 'Export CSV data';

  @override
  String get reportExportJson => 'Export JSON (system integration)';

  @override
  String get reportExportPng => 'Export summary card (PNG)';

  @override
  String reportExported(String path) {
    return 'Exported: $path';
  }

  @override
  String reportExportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get reportEngineBreakdownTitle => 'Engine breakdown';

  @override
  String get reportEngineNotInstalled => 'Not installed';

  @override
  String get reportSentenceAnalysisTitle => 'Sentence-level analysis';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text. AI probability $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'Hyperlink authenticity';

  @override
  String get reportLinkNoneDetected =>
      'No hyperlinks were detected in this document.';

  @override
  String get reportLinkCheckingProgress => 'Verifying links…';

  @override
  String reportLinkDetectedPending(int count) {
    return 'Detected $count hyperlink(s); not yet verified';
  }

  @override
  String get reportLinkDisabledHint =>
      'AI-generated content often includes plausible-looking but fabricated citation links. You\'ve turned off hyperlink verification in Settings; you can turn it back on for automatic verification, or tap below for a one-time check.';

  @override
  String get reportVerifyNowButton => 'Verify now (requires network)';

  @override
  String get reportLinkReachable => 'Reachable — the URL exists';

  @override
  String get reportLinkNotFound =>
      'URL does not exist (404) — possibly a fabricated citation';

  @override
  String get reportLinkUnreachable =>
      'Could not verify (timed out or no server response)';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'Verified in journal registry: registered with $journal$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      'No matching DOI registration found — possibly a fabricated citation';

  @override
  String get reportLinkCitationUnreachable =>
      'Could not verify (timed out or no response from Crossref)';

  @override
  String reportLinkTruncated(int max, int count) {
    return 'Only the first $max links were verified (detected $count total)';
  }

  @override
  String get reportBibAuthenticityTitle => 'Citation authenticity';

  @override
  String get reportBibNoneDetected =>
      'No bibliography entries were detected in this document.';

  @override
  String get reportBibCheckingProgress => 'Verifying bibliography…';

  @override
  String reportBibDetectedPending(int count) {
    return 'Detected a bibliography ($count entries); not yet verified';
  }

  @override
  String get reportBibDisabledHint =>
      'AI-generated content often includes plausible-looking but fabricated references. You\'ve turned off hyperlink verification in Settings; you can turn it back on for automatic verification, or tap below for a one-time check.';

  @override
  String get reportVerifyNowBibButton => 'Verify now (requires network)';

  @override
  String get reportBibResultHint =>
      'Matched against Crossref\'s public registry by author, year, and title similarity. Not an absolute guarantee — when \"uncertain\", please double-check manually.';

  @override
  String reportBibHighConfidence(String journal) {
    return 'High confidence: likely exists$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (registered with $journal)';
  }

  @override
  String get reportBibNotFound =>
      'No close match found — possibly a fabricated reference';

  @override
  String get reportBibUncertain =>
      'Moderate similarity or connection failed — uncertain, please verify manually';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Only the first $max entries were verified (detected $count total)';
  }

  @override
  String get reportNetworkWarningTitle => 'Poor network connection';

  @override
  String get reportNetworkWarningBody =>
      'This app assumes network connectivity is available by default; hyperlink and citation authenticity analysis both require network access to produce a result. A connection could not be established — please check your network and try again.';

  @override
  String get reportRetryConnectionButton => 'Recheck connection';

  @override
  String get reportAiProbabilityLabel => 'AI probability';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '$total sentences\n$ai likely AI\n$human likely human';
  }

  @override
  String get summaryCardFooter => 'Core AI inference runs entirely on-device';

  @override
  String get exportReportTitle => 'TruthLens Detection Report';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · Page $page / $total';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return 'Analyzed: $datetime · ${seconds}s elapsed';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return 'Overall verdict: $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => ' (ESL correction applied)';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '$total sentences · $ai likely AI · $human likely human';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'To keep the PDF readable, only the first $max sentences are shown (of $count total); for the complete per-sentence data, use \"$csvLabel\" or \"$jsonLabel\" instead.';
  }

  @override
  String get pdfSentenceColumnHeader => 'Sentence (with matched patterns)';

  @override
  String composerHeadlineAi(int percent) {
    return 'This text is very likely AI-generated (AI probability $percent%)';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'This text leans AI-generated; further review is recommended (AI probability $percent%)';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'This text shows a mix of human and AI characteristics (AI probability $percent%)';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'This text leans human-written (AI probability $percent%)';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'This text is very likely human-written (AI probability $percent%)';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return 'The overall AI probability exceeds your $percent% threshold and is flagged as AI.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'The overall AI probability is below your $percent% flagging threshold.';
  }

  @override
  String get composerNarrativeTitle => 'Analysis interpretation';

  @override
  String get composerParaphraseTitle => 'Paraphrase traces detected';

  @override
  String get composerParaphraseBody =>
      'This text may have been processed by a paraphrasing tool (e.g. QuillBot, Undetectable.ai) to evade detection. Even if it reads naturally sentence-by-sentence, its overall statistical fingerprint still differs from genuine human writing — please pay extra attention.';

  @override
  String get composerPatternListTitle => 'Main AI writing patterns';

  @override
  String get composerEslTitle => 'ESL non-native writer bias correction';

  @override
  String get composerEslBody =>
      'This text may be from a non-native writer. Low perplexity and regular sentence patterns common among non-native writers are not themselves signs of AI, so the system has lowered the statistical model\'s weight to avoid misjudging it.';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return 'This text has $total sentences in total, of which $ai show strong AI characteristics and $human lean human-written.';
  }

  @override
  String get composerNarrativeAiPattern =>
      'Most sentences are highly regular in rhythm, word choice, and transition-word usage — a common fingerprint of AI-generated text.';

  @override
  String get composerNarrativeMixedPattern =>
      'The text contains both regularized and naturally-varying passages, suggesting a human draft polished by AI, or human-AI collaboration.';

  @override
  String get composerNarrativeHumanPattern =>
      'Sentence length and word choice show natural variation and personal style, with no clear signs of AI regularity.';

  @override
  String engineReasonPplLow(String ppl) {
    return 'Low language-model perplexity ($ppl) — the text is highly predictable, an indicator of AI generation';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'High language-model perplexity ($ppl), consistent with the unpredictability of human writing';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'Moderate language-model perplexity ($ppl)';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'Highly uniform sentence length (burstiness $value) — even rhythm is a typical statistical signature of AI-generated text';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'Noticeable variation in sentence length (burstiness $value), consistent with the natural rhythm of human writing';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'Low vocabulary diversity (TTR $value) — high word repetition';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'High vocabulary diversity (TTR $value)';
  }

  @override
  String get engineReasonNeutral =>
      'Statistical indicators show no significant tendency — neutral verdict';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return 'Frequent use of generic transition words ($words), averaging $density per sentence — rarely this dense in human writing';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return 'Multiple adjacent sentences start with the same word ($count instances) — repetitive sentence structure';
  }

  @override
  String get engineReasonNoStyleMarkers =>
      'No significant AI writing style patterns detected';

  @override
  String get engineReasonAdversarialNotInstalled =>
      'The paraphrase-detection model is not installed; it did not take part in this vote';

  @override
  String get engineReasonTransformerNotInstalled =>
      'No model is installed or the active model is unsupported; it did not take part in this vote';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'The model failed to load and did not take part in this vote ($error)';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model judged $aiCount of $total sentences to show AI characteristics';
  }

  @override
  String get engineReasonAdversarialDetected =>
      'The adversarial model detected likely AI traces scrubbed by a paraphrasing tool (e.g. QuillBot / Undetectable.ai)';

  @override
  String get engineReasonAdversarialClean =>
      'No clear paraphrase-evasion traces detected';

  @override
  String get engineReasonDisabledByUser =>
      'The user disabled this engine in Settings';

  @override
  String get engineReasonGenericNotInstalled =>
      'Model not installed; it did not take part in this vote';

  @override
  String patternGenericTransition(String word) {
    return 'generic transition word \"$word\"';
  }

  @override
  String get helpAppBarTitle => 'User Guide';

  @override
  String get helpAboutTitle => 'About TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens is a cross-platform content detection app (iOS / Android / macOS / Windows) whose core AI inference runs entirely on-device. Four independent sub-models — a Transformer neural classifier, statistical analysis, stylometric analysis, and adversarial paraphrase detection — vote together to judge whether text is AI-generated, with sentence-by-sentence, explainable reasoning: not just a \"looks like AI\" percentage, but an explanation of \"why\".';

  @override
  String get helpComparisonTitle => 'Comparison with leading tools';

  @override
  String get helpComparisonDisclaimer =>
      'This comparison is compiled from each tool\'s public information and general market perception, for positioning reference only — not third-party-certified benchmark data.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero\'s processing runs mainly in the cloud and requires uploading your document; all four of TruthLens\'s detection engines run on-device.';

  @override
  String get helpVsGptZero2 =>
      'GPTZero pioneered Perplexity/Burstiness metrics and sentence highlighting — TruthLens incorporates these and layers on a Transformer classifier, stylometric analysis, and adversarial defense, forming a four-model ensemble vote rather than a single metric.';

  @override
  String get helpVsGptZero3 =>
      'GPTZero is subscription-based; TruthLens requires no subscription and has no usage limits.';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin is sold only to institutions; individuals cannot purchase it directly. Anyone can install and use TruthLens.';

  @override
  String get helpVsTurnitin2 =>
      'Turnitin\'s decision process is close to a black box; TruthLens provides per-sentence AI probability, matched writing patterns, and a breakdown of each engine\'s score and reasoning.';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin mainly gives a binary \"is it AI\" call; TruthLens supports paragraph/sentence-level human/AI/mixed labeling.';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai is a per-document subscription that requires uploading your document to the cloud; TruthLens\'s core processing runs on-device with no ongoing subscription needed for detection.';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai offers fact-checking and readability analysis concepts; TruthLens echoes this with an on-device stylistic-feature module, and can do basic analysis offline too.';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks is mainly a cloud API known for low false-positive rates and strong multilingual support; TruthLens adopts the same philosophy with an XLM-RoBERTa multilingual base model and multi-model ensemble voting, but your document content is never uploaded to any server.';

  @override
  String get helpVsCopyleaks2 =>
      'Copyleaks has API usage limits depending on plan; TruthLens has no usage limits.';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'Winston AI\'s OCR image recognition requires uploading images to the cloud; TruthLens uses each platform\'s native framework (Vision on iOS/macOS, ML Kit on Android, Windows.Media.Ocr on Windows) to recognize text on-device.';

  @override
  String get helpVsWinston2 =>
      'Winston AI is known for polished, printable reports; TruthLens generates a dynamic AI-written report layout (falling back to a template if no LLM is installed), exportable as PDF/CSV/JSON/PNG.';

  @override
  String get helpAdvantagesTitle => 'TruthLens-only advantages';

  @override
  String get helpAdvantage1 =>
      'Hyperlink authenticity verification: automatically checks whether URLs found in a document are actually reachable; DOI-style academic links are further checked against Crossref\'s public registry to confirm the journal actually indexes that work.';

  @override
  String get helpAdvantage2 =>
      'Citation authenticity verification: even references with no hyperlink at all (plain \"author-year\" style) can be checked against a bibliographic registry to catch likely-fabricated citations — a common tell of AI hallucination.';

  @override
  String get helpAdvantage3 =>
      'ESL (non-native writer) bias correction: automatically detects non-native writing characteristics and lowers the statistical model\'s weight, avoiding misjudging natural non-native writing as AI.';

  @override
  String get helpAdvantage4 =>
      'Custom model import: advanced users can import their own local ONNX model to replace or supplement the built-in detection engines.';

  @override
  String get helpWorkflowTitle => 'Full operating workflow';

  @override
  String get helpWorkflowStep1Title => 'Model download & update';

  @override
  String get helpWorkflowStep1Body =>
      'First launch guides you through installing the core detection model; afterward you can always check, download, update, or remove models from \"Settings → AI Model Management\". The app proactively checks for the latest version on launch, and shows a badge on the settings icon and the \"AI Model Management\" entry if an update is available.';

  @override
  String get helpWorkflowStep2Title => 'Choosing a model (purpose & effect)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Multilingual AI classifier (40% weight): the main driver of the overall verdict, with sentence-level AI probability prediction — improves accuracy the most.';

  @override
  String get helpWorkflowStep2Bullet2 =>
      'Statistical analysis engine (25% weight): sliding-window perplexity and burstiness analysis, capturing the regular rhythm and predictable wording of AI text.';

  @override
  String get helpWorkflowStep2Bullet3 =>
      'Stylometric analysis (20% weight): semantic fluency, repeated sentence patterns, transition-word usage — the most explainable, easiest to understand \"why\".';

  @override
  String get helpWorkflowStep2Bullet4 =>
      'Adversarial defense (15% weight): detects text that has been washed through a paraphrasing tool (e.g. QuillBot, Undetectable.ai).';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'Report-writing LLM (optional): once installed, report text is dynamically written by an on-device LLM; without it, the app falls back to a fixed template — analysis itself is unaffected.';

  @override
  String get helpWorkflowStep2Bullet6 =>
      'You can individually enable/disable engines and adjust the AI-detection confidence threshold in Settings (raising it lowers the chance of misjudging human writing as AI).';

  @override
  String get helpWorkflowStep3Title => 'Uploading a document';

  @override
  String get helpWorkflowStep3Body =>
      'Three input methods: paste text directly, image OCR (recognized on-device with each platform\'s native framework), or import a file (txt / md / pdf / docx / doc). Text must be at least 40 characters long to submit for analysis.';

  @override
  String get helpWorkflowStep4Title => 'Running analysis';

  @override
  String get helpWorkflowStep4Body =>
      'Tap \"Start Detection\" and all four engines run in parallel, with live progress shown on screen. If non-native writing characteristics are detected, ESL bias correction is applied automatically (can be turned off in Settings).';

  @override
  String get helpWorkflowStep5Title => 'Viewing & exporting results';

  @override
  String get helpWorkflowStep5Body =>
      'The report page includes: an overall AI-probability gauge, a sentence-level heatmap, a breakdown of each engine\'s score and reasoning, hyperlink authenticity, and citation authenticity. You can export a full PDF report, per-sentence CSV data, JSON (for system integration), or a PNG summary card (for sharing). Every analysis is automatically saved to \"History\" for later review.';

  @override
  String get helpTuningTitle =>
      'Model download & tuning walkthrough (no experience needed)';

  @override
  String get helpTuningStep1Title => 'Open Model Management';

  @override
  String get helpTuningStep1Body =>
      'From the home screen, tap the gear icon to open \"Settings\", then tap \"Open\" next to \"AI Model Management\".';

  @override
  String get helpTuningStep2Title => 'Pick a model for your device';

  @override
  String get helpTuningStep2Body =>
      'The screen automatically suggests a suitable model tier based on your device\'s capability (RAM, CPU cores), and lists every available variant for each role (multilingual classifier / statistical analysis / adversarial defense / report LLM).';

  @override
  String get helpTuningStep3Title => 'Download & apply';

  @override
  String get helpTuningStep3Body =>
      'Tap \"Download\" next to the model you want and wait for it to finish — the first model you download is automatically set active. If you have multiple variants installed, tap \"Set active\" to switch anytime; tap the trash icon to remove a model you no longer need to free up space.';

  @override
  String get helpTuningStep4Title => 'Updating a model';

  @override
  String get helpTuningStep4Body =>
      'When a new version becomes available, \"AI Model Management\" and the settings gear icon show a badge — come back to this screen to see and download the update (the previously installed version is kept unless you remove it manually).';

  @override
  String get helpTuningStep5Title => 'Advanced: importing a custom model';

  @override
  String get helpTuningStep5Body =>
      'If you already have, or have fine-tuned, a compatible .onnx model elsewhere, you can import it via \"Settings → Custom ONNX model import & test\" — you\'ll need to provide the model file, its matching tokenizer configuration (or choose \"none\"), and the AI class index. Before importing, the app automatically checks whether this exact file was already imported, to avoid accidental duplicates.';

  @override
  String get helpOfficialLinksTitle => 'Official model download links';

  @override
  String get helpOfficialLinksHint =>
      'Tapping an item opens that model\'s official page in your system browser.';

  @override
  String get helpLinkRoleTransformer =>
      'Multilingual AI classifier (Transformer, 40% weight)';

  @override
  String get helpLinkRoleStatistical =>
      'Perplexity statistical model (Statistical, 25% weight)';

  @override
  String get helpLinkRoleAdversarial =>
      'Adversarial paraphrase-detection model (Adversarial, 15% weight)';

  @override
  String get helpLinkRoleLlm => 'Report-writing LLM (optional)';

  @override
  String get privacyAppBarTitle => 'Privacy Policy';

  @override
  String privacyPlatformTitle(String platform) {
    return '$platform Privacy Policy';
  }

  @override
  String privacyLastUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get privacyIosOverview1 =>
      'TruthLens does not collect any data linked to your identity, and does not use any data for tracking, so it does not require App Tracking Transparency (ATT) permission.';

  @override
  String get privacyIosOverview2 =>
      'This app uses the system file picker to access files or images you actively choose; it cannot access files you haven\'t selected (enforced by the iOS App Sandbox).';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLens does not collect personal data and does not share user data with any third party.';

  @override
  String get privacyAndroidOverview2 =>
      'This app only accesses storage when you actively choose to import a file or image; it does not scan or access other files in the background.';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens runs under macOS App Sandbox and can only access files you actively selected via the system file dialog (files.user-selected.read-write) — it cannot browse or access any other files or folders on its own.';

  @override
  String get privacyMacosOverview2 =>
      'Network access (network.client) is used only for the necessary connections listed below.';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens is a standalone desktop app; data is stored in your local user folder (e.g. AppData/Documents) and is never synced to the cloud.';

  @override
  String get privacyWindowsOverview2 =>
      'This app only accesses files you actively choose to import; it does not scan other files in the background.';

  @override
  String get privacyDataHandling1 =>
      'TruthLens has no user accounts, requires no sign-in, and contains no advertising or third-party tracking SDKs of any kind.';

  @override
  String get privacyDataHandling2 =>
      'Any document content you type, paste, or import is analyzed entirely by on-device AI models on your own device — it is never uploaded to TruthLens or any third-party server.';

  @override
  String get privacyDataHandling3 =>
      'Analysis results and history are stored only in a local database on your device; uninstalling the app or clearing history removes them completely — TruthLens keeps no copy anywhere.';

  @override
  String get privacyNetworkIntro =>
      'This app\'s core AI detection runs entirely on-device, but the following three features require network access:';

  @override
  String get privacyNetwork1 =>
      '1. Model catalog & download: connects to GitHub Releases / Hugging Face to download the detection model you chose — this only downloads the model and never uploads any user data.';

  @override
  String get privacyNetwork2 =>
      '2. Model update check: on launch, the app connects to compare version numbers only, used to indicate whether a new version is available.';

  @override
  String get privacyNetwork3 =>
      '3. Hyperlink & citation authenticity verification: on by default, can be turned off in Settings. When enabled, URLs or bibliography text detected in a document are sent directly to that URL itself, or to the Crossref public API, sending only the URL/DOI/citation text itself — never the rest of the document\'s content.';

  @override
  String get privacyRightsIntro =>
      'You can clear local analysis history anytime in \"History\", or turn off hyperlink/citation verification in \"Settings\", or remove all local data by';

  @override
  String get privacyRemoveIos => 'deleting the app';

  @override
  String get privacyRemoveAndroid => 'uninstalling the app';

  @override
  String get privacyRemoveMacos => 'moving the app to the Trash';

  @override
  String get privacyRemoveWindows => 'uninstalling the app';

  @override
  String get privacyDisclaimer =>
      'This page is a privacy explanation TruthLens wrote to reflect its actual functional behavior, not a lawyer-reviewed formal legal document; for a formal compliance review under the laws of your region, please consult independent legal counsel.';

  @override
  String get privacySectionOverviewIos =>
      'Overview (maps to the App Store Privacy \"Nutrition Label\")';

  @override
  String get privacySectionOverviewAndroid =>
      'Overview (maps to Google Play\'s \"Data Safety\" disclosure)';

  @override
  String get privacySectionOverviewMacos =>
      'Overview (App Sandbox permissions)';

  @override
  String get privacySectionOverviewWindows => 'Overview';

  @override
  String get privacySectionDataHandling => 'How we handle your data';

  @override
  String get privacySectionNetwork => 'Necessary network connections';

  @override
  String get privacySectionRights => 'Your rights';

  @override
  String get privacyGenericPlatformName => 'This platform';
}
