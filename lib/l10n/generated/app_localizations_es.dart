// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get verdictHuman => 'Escrito por humano';

  @override
  String get verdictLikelyHuman => 'Probablemente humano';

  @override
  String get verdictMixed => 'Contenido mixto';

  @override
  String get verdictLikelyAi => 'Probablemente IA';

  @override
  String get verdictAi => 'Generado por IA';

  @override
  String get inputSubtitle =>
      'Pega o escribe texto para detectar contenido generado por IA';

  @override
  String get inputHint => 'Escribe o pega el texto a analizar…';

  @override
  String get inputHistoryTooltip => 'Historial';

  @override
  String get inputHelpTooltip => 'Guía del usuario';

  @override
  String get inputPrivacyTooltip => 'Política de privacidad';

  @override
  String get inputSettingsTooltip => 'Ajustes';

  @override
  String get inputPasteButton => 'Pegar';

  @override
  String get inputOcrButton => 'OCR de imagen';

  @override
  String get inputImportButton => 'Importar archivo';

  @override
  String get inputStartButton => 'Iniciar detección';

  @override
  String get inputClearTooltip => 'Borrar contenido';

  @override
  String get inputTooShortSnackbar =>
      'Introduce al menos 40 caracteres para un análisis fiable';

  @override
  String get inputOcrUnsupported =>
      'El reconocimiento de texto OCR no es compatible con esta plataforma';

  @override
  String get inputOcrRecognizing => 'Reconociendo…';

  @override
  String get inputOcrNoText => 'No se identificó texto en la imagen';

  @override
  String inputOcrRecognized(int count) {
    return 'Se identificaron $count caracteres';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\" no contiene texto legible';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '\"$fileName\" importado ($count caracteres)';
  }

  @override
  String inputActiveModel(String modelId) {
    return 'Modelo: $modelId';
  }

  @override
  String get inputNoModel =>
      'No hay modelo instalado (solo análisis estadístico/estilométrico)';

  @override
  String inputCharCount(int count) {
    return '$count caracteres';
  }

  @override
  String get analysisAppBarTitle => 'Analizando';

  @override
  String get analysisEngineTransformer => 'Clasificador Transformer';

  @override
  String get analysisEngineStatistical => 'Análisis estadístico';

  @override
  String get analysisEngineStylometry => 'Análisis estilométrico';

  @override
  String get analysisEngineAdversarial => 'Defensa adversarial';

  @override
  String analysisProgressSemantics(int done, int total) {
    return 'Análisis en curso, $done de $total motores completados';
  }

  @override
  String get analysisDoneSemantics => 'Completado';

  @override
  String get engineNameAdversarialFull =>
      'Defensa adversarial (detección de paráfrasis)';

  @override
  String get modelNecessityText =>
      'Sin descargar el modelo de detección de red neuronal, TruthLens sigue funcionando, pero solo con análisis estadístico y estilométrico, con precisión y soporte multilingüe limitados. Tras descargar el modelo, el clasificador Transformer multilingüe se sumará a la votación conjunta, mejorando notablemente la precisión y la fiabilidad. El modelo se ejecuta en el dispositivo; una vez descargado, no sube ningún contenido.';

  @override
  String get modelPromptTitle =>
      'Se recomienda descargar el modelo de detección para un análisis completo';

  @override
  String get modelPromptDontRemind => 'No recordar de nuevo';

  @override
  String get modelPromptSkip => 'Omitir por ahora';

  @override
  String get modelPromptDownload => 'Ir a descargar';

  @override
  String get onboardingWelcomeTitle => 'Bienvenido a TruthLens';

  @override
  String get onboardingHeadline =>
      'Detección de contenido de IA en el dispositivo';

  @override
  String get onboardingDetectedDevice => 'Dispositivo detectado';

  @override
  String get onboardingChooseModel => 'Elige un modelo para descargar';

  @override
  String get onboardingRecommendHint =>
      '\"Recomendado\" se marca según tu hardware; también puedes elegir otra opción.';

  @override
  String get onboardingSkipButton =>
      'Decidir más tarde (usar análisis estadístico/estilométrico sin modelo)';

  @override
  String get onboardingSkipHint =>
      'Puedes descargar en cualquier momento desde \"Ajustes → Gestión de modelos de IA\"; se te recordará de nuevo al usar análisis que requieran el modelo.';

  @override
  String get modelListCustomImportedLabel => 'Modelo personalizado importado:';

  @override
  String get modelListActiveChip => 'En uso';

  @override
  String get modelListRecommendedChip => 'Recomendado';

  @override
  String get modelListCustomChip => 'Personalizado';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · Requiere ${ram}GB RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'Tamaño: $size · Tokenizador: $tokenizer · Índice de etiqueta IA: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'Descargando… $percent% ($downloaded / $total)';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'Descargar ($size)';
  }

  @override
  String get modelListComingSoonChip => 'Próximamente';

  @override
  String get modelListSetActiveButton => 'Establecer como activo';

  @override
  String get modelListUpdateButton => 'Actualizar';

  @override
  String get modelListDeleteTooltip => 'Eliminar';

  @override
  String get modelListPageButton => 'Página del modelo';

  @override
  String get modelListMayExceedMemory =>
      'Puede exceder la memoria del dispositivo';

  @override
  String modelListFailedPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String get modelListDeleteConfirmTitle => '¿Eliminar el modelo?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return 'Esto eliminará \"$name\" ($size). Deberás volver a descargarlo para usarlo de nuevo.';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'Esto eliminará el modelo personalizado importado \"$name\" ($size). Deberás volver a importarlo para usarlo de nuevo.';
  }

  @override
  String get modelImportAppBarTitle => 'Importar modelo ONNX personalizado';

  @override
  String get modelImportStep1Title =>
      '1. Selecciona el archivo del modelo ONNX';

  @override
  String modelImportSelectedFile(String name) {
    return 'Seleccionado: $name';
  }

  @override
  String get modelImportNoFileSelected =>
      'No se seleccionó archivo de modelo (.onnx)';

  @override
  String get modelImportBrowseButton => 'Examinar';

  @override
  String get modelImportCheckingDuplicate =>
      'Comprobando si ya se importó un archivo idéntico…';

  @override
  String get modelImportDuplicateTitle =>
      'Ya se importó un modelo con el mismo contenido';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'Este archivo tiene contenido idéntico a \"$name\" (función: $role). Si solo quieres cambiar el modelo activo, ve a \"Gestión de modelos de IA\" y establécelo directamente como activo, sin necesidad de reimportarlo. Aun así, puedes continuar con los pasos siguientes.';
  }

  @override
  String get modelImportStep2Title => '2. Configuración';

  @override
  String get modelImportNameLabel => 'Nombre visible del modelo';

  @override
  String get modelImportNameRequired => 'El nombre no puede estar vacío';

  @override
  String get modelImportRoleLabel => 'Función del motor de destino';

  @override
  String get modelImportTokenizerTypeLabel => 'Tipo de tokenizador';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone =>
      'Ninguno (sin tokenizador/a nivel de carácter)';

  @override
  String get modelImportNoTokenizerSelected =>
      'No se seleccionó archivo de tokenizador (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return 'Seleccionado: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'Índice de salida de etiqueta IA';

  @override
  String get modelImportIndex0 => 'Índice 0 (p. ej. RoBERTa)';

  @override
  String get modelImportIndex1 => 'Índice 1 (p. ej. DistilBERT)';

  @override
  String get modelImportStep3Title => '3. Probar y verificar';

  @override
  String get modelImportTestInputLabel => 'Texto de entrada de prueba';

  @override
  String get modelImportRunTestButton => 'Ejecutar inferencia de prueba';

  @override
  String get modelImportResultLabel =>
      'Resultado de la inferencia (probabilidad de IA):';

  @override
  String modelImportTestFailed(String error) {
    return 'Prueba fallida: $error';
  }

  @override
  String get modelImportConfirmButton =>
      'Confirmar importación y activar modelo';

  @override
  String get modelImportSelectTokenizerFirst =>
      'Selecciona primero un archivo de tokenizador';

  @override
  String get modelImportSelectTokenizer =>
      'Selecciona un archivo de tokenizador';

  @override
  String get modelImportSuccessSnackbar =>
      '¡Modelo importado correctamente! Se ha establecido automáticamente como modelo activo.';

  @override
  String get modelImportFailedSnackbar =>
      'Error al importar el modelo. Verifica los permisos o los registros';

  @override
  String get settingsAppBarTitle => 'Ajustes';

  @override
  String get settingsThresholdTitle => 'Umbral de confianza para determinar IA';

  @override
  String settingsThresholdSubtitle(int percent) {
    return 'Actual: $percent% — aumentarlo reduce los falsos positivos (texto humano clasificado erróneamente como IA)';
  }

  @override
  String get settingsEslTitle => 'Corrección de sesgo ESL (no nativo)';

  @override
  String get settingsEslSubtitle =>
      'Reduce automáticamente el peso del modelo estadístico al detectar un estilo de escritura de no nativo';

  @override
  String get settingsEngineSectionTitle =>
      'Configuración de submotores de detección (conjunto)';

  @override
  String get settingsEngineTransformerTitle =>
      'Clasificador de IA multilingüe (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Utiliza un modelo de red neuronal Transformer para predecir la probabilidad de IA en el dispositivo';

  @override
  String get settingsEngineStatisticalTitle =>
      'Motor de análisis estadístico (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      'Determina la regularidad del lenguaje mediante la variación de longitud de oraciones, Burstiness y PPL';

  @override
  String get settingsEngineStylometryTitle =>
      'Análisis estilométrico (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle =>
      'Analiza la fluidez semántica, los patrones de oraciones repetitivos y el uso de conectores';

  @override
  String get settingsEngineAdversarialTitle =>
      'Detección de paráfrasis adversarial (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle =>
      'Detecta si el texto ha sido parafraseado por máquina o procesado para eliminar rastros de IA';

  @override
  String get settingsLinkVerificationTitle =>
      'Verificación de hipervínculos y bibliografía';

  @override
  String get settingsLinkVerificationSubtitle =>
      'El informe se conectará para comprobar si las URL y las entradas bibliográficas detectadas en el documento realmente existen (el contenido generado por IA suele incluir referencias que parecen plausibles pero son inventadas). Tanto los enlaces académicos con formato DOI como las referencias con formato \"autor-año\" sin enlace se verifican contra el registro público de Crossref. El modelo de detección de IA principal sigue funcionando completamente en el dispositivo y nunca envía el contenido del documento; la conexión solo se usa para esta verificación y para comprobar actualizaciones del modelo, y puede desactivarse aquí.';

  @override
  String get settingsThemeTitle => 'Tema de visualización';

  @override
  String get settingsLanguageTitle => 'Idioma';

  @override
  String get settingsLanguageSubtitle =>
      'Elige el idioma de visualización de la aplicación';

  @override
  String get settingsModelManagementTitle => 'Gestión de modelos de IA';

  @override
  String get settingsModelManagementSubtitle =>
      'Descarga modelos de detección y el LLM de redacción de informes para habilitar la capacidad de inferencia completa';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'Actualización de modelo detectada — se recomienda revisar';

  @override
  String get settingsOpenButton => 'Abrir';

  @override
  String get settingsCustomImportTitle =>
      'Importar y probar modelo ONNX personalizado';

  @override
  String get settingsCustomImportSubtitle =>
      'Importa un modelo ONNX personalizado local, configura el tokenizador y ejecuta una prueba de inferencia';

  @override
  String get settingsLanguagePackTitle => 'Paquete de idiomas';

  @override
  String get settingsLanguagePackSubtitle =>
      'Modelo de ajuste de idioma adicional (disponible en la fase 4)';

  @override
  String get settingsModelManagerAppBarTitle => 'Gestión de modelos de IA';

  @override
  String get settingsImportTooltip => 'Importar modelo ONNX local';

  @override
  String settingsDeviceLabel(String summary) {
    return 'Dispositivo: $summary';
  }

  @override
  String get historyAppBarTitle => 'Historial';

  @override
  String get historyClearAllTooltip => 'Borrar todo';

  @override
  String get historySearchHint => 'Buscar en el historial…';

  @override
  String get historyDeletedSnackbar => 'Entrada eliminada';

  @override
  String get historyClearAllTitle => '¿Borrar todo el historial?';

  @override
  String historyClearAllBody(int count) {
    return 'Esto eliminará las $count entradas. Esta acción no se puede deshacer.';
  }

  @override
  String get historyClearButton => 'Borrar';

  @override
  String get historyDeleteEntryTitle => '¿Eliminar esta entrada?';

  @override
  String get historyReanalyzeTooltip => 'Volver a analizar';

  @override
  String get historyEmptyDefault => 'Aún no hay historial de detección';

  @override
  String historyEmptySearch(String query) {
    return 'No hay entradas que coincidan con \"$query\"';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, probabilidad de IA $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => 'Informe de detección';

  @override
  String get reportExportTooltip => 'Exportar informe';

  @override
  String get reportHomeTooltip => 'Volver al inicio';

  @override
  String get reportGeneratingTitle => 'Generando informe…';

  @override
  String get reportSourceLlm => 'Informe generado por IA';

  @override
  String get reportSourceTemplate => 'Informe generado por plantilla';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '$total oraciones · $ai probablemente IA · $human probablemente humano · $seconds s transcurridos';
  }

  @override
  String get reportExportPdf => 'Exportar informe PDF';

  @override
  String get reportExportCsv => 'Exportar datos CSV';

  @override
  String get reportExportJson => 'Exportar JSON (integración de sistemas)';

  @override
  String get reportExportPng => 'Exportar tarjeta resumen (PNG)';

  @override
  String reportExported(String path) {
    return 'Exportado: $path';
  }

  @override
  String reportExportFailed(String error) {
    return 'Error al exportar: $error';
  }

  @override
  String get reportEngineBreakdownTitle => 'Desglose por motor';

  @override
  String get reportEngineNotInstalled => 'No instalado';

  @override
  String get reportSentenceAnalysisTitle => 'Análisis a nivel de oración';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text. Probabilidad de IA $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'Autenticidad de hipervínculos';

  @override
  String get reportLinkNoneDetected =>
      'No se detectaron hipervínculos en este documento.';

  @override
  String get reportLinkCheckingProgress => 'Verificando enlaces…';

  @override
  String reportLinkDetectedPending(int count) {
    return 'Se detectaron $count hipervínculos; aún no verificados';
  }

  @override
  String get reportLinkDisabledHint =>
      'El contenido generado por IA suele incluir enlaces de referencia que parecen plausibles pero son inventados. Has desactivado la verificación de hipervínculos en Ajustes; puedes volver a activarla para la verificación automática, o tocar abajo para una comprobación única.';

  @override
  String get reportVerifyNowButton => 'Verificar ahora (requiere red)';

  @override
  String get reportLinkReachable => 'Accesible: la URL existe';

  @override
  String get reportLinkNotFound =>
      'La URL no existe (404); posible referencia inventada';

  @override
  String get reportLinkUnreachable =>
      'No se pudo verificar (tiempo de espera agotado o sin respuesta del servidor)';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'Verificado en el registro de revistas: registrado con $journal$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      'No se encontró ningún registro DOI coincidente; posible referencia inventada';

  @override
  String get reportLinkCitationUnreachable =>
      'No se pudo verificar (tiempo de espera agotado o sin respuesta de Crossref)';

  @override
  String reportLinkTruncated(int max, int count) {
    return 'Solo se verificaron los primeros $max enlaces (se detectaron $count en total)';
  }

  @override
  String get reportBibAuthenticityTitle => 'Autenticidad de las citas';

  @override
  String get reportBibNoneDetected =>
      'No se detectaron entradas bibliográficas en este documento.';

  @override
  String get reportBibCheckingProgress => 'Verificando bibliografía…';

  @override
  String reportBibDetectedPending(int count) {
    return 'Bibliografía detectada ($count entradas); aún no verificada';
  }

  @override
  String get reportBibDisabledHint =>
      'El contenido generado por IA suele incluir referencias que parecen plausibles pero son inventadas. Has desactivado la verificación de hipervínculos en Ajustes; puedes volver a activarla para la verificación automática, o tocar abajo para una comprobación única.';

  @override
  String get reportVerifyNowBibButton => 'Verificar ahora (requiere red)';

  @override
  String get reportBibResultHint =>
      'Comparado con el registro público de Crossref por similitud de autor, año y título. No es una garantía absoluta; cuando se indique \"incierto\", verifica manualmente.';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Alta confianza: probablemente existe$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (registrado con $journal)';
  }

  @override
  String get reportBibNotFound =>
      'No se encontró ninguna coincidencia cercana; posible referencia inventada';

  @override
  String get reportBibUncertain =>
      'Similitud moderada o conexión fallida; incierto, verifica manualmente';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Solo se verificaron las primeras $max entradas (se detectaron $count en total)';
  }

  @override
  String get reportNetworkWarningTitle => 'Conexión de red débil';

  @override
  String get reportNetworkWarningBody =>
      'Esta aplicación asume por defecto que hay conexión de red disponible; tanto el análisis de autenticidad de hipervínculos como el de citas requieren acceso a la red para producir resultados. No se pudo establecer conexión; verifica tu red e inténtalo de nuevo.';

  @override
  String get reportRetryConnectionButton => 'Reintentar conexión';

  @override
  String get reportAiProbabilityLabel => 'Probabilidad de IA';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '$total oraciones\n$ai probablemente IA\n$human probablemente humano';
  }

  @override
  String get summaryCardFooter =>
      'La inferencia de IA principal se ejecuta completamente en el dispositivo';

  @override
  String get exportReportTitle => 'Informe de detección de TruthLens';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · Página $page / $total';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return 'Analizado: $datetime · $seconds s transcurridos';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return 'Veredicto general: $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => ' (corrección ESL aplicada)';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '$total oraciones · $ai probablemente IA · $human probablemente humano';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'Para mantener la legibilidad del PDF, solo se muestran las primeras $max oraciones (de un total de $count); para los datos completos de cada oración, usa \"$csvLabel\" o \"$jsonLabel\" en su lugar.';
  }

  @override
  String get pdfSentenceColumnHeader => 'Oración (con patrones coincidentes)';

  @override
  String composerHeadlineAi(int percent) {
    return 'Este texto probablemente fue generado por IA (probabilidad de IA $percent%)';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'Este texto tiende a ser generado por IA; se recomienda una revisión adicional (probabilidad de IA $percent%)';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'Este texto muestra características mixtas de humano e IA (probabilidad de IA $percent%)';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'Este texto tiende a ser escrito por un humano (probabilidad de IA $percent%)';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'Este texto probablemente fue escrito por un humano (probabilidad de IA $percent%)';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return 'La probabilidad general de IA supera el umbral del $percent% que has establecido y se marcó como IA.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'La probabilidad general de IA está por debajo del umbral de marcado del $percent% que has establecido.';
  }

  @override
  String get composerNarrativeTitle => 'Interpretación del análisis';

  @override
  String get composerParaphraseTitle => 'Se detectaron rastros de paráfrasis';

  @override
  String get composerParaphraseBody =>
      'Este texto puede haber sido procesado por una herramienta de paráfrasis (p. ej. QuillBot, Undetectable.ai) para evadir la detección. Aunque parece natural oración por oración, su huella estadística general sigue siendo diferente de la escritura humana genuina; presta especial atención.';

  @override
  String get composerPatternListTitle =>
      'Principales patrones de escritura de IA';

  @override
  String get composerEslTitle => 'Corrección de sesgo ESL (no nativo)';

  @override
  String get composerEslBody =>
      'Este texto puede provenir de un escritor no nativo. La baja perplejidad y los patrones de oraciones regulares comunes entre escritores no nativos no son en sí mismos una señal de IA, por lo que el sistema ha reducido el peso del modelo estadístico para evitar clasificaciones erróneas.';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return 'Este texto tiene $total oraciones en total, de las cuales $ai muestran fuertes características de IA y $human tienden a ser escritas por un humano.';
  }

  @override
  String get composerNarrativeAiPattern =>
      'La mayoría de las oraciones son muy regulares en ritmo, elección de palabras y uso de conectores; una huella común del texto generado por IA.';

  @override
  String get composerNarrativeMixedPattern =>
      'El texto contiene partes tanto regulares como naturalmente variadas, lo que sugiere un borrador humano pulido por IA, o una colaboración humano-IA.';

  @override
  String get composerNarrativeHumanPattern =>
      'La longitud de las oraciones y la elección de palabras muestran variación natural y estilo personal, sin señales claras de regularidad de IA.';

  @override
  String engineReasonPplLow(String ppl) {
    return 'Perplejidad del modelo de lenguaje baja ($ppl); el texto es muy predecible, un indicador de generación por IA';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'Perplejidad del modelo de lenguaje alta ($ppl), acorde con la naturaleza impredecible de la escritura humana';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'Perplejidad del modelo de lenguaje moderada ($ppl)';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'Longitud de oraciones muy uniforme (burstiness $value); un ritmo homogéneo es un rastro estadístico común del texto generado por IA';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'Variación notable en la longitud de las oraciones (burstiness $value), acorde con el ritmo natural de la escritura humana';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'Diversidad de vocabulario baja (TTR $value); alta repetición de palabras';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'Diversidad de vocabulario alta (TTR $value)';
  }

  @override
  String get engineReasonNeutral =>
      'Los indicadores estadísticos no muestran una tendencia clara; se mantiene un veredicto neutral';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return 'Uso frecuente de conectores genéricos ($words), promedio $density por oración; una densidad poco común en la escritura humana';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return 'Varias oraciones consecutivas comienzan con la misma palabra ($count veces); una estructura de oración repetitiva';
  }

  @override
  String get engineReasonNoStyleMarkers =>
      'No se detectaron patrones notables de escritura de IA';

  @override
  String get engineReasonAdversarialNotInstalled =>
      'El modelo de detección de paráfrasis no está instalado; no participó en esta votación';

  @override
  String get engineReasonTransformerNotInstalled =>
      'No hay modelo instalado o el modelo activo no es compatible; no participó en esta votación';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'El modelo no se pudo cargar y no participó en esta votación ($error)';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model evaluó que $aiCount de $total oraciones muestran características de IA';
  }

  @override
  String get engineReasonAdversarialDetected =>
      'El modelo adversarial detectó posibles rastros de IA eliminados por una herramienta de paráfrasis (p. ej. QuillBot / Undetectable.ai)';

  @override
  String get engineReasonAdversarialClean =>
      'No se detectaron rastros claros de evasión mediante paráfrasis';

  @override
  String get engineReasonDisabledByUser =>
      'El usuario ha desactivado este motor en Ajustes';

  @override
  String get engineReasonGenericNotInstalled =>
      'Modelo no instalado; no participó en esta votación';

  @override
  String patternGenericTransition(String word) {
    return 'conector genérico \"$word\"';
  }

  @override
  String get helpAppBarTitle => 'Guía del usuario';

  @override
  String get helpAboutTitle => 'Acerca de TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens es una aplicación de detección de contenido multiplataforma (iOS / Android / macOS / Windows) cuya inferencia de IA principal se ejecuta completamente en el dispositivo. Cuatro submodelos independientes —el clasificador neuronal Transformer, el análisis estadístico, el análisis estilométrico y la detección de paráfrasis adversarial— votan juntos para determinar si el texto fue generado por IA, con razones explicables oración por oración: no solo un porcentaje de \"parece IA\", sino una explicación del \"por qué\".';

  @override
  String get helpComparisonTitle => 'Comparación con herramientas líderes';

  @override
  String get helpComparisonDisclaimer =>
      'Esta comparación se elaboró a partir de información pública de cada herramienta y percepciones generales del mercado, solo como referencia de posicionamiento funcional, no datos de referencia verificados por terceros.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'El procesamiento de GPTZero se realiza principalmente en la nube y requiere subir tu documento; los cuatro motores de detección de TruthLens se ejecutan en el dispositivo.';

  @override
  String get helpVsGptZero2 =>
      'GPTZero fue pionero en las métricas de Perplexity/Burstiness y el resaltado de oraciones; TruthLens las combina y añade un clasificador Transformer, análisis estilométrico y defensa adversarial, formando una votación conjunta de cuatro modelos en lugar de una única métrica.';

  @override
  String get helpVsGptZero3 =>
      'GPTZero se basa en suscripción; TruthLens no requiere suscripción ni tiene límites de uso.';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin se vende solo a instituciones; los particulares no pueden comprarlo directamente. Cualquiera puede instalar y usar TruthLens.';

  @override
  String get helpVsTurnitin2 =>
      'El proceso de decisión de Turnitin es casi una caja negra; TruthLens proporciona la probabilidad de IA de cada oración, patrones de escritura coincidentes y el desglose de puntuación y razones de cada motor.';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin ofrece principalmente un resultado binario de \"si es IA\"; TruthLens admite el etiquetado de humano/IA/mixto a nivel de párrafo/oración.';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai es una suscripción por documento que requiere subir tu documento a la nube; el procesamiento principal de TruthLens se ejecuta en el dispositivo, sin necesidad de suscripción continua para la detección.';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai ofrece conceptos de verificación de hechos y análisis de legibilidad; TruthLens responde a esto con un módulo de características de estilo en el dispositivo, y puede realizar análisis básicos incluso sin conexión.';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks es principalmente una API en la nube conocida por su baja tasa de falsos positivos y sólido soporte multilingüe; TruthLens comparte esta filosofía con un modelo base multilingüe XLM-RoBERTa y votación conjunta de varios modelos, pero el contenido de tu documento nunca se sube a ningún servidor.';

  @override
  String get helpVsCopyleaks2 =>
      'Copyleaks tiene límites de uso de API según el plan; TruthLens no tiene límites de uso.';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'El reconocimiento de imágenes OCR de Winston AI requiere subir imágenes a la nube; TruthLens usa los marcos nativos de cada plataforma (Vision en iOS/macOS, ML Kit en Android, Windows.Media.Ocr en Windows) para reconocer texto en el dispositivo.';

  @override
  String get helpVsWinston2 =>
      'Winston AI es conocido por informes ordenados e imprimibles; TruthLens genera dinámicamente el diseño del informe mediante IA (recurriendo a plantillas si no hay LLM instalado), exportable como PDF/CSV/JSON/PNG.';

  @override
  String get helpAdvantagesTitle => 'Ventajas exclusivas de TruthLens';

  @override
  String get helpAdvantage1 =>
      'Verificación de autenticidad de hipervínculos: comprueba automáticamente si las URL encontradas en el documento son realmente accesibles; los enlaces académicos con formato DOI se verifican además contra el registro público de Crossref para confirmar que la revista realmente indexa la obra.';

  @override
  String get helpAdvantage2 =>
      'Verificación de autenticidad de citas: incluso las referencias sin ningún hipervínculo (el estilo común \"autor-año\") pueden comprobarse contra registros bibliográficos para detectar citas posiblemente inventadas; una señal común de alucinación de IA.';

  @override
  String get helpAdvantage3 =>
      'Corrección de sesgo ESL (no nativo): detecta automáticamente características de escritura de no nativos y reduce el peso del modelo estadístico, evitando clasificar erróneamente la escritura natural de no nativos como IA.';

  @override
  String get helpAdvantage4 =>
      'Importación de modelos personalizados: los usuarios avanzados pueden importar sus propios modelos ONNX locales para reemplazar o complementar los motores de detección integrados.';

  @override
  String get helpWorkflowTitle => 'Flujo de trabajo operativo completo';

  @override
  String get helpWorkflowStep1Title => 'Descargar y actualizar modelos';

  @override
  String get helpWorkflowStep1Body =>
      'El primer inicio te guía para instalar el modelo de detección principal; después, siempre puedes revisar, descargar, actualizar o eliminar modelos desde \"Ajustes → Gestión de modelos de IA\". La aplicación comprueba proactivamente las últimas versiones al iniciarse, y muestra una insignia en el icono de ajustes y en la entrada de \"Gestión de modelos de IA\" si hay una actualización disponible.';

  @override
  String get helpWorkflowStep2Title => 'Elegir modelos (propósito e impacto)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Clasificador de IA multilingüe (peso 40%): el principal impulsor del veredicto general, con predicción de probabilidad de IA a nivel de oración; mejora la precisión más que cualquier otro.';

  @override
  String get helpWorkflowStep2Bullet2 =>
      'Motor de análisis estadístico (peso 25%): análisis de ventana deslizante de perplejidad y burstiness, capturando el ritmo regular y la elección de palabras predecible del texto de IA.';

  @override
  String get helpWorkflowStep2Bullet3 =>
      'Análisis estilométrico (peso 20%): fluidez semántica, patrones de oraciones repetitivos, uso de conectores; el más explicable, el más fácil de entender el \"por qué\".';

  @override
  String get helpWorkflowStep2Bullet4 =>
      'Defensa adversarial (peso 15%): detecta texto que ha sido \"limpiado\" mediante herramientas de paráfrasis (p. ej. QuillBot, Undetectable.ai).';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'LLM de redacción de informes (opcional): una vez instalado, el texto del informe se redacta dinámicamente mediante un LLM en el dispositivo; sin él, la aplicación recurre a una plantilla fija; el análisis en sí no se ve afectado.';

  @override
  String get helpWorkflowStep2Bullet6 =>
      'Puedes activar/desactivar motores individualmente y ajustar el umbral de confianza de detección de IA en Ajustes (aumentarlo reduce la probabilidad de clasificar erróneamente la escritura humana como IA).';

  @override
  String get helpWorkflowStep3Title => 'Subir un documento';

  @override
  String get helpWorkflowStep3Body =>
      'Tres métodos de entrada: pegar texto directamente, OCR de imagen (reconocido en el dispositivo con marcos nativos de cada plataforma), o importar archivo (txt / md / pdf / docx / doc). El texto debe tener al menos 40 caracteres para enviarse al análisis.';

  @override
  String get helpWorkflowStep4Title => 'Ejecutar el análisis';

  @override
  String get helpWorkflowStep4Body =>
      'Toca \"Iniciar detección\" y los cuatro motores se ejecutan en paralelo, mostrando el progreso en vivo en pantalla. Si se detectan características de escritura de no nativo, se aplica automáticamente la corrección de sesgo ESL (se puede desactivar en Ajustes).';

  @override
  String get helpWorkflowStep5Title => 'Ver y exportar resultados';

  @override
  String get helpWorkflowStep5Body =>
      'La página del informe incluye: el indicador general de probabilidad de IA, el mapa de calor a nivel de oración, el desglose de puntuación y razones de cada motor, la autenticidad de hipervínculos y la autenticidad de citas. Puedes exportar el informe completo en PDF, datos por oración en CSV, JSON (para integración de sistemas) o una tarjeta resumen en PNG (para compartir). Cada análisis se guarda automáticamente en \"Historial\" para su revisión posterior.';

  @override
  String get helpTuningTitle =>
      'Guía de descarga y ajuste de modelos (sin experiencia necesaria)';

  @override
  String get helpTuningStep1Title => 'Abrir la gestión de modelos';

  @override
  String get helpTuningStep1Body =>
      'Desde la pantalla principal, toca el icono de engranaje para abrir \"Ajustes\", luego toca \"Abrir\" junto a \"Gestión de modelos de IA\".';

  @override
  String get helpTuningStep2Title => 'Elige un modelo para tu dispositivo';

  @override
  String get helpTuningStep2Body =>
      'La pantalla sugiere automáticamente el nivel de modelo adecuado según las capacidades de tu dispositivo (RAM, núcleos de CPU), y enumera cada variante disponible para cada función (clasificador multilingüe / análisis estadístico / defensa adversarial / LLM de informes).';

  @override
  String get helpTuningStep3Title => 'Descargar y usar';

  @override
  String get helpTuningStep3Body =>
      'Toca \"Descargar\" junto al modelo que quieras y espera a que termine; el primer modelo que descargues se establecerá automáticamente como activo. Si tienes varias variantes instaladas, toca \"Establecer como activo\" para cambiar en cualquier momento; toca el icono de papelera para eliminar modelos innecesarios y liberar espacio.';

  @override
  String get helpTuningStep4Title => 'Actualizar modelos';

  @override
  String get helpTuningStep4Body =>
      'Cuando haya una nueva versión disponible, \"Gestión de modelos de IA\" y el icono de engranaje de ajustes mostrarán una insignia; vuelve a esta pantalla para ver y descargar la actualización (las versiones instaladas anteriormente se conservan a menos que las elimines manualmente).';

  @override
  String get helpTuningStep5Title =>
      'Avanzado: importar modelos personalizados';

  @override
  String get helpTuningStep5Body =>
      'Si ya tienes, o has ajustado, un modelo .onnx compatible en otro lugar, puedes importarlo mediante \"Ajustes → Importar y probar modelo ONNX personalizado\"; deberás proporcionar el archivo del modelo, la configuración del tokenizador correspondiente (o elegir \"ninguno\"), y el índice de la clase de IA. Antes de importar, la aplicación comprueba automáticamente si este mismo archivo ya se importó, para evitar duplicados accidentales.';

  @override
  String get helpOfficialLinksTitle =>
      'Enlaces oficiales de descarga de modelos';

  @override
  String get helpOfficialLinksHint =>
      'Al tocar un elemento se abrirá la página oficial de ese modelo en tu navegador del sistema.';

  @override
  String get helpLinkRoleTransformer =>
      'Clasificador de IA multilingüe (Transformer, peso 40%)';

  @override
  String get helpLinkRoleStatistical =>
      'Modelo estadístico de perplejidad (Statistical, peso 25%)';

  @override
  String get helpLinkRoleAdversarial =>
      'Modelo de detección de paráfrasis adversarial (Adversarial, peso 15%)';

  @override
  String get helpLinkRoleLlm => 'LLM de redacción de informes (opcional)';

  @override
  String get privacyAppBarTitle => 'Política de privacidad';

  @override
  String privacyPlatformTitle(String platform) {
    return 'Política de privacidad de $platform';
  }

  @override
  String privacyLastUpdated(String date) {
    return 'Última actualización: $date';
  }

  @override
  String get privacyIosOverview1 =>
      'TruthLens no recopila ningún dato asociado a tu identidad, ni utiliza ningún dato para seguimiento, por lo que no requiere permiso de Transparencia de Seguimiento de Aplicaciones (ATT).';

  @override
  String get privacyIosOverview2 =>
      'Esta aplicación utiliza el selector de archivos del sistema para acceder a archivos o imágenes que selecciones activamente; no puede acceder a archivos que no hayas seleccionado (aplicado por el sandbox de aplicaciones de iOS).';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLens no recopila datos personales ni comparte datos de usuario con terceros.';

  @override
  String get privacyAndroidOverview2 =>
      'Esta aplicación solo accede al almacenamiento cuando eliges activamente importar un archivo o imagen; no explora ni accede a otros archivos en segundo plano.';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens se ejecuta bajo el sandbox de aplicaciones de macOS y solo puede acceder a los archivos que selecciones activamente mediante el diálogo de archivos del sistema (files.user-selected.read-write); no puede explorar ni acceder a ningún otro archivo o carpeta por sí misma.';

  @override
  String get privacyMacosOverview2 =>
      'El acceso a la red (network.client) se usa solo para las funciones enumeradas en \"Comportamiento de conexión requerido\" a continuación.';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens es una aplicación de escritorio independiente; los datos se almacenan en tu carpeta de usuario local (p. ej. AppData/Documents) y nunca se sincronizan con la nube.';

  @override
  String get privacyWindowsOverview2 =>
      'Esta aplicación solo accede a los archivos que selecciones activamente para importar; no explora otros archivos en segundo plano.';

  @override
  String get privacyDataHandling1 =>
      'TruthLens no tiene cuentas de usuario, no requiere inicio de sesión y no contiene ningún SDK de publicidad o seguimiento de terceros en ninguna forma.';

  @override
  String get privacyDataHandling2 =>
      'Cualquier contenido de documento que escribas, pegues o importes se analiza completamente mediante modelos de IA en tu propio dispositivo; nunca se sube a TruthLens ni a ningún servidor de terceros.';

  @override
  String get privacyDataHandling3 =>
      'Los resultados de análisis y el historial se almacenan solo en una base de datos local en tu dispositivo; desinstalar la aplicación o borrar el historial los elimina por completo; TruthLens no conserva ninguna copia en ningún lugar.';

  @override
  String get privacyNetworkIntro =>
      'La detección de IA principal de esta aplicación se ejecuta completamente en el dispositivo, pero las siguientes tres funciones requieren acceso a la red:';

  @override
  String get privacyNetwork1 =>
      '1. Catálogo y descarga de modelos: se conecta a GitHub Releases/Hugging Face para descargar el modelo de detección que elijas; esto solo descarga el modelo y nunca sube ningún dato de usuario.';

  @override
  String get privacyNetwork2 =>
      '2. Comprobación de actualizaciones de modelos: al iniciarse, la aplicación se conecta solo para comparar números de versión, usados para mostrar si hay una nueva versión disponible.';

  @override
  String get privacyNetwork3 =>
      '3. Verificación de autenticidad de hipervínculos y citas: activada por defecto, se puede desactivar en Ajustes. Cuando está activada, la URL o el texto bibliográfico detectados en el documento se envían directamente a esa URL, o a la API pública de Crossref, enviando solo el texto de la URL/DOI/cita en sí; nunca el resto del contenido del documento.';

  @override
  String get privacyRightsIntro =>
      'Puedes borrar tu historial de análisis local en cualquier momento en \"Historial\", o desactivar la verificación de hipervínculos/citas en \"Ajustes\", o eliminar todos los datos locales';

  @override
  String get privacyRemoveIos => 'eliminando la aplicación';

  @override
  String get privacyRemoveAndroid => 'desinstalando la aplicación';

  @override
  String get privacyRemoveMacos => 'moviendo la aplicación a la Papelera';

  @override
  String get privacyRemoveWindows => 'desinstalando la aplicación';

  @override
  String get privacyDisclaimer =>
      'Esta página es una explicación de privacidad escrita por TruthLens para reflejar el comportamiento funcional real, no un documento legal formal revisado por un abogado; para una revisión formal de cumplimiento bajo las leyes de tu región, consulta a un abogado independiente.';

  @override
  String get privacySectionOverviewIos =>
      'Resumen (equivalente a las \"Etiquetas de Privacidad\" de App Store)';

  @override
  String get privacySectionOverviewAndroid =>
      'Resumen (equivalente a la divulgación de \"Seguridad de los Datos\" de Google Play)';

  @override
  String get privacySectionOverviewMacos =>
      'Resumen (permisos del sandbox de aplicaciones)';

  @override
  String get privacySectionOverviewWindows => 'Resumen';

  @override
  String get privacySectionDataHandling => 'Cómo manejamos tus datos';

  @override
  String get privacySectionNetwork => 'Conexiones de red requeridas';

  @override
  String get privacySectionRights => 'Tus derechos';

  @override
  String get privacyGenericPlatformName => 'Esta plataforma';
}
