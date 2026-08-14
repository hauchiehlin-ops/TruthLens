// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get commonCancel => '취소';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonClose => '닫기';

  @override
  String get verdictHuman => '사람이 작성함';

  @override
  String get verdictLikelyHuman => '사람일 가능성 높음';

  @override
  String get verdictMixed => '혼합 콘텐츠';

  @override
  String get verdictLikelyAi => 'AI일 가능성 높음';

  @override
  String get verdictAi => 'AI 생성';

  @override
  String get inputSubtitle => '텍스트를 붙여넣거나 입력하여 AI 생성 콘텐츠를 감지하세요';

  @override
  String get inputHint => '분석할 텍스트를 입력하거나 붙여넣으세요…';

  @override
  String get inputHistoryTooltip => '기록';

  @override
  String get inputHelpTooltip => '사용 안내';

  @override
  String get inputPrivacyTooltip => '개인정보처리방침';

  @override
  String get inputSettingsTooltip => '설정';

  @override
  String get inputPasteButton => '붙여넣기';

  @override
  String get inputOcrButton => '이미지 OCR';

  @override
  String get inputImportButton => '파일 가져오기';

  @override
  String get inputStartButton => '검사 시작';

  @override
  String get inputClearTooltip => '내용 지우기';

  @override
  String get inputTooShortSnackbar => '신뢰할 수 있는 분석을 위해 40자 이상 입력해 주세요';

  @override
  String get inputOcrUnsupported => '이 플랫폼에서는 OCR 텍스트 인식이 지원되지 않습니다';

  @override
  String get inputOcrRecognizing => '인식 중…';

  @override
  String get inputOcrNoText => '이미지에서 텍스트를 인식하지 못했습니다';

  @override
  String inputOcrRecognized(int count) {
    return '$count자를 인식했습니다';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\"에 읽을 수 있는 텍스트 내용이 없습니다';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '\"$fileName\"을(를) 가져왔습니다（$count자）';
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
    return '모델: $modelId';
  }

  @override
  String get inputNoModel => '설치된 모델 없음（통계/문체 분석만 가능）';

  @override
  String inputCharCount(int count) {
    return '$count자';
  }

  @override
  String get analysisAppBarTitle => '분석 중';

  @override
  String get analysisEngineTransformer => 'Transformer 분류기';

  @override
  String get analysisEngineStatistical => '통계적 특징 분석';

  @override
  String get analysisEngineStylometry => '문체 특징 분석';

  @override
  String get analysisEngineAdversarial => '적대적 방어';

  @override
  String analysisProgressSemantics(int done, int total) {
    return '분석 진행 중, $total개 엔진 중 $done개 완료';
  }

  @override
  String get analysisDoneSemantics => '완료됨';

  @override
  String analysisPreliminaryResult(int percent) {
    return 'Preliminary result: AI probability $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return 'Preliminary result: AI probability $percent% (refining…)';
  }

  @override
  String get engineNameAdversarialFull => '적대적 방어（패러프레이즈 감지）';

  @override
  String get modelNecessityText =>
      '신경망 감지 모델을 다운로드하지 않아도 TruthLens는 작동하지만, 통계 및 문체 분석만 사용하여 정확도와 다국어 지원이 제한됩니다. 모델을 다운로드하면 다국어 Transformer 분류기가 앙상블 투표에 추가되어 판정 정확도와 신뢰도가 크게 향상됩니다. 모델은 기기 내에서 실행되며, 다운로드 후에는 어떤 콘텐츠도 업로드하지 않습니다.';

  @override
  String get modelPromptTitle => '완전한 분석을 위해 감지 모델 다운로드를 권장합니다';

  @override
  String get modelPromptDontRemind => '다시 알리지 않기';

  @override
  String get modelPromptSkip => '나중에 하기';

  @override
  String get modelPromptDownload => '다운로드로 이동';

  @override
  String get onboardingWelcomeTitle => 'TruthLens에 오신 것을 환영합니다';

  @override
  String get onboardingHeadline => '기기 내 AI 콘텐츠 감지';

  @override
  String get onboardingDetectedDevice => '감지된 기기';

  @override
  String get onboardingChooseModel => '다운로드할 모델 선택';

  @override
  String get onboardingRecommendHint =>
      '사용 중인 하드웨어에 따라 \"추천\"이 표시됩니다. 다른 옵션도 직접 선택할 수 있습니다.';

  @override
  String get onboardingSkipButton => '나중에 결정（모델 없이 통계/문체 분석만 사용）';

  @override
  String get onboardingSkipHint =>
      '건너뛰어도 언제든지 \"설정 → AI 모델 관리\"에서 다운로드할 수 있습니다. 모델이 필요한 분석을 사용할 때 다시 안내해 드립니다.';

  @override
  String get modelListCustomImportedLabel => '사용자 지정으로 가져온 모델:';

  @override
  String get modelListActiveChip => '사용 중';

  @override
  String get modelListRecommendedChip => '추천';

  @override
  String get modelListCustomChip => '사용자 지정';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · 필요 RAM ${ram}GB · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return '크기: $size · Tokenizer: $tokenizer · AI 라벨 인덱스: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return '다운로드 중… $percent%（$downloaded / $total）';
  }

  @override
  String modelListDownloadButton(String size) {
    return '다운로드（$size）';
  }

  @override
  String get modelListComingSoonChip => '출시 예정';

  @override
  String get modelListSetActiveButton => '사용 중으로 설정';

  @override
  String get modelListUpdateButton => '업데이트';

  @override
  String get modelListDeleteTooltip => '삭제';

  @override
  String get modelListPageButton => '모델 페이지';

  @override
  String get modelListMayExceedMemory => '기기 메모리를 초과할 수 있습니다';

  @override
  String modelListFailedPrefix(String error) {
    return '실패: $error';
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
  String get modelListDeleteConfirmTitle => '모델을 삭제하시겠습니까?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return '\"$name\"（$size）을(를) 삭제합니다. 다시 사용하려면 재다운로드가 필요합니다.';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return '사용자 지정으로 가져온 \"$name\"（$size）을(를) 삭제합니다. 다시 사용하려면 재가져오기가 필요합니다.';
  }

  @override
  String get modelImportAppBarTitle => '사용자 지정 ONNX 모델 가져오기';

  @override
  String get modelImportStep1Title => '1. ONNX 모델 파일 선택';

  @override
  String modelImportSelectedFile(String name) {
    return '선택됨: $name';
  }

  @override
  String get modelImportNoFileSelected => '선택된 모델 파일 없음 (.onnx)';

  @override
  String get modelImportBrowseButton => '찾아보기';

  @override
  String get modelImportCheckingDuplicate => '동일한 파일이 이미 가져와졌는지 확인 중…';

  @override
  String get modelImportDuplicateTitle => '동일한 내용의 모델이 이미 가져와져 있습니다';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return '이 파일은 \"$name\"（역할: $role）과 내용이 완전히 동일합니다. 사용 중인 모델을 전환하려는 것뿐이라면 \"AI 모델 관리\"에서 바로 \"사용 중으로 설정\"할 수 있으며, 다시 가져올 필요가 없습니다. 아래 단계를 계속 진행할 수도 있습니다.';
  }

  @override
  String get modelImportStep2Title => '2. 매개변수 설정';

  @override
  String get modelImportNameLabel => '모델 표시 이름';

  @override
  String get modelImportNameRequired => '이름을 비워둘 수 없습니다';

  @override
  String get modelImportRoleLabel => '대상 엔진 역할';

  @override
  String get modelImportTokenizerTypeLabel => 'Tokenizer 유형';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => '없음（Tokenizer 없음/문자 단위）';

  @override
  String get modelImportNoTokenizerSelected => '선택된 Tokenizer 파일 없음 (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return '선택됨: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'AI 라벨 출력 인덱스';

  @override
  String get modelImportIndex0 => '인덱스 0（예: RoBERTa）';

  @override
  String get modelImportIndex1 => '인덱스 1（예: DistilBERT）';

  @override
  String get modelImportStep3Title => '3. 테스트 및 검증';

  @override
  String get modelImportTestInputLabel => '테스트 입력 텍스트';

  @override
  String get modelImportRunTestButton => '테스트 추론 실행';

  @override
  String get modelImportResultLabel => '추론 결과（AI 확률）:';

  @override
  String modelImportTestFailed(String error) {
    return '테스트 실패: $error';
  }

  @override
  String get modelImportConfirmButton => '가져오기 확인 및 모델 활성화';

  @override
  String get modelImportSelectTokenizerFirst => '먼저 Tokenizer 파일을 선택해 주세요';

  @override
  String get modelImportSelectTokenizer => 'Tokenizer 파일을 선택해 주세요';

  @override
  String get modelImportSuccessSnackbar =>
      '모델을 성공적으로 가져왔으며 사용 중인 모델로 자동 설정되었습니다!';

  @override
  String get modelImportFailedSnackbar => '모델 가져오기에 실패했습니다. 권한 또는 로그를 확인해 주세요';

  @override
  String get settingsAppBarTitle => '설정';

  @override
  String get settingsThresholdTitle => 'AI 판정 신뢰도 임계값';

  @override
  String get settingsThresholdInfoTooltip =>
      'How the AI flagging threshold affects the conclusion';

  @override
  String get settingsThresholdInfoBody =>
      'The enabled engines first calculate the overall AI probability. This setting does not change any engine score or that overall probability; it changes which conclusion is applied to the score. A lower threshold makes the same probability more likely to be concluded and marked as AI, while a higher threshold requires stronger AI probability and is more likely to conclude human writing. The report always retains the original probability and supporting evidence.';

  @override
  String settingsThresholdSubtitle(int percent) {
    return '현재: $percent% — 높이면 오탐（사람 글을 AI로 오판）을 줄일 수 있습니다';
  }

  @override
  String get settingsEslTitle => 'ESL（비원어민） 편향 보정';

  @override
  String get settingsEslSubtitle => '비원어민 문체가 감지되면 통계 모델의 가중치를 자동으로 낮춥니다';

  @override
  String get settingsEngineSectionTitle => '하위 감지 엔진 설정（앙상블）';

  @override
  String get settingsEngineTransformerTitle => '다국어 AI 분류기（Transformer）';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Transformer 신경망 모델을 사용하여 기기 내 AI 확률 예측을 수행합니다';

  @override
  String get settingsEngineStatisticalTitle => '통계 분석 엔진（Statistical）';

  @override
  String get settingsEngineStatisticalSubtitle =>
      '문장 길이 변동성, Burstiness, PPL을 통해 언어의 규칙성을 판정합니다';

  @override
  String get settingsEngineStylometryTitle => '문체 특징 분석（Stylometry）';

  @override
  String get settingsEngineStylometrySubtitle =>
      '의미적 유창성, 반복 문형, 접속어 사용 등 문체적 특징을 분석합니다';

  @override
  String get settingsEngineAdversarialTitle => '적대적 패러프레이즈 감지（Adversarial）';

  @override
  String get settingsEngineAdversarialSubtitle =>
      '기계에 의한 패러프레이징 또는 AI 흔적 제거 처리 여부를 감지합니다';

  @override
  String get settingsEngineWeightsTitle => 'AI 모델 가중치';

  @override
  String get settingsEngineWeightsSubtitle =>
      '각 엔진이 종합 결과에 미치는 영향을 설정합니다. 저장하려면 합계가 100%여야 합니다.';

  @override
  String get settingsEngineInfoTooltip => '이 엔진의 기능';

  @override
  String get settingsEngineTransformerHelp =>
      '다국어 Transformer로 완전한 문장을 평가합니다. 설정 가중치는 영향도를, AI 신호는 실제 기여도를 결정합니다.';

  @override
  String get settingsEngineStatisticalHelp =>
      '당혹도, 예측 가능성, 버스트성, 문장 길이 변화를 측정합니다. ESL 보정 시 유효 가중치가 낮아질 수 있습니다.';

  @override
  String get settingsEngineStylometryHelp =>
      '반복되는 문장 시작, 정형화된 전환어, 과도한 목록 등 설명 가능한 문체 특징을 검사합니다. 특징이 없으면 신호는 0%입니다.';

  @override
  String get settingsEngineAdversarialHelp =>
      '패러프레이징되거나 AI 흔적이 제거된 텍스트를 찾습니다. 낮은 점수는 약한 잔여 증거일 뿐 양성 판정이 아닙니다.';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return '합계: $total% — 저장 가능';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return '합계: $total% — 정확히 100%로 조정하세요';
  }

  @override
  String get settingsEngineWeightsSave => '가중치 저장';

  @override
  String get settingsEngineWeightsSaved => 'AI 모델 가중치를 이 기기에 저장했습니다';

  @override
  String get settingsEngineWeightsRestoreDefaults => '기본값 복원';

  @override
  String get engineReasonDisabledByUser => '사용자가 설정에서 이 엔진을 비활성화했습니다';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model: $total개 문장 중 강한 AI 임계값을 넘은 문장이 없습니다. 보정된 약한 신호는 $percent%입니다';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'AI 신호 $percent%';
  }

  @override
  String get reportEngineSignalExplanation =>
      'AI 신호는 이 문서에 대한 각 엔진의 확률입니다. 설정한 가중치가 영향도를 결정하며, 표시된 기여 점수의 합이 전체 AI 확률과 정확히 일치하도록 배분됩니다. ‘감지되지 않음’은 강한 신호 기준인 60% 미만이라는 뜻이며 반드시 0이라는 뜻은 아닙니다.';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return '$total개 문장 모두 강한 바꿔쓰기 신호 기준을 넘지 않았습니다. 보정된 약한 신호는 $percent%입니다';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$total개 문장 중 $count개가 강한 바꿔쓰기 신호 기준을 넘었습니다. 보정된 문서 신호는 $percent%입니다';
  }

  @override
  String get settingsLinkVerificationTitle => '하이퍼링크 및 참고 문헌 실재성 검증';

  @override
  String get settingsBibliographyIndexesTitle => 'Bibliography index sources';

  @override
  String get settingsBibliographyIndexesSubtitle =>
      'Public sources are automatic; add licensed Web of Science SCI/SSCI or Engineering Village EI access';

  @override
  String get settingsBibliographyCredentialsTitle =>
      'Bibliography index sources';

  @override
  String get settingsBibliographyCredentialsDescription =>
      'Public Crossref, OpenAlex, DataCite, Semantic Scholar, Europe PMC, ERIC, and Taiwan NCL sources require no key. SCI/SSCI and EI searches run only when you provide credentials authorized by their providers. Missing or rejected credentials are never treated as evidence that a citation does not exist.';

  @override
  String get settingsTaiwanIndexTitle => 'Taiwan NCL / TCI-HSS assistance';

  @override
  String get settingsTaiwanIndexSubtitle =>
      'Automatically searches the National Central Library Taiwan Periodical Literature source; former TSSCI/THCI records are consolidated in TCI-HSS.';

  @override
  String get settingsWosApiKeyTitle => 'Web of Science SCI / SSCI';

  @override
  String get settingsWosApiKeyDescription =>
      'Enter a Clarivate Web of Science Starter API key. Clarivate offers a limited free plan; higher quotas depend on institutional access.';

  @override
  String get settingsWosFreePlanButton => 'Get free 50/day plan';

  @override
  String get settingsEiApiKeyTitle => 'Engineering Village EI Compendex';

  @override
  String get settingsEiApiKeyDescription =>
      'Enter an Elsevier API key enabled for Engineering Village. Full EI access requires an eligible institutional subscription.';

  @override
  String get settingsEiInstitutionTokenLabel =>
      'Elsevier institution token (optional)';

  @override
  String get settingsEiInstitutionTokenHelper =>
      'Use only when supplied by your institution or Elsevier.';

  @override
  String get settingsGetApiKeyButton => 'Provider site';

  @override
  String get settingsSaveBibliographyCredentialsButton =>
      'Save index credentials';

  @override
  String get settingsBibliographyCredentialsSaved =>
      'Bibliography index credentials saved on this device';

  @override
  String get settingsLinkVerificationSubtitle =>
      '리포트는 문서에서 감지된 URL과 참고 문헌 항목이 실제로 존재하는지 확인하기 위해 연결됩니다（AI 생성 콘텐츠에는 그럴듯하지만 실제로는 존재하지 않는 인용이 흔히 포함됩니다）. DOI 형식의 학술 링크와 링크가 없는 \"저자—연도\" 형식의 참고 문헌 모두 Crossref 공개 등록 데이터와 대조됩니다. 핵심 AI 감지 모델은 여전히 완전히 기기 내에서 실행되며 문서 내용을 전송하지 않습니다. 연결은 이 검증과 모델 업데이트 확인에만 사용되며 여기서 끌 수 있습니다.';

  @override
  String get settingsThemeTitle => '화면 테마';

  @override
  String get settingsLanguageTitle => '언어';

  @override
  String get settingsLanguageSubtitle => '앱 표시 언어 선택';

  @override
  String get settingsModelManagementTitle => 'AI 모델 관리';

  @override
  String get settingsModelManagementSubtitle =>
      '감지 모델과 리포트 작성용 LLM을 다운로드하여 완전한 추론 기능을 활성화합니다';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      '모델 업데이트가 감지되었습니다. 확인해 보세요';

  @override
  String get settingsOpenButton => '열기';

  @override
  String get settingsCustomImportTitle => '사용자 지정 ONNX 모델 가져오기 및 테스트';

  @override
  String get settingsCustomImportSubtitle =>
      '로컬의 사용자 지정 ONNX 모델과 Tokenizer 설정을 가져와 추론 테스트를 실행합니다';

  @override
  String get modelImportWebUnsupported =>
      'Custom model import is not supported on the web version yet. Please use the app version.';

  @override
  String get settingsLanguagePackTitle => '언어 팩';

  @override
  String get settingsLanguagePackSubtitle => '추가 언어 미세 조정 모델（4단계에서 제공 예정）';

  @override
  String get settingsModelManagerAppBarTitle => 'AI 모델 관리';

  @override
  String get settingsImportTooltip => '로컬 ONNX 모델 가져오기';

  @override
  String settingsDeviceLabel(String summary) {
    return '기기: $summary';
  }

  @override
  String get historyAppBarTitle => '기록';

  @override
  String get historyClearAllTooltip => '전체 지우기';

  @override
  String get historySearchHint => '기록 검색…';

  @override
  String get historyDeletedSnackbar => '해당 기록을 삭제했습니다';

  @override
  String get historyClearAllTitle => '모든 기록을 지우시겠습니까?';

  @override
  String historyClearAllBody(int count) {
    return '전체 $count개의 기록을 삭제합니다. 이 작업은 되돌릴 수 없습니다.';
  }

  @override
  String get historyClearButton => '지우기';

  @override
  String get historyDeleteEntryTitle => '이 기록을 삭제하시겠습니까?';

  @override
  String get historyReanalyzeTooltip => '다시 분석';

  @override
  String get historyEmptyDefault => '아직 감지 기록이 없습니다';

  @override
  String historyEmptySearch(String query) {
    return '\"$query\"와 일치하는 기록이 없습니다';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, AI 확률 $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => '감지 리포트';

  @override
  String get reportExportTooltip => '리포트 내보내기';

  @override
  String get reportHomeTooltip => '홈으로 돌아가기';

  @override
  String get reportGeneratingTitle => '리포트 생성 중…';

  @override
  String get reportSourceLlm => 'AI 생성 리포트';

  @override
  String get reportSourceTemplate => '템플릿 생성 리포트';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '총 $total문장 · AI 의심 $ai문장 · 사람 $human문장 · 소요 시간 $seconds초';
  }

  @override
  String get reportExportPdf => 'PDF 리포트 내보내기';

  @override
  String get reportExportCsv => 'CSV 데이터 내보내기';

  @override
  String get reportExportJson => 'JSON 내보내기（시스템 연동）';

  @override
  String get reportExportPng => '요약 카드 내보내기（PNG）';

  @override
  String reportExported(String path) {
    return '내보내기 완료: $path';
  }

  @override
  String reportExportFailed(String error) {
    return '내보내기 실패: $error';
  }

  @override
  String get reportEngineWeightLabel => '가중치';

  @override
  String get privacySealNoticeText =>
      'TruthLens 제로 클라우드 개인정보 보호 인증: 100% 기기 내에서 연산되며 클라우드 데이터베이스에 저장되지 않습니다.';

  @override
  String get reportModelCalibrationTitle => '모델 벤치마크 자동 보정';

  @override
  String get reportCommunityDiscoveredTag => '커뮤니티 모델 (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => '엔진 세부 정보';

  @override
  String get reportEngineNotInstalled => '설치되지 않음';

  @override
  String get reportEngineLoadFailedBadge => '로드 실패';

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
  String get reportMetricAiSentenceRatio => '강한 AI 신호 문장 비율';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$total개 문장 중 $count개가 60% 강한 신호 기준을 넘었습니다';
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
  String get reportSentenceAnalysisTitle => '문장 단위 분석';

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
    return '$text. AI 확률 $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => '하이퍼링크 실재성';

  @override
  String get reportLinkNoneDetected => '문서에서 하이퍼링크가 감지되지 않았습니다.';

  @override
  String get reportLinkCheckingProgress => '링크 검증 중…';

  @override
  String reportLinkDetectedPending(int count) {
    return '$count개의 하이퍼링크가 감지되었으며 아직 검증되지 않았습니다';
  }

  @override
  String get reportLinkDisabledHint =>
      'AI 생성 콘텐츠에는 그럴듯하지만 실제로는 존재하지 않는 인용 링크가 흔히 포함됩니다. \"설정\"에서 하이퍼링크 검증을 껐습니다. 다시 켜면 자동으로 검증되며, 아래 버튼으로 한 번만 검증할 수도 있습니다.';

  @override
  String get reportVerifyNowButton => '지금 검증（네트워크 필요）';

  @override
  String get reportLinkReachable => '연결 가능, URL이 존재합니다';

  @override
  String get reportLinkNotFound => 'URL이 존재하지 않습니다（404）. 허위 인용일 가능성이 있습니다';

  @override
  String get reportLinkUnreachable => '확인할 수 없습니다（시간 초과 또는 서버 응답 없음）';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return '저널 등록 확인: $journal에 등록됨$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      '일치하는 DOI 등록을 찾을 수 없습니다. 허위 인용일 가능성이 있습니다';

  @override
  String get reportLinkCitationUnreachable =>
      '확인할 수 없습니다（시간 초과 또는 Crossref 응답 없음）';

  @override
  String reportLinkTruncated(int max, int count) {
    return '처음 $max개의 링크만 검증했습니다（총 감지된 링크 $count개）';
  }

  @override
  String get reportBibAuthenticityTitle => '인용 문헌 실재성';

  @override
  String get reportBibNoneDetected => '문서에서 참고 문헌 항목이 감지되지 않았습니다.';

  @override
  String get reportBibCheckingProgress => '참고 문헌 목록 검증 중…';

  @override
  String reportBibDetectedPending(int count) {
    return '참고 문헌 목록（$count개 항목）이 감지되었으며 아직 검증되지 않았습니다';
  }

  @override
  String get reportBibDisabledHint =>
      'AI 생성 콘텐츠에는 그럴듯하지만 실제로는 존재하지 않는 참고 문헌이 흔히 포함됩니다. \"설정\"에서 하이퍼링크 검증을 껐습니다. 다시 켜면 자동으로 검증되며, 아래 버튼으로 한 번만 검증할 수도 있습니다.';

  @override
  String get reportVerifyNowBibButton => '지금 검증（네트워크 필요）';

  @override
  String get reportBibRecheckAllUnreliableButton =>
      'Recheck all unverified citations';

  @override
  String get reportBibRecheckOneTooltip => 'Recheck this citation';

  @override
  String get reportBibResultHint =>
      '저자, 연도, 제목 유사도를 Crossref 공개 등록 데이터와 대조합니다. 절대적인 보장은 아니며, \"불확실\"할 경우 직접 확인하는 것을 권장합니다.';

  @override
  String reportBibHighConfidence(String journal) {
    return '높은 신뢰도: 존재할 가능성이 높음$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（$journal에 등록됨）';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'Journal name mismatch: the document says “$reported”, while the verified registry says “$registered”. Please review this citation.';
  }

  @override
  String get reportBibNotFound => '유사한 항목을 찾을 수 없습니다. 허위 참고 문헌일 가능성이 있습니다';

  @override
  String get reportBibUncertain => 'Suspect: not verified by registry match';

  @override
  String reportBibTruncated(int max, int count) {
    return '처음 $max개 항목만 검증했습니다（총 감지된 항목 $count개）';
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
  String get reportNetworkWarningTitle => '네트워크 연결 상태가 좋지 않습니다';

  @override
  String get reportNetworkWarningBody =>
      '이 앱은 실행 시 기본적으로 네트워크 연결이 있다고 가정합니다. 하이퍼링크 및 인용 문헌 실재성 분석은 결과를 판정하기 위해 네트워크 연결이 필요합니다. 현재 연결할 수 없습니다. 네트워크 상태를 확인한 후 다시 시도해 주세요.';

  @override
  String get reportRetryConnectionButton => '연결 다시 확인';

  @override
  String get reportAiProbabilityLabel => 'AI 확률';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '총 $total문장\nAI 의심 $ai문장\n사람 $human문장';
  }

  @override
  String get summaryCardFooter => '핵심 AI 추론은 모두 기기 내에서 실행됩니다';

  @override
  String get exportReportTitle => 'TruthLens 감지 리포트';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · $total페이지 중 $page페이지';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return '분석 시간: $datetime · 소요 시간 $seconds초';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return '종합 판정: $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => '（ESL 보정 적용됨）';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '총 $total문장 · AI 의심 $ai문장 · 사람 $human문장';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'PDF 가독성을 유지하기 위해 처음 $max문장만 표시됩니다（총 $count문장）. 전체 데이터가 필요하면 \"$csvLabel\" 또는 \"$jsonLabel\"을 이용해 주세요.';
  }

  @override
  String get pdfSentenceColumnHeader => '문장（일치한 패턴 포함）';

  @override
  String composerHeadlineAi(int percent) {
    return '이 텍스트는 AI가 생성했을 가능성이 매우 높습니다（AI 확률 $percent%）';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return '이 텍스트는 AI 생성 경향이 있으며 추가 검토를 권장합니다（AI 확률 $percent%）';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return '이 텍스트는 사람과 AI가 혼합된 특징을 보입니다（AI 확률 $percent%）';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return '이 텍스트는 사람이 작성한 경향이 있습니다（AI 확률 $percent%）';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return '이 텍스트는 사람이 작성했을 가능성이 매우 높습니다（AI 확률 $percent%）';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return '종합 AI 확률이 설정한 $percent% 임계값을 초과하여 AI로 표시되었습니다.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '종합 AI 확률이 설정한 $percent% 표시 임계값 미만입니다.';
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
  String get composerNarrativeTitle => '분석 해석';

  @override
  String get composerParaphraseTitle => '패러프레이즈 흔적 감지됨';

  @override
  String get composerParaphraseBody =>
      '이 텍스트는 감지를 회피하기 위해 패러프레이징 도구（QuillBot, Undetectable.ai 등）로 처리되었을 수 있습니다. 문장 단위로는 자연스럽게 읽히더라도 전체 통계적 특징은 순수한 사람의 글과 다릅니다. 특히 주의해 주세요.';

  @override
  String get composerPatternListTitle => '주요 AI 문체 패턴';

  @override
  String get composerEslTitle => 'ESL（비원어민） 편향 보정';

  @override
  String get composerEslBody =>
      '이 텍스트는 비원어민 작성자가 썼을 수 있습니다. 비원어민에게 흔한 낮은 혼란도와 규칙적인 문형은 그 자체로 AI의 특징이 아니므로, 시스템이 오판을 방지하기 위해 통계 모델의 가중치를 낮췄습니다.';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return '본문은 총 $total문장으로, 이 중 $ai문장이 강한 AI 특징을 보이고 $human문장이 사람이 작성한 경향을 보입니다.';
  }

  @override
  String get composerNarrativeAiPattern =>
      '대부분의 문장이 문장 길이 리듬, 단어 선택, 접속어 사용에서 매우 규칙적이며, 이는 AI 생성 텍스트의 일반적인 특징입니다.';

  @override
  String get composerNarrativeMixedPattern =>
      '텍스트에는 규칙적인 부분과 자연스럽게 변화하는 부분이 공존하여, 사람의 초안을 AI가 다듬었거나 사람과 AI의 협업일 가능성을 보여줍니다.';

  @override
  String get composerNarrativeHumanPattern =>
      '문장 길이와 단어 선택에서 자연스러운 변화와 개인적 스타일이 나타나며, 뚜렷한 AI의 규칙성은 보이지 않습니다.';

  @override
  String engineReasonPplLow(String ppl) {
    return '언어 모델 혼란도가 낮아（$ppl）텍스트의 예측 가능성이 높으며, 이는 AI 생성의 지표입니다';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return '언어 모델 혼란도가 높아（$ppl）사람의 글이 지닌 예측 불가능성과 일치합니다';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return '언어 모델 혼란도가 중간 수준입니다（$ppl）';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return '문장 길이가 매우 일정하며（burstiness $value）일정한 리듬은 AI 생성 텍스트의 전형적인 통계적 특징입니다';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return '문장 길이에 뚜렷한 변화가 있으며（burstiness $value）사람의 자연스러운 문장 리듬 변화와 일치합니다';
  }

  @override
  String engineReasonTtrLow(String value) {
    return '어휘 다양성이 낮고（TTR $value）단어 반복도가 높습니다';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return '어휘 다양성이 높습니다（TTR $value）';
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
  String get engineReasonNeutral => '통계적 지표에서 뚜렷한 경향이 나타나지 않아 중립적인 판정을 유지합니다';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return '일반적인 접속어（$words）의 사용 빈도가 높으며, 문장당 평균 $density회로 사람의 글에서는 이렇게 밀집되는 경우가 드뭅니다';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return '여러 인접 문장이 같은 단어로 시작하며（$count곳）문형이 반복됩니다';
  }

  @override
  String get engineReasonNoStyleMarkers => '뚜렷한 AI 문체 패턴이 감지되지 않았습니다';

  @override
  String get engineReasonAdversarialNotInstalled =>
      '패러프레이즈 감지 모델이 설치되지 않아 이번 투표에 참여하지 않았습니다';

  @override
  String get engineReasonTransformerNotInstalled =>
      '모델이 설치되지 않았거나 사용 중인 모델이 지원되지 않아 이번 투표에 참여하지 않았습니다';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return '모델 로드에 실패하여 이번 투표에 참여하지 않았습니다（$error）';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model이(가) 총 $total문장 중 $aiCount문장에서 AI 특징을 보인다고 판정했습니다';
  }

  @override
  String get engineReasonAdversarialDetected =>
      '적대적 모델이 패러프레이징 도구（QuillBot / Undetectable.ai 등）로 처리된 것으로 의심되는 AI 흔적을 감지했습니다';

  @override
  String get engineReasonAdversarialClean => '뚜렷한 패러프레이즈 회피 흔적이 감지되지 않았습니다';

  @override
  String get engineReasonGenericNotInstalled => '모델이 설치되지 않아 이번 투표에 참여하지 않았습니다';

  @override
  String patternGenericTransition(String word) {
    return '일반적인 접속어 \"$word\"';
  }

  @override
  String get helpAppBarTitle => '사용 안내';

  @override
  String get helpAboutTitle => 'TruthLens 소개';

  @override
  String get helpAboutBody =>
      'TruthLens는 핵심 AI 추론이 완전히 기기 내에서 실행되는 크로스 플랫폼 콘텐츠 감지 앱입니다（iOS / Android / macOS / Windows）. Transformer 신경망 분류기, 통계적 특징 분석, 문체 특징 분석, 적대적 패러프레이즈 감지라는 4개의 독립적인 하위 모델이 가중 투표를 통해 텍스트가 AI로 생성되었는지 판정하며, 문장 단위로 설명 가능한 분석 근거를 제공합니다. 단순히 \"AI 같음\" 백분율만 제시하는 것이 아니라 \"왜\" 그런지 설명합니다.';

  @override
  String get helpComparisonTitle => '주요 도구와의 비교';

  @override
  String get helpComparisonDisclaimer =>
      '아래 비교는 각 도구의 공개 정보와 일반적인 시장 인식을 바탕으로 정리한 것으로, 기능적 포지셔닝 참고용일 뿐이며 제3자가 인증한 성능 벤치마크 데이터가 아닙니다.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero의 연산은 주로 클라우드에서 이루어지며 문서를 업로드해야 합니다. TruthLens의 4개 감지 엔진은 모두 기기 내에서 실행됩니다.';

  @override
  String get helpVsGptZero2 =>
      'GPTZero가 선구적으로 도입한 Perplexity／Burstiness 지표와 문장 단위 하이라이트를 TruthLens도 채택했으며, 여기에 Transformer 분류기, 문체 특징 분석, 적대적 방어를 더해 단일 지표가 아닌 4개 모델의 앙상블 투표를 구성합니다.';

  @override
  String get helpVsGptZero3 =>
      'GPTZero는 구독제입니다. TruthLens는 구독이 필요 없고 사용 횟수 제한도 없습니다.';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin은 기관 구매만 가능하여 개인이 직접 구매할 수 없습니다. TruthLens는 누구나 설치하여 사용할 수 있습니다.';

  @override
  String get helpVsTurnitin2 =>
      'Turnitin의 판정 과정은 블랙박스에 가깝습니다. TruthLens는 문장별 AI 확률, 일치하는 문체 패턴, 4개 엔진 각각의 점수와 근거를 상세히 제공합니다.';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin은 주로 \"AI 여부\"에 대한 이진 판정입니다. TruthLens는 단락/문장 단위로 사람／AI／혼합 표시를 지원합니다.';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai는 문서별 과금 구독제이며 문서를 클라우드에 업로드해야 합니다. TruthLens의 핵심 연산은 기기 내에서 실행되어 감지 기능 사용에 지속적인 비용이 필요 없습니다.';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai에는 팩트체크와 가독성 분석 개념이 있습니다. TruthLens는 기기 내 문체 특징 모듈로 이에 대응하며 오프라인에서도 기본 분석이 가능합니다.';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks는 주로 클라우드 API이며 낮은 오탐률과 강력한 다국어 지원이 강점입니다. TruthLens는 동일한 철학의 XLM-RoBERTa 다국어 기반 모델과 다중 모델 앙상블 투표를 채택하지만, 문서 내용은 어떤 서버에도 업로드되지 않습니다.';

  @override
  String get helpVsCopyleaks2 =>
      'Copyleaks는 요금제에 따라 API 사용량 제한이 있습니다. TruthLens는 사용량 제한이 없습니다.';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'Winston AI의 OCR 이미지 인식은 이미지를 클라우드에 업로드해야 합니다. TruthLens는 각 플랫폼의 네이티브 프레임워크（iOS／macOS의 Vision, Android의 ML Kit, Windows의 Windows.Media.Ocr）를 사용하여 기기 내에서 인식을 수행합니다.';

  @override
  String get helpVsWinston2 =>
      'Winston AI는 세련된 리포트 레이아웃으로 유명합니다. TruthLens는 AI가 동적으로 생성하는 리포트 레이아웃을 제공하며（LLM 미설치 시 템플릿으로 자동 대체）, PDF／CSV／JSON／PNG 4가지 형식으로 내보낼 수 있습니다.';

  @override
  String get helpAdvantagesTitle => 'TruthLens만의 강점';

  @override
  String get helpAdvantage1 =>
      '하이퍼링크 실재성 검증: 문서 내 URL이 연결 가능하고 실제로 존재하는지 자동으로 확인합니다. DOI 형식의 학술 링크는 Crossref 공개 등록 데이터를 추가로 조회하여 저널이 해당 문헌을 실제로 등재하고 있는지 확인합니다.';

  @override
  String get helpAdvantage2 =>
      '인용 문헌 실재성 검증: 하이퍼링크가 없는 참고 문헌（순수 \"저자—연도\" 형식）도 서지 정보 대조를 통해 허위일 가능성이 있는 인용을 찾아낼 수 있습니다—이는 AI 환각（할루시네이션） 콘텐츠에서 흔히 나타나는 단서입니다.';

  @override
  String get helpAdvantage3 =>
      'ESL（비원어민 작성자） 편향 보정: 비원어민 문체 특징을 자동으로 감지하고 통계 모델의 가중치를 낮춰, 비원어민 화자의 자연스러운 글을 AI로 오판하는 것을 방지합니다.';

  @override
  String get helpAdvantage4 =>
      '사용자 지정 모델 가져오기: 고급 사용자는 자체 로컬 ONNX 모델을 가져와 내장 감지 엔진을 대체하거나 보완할 수 있습니다.';

  @override
  String get helpWorkflowTitle => '전체 작동 흐름';

  @override
  String helpWorkflowStepLabel(int step) {
    return '$step단계';
  }

  @override
  String get helpWorkflowStep1Title => '모델 다운로드 및 업데이트';

  @override
  String get helpWorkflowStep1Body =>
      '처음 실행 시 핵심 감지 모델 설치를 안내합니다. 이후에는 언제든지 \"설정 → AI 모델 관리\"에서 확인, 다운로드, 업데이트, 삭제할 수 있습니다. 앱은 실행 시 최신 버전을 자동으로 확인하며, 업데이트가 있으면 설정 톱니바퀴 아이콘과 \"AI 모델 관리\" 항목에 알림 배지가 표시됩니다.';

  @override
  String get helpWorkflowStep2Title => '모델 선택 방법（목적과 효과）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      '다국어 AI 분류기（가중치 40%）: 종합 판정의 주력으로, 문장 단위 AI 확률 예측을 수행하며 정확도 향상에 가장 크게 기여합니다.';

  @override
  String get helpWorkflowStep2Bullet2 =>
      '통계 분석 엔진（가중치 25%）: 혼란도와 Burstiness 슬라이딩 윈도우 분석을 통해 AI 텍스트의 규칙적인 리듬과 예측 가능한 단어 사용을 포착합니다.';

  @override
  String get helpWorkflowStep2Bullet3 =>
      '문체 특징 분석（가중치 20%）: 의미적 유창성, 반복 문형, 접속어 사용을 분석하며, 설명 가능성이 가장 높아 \"왜\"를 가장 쉽게 이해할 수 있습니다.';

  @override
  String get helpWorkflowStep2Bullet4 =>
      '적대적 방어（가중치 15%）: 패러프레이징 도구（QuillBot, Undetectable.ai 등）로 처리된 텍스트를 감지합니다.';

  @override
  String get helpWorkflowStep2Bullet5 =>
      '리포트 생성 LLM（선택 사항）: 설치하면 리포트 텍스트가 기기 내 LLM에 의해 동적으로 생성됩니다. 미설치 시 고정 템플릿으로 자동 대체되며 분석 기능 자체에는 영향이 없습니다.';

  @override
  String get helpWorkflowStep2Bullet6 =>
      '\"설정\"에서 각 엔진을 개별적으로 켜거나 끌 수 있고, AI 판정 신뢰도 임계값을 조정할 수 있습니다（높이면 사람의 글을 AI로 오판할 확률을 낮출 수 있습니다）.';

  @override
  String get helpWorkflowStep3Title => '문서 업로드';

  @override
  String get helpWorkflowStep3Body =>
      '세 가지 입력 방법: 텍스트 직접 붙여넣기, 이미지 OCR（각 플랫폼의 네이티브 프레임워크로 오프라인 인식）, 파일 가져오기（txt / md / pdf / docx / doc）. 분석을 제출하려면 텍스트가 40자 이상이어야 합니다.';

  @override
  String get helpWorkflowStep4Title => '분석 시작';

  @override
  String get helpWorkflowStep4Body =>
      '\"검사 시작\"을 탭하면 4개 엔진이 병렬로 실행되며, 화면에 각 엔진의 완료 진행 상황이 실시간으로 표시됩니다. 비원어민 문체 특징이 감지되면 ESL 편향 보정이 자동으로 적용됩니다（설정에서 끌 수 있음）.';

  @override
  String get helpWorkflowStep5Title => '결과 확인 및 내보내기';

  @override
  String get helpWorkflowStep5Body =>
      '리포트 페이지에는 종합 AI 확률 게이지, 문장 단위 히트맵, 4개 엔진의 점수 및 근거 상세, 하이퍼링크 실재성, 인용 문헌 실재성이 포함됩니다. 전체 PDF 리포트, 문장별 CSV 데이터, JSON（시스템 연동용）, PNG 요약 카드（공유용）를 내보낼 수 있습니다. 각 분석 결과는 자동으로 \"기록\"에 저장되어 언제든지 다시 확인할 수 있습니다.';

  @override
  String get helpWorkflowStep1ChipOnboarding => '첫 실행 안내';

  @override
  String get helpWorkflowStep1ChipModelManager => '모델 관리';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => '자동 업데이트 확인';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => '통계 분석 (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => '문체 분석 (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => '적대적 방어 (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => '리포트 LLM (선택)';

  @override
  String get helpWorkflowStep3ChipPaste => '텍스트 붙여넣기';

  @override
  String get helpWorkflowStep3ChipImageOcr => '이미지 OCR';

  @override
  String get helpWorkflowStep3ChipImportFormats => 'PDF / DOCX / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation => '코드/수식 제외';

  @override
  String get helpWorkflowStep4ChipEnsemble => '4개 엔진 병렬 추론';

  @override
  String get helpWorkflowStep4ChipLiveProgress => '실시간 진행률';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'ESL 작문 보정';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'AI 개요 게이지';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => '문장 히트맵';

  @override
  String get helpWorkflowStep5ChipCitationVerification => '문헌 검증';

  @override
  String get helpWorkflowStep5ChipExportFormats =>
      'PDF / CSV / JSON / PNG 내보내기';

  @override
  String get helpTuningTitle => '모델 다운로드 및 조정 가이드（초보자용）';

  @override
  String get helpTuningStep1Title => '모델 관리 화면 열기';

  @override
  String get helpTuningStep1Body =>
      '홈 화면에서 톱니바퀴 아이콘을 탭하여 \"설정\"으로 이동한 후, \"AI 모델 관리\" 옆의 \"열기\"를 탭합니다.';

  @override
  String get helpTuningStep2Title => '기기 성능에 따라 모델 선택';

  @override
  String get helpTuningStep2Body =>
      '화면은 사용 중인 기기 성능（RAM, CPU 코어 수）에 따라 적합한 모델 등급을 자동으로 제안하며, 각 역할（다국어 분류기／통계 분석／적대적 방어／리포트 LLM）에 사용 가능한 모든 변형을 나열합니다.';

  @override
  String get helpTuningStep3Title => '다운로드 및 적용';

  @override
  String get helpTuningStep3Body =>
      '원하는 모델 옆의 \"다운로드\"를 탭하고 완료될 때까지 기다립니다—처음 다운로드한 모델은 자동으로 사용 중으로 설정됩니다. 여러 변형이 설치되어 있으면 \"사용 중으로 설정\"으로 언제든지 전환할 수 있습니다. 휴지통 아이콘을 탭하면 필요 없는 모델을 삭제하여 공간을 확보할 수 있습니다.';

  @override
  String get helpTuningStep4Title => '모델 업데이트';

  @override
  String get helpTuningStep4Body =>
      '새 버전이 제공되면 \"AI 모델 관리\"와 설정 톱니바퀴 아이콘에 알림 배지가 표시됩니다. 이 화면으로 돌아오면 새 버전을 확인하고 다운로드하여 업데이트할 수 있습니다（수동으로 삭제하지 않는 한 기존 설치된 버전은 유지됩니다）.';

  @override
  String get helpTuningStep5Title => '고급: 사용자 지정 모델 가져오기';

  @override
  String get helpTuningStep5Body =>
      '다른 곳에서 이미 호환되는 .onnx 모델을 확보했거나 직접 미세 조정한 경우, \"설정 → 사용자 지정 ONNX 모델 가져오기 및 테스트\"를 통해 가져올 수 있습니다—모델 파일, 해당 Tokenizer 설정（또는 \"필요 없음\" 선택）, AI 클래스 인덱스를 제공해야 합니다. 가져오기 전에 동일한 파일이 이미 가져와졌는지 자동으로 확인하여 실수로 중복 설치되는 것을 방지합니다.';

  @override
  String get helpOfficialLinksTitle => '공식 모델 다운로드 링크';

  @override
  String get helpOfficialLinksHint => '항목을 탭하면 시스템 브라우저에서 해당 모델의 공식 페이지가 열립니다.';

  @override
  String get helpLinkRoleTransformer => '다국어 AI 분류기（Transformer, 가중치 40%）';

  @override
  String get helpLinkRoleStatistical => '혼란도 통계 모델（Statistical, 가중치 25%）';

  @override
  String get helpLinkRoleAdversarial =>
      '적대적 패러프레이즈 감지 모델（Adversarial, 가중치 15%）';

  @override
  String get helpLinkRoleLlm => '리포트 생성 LLM（선택 사항）';

  @override
  String get privacyAppBarTitle => '개인정보처리방침';

  @override
  String privacyPlatformTitle(String platform) {
    return '$platform용 개인정보처리방침';
  }

  @override
  String privacyLastUpdated(String date) {
    return '최종 업데이트: $date';
  }

  @override
  String get privacyIosOverview1 =>
      'TruthLens는 사용자의 신원과 연결된 데이터를 전혀 수집하지 않으며 추적 목적으로 어떤 데이터도 사용하지 않으므로 앱 추적 투명성（ATT） 권한이 필요하지 않습니다.';

  @override
  String get privacyIosOverview2 =>
      '이 앱은 시스템에서 제공하는 파일 선택 도구를 사용하여 사용자가 능동적으로 선택한 문서나 이미지에 접근합니다. 선택하지 않은 파일에는 접근할 수 없습니다（iOS 앱 샌드박스 제한）.';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLens는 개인 데이터를 수집하지 않으며 어떤 제3자와도 사용자 데이터를 공유하지 않습니다.';

  @override
  String get privacyAndroidOverview2 =>
      '이 앱은 사용자가 능동적으로 문서나 이미지 가져오기를 선택할 때만 해당 저장소 권한에 접근하며, 백그라운드에서 다른 파일을 스캔하거나 접근하지 않습니다.';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens는 macOS 앱 샌드박스 하에서 실행되며, 시스템 파일 대화 상자를 통해 사용자가 능동적으로 선택한 파일（files.user-selected.read-write）에만 접근할 수 있고, 다른 파일이나 폴더를 자유롭게 탐색하거나 접근할 수 없습니다.';

  @override
  String get privacyMacosOverview2 =>
      '네트워크 접근 권한（network.client）은 아래 \"필요한 연결 동작\"에 나열된 기능에만 사용됩니다.';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens는 독립 실행형 데스크톱 애플리케이션으로, 데이터는 로컬 사용자 폴더（AppData／Documents 등）에 저장되며 클라우드에 동기화되지 않습니다.';

  @override
  String get privacyWindowsOverview2 =>
      '이 앱은 사용자가 능동적으로 문서나 이미지 가져오기를 선택할 때만 해당 파일에 접근하며, 백그라운드에서 다른 파일을 스캔하지 않습니다.';

  @override
  String get privacyDataHandling1 =>
      'TruthLens에는 사용자 계정이 없으며 로그인이 필요하지 않고, 어떤 형태의 광고나 제3자 추적 SDK도 포함되어 있지 않습니다.';

  @override
  String get privacyDataHandling2 =>
      '사용자가 입력, 붙여넣기 또는 가져온 문서 내용은 모두 사용자의 기기에서 로컬 AI 모델에 의해 분석되며, TruthLens나 어떤 제3자 서버에도 업로드되지 않습니다.';

  @override
  String get privacyDataHandling3 =>
      '분석 결과와 기록은 사용자 기기의 로컬 데이터베이스에만 저장됩니다. 앱을 삭제하거나 기록을 지우면 함께 제거되며, TruthLens는 어떤 사본도 보관하지 않습니다.';

  @override
  String get privacyNetworkIntro =>
      '이 앱의 핵심 AI 감지는 완전히 기기 내에서 실행되지만, 다음 세 가지 기능은 네트워크 연결이 필요합니다:';

  @override
  String get privacyNetwork1 =>
      '1. 모델 카탈로그 및 다운로드: GitHub Releases／Hugging Face에 연결하여 선택한 감지 모델 파일을 다운로드합니다. 모델 다운로드만 수행하며 사용자 데이터를 업로드하지 않습니다.';

  @override
  String get privacyNetwork2 =>
      '2. 모델 업데이트 확인: 실행 시 버전 번호만 비교하기 위해 연결하며, 새 버전이 있는지 알리는 데 사용됩니다.';

  @override
  String get privacyNetwork3 =>
      '3. 하이퍼링크 및 인용 문헌 검증: 기본적으로 켜져 있으며 설정에서 끌 수 있습니다. 감지된 URL, DOI 또는 개별 인용 필드(저자, 제목, 연도, 게재지)를 대상 사이트, 공개 서지 서비스, 대만 NCL／TCI-HSS, 출판사 목록 및 설정된 SCI／SSCI／EI 서비스로 전송합니다. 문서의 나머지 내용은 전송하지 않습니다. 선택적 제공업체 인증 정보는 이 기기의 앱 환경설정에만 저장됩니다.';

  @override
  String get privacyNetwork4 =>
      '4. Web OCR fallback: on the Web version only, OCR first uses a local OCR server if configured. If you choose to enter a Gemini API key, selected images and rendered pages from PDFs that require OCR are sent directly from your browser to Google\'s Gemini API; the key is stored only in that browser\'s local storage.';

  @override
  String get privacyRightsIntro =>
      '\"기록\"에서 언제든지 로컬 분석 기록을 지우거나 \"설정\"에서 하이퍼링크／문헌 검증 기능을 끌 수 있으며, 또는 직접';

  @override
  String get privacyRemoveIos => '앱을 삭제';

  @override
  String get privacyRemoveAndroid => '앱을 제거';

  @override
  String get privacyRemoveMacos => '앱을 휴지통으로 이동';

  @override
  String get privacyRemoveWindows => '앱을 제거';

  @override
  String get privacyDisclaimer =>
      '이 페이지의 내용은 TruthLens가 실제 기능 동작에 따라 작성한 개인정보 설명이며, 변호사의 검토를 거친 공식 법률 문서가 아닙니다. 거주 지역의 법규에 따른 공식 준수 검토가 필요한 경우 별도로 전문 법률 자문을 받으시기 바랍니다.';

  @override
  String get privacySectionOverviewIos => '개요（App Store 개인정보 \"영양성분표\"에 해당）';

  @override
  String get privacySectionOverviewAndroid =>
      '개요（Google Play \"데이터 안전\" 공개에 해당）';

  @override
  String get privacySectionOverviewMacos => '개요（앱 샌드박스 권한 설명）';

  @override
  String get privacySectionOverviewWindows => '개요';

  @override
  String get privacySectionDataHandling => '데이터 처리 방법';

  @override
  String get privacySectionNetwork => '필요한 연결 동작';

  @override
  String get privacySectionRights => '귀하의 권리';

  @override
  String get privacyGenericPlatformName => '이 플랫폼';

  @override
  String get settingsLanguagePackDialogBody =>
      'TruthLens 내장 다국어 탐지 모델은 이미 104개 이상의 언어를 지원합니다. AI 모델 관리에서 언어 강화 커뮤니티 모델을 탐색, 다운로드 또는 전환할 수 있습니다.';

  @override
  String settingsVersionSubtitle(String version, String build) {
    return '버전 $version (Build $build) · 로컬 우선 개인정보 보호 탐지 엔진';
  }

  @override
  String get webOcrSettingsTitle => 'Web OCR 설정';

  @override
  String get webOcrPurpose => '분석 전에 이미지의 인쇄 문자나 손글씨를 인식합니다.';

  @override
  String get webOcrGeminiKeyTitle => 'Gemini API 키(선택 사항)';

  @override
  String get webOcrGetKeyButton => '키 받기';

  @override
  String get webOcrGeminiDescription =>
      '로컬 OCR 서버를 사용할 수 없을 때만 사용하며 키는 이 브라우저에 저장됩니다.';

  @override
  String get webOcrLocalServerTitle => '로컬 OCR 서버(권장)';

  @override
  String get webOcrLocalServerDescription =>
      'macOS에서는 Apple Vision, Windows에서는 Windows OCR을 사용해 컴퓨터에서 OCR을 실행합니다. 아래에 로컬 엔드포인트를 입력하세요.';

  @override
  String get webOcrSetupGuideButton => '초보자 설정 안내';

  @override
  String get webOcrPriorityTitle => '인식 우선순위';

  @override
  String get webOcrPriorityDescription =>
      '1. URL 설정 시 로컬 OCR 서버\n2. API 키 설정 시 Gemini\n3. 둘 다 실패하면 구체적인 진단 표시';

  @override
  String get webOcrSetupGuideTitle => '로컬 OCR 서버 설정';

  @override
  String get webOcrSetupGuideBody =>
      '1. 아래에서 OCR 프로젝트 열기를 선택합니다.\n2. macOS: setup_and_run_ocr.sh를 다운로드하고 터미널에서 실행합니다: bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows: setup_and_run_ocr.bat를 다운로드해 두 번 클릭하고 설치를 허용합니다.\n4. OCR 준비 완료 메시지가 나올 때까지 기다립니다. 자동 시작도 설정됩니다.\n5. http://127.0.0.1:5001/ocr 을 입력하고 연결 테스트를 선택합니다.\n6. 이미지 OCR을 열고 선명한 이미지로 확인합니다.\n\n127.0.0.1 사용 시 브라우저와 OCR 서버는 같은 컴퓨터에서 실행해야 합니다. 실패하면 설치, 포트 5001, /ocr 끝부분을 확인하세요.';

  @override
  String get webOcrOpenProjectButton => 'OCR 프로젝트 열기';

  @override
  String get webOcrTestServerButton => '연결 테스트';

  @override
  String get webOcrTestServerMissingUrl => '먼저 로컬 OCR 서버 URL을 입력하세요.';

  @override
  String get webOcrTestServerSuccess => '로컬 OCR 서버가 실행 중이며 준비되었습니다.';

  @override
  String get webOcrTestServerFailure =>
      '로컬 OCR 서버에 연결할 수 없습니다. 안내, 방화벽, URL을 확인하세요.';
}
