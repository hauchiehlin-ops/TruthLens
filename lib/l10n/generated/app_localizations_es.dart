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
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

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
  String inputPdfOcrProgress(int page, int total) {
    return 'La capa de texto del PDF no está disponible; reconociendo la página $page de $total con OCR…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return 'Se importó «$fileName» con OCR de PDF ($count caracteres)';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '«$fileName» no tiene una capa de texto fiable. Configure Web OCR o utilice una aplicación instalada con OCR nativo y vuelva a importarlo.';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '«$fileName» necesita OCR, pero supera el límite de seguridad de $max páginas. Divida el PDF e impórtelo por partes.';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return 'No se pudo leer «$fileName» de forma fiable. Puede estar dañado, protegido con contraseña o no ser compatible con el servicio de OCR configurado.';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '«$fileName» es un archivo .doc antiguo y su texto no se pudo extraer de forma fiable. Guárdelo como .docx en Word o expórtelo a PDF y vuelva a importarlo.';
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
  String analysisPreliminaryResult(int percent) {
    return 'Resultado preliminar: probabilidad de IA $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return 'Resultado preliminar: probabilidad de IA $percent% (refinando…)';
  }

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
  String get modelCatalogLoadFailed =>
      'No se pudo cargar el catálogo de modelos';

  @override
  String get modelCatalogEmpty => 'No hay modelos disponibles';

  @override
  String modelDownloadPathChip(String label) {
    return 'Ruta de descarga de $label';
  }

  @override
  String get modelDownloadPathModelFile => 'Archivo del modelo';

  @override
  String get modelDownloadPathCopied => 'Ruta de descarga copiada';

  @override
  String settingsSaveFailed(String error) {
    return 'No se pudo guardar la configuración: $error';
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
  String get settingsEngineWeightsTitle => 'Pesos de los modelos de IA';

  @override
  String get settingsEngineWeightsSubtitle =>
      'Define cuánto influye cada motor en el resultado combinado. El total debe ser 100 % antes de guardar.';

  @override
  String get settingsEngineInfoTooltip => 'Función de este motor';

  @override
  String get settingsEngineTransformerHelp =>
      'Evalúa bloques de párrafos que conservan el contexto con un Transformer multilingüe y asigna las puntuaciones a las oraciones para el informe detallado. El peso configura su influencia y la señal de IA determina su contribución real.';

  @override
  String get settingsEngineStatisticalHelp =>
      'Mide perplejidad, previsibilidad, variación y longitud de oraciones. La corrección ESL puede reducir su peso efectivo.';

  @override
  String get settingsEngineStylometryHelp =>
      'Busca rasgos explicables como inicios repetidos, transiciones formularias y exceso de listas. Sin coincidencias, la señal es 0 %.';

  @override
  String get settingsEngineAdversarialHelp =>
      'Busca texto de IA parafraseado o procesado para ocultar rastros. Una puntuación baja es evidencia residual débil, no una detección positiva.';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return 'Total: $total % — listo para guardar';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return 'Total: $total % — ajústalo exactamente a 100 %';
  }

  @override
  String get settingsEngineWeightsSave => 'Guardar pesos';

  @override
  String get settingsEngineWeightsSaved =>
      'Pesos guardados en este dispositivo';

  @override
  String get settingsEngineWeightsRestoreDefaults => 'Restaurar valores';

  @override
  String get engineReasonDisabledByUser =>
      'El usuario ha desactivado este motor en Ajustes';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model: ninguna de $total oraciones superó el umbral fuerte de IA; la señal débil calibrada es $percent %';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'Señal de IA $percent %';
  }

  @override
  String get reportEngineSignalExplanation =>
      'La señal de IA es la probabilidad asignada por el motor a este documento. El peso configurado controla su influencia y los puntos de contribución se distribuyen para que la suma mostrada coincida exactamente con la probabilidad global de IA. «No detectado» significa que está por debajo del umbral de señal fuerte del 60 %, no que el valor sea necesariamente cero.';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return 'Ninguna de las $total oraciones superó el umbral fuerte de paráfrasis; la señal débil calibrada es del $percent %';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$count de $total oraciones superaron el umbral fuerte de paráfrasis; la señal calibrada del documento es del $percent %';
  }

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
  String get modelImportWebUnsupported =>
      'La importación de modelos personalizados aún no es compatible con la versión web. Utilice la versión de la aplicación.';

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
  String get reportEngineWeightLabel => 'Ponderación';

  @override
  String get privacySealNoticeText =>
      'Sello de privacidad 100% offline TruthLens: Procesado en el dispositivo sin almacenamiento en la nube.';

  @override
  String get reportModelCalibrationTitle =>
      'Autocalibración de referencia de modelos';

  @override
  String get reportCommunityDiscoveredTag => 'Comunidad (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => 'Desglose por motores';

  @override
  String get reportEngineNotInstalled => 'No instalado';

  @override
  String get reportEngineLoadFailedBadge => 'Error de carga';

  @override
  String get reportEngineAnalysisLevelTitle => 'Capas de análisis de motores';

  @override
  String get reportVerdictAiLikelihood => 'Tendencia a IA';

  @override
  String get reportVerdictHumanLikelihood => 'Escritura humana';

  @override
  String get reportRadarRoleTransformer => 'Clasificador Transformer';

  @override
  String get reportRadarRoleStatistical => 'Análisis estadístico';

  @override
  String get reportRadarRoleStylometry => 'Análisis de estilometría';

  @override
  String get reportRadarRoleAdversarial => 'Defensa adversarial';

  @override
  String get reportRadarAxisTransformer => 'Clasificador de oraciones';

  @override
  String get reportRadarAxisStatistical => 'Regularidad del lenguaje';

  @override
  String get reportRadarAxisStylometry => 'Estilo de escritura';

  @override
  String get reportRadarAxisAdversarial => 'Defensa de reescritura';

  @override
  String get reportVerdictBadgeTitle => 'Veredicto general';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return 'Probabilidad de IA global $percent%';
  }

  @override
  String get reportVerdictHintHuman =>
      'La mayoría de las señales de los motores apuntan a una escritura humana natural.';

  @override
  String get reportVerdictHintLikelyHuman =>
      'En general tiende a humano, con una pequeña incertidumbre del modelo restante.';

  @override
  String get reportVerdictHintMixed =>
      'Las señales de los motores son mixtas; lea el análisis detallado junto con este resultado.';

  @override
  String get reportVerdictHintLikelyAi =>
      'Varios indicadores apuntan a IA; revise los pasajes con puntuación alta.';

  @override
  String get reportVerdictHintAi =>
      'Las señales generales apuntan fuertemente a contenido generado o reescrito por IA.';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return 'Veredicto general: $verdict; probabilidad de IA global $percent%.';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return 'Señal individual más fuerte: $label ($percent%), pero el resultado final combina los pesos de los motores y no es la conclusión de un solo motor.';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return 'La mayor contribución ponderada actualmente proviene de $label (aproximadamente $points puntos porcentuales).';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '«No se detectó un estilo de escritura de IA evidente» solo significa que el motor de estilo no encontró patrones fijos de oraciones o palabras de transición; otros modelos aún pueden aumentar la puntuación global mediante la regularidad del lenguaje, la clasificación de oraciones o señales de reescritura.';

  @override
  String get reportSynthesisModelGap =>
      'Cuando algunos motores no participaron, use primero «Completar modelos de análisis recomendados» en Gestión de modelos; si sigue fallando, el análisis detallado indicará si la causa es un modelo faltante, un tokenizador no compatible, un archivo faltante o un límite de compatibilidad de Web/ONNX Runtime.';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label no participó en esta votación ponderada, por lo que esta dimensión se muestra como 0%. $hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return 'Peso del rol $weight%, contribuye aproximadamente $points puntos porcentuales a la puntuación global$variantText.';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return ' (se combinaron $count variantes de modelo)';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label no participó en esta votación.';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label no devolvió ninguna explicación de texto adicional.';
  }

  @override
  String get reportEngineResolutionTransformer =>
      'Solución: descargue y active el Transformer multilingüe en Gestión de modelos; si ya está descargado, vuelva a descargar el modelo y el tokenizador.';

  @override
  String get reportEngineResolutionAdversarial =>
      'Solución: vuelva a descargar el modelo de detección de reescritura y el tokenizador en Gestión de modelos; en la web, actualice a una versión con la corrección de compatibilidad de BigInt y analice de nuevo.';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason. Causa: el ONNX Runtime web devolvió un tensor BigInt que el puente anterior no pudo convertir; actualice a la versión corregida y analice de nuevo.';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason. Solución: cambie a un modelo del catálogo o vuelva a descargar el modelo y el tokenizador.';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason. Solución: abra Gestión de modelos, toque «Completar modelos de análisis recomendados» y confirme que el Transformer multilingüe está marcado como activo.';
  }

  @override
  String get reportDetailAnalysisTitle => 'Análisis detallado';

  @override
  String get reportNoEngineData => 'Aún no hay datos de análisis de motores';

  @override
  String get reportEngineNotParticipated => 'No participó';

  @override
  String get reportAiContentReportTitle =>
      'Informe de detección de contenido de IA';

  @override
  String reportAnalysisTimeLabel(String time) {
    return 'Tiempo de análisis: $time';
  }

  @override
  String get reportDownloadPdfButton => 'Descargar PDF';

  @override
  String get reportSuspiciousLocationsTitle =>
      'Ubicaciones de contenido sospechoso';

  @override
  String reportSentenceCount(int count) {
    return '$count oraciones';
  }

  @override
  String get reportAiProbabilityPrefix => 'Probabilidad de IA: ';

  @override
  String get helpAdvantage5 =>
      'Análisis forense del origen: lee el registro de edición dentro de archivos .docx / .odt / .doc —tiempo dedicado, número de guardados, dispersión de las tandas de edición—. Esa prueba es independiente del veredicto sobre el texto y se muestra aparte de la probabilidad de IA. Los PDF y las imágenes no llevan historial de edición propio, así que no pueden aportarla.';

  @override
  String get helpAdvantage6 =>
      'Se abstiene con honestidad cuando la evidencia es escasa: menos de 5 frases analizables, menos de 100 palabras, menos de 2 motores participando, o motores separados por más de 60 puntos porcentuales dan «no hay evidencia suficiente para juzgar». La mayoría de las acusaciones falsas empiezan con un número seguro devuelto sobre una entrada demasiado débil.';

  @override
  String get settingsAiSampleTitle => 'Añadir una muestra de IA';

  @override
  String get settingsAiSampleSubtitle =>
      'La calibración en segundo plano solo recoge muestras humanas por sí sola. Para activar los pesos aprendidos también hacen falta textos que sepas generados por IA: pega o importa uno y se analizará y etiquetará como muestra de IA al momento.';

  @override
  String get settingsAiSampleFromClipboard => 'Pegar del portapapeles';

  @override
  String get settingsAiSampleFromFile => 'Importar un documento';

  @override
  String get settingsAiSampleAnalyzing => 'Analizando…';

  @override
  String settingsAiSampleAdded(int count) {
    return 'Muestra de IA añadida: $count en total';
  }

  @override
  String get settingsAiSampleTooShort =>
      'Demasiado corto para servir de muestra (hacen falta al menos 100 palabras)';

  @override
  String get settingsAiSampleFailed => 'No se encontró contenido utilizable';

  @override
  String get helpFormatCoverageTitle =>
      '2a. Límites de formato en las pruebas de origen';

  @override
  String get helpFormatCoverage =>
      '**Un límite importante: solo .docx y .odt llevan registro de edición.**\n\n| Origen | Registro de edición |\n|---|---|\n| .docx / .odt | ✅ sí |\n| .pdf | ❌ el formato no guarda historial alguno |\n| .doc (antiguo) | ✅ sí (OLE2 SummaryInformation) |\n| .txt / .md | ❌ sin contenedor |\n| OCR de imagen | ❌ solo quedan píxeles |\n| Texto pegado | ❌ no hay archivo |\n\nEsto afecta directamente al pilar 3: **solo los documentos con registro de edición entran automáticamente en la base con garantía estadística.** Si todo lo que recibes son PDF, esa base nunca crecerá: solo acumularás muestras de referencia sin garantía.\n\nPara que las pruebas de origen y la calibración automática funcionen de verdad, recoge originales .docx, .odt o .doc en lugar de PDF impresos o exportados. Es un requisito del flujo de trabajo, no un límite que el software pueda sortear: el PDF es un formato de salida y sencillamente no registra cómo se escribió el texto.';

  @override
  String provenanceUnsupportedFormat(String format) {
    return 'El formato $format no lleva historial de edición en absoluto, así que no es que se haya borrado el registro: nunca lo hubo. Solo .docx y .odt registran tiempo de edición, número de guardados y tandas de edición.';
  }

  @override
  String get provenanceStripped =>
      'Es un formato compatible, pero no se encontró registro de edición en el archivo. Eso suele significar que se guardó como archivo nuevo, se convirtió en línea o se exportó desde Google Docs: cualquiera de esas acciones lo reinicia.';

  @override
  String get provenanceHowToGetRecord =>
      'Para que las pruebas de origen sirvan, consigue el **archivo original .docx, .odt o .doc**, no un PDF impreso o exportado. Solo el original conserva el historial de edición, y solo él puede sumarse automáticamente a la base con garantía estadística.';

  @override
  String get calibrationAutoTitle => 'Recopilando en segundo plano';

  @override
  String get calibrationAutoSubtitle =>
      'Los documentos que analizas se añaden solos a la base: no hace falta etiquetar a mano.';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return 'Confirmados como humanos por el registro de edición: $auto; muestras solo de referencia: $observed';
  }

  @override
  String get calibrationAutoWhy =>
      'A la base con garantía estadística solo entran los documentos con registro de edición (tiempo dedicado, número de guardados, dispersión de las tandas), porque esa prueba es **independiente del veredicto sobre el texto**. Etiquetar según el propio veredicto de la herramienta sería corregirse a sí misma: lo que marcara por error nunca entraría en la base, el umbral se estrecharía en cada pasada y acabaría marcando más escritura auténtica. El texto pegado no lleva registro de edición, así que solo cuenta para el percentil de referencia de abajo.';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return 'Como referencia: esta puntuación cae en el percentil $percentile de los $count documentos que has analizado (sin garantía estadística)';
  }

  @override
  String get settingsAutoCollectTitle =>
      'Recopilar muestras de calibración en segundo plano';

  @override
  String get settingsAutoCollectSubtitle =>
      'Añade automáticamente los documentos analizados a la base. Las etiquetas salen del registro de edición, nunca del veredicto de esta herramienta.';

  @override
  String get settingsStoreTextTitle =>
      'Conservar el texto para validación sin conexión';

  @override
  String get settingsStoreTextSubtitle =>
      'Al activarlo, los textos que añadas a la base se guardan localmente con su contenido completo, para poder exportarlos luego como corpus y evaluarlos sin conexión.';

  @override
  String get settingsStoreTextWarning =>
      'Ese texto suele ser trabajo ajeno y por tanto es sensible. Actívalo solo mientras reúnes de verdad un corpus de validación, y usa «Borrar el texto guardado» en cuanto hayas exportado. Borrarlo no afecta a la predicción conforme: esta solo necesita las puntuaciones.';

  @override
  String get settingsExportCorpusTitle => 'Exportar el corpus de calibración';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return 'Listos para exportar: $human humanos, $ai de IA (hacen falta $required de cada uno)';
  }

  @override
  String get settingsExportCorpusButton => 'Exportar como JSONL';

  @override
  String get settingsExportCorpusEmpty =>
      'No hay nada que exportar: activa primero «conservar el texto» y ve acumulando la base';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return 'Se exportaron $count muestras; se omitieron $skipped sin texto guardado';
  }

  @override
  String get settingsClearStoredText => 'Borrar el texto guardado';

  @override
  String get settingsClearStoredTextDone =>
      'Se borró todo el texto guardado. Las puntuaciones y la calibración siguen intactas.';

  @override
  String get helpDesignTitle => 'Filosofía de diseño y límites conocidos';

  @override
  String get helpShiftTitle =>
      '1. El giro: no competimos por la exactitud de la puntuación';

  @override
  String get helpShiftBody =>
      'Casi todos los detectores del mercado responden a la misma pregunta: ¿este texto parece escrito por una IA?\n\nEsa es una carrera armamentística que se pierde. Cuanto más potente es el modelo, más se acerca su salida a la escritura humana en términos estadísticos, y las herramientas de reescritura mejoran mucho más rápido que los detectores. Por ese camino, un gran modelo en servidor solo pierde más despacio.\n\nTruthLens plantea otra pregunta: ¿qué pruebas tenemos realmente sobre cómo llegó a existir este documento, y qué peso tiene cada una?\n\nEs pasar de adivinar el estilo a sopesar pruebas de origen junto a conclusiones estadísticamente honestas. Por eso esta herramienta no persigue un puesto en los rankings de exactitud de puntuación única, sino que expone cada prueba por separado y dice claramente cuándo no lo sabe. La verdadera ventaja de ejecutarse en tu navegador no es la velocidad, sino ver lo que un servidor nunca llega a ver: el archivo completo y la base que tú mismo has reunido.';

  @override
  String get helpPillarsTitle => '2. Los cinco pilares';

  @override
  String get helpPillarsBody =>
      '1. Análisis forense del origen del documento (en marcha)\nLee el registro de edición dentro de los contenedores DOCX y ODT: tiempo total de edición, número de guardados, fechas de creación y modificación, y las marcas de tanda de edición (RSID) del cuerpo. Uno o dos RSID en todo un trabajo suele significar que el texto entró de una vez; 3.000 palabras con cuatro minutos de edición es una prueba más dura que cualquier puntuación de perplejidad. Cuenta como prueba de origen y se muestra aparte de la probabilidad de IA: nunca se mezcla con la puntuación.\n\n2. Calibración con base local y predicción conforme (en marcha)\nAñade textos que sepas que escribieron sus autores y el sistema juzgará según la distribución de este grupo en lugar de un umbral global. La predicción conforme ofrece una garantía sin supuestos de distribución: si la base y la muestra analizada son intercambiables, la tasa de falsos positivos se mantiene por debajo del alfa que fijes. Es la clave para reducir errores con escritura no nativa, y algo que los productos comerciales no pueden hacer: no tienen trabajos de referencia de las personas que evalúas.\n\n3. Pesos de motor aprendidos (en marcha)\nCuando la base contiene muestras humanas y de IA, el sistema mide cuánto separa cada motor los dos grupos (tamaño del efecto, d de Cohen) y propone pesos acordes, sustituyendo las proporciones fijas puestas a mano. Nada cambia hasta que pulsas Aplicar: los ajustes nunca se modifican en silencio.\n\n4. Perplejidad cruzada Binoculars (núcleo de cálculo listo, aún no activo)\nLa perplejidad simple trata lo predecible que es un texto como si eso midiera cuánto se parece a la IA, y de ahí vienen precisamente sus falsos positivos sistemáticos con escritura no nativa de estilo llano. Binoculars mide esa previsibilidad en relación con cuánto discrepan dos modelos entre sí. Las matemáticas están implementadas y probadas, pero activarlo aún exige un par de modelos de lenguaje pequeños que funcionen en el navegador y una validación con datos etiquetados.\n\n5. Detección de marca de agua (comprobado, inviable, no construido)\nLa detección de SynthID-Text está ligada a claves: el detector debe calcular con las mismas claves usadas al generar, y las claves de producción de Google no son públicas. Hacerlo en el navegador nunca se activaría con salidas reales de ChatGPT, Claude o Gemini; sería una función que jamás se dispara mientras te hace creer que se comprueban marcas de agua. Por eso se dejó fuera deliberadamente.';

  @override
  String get helpCascadeTitle => '3. La cascada por niveles y la abstención';

  @override
  String get helpCascadeBody =>
      'Para mantener la velocidad dentro del presupuesto de cómputo de un navegador, el análisis se ejecuta por niveles: primero las señales baratas, las caras solo cuando hacen falta.\n\nNivel 0  Pruebas de origen del documento (coste casi nulo)\nNivel 1  Rasgos estadísticos y estilométricos (motores existentes, baratos)\nNivel 2  Clasificador Transformer por frase\nNivel 3  Perplejidad cruzada (el más caro, solo si el panorama sigue confuso)\n\nEl resultado pasa después a la calibración local, que produce una conclusión con garantía de falsos positivos, o una abstención explícita.\n\n[Por qué importa la abstención]\nLa mayoría de las acusaciones falsas nacen de devolver un número seguro sobre una entrada demasiado corta o demasiado débil para sostenerlo. Esta herramienta muestra directamente \"No hay evidencia suficiente para juzgar\", en lugar de forzar una puntuación, cuando:\n\n- hay menos de 5 frases analizables\n- hay menos de 100 palabras\n- participaron menos de 2 motores\n- los motores difieren en más de 60 puntos porcentuales (promediarlos ha dejado de significar algo)\n\nAl abstenerse, la puntuación completa y las pruebas por frase siguen abajo para tu consulta, pero no las tomes como conclusión. Un sistema dispuesto a decir \"no lo sé\" merece más confianza que uno que siempre te entrega un número.';

  @override
  String get helpRisksTitle =>
      '4. Riesgos que conviene afrontar con honestidad';

  @override
  String get helpRisksBody =>
      'Cada punto siguiente es una limitación real de esta herramienta. Tenlos en cuenta antes de actuar sobre lo que informe.\n\n1. Las pruebas de origen pueden borrarse o falsificarse\nGuardar como archivo nuevo, convertir en línea, exportar desde Google Docs o copiar a un documento nuevo reinician el registro de edición. Una señal aquí es solo prueba de apoyo, y su ausencia desde luego no demuestra que lo escribiera una persona.\n\n2. La garantía conforme se apoya en la intercambiabilidad\nSolo se cumple si las muestras base y el texto analizado provienen del mismo grupo de personas haciendo el mismo tipo de tarea. Si la escritura de alguien ha mejorado claramente, o el tipo de tarea ha cambiado por completo, la premisa falla y hay que rehacer la base.\n\n3. La propia base puede estar contaminada\nSi los trabajos usados como base los escribió en realidad una IA, toda la calibración se tuerce. Las muestras base deben recogerse en condiciones controladas, por ejemplo trabajos hechos bajo supervisión.\n\n4. Los modelos pequeños en el navegador son menos exactos que los grandes en servidor\nEs el precio inevitable que la decisión Web-only paga por la privacidad. El valor de esta herramienta no es una puntuación única más exacta, sino ser explicable, calibrable y lo bastante honesta como para abstenerse.\n\n5. Ninguna puntuación debe sostener por sí sola una acusación\nLéela siempre junto a las pruebas por frase, el origen del documento y lo que ya sabes de esa persona en concreto. Esta herramienta está pensada para apoyar una conversación que mantengas tú, no para dictar un veredicto en tu lugar.';

  @override
  String get calibrationAddHuman => 'Añadir como base escrita por humano';

  @override
  String get calibrationAddAi => 'Añadir como muestra de IA conocida';

  @override
  String calibrationCounts(int human, int ai) {
    return 'Base: $human humanas, $ai de IA';
  }

  @override
  String get learnedWeightsTitle => 'Pesos de motor aprendidos';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return 'Tienes $human muestras humanas y $ai de IA. Cada clase necesita al menos $required para aprender pesos fiables; hasta entonces siguen vigentes tus pesos manuales.';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return 'Ya se pueden aprender pesos a partir de tus $human muestras humanas y $ai de IA.';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine: peso sugerido $weight% (separación $effect)';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return 'Aviso: $engine tiene los dos grupos al revés — las muestras de IA puntuaron más bajo, no más alto — así que su peso cae a cero. Suele significar que ese motor no encaja con este tipo de texto.';
  }

  @override
  String get learnedWeightsApply => 'Aplicar los pesos aprendidos';

  @override
  String get learnedWeightsApplied => 'Pesos aprendidos aplicados';

  @override
  String get learnedWeightsExplain =>
      'Los pesos salen de lo bien que cada motor separa tus muestras humanas de las de IA (tamaño del efecto, d de Cohen): cuanto más lejos queden los dos grupos y más estable sea cada uno, más peso gana ese motor. Esto sustituye a los pesos fijos puestos a mano para que el conjunto encaje con el tipo de texto con el que trabajas.';

  @override
  String get calibrationTitle => 'Calibración con base local';

  @override
  String get calibrationEmpty =>
      'Todavía no hay conjunto base. Añade unos cuantos textos que sepas con certeza que escribieron sus autores — trabajos hechos bajo supervisión, por ejemplo — y el sistema podrá juzgar según la distribución de este grupo en lugar de un umbral global igual para todos. Eso es precisamente lo que reduce los falsos positivos en escritura no nativa.';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return 'El conjunto base tiene $count muestra(s); para que un techo de falsos positivos del $alpha% se cumpla de verdad hacen falta al menos $required. Hasta entonces las cifras son solo orientativas y no se marca nada con ellas.';
  }

  @override
  String calibrationFlagged(int alpha) {
    return 'Con un techo de falsos positivos del $alpha%, este texto **queda marcado**.';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return 'Con un techo de falsos positivos del $alpha%, este texto **no queda marcado**.';
  }

  @override
  String calibrationPValue(String value, int count) {
    return 'Valor p conservador $value (frente a $count muestras base)';
  }

  @override
  String calibrationPercentile(int percentile) {
    return 'La puntuación cae en el percentil $percentile del conjunto base';
  }

  @override
  String get calibrationCaveat =>
      'Esta garantía se apoya en que las muestras base y el texto analizado sean intercambiables: mismo grupo de personas, mismo tipo de tarea. Si la escritura de alguien ha mejorado claramente, o el tipo de tarea ha cambiado por completo, deja de cumplirse y hay que rehacer el conjunto base. Ojo además: si las piezas base las escribió una IA, toda la calibración se tuerce, así que recógelas en condiciones controladas.';

  @override
  String get calibrationAddButton => 'Añadir este texto a la base';

  @override
  String calibrationAdded(int count) {
    return 'Añadido al conjunto base: ahora $count muestra(s)';
  }

  @override
  String get settingsCalibrationTitle => 'Conjunto base local';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return '$count muestra(s) guardadas ($required necesarias con esta α)';
  }

  @override
  String get settingsCalibrationClear => 'Vaciar el conjunto base';

  @override
  String get settingsCalibrationCleared => 'Conjunto base vaciado';

  @override
  String get settingsAlphaTitle => 'Techo de falsos positivos (α)';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return 'Actualmente $alpha% — más bajo es más estricto, pero exige más muestras base (al menos $required)';
  }

  @override
  String get abstentionHeadline => 'No hay evidencia suficiente para juzgar';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return 'Solo $count frase(s) analizable(s), cuando hacen falta al menos $required. Con esta extensión las señales estadísticas y por frase no pesan nada, y forzar una puntuación solo despistaría.';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return 'El texto tiene $count palabras y hacen falta al menos $required. Por debajo de eso, cualquier rasgo de escritura puede ser casualidad.';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return 'Solo participaron $available de $total motores, así que no hay forma de contrastar desde otro ángulo. Completa los modelos que faltan en gestión de modelos y vuelve a ejecutarlo.';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return 'Los motores están a $spread puntos porcentuales de distancia, lo bastante como para que promediarlos deje de significar algo. Mira las pruebas por frase y el origen del documento, y juzga tú.';
  }

  @override
  String get abstentionScoreStillShown =>
      'Abajo se mantienen la puntuación completa y las pruebas por frase para tu referencia. No las tomes como conclusión.';

  @override
  String get provenanceTitle => 'Evidencia de origen del documento';

  @override
  String get provenanceRiskHigh =>
      'El historial de edición es claramente inusual';

  @override
  String get provenanceRiskMedium => 'Hay algo raro en el historial de edición';

  @override
  String get provenanceRiskLow => 'El historial de edición parece normal';

  @override
  String get provenanceRiskUnknown => 'No hay historial de edición disponible';

  @override
  String get provenanceNoMetadata =>
      'Esta entrada no trae historial de edición: texto pegado, un PDF o un archivo al que le borraron el registro. Aquí no hay nada que juzgar por el origen, solo el análisis del texto.';

  @override
  String provenanceEditingDuration(int minutes) {
    return 'Tiempo de edición registrado en el archivo: $minutes minutos';
  }

  @override
  String provenanceRevisionCount(int count) {
    return 'Veces guardado: $count';
  }

  @override
  String provenanceApplication(String name) {
    return 'Creado con: $name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return 'El cuerpo lleva solo $count marca(s) de tanda de edición para $words palabras. Escribir mientras se piensa suele dejar decenas; tanta concentración normalmente significa que el texto entró de una vez, por ejemplo pegado.';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words palabras frente a $minutes minutos de edición registrada dan $wpm palabras por minuto, muy por encima de lo que alguien sostiene escribiendo de verdad.';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return 'El archivo casi no registra tiempo de edición, pero el cuerpo llega a $words palabras.';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return '$words palabras de contenido, guardadas solo $count vez/veces.';
  }

  @override
  String get provenanceCaveat =>
      'Conviene saberlo: estos registros pueden borrarse o reiniciarse — guardar como archivo nuevo, convertir en línea, exportar desde Google Docs o copiar a un documento nuevo los dejan a cero. Una señal aquí es prueba de apoyo, nunca una conclusión por sí sola; y su ausencia no demuestra que lo escribiera una persona.';

  @override
  String get telemetrySummaryTitle => 'En resumen';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '$engines de $total motores han terminado. La probabilidad de IA global es del $percent%, lo que da “$verdict”.';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return 'Los motores coinciden bastante (el más alto marca $high% y el más bajo $low%), así que la conclusión se sostiene bien.';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return 'Los motores no coinciden: $highLabel marca $high% y $lowLabel apenas $low%. Cuando pasa esto, no te fes solo de la puntuación global; las pruebas frase a frase de abajo dicen mucho más.';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return 'Lo que más empuja la puntuación es $label, con unos $points puntos porcentuales.';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return 'De las $total frases revisadas, ninguna ha cruzado la línea de señal fuerte de IA.';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return 'De $total frases, $count han cruzado la línea de señal fuerte de IA; vale la pena leerlas una a una.';
  }

  @override
  String get telemetrySummaryAdviceHuman =>
      'Se lee como algo escrito por una persona, sin nada que merezca más investigación.';

  @override
  String get telemetrySummaryAdviceMixed =>
      'Este cae en zona gris. Concluir solo con la puntuación es arriesgado: míralo junto con las pruebas por frase y lo que sepas del origen del documento.';

  @override
  String get telemetrySummaryAdviceAi =>
      'Las señales apuntan claramente a texto generado o reescrito por IA. Revisa una a una las frases marcadas antes de decidir.';

  @override
  String telemetrySummaryModelGap(int count) {
    return 'Además, $count motor(es) no han participado esta vez, así que baja un poco la confianza; complétalos en gestión de modelos y vuelve a ejecutar para afinar.';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'Probabilidad de IA < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'Probabilidad de IA $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'Probabilidad de IA ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return 'Confianza baja: el peso de modelo disponible está por debajo del 60% (umbral $threshold%). $available/$total motores participaron. Revise el análisis detallado de los motores.';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return 'Confianza alta: $available/$total modelos de detección alcanzaron consenso ($threshold% o más del peso coincide con este veredicto).';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return 'Confianza baja ($available/$total)';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return 'Confianza alta ($available/$total)';
  }

  @override
  String get reportMetricAiSentenceRatio =>
      'Proporción de oraciones con señal fuerte de IA';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count de $total superaron el umbral de señal fuerte del 60 %';
  }

  @override
  String get reportMetricElapsed => 'Tiempo de análisis';

  @override
  String get reportMetricElapsedNormal => '0,5-5s normal';

  @override
  String get reportMetricReliability => 'Fiabilidad';

  @override
  String get reportReliabilityLow => 'Baja';

  @override
  String get reportReliabilityHigh => 'Alta';

  @override
  String get reportReliabilityNeedsReview => 'Requiere revisión';

  @override
  String get reportReliabilityHighTrust => 'Muy fiable';

  @override
  String get reportSentenceAnalysisTitle => 'Análisis a nivel de oración';

  @override
  String get suspiciousFilterAll => 'Sospechoso';

  @override
  String get suspiciousFilterHigh => 'Alto';

  @override
  String get suspiciousFilterMedium => 'Medio';

  @override
  String get suspiciousExcludedTooltip =>
      'Se han excluido letras individuales, números de página, números de sección y fragmentos de OCR/PDF demasiado cortos.';

  @override
  String suspiciousCount(int count) {
    return '$count elementos';
  }

  @override
  String get suspiciousEmpty => 'Sin contenido sospechoso';

  @override
  String get suspiciousRiskHigh => 'Alto';

  @override
  String get suspiciousRiskMedium => 'Medio';

  @override
  String get suspiciousReasonHighModelSignals =>
      'Múltiples señales de modelo se inclinan fuertemente hacia IA';

  @override
  String get suspiciousReasonSentenceSignal =>
      'La señal de modelo a nivel de oración está elevada';

  @override
  String suspiciousOriginalLocation(String location) {
    return 'Ubicación original $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return 'Ubicación original $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return 'Oración n.º $number';
  }

  @override
  String get suspiciousEvidenceLabel => 'Evidencia:';

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
  String get reportBibRecheckAllUnreliableButton =>
      'Volver a verificar todas las citas no verificadas';

  @override
  String get reportBibRecheckOneTooltip => 'Volver a verificar esta cita';

  @override
  String get reportBibResultHint =>
      'Comparado con el registro público de Crossref por similitud de autor, año y título. No es una garantía absoluta; cuando se indique \"incierto\", verifica manualmente.';

  @override
  String reportBibVerificationSource(String source) {
    return 'Fuente de verificación: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'Verificar manualmente en Google Scholar';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Alta confianza: probablemente existe$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (registrado con $journal)';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'Discrepancia en el nombre de la revista: el documento indica «$reported», mientras que el registro verificado indica «$registered». Revise esta cita.';
  }

  @override
  String get reportBibNotFound =>
      'No se encontró ninguna coincidencia cercana; posible referencia inventada';

  @override
  String get reportBibUncertain =>
      'Sospechoso: no verificado por coincidencia de registro';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Solo se verificaron las primeras $max entradas (se detectaron $count en total)';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return '$count completados; los resultados seguirán actualizándose.';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return 'Progreso $completed/$total, $current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return 'Actual: $text';
  }

  @override
  String get reportBibProgressFinalizing => 'Finalizando resultados';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base: se encontró un candidato similar «$candidate», pero el autor, año o título no alcanzaron el umbral de coincidencia fiable.';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base: las fuentes de verificación no devolvieron una respuesta fiable o la entrada carece de suficiente información; TruthLens no considera esta cita como verificada.';
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
    return 'La probabilidad general de IA supera el umbral fijo del $percent% y se marcó como IA.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'La probabilidad general de IA está por debajo del umbral de marcado fijo del $percent%.';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return 'La probabilidad de IA global es $aiPercent%, lo que alcanza el umbral fijo de marcado de IA del $thresholdPercent%, por lo que el informe marca este texto como IA. Revise la evidencia a nivel de oración y las razones de los motores antes de tomar una decisión final.';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'La probabilidad de IA global es $aiPercent%, por debajo de el umbral fijo de marcado de IA del $thresholdPercent%, por lo que el informe no marca formalmente este texto como IA. La probabilidad y la evidencia se muestran igualmente para su revisión.';
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
  String engineReasonStatisticalSummaryAi(String percent) {
    return 'Resumen estadístico general: tiende a características generadas por IA (probabilidad de IA $percent%)';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return 'Resumen estadístico general: tiende a una escritura humana natural (probabilidad de IA $percent%)';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return 'Resumen estadístico general: los indicadores se equilibran, mostrando características neutrales (probabilidad de IA $percent%)';
  }

  @override
  String get reportFormulaTitle =>
      'Transparencia del cálculo ponderado y desglose de parámetros';

  @override
  String get reportFormulaExplanation =>
      'La probabilidad de IA global se calcula como un promedio ponderado de las probabilidades de todos los motores activos:';

  @override
  String get reportFormulaActiveEngines => 'Motores activos y pesos asignados';

  @override
  String get reportFormulaCalculation => 'Cálculo de la fórmula ponderada';

  @override
  String get reportFormulaFinalResult => 'Probabilidad de IA ponderada final';

  @override
  String get reportFormulaEslApplied =>
      'Se aplicó el ajuste para escritura no nativa ESL (peso del modelo estadístico reducido a la mitad)';

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
  String get modelRepairNoActiveVariant =>
      'No se encontró ningún modelo activo; descargue un modelo recomendado en Gestión de modelos.';

  @override
  String get modelRepairCustomRemoved =>
      'Se eliminó el modelo personalizado que no se pudo cargar. Los modelos personalizados no se pueden volver a descargar automáticamente; vuelva a importar el modelo y el tokenizador.';

  @override
  String get modelRepairNoSource =>
      'Se eliminó el archivo del modelo que no se pudo cargar, pero actualmente no hay ninguna fuente de catálogo disponible para volver a descargarlo; vuelva a descargar un modelo recomendado en Gestión de modelos.';

  @override
  String modelRepairRedownloaded(Object name) {
    return 'Se detectó que el archivo del modelo podría estar dañado o ser incompatible; se volvió a descargar $name automáticamente. Vuelva a ejecutar el análisis.';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return 'Se eliminó el archivo del modelo que no se pudo cargar, pero la descarga automática no se completó; compruebe su conexión de red y vuelva a descargar $name en Gestión de modelos.';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      'No se encontró ningún modelo Transformer activo; descárguelo o actívelo en Gestión de modelos';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return 'El tipo de tokenizador del modelo activo no es compatible ($tokenizer); cambie a un modelo compatible con bert-wordpiece o roberta-bpe';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Falta la ruta del modelo Transformer o del tokenizador; vuelva a descargarlo en Gestión de modelos';

  @override
  String get engineTransformerMissingFiles =>
      'El archivo del modelo Transformer o del tokenizador no existe; vuelva a descargarlo en Gestión de modelos';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'Versión de opset de ONNX no compatible (esta versión del modelo es demasiado reciente; actualice la aplicación): $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Formato del tokenizador dañado: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      'No se pudo cargar o ejecutar el modelo, y la reparación automática no se completó; vuelva a descargar el modelo Transformer activo y el tokenizador en Gestión de modelos.';

  @override
  String get engineAdversarialNoActiveVariant =>
      'No se encontró ningún modelo de detección de reescritura activo';

  @override
  String get engineAdversarialMissingFiles =>
      'El archivo del modelo o del tokenizador no existe; vuelva a descargarlo en Gestión de modelos';

  @override
  String get engineAdversarialRepairFailed =>
      'No se pudo cargar o ejecutar el modelo, y la reparación automática no se completó; vuelva a descargar el modelo de detección de reescritura y el tokenizador en Gestión de modelos.';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return 'El modelo no participó en esta votación. $error';
  }

  @override
  String get patternNotAnalyzable =>
      'Fragmento demasiado corto o posible ruido de PDF/OCR; no se realizó una evaluación de IA a nivel de oración';

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
      'TruthLens es un detector de contenido de IA que funciona **enteramente dentro de tu navegador**. Cuatro motores independientes —un clasificador neuronal Transformer, análisis estadístico, estilometría y detección de reescritura adversaria— votan con pesos si un texto fue generado por IA, y tu documento nunca sale del equipo.\n\nEl informe expresa el veredicto como probabilidad de IA clasificada en cinco tramos fijos (menos del 20 %, 20–40 %, 40–60 %, 60–80 %, 80 % o más), junto a pruebas por frase, la contribución de cada motor, las pruebas de origen del documento y el nombre del archivo al importar. Los puntos de corte no son ajustables, así que el mismo documento cae siempre en el mismo tramo. Cuando la evidencia es escasa —pocas frases o palabras, o motores demasiado en desacuerdo— lo dice claramente en lugar de forzar una puntuación.';

  @override
  String get helpComparisonTitle => 'Comparación con herramientas líderes';

  @override
  String get helpComparisonDisclaimer =>
      'Esta comparación se elaboró a partir de información pública de cada herramienta y percepciones generales del mercado, solo como referencia de posicionamiento funcional, no datos de referencia verificados por terceros.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero hace casi todo en la nube y exige subir el documento; los cuatro motores de TruthLens se ejecutan en tu propio navegador y el contenido no se envía a ningún sitio.';

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
      'Originality.ai cobra por pieza mediante suscripción y exige subir a la nube; TruthLens hace el trabajo esencial en el navegador, sin suscripción ni límite de uso.';

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
      'El OCR de imágenes de Winston AI sube la foto a la nube; el OCR de TruthLens prefiere un servidor local que tú configuras y solo recurre a la nube si aportas tú mismo una clave de API de Gemini: que intervenga la nube sigue siendo decisión tuya.';

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
  String helpWorkflowStepLabel(int step) {
    return 'Paso $step';
  }

  @override
  String get helpWorkflowStep1Title => 'Descargar y actualizar modelos';

  @override
  String get helpWorkflowStep1Body =>
      'El primer inicio te guía para instalar el modelo de detección principal; después, siempre puedes revisar, descargar, actualizar o eliminar modelos desde \"Ajustes → Gestión de modelos de IA\". La aplicación comprueba proactivamente las últimas versiones al iniciarse, y muestra una insignia en el icono de ajustes y en la entrada de \"Gestión de modelos de IA\" si hay una actualización disponible.';

  @override
  String get helpWorkflowStep2Title => 'Elegir modelos (propósito e impacto)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Clasificador de IA multilingüe (peso 40%): analiza bloques de párrafos limitados para conservar el contexto y asigna las probabilidades a las oraciones.';

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
      'Puedes activar/desactivar motores individualmente y ajustar sus pesos en Ajustes. Los cinco tramos del veredicto usan puntos de corte fijos (20 % / 40 % / 60 % / 80 %) y no se pueden cambiar, así que el mismo documento da el mismo veredicto para todo el mundo.';

  @override
  String get helpWorkflowStep3Title => 'Subir un documento';

  @override
  String get helpWorkflowStep3Body =>
      'Tres formas de entrada: pegar texto, reconocer una imagen con OCR o importar un documento (txt / md / pdf / docx / doc / odt). La importación de PDF compara dos analizadores de capa de texto y descarta la salida ilegible; los PDF escaneados se reconocen página a página cuando hay OCR disponible. Al importar, el nombre del archivo aparece bajo el encabezado de entrada y en su propia línea del título del informe; al pegar o escribir, queda en blanco.\n\nEl OCR prefiere el servidor local que configures y solo usa la nube si aportas tú mismo una clave de API de Gemini.';

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
  String get helpWorkflowStep1ChipOnboarding => 'Primer inicio';

  @override
  String get helpWorkflowStep1ChipModelManager => 'Gestión de modelos';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => 'Comprobación automática';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => 'Análisis estadístico (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => 'Estilometría (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => 'Defensa adversarial (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => 'LLM de informe (opcional)';

  @override
  String get helpWorkflowStep3ChipPaste => 'Pegar texto';

  @override
  String get helpWorkflowStep3ChipImageOcr => 'OCR de imagen';

  @override
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation =>
      'Aislar código/fórmulas';

  @override
  String get helpWorkflowStep4ChipEnsemble => 'Conjunto de 4 motores';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'Progreso en vivo';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'Corrección ESL';

  @override
  String get helpWorkflowStep4ChipStoppable =>
      'Se puede detener en cualquier momento';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'Indicador general de IA';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap =>
      'Mapa de calor por oración';

  @override
  String get helpWorkflowStep5ChipCitationVerification =>
      'Verificación de citas';

  @override
  String get helpWorkflowStep5ChipExportFormats =>
      'Exportar PDF / CSV / JSON / PNG';

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
  String get privacyWebOverview1 =>
      'TruthLens se ejecuta completamente como una aplicación web en la pestaña de su navegador. No hay nada que instalar; el texto del documento y los resultados del análisis nunca salen de su dispositivo, y los modelos de detección descargados se almacenan en caché solo en el almacenamiento aislado propio del navegador (OPFS), no en ningún servidor.';

  @override
  String get privacyWebOverview2 =>
      'La página solo lee un archivo, imagen o contenido del portapapeles cuando usted elige activamente importar, escanear o pegarlo; nunca lee otras pestañas, datos de otros sitios ni archivos que no haya seleccionado.';

  @override
  String get privacySectionOverviewWeb => 'Descripción general';

  @override
  String get privacyRemoveWeb =>
      'borrando los datos de este sitio en la configuración de su navegador (o simplemente cerrando la pestaña, ya que no se almacena nada en ningún servidor)';

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
  String get privacyNetwork4 =>
      '4. Alternativa de OCR web: solo en la versión web, OCR usa primero un servidor OCR local si está configurado. Si opta por introducir una clave de API de Gemini, las imágenes seleccionadas y las páginas de PDF renderizadas que necesitan OCR se envían directamente desde su navegador a la API de Gemini de Google; la clave se almacena únicamente en el almacenamiento local de ese navegador.';

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

  @override
  String settingsVersionSubtitle(String version, String build) {
    return 'Versión $version (Build $build) · Motor privado con prioridad local';
  }

  @override
  String get webOcrSettingsTitle => 'Configuración de OCR web';

  @override
  String get webOcrPurpose =>
      'Reconoce texto impreso o manuscrito de una imagen antes del análisis.';

  @override
  String get webOcrGeminiKeyTitle => 'Clave de API de Gemini (opcional)';

  @override
  String get webOcrGetKeyButton => 'Obtener clave';

  @override
  String get webOcrGeminiDescription =>
      'Solo se usa si el servidor OCR local no está disponible. La clave se guarda en este navegador.';

  @override
  String get webOcrLocalServerTitle => 'Servidor OCR local (recomendado)';

  @override
  String get webOcrLocalServerDescription =>
      'Ejecuta OCR en tu equipo con Apple Vision en macOS o Windows OCR en Windows. Introduce el endpoint local abajo.';

  @override
  String get webOcrSetupGuideButton => 'Guía de configuración';

  @override
  String get webOcrPriorityTitle => 'Orden de reconocimiento';

  @override
  String get webOcrPriorityDescription =>
      '1. Servidor OCR local si hay una URL\n2. Gemini si hay una clave API\n3. Diagnóstico específico si ambas opciones fallan';

  @override
  String get webOcrSetupGuideTitle => 'Configurar el servidor OCR local';

  @override
  String get webOcrSetupGuideBody =>
      '1. Selecciona Abrir proyecto OCR abajo.\n2. macOS: descarga setup_and_run_ocr.sh, abre Terminal y ejecuta: bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows: descarga setup_and_run_ocr.bat, haz doble clic y permite la instalación.\n4. Espera hasta que el instalador indique que OCR está listo; también configurará el inicio automático.\n5. Introduce http://127.0.0.1:5001/ocr y selecciona Probar conexión.\n6. Abre OCR de imagen y elige una imagen clara.\n\nPara usar 127.0.0.1, el navegador y el servidor deben ejecutarse en el mismo equipo. Si falla, revisa la instalación, el puerto 5001 y que la URL termine en /ocr.';

  @override
  String get webOcrOpenProjectButton => 'Abrir proyecto OCR';

  @override
  String get webOcrTestServerButton => 'Probar conexión';

  @override
  String get webOcrTestServerMissingUrl =>
      'Introduce primero la URL del servidor OCR local.';

  @override
  String get webOcrTestServerSuccess =>
      'El servidor OCR local está activo y listo.';

  @override
  String get webOcrTestServerFailure =>
      'No se pudo acceder al servidor OCR local. Revisa la guía, el cortafuegos y la URL.';

  @override
  String get workspaceModeSectionTitle => 'Modo de espacio de trabajo';

  @override
  String get workspaceModeSectionSubtitle =>
      'Elige cómo comparten un espacio la fuente, el análisis en vivo y la evidencia final.';

  @override
  String get workspaceModeOriginal => 'Diseño original';

  @override
  String get workspaceModeAuto => 'Automático';

  @override
  String get workspaceModeCommandGrid => 'Cuadrícula de mando';

  @override
  String get workspaceModeTimeline => 'Cronología de misión';

  @override
  String get workspaceModeEvidence => 'Lienzo de evidencia';

  @override
  String get workspaceModeCosmicFuture => 'Futuro cósmico';

  @override
  String get workspaceModeSoftEducation => 'Educación suave';

  @override
  String get workspaceModeTooltip => 'Cambiar modo de espacio de trabajo';

  @override
  String get workspaceMoreMenuTooltip => 'Más opciones';

  @override
  String get workspaceLanguageMenuTitle => 'Idioma';

  @override
  String get workspaceStageImport => 'Importar';

  @override
  String get workspaceStageParse => 'Procesar';

  @override
  String get workspaceStageAnalyze => 'Análisis de cuatro motores';

  @override
  String get workspaceStageVerify => 'Verificación';

  @override
  String get workspaceStageReport => 'Informe';

  @override
  String get workspaceLiveFindings => 'Hallazgos en vivo';

  @override
  String get workspaceTelemetry => 'Telemetría de análisis';

  @override
  String get workspaceDocument => 'Espacio del documento';

  @override
  String get workspaceOverallProgress => 'Progreso general';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return 'Paso $current/$total · $stage';
  }

  @override
  String get workspaceWaiting => 'Esperando un documento';

  @override
  String get workspaceAnalyzing => 'Análisis en curso';

  @override
  String get workspaceAnalysisComplete => 'Análisis completado';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '$done/$total módulos completados · ${seconds}s transcurridos · En ejecución: $engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return 'El análisis continúa y la interfaz responde. Ningún módulo terminó en los últimos ${seconds}s; los documentos grandes o modelos locales pueden tardar más.';
  }

  @override
  String get workspaceAnalysisFailed =>
      'El análisis se detuvo inesperadamente. Inténtalo de nuevo o revisa la configuración del modelo.';

  @override
  String get workspaceNewAnalysis => 'Nuevo análisis';

  @override
  String get workspaceStopAnalysis => 'Detener análisis';

  @override
  String get workspaceStopAnalysisTitle => '¿Detener el análisis actual?';

  @override
  String get workspaceStopAnalysisBody =>
      'El análisis sigue en curso. Se conservará el texto del documento, pero no se guardarán los resultados incompletos.';

  @override
  String get workspaceAnalysisStopped =>
      'Análisis detenido. El texto del documento permanece en el espacio de trabajo.';

  @override
  String get workspaceSelectedEvidence => 'Evidencia seleccionada';

  @override
  String get workspaceNoEvidence =>
      'La evidencia por oración aparecerá al terminar cada motor.';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return 'Probabilidad preliminar de IA: $percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      'Este porcentaje es la señal de IA propia de esta oración, no el veredicto general del documento. Un valor más alto significa que el patrón de redacción parece más generado por IA; un valor más bajo significa que se lee más como una escritura humana típica. El informe final combina todas las oraciones con la ponderación de los motores.';

  @override
  String get workspaceSentenceSignalHeader => 'Señal de IA por oración';

  @override
  String get workspaceSentenceColumnHeader => 'Oración';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine no encontró pruebas esta vez, así que no participó en la votación (peso de rol $weight %). Significa que no halló rastros de IA en su propio eje, no que considere el texto escrito por una persona.';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return 'Solo $engine encontró algo; los demás motores no hallaron nada esta vez. La conclusión se apoya en una única línea de evidencia, así que ajusta la confianza en consecuencia.';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return 'Otros $count motor(es) se ejecutaron pero no encontraron pruebas, y quedaron excluidos de la votación para que «nada que informar» no se cuente como «parece escrito por una persona».';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      'La perplejidad no se tuvo en cuenta en este documento: el modelo de perplejidad (DistilGPT2) se entrenó solo en inglés y, con texto en chino, japonés o coreano, mide la previsibilidad de los bytes, no la del idioma. Medido con datos etiquetados, separa la escritura humana de la de IA un 0 % de las veces, así que contarlo solo generaría falsos positivos.';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return 'Base por idioma: $breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return 'Hay $count muestra(s) anteriores sin etiqueta de idioma que no pueden integrarse en la base de ningún idioma: el texto original no se conserva, así que el idioma no puede recuperarse después. Se irán reemplazando con nuevos análisis.';
  }
}
