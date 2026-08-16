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
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

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
    return 'Текстовый слой PDF недоступен; распознаётся страница $page из $total с помощью OCR…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return 'Файл «$fileName» импортирован с помощью OCR PDF ($count символов)';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return 'В файле «$fileName» нет надёжного текстового слоя. Настройте веб-OCR или используйте установленное приложение с нативным OCR, затем импортируйте файл повторно.';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return 'Файлу «$fileName» требуется OCR, но он превышает лимит безопасности в $max страниц. Разделите PDF и импортируйте каждую часть.';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return 'Не удалось надёжно прочитать файл «$fileName». Возможно, он повреждён, защищён паролем или не поддерживается настроенной службой OCR.';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '«$fileName» — это файл в устаревшем формате .doc, текст которого не удалось надёжно извлечь. Сохраните его как .docx в Word или экспортируйте в PDF, затем импортируйте снова.';
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
    return 'Предварительный результат: вероятность ИИ $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return 'Предварительный результат: вероятность ИИ $percent% (уточняется…)';
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
  String get modelCatalogLoadFailed => 'Не удалось загрузить каталог моделей';

  @override
  String get modelCatalogEmpty => 'Нет доступных моделей';

  @override
  String modelDownloadPathChip(String label) {
    return 'Путь загрузки $label';
  }

  @override
  String get modelDownloadPathModelFile => 'Файл модели';

  @override
  String get modelDownloadPathCopied => 'Путь загрузки скопирован';

  @override
  String settingsSaveFailed(String error) {
    return 'Не удалось сохранить настройки: $error';
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
      'Как порог маркировки ИИ влияет на вывод';

  @override
  String get settingsThresholdInfoBody =>
      'Включённые движки сначала вычисляют общую вероятность ИИ. Эта настройка не изменяет ни один показатель движка, ни общую вероятность; она изменяет, какой вывод применяется к показателю. Более низкий порог делает более вероятным, что та же вероятность будет признана и помечена как ИИ, тогда как более высокий порог требует более сильной вероятности ИИ и с большей вероятностью приводит к выводу о человеческом письме. Отчёт всегда сохраняет исходную вероятность и подтверждающие доказательства.';

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
      'Импорт пользовательских моделей пока не поддерживается в веб-версии. Используйте версию приложения.';

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
  String get reportEngineAnalysisLevelTitle => 'Уровни анализа движков';

  @override
  String get reportVerdictAiLikelihood => 'Склонность к ИИ';

  @override
  String get reportVerdictHumanLikelihood => 'Человеческое письмо';

  @override
  String get reportRadarRoleTransformer => 'Классификатор Transformer';

  @override
  String get reportRadarRoleStatistical => 'Статистический анализ';

  @override
  String get reportRadarRoleStylometry => 'Стилометрический анализ';

  @override
  String get reportRadarRoleAdversarial => 'Состязательная защита';

  @override
  String get reportRadarAxisTransformer => 'Классификатор предложений';

  @override
  String get reportRadarAxisStatistical => 'Языковая регулярность';

  @override
  String get reportRadarAxisStylometry => 'Стиль письма';

  @override
  String get reportRadarAxisAdversarial => 'Защита от перефразирования';

  @override
  String get reportVerdictBadgeTitle => 'Общий вердикт';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return 'Общая вероятность ИИ $percent%';
  }

  @override
  String get reportVerdictHintHuman =>
      'Большинство сигналов движков указывают на естественное человеческое письмо.';

  @override
  String get reportVerdictHintLikelyHuman =>
      'В целом текст ближе к человеческому, с небольшой остаточной неопределённостью модели.';

  @override
  String get reportVerdictHintMixed =>
      'Сигналы движков неоднозначны; ознакомьтесь с подробным анализом вместе с этим результатом.';

  @override
  String get reportVerdictHintLikelyAi =>
      'Несколько показателей указывают на ИИ; проверьте фрагменты с высокой оценкой.';

  @override
  String get reportVerdictHintAi =>
      'Общие сигналы сильно указывают на текст, сгенерированный или переписанный ИИ.';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return 'Общий вердикт: $verdict; общая вероятность ИИ $percent%.';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return 'Самый сильный отдельный сигнал: $label ($percent%), но итоговый результат объединяет веса всех движков и не является заключением одного движка.';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return 'Наибольший взвешенный вклад в настоящее время вносит $label (около $points процентных пунктов).';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '«Явный стиль письма ИИ не обнаружен» означает лишь то, что стилевой движок не нашёл фиксированных структур предложений или переходных слов; другие модели всё же могут повысить общий балл за счёт языковой регулярности, классификации предложений или сигналов перефразирования.';

  @override
  String get reportSynthesisModelGap =>
      'Если некоторые движки не участвовали, сначала используйте «Дополнить рекомендуемые модели анализа» в «Управление моделями»; если проблема сохраняется, подробный анализ укажет, вызвана ли она отсутствующей моделью, неподдерживаемым токенизатором, отсутствующим файлом или ограничением совместимости Web/ONNX Runtime.';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label не участвовал в этом взвешенном голосовании, поэтому данный показатель отображается как 0%. $hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return 'Вес роли $weight%, вклад в общий балл — около $points процентных пунктов$variantText.';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return ' (объединено вариантов модели: $count)';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label не участвовал в этом голосовании.';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label не вернул дополнительного текстового объяснения.';
  }

  @override
  String get reportEngineResolutionTransformer =>
      'Решение: загрузите и активируйте многоязычный Transformer в «Управление моделями»; если он уже загружен, загрузите модель и токенизатор повторно.';

  @override
  String get reportEngineResolutionAdversarial =>
      'Решение: повторно загрузите модель обнаружения перефразирования и токенизатор в «Управление моделями»; в веб-версии обновитесь до версии с исправлением совместимости BigInt и проанализируйте снова.';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason. Причина: веб-ONNX Runtime вернул тензор BigInt, который старый мост не смог преобразовать; обновитесь до исправленной версии и проанализируйте снова.';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason. Решение: переключитесь на модель из каталога или загрузите модель и токенизатор повторно.';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason. Решение: откройте «Управление моделями», нажмите «Дополнить рекомендуемые модели анализа» и убедитесь, что многоязычный Transformer отмечен как активный.';
  }

  @override
  String get reportDetailAnalysisTitle => 'Подробный анализ';

  @override
  String get reportNoEngineData => 'Данных анализа движков пока нет';

  @override
  String get reportEngineNotParticipated => 'Не участвовал';

  @override
  String get reportAiContentReportTitle => 'Отчёт об обнаружении ИИ-контента';

  @override
  String reportAnalysisTimeLabel(String time) {
    return 'Время анализа: $time';
  }

  @override
  String get reportDownloadPdfButton => 'Скачать PDF';

  @override
  String get reportSuspiciousLocationsTitle => 'Места подозрительного контента';

  @override
  String reportSentenceCount(int count) {
    return '$count предложений';
  }

  @override
  String get reportAiProbabilityPrefix => 'Вероятность ИИ: ';

  @override
  String get telemetrySummaryTitle => 'Что в итоге';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return 'Отработали $engines из $total движков. Общая вероятность ИИ — $percent%, это даёт «$verdict».';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return 'Движки в целом сходятся (максимум $high%, минимум $low%), так что вывод вполне надёжен.';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return 'Движки расходятся: $highLabel даёт $high%, а $lowLabel — всего $low%. В таком случае не опирайтесь на общий балл: разбор по предложениям ниже скажет намного больше.';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return 'Балл тянет вверх в основном $label — около $points процентных пунктов.';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return 'Из всех $total предложений ни одно не пересекло порог сильного ИИ-сигнала.';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return 'Из $total предложений $count пересекли порог сильного ИИ-сигнала — их стоит просмотреть по одному.';
  }

  @override
  String get telemetrySummaryAdviceHuman =>
      'Читается как написанное человеком; копать тут особо нечего.';

  @override
  String get telemetrySummaryAdviceMixed =>
      'Текст в серой зоне. Судить только по баллу рискованно — смотрите вместе с разбором по предложениям и тем, что знаете об источнике документа.';

  @override
  String get telemetrySummaryAdviceAi =>
      'Сигналы чётко указывают на генерацию или переписывание ИИ. Проверьте отмеченные предложения по одному, прежде чем решать.';

  @override
  String telemetrySummaryModelGap(int count) {
    return 'Кроме того, $count движок(ов) в этот раз не голосовали, так что уверенность стоит немного снизить. Дозагрузите их в управлении моделями и запустите заново — будет точнее.';
  }

  @override
  String get reportAiThresholdPrefix => 'Порог маркировки ИИ: ';

  @override
  String reportVerdictRangeBelow(int value) {
    return 'Вероятность ИИ ниже $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'Вероятность ИИ $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'Вероятность ИИ от $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return 'Низкая достоверность: доступный вес модели ниже 60% (порог $threshold%). Участвовало $available/$total движков. Ознакомьтесь с подробным анализом движков.';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return 'Высокая достоверность: $available/$total моделей обнаружения достигли консенсуса ($threshold% или больше веса согласны с этим вердиктом).';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return 'Низкая достоверность ($available/$total)';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return 'Высокая достоверность ($available/$total)';
  }

  @override
  String get reportMetricAiSentenceRatio =>
      'Доля предложений с сильным сигналом ИИ';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count из $total превысили порог сильного сигнала 60%';
  }

  @override
  String get reportMetricElapsed => 'Время анализа';

  @override
  String get reportMetricElapsedNormal => '0,5-5 с — норма';

  @override
  String get reportMetricReliability => 'Надёжность';

  @override
  String get reportReliabilityLow => 'Низкая';

  @override
  String get reportReliabilityHigh => 'Высокая';

  @override
  String get reportReliabilityNeedsReview => 'Требуется проверка';

  @override
  String get reportReliabilityHighTrust => 'Очень надёжно';

  @override
  String get reportSentenceAnalysisTitle => 'Анализ на уровне предложений';

  @override
  String get suspiciousFilterAll => 'Подозрительно';

  @override
  String get suspiciousFilterHigh => 'Высокий';

  @override
  String get suspiciousFilterMedium => 'Средний';

  @override
  String get suspiciousExcludedTooltip =>
      'Отдельные буквы, номера страниц, номера разделов и слишком короткие фрагменты OCR/PDF были исключены.';

  @override
  String suspiciousCount(int count) {
    return '$count элементов';
  }

  @override
  String get suspiciousEmpty => 'Подозрительный контент отсутствует';

  @override
  String get suspiciousRiskHigh => 'Высокий';

  @override
  String get suspiciousRiskMedium => 'Средний';

  @override
  String get suspiciousReasonHighModelSignals =>
      'Несколько сигналов моделей сильно склоняются к ИИ';

  @override
  String get suspiciousReasonSentenceSignal =>
      'Сигнал модели на уровне предложения повышен';

  @override
  String suspiciousOriginalLocation(String location) {
    return 'Исходное расположение $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return 'Исходное расположение $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return 'Предложение №$number';
  }

  @override
  String get suspiciousEvidenceLabel => 'Доказательство:';

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
      'Перепроверить все неподтверждённые цитаты';

  @override
  String get reportBibRecheckOneTooltip => 'Перепроверить эту цитату';

  @override
  String get reportBibResultHint =>
      'Сопоставлено с публичным реестром Crossref по сходству автора, года и названия. Не является абсолютной гарантией — при статусе «неопределённо» проверьте вручную.';

  @override
  String reportBibVerificationSource(String source) {
    return 'Источник проверки: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'Проверить вручную в Google Scholar';

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
    return 'Несоответствие названия журнала: в документе указано «$reported», а в проверенном реестре — «$registered». Пожалуйста, проверьте эту цитату.';
  }

  @override
  String get reportBibNotFound =>
      'Близкое совпадение не найдено — возможно, вымышленная ссылка';

  @override
  String get reportBibUncertain =>
      'Подозрительно: не подтверждено сопоставлением с реестром';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Проверены только первые $max записей (всего обнаружено $count)';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return 'Завершено $count; результаты будут продолжать обновляться.';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return 'Прогресс $completed/$total, $current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return 'Текущий: $text';
  }

  @override
  String get reportBibProgressFinalizing => 'Завершение результатов';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base: найден похожий кандидат «$candidate», но автор, год или название не достигли порога надёжного совпадения.';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base: источники проверки не дали надёжного ответа, или записи недостаточно информации; TruthLens не считает эту цитату подтверждённой.';
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
    return 'Общая вероятность ИИ составляет $aiPercent%, что достигает установленного вами порога маркировки ИИ $thresholdPercent%, поэтому отчёт помечает этот текст как ИИ. Перед принятием окончательного решения ознакомьтесь с доказательствами на уровне предложений и обоснованиями движков.';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'Общая вероятность ИИ составляет $aiPercent%, что ниже установленного вами порога маркировки ИИ $thresholdPercent%, поэтому отчёт официально не помечает этот текст как ИИ. Вероятность и доказательства по-прежнему отображаются для проверки.';
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
    return 'Общая статистическая сводка: склоняется к признакам, сгенерированным ИИ (вероятность ИИ $percent%)';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return 'Общая статистическая сводка: склоняется к естественному человеческому письму (вероятность ИИ $percent%)';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return 'Общая статистическая сводка: показатели уравновешивают друг друга, демонстрируя нейтральные признаки (вероятность ИИ $percent%)';
  }

  @override
  String get reportFormulaTitle =>
      'Прозрачность взвешенного расчёта и разбивка параметров';

  @override
  String get reportFormulaExplanation =>
      'Общая вероятность ИИ рассчитывается как взвешенное среднее вероятностей всех активных движков:';

  @override
  String get reportFormulaActiveEngines => 'Активные движки и назначенные веса';

  @override
  String get reportFormulaCalculation => 'Расчёт взвешенной формулы';

  @override
  String get reportFormulaFinalResult => 'Итоговая взвешенная вероятность ИИ';

  @override
  String get reportFormulaEslApplied =>
      'Применена корректировка для неносителей языка ESL (вес статистической модели уменьшен вдвое)';

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
  String get modelRepairNoActiveVariant =>
      'Активная модель не найдена; загрузите рекомендуемую модель в разделе «Управление моделями».';

  @override
  String get modelRepairCustomRemoved =>
      'Пользовательская модель, которую не удалось загрузить, была удалена. Пользовательские модели нельзя автоматически загрузить повторно; повторно импортируйте модель и токенизатор.';

  @override
  String get modelRepairNoSource =>
      'Файл модели, который не удалось загрузить, был удалён, но источник каталога для повторной загрузки в данный момент недоступен; повторно загрузите рекомендуемую модель в разделе «Управление моделями».';

  @override
  String modelRepairRedownloaded(Object name) {
    return 'Обнаружено, что файл модели может быть повреждён или несовместим; $name был автоматически загружен повторно. Пожалуйста, запустите анализ снова.';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return 'Файл модели, который не удалось загрузить, был удалён, но автоматическая повторная загрузка не завершилась; проверьте подключение к сети и повторно загрузите $name в разделе «Управление моделями».';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      'Активная модель Transformer не найдена; загрузите или активируйте её в разделе «Управление моделями»';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return 'Тип токенизатора активной модели не поддерживается ($tokenizer); переключитесь на модель с поддержкой bert-wordpiece или roberta-bpe';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Путь к модели Transformer или токенизатору отсутствует; загрузите повторно в разделе «Управление моделями»';

  @override
  String get engineTransformerMissingFiles =>
      'Файл модели Transformer или токенизатора не существует; загрузите повторно в разделе «Управление моделями»';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'Версия ONNX opset не поддерживается (эта версия модели слишком новая; обновите приложение): $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Формат токенизатора повреждён: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      'Не удалось загрузить модель или выполнить вывод, автоматическое восстановление не завершилось; повторно загрузите активную модель Transformer и токенизатор в разделе «Управление моделями».';

  @override
  String get engineAdversarialNoActiveVariant =>
      'Активная модель обнаружения перефразирования не найдена';

  @override
  String get engineAdversarialMissingFiles =>
      'Файл модели или токенизатора не существует; загрузите повторно в разделе «Управление моделями»';

  @override
  String get engineAdversarialRepairFailed =>
      'Не удалось загрузить модель или выполнить вывод, автоматическое восстановление не завершилось; повторно загрузите модель обнаружения перефразирования и токенизатор в разделе «Управление моделями».';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return 'Модель не участвовала в этом голосовании. $error';
  }

  @override
  String get patternNotAnalyzable =>
      'Фрагмент слишком короткий или похож на шум PDF/OCR; оценка ИИ на уровне предложения не выполнялась';

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
      'Три способа ввода: прямая вставка текста, OCR изображения (распознаётся на устройстве с нативными фреймворками каждой платформы) или импорт файла (txt / md / pdf / docx / doc / odt). Текст должен содержать не менее 40 символов для отправки на анализ.';

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
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

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
  String get helpWorkflowStep4ChipStoppable =>
      'Можно остановить в любой момент';

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
  String get privacyWebOverview1 =>
      'TruthLens полностью работает как веб-приложение во вкладке вашего браузера. Ничего не нужно устанавливать; текст документа и результаты анализа никогда не покидают ваше устройство, а загруженные модели обнаружения кэшируются только в собственном изолированном хранилище браузера (OPFS), а не на сервере.';

  @override
  String get privacyWebOverview2 =>
      'Страница читает файл, изображение или содержимое буфера обмена только тогда, когда вы активно выбираете импорт, сканирование или вставку; она никогда не читает другие вкладки, данные других сайтов или невыбранные файлы.';

  @override
  String get privacySectionOverviewWeb => 'Обзор';

  @override
  String get privacyRemoveWeb =>
      'очистив данные этого сайта в настройках браузера (или просто закрыв вкладку, поскольку на сервере ничего не хранится)';

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
      '4. Резервный веб-OCR: только в веб-версии OCR сначала использует локальный сервер OCR, если он настроен. Если вы решите ввести ключ API Gemini, выбранные изображения и отрисованные страницы PDF, требующие OCR, отправляются напрямую из вашего браузера в API Gemini Google; ключ хранится только в локальном хранилище этого браузера.';

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
  String get workspaceModeCosmicFuture => 'Космическое будущее';

  @override
  String get workspaceModeSoftEducation => 'Мягкое образование';

  @override
  String get workspaceModeTooltip => 'Сменить режим рабочего пространства';

  @override
  String get workspaceMoreMenuTooltip => 'Дополнительные параметры';

  @override
  String get workspaceLanguageMenuTitle => 'Язык';

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
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return 'Шаг $current/$total · $stage';
  }

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
  String get workspaceStopAnalysis => 'Остановить анализ';

  @override
  String get workspaceStopAnalysisTitle => 'Остановить текущий анализ?';

  @override
  String get workspaceStopAnalysisBody =>
      'Анализ всё ещё выполняется. Текст документа сохранится, но незавершённые результаты не будут записаны.';

  @override
  String get workspaceAnalysisStopped =>
      'Анализ остановлен. Текст документа остался в рабочем пространстве.';

  @override
  String get workspaceSelectedEvidence => 'Выбранное доказательство';

  @override
  String get workspaceNoEvidence =>
      'Доказательства по предложениям появятся после завершения модулей.';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return 'Предварительная вероятность ИИ: $percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      'Этот процент — собственный сигнал ИИ данного предложения, а не общий вердикт по документу. Чем выше значение, тем больше формулировка похожа на сгенерированную ИИ; чем ниже — тем больше она напоминает типичное человеческое письмо. Итоговый отчёт объединяет все предложения с учётом весов движков.';

  @override
  String get workspaceSentenceSignalHeader => 'Сигнал ИИ по предложению';

  @override
  String get workspaceSentenceColumnHeader => 'Предложение';
}
