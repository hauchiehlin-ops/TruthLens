// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get verdictHuman => 'Написано человеком';

  @override
  String get verdictLikelyHuman => 'Вероятно, человеком';

  @override
  String get verdictMixed => 'Смешанный контент';

  @override
  String get verdictLikelyAi => 'Вероятно, ИИ';

  @override
  String get verdictAi => 'Сгенерировано ИИ';

  @override
  String get inputSubtitle =>
      'Вставьте или введите текст для обнаружения контента, созданного ИИ';

  @override
  String get inputHint => 'Введите или вставьте текст для анализа…';

  @override
  String get inputHistoryTooltip => 'История';

  @override
  String get inputHelpTooltip => 'Руководство пользователя';

  @override
  String get inputPrivacyTooltip => 'Политика конфиденциальности';

  @override
  String get inputSettingsTooltip => 'Настройки';

  @override
  String get inputPasteButton => 'Вставить';

  @override
  String get inputOcrButton => 'OCR изображения';

  @override
  String get inputImportButton => 'Импорт файла';

  @override
  String get inputStartButton => 'Начать обнаружение';

  @override
  String get inputClearTooltip => 'Очистить содержимое';

  @override
  String get inputTooShortSnackbar =>
      'Введите не менее 40 символов для надёжного анализа';

  @override
  String get inputOcrUnsupported =>
      'Распознавание текста OCR не поддерживается на этой платформе';

  @override
  String get inputOcrRecognizing => 'Распознавание…';

  @override
  String get inputOcrNoText => 'На изображении не обнаружено текста';

  @override
  String inputOcrRecognized(int count) {
    return 'Успешно распознано $count символов';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\" не содержит читаемого текста';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '\"$fileName\" импортирован ($count символов)';
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
    return 'Модель: $modelId';
  }

  @override
  String get inputNoModel =>
      'Модель не установлена (только статистический/стилометрический анализ)';

  @override
  String inputCharCount(int count) {
    return '$count символов';
  }

  @override
  String get analysisAppBarTitle => 'Анализ';

  @override
  String get analysisEngineTransformer => 'Классификатор Transformer';

  @override
  String get analysisEngineStatistical => 'Статистический анализ';

  @override
  String get analysisEngineStylometry => 'Стилометрический анализ';

  @override
  String get analysisEngineAdversarial => 'Состязательная защита';

  @override
  String analysisProgressSemantics(int done, int total) {
    return 'Анализ выполняется, завершено $done из $total модулей';
  }

  @override
  String get analysisDoneSemantics => 'Готово';

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
      'Состязательная защита (обнаружение перефразирования)';

  @override
  String get modelNecessityText =>
      'Без загрузки модели обнаружения на основе нейронной сети TruthLens по-прежнему работает, но использует только статистический и стилометрический анализ с ограниченной точностью и поддержкой языков. После загрузки модели многоязычный классификатор Transformer присоединится к ансамблевому голосованию, значительно повышая точность и надёжность. Модель работает на устройстве; после загрузки она не отправляет никакого контента.';

  @override
  String get modelPromptTitle =>
      'Рекомендуется загрузить модель обнаружения для полного анализа';

  @override
  String get modelPromptDontRemind => 'Больше не напоминать';

  @override
  String get modelPromptSkip => 'Пропустить пока';

  @override
  String get modelPromptDownload => 'Загрузить';

  @override
  String get onboardingWelcomeTitle => 'Добро пожаловать в TruthLens';

  @override
  String get onboardingHeadline => 'Обнаружение контента ИИ на устройстве';

  @override
  String get onboardingDetectedDevice => 'Обнаружено устройство';

  @override
  String get onboardingChooseModel => 'Выберите модель для загрузки';

  @override
  String get onboardingRecommendHint =>
      'Отметка «Рекомендуется» основана на вашем оборудовании; вы также можете выбрать другой вариант.';

  @override
  String get onboardingSkipButton =>
      'Решить позже (использовать статистический/стилометрический анализ без модели)';

  @override
  String get onboardingSkipHint =>
      'Вы всегда можете загрузить модель позже в разделе «Настройки → Управление моделями ИИ»; вам напомнят снова при использовании анализа, требующего модель.';

  @override
  String get modelListCustomImportedLabel =>
      'Импортированная пользовательская модель:';

  @override
  String get modelListActiveChip => 'Используется';

  @override
  String get modelListRecommendedChip => 'Рекомендуется';

  @override
  String get modelListCustomChip => 'Пользовательская';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · Требуется $ram ГБ ОЗУ · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'Размер: $size · Токенизатор: $tokenizer · Индекс метки ИИ: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'Загрузка… $percent% ($downloaded / $total)';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'Загрузить ($size)';
  }

  @override
  String get modelListComingSoonChip => 'Скоро';

  @override
  String get modelListSetActiveButton => 'Сделать активной';

  @override
  String get modelListUpdateButton => 'Обновить';

  @override
  String get modelListDeleteTooltip => 'Удалить';

  @override
  String get modelListPageButton => 'Страница модели';

  @override
  String get modelListMayExceedMemory =>
      'Может превысить объём памяти устройства';

  @override
  String modelListFailedPrefix(String error) {
    return 'Ошибка: $error';
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
  String get modelListDeleteConfirmTitle => 'Удалить модель?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return 'Это удалит \"$name\" ($size). Вам придётся скачать её снова, чтобы использовать.';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'Это удалит импортированную пользовательскую модель \"$name\" ($size). Вам придётся импортировать её снова, чтобы использовать.';
  }

  @override
  String get modelImportAppBarTitle => 'Импорт пользовательской модели ONNX';

  @override
  String get modelImportStep1Title => '1. Выберите файл модели ONNX';

  @override
  String modelImportSelectedFile(String name) {
    return 'Выбрано: $name';
  }

  @override
  String get modelImportNoFileSelected => 'Файл модели не выбран (.onnx)';

  @override
  String get modelImportBrowseButton => 'Обзор';

  @override
  String get modelImportCheckingDuplicate =>
      'Проверка, не был ли уже импортирован идентичный файл…';

  @override
  String get modelImportDuplicateTitle =>
      'Модель с идентичным содержимым уже импортирована';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'Этот файл имеет полностью идентичное содержимое с \"$name\" (роль: $role). Если вы просто хотите переключить активную модель, перейдите в «Управление моделями ИИ» и сделайте её активной напрямую — повторный импорт не требуется. Вы всё же можете продолжить шаги ниже.';
  }

  @override
  String get modelImportStep2Title => '2. Настройка';

  @override
  String get modelImportNameLabel => 'Отображаемое имя модели';

  @override
  String get modelImportNameRequired => 'Имя не может быть пустым';

  @override
  String get modelImportRoleLabel => 'Роль целевого модуля';

  @override
  String get modelImportTokenizerTypeLabel => 'Тип токенизатора';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => 'Нет (без токенизатора/посимвольно)';

  @override
  String get modelImportNoTokenizerSelected =>
      'Файл токенизатора не выбран (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return 'Выбрано: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'Индекс вывода метки ИИ';

  @override
  String get modelImportIndex0 => 'Индекс 0 (например, RoBERTa)';

  @override
  String get modelImportIndex1 => 'Индекс 1 (например, DistilBERT)';

  @override
  String get modelImportStep3Title => '3. Тест и проверка';

  @override
  String get modelImportTestInputLabel => 'Тестовый входной текст';

  @override
  String get modelImportRunTestButton => 'Запустить тестовый вывод';

  @override
  String get modelImportResultLabel => 'Результат вывода (вероятность ИИ):';

  @override
  String modelImportTestFailed(String error) {
    return 'Тест не пройден: $error';
  }

  @override
  String get modelImportConfirmButton =>
      'Подтвердить импорт и активировать модель';

  @override
  String get modelImportSelectTokenizerFirst =>
      'Сначала выберите файл токенизатора';

  @override
  String get modelImportSelectTokenizer => 'Выберите файл токенизатора';

  @override
  String get modelImportSuccessSnackbar =>
      'Модель успешно импортирована! Автоматически установлена как активная.';

  @override
  String get modelImportFailedSnackbar =>
      'Не удалось импортировать модель. Проверьте разрешения или журналы';

  @override
  String get settingsAppBarTitle => 'Настройки';

  @override
  String get settingsThresholdTitle => 'Порог уверенности определения ИИ';

  @override
  String get settingsThresholdInfoTooltip =>
      'How the AI flagging threshold affects the conclusion';

  @override
  String get settingsThresholdInfoBody =>
      'The enabled engines first calculate the overall AI probability. This setting does not change any engine score or that overall probability; it changes which conclusion is applied to the score. A lower threshold makes the same probability more likely to be concluded and marked as AI, while a higher threshold requires stronger AI probability and is more likely to conclude human writing. The report always retains the original probability and supporting evidence.';

  @override
  String settingsThresholdSubtitle(int percent) {
    return 'Текущий: $percent% — увеличение снижает число ложных срабатываний (текст человека ошибочно принят за ИИ)';
  }

  @override
  String get settingsEslTitle => 'Коррекция смещения ESL (неносители языка)';

  @override
  String get settingsEslSubtitle =>
      'Автоматически снижает вес статистической модели при обнаружении стиля письма неносителя языка';

  @override
  String get settingsEngineSectionTitle =>
      'Настройки подмодулей обнаружения (ансамбль)';

  @override
  String get settingsEngineTransformerTitle =>
      'Многоязычный классификатор ИИ (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Использует модель нейронной сети Transformer для прогнозирования вероятности ИИ на устройстве';

  @override
  String get settingsEngineStatisticalTitle =>
      'Модуль статистического анализа (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      'Определяет регулярность языка через вариацию длины предложений, Burstiness и PPL';

  @override
  String get settingsEngineStylometryTitle =>
      'Стилометрический анализ (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle =>
      'Анализирует семантическую плавность, повторяющиеся шаблоны предложений и использование связок';

  @override
  String get settingsEngineAdversarialTitle =>
      'Обнаружение состязательного перефразирования (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle =>
      'Обнаруживает, был ли текст перефразирован машиной или обработан для удаления следов ИИ';

  @override
  String get settingsEngineWeightsTitle => 'Веса моделей ИИ';

  @override
  String get settingsEngineWeightsSubtitle =>
      'Задайте влияние каждого движка на общий результат. Перед сохранением сумма должна составлять ровно 100%.';

  @override
  String get settingsEngineInfoTooltip => 'Назначение этого движка';

  @override
  String get settingsEngineTransformerHelp =>
      'Оценивает сохраняющие контекст блоки абзацев многоязычной моделью Transformer, затем сопоставляет оценки блоков с предложениями для подробного отчёта. Вес задаёт влияние, а сигнал ИИ определяет фактический вклад.';

  @override
  String get settingsEngineStatisticalHelp =>
      'Измеряет перплексию, предсказуемость, вариативность и длину предложений. Коррекция ESL может уменьшить эффективный вес.';

  @override
  String get settingsEngineStylometryHelp =>
      'Проверяет объяснимые признаки стиля: повторяющиеся начала, шаблонные переходы и избыток списков. Без признаков сигнал равен 0%.';

  @override
  String get settingsEngineAdversarialHelp =>
      'Ищет перефразированный текст ИИ или удалённые следы ИИ. Низкий балл означает лишь слабый остаточный сигнал, а не положительное обнаружение.';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return 'Сумма: $total% — можно сохранить';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return 'Сумма: $total% — установите ровно 100%';
  }

  @override
  String get settingsEngineWeightsSave => 'Сохранить веса';

  @override
  String get settingsEngineWeightsSaved =>
      'Веса моделей ИИ сохранены на устройстве';

  @override
  String get settingsEngineWeightsRestoreDefaults => 'Вернуть значения';

  @override
  String get engineReasonDisabledByUser =>
      'Пользователь отключил этот модуль в Настройках';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model: ни одно из $total предложений не превысило строгий порог ИИ; откалиброванный слабый сигнал — $percent%';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'Сигнал ИИ $percent%';
  }

  @override
  String get reportEngineSignalExplanation =>
      'Сигнал ИИ — это вероятность, назначенная модулем этому документу. Заданный вес определяет его влияние, а баллы вклада распределяются так, чтобы их отображаемая сумма точно совпадала с общей вероятностью ИИ. «Не обнаружено» означает значение ниже порога сильного сигнала 60%, а не обязательно ноль.';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return 'Ни одно из $total предложений не превысило порог сильного сигнала перефразирования; откалиброванный слабый сигнал составляет $percent%';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$count из $total предложений превысили порог сильного сигнала перефразирования; откалиброванный сигнал документа составляет $percent%';
  }

  @override
  String get settingsLinkVerificationTitle =>
      'Проверка гиперссылок и библиографии';

  @override
  String get settingsLinkVerificationSubtitle =>
      'Отчёт подключится для проверки, действительно ли существуют URL-адреса и библиографические записи, обнаруженные в документе (контент, созданный ИИ, часто содержит правдоподобные, но вымышленные ссылки). Академические ссылки в формате DOI и ссылки в формате «автор—год» без гиперссылки проверяются по публичному реестру Crossref. Основная модель обнаружения ИИ по-прежнему работает полностью на устройстве и никогда не отправляет содержимое документа; подключение используется только для этой проверки и проверки обновлений модели, и его можно отключить здесь.';

  @override
  String get settingsThemeTitle => 'Тема оформления';

  @override
  String get settingsLanguageTitle => 'Язык';

  @override
  String get settingsLanguageSubtitle => 'Выберите язык отображения приложения';

  @override
  String get settingsModelManagementTitle => 'Управление моделями ИИ';

  @override
  String get settingsModelManagementSubtitle =>
      'Загрузите модели обнаружения и LLM для составления отчётов, чтобы включить полные возможности вывода';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'Обнаружено обновление модели — рекомендуется проверить';

  @override
  String get settingsOpenButton => 'Открыть';

  @override
  String get settingsCustomImportTitle =>
      'Импорт и тестирование пользовательской модели ONNX';

  @override
  String get settingsCustomImportSubtitle =>
      'Импортируйте локальную пользовательскую модель ONNX, настройте токенизатор и запустите тестовый вывод';

  @override
  String get modelImportWebUnsupported =>
      'Custom model import is not supported on the web version yet. Please use the app version.';

  @override
  String get settingsLanguagePackTitle => 'Языковой пакет';

  @override
  String get settingsLanguagePackSubtitle =>
      'Дополнительная модель языковой настройки (доступна на этапе 4)';

  @override
  String get settingsModelManagerAppBarTitle => 'Управление моделями ИИ';

  @override
  String get settingsImportTooltip => 'Импортировать локальную модель ONNX';

  @override
  String settingsDeviceLabel(String summary) {
    return 'Устройство: $summary';
  }

  @override
  String get historyAppBarTitle => 'История';

  @override
  String get historyClearAllTooltip => 'Очистить всё';

  @override
  String get historySearchHint => 'Поиск по истории…';

  @override
  String get historyDeletedSnackbar => 'Запись удалена';

  @override
  String get historyClearAllTitle => 'Очистить всю историю?';

  @override
  String historyClearAllBody(int count) {
    return 'Это удалит все $count записей. Это действие нельзя отменить.';
  }

  @override
  String get historyClearButton => 'Очистить';

  @override
  String get historyDeleteEntryTitle => 'Удалить эту запись?';

  @override
  String get historyReanalyzeTooltip => 'Повторный анализ';

  @override
  String get historyEmptyDefault => 'Пока нет истории обнаружения';

  @override
  String historyEmptySearch(String query) {
    return 'Нет записей, соответствующих \"$query\"';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, вероятность ИИ $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => 'Отчёт обнаружения';

  @override
  String get reportExportTooltip => 'Экспортировать отчёт';

  @override
  String get reportHomeTooltip => 'Вернуться на главную';

  @override
  String get reportGeneratingTitle => 'Создание отчёта…';

  @override
  String get reportSourceLlm => 'Отчёт создан ИИ';

  @override
  String get reportSourceTemplate => 'Отчёт создан по шаблону';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '$total предложений · $ai вероятно ИИ · $human вероятно человек · прошло $seconds с';
  }

  @override
  String get reportExportPdf => 'Экспорт отчёта в PDF';

  @override
  String get reportExportCsv => 'Экспорт данных в CSV';

  @override
  String get reportExportJson => 'Экспорт в JSON (интеграция систем)';

  @override
  String get reportExportPng => 'Экспорт карточки сводки (PNG)';

  @override
  String reportExported(String path) {
    return 'Экспортировано: $path';
  }

  @override
  String reportExportFailed(String error) {
    return 'Ошибка экспорта: $error';
  }

  @override
  String get reportEngineWeightLabel => 'Вес';

  @override
  String get privacySealNoticeText =>
      'Знак 100% локальной конфиденциальности TruthLens: Обработка на устройстве без сохранения в облаке.';

  @override
  String get reportModelCalibrationTitle => 'Автокалибровка бенчмарка моделей';

  @override
  String get reportCommunityDiscoveredTag => 'Сообщество (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => 'Детализация движков';

  @override
  String get reportEngineNotInstalled => 'Не установлено';

  @override
  String get reportEngineLoadFailedBadge => 'Ошибка загрузки';

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
      'Доля предложений с сильным сигналом ИИ';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count из $total превысили порог сильного сигнала 60%';
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
  String get reportSentenceAnalysisTitle => 'Анализ на уровне предложений';

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
    return '$text. Вероятность ИИ $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'Подлинность гиперссылок';

  @override
  String get reportLinkNoneDetected =>
      'В этом документе гиперссылки не обнаружены.';

  @override
  String get reportLinkCheckingProgress => 'Проверка ссылок…';

  @override
  String reportLinkDetectedPending(int count) {
    return 'Обнаружено $count гиперссылок; ещё не проверено';
  }

  @override
  String get reportLinkDisabledHint =>
      'Контент, созданный ИИ, часто содержит правдоподобные, но вымышленные ссылки. Вы отключили проверку гиперссылок в Настройках; вы можете снова включить её для автоматической проверки или нажать ниже для однократной проверки.';

  @override
  String get reportVerifyNowButton => 'Проверить сейчас (требуется сеть)';

  @override
  String get reportLinkReachable => 'Доступно — URL существует';

  @override
  String get reportLinkNotFound =>
      'URL не существует (404) — возможно, вымышленная ссылка';

  @override
  String get reportLinkUnreachable =>
      'Не удалось проверить (тайм-аут или нет ответа сервера)';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'Подтверждено в реестре журналов: зарегистрировано в $journal$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      'Соответствующая регистрация DOI не найдена — возможно, вымышленная ссылка';

  @override
  String get reportLinkCitationUnreachable =>
      'Не удалось проверить (тайм-аут или нет ответа от Crossref)';

  @override
  String reportLinkTruncated(int max, int count) {
    return 'Проверены только первые $max ссылок (всего обнаружено $count)';
  }

  @override
  String get reportBibAuthenticityTitle => 'Подлинность цитирования';

  @override
  String get reportBibNoneDetected =>
      'В этом документе библиографические записи не обнаружены.';

  @override
  String get reportBibCheckingProgress => 'Проверка библиографии…';

  @override
  String reportBibDetectedPending(int count) {
    return 'Обнаружена библиография ($count записей); ещё не проверено';
  }

  @override
  String get reportBibDisabledHint =>
      'Контент, созданный ИИ, часто содержит правдоподобные, но вымышленные ссылки. Вы отключили проверку гиперссылок в Настройках; вы можете снова включить её для автоматической проверки или нажать ниже для однократной проверки.';

  @override
  String get reportVerifyNowBibButton => 'Проверить сейчас (требуется сеть)';

  @override
  String get reportBibRecheckAllUnreliableButton =>
      'Recheck all unverified citations';

  @override
  String get reportBibRecheckOneTooltip => 'Recheck this citation';

  @override
  String get reportBibResultHint =>
      'Сопоставлено с публичным реестром Crossref по сходству автора, года и названия. Не является абсолютной гарантией — при статусе «неопределённо» проверьте вручную.';

  @override
  String reportBibVerificationSource(String source) {
    return 'Verification source: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'Check manually in Google Scholar';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Высокая уверенность: вероятно, существует$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (зарегистрировано в $journal)';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'Journal name mismatch: the document says “$reported”, while the verified registry says “$registered”. Please review this citation.';
  }

  @override
  String get reportBibNotFound =>
      'Близкое совпадение не найдено — возможно, вымышленная ссылка';

  @override
  String get reportBibUncertain => 'Suspect: not verified by registry match';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Проверены только первые $max записей (всего обнаружено $count)';
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
  String get reportNetworkWarningTitle => 'Слабое сетевое соединение';

  @override
  String get reportNetworkWarningBody =>
      'Это приложение по умолчанию предполагает наличие сетевого соединения; для анализа подлинности гиперссылок и цитирования требуется доступ к сети, чтобы получить результаты. Не удалось установить соединение — проверьте вашу сеть и попробуйте снова.';

  @override
  String get reportRetryConnectionButton => 'Повторить подключение';

  @override
  String get reportAiProbabilityLabel => 'Вероятность ИИ';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '$total предложений\n$ai вероятно ИИ\n$human вероятно человек';
  }

  @override
  String get summaryCardFooter =>
      'Основной вывод ИИ полностью выполняется на устройстве';

  @override
  String get exportReportTitle => 'Отчёт обнаружения TruthLens';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · Страница $page из $total';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return 'Проанализировано: $datetime · прошло $seconds с';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return 'Общий вердикт: $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => ' (применена коррекция ESL)';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '$total предложений · $ai вероятно ИИ · $human вероятно человек';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'Для сохранения читаемости PDF отображаются только первые $max предложений (из $count всего); для полных данных по каждому предложению используйте вместо этого \"$csvLabel\" или \"$jsonLabel\".';
  }

  @override
  String get pdfSentenceColumnHeader =>
      'Предложение (с совпадающими шаблонами)';

  @override
  String composerHeadlineAi(int percent) {
    return 'Этот текст, скорее всего, создан ИИ (вероятность ИИ $percent%)';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'Этот текст, вероятно, создан ИИ; рекомендуется дополнительная проверка (вероятность ИИ $percent%)';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'Этот текст демонстрирует смешанные характеристики человека и ИИ (вероятность ИИ $percent%)';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'Этот текст, вероятно, написан человеком (вероятность ИИ $percent%)';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'Этот текст, скорее всего, написан человеком (вероятность ИИ $percent%)';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return 'Общая вероятность ИИ превышает установленный вами порог $percent% и помечена как ИИ.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'Общая вероятность ИИ ниже установленного вами порога маркировки $percent%.';
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
  String get composerNarrativeTitle => 'Интерпретация анализа';

  @override
  String get composerParaphraseTitle => 'Обнаружены следы перефразирования';

  @override
  String get composerParaphraseBody =>
      'Этот текст, возможно, был обработан инструментом перефразирования (например, QuillBot, Undetectable.ai) для обхода обнаружения. Хотя предложение за предложением он выглядит естественно, его общий статистический след всё же отличается от подлинного человеческого письма — обратите на это особое внимание.';

  @override
  String get composerPatternListTitle => 'Основные шаблоны письма ИИ';

  @override
  String get composerEslTitle => 'Коррекция смещения ESL (неносители языка)';

  @override
  String get composerEslBody =>
      'Этот текст может принадлежать автору, для которого язык не родной. Низкая перплексия и регулярные шаблоны предложений, характерные для неносителей языка, сами по себе не являются признаком ИИ, поэтому система снизила вес статистической модели, чтобы избежать ошибочной оценки.';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return 'В этом тексте всего $total предложений, из которых $ai демонстрируют сильные характеристики ИИ, а $human склонны к написанию человеком.';
  }

  @override
  String get composerNarrativeAiPattern =>
      'Большинство предложений очень регулярны по ритму, выбору слов и использованию связок — обычный след текста, созданного ИИ.';

  @override
  String get composerNarrativeMixedPattern =>
      'Текст содержит как регулярные, так и естественно вариативные части, что указывает на человеческий черновик, отшлифованный ИИ, или на сотрудничество человека с ИИ.';

  @override
  String get composerNarrativeHumanPattern =>
      'Длина предложений и выбор слов демонстрируют естественную вариативность и личный стиль, без явных признаков регулярности ИИ.';

  @override
  String engineReasonPplLow(String ppl) {
    return 'Низкая перплексия языковой модели ($ppl) — текст очень предсказуем, индикатор генерации ИИ';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'Высокая перплексия языковой модели ($ppl), что соответствует непредсказуемой природе человеческого письма';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'Умеренная перплексия языковой модели ($ppl)';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'Очень однородная длина предложений (burstiness $value) — ровный ритм является распространённым статистическим следом текста, созданного ИИ';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'Заметная вариация длины предложений (burstiness $value), что соответствует естественному ритму человеческого письма';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'Низкое разнообразие словаря (TTR $value) — высокая повторяемость слов';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'Высокое разнообразие словаря (TTR $value)';
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
      'Статистические показатели не демонстрируют явной тенденции — сохраняется нейтральный вердикт';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return 'Частое использование общих связок ($words), в среднем $density на предложение — плотность, редкая для человеческого письма';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return 'Несколько подряд идущих предложений начинаются с одного и того же слова ($count раз) — повторяющаяся структура предложений';
  }

  @override
  String get engineReasonNoStyleMarkers =>
      'Заметных шаблонов письма ИИ не обнаружено';

  @override
  String get engineReasonAdversarialNotInstalled =>
      'Модель обнаружения перефразирования не установлена; не участвовала в этом голосовании';

  @override
  String get engineReasonTransformerNotInstalled =>
      'Модель не установлена или активная модель не поддерживается; не участвовала в этом голосовании';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'Не удалось загрузить модель, она не участвовала в этом голосовании ($error)';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model оценила, что $aiCount из $total предложений демонстрируют характеристики ИИ';
  }

  @override
  String get engineReasonAdversarialDetected =>
      'Состязательная модель обнаружила возможные следы ИИ, удалённые с помощью инструмента перефразирования (например, QuillBot / Undetectable.ai)';

  @override
  String get engineReasonAdversarialClean =>
      'Явных следов обхода через перефразирование не обнаружено';

  @override
  String get engineReasonGenericNotInstalled =>
      'Модель не установлена; не участвовала в этом голосовании';

  @override
  String patternGenericTransition(String word) {
    return 'общая связка «$word»';
  }

  @override
  String get helpAppBarTitle => 'Руководство пользователя';

  @override
  String get helpAboutTitle => 'О TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens — это кроссплатформенное приложение (iOS / Android / macOS / Windows) для обнаружения контента, основной вывод ИИ которого полностью выполняется на устройстве. Четыре независимых подмодели — нейронный классификатор Transformer, статистический анализ, стилометрический анализ и обнаружение состязательного перефразирования — совместно голосуют, чтобы определить, создан ли текст ИИ, с объяснимыми причинами для каждого предложения: не просто процент «похоже на ИИ», а объяснение «почему».';

  @override
  String get helpComparisonTitle => 'Сравнение с ведущими инструментами';

  @override
  String get helpComparisonDisclaimer =>
      'Это сравнение составлено на основе публичной информации о каждом инструменте и общего восприятия рынка, только для справки по функциональному позиционированию — не проверенные третьей стороной эталонные данные.';

  @override
  String get helpVsGptZeroTitle => 'против GPTZero';

  @override
  String get helpVsGptZero1 =>
      'Обработка GPTZero в основном выполняется в облаке и требует загрузки вашего документа; все четыре модуля обнаружения TruthLens работают на устройстве.';

  @override
  String get helpVsGptZero2 =>
      'GPTZero стал пионером метрик Perplexity/Burstiness и выделения предложений — TruthLens объединяет их и добавляет классификатор Transformer, стилометрический анализ и состязательную защиту, формируя ансамблевое голосование четырёх моделей вместо одной метрики.';

  @override
  String get helpVsGptZero3 =>
      'GPTZero работает по подписке; TruthLens не требует подписки и не имеет ограничений использования.';

  @override
  String get helpVsTurnitinTitle => 'против Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin продаётся только учреждениям; частные лица не могут купить его напрямую. Любой может установить и использовать TruthLens.';

  @override
  String get helpVsTurnitin2 =>
      'Процесс принятия решений Turnitin почти как чёрный ящик; TruthLens предоставляет вероятность ИИ для каждого предложения, совпадающие шаблоны письма, а также разбивку баллов и причин по каждому модулю.';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin в основном даёт бинарный результат «является ли это ИИ»; TruthLens поддерживает маркировку человек/ИИ/смешанное на уровне абзаца/предложения.';

  @override
  String get helpVsOriginalityTitle => 'против Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai — это подписка за документ, требующая загрузки вашего документа в облако; основная обработка TruthLens выполняется на устройстве без необходимости постоянной подписки для обнаружения.';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai предлагает концепции проверки фактов и анализа читабельности; TruthLens отвечает на это модулем стилевых характеристик на устройстве и может выполнять базовый анализ даже офлайн.';

  @override
  String get helpVsCopyleaksTitle => 'против Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks в основном представляет собой облачный API, известный низким уровнем ложных срабатываний и надёжной многоязычной поддержкой; TruthLens разделяет эту философию с многоязычной базовой моделью XLM-RoBERTa и ансамблевым голосованием нескольких моделей, но содержимое вашего документа никогда не загружается ни на какой сервер.';

  @override
  String get helpVsCopyleaks2 =>
      'У Copyleaks есть ограничения использования API в зависимости от тарифа; у TruthLens ограничений использования нет.';

  @override
  String get helpVsWinstonTitle => 'против Winston AI';

  @override
  String get helpVsWinston1 =>
      'Распознавание изображений OCR в Winston AI требует загрузки изображений в облако; TruthLens использует нативные фреймворки каждой платформы (Vision на iOS/macOS, ML Kit на Android, Windows.Media.Ocr на Windows) для распознавания текста на устройстве.';

  @override
  String get helpVsWinston2 =>
      'Winston AI известен аккуратными, готовыми для печати отчётами; TruthLens динамически создаёт макет отчёта с помощью ИИ (возвращаясь к шаблону, если LLM не установлена), с возможностью экспорта в PDF/CSV/JSON/PNG.';

  @override
  String get helpAdvantagesTitle => 'Эксклюзивные преимущества TruthLens';

  @override
  String get helpAdvantage1 =>
      'Проверка подлинности гиперссылок: автоматически проверяет, действительно ли доступны URL-адреса, найденные в документе; академические ссылки в формате DOI дополнительно проверяются по публичному реестру Crossref для подтверждения того, что журнал действительно индексирует эту работу.';

  @override
  String get helpAdvantage2 =>
      'Проверка подлинности цитирования: даже ссылки без каких-либо гиперссылок (обычный стиль «автор—год») можно проверить по библиографическим реестрам для обнаружения возможно вымышленных цитат — распространённый признак галлюцинаций ИИ.';

  @override
  String get helpAdvantage3 =>
      'Коррекция смещения ESL (неносители языка): автоматически обнаруживает характеристики письма неносителей языка и снижает вес статистической модели, избегая ошибочной оценки естественного письма неносителей как ИИ.';

  @override
  String get helpAdvantage4 =>
      'Импорт пользовательских моделей: продвинутые пользователи могут импортировать собственные локальные модели ONNX для замены или дополнения встроенных модулей обнаружения.';

  @override
  String get helpWorkflowTitle => 'Полный рабочий процесс';

  @override
  String helpWorkflowStepLabel(int step) {
    return 'Шаг $step';
  }

  @override
  String get helpWorkflowStep1Title => 'Загрузка и обновление моделей';

  @override
  String get helpWorkflowStep1Body =>
      'При первом запуске вам предлагается установить основную модель обнаружения; после этого вы всегда можете проверить, загрузить, обновить или удалить модели в разделе «Настройки → Управление моделями ИИ». Приложение проактивно проверяет наличие последних версий при запуске и показывает значок на значке настроек и пункте «Управление моделями ИИ», если доступно обновление.';

  @override
  String get helpWorkflowStep2Title => 'Выбор моделей (назначение и влияние)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Многоязычный классификатор ИИ (вес 40%): анализирует ограниченные блоки абзацев с сохранением контекста, затем сопоставляет вероятности с предложениями.';

  @override
  String get helpWorkflowStep2Bullet2 =>
      'Модуль статистического анализа (вес 25%): анализ скользящего окна перплексии и burstiness, улавливающий регулярный ритм и предсказуемый выбор слов текста ИИ.';

  @override
  String get helpWorkflowStep2Bullet3 =>
      'Стилометрический анализ (вес 20%): семантическая плавность, повторяющиеся шаблоны предложений, использование связок — наиболее объяснимый, легче всего понять «почему».';

  @override
  String get helpWorkflowStep2Bullet4 =>
      'Состязательная защита (вес 15%): обнаруживает текст, который был «очищен» с помощью инструментов перефразирования (например, QuillBot, Undetectable.ai).';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'LLM для составления отчётов (опционально): после установки текст отчёта динамически составляется LLM на устройстве; без неё приложение возвращается к фиксированному шаблону — сам анализ не страдает.';

  @override
  String get helpWorkflowStep2Bullet6 =>
      'Вы можете включать/отключать модули по отдельности и настраивать порог уверенности обнаружения ИИ в Настройках (увеличение снижает вероятность ошибочной оценки человеческого письма как ИИ).';

  @override
  String get helpWorkflowStep3Title => 'Загрузка документа';

  @override
  String get helpWorkflowStep3Body =>
      'Три способа ввода: прямая вставка текста, OCR изображения (распознаётся на устройстве с нативными фреймворками каждой платформы) или импорт файла (txt / md / pdf / docx / doc). Текст должен содержать не менее 40 символов для отправки на анализ.';

  @override
  String get helpWorkflowStep4Title => 'Запуск анализа';

  @override
  String get helpWorkflowStep4Body =>
      'Нажмите «Начать обнаружение», и все четыре модуля запускаются параллельно, с отображением прогресса в реальном времени на экране. Если обнаружены характеристики письма неносителя языка, автоматически применяется коррекция смещения ESL (можно отключить в Настройках).';

  @override
  String get helpWorkflowStep5Title => 'Просмотр и экспорт результатов';

  @override
  String get helpWorkflowStep5Body =>
      'Страница отчёта включает: общий индикатор вероятности ИИ, тепловую карту на уровне предложений, разбивку баллов и причин по каждому модулю, подлинность гиперссылок и подлинность цитирования. Вы можете экспортировать полный отчёт в PDF, данные по каждому предложению в CSV, JSON (для интеграции систем) или карточку сводки в PNG (для обмена). Каждый анализ автоматически сохраняется в «Истории» для последующего просмотра.';

  @override
  String get helpWorkflowStep1ChipOnboarding => 'Первый запуск';

  @override
  String get helpWorkflowStep1ChipModelManager => 'Управление моделями';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => 'Автопроверка обновлений';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => 'Статистический анализ (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => 'Стилометрия (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => 'Adversarial defense (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => 'LLM отчёта (опционально)';

  @override
  String get helpWorkflowStep3ChipPaste => 'Вставить текст';

  @override
  String get helpWorkflowStep3ChipImageOcr => 'OCR изображения';

  @override
  String get helpWorkflowStep3ChipImportFormats => 'PDF / DOCX / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation =>
      'Исключить код/формулы';

  @override
  String get helpWorkflowStep4ChipEnsemble => 'Ансамбль 4 движков';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'Прогресс в реальном времени';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'Коррекция ESL';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'Общий индикатор ИИ';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => 'Теплокарта предложений';

  @override
  String get helpWorkflowStep5ChipCitationVerification =>
      'Проверка цитирований';

  @override
  String get helpWorkflowStep5ChipExportFormats =>
      'Экспорт PDF / CSV / JSON / PNG';

  @override
  String get helpTuningTitle =>
      'Руководство по загрузке и настройке моделей (опыт не требуется)';

  @override
  String get helpTuningStep1Title => 'Откройте управление моделями';

  @override
  String get helpTuningStep1Body =>
      'На главном экране нажмите значок шестерёнки, чтобы открыть «Настройки», затем нажмите «Открыть» рядом с «Управление моделями ИИ».';

  @override
  String get helpTuningStep2Title => 'Выберите модель для вашего устройства';

  @override
  String get helpTuningStep2Body =>
      'Экран автоматически предлагает подходящий уровень модели на основе возможностей вашего устройства (ОЗУ, ядра ЦП) и перечисляет каждый доступный вариант для каждой роли (многоязычный классификатор / статистический анализ / состязательная защита / LLM для отчётов).';

  @override
  String get helpTuningStep3Title => 'Загрузка и использование';

  @override
  String get helpTuningStep3Body =>
      'Нажмите «Загрузить» рядом с нужной моделью и дождитесь завершения — первая загруженная вами модель автоматически станет активной. Если у вас установлено несколько вариантов, нажмите «Сделать активной», чтобы переключиться в любое время; нажмите значок корзины, чтобы удалить ненужные модели и освободить место.';

  @override
  String get helpTuningStep4Title => 'Обновление моделей';

  @override
  String get helpTuningStep4Body =>
      'Когда доступна новая версия, «Управление моделями ИИ» и значок шестерёнки настроек показывают значок — вернитесь на этот экран, чтобы увидеть и загрузить обновление (ранее установленные версии сохраняются, если вы не удалите их вручную).';

  @override
  String get helpTuningStep5Title =>
      'Расширенно: импорт пользовательских моделей';

  @override
  String get helpTuningStep5Body =>
      'Если у вас уже есть или вы настроили совместимую модель .onnx в другом месте, вы можете импортировать её через «Настройки → Импорт и тестирование пользовательской модели ONNX» — вам нужно предоставить файл модели, соответствующую конфигурацию токенизатора (или выбрать «нет») и индекс класса ИИ. Перед импортом приложение автоматически проверяет, не был ли этот же файл уже импортирован, чтобы избежать случайного дублирования.';

  @override
  String get helpOfficialLinksTitle =>
      'Официальные ссылки для загрузки моделей';

  @override
  String get helpOfficialLinksHint =>
      'Нажатие на элемент откроет официальную страницу этой модели в системном браузере.';

  @override
  String get helpLinkRoleTransformer =>
      'Многоязычный классификатор ИИ (Transformer, вес 40%)';

  @override
  String get helpLinkRoleStatistical =>
      'Статистическая модель перплексии (Statistical, вес 25%)';

  @override
  String get helpLinkRoleAdversarial =>
      'Модель обнаружения состязательного перефразирования (Adversarial, вес 15%)';

  @override
  String get helpLinkRoleLlm => 'LLM для составления отчётов (опционально)';

  @override
  String get privacyAppBarTitle => 'Политика конфиденциальности';

  @override
  String privacyPlatformTitle(String platform) {
    return 'Политика конфиденциальности $platform';
  }

  @override
  String privacyLastUpdated(String date) {
    return 'Последнее обновление: $date';
  }

  @override
  String get privacyIosOverview1 =>
      'TruthLens не собирает никаких данных, связанных с вашей личностью, и не использует никакие данные для отслеживания, поэтому не требует разрешения App Tracking Transparency (ATT).';

  @override
  String get privacyIosOverview2 =>
      'Это приложение использует системный выбор файлов для доступа к файлам или изображениям, которые вы активно выбираете; оно не может получить доступ к файлам, которые вы не выбрали (это обеспечивается App Sandbox iOS).';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLens не собирает личные данные и не передаёт данные пользователя каким-либо третьим лицам.';

  @override
  String get privacyAndroidOverview2 =>
      'Это приложение обращается к хранилищу только тогда, когда вы активно выбираете импорт файла или изображения; оно не сканирует и не обращается к другим файлам в фоновом режиме.';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens работает в App Sandbox macOS и может получать доступ только к файлам, которые вы активно выбираете через системный диалог файлов (files.user-selected.read-write) — оно не может самостоятельно просматривать или обращаться к каким-либо другим файлам или папкам.';

  @override
  String get privacyMacosOverview2 =>
      'Доступ к сети (network.client) используется только для функций, перечисленных в разделе «Требуемое поведение подключения» ниже.';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens — это автономное настольное приложение; данные хранятся в вашей локальной папке пользователя (например, AppData/Documents) и никогда не синхронизируются с облаком.';

  @override
  String get privacyWindowsOverview2 =>
      'Это приложение обращается только к файлам, которые вы активно выбираете для импорта; оно не сканирует другие файлы в фоновом режиме.';

  @override
  String get privacyDataHandling1 =>
      'У TruthLens нет учётных записей пользователей, не требуется вход в систему, и оно не содержит никаких рекламных или отслеживающих SDK третьих лиц в какой-либо форме.';

  @override
  String get privacyDataHandling2 =>
      'Любое содержимое документа, которое вы вводите, вставляете или импортируете, полностью анализируется моделями ИИ на вашем собственном устройстве — оно никогда не загружается на серверы TruthLens или какие-либо серверы третьих лиц.';

  @override
  String get privacyDataHandling3 =>
      'Результаты анализа и история хранятся только в локальной базе данных на вашем устройстве; удаление приложения или очистка истории полностью удаляет их — TruthLens не хранит никаких копий где-либо.';

  @override
  String get privacyNetworkIntro =>
      'Основное обнаружение ИИ в этом приложении полностью выполняется на устройстве, но следующие три функции требуют доступа к сети:';

  @override
  String get privacyNetwork1 =>
      '1. Каталог и загрузка моделей: подключается к GitHub Releases/Hugging Face для загрузки выбранной вами модели обнаружения — это только загружает модель и никогда не отправляет никакие данные пользователя.';

  @override
  String get privacyNetwork2 =>
      '2. Проверка обновлений модели: при запуске приложение подключается только для сравнения номеров версий, что используется для отображения доступности новой версии.';

  @override
  String get privacyNetwork3 =>
      '3. Проверка подлинности гиперссылок и цитирования: включена по умолчанию, можно отключить в Настройках. При включении URL-адрес или библиографический текст, обнаруженный в документе, отправляется напрямую на этот URL или в публичный API Crossref, отправляя только текст URL/DOI/цитирования — никогда остальное содержимое документа.';

  @override
  String get privacyNetwork4 =>
      '4. Web OCR fallback: on the Web version only, OCR first uses a local OCR server if configured. If you choose to enter a Gemini API key, selected images and rendered pages from PDFs that require OCR are sent directly from your browser to Google\'s Gemini API; the key is stored only in that browser\'s local storage.';

  @override
  String get privacyRightsIntro =>
      'Вы можете в любое время очистить свою локальную историю анализа в разделе «История», отключить проверку гиперссылок/цитирования в «Настройках» или удалить все локальные данные, выполнив';

  @override
  String get privacyRemoveIos => 'удаление приложения';

  @override
  String get privacyRemoveAndroid => 'удаление приложения';

  @override
  String get privacyRemoveMacos => 'перемещение приложения в Корзину';

  @override
  String get privacyRemoveWindows => 'удаление приложения';

  @override
  String get privacyDisclaimer =>
      'Эта страница представляет собой объяснение конфиденциальности, написанное TruthLens для отражения фактического функционального поведения, а не формальный юридический документ, проверенный юристом; для формальной проверки соответствия законам вашего региона обратитесь к независимому юристу.';

  @override
  String get privacySectionOverviewIos =>
      'Обзор (эквивалент «Меток конфиденциальности» App Store)';

  @override
  String get privacySectionOverviewAndroid =>
      'Обзор (эквивалент раскрытия «Безопасность данных» Google Play)';

  @override
  String get privacySectionOverviewMacos => 'Обзор (разрешения App Sandbox)';

  @override
  String get privacySectionOverviewWindows => 'Обзор';

  @override
  String get privacySectionDataHandling => 'Как мы обрабатываем ваши данные';

  @override
  String get privacySectionNetwork => 'Необходимые сетевые подключения';

  @override
  String get privacySectionRights => 'Ваши права';

  @override
  String get privacyGenericPlatformName => 'Эта платформа';

  @override
  String get settingsLanguagePackDialogBody =>
      'Встроенный многоязычный детектор TruthLens уже поддерживает более 104 языков. В управлении моделями ИИ можно искать, загружать и переключать языковые модели сообщества.';

  @override
  String settingsVersionSubtitle(String version, String build) {
    return 'Версия $version (Build $build) · Конфиденциальный локальный движок';
  }

  @override
  String get webOcrSettingsTitle => 'Настройки Web OCR';

  @override
  String get webOcrPurpose =>
      'Распознаёт печатный или рукописный текст на изображении до анализа.';

  @override
  String get webOcrGeminiKeyTitle => 'Ключ API Gemini (необязательно)';

  @override
  String get webOcrGetKeyButton => 'Получить ключ';

  @override
  String get webOcrGeminiDescription =>
      'Используется только при недоступности локального OCR-сервера. Ключ хранится в этом браузере.';

  @override
  String get webOcrLocalServerTitle => 'Локальный OCR-сервер (рекомендуется)';

  @override
  String get webOcrLocalServerDescription =>
      'Запускает OCR на компьютере через Apple Vision в macOS или Windows OCR в Windows. Укажите локальную конечную точку ниже.';

  @override
  String get webOcrSetupGuideButton => 'Руководство по настройке';

  @override
  String get webOcrPriorityTitle => 'Порядок распознавания';

  @override
  String get webOcrPriorityDescription =>
      '1. Локальный OCR-сервер при заданном URL\n2. Gemini при заданном ключе API\n3. Точная диагностика при сбое обоих способов';

  @override
  String get webOcrSetupGuideTitle => 'Настройка локального OCR-сервера';

  @override
  String get webOcrSetupGuideBody =>
      '1. Нажмите Открыть проект OCR ниже.\n2. macOS: загрузите setup_and_run_ocr.sh, откройте Терминал и выполните: bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows: загрузите setup_and_run_ocr.bat, дважды щёлкните и разрешите установку.\n4. Дождитесь сообщения о готовности OCR; автозапуск также будет настроен.\n5. Введите http://127.0.0.1:5001/ocr и нажмите Проверить соединение.\n6. Откройте OCR изображения и выберите чёткое изображение.\n\nДля 127.0.0.1 браузер и сервер должны работать на одном компьютере. При сбое проверьте установку, порт 5001 и окончание /ocr.';

  @override
  String get webOcrOpenProjectButton => 'Открыть проект OCR';

  @override
  String get webOcrTestServerButton => 'Проверить соединение';

  @override
  String get webOcrTestServerMissingUrl =>
      'Сначала введите URL локального OCR-сервера.';

  @override
  String get webOcrTestServerSuccess => 'Локальный OCR-сервер запущен и готов.';

  @override
  String get webOcrTestServerFailure =>
      'Не удалось подключиться к локальному OCR-серверу. Проверьте руководство, брандмауэр и URL.';

  @override
  String get workspaceModeSectionTitle => 'Режим рабочего пространства';

  @override
  String get workspaceModeSectionSubtitle =>
      'Выберите размещение источника, анализа в реальном времени и итоговых доказательств.';

  @override
  String get workspaceModeOriginal => 'Исходный макет';

  @override
  String get workspaceModeAuto => 'Автоматически';

  @override
  String get workspaceModeCommandGrid => 'Командная сетка';

  @override
  String get workspaceModeTimeline => 'Хронология миссии';

  @override
  String get workspaceModeEvidence => 'Полотно доказательств';

  @override
  String get workspaceModeTooltip => 'Сменить режим рабочего пространства';

  @override
  String get workspaceStageImport => 'Импорт';

  @override
  String get workspaceStageParse => 'Разбор';

  @override
  String get workspaceStageAnalyze => 'Анализ четырьмя модулями';

  @override
  String get workspaceStageVerify => 'Проверка';

  @override
  String get workspaceStageReport => 'Отчёт';

  @override
  String get workspaceLiveFindings => 'Текущие результаты';

  @override
  String get workspaceTelemetry => 'Телеметрия анализа';

  @override
  String get workspaceDocument => 'Рабочая область документа';

  @override
  String get workspaceOverallProgress => 'Общий прогресс';

  @override
  String get workspaceWaiting => 'Ожидание документа';

  @override
  String get workspaceAnalyzing => 'Идёт анализ';

  @override
  String get workspaceAnalysisComplete => 'Анализ завершён';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return 'Завершено модулей: $done/$total · Прошло $seconds с · Выполняется: $engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return 'Анализ продолжается, интерфейс отвечает. За последние $seconds с ни один модуль не завершился; большим документам или локальным моделям может требоваться больше времени.';
  }

  @override
  String get workspaceAnalysisFailed =>
      'Анализ неожиданно остановился. Повторите попытку или проверьте настройки модели.';

  @override
  String get workspaceNewAnalysis => 'Новый анализ';

  @override
  String get workspaceSelectedEvidence => 'Выбранное доказательство';

  @override
  String get workspaceNoEvidence =>
      'Доказательства по предложениям появятся после завершения модулей.';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return 'Предварительная вероятность ИИ: $percent%';
  }
}
