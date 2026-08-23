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

  /// No description provided for @commonCopyrightNotice.
  ///
  /// In en, this message translates to:
  /// **'© {year} B&B出版 · E-mail: dr.cobra.lin@gmail.com'**
  String commonCopyrightNotice(Object year);

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

  /// No description provided for @inputPdfOcrProgress.
  ///
  /// In en, this message translates to:
  /// **'PDF text layer is unavailable; recognizing page {page} of {total} with OCR…'**
  String inputPdfOcrProgress(int page, int total);

  /// No description provided for @inputPdfOcrSuccess.
  ///
  /// In en, this message translates to:
  /// **'Imported \"{fileName}\" with PDF OCR ({count} characters)'**
  String inputPdfOcrSuccess(String fileName, int count);

  /// No description provided for @inputPdfNeedsOcr.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" has no reliable text layer. Configure Web OCR or use an installed app with native OCR, then import it again.'**
  String inputPdfNeedsOcr(String fileName);

  /// No description provided for @inputPdfTooManyPages.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" needs OCR but exceeds the {max} page safety limit. Split the PDF and import each part.'**
  String inputPdfTooManyPages(String fileName, int max);

  /// No description provided for @inputPdfUnreadable.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" could not be read reliably. It may be damaged, password-protected, or unsupported by the configured OCR service.'**
  String inputPdfUnreadable(String fileName);

  /// No description provided for @inputDocLegacyUnreadable.
  ///
  /// In en, this message translates to:
  /// **'\"{fileName}\" is a legacy .doc file and its text could not be extracted reliably. In Word, save it as .docx or export it to PDF, then import again.'**
  String inputDocLegacyUnreadable(Object fileName);

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

  /// No description provided for @analysisPreliminaryResult.
  ///
  /// In en, this message translates to:
  /// **'Preliminary result: AI probability {percent}%'**
  String analysisPreliminaryResult(int percent);

  /// No description provided for @analysisPreliminaryResultRefining.
  ///
  /// In en, this message translates to:
  /// **'Preliminary result: AI probability {percent}% (refining…)'**
  String analysisPreliminaryResultRefining(int percent);

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

  /// No description provided for @modelCatalogLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load model catalog'**
  String get modelCatalogLoadFailed;

  /// No description provided for @modelCatalogEmpty.
  ///
  /// In en, this message translates to:
  /// **'No models available'**
  String get modelCatalogEmpty;

  /// No description provided for @modelDownloadPathChip.
  ///
  /// In en, this message translates to:
  /// **'{label} download path'**
  String modelDownloadPathChip(String label);

  /// No description provided for @modelDownloadPathModelFile.
  ///
  /// In en, this message translates to:
  /// **'Model file'**
  String get modelDownloadPathModelFile;

  /// No description provided for @modelDownloadPathCopied.
  ///
  /// In en, this message translates to:
  /// **'Download path copied'**
  String get modelDownloadPathCopied;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save settings: {error}'**
  String settingsSaveFailed(String error);

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

  /// No description provided for @settingsEngineWeightsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI model weights'**
  String get settingsEngineWeightsTitle;

  /// No description provided for @settingsEngineWeightsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set how strongly each engine affects the combined result. The total must equal 100% before saving.'**
  String get settingsEngineWeightsSubtitle;

  /// No description provided for @settingsEngineInfoTooltip.
  ///
  /// In en, this message translates to:
  /// **'What this engine does'**
  String get settingsEngineInfoTooltip;

  /// No description provided for @settingsEngineTransformerHelp.
  ///
  /// In en, this message translates to:
  /// **'Evaluates context-preserving paragraph blocks with a multilingual Transformer model, then maps block scores back to sentences for detailed reporting. Its configured weight controls influence, while its AI signal controls the actual contribution.'**
  String get settingsEngineTransformerHelp;

  /// No description provided for @settingsEngineStatisticalHelp.
  ///
  /// In en, this message translates to:
  /// **'Measures perplexity, predictability, burstiness, and sentence-length variation. Regular text can raise this signal, so ESL correction may reduce its effective weight.'**
  String get settingsEngineStatisticalHelp;

  /// No description provided for @settingsEngineStylometryHelp.
  ///
  /// In en, this message translates to:
  /// **'Checks explainable writing-style markers such as repeated openings, formulaic transitions, and excessive list structure. No matched markers now produce a 0% signal.'**
  String get settingsEngineStylometryHelp;

  /// No description provided for @settingsEngineAdversarialHelp.
  ///
  /// In en, this message translates to:
  /// **'Looks for AI text that may have been paraphrased or processed to hide AI traces. A low score means only weak residual evidence, not a positive detection.'**
  String get settingsEngineAdversarialHelp;

  /// No description provided for @settingsEngineWeightsTotalValid.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}% — ready to save'**
  String settingsEngineWeightsTotalValid(int total);

  /// No description provided for @settingsEngineWeightsTotalInvalid.
  ///
  /// In en, this message translates to:
  /// **'Total: {total}% — adjust to exactly 100%'**
  String settingsEngineWeightsTotalInvalid(int total);

  /// No description provided for @settingsEngineWeightsSave.
  ///
  /// In en, this message translates to:
  /// **'Save weights'**
  String get settingsEngineWeightsSave;

  /// No description provided for @settingsEngineWeightsSaved.
  ///
  /// In en, this message translates to:
  /// **'AI model weights saved on this device'**
  String get settingsEngineWeightsSaved;

  /// No description provided for @settingsEngineWeightsRestoreDefaults.
  ///
  /// In en, this message translates to:
  /// **'Restore defaults'**
  String get settingsEngineWeightsRestoreDefaults;

  /// No description provided for @engineReasonDisabledByUser.
  ///
  /// In en, this message translates to:
  /// **'The user disabled this engine in Settings'**
  String get engineReasonDisabledByUser;

  /// No description provided for @engineReasonTransformerNoStrongSentence.
  ///
  /// In en, this message translates to:
  /// **'{model}: none of {total} sentences crossed the strong-AI threshold; the calibrated weak signal is {percent}%'**
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  );

  /// No description provided for @reportEngineSignalLabel.
  ///
  /// In en, this message translates to:
  /// **'AI signal {percent}%'**
  String reportEngineSignalLabel(int percent);

  /// No description provided for @reportEngineSignalExplanation.
  ///
  /// In en, this message translates to:
  /// **'AI signal is the engine\'s probability for this document; configured weight controls its influence, and contribution points are allocated so their displayed sum exactly matches the overall AI probability. ‘Not detected’ means below the 60% strong-signal threshold, not necessarily mathematically zero.'**
  String get reportEngineSignalExplanation;

  /// No description provided for @engineReasonAdversarialNoStrongSentence.
  ///
  /// In en, this message translates to:
  /// **'None of {total} sentences crossed the strong paraphrase threshold; the calibrated weak signal is {percent}%'**
  String engineReasonAdversarialNoStrongSentence(int total, int percent);

  /// No description provided for @engineReasonAdversarialStrongSentences.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} sentences crossed the strong paraphrase threshold; the calibrated document signal is {percent}%'**
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  );

  /// No description provided for @settingsLinkVerificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Hyperlink & bibliography verification'**
  String get settingsLinkVerificationTitle;

  /// No description provided for @settingsLinkVerificationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The report checks detected URLs and bibliography entries against Crossref, OpenAlex, DataCite, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and recognizable publisher catalogs. Only the URL, DOI, or individual citation fields (author, title, year, and venue) are queried; the rest of the document is not sent. Core AI detection remains on-device, and this verification can be turned off here.'**
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

  /// No description provided for @modelImportWebUnsupported.
  ///
  /// In en, this message translates to:
  /// **'Custom model import is not supported on the web version yet. Please use the app version.'**
  String get modelImportWebUnsupported;

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

  /// No description provided for @reportEngineWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get reportEngineWeightLabel;

  /// No description provided for @privacySealNoticeText.
  ///
  /// In en, this message translates to:
  /// **'TruthLens Zero-Cloud Privacy Audit Seal: Processed 100% on-device without cloud upload or database persistence.'**
  String get privacySealNoticeText;

  /// No description provided for @reportModelCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Model Benchmark Auto-Calibration'**
  String get reportModelCalibrationTitle;

  /// No description provided for @reportCommunityDiscoveredTag.
  ///
  /// In en, this message translates to:
  /// **'Community (HuggingFace)'**
  String get reportCommunityDiscoveredTag;

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

  /// No description provided for @reportEngineLoadFailedBadge.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get reportEngineLoadFailedBadge;

  /// No description provided for @reportEngineAnalysisLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Engine analysis layers'**
  String get reportEngineAnalysisLevelTitle;

  /// No description provided for @reportVerdictAiLikelihood.
  ///
  /// In en, this message translates to:
  /// **'AI Leaning'**
  String get reportVerdictAiLikelihood;

  /// No description provided for @reportVerdictHumanLikelihood.
  ///
  /// In en, this message translates to:
  /// **'Human Writing'**
  String get reportVerdictHumanLikelihood;

  /// No description provided for @reportRadarRoleTransformer.
  ///
  /// In en, this message translates to:
  /// **'Transformer classifier'**
  String get reportRadarRoleTransformer;

  /// No description provided for @reportRadarRoleStatistical.
  ///
  /// In en, this message translates to:
  /// **'Statistical analysis'**
  String get reportRadarRoleStatistical;

  /// No description provided for @reportRadarRoleStylometry.
  ///
  /// In en, this message translates to:
  /// **'Stylometry analysis'**
  String get reportRadarRoleStylometry;

  /// No description provided for @reportRadarRoleAdversarial.
  ///
  /// In en, this message translates to:
  /// **'Adversarial defense'**
  String get reportRadarRoleAdversarial;

  /// No description provided for @reportRadarAxisTransformer.
  ///
  /// In en, this message translates to:
  /// **'Sentence classifier'**
  String get reportRadarAxisTransformer;

  /// No description provided for @reportRadarAxisStatistical.
  ///
  /// In en, this message translates to:
  /// **'Language regularity'**
  String get reportRadarAxisStatistical;

  /// No description provided for @reportRadarAxisStylometry.
  ///
  /// In en, this message translates to:
  /// **'Writing style'**
  String get reportRadarAxisStylometry;

  /// No description provided for @reportRadarAxisAdversarial.
  ///
  /// In en, this message translates to:
  /// **'Rewrite defense'**
  String get reportRadarAxisAdversarial;

  /// No description provided for @reportVerdictBadgeTitle.
  ///
  /// In en, this message translates to:
  /// **'Overall verdict'**
  String get reportVerdictBadgeTitle;

  /// No description provided for @reportVerdictBadgeProbability.
  ///
  /// In en, this message translates to:
  /// **'Overall AI probability {percent}%'**
  String reportVerdictBadgeProbability(int percent);

  /// No description provided for @reportVerdictHintHuman.
  ///
  /// In en, this message translates to:
  /// **'Most engine signals lean toward natural human writing.'**
  String get reportVerdictHintHuman;

  /// No description provided for @reportVerdictHintLikelyHuman.
  ///
  /// In en, this message translates to:
  /// **'Overall leans human, with a small amount of model uncertainty retained.'**
  String get reportVerdictHintLikelyHuman;

  /// No description provided for @reportVerdictHintMixed.
  ///
  /// In en, this message translates to:
  /// **'Engine signals are mixed; read the detailed analysis together with this result.'**
  String get reportVerdictHintMixed;

  /// No description provided for @reportVerdictHintLikelyAi.
  ///
  /// In en, this message translates to:
  /// **'Multiple indicators lean AI; review the high-scoring passages.'**
  String get reportVerdictHintLikelyAi;

  /// No description provided for @reportVerdictHintAi.
  ///
  /// In en, this message translates to:
  /// **'Overall signals strongly lean AI-generated or rewritten.'**
  String get reportVerdictHintAi;

  /// No description provided for @reportSynthesisOverall.
  ///
  /// In en, this message translates to:
  /// **'Overall verdict: {verdict}; overall AI probability {percent}%.'**
  String reportSynthesisOverall(String verdict, int percent);

  /// No description provided for @reportSynthesisStrongestSignal.
  ///
  /// In en, this message translates to:
  /// **'Strongest single signal: {label} ({percent}%), but the final result merges engine weights and is not the conclusion of one engine alone.'**
  String reportSynthesisStrongestSignal(String label, int percent);

  /// No description provided for @reportSynthesisStrongestContribution.
  ///
  /// In en, this message translates to:
  /// **'Largest weighted contribution currently comes from {label} (about {points} percentage points).'**
  String reportSynthesisStrongestContribution(String label, int points);

  /// No description provided for @reportSynthesisStyleCaveat.
  ///
  /// In en, this message translates to:
  /// **'“No obvious AI writing style detected” only means the style engine did not find fixed sentence patterns or transition-word patterns; other models may still raise the overall score through language regularity, sentence classification, or rewrite signals.'**
  String get reportSynthesisStyleCaveat;

  /// No description provided for @reportSynthesisModelGap.
  ///
  /// In en, this message translates to:
  /// **'When some engines did not participate, use “Complete recommended analysis models” in Model Management first; if it still fails, the detailed analysis will state whether the cause is a missing model, unsupported tokenizer, missing file, or Web/ONNX Runtime compatibility limit.'**
  String get reportSynthesisModelGap;

  /// No description provided for @reportEngineRelationshipUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{label} did not participate in this weighted vote, so this dimension is shown as 0%. {hint}'**
  String reportEngineRelationshipUnavailable(String label, String hint);

  /// No description provided for @reportEngineRelationshipAvailable.
  ///
  /// In en, this message translates to:
  /// **'Role weight {weight}%, contributing about {points} percentage points to the overall score{variantText}.'**
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  );

  /// No description provided for @reportEngineVariantMerged.
  ///
  /// In en, this message translates to:
  /// **' (merged {count} model variants)'**
  String reportEngineVariantMerged(int count);

  /// No description provided for @reportEngineFallbackUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{label} did not participate in this vote.'**
  String reportEngineFallbackUnavailable(String label);

  /// No description provided for @reportEngineFallbackAvailable.
  ///
  /// In en, this message translates to:
  /// **'{label} returned no additional text explanation.'**
  String reportEngineFallbackAvailable(String label);

  /// No description provided for @reportEngineResolutionTransformer.
  ///
  /// In en, this message translates to:
  /// **'Fix: download and enable the multilingual Transformer in Model Management; if it is already downloaded, re-download the model and tokenizer.'**
  String get reportEngineResolutionTransformer;

  /// No description provided for @reportEngineResolutionAdversarial.
  ///
  /// In en, this message translates to:
  /// **'Fix: re-download the rewrite detection model and tokenizer in Model Management; on web, update to a version with the BigInt compatibility fix and analyze again.'**
  String get reportEngineResolutionAdversarial;

  /// No description provided for @reportEngineReasonBigInt.
  ///
  /// In en, this message translates to:
  /// **'{reason}. Cause: the web ONNX Runtime returned a BigInt tensor that the older bridge could not convert; update to the fixed build and analyze again.'**
  String reportEngineReasonBigInt(String reason);

  /// No description provided for @reportEngineReasonTokenizer.
  ///
  /// In en, this message translates to:
  /// **'{reason}. Fix: switch to a catalog model, or re-download the model and tokenizer.'**
  String reportEngineReasonTokenizer(String reason);

  /// No description provided for @reportEngineReasonNoActiveTransformer.
  ///
  /// In en, this message translates to:
  /// **'{reason}. Fix: open Model Management, tap “Complete recommended analysis models”, and confirm the multilingual Transformer is marked active.'**
  String reportEngineReasonNoActiveTransformer(String reason);

  /// No description provided for @reportDetailAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Detailed analysis'**
  String get reportDetailAnalysisTitle;

  /// No description provided for @reportNoEngineData.
  ///
  /// In en, this message translates to:
  /// **'No engine analysis data yet'**
  String get reportNoEngineData;

  /// No description provided for @reportEngineNotParticipated.
  ///
  /// In en, this message translates to:
  /// **'Not involved'**
  String get reportEngineNotParticipated;

  /// No description provided for @reportAiContentReportTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Content Detection Report'**
  String get reportAiContentReportTitle;

  /// No description provided for @reportAnalysisTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Analysis time: {time}'**
  String reportAnalysisTimeLabel(String time);

  /// No description provided for @reportDownloadPdfButton.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get reportDownloadPdfButton;

  /// No description provided for @reportSuspiciousLocationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Suspicious content locations'**
  String get reportSuspiciousLocationsTitle;

  /// No description provided for @reportSentenceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sentences'**
  String reportSentenceCount(int count);

  /// No description provided for @reportAiProbabilityPrefix.
  ///
  /// In en, this message translates to:
  /// **'AI probability: '**
  String get reportAiProbabilityPrefix;

  /// No description provided for @helpAdvantage5.
  ///
  /// In en, this message translates to:
  /// **'Document origin forensics: reads the editing record inside .docx / .odt / .doc files — time spent editing, number of saves, how widely the editing batches are spread. That evidence is independent of the text verdict and is shown separately from the AI probability. PDFs and images carry no editing history of their own, so they cannot supply it.'**
  String get helpAdvantage5;

  /// No description provided for @helpAdvantage6.
  ///
  /// In en, this message translates to:
  /// **'It always gives the most likely AI / not-AI direction, while separating that direction from confidence. Short input, silent models, too few engines or sharp disagreement lower confidence instead of erasing the answer.'**
  String get helpAdvantage6;

  /// No description provided for @settingsAiSampleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add a known-AI sample'**
  String get settingsAiSampleTitle;

  /// No description provided for @settingsAiSampleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Background calibration only gathers human samples on its own. To enable learned engine weights you also need pieces known to be AI-generated — paste or import one and it will be analysed and labelled as an AI sample straight away.'**
  String get settingsAiSampleSubtitle;

  /// No description provided for @settingsAiSampleFromClipboard.
  ///
  /// In en, this message translates to:
  /// **'Paste from clipboard'**
  String get settingsAiSampleFromClipboard;

  /// No description provided for @settingsAiSampleFromFile.
  ///
  /// In en, this message translates to:
  /// **'Import a document'**
  String get settingsAiSampleFromFile;

  /// No description provided for @settingsAiSampleAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analysing…'**
  String get settingsAiSampleAnalyzing;

  /// No description provided for @settingsAiSampleAdded.
  ///
  /// In en, this message translates to:
  /// **'AI sample added — {count} in total'**
  String settingsAiSampleAdded(int count);

  /// No description provided for @settingsAiSampleTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short to use as a sample (at least 100 words needed)'**
  String get settingsAiSampleTooShort;

  /// No description provided for @settingsAiSampleFailed.
  ///
  /// In en, this message translates to:
  /// **'No usable content was found'**
  String get settingsAiSampleFailed;

  /// No description provided for @helpFormatCoverageTitle.
  ///
  /// In en, this message translates to:
  /// **'2a. Format limits on origin evidence'**
  String get helpFormatCoverageTitle;

  /// No description provided for @helpFormatCoverage.
  ///
  /// In en, this message translates to:
  /// **'**An important limit: only .docx, .odt and legacy .doc carry an editing record.**\n\n| Source | Editing record |\n|---|---|\n| .docx / .odt | ✅ yes |\n| .pdf | ❌ the format holds no editing history at all |\n| .doc (legacy) | ✅ yes (OLE2 SummaryInformation) |\n| .txt / .md | ❌ no container |\n| Image OCR | ❌ only pixels remain |\n| Pasted text | ❌ no file at all |\n\nThis bears directly on pillar 3: **only documents carrying an editing record are added automatically to the statistically guaranteed baseline.** If everything you receive is PDF, that baseline will never grow — you will only accumulate reference-only samples that carry no guarantee.\n\nTo make origin evidence and automatic calibration actually work, collect .docx or .odt originals rather than printed or exported PDFs. That is a workflow requirement, not something the software can work around: PDF is an output format and simply does not record how the text came to be written.'**
  String get helpFormatCoverage;

  /// No description provided for @provenanceUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'The {format} format does not carry an editing history at all, so this is not a case of the record being wiped — there never was one. Only .docx and .odt record editing time, save counts and editing batches.'**
  String provenanceUnsupportedFormat(String format);

  /// No description provided for @provenanceStripped.
  ///
  /// In en, this message translates to:
  /// **'This format is supported, but no editing record was found in the file. That usually means it was saved as a new file, converted online, or exported from Google Docs — each of which resets the record.'**
  String get provenanceStripped;

  /// No description provided for @provenanceHowToGetRecord.
  ///
  /// In en, this message translates to:
  /// **'To make origin evidence useful, obtain the **original .docx, .odt or .doc file** rather than a printed or exported PDF. Only the original retains the editing history, and only it can be added automatically to the statistically guaranteed baseline.'**
  String get provenanceHowToGetRecord;

  /// No description provided for @calibrationAutoTitle.
  ///
  /// In en, this message translates to:
  /// **'Collecting in the background'**
  String get calibrationAutoTitle;

  /// No description provided for @calibrationAutoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Documents you analyse are added to the baseline automatically — no manual labelling needed.'**
  String get calibrationAutoSubtitle;

  /// No description provided for @calibrationAutoStatus.
  ///
  /// In en, this message translates to:
  /// **'Confirmed human-written by editing record: {auto}; reference-only samples: {observed}'**
  String calibrationAutoStatus(int auto, int observed);

  /// No description provided for @calibrationAutoWhy.
  ///
  /// In en, this message translates to:
  /// **'Only documents carrying an editing record (time spent, number of saves, spread of editing batches) enter the statistically guaranteed baseline, because that evidence is **independent of the text verdict**. Labelling automatically from this tool\'s own verdict would mean marking its own homework — work it wrongly flagged could never enter the baseline, the threshold would tighten with each pass, and more genuine human writing would end up flagged. Pasted text carries no editing record, so it only counts towards the reference percentile below.'**
  String get calibrationAutoWhy;

  /// No description provided for @calibrationObservedPercentile.
  ///
  /// In en, this message translates to:
  /// **'For reference: this score sits at the {percentile}th percentile of the {count} documents you have analysed (no statistical guarantee attached)'**
  String calibrationObservedPercentile(int percentile, int count);

  /// No description provided for @settingsAutoCollectTitle.
  ///
  /// In en, this message translates to:
  /// **'Collect calibration samples in the background'**
  String get settingsAutoCollectTitle;

  /// No description provided for @settingsAutoCollectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds analysed documents to the baseline automatically. Labels come from the document\'s editing record, never from this tool\'s own verdict.'**
  String get settingsAutoCollectSubtitle;

  /// No description provided for @settingsStoreTextTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep the text for offline validation'**
  String get settingsStoreTextTitle;

  /// No description provided for @settingsStoreTextSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When on, pieces you add to the baseline are stored locally with their full text, so you can later export them as a corpus file for offline evaluation.'**
  String get settingsStoreTextSubtitle;

  /// No description provided for @settingsStoreTextWarning.
  ///
  /// In en, this message translates to:
  /// **'That text is usually someone else\'s work and therefore sensitive. Turn this on only while you are actually gathering an offline validation corpus, and use \\u201cClear stored text\\u201d below once you have exported. Clearing does not affect conformal prediction — it only needs the scores.'**
  String get settingsStoreTextWarning;

  /// No description provided for @settingsExportCorpusTitle.
  ///
  /// In en, this message translates to:
  /// **'Export the calibration corpus'**
  String get settingsExportCorpusTitle;

  /// No description provided for @settingsExportCorpusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to export: {human} human, {ai} AI ({required} of each needed for offline evaluation)'**
  String settingsExportCorpusSubtitle(int human, int ai, int required);

  /// No description provided for @settingsExportCorpusButton.
  ///
  /// In en, this message translates to:
  /// **'Export as JSONL'**
  String get settingsExportCorpusButton;

  /// No description provided for @settingsExportCorpusEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export — turn on \\u201ckeep the text\\u201d first, then build up the baseline'**
  String get settingsExportCorpusEmpty;

  /// No description provided for @settingsExportCorpusDone.
  ///
  /// In en, this message translates to:
  /// **'Exported {count} sample(s); skipped {skipped} that had no stored text'**
  String settingsExportCorpusDone(int count, int skipped);

  /// No description provided for @settingsClearStoredText.
  ///
  /// In en, this message translates to:
  /// **'Clear stored text'**
  String get settingsClearStoredText;

  /// No description provided for @settingsClearStoredTextDone.
  ///
  /// In en, this message translates to:
  /// **'All stored text cleared. Scores and calibration are untouched.'**
  String get settingsClearStoredTextDone;

  /// No description provided for @helpDesignTitle.
  ///
  /// In en, this message translates to:
  /// **'Design philosophy and known limits'**
  String get helpDesignTitle;

  /// No description provided for @helpShiftTitle.
  ///
  /// In en, this message translates to:
  /// **'1. The shift: not competing on score accuracy'**
  String get helpShiftTitle;

  /// No description provided for @helpShiftBody.
  ///
  /// In en, this message translates to:
  /// **'Nearly every detector on the market answers the same question: does this text look like it was written by AI?\n\nThat is an arms race you lose. The stronger the model, the closer its output sits to human writing statistically — and paraphrasing tools improve far faster than detectors do. On that road a large server-side model merely loses more slowly.\n\nTruthLens asks a different question: what evidence do we actually hold about how this document came to exist, and how strong is each piece?\n\nThat is a shift from guessing at writing style to weighing origin evidence alongside statistically honest conclusions. It is why this tool deliberately does not chase a place in the single-score accuracy rankings, but lays each piece of evidence out separately and says plainly when it does not know. The real advantage of running in your browser is not inference speed — it is seeing what a server never gets to see: the complete file, and the baseline you collected yourself.'**
  String get helpShiftBody;

  /// No description provided for @helpPillarsTitle.
  ///
  /// In en, this message translates to:
  /// **'2. The five pillars'**
  String get helpPillarsTitle;

  /// No description provided for @helpPillarsBody.
  ///
  /// In en, this message translates to:
  /// **'1. Document origin forensics (live)\nReads the editing record inside DOCX and ODT containers: total editing time, number of saves, creation and modification times, and the editing-batch markers (RSIDs) in the body. One or two RSIDs across a whole essay usually means the text went in all at once; 3,000 words with four minutes of editing is harder evidence than any perplexity score. This counts as origin evidence and is shown separately from the AI probability — deliberately never folded into the score.\n\n2. Local baseline calibration and conformal prediction (live)\nAdd pieces you know the authors wrote themselves, and the system judges against this group\'s own distribution rather than a global threshold. Conformal prediction gives a distribution-free guarantee: provided baseline and tested samples are exchangeable, the false-positive rate stays under the alpha you set. This is the key to cutting misjudgements on non-native writing, and it is something commercial products cannot do — they do not have baseline writing from the people you are assessing.\n\n3. Learned engine weights (live)\nOnce the baseline holds both human and AI samples, the system measures how well each engine separates the two groups (Cohen\'s d effect size) and suggests weights accordingly, replacing the hand-set fixed ratios. Nothing changes until you press Apply — settings are never altered silently.\n\n4. Binoculars cross-perplexity (scoring core done, not yet live)\nRaw perplexity treats how predictable a text is as though that meant how AI-like it is, which is exactly why it produces systematic false positives on plain-spoken non-native writing. Binoculars measures predictability relative to how much two models disagree with each other. The scoring maths is implemented and tested, but switching it on still needs a pair of small language models that can run in a browser, plus validation against labelled data.\n\n5. Watermark detection (checked, not feasible, not built)\nSynthID-Text detection is key-bound: the detector must compute with the same keys used at generation, and Google\'s production keys are not public. Doing this in a browser would never fire on real output from ChatGPT, Claude or Gemini — it would only be a feature that never triggers while leaving you believing watermarks are being checked. So it was deliberately left out.'**
  String get helpPillarsBody;

  /// No description provided for @helpCascadeTitle.
  ///
  /// In en, this message translates to:
  /// **'3. Tiered analysis and integrated assessment'**
  String get helpCascadeTitle;

  /// No description provided for @helpCascadeBody.
  ///
  /// In en, this message translates to:
  /// **'Analysis runs in tiers: document origin, statistical and stylometric features, Transformer sentence classification, then expensive cross-perplexity when needed.\n\nThe six evidence axes remain separate because they answer different questions. The authorship score uses direct text traces and may be reduced by affirmative live-writing, origin, or incremental-draft evidence. Missing citations, task mismatch, bulk paste, sparse revisions, and suspicious metadata remain review concerns but cannot by themselves turn a document into an AI verdict.\n\nConfidence is calculated separately. Fewer than 5 analysable sentences, fewer than 100 words, fewer than 2 engines, silent models or sharp disagreement reduce confidence and trigger a visible limitation warning. The direction remains useful for screening, but low confidence must never be presented as proof.'**
  String get helpCascadeBody;

  /// No description provided for @helpRisksTitle.
  ///
  /// In en, this message translates to:
  /// **'4. Risks worth facing honestly'**
  String get helpRisksTitle;

  /// No description provided for @helpRisksBody.
  ///
  /// In en, this message translates to:
  /// **'Every item below is a real limitation of this tool. Please weigh them before acting on anything it reports.\n\n1. Origin evidence can be wiped or faked\nSaving as a new file, converting online, exporting from Google Docs, or copying into a fresh document all reset the editing record. A signal here is supporting evidence only, and the absence of one certainly does not prove a person wrote it.\n\n2. The conformal guarantee rests on exchangeability\nIt holds only if the baseline samples and the text under test come from the same group of people doing the same kind of writing task. If an author\'s writing has clearly improved, or the kind of task has changed entirely, the premise fails and the baseline needs rebuilding.\n\n3. The baseline itself can be contaminated\nIf the work you used as a baseline was in fact ghost-written by AI, the whole calibration skews. Baseline samples must be gathered under controlled conditions — work produced under supervision, for instance.\n\n4. Small in-browser models are less accurate than large server-side ones\nThat is the unavoidable price the Web-only decision pays for privacy. This tool\'s value is not a magically accurate score, but an explainable direction with explicit confidence and evidence limitations.\n\n5. No score should ever stand alone as grounds for an accusation\nAlways read it alongside the sentence-level evidence, the document\'s origin, and what you already know about this particular author. This tool is designed to support a conversation you have, not to deliver a verdict in your place.'**
  String get helpRisksBody;

  /// No description provided for @calibrationAddHuman.
  ///
  /// In en, this message translates to:
  /// **'Add as human-written baseline'**
  String get calibrationAddHuman;

  /// No description provided for @calibrationAddAi.
  ///
  /// In en, this message translates to:
  /// **'Add as known-AI sample'**
  String get calibrationAddAi;

  /// No description provided for @calibrationCounts.
  ///
  /// In en, this message translates to:
  /// **'Baseline: {human} human, {ai} AI'**
  String calibrationCounts(int human, int ai);

  /// No description provided for @learnedWeightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Learned engine weights'**
  String get learnedWeightsTitle;

  /// No description provided for @learnedWeightsNeedMore.
  ///
  /// In en, this message translates to:
  /// **'You have {human} human and {ai} AI samples. Each class needs at least {required} before weights can be learned reliably; until then your manual weights stay in force.'**
  String learnedWeightsNeedMore(int human, int ai, int required);

  /// No description provided for @learnedWeightsReady.
  ///
  /// In en, this message translates to:
  /// **'Weights can now be learned from your {human} human and {ai} AI samples.'**
  String learnedWeightsReady(int human, int ai);

  /// No description provided for @learnedWeightsRow.
  ///
  /// In en, this message translates to:
  /// **'{engine}: suggested weight {weight}% (separation {effect})'**
  String learnedWeightsRow(String engine, int weight, String effect);

  /// No description provided for @learnedWeightsReversed.
  ///
  /// In en, this message translates to:
  /// **'Note: {engine} has the two groups the wrong way round — the AI samples scored lower, not higher — so its weight drops to zero. That usually means the engine does not suit this kind of text.'**
  String learnedWeightsReversed(String engine);

  /// No description provided for @learnedWeightsApply.
  ///
  /// In en, this message translates to:
  /// **'Apply the learned weights'**
  String get learnedWeightsApply;

  /// No description provided for @learnedWeightsApplied.
  ///
  /// In en, this message translates to:
  /// **'Learned weights applied'**
  String get learnedWeightsApplied;

  /// No description provided for @learnedWeightsExplain.
  ///
  /// In en, this message translates to:
  /// **'Weights come from how well each engine separates your human samples from your AI ones (Cohen\'s d effect size): the further apart the two groups, and the steadier each group is, the more weight that engine earns. This replaces the hand-set fixed weights so the ensemble fits the kind of text you actually work with.'**
  String get learnedWeightsExplain;

  /// No description provided for @calibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Local baseline calibration'**
  String get calibrationTitle;

  /// No description provided for @calibrationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No baseline set yet. Add a handful of pieces you know the authors wrote themselves — work produced under supervision, for instance — and the system can judge against this group\'s own distribution instead of a one-size-fits-all global threshold. That is exactly what brings down false positives on non-native writing.'**
  String get calibrationEmpty;

  /// No description provided for @calibrationNotEnough.
  ///
  /// In en, this message translates to:
  /// **'The baseline holds {count} sample(s); making a {alpha}% false-positive ceiling actually hold needs at least {required}. Until then the figures are shown for reference only and nothing gets flagged on their basis.'**
  String calibrationNotEnough(int count, int required, int alpha);

  /// No description provided for @calibrationFlagged.
  ///
  /// In en, this message translates to:
  /// **'At a {alpha}% false-positive ceiling, this text **is flagged**.'**
  String calibrationFlagged(int alpha);

  /// No description provided for @calibrationNotFlagged.
  ///
  /// In en, this message translates to:
  /// **'At a {alpha}% false-positive ceiling, this text **is not flagged**.'**
  String calibrationNotFlagged(int alpha);

  /// No description provided for @calibrationPValue.
  ///
  /// In en, this message translates to:
  /// **'Conservative p-value {value} (against {count} baseline samples)'**
  String calibrationPValue(String value, int count);

  /// No description provided for @calibrationPercentile.
  ///
  /// In en, this message translates to:
  /// **'The score sits at the {percentile}th percentile of the baseline'**
  String calibrationPercentile(int percentile);

  /// No description provided for @calibrationCaveat.
  ///
  /// In en, this message translates to:
  /// **'This guarantee rests on the baseline samples and the text under test being exchangeable — same group of people, same kind of writing task. If an author\'s writing has clearly improved, or the kind of task has changed entirely, that no longer holds and the baseline needs rebuilding. Note too: if the baseline pieces were themselves ghost-written by AI, the whole calibration skews, so collect them under controlled conditions.'**
  String get calibrationCaveat;

  /// No description provided for @calibrationAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add this to the baseline'**
  String get calibrationAddButton;

  /// No description provided for @calibrationAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to the baseline — {count} sample(s) now'**
  String calibrationAdded(int count);

  /// No description provided for @settingsCalibrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Local baseline set'**
  String get settingsCalibrationTitle;

  /// No description provided for @settingsCalibrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} sample(s) held ({required} needed at this α)'**
  String settingsCalibrationSubtitle(int count, int required);

  /// No description provided for @settingsCalibrationClear.
  ///
  /// In en, this message translates to:
  /// **'Clear the baseline set'**
  String get settingsCalibrationClear;

  /// No description provided for @settingsCalibrationCleared.
  ///
  /// In en, this message translates to:
  /// **'Baseline set cleared'**
  String get settingsCalibrationCleared;

  /// No description provided for @settingsAlphaTitle.
  ///
  /// In en, this message translates to:
  /// **'False-positive ceiling (α)'**
  String get settingsAlphaTitle;

  /// No description provided for @settingsAlphaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Currently {alpha}% — lower is stricter but needs more baseline samples (at least {required})'**
  String settingsAlphaSubtitle(int alpha, int required);

  /// No description provided for @abstentionHeadline.
  ///
  /// In en, this message translates to:
  /// **'Not enough evidence to judge'**
  String get abstentionHeadline;

  /// No description provided for @abstentionTooFewSentences.
  ///
  /// In en, this message translates to:
  /// **'Only {count} analysable sentence(s), where at least {required} are needed. At this length the statistical and sentence-level signals carry no weight, and forcing a score out of them would only mislead.'**
  String abstentionTooFewSentences(int count, int required);

  /// No description provided for @abstentionTooFewWords.
  ///
  /// In en, this message translates to:
  /// **'The text runs to {count} words, where at least {required} are needed. Below that, any writing trait could just be chance.'**
  String abstentionTooFewWords(int count, int required);

  /// No description provided for @abstentionTooFewEngines.
  ///
  /// In en, this message translates to:
  /// **'Only {available} of {total} engines took part, so nothing can be cross-checked from a second angle. Fill in the missing models under model management and run it again.'**
  String abstentionTooFewEngines(int available, int total);

  /// No description provided for @abstentionEnginesConflict.
  ///
  /// In en, this message translates to:
  /// **'The engines are {spread} percentage points apart — far enough that averaging them stops meaning anything. Read the sentence evidence and the document\'s origin instead, and judge for yourself.'**
  String abstentionEnginesConflict(int spread);

  /// No description provided for @abstentionNoEvidenceFound.
  ///
  /// In en, this message translates to:
  /// **'All engines ran, but none found usable evidence. The low fallback score is diagnostic output, not evidence that a person wrote the text.'**
  String get abstentionNoEvidenceFound;

  /// No description provided for @abstentionSingleWeakEvidenceSource.
  ///
  /// In en, this message translates to:
  /// **'Only {count} engine found usable evidence, and the overall score is still below the AI threshold. Treat this as weak coverage, not as evidence that a person wrote it.'**
  String abstentionSingleWeakEvidenceSource(int count);

  /// No description provided for @abstentionScoreStillShown.
  ///
  /// In en, this message translates to:
  /// **'The full score and sentence evidence are still shown below for your own reference. Please don\'t treat them as a conclusion.'**
  String get abstentionScoreStillShown;

  /// No description provided for @provenanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Document origin evidence'**
  String get provenanceTitle;

  /// No description provided for @provenanceRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'Editing history is clearly unusual'**
  String get provenanceRiskHigh;

  /// No description provided for @provenanceRiskMedium.
  ///
  /// In en, this message translates to:
  /// **'Editing history has something odd about it'**
  String get provenanceRiskMedium;

  /// No description provided for @provenanceRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Editing history looks normal'**
  String get provenanceRiskLow;

  /// No description provided for @provenanceRiskUnknown.
  ///
  /// In en, this message translates to:
  /// **'No editing history available'**
  String get provenanceRiskUnknown;

  /// No description provided for @provenanceNoMetadata.
  ///
  /// In en, this message translates to:
  /// **'This input carries no editing history — pasted text, a PDF, or a file whose record was stripped. There is nothing to judge from origin here, only the text analysis itself.'**
  String get provenanceNoMetadata;

  /// No description provided for @provenanceEditingDuration.
  ///
  /// In en, this message translates to:
  /// **'Editing time recorded in the file: {minutes} minutes'**
  String provenanceEditingDuration(int minutes);

  /// No description provided for @provenanceRevisionCount.
  ///
  /// In en, this message translates to:
  /// **'Times saved: {count}'**
  String provenanceRevisionCount(int count);

  /// No description provided for @provenanceApplication.
  ///
  /// In en, this message translates to:
  /// **'Produced with: {name}'**
  String provenanceApplication(String name);

  /// No description provided for @provenanceSignalSingleSession.
  ///
  /// In en, this message translates to:
  /// **'The body carries only {count} editing-batch marker(s) for {words} words. Writing as you think normally leaves dozens; this much concentration usually means the text went in all at once — pasted, for instance.'**
  String provenanceSignalSingleSession(int count, int words);

  /// No description provided for @provenanceSignalTypingSpeed.
  ///
  /// In en, this message translates to:
  /// **'{words} words against {minutes} minutes of recorded editing works out to {wpm} words per minute, far above what anyone sustains while actually writing.'**
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm);

  /// No description provided for @provenanceSignalNoEditingTime.
  ///
  /// In en, this message translates to:
  /// **'The file records almost no editing time at all, yet the body runs to {words} words.'**
  String provenanceSignalNoEditingTime(int words);

  /// No description provided for @provenanceSignalFewRevisions.
  ///
  /// In en, this message translates to:
  /// **'{words} words of content, saved only {count} time(s).'**
  String provenanceSignalFewRevisions(int count, int words);

  /// No description provided for @provenanceCaveat.
  ///
  /// In en, this message translates to:
  /// **'Worth knowing: these records can be wiped or reset — saving as a new file, converting online, exporting from Google Docs, or copying into a fresh document all zero them out. So a signal here is supporting evidence, never a conclusion on its own; and the absence of one does not prove a person wrote it.'**
  String get provenanceCaveat;

  /// No description provided for @telemetrySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'What this adds up to'**
  String get telemetrySummaryTitle;

  /// No description provided for @telemetrySummaryVerdict.
  ///
  /// In en, this message translates to:
  /// **'{engines} of {total} engines finished. Overall AI probability is {percent}%, which lands on “{verdict}”.'**
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  );

  /// No description provided for @telemetrySummaryAgreement.
  ///
  /// In en, this message translates to:
  /// **'The engines broadly agree — the highest read {high}% and the lowest {low}% — so this conclusion holds up well.'**
  String telemetrySummaryAgreement(int high, int low);

  /// No description provided for @telemetrySummaryDisagreement.
  ///
  /// In en, this message translates to:
  /// **'The engines disagree: {highLabel} read {high}% while {lowLabel} read only {low}%. When that happens, don\'t lean on the headline score — the sentence-level evidence below tells you much more.'**
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  );

  /// No description provided for @telemetrySummaryDriver.
  ///
  /// In en, this message translates to:
  /// **'Most of the score comes from {label}, worth about {points} percentage points.'**
  String telemetrySummaryDriver(String label, int points);

  /// No description provided for @telemetrySummarySentencesNone.
  ///
  /// In en, this message translates to:
  /// **'Across all {total} sentences, not one crossed the strong-AI line.'**
  String telemetrySummarySentencesNone(int total);

  /// No description provided for @telemetrySummarySentencesSome.
  ///
  /// In en, this message translates to:
  /// **'Of {total} sentences, {count} crossed the strong-AI line — worth reading through one by one.'**
  String telemetrySummarySentencesSome(int count, int total);

  /// No description provided for @telemetrySummaryAdviceHuman.
  ///
  /// In en, this message translates to:
  /// **'It reads like something a person actually wrote, with nothing that needs chasing down.'**
  String get telemetrySummaryAdviceHuman;

  /// No description provided for @telemetrySummaryAdviceMixed.
  ///
  /// In en, this message translates to:
  /// **'This one sits in the grey zone. The score alone isn\'t enough to call it — read it alongside the sentence evidence and whatever you know about where the document came from.'**
  String get telemetrySummaryAdviceMixed;

  /// No description provided for @telemetrySummaryAdviceAi.
  ///
  /// In en, this message translates to:
  /// **'The signals point clearly at AI generation or rewriting. Check the flagged sentences one by one before you decide.'**
  String get telemetrySummaryAdviceAi;

  /// No description provided for @telemetrySummaryModelGap.
  ///
  /// In en, this message translates to:
  /// **'{count} engine(s) sat this one out, so take the confidence with a pinch of salt — fill them in under model management and re-run for a sharper read.'**
  String telemetrySummaryModelGap(int count);

  /// No description provided for @reportVerdictRangeBelow.
  ///
  /// In en, this message translates to:
  /// **'AI probability < {value}%'**
  String reportVerdictRangeBelow(int value);

  /// No description provided for @reportVerdictRangeBetween.
  ///
  /// In en, this message translates to:
  /// **'AI probability {low}%–{high}%'**
  String reportVerdictRangeBetween(int low, int high);

  /// No description provided for @reportVerdictRangeAbove.
  ///
  /// In en, this message translates to:
  /// **'AI probability ≥ {value}%'**
  String reportVerdictRangeAbove(int value);

  /// No description provided for @reportConfidenceLowTooltip.
  ///
  /// In en, this message translates to:
  /// **'Low confidence: available model weight is below 60% ({threshold}% threshold). {available}/{total} engines participated. Review detailed engine analysis.'**
  String reportConfidenceLowTooltip(int threshold, int available, int total);

  /// No description provided for @reportConfidenceHighTooltip.
  ///
  /// In en, this message translates to:
  /// **'High confidence: {available}/{total} detection models reached consensus ({threshold}% or more weight agrees with this verdict).'**
  String reportConfidenceHighTooltip(int available, int total, int threshold);

  /// No description provided for @reportConfidenceLowBadge.
  ///
  /// In en, this message translates to:
  /// **'Low confidence ({available}/{total})'**
  String reportConfidenceLowBadge(int available, int total);

  /// No description provided for @reportConfidenceHighBadge.
  ///
  /// In en, this message translates to:
  /// **'High confidence ({available}/{total})'**
  String reportConfidenceHighBadge(int available, int total);

  /// No description provided for @reportMetricAiSentenceRatio.
  ///
  /// In en, this message translates to:
  /// **'Strong AI-signal sentence ratio'**
  String get reportMetricAiSentenceRatio;

  /// No description provided for @reportStrongAiSentenceCount.
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} crossed the 60% strong-signal threshold'**
  String reportStrongAiSentenceCount(int count, int total);

  /// No description provided for @reportMetricElapsed.
  ///
  /// In en, this message translates to:
  /// **'Analysis time'**
  String get reportMetricElapsed;

  /// No description provided for @reportMetricElapsedNormal.
  ///
  /// In en, this message translates to:
  /// **'0.5-5s normal'**
  String get reportMetricElapsedNormal;

  /// No description provided for @reportMetricReliability.
  ///
  /// In en, this message translates to:
  /// **'Reliability'**
  String get reportMetricReliability;

  /// No description provided for @reportReliabilityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get reportReliabilityLow;

  /// No description provided for @reportReliabilityHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get reportReliabilityHigh;

  /// No description provided for @reportReliabilityNeedsReview.
  ///
  /// In en, this message translates to:
  /// **'Needs review'**
  String get reportReliabilityNeedsReview;

  /// No description provided for @reportReliabilityHighTrust.
  ///
  /// In en, this message translates to:
  /// **'Highly reliable'**
  String get reportReliabilityHighTrust;

  /// No description provided for @reportSentenceAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Sentence-level analysis'**
  String get reportSentenceAnalysisTitle;

  /// No description provided for @suspiciousFilterAll.
  ///
  /// In en, this message translates to:
  /// **'Suspicious'**
  String get suspiciousFilterAll;

  /// No description provided for @suspiciousFilterHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get suspiciousFilterHigh;

  /// No description provided for @suspiciousFilterMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get suspiciousFilterMedium;

  /// No description provided for @suspiciousExcludedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Single letters, page numbers, section numbers, and overly short OCR/PDF fragments have been excluded.'**
  String get suspiciousExcludedTooltip;

  /// No description provided for @suspiciousCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String suspiciousCount(int count);

  /// No description provided for @suspiciousEmpty.
  ///
  /// In en, this message translates to:
  /// **'No suspicious content'**
  String get suspiciousEmpty;

  /// No description provided for @suspiciousRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get suspiciousRiskHigh;

  /// No description provided for @suspiciousRiskMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get suspiciousRiskMedium;

  /// No description provided for @suspiciousReasonHighModelSignals.
  ///
  /// In en, this message translates to:
  /// **'Multiple model signals strongly lean AI'**
  String get suspiciousReasonHighModelSignals;

  /// No description provided for @suspiciousReasonSentenceSignal.
  ///
  /// In en, this message translates to:
  /// **'Sentence-level model signal is elevated'**
  String get suspiciousReasonSentenceSignal;

  /// No description provided for @suspiciousOriginalLocation.
  ///
  /// In en, this message translates to:
  /// **'Original location {location}'**
  String suspiciousOriginalLocation(String location);

  /// No description provided for @suspiciousOriginalLocationWithReason.
  ///
  /// In en, this message translates to:
  /// **'Original location {location} · {reason}'**
  String suspiciousOriginalLocationWithReason(String location, String reason);

  /// No description provided for @suspiciousSentenceNumber.
  ///
  /// In en, this message translates to:
  /// **'Sentence #{number}'**
  String suspiciousSentenceNumber(int number);

  /// No description provided for @suspiciousEvidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Evidence:'**
  String get suspiciousEvidenceLabel;

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
  /// **'Could not verify (timed out or no response from bibliographic services)'**
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

  /// No description provided for @reportBibRecheckAllUnreliableButton.
  ///
  /// In en, this message translates to:
  /// **'Recheck all unverified citations'**
  String get reportBibRecheckAllUnreliableButton;

  /// No description provided for @reportBibRecheckOneTooltip.
  ///
  /// In en, this message translates to:
  /// **'Recheck this citation'**
  String get reportBibRecheckOneTooltip;

  /// No description provided for @reportBibResultHint.
  ///
  /// In en, this message translates to:
  /// **'Matched by author, year, title, and venue across Crossref, OpenAlex, DataCite, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and recognizable publisher catalogs. A high-confidence result requires a DOI registration or multiple consistent metadata fields; entries without a reliable match are marked as not verified. Google Scholar is available only as a user-initiated manual lookup because it does not provide automated API access.'**
  String get reportBibResultHint;

  /// No description provided for @reportBibVerificationSource.
  ///
  /// In en, this message translates to:
  /// **'Verification source: {source}'**
  String reportBibVerificationSource(String source);

  /// No description provided for @reportBibGoogleScholarManualLookup.
  ///
  /// In en, this message translates to:
  /// **'Check manually in Google Scholar'**
  String get reportBibGoogleScholarManualLookup;

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

  /// No description provided for @reportBibJournalMismatch.
  ///
  /// In en, this message translates to:
  /// **'Journal name mismatch: the document says “{reported}”, while the verified registry says “{registered}”. Please review this citation.'**
  String reportBibJournalMismatch(String reported, String registered);

  /// No description provided for @reportBibNotFound.
  ///
  /// In en, this message translates to:
  /// **'No close match found — possibly a fabricated reference'**
  String get reportBibNotFound;

  /// No description provided for @reportBibUncertain.
  ///
  /// In en, this message translates to:
  /// **'Suspect: not verified by registry match'**
  String get reportBibUncertain;

  /// No description provided for @reportBibTruncated.
  ///
  /// In en, this message translates to:
  /// **'All detected entries are verified with live progress (detected {count} total)'**
  String reportBibTruncated(int max, int count);

  /// No description provided for @reportBibCompletedPreview.
  ///
  /// In en, this message translates to:
  /// **'{count} completed; results will keep updating.'**
  String reportBibCompletedPreview(int count);

  /// No description provided for @reportBibProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress {completed}/{total}, {current}'**
  String reportBibProgress(int completed, int total, String current);

  /// No description provided for @reportBibProgressCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current: {text}'**
  String reportBibProgressCurrent(String text);

  /// No description provided for @reportBibProgressFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finalizing results'**
  String get reportBibProgressFinalizing;

  /// No description provided for @reportBibUncertainWithCandidate.
  ///
  /// In en, this message translates to:
  /// **'{base}: similar candidate found “{candidate}”, but author, year, or title did not meet the reliable-match threshold.'**
  String reportBibUncertainWithCandidate(String base, String candidate);

  /// No description provided for @reportBibUncertainNoReliableResponse.
  ///
  /// In en, this message translates to:
  /// **'{base}: verification sources returned no reliable response or the entry lacks enough information; TruthLens does not treat this citation as verified.'**
  String reportBibUncertainNoReliableResponse(String base);

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
  /// **'This text is more likely AI-generated; further review is recommended (integrated AI likelihood {percent}%)'**
  String composerHeadlineLikelyAi(int percent);

  /// No description provided for @composerHeadlineMixed.
  ///
  /// In en, this message translates to:
  /// **'This text shows a mix of human and AI characteristics (AI probability {percent}%)'**
  String composerHeadlineMixed(int percent);

  /// No description provided for @composerHeadlineLikelyHuman.
  ///
  /// In en, this message translates to:
  /// **'This text is more likely not AI-generated (integrated AI likelihood {percent}%)'**
  String composerHeadlineLikelyHuman(int percent);

  /// No description provided for @composerHeadlineHuman.
  ///
  /// In en, this message translates to:
  /// **'This text is very likely human-written (AI probability {percent}%)'**
  String composerHeadlineHuman(int percent);

  /// No description provided for @composerThresholdFlagged.
  ///
  /// In en, this message translates to:
  /// **'The overall AI probability exceeds the fixed {percent}% threshold and is flagged as AI.'**
  String composerThresholdFlagged(int percent);

  /// No description provided for @composerThresholdNotFlagged.
  ///
  /// In en, this message translates to:
  /// **'The overall AI probability is below the fixed {percent}% flagging threshold.'**
  String composerThresholdNotFlagged(int percent);

  /// No description provided for @composerThresholdFlaggedDetailed.
  ///
  /// In en, this message translates to:
  /// **'Overall AI probability is {aiPercent}%, which reaches the fixed {thresholdPercent}% AI flagging threshold, so the report marks this text as AI. Review sentence evidence and engine reasons before making a final decision.'**
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent);

  /// No description provided for @composerThresholdNotFlaggedDetailed.
  ///
  /// In en, this message translates to:
  /// **'Overall AI probability is {aiPercent}%, below the fixed {thresholdPercent}% AI flagging threshold, so the report does not formally mark this text as AI. The probability and evidence are still shown for review.'**
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  );

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
  /// **'Low language-model perplexity ({ppl}) [AI-leaning], text is highly predictable'**
  String engineReasonPplLow(String ppl);

  /// No description provided for @engineReasonPplHigh.
  ///
  /// In en, this message translates to:
  /// **'High language-model perplexity ({ppl}) [Human-leaning], consistent with human writing variety'**
  String engineReasonPplHigh(String ppl);

  /// No description provided for @engineReasonPplMid.
  ///
  /// In en, this message translates to:
  /// **'Moderate language-model perplexity ({ppl}) [Neutral]'**
  String engineReasonPplMid(String ppl);

  /// No description provided for @engineReasonBurstinessLow.
  ///
  /// In en, this message translates to:
  /// **'Highly uniform sentence length (burstiness {value}) [AI-leaning], repetitive rhythm'**
  String engineReasonBurstinessLow(String value);

  /// No description provided for @engineReasonBurstinessHigh.
  ///
  /// In en, this message translates to:
  /// **'Noticeable variation in sentence length (burstiness {value}) [Human-leaning], dynamic rhythm'**
  String engineReasonBurstinessHigh(String value);

  /// No description provided for @engineReasonTtrLow.
  ///
  /// In en, this message translates to:
  /// **'Low vocabulary diversity (TTR {value}) [AI-leaning template pattern]'**
  String engineReasonTtrLow(String value);

  /// No description provided for @engineReasonTtrHigh.
  ///
  /// In en, this message translates to:
  /// **'High vocabulary diversity (TTR {value}) [Human-leaning]'**
  String engineReasonTtrHigh(String value);

  /// No description provided for @engineReasonStatisticalSummaryAi.
  ///
  /// In en, this message translates to:
  /// **'Overall statistical summary: Leans towards AI-generated characteristics ({percent}% AI probability)'**
  String engineReasonStatisticalSummaryAi(String percent);

  /// No description provided for @engineReasonStatisticalSummaryHuman.
  ///
  /// In en, this message translates to:
  /// **'Overall statistical summary: Leans towards human natural writing ({percent}% AI probability)'**
  String engineReasonStatisticalSummaryHuman(String percent);

  /// No description provided for @engineReasonStatisticalSummaryNeutral.
  ///
  /// In en, this message translates to:
  /// **'Overall statistical summary: Indicators balance out, showing neutral characteristics ({percent}% AI probability)'**
  String engineReasonStatisticalSummaryNeutral(String percent);

  /// No description provided for @reportFormulaTitle.
  ///
  /// In en, this message translates to:
  /// **'Weighted Calculation Transparency & Parameter Breakdown'**
  String get reportFormulaTitle;

  /// No description provided for @reportFormulaExplanation.
  ///
  /// In en, this message translates to:
  /// **'The overall AI probability is computed as a weighted average of probabilities from all active engines:'**
  String get reportFormulaExplanation;

  /// No description provided for @reportFormulaActiveEngines.
  ///
  /// In en, this message translates to:
  /// **'Active Engines & Assigned Weights'**
  String get reportFormulaActiveEngines;

  /// No description provided for @reportFormulaCalculation.
  ///
  /// In en, this message translates to:
  /// **'Weighted Formula Calculation'**
  String get reportFormulaCalculation;

  /// No description provided for @reportFormulaFinalResult.
  ///
  /// In en, this message translates to:
  /// **'Final Weighted AI Probability'**
  String get reportFormulaFinalResult;

  /// No description provided for @reportFormulaEslApplied.
  ///
  /// In en, this message translates to:
  /// **'ESL non-native writing adjustment applied (statistical model weight halved)'**
  String get reportFormulaEslApplied;

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

  /// No description provided for @engineReasonAssistantResponseArtifact.
  ///
  /// In en, this message translates to:
  /// **'Detected {count} conversational assistant-response artifact(s), such as addressing the requester or offering to revise the requested text'**
  String engineReasonAssistantResponseArtifact(int count);

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

  /// No description provided for @modelRepairNoActiveVariant.
  ///
  /// In en, this message translates to:
  /// **'No active model found; download a recommended model in Model Management.'**
  String get modelRepairNoActiveVariant;

  /// No description provided for @modelRepairCustomRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed the custom model that failed to load. Custom models cannot be re-downloaded automatically; please re-import the model and tokenizer.'**
  String get modelRepairCustomRemoved;

  /// No description provided for @modelRepairNoSource.
  ///
  /// In en, this message translates to:
  /// **'Removed the model file that failed to load, but no catalog source is currently available to re-download it; please re-download a recommended model in Model Management.'**
  String get modelRepairNoSource;

  /// No description provided for @modelRepairRedownloaded.
  ///
  /// In en, this message translates to:
  /// **'Detected that the model file may be corrupted or incompatible; automatically re-downloaded {name}. Please run the analysis again.'**
  String modelRepairRedownloaded(Object name);

  /// No description provided for @modelRepairRedownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Removed the model file that failed to load, but the automatic re-download did not complete; please check your network connection and re-download {name} in Model Management.'**
  String modelRepairRedownloadFailed(Object name);

  /// No description provided for @engineTransformerNoActiveVariant.
  ///
  /// In en, this message translates to:
  /// **'No active Transformer model found; download one or set it active in Model Management'**
  String get engineTransformerNoActiveVariant;

  /// No description provided for @engineTransformerUnsupportedTokenizer.
  ///
  /// In en, this message translates to:
  /// **'The active model\'s tokenizer type is not supported ({tokenizer}); switch to a model that supports bert-wordpiece or roberta-bpe'**
  String engineTransformerUnsupportedTokenizer(Object tokenizer);

  /// No description provided for @engineTransformerMissingPaths.
  ///
  /// In en, this message translates to:
  /// **'Transformer model or tokenizer path is missing; re-download in Model Management'**
  String get engineTransformerMissingPaths;

  /// No description provided for @engineTransformerMissingFiles.
  ///
  /// In en, this message translates to:
  /// **'Transformer model or tokenizer file does not exist; re-download in Model Management'**
  String get engineTransformerMissingFiles;

  /// No description provided for @engineTransformerOpsetUnsupported.
  ///
  /// In en, this message translates to:
  /// **'ONNX opset version is not supported (this model version is too new; update the app): {variantId}'**
  String engineTransformerOpsetUnsupported(Object variantId);

  /// No description provided for @engineTransformerTokenizerCorrupt.
  ///
  /// In en, this message translates to:
  /// **'Tokenizer format is corrupted: {message}'**
  String engineTransformerTokenizerCorrupt(Object message);

  /// No description provided for @engineTransformerRepairFailed.
  ///
  /// In en, this message translates to:
  /// **'Model loading or inference failed, and automatic repair did not complete; re-download the active Transformer model and tokenizer in Model Management.'**
  String get engineTransformerRepairFailed;

  /// No description provided for @engineAdversarialNoActiveVariant.
  ///
  /// In en, this message translates to:
  /// **'No active rewrite-detection model found'**
  String get engineAdversarialNoActiveVariant;

  /// No description provided for @engineAdversarialMissingFiles.
  ///
  /// In en, this message translates to:
  /// **'Model or tokenizer file does not exist; re-download in Model Management'**
  String get engineAdversarialMissingFiles;

  /// No description provided for @engineAdversarialRepairFailed.
  ///
  /// In en, this message translates to:
  /// **'Model loading or inference failed, and automatic repair did not complete; re-download the rewrite-detection model and tokenizer in Model Management.'**
  String get engineAdversarialRepairFailed;

  /// No description provided for @engineReasonNotParticipatedWithError.
  ///
  /// In en, this message translates to:
  /// **'Model did not participate in this vote. {error}'**
  String engineReasonNotParticipatedWithError(Object error);

  /// No description provided for @patternNotAnalyzable.
  ///
  /// In en, this message translates to:
  /// **'Segment too short or suspected PDF/OCR noise; no sentence-level AI judgment made'**
  String get patternNotAnalyzable;

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
  /// **'TruthLens is an AI content detector that runs **entirely inside your browser**. Four text-analysis engines evaluate direct text traces; writing process, document origin and source integrity are shown as separate forensic evidence, and your document never leaves the machine.\n\nOnly authorship-specific signals can raise the AI verdict. Correlated engines are merged into independent evidence families before fusion, and a high score never increases its own weight. The report distinguishes likely human, human-AI mixed and likely AI-generated writing, with an integrated likelihood index and separate confidence level. The original engine signals and each evidence axis remain visible, so a low-confidence direction cannot masquerade as proof.'**
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
  /// **'GPTZero does most of its work in the cloud and requires uploading your document; all four TruthLens engines run inside your own browser, and the content is never sent anywhere.'**
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
  /// **'Originality.ai charges per piece on a subscription and requires uploading to the cloud; TruthLens does its core work in the browser, with no subscription and no usage cap.'**
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
  /// **'Winston AI\'s image OCR uploads the picture to the cloud; TruthLens OCR prefers a local OCR server that you configure, and only falls back to the cloud if you supply a Gemini API key yourself — whether the cloud is involved at all stays your decision.'**
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
  /// **'Hyperlink and citation authenticity verification: checks reachable URLs, validates DOI registration through Crossref and DataCite, and cross-checks citation metadata with OpenAlex, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and publisher catalogs. Each verified citation identifies its evidence source; Google Scholar is offered as a manual lookup only.'**
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
  /// **'Local records and exports: reports can be saved as PDF/CSV/JSON/PNG, and the app keeps analysis history locally with the source file name when available, so you can re-run or review prior checks without an account.'**
  String get helpAdvantage4;

  /// No description provided for @helpWorkflowTitle.
  ///
  /// In en, this message translates to:
  /// **'Full operating workflow'**
  String get helpWorkflowTitle;

  /// No description provided for @helpWorkflowStepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step {step}'**
  String helpWorkflowStepLabel(int step);

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
  /// **'Multilingual AI classifier (40% weight): analyzes bounded paragraph blocks to retain context, then maps probabilities back to sentences for detailed evidence.'**
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
  /// **'You can individually enable/disable engines and adjust family weight ceilings in Settings. Actual weight is reduced when a model is unvalidated for the document\'s language or domain, has weak calibration, or covers too little text. Correlated engines are merged within one evidence family and cannot multiply the same signal.'**
  String get helpWorkflowStep2Bullet6;

  /// No description provided for @helpWorkflowStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Adding content'**
  String get helpWorkflowStep3Title;

  /// No description provided for @helpWorkflowStep3Body.
  ///
  /// In en, this message translates to:
  /// **'Three ways in: paste text directly, recognise an image with OCR, or import a document (txt / md / pdf / docx / doc / odt). PDF import compares two text-layer parsers and discards garbled output; scanned PDFs are recognised page by page when OCR is available. When you import, the filename appears under the input heading and on its own line in the report title; when you paste or type, it stays blank.\n\nOCR prefers the local server you configure, and only uses the cloud fallback if you supply a Gemini API key yourself.'**
  String get helpWorkflowStep3Body;

  /// No description provided for @helpWorkflowStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Running analysis'**
  String get helpWorkflowStep4Title;

  /// No description provided for @helpWorkflowStep4Body.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Start Detection\" and all four engines run in parallel, with live progress shown on screen. If non-native writing characteristics are detected, ESL bias correction is applied automatically (can be turned off in Settings). You can stop a running analysis at any time from the toolbar; the document text is kept, but unfinished results are not saved.'**
  String get helpWorkflowStep4Body;

  /// No description provided for @helpWorkflowStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Viewing & exporting results'**
  String get helpWorkflowStep5Title;

  /// No description provided for @helpWorkflowStep5Body.
  ///
  /// In en, this message translates to:
  /// **'Import, live four-engine progress, and the complete report now remain in one situation-center workspace. Switch among Command grid, Mission timeline, and Evidence canvas at any time without restarting analysis; Automatic uses Command grid on desktop and Mission timeline on mobile. The result includes the verdict, AI probability, confidence, elapsed time, sentence evidence, engine contributions, link checks, and citation checks. You can export PDF, CSV, JSON, or PNG, and every result is saved to local History.'**
  String get helpWorkflowStep5Body;

  /// No description provided for @helpWorkflowStep1ChipOnboarding.
  ///
  /// In en, this message translates to:
  /// **'First launch'**
  String get helpWorkflowStep1ChipOnboarding;

  /// No description provided for @helpWorkflowStep1ChipModelManager.
  ///
  /// In en, this message translates to:
  /// **'Model management'**
  String get helpWorkflowStep1ChipModelManager;

  /// No description provided for @helpWorkflowStep1ChipUpdateCheck.
  ///
  /// In en, this message translates to:
  /// **'Auto update check'**
  String get helpWorkflowStep1ChipUpdateCheck;

  /// No description provided for @helpWorkflowStep2ChipTransformer.
  ///
  /// In en, this message translates to:
  /// **'Transformer (40%)'**
  String get helpWorkflowStep2ChipTransformer;

  /// No description provided for @helpWorkflowStep2ChipStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistical analysis (25%)'**
  String get helpWorkflowStep2ChipStatistics;

  /// No description provided for @helpWorkflowStep2ChipStylometry.
  ///
  /// In en, this message translates to:
  /// **'Stylometry (20%)'**
  String get helpWorkflowStep2ChipStylometry;

  /// No description provided for @helpWorkflowStep2ChipAdversarial.
  ///
  /// In en, this message translates to:
  /// **'Adversarial defense (15%)'**
  String get helpWorkflowStep2ChipAdversarial;

  /// No description provided for @helpWorkflowStep2ChipReportLlm.
  ///
  /// In en, this message translates to:
  /// **'Report LLM (optional)'**
  String get helpWorkflowStep2ChipReportLlm;

  /// No description provided for @helpWorkflowStep3ChipPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste text'**
  String get helpWorkflowStep3ChipPaste;

  /// No description provided for @helpWorkflowStep3ChipImageOcr.
  ///
  /// In en, this message translates to:
  /// **'Image OCR'**
  String get helpWorkflowStep3ChipImageOcr;

  /// No description provided for @helpWorkflowStep3ChipImportFormats.
  ///
  /// In en, this message translates to:
  /// **'PDF / DOCX / DOC / ODT / TXT / MD'**
  String get helpWorkflowStep3ChipImportFormats;

  /// No description provided for @helpWorkflowStep3ChipCodeFormulaIsolation.
  ///
  /// In en, this message translates to:
  /// **'Code/formula isolation'**
  String get helpWorkflowStep3ChipCodeFormulaIsolation;

  /// No description provided for @helpWorkflowStep4ChipEnsemble.
  ///
  /// In en, this message translates to:
  /// **'Four-engine ensemble'**
  String get helpWorkflowStep4ChipEnsemble;

  /// No description provided for @helpWorkflowStep4ChipLiveProgress.
  ///
  /// In en, this message translates to:
  /// **'Live progress'**
  String get helpWorkflowStep4ChipLiveProgress;

  /// No description provided for @helpWorkflowStep4ChipEslCorrection.
  ///
  /// In en, this message translates to:
  /// **'ESL writing correction'**
  String get helpWorkflowStep4ChipEslCorrection;

  /// No description provided for @helpWorkflowStep4ChipStoppable.
  ///
  /// In en, this message translates to:
  /// **'Stop anytime'**
  String get helpWorkflowStep4ChipStoppable;

  /// No description provided for @helpWorkflowStep5ChipOverviewGauge.
  ///
  /// In en, this message translates to:
  /// **'AI overview gauge'**
  String get helpWorkflowStep5ChipOverviewGauge;

  /// No description provided for @helpWorkflowStep5ChipSentenceHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Sentence heatmap'**
  String get helpWorkflowStep5ChipSentenceHeatmap;

  /// No description provided for @helpWorkflowStep5ChipCitationVerification.
  ///
  /// In en, this message translates to:
  /// **'Citation verification'**
  String get helpWorkflowStep5ChipCitationVerification;

  /// No description provided for @helpWorkflowStep5ChipExportFormats.
  ///
  /// In en, this message translates to:
  /// **'PDF / CSV / JSON / PNG export'**
  String get helpWorkflowStep5ChipExportFormats;

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
  /// **'From the full Settings page or the right-side settings panel on wide screens, open \"AI Model Management\" to download, update, activate, or remove local models.'**
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
  /// **'If you already have, or have fine-tuned, a compatible .onnx model elsewhere, you can import it via \"Settings → Custom ONNX model import & test\" — you\'ll need to provide the model file, its matching tokenizer configuration (or choose \"none\"), and the AI class index. Before importing, the app automatically checks whether this exact file was already imported, to avoid accidental duplicates. You can also adjust engine weights from Settings.'**
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

  /// No description provided for @privacyWebOverview1.
  ///
  /// In en, this message translates to:
  /// **'TruthLens runs entirely as a web app in your browser tab. There is nothing to install; document text and analysis never leave your device, and downloaded detection models are cached in your browser\'s own sandboxed storage (OPFS), not on any server.'**
  String get privacyWebOverview1;

  /// No description provided for @privacyWebOverview2.
  ///
  /// In en, this message translates to:
  /// **'The page only reads a file, image, or clipboard content when you actively choose to import, scan, or paste it; it never reads other tabs, other sites\' data, or files you have not selected.'**
  String get privacyWebOverview2;

  /// No description provided for @privacySectionOverviewWeb.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get privacySectionOverviewWeb;

  /// No description provided for @privacyRemoveWeb.
  ///
  /// In en, this message translates to:
  /// **'clearing this site\'s data in your browser settings (or simply closing the tab, since nothing is stored on any server)'**
  String get privacyRemoveWeb;

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
  /// **'Any text you type, paste, or import is analyzed entirely by on-device AI models on your own device. TruthLens does not upload document text to its own server or to a third-party AI-detection service.'**
  String get privacyDataHandling2;

  /// No description provided for @privacyDataHandling3.
  ///
  /// In en, this message translates to:
  /// **'Analysis results and history are stored only in your browser\'s local storage on your device. History includes the analyzed text, scores, time, and the source file name when you imported a file; clearing History in the app, or clearing this site\'s data in your browser, removes this local copy — TruthLens keeps no copy anywhere.'**
  String get privacyDataHandling3;

  /// No description provided for @privacyNetworkIntro.
  ///
  /// In en, this message translates to:
  /// **'This app\'s core AI detection runs entirely on-device, but the following optional or supporting features require network access:'**
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
  /// **'3. Hyperlink & citation authenticity verification: on by default and can be turned off in Settings. When enabled, detected URLs, DOI values, or individual citation fields (author, title, year, and venue) are sent to the target website and/or Crossref, OpenAlex, DataCite, Semantic Scholar, Europe PMC/PubMed/AGRICOLA, ERIC, DOAJ, and recognizable publisher catalogs. The rest of the document is not sent. Google Scholar receives a citation query only when you press its manual lookup button.'**
  String get privacyNetwork3;

  /// No description provided for @privacyNetwork4.
  ///
  /// In en, this message translates to:
  /// **'4. Web OCR fallback: on the Web version only, OCR first uses a local OCR server if configured. If you choose to enter a Gemini API key, selected images and rendered pages from PDFs that require OCR are sent directly from your browser to Google\'s Gemini API; the key is stored only in that browser\'s local storage.'**
  String get privacyNetwork4;

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

  /// No description provided for @settingsVersionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (Build {build}) · Local-first private detection engine'**
  String settingsVersionSubtitle(String version, String build);

  /// No description provided for @webOcrSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Web OCR settings'**
  String get webOcrSettingsTitle;

  /// No description provided for @webOcrPurpose.
  ///
  /// In en, this message translates to:
  /// **'Recognize printed or handwritten text in an uploaded image before analysis.'**
  String get webOcrPurpose;

  /// No description provided for @webOcrGeminiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Gemini API key (optional)'**
  String get webOcrGeminiKeyTitle;

  /// No description provided for @webOcrGetKeyButton.
  ///
  /// In en, this message translates to:
  /// **'Get a key'**
  String get webOcrGetKeyButton;

  /// No description provided for @webOcrGeminiDescription.
  ///
  /// In en, this message translates to:
  /// **'Used only when the local OCR server is unavailable. The key is saved in this browser.'**
  String get webOcrGeminiDescription;

  /// No description provided for @webOcrLocalServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Local OCR server (recommended)'**
  String get webOcrLocalServerTitle;

  /// No description provided for @webOcrLocalServerDescription.
  ///
  /// In en, this message translates to:
  /// **'Runs OCR on your computer with Apple Vision on macOS or Windows OCR on Windows. Enter the local endpoint below.'**
  String get webOcrLocalServerDescription;

  /// No description provided for @webOcrSetupGuideButton.
  ///
  /// In en, this message translates to:
  /// **'Beginner setup guide'**
  String get webOcrSetupGuideButton;

  /// No description provided for @webOcrPriorityTitle.
  ///
  /// In en, this message translates to:
  /// **'Recognition order'**
  String get webOcrPriorityTitle;

  /// No description provided for @webOcrPriorityDescription.
  ///
  /// In en, this message translates to:
  /// **'1. Local OCR server when a URL is set\n2. Gemini when an API key is set\n3. A specific diagnostic message when neither path succeeds'**
  String get webOcrPriorityDescription;

  /// No description provided for @webOcrSetupGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the local OCR server'**
  String get webOcrSetupGuideTitle;

  /// No description provided for @webOcrSetupGuideBody.
  ///
  /// In en, this message translates to:
  /// **'1. Select Open OCR project below.\n2. macOS: download setup_and_run_ocr.sh, open Terminal, and run: bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows: download setup_and_run_ocr.bat, then double-click it and allow the requested installation.\n4. Wait until the installer says OCR is ready. It will also configure automatic startup.\n5. Return here, enter http://127.0.0.1:5001/ocr, and select Test connection.\n6. Open Image OCR and choose a clear image to confirm text recognition.\n\nThe browser and OCR server must run on the same computer for 127.0.0.1 to work. If testing fails, check that the installer completed, port 5001 is not blocked, and the URL ends with /ocr.'**
  String get webOcrSetupGuideBody;

  /// No description provided for @webOcrOpenProjectButton.
  ///
  /// In en, this message translates to:
  /// **'Open OCR project'**
  String get webOcrOpenProjectButton;

  /// No description provided for @webOcrTestServerButton.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get webOcrTestServerButton;

  /// No description provided for @webOcrTestServerMissingUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter the local OCR server URL first.'**
  String get webOcrTestServerMissingUrl;

  /// No description provided for @webOcrTestServerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Local OCR server is running and ready.'**
  String get webOcrTestServerSuccess;

  /// No description provided for @webOcrTestServerFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the local OCR server. Open the setup guide and check the installer, firewall, and URL.'**
  String get webOcrTestServerFailure;

  /// No description provided for @workspaceModeSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace mode'**
  String get workspaceModeSectionTitle;

  /// No description provided for @workspaceModeSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose how source, live analysis, and final evidence share one workspace.'**
  String get workspaceModeSectionSubtitle;

  /// No description provided for @workspaceModeOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original layout'**
  String get workspaceModeOriginal;

  /// No description provided for @workspaceModeAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get workspaceModeAuto;

  /// No description provided for @workspaceModeCommandGrid.
  ///
  /// In en, this message translates to:
  /// **'Command grid'**
  String get workspaceModeCommandGrid;

  /// No description provided for @workspaceModeTimeline.
  ///
  /// In en, this message translates to:
  /// **'Mission timeline'**
  String get workspaceModeTimeline;

  /// No description provided for @workspaceModeEvidence.
  ///
  /// In en, this message translates to:
  /// **'Evidence canvas'**
  String get workspaceModeEvidence;

  /// No description provided for @workspaceModeCosmicFuture.
  ///
  /// In en, this message translates to:
  /// **'Cosmic Future'**
  String get workspaceModeCosmicFuture;

  /// No description provided for @workspaceModeSoftEducation.
  ///
  /// In en, this message translates to:
  /// **'Soft Education'**
  String get workspaceModeSoftEducation;

  /// No description provided for @workspaceModeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Switch workspace mode'**
  String get workspaceModeTooltip;

  /// No description provided for @workspaceMoreMenuTooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get workspaceMoreMenuTooltip;

  /// No description provided for @workspaceLanguageMenuTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get workspaceLanguageMenuTitle;

  /// No description provided for @workspaceStageImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get workspaceStageImport;

  /// No description provided for @workspaceStageParse.
  ///
  /// In en, this message translates to:
  /// **'Parse'**
  String get workspaceStageParse;

  /// No description provided for @workspaceStageAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Four-engine analysis'**
  String get workspaceStageAnalyze;

  /// No description provided for @workspaceStageVerify.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get workspaceStageVerify;

  /// No description provided for @workspaceStageReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get workspaceStageReport;

  /// No description provided for @workspaceLiveFindings.
  ///
  /// In en, this message translates to:
  /// **'Live findings'**
  String get workspaceLiveFindings;

  /// No description provided for @workspaceTelemetry.
  ///
  /// In en, this message translates to:
  /// **'Analysis telemetry'**
  String get workspaceTelemetry;

  /// No description provided for @workspaceDocument.
  ///
  /// In en, this message translates to:
  /// **'Document workspace'**
  String get workspaceDocument;

  /// No description provided for @workspaceOverallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get workspaceOverallProgress;

  /// No description provided for @workspaceProgressStatusSummary.
  ///
  /// In en, this message translates to:
  /// **'Step {current}/{total} · {stage}'**
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  );

  /// No description provided for @workspaceWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a document'**
  String get workspaceWaiting;

  /// No description provided for @workspaceAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analysis in progress'**
  String get workspaceAnalyzing;

  /// No description provided for @workspaceAnalysisComplete.
  ///
  /// In en, this message translates to:
  /// **'Analysis complete'**
  String get workspaceAnalysisComplete;

  /// No description provided for @workspaceAnalysisActivity.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} modules complete · {seconds}s elapsed · Running: {engines}'**
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  );

  /// No description provided for @workspaceAnalysisSlow.
  ///
  /// In en, this message translates to:
  /// **'Analysis is still running and the interface is responsive. No module completed in the last {seconds}s; large documents or local models may take longer.'**
  String workspaceAnalysisSlow(Object seconds);

  /// No description provided for @workspaceAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis stopped unexpectedly. Please retry or check the model settings.'**
  String get workspaceAnalysisFailed;

  /// No description provided for @workspaceNewAnalysis.
  ///
  /// In en, this message translates to:
  /// **'New analysis'**
  String get workspaceNewAnalysis;

  /// No description provided for @workspaceStopAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Stop analysis'**
  String get workspaceStopAnalysis;

  /// No description provided for @workspaceStopAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop the current analysis?'**
  String get workspaceStopAnalysisTitle;

  /// No description provided for @workspaceStopAnalysisBody.
  ///
  /// In en, this message translates to:
  /// **'The analysis is still running. The document text will be kept, but unfinished results will not be saved.'**
  String get workspaceStopAnalysisBody;

  /// No description provided for @workspaceAnalysisStopped.
  ///
  /// In en, this message translates to:
  /// **'Analysis stopped. The document text remains in the workspace.'**
  String get workspaceAnalysisStopped;

  /// No description provided for @workspaceSelectedEvidence.
  ///
  /// In en, this message translates to:
  /// **'Selected evidence'**
  String get workspaceSelectedEvidence;

  /// No description provided for @workspaceNoEvidence.
  ///
  /// In en, this message translates to:
  /// **'Sentence evidence appears here as each engine completes.'**
  String get workspaceNoEvidence;

  /// No description provided for @workspacePreliminaryVerdict.
  ///
  /// In en, this message translates to:
  /// **'Preliminary AI probability: {percent}%'**
  String workspacePreliminaryVerdict(int percent);

  /// No description provided for @workspaceSentenceSignalTooltip.
  ///
  /// In en, this message translates to:
  /// **'This percentage is this sentence\'s own AI signal, not the overall document verdict. Higher means the wording pattern looks more AI-generated; lower means it reads more like typical human writing. The final report combines every sentence with engine weighting.'**
  String get workspaceSentenceSignalTooltip;

  /// No description provided for @workspaceSentenceSignalHeader.
  ///
  /// In en, this message translates to:
  /// **'AI signal per sentence'**
  String get workspaceSentenceSignalHeader;

  /// No description provided for @workspaceSentenceColumnHeader.
  ///
  /// In en, this message translates to:
  /// **'Sentence'**
  String get workspaceSentenceColumnHeader;

  /// Shown for an engine that ran but found no evidence, so it did not vote
  ///
  /// In en, this message translates to:
  /// **'{engine} found no evidence this time, so it did not take part in the vote (role weight {weight}%). This means it spotted no AI traces on its own axis — not that it considers the text human-written.'**
  String reportEngineRelationshipNoEvidence(String engine, int weight);

  /// Telemetry summary line when exactly one engine found evidence
  ///
  /// In en, this message translates to:
  /// **'Only {engine} found anything; the other engines turned up nothing this time. The conclusion rests on a single line of evidence, so treat its confidence accordingly.'**
  String telemetrySummarySingleSource(String engine);

  /// Telemetry summary line counting engines that ran but found no evidence
  ///
  /// In en, this message translates to:
  /// **'{count} further engine(s) ran but found no evidence, and were excluded from the vote so that \'nothing to report\' is not miscounted as \'looks human-written\'.'**
  String telemetrySummarySilentEngines(int count);

  /// Shown when the perplexity metric is skipped because the model does not support the document's language
  ///
  /// In en, this message translates to:
  /// **'Perplexity was not used for this document: the perplexity model (DistilGPT2) was trained on English only, and on Chinese, Japanese or Korean text it measures byte predictability rather than language predictability. Measured on labelled data, it separates human from AI writing in those languages 0% of the time, so counting it would only manufacture false positives.'**
  String get engineReasonPplUncalibratedLanguage;

  /// Per-language calibration sample counts
  ///
  /// In en, this message translates to:
  /// **'Baseline by language: {breakdown}'**
  String settingsCalibrationByLanguage(String breakdown);

  /// Count of pre-language-tagging calibration samples
  ///
  /// In en, this message translates to:
  /// **'{count} earlier sample(s) carry no language tag and cannot join any language\'s baseline — the original text is not kept, so the language cannot be recovered after the fact. They will be replaced as new documents are analysed.'**
  String settingsCalibrationLegacySamples(int count);

  /// Model routing explanation shown in engine reasons
  ///
  /// In en, this message translates to:
  /// **'Routed to “{variant}” for this document: the variant you selected is not validated for {language}, and this one is.'**
  String engineRoutedToBetterVariant(String variant, String language);

  /// Model routing explanation shown in engine reasons
  ///
  /// In en, this message translates to:
  /// **'“{variant}” is a multilingual model but has not been validated on {language}, so treat its score as weaker evidence than a validated one.'**
  String engineLanguageNotValidated(String variant, String language);

  /// Model routing explanation shown in engine reasons
  ///
  /// In en, this message translates to:
  /// **'“{variant}” does not cover {language}. Its score is shown for reference only and should not be read as evidence either way.'**
  String engineLanguageUnsupported(String variant, String language);

  /// Perplexity skipped because the document language could not be determined
  ///
  /// In en, this message translates to:
  /// **'Perplexity was not used: the language of this document could not be determined, so there is no calibrated threshold to compare against. Guessing a language would mean applying the wrong scale — the mistake this check exists to prevent.'**
  String get engineReasonPplLanguageUndetermined;

  /// Perplexity skipped because no threshold has been measured for this model and language
  ///
  /// In en, this message translates to:
  /// **'Perplexity was not used: the model in use (“{model}”) has no measured threshold for {language} yet. Its raw value carries no meaning without a calibrated scale, so it is left out rather than guessed at.'**
  String engineReasonPplNoCalibrationForModel(String model, String language);

  /// Guidance shown when the imported format has no editing record
  ///
  /// In en, this message translates to:
  /// **'This format carries no editing record. PDFs, images and pasted text hold no history of how they were written, so the analysis rests entirely on text statistics. If you can obtain the original .docx, .odt or .doc, its editing history is far stronger evidence — and unlike text statistics, it does not weaken as language models improve.'**
  String get inputNoEditingRecordHint;

  /// Caveat shown beside a human-leaning verdict when no provenance evidence exists
  ///
  /// In en, this message translates to:
  /// **'A low score is not confirmation that a person wrote this. With no origin evidence available, this verdict rests only on text statistics, which reliably flag formulaic writing but not well-written output from current-generation models.'**
  String get reportLowScoreNotProofOfHuman;

  /// Shown when origin evidence is suspicious but the text score leans human
  ///
  /// In en, this message translates to:
  /// **'The file\'s own editing record contradicts this low score. Origin evidence does not weaken as language models improve, whereas text statistics cannot identify well-written output from current-generation models. Read the origin evidence below before drawing any conclusion from the score above.'**
  String get reportProvenanceContradictsLowScore;

  /// Provenance signal: words concentrated in one RSID editing batch
  ///
  /// In en, this message translates to:
  /// **'{paragraphs} of {total} paragraphs share a single editing batch and carry {percent}% of the words — consistent with that block being written or pasted in one sitting, even though the file has other editing batches.'**
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  );

  /// Verifiable finding: evasion marks
  ///
  /// In en, this message translates to:
  /// **'{count} character-level evasion marks were found (zero-width characters, look-alike letters, or direction controls). Ordinary writing tools do not produce these — someone processed the text to defeat detection.'**
  String findingEvasionDetected(int count);

  /// Verifiable finding: citations not located
  ///
  /// In en, this message translates to:
  /// **'{notFound} of {total} cited works could not be found in any of the reference databases checked. Fabricated citations are a behaviour of language models, and unlike writing style, whether a paper exists is a verifiable fact.'**
  String findingCitationsNotFound(int notFound, int total);

  /// Verifiable finding: all citations located
  ///
  /// In en, this message translates to:
  /// **'All {total} cited works were located in public reference databases.'**
  String findingCitationsAllVerified(int total);

  /// Verifiable finding: editing record looks normal
  ///
  /// In en, this message translates to:
  /// **'The file records {minutes} minutes of editing across {revisions} saves, which is consistent with the text having been written in this document.'**
  String findingEditingRecordNormal(int minutes, int revisions);

  /// No description provided for @findingPublicationPredatesGenerativeAi.
  ///
  /// In en, this message translates to:
  /// **'Source DOI {doi} matches this document and was registered in {year}, before modern generative-AI writing systems.'**
  String findingPublicationPredatesGenerativeAi(String doi, int year);

  /// No description provided for @findingPublicationIdentityMismatch.
  ///
  /// In en, this message translates to:
  /// **'Source DOI {doi} resolves, but its registered title does not match this document. Verify the document identity before relying on it.'**
  String findingPublicationIdentityMismatch(String doi);

  /// No description provided for @integratedStabilityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Segment stability unavailable · no sentence-level evidence voted'**
  String get integratedStabilityUnavailable;

  /// No description provided for @integratedNeutralBaseline.
  ///
  /// In en, this message translates to:
  /// **'No authorship-specific evidence was found; 50% is a neutral baseline, not an equal-evidence result.'**
  String get integratedNeutralBaseline;

  /// Heading of the verifiable-facts card shown above the verdict
  ///
  /// In en, this message translates to:
  /// **'What can be verified'**
  String get reportVerifiableFindingsTitle;

  /// Subtitle explaining that these facts do not decay
  ///
  /// In en, this message translates to:
  /// **'Each item below can be checked independently. Unlike a probability, these do not weaken as language models improve.'**
  String get reportVerifiableFindingsSubtitle;

  /// Verifiable finding: a large paste was recorded
  ///
  /// In en, this message translates to:
  /// **'A single paste of {characters} characters was recorded while this text was being entered. A language model cannot fake how text arrives in an editor — this block was not typed here.'**
  String findingBulkPaste(int characters);

  /// Verifiable finding: text was typed in the app
  ///
  /// In en, this message translates to:
  /// **'The text was typed in this app over {minutes} minutes, with {deleted} characters revised along the way. Writing that happens here leaves a record no language model can reproduce.'**
  String findingWrittenInApp(int minutes, int deleted);

  /// No description provided for @evidenceMatrixTitle.
  ///
  /// In en, this message translates to:
  /// **'Multi-evidence assessment'**
  String get evidenceMatrixTitle;

  /// No description provided for @evidenceMatrixSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Six axes are shown separately. Only authorship-specific evidence affects the author verdict; coverage shows what could be examined.'**
  String get evidenceMatrixSubtitle;

  /// No description provided for @evidenceMatrixCoverage.
  ///
  /// In en, this message translates to:
  /// **'Evidence coverage: {available} of {total} axes'**
  String evidenceMatrixCoverage(int available, int total);

  /// No description provided for @evidenceAxisText.
  ///
  /// In en, this message translates to:
  /// **'Text-generation traces'**
  String get evidenceAxisText;

  /// No description provided for @evidenceAxisTextNote.
  ///
  /// In en, this message translates to:
  /// **'Probabilistic patterns from the four local detectors'**
  String get evidenceAxisTextNote;

  /// No description provided for @evidenceAxisProcess.
  ///
  /// In en, this message translates to:
  /// **'Writing process'**
  String get evidenceAxisProcess;

  /// No description provided for @evidenceAxisProcessNote.
  ///
  /// In en, this message translates to:
  /// **'Typing, revision and paste events recorded without storing their content'**
  String get evidenceAxisProcessNote;

  /// No description provided for @evidenceAxisOrigin.
  ///
  /// In en, this message translates to:
  /// **'Document origin'**
  String get evidenceAxisOrigin;

  /// No description provided for @evidenceAxisOriginNote.
  ///
  /// In en, this message translates to:
  /// **'Editing time, saves and DOCX/ODT/RSID metadata'**
  String get evidenceAxisOriginNote;

  /// No description provided for @evidenceAxisSources.
  ///
  /// In en, this message translates to:
  /// **'Claim and source integrity'**
  String get evidenceAxisSources;

  /// No description provided for @evidenceAxisSourcesNote.
  ///
  /// In en, this message translates to:
  /// **'Checkable claims, citation anchors and bibliographic verification'**
  String get evidenceAxisSourcesNote;

  /// No description provided for @evidenceStateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get evidenceStateUnavailable;

  /// No description provided for @evidenceStateInconclusive.
  ///
  /// In en, this message translates to:
  /// **'Inconclusive'**
  String get evidenceStateInconclusive;

  /// No description provided for @evidenceStateReassuring.
  ///
  /// In en, this message translates to:
  /// **'Consistent'**
  String get evidenceStateReassuring;

  /// No description provided for @evidenceStateConcern.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get evidenceStateConcern;

  /// No description provided for @evidenceStrengthNone.
  ///
  /// In en, this message translates to:
  /// **'No evidence'**
  String get evidenceStrengthNone;

  /// No description provided for @evidenceStrengthLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get evidenceStrengthLimited;

  /// No description provided for @evidenceStrengthModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get evidenceStrengthModerate;

  /// No description provided for @evidenceStrengthStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get evidenceStrengthStrong;

  /// No description provided for @evidenceMatrixTextOnlyWarning.
  ///
  /// In en, this message translates to:
  /// **'Only the text-pattern axis was available. Current-generation AI can imitate human prose, so this report cannot establish authorship from the score alone.'**
  String get evidenceMatrixTextOnlyWarning;

  /// No description provided for @evidenceMatrixStrongConcern.
  ///
  /// In en, this message translates to:
  /// **'At least one independent axis contains a strong review signal. Inspect that evidence before relying on the text score.'**
  String get evidenceMatrixStrongConcern;

  /// No description provided for @findingUnsupportedClaims.
  ///
  /// In en, this message translates to:
  /// **'{unsupported} of {total} checkable claims contain numbers, comparisons or research attributions without a source anchor in the same sentence. This does not prove they are false, but identifies the claims that need verification first.'**
  String findingUnsupportedClaims(int unsupported, int total);

  /// No description provided for @challengeTitle.
  ///
  /// In en, this message translates to:
  /// **'Supervised follow-up'**
  String get challengeTitle;

  /// No description provided for @challengeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask the writer to explain specific claims from this document'**
  String get challengeSubtitle;

  /// No description provided for @challengeCaveat.
  ///
  /// In en, this message translates to:
  /// **'Use this while the writer is present. The check only measures whether an answer engages with the document and whether it was pasted; passing is not proof of identity or authorship.'**
  String get challengeCaveat;

  /// No description provided for @challengeExplainQuestion.
  ///
  /// In en, this message translates to:
  /// **'Explain this passage in your own words and state why it matters: “{excerpt}”'**
  String challengeExplainQuestion(String excerpt);

  /// No description provided for @challengeJustifyQuestion.
  ///
  /// In en, this message translates to:
  /// **'What evidence or reasoning supports this claim, and what would weaken it? “{excerpt}”'**
  String challengeJustifyQuestion(String excerpt);

  /// No description provided for @challengeAnswerHint.
  ///
  /// In en, this message translates to:
  /// **'Answer here without pasting prepared text'**
  String get challengeAnswerHint;

  /// No description provided for @challengeEvaluate.
  ///
  /// In en, this message translates to:
  /// **'Check response'**
  String get challengeEvaluate;

  /// No description provided for @challengeStateUnanswered.
  ///
  /// In en, this message translates to:
  /// **'Not checked'**
  String get challengeStateUnanswered;

  /// No description provided for @challengeStateInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Needs a more specific answer'**
  String get challengeStateInsufficient;

  /// No description provided for @challengeStateGrounded.
  ///
  /// In en, this message translates to:
  /// **'Directly engages with the passage'**
  String get challengeStateGrounded;

  /// No description provided for @challengeStatePasted.
  ///
  /// In en, this message translates to:
  /// **'Large paste detected; repeat under supervision'**
  String get challengeStatePasted;

  /// No description provided for @integratedAssessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Integrated authorship assessment'**
  String get integratedAssessmentTitle;

  /// No description provided for @integratedLikelyAi.
  ///
  /// In en, this message translates to:
  /// **'More likely AI-generated'**
  String get integratedLikelyAi;

  /// No description provided for @integratedLikelyMixed.
  ///
  /// In en, this message translates to:
  /// **'More likely human-AI mixed'**
  String get integratedLikelyMixed;

  /// No description provided for @integratedLikelyHuman.
  ///
  /// In en, this message translates to:
  /// **'More likely not AI-generated'**
  String get integratedLikelyHuman;

  /// No description provided for @integratedBalanced.
  ///
  /// In en, this message translates to:
  /// **'AI and human signals are balanced'**
  String get integratedBalanced;

  /// No description provided for @integratedLikelihoodLabel.
  ///
  /// In en, this message translates to:
  /// **'Integrated AI likelihood: {percent}%'**
  String integratedLikelihoodLabel(int percent);

  /// No description provided for @integratedTextScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Text-model score: {percent}%'**
  String integratedTextScoreLabel(int percent);

  /// No description provided for @integratedConfidenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Confidence: {confidence}'**
  String integratedConfidenceLabel(String confidence);

  /// No description provided for @integratedConfidenceLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get integratedConfidenceLow;

  /// No description provided for @integratedConfidenceModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get integratedConfidenceModerate;

  /// No description provided for @integratedConfidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get integratedConfidenceHigh;

  /// No description provided for @integratedEvidenceCoverage.
  ///
  /// In en, this message translates to:
  /// **'Independent evidence families: {families}/4 · applicability coverage {coverage}%'**
  String integratedEvidenceCoverage(int families, int coverage);

  /// No description provided for @integratedEvidenceGatePassed.
  ///
  /// In en, this message translates to:
  /// **'AI evidence gate: passed'**
  String get integratedEvidenceGatePassed;

  /// No description provided for @integratedEvidenceGateNotPassed.
  ///
  /// In en, this message translates to:
  /// **'AI evidence gate: not passed · directional screening only'**
  String get integratedEvidenceGateNotPassed;

  /// No description provided for @integratedQualifiedWarning.
  ///
  /// In en, this message translates to:
  /// **'{reason} The system still gives the most likely direction, but confidence is reduced; treat it as a screening result, not proof.'**
  String integratedQualifiedWarning(String reason);

  /// No description provided for @integratedIndexCaveat.
  ///
  /// In en, this message translates to:
  /// **'The separate AI evidence gate indicates whether independent support is strong enough for escalation. Citation quality, paste behavior, and suspicious metadata cannot independently produce an AI verdict. This is an evidence score, not a calibrated statistical probability.'**
  String get integratedIndexCaveat;

  /// No description provided for @reportTextEngineSignalExplanation.
  ///
  /// In en, this message translates to:
  /// **'These bars show diagnostic signals from the four text engines. The final text score first merges correlated engines into independent evidence families and applies language/domain applicability and calibration reliability. The separate AI evidence gate indicates whether support is strong enough for escalation; ‘not detected’ is not proof of human authorship.'**
  String get reportTextEngineSignalExplanation;

  /// No description provided for @reportSynthesisTextScoreContext.
  ///
  /// In en, this message translates to:
  /// **'Four-engine text-model raw score: {percent}%. This is one input to the integrated assessment, not a second verdict.'**
  String reportSynthesisTextScoreContext(int percent);

  /// No description provided for @reportSynthesisStrongestTextSignal.
  ///
  /// In en, this message translates to:
  /// **'Strongest text-engine signal: {label} ({percent}%). It can influence the text-model score but cannot override the integrated assessment by itself.'**
  String reportSynthesisStrongestTextSignal(String label, int percent);

  /// No description provided for @composerTextScoreThresholdReached.
  ///
  /// In en, this message translates to:
  /// **'The text-model raw score is {aiPercent}%, reaching the {thresholdPercent}% diagnostic marker. This is a text-signal observation only; the integrated assessment above remains the report\'s authorship direction.'**
  String composerTextScoreThresholdReached(int aiPercent, int thresholdPercent);

  /// No description provided for @composerTextScoreThresholdNotReached.
  ///
  /// In en, this message translates to:
  /// **'The text-model raw score is {aiPercent}%, below the {thresholdPercent}% diagnostic marker. Missing that marker is not evidence of human authorship; the integrated assessment above remains the report\'s authorship direction.'**
  String composerTextScoreThresholdNotReached(
    int aiPercent,
    int thresholdPercent,
  );

  /// No description provided for @telemetryIntegratedVerdict.
  ///
  /// In en, this message translates to:
  /// **'After weighting the available evidence, the document is “{direction}” (AI likelihood index {percent}%, {confidence} confidence).'**
  String telemetryIntegratedVerdict(
    String direction,
    int percent,
    String confidence,
  );

  /// No description provided for @integratedStabilityLabel.
  ///
  /// In en, this message translates to:
  /// **'Segment stability {percent}% · interval {lower}–{upper}%'**
  String integratedStabilityLabel(int percent, int lower, int upper);

  /// No description provided for @integratedInputQualityLabel.
  ///
  /// In en, this message translates to:
  /// **'Input extraction quality: {percent}%'**
  String integratedInputQualityLabel(int percent);

  /// No description provided for @integratedCalibrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Matched local baseline: p={value} · n={count}'**
  String integratedCalibrationLabel(String value, int count);

  /// No description provided for @analysisReadinessLabel.
  ///
  /// In en, this message translates to:
  /// **'Expected confidence ceiling: {level}'**
  String analysisReadinessLabel(String level);

  /// No description provided for @analysisReadinessShortText.
  ///
  /// In en, this message translates to:
  /// **'more text needed'**
  String get analysisReadinessShortText;

  /// No description provided for @analysisReadinessFewSentences.
  ///
  /// In en, this message translates to:
  /// **'too few segments'**
  String get analysisReadinessFewSentences;

  /// No description provided for @analysisReadinessCoreModel.
  ///
  /// In en, this message translates to:
  /// **'core classifier unavailable'**
  String get analysisReadinessCoreModel;

  /// No description provided for @analysisReadinessFewEngines.
  ///
  /// In en, this message translates to:
  /// **'fewer than two engines enabled'**
  String get analysisReadinessFewEngines;

  /// No description provided for @analysisReadinessExtraction.
  ///
  /// In en, this message translates to:
  /// **'extraction quality is limited'**
  String get analysisReadinessExtraction;

  /// No description provided for @analysisReadinessBaseline.
  ///
  /// In en, this message translates to:
  /// **'no matched local baseline'**
  String get analysisReadinessBaseline;
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
