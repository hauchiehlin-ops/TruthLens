import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @verdictHuman.
  ///
  /// In en, this message translates to:
  /// **'Human-written'**
  String get verdictHuman;

  /// No description provided for @verdictLikelyHuman.
  ///
  /// In en, this message translates to:
  /// **'Likely human'**
  String get verdictLikelyHuman;

  /// No description provided for @verdictMixed.
  ///
  /// In en, this message translates to:
  /// **'Mixed content'**
  String get verdictMixed;

  /// No description provided for @verdictLikelyAi.
  ///
  /// In en, this message translates to:
  /// **'Likely AI'**
  String get verdictLikelyAi;

  /// No description provided for @verdictAi.
  ///
  /// In en, this message translates to:
  /// **'AI-generated'**
  String get verdictAi;

  /// No description provided for @inputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste or type text to detect AI-generated content'**
  String get inputSubtitle;

  /// No description provided for @inputHint.
  ///
  /// In en, this message translates to:
  /// **'Type or paste the text to analyze…'**
  String get inputHint;

  /// No description provided for @inputHistoryTooltip.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get inputHistoryTooltip;

  /// No description provided for @inputHelpTooltip.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get inputHelpTooltip;

  /// No description provided for @inputPrivacyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get inputPrivacyTooltip;

  /// No description provided for @inputSettingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get inputSettingsTooltip;

  /// No description provided for @inputPasteButton.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get inputPasteButton;

  /// No description provided for @inputOcrButton.
  ///
  /// In en, this message translates to:
  /// **'Image OCR'**
  String get inputOcrButton;

  /// No description provided for @inputImportButton.
  ///
  /// In en, this message translates to:
  /// **'Import File'**
  String get inputImportButton;

  /// No description provided for @inputStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start Detection'**
  String get inputStartButton;

  /// No description provided for @inputClearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear content'**
  String get inputClearTooltip;

  /// No description provided for @inputTooShortSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Please enter at least 40 characters for reliable analysis'**
  String get inputTooShortSnackbar;

  /// No description provided for @inputOcrUnsupported.
  ///
  /// In en, this message translates to:
  /// **'OCR text recognition is not supported on this platform'**
  String get inputOcrUnsupported;

  /// No description provided for @inputOcrRecognizing.
  ///
  /// In en, this message translates to:
  /// **'Recognizing…'**
  String get inputOcrRecognizing;

  /// No description provided for @inputOcrNoText.
  ///
  /// In en, this message translates to:
  /// **'No text was recognized in the image'**
  String get inputOcrNoText;

  /// No description provided for @inputOcrRecognized.
  ///
  /// In en, this message translates to:
  /// **'Recognized {count} characters'**
  String inputOcrRecognized(int count);

  /// No description provided for @inputImportNoText.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" has no readable text content'**
  String inputImportNoText(String fileName);

  /// No description provided for @inputImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported \"{fileName}\" ({count} characters)'**
  String inputImportSuccess(String fileName, int count);

  /// No description provided for @inputActiveModel.
  ///
  /// In en, this message translates to:
  /// **'Model: {modelId}'**
  String inputActiveModel(String modelId);

  /// No description provided for @inputNoModel.
  ///
  /// In en, this message translates to:
  /// **'No model installed (statistical/style analysis only)'**
  String get inputNoModel;

  /// No description provided for @inputCharCount.
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String inputCharCount(int count);

  /// No description provided for @analysisAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing'**
  String get analysisAppBarTitle;

  /// No description provided for @analysisEngineTransformer.
  ///
  /// In en, this message translates to:
  /// **'Transformer classifier'**
  String get analysisEngineTransformer;

  /// No description provided for @analysisEngineStatistical.
  ///
  /// In en, this message translates to:
  /// **'Statistical analysis'**
  String get analysisEngineStatistical;

  /// No description provided for @analysisEngineStylometry.
  ///
  /// In en, this message translates to:
  /// **'Stylometry analysis'**
  String get analysisEngineStylometry;

  /// No description provided for @analysisEngineAdversarial.
  ///
  /// In en, this message translates to:
  /// **'Adversarial defense'**
  String get analysisEngineAdversarial;

  /// No description provided for @analysisProgressSemantics.
  ///
  /// In en, this message translates to:
  /// **'Analysis in progress, {done} of {total} engines completed'**
  String analysisProgressSemantics(int done, int total);

  /// No description provided for @analysisDoneSemantics.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get analysisDoneSemantics;

  /// No description provided for @engineNameAdversarialFull.
  ///
  /// In en, this message translates to:
  /// **'Adversarial defense (paraphrase detection)'**
  String get engineNameAdversarialFull;

  /// No description provided for @modelNecessityText.
  ///
  /// In en, this message translates to:
  /// **'Without a downloaded neural detection model, TruthLens still works, but only using statistical and stylistic analysis with limited accuracy and language coverage. After downloading a model, the multilingual Transformer classifier joins the ensemble vote, significantly improving accuracy and reliability. The model runs on-device; once downloaded, it never uploads any content.'**
  String get modelNecessityText;

  /// No description provided for @modelPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Download a detection model for full analysis'**
  String get modelPromptTitle;

  /// No description provided for @modelPromptDontRemind.
  ///
  /// In en, this message translates to:
  /// **'Don\'t remind me again'**
  String get modelPromptDontRemind;

  /// No description provided for @modelPromptSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get modelPromptSkip;

  /// No description provided for @modelPromptDownload.
  ///
  /// In en, this message translates to:
  /// **'Go to download'**
  String get modelPromptDownload;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to TruthLens'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingHeadline.
  ///
  /// In en, this message translates to:
  /// **'On-device AI content detection'**
  String get onboardingHeadline;

  /// No description provided for @onboardingDetectedDevice.
  ///
  /// In en, this message translates to:
  /// **'Detected device'**
  String get onboardingDetectedDevice;

  /// No description provided for @onboardingChooseModel.
  ///
  /// In en, this message translates to:
  /// **'Choose a model to download'**
  String get onboardingChooseModel;

  /// No description provided for @onboardingRecommendHint.
  ///
  /// In en, this message translates to:
  /// **'\"Recommended\" is marked based on your hardware; you may also pick another option.'**
  String get onboardingRecommendHint;

  /// No description provided for @onboardingSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Decide later (use statistical/stylistic analysis without a model)'**
  String get onboardingSkipButton;

  /// No description provided for @onboardingSkipHint.
  ///
  /// In en, this message translates to:
  /// **'You can still download later from \"Settings → AI Model Management\"; you\'ll be reminded again when an analysis needs a model.'**
  String get onboardingSkipHint;

  /// No description provided for @modelListCustomImportedLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom imported models:'**
  String get modelListCustomImportedLabel;

  /// No description provided for @modelListActiveChip.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get modelListActiveChip;

  /// No description provided for @modelListRecommendedChip.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get modelListRecommendedChip;

  /// No description provided for @modelListCustomChip.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get modelListCustomChip;

  /// No description provided for @modelListSizeLangRam.
  ///
  /// In en, this message translates to:
  /// **'{size} · {langs} · needs {ram}GB RAM · v{version}'**
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  );

  /// No description provided for @modelListSizeTokenizerLabel.
  ///
  /// In en, this message translates to:
  /// **'Size: {size} · Tokenizer: {tokenizer} · AI Label Index: {index}'**
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index);

  /// No description provided for @modelListDownloadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading… {percent}% ({downloaded} / {total})'**
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  );

  /// No description provided for @modelListDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download ({size})'**
  String modelListDownloadButton(String size);

  /// No description provided for @modelListComingSoonChip.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get modelListComingSoonChip;

  /// No description provided for @modelListSetActiveButton.
  ///
  /// In en, this message translates to:
  /// **'Set active'**
  String get modelListSetActiveButton;

  /// No description provided for @modelListUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get modelListUpdateButton;

  /// No description provided for @modelListDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get modelListDeleteTooltip;

  /// No description provided for @modelListPageButton.
  ///
  /// In en, this message translates to:
  /// **'Model page'**
  String get modelListPageButton;

  /// No description provided for @modelListMayExceedMemory.
  ///
  /// In en, this message translates to:
  /// **'May exceed device memory'**
  String get modelListMayExceedMemory;

  /// No description provided for @modelListFailedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String modelListFailedPrefix(String error);

  /// No description provided for @modelListDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this model?'**
  String get modelListDeleteConfirmTitle;

  /// No description provided for @modelListDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete \"{name}\" ({size}). You\'ll need to download it again to use it.'**
  String modelListDeleteConfirmBody(String name, String size);

  /// No description provided for @modelListDeleteCustomConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete the custom-imported \"{name}\" ({size}). You\'ll need to import it again to use it.'**
  String modelListDeleteCustomConfirmBody(String name, String size);

  /// No description provided for @modelImportAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Custom ONNX Model'**
  String get modelImportAppBarTitle;

  /// No description provided for @modelImportStep1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Select an ONNX model file'**
  String get modelImportStep1Title;

  /// No description provided for @modelImportSelectedFile.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String modelImportSelectedFile(String name);

  /// No description provided for @modelImportNoFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No model file selected (.onnx)'**
  String get modelImportNoFileSelected;

  /// No description provided for @modelImportBrowseButton.
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get modelImportBrowseButton;

  /// No description provided for @modelImportCheckingDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Checking whether this file was already imported…'**
  String get modelImportCheckingDuplicate;

  /// No description provided for @modelImportDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'An identical model has already been imported'**
  String get modelImportDuplicateTitle;

  /// No description provided for @modelImportDuplicateBody.
  ///
  /// In en, this message translates to:
  /// **'This file has exactly the same content as \"{name}\" (role: {role}). If you just want to switch the active model, go to \"AI Model Management\" and set it active there — no need to re-import. You can still continue the steps below.'**
  String modelImportDuplicateBody(String name, String role);

  /// No description provided for @modelImportStep2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Configuration'**
  String get modelImportStep2Title;

  /// No description provided for @modelImportNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Model display name'**
  String get modelImportNameLabel;

  /// No description provided for @modelImportNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get modelImportNameRequired;

  /// No description provided for @modelImportRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Target engine role'**
  String get modelImportRoleLabel;

  /// No description provided for @modelImportTokenizerTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Tokenizer type'**
  String get modelImportTokenizerTypeLabel;

  /// No description provided for @modelImportTokenizerBert.
  ///
  /// In en, this message translates to:
  /// **'BERT (WordPiece)'**
  String get modelImportTokenizerBert;

  /// No description provided for @modelImportTokenizerRoberta.
  ///
  /// In en, this message translates to:
  /// **'RoBERTa (BPE)'**
  String get modelImportTokenizerRoberta;

  /// No description provided for @modelImportTokenizerNone.
  ///
  /// In en, this message translates to:
  /// **'None (no tokenizer / char-level)'**
  String get modelImportTokenizerNone;

  /// No description provided for @modelImportNoTokenizerSelected.
  ///
  /// In en, this message translates to:
  /// **'No tokenizer file selected (.json)'**
  String get modelImportNoTokenizerSelected;

  /// No description provided for @modelImportTokenizerSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String modelImportTokenizerSelected(String name);

  /// No description provided for @modelImportAiLabelIndexLabel.
  ///
  /// In en, this message translates to:
  /// **'AI label output index'**
  String get modelImportAiLabelIndexLabel;

  /// No description provided for @modelImportIndex0.
  ///
  /// In en, this message translates to:
  /// **'Index 0 (e.g. RoBERTa)'**
  String get modelImportIndex0;

  /// No description provided for @modelImportIndex1.
  ///
  /// In en, this message translates to:
  /// **'Index 1 (e.g. DistilBERT)'**
  String get modelImportIndex1;

  /// No description provided for @modelImportStep3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Test & verify'**
  String get modelImportStep3Title;

  /// No description provided for @modelImportTestInputLabel.
  ///
  /// In en, this message translates to:
  /// **'Test input text'**
  String get modelImportTestInputLabel;

  /// No description provided for @modelImportRunTestButton.
  ///
  /// In en, this message translates to:
  /// **'Run test inference'**
  String get modelImportRunTestButton;

  /// No description provided for @modelImportResultLabel.
  ///
  /// In en, this message translates to:
  /// **'Inference result (AI probability):'**
  String get modelImportResultLabel;

  /// No description provided for @modelImportTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Test failed: {error}'**
  String modelImportTestFailed(String error);

  /// No description provided for @modelImportConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm import and activate model'**
  String get modelImportConfirmButton;

  /// No description provided for @modelImportSelectTokenizerFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a tokenizer file first'**
  String get modelImportSelectTokenizerFirst;

  /// No description provided for @modelImportSelectTokenizer.
  ///
  /// In en, this message translates to:
  /// **'Please select a tokenizer file'**
  String get modelImportSelectTokenizer;

  /// No description provided for @modelImportSuccessSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Model imported successfully and set as active!'**
  String get modelImportSuccessSnackbar;

  /// No description provided for @modelImportFailedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Model import failed. Please check permissions or logs'**
  String get modelImportFailedSnackbar;

  /// No description provided for @settingsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsAppBarTitle;

  /// No description provided for @settingsThresholdTitle.
  ///
  /// In en, this message translates to:
  /// **'AI detection confidence threshold'**
  String get settingsThresholdTitle;

  /// No description provided for @settingsThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Current: {percent}% — raising it lowers false positives (human text misjudged as AI)'**
  String settingsThresholdSubtitle(int percent);

  /// No description provided for @settingsEslTitle.
  ///
  /// In en, this message translates to:
  /// **'ESL non-native writer bias correction'**
  String get settingsEslTitle;

  /// No description provided for @settingsEslSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically lowers the statistical model\'s weight when non-native writing style is detected'**
  String get settingsEslSubtitle;

  /// No description provided for @settingsEngineSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Sub-detection engines (Ensemble)'**
  String get settingsEngineSectionTitle;

  /// No description provided for @settingsEngineTransformerTitle.
  ///
  /// In en, this message translates to:
  /// **'Multilingual AI classifier (Transformer)'**
  String get settingsEngineTransformerTitle;

  /// No description provided for @settingsEngineTransformerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uses a Transformer neural network model for on-device AI probability prediction'**
  String get settingsEngineTransformerSubtitle;

  /// No description provided for @settingsEngineStatisticalTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistical analysis engine'**
  String get settingsEngineStatisticalTitle;

  /// No description provided for @settingsEngineStatisticalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Determines language regularity via sentence-length variance, burstiness, and perplexity'**
  String get settingsEngineStatisticalSubtitle;

  /// No description provided for @settingsEngineStylometryTitle.
  ///
  /// In en, this message translates to:
  /// **'Stylometry analysis'**
  String get settingsEngineStylometryTitle;

  /// No description provided for @settingsEngineStylometrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzes semantic fluency, repeated sentence patterns, and transition-word usage'**
  String get settingsEngineStylometrySubtitle;

  /// No description provided for @settingsEngineAdversarialTitle.
  ///
  /// In en, this message translates to:
  /// **'Adversarial paraphrase detection'**
  String get settingsEngineAdversarialTitle;

  /// No description provided for @settingsEngineAdversarialSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Detects whether text has been machine-paraphrased or AI-trace-scrubbed'**
  String get settingsEngineAdversarialSubtitle;

  /// No description provided for @settingsLinkVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Hyperlink & bibliography verification'**
  String get settingsLinkVerificationTitle;

  /// No description provided for @settingsLinkVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The report will connect to check whether URLs and bibliography entries detected in a document actually exist (AI-generated content often includes plausible-looking but fabricated citations). DOI-style academic links, and \"author-year\" references without any link, are both checked against Crossref\'s public registry. Core AI detection still runs entirely on-device and never sends document content; connectivity is used only for this verification and for model update checks, and can be turned off here.'**
  String get settingsLinkVerificationSubtitle;

  /// No description provided for @settingsThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsThemeTitle;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the app display language'**
  String get settingsLanguageSubtitle;

  /// No description provided for @settingsModelManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Model Management'**
  String get settingsModelManagementTitle;

  /// No description provided for @settingsModelManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download detection models and the report-writing LLM to enable full inference'**
  String get settingsModelManagementSubtitle;

  /// No description provided for @settingsModelManagementUpdateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A model update was detected — check it out'**
  String get settingsModelManagementUpdateSubtitle;

  /// No description provided for @settingsOpenButton.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get settingsOpenButton;

  /// No description provided for @settingsCustomImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Custom ONNX model import & test'**
  String get settingsCustomImportTitle;

  /// No description provided for @settingsCustomImportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Import a local custom ONNX model and tokenizer configuration, and run a test inference'**
  String get settingsCustomImportSubtitle;

  /// No description provided for @settingsLanguagePackTitle.
  ///
  /// In en, this message translates to:
  /// **'Language packs'**
  String get settingsLanguagePackTitle;

  /// No description provided for @settingsLanguagePackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Additional fine-tuned language models (available in phase 4)'**
  String get settingsLanguagePackSubtitle;

  /// No description provided for @settingsModelManagerAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Model Management'**
  String get settingsModelManagerAppBarTitle;

  /// No description provided for @settingsImportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Import a local ONNX model'**
  String get settingsImportTooltip;

  /// No description provided for @settingsDeviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Device: {summary}'**
  String settingsDeviceLabel(String summary);

  /// No description provided for @historyAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyAppBarTitle;

  /// No description provided for @historyClearAllTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get historyClearAllTooltip;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search history…'**
  String get historySearchHint;

  /// No description provided for @historyDeletedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get historyDeletedSnackbar;

  /// No description provided for @historyClearAllTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all history?'**
  String get historyClearAllTitle;

  /// No description provided for @historyClearAllBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all {count} entries. This cannot be undone.'**
  String historyClearAllBody(int count);

  /// No description provided for @historyClearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get historyClearButton;

  /// No description provided for @historyDeleteEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get historyDeleteEntryTitle;

  /// No description provided for @historyReanalyzeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Re-analyze'**
  String get historyReanalyzeTooltip;

  /// No description provided for @historyEmptyDefault.
  ///
  /// In en, this message translates to:
  /// **'No analysis history yet'**
  String get historyEmptyDefault;

  /// No description provided for @historyEmptySearch.
  ///
  /// In en, this message translates to:
  /// **'No entries match \"{query}\"'**
  String historyEmptySearch(String query);

  /// No description provided for @historyEntrySemantics.
  ///
  /// In en, this message translates to:
  /// **'{verdict}, AI probability {percent}%, {time}. {text}'**
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  );

  /// No description provided for @reportAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Detection Report'**
  String get reportAppBarTitle;

  /// No description provided for @reportExportTooltip.
  ///
  /// In en, this message translates to:
  /// **'Export report'**
  String get reportExportTooltip;

  /// No description provided for @reportHomeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get reportHomeTooltip;

  /// No description provided for @reportGeneratingTitle.
  ///
  /// In en, this message translates to:
  /// **'Generating report…'**
  String get reportGeneratingTitle;

  /// No description provided for @reportSourceLlm.
  ///
  /// In en, this message translates to:
  /// **'AI-generated report'**
  String get reportSourceLlm;

  /// No description provided for @reportSourceTemplate.
  ///
  /// In en, this message translates to:
  /// **'Template-generated report'**
  String get reportSourceTemplate;

  /// No description provided for @reportSentenceSummary.
  ///
  /// In en, this message translates to:
  /// **'{total} sentences · {ai} likely AI · {human} likely human · {seconds}s elapsed'**
  String reportSentenceSummary(int total, int ai, int human, String seconds);

  /// No description provided for @reportExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF report'**
  String get reportExportPdf;

  /// No description provided for @reportExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV data'**
  String get reportExportCsv;

  /// No description provided for @reportExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON (system integration)'**
  String get reportExportJson;

  /// No description provided for @reportExportPng.
  ///
  /// In en, this message translates to:
  /// **'Export summary card (PNG)'**
  String get reportExportPng;

  /// No description provided for @reportExported.
  ///
  /// In en, this message translates to:
  /// **'Exported: {path}'**
  String reportExported(String path);

  /// No description provided for @reportExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String reportExportFailed(String error);

  /// No description provided for @reportEngineBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Engine breakdown'**
  String get reportEngineBreakdownTitle;

  /// No description provided for @reportEngineNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get reportEngineNotInstalled;

  /// No description provided for @reportSentenceAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Sentence-level analysis'**
  String get reportSentenceAnalysisTitle;

  /// No description provided for @reportSentenceTooltip.
  ///
  /// In en, this message translates to:
  /// **'{text}. AI probability {percent}%{patterns}'**
  String reportSentenceTooltip(String text, int percent, String patterns);

  /// No description provided for @reportLinkAuthenticityTitle.
  ///
  /// In en, this message translates to:
  /// **'Hyperlink authenticity'**
  String get reportLinkAuthenticityTitle;

  /// No description provided for @reportLinkNoneDetected.
  ///
  /// In en, this message translates to:
  /// **'No hyperlinks were detected in this document.'**
  String get reportLinkNoneDetected;

  /// No description provided for @reportLinkCheckingProgress.
  ///
  /// In en, this message translates to:
  /// **'Verifying links…'**
  String get reportLinkCheckingProgress;

  /// No description provided for @reportLinkDetectedPending.
  ///
  /// In en, this message translates to:
  /// **'Detected {count} hyperlink(s); not yet verified'**
  String reportLinkDetectedPending(int count);

  /// No description provided for @reportLinkDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'AI-generated content often includes plausible-looking but fabricated citation links. You\'ve turned off hyperlink verification in Settings; you can turn it back on for automatic verification, or tap below for a one-time check.'**
  String get reportLinkDisabledHint;

  /// No description provided for @reportVerifyNowButton.
  ///
  /// In en, this message translates to:
  /// **'Verify now (requires network)'**
  String get reportVerifyNowButton;

  /// No description provided for @reportLinkReachable.
  ///
  /// In en, this message translates to:
  /// **'Reachable — the URL exists'**
  String get reportLinkReachable;

  /// No description provided for @reportLinkNotFound.
  ///
  /// In en, this message translates to:
  /// **'URL does not exist (404) — possibly a fabricated citation'**
  String get reportLinkNotFound;

  /// No description provided for @reportLinkUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not verify (timed out or no server response)'**
  String get reportLinkUnreachable;

  /// No description provided for @reportLinkCitationVerified.
  ///
  /// In en, this message translates to:
  /// **'Verified in journal registry: registered with {journal}{title}'**
  String reportLinkCitationVerified(String journal, String title);

  /// No description provided for @reportLinkCitationNotFound.
  ///
  /// In en, this message translates to:
  /// **'No matching DOI registration found — possibly a fabricated citation'**
  String get reportLinkCitationNotFound;

  /// No description provided for @reportLinkCitationUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not verify (timed out or no response from Crossref)'**
  String get reportLinkCitationUnreachable;

  /// No description provided for @reportLinkTruncated.
  ///
  /// In en, this message translates to:
  /// **'Only the first {max} links were verified (detected {count} total)'**
  String reportLinkTruncated(int max, int count);

  /// No description provided for @reportBibAuthenticityTitle.
  ///
  /// In en, this message translates to:
  /// **'Citation authenticity'**
  String get reportBibAuthenticityTitle;

  /// No description provided for @reportBibNoneDetected.
  ///
  /// In en, this message translates to:
  /// **'No bibliography entries were detected in this document.'**
  String get reportBibNoneDetected;

  /// No description provided for @reportBibCheckingProgress.
  ///
  /// In en, this message translates to:
  /// **'Verifying bibliography…'**
  String get reportBibCheckingProgress;

  /// No description provided for @reportBibDetectedPending.
  ///
  /// In en, this message translates to:
  /// **'Detected a bibliography ({count} entries); not yet verified'**
  String reportBibDetectedPending(int count);

  /// No description provided for @reportBibDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'AI-generated content often includes plausible-looking but fabricated references. You\'ve turned off hyperlink verification in Settings; you can turn it back on for automatic verification, or tap below for a one-time check.'**
  String get reportBibDisabledHint;

  /// No description provided for @reportVerifyNowBibButton.
  ///
  /// In en, this message translates to:
  /// **'Verify now (requires network)'**
  String get reportVerifyNowBibButton;

  /// No description provided for @reportBibResultHint.
  ///
  /// In en, this message translates to:
  /// **'Matched against Crossref\'s public registry by author, year, and title similarity. Not an absolute guarantee — when \"uncertain\", please double-check manually.'**
  String get reportBibResultHint;

  /// No description provided for @reportBibHighConfidence.
  ///
  /// In en, this message translates to:
  /// **'High confidence: likely exists{journal}'**
  String reportBibHighConfidence(String journal);

  /// No description provided for @reportBibJournalSuffix.
  ///
  /// In en, this message translates to:
  /// **' (registered with {journal})'**
  String reportBibJournalSuffix(String journal);

  /// No description provided for @reportBibNotFound.
  ///
  /// In en, this message translates to:
  /// **'No close match found — possibly a fabricated reference'**
  String get reportBibNotFound;

  /// No description provided for @reportBibUncertain.
  ///
  /// In en, this message translates to:
  /// **'Moderate similarity or connection failed — uncertain, please verify manually'**
  String get reportBibUncertain;

  /// No description provided for @reportBibTruncated.
  ///
  /// In en, this message translates to:
  /// **'Only the first {max} entries were verified (detected {count} total)'**
  String reportBibTruncated(int max, int count);

  /// No description provided for @reportNetworkWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Poor network connection'**
  String get reportNetworkWarningTitle;

  /// No description provided for @reportNetworkWarningBody.
  ///
  /// In en, this message translates to:
  /// **'This app assumes network connectivity is available by default; hyperlink and citation authenticity analysis both require network access to produce a result. A connection could not be established — please check your network and try again.'**
  String get reportNetworkWarningBody;

  /// No description provided for @reportRetryConnectionButton.
  ///
  /// In en, this message translates to:
  /// **'Recheck connection'**
  String get reportRetryConnectionButton;

  /// No description provided for @reportAiProbabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'AI probability'**
  String get reportAiProbabilityLabel;

  /// No description provided for @summaryCardStats.
  ///
  /// In en, this message translates to:
  /// **'{total} sentences\n{ai} likely AI\n{human} likely human'**
  String summaryCardStats(int total, int ai, int human);

  /// No description provided for @summaryCardFooter.
  ///
  /// In en, this message translates to:
  /// **'Core AI inference runs entirely on-device'**
  String get summaryCardFooter;

  /// No description provided for @exportReportTitle.
  ///
  /// In en, this message translates to:
  /// **'TruthLens Detection Report'**
  String get exportReportTitle;

  /// No description provided for @pdfPageFooter.
  ///
  /// In en, this message translates to:
  /// **'TruthLens · Page {page} / {total}'**
  String pdfPageFooter(int page, int total);

  /// No description provided for @pdfAnalyzedAtElapsed.
  ///
  /// In en, this message translates to:
  /// **'Analyzed: {datetime} · {seconds}s elapsed'**
  String pdfAnalyzedAtElapsed(String datetime, String seconds);

  /// No description provided for @reportOverallVerdictLabel.
  ///
  /// In en, this message translates to:
  /// **'Overall verdict: {verdict}'**
  String reportOverallVerdictLabel(String verdict);

  /// No description provided for @pdfEslAppliedSuffix.
  ///
  /// In en, this message translates to:
  /// **' (ESL correction applied)'**
  String get pdfEslAppliedSuffix;

  /// No description provided for @pdfSentenceCounts.
  ///
  /// In en, this message translates to:
  /// **'{total} sentences · {ai} likely AI · {human} likely human'**
  String pdfSentenceCounts(int total, int ai, int human);

  /// No description provided for @pdfTruncationNotice.
  ///
  /// In en, this message translates to:
  /// **'To keep the PDF readable, only the first {max} sentences are shown (of {count} total); for the complete per-sentence data, use \"{csvLabel}\" or \"{jsonLabel}\" instead.'**
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  );

  /// No description provided for @pdfSentenceColumnHeader.
  ///
  /// In en, this message translates to:
  /// **'Sentence (with matched patterns)'**
  String get pdfSentenceColumnHeader;

  /// No description provided for @composerHeadlineAi.
  ///
  /// In en, this message translates to:
  /// **'This text is very likely AI-generated (AI probability {percent}%)'**
  String composerHeadlineAi(int percent);

  /// No description provided for @composerHeadlineLikelyAi.
  ///
  /// In en, this message translates to:
  /// **'This text leans AI-generated; further review is recommended (AI probability {percent}%)'**
  String composerHeadlineLikelyAi(int percent);

  /// No description provided for @composerHeadlineMixed.
  ///
  /// In en, this message translates to:
  /// **'This text shows a mix of human and AI characteristics (AI probability {percent}%)'**
  String composerHeadlineMixed(int percent);

  /// No description provided for @composerHeadlineLikelyHuman.
  ///
  /// In en, this message translates to:
  /// **'This text leans human-written (AI probability {percent}%)'**
  String composerHeadlineLikelyHuman(int percent);

  /// No description provided for @composerHeadlineHuman.
  ///
  /// In en, this message translates to:
  /// **'This text is very likely human-written (AI probability {percent}%)'**
  String composerHeadlineHuman(int percent);

  /// No description provided for @composerThresholdFlagged.
  ///
  /// In en, this message translates to:
  /// **'The overall AI probability exceeds your {percent}% threshold and is flagged as AI.'**
  String composerThresholdFlagged(int percent);

  /// No description provided for @composerThresholdNotFlagged.
  ///
  /// In en, this message translates to:
  /// **'The overall AI probability is below your {percent}% flagging threshold.'**
  String composerThresholdNotFlagged(int percent);

  /// No description provided for @composerNarrativeTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis interpretation'**
  String get composerNarrativeTitle;

  /// No description provided for @composerParaphraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Paraphrase traces detected'**
  String get composerParaphraseTitle;

  /// No description provided for @composerParaphraseBody.
  ///
  /// In en, this message translates to:
  /// **'This text may have been processed by a paraphrasing tool (e.g. QuillBot, Undetectable.ai) to evade detection. Even if it reads naturally sentence-by-sentence, its overall statistical fingerprint still differs from genuine human writing — please pay extra attention.'**
  String get composerParaphraseBody;

  /// No description provided for @composerPatternListTitle.
  ///
  /// In en, this message translates to:
  /// **'Main AI writing patterns'**
  String get composerPatternListTitle;

  /// No description provided for @composerEslTitle.
  ///
  /// In en, this message translates to:
  /// **'ESL non-native writer bias correction'**
  String get composerEslTitle;

  /// No description provided for @composerEslBody.
  ///
  /// In en, this message translates to:
  /// **'This text may be from a non-native writer. Low perplexity and regular sentence patterns common among non-native writers are not themselves signs of AI, so the system has lowered the statistical model\'s weight to avoid misjudging it.'**
  String get composerEslBody;

  /// No description provided for @composerNarrativeIntro.
  ///
  /// In en, this message translates to:
  /// **'This text has {total} sentences in total, of which {ai} show strong AI characteristics and {human} lean human-written.'**
  String composerNarrativeIntro(int total, int ai, int human);

  /// No description provided for @composerNarrativeAiPattern.
  ///
  /// In en, this message translates to:
  /// **'Most sentences are highly regular in rhythm, word choice, and transition-word usage — a common fingerprint of AI-generated text.'**
  String get composerNarrativeAiPattern;

  /// No description provided for @composerNarrativeMixedPattern.
  ///
  /// In en, this message translates to:
  /// **'The text contains both regularized and naturally-varying passages, suggesting a human draft polished by AI, or human-AI collaboration.'**
  String get composerNarrativeMixedPattern;

  /// No description provided for @composerNarrativeHumanPattern.
  ///
  /// In en, this message translates to:
  /// **'Sentence length and word choice show natural variation and personal style, with no clear signs of AI regularity.'**
  String get composerNarrativeHumanPattern;

  /// No description provided for @engineReasonPplLow.
  ///
  /// In en, this message translates to:
  /// **'Low language-model perplexity ({ppl}) — the text is highly predictable, an indicator of AI generation'**
  String engineReasonPplLow(String ppl);

  /// No description provided for @engineReasonPplHigh.
  ///
  /// In en, this message translates to:
  /// **'High language-model perplexity ({ppl}), consistent with the unpredictability of human writing'**
  String engineReasonPplHigh(String ppl);

  /// No description provided for @engineReasonPplMid.
  ///
  /// In en, this message translates to:
  /// **'Moderate language-model perplexity ({ppl})'**
  String engineReasonPplMid(String ppl);

  /// No description provided for @engineReasonBurstinessLow.
  ///
  /// In en, this message translates to:
  /// **'Highly uniform sentence length (burstiness {value}) — even rhythm is a typical statistical signature of AI-generated text'**
  String engineReasonBurstinessLow(String value);

  /// No description provided for @engineReasonBurstinessHigh.
  ///
  /// In en, this message translates to:
  /// **'Noticeable variation in sentence length (burstiness {value}), consistent with the natural rhythm of human writing'**
  String engineReasonBurstinessHigh(String value);

  /// No description provided for @engineReasonTtrLow.
  ///
  /// In en, this message translates to:
  /// **'Low vocabulary diversity (TTR {value}) — high word repetition'**
  String engineReasonTtrLow(String value);

  /// No description provided for @engineReasonTtrHigh.
  ///
  /// In en, this message translates to:
  /// **'High vocabulary diversity (TTR {value})'**
  String engineReasonTtrHigh(String value);

  /// No description provided for @engineReasonNeutral.
  ///
  /// In en, this message translates to:
  /// **'Statistical indicators show no significant tendency — neutral verdict'**
  String get engineReasonNeutral;

  /// No description provided for @engineReasonTransitionWords.
  ///
  /// In en, this message translates to:
  /// **'Frequent use of generic transition words ({words}), averaging {density} per sentence — rarely this dense in human writing'**
  String engineReasonTransitionWords(String words, String density);

  /// No description provided for @engineReasonRepeatedOpeners.
  ///
  /// In en, this message translates to:
  /// **'Multiple adjacent sentences start with the same word ({count} instances) — repetitive sentence structure'**
  String engineReasonRepeatedOpeners(int count);

  /// No description provided for @engineReasonNoStyleMarkers.
  ///
  /// In en, this message translates to:
  /// **'No significant AI writing style patterns detected'**
  String get engineReasonNoStyleMarkers;

  /// No description provided for @engineReasonAdversarialNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'The paraphrase-detection model is not installed; it did not take part in this vote'**
  String get engineReasonAdversarialNotInstalled;

  /// No description provided for @engineReasonTransformerNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'No model is installed or the active model is unsupported; it did not take part in this vote'**
  String get engineReasonTransformerNotInstalled;

  /// No description provided for @engineReasonTransformerLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'The model failed to load and did not take part in this vote ({error})'**
  String engineReasonTransformerLoadFailed(String error);

  /// No description provided for @engineReasonTransformerResult.
  ///
  /// In en, this message translates to:
  /// **'{model} judged {aiCount} of {total} sentences to show AI characteristics'**
  String engineReasonTransformerResult(String model, int aiCount, int total);

  /// No description provided for @engineReasonAdversarialDetected.
  ///
  /// In en, this message translates to:
  /// **'The adversarial model detected likely AI traces scrubbed by a paraphrasing tool (e.g. QuillBot / Undetectable.ai)'**
  String get engineReasonAdversarialDetected;

  /// No description provided for @engineReasonAdversarialClean.
  ///
  /// In en, this message translates to:
  /// **'No clear paraphrase-evasion traces detected'**
  String get engineReasonAdversarialClean;

  /// No description provided for @engineReasonDisabledByUser.
  ///
  /// In en, this message translates to:
  /// **'The user disabled this engine in Settings'**
  String get engineReasonDisabledByUser;

  /// No description provided for @engineReasonGenericNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Model not installed; it did not take part in this vote'**
  String get engineReasonGenericNotInstalled;

  /// No description provided for @patternGenericTransition.
  ///
  /// In en, this message translates to:
  /// **'generic transition word \"{word}\"'**
  String patternGenericTransition(String word);

  /// No description provided for @helpAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get helpAppBarTitle;

  /// No description provided for @helpAboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About TruthLens'**
  String get helpAboutTitle;

  /// No description provided for @helpAboutBody.
  ///
  /// In en, this message translates to:
  /// **'TruthLens is a cross-platform content detection app (iOS / Android / macOS / Windows) whose core AI inference runs entirely on-device. Four independent sub-models — a Transformer neural classifier, statistical analysis, stylometric analysis, and adversarial paraphrase detection — vote together to judge whether text is AI-generated, with sentence-by-sentence, explainable reasoning: not just a \"looks like AI\" percentage, but an explanation of \"why\".'**
  String get helpAboutBody;

  /// No description provided for @helpComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Comparison with leading tools'**
  String get helpComparisonTitle;

  /// No description provided for @helpComparisonDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This comparison is compiled from each tool\'s public information and general market perception, for positioning reference only — not third-party-certified benchmark data.'**
  String get helpComparisonDisclaimer;

  /// No description provided for @helpVsGptZeroTitle.
  ///
  /// In en, this message translates to:
  /// **'vs GPTZero'**
  String get helpVsGptZeroTitle;

  /// No description provided for @helpVsGptZero1.
  ///
  /// In en, this message translates to:
  /// **'GPTZero\'s processing runs mainly in the cloud and requires uploading your document; all four of TruthLens\'s detection engines run on-device.'**
  String get helpVsGptZero1;

  /// No description provided for @helpVsGptZero2.
  ///
  /// In en, this message translates to:
  /// **'GPTZero pioneered Perplexity/Burstiness metrics and sentence highlighting — TruthLens incorporates these and layers on a Transformer classifier, stylometric analysis, and adversarial defense, forming a four-model ensemble vote rather than a single metric.'**
  String get helpVsGptZero2;

  /// No description provided for @helpVsGptZero3.
  ///
  /// In en, this message translates to:
  /// **'GPTZero is subscription-based; TruthLens requires no subscription and has no usage limits.'**
  String get helpVsGptZero3;

  /// No description provided for @helpVsTurnitinTitle.
  ///
  /// In en, this message translates to:
  /// **'vs Turnitin'**
  String get helpVsTurnitinTitle;

  /// No description provided for @helpVsTurnitin1.
  ///
  /// In en, this message translates to:
  /// **'Turnitin is sold only to institutions; individuals cannot purchase it directly. Anyone can install and use TruthLens.'**
  String get helpVsTurnitin1;

  /// No description provided for @helpVsTurnitin2.
  ///
  /// In en, this message translates to:
  /// **'Turnitin\'s decision process is close to a black box; TruthLens provides per-sentence AI probability, matched writing patterns, and a breakdown of each engine\'s score and reasoning.'**
  String get helpVsTurnitin2;

  /// No description provided for @helpVsTurnitin3.
  ///
  /// In en, this message translates to:
  /// **'Turnitin mainly gives a binary \"is it AI\" call; TruthLens supports paragraph/sentence-level human/AI/mixed labeling.'**
  String get helpVsTurnitin3;

  /// No description provided for @helpVsOriginalityTitle.
  ///
  /// In en, this message translates to:
  /// **'vs Originality.ai'**
  String get helpVsOriginalityTitle;

  /// No description provided for @helpVsOriginality1.
  ///
  /// In en, this message translates to:
  /// **'Originality.ai is a per-document subscription that requires uploading your document to the cloud; TruthLens\'s core processing runs on-device with no ongoing subscription needed for detection.'**
  String get helpVsOriginality1;

  /// No description provided for @helpVsOriginality2.
  ///
  /// In en, this message translates to:
  /// **'Originality.ai offers fact-checking and readability analysis concepts; TruthLens echoes this with an on-device stylistic-feature module, and can do basic analysis offline too.'**
  String get helpVsOriginality2;

  /// No description provided for @helpVsCopyleaksTitle.
  ///
  /// In en, this message translates to:
  /// **'vs Copyleaks'**
  String get helpVsCopyleaksTitle;

  /// No description provided for @helpVsCopyleaks1.
  ///
  /// In en, this message translates to:
  /// **'Copyleaks is mainly a cloud API known for low false-positive rates and strong multilingual support; TruthLens adopts the same philosophy with an XLM-RoBERTa multilingual base model and multi-model ensemble voting, but your document content is never uploaded to any server.'**
  String get helpVsCopyleaks1;

  /// No description provided for @helpVsCopyleaks2.
  ///
  /// In en, this message translates to:
  /// **'Copyleaks has API usage limits depending on plan; TruthLens has no usage limits.'**
  String get helpVsCopyleaks2;

  /// No description provided for @helpVsWinstonTitle.
  ///
  /// In en, this message translates to:
  /// **'vs Winston AI'**
  String get helpVsWinstonTitle;

  /// No description provided for @helpVsWinston1.
  ///
  /// In en, this message translates to:
  /// **'Winston AI\'s OCR image recognition requires uploading images to the cloud; TruthLens uses each platform\'s native framework (Vision on iOS/macOS, ML Kit on Android, Windows.Media.Ocr on Windows) to recognize text on-device.'**
  String get helpVsWinston1;

  /// No description provided for @helpVsWinston2.
  ///
  /// In en, this message translates to:
  /// **'Winston AI is known for polished, printable reports; TruthLens generates a dynamic AI-written report layout (falling back to a template if no LLM is installed), exportable as PDF/CSV/JSON/PNG.'**
  String get helpVsWinston2;

  /// No description provided for @helpAdvantagesTitle.
  ///
  /// In en, this message translates to:
  /// **'TruthLens-only advantages'**
  String get helpAdvantagesTitle;

  /// No description provided for @helpAdvantage1.
  ///
  /// In en, this message translates to:
  /// **'Hyperlink authenticity verification: automatically checks whether URLs found in a document are actually reachable; DOI-style academic links are further checked against Crossref\'s public registry to confirm the journal actually indexes that work.'**
  String get helpAdvantage1;

  /// No description provided for @helpAdvantage2.
  ///
  /// In en, this message translates to:
  /// **'Citation authenticity verification: even references with no hyperlink at all (plain \"author-year\" style) can be checked against a bibliographic registry to catch likely-fabricated citations — a common tell of AI hallucination.'**
  String get helpAdvantage2;

  /// No description provided for @helpAdvantage3.
  ///
  /// In en, this message translates to:
  /// **'ESL (non-native writer) bias correction: automatically detects non-native writing characteristics and lowers the statistical model\'s weight, avoiding misjudging natural non-native writing as AI.'**
  String get helpAdvantage3;

  /// No description provided for @helpAdvantage4.
  ///
  /// In en, this message translates to:
  /// **'Custom model import: advanced users can import their own local ONNX model to replace or supplement the built-in detection engines.'**
  String get helpAdvantage4;

  /// No description provided for @helpWorkflowTitle.
  ///
  /// In en, this message translates to:
  /// **'Full operating workflow'**
  String get helpWorkflowTitle;

  /// No description provided for @helpWorkflowStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Model download & update'**
  String get helpWorkflowStep1Title;

  /// No description provided for @helpWorkflowStep1Body.
  ///
  /// In en, this message translates to:
  /// **'First launch guides you through installing the core detection model; afterward you can always check, download, update, or remove models from \"Settings → AI Model Management\". The app proactively checks for the latest version on launch, and shows a badge on the settings icon and the \"AI Model Management\" entry if an update is available.'**
  String get helpWorkflowStep1Body;

  /// No description provided for @helpWorkflowStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Choosing a model (purpose & effect)'**
  String get helpWorkflowStep2Title;

  /// No description provided for @helpWorkflowStep2Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Multilingual AI classifier (40% weight): the main driver of the overall verdict, with sentence-level AI probability prediction — improves accuracy the most.'**
  String get helpWorkflowStep2Bullet1;

  /// No description provided for @helpWorkflowStep2Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Statistical analysis engine (25% weight): sliding-window perplexity and burstiness analysis, capturing the regular rhythm and predictable wording of AI text.'**
  String get helpWorkflowStep2Bullet2;

  /// No description provided for @helpWorkflowStep2Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Stylometric analysis (20% weight): semantic fluency, repeated sentence patterns, transition-word usage — the most explainable, easiest to understand \"why\".'**
  String get helpWorkflowStep2Bullet3;

  /// No description provided for @helpWorkflowStep2Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Adversarial defense (15% weight): detects text that has been washed through a paraphrasing tool (e.g. QuillBot, Undetectable.ai).'**
  String get helpWorkflowStep2Bullet4;

  /// No description provided for @helpWorkflowStep2Bullet5.
  ///
  /// In en, this message translates to:
  /// **'Report-writing LLM (optional): once installed, report text is dynamically written by an on-device LLM; without it, the app falls back to a fixed template — analysis itself is unaffected.'**
  String get helpWorkflowStep2Bullet5;

  /// No description provided for @helpWorkflowStep2Bullet6.
  ///
  /// In en, this message translates to:
  /// **'You can individually enable/disable engines and adjust the AI-detection confidence threshold in Settings (raising it lowers the chance of misjudging human writing as AI).'**
  String get helpWorkflowStep2Bullet6;

  /// No description provided for @helpWorkflowStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Uploading a document'**
  String get helpWorkflowStep3Title;

  /// No description provided for @helpWorkflowStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Three input methods: paste text directly, image OCR (recognized on-device with each platform\'s native framework), or import a file (txt / md / pdf / docx / doc). Text must be at least 40 characters long to submit for analysis.'**
  String get helpWorkflowStep3Body;

  /// No description provided for @helpWorkflowStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Running analysis'**
  String get helpWorkflowStep4Title;

  /// No description provided for @helpWorkflowStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Start Detection\" and all four engines run in parallel, with live progress shown on screen. If non-native writing characteristics are detected, ESL bias correction is applied automatically (can be turned off in Settings).'**
  String get helpWorkflowStep4Body;

  /// No description provided for @helpWorkflowStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Viewing & exporting results'**
  String get helpWorkflowStep5Title;

  /// No description provided for @helpWorkflowStep5Body.
  ///
  /// In en, this message translates to:
  /// **'The report page includes: an overall AI-probability gauge, a sentence-level heatmap, a breakdown of each engine\'s score and reasoning, hyperlink authenticity, and citation authenticity. You can export a full PDF report, per-sentence CSV data, JSON (for system integration), or a PNG summary card (for sharing). Every analysis is automatically saved to \"History\" for later review.'**
  String get helpWorkflowStep5Body;

  /// No description provided for @helpTuningTitle.
  ///
  /// In en, this message translates to:
  /// **'Model download & tuning walkthrough (no experience needed)'**
  String get helpTuningTitle;

  /// No description provided for @helpTuningStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open Model Management'**
  String get helpTuningStep1Title;

  /// No description provided for @helpTuningStep1Body.
  ///
  /// In en, this message translates to:
  /// **'From the home screen, tap the gear icon to open \"Settings\", then tap \"Open\" next to \"AI Model Management\".'**
  String get helpTuningStep1Body;

  /// No description provided for @helpTuningStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Pick a model for your device'**
  String get helpTuningStep2Title;

  /// No description provided for @helpTuningStep2Body.
  ///
  /// In en, this message translates to:
  /// **'The screen automatically suggests a suitable model tier based on your device\'s capability (RAM, CPU cores), and lists every available variant for each role (multilingual classifier / statistical analysis / adversarial defense / report LLM).'**
  String get helpTuningStep2Body;

  /// No description provided for @helpTuningStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Download & apply'**
  String get helpTuningStep3Title;

  /// No description provided for @helpTuningStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Download\" next to the model you want and wait for it to finish — the first model you download is automatically set active. If you have multiple variants installed, tap \"Set active\" to switch anytime; tap the trash icon to remove a model you no longer need to free up space.'**
  String get helpTuningStep3Body;

  /// No description provided for @helpTuningStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Updating a model'**
  String get helpTuningStep4Title;

  /// No description provided for @helpTuningStep4Body.
  ///
  /// In en, this message translates to:
  /// **'When a new version becomes available, \"AI Model Management\" and the settings gear icon show a badge — come back to this screen to see and download the update (the previously installed version is kept unless you remove it manually).'**
  String get helpTuningStep4Body;

  /// No description provided for @helpTuningStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Advanced: importing a custom model'**
  String get helpTuningStep5Title;

  /// No description provided for @helpTuningStep5Body.
  ///
  /// In en, this message translates to:
  /// **'If you already have, or have fine-tuned, a compatible .onnx model elsewhere, you can import it via \"Settings → Custom ONNX model import & test\" — you\'ll need to provide the model file, its matching tokenizer configuration (or choose \"none\"), and the AI class index. Before importing, the app automatically checks whether this exact file was already imported, to avoid accidental duplicates.'**
  String get helpTuningStep5Body;

  /// No description provided for @helpOfficialLinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Official model download links'**
  String get helpOfficialLinksTitle;

  /// No description provided for @helpOfficialLinksHint.
  ///
  /// In en, this message translates to:
  /// **'Tapping an item opens that model\'s official page in your system browser.'**
  String get helpOfficialLinksHint;

  /// No description provided for @helpLinkRoleTransformer.
  ///
  /// In en, this message translates to:
  /// **'Multilingual AI classifier (Transformer, 40% weight)'**
  String get helpLinkRoleTransformer;

  /// No description provided for @helpLinkRoleStatistical.
  ///
  /// In en, this message translates to:
  /// **'Perplexity statistical model (Statistical, 25% weight)'**
  String get helpLinkRoleStatistical;

  /// No description provided for @helpLinkRoleAdversarial.
  ///
  /// In en, this message translates to:
  /// **'Adversarial paraphrase-detection model (Adversarial, 15% weight)'**
  String get helpLinkRoleAdversarial;

  /// No description provided for @helpLinkRoleLlm.
  ///
  /// In en, this message translates to:
  /// **'Report-writing LLM (optional)'**
  String get helpLinkRoleLlm;

  /// No description provided for @privacyAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyAppBarTitle;

  /// No description provided for @privacyPlatformTitle.
  ///
  /// In en, this message translates to:
  /// **'{platform} Privacy Policy'**
  String privacyPlatformTitle(String platform);

  /// No description provided for @privacyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String privacyLastUpdated(String date);

  /// No description provided for @privacyIosOverview1.
  ///
  /// In en, this message translates to:
  /// **'TruthLens does not collect any data linked to your identity, and does not use any data for tracking, so it does not require App Tracking Transparency (ATT) permission.'**
  String get privacyIosOverview1;

  /// No description provided for @privacyIosOverview2.
  ///
  /// In en, this message translates to:
  /// **'This app uses the system file picker to access files or images you actively choose; it cannot access files you haven\'t selected (enforced by the iOS App Sandbox).'**
  String get privacyIosOverview2;

  /// No description provided for @privacyAndroidOverview1.
  ///
  /// In en, this message translates to:
  /// **'TruthLens does not collect personal data and does not share user data with any third party.'**
  String get privacyAndroidOverview1;

  /// No description provided for @privacyAndroidOverview2.
  ///
  /// In en, this message translates to:
  /// **'This app only accesses storage when you actively choose to import a file or image; it does not scan or access other files in the background.'**
  String get privacyAndroidOverview2;

  /// No description provided for @privacyMacosOverview1.
  ///
  /// In en, this message translates to:
  /// **'TruthLens runs under macOS App Sandbox and can only access files you actively selected via the system file dialog (files.user-selected.read-write) — it cannot browse or access any other files or folders on its own.'**
  String get privacyMacosOverview1;

  /// No description provided for @privacyMacosOverview2.
  ///
  /// In en, this message translates to:
  /// **'Network access (network.client) is used only for the necessary connections listed below.'**
  String get privacyMacosOverview2;

  /// No description provided for @privacyWindowsOverview1.
  ///
  /// In en, this message translates to:
  /// **'TruthLens is a standalone desktop app; data is stored in your local user folder (e.g. AppData/Documents) and is never synced to the cloud.'**
  String get privacyWindowsOverview1;

  /// No description provided for @privacyWindowsOverview2.
  ///
  /// In en, this message translates to:
  /// **'This app only accesses files you actively choose to import; it does not scan other files in the background.'**
  String get privacyWindowsOverview2;

  /// No description provided for @privacyDataHandling1.
  ///
  /// In en, this message translates to:
  /// **'TruthLens has no user accounts, requires no sign-in, and contains no advertising or third-party tracking SDKs of any kind.'**
  String get privacyDataHandling1;

  /// No description provided for @privacyDataHandling2.
  ///
  /// In en, this message translates to:
  /// **'Any document content you type, paste, or import is analyzed entirely by on-device AI models on your own device — it is never uploaded to TruthLens or any third-party server.'**
  String get privacyDataHandling2;

  /// No description provided for @privacyDataHandling3.
  ///
  /// In en, this message translates to:
  /// **'Analysis results and history are stored only in a local database on your device; uninstalling the app or clearing history removes them completely — TruthLens keeps no copy anywhere.'**
  String get privacyDataHandling3;

  /// No description provided for @privacyNetworkIntro.
  ///
  /// In en, this message translates to:
  /// **'This app\'s core AI detection runs entirely on-device, but the following three features require network access:'**
  String get privacyNetworkIntro;

  /// No description provided for @privacyNetwork1.
  ///
  /// In en, this message translates to:
  /// **'1. Model catalog & download: connects to GitHub Releases / Hugging Face to download the detection model you chose — this only downloads the model and never uploads any user data.'**
  String get privacyNetwork1;

  /// No description provided for @privacyNetwork2.
  ///
  /// In en, this message translates to:
  /// **'2. Model update check: on launch, the app connects to compare version numbers only, used to indicate whether a new version is available.'**
  String get privacyNetwork2;

  /// No description provided for @privacyNetwork3.
  ///
  /// In en, this message translates to:
  /// **'3. Hyperlink & citation authenticity verification: on by default, can be turned off in Settings. When enabled, URLs or bibliography text detected in a document are sent directly to that URL itself, or to the Crossref public API, sending only the URL/DOI/citation text itself — never the rest of the document\'s content.'**
  String get privacyNetwork3;

  /// No description provided for @privacyRightsIntro.
  ///
  /// In en, this message translates to:
  /// **'You can clear local analysis history anytime in \"History\", or turn off hyperlink/citation verification in \"Settings\", or remove all local data by'**
  String get privacyRightsIntro;

  /// No description provided for @privacyRemoveIos.
  ///
  /// In en, this message translates to:
  /// **'deleting the app'**
  String get privacyRemoveIos;

  /// No description provided for @privacyRemoveAndroid.
  ///
  /// In en, this message translates to:
  /// **'uninstalling the app'**
  String get privacyRemoveAndroid;

  /// No description provided for @privacyRemoveMacos.
  ///
  /// In en, this message translates to:
  /// **'moving the app to the Trash'**
  String get privacyRemoveMacos;

  /// No description provided for @privacyRemoveWindows.
  ///
  /// In en, this message translates to:
  /// **'uninstalling the app'**
  String get privacyRemoveWindows;

  /// No description provided for @privacyDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This page is a privacy explanation TruthLens wrote to reflect its actual functional behavior, not a lawyer-reviewed formal legal document; for a formal compliance review under the laws of your region, please consult independent legal counsel.'**
  String get privacyDisclaimer;

  /// No description provided for @privacySectionOverviewIos.
  ///
  /// In en, this message translates to:
  /// **'Overview (maps to the App Store Privacy \"Nutrition Label\")'**
  String get privacySectionOverviewIos;

  /// No description provided for @privacySectionOverviewAndroid.
  ///
  /// In en, this message translates to:
  /// **'Overview (maps to Google Play\'s \"Data Safety\" disclosure)'**
  String get privacySectionOverviewAndroid;

  /// No description provided for @privacySectionOverviewMacos.
  ///
  /// In en, this message translates to:
  /// **'Overview (App Sandbox permissions)'**
  String get privacySectionOverviewMacos;

  /// No description provided for @privacySectionOverviewWindows.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get privacySectionOverviewWindows;

  /// No description provided for @privacySectionDataHandling.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get privacySectionDataHandling;

  /// No description provided for @privacySectionNetwork.
  ///
  /// In en, this message translates to:
  /// **'Necessary network connections'**
  String get privacySectionNetwork;

  /// No description provided for @privacySectionRights.
  ///
  /// In en, this message translates to:
  /// **'Your rights'**
  String get privacySectionRights;

  /// No description provided for @privacyGenericPlatformName.
  ///
  /// In en, this message translates to:
  /// **'This platform'**
  String get privacyGenericPlatformName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'id',
    'ja',
    'ko',
    'ms',
    'pt',
    'ru',
    'th',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
