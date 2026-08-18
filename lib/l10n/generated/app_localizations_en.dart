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
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

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
  String inputPdfOcrProgress(int page, int total) {
    return 'PDF text layer is unavailable; recognizing page $page of $total with OCR…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return 'Imported \"$fileName\" with PDF OCR ($count characters)';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '\"$fileName\" has no reliable text layer. Configure Web OCR or use an installed app with native OCR, then import it again.';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '\"$fileName\" needs OCR but exceeds the $max page safety limit. Split the PDF and import each part.';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return '\"$fileName\" could not be read reliably. It may be damaged, password-protected, or unsupported by the configured OCR service.';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '\"$fileName\" is a legacy .doc file and its text could not be extracted reliably. In Word, save it as .docx or export it to PDF, then import again.';
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
  String analysisPreliminaryResult(int percent) {
    return 'Preliminary result: AI probability $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return 'Preliminary result: AI probability $percent% (refining…)';
  }

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
  String get modelCatalogLoadFailed => 'Could not load model catalog';

  @override
  String get modelCatalogEmpty => 'No models available';

  @override
  String modelDownloadPathChip(String label) {
    return '$label download path';
  }

  @override
  String get modelDownloadPathModelFile => 'Model file';

  @override
  String get modelDownloadPathCopied => 'Download path copied';

  @override
  String settingsSaveFailed(String error) {
    return 'Failed to save settings: $error';
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
  String get settingsEngineWeightsTitle => 'AI model weights';

  @override
  String get settingsEngineWeightsSubtitle =>
      'Set how strongly each engine affects the combined result. The total must equal 100% before saving.';

  @override
  String get settingsEngineInfoTooltip => 'What this engine does';

  @override
  String get settingsEngineTransformerHelp =>
      'Evaluates context-preserving paragraph blocks with a multilingual Transformer model, then maps block scores back to sentences for detailed reporting. Its configured weight controls influence, while its AI signal controls the actual contribution.';

  @override
  String get settingsEngineStatisticalHelp =>
      'Measures perplexity, predictability, burstiness, and sentence-length variation. Regular text can raise this signal, so ESL correction may reduce its effective weight.';

  @override
  String get settingsEngineStylometryHelp =>
      'Checks explainable writing-style markers such as repeated openings, formulaic transitions, and excessive list structure. No matched markers now produce a 0% signal.';

  @override
  String get settingsEngineAdversarialHelp =>
      'Looks for AI text that may have been paraphrased or processed to hide AI traces. A low score means only weak residual evidence, not a positive detection.';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return 'Total: $total% — ready to save';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return 'Total: $total% — adjust to exactly 100%';
  }

  @override
  String get settingsEngineWeightsSave => 'Save weights';

  @override
  String get settingsEngineWeightsSaved =>
      'AI model weights saved on this device';

  @override
  String get settingsEngineWeightsRestoreDefaults => 'Restore defaults';

  @override
  String get engineReasonDisabledByUser =>
      'The user disabled this engine in Settings';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model: none of $total sentences crossed the strong-AI threshold; the calibrated weak signal is $percent%';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'AI signal $percent%';
  }

  @override
  String get reportEngineSignalExplanation =>
      'AI signal is the engine\'s probability for this document; configured weight controls its influence, and contribution points are allocated so their displayed sum exactly matches the overall AI probability. ‘Not detected’ means below the 60% strong-signal threshold, not necessarily mathematically zero.';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return 'None of $total sentences crossed the strong paraphrase threshold; the calibrated weak signal is $percent%';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$count of $total sentences crossed the strong paraphrase threshold; the calibrated document signal is $percent%';
  }

  @override
  String get settingsLinkVerificationTitle =>
      'Hyperlink & bibliography verification';

  @override
  String get settingsLinkVerificationSubtitle =>
      'The report checks detected URLs and bibliography entries against Crossref, OpenAlex, DataCite, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and recognizable publisher catalogs. Only the URL, DOI, or individual citation fields (author, title, year, and venue) are queried; the rest of the document is not sent. Core AI detection remains on-device, and this verification can be turned off here.';

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
  String get modelImportWebUnsupported =>
      'Custom model import is not supported on the web version yet. Please use the app version.';

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
  String get reportEngineWeightLabel => 'Weight';

  @override
  String get privacySealNoticeText =>
      'TruthLens Zero-Cloud Privacy Audit Seal: Processed 100% on-device without cloud upload or database persistence.';

  @override
  String get reportModelCalibrationTitle => 'Model Benchmark Auto-Calibration';

  @override
  String get reportCommunityDiscoveredTag => 'Community (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => 'Engine breakdown';

  @override
  String get reportEngineNotInstalled => 'Not installed';

  @override
  String get reportEngineLoadFailedBadge => 'Load failed';

  @override
  String get reportEngineAnalysisLevelTitle => 'Engine analysis layers';

  @override
  String get reportVerdictAiLikelihood => 'AI Leaning';

  @override
  String get reportVerdictHumanLikelihood => 'Human Writing';

  @override
  String get reportRadarRoleTransformer => 'Transformer classifier';

  @override
  String get reportRadarRoleStatistical => 'Statistical analysis';

  @override
  String get reportRadarRoleStylometry => 'Stylometry analysis';

  @override
  String get reportRadarRoleAdversarial => 'Adversarial defense';

  @override
  String get reportRadarAxisTransformer => 'Sentence classifier';

  @override
  String get reportRadarAxisStatistical => 'Language regularity';

  @override
  String get reportRadarAxisStylometry => 'Writing style';

  @override
  String get reportRadarAxisAdversarial => 'Rewrite defense';

  @override
  String get reportVerdictBadgeTitle => 'Overall verdict';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return 'Overall AI probability $percent%';
  }

  @override
  String get reportVerdictHintHuman =>
      'Most engine signals lean toward natural human writing.';

  @override
  String get reportVerdictHintLikelyHuman =>
      'Overall leans human, with a small amount of model uncertainty retained.';

  @override
  String get reportVerdictHintMixed =>
      'Engine signals are mixed; read the detailed analysis together with this result.';

  @override
  String get reportVerdictHintLikelyAi =>
      'Multiple indicators lean AI; review the high-scoring passages.';

  @override
  String get reportVerdictHintAi =>
      'Overall signals strongly lean AI-generated or rewritten.';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return 'Overall verdict: $verdict; overall AI probability $percent%.';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return 'Strongest single signal: $label ($percent%), but the final result merges engine weights and is not the conclusion of one engine alone.';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return 'Largest weighted contribution currently comes from $label (about $points percentage points).';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '“No obvious AI writing style detected” only means the style engine did not find fixed sentence patterns or transition-word patterns; other models may still raise the overall score through language regularity, sentence classification, or rewrite signals.';

  @override
  String get reportSynthesisModelGap =>
      'When some engines did not participate, use “Complete recommended analysis models” in Model Management first; if it still fails, the detailed analysis will state whether the cause is a missing model, unsupported tokenizer, missing file, or Web/ONNX Runtime compatibility limit.';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label did not participate in this weighted vote, so this dimension is shown as 0%. $hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return 'Role weight $weight%, contributing about $points percentage points to the overall score$variantText.';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return ' (merged $count model variants)';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label did not participate in this vote.';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label returned no additional text explanation.';
  }

  @override
  String get reportEngineResolutionTransformer =>
      'Fix: download and enable the multilingual Transformer in Model Management; if it is already downloaded, re-download the model and tokenizer.';

  @override
  String get reportEngineResolutionAdversarial =>
      'Fix: re-download the rewrite detection model and tokenizer in Model Management; on web, update to a version with the BigInt compatibility fix and analyze again.';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason. Cause: the web ONNX Runtime returned a BigInt tensor that the older bridge could not convert; update to the fixed build and analyze again.';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason. Fix: switch to a catalog model, or re-download the model and tokenizer.';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason. Fix: open Model Management, tap “Complete recommended analysis models”, and confirm the multilingual Transformer is marked active.';
  }

  @override
  String get reportDetailAnalysisTitle => 'Detailed analysis';

  @override
  String get reportNoEngineData => 'No engine analysis data yet';

  @override
  String get reportEngineNotParticipated => 'Not involved';

  @override
  String get reportAiContentReportTitle => 'AI Content Detection Report';

  @override
  String reportAnalysisTimeLabel(String time) {
    return 'Analysis time: $time';
  }

  @override
  String get reportDownloadPdfButton => 'Download PDF';

  @override
  String get reportSuspiciousLocationsTitle => 'Suspicious content locations';

  @override
  String reportSentenceCount(int count) {
    return '$count sentences';
  }

  @override
  String get reportAiProbabilityPrefix => 'AI probability: ';

  @override
  String get helpAdvantage5 =>
      'Document origin forensics: reads the editing record inside .docx / .odt / .doc files — time spent editing, number of saves, how widely the editing batches are spread. That evidence is independent of the text verdict and is shown separately from the AI probability. PDFs and images carry no editing history of their own, so they cannot supply it.';

  @override
  String get helpAdvantage6 =>
      'It abstains honestly when the evidence is thin: fewer than 5 analysable sentences, fewer than 100 words, fewer than 2 engines taking part, or engines more than 60 percentage points apart all produce \\u201cnot enough evidence to judge\\u201d. Most false accusations start with a confident number handed back on an input too weak to support one.';

  @override
  String get settingsAiSampleTitle => 'Add a known-AI sample';

  @override
  String get settingsAiSampleSubtitle =>
      'Background calibration only gathers human samples on its own. To enable learned engine weights you also need pieces known to be AI-generated — paste or import one and it will be analysed and labelled as an AI sample straight away.';

  @override
  String get settingsAiSampleFromClipboard => 'Paste from clipboard';

  @override
  String get settingsAiSampleFromFile => 'Import a document';

  @override
  String get settingsAiSampleAnalyzing => 'Analysing…';

  @override
  String settingsAiSampleAdded(int count) {
    return 'AI sample added — $count in total';
  }

  @override
  String get settingsAiSampleTooShort =>
      'Too short to use as a sample (at least 100 words needed)';

  @override
  String get settingsAiSampleFailed => 'No usable content was found';

  @override
  String get helpFormatCoverageTitle => '2a. Format limits on origin evidence';

  @override
  String get helpFormatCoverage =>
      '**An important limit: only .docx, .odt and legacy .doc carry an editing record.**\n\n| Source | Editing record |\n|---|---|\n| .docx / .odt | ✅ yes |\n| .pdf | ❌ the format holds no editing history at all |\n| .doc (legacy) | ✅ yes (OLE2 SummaryInformation) |\n| .txt / .md | ❌ no container |\n| Image OCR | ❌ only pixels remain |\n| Pasted text | ❌ no file at all |\n\nThis bears directly on pillar 3: **only documents carrying an editing record are added automatically to the statistically guaranteed baseline.** If everything you receive is PDF, that baseline will never grow — you will only accumulate reference-only samples that carry no guarantee.\n\nTo make origin evidence and automatic calibration actually work, collect .docx or .odt originals rather than printed or exported PDFs. That is a workflow requirement, not something the software can work around: PDF is an output format and simply does not record how the text came to be written.';

  @override
  String provenanceUnsupportedFormat(String format) {
    return 'The $format format does not carry an editing history at all, so this is not a case of the record being wiped — there never was one. Only .docx and .odt record editing time, save counts and editing batches.';
  }

  @override
  String get provenanceStripped =>
      'This format is supported, but no editing record was found in the file. That usually means it was saved as a new file, converted online, or exported from Google Docs — each of which resets the record.';

  @override
  String get provenanceHowToGetRecord =>
      'To make origin evidence useful, obtain the **original .docx, .odt or .doc file** rather than a printed or exported PDF. Only the original retains the editing history, and only it can be added automatically to the statistically guaranteed baseline.';

  @override
  String get calibrationAutoTitle => 'Collecting in the background';

  @override
  String get calibrationAutoSubtitle =>
      'Documents you analyse are added to the baseline automatically — no manual labelling needed.';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return 'Confirmed human-written by editing record: $auto; reference-only samples: $observed';
  }

  @override
  String get calibrationAutoWhy =>
      'Only documents carrying an editing record (time spent, number of saves, spread of editing batches) enter the statistically guaranteed baseline, because that evidence is **independent of the text verdict**. Labelling automatically from this tool\'s own verdict would mean marking its own homework — work it wrongly flagged could never enter the baseline, the threshold would tighten with each pass, and more genuine human writing would end up flagged. Pasted text carries no editing record, so it only counts towards the reference percentile below.';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return 'For reference: this score sits at the ${percentile}th percentile of the $count documents you have analysed (no statistical guarantee attached)';
  }

  @override
  String get settingsAutoCollectTitle =>
      'Collect calibration samples in the background';

  @override
  String get settingsAutoCollectSubtitle =>
      'Adds analysed documents to the baseline automatically. Labels come from the document\'s editing record, never from this tool\'s own verdict.';

  @override
  String get settingsStoreTextTitle => 'Keep the text for offline validation';

  @override
  String get settingsStoreTextSubtitle =>
      'When on, pieces you add to the baseline are stored locally with their full text, so you can later export them as a corpus file for offline evaluation.';

  @override
  String get settingsStoreTextWarning =>
      'That text is usually someone else\'s work and therefore sensitive. Turn this on only while you are actually gathering an offline validation corpus, and use \\u201cClear stored text\\u201d below once you have exported. Clearing does not affect conformal prediction — it only needs the scores.';

  @override
  String get settingsExportCorpusTitle => 'Export the calibration corpus';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return 'Ready to export: $human human, $ai AI ($required of each needed for offline evaluation)';
  }

  @override
  String get settingsExportCorpusButton => 'Export as JSONL';

  @override
  String get settingsExportCorpusEmpty =>
      'Nothing to export — turn on \\u201ckeep the text\\u201d first, then build up the baseline';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return 'Exported $count sample(s); skipped $skipped that had no stored text';
  }

  @override
  String get settingsClearStoredText => 'Clear stored text';

  @override
  String get settingsClearStoredTextDone =>
      'All stored text cleared. Scores and calibration are untouched.';

  @override
  String get helpDesignTitle => 'Design philosophy and known limits';

  @override
  String get helpShiftTitle => '1. The shift: not competing on score accuracy';

  @override
  String get helpShiftBody =>
      'Nearly every detector on the market answers the same question: does this text look like it was written by AI?\n\nThat is an arms race you lose. The stronger the model, the closer its output sits to human writing statistically — and paraphrasing tools improve far faster than detectors do. On that road a large server-side model merely loses more slowly.\n\nTruthLens asks a different question: what evidence do we actually hold about how this document came to exist, and how strong is each piece?\n\nThat is a shift from guessing at writing style to weighing origin evidence alongside statistically honest conclusions. It is why this tool deliberately does not chase a place in the single-score accuracy rankings, but lays each piece of evidence out separately and says plainly when it does not know. The real advantage of running in your browser is not inference speed — it is seeing what a server never gets to see: the complete file, and the baseline you collected yourself.';

  @override
  String get helpPillarsTitle => '2. The five pillars';

  @override
  String get helpPillarsBody =>
      '1. Document origin forensics (live)\nReads the editing record inside DOCX and ODT containers: total editing time, number of saves, creation and modification times, and the editing-batch markers (RSIDs) in the body. One or two RSIDs across a whole essay usually means the text went in all at once; 3,000 words with four minutes of editing is harder evidence than any perplexity score. This counts as origin evidence and is shown separately from the AI probability — deliberately never folded into the score.\n\n2. Local baseline calibration and conformal prediction (live)\nAdd pieces you know the authors wrote themselves, and the system judges against this group\'s own distribution rather than a global threshold. Conformal prediction gives a distribution-free guarantee: provided baseline and tested samples are exchangeable, the false-positive rate stays under the alpha you set. This is the key to cutting misjudgements on non-native writing, and it is something commercial products cannot do — they do not have baseline writing from the people you are assessing.\n\n3. Learned engine weights (live)\nOnce the baseline holds both human and AI samples, the system measures how well each engine separates the two groups (Cohen\'s d effect size) and suggests weights accordingly, replacing the hand-set fixed ratios. Nothing changes until you press Apply — settings are never altered silently.\n\n4. Binoculars cross-perplexity (scoring core done, not yet live)\nRaw perplexity treats how predictable a text is as though that meant how AI-like it is, which is exactly why it produces systematic false positives on plain-spoken non-native writing. Binoculars measures predictability relative to how much two models disagree with each other. The scoring maths is implemented and tested, but switching it on still needs a pair of small language models that can run in a browser, plus validation against labelled data.\n\n5. Watermark detection (checked, not feasible, not built)\nSynthID-Text detection is key-bound: the detector must compute with the same keys used at generation, and Google\'s production keys are not public. Doing this in a browser would never fire on real output from ChatGPT, Claude or Gemini — it would only be a feature that never triggers while leaving you believing watermarks are being checked. So it was deliberately left out.';

  @override
  String get helpCascadeTitle => '3. The tiered cascade and abstention';

  @override
  String get helpCascadeBody =>
      'To stay fast within a browser\'s limited compute budget, analysis runs in tiers: cheap signals first, expensive ones only when needed.\n\nTier 0  Document origin evidence (near-zero cost)\nTier 1  Statistical and stylometric features (existing engines, cheap)\nTier 2  Transformer sentence-level classifier\nTier 3  Cross-perplexity (most expensive, only if the picture is still unclear)\n\nThe result then passes to local calibration, which produces a conclusion carrying a false-positive guarantee — or an explicit abstention.\n\n[Why abstention matters]\nMost false accusations come from handing back a confident number on an input too short or too weak to support one. This tool shows \"Not enough evidence to judge\" outright, rather than forcing a score, when:\n\n- fewer than 5 analysable sentences\n- fewer than 100 words\n- fewer than 2 engines took part\n- engines disagree by more than 60 percentage points (averaging them has stopped meaning anything)\n\nWhen it abstains, the full score and sentence evidence remain below for your reference — but please do not treat them as a conclusion. A system willing to say \"I don\'t know\" deserves more trust than one that always hands you a number.';

  @override
  String get helpRisksTitle => '4. Risks worth facing honestly';

  @override
  String get helpRisksBody =>
      'Every item below is a real limitation of this tool. Please weigh them before acting on anything it reports.\n\n1. Origin evidence can be wiped or faked\nSaving as a new file, converting online, exporting from Google Docs, or copying into a fresh document all reset the editing record. A signal here is supporting evidence only, and the absence of one certainly does not prove a person wrote it.\n\n2. The conformal guarantee rests on exchangeability\nIt holds only if the baseline samples and the text under test come from the same group of people doing the same kind of writing task. If an author\'s writing has clearly improved, or the kind of task has changed entirely, the premise fails and the baseline needs rebuilding.\n\n3. The baseline itself can be contaminated\nIf the work you used as a baseline was in fact ghost-written by AI, the whole calibration skews. Baseline samples must be gathered under controlled conditions — work produced under supervision, for instance.\n\n4. Small in-browser models are less accurate than large server-side ones\nThat is the unavoidable price the Web-only decision pays for privacy. This tool\'s value is not a more accurate single score, but being explainable, calibratable, and honest enough to abstain.\n\n5. No score should ever stand alone as grounds for an accusation\nAlways read it alongside the sentence-level evidence, the document\'s origin, and what you already know about this particular author. This tool is designed to support a conversation you have, not to deliver a verdict in your place.';

  @override
  String get calibrationAddHuman => 'Add as human-written baseline';

  @override
  String get calibrationAddAi => 'Add as known-AI sample';

  @override
  String calibrationCounts(int human, int ai) {
    return 'Baseline: $human human, $ai AI';
  }

  @override
  String get learnedWeightsTitle => 'Learned engine weights';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return 'You have $human human and $ai AI samples. Each class needs at least $required before weights can be learned reliably; until then your manual weights stay in force.';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return 'Weights can now be learned from your $human human and $ai AI samples.';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine: suggested weight $weight% (separation $effect)';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return 'Note: $engine has the two groups the wrong way round — the AI samples scored lower, not higher — so its weight drops to zero. That usually means the engine does not suit this kind of text.';
  }

  @override
  String get learnedWeightsApply => 'Apply the learned weights';

  @override
  String get learnedWeightsApplied => 'Learned weights applied';

  @override
  String get learnedWeightsExplain =>
      'Weights come from how well each engine separates your human samples from your AI ones (Cohen\'s d effect size): the further apart the two groups, and the steadier each group is, the more weight that engine earns. This replaces the hand-set fixed weights so the ensemble fits the kind of text you actually work with.';

  @override
  String get calibrationTitle => 'Local baseline calibration';

  @override
  String get calibrationEmpty =>
      'No baseline set yet. Add a handful of pieces you know the authors wrote themselves — work produced under supervision, for instance — and the system can judge against this group\'s own distribution instead of a one-size-fits-all global threshold. That is exactly what brings down false positives on non-native writing.';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return 'The baseline holds $count sample(s); making a $alpha% false-positive ceiling actually hold needs at least $required. Until then the figures are shown for reference only and nothing gets flagged on their basis.';
  }

  @override
  String calibrationFlagged(int alpha) {
    return 'At a $alpha% false-positive ceiling, this text **is flagged**.';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return 'At a $alpha% false-positive ceiling, this text **is not flagged**.';
  }

  @override
  String calibrationPValue(String value, int count) {
    return 'Conservative p-value $value (against $count baseline samples)';
  }

  @override
  String calibrationPercentile(int percentile) {
    return 'The score sits at the ${percentile}th percentile of the baseline';
  }

  @override
  String get calibrationCaveat =>
      'This guarantee rests on the baseline samples and the text under test being exchangeable — same group of people, same kind of writing task. If an author\'s writing has clearly improved, or the kind of task has changed entirely, that no longer holds and the baseline needs rebuilding. Note too: if the baseline pieces were themselves ghost-written by AI, the whole calibration skews, so collect them under controlled conditions.';

  @override
  String get calibrationAddButton => 'Add this to the baseline';

  @override
  String calibrationAdded(int count) {
    return 'Added to the baseline — $count sample(s) now';
  }

  @override
  String get settingsCalibrationTitle => 'Local baseline set';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return '$count sample(s) held ($required needed at this α)';
  }

  @override
  String get settingsCalibrationClear => 'Clear the baseline set';

  @override
  String get settingsCalibrationCleared => 'Baseline set cleared';

  @override
  String get settingsAlphaTitle => 'False-positive ceiling (α)';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return 'Currently $alpha% — lower is stricter but needs more baseline samples (at least $required)';
  }

  @override
  String get abstentionHeadline => 'Not enough evidence to judge';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return 'Only $count analysable sentence(s), where at least $required are needed. At this length the statistical and sentence-level signals carry no weight, and forcing a score out of them would only mislead.';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return 'The text runs to $count words, where at least $required are needed. Below that, any writing trait could just be chance.';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return 'Only $available of $total engines took part, so nothing can be cross-checked from a second angle. Fill in the missing models under model management and run it again.';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return 'The engines are $spread percentage points apart — far enough that averaging them stops meaning anything. Read the sentence evidence and the document\'s origin instead, and judge for yourself.';
  }

  @override
  String get abstentionScoreStillShown =>
      'The full score and sentence evidence are still shown below for your own reference. Please don\'t treat them as a conclusion.';

  @override
  String get provenanceTitle => 'Document origin evidence';

  @override
  String get provenanceRiskHigh => 'Editing history is clearly unusual';

  @override
  String get provenanceRiskMedium =>
      'Editing history has something odd about it';

  @override
  String get provenanceRiskLow => 'Editing history looks normal';

  @override
  String get provenanceRiskUnknown => 'No editing history available';

  @override
  String get provenanceNoMetadata =>
      'This input carries no editing history — pasted text, a PDF, or a file whose record was stripped. There is nothing to judge from origin here, only the text analysis itself.';

  @override
  String provenanceEditingDuration(int minutes) {
    return 'Editing time recorded in the file: $minutes minutes';
  }

  @override
  String provenanceRevisionCount(int count) {
    return 'Times saved: $count';
  }

  @override
  String provenanceApplication(String name) {
    return 'Produced with: $name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return 'The body carries only $count editing-batch marker(s) for $words words. Writing as you think normally leaves dozens; this much concentration usually means the text went in all at once — pasted, for instance.';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words words against $minutes minutes of recorded editing works out to $wpm words per minute, far above what anyone sustains while actually writing.';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return 'The file records almost no editing time at all, yet the body runs to $words words.';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return '$words words of content, saved only $count time(s).';
  }

  @override
  String get provenanceCaveat =>
      'Worth knowing: these records can be wiped or reset — saving as a new file, converting online, exporting from Google Docs, or copying into a fresh document all zero them out. So a signal here is supporting evidence, never a conclusion on its own; and the absence of one does not prove a person wrote it.';

  @override
  String get telemetrySummaryTitle => 'What this adds up to';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '$engines of $total engines finished. Overall AI probability is $percent%, which lands on “$verdict”.';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return 'The engines broadly agree — the highest read $high% and the lowest $low% — so this conclusion holds up well.';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return 'The engines disagree: $highLabel read $high% while $lowLabel read only $low%. When that happens, don\'t lean on the headline score — the sentence-level evidence below tells you much more.';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return 'Most of the score comes from $label, worth about $points percentage points.';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return 'Across all $total sentences, not one crossed the strong-AI line.';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return 'Of $total sentences, $count crossed the strong-AI line — worth reading through one by one.';
  }

  @override
  String get telemetrySummaryAdviceHuman =>
      'It reads like something a person actually wrote, with nothing that needs chasing down.';

  @override
  String get telemetrySummaryAdviceMixed =>
      'This one sits in the grey zone. The score alone isn\'t enough to call it — read it alongside the sentence evidence and whatever you know about where the document came from.';

  @override
  String get telemetrySummaryAdviceAi =>
      'The signals point clearly at AI generation or rewriting. Check the flagged sentences one by one before you decide.';

  @override
  String telemetrySummaryModelGap(int count) {
    return '$count engine(s) sat this one out, so take the confidence with a pinch of salt — fill them in under model management and re-run for a sharper read.';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'AI probability < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'AI probability $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'AI probability ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return 'Low confidence: available model weight is below 60% ($threshold% threshold). $available/$total engines participated. Review detailed engine analysis.';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return 'High confidence: $available/$total detection models reached consensus ($threshold% or more weight agrees with this verdict).';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return 'Low confidence ($available/$total)';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return 'High confidence ($available/$total)';
  }

  @override
  String get reportMetricAiSentenceRatio => 'Strong AI-signal sentence ratio';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count of $total crossed the 60% strong-signal threshold';
  }

  @override
  String get reportMetricElapsed => 'Analysis time';

  @override
  String get reportMetricElapsedNormal => '0.5-5s normal';

  @override
  String get reportMetricReliability => 'Reliability';

  @override
  String get reportReliabilityLow => 'Low';

  @override
  String get reportReliabilityHigh => 'High';

  @override
  String get reportReliabilityNeedsReview => 'Needs review';

  @override
  String get reportReliabilityHighTrust => 'Highly reliable';

  @override
  String get reportSentenceAnalysisTitle => 'Sentence-level analysis';

  @override
  String get suspiciousFilterAll => 'Suspicious';

  @override
  String get suspiciousFilterHigh => 'High';

  @override
  String get suspiciousFilterMedium => 'Medium';

  @override
  String get suspiciousExcludedTooltip =>
      'Single letters, page numbers, section numbers, and overly short OCR/PDF fragments have been excluded.';

  @override
  String suspiciousCount(int count) {
    return '$count items';
  }

  @override
  String get suspiciousEmpty => 'No suspicious content';

  @override
  String get suspiciousRiskHigh => 'High';

  @override
  String get suspiciousRiskMedium => 'Medium';

  @override
  String get suspiciousReasonHighModelSignals =>
      'Multiple model signals strongly lean AI';

  @override
  String get suspiciousReasonSentenceSignal =>
      'Sentence-level model signal is elevated';

  @override
  String suspiciousOriginalLocation(String location) {
    return 'Original location $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return 'Original location $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return 'Sentence #$number';
  }

  @override
  String get suspiciousEvidenceLabel => 'Evidence:';

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
      'Could not verify (timed out or no response from bibliographic services)';

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
  String get reportBibRecheckAllUnreliableButton =>
      'Recheck all unverified citations';

  @override
  String get reportBibRecheckOneTooltip => 'Recheck this citation';

  @override
  String get reportBibResultHint =>
      'Matched by author, year, title, and venue across Crossref, OpenAlex, DataCite, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and recognizable publisher catalogs. A high-confidence result requires a DOI registration or multiple consistent metadata fields; entries without a reliable match are marked as not verified. Google Scholar is available only as a user-initiated manual lookup because it does not provide automated API access.';

  @override
  String reportBibVerificationSource(String source) {
    return 'Verification source: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'Check manually in Google Scholar';

  @override
  String reportBibHighConfidence(String journal) {
    return 'High confidence: likely exists$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (registered with $journal)';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'Journal name mismatch: the document says “$reported”, while the verified registry says “$registered”. Please review this citation.';
  }

  @override
  String get reportBibNotFound =>
      'No close match found — possibly a fabricated reference';

  @override
  String get reportBibUncertain => 'Suspect: not verified by registry match';

  @override
  String reportBibTruncated(int max, int count) {
    return 'All detected entries are verified with live progress (detected $count total)';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return '$count completed; results will keep updating.';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return 'Progress $completed/$total, $current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return 'Current: $text';
  }

  @override
  String get reportBibProgressFinalizing => 'Finalizing results';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base: similar candidate found “$candidate”, but author, year, or title did not meet the reliable-match threshold.';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base: verification sources returned no reliable response or the entry lacks enough information; TruthLens does not treat this citation as verified.';
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
    return 'The overall AI probability exceeds the fixed $percent% threshold and is flagged as AI.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'The overall AI probability is below the fixed $percent% flagging threshold.';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return 'Overall AI probability is $aiPercent%, which reaches the fixed $thresholdPercent% AI flagging threshold, so the report marks this text as AI. Review sentence evidence and engine reasons before making a final decision.';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'Overall AI probability is $aiPercent%, below the fixed $thresholdPercent% AI flagging threshold, so the report does not formally mark this text as AI. The probability and evidence are still shown for review.';
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
    return 'Low language-model perplexity ($ppl) [AI-leaning], text is highly predictable';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'High language-model perplexity ($ppl) [Human-leaning], consistent with human writing variety';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'Moderate language-model perplexity ($ppl) [Neutral]';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'Highly uniform sentence length (burstiness $value) [AI-leaning], repetitive rhythm';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'Noticeable variation in sentence length (burstiness $value) [Human-leaning], dynamic rhythm';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'Low vocabulary diversity (TTR $value) [AI-leaning template pattern]';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'High vocabulary diversity (TTR $value) [Human-leaning]';
  }

  @override
  String engineReasonStatisticalSummaryAi(String percent) {
    return 'Overall statistical summary: Leans towards AI-generated characteristics ($percent% AI probability)';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return 'Overall statistical summary: Leans towards human natural writing ($percent% AI probability)';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return 'Overall statistical summary: Indicators balance out, showing neutral characteristics ($percent% AI probability)';
  }

  @override
  String get reportFormulaTitle =>
      'Weighted Calculation Transparency & Parameter Breakdown';

  @override
  String get reportFormulaExplanation =>
      'The overall AI probability is computed as a weighted average of probabilities from all active engines:';

  @override
  String get reportFormulaActiveEngines => 'Active Engines & Assigned Weights';

  @override
  String get reportFormulaCalculation => 'Weighted Formula Calculation';

  @override
  String get reportFormulaFinalResult => 'Final Weighted AI Probability';

  @override
  String get reportFormulaEslApplied =>
      'ESL non-native writing adjustment applied (statistical model weight halved)';

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
  String get modelRepairNoActiveVariant =>
      'No active model found; download a recommended model in Model Management.';

  @override
  String get modelRepairCustomRemoved =>
      'Removed the custom model that failed to load. Custom models cannot be re-downloaded automatically; please re-import the model and tokenizer.';

  @override
  String get modelRepairNoSource =>
      'Removed the model file that failed to load, but no catalog source is currently available to re-download it; please re-download a recommended model in Model Management.';

  @override
  String modelRepairRedownloaded(Object name) {
    return 'Detected that the model file may be corrupted or incompatible; automatically re-downloaded $name. Please run the analysis again.';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return 'Removed the model file that failed to load, but the automatic re-download did not complete; please check your network connection and re-download $name in Model Management.';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      'No active Transformer model found; download one or set it active in Model Management';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return 'The active model\'s tokenizer type is not supported ($tokenizer); switch to a model that supports bert-wordpiece or roberta-bpe';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Transformer model or tokenizer path is missing; re-download in Model Management';

  @override
  String get engineTransformerMissingFiles =>
      'Transformer model or tokenizer file does not exist; re-download in Model Management';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'ONNX opset version is not supported (this model version is too new; update the app): $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Tokenizer format is corrupted: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      'Model loading or inference failed, and automatic repair did not complete; re-download the active Transformer model and tokenizer in Model Management.';

  @override
  String get engineAdversarialNoActiveVariant =>
      'No active rewrite-detection model found';

  @override
  String get engineAdversarialMissingFiles =>
      'Model or tokenizer file does not exist; re-download in Model Management';

  @override
  String get engineAdversarialRepairFailed =>
      'Model loading or inference failed, and automatic repair did not complete; re-download the rewrite-detection model and tokenizer in Model Management.';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return 'Model did not participate in this vote. $error';
  }

  @override
  String get patternNotAnalyzable =>
      'Segment too short or suspected PDF/OCR noise; no sentence-level AI judgment made';

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
      'TruthLens is an AI content detector that runs **entirely inside your browser**. Four independent engines — a Transformer neural classifier, statistical feature analysis, stylometry, and adversarial-rewrite detection — vote by weight on whether text was AI-generated, and your document never leaves the machine.\n\nThe report expresses its verdict as an AI probability sorted into five fixed bands (under 20%, 20–40%, 40–60%, 60–80%, 80% and above), alongside sentence-level evidence, each engine\'s contribution, the document\'s origin evidence, and the source filename when you import one. The cut points are not adjustable, so the same document always lands in the same band. When the evidence is too thin — too few sentences or words, or engines that disagree too sharply — it says so plainly instead of forcing out a score.';

  @override
  String get helpComparisonTitle => 'Comparison with leading tools';

  @override
  String get helpComparisonDisclaimer =>
      'This comparison is compiled from each tool\'s public information and general market perception, for positioning reference only — not third-party-certified benchmark data.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero does most of its work in the cloud and requires uploading your document; all four TruthLens engines run inside your own browser, and the content is never sent anywhere.';

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
      'Originality.ai charges per piece on a subscription and requires uploading to the cloud; TruthLens does its core work in the browser, with no subscription and no usage cap.';

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
      'Winston AI\'s image OCR uploads the picture to the cloud; TruthLens OCR prefers a local OCR server that you configure, and only falls back to the cloud if you supply a Gemini API key yourself — whether the cloud is involved at all stays your decision.';

  @override
  String get helpVsWinston2 =>
      'Winston AI is known for polished, printable reports; TruthLens generates a dynamic AI-written report layout (falling back to a template if no LLM is installed), exportable as PDF/CSV/JSON/PNG.';

  @override
  String get helpAdvantagesTitle => 'TruthLens-only advantages';

  @override
  String get helpAdvantage1 =>
      'Hyperlink and citation authenticity verification: checks reachable URLs, validates DOI registration through Crossref and DataCite, and cross-checks citation metadata with OpenAlex, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and publisher catalogs. Each verified citation identifies its evidence source; Google Scholar is offered as a manual lookup only.';

  @override
  String get helpAdvantage2 =>
      'Citation authenticity verification: even references with no hyperlink at all (plain \"author-year\" style) can be checked against a bibliographic registry to catch likely-fabricated citations — a common tell of AI hallucination.';

  @override
  String get helpAdvantage3 =>
      'ESL (non-native writer) bias correction: automatically detects non-native writing characteristics and lowers the statistical model\'s weight, avoiding misjudging natural non-native writing as AI.';

  @override
  String get helpAdvantage4 =>
      'Local records and exports: reports can be saved as PDF/CSV/JSON/PNG, and the app keeps analysis history locally with the source file name when available, so you can re-run or review prior checks without an account.';

  @override
  String get helpWorkflowTitle => 'Full operating workflow';

  @override
  String helpWorkflowStepLabel(int step) {
    return 'Step $step';
  }

  @override
  String get helpWorkflowStep1Title => 'Model download & update';

  @override
  String get helpWorkflowStep1Body =>
      'First launch guides you through installing the core detection model; afterward you can always check, download, update, or remove models from \"Settings → AI Model Management\". The app proactively checks for the latest version on launch, and shows a badge on the settings icon and the \"AI Model Management\" entry if an update is available.';

  @override
  String get helpWorkflowStep2Title => 'Choosing a model (purpose & effect)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Multilingual AI classifier (40% weight): analyzes bounded paragraph blocks to retain context, then maps probabilities back to sentences for detailed evidence.';

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
      'You can individually enable/disable engines and adjust engine weights in Settings. The five verdict bands use fixed cut points (20% / 40% / 60% / 80%) and cannot be changed, so the same document always yields the same verdict for everyone.';

  @override
  String get helpWorkflowStep3Title => 'Adding content';

  @override
  String get helpWorkflowStep3Body =>
      'Three ways in: paste text directly, recognise an image with OCR, or import a document (txt / md / pdf / docx / doc / odt). PDF import compares two text-layer parsers and discards garbled output; scanned PDFs are recognised page by page when OCR is available. When you import, the filename appears under the input heading and on its own line in the report title; when you paste or type, it stays blank.\n\nOCR prefers the local server you configure, and only uses the cloud fallback if you supply a Gemini API key yourself.';

  @override
  String get helpWorkflowStep4Title => 'Running analysis';

  @override
  String get helpWorkflowStep4Body =>
      'Tap \"Start Detection\" and all four engines run in parallel, with live progress shown on screen. If non-native writing characteristics are detected, ESL bias correction is applied automatically (can be turned off in Settings). You can stop a running analysis at any time from the toolbar; the document text is kept, but unfinished results are not saved.';

  @override
  String get helpWorkflowStep5Title => 'Viewing & exporting results';

  @override
  String get helpWorkflowStep5Body =>
      'Import, live four-engine progress, and the complete report now remain in one situation-center workspace. Switch among Command grid, Mission timeline, and Evidence canvas at any time without restarting analysis; Automatic uses Command grid on desktop and Mission timeline on mobile. The result includes the verdict, AI probability, confidence, elapsed time, sentence evidence, engine contributions, link checks, and citation checks. You can export PDF, CSV, JSON, or PNG, and every result is saved to local History.';

  @override
  String get helpWorkflowStep1ChipOnboarding => 'First launch';

  @override
  String get helpWorkflowStep1ChipModelManager => 'Model management';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => 'Auto update check';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => 'Statistical analysis (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => 'Stylometry (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => 'Adversarial defense (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => 'Report LLM (optional)';

  @override
  String get helpWorkflowStep3ChipPaste => 'Paste text';

  @override
  String get helpWorkflowStep3ChipImageOcr => 'Image OCR';

  @override
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation =>
      'Code/formula isolation';

  @override
  String get helpWorkflowStep4ChipEnsemble => 'Four-engine ensemble';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'Live progress';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'ESL writing correction';

  @override
  String get helpWorkflowStep4ChipStoppable => 'Stop anytime';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'AI overview gauge';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => 'Sentence heatmap';

  @override
  String get helpWorkflowStep5ChipCitationVerification =>
      'Citation verification';

  @override
  String get helpWorkflowStep5ChipExportFormats =>
      'PDF / CSV / JSON / PNG export';

  @override
  String get helpTuningTitle =>
      'Model download & tuning walkthrough (no experience needed)';

  @override
  String get helpTuningStep1Title => 'Open Model Management';

  @override
  String get helpTuningStep1Body =>
      'From the full Settings page or the right-side settings panel on wide screens, open \"AI Model Management\" to download, update, activate, or remove local models.';

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
      'If you already have, or have fine-tuned, a compatible .onnx model elsewhere, you can import it via \"Settings → Custom ONNX model import & test\" — you\'ll need to provide the model file, its matching tokenizer configuration (or choose \"none\"), and the AI class index. Before importing, the app automatically checks whether this exact file was already imported, to avoid accidental duplicates. You can also adjust engine weights from Settings.';

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
  String get privacyWebOverview1 =>
      'TruthLens runs entirely as a web app in your browser tab. There is nothing to install; document text and analysis never leave your device, and downloaded detection models are cached in your browser\'s own sandboxed storage (OPFS), not on any server.';

  @override
  String get privacyWebOverview2 =>
      'The page only reads a file, image, or clipboard content when you actively choose to import, scan, or paste it; it never reads other tabs, other sites\' data, or files you have not selected.';

  @override
  String get privacySectionOverviewWeb => 'Overview';

  @override
  String get privacyRemoveWeb =>
      'clearing this site\'s data in your browser settings (or simply closing the tab, since nothing is stored on any server)';

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
      'Any text you type, paste, or import is analyzed entirely by on-device AI models on your own device. TruthLens does not upload document text to its own server or to a third-party AI-detection service.';

  @override
  String get privacyDataHandling3 =>
      'Analysis results and history are stored only in your browser\'s local storage on your device. History includes the analyzed text, scores, time, and the source file name when you imported a file; clearing History in the app, or clearing this site\'s data in your browser, removes this local copy — TruthLens keeps no copy anywhere.';

  @override
  String get privacyNetworkIntro =>
      'This app\'s core AI detection runs entirely on-device, but the following optional or supporting features require network access:';

  @override
  String get privacyNetwork1 =>
      '1. Model catalog & download: connects to GitHub Releases / Hugging Face to download the detection model you chose — this only downloads the model and never uploads any user data.';

  @override
  String get privacyNetwork2 =>
      '2. Model update check: on launch, the app connects to compare version numbers only, used to indicate whether a new version is available.';

  @override
  String get privacyNetwork3 =>
      '3. Hyperlink & citation authenticity verification: on by default and can be turned off in Settings. When enabled, detected URLs, DOI values, or individual citation fields (author, title, year, and venue) are sent to the target website and/or Crossref, OpenAlex, DataCite, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and recognizable publisher catalogs. The rest of the document is not sent. Google Scholar receives a citation query only when you press its manual lookup button.';

  @override
  String get privacyNetwork4 =>
      '4. Web OCR fallback: on the Web version only, OCR first uses a local OCR server if configured. If you choose to enter a Gemini API key, selected images and rendered pages from PDFs that require OCR are sent directly from your browser to Google\'s Gemini API; the key is stored only in that browser\'s local storage.';

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

  @override
  String settingsVersionSubtitle(String version, String build) {
    return 'Version $version (Build $build) · Local-first private detection engine';
  }

  @override
  String get webOcrSettingsTitle => 'Web OCR settings';

  @override
  String get webOcrPurpose =>
      'Recognize printed or handwritten text in an uploaded image before analysis.';

  @override
  String get webOcrGeminiKeyTitle => 'Gemini API key (optional)';

  @override
  String get webOcrGetKeyButton => 'Get a key';

  @override
  String get webOcrGeminiDescription =>
      'Used only when the local OCR server is unavailable. The key is saved in this browser.';

  @override
  String get webOcrLocalServerTitle => 'Local OCR server (recommended)';

  @override
  String get webOcrLocalServerDescription =>
      'Runs OCR on your computer with Apple Vision on macOS or Windows OCR on Windows. Enter the local endpoint below.';

  @override
  String get webOcrSetupGuideButton => 'Beginner setup guide';

  @override
  String get webOcrPriorityTitle => 'Recognition order';

  @override
  String get webOcrPriorityDescription =>
      '1. Local OCR server when a URL is set\n2. Gemini when an API key is set\n3. A specific diagnostic message when neither path succeeds';

  @override
  String get webOcrSetupGuideTitle => 'Set up the local OCR server';

  @override
  String get webOcrSetupGuideBody =>
      '1. Select Open OCR project below.\n2. macOS: download setup_and_run_ocr.sh, open Terminal, and run: bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows: download setup_and_run_ocr.bat, then double-click it and allow the requested installation.\n4. Wait until the installer says OCR is ready. It will also configure automatic startup.\n5. Return here, enter http://127.0.0.1:5001/ocr, and select Test connection.\n6. Open Image OCR and choose a clear image to confirm text recognition.\n\nThe browser and OCR server must run on the same computer for 127.0.0.1 to work. If testing fails, check that the installer completed, port 5001 is not blocked, and the URL ends with /ocr.';

  @override
  String get webOcrOpenProjectButton => 'Open OCR project';

  @override
  String get webOcrTestServerButton => 'Test connection';

  @override
  String get webOcrTestServerMissingUrl =>
      'Enter the local OCR server URL first.';

  @override
  String get webOcrTestServerSuccess =>
      'Local OCR server is running and ready.';

  @override
  String get webOcrTestServerFailure =>
      'Could not reach the local OCR server. Open the setup guide and check the installer, firewall, and URL.';

  @override
  String get workspaceModeSectionTitle => 'Workspace mode';

  @override
  String get workspaceModeSectionSubtitle =>
      'Choose how source, live analysis, and final evidence share one workspace.';

  @override
  String get workspaceModeOriginal => 'Original layout';

  @override
  String get workspaceModeAuto => 'Automatic';

  @override
  String get workspaceModeCommandGrid => 'Command grid';

  @override
  String get workspaceModeTimeline => 'Mission timeline';

  @override
  String get workspaceModeEvidence => 'Evidence canvas';

  @override
  String get workspaceModeCosmicFuture => 'Cosmic Future';

  @override
  String get workspaceModeSoftEducation => 'Soft Education';

  @override
  String get workspaceModeTooltip => 'Switch workspace mode';

  @override
  String get workspaceMoreMenuTooltip => 'More options';

  @override
  String get workspaceLanguageMenuTitle => 'Language';

  @override
  String get workspaceStageImport => 'Import';

  @override
  String get workspaceStageParse => 'Parse';

  @override
  String get workspaceStageAnalyze => 'Four-engine analysis';

  @override
  String get workspaceStageVerify => 'Verification';

  @override
  String get workspaceStageReport => 'Report';

  @override
  String get workspaceLiveFindings => 'Live findings';

  @override
  String get workspaceTelemetry => 'Analysis telemetry';

  @override
  String get workspaceDocument => 'Document workspace';

  @override
  String get workspaceOverallProgress => 'Overall progress';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return 'Step $current/$total · $stage';
  }

  @override
  String get workspaceWaiting => 'Waiting for a document';

  @override
  String get workspaceAnalyzing => 'Analysis in progress';

  @override
  String get workspaceAnalysisComplete => 'Analysis complete';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '$done/$total modules complete · ${seconds}s elapsed · Running: $engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return 'Analysis is still running and the interface is responsive. No module completed in the last ${seconds}s; large documents or local models may take longer.';
  }

  @override
  String get workspaceAnalysisFailed =>
      'Analysis stopped unexpectedly. Please retry or check the model settings.';

  @override
  String get workspaceNewAnalysis => 'New analysis';

  @override
  String get workspaceStopAnalysis => 'Stop analysis';

  @override
  String get workspaceStopAnalysisTitle => 'Stop the current analysis?';

  @override
  String get workspaceStopAnalysisBody =>
      'The analysis is still running. The document text will be kept, but unfinished results will not be saved.';

  @override
  String get workspaceAnalysisStopped =>
      'Analysis stopped. The document text remains in the workspace.';

  @override
  String get workspaceSelectedEvidence => 'Selected evidence';

  @override
  String get workspaceNoEvidence =>
      'Sentence evidence appears here as each engine completes.';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return 'Preliminary AI probability: $percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      'This percentage is this sentence\'s own AI signal, not the overall document verdict. Higher means the wording pattern looks more AI-generated; lower means it reads more like typical human writing. The final report combines every sentence with engine weighting.';

  @override
  String get workspaceSentenceSignalHeader => 'AI signal per sentence';

  @override
  String get workspaceSentenceColumnHeader => 'Sentence';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine found no evidence this time, so it did not take part in the vote (role weight $weight%). This means it spotted no AI traces on its own axis — not that it considers the text human-written.';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return 'Only $engine found anything; the other engines turned up nothing this time. The conclusion rests on a single line of evidence, so treat its confidence accordingly.';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return '$count further engine(s) ran but found no evidence, and were excluded from the vote so that \'nothing to report\' is not miscounted as \'looks human-written\'.';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      'Perplexity was not used for this document: the perplexity model (DistilGPT2) was trained on English only, and on Chinese, Japanese or Korean text it measures byte predictability rather than language predictability. Measured on labelled data, it separates human from AI writing in those languages 0% of the time, so counting it would only manufacture false positives.';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return 'Baseline by language: $breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return '$count earlier sample(s) carry no language tag and cannot join any language\'s baseline — the original text is not kept, so the language cannot be recovered after the fact. They will be replaced as new documents are analysed.';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return 'Routed to “$variant” for this document: the variant you selected is not validated for $language, and this one is.';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '“$variant” is a multilingual model but has not been validated on $language, so treat its score as weaker evidence than a validated one.';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '“$variant” does not cover $language. Its score is shown for reference only and should not be read as evidence either way.';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      'Perplexity was not used: the language of this document could not be determined, so there is no calibrated threshold to compare against. Guessing a language would mean applying the wrong scale — the mistake this check exists to prevent.';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return 'Perplexity was not used: the model in use (“$model”) has no measured threshold for $language yet. Its raw value carries no meaning without a calibrated scale, so it is left out rather than guessed at.';
  }
}
