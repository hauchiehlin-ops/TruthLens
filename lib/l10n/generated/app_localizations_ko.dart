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
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

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
    return 'PDF 텍스트 레이어를 사용할 수 없습니다. OCR로 $total페이지 중 $page페이지를 인식하는 중…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return 'PDF OCR로 \"$fileName\"을(를) 가져왔습니다（$count자）';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '\"$fileName\"에 신뢰할 수 있는 텍스트 레이어가 없습니다. 웹 OCR을 설정하거나 네이티브 OCR을 지원하는 설치된 앱을 사용한 후 다시 가져오세요.';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '\"$fileName\"에 OCR이 필요하지만 $max페이지 안전 제한을 초과합니다. PDF를 분할한 후 각 부분을 가져오세요.';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return '\"$fileName\"을(를) 안정적으로 읽을 수 없습니다. 손상되었거나 비밀번호로 보호되어 있거나 구성된 OCR 서비스에서 지원되지 않을 수 있습니다.';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '\"$fileName\"은(는) 구형 .doc 형식이라 텍스트를 안정적으로 추출할 수 없습니다. Word에서 .docx로 저장하거나 PDF로 내보낸 후 다시 가져오세요.';
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
    return '예비 결과: AI 확률 $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return '예비 결과: AI 확률 $percent%（정밀 분석 중…）';
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
  String get modelCatalogLoadFailed => '모델 카탈로그를 불러올 수 없습니다';

  @override
  String get modelCatalogEmpty => '사용 가능한 모델이 없습니다';

  @override
  String modelDownloadPathChip(String label) {
    return '$label 다운로드 경로';
  }

  @override
  String get modelDownloadPathModelFile => '모델 파일';

  @override
  String get modelDownloadPathCopied => '다운로드 경로가 복사되었습니다';

  @override
  String settingsSaveFailed(String error) {
    return '설정을 저장하지 못했습니다: $error';
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
      '다국어 Transformer로 문맥을 유지한 단락 블록을 평가한 뒤 상세 보고서를 위해 블록 점수를 문장에 다시 매핑합니다. 설정 가중치는 영향도를, AI 신호는 실제 기여도를 결정합니다.';

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
  String reportEngineDirectionalIndex(int percent) {
    return 'Weak direction $percent/100';
  }

  @override
  String get reportEngineNoDirectionalSignal => 'No directional signal';

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
      '사용자 지정 모델 가져오기는 웹 버전에서 아직 지원되지 않습니다. 앱 버전을 사용해 주세요.';

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
  String get historyUntitledDocument => '제목 없는 문서';

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
  String get reportEngineAnalysisLevelTitle => '엔진 분석 레이어';

  @override
  String get reportVerdictAiLikelihood => 'AI 경향';

  @override
  String get reportVerdictHumanLikelihood => '인간 글쓰기';

  @override
  String get reportRadarRoleTransformer => 'Transformer 분류기';

  @override
  String get reportRadarRoleStatistical => '통계 분석';

  @override
  String get reportRadarRoleStylometry => '문체 분석';

  @override
  String get reportRadarRoleAdversarial => '적대적 방어';

  @override
  String get reportRadarAxisTransformer => '문장 분류';

  @override
  String get reportRadarAxisStatistical => '언어 규칙성';

  @override
  String get reportRadarAxisStylometry => '문체';

  @override
  String get reportRadarAxisAdversarial => '재작성 방어';

  @override
  String get reportVerdictBadgeTitle => '종합 판정';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return '전체 AI 확률 $percent%';
  }

  @override
  String get reportVerdictHintHuman =>
      '대부분의 엔진 신호가 자연스러운 인간의 글쓰기 쪽으로 기울어져 있습니다.';

  @override
  String get reportVerdictHintLikelyHuman =>
      '전반적으로 인간에 가까우며, 약간의 모델 불확실성이 남아 있습니다.';

  @override
  String get reportVerdictHintMixed =>
      '엔진 신호가 혼재되어 있습니다. 이 결과와 함께 상세 분석을 참고하세요.';

  @override
  String get reportVerdictHintLikelyAi => '여러 지표가 AI를 가리킵니다. 점수가 높은 부분을 검토하세요.';

  @override
  String get reportVerdictHintAi => '전반적인 신호가 AI 생성 또는 재작성 쪽으로 강하게 기울어져 있습니다.';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return '종합 판정: $verdict; 전체 AI 확률 $percent%.';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return '가장 강한 단일 신호: $label（$percent%）. 그러나 최종 결과는 각 엔진의 가중치를 결합한 것이며 단일 엔진의 결론이 아닙니다.';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return '현재 가장 큰 가중 기여는 $label에서 나옵니다（약 $points 퍼센트포인트）.';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '\"명확한 AI 문체가 감지되지 않음\"은 문체 엔진이 고정된 문장 패턴이나 전환어 패턴을 찾지 못했다는 의미일 뿐이며, 다른 모델은 언어 규칙성, 문장 분류, 재작성 신호를 통해 여전히 전체 점수를 높일 수 있습니다.';

  @override
  String get reportSynthesisModelGap =>
      '일부 엔진이 참여하지 않은 경우, 먼저 모델 관리에서 \"추천 분석 모델 완성\"을 사용하세요. 그래도 실패하면 상세 분석에서 원인이 모델 누락, 지원되지 않는 tokenizer, 파일 누락, Web/ONNX Runtime 호환성 제한 중 무엇인지 알려줍니다.';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label은(는) 이 가중 투표에 참여하지 않아 이 항목은 0%로 표시됩니다. $hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return '역할 가중치 $weight%, 전체 점수에 약 $points 퍼센트포인트 기여$variantText.';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return '（모델 변형 $count개 병합됨）';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label은(는) 이번 투표에 참여하지 않았습니다.';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label은(는) 추가 텍스트 설명을 반환하지 않았습니다.';
  }

  @override
  String get reportEngineResolutionTransformer =>
      '해결 방법: 모델 관리에서 다국어 Transformer를 다운로드하고 활성화하세요. 이미 다운로드된 경우 모델과 tokenizer를 다시 다운로드하세요.';

  @override
  String get reportEngineResolutionAdversarial =>
      '해결 방법: 모델 관리에서 재작성 감지 모델과 tokenizer를 다시 다운로드하세요. 웹에서는 BigInt 호환성 수정이 적용된 버전으로 업데이트한 후 다시 분석하세요.';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason. 원인: 웹 ONNX Runtime이 반환한 BigInt 텐서를 이전 브리지가 변환할 수 없습니다. 수정된 빌드로 업데이트한 후 다시 분석하세요.';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason. 해결 방법: 카탈로그 모델로 전환하거나 모델과 tokenizer를 다시 다운로드하세요.';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason. 해결 방법: 모델 관리를 열고 \"추천 분석 모델 완성\"을 탭한 후 다국어 Transformer가 활성으로 표시되어 있는지 확인하세요.';
  }

  @override
  String get reportDetailAnalysisTitle => '상세 분석';

  @override
  String get reportNoEngineData => '아직 엔진 분석 데이터가 없습니다';

  @override
  String get reportEngineNotParticipated => '참여하지 않음';

  @override
  String get reportAiContentReportTitle => 'AI 콘텐츠 감지 보고서';

  @override
  String reportAnalysisTimeLabel(String time) {
    return '분석 시간: $time';
  }

  @override
  String get reportDownloadPdfButton => 'PDF 다운로드';

  @override
  String get reportSuspiciousLocationsTitle => '의심스러운 콘텐츠 위치';

  @override
  String reportSentenceCount(int count) {
    return '$count개 문장';
  }

  @override
  String get reportAiProbabilityPrefix => 'AI 확률: ';

  @override
  String get helpAdvantage5 =>
      '문서 출처 감식: .docx / .odt / .doc 안의 편집 기록(편집 시간, 저장 횟수, 편집 배치의 분산 정도)을 읽습니다. 이는 본문 판정과 독립된 증거이며 AI 확률과 분리해 표시합니다. PDF와 이미지는 자체 편집 이력이 없어 이런 증거를 제공할 수 없습니다.';

  @override
  String get helpAdvantage6 =>
      '근거가 부족하면 정직하게 판정을 유보합니다: 분석 가능한 문장 5개 미만, 100단어 미만, 참여 엔진 2개 미만, 또는 엔진 간 차이가 60퍼센트포인트 초과이면 \'증거가 부족하여 판정하지 않습니다\'라고 표시합니다. 잘못된 지목의 대부분은 근거가 약한 입력에 자신 있는 숫자를 돌려주는 데서 시작됩니다.';

  @override
  String get settingsAiSampleTitle => 'AI 생성 표본 추가';

  @override
  String get settingsAiSampleSubtitle =>
      '백그라운드 보정은 사람 표본만 자동으로 모읍니다. 학습된 엔진 가중치를 쓰려면 AI가 생성한 것이 확실한 글도 필요합니다. 붙여넣거나 가져오면 곧바로 분석해 AI 표본으로 등록합니다.';

  @override
  String get settingsAiSampleFromClipboard => '클립보드에서 붙여넣기';

  @override
  String get settingsAiSampleFromFile => '문서 가져오기';

  @override
  String get settingsAiSampleAnalyzing => '분석 중…';

  @override
  String settingsAiSampleAdded(int count) {
    return 'AI 표본을 추가했습니다 — 현재 $count편';
  }

  @override
  String get settingsAiSampleTooShort => '표본으로 쓰기에 너무 짧습니다(최소 100단어 필요)';

  @override
  String get settingsAiSampleFailed => '사용할 수 있는 내용을 찾지 못했습니다';

  @override
  String get helpFormatCoverageTitle => '2-a. 출처 증거의 형식 제한';

  @override
  String get helpFormatCoverage =>
      '**중요한 한계: 편집 기록을 담는 것은 .docx와 .odt뿐입니다.**\n\n| 입력 | 편집 기록 |\n|---|---|\n| .docx / .odt | ✅ 있음 |\n| .pdf | ❌ 형식상 편집 이력이 아예 없음 |\n| .doc(구버전) | ✅ 있음(OLE2 SummaryInformation) |\n| .txt / .md | ❌ 컨테이너 없음 |\n| 이미지 OCR | ❌ 픽셀만 남음 |\n| 붙여넣기 | ❌ 파일 자체가 없음 |\n\n이는 세 번째 기둥과 직결됩니다. **편집 기록을 가진 문서만 통계적 보장이 있는 기준 세트에 자동으로 추가됩니다.** 받는 것이 전부 PDF라면 그 기준 세트는 결코 늘지 않고, 보장 없는 참고용 표본만 쌓입니다.\n\n출처 증거와 자동 보정이 실제로 작동하게 하려면 인쇄하거나 내보낸 PDF가 아니라 작성자에게서 .docx 또는 .odt 원본을 받으세요. 이는 소프트웨어가 우회할 수 있는 제약이 아니라 업무 절차상의 요구입니다. PDF는 출력 형식이며 \'어떻게 쓰였는지\'를 기록하지 않습니다.';

  @override
  String provenanceUnsupportedFormat(String format) {
    return '$format 형식은 애초에 편집 이력을 담지 않습니다. 따라서 ‘기록이 지워진’ 것이 아니라 처음부터 없었던 것입니다. 편집 시간, 저장 횟수, 편집 배치를 기록하는 것은 .docx와 .odt뿐입니다.';
  }

  @override
  String get provenanceStripped =>
      '지원되는 형식이지만 파일에서 편집 기록을 찾지 못했습니다. 대개 다른 이름으로 저장, 온라인 변환, Google 문서에서 내보내기 등을 거친 경우이며, 이런 동작은 기록을 초기화합니다.';

  @override
  String get provenanceHowToGetRecord =>
      '출처 증거를 살리려면 인쇄하거나 내보낸 PDF가 아니라 **.docx, .odt 또는 .doc 원본 파일**을 확보하세요. 편집 이력이 남는 것은 원본뿐이며, 통계적 보장이 있는 기준 세트에 자동으로 들어갈 수 있는 것도 원본뿐입니다.';

  @override
  String get calibrationAutoTitle => '백그라운드에서 수집 중';

  @override
  String get calibrationAutoSubtitle =>
      '분석한 문서는 자동으로 기준 세트에 추가됩니다. 수동 라벨링이 필요 없습니다.';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return '편집 기록으로 사람 작성 확인: $auto편 / 참고용 표본: $observed편';
  }

  @override
  String get calibrationAutoWhy =>
      '통계적 보장이 있는 기준 세트에 들어가는 것은 편집 기록(편집 시간, 저장 횟수, 편집 배치 분산)을 가진 문서뿐입니다. 그것이 **본문 판정과 독립된** 증거이기 때문입니다. 이 도구 자신의 판정으로 라벨을 붙이면 제 답안을 제가 채점하는 셈입니다 — 잘못 표시된 글은 영영 기준 세트에 들어가지 못하고, 기준값은 갈수록 엄격해져 오히려 진짜 사람이 쓴 글이 더 많이 표시됩니다. 붙여넣은 텍스트에는 편집 기록이 없으므로 아래 참고 백분위에만 반영됩니다.';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return '참고: 이 점수는 분석한 $count편 중 $percentile번째 백분위에 있습니다(통계적 보장 없음)';
  }

  @override
  String get settingsAutoCollectTitle => '백그라운드에서 보정 표본 수집';

  @override
  String get settingsAutoCollectSubtitle =>
      '분석한 문서를 자동으로 기준 세트에 추가합니다. 라벨은 문서의 편집 기록에서 오며, 이 도구의 판정은 쓰지 않습니다.';

  @override
  String get settingsStoreTextTitle => '오프라인 검증용으로 원문 보관';

  @override
  String get settingsStoreTextSubtitle =>
      '켜면 기준 세트에 추가한 글이 원문과 함께 기기에 저장되어, 나중에 코퍼스 파일로 내보내 오프라인 평가에 쓸 수 있습니다.';

  @override
  String get settingsStoreTextWarning =>
      '원문은 대개 타인의 작품이므로 민감한 자료입니다. 오프라인 검증용 코퍼스를 실제로 모을 때만 켜고, 내보낸 뒤에는 아래 ‘저장된 원문 지우기’로 즉시 삭제하세요. 지워도 공형 예측에는 영향이 없습니다(점수만 사용).';

  @override
  String get settingsExportCorpusTitle => '기준 코퍼스 내보내기';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return '내보낼 수 있음: 사람 $human편, AI $ai편(오프라인 평가에는 각 $required편 필요)';
  }

  @override
  String get settingsExportCorpusButton => 'JSONL로 내보내기';

  @override
  String get settingsExportCorpusEmpty =>
      '내보낼 표본이 없습니다. 먼저 ‘원문 보관’을 켜고 기준 세트를 쌓으세요';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return '$count편을 내보냈습니다(원문이 없는 $skipped편은 건너뜀)';
  }

  @override
  String get settingsClearStoredText => '저장된 원문 지우기';

  @override
  String get settingsClearStoredTextDone => '저장된 원문을 모두 지웠습니다. 점수와 보정은 그대로입니다.';

  @override
  String get helpDesignTitle => '설계 철학과 알려진 한계';

  @override
  String get helpShiftTitle => '1. 위치 전환: 점수 정확도로 겨루지 않습니다';

  @override
  String get helpShiftBody =>
      '시중의 거의 모든 탐지기는 같은 질문에 답합니다. \"이 글은 AI가 쓴 것처럼 보이는가?\"\n\n이것은 이길 수 없는 군비 경쟁입니다. 모델이 강해질수록 생성물의 통계적 특징은 사람의 글에 가까워지고, 바꿔쓰기 도구의 발전 속도는 탐지기보다 훨씬 빠릅니다. 이 길에서는 서버의 대형 모델도 그저 더 천천히 질 뿐입니다.\n\nTruthLens는 다른 질문을 던집니다. \"이 문서가 어떻게 만들어졌는지에 대해 우리 손에 어떤 증거가 있으며, 각각 얼마나 강한가?\"\n\n문체 추측에서 벗어나 출처 증거와 통계적으로 정직한 결론으로 무게중심을 옮기는 것입니다. 이 도구가 단일 점수 정확도 순위를 일부러 좇지 않고, 증거를 하나씩 따로 펼쳐 보이며 근거가 부족할 때는 모른다고 분명히 말하는 이유가 여기 있습니다. 브라우저 실행의 진짜 장점은 추론 속도가 아니라 서버가 결코 볼 수 없는 것—완전한 파일, 그리고 사용자가 직접 모은 기준—을 본다는 점입니다.';

  @override
  String get helpPillarsTitle => '2. 다섯 개의 기둥';

  @override
  String get helpPillarsBody =>
      '1. 문서 출처 감식(가동 중)\nDOCX·ODT 컨테이너 안의 편집 기록을 읽습니다. 총 편집 시간, 저장 횟수, 생성·수정 시각, 그리고 본문의 편집 배치 표식(RSID). 글 전체에 RSID가 한두 개뿐이면 대개 내용이 한 번에 들어갔다는 뜻입니다. 3,000단어인데 편집 4분이라는 기록은 어떤 혼란도 점수보다도 단단한 증거입니다. 이는 출처 증거로서 AI 확률과 분리해 표시하며, 의도적으로 점수에 섞지 않습니다.\n\n2. 로컬 기준 보정과 공형 예측(가동 중)\n작성자가 직접 쓴 것이 확실한 글을 기준 세트에 추가하면, 전 세계 공통 기준값이 아니라 이 집단 자체의 분포로 판단합니다. 공형 예측은 분포에 의존하지 않는 보장을 제공합니다. 기준과 검사 대상이 교환 가능하다면 오탐률은 설정한 α 이하로 유지됩니다. 비원어민 글쓰기의 오판을 줄이는 핵심이며, 상용 제품은 할 수 없는 일입니다. 그들에게는 당신 작성자의 기준 글이 없습니다.\n\n3. 학습된 엔진 가중치(가동 중)\n기준 세트에 사람과 AI 표본이 모두 쌓이면, 각 엔진이 두 집단을 얼마나 잘 갈라내는지(Cohen\'s d 효과크기)를 재어 그에 맞는 가중치를 제안합니다. 손으로 정한 고정 비율을 대체하지만, \'적용\'을 누르기 전까지 아무것도 바뀌지 않습니다. 설정이 조용히 변경되는 일은 없습니다.\n\n4. Binoculars 교차 혼란도(채점 핵심 완료, 아직 미가동)\n순수 혼란도는 \'예측하기 쉬운 정도\'를 곧 \'AI다움\'으로 취급하기 때문에, 표현이 담백한 비원어민 글에 체계적인 오탐을 냅니다. Binoculars는 예측 용이성을 \'두 모델이 서로 얼마나 어긋나는지\'에 견주어 잽니다. 채점 수학은 구현·검증했지만, 실제로 켜려면 브라우저에서 돌아가는 소형 언어 모델 한 쌍과 라벨 데이터 검증이 더 필요합니다.\n\n5. 워터마크 탐지(조사 결과 실현 불가, 미구현)\nSynthID-Text 탐지는 키에 묶여 있습니다. 탐지기는 생성 때와 같은 키로 계산해야 하는데, Google 운영 환경의 키는 공개되어 있지 않습니다. 브라우저에서 이를 해도 ChatGPT·Claude·Gemini의 실제 출력에는 결코 반응하지 않습니다. 워터마크를 확인하고 있다고 오해하게 만들 뿐 절대 작동하지 않는 기능이 되므로 일부러 넣지 않았습니다.';

  @override
  String get helpCascadeTitle => '3. 단계적 캐스케이드와 판정 유보';

  @override
  String get helpCascadeBody =>
      '브라우저의 제한된 연산 예산에서 속도를 유지하기 위해 분석은 단계별로 진행됩니다. 값싼 신호를 먼저, 비싼 것은 필요할 때만.\n\n0단계  문서 출처 증거(비용 거의 없음)\n1단계  통계·문체 특징(기존 엔진, 저렴)\n2단계  Transformer 문장 단위 분류기\n3단계  교차 혼란도(가장 비쌈, 앞 단계에서도 애매할 때만)\n\n결과는 로컬 보정으로 넘어가 오탐률 보장이 붙은 결론—또는 명시적 유보—을 냅니다.\n\n[유보가 중요한 이유]\n잘못된 지목의 대부분은 너무 짧거나 신호가 약한 입력에 자신 있는 숫자를 돌려주는 데서 생깁니다. 이 도구는 다음의 경우 점수를 억지로 내지 않고 \"증거가 부족하여 판정하지 않습니다\"라고 표시합니다.\n\n- 분석 가능한 문장 5개 미만\n- 본문 100단어 미만\n- 참여 엔진 2개 미만\n- 엔진 간 차이가 60퍼센트포인트 초과(평균이 의미를 잃음)\n\n유보할 때도 참고용으로 전체 점수와 문장별 근거를 아래에 남깁니다. 다만 결론으로 받아들이지는 마세요. \"모른다\"고 말할 수 있는 시스템이 언제나 숫자를 건네는 시스템보다 더 믿을 만합니다.';

  @override
  String get helpRisksTitle => '4. 정직하게 마주해야 할 위험';

  @override
  String get helpRisksBody =>
      '아래는 모두 이 도구에 실제로 존재하는 한계입니다. 보고된 내용에 따라 행동하기 전에 반드시 함께 고려하세요.\n\n1. 출처 증거는 지우거나 위조할 수 있습니다\n다른 이름으로 저장, 온라인 변환, Google 문서에서 내보내기, 새 파일로 복사 — 모두 편집 기록을 0으로 되돌립니다. 신호는 보조 증거일 뿐이며, 신호가 없다고 해서 사람이 썼다는 증명은 결코 되지 않습니다.\n\n2. 공형 보장은 교환 가능성에 기댑니다\n기준 표본과 검사 대상이 같은 집단, 같은 종류의 과제일 때만 성립합니다. 작성자의 글쓰기가 뚜렷이 늘었거나 과제 종류이 완전히 바뀌었다면 전제가 무너지고 기준 세트를 다시 만들어야 합니다.\n\n3. 기준 세트 자체가 오염될 수 있습니다\n기준으로 쓴 과제가 사실 AI 대필이었다면 보정 전체가 틀어집니다. 기준 표본은 통제된 환경 — 예컨대 통제된 환경에서 완성한 작품 — 에서 모아야 합니다.\n\n4. 브라우저 내 소형 모델은 서버의 대형 모델보다 정확도가 낮습니다\nWeb 전용이라는 결정이 프라이버시와 맞바꾼 불가피한 대가입니다. 이 도구의 가치는 더 정확한 단일 점수가 아니라, 설명 가능하고 보정 가능하며 정직하게 유보한다는 데 있습니다.\n\n5. 어떤 점수도 단독으로 지목의 근거가 되어서는 안 됩니다\n반드시 문장별 근거, 문서의 출처, 그리고 그 작성자에 대해 이미 알고 있는 바와 함께 읽으세요. 이 도구는 당신이 나눌 대화를 돕도록 설계되었지, 대신 판결을 내리기 위한 것이 아닙니다.';

  @override
  String get calibrationAddHuman => '\'사람이 작성\' 기준으로 추가';

  @override
  String get calibrationAddAi => '\'AI 생성\' 표본으로 추가';

  @override
  String calibrationCounts(int human, int ai) {
    return '기준 세트: 사람 $human편, AI $ai편';
  }

  @override
  String get learnedWeightsTitle => '학습된 엔진 가중치';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return '현재 사람 $human편, AI $ai편입니다. 신뢰할 만한 가중치를 학습하려면 각 부류마다 최소 $required편이 필요하며, 그전까지는 수동 설정 가중치가 그대로 적용됩니다.';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return '사람 $human편, AI $ai편의 표본으로 가중치를 학습할 수 있습니다.';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine: 권장 가중치 $weight%(분리도 $effect)';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return '참고: $engine은(는) 두 집단을 반대로 판정했습니다(AI 표본이 오히려 낮은 점수). 그래서 가중치가 0이 됩니다. 보통 이 엔진이 이런 종류의 글에 맞지 않는다는 뜻입니다.';
  }

  @override
  String get learnedWeightsApply => '학습된 가중치 적용';

  @override
  String get learnedWeightsApplied => '학습된 가중치를 적용했습니다';

  @override
  String get learnedWeightsExplain =>
      '가중치는 각 엔진이 사람 표본과 AI 표본을 얼마나 잘 갈라내는지(Cohen\'s d 효과크기)에서 나옵니다. 두 집단이 멀리 떨어질수록, 각 집단이 안정적일수록 그 엔진의 가중치가 커집니다. 이는 수동으로 정한 고정 가중치를 대체해, 실제로 다루는 글의 종류에 앙상블을 맞춥니다.';

  @override
  String get calibrationTitle => '로컬 기준 보정';

  @override
  String get calibrationEmpty =>
      '아직 기준 세트가 없습니다. 작성자가 직접 쓴 것이 확실한 글(예: 통제된 환경에서 완성한 작품)을 몇 편 추가하면, 전 세계 공통 기준값 대신 이 집단 자체의 분포에 견주어 판단할 수 있습니다. 비원어민 글쓰기의 오탐을 줄이는 핵심이 바로 이것입니다.';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return '기준 세트가 현재 $count편인데, $alpha% 오탐률 상한이 실제로 성립하려면 최소 $required편이 필요합니다. 그때까지는 참고 수치만 보여 주며 이를 근거로 어떤 글도 표시하지 않습니다.';
  }

  @override
  String calibrationFlagged(int alpha) {
    return '오탐률 상한 $alpha% 설정에서 이 글은 **표시되었습니다**.';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return '오탐률 상한 $alpha% 설정에서 이 글은 **표시되지 않았습니다**.';
  }

  @override
  String calibrationPValue(String value, int count) {
    return '보수적 p값 $value(기준 표본 $count편 대비)';
  }

  @override
  String calibrationPercentile(int percentile) {
    return '점수가 기준 세트의 $percentile번째 백분위에 있습니다';
  }

  @override
  String get calibrationCaveat =>
      '이 보장은 기준 표본과 검사 대상이 교환 가능하다는 것, 즉 같은 집단·같은 종류의 과제라는 전제에 기댑니다. 작성자의 글쓰기 실력이 뚜렷이 늘었거나 과제 종류이 완전히 바뀌었다면 전제가 무너지므로 기준 세트를 다시 만들어야 합니다. 또한 기준 글 자체가 AI 대필이라면 보정 전체가 틀어지므로 통제된 환경에서 수집하세요.';

  @override
  String get calibrationAddButton => '이 글을 기준 세트에 추가';

  @override
  String calibrationAdded(int count) {
    return '기준 세트에 추가했습니다 — 현재 $count편';
  }

  @override
  String get settingsCalibrationTitle => '로컬 기준 세트';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return '현재 $count편(이 α에는 $required편 필요)';
  }

  @override
  String get settingsCalibrationClear => '기준 세트 비우기';

  @override
  String get settingsCalibrationCleared => '기준 세트를 비웠습니다';

  @override
  String get settingsAlphaTitle => '오탐률 상한(α)';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return '현재 $alpha% — 낮을수록 엄격하지만 기준 표본이 더 많이 필요합니다(최소 $required편)';
  }

  @override
  String get abstentionHeadline => '증거가 부족하여 판정하지 않습니다';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return '분석 가능한 문장이 $count개뿐입니다(최소 $required개 필요). 이 길이에서는 통계·문장 단위 신호가 의미를 갖지 못하며, 억지로 점수를 내면 오해만 부릅니다.';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return '본문이 $count단어로, 최소 $required단어가 필요합니다. 그 아래에서는 어떤 문체 특징도 우연일 수 있습니다.';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return '$total개 중 $available개 엔진만 참여해 다른 각도에서 교차 검증할 수 없습니다. 모델 관리에서 채운 뒤 다시 실행하세요.';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return '엔진 간 차이가 $spread퍼센트포인트로, 평균을 내는 것이 의미를 잃을 만큼 갈립니다. 문장별 근거와 문서 출처를 보고 직접 판단하세요.';
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
      '아래에 전체 점수와 문장별 근거를 참고용으로 남겨 두었습니다. 다만 결론으로 받아들이지는 마세요.';

  @override
  String get provenanceTitle => '문서 출처 증거';

  @override
  String get provenanceRiskHigh => '편집 기록이 명백히 이례적입니다';

  @override
  String get provenanceRiskMedium => '편집 기록에 의심스러운 점이 있습니다';

  @override
  String get provenanceRiskLow => '편집 기록은 정상으로 보입니다';

  @override
  String get provenanceRiskUnknown => '사용할 수 있는 편집 기록이 없습니다';

  @override
  String get provenanceNoMetadata =>
      '이 입력에는 편집 기록이 없습니다(붙여넣은 텍스트, PDF, 또는 기록이 지워진 파일). 따라서 출처로는 판단할 수 없고 본문 분석만 가능합니다.';

  @override
  String provenanceEditingDuration(int minutes) {
    return '파일에 기록된 총 편집 시간: $minutes분';
  }

  @override
  String provenanceRevisionCount(int count) {
    return '저장 횟수: $count회';
  }

  @override
  String provenanceApplication(String name) {
    return '생성 프로그램: $name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return '본문의 편집 배치 표식이 $count개뿐인데 내용은 $words단어입니다. 생각하며 쓰면 보통 수십 개가 남으므로, 이 정도로 집중되어 있다면 대개 한 번에 들어간 것(예: 붙여넣기)입니다.';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words단어에 기록된 편집 시간 $minutes분이면 분당 $wpm단어로, 실제로 글을 쓰면서 유지할 수 있는 속도를 훨씬 넘습니다.';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return '파일에 기록된 편집 시간이 거의 0인데 본문은 $words단어입니다.';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return '$words단어 분량이 $count번만 저장되었습니다.';
  }

  @override
  String get provenanceCaveat =>
      '참고: 이 기록은 지우거나 초기화할 수 있습니다. 다른 이름으로 저장, 온라인 변환, Google 문서에서 내보내기, 새 파일로 복사 — 모두 기록을 0으로 만듭니다. 따라서 신호는 보조 증거일 뿐 단독으로 결론이 될 수 없으며, 신호가 없다고 사람이 썼다는 증명도 되지 않습니다.';

  @override
  String get telemetrySummaryTitle => '분석 요약';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '엔진 $total개 중 $engines개가 완료됐습니다. 전체 AI 확률은 $percent%로 “$verdict”으로 판정됐습니다.';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return '엔진들의 판단이 대체로 일치합니다(최고 $high%, 최저 $low%). 이 결론은 충분히 믿을 만합니다.';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return '엔진들의 판단이 엇갈립니다. $highLabel은 $high%인데 $lowLabel은 $low%에 그쳤습니다. 이럴 땐 종합 점수만 보지 말고 아래 문장별 근거를 확인하는 편이 훨씬 정확합니다.';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return '점수를 끌어올린 건 주로 $label이며, 약 $points퍼센트포인트를 기여했습니다.';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return '$total개 문장을 모두 훑었지만 강한 AI 신호선을 넘은 문장은 하나도 없습니다.';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return '$total개 문장 중 $count개가 강한 AI 신호선을 넘었습니다. 한 문장씩 살펴볼 가치가 있습니다.';
  }

  @override
  String get telemetrySummaryAdviceHuman =>
      '전체적으로 사람이 직접 쓴 글로 읽힙니다. 따로 파고들 만한 부분은 없습니다.';

  @override
  String get telemetrySummaryAdviceMixed =>
      '이 문서는 회색지대에 있습니다. 점수만으로 결론 내리기엔 위험하니 문장별 근거와 문서 출처를 함께 보고 판단하세요.';

  @override
  String get telemetrySummaryAdviceAi =>
      '신호가 AI 생성이나 재작성 쪽을 뚜렷하게 가리킵니다. 표시된 문장을 하나씩 확인한 뒤 결정하세요.';

  @override
  String telemetrySummaryModelGap(int count) {
    return '참고로 $count개 엔진이 이번 투표에 참여하지 않아 확신도는 조금 낮춰 보셔야 합니다. 모델 관리에서 채운 뒤 다시 돌리면 더 정확해집니다.';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'AI 확률 < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'AI 확률 $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'AI 확률 ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return '낮은 신뢰도: 사용 가능한 모델 가중치가 60% 미만입니다（임계값 $threshold%）. $available/$total개 엔진이 참여했습니다. 상세 엔진 분석을 검토하세요.';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return '높은 신뢰도: $available/$total개 감지 모델이 합의에 도달했습니다（$threshold% 이상의 가중치가 이 판정에 동의）.';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return '낮은 신뢰도（$available/$total）';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return '높은 신뢰도（$available/$total）';
  }

  @override
  String get reportMetricAiSentenceRatio => '강한 AI 신호 문장 비율';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$total개 문장 중 $count개가 60% 강한 신호 기준을 넘었습니다';
  }

  @override
  String get reportMetricElapsed => '분석 시간';

  @override
  String get reportMetricElapsedNormal => '0.5-5초 정상';

  @override
  String get reportMetricReliability => '신뢰도';

  @override
  String get reportReliabilityLow => '낮음';

  @override
  String get reportReliabilityHigh => '높음';

  @override
  String get reportReliabilityNeedsReview => '검토 필요';

  @override
  String get reportReliabilityHighTrust => '매우 신뢰할 수 있음';

  @override
  String get reportSentenceAnalysisTitle => '문장 단위 분석';

  @override
  String get suspiciousFilterAll => '의심스러움';

  @override
  String get suspiciousFilterHigh => '높음';

  @override
  String get suspiciousFilterMedium => '중간';

  @override
  String get suspiciousExcludedTooltip =>
      '단일 문자, 페이지 번호, 섹션 번호, 너무 짧은 OCR/PDF 조각은 제외되었습니다.';

  @override
  String suspiciousCount(int count) {
    return '$count개 항목';
  }

  @override
  String get suspiciousEmpty => '의심스러운 콘텐츠 없음';

  @override
  String get suspiciousRiskHigh => '높음';

  @override
  String get suspiciousRiskMedium => '중간';

  @override
  String get suspiciousReasonHighModelSignals => '여러 모델 신호가 AI 쪽으로 강하게 기울어짐';

  @override
  String get suspiciousReasonSentenceSignal => '문장 단위 모델 신호가 높음';

  @override
  String suspiciousOriginalLocation(String location) {
    return '원본 위치 $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return '원본 위치 $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return '문장 #$number';
  }

  @override
  String get suspiciousEvidenceLabel => '근거:';

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
  String get reportBibRecheckAllUnreliableButton => '검증되지 않은 모든 인용을 다시 확인';

  @override
  String get reportBibRecheckOneTooltip => '이 인용을 다시 확인';

  @override
  String get reportBibResultHint =>
      '저자, 연도, 제목 유사도를 Crossref 공개 등록 데이터와 대조합니다. 절대적인 보장은 아니며, \"불확실\"할 경우 직접 확인하는 것을 권장합니다.';

  @override
  String reportBibVerificationSource(String source) {
    return '검증 출처: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup => 'Google Scholar에서 수동으로 확인';

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
    return '저널명 불일치: 문서에는 \"$reported\"라고 되어 있지만, 검증된 등록 정보에는 \"$registered\"라고 되어 있습니다. 이 인용을 검토하세요.';
  }

  @override
  String get reportBibNotFound => '유사한 항목을 찾을 수 없습니다. 허위 참고 문헌일 가능성이 있습니다';

  @override
  String get reportBibUncertain => '의심됨: 등록 데이터 대조로 검증되지 않음';

  @override
  String reportBibTruncated(int max, int count) {
    return '처음 $max개 항목만 검증했습니다（총 감지된 항목 $count개）';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return '$count개 완료됨. 결과는 계속 업데이트됩니다.';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return '진행률 $completed/$total, $current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return '현재: $text';
  }

  @override
  String get reportBibProgressFinalizing => '결과 마무리 중';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base: 유사한 후보 \"$candidate\"을(를) 찾았지만, 저자, 연도 또는 제목이 신뢰할 수 있는 일치 임계값을 충족하지 않았습니다.';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base: 검증 소스가 신뢰할 수 있는 응답을 반환하지 않았거나 항목 정보가 부족합니다. TruthLens는 이 인용을 검증된 것으로 간주하지 않습니다.';
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
    return '종합 AI 확률이 고정 $percent% 임계값을 초과하여 AI로 표시되었습니다.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '종합 AI 확률이 고정 $percent% 표시 임계값 미만입니다.';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return '전체 AI 확률은 $aiPercent%로, 고정 AI 표시 임계값 $thresholdPercent%에 도달하여 보고서가 이 텍스트를 AI로 표시합니다. 최종 결정을 내리기 전에 문장 단위 증거와 엔진 이유를 검토하세요.';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '전체 AI 확률은 $aiPercent%로, 고정 AI 표시 임계값 $thresholdPercent%보다 낮아 보고서가 이 텍스트를 공식적으로 AI로 표시하지 않습니다. 확률과 증거는 검토를 위해 계속 표시됩니다.';
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
  String engineReasonBurstinessMid(String value) {
    return 'Sentence-length variation (burstiness $value) stayed inside the neutral band 0.30–0.55';
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
  String engineReasonMattrNoAiSignal(String value, String cut) {
    return 'Vocabulary diversity (MATTR $value) did not cross the calibrated AI-signal cutoff $cut';
  }

  @override
  String engineReasonStatisticalSummaryAi(String percent) {
    return '전체 통계 요약: AI 생성 특성 쪽으로 기울어짐（AI 확률 $percent%）';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return '전체 통계 요약: 자연스러운 인간 글쓰기 쪽으로 기울어짐（AI 확률 $percent%）';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return '전체 통계 요약: 지표가 균형을 이루어 중립적 특성을 보임（AI 확률 $percent%）';
  }

  @override
  String get reportFormulaTitle => '가중치 계산 투명성 및 매개변수 분석';

  @override
  String get reportFormulaExplanation =>
      '전체 AI 확률은 모든 활성 엔진의 확률을 가중 평균하여 계산됩니다:';

  @override
  String get reportFormulaActiveEngines => '활성 엔진 및 할당된 가중치';

  @override
  String get reportFormulaCalculation => '가중치 공식 계산';

  @override
  String get reportFormulaFinalResult => '최종 가중 AI 확률';

  @override
  String get reportFormulaEslApplied => 'ESL 비원어민 작문 보정 적용됨（통계 모델 가중치 절반으로 감소）';

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
  String engineReasonPan25LexicalAi(int percent) {
    return 'PAN 2025 lexical fingerprint leans AI ($percent/100); this independent English baseline detects word and phrase distributions that differ from its human corpus';
  }

  @override
  String engineReasonPan25LexicalHuman(int percent) {
    return 'PAN 2025 lexical fingerprint leans human ($percent/100); this remains model evidence, not proof of authorship';
  }

  @override
  String engineReasonPan25LexicalNeutral(int percent) {
    return 'PAN 2025 lexical fingerprint is neutral ($percent/100) and does not provide a direction';
  }

  @override
  String engineReasonCompressionCoherence(String value) {
    return 'Cross-boundary compression coherence ($value) exceeds the PAN 2025 human 95th-percentile screen [weak AI-side signal]';
  }

  @override
  String engineReasonAssistantResponseArtifact(int count) {
    return 'Detected $count conversational assistant-response artifact(s), such as addressing the requester or offering to revise the requested text';
  }

  @override
  String get engineReasonAdversarialNotInstalled =>
      '패러프레이즈 감지 모델이 설치되지 않아 이번 투표에 참여하지 않았습니다';

  @override
  String get engineReasonTransformerNotInstalled =>
      '모델이 설치되지 않았거나 사용 중인 모델이 지원되지 않아 이번 투표에 참여하지 않았습니다';

  @override
  String get modelRepairNoActiveVariant =>
      '활성화된 모델을 찾을 수 없습니다. 모델 관리에서 추천 모델을 다운로드하세요.';

  @override
  String get modelRepairCustomRemoved =>
      '로드에 실패한 사용자 지정 모델을 제거했습니다. 사용자 지정 모델은 자동으로 다시 다운로드할 수 없으므로 모델과 토크나이저를 다시 가져오세요.';

  @override
  String get modelRepairNoSource =>
      '로드에 실패한 모델 파일을 제거했지만 다시 다운로드할 수 있는 카탈로그 소스를 찾을 수 없습니다. 모델 관리에서 추천 모델을 다시 다운로드하세요.';

  @override
  String modelRepairRedownloaded(Object name) {
    return '모델 파일이 손상되었거나 호환되지 않을 수 있음을 감지하여 $name을(를) 자동으로 다시 다운로드했습니다. 분석을 다시 실행하세요.';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return '로드에 실패한 모델 파일을 제거했지만 자동 재다운로드가 완료되지 않았습니다. 네트워크 연결을 확인한 후 모델 관리에서 $name을(를) 다시 다운로드하세요.';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      '활성화된 Transformer 모델을 찾을 수 없습니다. 모델 관리에서 다운로드하거나 활성으로 설정하세요';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return '사용 중인 모델의 tokenizer 유형이 지원되지 않습니다（$tokenizer）. bert-wordpiece 또는 roberta-bpe를 지원하는 모델로 전환하세요';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Transformer 모델 또는 tokenizer 경로가 없습니다. 모델 관리에서 다시 다운로드하세요';

  @override
  String get engineTransformerMissingFiles =>
      'Transformer 모델 또는 tokenizer 파일이 존재하지 않습니다. 모델 관리에서 다시 다운로드하세요';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'ONNX opset 버전이 지원되지 않습니다（이 모델 버전이 너무 최신입니다. 앱을 업데이트하세요）: $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Tokenizer 형식이 손상되었습니다: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      '모델 로드 또는 추론에 실패했으며 자동 복구도 완료되지 않았습니다. 모델 관리에서 활성 Transformer 모델과 tokenizer를 다시 다운로드하세요.';

  @override
  String get engineAdversarialNoActiveVariant => '활성화된 재작성 감지 모델을 찾을 수 없습니다';

  @override
  String get engineAdversarialMissingFiles =>
      '모델 또는 tokenizer 파일이 존재하지 않습니다. 모델 관리에서 다시 다운로드하세요';

  @override
  String get engineAdversarialRepairFailed =>
      '모델 로드 또는 추론에 실패했으며 자동 복구도 완료되지 않았습니다. 모델 관리에서 재작성 감지 모델과 tokenizer를 다시 다운로드하세요.';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return '이 모델은 이번 투표에 참여하지 않았습니다. $error';
  }

  @override
  String get patternNotAnalyzable =>
      '구간이 너무 짧거나 PDF/OCR 노이즈로 의심되어 문장 단위 AI 판정을 수행하지 않았습니다';

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
      'TruthLens는 **전적으로 브라우저 안에서 동작하는** AI 콘텐츠 탐지 도구입니다. Transformer 신경망 분류기, 통계 특징 분석, 문체 분석, 적대적 재작성 탐지라는 네 개의 독립 엔진이 가중 투표로 판정하며, 문서는 어디로도 전송되지 않습니다.\n\n보고서는 판정을 AI 확률로 제시하며 다섯 개의 고정 구간(20% 미만, 20–40%, 40–60%, 60–80%, 80% 이상)으로 분류합니다. 여기에 문장별 근거, 각 엔진의 기여, 문서 출처 증거, 가져온 파일명을 함께 보여 줍니다. 구간 경계는 조정할 수 없으므로 같은 문서는 누구에게나 같은 구간에 들어갑니다. 근거가 부족하면(문장 수나 단어 수가 적거나 엔진 간 차이가 큼) 억지로 점수를 내지 않고 \'판정하지 않습니다\'라고 분명히 밝힙니다.';

  @override
  String get helpComparisonTitle => '주요 도구와의 비교';

  @override
  String get helpComparisonDisclaimer =>
      '아래 비교는 각 도구의 공개 정보와 일반적인 시장 인식을 바탕으로 정리한 것으로, 기능적 포지셔닝 참고용일 뿐이며 제3자가 인증한 성능 벤치마크 데이터가 아닙니다.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero는 연산 대부분을 클라우드에서 하고 문서 업로드가 필요하지만, TruthLens는 네 엔진 모두 사용자의 브라우저 안에서 실행되며 내용은 어디로도 전송되지 않습니다.';

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
      'Originality.ai는 건당 과금 구독제이며 클라우드 업로드가 필요하지만, TruthLens는 핵심 연산을 브라우저에서 끝내고 구독도 사용 횟수 제한도 없습니다.';

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
      'Winston AI의 이미지 OCR은 사진을 클라우드로 올립니다. TruthLens의 OCR은 사용자가 설정한 로컬 OCR 서버를 우선 사용하며, 직접 Gemini API 키를 제공한 경우에만 클라우드로 대체합니다. 클라우드를 쓸지 여부는 사용자의 결정입니다.';

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
      '다국어 AI 분류기（가중치 40%）: 문맥을 유지하는 제한된 단락 블록을 분석한 뒤 확률을 문장에 다시 매핑합니다.';

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
      '\"설정\"에서 각 엔진을 개별적으로 켜거나 끌 수 있고, 엔진 가중치를 조정할 수 있습니다. 다섯 개의 판정 구간은 고정 경계(20% / 40% / 60% / 80%)를 사용하며 변경할 수 없으므로, 같은 문서는 누구에게나 같은 판정이 나옵니다.';

  @override
  String get helpWorkflowStep3Title => '문서 업로드';

  @override
  String get helpWorkflowStep3Body =>
      '입력 방법은 세 가지입니다: 텍스트 직접 붙여넣기, 이미지 OCR 인식, 문서 가져오기(txt / md / pdf / docx / doc / odt). PDF 가져오기는 두 가지 텍스트 층 파서 결과를 비교해 깨진 문자를 걸러내며, 스캔 PDF는 OCR을 쓸 수 있을 때 쪽 단위로 인식합니다. 가져오면 파일명이 입력 제목 아래에 표시되고 보고서 제목에도 별도 줄로 나타납니다. 붙여넣거나 직접 입력하면 비어 있습니다.\n\nOCR은 설정한 로컬 서버를 우선하며, 직접 Gemini API 키를 제공한 경우에만 클라우드로 대체합니다.';

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
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation => '코드/수식 제외';

  @override
  String get helpWorkflowStep4ChipEnsemble => '4개 엔진 병렬 추론';

  @override
  String get helpWorkflowStep4ChipLiveProgress => '실시간 진행률';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'ESL 작문 보정';

  @override
  String get helpWorkflowStep4ChipStoppable => '언제든지 중지 가능';

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
  String get privacyWebOverview1 =>
      'TruthLens는 브라우저 탭에서 완전히 웹 앱으로 실행됩니다. 설치할 필요가 없으며, 문서 텍스트와 분석 결과는 기기를 벗어나지 않고, 다운로드된 감지 모델은 서버가 아닌 브라우저 자체의 샌드박스 저장소（OPFS）에만 캐시됩니다.';

  @override
  String get privacyWebOverview2 =>
      '이 페이지는 사용자가 적극적으로 가져오기, 스캔 또는 붙여넣기를 선택할 때만 파일, 이미지 또는 클립보드 콘텐츠를 읽습니다. 다른 탭, 다른 사이트의 데이터 또는 선택하지 않은 파일은 절대 읽지 않습니다.';

  @override
  String get privacySectionOverviewWeb => '개요';

  @override
  String get privacyRemoveWeb =>
      '브라우저 설정에서 이 사이트의 데이터를 지우기（또는 서버에 저장된 것이 없으므로 탭을 닫기만 해도 됩니다）';

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
      '3. 하이퍼링크 및 인용 문헌 실재성 검증: 기본적으로 켜져 있으며 \"설정\"에서 끌 수 있습니다. 켜져 있으면 문서에서 감지된 URL이나 참고 문헌 텍스트를 해당 URL 자체 또는 Crossref 공개 API로 직접 전송합니다. URL／DOI／서지 정보 텍스트만 전송하며 문서의 다른 내용은 포함하지 않습니다.';

  @override
  String get privacyNetwork4 =>
      '4. 웹 OCR 대체: 웹 버전에서만 OCR은 구성된 경우 로컬 OCR 서버를 먼저 사용합니다. Gemini API 키를 입력하도록 선택한 경우, 선택한 이미지와 OCR이 필요한 PDF 렌더링 페이지가 브라우저에서 Google의 Gemini API로 직접 전송됩니다. 키는 해당 브라우저의 로컬 저장소에만 저장됩니다.';

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

  @override
  String get workspaceModeSectionTitle => '작업 공간 모드';

  @override
  String get workspaceModeSectionSubtitle =>
      '원문, 실시간 분석, 최종 근거를 한 작업 공간에 배치하는 방식을 선택합니다.';

  @override
  String get workspaceModeOriginal => '기존 레이아웃';

  @override
  String get workspaceModeAuto => '자동';

  @override
  String get workspaceModeCommandGrid => '지휘 그리드';

  @override
  String get workspaceModeTimeline => '임무 타임라인';

  @override
  String get workspaceModeEvidence => '근거 캔버스';

  @override
  String get workspaceModeCosmicFuture => '코스믹 퓨처';

  @override
  String get workspaceModeSoftEducation => '소프트 에듀케이션';

  @override
  String get workspaceModeTooltip => '작업 공간 모드 전환';

  @override
  String get workspaceMoreMenuTooltip => '추가 옵션';

  @override
  String get workspaceLanguageMenuTitle => '언어';

  @override
  String get workspaceStageImport => '가져오기';

  @override
  String get workspaceStageParse => '파싱';

  @override
  String get workspaceStageAnalyze => '4개 엔진 분석';

  @override
  String get workspaceStageVerify => '검증';

  @override
  String get workspaceStageReport => '보고서';

  @override
  String get workspaceLiveFindings => '실시간 발견';

  @override
  String get workspaceTelemetry => '분석 텔레메트리';

  @override
  String get workspaceDocument => '문서 작업 공간';

  @override
  String get workspaceOverallProgress => '전체 진행률';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return '단계 $current/$total・$stage';
  }

  @override
  String get workspaceWaiting => '문서 대기 중';

  @override
  String get workspaceAnalyzing => '분석 진행 중';

  @override
  String get workspaceAnalysisComplete => '분석 완료';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '$done/$total개 모듈 완료 · $seconds초 경과 · 실행 중: $engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return '분석이 계속 진행 중이며 화면은 응답하고 있습니다. 지난 $seconds초 동안 완료된 모듈이 없습니다. 큰 문서나 로컬 모델은 시간이 더 걸릴 수 있습니다.';
  }

  @override
  String get workspaceAnalysisFailed =>
      '분석이 예기치 않게 중지되었습니다. 다시 시도하거나 모델 설정을 확인하세요.';

  @override
  String get workspaceNewAnalysis => '새 분석';

  @override
  String get workspaceStopAnalysis => '분석 중지';

  @override
  String get workspaceStopAnalysisTitle => '현재 분석을 중지할까요?';

  @override
  String get workspaceStopAnalysisBody =>
      '분석이 아직 진행 중입니다. 문서 텍스트는 유지되지만 완료되지 않은 결과는 저장되지 않습니다.';

  @override
  String get workspaceAnalysisStopped => '분석이 중지되었습니다. 문서 텍스트는 작업 공간에 유지됩니다.';

  @override
  String get workspaceSelectedEvidence => '선택한 근거';

  @override
  String get workspaceNoEvidence => '각 엔진이 완료되면 문장 근거가 여기에 표시됩니다.';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return '예비 AI 확률: $percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      '이 백분율은 이 문장 자체의 AI 신호이며 문서 전체의 판정이 아닙니다. 값이 높을수록 문구 패턴이 AI가 생성한 것처럼 보이고, 낮을수록 일반적인 인간의 글쓰기처럼 읽힙니다. 최종 보고서는 모든 문장을 엔진 가중치와 결합합니다.';

  @override
  String get workspaceSentenceSignalHeader => '문장별 AI 신호';

  @override
  String get workspaceSentenceColumnHeader => '문장';

  @override
  String get workspaceAiEvidenceIndexShort => 'index';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine은(는) 이번에 근거를 찾지 못해 투표에 참여하지 않았습니다(역할 가중치 $weight%). 자신이 맡은 관점에서 AI 흔적이 없었다는 뜻이며, 사람이 썼다고 판단한 것은 아닙니다.';
  }

  @override
  String reportEngineRelationshipDirectionalOnly(String engine, int weight) {
    return '$engine found only a weak directional signal. It is discounted for screening and does not count as threshold-qualified evidence (role weight cap $weight%).';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return '이번에는 $engine만 근거를 찾았고 나머지 엔진은 아무것도 발견하지 못했습니다. 결론이 단일 관점에만 기대고 있으므로 신뢰도는 그만큼 낮춰 보십시오.';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return '다른 $count개 엔진은 실행되었으나 근거를 찾지 못해 투표에서 제외했습니다. \'할 말이 없음\'이 \'사람이 쓴 것 같음\'으로 잘못 계산되지 않도록 하기 위함입니다.';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      '이 문서에는 언어 모델 혼란도를 반영하지 않았습니다. 혼란도 모델(DistilGPT2)은 영어로만 학습되어 중국어·일본어·한국어 텍스트에서는 언어의 예측 가능성이 아니라 바이트의 예측 가능성을 측정합니다. 라벨링된 데이터로 측정한 결과 이들 언어에서 사람과 AI를 구분하는 능력은 0%였으므로, 반영하면 거짓 양성만 늘어납니다.';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return '언어별 기준 집합: $breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return '언어 표시가 없는 이전 표본이 $count개 있어 어떤 언어의 기준 집합에도 넣을 수 없습니다. 원문을 보관하지 않으므로 나중에 언어를 알아낼 수 없기 때문입니다. 새 분석이 쌓이면서 교체됩니다.';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return '이 문서에는 \"$variant\"을 사용했습니다. 선택한 변형은 $language에 대해 검증되지 않았고, 이 모델은 검증되었습니다.';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '\"$variant\"은 다국어 모델이지만 $language에서 검증되지 않았습니다. 검증된 언어보다 근거가 약한 점수로 보십시오.';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '\"$variant\"은 $language를 포함하지 않습니다. 점수는 참고용이며 어느 방향의 근거도 되지 않습니다.';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      '언어 모델 혼란도를 반영하지 않았습니다. 이 문서의 언어를 판정할 수 없어 비교할 보정 기준값이 없기 때문입니다. 언어를 추측하면 잘못된 척도를 적용하게 되며, 그것이 바로 이 검사가 막으려는 오류입니다.';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return '언어 모델 혼란도를 반영하지 않았습니다. 사용 중인 모델 \"$model\"에는 $language의 기준값이 아직 측정되지 않았습니다. 보정된 척도가 없으면 원시 값은 아무 의미가 없으므로, 추측하지 않고 제외했습니다.';
  }

  @override
  String get inputNoEditingRecordHint =>
      '이 형식에는 편집 기록이 없습니다. PDF·이미지·붙여넣은 텍스트는 어떻게 작성되었는지의 이력을 남기지 않으므로, 분석은 전적으로 텍스트 통계에 의존합니다. 원본 .docx·.odt·.doc를 구할 수 있다면 그 편집 이력이 훨씬 강한 근거이며, 텍스트 통계와 달리 언어 모델이 발전해도 약해지지 않습니다.';

  @override
  String get reportLowScoreNotProofOfHuman =>
      '점수가 낮다고 해서 사람이 썼다는 확인은 아닙니다. 이번에는 출처 근거가 없어 이 판정은 텍스트 통계에만 기대고 있습니다. 텍스트 통계는 정형화된 글은 안정적으로 잡아내지만, 현행 모델이 잘 쓴 결과물은 잡아내지 못합니다.';

  @override
  String get reportProvenanceContradictsLowScore =>
      '파일 자체의 편집 기록이 이 낮은 점수와 모순됩니다. 출처 근거는 언어 모델이 발전해도 약해지지 않지만, 텍스트 통계는 현행 모델이 잘 쓴 결과물을 가려내지 못합니다. 위의 점수로 결론을 내리기 전에 아래의 출처 근거를 먼저 확인하십시오.';

  @override
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  ) {
    return '$total개 단락 중 $paragraphs개가 같은 편집 배치에 속하며 전체 단어의 $percent%를 차지합니다. 파일에 다른 편집 배치가 있더라도, 해당 부분은 한 번에 작성되었거나 붙여넣어진 형태와 일치합니다.';
  }

  @override
  String findingEvasionDetected(int count) {
    return '문자 수준의 회피 흔적이 $count건 발견되었습니다(폭 없는 문자, 모양이 같은 이체 문자, 방향 제어 문자). 일반적인 작성 도구는 이런 것을 만들지 않습니다. 탐지를 피하려고 누군가 텍스트를 가공했습니다.';
  }

  @override
  String findingCitationsNotFound(int notFound, int total) {
    return '인용된 $total건 중 $notFound건이 조회한 어떤 문헌 데이터베이스에서도 발견되지 않았습니다. 없는 문헌을 인용하는 것은 언어 모델의 행동이며, 문체와 달리 논문의 존재 여부는 검증 가능한 사실입니다.';
  }

  @override
  String findingCitationsAllVerified(int total) {
    return '인용된 $total건 모두 공개 데이터베이스에서 확인되었습니다.';
  }

  @override
  String findingEditingRecordNormal(int minutes, int revisions) {
    return '파일에는 $revisions회 저장에 걸쳐 $minutes분의 편집 시간이 기록되어 있어, 본문이 이 문서에서 작성되었다는 것과 일치합니다.';
  }

  @override
  String findingPublicationPredatesGenerativeAi(String doi, int year) {
    return 'Source DOI $doi matches this document and was registered in $year, before modern generative-AI writing systems.';
  }

  @override
  String findingPublicationIdentityMismatch(String doi) {
    return 'Source DOI $doi resolves, but its registered title does not match this document. Verify the document identity before relying on it.';
  }

  @override
  String get integratedStabilityUnavailable =>
      'Segment stability unavailable · no sentence-level evidence voted';

  @override
  String get integratedNeutralBaseline =>
      'No authorship-specific evidence strong enough for escalation was found. The result shown is the best directional screening available, not a claim that AI and human evidence are evenly split.';

  @override
  String get reportVerifiableFindingsTitle => '검증 가능한 사실';

  @override
  String get reportVerifiableFindingsSubtitle =>
      '아래 각 항목은 독립적으로 확인할 수 있습니다. 확률과 달리 언어 모델이 발전해도 약해지지 않습니다.';

  @override
  String findingBulkPaste(int characters) {
    return '입력 중 $characters자를 한 번에 붙여넣은 기록이 있습니다. 텍스트가 편집기에 어떻게 나타나는지는 언어 모델이 위조할 수 없습니다. 이 부분은 여기서 입력된 것이 아닙니다.';
  }

  @override
  String findingWrittenInApp(int minutes, int deleted) {
    return '이 앱에서 $minutes분에 걸쳐 입력되었고, 그 과정에서 $deleted자를 수정했습니다. 여기서 이루어진 작성은 어떤 언어 모델도 재현할 수 없는 기록을 남깁니다.';
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
  String get integratedAssessmentTitle => 'Integrated authorship assessment';

  @override
  String get integratedInsufficientEvidence =>
      'No quantifiable authorship signal';

  @override
  String get integratedLikelyAi => 'More likely AI-generated';

  @override
  String get integratedLikelyMixed => 'More likely human-AI mixed';

  @override
  String get integratedLikelyHuman => 'More likely not AI-generated';

  @override
  String get integratedBalanced => 'No clear AI-dominant signal detected';

  @override
  String get integratedPreliminaryAi => 'Currently leans AI, near the boundary';

  @override
  String get integratedPreliminaryHuman =>
      'Currently leans human, near the boundary';

  @override
  String integratedLikelihoodLabel(int percent) {
    return 'AI evidence index: $percent/100';
  }

  @override
  String get integratedLikelihoodUnavailable =>
      'AI evidence index: not estimable';

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
  String integratedEvidenceSufficiency(int percent, String tier) {
    return 'Evidence sufficiency: $percent/100 · $tier';
  }

  @override
  String get integratedEvidenceTierScreening => 'preliminary screening';

  @override
  String get integratedEvidenceTierReference => 'reference-level';

  @override
  String get integratedEvidenceTierStrong => 'well supported';

  @override
  String integratedBoundaryAi(int index, int gap) {
    return 'Index $index is only a weak AI-side direction and remains $gap points below the 60-point escalation line. It has not established AI authorship.';
  }

  @override
  String integratedBoundaryHuman(int index, int gap) {
    return 'Index $index leans human and remains $gap points below the 60-point AI escalation line, but the limited evidence cannot rule out AI assistance.';
  }

  @override
  String integratedEvidenceCoverage(int families, int coverage) {
    return 'Directional signal families: $families/4 · applicability coverage $coverage%';
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
      'These bars show diagnostic signals from the four text engines. Related engines are merged by family, including conservatively discounted human-side classifier output, before language/domain applicability and calibration reliability are applied. The direction answers which explanation is better supported; the separate AI evidence gate answers whether support is strong enough for escalation.';

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
    return 'After weighting the available evidence, the document is “$direction” (AI evidence index $percent/100, $confidence confidence).';
  }

  @override
  String telemetryIntegratedUnavailable(String direction, String confidence) {
    return 'The available modules did not produce a quantifiable authorship direction (“$direction”, $confidence confidence); no numeric index was issued.';
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
    return 'Pre-analysis confidence baseline: $level';
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
