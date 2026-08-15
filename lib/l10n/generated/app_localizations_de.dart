// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get verdictHuman => 'Von Mensch geschrieben';

  @override
  String get verdictLikelyHuman => 'Wahrscheinlich Mensch';

  @override
  String get verdictMixed => 'Gemischter Inhalt';

  @override
  String get verdictLikelyAi => 'Wahrscheinlich KI';

  @override
  String get verdictAi => 'KI-generiert';

  @override
  String get inputSubtitle =>
      'Text einfügen oder eingeben, um KI-generierte Inhalte zu erkennen';

  @override
  String get inputHint => 'Zu analysierenden Text eingeben oder einfügen…';

  @override
  String get inputHistoryTooltip => 'Verlauf';

  @override
  String get inputHelpTooltip => 'Benutzerhandbuch';

  @override
  String get inputPrivacyTooltip => 'Datenschutzrichtlinie';

  @override
  String get inputSettingsTooltip => 'Einstellungen';

  @override
  String get inputPasteButton => 'Einfügen';

  @override
  String get inputOcrButton => 'Bild-OCR';

  @override
  String get inputImportButton => 'Datei importieren';

  @override
  String get inputStartButton => 'Erkennung starten';

  @override
  String get inputClearTooltip => 'Inhalt löschen';

  @override
  String get inputTooShortSnackbar =>
      'Bitte mindestens 40 Zeichen für eine zuverlässige Analyse eingeben';

  @override
  String get inputOcrUnsupported =>
      'OCR-Texterkennung wird auf dieser Plattform nicht unterstützt';

  @override
  String get inputOcrRecognizing => 'Wird erkannt…';

  @override
  String get inputOcrNoText => 'Kein Text im Bild identifiziert';

  @override
  String inputOcrRecognized(int count) {
    return '$count Zeichen erfolgreich erkannt';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\" enthält keinen lesbaren Textinhalt';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '\"$fileName\" wurde importiert ($count Zeichen)';
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
  String inputActiveModel(String modelId) {
    return 'Modell: $modelId';
  }

  @override
  String get inputNoModel =>
      'Kein Modell installiert (nur statistische/stilistische Analyse)';

  @override
  String inputCharCount(int count) {
    return '$count Zeichen';
  }

  @override
  String get analysisAppBarTitle => 'Analysiere';

  @override
  String get analysisEngineTransformer => 'Transformer-Klassifikator';

  @override
  String get analysisEngineStatistical => 'Statistische Analyse';

  @override
  String get analysisEngineStylometry => 'Stilometrische Analyse';

  @override
  String get analysisEngineAdversarial => 'Adversariale Abwehr';

  @override
  String analysisProgressSemantics(int done, int total) {
    return 'Analyse läuft, $done von $total Engines abgeschlossen';
  }

  @override
  String get analysisDoneSemantics => 'Abgeschlossen';

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
      'Adversariale Abwehr (Paraphrasierungserkennung)';

  @override
  String get modelNecessityText =>
      'Ohne das Herunterladen des neuronalen Erkennungsmodells funktioniert TruthLens weiterhin, verwendet jedoch nur statistische und stilistische Analyse mit eingeschränkter Genauigkeit und mehrsprachiger Unterstützung. Nach dem Herunterladen des Modells nimmt der mehrsprachige Transformer-Klassifikator an der Ensemble-Abstimmung teil und verbessert Genauigkeit und Zuverlässigkeit erheblich. Das Modell läuft auf dem Gerät; nach dem Herunterladen lädt es keine Inhalte hoch.';

  @override
  String get modelPromptTitle =>
      'Es wird empfohlen, das Erkennungsmodell für eine vollständige Analyse herunterzuladen';

  @override
  String get modelPromptDontRemind => 'Nicht mehr erinnern';

  @override
  String get modelPromptSkip => 'Vorerst überspringen';

  @override
  String get modelPromptDownload => 'Jetzt herunterladen';

  @override
  String get onboardingWelcomeTitle => 'Willkommen bei TruthLens';

  @override
  String get onboardingHeadline => 'KI-Inhaltserkennung auf dem Gerät';

  @override
  String get onboardingDetectedDevice => 'Gerät erkannt';

  @override
  String get onboardingChooseModel => 'Modell zum Herunterladen wählen';

  @override
  String get onboardingRecommendHint =>
      '\"Empfohlen\" wird basierend auf Ihrer Hardware markiert; Sie können auch eine andere Option wählen.';

  @override
  String get onboardingSkipButton =>
      'Später entscheiden (statistische/stilistische Analyse ohne Modell verwenden)';

  @override
  String get onboardingSkipHint =>
      'Sie können jederzeit unter \"Einstellungen → KI-Modellverwaltung\" herunterladen; Sie werden bei der Verwendung von Analysen, die ein Modell erfordern, erneut erinnert.';

  @override
  String get modelListCustomImportedLabel =>
      'Importiertes benutzerdefiniertes Modell:';

  @override
  String get modelListActiveChip => 'In Verwendung';

  @override
  String get modelListRecommendedChip => 'Empfohlen';

  @override
  String get modelListCustomChip => 'Benutzerdefiniert';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · Benötigt ${ram}GB RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'Größe: $size · Tokenizer: $tokenizer · KI-Label-Index: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'Wird heruntergeladen… $percent% ($downloaded / $total)';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'Herunterladen ($size)';
  }

  @override
  String get modelListComingSoonChip => 'Demnächst verfügbar';

  @override
  String get modelListSetActiveButton => 'Als aktiv festlegen';

  @override
  String get modelListUpdateButton => 'Aktualisieren';

  @override
  String get modelListDeleteTooltip => 'Löschen';

  @override
  String get modelListPageButton => 'Modellseite';

  @override
  String get modelListMayExceedMemory =>
      'Kann den Gerätespeicher überschreiten';

  @override
  String modelListFailedPrefix(String error) {
    return 'Fehlgeschlagen: $error';
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
  String get modelListDeleteConfirmTitle => 'Modell löschen?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return 'Dadurch wird \"$name\" ($size) gelöscht. Sie müssen es erneut herunterladen, um es wieder zu verwenden.';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'Dadurch wird das importierte benutzerdefinierte Modell \"$name\" ($size) gelöscht. Sie müssen es erneut importieren, um es wieder zu verwenden.';
  }

  @override
  String get modelImportAppBarTitle =>
      'Benutzerdefiniertes ONNX-Modell importieren';

  @override
  String get modelImportStep1Title => '1. ONNX-Modelldatei auswählen';

  @override
  String modelImportSelectedFile(String name) {
    return 'Ausgewählt: $name';
  }

  @override
  String get modelImportNoFileSelected =>
      'Keine Modelldatei ausgewählt (.onnx)';

  @override
  String get modelImportBrowseButton => 'Durchsuchen';

  @override
  String get modelImportCheckingDuplicate =>
      'Wird geprüft, ob eine identische Datei bereits importiert wurde…';

  @override
  String get modelImportDuplicateTitle =>
      'Modell mit identischem Inhalt bereits importiert';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'Diese Datei hat einen vollständig identischen Inhalt wie \"$name\" (Rolle: $role). Wenn Sie nur das aktive Modell wechseln möchten, gehen Sie zu \"KI-Modellverwaltung\" und legen Sie es direkt als aktiv fest — kein erneuter Import erforderlich. Sie können trotzdem mit den folgenden Schritten fortfahren.';
  }

  @override
  String get modelImportStep2Title => '2. Konfiguration';

  @override
  String get modelImportNameLabel => 'Anzeigename des Modells';

  @override
  String get modelImportNameRequired => 'Name darf nicht leer sein';

  @override
  String get modelImportRoleLabel => 'Rolle der Ziel-Engine';

  @override
  String get modelImportTokenizerTypeLabel => 'Tokenizer-Typ';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => 'Keine (ohne Tokenizer/Zeichenebene)';

  @override
  String get modelImportNoTokenizerSelected =>
      'Keine Tokenizer-Datei ausgewählt (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return 'Ausgewählt: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'KI-Label-Ausgabeindex';

  @override
  String get modelImportIndex0 => 'Index 0 (z. B. RoBERTa)';

  @override
  String get modelImportIndex1 => 'Index 1 (z. B. DistilBERT)';

  @override
  String get modelImportStep3Title => '3. Testen & verifizieren';

  @override
  String get modelImportTestInputLabel => 'Test-Eingabetext';

  @override
  String get modelImportRunTestButton => 'Test-Inferenz ausführen';

  @override
  String get modelImportResultLabel =>
      'Inferenzergebnis (KI-Wahrscheinlichkeit):';

  @override
  String modelImportTestFailed(String error) {
    return 'Test fehlgeschlagen: $error';
  }

  @override
  String get modelImportConfirmButton =>
      'Import bestätigen und Modell aktivieren';

  @override
  String get modelImportSelectTokenizerFirst =>
      'Bitte zuerst eine Tokenizer-Datei auswählen';

  @override
  String get modelImportSelectTokenizer =>
      'Bitte eine Tokenizer-Datei auswählen';

  @override
  String get modelImportSuccessSnackbar =>
      'Modell erfolgreich importiert! Wurde automatisch als aktives Modell festgelegt.';

  @override
  String get modelImportFailedSnackbar =>
      'Modellimport fehlgeschlagen. Bitte Berechtigungen oder Protokolle prüfen';

  @override
  String get settingsAppBarTitle => 'Einstellungen';

  @override
  String get settingsThresholdTitle => 'Vertrauensschwelle für KI-Bestimmung';

  @override
  String get settingsThresholdInfoTooltip =>
      'How the AI flagging threshold affects the conclusion';

  @override
  String get settingsThresholdInfoBody =>
      'The enabled engines first calculate the overall AI probability. This setting does not change any engine score or that overall probability; it changes which conclusion is applied to the score. A lower threshold makes the same probability more likely to be concluded and marked as AI, while a higher threshold requires stronger AI probability and is more likely to conclude human writing. The report always retains the original probability and supporting evidence.';

  @override
  String settingsThresholdSubtitle(int percent) {
    return 'Aktuell: $percent% — eine Erhöhung reduziert Falschmeldungen (menschlicher Text fälschlich als KI eingestuft)';
  }

  @override
  String get settingsEslTitle =>
      'ESL-Verzerrungskorrektur (Nicht-Muttersprachler)';

  @override
  String get settingsEslSubtitle =>
      'Verringert automatisch das Gewicht des statistischen Modells, wenn ein Schreibstil von Nicht-Muttersprachlern erkannt wird';

  @override
  String get settingsEngineSectionTitle =>
      'Einstellungen der Erkennungs-Untermodule (Ensemble)';

  @override
  String get settingsEngineTransformerTitle =>
      'Mehrsprachiger KI-Klassifikator (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Verwendet ein Transformer-Neuronal-Netz-Modell zur Vorhersage der KI-Wahrscheinlichkeit auf dem Gerät';

  @override
  String get settingsEngineStatisticalTitle =>
      'Statistisches Analysemodul (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      'Bestimmt die Sprachregelmäßigkeit durch Variation der Satzlänge, Burstiness und PPL';

  @override
  String get settingsEngineStylometryTitle =>
      'Stilometrische Analyse (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle =>
      'Analysiert semantische Flüssigkeit, wiederkehrende Satzmuster und die Verwendung von Übergangswörtern';

  @override
  String get settingsEngineAdversarialTitle =>
      'Erkennung adversarialer Paraphrasierung (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle =>
      'Erkennt, ob der Text maschinell paraphrasiert oder zur Entfernung von KI-Spuren bearbeitet wurde';

  @override
  String get settingsEngineWeightsTitle => 'Gewichtung der KI-Modelle';

  @override
  String get settingsEngineWeightsSubtitle =>
      'Legen Sie fest, wie stark jede Engine das Gesamtergebnis beeinflusst. Vor dem Speichern muss die Summe 100 % betragen.';

  @override
  String get settingsEngineInfoTooltip => 'Funktion dieser Engine';

  @override
  String get settingsEngineTransformerHelp =>
      'Bewertet kontexterhaltende Absatzblöcke mit einem mehrsprachigen Transformer und ordnet die Blockwerte für detaillierte Berichte wieder den Sätzen zu. Die Gewichtung bestimmt den Einfluss, das KI-Signal den tatsächlichen Beitrag.';

  @override
  String get settingsEngineStatisticalHelp =>
      'Misst Perplexität, Vorhersagbarkeit, Burstiness und Satzlängenvariation. Die ESL-Korrektur kann die effektive Gewichtung reduzieren.';

  @override
  String get settingsEngineStylometryHelp =>
      'Prüft erklärbare Stilmerkmale wie wiederholte Satzanfänge, formelhafte Übergänge und übermäßige Listen. Ohne Treffer beträgt das Signal 0 %.';

  @override
  String get settingsEngineAdversarialHelp =>
      'Sucht nach paraphrasiertem KI-Text oder entfernten KI-Spuren. Ein niedriger Wert bedeutet nur schwache Restsignale, keinen positiven Nachweis.';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return 'Summe: $total % — bereit zum Speichern';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return 'Summe: $total % — genau auf 100 % einstellen';
  }

  @override
  String get settingsEngineWeightsSave => 'Gewichtungen speichern';

  @override
  String get settingsEngineWeightsSaved =>
      'KI-Modellgewichtungen wurden auf diesem Gerät gespeichert';

  @override
  String get settingsEngineWeightsRestoreDefaults => 'Standardwerte';

  @override
  String get engineReasonDisabledByUser =>
      'Benutzer hat diese Engine in den Einstellungen deaktiviert';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model: Keiner von $total Sätzen überschritt den starken KI-Schwellenwert; das kalibrierte schwache Signal beträgt $percent %';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'KI-Signal $percent %';
  }

  @override
  String get reportEngineSignalExplanation =>
      'Das KI-Signal ist die Wahrscheinlichkeit dieses Moduls für das Dokument. Das eingestellte Gewicht bestimmt seinen Einfluss; die Beitragspunkte werden so verteilt, dass ihre angezeigte Summe genau der gesamten KI-Wahrscheinlichkeit entspricht. „Nicht erkannt“ bedeutet unterhalb der starken Signalschwelle von 60 %, nicht zwingend den Wert null.';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return 'Keiner von $total Sätzen überschritt die Schwelle für ein starkes Umschreibungssignal; das kalibrierte schwache Signal beträgt $percent %';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$count von $total Sätzen überschritten die Schwelle für ein starkes Umschreibungssignal; das kalibrierte Dokumentsignal beträgt $percent %';
  }

  @override
  String get settingsLinkVerificationTitle =>
      'Verifizierung von Hyperlinks und Bibliografie';

  @override
  String get settingsLinkVerificationSubtitle =>
      'Der Bericht stellt eine Verbindung her, um zu prüfen, ob die im Dokument erkannten URLs und Bibliografieeinträge tatsächlich existieren (KI-generierte Inhalte enthalten oft plausibel klingende, aber erfundene Referenzen). Sowohl akademische Links im DOI-Format als auch Referenzen im \"Autor-Jahr\"-Format ohne Link werden gegen das öffentliche Crossref-Register geprüft. Das Kern-KI-Erkennungsmodell läuft weiterhin vollständig auf dem Gerät und sendet niemals Dokumentinhalte; die Verbindung wird nur für diese Verifizierung und Modell-Updateprüfungen verwendet und kann hier deaktiviert werden.';

  @override
  String get settingsThemeTitle => 'Anzeigethema';

  @override
  String get settingsLanguageTitle => 'Sprache';

  @override
  String get settingsLanguageSubtitle => 'Anzeigesprache der App wählen';

  @override
  String get settingsModelManagementTitle => 'KI-Modellverwaltung';

  @override
  String get settingsModelManagementSubtitle =>
      'Erkennungsmodelle und Bericht-LLM herunterladen, um die volle Inferenzfähigkeit zu aktivieren';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'Modell-Update erkannt — Überprüfung empfohlen';

  @override
  String get settingsOpenButton => 'Öffnen';

  @override
  String get settingsCustomImportTitle =>
      'Benutzerdefiniertes ONNX-Modell importieren & testen';

  @override
  String get settingsCustomImportSubtitle =>
      'Lokales benutzerdefiniertes ONNX-Modell importieren, Tokenizer konfigurieren und Test-Inferenz ausführen';

  @override
  String get modelImportWebUnsupported =>
      'Custom model import is not supported on the web version yet. Please use the app version.';

  @override
  String get settingsLanguagePackTitle => 'Sprachpaket';

  @override
  String get settingsLanguagePackSubtitle =>
      'Zusätzliches Sprachanpassungsmodell (verfügbar in Phase 4)';

  @override
  String get settingsModelManagerAppBarTitle => 'KI-Modellverwaltung';

  @override
  String get settingsImportTooltip => 'Lokales ONNX-Modell importieren';

  @override
  String settingsDeviceLabel(String summary) {
    return 'Gerät: $summary';
  }

  @override
  String get historyAppBarTitle => 'Verlauf';

  @override
  String get historyClearAllTooltip => 'Alles löschen';

  @override
  String get historySearchHint => 'Verlauf durchsuchen…';

  @override
  String get historyDeletedSnackbar => 'Eintrag gelöscht';

  @override
  String get historyClearAllTitle => 'Gesamten Verlauf löschen?';

  @override
  String historyClearAllBody(int count) {
    return 'Dadurch werden alle $count Einträge gelöscht. Diese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get historyClearButton => 'Löschen';

  @override
  String get historyDeleteEntryTitle => 'Diesen Eintrag löschen?';

  @override
  String get historyReanalyzeTooltip => 'Erneut analysieren';

  @override
  String get historyEmptyDefault => 'Noch kein Erkennungsverlauf vorhanden';

  @override
  String historyEmptySearch(String query) {
    return 'Keine Einträge gefunden, die \"$query\" entsprechen';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, KI-Wahrscheinlichkeit $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => 'Erkennungsbericht';

  @override
  String get reportExportTooltip => 'Bericht exportieren';

  @override
  String get reportHomeTooltip => 'Zurück zur Startseite';

  @override
  String get reportGeneratingTitle => 'Bericht wird erstellt…';

  @override
  String get reportSourceLlm => 'Bericht KI-generiert';

  @override
  String get reportSourceTemplate => 'Bericht vorlagenbasiert generiert';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '$total Sätze · $ai wahrscheinlich KI · $human wahrscheinlich Mensch · $seconds s vergangen';
  }

  @override
  String get reportExportPdf => 'PDF-Bericht exportieren';

  @override
  String get reportExportCsv => 'CSV-Daten exportieren';

  @override
  String get reportExportJson => 'JSON exportieren (Systemintegration)';

  @override
  String get reportExportPng => 'Übersichtskarte exportieren (PNG)';

  @override
  String reportExported(String path) {
    return 'Exportiert: $path';
  }

  @override
  String reportExportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get reportEngineWeightLabel => 'Gewichtung';

  @override
  String get privacySealNoticeText =>
      'TruthLens Zero-Cloud-Datenschutzsiegel: 100% lokale Ausführung auf dem Gerät ohne Cloud-Speicherung.';

  @override
  String get reportModelCalibrationTitle =>
      'Automatische Modell-Benchmark-Kalibrierung';

  @override
  String get reportCommunityDiscoveredTag => 'Community (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => 'Aufschlüsselung nach Engines';

  @override
  String get reportEngineNotInstalled => 'Nicht installiert';

  @override
  String get reportEngineLoadFailedBadge => 'Laden fehlgeschlagen';

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
  String get reportMetricAiSentenceRatio =>
      'Anteil der Sätze mit starkem KI-Signal';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count von $total überschritten die starke Signalschwelle von 60 %';
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
  String get reportSentenceAnalysisTitle => 'Analyse auf Satzebene';

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
    return '$text. KI-Wahrscheinlichkeit $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'Authentizität der Hyperlinks';

  @override
  String get reportLinkNoneDetected =>
      'In diesem Dokument wurden keine Hyperlinks erkannt.';

  @override
  String get reportLinkCheckingProgress => 'Links werden verifiziert…';

  @override
  String reportLinkDetectedPending(int count) {
    return '$count Hyperlinks erkannt; noch nicht verifiziert';
  }

  @override
  String get reportLinkDisabledHint =>
      'KI-generierte Inhalte enthalten oft plausibel klingende, aber erfundene Referenzlinks. Sie haben die Hyperlink-Verifizierung in den Einstellungen deaktiviert; Sie können sie für die automatische Verifizierung wieder aktivieren oder unten für eine einmalige Prüfung antippen.';

  @override
  String get reportVerifyNowButton =>
      'Jetzt verifizieren (Netzwerk erforderlich)';

  @override
  String get reportLinkReachable => 'Erreichbar — URL existiert';

  @override
  String get reportLinkNotFound =>
      'URL existiert nicht (404) — möglicherweise erfundene Referenz';

  @override
  String get reportLinkUnreachable =>
      'Konnte nicht verifiziert werden (Zeitüberschreitung oder keine Serverantwort)';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'Im Zeitschriftenregister verifiziert: registriert bei $journal$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      'Keine passende DOI-Registrierung gefunden — möglicherweise erfundene Referenz';

  @override
  String get reportLinkCitationUnreachable =>
      'Konnte nicht verifiziert werden (Zeitüberschreitung oder keine Antwort von Crossref)';

  @override
  String reportLinkTruncated(int max, int count) {
    return 'Nur die ersten $max Links wurden verifiziert (insgesamt $count erkannt)';
  }

  @override
  String get reportBibAuthenticityTitle => 'Authentizität der Zitate';

  @override
  String get reportBibNoneDetected =>
      'In diesem Dokument wurden keine Bibliografieeinträge erkannt.';

  @override
  String get reportBibCheckingProgress => 'Bibliografie wird verifiziert…';

  @override
  String reportBibDetectedPending(int count) {
    return 'Bibliografie erkannt ($count Einträge); noch nicht verifiziert';
  }

  @override
  String get reportBibDisabledHint =>
      'KI-generierte Inhalte enthalten oft plausibel klingende, aber erfundene Referenzen. Sie haben die Hyperlink-Verifizierung in den Einstellungen deaktiviert; Sie können sie für die automatische Verifizierung wieder aktivieren oder unten für eine einmalige Prüfung antippen.';

  @override
  String get reportVerifyNowBibButton =>
      'Jetzt verifizieren (Netzwerk erforderlich)';

  @override
  String get reportBibRecheckAllUnreliableButton =>
      'Recheck all unverified citations';

  @override
  String get reportBibRecheckOneTooltip => 'Recheck this citation';

  @override
  String get reportBibResultHint =>
      'Abgeglichen mit dem öffentlichen Crossref-Register nach Ähnlichkeit von Autor, Jahr und Titel. Keine absolute Garantie — bei \"unsicher\" bitte manuell verifizieren.';

  @override
  String reportBibVerificationSource(String source) {
    return 'Verification source: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'Check manually in Google Scholar';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Hohe Zuverlässigkeit: existiert wahrscheinlich$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (registriert bei $journal)';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'Journal name mismatch: the document says “$reported”, while the verified registry says “$registered”. Please review this citation.';
  }

  @override
  String get reportBibNotFound =>
      'Keine nahe Übereinstimmung gefunden — möglicherweise erfundene Referenz';

  @override
  String get reportBibUncertain => 'Suspect: not verified by registry match';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Nur die ersten $max Einträge wurden verifiziert (insgesamt $count erkannt)';
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
  String get reportNetworkWarningTitle => 'Schwache Netzwerkverbindung';

  @override
  String get reportNetworkWarningBody =>
      'Diese App geht standardmäßig davon aus, dass eine Netzwerkverbindung verfügbar ist; sowohl die Analyse der Hyperlink-Authentizität als auch der Zitat-Authentizität erfordert Netzwerkzugriff, um Ergebnisse zu liefern. Es konnte keine Verbindung hergestellt werden — bitte Netzwerk prüfen und erneut versuchen.';

  @override
  String get reportRetryConnectionButton => 'Verbindung erneut versuchen';

  @override
  String get reportAiProbabilityLabel => 'KI-Wahrscheinlichkeit';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '$total Sätze\n$ai wahrscheinlich KI\n$human wahrscheinlich Mensch';
  }

  @override
  String get summaryCardFooter =>
      'Die Kern-KI-Inferenz läuft vollständig auf dem Gerät';

  @override
  String get exportReportTitle => 'TruthLens-Erkennungsbericht';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · Seite $page / $total';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return 'Analysiert: $datetime · $seconds s vergangen';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return 'Gesamturteil: $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => ' (ESL-Korrektur angewendet)';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '$total Sätze · $ai wahrscheinlich KI · $human wahrscheinlich Mensch';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'Um die PDF-Lesbarkeit zu erhalten, werden nur die ersten $max Sätze angezeigt (von insgesamt $count); verwenden Sie für vollständige Daten pro Satz stattdessen \"$csvLabel\" oder \"$jsonLabel\".';
  }

  @override
  String get pdfSentenceColumnHeader => 'Satz (mit übereinstimmenden Mustern)';

  @override
  String composerHeadlineAi(int percent) {
    return 'Dieser Text wurde höchstwahrscheinlich von KI generiert (KI-Wahrscheinlichkeit $percent%)';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'Dieser Text tendiert zu KI-Generierung; weitere Überprüfung wird empfohlen (KI-Wahrscheinlichkeit $percent%)';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'Dieser Text zeigt gemischte Merkmale von Mensch und KI (KI-Wahrscheinlichkeit $percent%)';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'Dieser Text tendiert dazu, von einem Menschen geschrieben zu sein (KI-Wahrscheinlichkeit $percent%)';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'Dieser Text wurde höchstwahrscheinlich von einem Menschen geschrieben (KI-Wahrscheinlichkeit $percent%)';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return 'Die Gesamt-KI-Wahrscheinlichkeit überschreitet die von Ihnen festgelegte Schwelle von $percent% und wurde als KI markiert.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'Die Gesamt-KI-Wahrscheinlichkeit liegt unter der von Ihnen festgelegten Markierungsschwelle von $percent%.';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return 'Overall AI probability is $aiPercent%, which reaches your $thresholdPercent% AI flagging threshold, so the report marks this text as AI. Review sentence evidence and engine reasons before making a final decision.';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'Overall AI probability is $aiPercent%, below your $thresholdPercent% AI flagging threshold, so the report does not formally mark this text as AI. The probability and evidence are still shown for review.';
  }

  @override
  String get composerNarrativeTitle => 'Analyseinterpretation';

  @override
  String get composerParaphraseTitle => 'Paraphrasierungsspuren erkannt';

  @override
  String get composerParaphraseBody =>
      'Dieser Text wurde möglicherweise mit einem Paraphrasierungstool (z. B. QuillBot, Undetectable.ai) bearbeitet, um die Erkennung zu umgehen. Obwohl er Satz für Satz natürlich wirkt, unterscheidet sich sein statistischer Gesamtfingerabdruck dennoch von echtem menschlichem Schreiben — bitte besondere Aufmerksamkeit schenken.';

  @override
  String get composerPatternListTitle => 'Wichtigste KI-Schreibmuster';

  @override
  String get composerEslTitle =>
      'ESL-Verzerrungskorrektur (Nicht-Muttersprachler)';

  @override
  String get composerEslBody =>
      'Dieser Text könnte von einem Nicht-Muttersprachler stammen. Niedrige Perplexität und regelmäßige Satzmuster, die bei Nicht-Muttersprachlern häufig vorkommen, sind an sich kein KI-Zeichen, daher hat das System das Gewicht des statistischen Modells verringert, um Fehleinschätzungen zu vermeiden.';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return 'Dieser Text hat insgesamt $total Sätze, von denen $ai starke KI-Merkmale zeigen und $human eher von einem Menschen geschrieben scheinen.';
  }

  @override
  String get composerNarrativeAiPattern =>
      'Die meisten Sätze sind in Rhythmus, Wortwahl und Verwendung von Übergangswörtern sehr regelmäßig — ein häufiger Fingerabdruck von KI-generiertem Text.';

  @override
  String get composerNarrativeMixedPattern =>
      'Der Text enthält sowohl regelmäßige als auch natürlich variierende Teile, was auf einen von KI aufpolierten menschlichen Entwurf oder eine Mensch-KI-Zusammenarbeit hindeutet.';

  @override
  String get composerNarrativeHumanPattern =>
      'Satzlänge und Wortwahl zeigen natürliche Variation und persönlichen Stil ohne klare Anzeichen von KI-Regelmäßigkeit.';

  @override
  String engineReasonPplLow(String ppl) {
    return 'Niedrige Sprachmodell-Perplexität ($ppl) — Text ist sehr vorhersehbar, ein Indikator für KI-Generierung';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'Hohe Sprachmodell-Perplexität ($ppl), im Einklang mit der unvorhersehbaren Natur menschlichen Schreibens';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'Moderate Sprachmodell-Perplexität ($ppl)';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'Sehr einheitliche Satzlänge (Burstiness $value) — ein gleichmäßiger Rhythmus ist ein häufiger statistischer Fingerabdruck von KI-generiertem Text';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'Deutliche Variation der Satzlänge (Burstiness $value), im Einklang mit dem natürlichen Rhythmus menschlichen Schreibens';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'Geringe Wortschatzvielfalt (TTR $value) — hohe Wortwiederholung';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'Hohe Wortschatzvielfalt (TTR $value)';
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
      'Statistische Indikatoren zeigen keine klare Tendenz — neutrales Urteil beibehalten';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return 'Häufige Verwendung allgemeiner Übergangswörter ($words), durchschnittlich $density pro Satz — eine Dichte, die in menschlichem Schreiben selten ist';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return 'Mehrere aufeinanderfolgende Sätze beginnen mit demselben Wort ($count Mal) — wiederkehrende Satzstruktur';
  }

  @override
  String get engineReasonNoStyleMarkers =>
      'Keine auffälligen KI-Schreibmuster erkannt';

  @override
  String get engineReasonAdversarialNotInstalled =>
      'Paraphrasierungserkennungsmodell nicht installiert; nahm nicht an dieser Abstimmung teil';

  @override
  String get engineReasonTransformerNotInstalled =>
      'Kein Modell installiert oder aktives Modell wird nicht unterstützt; nahm nicht an dieser Abstimmung teil';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'Modell konnte nicht geladen werden und nahm nicht an dieser Abstimmung teil ($error)';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model bewertete, dass $aiCount von $total Sätzen KI-Merkmale zeigen';
  }

  @override
  String get engineReasonAdversarialDetected =>
      'Das adversariale Modell erkannte mögliche KI-Spuren, die durch ein Paraphrasierungstool (z. B. QuillBot / Undetectable.ai) entfernt wurden';

  @override
  String get engineReasonAdversarialClean =>
      'Keine klaren Spuren einer Paraphrasierungs-Umgehung erkannt';

  @override
  String get engineReasonGenericNotInstalled =>
      'Modell nicht installiert; nahm nicht an dieser Abstimmung teil';

  @override
  String patternGenericTransition(String word) {
    return 'allgemeines Übergangswort \"$word\"';
  }

  @override
  String get helpAppBarTitle => 'Benutzerhandbuch';

  @override
  String get helpAboutTitle => 'Über TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens ist eine plattformübergreifende Inhaltserkennungsanwendung (iOS / Android / macOS / Windows), deren Kern-KI-Inferenz vollständig auf dem Gerät läuft. Vier unabhängige Untermodelle — der neuronale Transformer-Klassifikator, die statistische Analyse, die stilometrische Analyse und die adversariale Paraphrasierungserkennung — stimmen gemeinsam ab, um zu bestimmen, ob der Text von KI generiert wurde, mit erklärbaren Gründen Satz für Satz: nicht nur ein \"sieht nach KI aus\"-Prozentsatz, sondern eine Erklärung des \"Warum\".';

  @override
  String get helpComparisonTitle => 'Vergleich mit führenden Tools';

  @override
  String get helpComparisonDisclaimer =>
      'Dieser Vergleich wurde aus öffentlichen Informationen jedes Tools und allgemeinen Markteinschätzungen zusammengestellt, nur zur Referenz der funktionalen Positionierung — keine von Dritten verifizierten Benchmark-Daten.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'Die Verarbeitung von GPTZero erfolgt hauptsächlich in der Cloud und erfordert das Hochladen Ihres Dokuments; alle vier Erkennungs-Engines von TruthLens laufen auf dem Gerät.';

  @override
  String get helpVsGptZero2 =>
      'GPTZero war Pionier bei Perplexity/Burstiness-Metriken und Satzhervorhebung — TruthLens kombiniert diese und fügt einen Transformer-Klassifikator, stilometrische Analyse und adversariale Abwehr hinzu, wodurch eine Ensemble-Abstimmung aus vier Modellen statt einer einzigen Metrik entsteht.';

  @override
  String get helpVsGptZero3 =>
      'GPTZero basiert auf Abonnements; TruthLens erfordert kein Abonnement und hat keine Nutzungsbeschränkungen.';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin wird nur an Institutionen verkauft; Einzelpersonen können es nicht direkt kaufen. Jeder kann TruthLens installieren und verwenden.';

  @override
  String get helpVsTurnitin2 =>
      'Der Entscheidungsprozess von Turnitin ist fast eine Blackbox; TruthLens liefert die KI-Wahrscheinlichkeit jedes Satzes, passende Schreibmuster sowie die Aufschlüsselung von Punktzahl und Gründen jeder Engine.';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin liefert größtenteils ein binäres \"ist es KI\"-Ergebnis; TruthLens unterstützt die Kennzeichnung von Mensch/KI/Gemischt auf Absatz-/Satzebene.';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai ist ein Abonnement pro Dokument, das das Hochladen Ihres Dokuments in die Cloud erfordert; die Kernverarbeitung von TruthLens läuft auf dem Gerät, ohne dass ein fortlaufendes Abonnement für die Erkennung erforderlich ist.';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai bietet Konzepte für Faktenprüfung und Lesbarkeitsanalyse; TruthLens reagiert darauf mit einem Stilmerkmalmodul auf dem Gerät und kann grundlegende Analysen sogar offline durchführen.';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks ist hauptsächlich eine Cloud-API, bekannt für niedrige Falsch-Positiv-Raten und starke mehrsprachige Unterstützung; TruthLens teilt diese Philosophie mit einem mehrsprachigen XLM-RoBERTa-Basismodell und Multi-Modell-Ensemble-Abstimmung, aber der Inhalt Ihres Dokuments wird niemals auf einen Server hochgeladen.';

  @override
  String get helpVsCopyleaks2 =>
      'Copyleaks hat je nach Plan API-Nutzungsbeschränkungen; TruthLens hat keine Nutzungsbeschränkungen.';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'Die OCR-Bilderkennung von Winston AI erfordert das Hochladen von Bildern in die Cloud; TruthLens verwendet plattformspezifische native Frameworks (Vision auf iOS/macOS, ML Kit auf Android, Windows.Media.Ocr auf Windows), um Text auf dem Gerät zu erkennen.';

  @override
  String get helpVsWinston2 =>
      'Winston AI ist bekannt für ordentliche, druckbare Berichte; TruthLens generiert das Berichtslayout dynamisch per KI (fällt auf eine Vorlage zurück, wenn kein LLM installiert ist), exportierbar als PDF/CSV/JSON/PNG.';

  @override
  String get helpAdvantagesTitle => 'Exklusive Vorteile von TruthLens';

  @override
  String get helpAdvantage1 =>
      'Verifizierung der Hyperlink-Authentizität: prüft automatisch, ob im Dokument gefundene URLs tatsächlich erreichbar sind; akademische Links im DOI-Format werden zusätzlich gegen das öffentliche Crossref-Register verifiziert, um zu bestätigen, dass die Zeitschrift die Arbeit tatsächlich indiziert.';

  @override
  String get helpAdvantage2 =>
      'Verifizierung der Zitat-Authentizität: selbst Referenzen ohne jeglichen Hyperlink (der übliche \"Autor-Jahr\"-Stil) können gegen Bibliografieregister geprüft werden, um möglicherweise erfundene Zitate zu erkennen — ein häufiges Zeichen für KI-Halluzinationen.';

  @override
  String get helpAdvantage3 =>
      'ESL-Verzerrungskorrektur (Nicht-Muttersprachler): erkennt automatisch Schreibmerkmale von Nicht-Muttersprachlern und verringert das Gewicht des statistischen Modells, um zu vermeiden, dass natürliches Schreiben von Nicht-Muttersprachlern fälschlicherweise als KI eingestuft wird.';

  @override
  String get helpAdvantage4 =>
      'Import benutzerdefinierter Modelle: fortgeschrittene Benutzer können ihre eigenen lokalen ONNX-Modelle importieren, um integrierte Erkennungs-Engines zu ersetzen oder zu ergänzen.';

  @override
  String get helpWorkflowTitle => 'Vollständiger Betriebsablauf';

  @override
  String helpWorkflowStepLabel(int step) {
    return 'Schritt $step';
  }

  @override
  String get helpWorkflowStep1Title => 'Modelle herunterladen & aktualisieren';

  @override
  String get helpWorkflowStep1Body =>
      'Beim ersten Start werden Sie durch die Installation des Kern-Erkennungsmodells geführt; danach können Sie jederzeit Modelle unter \"Einstellungen → KI-Modellverwaltung\" prüfen, herunterladen, aktualisieren oder entfernen. Die App prüft beim Start proaktiv auf die neuesten Versionen und zeigt ein Abzeichen auf dem Einstellungssymbol und dem Eintrag \"KI-Modellverwaltung\" an, wenn ein Update verfügbar ist.';

  @override
  String get helpWorkflowStep2Title => 'Modelle auswählen (Zweck & Auswirkung)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Mehrsprachiger KI-Klassifikator (Gewicht 40%): analysiert begrenzte Absatzblöcke mit Kontext und ordnet die Wahrscheinlichkeiten anschließend den Sätzen zu.';

  @override
  String get helpWorkflowStep2Bullet2 =>
      'Statistisches Analysemodul (Gewicht 25%): Gleitfenster-Analyse von Perplexität und Burstiness, erfasst den regelmäßigen Rhythmus und die vorhersehbare Wortwahl von KI-Text.';

  @override
  String get helpWorkflowStep2Bullet3 =>
      'Stilometrische Analyse (Gewicht 20%): semantische Flüssigkeit, wiederkehrende Satzmuster, Verwendung von Übergangswörtern — am erklärbarsten, am leichtesten zu verstehen, \"warum\".';

  @override
  String get helpWorkflowStep2Bullet4 =>
      'Adversariale Abwehr (Gewicht 15%): erkennt Text, der mit Paraphrasierungstools (z. B. QuillBot, Undetectable.ai) \"gereinigt\" wurde.';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'Bericht-LLM (optional): nach der Installation wird der Berichtstext dynamisch von einem LLM auf dem Gerät verfasst; ohne dieses greift die App auf eine feste Vorlage zurück — die Analyse selbst ist nicht betroffen.';

  @override
  String get helpWorkflowStep2Bullet6 =>
      'Sie können Engines einzeln aktivieren/deaktivieren und die Vertrauensschwelle der KI-Erkennung in den Einstellungen anpassen (eine Erhöhung verringert die Wahrscheinlichkeit, menschliches Schreiben fälschlicherweise als KI einzustufen).';

  @override
  String get helpWorkflowStep3Title => 'Ein Dokument hochladen';

  @override
  String get helpWorkflowStep3Body =>
      'Drei Eingabemethoden: direktes Einfügen von Text, Bild-OCR (auf dem Gerät mit plattformspezifischen nativen Frameworks erkannt) oder Dateiimport (txt / md / pdf / docx / doc). Der Text muss mindestens 40 Zeichen umfassen, um zur Analyse eingereicht zu werden.';

  @override
  String get helpWorkflowStep4Title => 'Analyse ausführen';

  @override
  String get helpWorkflowStep4Body =>
      'Tippen Sie auf \"Erkennung starten\", und alle vier Engines laufen parallel, wobei der Fortschritt live auf dem Bildschirm angezeigt wird. Wenn Schreibmerkmale von Nicht-Muttersprachlern erkannt werden, wird die ESL-Verzerrungskorrektur automatisch angewendet (kann in den Einstellungen deaktiviert werden).';

  @override
  String get helpWorkflowStep5Title => 'Ergebnisse anzeigen & exportieren';

  @override
  String get helpWorkflowStep5Body =>
      'Die Berichtsseite umfasst: den Gesamtindikator der KI-Wahrscheinlichkeit, die Heatmap auf Satzebene, die Aufschlüsselung von Punktzahl und Gründen jeder Engine, die Hyperlink-Authentizität und die Zitat-Authentizität. Sie können den vollständigen PDF-Bericht, satzweise CSV-Daten, JSON (für Systemintegration) oder eine PNG-Übersichtskarte (zum Teilen) exportieren. Jede Analyse wird automatisch im \"Verlauf\" zur späteren Überprüfung gespeichert.';

  @override
  String get helpWorkflowStep1ChipOnboarding => 'Erster Start';

  @override
  String get helpWorkflowStep1ChipModelManager => 'Modellverwaltung';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => 'Auto-Updateprüfung';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => 'Statistische Analyse (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => 'Stilometrie (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => 'Adversarial Defense (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => 'Berichts-LLM (optional)';

  @override
  String get helpWorkflowStep3ChipPaste => 'Text einfügen';

  @override
  String get helpWorkflowStep3ChipImageOcr => 'Bild-OCR';

  @override
  String get helpWorkflowStep3ChipImportFormats => 'PDF / DOCX / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation =>
      'Code/Formeln isolieren';

  @override
  String get helpWorkflowStep4ChipEnsemble => '4-Engine-Ensemble';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'Live-Fortschritt';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'ESL-Korrektur';

  @override
  String get helpWorkflowStep4ChipStoppable => 'Stop anytime';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'KI-Übersichtsanzeige';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => 'Satz-Heatmap';

  @override
  String get helpWorkflowStep5ChipCitationVerification => 'Zitierungsprüfung';

  @override
  String get helpWorkflowStep5ChipExportFormats =>
      'PDF / CSV / JSON / PNG exportieren';

  @override
  String get helpTuningTitle =>
      'Anleitung zum Herunterladen & Anpassen von Modellen (keine Erfahrung erforderlich)';

  @override
  String get helpTuningStep1Title => 'Modellverwaltung öffnen';

  @override
  String get helpTuningStep1Body =>
      'Tippen Sie auf dem Hauptbildschirm auf das Zahnradsymbol, um \"Einstellungen\" zu öffnen, und tippen Sie dann auf \"Öffnen\" neben \"KI-Modellverwaltung\".';

  @override
  String get helpTuningStep2Title => 'Modell für Ihr Gerät wählen';

  @override
  String get helpTuningStep2Body =>
      'Der Bildschirm schlägt automatisch die geeignete Modellstufe basierend auf den Fähigkeiten Ihres Geräts vor (RAM, CPU-Kerne) und listet jede verfügbare Variante für jede Rolle auf (mehrsprachiger Klassifikator / statistische Analyse / adversariale Abwehr / Bericht-LLM).';

  @override
  String get helpTuningStep3Title => 'Herunterladen & verwenden';

  @override
  String get helpTuningStep3Body =>
      'Tippen Sie auf \"Herunterladen\" neben dem gewünschten Modell und warten Sie den Abschluss ab — das erste heruntergeladene Modell wird automatisch als aktiv festgelegt. Wenn Sie mehrere Varianten installiert haben, tippen Sie auf \"Als aktiv festlegen\", um jederzeit zu wechseln; tippen Sie auf das Papierkorbsymbol, um nicht benötigte Modelle zu entfernen und Speicherplatz freizugeben.';

  @override
  String get helpTuningStep4Title => 'Modelle aktualisieren';

  @override
  String get helpTuningStep4Body =>
      'Wenn eine neue Version verfügbar ist, zeigen \"KI-Modellverwaltung\" und das Einstellungs-Zahnradsymbol ein Abzeichen an — kehren Sie zu diesem Bildschirm zurück, um das Update anzuzeigen und herunterzuladen (zuvor installierte Versionen bleiben erhalten, sofern Sie sie nicht manuell entfernen).';

  @override
  String get helpTuningStep5Title =>
      'Erweitert: benutzerdefinierte Modelle importieren';

  @override
  String get helpTuningStep5Body =>
      'Wenn Sie bereits ein kompatibles .onnx-Modell an anderer Stelle haben oder angepasst haben, können Sie es über \"Einstellungen → Benutzerdefiniertes ONNX-Modell importieren & testen\" importieren — Sie müssen die Modelldatei, die entsprechende Tokenizer-Konfiguration (oder \"keine\" wählen) und den KI-Klassenindex angeben. Vor dem Import prüft die App automatisch, ob dieselbe Datei bereits importiert wurde, um versehentliche Duplikate zu vermeiden.';

  @override
  String get helpOfficialLinksTitle => 'Offizielle Modell-Download-Links';

  @override
  String get helpOfficialLinksHint =>
      'Durch Antippen eines Elements wird die offizielle Seite dieses Modells in Ihrem Systembrowser geöffnet.';

  @override
  String get helpLinkRoleTransformer =>
      'Mehrsprachiger KI-Klassifikator (Transformer, Gewicht 40%)';

  @override
  String get helpLinkRoleStatistical =>
      'Statistisches Perplexitätsmodell (Statistical, Gewicht 25%)';

  @override
  String get helpLinkRoleAdversarial =>
      'Modell zur Erkennung adversarialer Paraphrasierung (Adversarial, Gewicht 15%)';

  @override
  String get helpLinkRoleLlm => 'Bericht-LLM (optional)';

  @override
  String get privacyAppBarTitle => 'Datenschutzrichtlinie';

  @override
  String privacyPlatformTitle(String platform) {
    return 'Datenschutzrichtlinie für $platform';
  }

  @override
  String privacyLastUpdated(String date) {
    return 'Zuletzt aktualisiert: $date';
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
      'TruthLens sammelt keine Daten, die mit Ihrer Identität verknüpft sind, und verwendet keine Daten zum Tracking, sodass keine App-Tracking-Transparenz-Berechtigung (ATT) erforderlich ist.';

  @override
  String get privacyIosOverview2 =>
      'Diese App verwendet den System-Dateiauswähler, um auf Dateien oder Bilder zuzugreifen, die Sie aktiv auswählen; sie kann nicht auf Dateien zugreifen, die Sie nicht ausgewählt haben (durchgesetzt durch die iOS-App-Sandbox).';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLens sammelt keine personenbezogenen Daten und gibt keine Benutzerdaten an Dritte weiter.';

  @override
  String get privacyAndroidOverview2 =>
      'Diese App greift nur dann auf den Speicher zu, wenn Sie aktiv den Import einer Datei oder eines Bildes auswählen; sie durchsucht oder greift nicht im Hintergrund auf andere Dateien zu.';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens läuft unter der macOS-App-Sandbox und kann nur auf Dateien zugreifen, die Sie aktiv über den System-Dateidialog auswählen (files.user-selected.read-write) — sie kann nicht selbstständig andere Dateien oder Ordner durchsuchen oder darauf zugreifen.';

  @override
  String get privacyMacosOverview2 =>
      'Netzwerkzugriff (network.client) wird nur für die unten unter \"Erforderliches Verbindungsverhalten\" aufgeführten Funktionen verwendet.';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens ist eine eigenständige Desktop-Anwendung; Daten werden in Ihrem lokalen Benutzerordner gespeichert (z. B. AppData/Documents) und niemals mit der Cloud synchronisiert.';

  @override
  String get privacyWindowsOverview2 =>
      'Diese App greift nur auf Dateien zu, die Sie aktiv zum Importieren auswählen; sie durchsucht keine anderen Dateien im Hintergrund.';

  @override
  String get privacyDataHandling1 =>
      'TruthLens hat keine Benutzerkonten, erfordert keine Anmeldung und enthält in keiner Form Werbe- oder Tracking-SDKs von Dritten.';

  @override
  String get privacyDataHandling2 =>
      'Jeglicher Dokumentinhalt, den Sie eingeben, einfügen oder importieren, wird vollständig von KI-Modellen auf Ihrem eigenen Gerät analysiert — er wird niemals auf TruthLens oder Server Dritter hochgeladen.';

  @override
  String get privacyDataHandling3 =>
      'Analyseergebnisse und Verlauf werden nur in einer lokalen Datenbank auf Ihrem Gerät gespeichert; das Deinstallieren der App oder das Löschen des Verlaufs entfernt sie vollständig — TruthLens speichert keine Kopien an anderer Stelle.';

  @override
  String get privacyNetworkIntro =>
      'Die Kern-KI-Erkennung dieser App läuft vollständig auf dem Gerät, aber die folgenden drei Funktionen erfordern Netzwerkzugriff:';

  @override
  String get privacyNetwork1 =>
      '1. Modellkatalog & -download: verbindet sich mit GitHub Releases/Hugging Face, um das von Ihnen gewählte Erkennungsmodell herunterzuladen — dies lädt nur das Modell herunter und sendet niemals Benutzerdaten.';

  @override
  String get privacyNetwork2 =>
      '2. Modell-Update-Prüfung: beim Start verbindet sich die App nur, um Versionsnummern zu vergleichen, um anzuzeigen, ob eine neue Version verfügbar ist.';

  @override
  String get privacyNetwork3 =>
      '3. Verifizierung der Hyperlink- & Zitat-Authentizität: standardmäßig aktiviert, kann in den Einstellungen deaktiviert werden. Bei Aktivierung wird die im Dokument erkannte URL oder der Bibliografietext direkt an diese URL selbst oder an die öffentliche Crossref-API gesendet, wobei nur der Text der URL/DOI/des Zitats selbst gesendet wird — niemals der übrige Dokumentinhalt.';

  @override
  String get privacyNetwork4 =>
      '4. Web OCR fallback: on the Web version only, OCR first uses a local OCR server if configured. If you choose to enter a Gemini API key, selected images and rendered pages from PDFs that require OCR are sent directly from your browser to Google\'s Gemini API; the key is stored only in that browser\'s local storage.';

  @override
  String get privacyRightsIntro =>
      'Sie können Ihren lokalen Analyseverlauf jederzeit im \"Verlauf\" löschen, die Hyperlink-/Zitatverifizierung in den \"Einstellungen\" deaktivieren oder alle lokalen Daten entfernen durch';

  @override
  String get privacyRemoveIos => 'Löschen der App';

  @override
  String get privacyRemoveAndroid => 'Deinstallieren der App';

  @override
  String get privacyRemoveMacos => 'Verschieben der App in den Papierkorb';

  @override
  String get privacyRemoveWindows => 'Deinstallieren der App';

  @override
  String get privacyDisclaimer =>
      'Diese Seite ist eine von TruthLens verfasste Datenschutzerklärung, die das tatsächliche Funktionsverhalten widerspiegelt, kein formelles, von einem Anwalt geprüftes Rechtsdokument; für eine formelle Compliance-Prüfung nach den Gesetzen Ihrer Region konsultieren Sie bitte einen unabhängigen Anwalt.';

  @override
  String get privacySectionOverviewIos =>
      'Übersicht (entspricht den \"Datenschutzangaben\" des App Store)';

  @override
  String get privacySectionOverviewAndroid =>
      'Übersicht (entspricht der \"Datensicherheit\"-Offenlegung von Google Play)';

  @override
  String get privacySectionOverviewMacos =>
      'Übersicht (App-Sandbox-Berechtigungen)';

  @override
  String get privacySectionOverviewWindows => 'Übersicht';

  @override
  String get privacySectionDataHandling => 'Wie wir Ihre Daten behandeln';

  @override
  String get privacySectionNetwork => 'Erforderliche Netzwerkverbindungen';

  @override
  String get privacySectionRights => 'Ihre Rechte';

  @override
  String get privacyGenericPlatformName => 'Diese Plattform';

  @override
  String get settingsLanguagePackDialogBody =>
      'Der integrierte mehrsprachige Detektor von TruthLens unterstützt bereits über 104 Sprachen. In der KI-Modellverwaltung können Sie sprachoptimierte Community-Modelle suchen, herunterladen oder wechseln.';

  @override
  String settingsVersionSubtitle(String version, String build) {
    return 'Version $version (Build $build) · Lokale, datenschutzfreundliche Erkennung';
  }

  @override
  String get webOcrSettingsTitle => 'Web-OCR-Einstellungen';

  @override
  String get webOcrPurpose =>
      'Gedruckten oder handgeschriebenen Text in einem Bild vor der Analyse erkennen.';

  @override
  String get webOcrGeminiKeyTitle => 'Gemini-API-Schlüssel (optional)';

  @override
  String get webOcrGetKeyButton => 'Schlüssel abrufen';

  @override
  String get webOcrGeminiDescription =>
      'Wird nur verwendet, wenn der lokale OCR-Server nicht verfügbar ist. Der Schlüssel bleibt in diesem Browser.';

  @override
  String get webOcrLocalServerTitle => 'Lokaler OCR-Server (empfohlen)';

  @override
  String get webOcrLocalServerDescription =>
      'OCR läuft auf Ihrem Computer: Apple Vision unter macOS oder Windows OCR unter Windows. Geben Sie unten den lokalen Endpunkt ein.';

  @override
  String get webOcrSetupGuideButton => 'Einrichtungsanleitung';

  @override
  String get webOcrPriorityTitle => 'Erkennungsreihenfolge';

  @override
  String get webOcrPriorityDescription =>
      '1. Lokaler OCR-Server bei gesetzter URL\n2. Gemini bei gesetztem API-Schlüssel\n3. Genaue Diagnose, wenn beide Wege fehlschlagen';

  @override
  String get webOcrSetupGuideTitle => 'Lokalen OCR-Server einrichten';

  @override
  String get webOcrSetupGuideBody =>
      '1. Wählen Sie unten OCR-Projekt öffnen.\n2. macOS: Laden Sie setup_and_run_ocr.sh herunter, öffnen Sie Terminal und führen Sie aus: bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows: Laden Sie setup_and_run_ocr.bat herunter, doppelklicken Sie darauf und erlauben Sie die Installation.\n4. Warten Sie, bis der Installer meldet, dass OCR bereit ist; der Autostart wird ebenfalls eingerichtet.\n5. Geben Sie hier http://127.0.0.1:5001/ocr ein und wählen Sie Verbindung testen.\n6. Öffnen Sie Bild-OCR und wählen Sie ein deutliches Bild.\n\nFür 127.0.0.1 müssen Browser und OCR-Server auf demselben Computer laufen. Prüfen Sie bei Fehlern Installation, Port 5001 und die Endung /ocr.';

  @override
  String get webOcrOpenProjectButton => 'OCR-Projekt öffnen';

  @override
  String get webOcrTestServerButton => 'Verbindung testen';

  @override
  String get webOcrTestServerMissingUrl =>
      'Geben Sie zuerst die URL des lokalen OCR-Servers ein.';

  @override
  String get webOcrTestServerSuccess =>
      'Der lokale OCR-Server läuft und ist bereit.';

  @override
  String get webOcrTestServerFailure =>
      'Der lokale OCR-Server ist nicht erreichbar. Prüfen Sie Anleitung, Firewall und URL.';

  @override
  String get workspaceModeSectionTitle => 'Arbeitsbereichsmodus';

  @override
  String get workspaceModeSectionSubtitle =>
      'Wählen Sie, wie Quelle, Live-Analyse und Belege in einem Arbeitsbereich erscheinen.';

  @override
  String get workspaceModeOriginal => 'Ursprüngliches Layout';

  @override
  String get workspaceModeAuto => 'Automatisch';

  @override
  String get workspaceModeCommandGrid => 'Kommandoraster';

  @override
  String get workspaceModeTimeline => 'Missionszeitachse';

  @override
  String get workspaceModeEvidence => 'Beweisfläche';

  @override
  String get workspaceModeCosmicFuture => 'Cosmic Future';

  @override
  String get workspaceModeSoftEducation => 'Soft Education';

  @override
  String get workspaceModeTooltip => 'Arbeitsbereichsmodus wechseln';

  @override
  String get workspaceMoreMenuTooltip => 'More options';

  @override
  String get workspaceLanguageMenuTitle => 'Language';

  @override
  String get workspaceStageImport => 'Import';

  @override
  String get workspaceStageParse => 'Auswertung';

  @override
  String get workspaceStageAnalyze => 'Vier-Engine-Analyse';

  @override
  String get workspaceStageVerify => 'Prüfung';

  @override
  String get workspaceStageReport => 'Bericht';

  @override
  String get workspaceLiveFindings => 'Live-Ergebnisse';

  @override
  String get workspaceTelemetry => 'Analyse-Telemetrie';

  @override
  String get workspaceDocument => 'Dokumentbereich';

  @override
  String get workspaceOverallProgress => 'Gesamtfortschritt';

  @override
  String get workspaceWaiting => 'Warten auf ein Dokument';

  @override
  String get workspaceAnalyzing => 'Analyse läuft';

  @override
  String get workspaceAnalysisComplete => 'Analyse abgeschlossen';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '$done/$total Module abgeschlossen · ${seconds}s vergangen · Aktiv: $engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return 'Die Analyse läuft weiter und die Oberfläche reagiert. Seit ${seconds}s wurde kein Modul abgeschlossen; große Dokumente oder lokale Modelle können länger dauern.';
  }

  @override
  String get workspaceAnalysisFailed =>
      'Die Analyse wurde unerwartet beendet. Bitte erneut versuchen oder die Modelleinstellungen prüfen.';

  @override
  String get workspaceNewAnalysis => 'Neue Analyse';

  @override
  String get workspaceStopAnalysis => 'Analyse stoppen';

  @override
  String get workspaceStopAnalysisTitle => 'Aktuelle Analyse stoppen?';

  @override
  String get workspaceStopAnalysisBody =>
      'Die Analyse läuft noch. Der Dokumenttext bleibt erhalten, unvollständige Ergebnisse werden jedoch nicht gespeichert.';

  @override
  String get workspaceAnalysisStopped =>
      'Analyse gestoppt. Der Dokumenttext bleibt im Arbeitsbereich erhalten.';

  @override
  String get workspaceSelectedEvidence => 'Ausgewählter Beleg';

  @override
  String get workspaceNoEvidence =>
      'Satzbelege erscheinen hier, sobald die Engines fertig sind.';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return 'Vorläufige KI-Wahrscheinlichkeit: $percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      'This percentage is this sentence\'s own AI signal, not the overall document verdict. Higher means the wording pattern looks more AI-generated; lower means it reads more like typical human writing. The final report combines every sentence with engine weighting.';

  @override
  String get workspaceSentenceSignalHeader => 'AI signal per sentence';

  @override
  String get workspaceSentenceColumnHeader => 'Sentence';
}
