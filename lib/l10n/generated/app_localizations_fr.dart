// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonClose => 'Fermer';

  @override
  String get verdictHuman => 'Écrit par un humain';

  @override
  String get verdictLikelyHuman => 'Probablement humain';

  @override
  String get verdictMixed => 'Contenu mixte';

  @override
  String get verdictLikelyAi => 'Probablement IA';

  @override
  String get verdictAi => 'Généré par IA';

  @override
  String get inputSubtitle =>
      'Collez ou saisissez du texte pour détecter le contenu généré par IA';

  @override
  String get inputHint => 'Saisissez ou collez le texte à analyser…';

  @override
  String get inputHistoryTooltip => 'Historique';

  @override
  String get inputHelpTooltip => 'Guide de l\'utilisateur';

  @override
  String get inputPrivacyTooltip => 'Politique de confidentialité';

  @override
  String get inputSettingsTooltip => 'Paramètres';

  @override
  String get inputPasteButton => 'Coller';

  @override
  String get inputOcrButton => 'OCR d\'image';

  @override
  String get inputImportButton => 'Importer un fichier';

  @override
  String get inputStartButton => 'Démarrer la détection';

  @override
  String get inputClearTooltip => 'Effacer le contenu';

  @override
  String get inputTooShortSnackbar =>
      'Veuillez saisir au moins 40 caractères pour une analyse fiable';

  @override
  String get inputOcrUnsupported =>
      'La reconnaissance de texte OCR n\'est pas prise en charge sur cette plateforme';

  @override
  String get inputOcrRecognizing => 'Reconnaissance en cours…';

  @override
  String get inputOcrNoText => 'Aucun texte identifié dans l\'image';

  @override
  String inputOcrRecognized(int count) {
    return '$count caractères reconnus avec succès';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\" ne contient aucun contenu textuel lisible';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '\"$fileName\" importé ($count caractères)';
  }

  @override
  String inputActiveModel(String modelId) {
    return 'Modèle : $modelId';
  }

  @override
  String get inputNoModel =>
      'Aucun modèle installé (analyse statistique/stylistique uniquement)';

  @override
  String inputCharCount(int count) {
    return '$count caractères';
  }

  @override
  String get analysisAppBarTitle => 'Analyse en cours';

  @override
  String get analysisEngineTransformer => 'Classificateur Transformer';

  @override
  String get analysisEngineStatistical => 'Analyse statistique';

  @override
  String get analysisEngineStylometry => 'Analyse stylométrique';

  @override
  String get analysisEngineAdversarial => 'Défense adversariale';

  @override
  String analysisProgressSemantics(int done, int total) {
    return 'Analyse en cours, $done sur $total moteurs terminés';
  }

  @override
  String get analysisDoneSemantics => 'Terminé';

  @override
  String get engineNameAdversarialFull =>
      'Défense adversariale (détection de paraphrase)';

  @override
  String get modelNecessityText =>
      'Sans télécharger le modèle de détection par réseau de neurones, TruthLens continue de fonctionner, mais n\'utilise que l\'analyse statistique et stylistique, avec une précision et un support multilingue limités. Après le téléchargement du modèle, le classificateur Transformer multilingue rejoindra le vote d\'ensemble, améliorant considérablement la précision et la fiabilité. Le modèle s\'exécute sur l\'appareil ; une fois téléchargé, il ne télécharge aucun contenu.';

  @override
  String get modelPromptTitle =>
      'Il est recommandé de télécharger le modèle de détection pour une analyse complète';

  @override
  String get modelPromptDontRemind => 'Ne plus me rappeler';

  @override
  String get modelPromptSkip => 'Ignorer pour l\'instant';

  @override
  String get modelPromptDownload => 'Télécharger';

  @override
  String get onboardingWelcomeTitle => 'Bienvenue sur TruthLens';

  @override
  String get onboardingHeadline => 'Détection de contenu IA sur l\'appareil';

  @override
  String get onboardingDetectedDevice => 'Appareil détecté';

  @override
  String get onboardingChooseModel => 'Choisissez un modèle à télécharger';

  @override
  String get onboardingRecommendHint =>
      '\"Recommandé\" est marqué selon votre matériel ; vous pouvez également choisir une autre option.';

  @override
  String get onboardingSkipButton =>
      'Décider plus tard (utiliser l\'analyse statistique/stylistique sans modèle)';

  @override
  String get onboardingSkipHint =>
      'Vous pouvez toujours télécharger à tout moment depuis \"Paramètres → Gestion des modèles IA\" ; vous serez de nouveau rappelé lors de l\'utilisation d\'analyses nécessitant un modèle.';

  @override
  String get modelListCustomImportedLabel => 'Modèle personnalisé importé :';

  @override
  String get modelListActiveChip => 'En cours d\'utilisation';

  @override
  String get modelListRecommendedChip => 'Recommandé';

  @override
  String get modelListCustomChip => 'Personnalisé';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · Nécessite $ram Go de RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'Taille : $size · Tokenizer : $tokenizer · Indice d\'étiquette IA : $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'Téléchargement… $percent% ($downloaded / $total)';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'Télécharger ($size)';
  }

  @override
  String get modelListComingSoonChip => 'Bientôt disponible';

  @override
  String get modelListSetActiveButton => 'Définir comme actif';

  @override
  String get modelListUpdateButton => 'Mettre à jour';

  @override
  String get modelListDeleteTooltip => 'Supprimer';

  @override
  String get modelListPageButton => 'Page du modèle';

  @override
  String get modelListMayExceedMemory =>
      'Peut dépasser la mémoire de l\'appareil';

  @override
  String modelListFailedPrefix(String error) {
    return 'Échec : $error';
  }

  @override
  String get modelListDeleteConfirmTitle => 'Supprimer le modèle ?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return 'Cela supprimera \"$name\" ($size). Vous devrez le retélécharger pour l\'utiliser à nouveau.';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'Cela supprimera le modèle personnalisé importé \"$name\" ($size). Vous devrez le réimporter pour l\'utiliser à nouveau.';
  }

  @override
  String get modelImportAppBarTitle => 'Importer un modèle ONNX personnalisé';

  @override
  String get modelImportStep1Title =>
      '1. Sélectionnez le fichier du modèle ONNX';

  @override
  String modelImportSelectedFile(String name) {
    return 'Sélectionné : $name';
  }

  @override
  String get modelImportNoFileSelected =>
      'Aucun fichier de modèle sélectionné (.onnx)';

  @override
  String get modelImportBrowseButton => 'Parcourir';

  @override
  String get modelImportCheckingDuplicate =>
      'Vérification qu\'un fichier identique n\'a pas déjà été importé…';

  @override
  String get modelImportDuplicateTitle =>
      'Un modèle avec un contenu identique a déjà été importé';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'Ce fichier a un contenu entièrement identique à \"$name\" (rôle : $role). Si vous souhaitez simplement changer de modèle actif, allez dans \"Gestion des modèles IA\" et définissez-le directement comme actif — aucune réimportation nécessaire. Vous pouvez tout de même continuer avec les étapes ci-dessous.';
  }

  @override
  String get modelImportStep2Title => '2. Configuration';

  @override
  String get modelImportNameLabel => 'Nom d\'affichage du modèle';

  @override
  String get modelImportNameRequired => 'Le nom ne peut pas être vide';

  @override
  String get modelImportRoleLabel => 'Rôle du moteur cible';

  @override
  String get modelImportTokenizerTypeLabel => 'Type de tokenizer';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone =>
      'Aucun (sans tokenizer/niveau caractère)';

  @override
  String get modelImportNoTokenizerSelected =>
      'Aucun fichier de tokenizer sélectionné (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return 'Sélectionné : $name';
  }

  @override
  String get modelImportAiLabelIndexLabel =>
      'Indice de sortie de l\'étiquette IA';

  @override
  String get modelImportIndex0 => 'Indice 0 (par ex. RoBERTa)';

  @override
  String get modelImportIndex1 => 'Indice 1 (par ex. DistilBERT)';

  @override
  String get modelImportStep3Title => '3. Tester et vérifier';

  @override
  String get modelImportTestInputLabel => 'Texte de test en entrée';

  @override
  String get modelImportRunTestButton => 'Exécuter l\'inférence de test';

  @override
  String get modelImportResultLabel =>
      'Résultat de l\'inférence (probabilité IA) :';

  @override
  String modelImportTestFailed(String error) {
    return 'Échec du test : $error';
  }

  @override
  String get modelImportConfirmButton =>
      'Confirmer l\'importation et activer le modèle';

  @override
  String get modelImportSelectTokenizerFirst =>
      'Veuillez d\'abord sélectionner un fichier de tokenizer';

  @override
  String get modelImportSelectTokenizer =>
      'Veuillez sélectionner un fichier de tokenizer';

  @override
  String get modelImportSuccessSnackbar =>
      'Modèle importé avec succès ! Défini automatiquement comme modèle actif.';

  @override
  String get modelImportFailedSnackbar =>
      'Échec de l\'importation du modèle. Veuillez vérifier les autorisations ou les journaux';

  @override
  String get settingsAppBarTitle => 'Paramètres';

  @override
  String get settingsThresholdTitle =>
      'Seuil de confiance pour la détermination IA';

  @override
  String settingsThresholdSubtitle(int percent) {
    return 'Actuel : $percent% — l\'augmenter réduit les faux positifs (texte humain classé à tort comme IA)';
  }

  @override
  String get settingsEslTitle => 'Correction du biais ESL (non natif)';

  @override
  String get settingsEslSubtitle =>
      'Réduit automatiquement le poids du modèle statistique lorsqu\'un style d\'écriture non natif est détecté';

  @override
  String get settingsEngineSectionTitle =>
      'Paramètres des sous-moteurs de détection (Ensemble)';

  @override
  String get settingsEngineTransformerTitle =>
      'Classificateur IA multilingue (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Utilise un modèle de réseau de neurones Transformer pour prédire la probabilité IA sur l\'appareil';

  @override
  String get settingsEngineStatisticalTitle =>
      'Moteur d\'analyse statistique (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      'Détermine la régularité du langage via la variation de longueur des phrases, la Burstiness et le PPL';

  @override
  String get settingsEngineStylometryTitle =>
      'Analyse stylométrique (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle =>
      'Analyse la fluidité sémantique, les motifs de phrases répétitifs et l\'utilisation de mots de transition';

  @override
  String get settingsEngineAdversarialTitle =>
      'Détection de paraphrase adversariale (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle =>
      'Détecte si le texte a été paraphrasé par une machine ou traité pour supprimer les traces d\'IA';

  @override
  String get settingsLinkVerificationTitle =>
      'Vérification des hyperliens et de la bibliographie';

  @override
  String get settingsLinkVerificationSubtitle =>
      'Le rapport se connectera pour vérifier si les URL et les entrées bibliographiques détectées dans le document existent réellement (le contenu généré par IA inclut souvent des références plausibles mais fictives). Les liens académiques au format DOI, ainsi que les références au format \"auteur-année\" sans lien, sont tous deux vérifiés par rapport au registre public Crossref. Le modèle de détection IA principal continue de fonctionner entièrement sur l\'appareil et n\'envoie jamais le contenu du document ; la connexion n\'est utilisée que pour cette vérification et pour vérifier les mises à jour du modèle, et peut être désactivée ici.';

  @override
  String get settingsThemeTitle => 'Thème d\'affichage';

  @override
  String get settingsLanguageTitle => 'Langue';

  @override
  String get settingsLanguageSubtitle =>
      'Choisissez la langue d\'affichage de l\'application';

  @override
  String get settingsModelManagementTitle => 'Gestion des modèles IA';

  @override
  String get settingsModelManagementSubtitle =>
      'Téléchargez les modèles de détection et le LLM de rédaction de rapports pour activer la capacité d\'inférence complète';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'Mise à jour du modèle détectée — vérification recommandée';

  @override
  String get settingsOpenButton => 'Ouvrir';

  @override
  String get settingsCustomImportTitle =>
      'Importer et tester un modèle ONNX personnalisé';

  @override
  String get settingsCustomImportSubtitle =>
      'Importez un modèle ONNX personnalisé local, configurez le tokenizer et exécutez un test d\'inférence';

  @override
  String get settingsLanguagePackTitle => 'Pack de langue';

  @override
  String get settingsLanguagePackSubtitle =>
      'Modèle d\'ajustement linguistique supplémentaire (disponible en phase 4)';

  @override
  String get settingsModelManagerAppBarTitle => 'Gestion des modèles IA';

  @override
  String get settingsImportTooltip => 'Importer un modèle ONNX local';

  @override
  String settingsDeviceLabel(String summary) {
    return 'Appareil : $summary';
  }

  @override
  String get historyAppBarTitle => 'Historique';

  @override
  String get historyClearAllTooltip => 'Tout effacer';

  @override
  String get historySearchHint => 'Rechercher dans l\'historique…';

  @override
  String get historyDeletedSnackbar => 'Entrée supprimée';

  @override
  String get historyClearAllTitle => 'Effacer tout l\'historique ?';

  @override
  String historyClearAllBody(int count) {
    return 'Cela supprimera les $count entrées. Cette action est irréversible.';
  }

  @override
  String get historyClearButton => 'Effacer';

  @override
  String get historyDeleteEntryTitle => 'Supprimer cette entrée ?';

  @override
  String get historyReanalyzeTooltip => 'Réanalyser';

  @override
  String get historyEmptyDefault =>
      'Aucun historique de détection pour le moment';

  @override
  String historyEmptySearch(String query) {
    return 'Aucune entrée ne correspond à \"$query\"';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, probabilité IA $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => 'Rapport de détection';

  @override
  String get reportExportTooltip => 'Exporter le rapport';

  @override
  String get reportHomeTooltip => 'Retour à l\'accueil';

  @override
  String get reportGeneratingTitle => 'Génération du rapport…';

  @override
  String get reportSourceLlm => 'Rapport généré par IA';

  @override
  String get reportSourceTemplate => 'Rapport généré par modèle';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '$total phrases · $ai probablement IA · $human probablement humain · $seconds s écoulées';
  }

  @override
  String get reportExportPdf => 'Exporter le rapport PDF';

  @override
  String get reportExportCsv => 'Exporter les données CSV';

  @override
  String get reportExportJson => 'Exporter en JSON (intégration système)';

  @override
  String get reportExportPng => 'Exporter la carte récapitulative (PNG)';

  @override
  String reportExported(String path) {
    return 'Exporté : $path';
  }

  @override
  String reportExportFailed(String error) {
    return 'Échec de l\'exportation : $error';
  }

  @override
  String get reportEngineBreakdownTitle => 'Répartition par moteur';

  @override
  String get reportEngineNotInstalled => 'Non installé';

  @override
  String get reportSentenceAnalysisTitle => 'Analyse au niveau de la phrase';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text. Probabilité IA $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'Authenticité des hyperliens';

  @override
  String get reportLinkNoneDetected =>
      'Aucun hyperlien détecté dans ce document.';

  @override
  String get reportLinkCheckingProgress => 'Vérification des liens…';

  @override
  String reportLinkDetectedPending(int count) {
    return '$count hyperliens détectés ; pas encore vérifiés';
  }

  @override
  String get reportLinkDisabledHint =>
      'Le contenu généré par IA inclut souvent des liens de référence plausibles mais fictifs. Vous avez désactivé la vérification des hyperliens dans les paramètres ; vous pouvez la réactiver pour une vérification automatique, ou appuyer ci-dessous pour une vérification unique.';

  @override
  String get reportVerifyNowButton => 'Vérifier maintenant (réseau requis)';

  @override
  String get reportLinkReachable => 'Accessible — l\'URL existe';

  @override
  String get reportLinkNotFound =>
      'L\'URL n\'existe pas (404) — référence potentiellement fictive';

  @override
  String get reportLinkUnreachable =>
      'Impossible à vérifier (délai dépassé ou aucune réponse du serveur)';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'Vérifié dans le registre des revues : enregistré auprès de $journal$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      'Aucun enregistrement DOI correspondant trouvé — référence potentiellement fictive';

  @override
  String get reportLinkCitationUnreachable =>
      'Impossible à vérifier (délai dépassé ou aucune réponse de Crossref)';

  @override
  String reportLinkTruncated(int max, int count) {
    return 'Seuls les $max premiers liens ont été vérifiés (total de $count détectés)';
  }

  @override
  String get reportBibAuthenticityTitle => 'Authenticité des citations';

  @override
  String get reportBibNoneDetected =>
      'Aucune entrée bibliographique détectée dans ce document.';

  @override
  String get reportBibCheckingProgress => 'Vérification de la bibliographie…';

  @override
  String reportBibDetectedPending(int count) {
    return 'Bibliographie détectée ($count entrées) ; pas encore vérifiée';
  }

  @override
  String get reportBibDisabledHint =>
      'Le contenu généré par IA inclut souvent des références plausibles mais fictives. Vous avez désactivé la vérification des hyperliens dans les paramètres ; vous pouvez la réactiver pour une vérification automatique, ou appuyer ci-dessous pour une vérification unique.';

  @override
  String get reportVerifyNowBibButton => 'Vérifier maintenant (réseau requis)';

  @override
  String get reportBibResultHint =>
      'Comparé au registre public Crossref selon la similarité de l\'auteur, de l\'année et du titre. Ce n\'est pas une garantie absolue — en cas d\'\"incertain\", veuillez vérifier manuellement.';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Confiance élevée : existe probablement$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (enregistré auprès de $journal)';
  }

  @override
  String get reportBibNotFound =>
      'Aucune correspondance proche trouvée — référence potentiellement fictive';

  @override
  String get reportBibUncertain =>
      'Similarité modérée ou échec de connexion — incertain, veuillez vérifier manuellement';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Seules les $max premières entrées ont été vérifiées (total de $count détectées)';
  }

  @override
  String get reportNetworkWarningTitle => 'Connexion réseau faible';

  @override
  String get reportNetworkWarningBody =>
      'Cette application suppose par défaut qu\'une connexion réseau est disponible ; l\'analyse de l\'authenticité des hyperliens et des citations nécessite un accès réseau pour produire des résultats. Impossible d\'établir une connexion — veuillez vérifier votre réseau et réessayer.';

  @override
  String get reportRetryConnectionButton => 'Réessayer la connexion';

  @override
  String get reportAiProbabilityLabel => 'Probabilité IA';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '$total phrases\n$ai probablement IA\n$human probablement humain';
  }

  @override
  String get summaryCardFooter =>
      'L\'inférence IA principale s\'exécute entièrement sur l\'appareil';

  @override
  String get exportReportTitle => 'Rapport de détection TruthLens';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · Page $page / $total';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return 'Analysé : $datetime · $seconds s écoulées';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return 'Verdict global : $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => ' (correction ESL appliquée)';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '$total phrases · $ai probablement IA · $human probablement humain';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'Pour préserver la lisibilité du PDF, seules les $max premières phrases sont affichées (sur un total de $count) ; pour les données complètes de chaque phrase, utilisez plutôt \"$csvLabel\" ou \"$jsonLabel\".';
  }

  @override
  String get pdfSentenceColumnHeader => 'Phrase (avec motifs correspondants)';

  @override
  String composerHeadlineAi(int percent) {
    return 'Ce texte a très probablement été généré par IA (probabilité IA $percent%)';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'Ce texte tend à être généré par IA ; un examen plus approfondi est recommandé (probabilité IA $percent%)';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'Ce texte présente des caractéristiques mixtes humaines et IA (probabilité IA $percent%)';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'Ce texte tend à avoir été écrit par un humain (probabilité IA $percent%)';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'Ce texte a très probablement été écrit par un humain (probabilité IA $percent%)';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return 'La probabilité IA globale dépasse le seuil de $percent% que vous avez défini et a été signalée comme IA.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'La probabilité IA globale est inférieure au seuil de signalement de $percent% que vous avez défini.';
  }

  @override
  String get composerNarrativeTitle => 'Interprétation de l\'analyse';

  @override
  String get composerParaphraseTitle => 'Traces de paraphrase détectées';

  @override
  String get composerParaphraseBody =>
      'Ce texte a peut-être été traité par un outil de paraphrase (par ex. QuillBot, Undetectable.ai) pour échapper à la détection. Bien qu\'il paraisse naturel phrase par phrase, son empreinte statistique globale reste différente de l\'écriture humaine authentique — veuillez y prêter une attention particulière.';

  @override
  String get composerPatternListTitle => 'Principaux motifs d\'écriture IA';

  @override
  String get composerEslTitle => 'Correction du biais ESL (non natif)';

  @override
  String get composerEslBody =>
      'Ce texte pourrait provenir d\'un rédacteur non natif. Une faible perplexité et des motifs de phrases réguliers, courants chez les rédacteurs non natifs, ne sont pas en soi un signe d\'IA, c\'est pourquoi le système a réduit le poids du modèle statistique pour éviter une mauvaise évaluation.';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return 'Ce texte compte $total phrases au total, dont $ai présentent de fortes caractéristiques IA et $human tendent à avoir été écrites par un humain.';
  }

  @override
  String get composerNarrativeAiPattern =>
      'La plupart des phrases sont très régulières en rythme, choix de mots et utilisation de mots de transition — une empreinte courante du texte généré par IA.';

  @override
  String get composerNarrativeMixedPattern =>
      'Le texte contient à la fois des parties régulières et naturellement variées, suggérant un brouillon humain retouché par IA, ou une collaboration humain-IA.';

  @override
  String get composerNarrativeHumanPattern =>
      'La longueur des phrases et le choix des mots montrent une variation naturelle et un style personnel, sans signe clair de régularité IA.';

  @override
  String engineReasonPplLow(String ppl) {
    return 'Faible perplexité du modèle de langage ($ppl) — le texte est très prévisible, un indicateur de génération par IA';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'Forte perplexité du modèle de langage ($ppl), conforme à la nature imprévisible de l\'écriture humaine';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'Perplexité modérée du modèle de langage ($ppl)';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'Longueur de phrase très uniforme (burstiness $value) — un rythme régulier est une empreinte statistique courante du texte généré par IA';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'Variation notable de la longueur des phrases (burstiness $value), conforme au rythme naturel de l\'écriture humaine';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'Faible diversité du vocabulaire (TTR $value) — forte répétition de mots';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'Forte diversité du vocabulaire (TTR $value)';
  }

  @override
  String get engineReasonNeutral =>
      'Les indicateurs statistiques ne montrent aucune tendance claire — verdict neutre maintenu';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return 'Utilisation fréquente de mots de transition génériques ($words), en moyenne $density par phrase — une densité rare dans l\'écriture humaine';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return 'Plusieurs phrases consécutives commencent par le même mot ($count fois) — structure de phrase répétitive';
  }

  @override
  String get engineReasonNoStyleMarkers =>
      'Aucun motif d\'écriture IA notable détecté';

  @override
  String get engineReasonAdversarialNotInstalled =>
      'Le modèle de détection de paraphrase n\'est pas installé ; n\'a pas participé à ce vote';

  @override
  String get engineReasonTransformerNotInstalled =>
      'Aucun modèle installé ou modèle actif non pris en charge ; n\'a pas participé à ce vote';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'Échec du chargement du modèle, n\'a pas participé à ce vote ($error)';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model a évalué que $aiCount phrases sur $total présentent des caractéristiques IA';
  }

  @override
  String get engineReasonAdversarialDetected =>
      'Le modèle adversarial a détecté des traces IA potentiellement supprimées par un outil de paraphrase (par ex. QuillBot / Undetectable.ai)';

  @override
  String get engineReasonAdversarialClean =>
      'Aucune trace claire d\'évasion par paraphrase détectée';

  @override
  String get engineReasonDisabledByUser =>
      'L\'utilisateur a désactivé ce moteur dans les paramètres';

  @override
  String get engineReasonGenericNotInstalled =>
      'Modèle non installé ; n\'a pas participé à ce vote';

  @override
  String patternGenericTransition(String word) {
    return 'mot de transition générique « $word »';
  }

  @override
  String get helpAppBarTitle => 'Guide de l\'utilisateur';

  @override
  String get helpAboutTitle => 'À propos de TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens est une application de détection de contenu multiplateforme (iOS / Android / macOS / Windows) dont l\'inférence IA principale s\'exécute entièrement sur l\'appareil. Quatre sous-modèles indépendants — le classificateur neuronal Transformer, l\'analyse statistique, l\'analyse stylométrique et la détection de paraphrase adversariale — votent ensemble pour déterminer si le texte a été généré par IA, avec des raisons explicables phrase par phrase : pas seulement un pourcentage \"ressemble à de l\'IA\", mais une explication du \"pourquoi\".';

  @override
  String get helpComparisonTitle => 'Comparaison avec les outils leaders';

  @override
  String get helpComparisonDisclaimer =>
      'Cette comparaison a été compilée à partir d\'informations publiques de chaque outil et de perceptions générales du marché, à titre de référence de positionnement fonctionnel uniquement — pas des données de référence vérifiées par un tiers.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'Le traitement de GPTZero s\'effectue principalement dans le cloud et nécessite le téléchargement de votre document ; les quatre moteurs de détection de TruthLens s\'exécutent sur l\'appareil.';

  @override
  String get helpVsGptZero2 =>
      'GPTZero a été pionnier des métriques Perplexity/Burstiness et de la mise en surbrillance des phrases — TruthLens les combine et ajoute un classificateur Transformer, une analyse stylométrique et une défense adversariale, formant un vote d\'ensemble à quatre modèles plutôt qu\'une seule métrique.';

  @override
  String get helpVsGptZero3 =>
      'GPTZero fonctionne par abonnement ; TruthLens ne nécessite aucun abonnement et n\'a aucune limite d\'utilisation.';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin est vendu uniquement aux institutions ; les particuliers ne peuvent pas l\'acheter directement. N\'importe qui peut installer et utiliser TruthLens.';

  @override
  String get helpVsTurnitin2 =>
      'Le processus de décision de Turnitin est presque une boîte noire ; TruthLens fournit la probabilité IA de chaque phrase, les motifs d\'écriture correspondants, ainsi que la répartition des scores et des raisons de chaque moteur.';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin fournit principalement un résultat binaire \"est-ce de l\'IA\" ; TruthLens prend en charge l\'étiquetage humain/IA/mixte au niveau du paragraphe/de la phrase.';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai est un abonnement par document qui nécessite le téléchargement de votre document dans le cloud ; le traitement principal de TruthLens s\'exécute sur l\'appareil sans nécessiter d\'abonnement continu pour la détection.';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai propose des concepts de vérification des faits et d\'analyse de lisibilité ; TruthLens y répond avec un module de caractéristiques stylistiques sur l\'appareil, et peut effectuer une analyse de base même hors ligne.';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks est principalement une API cloud connue pour son faible taux de faux positifs et son solide support multilingue ; TruthLens partage cette philosophie avec un modèle de base multilingue XLM-RoBERTa et un vote d\'ensemble multi-modèles, mais le contenu de votre document n\'est jamais téléchargé sur un serveur quelconque.';

  @override
  String get helpVsCopyleaks2 =>
      'Copyleaks a des limites d\'utilisation d\'API selon le plan ; TruthLens n\'a aucune limite d\'utilisation.';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'La reconnaissance d\'images OCR de Winston AI nécessite le téléchargement d\'images vers le cloud ; TruthLens utilise les frameworks natifs propres à chaque plateforme (Vision sur iOS/macOS, ML Kit sur Android, Windows.Media.Ocr sur Windows) pour reconnaître le texte sur l\'appareil.';

  @override
  String get helpVsWinston2 =>
      'Winston AI est connu pour ses rapports soignés et imprimables ; TruthLens génère dynamiquement la mise en page du rapport via IA (revenant à un modèle si aucun LLM n\'est installé), exportable en PDF/CSV/JSON/PNG.';

  @override
  String get helpAdvantagesTitle => 'Avantages exclusifs de TruthLens';

  @override
  String get helpAdvantage1 =>
      'Vérification de l\'authenticité des hyperliens : vérifie automatiquement si les URL trouvées dans le document sont réellement accessibles ; les liens académiques au format DOI sont en outre vérifiés par rapport au registre public Crossref pour confirmer que la revue indexe effectivement l\'œuvre.';

  @override
  String get helpAdvantage2 =>
      'Vérification de l\'authenticité des citations : même les références sans aucun hyperlien (le style courant \"auteur-année\") peuvent être vérifiées par rapport aux registres bibliographiques pour détecter des citations potentiellement fictives — un signe courant d\'hallucination de l\'IA.';

  @override
  String get helpAdvantage3 =>
      'Correction du biais ESL (non natif) : détecte automatiquement les caractéristiques d\'écriture non natives et réduit le poids du modèle statistique, évitant de classer à tort l\'écriture naturelle non native comme IA.';

  @override
  String get helpAdvantage4 =>
      'Importation de modèles personnalisés : les utilisateurs avancés peuvent importer leurs propres modèles ONNX locaux pour remplacer ou compléter les moteurs de détection intégrés.';

  @override
  String get helpWorkflowTitle => 'Flux de travail opérationnel complet';

  @override
  String get helpWorkflowStep1Title =>
      'Télécharger et mettre à jour les modèles';

  @override
  String get helpWorkflowStep1Body =>
      'Le premier lancement vous guide pour installer le modèle de détection principal ; par la suite, vous pouvez toujours vérifier, télécharger, mettre à jour ou supprimer des modèles depuis \"Paramètres → Gestion des modèles IA\". L\'application vérifie de manière proactive les dernières versions au lancement et affiche un badge sur l\'icône des paramètres et l\'entrée \"Gestion des modèles IA\" si une mise à jour est disponible.';

  @override
  String get helpWorkflowStep2Title =>
      'Choisir les modèles (objectif et impact)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Classificateur IA multilingue (poids 40%) : le principal moteur du verdict global, avec prédiction de la probabilité IA au niveau de la phrase — améliore le plus la précision.';

  @override
  String get helpWorkflowStep2Bullet2 =>
      'Moteur d\'analyse statistique (poids 25%) : analyse par fenêtre glissante de la perplexité et de la burstiness, capturant le rythme régulier et le choix de mots prévisible du texte IA.';

  @override
  String get helpWorkflowStep2Bullet3 =>
      'Analyse stylométrique (poids 20%) : fluidité sémantique, motifs de phrases répétitifs, utilisation de mots de transition — le plus explicable, le plus facile à comprendre le \"pourquoi\".';

  @override
  String get helpWorkflowStep2Bullet4 =>
      'Défense adversariale (poids 15%) : détecte le texte qui a été \"nettoyé\" via des outils de paraphrase (par ex. QuillBot, Undetectable.ai).';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'LLM de rédaction de rapports (optionnel) : une fois installé, le texte du rapport est rédigé dynamiquement par un LLM sur l\'appareil ; sans lui, l\'application revient à un modèle fixe — l\'analyse elle-même n\'est pas affectée.';

  @override
  String get helpWorkflowStep2Bullet6 =>
      'Vous pouvez activer/désactiver les moteurs individuellement et ajuster le seuil de confiance de détection IA dans les paramètres (l\'augmenter réduit la probabilité de classer à tort l\'écriture humaine comme IA).';

  @override
  String get helpWorkflowStep3Title => 'Téléverser un document';

  @override
  String get helpWorkflowStep3Body =>
      'Trois méthodes de saisie : coller du texte directement, OCR d\'image (reconnu sur l\'appareil avec des frameworks natifs propres à chaque plateforme), ou importer un fichier (txt / md / pdf / docx / doc). Le texte doit comporter au moins 40 caractères pour être soumis à l\'analyse.';

  @override
  String get helpWorkflowStep4Title => 'Exécuter l\'analyse';

  @override
  String get helpWorkflowStep4Body =>
      'Appuyez sur \"Démarrer la détection\" et les quatre moteurs s\'exécutent en parallèle, avec la progression affichée en direct à l\'écran. Si des caractéristiques d\'écriture non native sont détectées, la correction du biais ESL est appliquée automatiquement (peut être désactivée dans les paramètres).';

  @override
  String get helpWorkflowStep5Title => 'Consulter et exporter les résultats';

  @override
  String get helpWorkflowStep5Body =>
      'La page du rapport comprend : l\'indicateur global de probabilité IA, la carte thermique au niveau de la phrase, la répartition des scores et des raisons de chaque moteur, l\'authenticité des hyperliens et l\'authenticité des citations. Vous pouvez exporter le rapport PDF complet, les données CSV par phrase, le JSON (pour l\'intégration système), ou une carte récapitulative PNG (pour le partage). Chaque analyse est automatiquement enregistrée dans l\'\"Historique\" pour un examen ultérieur.';

  @override
  String get helpTuningTitle =>
      'Guide de téléchargement et d\'ajustement des modèles (aucune expérience requise)';

  @override
  String get helpTuningStep1Title => 'Ouvrir la gestion des modèles';

  @override
  String get helpTuningStep1Body =>
      'Depuis l\'écran principal, appuyez sur l\'icône d\'engrenage pour ouvrir \"Paramètres\", puis appuyez sur \"Ouvrir\" à côté de \"Gestion des modèles IA\".';

  @override
  String get helpTuningStep2Title => 'Choisissez un modèle pour votre appareil';

  @override
  String get helpTuningStep2Body =>
      'L\'écran suggère automatiquement le niveau de modèle approprié en fonction des capacités de votre appareil (RAM, cœurs CPU), et répertorie chaque variante disponible pour chaque rôle (classificateur multilingue / analyse statistique / défense adversariale / LLM de rapport).';

  @override
  String get helpTuningStep3Title => 'Télécharger et utiliser';

  @override
  String get helpTuningStep3Body =>
      'Appuyez sur \"Télécharger\" à côté du modèle souhaité et attendez la fin — le premier modèle téléchargé sera automatiquement défini comme actif. Si vous avez plusieurs variantes installées, appuyez sur \"Définir comme actif\" pour changer à tout moment ; appuyez sur l\'icône de la corbeille pour supprimer les modèles inutiles et libérer de l\'espace.';

  @override
  String get helpTuningStep4Title => 'Mettre à jour les modèles';

  @override
  String get helpTuningStep4Body =>
      'Lorsqu\'une nouvelle version est disponible, \"Gestion des modèles IA\" et l\'icône d\'engrenage des paramètres affichent un badge — revenez à cet écran pour voir et télécharger la mise à jour (les versions précédemment installées sont conservées à moins que vous ne les supprimiez manuellement).';

  @override
  String get helpTuningStep5Title =>
      'Avancé : importer des modèles personnalisés';

  @override
  String get helpTuningStep5Body =>
      'Si vous disposez déjà, ou avez ajusté, un modèle .onnx compatible ailleurs, vous pouvez l\'importer via \"Paramètres → Importer et tester un modèle ONNX personnalisé\" — vous devrez fournir le fichier du modèle, la configuration de tokenizer correspondante (ou choisir \"aucun\"), et l\'indice de classe IA. Avant l\'importation, l\'application vérifie automatiquement si ce même fichier a déjà été importé, afin d\'éviter les doublons accidentels.';

  @override
  String get helpOfficialLinksTitle =>
      'Liens de téléchargement officiels des modèles';

  @override
  String get helpOfficialLinksHint =>
      'Appuyer sur un élément ouvrira la page officielle de ce modèle dans votre navigateur système.';

  @override
  String get helpLinkRoleTransformer =>
      'Classificateur IA multilingue (Transformer, poids 40%)';

  @override
  String get helpLinkRoleStatistical =>
      'Modèle statistique de perplexité (Statistical, poids 25%)';

  @override
  String get helpLinkRoleAdversarial =>
      'Modèle de détection de paraphrase adversariale (Adversarial, poids 15%)';

  @override
  String get helpLinkRoleLlm => 'LLM de rédaction de rapports (optionnel)';

  @override
  String get privacyAppBarTitle => 'Politique de confidentialité';

  @override
  String privacyPlatformTitle(String platform) {
    return 'Politique de confidentialité $platform';
  }

  @override
  String privacyLastUpdated(String date) {
    return 'Dernière mise à jour : $date';
  }

  @override
  String get privacyIosOverview1 =>
      'TruthLens ne collecte aucune donnée associée à votre identité et n\'utilise aucune donnée à des fins de suivi, ce qui ne nécessite donc pas d\'autorisation de transparence du suivi des applications (ATT).';

  @override
  String get privacyIosOverview2 =>
      'Cette application utilise le sélecteur de fichiers du système pour accéder aux fichiers ou images que vous sélectionnez activement ; elle ne peut pas accéder aux fichiers que vous n\'avez pas sélectionnés (appliqué par le bac à sable des applications iOS).';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLens ne collecte aucune donnée personnelle et ne partage aucune donnée utilisateur avec des tiers.';

  @override
  String get privacyAndroidOverview2 =>
      'Cette application n\'accède au stockage que lorsque vous choisissez activement d\'importer un fichier ou une image ; elle ne parcourt ni n\'accède à d\'autres fichiers en arrière-plan.';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens s\'exécute sous le bac à sable des applications macOS et ne peut accéder qu\'aux fichiers que vous sélectionnez activement via la boîte de dialogue de fichiers du système (files.user-selected.read-write) — elle ne peut pas parcourir ni accéder à d\'autres fichiers ou dossiers par elle-même.';

  @override
  String get privacyMacosOverview2 =>
      'L\'accès réseau (network.client) n\'est utilisé que pour les fonctions énumérées dans \"Comportement de connexion requis\" ci-dessous.';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens est une application de bureau autonome ; les données sont stockées dans votre dossier utilisateur local (par ex. AppData/Documents) et ne sont jamais synchronisées avec le cloud.';

  @override
  String get privacyWindowsOverview2 =>
      'Cette application n\'accède qu\'aux fichiers que vous sélectionnez activement pour l\'importation ; elle ne parcourt pas d\'autres fichiers en arrière-plan.';

  @override
  String get privacyDataHandling1 =>
      'TruthLens n\'a pas de comptes utilisateur, ne nécessite pas de connexion et ne contient aucun SDK publicitaire ou de suivi tiers sous quelque forme que ce soit.';

  @override
  String get privacyDataHandling2 =>
      'Tout contenu de document que vous saisissez, collez ou importez est entièrement analysé par des modèles IA sur votre propre appareil ; il n\'est jamais téléchargé vers TruthLens ou tout serveur tiers.';

  @override
  String get privacyDataHandling3 =>
      'Les résultats d\'analyse et l\'historique ne sont stockés que dans une base de données locale sur votre appareil ; désinstaller l\'application ou effacer l\'historique les supprime complètement — TruthLens ne conserve aucune copie où que ce soit.';

  @override
  String get privacyNetworkIntro =>
      'La détection IA principale de cette application s\'exécute entièrement sur l\'appareil, mais les trois fonctionnalités suivantes nécessitent un accès réseau :';

  @override
  String get privacyNetwork1 =>
      '1. Catalogue et téléchargement de modèles : se connecte à GitHub Releases/Hugging Face pour télécharger le modèle de détection que vous avez choisi — cela ne fait que télécharger le modèle et ne télécharge jamais aucune donnée utilisateur.';

  @override
  String get privacyNetwork2 =>
      '2. Vérification des mises à jour de modèle : au lancement, l\'application se connecte uniquement pour comparer les numéros de version, utilisés pour indiquer si une nouvelle version est disponible.';

  @override
  String get privacyNetwork3 =>
      '3. Vérification de l\'authenticité des hyperliens et des citations : activée par défaut, peut être désactivée dans les paramètres. Lorsqu\'elle est activée, l\'URL ou le texte bibliographique détecté dans le document est envoyé directement à cette URL, ou à l\'API publique Crossref, n\'envoyant que le texte de l\'URL/DOI/citation lui-même — jamais le reste du contenu du document.';

  @override
  String get privacyRightsIntro =>
      'Vous pouvez effacer votre historique d\'analyse local à tout moment dans \"Historique\", désactiver la vérification des hyperliens/citations dans \"Paramètres\", ou supprimer toutes les données locales en';

  @override
  String get privacyRemoveIos => 'supprimant l\'application';

  @override
  String get privacyRemoveAndroid => 'désinstallant l\'application';

  @override
  String get privacyRemoveMacos => 'déplaçant l\'application vers la Corbeille';

  @override
  String get privacyRemoveWindows => 'désinstallant l\'application';

  @override
  String get privacyDisclaimer =>
      'Cette page est une explication de confidentialité rédigée par TruthLens pour refléter le comportement fonctionnel réel, et non un document juridique formel révisé par un avocat ; pour un examen de conformité formel selon les lois de votre région, veuillez consulter un avocat indépendant.';

  @override
  String get privacySectionOverviewIos =>
      'Aperçu (équivalent aux \"étiquettes de confidentialité\" de l\'App Store)';

  @override
  String get privacySectionOverviewAndroid =>
      'Aperçu (équivalent à la divulgation \"Sécurité des données\" de Google Play)';

  @override
  String get privacySectionOverviewMacos =>
      'Aperçu (autorisations du bac à sable des applications)';

  @override
  String get privacySectionOverviewWindows => 'Aperçu';

  @override
  String get privacySectionDataHandling => 'Comment nous traitons vos données';

  @override
  String get privacySectionNetwork => 'Connexions réseau requises';

  @override
  String get privacySectionRights => 'Vos droits';

  @override
  String get privacyGenericPlatformName => 'Cette plateforme';
}
