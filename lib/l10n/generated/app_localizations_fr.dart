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
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

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
  String inputPdfOcrProgress(int page, int total) {
    return 'La couche de texte du PDF n\'est pas disponible ; reconnaissance de la page $page sur $total par OCR…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return '« $fileName » importé avec l\'OCR PDF ($count caractères)';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '« $fileName » n\'a pas de couche de texte fiable. Configurez l\'OCR web ou utilisez une application installée avec OCR natif, puis réimportez-le.';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '« $fileName » nécessite l\'OCR mais dépasse la limite de sécurité de $max pages. Divisez le PDF et importez chaque partie.';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return '« $fileName » n\'a pas pu être lu de manière fiable. Il est peut-être endommagé, protégé par mot de passe ou non pris en charge par le service OCR configuré.';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '« $fileName » est un ancien fichier .doc dont le texte n\'a pas pu être extrait de manière fiable. Enregistrez-le au format .docx dans Word ou exportez-le en PDF, puis réimportez-le.';
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
  String analysisPreliminaryResult(int percent) {
    return 'Résultat préliminaire : probabilité IA $percent %';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return 'Résultat préliminaire : probabilité IA $percent % (affinement…)';
  }

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
  String get modelCatalogLoadFailed =>
      'Impossible de charger le catalogue de modèles';

  @override
  String get modelCatalogEmpty => 'Aucun modèle disponible';

  @override
  String modelDownloadPathChip(String label) {
    return 'Chemin de téléchargement de $label';
  }

  @override
  String get modelDownloadPathModelFile => 'Fichier du modèle';

  @override
  String get modelDownloadPathCopied => 'Chemin de téléchargement copié';

  @override
  String settingsSaveFailed(String error) {
    return 'Échec de l\'enregistrement des paramètres : $error';
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
  String get settingsEngineWeightsTitle => 'Poids des modèles d\'IA';

  @override
  String get settingsEngineWeightsSubtitle =>
      'Définissez l\'influence de chaque moteur sur le résultat combiné. Le total doit atteindre 100 % avant l\'enregistrement.';

  @override
  String get settingsEngineInfoTooltip => 'Rôle de ce moteur';

  @override
  String get settingsEngineTransformerHelp =>
      'Évalue des blocs de paragraphes conservant le contexte avec un Transformer multilingue, puis reporte les scores sur les phrases pour le rapport détaillé. Le poids règle son influence et le signal d\'IA détermine sa contribution réelle.';

  @override
  String get settingsEngineStatisticalHelp =>
      'Mesure perplexité, prévisibilité, burstiness et variation des phrases. La correction ESL peut réduire son poids effectif.';

  @override
  String get settingsEngineStylometryHelp =>
      'Recherche des marqueurs explicables : débuts répétés, transitions formulaires et listes excessives. Sans marqueur, le signal est de 0 %.';

  @override
  String get settingsEngineAdversarialHelp =>
      'Recherche du texte d\'IA paraphrasé ou nettoyé de ses traces. Un score faible indique un résidu faible, pas une détection positive.';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return 'Total : $total % — prêt à enregistrer';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return 'Total : $total % — ajustez exactement à 100 %';
  }

  @override
  String get settingsEngineWeightsSave => 'Enregistrer les poids';

  @override
  String get settingsEngineWeightsSaved => 'Poids enregistrés sur cet appareil';

  @override
  String get settingsEngineWeightsRestoreDefaults => 'Valeurs par défaut';

  @override
  String get engineReasonDisabledByUser =>
      'L\'utilisateur a désactivé ce moteur dans les paramètres';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model : aucune des $total phrases n\'a franchi le seuil IA fort ; le signal faible calibré est de $percent %';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'Signal IA $percent %';
  }

  @override
  String get reportEngineSignalExplanation =>
      'Le signal IA est la probabilité attribuée à ce document par le moteur. Le poids configuré détermine son influence et les points de contribution sont répartis afin que leur somme affichée corresponde exactement à la probabilité IA globale. « Non détecté » signifie sous le seuil de signal fort de 60 %, et non nécessairement une valeur nulle.';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return 'Aucune des $total phrases n’a franchi le seuil fort de paraphrase ; le signal faible calibré est de $percent %';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$count phrases sur $total ont franchi le seuil fort de paraphrase ; le signal calibré du document est de $percent %';
  }

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
  String get modelImportWebUnsupported =>
      'L\'importation de modèles personnalisés n\'est pas encore prise en charge sur la version web. Veuillez utiliser la version application.';

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
  String get reportEngineWeightLabel => 'Pondération';

  @override
  String get privacySealNoticeText =>
      'Sceau de confidentialité TruthLens Zero-Cloud : Traité 100% sur l\'appareil sans stockage cloud.';

  @override
  String get reportModelCalibrationTitle =>
      'Auto-étalonnage du benchmark de modèle';

  @override
  String get reportCommunityDiscoveredTag => 'Communauté (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => 'Détail par moteur';

  @override
  String get reportEngineNotInstalled => 'Non installé';

  @override
  String get reportEngineLoadFailedBadge => 'Échec chargement';

  @override
  String get reportEngineAnalysisLevelTitle => 'Couches d\'analyse des moteurs';

  @override
  String get reportVerdictAiLikelihood => 'Tendance IA';

  @override
  String get reportVerdictHumanLikelihood => 'Écriture humaine';

  @override
  String get reportRadarRoleTransformer => 'Classificateur Transformer';

  @override
  String get reportRadarRoleStatistical => 'Analyse statistique';

  @override
  String get reportRadarRoleStylometry => 'Analyse stylométrique';

  @override
  String get reportRadarRoleAdversarial => 'Défense adversariale';

  @override
  String get reportRadarAxisTransformer => 'Classificateur de phrases';

  @override
  String get reportRadarAxisStatistical => 'Régularité linguistique';

  @override
  String get reportRadarAxisStylometry => 'Style d\'écriture';

  @override
  String get reportRadarAxisAdversarial => 'Défense contre la réécriture';

  @override
  String get reportVerdictBadgeTitle => 'Verdict global';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return 'Probabilité IA globale $percent %';
  }

  @override
  String get reportVerdictHintHuman =>
      'La plupart des signaux des moteurs penchent vers une écriture humaine naturelle.';

  @override
  String get reportVerdictHintLikelyHuman =>
      'Globalement plutôt humain, avec une petite incertitude de modèle restante.';

  @override
  String get reportVerdictHintMixed =>
      'Les signaux des moteurs sont mitigés ; lisez l\'analyse détaillée avec ce résultat.';

  @override
  String get reportVerdictHintLikelyAi =>
      'Plusieurs indicateurs penchent vers l\'IA ; examinez les passages à score élevé.';

  @override
  String get reportVerdictHintAi =>
      'Les signaux globaux penchent fortement vers un contenu généré ou réécrit par IA.';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return 'Verdict global : $verdict ; probabilité IA globale $percent %.';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return 'Signal individuel le plus fort : $label ($percent %), mais le résultat final combine les pondérations des moteurs et n\'est pas la conclusion d\'un seul moteur.';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return 'La plus grande contribution pondérée provient actuellement de $label (environ $points points de pourcentage).';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '« Aucun style d\'écriture IA évident détecté » signifie seulement que le moteur de style n\'a pas trouvé de tournures de phrases fixes ou de mots de transition ; d\'autres modèles peuvent encore augmenter le score global via la régularité linguistique, la classification des phrases ou des signaux de réécriture.';

  @override
  String get reportSynthesisModelGap =>
      'Lorsque certains moteurs n\'ont pas participé, utilisez d\'abord « Compléter les modèles d\'analyse recommandés » dans Gestion des modèles ; si cela échoue encore, l\'analyse détaillée indiquera si la cause est un modèle manquant, un tokenizer non pris en charge, un fichier manquant ou une limite de compatibilité Web/ONNX Runtime.';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label n\'a pas participé à ce vote pondéré, cette dimension est donc affichée à 0 %. $hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return 'Poids du rôle $weight %, contribue à environ $points points de pourcentage au score global$variantText.';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return ' (fusion de $count variantes de modèle)';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label n\'a pas participé à ce vote.';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label n\'a fourni aucune explication textuelle supplémentaire.';
  }

  @override
  String get reportEngineResolutionTransformer =>
      'Solution : téléchargez et activez le Transformer multilingue dans Gestion des modèles ; s\'il est déjà téléchargé, retéléchargez le modèle et le tokenizer.';

  @override
  String get reportEngineResolutionAdversarial =>
      'Solution : retéléchargez le modèle de détection de réécriture et le tokenizer dans Gestion des modèles ; sur le web, mettez à jour vers une version avec le correctif de compatibilité BigInt et relancez l\'analyse.';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason. Cause : l\'ONNX Runtime web a renvoyé un tenseur BigInt que l\'ancien pont ne pouvait pas convertir ; mettez à jour vers la version corrigée et relancez l\'analyse.';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason. Solution : passez à un modèle du catalogue ou retéléchargez le modèle et le tokenizer.';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason. Solution : ouvrez Gestion des modèles, appuyez sur « Compléter les modèles d\'analyse recommandés » et confirmez que le Transformer multilingue est marqué comme actif.';
  }

  @override
  String get reportDetailAnalysisTitle => 'Analyse détaillée';

  @override
  String get reportNoEngineData =>
      'Aucune donnée d\'analyse de moteur pour le moment';

  @override
  String get reportEngineNotParticipated => 'Non impliqué';

  @override
  String get reportAiContentReportTitle => 'Rapport de détection de contenu IA';

  @override
  String reportAnalysisTimeLabel(String time) {
    return 'Temps d\'analyse : $time';
  }

  @override
  String get reportDownloadPdfButton => 'Télécharger le PDF';

  @override
  String get reportSuspiciousLocationsTitle =>
      'Emplacements de contenu suspect';

  @override
  String reportSentenceCount(int count) {
    return '$count phrases';
  }

  @override
  String get reportAiProbabilityPrefix => 'Probabilité IA : ';

  @override
  String get helpAdvantage5 =>
      'Analyse de l\'origine du document : lit le journal d\'édition contenu dans les fichiers .docx / .odt / .doc — temps passé, nombre d\'enregistrements, dispersion des sessions de travail. Cette preuve est indépendante du verdict sur le texte et s\'affiche séparément de la probabilité IA. Les PDF et les images n\'ont pas d\'historique d\'édition propre et ne peuvent donc pas la fournir.';

  @override
  String get helpAdvantage6 =>
      'Il s\'abstient honnêtement quand les éléments manquent : moins de 5 phrases analysables, moins de 100 mots, moins de 2 moteurs participants, ou des moteurs séparés de plus de 60 points de pourcentage donnent « pas assez d\'éléments pour trancher ». La plupart des accusations infondées commencent par un chiffre assuré rendu sur une entrée trop faible.';

  @override
  String get settingsAiSampleTitle => 'Ajouter un échantillon IA';

  @override
  String get settingsAiSampleSubtitle =>
      'L\'étalonnage en arrière-plan ne recueille de lui-même que des échantillons humains. Pour activer les poids appris, il faut aussi des textes dont vous savez qu\'ils viennent d\'une IA : collez-en un ou importez-le, il sera analysé et étiqueté comme échantillon IA immédiatement.';

  @override
  String get settingsAiSampleFromClipboard => 'Coller depuis le presse-papiers';

  @override
  String get settingsAiSampleFromFile => 'Importer un document';

  @override
  String get settingsAiSampleAnalyzing => 'Analyse en cours…';

  @override
  String settingsAiSampleAdded(int count) {
    return 'Échantillon IA ajouté — $count au total';
  }

  @override
  String get settingsAiSampleTooShort =>
      'Trop court pour servir d\'échantillon (au moins 100 mots requis)';

  @override
  String get settingsAiSampleFailed => 'Aucun contenu exploitable trouvé';

  @override
  String get helpFormatCoverageTitle =>
      '2a. Limites de format des indices d\'origine';

  @override
  String get helpFormatCoverage =>
      '**Une limite importante : seuls .docx et .odt portent un journal d\'édition.**\n\n| Source | Journal d\'édition |\n|---|---|\n| .docx / .odt | ✅ oui |\n| .pdf | ❌ le format ne contient aucun historique |\n| .doc (ancien) | ✅ oui (OLE2 SummaryInformation) |\n| .txt / .md | ❌ aucun conteneur |\n| OCR d\'image | ❌ il ne reste que des pixels |\n| Texte collé | ❌ aucun fichier |\n\nCela touche directement le pilier 3 : **seuls les documents dotés d\'un journal d\'édition rejoignent automatiquement la référence à garantie statistique.** Si vous ne recevez que des PDF, cette référence ne grandira jamais ; vous n\'accumulerez que des échantillons indicatifs, sans garantie.\n\nPour que les indices d\'origine et l\'étalonnage automatique fonctionnent réellement, collectez les originaux .docx, .odt ou .doc plutôt que des PDF imprimés ou exportés. C\'est une exigence d\'organisation, non une limite que le logiciel pourrait contourner : le PDF est un format de sortie et n\'enregistre tout simplement pas la façon dont le texte a été écrit.';

  @override
  String provenanceUnsupportedFormat(String format) {
    return 'Le format $format ne transporte aucun historique d\'édition : le journal n\'a pas été effacé, il n\'a jamais existé. Seuls .docx et .odt consignent le temps d\'édition, le nombre d\'enregistrements et les sessions de travail.';
  }

  @override
  String get provenanceStripped =>
      'Ce format est pris en charge, mais aucun journal d\'édition n\'a été trouvé dans le fichier. Cela signifie généralement qu\'il a été enregistré sous un nouveau nom, converti en ligne ou exporté depuis Google Docs — autant d\'actions qui remettent le journal à zéro.';

  @override
  String get provenanceHowToGetRecord =>
      'Pour que les indices d\'origine servent à quelque chose, procurez-vous le **fichier .docx, .odt ou .doc d\'origine** plutôt qu\'un PDF imprimé ou exporté. Seul l\'original conserve l\'historique d\'édition, et lui seul peut rejoindre automatiquement la référence à garantie statistique.';

  @override
  String get calibrationAutoTitle => 'Collecte en arrière-plan';

  @override
  String get calibrationAutoSubtitle =>
      'Les documents analysés rejoignent automatiquement la référence — aucun étiquetage manuel nécessaire.';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return 'Confirmés humains par le journal d\'édition : $auto ; échantillons indicatifs seulement : $observed';
  }

  @override
  String get calibrationAutoWhy =>
      'Seuls les documents dotés d\'un journal d\'édition (temps passé, nombre d\'enregistrements, dispersion des sessions) entrent dans la référence à garantie statistique, car cette preuve est **indépendante du verdict sur le texte**. Étiqueter d\'après le propre verdict de l\'outil reviendrait à corriger sa propre copie : les textes signalés à tort n\'entreraient jamais dans la référence, le seuil se resserrerait à chaque passage, et davantage de travaux authentiques finiraient signalés. Le texte collé n\'a pas de journal d\'édition : il ne compte donc que pour le centile indicatif ci-dessous.';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return 'À titre indicatif : ce score se situe au ${percentile}e centile des $count documents que vous avez analysés (sans garantie statistique)';
  }

  @override
  String get settingsAutoCollectTitle =>
      'Collecter les échantillons d\'étalonnage en arrière-plan';

  @override
  String get settingsAutoCollectSubtitle =>
      'Ajoute automatiquement les documents analysés à la référence. Les étiquettes viennent du journal d\'édition, jamais du verdict de cet outil.';

  @override
  String get settingsStoreTextTitle =>
      'Conserver le texte pour la validation hors ligne';

  @override
  String get settingsStoreTextSubtitle =>
      'Une fois activé, les textes ajoutés à la référence sont conservés localement avec leur contenu intégral, ce qui permet de les exporter ensuite comme corpus pour l\'évaluation hors ligne.';

  @override
  String get settingsStoreTextWarning =>
      'Ces textes sont le plus souvent des travaux d\'autrui, donc sensibles. N\'activez cette option que pendant la constitution effective d\'un corpus de validation, et utilisez « Effacer les textes conservés » dès l\'export terminé. L\'effacement n\'affecte pas la prédiction conforme : elle n\'a besoin que des scores.';

  @override
  String get settingsExportCorpusTitle => 'Exporter le corpus d\'étalonnage';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return 'Prêts à l\'export : $human humains, $ai IA ($required de chaque nécessaires)';
  }

  @override
  String get settingsExportCorpusButton => 'Exporter en JSONL';

  @override
  String get settingsExportCorpusEmpty =>
      'Rien à exporter — activez d\'abord « conserver le texte », puis constituez la référence';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return '$count échantillon(s) exporté(s) ; $skipped ignoré(s) faute de texte conservé';
  }

  @override
  String get settingsClearStoredText => 'Effacer les textes conservés';

  @override
  String get settingsClearStoredTextDone =>
      'Tous les textes conservés ont été effacés. Les scores et l\'étalonnage restent inchangés.';

  @override
  String get helpDesignTitle => 'Principes de conception et limites connues';

  @override
  String get helpShiftTitle =>
      '1. Le changement d\'angle : pas une course à la précision du score';

  @override
  String get helpShiftBody =>
      'Presque tous les détecteurs du marché répondent à la même question : ce texte a-t-il l\'air écrit par une IA ?\n\nC\'est une course aux armements perdue d\'avance. Plus le modèle est puissant, plus sa production se rapproche statistiquement de l\'écriture humaine — et les outils de reformulation progressent bien plus vite que les détecteurs. Sur cette voie, un gros modèle côté serveur perd simplement moins vite.\n\nTruthLens pose une autre question : de quels éléments disposons-nous réellement sur la façon dont ce document a vu le jour, et quelle est la solidité de chacun ?\n\nC\'est passer de la conjecture stylistique à la pesée d\'indices d\'origine, assortie de conclusions statistiquement honnêtes. D\'où le choix assumé de ne pas viser une place dans les classements de précision au score unique, mais d\'exposer chaque indice séparément et de dire clairement quand on ne sait pas. Le vrai avantage de l\'exécution dans votre navigateur n\'est pas la vitesse : c\'est de voir ce qu\'un serveur ne voit jamais — le fichier complet, et la référence que vous avez constituée vous-même.';

  @override
  String get helpPillarsTitle => '2. Les cinq piliers';

  @override
  String get helpPillarsBody =>
      '1. Analyse de l\'origine du document (en service)\nLit le journal d\'édition contenu dans les conteneurs DOCX et ODT : temps total d\'édition, nombre d\'enregistrements, dates de création et de modification, et les marqueurs de session d\'édition (RSID) du corps du texte. Un ou deux RSID sur tout un devoir signifie généralement que le texte est arrivé d\'un bloc ; 3 000 mots pour quatre minutes d\'édition constituent un indice plus dur que n\'importe quel score de perplexité. Cela relève de la preuve d\'origine et s\'affiche séparément de la probabilité IA : jamais fondu dans le score.\n\n2. Étalonnage sur base locale et prédiction conforme (en service)\nAjoutez des textes dont vous êtes sûr qu\'ils ont été écrits par leurs auteurs : le système juge alors d\'après la distribution propre à ce groupe plutôt qu\'un seuil mondial. La prédiction conforme offre une garantie sans hypothèse de distribution : si la référence et l\'échantillon testé sont échangeables, le taux de faux positifs reste sous l\'alpha que vous fixez. C\'est la clé pour réduire les erreurs sur l\'écriture non native, et une chose que les produits commerciaux ne peuvent pas faire : ils n\'ont pas de travaux de référence des personnes que vous évaluez.\n\n3. Poids de moteurs appris (en service)\nDès que la référence contient des échantillons humains et IA, le système mesure la capacité de chaque moteur à séparer les deux groupes (taille d\'effet, d de Cohen) et propose des poids en conséquence, remplaçant les proportions fixes réglées à la main. Rien ne change tant que vous n\'avez pas cliqué sur Appliquer : les réglages ne sont jamais modifiés en silence.\n\n4. Perplexité croisée Binoculars (cœur de calcul terminé, pas encore actif)\nLa perplexité brute traite la prévisibilité d\'un texte comme si elle mesurait sa parenté avec l\'IA — d\'où précisément ses faux positifs systématiques sur une écriture non native au style simple. Binoculars mesure cette prévisibilité relativement à l\'ampleur du désaccord entre deux modèles. Les mathématiques sont implémentées et testées, mais l\'activation exige encore une paire de petits modèles de langue exécutables dans un navigateur, plus une validation sur données annotées.\n\n5. Détection de filigrane (vérifié, non réalisable, non développé)\nLa détection SynthID-Text est liée aux clés : le détecteur doit calculer avec les mêmes clés qu\'à la génération, or les clés de production de Google ne sont pas publiques. Dans un navigateur, cela ne se déclencherait jamais sur des sorties réelles de ChatGPT, Claude ou Gemini : ce serait une fonction qui ne s\'active jamais tout en vous laissant croire que les filigranes sont vérifiés. Elle a donc été délibérément écartée.';

  @override
  String get helpCascadeTitle => '3. La cascade par paliers et l\'abstention';

  @override
  String get helpCascadeBody =>
      'Pour rester rapide dans le budget de calcul limité d\'un navigateur, l\'analyse procède par paliers : signaux bon marché d\'abord, coûteux seulement si nécessaire.\n\nPalier 0  Preuves d\'origine du document (coût quasi nul)\nPalier 1  Traits statistiques et stylométriques (moteurs existants, peu coûteux)\nPalier 2  Classifieur Transformer phrase par phrase\nPalier 3  Perplexité croisée (le plus coûteux, uniquement si le tableau reste flou)\n\nLe résultat passe ensuite à l\'étalonnage local, qui produit une conclusion assortie d\'une garantie de faux positifs — ou une abstention explicite.\n\n[Pourquoi l\'abstention compte]\nLa plupart des accusations infondées naissent d\'un chiffre assuré rendu sur une entrée trop courte ou trop faible pour le soutenir. Cet outil affiche franchement « Pas assez d\'éléments pour trancher » plutôt que de forcer un score lorsque :\n\n- moins de 5 phrases analysables\n- moins de 100 mots\n- moins de 2 moteurs ont participé\n- les moteurs divergent de plus de 60 points de pourcentage (en faire la moyenne ne veut plus rien dire)\n\nEn cas d\'abstention, le score complet et les preuves par phrase restent affichés plus bas à titre indicatif — mais ne les prenez pas pour une conclusion. Un système capable de dire « je ne sais pas » mérite plus de confiance que celui qui vous tend toujours un chiffre.';

  @override
  String get helpRisksTitle => '4. Risques à regarder en face';

  @override
  String get helpRisksBody =>
      'Chacun des points ci-dessous est une limite réelle de cet outil. Pesez-les avant d\'agir sur ce qu\'il rapporte.\n\n1. Les preuves d\'origine peuvent être effacées ou falsifiées\nEnregistrer sous, convertir en ligne, exporter depuis Google Docs ou copier dans un nouveau fichier remettent le journal d\'édition à zéro. Un signal n\'est qu\'un élément à charge parmi d\'autres, et son absence ne prouve certainement pas qu\'un humain a écrit le texte.\n\n2. La garantie conforme repose sur l\'échangeabilité\nElle ne tient que si les échantillons de référence et le texte examiné proviennent du même groupe de personnes pour le même type d\'exercice. Si l\'écriture d\'un auteur a nettement progressé, ou si le type de tâche a complètement changé, l\'hypothèse tombe et la référence doit être reconstituée.\n\n3. Le jeu de référence lui-même peut être contaminé\nSi les travaux servant de référence ont en réalité été rédigés par une IA, tout l\'étalonnage est faussé. Les échantillons de référence doivent être recueillis en conditions contrôlées, par exemple des travaux réalisés sous surveillance.\n\n4. Les petits modèles dans le navigateur sont moins précis que les gros côté serveur\nC\'est le prix inévitable que le choix du tout-Web paie pour la confidentialité. La valeur de cet outil n\'est pas un score unique plus juste, mais le fait d\'être explicable, étalonnable et assez honnête pour s\'abstenir.\n\n5. Aucun score ne doit à lui seul fonder une accusation\nLisez-le toujours avec les preuves phrase par phrase, l\'origine du document et ce que vous savez déjà de cette personne en particulier. Cet outil est conçu pour appuyer une conversation que vous menez, non pour rendre un verdict à votre place.';

  @override
  String get calibrationAddHuman =>
      'Ajouter comme référence écrite par un humain';

  @override
  String get calibrationAddAi => 'Ajouter comme échantillon IA connu';

  @override
  String calibrationCounts(int human, int ai) {
    return 'Référence : $human humains, $ai IA';
  }

  @override
  String get learnedWeightsTitle => 'Poids de moteurs appris';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return 'Vous avez $human échantillons humains et $ai IA. Il en faut au moins $required par classe pour apprendre des poids fiables ; d\'ici là, vos poids manuels restent en vigueur.';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return 'Les poids peuvent désormais être appris à partir de vos $human échantillons humains et $ai IA.';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine : poids suggéré $weight % (séparation $effect)';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return 'À noter : $engine inverse les deux groupes — les échantillons IA ont obtenu des scores plus bas, et non plus hauts — son poids tombe donc à zéro. Cela signifie généralement que ce moteur ne convient pas à ce type de texte.';
  }

  @override
  String get learnedWeightsApply => 'Appliquer les poids appris';

  @override
  String get learnedWeightsApplied => 'Poids appris appliqués';

  @override
  String get learnedWeightsExplain =>
      'Les poids découlent de la capacité de chaque moteur à séparer vos échantillons humains de vos échantillons IA (taille d\'effet, d de Cohen) : plus les deux groupes sont éloignés et plus chacun est stable, plus le moteur gagne du poids. Cela remplace les poids fixes réglés à la main, pour que l\'ensemble colle au type de texte que vous traitez réellement.';

  @override
  String get calibrationTitle => 'Étalonnage sur base locale';

  @override
  String get calibrationEmpty =>
      'Aucun jeu de référence pour l\'instant. Ajoutez quelques textes dont vous êtes sûr qu\'ils ont été écrits par leurs auteurs — des travaux réalisés sous surveillance, par exemple — et le système pourra juger d\'après la distribution propre à ce groupe plutôt qu\'un seuil mondial uniforme. C\'est précisément ce qui fait chuter les faux positifs sur l\'écriture non native.';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return 'Le jeu de référence compte $count échantillon(s) ; pour qu\'un plafond de faux positifs de $alpha % tienne réellement, il en faut au moins $required. D\'ici là, les chiffres sont indicatifs et rien n\'est signalé sur cette base.';
  }

  @override
  String calibrationFlagged(int alpha) {
    return 'Avec un plafond de faux positifs de $alpha %, ce texte **est signalé**.';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return 'Avec un plafond de faux positifs de $alpha %, ce texte **n\'est pas signalé**.';
  }

  @override
  String calibrationPValue(String value, int count) {
    return 'Valeur p conservatrice $value (face à $count échantillons de référence)';
  }

  @override
  String calibrationPercentile(int percentile) {
    return 'Le score se situe au ${percentile}e centile du jeu de référence';
  }

  @override
  String get calibrationCaveat =>
      'Cette garantie suppose que les échantillons de référence et le texte examiné sont échangeables : même groupe de personnes, même type d\'exercice. Si l\'écriture d\'un auteur a nettement progressé, ou si le type de tâche a complètement changé, l\'hypothèse tombe et il faut reconstituer le jeu de référence. À noter aussi : si les textes de référence ont eux-mêmes été rédigés par une IA, tout l\'étalonnage est faussé — recueillez-les en conditions contrôlées.';

  @override
  String get calibrationAddButton => 'Ajouter ce texte à la référence';

  @override
  String calibrationAdded(int count) {
    return 'Ajouté au jeu de référence — $count échantillon(s) désormais';
  }

  @override
  String get settingsCalibrationTitle => 'Jeu de référence local';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return '$count échantillon(s) conservés ($required requis avec cet α)';
  }

  @override
  String get settingsCalibrationClear => 'Vider le jeu de référence';

  @override
  String get settingsCalibrationCleared => 'Jeu de référence vidé';

  @override
  String get settingsAlphaTitle => 'Plafond de faux positifs (α)';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return 'Actuellement $alpha % — plus bas est plus strict, mais exige davantage d\'échantillons (au moins $required)';
  }

  @override
  String get abstentionHeadline => 'Pas assez d\'éléments pour trancher';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return 'Seulement $count phrase(s) analysable(s), alors qu\'il en faut au moins $required. À cette longueur, les signaux statistiques et phrase par phrase ne pèsent rien, et en tirer un score de force ne ferait qu\'induire en erreur.';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return 'Le texte compte $count mots, il en faut au moins $required. En dessous, n\'importe quel trait d\'écriture peut relever du hasard.';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return 'Seuls $available moteurs sur $total ont participé : impossible de recouper sous un autre angle. Complétez les modèles manquants dans la gestion des modèles, puis relancez.';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return 'Les moteurs sont séparés de $spread points de pourcentage — assez pour qu\'en faire la moyenne ne veuille plus rien dire. Appuyez-vous plutôt sur les preuves phrase par phrase et l\'origine du document, et jugez vous-même.';
  }

  @override
  String get abstentionNoEvidenceFound =>
      'All engines ran, but none found usable evidence. The low fallback score is diagnostic output, not evidence that a person wrote the text.';

  @override
  String abstentionSingleWeakEvidenceSource(int count) {
    return 'Only $count engine found usable evidence, and the overall score is still below the AI threshold. Treat this as weak coverage, not as evidence that a person wrote it.';
  }

  @override
  String get abstentionScoreStillShown =>
      'Le score complet et les preuves par phrase restent affichés ci-dessous à titre indicatif. Ne les prenez pas pour une conclusion.';

  @override
  String get provenanceTitle => 'Indices sur l\'origine du document';

  @override
  String get provenanceRiskHigh =>
      'L\'historique de modification est nettement inhabituel';

  @override
  String get provenanceRiskMedium =>
      'Quelque chose cloche dans l\'historique de modification';

  @override
  String get provenanceRiskLow => 'L\'historique de modification paraît normal';

  @override
  String get provenanceRiskUnknown =>
      'Aucun historique de modification disponible';

  @override
  String get provenanceNoMetadata =>
      'Cette entrée ne contient aucun historique de modification — texte collé, PDF, ou fichier dont l\'enregistrement a été effacé. Rien à juger côté origine ici, seulement l\'analyse du texte.';

  @override
  String provenanceEditingDuration(int minutes) {
    return 'Temps d\'édition enregistré dans le fichier : $minutes minutes';
  }

  @override
  String provenanceRevisionCount(int count) {
    return 'Nombre d\'enregistrements : $count';
  }

  @override
  String provenanceApplication(String name) {
    return 'Produit avec : $name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return 'Le corps du texte ne porte que $count marqueur(s) de session d\'édition pour $words mots. Écrire en réfléchissant en laisse d\'ordinaire des dizaines ; une telle concentration signifie généralement que le texte est arrivé d\'un seul bloc — collé, par exemple.';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words mots pour $minutes minutes d\'édition enregistrée, soit $wpm mots par minute, bien au-delà de ce que l\'on tient en écrivant réellement.';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return 'Le fichier n\'enregistre presque aucun temps d\'édition, alors que le corps compte $words mots.';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return '$words mots de contenu, enregistrés seulement $count fois.';
  }

  @override
  String get provenanceCaveat =>
      'À savoir : ces enregistrements peuvent être effacés ou remis à zéro — enregistrer sous, convertir en ligne, exporter depuis Google Docs ou copier dans un nouveau fichier les annulent tous. Un signal est donc un élément à charge parmi d\'autres, jamais une conclusion à lui seul ; et son absence ne prouve pas qu\'un humain a écrit le texte.';

  @override
  String get telemetrySummaryTitle => 'Ce que ça donne';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '$engines moteurs sur $total ont terminé. La probabilité IA globale est de $percent %, ce qui donne « $verdict ».';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return 'Les moteurs sont plutôt d\'accord (le plus haut à $high %, le plus bas à $low %), la conclusion tient donc bien.';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return 'Les moteurs divergent : $highLabel donne $high % alors que $lowLabel n\'en donne que $low %. Dans ce cas, ne vous fiez pas au seul score global — les preuves phrase par phrase ci-dessous en disent bien plus.';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return 'Ce qui tire le score, c\'est surtout $label, pour environ $points points de pourcentage.';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return 'Sur les $total phrases passées en revue, aucune n\'a franchi le seuil de signal IA fort.';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return 'Sur $total phrases, $count ont franchi le seuil de signal IA fort — à relire une par une.';
  }

  @override
  String get telemetrySummaryAdviceHuman =>
      'Ça se lit comme un texte écrit par une personne ; rien ici ne demande de vérification.';

  @override
  String get telemetrySummaryAdviceMixed =>
      'Ce texte est en zone grise. Trancher sur le seul score serait risqué : croisez-le avec les preuves par phrase et ce que vous savez de la provenance du document.';

  @override
  String get telemetrySummaryAdviceAi =>
      'Les signaux pointent nettement vers une génération ou une réécriture par IA. Vérifiez les phrases signalées une par une avant de décider.';

  @override
  String telemetrySummaryModelGap(int count) {
    return 'Par ailleurs, $count moteur(s) n\'ont pas participé cette fois : prenez la confiance avec un peu de recul. Complétez-les dans la gestion des modèles et relancez pour affiner.';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'Probabilité IA < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'Probabilité IA $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'Probabilité IA ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return 'Confiance faible : le poids de modèle disponible est inférieur à 60 % (seuil $threshold %). $available/$total moteurs ont participé. Consultez l\'analyse détaillée des moteurs.';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return 'Confiance élevée : $available/$total modèles de détection ont atteint un consensus ($threshold % ou plus du poids est d\'accord avec ce verdict).';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return 'Confiance faible ($available/$total)';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return 'Confiance élevée ($available/$total)';
  }

  @override
  String get reportMetricAiSentenceRatio => 'Part des phrases à signal IA fort';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count phrases sur $total ont franchi le seuil de signal fort de 60 %';
  }

  @override
  String get reportMetricElapsed => 'Temps d\'analyse';

  @override
  String get reportMetricElapsedNormal => '0,5-5 s normal';

  @override
  String get reportMetricReliability => 'Fiabilité';

  @override
  String get reportReliabilityLow => 'Faible';

  @override
  String get reportReliabilityHigh => 'Élevée';

  @override
  String get reportReliabilityNeedsReview => 'Nécessite une vérification';

  @override
  String get reportReliabilityHighTrust => 'Très fiable';

  @override
  String get reportSentenceAnalysisTitle => 'Analyse au niveau de la phrase';

  @override
  String get suspiciousFilterAll => 'Suspect';

  @override
  String get suspiciousFilterHigh => 'Élevé';

  @override
  String get suspiciousFilterMedium => 'Moyen';

  @override
  String get suspiciousExcludedTooltip =>
      'Les lettres isolées, les numéros de page, les numéros de section et les fragments OCR/PDF trop courts ont été exclus.';

  @override
  String suspiciousCount(int count) {
    return '$count éléments';
  }

  @override
  String get suspiciousEmpty => 'Aucun contenu suspect';

  @override
  String get suspiciousRiskHigh => 'Élevé';

  @override
  String get suspiciousRiskMedium => 'Moyen';

  @override
  String get suspiciousReasonHighModelSignals =>
      'Plusieurs signaux de modèle penchent fortement vers l\'IA';

  @override
  String get suspiciousReasonSentenceSignal =>
      'Le signal du modèle au niveau de la phrase est élevé';

  @override
  String suspiciousOriginalLocation(String location) {
    return 'Emplacement d\'origine $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return 'Emplacement d\'origine $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return 'Phrase n° $number';
  }

  @override
  String get suspiciousEvidenceLabel => 'Preuve :';

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
  String get reportBibRecheckAllUnreliableButton =>
      'Revérifier toutes les citations non vérifiées';

  @override
  String get reportBibRecheckOneTooltip => 'Revérifier cette citation';

  @override
  String get reportBibResultHint =>
      'Comparé au registre public Crossref selon la similarité de l\'auteur, de l\'année et du titre. Ce n\'est pas une garantie absolue — en cas d\'\"incertain\", veuillez vérifier manuellement.';

  @override
  String reportBibVerificationSource(String source) {
    return 'Source de vérification : $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'Vérifier manuellement sur Google Scholar';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Confiance élevée : existe probablement$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (enregistré auprès de $journal)';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'Nom de revue différent : le document indique « $reported », tandis que le registre vérifié indique « $registered ». Veuillez vérifier cette citation.';
  }

  @override
  String get reportBibNotFound =>
      'Aucune correspondance proche trouvée — référence potentiellement fictive';

  @override
  String get reportBibUncertain =>
      'Suspect : non vérifié par correspondance de registre';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Seules les $max premières entrées ont été vérifiées (total de $count détectées)';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return '$count terminés ; les résultats continueront de se mettre à jour.';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return 'Progression $completed/$total, $current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return 'Actuel : $text';
  }

  @override
  String get reportBibProgressFinalizing => 'Finalisation des résultats';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base : candidat similaire trouvé « $candidate », mais l\'auteur, l\'année ou le titre n\'ont pas atteint le seuil de correspondance fiable.';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base : les sources de vérification n\'ont renvoyé aucune réponse fiable ou l\'entrée manque d\'informations suffisantes ; TruthLens ne considère pas cette citation comme vérifiée.';
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
    return 'La probabilité IA globale dépasse le seuil fixe de $percent% et a été signalée comme IA.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'La probabilité IA globale est inférieure au seuil fixe de signalement de $percent%.';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return 'La probabilité IA globale est de $aiPercent %, ce qui atteint le seuil fixe de signalement IA de $thresholdPercent %, le rapport marque donc ce texte comme IA. Examinez les preuves au niveau des phrases et les raisons des moteurs avant de prendre une décision finale.';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'La probabilité IA globale est de $aiPercent %, en dessous du seuil fixe de signalement IA de $thresholdPercent %, le rapport ne marque donc pas formellement ce texte comme IA. La probabilité et les preuves sont tout de même affichées pour examen.';
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
  String engineReasonStatisticalSummaryAi(String percent) {
    return 'Résumé statistique global : penche vers des caractéristiques générées par IA (probabilité IA $percent %)';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return 'Résumé statistique global : penche vers une écriture humaine naturelle (probabilité IA $percent %)';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return 'Résumé statistique global : les indicateurs s\'équilibrent, montrant des caractéristiques neutres (probabilité IA $percent %)';
  }

  @override
  String get reportFormulaTitle =>
      'Transparence du calcul pondéré et détail des paramètres';

  @override
  String get reportFormulaExplanation =>
      'La probabilité IA globale est calculée comme une moyenne pondérée des probabilités de tous les moteurs actifs :';

  @override
  String get reportFormulaActiveEngines =>
      'Moteurs actifs et pondérations attribuées';

  @override
  String get reportFormulaCalculation => 'Calcul de la formule pondérée';

  @override
  String get reportFormulaFinalResult => 'Probabilité IA pondérée finale';

  @override
  String get reportFormulaEslApplied =>
      'Ajustement pour l\'écriture non native ESL appliqué (poids du modèle statistique réduit de moitié)';

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
  String engineReasonAssistantResponseArtifact(int count) {
    return 'Detected $count conversational assistant-response artifact(s), such as addressing the requester or offering to revise the requested text';
  }

  @override
  String get engineReasonAdversarialNotInstalled =>
      'Le modèle de détection de paraphrase n\'est pas installé ; n\'a pas participé à ce vote';

  @override
  String get engineReasonTransformerNotInstalled =>
      'Aucun modèle installé ou modèle actif non pris en charge ; n\'a pas participé à ce vote';

  @override
  String get modelRepairNoActiveVariant =>
      'Aucun modèle actif trouvé ; téléchargez un modèle recommandé dans Gestion des modèles.';

  @override
  String get modelRepairCustomRemoved =>
      'Le modèle personnalisé qui n\'a pas pu être chargé a été supprimé. Les modèles personnalisés ne peuvent pas être retéléchargés automatiquement ; veuillez réimporter le modèle et le tokenizer.';

  @override
  String get modelRepairNoSource =>
      'Le fichier du modèle qui n\'a pas pu être chargé a été supprimé, mais aucune source de catalogue n\'est actuellement disponible pour le retélécharger ; veuillez retélécharger un modèle recommandé dans Gestion des modèles.';

  @override
  String modelRepairRedownloaded(Object name) {
    return 'Le fichier du modèle semble corrompu ou incompatible ; $name a été retéléchargé automatiquement. Veuillez relancer l\'analyse.';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return 'Le fichier du modèle qui n\'a pas pu être chargé a été supprimé, mais le retéléchargement automatique n\'a pas abouti ; vérifiez votre connexion réseau et retéléchargez $name dans Gestion des modèles.';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      'Aucun modèle Transformer actif trouvé ; téléchargez-en un ou activez-le dans Gestion des modèles';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return 'Le type de tokenizer du modèle actif n\'est pas pris en charge ($tokenizer) ; passez à un modèle compatible avec bert-wordpiece ou roberta-bpe';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Chemin du modèle Transformer ou du tokenizer manquant ; retéléchargez-le dans Gestion des modèles';

  @override
  String get engineTransformerMissingFiles =>
      'Le fichier du modèle Transformer ou du tokenizer n\'existe pas ; retéléchargez-le dans Gestion des modèles';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'Version d\'opset ONNX non prise en charge (cette version du modèle est trop récente ; mettez à jour l\'application) : $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Format du tokenizer corrompu : $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      'Le chargement ou l\'inférence du modèle a échoué, et la réparation automatique n\'a pas abouti ; retéléchargez le modèle Transformer actif et le tokenizer dans Gestion des modèles.';

  @override
  String get engineAdversarialNoActiveVariant =>
      'Aucun modèle de détection de réécriture actif trouvé';

  @override
  String get engineAdversarialMissingFiles =>
      'Le fichier du modèle ou du tokenizer n\'existe pas ; retéléchargez-le dans Gestion des modèles';

  @override
  String get engineAdversarialRepairFailed =>
      'Le chargement ou l\'inférence du modèle a échoué, et la réparation automatique n\'a pas abouti ; retéléchargez le modèle de détection de réécriture et le tokenizer dans Gestion des modèles.';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return 'Le modèle n\'a pas participé à ce vote. $error';
  }

  @override
  String get patternNotAnalyzable =>
      'Segment trop court ou probable bruit PDF/OCR ; aucune évaluation IA au niveau de la phrase effectuée';

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
      'TruthLens est un détecteur de contenu IA qui fonctionne **entièrement dans votre navigateur**. Quatre moteurs indépendants — un classifieur neuronal Transformer, l\'analyse statistique, la stylométrie et la détection de réécriture adverse — votent avec des poids pour déterminer si un texte a été généré par une IA, et votre document ne quitte jamais la machine.\n\nLe rapport exprime son verdict sous forme de probabilité IA classée en cinq paliers fixes (moins de 20 %, 20–40 %, 40–60 %, 60–80 %, 80 % et plus), accompagné des preuves phrase par phrase, de la contribution de chaque moteur, des indices d\'origine du document et du nom de fichier à l\'import. Les seuils ne sont pas réglables : un même document tombe donc toujours dans le même palier. Quand les éléments sont trop minces — trop peu de phrases ou de mots, ou des moteurs trop divergents — il le dit franchement au lieu de forcer un score.';

  @override
  String get helpComparisonTitle => 'Comparaison avec les outils leaders';

  @override
  String get helpComparisonDisclaimer =>
      'Cette comparaison a été compilée à partir d\'informations publiques de chaque outil et de perceptions générales du marché, à titre de référence de positionnement fonctionnel uniquement — pas des données de référence vérifiées par un tiers.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero effectue l\'essentiel du travail dans le cloud et exige l\'envoi du document ; les quatre moteurs de TruthLens s\'exécutent dans votre propre navigateur et le contenu n\'est envoyé nulle part.';

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
      'Originality.ai facture à la pièce sur abonnement et exige un envoi vers le cloud ; TruthLens réalise l\'essentiel dans le navigateur, sans abonnement ni limite d\'usage.';

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
      'L\'OCR d\'images de Winston AI envoie la photo dans le cloud ; l\'OCR de TruthLens privilégie un serveur local que vous configurez et ne bascule vers le cloud que si vous fournissez vous-même une clé d\'API Gemini — recourir ou non au cloud reste votre décision.';

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
  String helpWorkflowStepLabel(int step) {
    return 'Étape $step';
  }

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
      'Classificateur IA multilingue (poids 40%) : analyse des blocs de paragraphes limités pour conserver le contexte, puis reporte les probabilités sur les phrases.';

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
      'Vous pouvez activer/désactiver les moteurs individuellement et ajuster leurs poids dans les paramètres. Les cinq paliers de verdict utilisent des seuils fixes (20 % / 40 % / 60 % / 80 %) et ne sont pas modifiables : un même document donne donc le même verdict pour tout le monde.';

  @override
  String get helpWorkflowStep3Title => 'Téléverser un document';

  @override
  String get helpWorkflowStep3Body =>
      'Trois entrées possibles : coller du texte, reconnaître une image par OCR, ou importer un document (txt / md / pdf / docx / doc / odt). L\'import PDF compare deux analyseurs de couche texte et écarte les sorties illisibles ; les PDF numérisés sont reconnus page par page lorsque l\'OCR est disponible. À l\'import, le nom du fichier apparaît sous l\'intitulé de saisie et sur sa propre ligne dans le titre du rapport ; en cas de collage ou de saisie, il reste vide.\n\nL\'OCR privilégie le serveur local que vous configurez et n\'utilise le cloud que si vous fournissez vous-même une clé d\'API Gemini.';

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
  String get helpWorkflowStep1ChipOnboarding => 'Premier lancement';

  @override
  String get helpWorkflowStep1ChipModelManager => 'Gestion des modèles';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => 'Vérification automatique';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => 'Analyse statistique (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => 'Stylométrie (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => 'Défense adversariale (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => 'LLM de rapport (facultatif)';

  @override
  String get helpWorkflowStep3ChipPaste => 'Coller le texte';

  @override
  String get helpWorkflowStep3ChipImageOcr => 'OCR d’image';

  @override
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation =>
      'Isoler code/formules';

  @override
  String get helpWorkflowStep4ChipEnsemble => 'Ensemble de 4 moteurs';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'Progression en direct';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'Correction ESL';

  @override
  String get helpWorkflowStep4ChipStoppable => 'Peut être arrêté à tout moment';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'Jauge IA globale';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap =>
      'Carte thermique par phrase';

  @override
  String get helpWorkflowStep5ChipCitationVerification =>
      'Vérification des citations';

  @override
  String get helpWorkflowStep5ChipExportFormats =>
      'Export PDF / CSV / JSON / PNG';

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
  String get privacyWebOverview1 =>
      'TruthLens fonctionne entièrement comme une application web dans l\'onglet de votre navigateur. Rien à installer ; le texte du document et les résultats d\'analyse ne quittent jamais votre appareil, et les modèles de détection téléchargés sont mis en cache uniquement dans le stockage isolé propre à votre navigateur (OPFS), pas sur un serveur.';

  @override
  String get privacyWebOverview2 =>
      'La page ne lit un fichier, une image ou le contenu du presse-papiers que lorsque vous choisissez activement de l\'importer, de le numériser ou de le coller ; elle ne lit jamais d\'autres onglets, les données d\'autres sites ou des fichiers que vous n\'avez pas sélectionnés.';

  @override
  String get privacySectionOverviewWeb => 'Aperçu';

  @override
  String get privacyRemoveWeb =>
      'en effaçant les données de ce site dans les paramètres de votre navigateur (ou simplement en fermant l\'onglet, puisque rien n\'est stocké sur un serveur)';

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
  String get privacyNetwork4 =>
      '4. Solution de repli OCR web : uniquement dans la version web, l\'OCR utilise d\'abord un serveur OCR local si configuré. Si vous choisissez de saisir une clé API Gemini, les images sélectionnées et les pages PDF rendues nécessitant l\'OCR sont envoyées directement depuis votre navigateur à l\'API Gemini de Google ; la clé est stockée uniquement dans le stockage local de ce navigateur.';

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

  @override
  String settingsVersionSubtitle(String version, String build) {
    return 'Version $version (Build $build) · Moteur privé privilégiant le traitement local';
  }

  @override
  String get webOcrSettingsTitle => 'Paramètres OCR Web';

  @override
  String get webOcrPurpose =>
      'Reconnaît le texte imprimé ou manuscrit d\'une image avant l\'analyse.';

  @override
  String get webOcrGeminiKeyTitle => 'Clé API Gemini (facultative)';

  @override
  String get webOcrGetKeyButton => 'Obtenir une clé';

  @override
  String get webOcrGeminiDescription =>
      'Utilisée uniquement si le serveur OCR local est indisponible. La clé reste dans ce navigateur.';

  @override
  String get webOcrLocalServerTitle => 'Serveur OCR local (recommandé)';

  @override
  String get webOcrLocalServerDescription =>
      'Exécute l\'OCR sur votre ordinateur avec Apple Vision sous macOS ou Windows OCR sous Windows. Saisissez le point d\'accès local ci-dessous.';

  @override
  String get webOcrSetupGuideButton => 'Guide de configuration';

  @override
  String get webOcrPriorityTitle => 'Ordre de reconnaissance';

  @override
  String get webOcrPriorityDescription =>
      '1. Serveur OCR local si une URL est définie\n2. Gemini si une clé API est définie\n3. Diagnostic précis si les deux méthodes échouent';

  @override
  String get webOcrSetupGuideTitle => 'Configurer le serveur OCR local';

  @override
  String get webOcrSetupGuideBody =>
      '1. Sélectionnez Ouvrir le projet OCR ci-dessous.\n2. macOS : téléchargez setup_and_run_ocr.sh, ouvrez Terminal et exécutez : bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows : téléchargez setup_and_run_ocr.bat, double-cliquez dessus et autorisez l\'installation.\n4. Attendez que l\'installateur indique que l\'OCR est prêt ; le démarrage automatique sera aussi configuré.\n5. Saisissez http://127.0.0.1:5001/ocr puis sélectionnez Tester la connexion.\n6. Ouvrez OCR d\'image et choisissez une image nette.\n\nPour utiliser 127.0.0.1, le navigateur et le serveur doivent fonctionner sur le même ordinateur. En cas d\'échec, vérifiez l\'installation, le port 5001 et la terminaison /ocr.';

  @override
  String get webOcrOpenProjectButton => 'Ouvrir le projet OCR';

  @override
  String get webOcrTestServerButton => 'Tester la connexion';

  @override
  String get webOcrTestServerMissingUrl =>
      'Saisissez d\'abord l\'URL du serveur OCR local.';

  @override
  String get webOcrTestServerSuccess =>
      'Le serveur OCR local fonctionne et est prêt.';

  @override
  String get webOcrTestServerFailure =>
      'Le serveur OCR local est inaccessible. Vérifiez le guide, le pare-feu et l\'URL.';

  @override
  String get workspaceModeSectionTitle => 'Mode d’espace de travail';

  @override
  String get workspaceModeSectionSubtitle =>
      'Choisissez comment la source, l\'analyse en direct et les preuves partagent le même espace.';

  @override
  String get workspaceModeOriginal => 'Mise en page d’origine';

  @override
  String get workspaceModeAuto => 'Automatique';

  @override
  String get workspaceModeCommandGrid => 'Grille de commandement';

  @override
  String get workspaceModeTimeline => 'Chronologie de mission';

  @override
  String get workspaceModeEvidence => 'Canevas de preuves';

  @override
  String get workspaceModeCosmicFuture => 'Futur cosmique';

  @override
  String get workspaceModeSoftEducation => 'Éducation douce';

  @override
  String get workspaceModeTooltip => 'Changer le mode d’espace de travail';

  @override
  String get workspaceMoreMenuTooltip => 'Plus d\'options';

  @override
  String get workspaceLanguageMenuTitle => 'Langue';

  @override
  String get workspaceStageImport => 'Importation';

  @override
  String get workspaceStageParse => 'Analyse';

  @override
  String get workspaceStageAnalyze => 'Analyse à quatre moteurs';

  @override
  String get workspaceStageVerify => 'Vérification';

  @override
  String get workspaceStageReport => 'Rapport';

  @override
  String get workspaceLiveFindings => 'Résultats en direct';

  @override
  String get workspaceTelemetry => 'Télémétrie d\'analyse';

  @override
  String get workspaceDocument => 'Espace document';

  @override
  String get workspaceOverallProgress => 'Progression globale';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return 'Étape $current/$total · $stage';
  }

  @override
  String get workspaceWaiting => 'En attente d\'un document';

  @override
  String get workspaceAnalyzing => 'Analyse en cours';

  @override
  String get workspaceAnalysisComplete => 'Analyse terminée';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '$done/$total modules terminés · ${seconds}s écoulées · En cours : $engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return 'L’analyse continue et l’interface répond. Aucun module n’est terminé depuis ${seconds}s ; les documents volumineux ou modèles locaux peuvent prendre plus de temps.';
  }

  @override
  String get workspaceAnalysisFailed =>
      'L’analyse s’est arrêtée de façon inattendue. Réessayez ou vérifiez les paramètres du modèle.';

  @override
  String get workspaceNewAnalysis => 'Nouvelle analyse';

  @override
  String get workspaceStopAnalysis => 'Arrêter l’analyse';

  @override
  String get workspaceStopAnalysisTitle => 'Arrêter l’analyse en cours ?';

  @override
  String get workspaceStopAnalysisBody =>
      'L’analyse est toujours en cours. Le texte du document sera conservé, mais les résultats incomplets ne seront pas enregistrés.';

  @override
  String get workspaceAnalysisStopped =>
      'Analyse arrêtée. Le texte du document reste dans l’espace de travail.';

  @override
  String get workspaceSelectedEvidence => 'Preuve sélectionnée';

  @override
  String get workspaceNoEvidence =>
      'Les preuves par phrase apparaissent à mesure que les moteurs terminent.';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return 'Probabilité IA préliminaire : $percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      'Ce pourcentage est le signal IA propre à cette phrase, pas le verdict global du document. Plus il est élevé, plus le style d\'écriture semble généré par IA ; plus il est bas, plus il ressemble à une écriture humaine typique. Le rapport final combine chaque phrase avec la pondération des moteurs.';

  @override
  String get workspaceSentenceSignalHeader => 'Signal IA par phrase';

  @override
  String get workspaceSentenceColumnHeader => 'Phrase';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine n\'a trouvé aucune preuve cette fois et n\'a donc pas participé au vote (poids du rôle $weight %). Cela signifie aucune trace d\'IA sur son propre axe — pas qu\'il juge le texte écrit par un humain.';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return 'Seul $engine a trouvé quelque chose ; les autres moteurs n\'ont rien relevé cette fois. La conclusion ne repose que sur une seule ligne de preuves : ajustez la confiance en conséquence.';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return '$count autre(s) moteur(s) ont tourné sans rien trouver et ont été exclus du vote, pour que « rien à signaler » ne soit pas compté comme « semble écrit par un humain ».';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      'La perplexité n\'a pas été prise en compte pour ce document : le modèle de perplexité (DistilGPT2) n\'a été entraîné qu\'en anglais et, sur du texte chinois, japonais ou coréen, il mesure la prévisibilité des octets et non celle de la langue. Mesuré sur données annotées, il sépare l\'écriture humaine de l\'IA dans 0 % des cas ; le compter ne produirait que des faux positifs.';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return 'Base par langue : $breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return '$count échantillon(s) antérieurs ne portent pas d\'étiquette de langue et ne peuvent rejoindre la base d\'aucune langue : le texte original n\'est pas conservé, la langue est donc irrécupérable après coup. Ils seront remplacés au fil des nouvelles analyses.';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return 'Pour ce document, « $variant » a été retenu : la variante que vous avez choisie n\'est pas validée pour $language, celle-ci l\'est.';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '« $variant » est multilingue mais n\'a pas été validé sur $language ; son score constitue une preuve plus faible que pour une langue validée.';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '« $variant » ne couvre pas $language. Son score est indiqué à titre indicatif et ne doit pas être lu comme une preuve.';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      'La perplexité n\'a pas été prise en compte : la langue de ce document n\'a pu être déterminée, il n\'existe donc aucun seuil calibré de référence. Deviner une langue appliquerait la mauvaise échelle — précisément l\'erreur que ce contrôle évite.';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return 'La perplexité n\'a pas été prise en compte : le modèle utilisé (« $model ») n\'a pas encore de seuil mesuré pour $language. Sans échelle calibrée, la valeur brute ne signifie rien ; elle est donc écartée plutôt que devinée.';
  }

  @override
  String get inputNoEditingRecordHint =>
      'Ce format ne comporte aucun historique d\'édition. Les PDF, les images et le texte collé ne conservent rien de la façon dont ils ont été écrits ; l\'analyse repose donc uniquement sur les statistiques textuelles. Si vous pouvez obtenir le .docx, .odt ou .doc d\'origine, son historique constitue une preuve bien plus solide — et contrairement aux statistiques, elle ne s\'affaiblit pas à mesure que les modèles progressent.';

  @override
  String get reportLowScoreNotProofOfHuman =>
      'Un score faible ne prouve pas qu\'une personne a écrit ce texte. Faute de preuve d\'origine, ce verdict ne repose que sur les statistiques textuelles, qui repèrent de façon fiable l\'écriture stéréotypée mais pas les productions bien écrites des modèles actuels.';

  @override
  String get reportProvenanceContradictsLowScore =>
      'L\'historique d\'édition du fichier contredit ce score faible. Les preuves d\'origine ne s\'affaiblissent pas à mesure que les modèles progressent, alors que les statistiques textuelles ne repèrent pas les productions bien écrites des modèles actuels. Consultez d\'abord les preuves d\'origine ci-dessous avant de tirer une conclusion du score.';

  @override
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  ) {
    return '$paragraphs paragraphes sur $total relèvent d\'un même lot d\'édition et représentent $percent % des mots — cohérent avec un bloc écrit ou collé en une seule fois, même si le fichier comporte d\'autres lots d\'édition.';
  }

  @override
  String findingEvasionDetected(int count) {
    return '$count marques d\'évasion au niveau des caractères ont été trouvées (caractères de largeur nulle, lettres d\'apparence identique ou contrôles de direction). Les outils d\'écriture ordinaires n\'en produisent pas : le texte a été traité pour déjouer la détection.';
  }

  @override
  String findingCitationsNotFound(int notFound, int total) {
    return 'Sur $total ouvrages cités, $notFound n\'ont été trouvés dans aucune des bases bibliographiques consultées. Les citations inventées sont un comportement des modèles de langage et, contrairement au style, l\'existence d\'un article est un fait vérifiable.';
  }

  @override
  String findingCitationsAllVerified(int total) {
    return 'Les $total ouvrages cités ont tous été trouvés dans les bases publiques.';
  }

  @override
  String findingEditingRecordNormal(int minutes, int revisions) {
    return 'Le fichier enregistre $minutes minutes d\'édition sur $revisions enregistrements, ce qui est cohérent avec un texte rédigé dans ce document.';
  }

  @override
  String get reportVerifiableFindingsTitle => 'Ce qui est vérifiable';

  @override
  String get reportVerifiableFindingsSubtitle =>
      'Chaque élément ci-dessous peut être vérifié indépendamment. Contrairement à une probabilité, ils ne s\'affaiblissent pas à mesure que les modèles progressent.';

  @override
  String findingBulkPaste(int characters) {
    return 'Un collage unique de $characters caractères a été enregistré pendant la saisie. Un modèle de langue ne peut pas falsifier la façon dont le texte apparaît dans un éditeur : ce bloc n\'a pas été tapé ici.';
  }

  @override
  String findingWrittenInApp(int minutes, int deleted) {
    return 'Le texte a été saisi dans cette application pendant $minutes minutes, avec $deleted caractères révisés. L\'écriture qui se déroule ici laisse une trace qu\'aucun modèle ne peut reproduire.';
  }

  @override
  String get evidenceMatrixTitle => 'Multi-evidence assessment';

  @override
  String get evidenceMatrixSubtitle =>
      'Six axes are shown separately. Only authorship-specific evidence affects the author verdict; coverage shows what could be examined.';

  @override
  String evidenceMatrixCoverage(int available, int total) {
    return 'Evidence coverage: $available of $total axes';
  }

  @override
  String get evidenceAxisText => 'Text-generation traces';

  @override
  String get evidenceAxisTextNote =>
      'Probabilistic patterns from the four local detectors';

  @override
  String get evidenceAxisProcess => 'Writing process';

  @override
  String get evidenceAxisProcessNote =>
      'Typing, revision and paste events recorded without storing their content';

  @override
  String get evidenceAxisOrigin => 'Document origin';

  @override
  String get evidenceAxisOriginNote =>
      'Editing time, saves and DOCX/ODT/RSID metadata';

  @override
  String get evidenceAxisSources => 'Claim and source integrity';

  @override
  String get evidenceAxisSourcesNote =>
      'Checkable claims, citation anchors and bibliographic verification';

  @override
  String get evidenceStateUnavailable => 'Unavailable';

  @override
  String get evidenceStateInconclusive => 'Inconclusive';

  @override
  String get evidenceStateReassuring => 'Consistent';

  @override
  String get evidenceStateConcern => 'Review';

  @override
  String get evidenceStrengthNone => 'No evidence';

  @override
  String get evidenceStrengthLimited => 'Limited';

  @override
  String get evidenceStrengthModerate => 'Moderate';

  @override
  String get evidenceStrengthStrong => 'Strong';

  @override
  String get evidenceMatrixTextOnlyWarning =>
      'Only the text-pattern axis was available. Current-generation AI can imitate human prose, so this report cannot establish authorship from the score alone.';

  @override
  String get evidenceMatrixStrongConcern =>
      'At least one independent axis contains a strong review signal. Inspect that evidence before relying on the text score.';

  @override
  String findingUnsupportedClaims(int unsupported, int total) {
    return '$unsupported of $total checkable claims contain numbers, comparisons or research attributions without a source anchor in the same sentence. This does not prove they are false, but identifies the claims that need verification first.';
  }

  @override
  String get challengeTitle => 'Supervised follow-up';

  @override
  String get challengeSubtitle =>
      'Ask the writer to explain specific claims from this document';

  @override
  String get challengeCaveat =>
      'Use this while the writer is present. The check only measures whether an answer engages with the document and whether it was pasted; passing is not proof of identity or authorship.';

  @override
  String challengeExplainQuestion(String excerpt) {
    return 'Explain this passage in your own words and state why it matters: “$excerpt”';
  }

  @override
  String challengeJustifyQuestion(String excerpt) {
    return 'What evidence or reasoning supports this claim, and what would weaken it? “$excerpt”';
  }

  @override
  String get challengeAnswerHint => 'Answer here without pasting prepared text';

  @override
  String get challengeEvaluate => 'Check response';

  @override
  String get challengeStateUnanswered => 'Not checked';

  @override
  String get challengeStateInsufficient => 'Needs a more specific answer';

  @override
  String get challengeStateGrounded => 'Directly engages with the passage';

  @override
  String get challengeStatePasted =>
      'Large paste detected; repeat under supervision';

  @override
  String get integratedAssessmentTitle => 'Integrated authorship assessment';

  @override
  String get integratedLikelyAi => 'More likely AI-generated';

  @override
  String get integratedLikelyMixed => 'More likely human-AI mixed';

  @override
  String get integratedLikelyHuman => 'More likely not AI-generated';

  @override
  String get integratedBalanced => 'AI and human signals are balanced';

  @override
  String integratedLikelihoodLabel(int percent) {
    return 'Integrated AI likelihood: $percent%';
  }

  @override
  String integratedTextScoreLabel(int percent) {
    return 'Text-model score: $percent%';
  }

  @override
  String integratedConfidenceLabel(String confidence) {
    return 'Confidence: $confidence';
  }

  @override
  String get integratedConfidenceLow => 'Low';

  @override
  String get integratedConfidenceModerate => 'Moderate';

  @override
  String get integratedConfidenceHigh => 'High';

  @override
  String integratedEvidenceCoverage(int families, int coverage) {
    return 'Independent evidence families: $families/4 · applicability coverage $coverage%';
  }

  @override
  String get integratedEvidenceGatePassed => 'AI evidence gate: passed';

  @override
  String get integratedEvidenceGateNotPassed =>
      'AI evidence gate: not passed · directional screening only';

  @override
  String integratedQualifiedWarning(String reason) {
    return '$reason The system still gives the most likely direction, but confidence is reduced; treat it as a screening result, not proof.';
  }

  @override
  String get integratedIndexCaveat =>
      'The separate AI evidence gate indicates whether independent support is strong enough for escalation. Citation quality, paste behavior, and suspicious metadata cannot independently produce an AI verdict. This is an evidence score, not a calibrated statistical probability.';

  @override
  String get reportTextEngineSignalExplanation =>
      'These bars show diagnostic signals from the four text engines. The final text score first merges correlated engines into independent evidence families and applies language/domain applicability and calibration reliability. The separate AI evidence gate indicates whether support is strong enough for escalation; ‘not detected’ is not proof of human authorship.';

  @override
  String reportSynthesisTextScoreContext(int percent) {
    return 'Four-engine text-model raw score: $percent%. This is one input to the integrated assessment, not a second verdict.';
  }

  @override
  String reportSynthesisStrongestTextSignal(String label, int percent) {
    return 'Strongest text-engine signal: $label ($percent%). It can influence the text-model score but cannot override the integrated assessment by itself.';
  }

  @override
  String composerTextScoreThresholdReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'The text-model raw score is $aiPercent%, reaching the $thresholdPercent% diagnostic marker. This is a text-signal observation only; the integrated assessment above remains the report\'s authorship direction.';
  }

  @override
  String composerTextScoreThresholdNotReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'The text-model raw score is $aiPercent%, below the $thresholdPercent% diagnostic marker. Missing that marker is not evidence of human authorship; the integrated assessment above remains the report\'s authorship direction.';
  }

  @override
  String telemetryIntegratedVerdict(
    String direction,
    int percent,
    String confidence,
  ) {
    return 'After weighting the available evidence, the document is “$direction” (AI likelihood index $percent%, $confidence confidence).';
  }

  @override
  String integratedStabilityLabel(int percent, int lower, int upper) {
    return 'Segment stability $percent% · interval $lower–$upper%';
  }

  @override
  String integratedInputQualityLabel(int percent) {
    return 'Input extraction quality: $percent%';
  }

  @override
  String integratedCalibrationLabel(String value, int count) {
    return 'Matched local baseline: p=$value · n=$count';
  }

  @override
  String analysisReadinessLabel(String level) {
    return 'Expected confidence ceiling: $level';
  }

  @override
  String get analysisReadinessShortText => 'more text needed';

  @override
  String get analysisReadinessFewSentences => 'too few segments';

  @override
  String get analysisReadinessCoreModel => 'core classifier unavailable';

  @override
  String get analysisReadinessFewEngines => 'fewer than two engines enabled';

  @override
  String get analysisReadinessExtraction => 'extraction quality is limited';

  @override
  String get analysisReadinessBaseline => 'no matched local baseline';
}
