// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonDelete => '削除';

  @override
  String get commonClose => '閉じる';

  @override
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

  @override
  String get verdictHuman => '人間が執筆';

  @override
  String get verdictLikelyHuman => '人間の可能性が高い';

  @override
  String get verdictMixed => '混合コンテンツ';

  @override
  String get verdictLikelyAi => 'AIの可能性が高い';

  @override
  String get verdictAi => 'AI生成';

  @override
  String get inputSubtitle => 'テキストを貼り付けるか入力して、AI生成コンテンツを検出';

  @override
  String get inputHint => '検出したいテキストを入力または貼り付けてください…';

  @override
  String get inputHistoryTooltip => '履歴';

  @override
  String get inputHelpTooltip => '使い方ガイド';

  @override
  String get inputPrivacyTooltip => 'プライバシーポリシー';

  @override
  String get inputSettingsTooltip => '設定';

  @override
  String get inputPasteButton => '貼り付け';

  @override
  String get inputOcrButton => '画像OCR';

  @override
  String get inputImportButton => 'ファイルを読み込む';

  @override
  String get inputStartButton => '検出を開始';

  @override
  String get inputClearTooltip => '内容をクリア';

  @override
  String get inputTooShortSnackbar => '信頼できる分析のため、40文字以上入力してください';

  @override
  String get inputOcrUnsupported => 'このプラットフォームはOCR文字認識に対応していません';

  @override
  String get inputOcrRecognizing => '認識中…';

  @override
  String get inputOcrNoText => '画像からテキストを認識できませんでした';

  @override
  String inputOcrRecognized(int count) {
    return '$count 文字を認識しました';
  }

  @override
  String inputImportNoText(String fileName) {
    return '「$fileName」に読み取り可能なテキストがありません';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '「$fileName」を読み込みました（$count 文字）';
  }

  @override
  String inputPdfOcrProgress(int page, int total) {
    return 'PDFのテキスト層が利用できません。OCRで$totalページ中$pageページ目を認識しています…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return '「$fileName」をPDF OCRでインポートしました（$count文字）';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '「$fileName」には信頼できるテキスト層がありません。Web OCRを設定するか、ネイティブOCRに対応したアプリ版をご利用のうえ、再度インポートしてください。';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '「$fileName」はOCRが必要ですが、$maxページの安全上限を超えています。PDFを分割してから、それぞれをインポートしてください。';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return '「$fileName」を確実に読み取れませんでした。破損している、パスワードで保護されている、または設定されたOCRサービスでサポートされていない可能性があります。';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '「$fileName」は旧形式の .doc ファイルのため、テキストを確実に抽出できませんでした。Word で .docx として保存するか、PDF に書き出してから再度インポートしてください。';
  }

  @override
  String inputActiveModel(String modelId) {
    return 'モデル：$modelId';
  }

  @override
  String get inputNoModel => 'モデル未インストール（統計・スタイル分析のみ）';

  @override
  String inputCharCount(int count) {
    return '$count 文字';
  }

  @override
  String get analysisAppBarTitle => '分析中';

  @override
  String get analysisEngineTransformer => 'Transformer分類器';

  @override
  String get analysisEngineStatistical => '統計特徴分析';

  @override
  String get analysisEngineStylometry => '文体特徴分析';

  @override
  String get analysisEngineAdversarial => '敵対的防御';

  @override
  String analysisProgressSemantics(int done, int total) {
    return '分析実行中、$total 個中 $done 個のエンジンが完了';
  }

  @override
  String get analysisDoneSemantics => '完了';

  @override
  String analysisPreliminaryResult(int percent) {
    return '初期結果：AI確率 $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return '初期結果：AI確率 $percent%（精査中…）';
  }

  @override
  String get engineNameAdversarialFull => '敵対的防御（言い換え検出）';

  @override
  String get modelNecessityText =>
      'ニューラルネットワーク検出モデルをダウンロードしていない場合でも、TruthLensは動作しますが、統計分析とスタイル分析のみとなり、精度と多言語対応が限定されます。モデルをダウンロードすると、多言語Transformer分類器がアンサンブル投票に加わり、判定精度と信頼性が大幅に向上します。モデルはデバイス上で実行され、ダウンロード後は一切のコンテンツをアップロードしません。';

  @override
  String get modelPromptTitle => '完全な分析のために検出モデルのダウンロードをお勧めします';

  @override
  String get modelPromptDontRemind => '今後表示しない';

  @override
  String get modelPromptSkip => '後でスキップ';

  @override
  String get modelPromptDownload => 'ダウンロードへ';

  @override
  String get firstRunModelPromptTitle => '検出モデルを追加しますか？';

  @override
  String get firstRunModelPromptBody =>
      'TruthLens はこのままでも動作します。統計エンジンと文体エンジンはすでに利用可能です。端末内で動くニューラルモデルを追加すると、多言語分類器がアンサンブル投票に加わり、精度と対応言語が大きく向上します。モデルはすべてブラウザー内で実行され、文書がアップロードされることはありません。「設定 → AI モデル管理」から後で決めることもできます。';

  @override
  String get firstRunModelPromptLater => '今はしない';

  @override
  String get firstRunModelPromptGo => 'モデルを選ぶ';

  @override
  String get modernChineseModelPromptTitle => '中国語の検出精度を上げる';

  @override
  String get modernChineseModelPromptBody =>
      'この中国語文書には現在、現代中国語検出器（約 98 MB）がありません。従来の多言語モデルは初期世代のテキストで較正されており、DeepSeek・Gemini・GPT 系の現在の中国語表現を見逃すことがあります。より適切に較正された結果を得るには専用の端末内モデルをダウンロードしてください。弱い言語横断のフォールバックのまま続けることもできます。';

  @override
  String get onboardingWelcomeTitle => 'TruthLensへようこそ';

  @override
  String get onboardingHeadline => 'デバイス上でのAIコンテンツ検出';

  @override
  String get onboardingDetectedDevice => '検出されたデバイス';

  @override
  String get onboardingChooseModel => 'ダウンロードするモデルを選択';

  @override
  String get onboardingRecommendHint =>
      'お使いのハードウェアに基づいて「推奨」マークが表示されています。他のオプションも選択できます。';

  @override
  String get onboardingBundleTitle => 'この端末向けの推奨構成';

  @override
  String onboardingBundleSummary(int count, String size) {
    return 'モデル $count 個 · 合計 $size MB';
  }

  @override
  String onboardingBundleStorage(String available, String remaining) {
    return 'ブラウザーの保存容量：使用可能 $available MB、ダウンロード後の残りは約 $remaining MB';
  }

  @override
  String get onboardingStorageNotPersisted =>
      'ダウンロード済みのモデルは、まだ自動削除から保護されていません。ディスク容量が不足するとブラウザーが回収することがあり、その場合は再ダウンロードが必要になります。TruthLens をアプリとしてインストールすると、ブラウザーが保持する可能性が大きく高まります。';

  @override
  String get onboardingInstallAppButton => 'アプリとしてインストール';

  @override
  String get onboardingSkipButton => '後で決める（モデルなしで統計・スタイル分析のみ使用）';

  @override
  String get onboardingSkipHint =>
      'スキップしても「設定 → AIモデル管理」からいつでもダウンロードできます。モデルが必要な分析を使う際にも再度お知らせします。';

  @override
  String get modelListCustomImportedLabel => 'カスタムインポートされたモデル：';

  @override
  String get modelListActiveChip => '使用中';

  @override
  String get modelListRecommendedChip => '推奨';

  @override
  String get modelListCustomChip => 'カスタム';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · 必要RAM ${ram}GB · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'サイズ: $size · Tokenizer: $tokenizer · AIラベルインデックス: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'ダウンロード中… $percent%（$downloaded / $total）';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'ダウンロード（$size）';
  }

  @override
  String get modelListComingSoonChip => '近日公開';

  @override
  String get modelListSetActiveButton => '使用中に設定';

  @override
  String get modelListUpdateButton => '更新';

  @override
  String get modelListDeleteTooltip => '削除';

  @override
  String get modelListPageButton => 'モデルページ';

  @override
  String get modelListMayExceedMemory => 'デバイスのメモリを超える可能性があります';

  @override
  String modelListFailedPrefix(String error) {
    return '失敗：$error';
  }

  @override
  String get modelCatalogLoadFailed => 'モデルカタログを読み込めませんでした';

  @override
  String get modelCatalogEmpty => '利用可能なモデルがありません';

  @override
  String modelDownloadPathChip(String label) {
    return '$label のダウンロードパス';
  }

  @override
  String get modelDownloadPathModelFile => 'モデルファイル';

  @override
  String get modelDownloadPathCopied => 'ダウンロードパスをコピーしました';

  @override
  String settingsSaveFailed(String error) {
    return '設定の保存に失敗しました：$error';
  }

  @override
  String get modelListDeleteConfirmTitle => 'モデルを削除しますか？';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return '「$name」（$size）を削除します。再度使用するには再ダウンロードが必要です。';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'カスタムインポートされた「$name」（$size）を削除します。再度使用するには再インポートが必要です。';
  }

  @override
  String get modelImportAppBarTitle => 'カスタムONNXモデルのインポート';

  @override
  String get modelImportStep1Title => '1. ONNXモデルファイルを選択';

  @override
  String modelImportSelectedFile(String name) {
    return '選択済み: $name';
  }

  @override
  String get modelImportNoFileSelected => 'モデルファイルが選択されていません (.onnx)';

  @override
  String get modelImportBrowseButton => '参照';

  @override
  String get modelImportCheckingDuplicate => '同じファイルが既にインポートされているか確認中…';

  @override
  String get modelImportDuplicateTitle => '同一内容のモデルが既にインポートされています';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'このファイルは「$name」（役割：$role）と内容が完全に一致しています。使用中モデルを切り替えたいだけの場合は、「AIモデル管理」で直接「使用中に設定」できます。再インポートは不要です。以下の手順を続けることもできます。';
  }

  @override
  String get modelImportStep2Title => '2. パラメータ設定';

  @override
  String get modelImportNameLabel => 'モデル表示名';

  @override
  String get modelImportNameRequired => '名前を空にすることはできません';

  @override
  String get modelImportRoleLabel => '対象エンジンの役割';

  @override
  String get modelImportTokenizerTypeLabel => 'Tokenizerの種類';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => 'なし（Tokenizerなし・文字単位）';

  @override
  String get modelImportNoTokenizerSelected =>
      'Tokenizerファイルが選択されていません (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return '選択済み: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'AIラベル出力インデックス';

  @override
  String get modelImportIndex0 => 'インデックス 0（例：RoBERTa）';

  @override
  String get modelImportIndex1 => 'インデックス 1（例：DistilBERT）';

  @override
  String get modelImportStep3Title => '3. テストと検証';

  @override
  String get modelImportTestInputLabel => 'テスト用入力テキスト';

  @override
  String get modelImportRunTestButton => 'テスト推論を実行';

  @override
  String get modelImportResultLabel => '推論結果（AI確率）:';

  @override
  String modelImportTestFailed(String error) {
    return 'テスト失敗: $error';
  }

  @override
  String get modelImportConfirmButton => 'インポートを確定してモデルを有効化';

  @override
  String get modelImportSelectTokenizerFirst => '先にTokenizerファイルを選択してください';

  @override
  String get modelImportSelectTokenizer => 'Tokenizerファイルを選択してください';

  @override
  String get modelImportSuccessSnackbar => 'モデルのインポートに成功し、使用中モデルとして自動設定されました！';

  @override
  String get modelImportFailedSnackbar => 'モデルのインポートに失敗しました。権限またはログを確認してください';

  @override
  String get settingsAppBarTitle => '設定';

  @override
  String get settingsEslTitle => 'ESL（非ネイティブ）バイアス補正';

  @override
  String get settingsEslSubtitle => '非ネイティブの文体を検出すると、統計モデルの重みを自動的に下げます';

  @override
  String get settingsEngineSectionTitle => 'サブ検出エンジン設定（アンサンブル）';

  @override
  String get settingsEngineTransformerTitle => '多言語AI分類器（Transformer）';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Transformerニューラルネットワークモデルでオンデバイスのai確率予測を行います';

  @override
  String get settingsEngineStatisticalTitle => '統計分析エンジン（Statistical）';

  @override
  String get settingsEngineStatisticalSubtitle =>
      '文長のばらつき、Burstiness、PPLにより言語の規則性を判定します';

  @override
  String get settingsEngineStylometryTitle => '文体特徴分析（Stylometry）';

  @override
  String get settingsEngineStylometrySubtitle =>
      '意味の流暢さ、繰り返し文型、接続詞の使用などの文体的特徴を分析します';

  @override
  String get settingsEngineAdversarialTitle => '敵対的言い換え検出（Adversarial）';

  @override
  String get settingsEngineAdversarialSubtitle => '機械による言い換えやAI痕跡除去処理を検出します';

  @override
  String get settingsEngineWeightsTitle => 'AIモデルの重み';

  @override
  String get settingsEngineWeightsSubtitle =>
      '各エンジンが総合結果に与える影響を設定します。保存するには合計を100%にしてください。';

  @override
  String get settingsEngineInfoTooltip => 'このエンジンの役割';

  @override
  String get settingsEngineTransformerHelp =>
      '多言語Transformerで文脈を保持した段落ブロックを評価し、詳細レポート用にブロックスコアを各文へ対応付けます。設定した重みが影響度を、AI信号が実際の寄与度を決定します。';

  @override
  String get settingsEngineStatisticalHelp =>
      '困惑度、予測可能性、バースト性、文長の変動を測定します。ESL補正により実効重みが下がる場合があります。';

  @override
  String get settingsEngineStylometryHelp =>
      '書き出しの反復、定型的な接続表現、過剰な箇条書きなど説明可能な文体特徴を確認します。特徴がなければ信号は0%です。';

  @override
  String get settingsEngineAdversarialHelp =>
      '言い換えやAI痕跡除去が行われた文章を検出します。低い値は弱い残留証拠であり、陽性判定ではありません。';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return '合計：$total% — 保存できます';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return '合計：$total% — 100%に調整してください';
  }

  @override
  String get settingsEngineWeightsSave => '重みを保存';

  @override
  String get settingsEngineWeightsSaved => 'AIモデルの重みをこの端末に保存しました';

  @override
  String get settingsEngineWeightsRestoreDefaults => '初期値に戻す';

  @override
  String get engineReasonDisabledByUser => 'ユーザーが設定でこのエンジンを無効にしています';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model：$total文のうち強いAI閾値を超えた文はありません。校正後の弱い信号は$percent%です';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'AI信号 $percent%';
  }

  @override
  String reportEngineDirectionalIndex(int percent) {
    return '弱い方向性 $percent/100';
  }

  @override
  String get reportEngineNoDirectionalSignal => '方向性シグナルなし';

  @override
  String get reportEngineSignalExplanation =>
      'AI信号は、この文書に対する各エンジンの確率です。設定した重みが影響度を決め、表示される寄与ポイントの合計が総合AI確率と正確に一致するよう配分されます。「未検出」は強い信号のしきい値60%未満を意味し、必ずしも数値が0という意味ではありません。';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return '$total文のいずれも強い言い換え信号のしきい値を超えませんでした。校正後の弱い信号は$percent%です';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$total文中$count文が強い言い換え信号のしきい値を超えました。校正後の文書信号は$percent%です';
  }

  @override
  String get settingsLinkVerificationTitle => 'ハイパーリンク・参考文献の実在性検証';

  @override
  String get settingsLinkVerificationSubtitle =>
      'レポートは、文書内で検出されたURLや参考文献が実在するかを確認するために接続します（AI生成コンテンツには、もっともらしいが実在しない引用がよく含まれます）。DOI形式の学術リンクと、リンクのない「著者名—年」形式の参考文献の両方が、Crossrefの公開登録データと照合されます。コア AI 検出モデルは引き続き完全にデバイス上で実行され、文書内容は送信されません。接続はこの検証とモデル更新確認にのみ使用され、ここでオフにできます。';

  @override
  String get settingsThemeTitle => '外観テーマ';

  @override
  String get settingsLanguageTitle => '言語';

  @override
  String get settingsLanguageSubtitle => 'アプリの表示言語を選択';

  @override
  String get settingsModelManagementTitle => 'AIモデル管理';

  @override
  String get settingsModelManagementSubtitle =>
      '検出モデルとレポート生成LLMをダウンロードして、完全な推論機能を有効化';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'モデルの更新が見つかりました。確認をお勧めします';

  @override
  String get settingsOpenButton => '開く';

  @override
  String get settingsCustomImportTitle => 'カスタムONNXモデルのインポートとテスト';

  @override
  String get settingsCustomImportSubtitle =>
      'ローカルのカスタムONNXモデルとTokenizer設定をインポートして推論テストを実行';

  @override
  String get modelImportWebUnsupported =>
      'カスタムモデルのインポートはWeb版ではまだサポートされていません。アプリ版をご利用ください。';

  @override
  String get settingsModelManagerAppBarTitle => 'AIモデル管理';

  @override
  String get settingsImportTooltip => 'ローカルのONNXモデルをインポート';

  @override
  String settingsDeviceLabel(String summary) {
    return 'デバイス：$summary';
  }

  @override
  String get historyAppBarTitle => '履歴';

  @override
  String get historyClearAllTooltip => 'すべてクリア';

  @override
  String get historySearchHint => '履歴を検索…';

  @override
  String get historyUntitledDocument => '無題の文書';

  @override
  String get historyDeletedSnackbar => 'この記録を削除しました';

  @override
  String get historyClearAllTitle => 'すべての履歴をクリアしますか？';

  @override
  String historyClearAllBody(int count) {
    return '$count 件すべての記録を削除します。この操作は元に戻せません。';
  }

  @override
  String get historyClearButton => 'クリア';

  @override
  String get historyDeleteEntryTitle => 'この記録を削除しますか？';

  @override
  String get historyReanalyzeTooltip => '再分析';

  @override
  String get historyEmptyDefault => '検出履歴はまだありません';

  @override
  String historyEmptySearch(String query) {
    return '「$query」に一致する記録が見つかりません';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict、AI確率 $percent%、$time。$text';
  }

  @override
  String get reportAppBarTitle => '検出レポート';

  @override
  String get reportExportTooltip => 'レポートをエクスポート';

  @override
  String get reportHomeTooltip => 'ホームに戻る';

  @override
  String get reportGeneratingTitle => 'レポートを生成中…';

  @override
  String get reportSourceLlm => 'AI生成レポート';

  @override
  String get reportSourceTemplate => 'テンプレート生成レポート';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '合計 $total 文 · AIの疑い $ai 文 · 人間 $human 文 · 所要時間 $seconds 秒';
  }

  @override
  String get reportExportPdf => 'PDFレポートをエクスポート';

  @override
  String get reportExportCsv => 'CSVデータをエクスポート';

  @override
  String get reportExportJson => 'JSONをエクスポート（システム連携）';

  @override
  String get reportExportPng => 'サマリーカードをエクスポート（PNG）';

  @override
  String reportExported(String path) {
    return 'エクスポート完了：$path';
  }

  @override
  String reportExportFailed(String error) {
    return 'エクスポート失敗：$error';
  }

  @override
  String get reportEngineWeightLabel => '重み';

  @override
  String get privacySealNoticeText =>
      'TruthLens ゼロクラウドプライバシー認証：すべての推論処理はデバイス上で完了し、クラウド保存はありません。';

  @override
  String get reportModelCalibrationTitle => 'モデルベンチマーク自動キャリブレーション';

  @override
  String get reportCommunityDiscoveredTag => 'コミュニティモデル (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => 'エンジン内訳';

  @override
  String get reportEngineNotInstalled => '未インストール';

  @override
  String get reportEngineLoadFailedBadge => '読み込み失敗';

  @override
  String get reportEngineAnalysisLevelTitle => 'エンジン分析レイヤー';

  @override
  String get reportVerdictAiLikelihood => 'AI寄り';

  @override
  String get reportVerdictHumanLikelihood => '人間による執筆';

  @override
  String get reportRadarRoleTransformer => 'Transformer 分類器';

  @override
  String get reportRadarRoleStatistical => '統計分析';

  @override
  String get reportRadarRoleStylometry => '文体分析';

  @override
  String get reportRadarRoleAdversarial => '敵対的防御';

  @override
  String get reportRadarAxisTransformer => '文分類';

  @override
  String get reportRadarAxisStatistical => '言語の規則性';

  @override
  String get reportRadarAxisStylometry => '文体';

  @override
  String get reportRadarAxisAdversarial => '書き換え防御';

  @override
  String get reportVerdictBadgeTitle => '総合判定';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return '全体AI確率 $percent%';
  }

  @override
  String get reportVerdictHintHuman => 'ほとんどのエンジン信号は自然な人間の文章に偏っています。';

  @override
  String get reportVerdictHintLikelyHuman => '全体的に人間寄りですが、わずかにモデルの不確実性が残っています。';

  @override
  String get reportVerdictHintMixed => 'エンジンの信号が分かれています。詳細分析と併せてご確認ください。';

  @override
  String get reportVerdictHintLikelyAi => '複数の指標がAIに偏っています。スコアの高い箇所を確認してください。';

  @override
  String get reportVerdictHintAi => '全体的な信号はAI生成または書き換えに強く偏っています。';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return '総合判定：$verdict、全体AI確率 $percent%。';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return '最も強い単一シグナル：$label（$percent%）。ただし最終結果は各エンジンの重みを統合したものであり、単一エンジンの結論ではありません。';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return '現在最大の加重寄与は $label（約 $points パーセントポイント）によるものです。';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '「明確なAI文体は検出されませんでした」は、文体エンジンが固定的な文型や接続語パターンを見つけなかったことのみを意味します。他のモデルは言語の規則性、文分類、書き換えシグナルによって全体スコアを引き上げる可能性があります。';

  @override
  String get reportSynthesisModelGap =>
      '一部のエンジンが参加しなかった場合は、まずモデル管理で「推奨分析モデルを補完」を使用してください。それでも失敗する場合、詳細分析でモデル欠落、非対応トークナイザー、ファイル欠落、Web/ONNX Runtimeの互換性制限のいずれが原因かが示されます。';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label はこの加重投票に参加しなかったため、この項目は0%と表示されます。$hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return '役割の重み $weight%、全体スコアへの寄与は約 $points パーセントポイント$variantText。';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return '（$count 個のモデルバリアントを統合）';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label はこの投票に参加しませんでした。';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label は追加のテキスト説明を返しませんでした。';
  }

  @override
  String get reportEngineResolutionTransformer =>
      '解決策：モデル管理で多言語Transformerをダウンロードして有効化してください。すでにダウンロード済みの場合は、モデルとトークナイザーを再ダウンロードしてください。';

  @override
  String get reportEngineResolutionAdversarial =>
      '解決策：モデル管理で言い換え検出モデルとトークナイザーを再ダウンロードしてください。Web版ではBigInt互換性修正版に更新してから再度分析してください。';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason。原因：Web版のONNX Runtimeが返したBigIntテンソルを旧ブリッジが変換できませんでした。修正版に更新して再度分析してください。';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason。解決策：カタログ内のモデルに切り替えるか、モデルとトークナイザーを再ダウンロードしてください。';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason。解決策：モデル管理を開き、「推奨分析モデルを補完」をタップして、多言語Transformerがアクティブとしてマークされていることを確認してください。';
  }

  @override
  String get reportDetailAnalysisTitle => '詳細分析';

  @override
  String get reportNoEngineData => 'エンジンデータなし';

  @override
  String get ocrGeminiKeyRequired => '先に Gemini API キーを入力してください。';

  @override
  String get ocrGeminiKeyValid => 'Gemini API キーは有効で接続できます。';

  @override
  String get ocrGeminiKeyUnreachable => 'Gemini API に接続できません。キーをご確認ください。';

  @override
  String get ocrStatusLocalUnset => 'ローカル OCR：エンドポイント未設定';

  @override
  String get ocrStatusLocalUntested => 'ローカル OCR：エンドポイント設定済み、未テスト';

  @override
  String get ocrStatusLocalTesting => 'ローカル OCR：接続をテスト中';

  @override
  String get ocrStatusLocalReady => 'ローカル OCR：利用可能';

  @override
  String get ocrStatusLocalUnreachable => 'ローカル OCR：接続できません';

  @override
  String get ocrStatusGeminiUnset => 'Gemini：キー未設定';

  @override
  String get ocrStatusGeminiUntested => 'Gemini：キー設定済み、未テスト';

  @override
  String get ocrStatusGeminiVerifying => 'Gemini：キーを検証中';

  @override
  String get ocrStatusGeminiValid => 'Gemini：キーは有効';

  @override
  String get ocrStatusGeminiInvalid => 'Gemini：無効または接続できません';

  @override
  String get ocrActiveLocalVerified => '有効なエンジン：ローカル OCR サーバー（テスト済み）';

  @override
  String get ocrActiveLocalUntested => '有効なエンジン：ローカル OCR サーバー（未テスト）';

  @override
  String get ocrActiveGeminiVerified => '有効なエンジン：Gemini API（テスト済み）';

  @override
  String get ocrActiveGeminiUntested => '有効なエンジン：Gemini API（未テスト）';

  @override
  String get ocrActiveNone => 'OCR エンジンが未設定です';

  @override
  String get ocrDetectAndDownload => 'システムを検出してインストーラーを取得';

  @override
  String get ocrAutoInstallUnavailable => '自動インストールは利用できません';

  @override
  String get ocrUnsupportedPlatformBody =>
      '現在のプラットフォームはワンクリック導入に対応していません。Web ブラウザーは iOS、Android、Linux、不明なシステム上でローカル OCR サービスを導入・起動できません。\n\n選択肢：\n1. macOS または Windows のデスクトップブラウザーでこのウィザードを使う。\n2. Gemini API キーを Web OCR の代替として使う。\n3. 上級者は OCR プロジェクトを開き、互換の /ocr エンドポイントを自分で用意して URL をここに入力する。';

  @override
  String ocrInstallerReady(String osName) {
    return '$osName 用インストーラーの準備ができました';
  }

  @override
  String get ocrRunInstructionMac => 'bash ~/Downloads/setup_and_run_ocr.sh';

  @override
  String get ocrRunInstructionWindows =>
      'Downloads フォルダーの setup_and_run_ocr.bat をダブルクリック';

  @override
  String ocrAssistantDownloadedBody(
    String osName,
    String endpoint,
    String fileName,
    String runInstruction,
    String testButton,
  ) {
    return '$osName を検出し、ローカルエンドポイントを自動入力しました：\n$endpoint\n\nブラウザーが $fileName のダウンロードを開始しました。ブラウザーのセキュリティ制限により、TruthLens Web がインストーラーを実行したり起動設定を変更したりすることはできません。\n\n次の手順：\n1. ダウンロードしたインストーラーを実行：$runInstruction\n2. ターミナルまたはウィンドウに OCR サービスの準備完了が表示されるまで待つ。\n3. ここに戻って「$testButton」を選ぶ。\n\nテスト成功後、画像 OCR はこのローカルサービスを優先します。Gemini API キーを別途設定しない限り、画像が Gemini に送られることはありません。';
  }

  @override
  String get reportEngineNotParticipated => '不参加';

  @override
  String get reportAiContentReportTitle => 'AIコンテンツ検出レポート';

  @override
  String reportAnalysisTimeLabel(String time) {
    return '分析時間：$time';
  }

  @override
  String get reportDownloadPdfButton => 'PDFをダウンロード';

  @override
  String get reportSuspiciousLocationsTitle => '疑わしいコンテンツの位置';

  @override
  String reportSentenceCount(int count) {
    return '$count 文';
  }

  @override
  String get reportAiProbabilityPrefix => 'AI確率：';

  @override
  String get helpAdvantage5 =>
      '文書来歴の鑑識：.docx／.odt／.doc の編集記録（編集時間、保存回数、編集バッチの分散度）を読み取ります。これは本文の判定とは独立した証拠であり、AI確率とは分けて表示されます。PDFや画像はそもそも編集履歴を持たないため、この種の証拠は提供できません。';

  @override
  String get helpAdvantage6 =>
      '根拠が乏しいときは誠実に判定を見送ります：分析可能な文が5文未満、本文が100語未満、参加エンジンが2個未満、エンジン間の差が60パーセントポイント超のいずれかで「証拠が不十分なため判定しません」と表示します。誤った告発の多くは、根拠の乏しい入力に自信ありげな数字を返すことから始まります。';

  @override
  String get settingsAiSampleTitle => 'AI生成サンプルを追加';

  @override
  String get settingsAiSampleSubtitle =>
      'バックグラウンドのキャリブレーションが自動で集めるのは人間のサンプルだけです。学習によるエンジン重みを有効にするには、AI生成と分かっている文章も必要です。貼り付けまたは読み込むと、すぐに分析してAIサンプルとして登録します。';

  @override
  String get settingsAiSampleFromClipboard => 'クリップボードから貼り付け';

  @override
  String get settingsAiSampleFromFile => '文書を読み込む';

  @override
  String get settingsAiSampleAnalyzing => '分析中…';

  @override
  String settingsAiSampleAdded(int count) {
    return 'AIサンプルを追加しました（現在$count件）';
  }

  @override
  String get settingsAiSampleTooShort => 'サンプルにするには短すぎます（最低100語必要）';

  @override
  String get settingsAiSampleFailed => '利用できる内容が取得できませんでした';

  @override
  String get helpFormatCoverageTitle => '2-a. 来歴証拠の形式上の制限';

  @override
  String get helpFormatCoverage =>
      '**重要な制限：編集記録を持つのは .docx と .odt だけです。**\n\n| 入力元 | 編集記録 |\n|---|---|\n| .docx／.odt | ✅ あり |\n| .pdf | ❌ 形式上そもそも編集履歴を持たない |\n| .doc（旧版） | ✅ あり（OLE2 SummaryInformation） |\n| .txt／.md | ❌ コンテナなし |\n| 画像OCR | ❌ 画素しか残らない |\n| 貼り付け | ❌ ファイルが存在しない |\n\nこれは第3の柱に直接関わります。**編集記録を持つ文書だけが、統計的保証のある基準セットへ自動的に加わります。** 受け取るものがすべてPDFであれば、その基準セットは決して増えず、保証のない参考サンプルだけが溜まっていきます。\n\n来歴の証拠と自動キャリブレーションを実際に機能させるには、印刷・書き出しされたPDFではなく、作成者から .docx または .odt の元ファイルを集めてください。これはソフトウェアで回避できる制限ではなく、運用上の要件です。PDFは出力形式であり、「どのように書かれたか」を記録しません。';

  @override
  String provenanceUnsupportedFormat(String format) {
    return '$format という形式はそもそも編集履歴を持ちません。したがって「記録が消された」のではなく、最初から存在しないということです。編集時間・保存回数・編集バッチを記録するのは .docx と .odt だけです。';
  }

  @override
  String get provenanceStripped =>
      '対応形式ですが、ファイル内に編集記録が見つかりません。別名保存、オンライン変換、Googleドキュメントからのエクスポートなど、記録をリセットする操作を経た可能性が高いです。';

  @override
  String get provenanceHowToGetRecord =>
      '来歴の証拠を活かすには、印刷・書き出しされたPDFではなく、**.docx／.odt／.doc の元ファイル**を入手してください。編集履歴が残るのは元ファイルだけであり、統計的保証のある基準セットへ自動的に加われるのもそれだけです。';

  @override
  String get calibrationAutoTitle => 'バックグラウンドで収集中';

  @override
  String get calibrationAutoSubtitle =>
      '分析した文書は自動的に基準セットへ加わります。手動でのラベル付けは不要です。';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return '編集記録により人間の執筆と確認：$auto件／参考のみのサンプル：$observed件';
  }

  @override
  String get calibrationAutoWhy =>
      '統計的保証のある基準セットに入るのは、編集記録（編集時間・保存回数・編集バッチの分散）を持つ文書だけです。それが**本文の判定とは独立した**証拠だからです。本ツール自身の判定でラベルを付ければ、自分の答案を自分で採点するのと同じ——誤判定された文章は永久に基準セットへ入れず、しきい値は回を追うごとに厳しくなり、かえって多くの本物の人間の文章が判定対象になってしまいます。貼り付けたテキストには編集記録がないため、下の参考パーセンタイルにのみ計上されます。';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return '参考：このスコアは分析済み$count件中の第$percentileパーセンタイルに位置します（統計的保証はありません）';
  }

  @override
  String get settingsAutoCollectTitle => 'バックグラウンドでキャリブレーション用サンプルを収集';

  @override
  String get settingsAutoCollectSubtitle =>
      '分析した文書を自動で基準セットに追加します。ラベルは文書の編集記録に基づき、本ツール自身の判定は使いません。';

  @override
  String get settingsStoreTextTitle => 'オフライン検証用に本文を保存';

  @override
  String get settingsStoreTextSubtitle =>
      '有効にすると、基準セットに追加した文章が本文ごと端末内に保存され、後でコーパスファイルとして書き出してオフライン評価に使えます。';

  @override
  String get settingsStoreTextWarning =>
      '本文は多くの場合が他者の作品であり、機微な情報です。オフライン検証用のコーパスを実際に収集するときだけ有効にし、書き出し後は下の「保存した本文を消去」で速やかに削除してください。消去しても共形予測には影響しません（スコアのみを使うため）。';

  @override
  String get settingsExportCorpusTitle => 'キャリブレーションコーパスを書き出す';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return '書き出し可能：人間$human件、AI$ai件（オフライン評価には各$required件必要）';
  }

  @override
  String get settingsExportCorpusButton => 'JSONLとして書き出す';

  @override
  String get settingsExportCorpusEmpty =>
      '書き出せるサンプルがありません。まず「本文を保存」を有効にし、基準セットを蓄積してください';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return '$count件を書き出しました（本文が未保存の$skipped件はスキップ）';
  }

  @override
  String get settingsClearStoredText => '保存した本文を消去';

  @override
  String get settingsClearStoredTextDone =>
      '保存されていた本文をすべて消去しました。スコアとキャリブレーションはそのままです。';

  @override
  String get helpDesignTitle => '設計思想と既知の限界';

  @override
  String get helpShiftTitle => '1. 位置づけの転換：スコアの正確さでは競わない';

  @override
  String get helpShiftBody =>
      '市場のほとんどの検出器は同じ問いに答えています。「この文章はAIが書いたように見えるか？」\n\nこれは負けが決まった軍拡競争です。モデルが強くなるほど生成文の統計的特徴は人間に近づき、書き換えツールの進歩は検出器よりはるかに速い。この道ではサーバー側の大規模モデルも負け方が遅いだけです。\n\nTruthLensは別の問いを立てます。「この文書がどのように作られたかについて、手元にどんな証拠があり、それぞれどれほど強いのか？」\n\nつまり文体からの推測ではなく、来歴の証拠と統計的に誠実な結論へ軸足を移します。本ツールが単一スコアの精度競争を意図的に追わず、証拠を個別に並べ、根拠が足りないときは分からないと明言するのはこのためです。ブラウザ実行の本当の利点は推論速度ではなく、サーバーには見えないもの——完全なファイルと、利用者自身が集めた基準——が見えることです。';

  @override
  String get helpPillarsTitle => '2. 五つの柱';

  @override
  String get helpPillarsBody =>
      '1. 文書来歴の鑑識（稼働中）\nDOCX・ODTコンテナ内の編集記録を読み取ります。総編集時間、保存回数、作成・更新日時、本文の編集バッチ標識（RSID）。論文全体でRSIDが1〜2組しかなければ、通常は一度に流し込まれたことを意味します。3000語で編集4分という記録は、どの困惑度スコアより硬い証拠です。これは来歴の証拠としてAI確率とは分けて表示し、意図的にスコアへ混ぜません。\n\n2. ローカル基準キャリブレーションと共形予測（稼働中）\n作成者本人が書いたと確実な文章を基準セットに加えると、世界共通のしきい値ではなくこの集団自身の分布で判断します。共形予測は分布に依存しない保証を与えます。基準と検査対象が交換可能であれば、誤検出率は設定したα以下に収まります。非母語話者の文章での誤判定を減らす鍵であり、商用製品にはできないことです。彼らは利用者の作成者の基準文章を持っていません。\n\n3. 学習によるエンジン重み（稼働中）\n基準セットに人間とAIの両方のサンプルが揃うと、各エンジンが両群をどれだけ分離できるか（Cohen\'s dの効果量）を測り、それに応じた重みを提案します。手動の固定比率を置き換えますが、「適用」を押すまで何も変わりません。設定が黙って書き換わることはありません。\n\n4. Binoculars交差困惑度（採点の中核は完成、未稼働）\n素の困惑度は「予測しやすさ」をそのまま「AIらしさ」として扱うため、平易な非母語話者の文章に系統的な誤検出を生みます。Binocularsは予測しやすさを「2つのモデルがどれだけ食い違うか」との相対で測ります。採点の数学は実装・検証済みですが、実際に有効化するにはブラウザで動く小型言語モデルの組と、ラベル付きデータでの検証が必要です。\n\n5. 電子透かし検出（調査の結果、実現不可能につき未実装）\nSynthID-Textの検出は鍵に紐づきます。検出器は生成時と同じ鍵で計算する必要があり、Googleの本番環境の鍵は公開されていません。ブラウザでこれを行っても、ChatGPT・Claude・Geminiの実際の出力には決して反応しません。透かしを確認していると誤解させるだけの、決して発火しない機能になるため、意図的に見送りました。';

  @override
  String get helpCascadeTitle => '3. 段階的カスケードと判定の見送り';

  @override
  String get helpCascadeBody =>
      'ブラウザの限られた計算資源で速度を保つため、分析は段階的に行います。安価な信号を先に、高価なものは必要なときだけ。\n\n第0層　文書来歴の証拠（ほぼ無コスト）\n第1層　統計・文体特徴（既存エンジン、安価）\n第2層　Transformer文単位分類器\n第3層　交差困惑度（最も高価、判断がまだ曖昧な場合のみ）\n\n結果はローカルキャリブレーションに渡され、誤検出率の保証を伴う結論——あるいは明示的な見送り——を出します。\n\n【見送りが重要な理由】\n誤った告発の多くは、短すぎたり信号が弱すぎたりする入力に自信ありげな数字を返すことから生まれます。本ツールは以下の場合、スコアを無理に出さず「証拠が不十分なため判定しません」と表示します。\n\n・分析可能な文が5文未満\n・本文が100語未満\n・参加したエンジンが2個未満\n・エンジン間の差が60パーセントポイント超（平均を取る意味が失われている）\n\n見送り時も、参考用に完全なスコアと文単位の根拠を下に残します。ただし結論として扱わないでください。「分からない」と言えるシステムは、常に数字を返すシステムより信頼に値します。';

  @override
  String get helpRisksTitle => '4. 誠実に向き合うべきリスク';

  @override
  String get helpRisksBody =>
      '以下はいずれも本ツールに実在する限界です。報告内容に基づいて行動する前に必ず考慮してください。\n\n1. 来歴の証拠は消去も偽装もできる\n別名保存、オンライン変換、Googleドキュメントからのエクスポート、新規ファイルへのコピー——いずれも編集記録をゼロに戻します。信号は補強証拠にすぎず、信号がないことは人が書いた証明には決してなりません。\n\n2. 共形保証は交換可能性に依存する\n基準サンプルと検査対象が同じ集団・同じ種類の課題である場合にのみ成立します。作成者の文章力が明らかに向上した、あるいはタスクの種類が全く変わった場合、前提は崩れ基準セットの作り直しが必要です。\n\n3. 基準セット自体が汚染されうる\n基準に使った課題が実はAIによる代筆であれば、キャリブレーション全体が歪みます。基準サンプルは管理された環境——たとえば管理された環境で仕上げた作品——で集める必要があります。\n\n4. ブラウザ内の小型モデルはサーバー側の大規模モデルより精度が劣る\nWeb専用という決定がプライバシーと引き換えに払う、避けられない代償です。本ツールの価値は単一スコアの精度ではなく、説明でき、較正でき、誠実に判定を見送れることにあります。\n\n5. いかなるスコアも単独で告発の根拠にしてはならない\n必ず文単位の根拠、文書の来歴、そしてその作成者について既に知っていることと併せて読んでください。本ツールは対話を支えるために設計されており、判断を代行するためのものではありません。';

  @override
  String get calibrationAddHuman => '「人間が執筆」の基準として追加';

  @override
  String get calibrationAddAi => '「AI生成」のサンプルとして追加';

  @override
  String calibrationCounts(int human, int ai) {
    return '基準セット：人間$human件、AI$ai件';
  }

  @override
  String get learnedWeightsTitle => '学習によるエンジン重み';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return '現在、人間$human件・AI$ai件です。信頼できる重みを学習するには各クラス最低$required件必要で、それまでは手動設定の重みが使われます。';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return '人間$human件・AI$ai件のサンプルから重みを学習できます。';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine：推奨重み$weight%（分離度 $effect）';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return '注意：$engineは2グループを逆に判定しています（AIサンプルの方が低いスコア）。そのため重みは0になります。多くの場合、このエンジンがこの種の文章に向いていないことを意味します。';
  }

  @override
  String get learnedWeightsApply => '学習した重みを適用';

  @override
  String get learnedWeightsApplied => '学習した重みを適用しました';

  @override
  String get learnedWeightsExplain =>
      '重みは、各エンジンが人間のサンプルとAIのサンプルをどれだけよく分離できるか（Cohen\'s dの効果量）から決まります。2グループが離れているほど、また各グループが安定しているほど、そのエンジンの重みは大きくなります。これにより手動の固定重みが置き換えられ、実際に扱う文章の種類にアンサンブルが適合します。';

  @override
  String get calibrationTitle => 'ローカル基準キャリブレーション';

  @override
  String get calibrationEmpty =>
      '基準セットがまだありません。作成者本人が書いたと確実にわかるもの（管理された環境で仕上げた作品など）をいくつか登録すると、世界共通のしきい値ではなく、この集団自身の分布に照らして判断できるようになります。非母語話者の文章での誤検出を減らす鍵がまさにこれです。';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return '基準セットは現在$count件ですが、$alpha%の誤検出率上限を実際に成立させるには最低$required件必要です。それまでは参考値の表示のみで、これを根拠に文章を判定することはありません。';
  }

  @override
  String calibrationFlagged(int alpha) {
    return '誤検出率上限$alpha%の設定において、この文章は**判定対象となりました**。';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return '誤検出率上限$alpha%の設定において、この文章は**判定対象外です**。';
  }

  @override
  String calibrationPValue(String value, int count) {
    return '保守的p値 $value（基準サンプル$count件に対して）';
  }

  @override
  String calibrationPercentile(int percentile) {
    return 'スコアは基準セットの第$percentileパーセンタイルに位置します';
  }

  @override
  String get calibrationCaveat =>
      'この保証は「基準サンプルと検査対象が交換可能である」こと、つまり同じ集団・同じ種類の課題であることを前提とします。作成者の文章力が明らかに向上した場合やタスクの種類が全く変わった場合、前提は崩れるため基準セットの作り直しが必要です。また、基準サンプル自体がAIによる代筆であればキャリブレーション全体が歪むため、収集は管理された環境で行ってください。';

  @override
  String get calibrationAddButton => 'これを基準セットに追加';

  @override
  String calibrationAdded(int count) {
    return '基準セットに追加しました（現在$count件）';
  }

  @override
  String get settingsCalibrationTitle => 'ローカル基準セット';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return '現在$count件（このαには$required件必要）';
  }

  @override
  String get settingsCalibrationClear => '基準セットを消去';

  @override
  String get settingsCalibrationCleared => '基準セットを消去しました';

  @override
  String get settingsAlphaTitle => '誤検出率上限（α）';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return '現在$alpha% — 低いほど厳格ですが、より多くの基準サンプルが必要です（最低$required件）';
  }

  @override
  String get abstentionHeadline => '証拠が不十分なため判定しません';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return '分析可能な文が$count文しかありません（最低$required文必要）。この長さでは統計的・文単位のシグナルに意味がなく、無理に点数を出せば誤解を招くだけです。';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return '本文は$count語で、最低$required語が必要です。これを下回ると、どんな文章的特徴も偶然でありえます。';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return '$total個中$available個のエンジンしか参加しておらず、別角度からの相互検証ができません。モデル管理で補ってから再実行してください。';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return 'エンジン間の差が$spreadパーセントポイントあり、平均を取る意味が失われるほど分かれています。文単位の根拠と文書の来歴を見てご自身で判断してください。';
  }

  @override
  String get abstentionNoEvidenceFound =>
      'すべてのエンジンが実行されましたが、利用できる根拠は見つかりませんでした。低いフォールバックスコアは診断用の出力であり、人間が書いたことの証拠ではありません。';

  @override
  String abstentionSingleWeakEvidenceSource(int count) {
    return '利用できる根拠を見つけたエンジンは $count 個のみで、総合スコアも AI しきい値を下回っています。これは根拠の網羅性が低いという意味であり、人間が書いた証拠ではありません。';
  }

  @override
  String get abstentionScoreStillShown =>
      '下には参考用に完全なスコアと文単位の根拠を残していますが、結論として扱わないでください。';

  @override
  String get provenanceTitle => '文書の来歴証拠';

  @override
  String get provenanceRiskHigh => '編集履歴が明らかに不自然です';

  @override
  String get provenanceRiskMedium => '編集履歴に気になる点があります';

  @override
  String get provenanceRiskLow => '編集履歴は自然に見えます';

  @override
  String get provenanceRiskUnknown => '利用できる編集履歴がありません';

  @override
  String get provenanceNoMetadata =>
      'この入力には編集履歴が含まれていません（貼り付けたテキスト、PDF、または履歴が消去されたファイル）。そのため来歴からは判断できず、本文の分析のみとなります。';

  @override
  String provenanceEditingDuration(int minutes) {
    return 'ファイルに記録された編集時間：$minutes分';
  }

  @override
  String provenanceRevisionCount(int count) {
    return '保存回数：$count回';
  }

  @override
  String provenanceApplication(String name) {
    return '作成ソフト：$name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return '本文の編集バッチ標識が$count組しかないのに対し、内容は$words語あります。考えながら書けば通常は数十組残るため、これほど集中しているのは一度にまとめて入力された（貼り付けなど）ことを示唆します。';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words語に対し記録された編集時間は$minutes分で、毎分$wpm語となります。実際に書きながら維持できる速度をはるかに超えています。';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return 'ファイルの記録上、編集時間がほぼ0であるにもかかわらず、本文は$words語あります。';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return '$words語の内容が$count回しか保存されていません。';
  }

  @override
  String get provenanceCaveat =>
      'ご注意：これらの記録は消去やリセットが可能です。別名で保存する、オンラインで変換する、Googleドキュメントからエクスポートする、新しいファイルにコピーする——いずれも記録をゼロに戻します。したがって、信号は補強証拠にすぎず単独で結論にはできません。また信号がないことは人が書いた証明にもなりません。';

  @override
  String get telemetrySummaryTitle => '分析のまとめ';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '$total個中$engines個のエンジンが完了しました。全体のAI確率は$percent%で、「$verdict」と判定されました。';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return '各エンジンの見方はおおむね一致しています（最高$high%、最低$low%）。この結論は十分に信頼できます。';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return 'エンジン間で見方が分かれています。$highLabelは$high%、一方$lowLabelは$low%でした。こういうときは総合スコアだけで判断せず、下の文単位の根拠を見たほうが確実です。';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return 'スコアを押し上げている主な要因は$labelで、約$pointsパーセントポイント寄与しています。';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return '$total文をすべて確認しましたが、強いAIシグナルの線を越えた文は1つもありませんでした。';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return '$total文のうち$count文が強いAIシグナルの線を越えました。1文ずつ目を通す価値があります。';
  }

  @override
  String get telemetrySummaryAdviceHuman =>
      '全体として人が自分で書いた文章に読めます。特に追跡が必要な箇所はありません。';

  @override
  String get telemetrySummaryAdviceMixed =>
      'これはグレーゾーンです。スコアだけで結論を出すのは危険なので、文単位の根拠と文書の出所を合わせて判断してください。';

  @override
  String get telemetrySummaryAdviceAi =>
      'シグナルは明らかにAI生成または書き換えを示しています。マークされた文を1つずつ確認してから判断してください。';

  @override
  String telemetrySummaryModelGap(int count) {
    return 'なお$count個のエンジンが今回の投票に参加していないため、確信度は割り引いて考えてください。モデル管理で補ってから再実行すると精度が上がります。';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'AI確率 < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'AI確率 $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'AI確率 ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return '信頼度低：利用可能なモデルの重みが60%未満です（しきい値$threshold%）。$available/$total エンジンが参加しました。詳細なエンジン分析をご確認ください。';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return '信頼度高：$available/$total 個の検出モデルが合意に達しました（$threshold%以上の重みがこの判定に同意）。';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return '信頼度低（$available/$total）';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return '信頼度高（$available/$total）';
  }

  @override
  String get reportMetricAiSentenceRatio => '強いAI信号を示す文の割合';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$total文中$count文が60%の強い信号しきい値を超えました';
  }

  @override
  String get reportMetricElapsed => '分析時間';

  @override
  String get reportMetricElapsedNormal => '0.5〜5秒が通常';

  @override
  String get reportMetricReliability => '信頼性';

  @override
  String get reportReliabilityLow => '低';

  @override
  String get reportReliabilityHigh => '高';

  @override
  String get reportReliabilityNeedsReview => '要確認';

  @override
  String get reportReliabilityHighTrust => '非常に信頼できる';

  @override
  String get reportSentenceAnalysisTitle => '文単位の分析';

  @override
  String get suspiciousFilterAll => '疑わしい';

  @override
  String get suspiciousFilterHigh => '高';

  @override
  String get suspiciousFilterMedium => '中';

  @override
  String get suspiciousExcludedTooltip =>
      '単一の文字、ページ番号、章番号、短すぎるOCR/PDF断片は除外されています。';

  @override
  String suspiciousCount(int count) {
    return '$count 件';
  }

  @override
  String get suspiciousEmpty => '疑わしいコンテンツはありません';

  @override
  String get suspiciousRiskHigh => '高';

  @override
  String get suspiciousRiskMedium => '中';

  @override
  String get suspiciousReasonHighModelSignals => '複数のモデル信号が強くAIに偏っています';

  @override
  String get suspiciousReasonSentenceSignal => '文単位のモデル信号が高まっています';

  @override
  String suspiciousOriginalLocation(String location) {
    return '元の位置 $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return '元の位置 $location・$reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return '文 #$number';
  }

  @override
  String get suspiciousEvidenceLabel => '根拠：';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text。AI確率 $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'ハイパーリンクの実在性';

  @override
  String get reportLinkNoneDetected => '文書内にハイパーリンクは検出されませんでした。';

  @override
  String get reportLinkCheckingProgress => 'リンクを検証中…';

  @override
  String reportLinkDetectedPending(int count) {
    return '$count 件のハイパーリンクを検出しました。まだ検証されていません';
  }

  @override
  String get reportLinkDisabledHint =>
      'AI生成コンテンツには、もっともらしいが実在しない引用リンクがよく含まれます。「設定」でハイパーリンク検証をオフにしています。再度オンにすると自動検証されます。下のボタンで一回限りの検証も可能です。';

  @override
  String get reportVerifyNowButton => '今すぐ検証（要ネットワーク接続）';

  @override
  String get reportLinkReachable => '接続可能、URLは実在します';

  @override
  String get reportLinkNotFound => 'URLが存在しません（404）。虚偽の引用の可能性があります';

  @override
  String get reportLinkUnreachable => '確認できません（タイムアウトまたはサーバー応答なし）';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'ジャーナル登録を確認：$journalに登録済み$title';
  }

  @override
  String get reportLinkCitationNotFound => '一致するDOI登録が見つかりません。虚偽の引用の可能性があります';

  @override
  String get reportLinkCitationUnreachable => '確認できません（タイムアウトまたはCrossrefの応答なし）';

  @override
  String reportLinkTruncated(int max, int count) {
    return '最初の $max 件のリンクのみ検証しました（検出総数 $count 件）';
  }

  @override
  String get reportBibAuthenticityTitle => '引用文献の実在性';

  @override
  String get reportBibNoneDetected => '文書内に参考文献の項目は検出されませんでした。';

  @override
  String get reportBibCheckingProgress => '参考文献目録を検証中…';

  @override
  String reportBibDetectedPending(int count) {
    return '参考文献目録（$count 件）を検出しました。まだ検証されていません';
  }

  @override
  String get reportBibDisabledHint =>
      'AI生成コンテンツには、もっともらしいが実在しない参考文献がよく含まれます。「設定」でハイパーリンク検証をオフにしています。再度オンにすると自動検証されます。下のボタンで一回限りの検証も可能です。';

  @override
  String get reportVerifyNowBibButton => '今すぐ検証（要ネットワーク接続）';

  @override
  String get reportBibRecheckAllUnreliableButton => '未検証の引用をすべて再確認';

  @override
  String get reportBibRecheckOneTooltip => 'この引用を再確認';

  @override
  String get reportBibResultHint =>
      '著者名、発行年、タイトルの類似度でCrossrefの公開登録データと照合します。絶対的な保証ではありません。「不確定」の場合は自分で確認することをお勧めします。';

  @override
  String reportBibVerificationSource(String source) {
    return '検証ソース：$source';
  }

  @override
  String get reportBibGoogleScholarManualLookup => 'Google Scholarで手動確認';

  @override
  String reportBibHighConfidence(String journal) {
    return '高信頼度：実在する可能性が高い$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（$journalに登録済み）';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'ジャーナル名の不一致：文書では「$reported」とされていますが、検証済み登録では「$registered」となっています。この引用をご確認ください。';
  }

  @override
  String get reportBibNotFound => '近い一致が見つかりません。虚偽の参考文献の可能性があります';

  @override
  String get reportBibUncertain => '疑わしい：登録データとの照合による検証はされていません';

  @override
  String reportBibTruncated(int max, int count) {
    return '最初の $max 件のみ検証しました（検出総数 $count 件）';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return '$count 件完了。結果は継続して更新されます。';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return '進捗 $completed/$total、$current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return '現在：$text';
  }

  @override
  String get reportBibProgressFinalizing => '結果を確定しています';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base：類似候補「$candidate」が見つかりましたが、著者・年・タイトルが信頼できる一致のしきい値に達しませんでした。';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base：検証ソースから信頼できる応答がないか、項目情報が不十分なため、TruthLensはこの引用を検証済みとは扱いません。';
  }

  @override
  String get reportNetworkWarningTitle => 'ネットワーク接続が不安定です';

  @override
  String get reportNetworkWarningBody =>
      '本アプリは実行時にネットワーク接続があることを前提としています。ハイパーリンクと引用文献の実在性分析には、結果を判定するためにネットワーク接続が必要です。現在接続できません。ネットワーク状態を確認して再試行してください。';

  @override
  String get reportRetryConnectionButton => '接続を再確認';

  @override
  String get reportAiProbabilityLabel => 'AI確率';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '合計 $total 文\nAIの疑い $ai 文\n人間 $human 文';
  }

  @override
  String get summaryCardFooter => 'コアAI推論はすべてデバイス上で実行されます';

  @override
  String get exportReportTitle => 'TruthLens 検出レポート';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · $total ページ中 $page ページ目';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return '分析日時：$datetime · 所要時間 $seconds 秒';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return '総合判定：$verdict';
  }

  @override
  String get pdfEslAppliedSuffix => '（ESL補正を適用済み）';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '合計 $total 文 · AIの疑い $ai 文 · 人間 $human 文';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'PDFの可読性を保つため、最初の $max 文のみ表示しています（全 $count 文）。完全なデータが必要な場合は「$csvLabel」または「$jsonLabel」をご利用ください。';
  }

  @override
  String get pdfSentenceColumnHeader => '文（一致したパターン付き）';

  @override
  String composerHeadlineAi(int percent) {
    return 'この文章はAIによって生成された可能性が非常に高いです（AI確率 $percent%）';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'この文章はAI生成の傾向があり、さらなる確認をお勧めします（AI確率 $percent%）';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'この文章は人間とAIの混合的な特徴を示しています（AI確率 $percent%）';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'この文章は人間が執筆した傾向があります（AI確率 $percent%）';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'この文章は人間によって執筆された可能性が非常に高いです（AI確率 $percent%）';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return '総合AI確率が固定の $percent% のしきい値を超え、AIとしてフラグが立てられました。';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '総合AI確率は固定の $percent% のフラグしきい値未満です。';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return '全体のAI確率は$aiPercent%で、固定のAI判定しきい値$thresholdPercent%に達しているため、レポートはこのテキストをAIとして判定します。最終判断の前に文単位の根拠と各エンジンの理由をご確認ください。';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return '全体のAI確率は$aiPercent%で、固定のAI判定しきい値$thresholdPercent%を下回っているため、レポートはこのテキストを正式にAIとして判定しません。確率と根拠は引き続き確認用に表示されます。';
  }

  @override
  String get composerNarrativeTitle => '分析の解釈';

  @override
  String get composerParaphraseTitle => '言い換えの痕跡を検出';

  @override
  String get composerParaphraseBody =>
      'この文章は、検出を回避するために言い換えツール（QuillBot、Undetectable.aiなど）で処理された可能性があります。文単位では自然に読めても、全体の統計的特徴は本来の人間の文章とは異なります。特にご注意ください。';

  @override
  String get composerPatternListTitle => '主なAI文体パターン';

  @override
  String get composerEslTitle => 'ESL（非ネイティブ）バイアス補正';

  @override
  String get composerEslBody =>
      'この文章は非ネイティブの執筆者によるものである可能性があります。非ネイティブに一般的な低い困惑度と規則的な文型は、それ自体AIの特徴ではないため、誤判定を避けるためシステムは統計モデルの重みを下げました。';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return '本文は合計 $total 文で、そのうち $ai 文が強いAIの特徴を示し、$human 文が人間の執筆傾向を示しています。';
  }

  @override
  String get composerNarrativeAiPattern =>
      'ほとんどの文が、文の長さのリズム、語彙選択、接続詞の使用において高度に規則的であり、これはAI生成文章の典型的な特徴です。';

  @override
  String get composerNarrativeMixedPattern =>
      '文章には規則的な部分と自然な変化のある部分が混在しており、人間の下書きをAIが推敲したか、人間とAIの共同作業である可能性を示しています。';

  @override
  String get composerNarrativeHumanPattern =>
      '文の長さと語彙選択には自然な変化と個性が見られ、明らかなAIの規則性は見られません。';

  @override
  String engineReasonPplLow(String ppl) {
    return '言語モデルの困惑度が低く（$ppl）、文章の予測可能性が高いことはAI生成の指標です';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return '言語モデルの困惑度が高く（$ppl）、人間の文章の予測不可能性と一致します';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return '言語モデルの困惑度は中程度です（$ppl）';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return '文の長さが非常に均一で（burstiness $value）、均一なリズムはAI生成文章の典型的な統計的特徴です';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return '文の長さに明らかな変化があり（burstiness $value）、人間の自然な文章のリズムの変化と一致します';
  }

  @override
  String engineReasonBurstinessMid(String value) {
    return '文長のばらつき（バースト性 $value）は中立帯 0.30〜0.55 の範囲内でした';
  }

  @override
  String engineReasonTtrLow(String value) {
    return '語彙の多様性が低く（TTR $value）、単語の反復度が高いです';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return '語彙の多様性が高いです（TTR $value）';
  }

  @override
  String engineReasonMattrNoAiSignal(String value, String cut) {
    return '語彙の多様性（MATTR $value）は較正済みの AI シグナル基準 $cut を超えませんでした';
  }

  @override
  String engineReasonStatisticalSummaryAi(String percent) {
    return '統計総合サマリー：AI生成的な特徴に偏っています（AI確率 $percent%）';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return '統計総合サマリー：自然な人間の文章に偏っています（AI確率 $percent%）';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return '統計総合サマリー：各指標が拮抗し、中立的な特徴を示しています（AI確率 $percent%）';
  }

  @override
  String get reportFormulaTitle => '加重計算の透明性とパラメータ内訳';

  @override
  String get reportFormulaExplanation =>
      '全体のAI確率は、アクティブな各エンジンの確率を割り当てられた重みで加重平均して算出されます：';

  @override
  String get reportFormulaActiveEngines => 'アクティブなエンジンと割り当てられた重み';

  @override
  String get reportFormulaCalculation => '加重計算式';

  @override
  String get reportFormulaFinalResult => '最終加重AI確率';

  @override
  String get reportFormulaEslApplied => 'ESL非母語ライティング補正を適用済み（統計モデルの重みを半分に）';

  @override
  String get engineReasonNeutral => '統計的指標に明確な傾向は見られず、中立的な判定を維持します';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return '汎用的な接続詞（$words）の使用頻度が高く、1文あたり平均 $density 回で、人間の文章ではこれほど密集することは稀です';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return '複数の隣接する文が同じ単語で始まっており（$count 箇所）、文型が反復しています';
  }

  @override
  String get engineReasonNoStyleMarkers => '顕著なAI文体パターンは検出されませんでした';

  @override
  String get engineStatisticalPerplexityModule => '言語モデルのパープレキシティ';

  @override
  String get engineStatisticalLexicalModule => '語彙指紋';

  @override
  String get engineStatisticalHeuristicModule => 'ヒューリスティック統計';

  @override
  String get engineStylometryRulesModule => 'ルールベースの文体特徴';

  @override
  String get engineStylometryPan25Module => 'PAN 2025 語彙指紋';

  @override
  String get engineStylometryDetectRlModule => 'DetectRL-ZH 文字指紋';

  @override
  String get modelNameMbertMultilingual => '多言語検出器（英+中・INT8）';

  @override
  String get modelNameTruthlensZh => 'TruthLens 中国語検出器（2026 世代・INT8）';

  @override
  String get modelNameAigcZhv3 => '現代中国語検出器（DeepSeek／GPT-4・INT8）';

  @override
  String get modelNameRobertaEn => 'RoBERTa 検出器（英語・ChatGPT 専用）';

  @override
  String get modelNameQwenPpl => '多言語パープレキシティモデル（Qwen2.5-0.5B・INT8）';

  @override
  String get modelNameDistilgpt2Ppl => 'DistilGPT2 パープレキシティモデル（INT8）';

  @override
  String get modelNameAdversarial => '書き換え検出モデル（INT8）';

  @override
  String get modelErrorNoSource => 'このバリアントにはまだダウンロード元がありません。';

  @override
  String modelErrorStorageShort(String mb) {
    return 'ブラウザーの保存容量が不足しています（約 $mb MB 不足）。不要なモデルを削除するか、ディスク容量を空けてください。';
  }

  @override
  String get modelErrorChecksum => 'チェックサムが一致しません。ファイルが破損している可能性があります。';

  @override
  String get modelErrorTokenizerIncomplete =>
      'ダウンロードした Tokenizer JSON が不完全か、接続が切断されました。';

  @override
  String modelErrorSizeMismatch(String got, String expected) {
    return 'ダウンロードが不完全です：$got MB を受信、約 $expected MB を想定。';
  }

  @override
  String get modelErrorChunkAborted => 'ダウンロードがブロック途中で切断され、再試行にも失敗しました。';

  @override
  String get modelErrorTokenizerInvalid => 'Tokenizer JSON の形式が無効です。';

  @override
  String deviceCapabilitySummary(
    String platform,
    int cpu,
    String ram,
    String estimated,
    String tier,
  ) {
    return '$platform · $cpu コア · $ram GB RAM$estimated · $tier';
  }

  @override
  String get deviceCapabilityEstimated => '（推定）';

  @override
  String engineReasonPan25LexicalAi(int percent) {
    return 'PAN 2025 の語彙指紋は AI 寄りです（$percent/100）。この独立した英語ベースラインは、人間コーパスと異なる語・句の分布を検出します';
  }

  @override
  String engineReasonPan25LexicalHuman(int percent) {
    return 'PAN 2025 の語彙指紋は人間寄りです（$percent/100）。これはモデルによる根拠であり、執筆者の証明ではありません';
  }

  @override
  String engineReasonPan25LexicalNeutral(int percent) {
    return 'PAN 2025 の語彙指紋は中立で（$percent/100）、方向性を示しません';
  }

  @override
  String engineReasonDetectRlZhAi(int percent) {
    return 'DetectRL-ZH の中国語文字指紋が保守的な AI 根拠ゲートを超えました（$percent/100）。DeepSeek-V3、混在テキスト、逆翻訳、文字の摂動、長さの変動に対して独立に検証されています';
  }

  @override
  String engineReasonDetectRlZhNoAiSignal(int percent) {
    return 'DetectRL-ZH の中国語文字指紋は保守的な AI 根拠ゲートを超えませんでした（$percent/100）。これは判断保留であり、人間が書いた証拠ではありません';
  }

  @override
  String engineReasonCompressionCoherence(String value) {
    return '境界をまたぐ圧縮の一貫性（$value）が PAN 2025 の人間 95 パーセンタイル基準を上回りました［AI 側の弱いシグナル］';
  }

  @override
  String engineReasonAssistantResponseArtifact(int count) {
    return '依頼者への呼びかけや、依頼された文章の修正の申し出など、対話型アシスタント応答の痕跡を $count 件検出しました';
  }

  @override
  String get engineReasonAdversarialNotInstalled =>
      '言い換え検出モデルが未インストールのため、今回の投票に参加していません';

  @override
  String get engineReasonTransformerNotInstalled =>
      'モデルが未インストール、または使用中のモデルがサポートされていないため、今回の投票に参加していません';

  @override
  String get modelRepairNoActiveVariant =>
      'アクティブなモデルが見つかりません。モデル管理で推奨モデルをダウンロードしてください。';

  @override
  String get modelRepairCustomRemoved =>
      '読み込みに失敗したカスタムモデルを削除しました。カスタムモデルは自動的に再ダウンロードできないため、モデルとトークナイザーを再インポートしてください。';

  @override
  String get modelRepairNoSource =>
      '読み込みに失敗したモデルファイルを削除しましたが、再ダウンロード可能なカタログソースが見つかりません。モデル管理で推奨モデルを再ダウンロードしてください。';

  @override
  String modelRepairRedownloaded(Object name) {
    return 'モデルファイルが破損または非互換の可能性を検出したため、$name を自動的に再ダウンロードしました。もう一度分析を実行してください。';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return '読み込みに失敗したモデルファイルを削除しましたが、自動再ダウンロードが完了しませんでした。ネットワーク接続を確認し、モデル管理で $name を再ダウンロードしてください。';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      'アクティブな Transformer モデルが見つかりません。モデル管理でダウンロードするか、使用中に設定してください';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return '使用中モデルの tokenizer 形式がサポートされていません（$tokenizer）。bert-wordpiece または roberta-bpe に対応したモデルに切り替えてください';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Transformer モデルまたは tokenizer のパスが見つかりません。モデル管理で再ダウンロードしてください';

  @override
  String get engineTransformerMissingFiles =>
      'Transformer モデルまたは tokenizer のファイルが存在しません。モデル管理で再ダウンロードしてください';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'ONNX opset バージョンがサポートされていません（このモデルは新しすぎます。アプリを更新してください）: $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Tokenizer 形式が破損しています: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      'モデルの読み込みまたは推論に失敗し、自動修復も完了しませんでした。モデル管理で使用中の Transformer モデルと tokenizer を再ダウンロードしてください。';

  @override
  String get engineAdversarialNoActiveVariant => 'アクティブな言い換え検出モデルが見つかりません';

  @override
  String get engineAdversarialMissingFiles =>
      'モデルまたは tokenizer のファイルが存在しません。モデル管理で再ダウンロードしてください';

  @override
  String get engineAdversarialRepairFailed =>
      'モデルの読み込みまたは推論に失敗し、自動修復も完了しませんでした。モデル管理で言い換え検出モデルと tokenizer を再ダウンロードしてください。';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return 'このモデルは今回の投票に参加していません。$error';
  }

  @override
  String get patternNotAnalyzable =>
      'セグメントが短すぎるか、PDF/OCR ノイズの疑いがあるため、文単位の AI 判定を行いませんでした';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'モデルの読み込みに失敗し、今回の投票に参加していません（$error）';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model は $total 文中 $aiCount 文にAIの特徴があると判定しました';
  }

  @override
  String get engineReasonAdversarialDetected =>
      '敵対的モデルが、言い換えツール（QuillBot / Undetectable.aiなど）で処理された可能性のあるAIの痕跡を検出しました';

  @override
  String get engineReasonAdversarialClean => '明らかな言い換え回避の痕跡は検出されませんでした';

  @override
  String get engineReasonGenericNotInstalled => 'モデルが未インストールのため、今回の投票に参加していません';

  @override
  String patternGenericTransition(String word) {
    return '汎用的な接続詞「$word」';
  }

  @override
  String get helpAppBarTitle => '使い方ガイド';

  @override
  String get helpAboutTitle => 'TruthLensについて';

  @override
  String get helpAboutBody =>
      'TruthLensは**すべてブラウザ内で動作する**AIコンテンツ検出ツールです。Transformerニューラル分類器、統計的特徴分析、文体分析、敵対的書き換え検出という4つの独立したエンジンが重み付き投票を行い、文書が外部へ送信されることはありません。\n\nレポートは判定をAI確率として示し、5つの固定区分（20%未満、20–40%、40–60%、60–80%、80%以上）に振り分けます。あわせて文単位の根拠、各エンジンの寄与、文書の来歴証拠、読み込み時の元ファイル名を併記します。区分の境界は調整できないため、同じ文書は誰の手元でも同じ区分になります。根拠が乏しい場合（文数や語数が少ない、エンジン間の食い違いが大きい）は、無理にスコアを出さず「判定しません」と明示します。';

  @override
  String get helpComparisonTitle => '主要ツールとの比較';

  @override
  String get helpComparisonDisclaimer =>
      '以下の比較は各ツールの公開情報と一般的な市場認識に基づいて整理したものであり、機能的な位置付けの参考のみを目的としています。第三者認証によるベンチマークデータではありません。';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZeroは処理の大半をクラウドで行い文書のアップロードが必要ですが、TruthLensは4つのエンジンすべてをご自身のブラウザ内で実行し、内容はどこにも送信しません。';

  @override
  String get helpVsGptZero2 =>
      'GPTZeroが先駆けたPerplexity／Burstiness指標と文単位のハイライトはTruthLensにも取り入れられており、さらにTransformer分類器、文体分析、敵対的防御を重ね、単一指標ではなく4モデルのアンサンブル投票を形成しています。';

  @override
  String get helpVsGptZero3 =>
      'GPTZeroはサブスクリプション制です。TruthLensはサブスクリプション不要で、使用回数の制限もありません。';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitinは機関向けの購入のみで、個人が直接購入することはできません。TruthLensは誰でもインストールして使用できます。';

  @override
  String get helpVsTurnitin2 =>
      'Turnitinの判定プロセスはブラックボックスに近いです。TruthLensは文単位のAI確率、一致した文体パターン、4つのエンジンそれぞれのスコアと理由の内訳を提供します。';

  @override
  String get helpVsTurnitin3 =>
      'Turnitinは主に「AIかどうか」の二値判定です。TruthLensは段落・文単位で人間／AI／混合のラベル付けに対応しています。';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.aiは従量課金のサブスクリプションでクラウドへのアップロードが必要ですが、TruthLensは中核処理をブラウザ内で完結し、サブスクリプションも利用回数制限もありません。';

  @override
  String get helpVsOriginality2 =>
      'Originality.aiにはファクトチェックと読みやすさ分析の概念があります。TruthLensはオンデバイスの文体特徴モジュールでこれに応え、オフラインでも基本的な分析が可能です。';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaksは主にクラウドAPIで、低い誤検知率と強力な多言語対応が強みです。TruthLensは同じ理念のXLM-RoBERTa多言語ベースモデルとマルチモデルのアンサンブル投票を採用していますが、文書内容はいかなるサーバーにもアップロードされません。';

  @override
  String get helpVsCopyleaks2 =>
      'CopyleaksはプランによってAPI使用量の制限があります。TruthLensには使用量の制限はありません。';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'Winston AIの画像OCRは画像をクラウドへ送信します。TruthLensのOCRはご自身で設定したローカルOCRサーバーを優先し、ご自身でGemini APIキーを提供した場合にのみクラウドへフォールバックします。クラウドを使うかどうかは利用者の判断に委ねられます。';

  @override
  String get helpVsWinston2 =>
      'Winston AIは洗練されたレポートレイアウトで知られています。TruthLensはAIによる動的なレポートレイアウト生成を提供し（LLM未インストール時はテンプレートに自動フォールバック）、PDF／CSV／JSON／PNGの4形式でエクスポートできます。';

  @override
  String get helpAdvantagesTitle => 'TruthLens独自の強み';

  @override
  String get helpAdvantage1 =>
      'ハイパーリンクの実在性検証：文書内のURLが接続可能で実在するかを自動的に確認します。DOI形式の学術リンクはさらにCrossrefの公開登録データを照会し、ジャーナルがその文献を実際に収録しているかを確認します。';

  @override
  String get helpAdvantage2 =>
      '引用文献の実在性検証：ハイパーリンクのない参考文献（純粋な「著者名—年」形式）でも、書誌情報の照合により虚偽の可能性がある引用を検出できます——これはAIの幻覚（ハルシネーション）コンテンツによく見られる兆候です。';

  @override
  String get helpAdvantage3 =>
      'ESL（非ネイティブ執筆者）バイアス補正：非ネイティブの文体特徴を自動検出し、統計モデルの重みを下げることで、非ネイティブ話者の自然な文章をAIと誤判定することを防ぎます。';

  @override
  String get helpAdvantage4 =>
      'カスタムモデルのインポート：上級ユーザーは独自のローカルONNXモデルをインポートして、組み込みの検出エンジンを置き換えたり補完したりできます。';

  @override
  String get helpWorkflowTitle => '完全な操作フロー';

  @override
  String helpWorkflowStepLabel(int step) {
    return 'ステップ $step';
  }

  @override
  String get helpWorkflowStep1Title => 'モデルのダウンロードと更新';

  @override
  String get helpWorkflowStep1Body =>
      'アプリは常にメイン画面から開きます。初回起動時に検出モデルが未インストールであれば、選択するかどうかを尋ねるダイアログが表示されます。断った場合でも、統計エンジンと文体エンジンでそのまま分析を開始できます。モデルの確認・ダウンロード・更新・削除は、いつでも「設定 → AI モデル管理」から行えます。起動時に最新版を自動確認し、更新がある場合は設定アイコンと「AI モデル管理」の項目にバッジを表示します。';

  @override
  String get helpWorkflowStep2Title => 'モデルの選び方（目的と効果）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      '多言語 AI 分類器（重み 40%）：文脈を保つために区切られた段落ブロックを解析し、その確率を文単位に対応づけて詳細な根拠を示します。分類器のバリアントを複数インストールしている場合、分析ごとに文書の言語で検証済みのものが選ばれます。中国語の文書には専用の現代中国語検出器が必要で、未導入の場合はアプリが案内します。';

  @override
  String get helpWorkflowStep2Bullet2 =>
      '統計分析エンジン（重み25%）：困惑度とBurstinessのスライディングウィンドウ分析により、AI文章の規則的なリズムと予測可能な語彙を捉えます。';

  @override
  String get helpWorkflowStep2Bullet3 =>
      '文体特徴分析（重み20%）：意味の流暢さ、繰り返し文型、接続詞の使用を分析し、説明可能性が最も高く「なぜ」が最も理解しやすいです。';

  @override
  String get helpWorkflowStep2Bullet4 =>
      '敵対的防御（重み15%）：言い換えツール（QuillBot、Undetectable.aiなど）で処理された文章を検出します。';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'レポート生成LLM（任意）：インストールするとレポート文章がオンデバイスLLMによって動的に生成されます。未インストールの場合は固定テンプレートに自動フォールバックし、分析機能自体には影響しません。';

  @override
  String get helpWorkflowStep2Bullet6 =>
      '「設定」で各エンジンの有効／無効を個別に切り替えたり、エンジンの重みを調整したりできます。5つの判定区分は固定の境界（20%／40%／60%／80%）を使い、変更できません。したがって同じ文書は誰にとっても同じ判定になります。';

  @override
  String get helpWorkflowStep3Title => '文書のアップロード';

  @override
  String get helpWorkflowStep3Body =>
      '入力方法は3つ：テキストを直接貼り付け、画像をOCRで認識、文書を読み込み（txt / md / pdf / docx / doc / odt）。PDF読み込みでは2種類のテキスト層解析結果を比較して文字化けを除外し、スキャンPDFはOCRが利用可能なら1ページずつ認識します。読み込み時はファイル名が入力欄の見出し下に表示され、レポート見出しにも独立した行として現れます。貼り付けや手入力の場合は空欄のままです。\n\nOCRは設定したローカルサーバーを優先し、ご自身でGemini APIキーを提供した場合にのみクラウドへフォールバックします。';

  @override
  String get helpWorkflowStep4Title => '分析の開始';

  @override
  String get helpWorkflowStep4Body =>
      '「検出を開始」をタップすると、4つのエンジンが並行して実行され、画面上に各エンジンの完了状況がリアルタイムで表示されます。非ネイティブの文体特徴が検出された場合、ESLバイアス補正が自動的に適用されます（設定でオフにできます）。';

  @override
  String get helpWorkflowStep5Title => '結果の確認とエクスポート';

  @override
  String get helpWorkflowStep5Body =>
      'レポートページには、総合AI確率のゲージ、文単位のヒートマップ、4つのエンジンのスコアと理由の内訳、ハイパーリンクの実在性、引用文献の実在性が含まれます。完全なPDFレポート、文単位のCSVデータ、JSON（システム連携用）、PNGサマリーカード（共有用）をエクスポートできます。各分析結果は自動的に「履歴」に保存され、いつでも確認できます。';

  @override
  String get helpWorkflowStep1ChipOnboarding => '初回起動ガイド';

  @override
  String get helpWorkflowStep1ChipModelManager => 'モデル管理';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => '自動更新チェック';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => '統計分析 (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => '文体分析 (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => '敵対的防御 (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => 'レポート LLM (任意)';

  @override
  String get helpWorkflowStep3ChipPaste => 'テキスト貼り付け';

  @override
  String get helpWorkflowStep3ChipImageOcr => '画像 OCR';

  @override
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation => 'コード/数式の除外';

  @override
  String get helpWorkflowStep4ChipEnsemble => '4エンジン並列推論';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'ライブ進捗';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'ESL 文体補正';

  @override
  String get helpWorkflowStep4ChipStoppable => 'いつでも停止可能';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'AI 概要ゲージ';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => '文単位ヒートマップ';

  @override
  String get helpWorkflowStep5ChipCitationVerification => '文献検証';

  @override
  String get helpWorkflowStep5ChipExportFormats => 'PDF / CSV / JSON / PNG 出力';

  @override
  String get helpTuningTitle => 'モデルのダウンロードと調整ガイド（初心者向け）';

  @override
  String get helpTuningStep1Title => 'モデル管理画面を開く';

  @override
  String get helpTuningStep1Body =>
      'ホーム画面から歯車アイコンをタップして「設定」に入り、「AIモデル管理」の横の「開く」をタップします。';

  @override
  String get helpTuningStep2Title => 'デバイス性能に応じたモデルの選択';

  @override
  String get helpTuningStep2Body =>
      '画面はお使いのデバイス性能（RAM、CPUコア数）に基づいて適切なモデルティアを自動的に提案し、各役割（多言語分類器／統計分析／敵対的防御／レポートLLM）で利用可能なすべてのバリエーションを一覧表示します。';

  @override
  String get helpTuningStep3Title => 'ダウンロードと適用';

  @override
  String get helpTuningStep3Body =>
      '使用したいモデルの横にある「ダウンロード」をタップし、完了を待ちます。最初にダウンロードしたモデルは自動的に使用中に設定されます。複数のバリエーションがある場合は「使用中に設定」でいつでも切り替えられます。ゴミ箱アイコンをタップすると不要なモデルを削除して容量を解放できます。';

  @override
  String get helpTuningStep4Title => 'モデルの更新';

  @override
  String get helpTuningStep4Body =>
      '新しいバージョンが利用可能になると、「AIモデル管理」と設定の歯車アイコンに通知バッジが表示されます。この画面に戻ると新しいバージョンを確認してダウンロード・更新できます（手動で削除しない限り、元のバージョンは保持されます）。';

  @override
  String get helpTuningStep5Title => '上級者向け：カスタムモデルのインポート';

  @override
  String get helpTuningStep5Body =>
      '互換性のある.onnxモデルを既にお持ちの場合、または独自に微調整した場合は、「設定 → カスタムONNXモデルのインポートとテスト」からインポートできます。モデルファイル、対応するTokenizer設定（または「不要」を選択）、AIクラスインデックスを指定する必要があります。インポート前に、同じファイルが既にインポートされていないか自動的に確認され、誤って重複インポートすることを防ぎます。';

  @override
  String get helpOfficialLinksTitle => '公式モデルダウンロードリンク';

  @override
  String get helpOfficialLinksHint => '項目をタップすると、システムのブラウザでそのモデルの公式ページが開きます。';

  @override
  String get helpLinkRoleTransformer => '多言語AI分類器（Transformer、重み40%）';

  @override
  String get helpLinkRoleStatistical => '困惑度統計モデル（Statistical、重み25%）';

  @override
  String get helpLinkRoleAdversarial => '敵対的言い換え検出モデル（Adversarial、重み15%）';

  @override
  String get helpLinkRoleLlm => 'レポート生成LLM（任意）';

  @override
  String get privacyAppBarTitle => 'プライバシーポリシー';

  @override
  String privacyPlatformTitle(String platform) {
    return '$platform版プライバシーポリシー';
  }

  @override
  String privacyLastUpdated(String date) {
    return '最終更新：$date';
  }

  @override
  String get privacyWebOverview1 =>
      'TruthLensはブラウザタブ内で完全にWebアプリとして動作します。インストールは不要で、文書テキストと分析結果はお使いの端末から外部に出ることはなく、ダウンロードした検出モデルもサーバーではなくブラウザ自体のサンドボックスストレージ（OPFS）にキャッシュされます。';

  @override
  String get privacyWebOverview2 =>
      'このページは、インポート・スキャン・貼り付けを積極的に選択したときのみ、対応するファイル、画像、クリップボードの内容を読み取ります。他のタブや他サイトのデータ、選択していないファイルを読み取ることはありません。';

  @override
  String get privacySectionOverviewWeb => '概要';

  @override
  String get privacyRemoveWeb =>
      'ブラウザの設定でこのサイトのデータを消去する（またはサーバーには何も保存されないため、単にタブを閉じるだけでも構いません）';

  @override
  String get privacyIosOverview1 =>
      'TruthLensは、あなたの身元に紐づくデータを一切収集せず、追跡目的でデータを使用することもないため、App追跡透明性（ATT）の許可は必要ありません。';

  @override
  String get privacyIosOverview2 =>
      '本アプリはシステム提供のファイル選択ツールを使用して、あなたが能動的に選択した文書や画像にアクセスします。選択していないファイルにはアクセスできません（iOS App Sandboxによる制限）。';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLensは個人データを収集せず、いかなる第三者ともユーザーデータを共有しません。';

  @override
  String get privacyAndroidOverview2 =>
      '本アプリは、あなたが能動的に文書や画像のインポートを選択した場合にのみ対応するストレージ権限にアクセスし、バックグラウンドで他のファイルをスキャンやアクセスすることはありません。';

  @override
  String get privacyMacosOverview1 =>
      'TruthLensはmacOS App Sandbox下で実行され、システムのファイルダイアログを通じてあなたが能動的に選択したファイル（files.user-selected.read-write）にのみアクセスでき、他のファイルやフォルダを自由に閲覧・アクセスすることはできません。';

  @override
  String get privacyMacosOverview2 =>
      'ネットワークアクセス権限（network.client）は、下記の「必要な接続動作」に記載された機能にのみ使用されます。';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLensはスタンドアロンのデスクトップアプリケーションで、データはお使いのローカルユーザーフォルダ（AppData／Documentsなど）に保存され、クラウドに同期されることはありません。';

  @override
  String get privacyWindowsOverview2 =>
      '本アプリは、あなたが能動的に文書や画像のインポートを選択した場合にのみ対応するファイルにアクセスし、バックグラウンドで他のファイルをスキャンすることはありません。';

  @override
  String get privacyDataHandling1 =>
      'TruthLensにはユーザーアカウントがなく、サインインも不要で、いかなる広告や第三者トラッキングSDKも含まれていません。';

  @override
  String get privacyDataHandling2 =>
      'あなたが入力、貼り付け、またはインポートした文書内容は、すべてあなたのデバイス上でローカルAIモデルによって分析され、TruthLensやいかなる第三者サーバーにもアップロードされることはありません。';

  @override
  String get privacyDataHandling3 =>
      '分析結果と履歴は、あなたのデバイス上のローカルデータベースにのみ保存されます。アプリをアンインストールするか履歴をクリアすると完全に削除され、TruthLensはいかなるコピーも保持しません。';

  @override
  String get privacyNetworkIntro =>
      '本アプリのコアAI検出は完全にデバイス上で実行されますが、以下の3つの機能にはネットワーク接続が必要です：';

  @override
  String get privacyNetwork1 =>
      '1. モデルカタログとダウンロード：GitHub Releases／Hugging Faceに接続し、選択した検出モデルファイルをダウンロードします。モデルのダウンロードのみを行い、ユーザーデータをアップロードすることはありません。';

  @override
  String get privacyNetwork2 =>
      '2. モデル更新確認：起動時にバージョン番号のみを比較するために接続し、新しいバージョンがあるかどうかを通知するために使用されます。';

  @override
  String get privacyNetwork3 =>
      '3. ハイパーリンクと引用文献の実在性検証：デフォルトで有効になっており、「設定」でオフにできます。有効時、文書内で検出されたURLや参考文献のテキストを、そのURL自体またはCrossref公開APIに直接送信します。送信するのはURL／DOI／書誌情報のテキストのみで、文書内の他の内容は含まれません。';

  @override
  String get privacyNetwork4 =>
      '4. Web OCRフォールバック：Web版のみ、設定されている場合はまずローカルOCRサーバーを使用します。Gemini APIキーを入力した場合、選択した画像やOCRが必要なPDFページのレンダリング画像はブラウザから直接GoogleのGemini APIに送信されます。キーはそのブラウザのローカルストレージにのみ保存されます。';

  @override
  String get privacyRightsIntro =>
      '「履歴」でいつでもローカルの分析記録をクリアしたり、「設定」でハイパーリンク／引用文献検証機能をオフにしたり、または直接';

  @override
  String get privacyRemoveIos => 'アプリを削除';

  @override
  String get privacyRemoveAndroid => 'アプリをアンインストール';

  @override
  String get privacyRemoveMacos => 'アプリをゴミ箱に入れる';

  @override
  String get privacyRemoveWindows => 'アプリをアンインストール';

  @override
  String get privacyDisclaimer =>
      'このページの内容は、TruthLensが実際の機能動作に基づいて作成したプライバシーに関する説明であり、弁護士による審査を経た正式な法的文書ではありません。お住まいの地域の法規に基づく正式なコンプライアンス審査が必要な場合は、専門の法律相談をご利用ください。';

  @override
  String get privacySectionOverviewIos => '概要（App Storeプライバシー「栄養成分表示」に相当）';

  @override
  String get privacySectionOverviewAndroid => '概要（Google Playの「データセーフティ」開示に相当）';

  @override
  String get privacySectionOverviewMacos => '概要（App Sandbox権限の説明）';

  @override
  String get privacySectionOverviewWindows => '概要';

  @override
  String get privacySectionDataHandling => 'データの取り扱いについて';

  @override
  String get privacySectionNetwork => '必要な接続動作';

  @override
  String get privacySectionRights => 'あなたの権利';

  @override
  String get privacyGenericPlatformName => 'このプラットフォーム';

  @override
  String settingsVersionSubtitle(String version, String build) {
    return 'バージョン $version（Build $build）・ローカル優先のプライバシー検出エンジン';
  }

  @override
  String get webOcrSettingsTitle => 'Web OCR設定';

  @override
  String get webOcrPurpose => '分析前に、画像内の印刷文字や手書き文字を認識します。';

  @override
  String get webOcrGeminiKeyTitle => 'Gemini APIキー（任意）';

  @override
  String get webOcrGetKeyButton => 'キーを取得';

  @override
  String get webOcrGeminiDescription =>
      'ローカルOCRサーバーが利用できない場合のみ使用します。キーはこのブラウザに保存されます。';

  @override
  String get webOcrLocalServerTitle => 'ローカルOCRサーバー（推奨）';

  @override
  String get webOcrLocalServerDescription =>
      'macOSではApple Vision、WindowsではWindows OCRを使い、コンピューター上でOCRを実行します。下にローカルエンドポイントを入力してください。';

  @override
  String get webOcrSetupGuideButton => '初めての設定ガイド';

  @override
  String get webOcrPriorityTitle => '認識の優先順序';

  @override
  String get webOcrPriorityDescription =>
      '1. URL設定時はローカルOCRサーバー\n2. APIキー設定時はGemini\n3. 両方失敗した場合は具体的な診断を表示';

  @override
  String get webOcrSetupGuideTitle => 'ローカルOCRサーバーの設定';

  @override
  String get webOcrSetupGuideBody =>
      '1. 下の「OCRプロジェクトを開く」を選びます。\n2. macOS：setup_and_run_ocr.shをダウンロードし、ターミナルで次を実行します：bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows：setup_and_run_ocr.batをダウンロードし、ダブルクリックしてインストールを許可します。\n4. OCRの準備完了と表示されるまで待ちます。自動起動も設定されます。\n5. http://127.0.0.1:5001/ocr を入力し、「接続テスト」を選びます。\n6. 画像OCRを開き、鮮明な画像で確認します。\n\n127.0.0.1を使う場合、ブラウザとOCRサーバーは同じコンピューターで実行してください。失敗時はインストール、ポート5001、末尾の/ocrを確認してください。';

  @override
  String get webOcrOpenProjectButton => 'OCRプロジェクトを開く';

  @override
  String get webOcrTestServerButton => '接続テスト';

  @override
  String get webOcrTestServerMissingUrl => '先にローカルOCRサーバーのURLを入力してください。';

  @override
  String get webOcrTestServerSuccess => 'ローカルOCRサーバーは起動済みで利用できます。';

  @override
  String get webOcrTestServerFailure =>
      'ローカルOCRサーバーに接続できません。ガイド、ファイアウォール、URLを確認してください。';

  @override
  String get workspaceModeSectionTitle => 'ワークスペースモード';

  @override
  String get workspaceModeSectionSubtitle =>
      '原文、ライブ分析、最終証拠を一つの作業画面に配置する方法を選択します。';

  @override
  String get workspaceModeOriginal => '元のレイアウト';

  @override
  String get workspaceModeCommandGrid => 'コマンドグリッド';

  @override
  String get workspaceModeTimeline => 'ミッションタイムライン';

  @override
  String get workspaceModeEvidence => '証拠キャンバス';

  @override
  String get workspaceModeTooltip => 'ワークスペースモードを切り替え';

  @override
  String get workspaceMoreMenuTooltip => 'その他のオプション';

  @override
  String get workspaceLanguageMenuTitle => '言語';

  @override
  String get workspaceStageImport => '取込';

  @override
  String get workspaceStageParse => '解析';

  @override
  String get workspaceStageAnalyze => '4エンジン分析';

  @override
  String get workspaceStageVerify => '検証';

  @override
  String get workspaceStageReport => 'レポート';

  @override
  String get workspaceLiveFindings => 'ライブ検出';

  @override
  String get workspaceTelemetry => '分析テレメトリ';

  @override
  String get workspaceDocument => '文書ワークスペース';

  @override
  String get workspaceOverallProgress => '全体の進捗';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return 'ステップ $current/$total・$stage';
  }

  @override
  String get workspaceWaiting => '文書を待っています';

  @override
  String get workspaceAnalyzing => '分析中';

  @override
  String get workspaceAnalysisComplete => '分析完了';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '$done/$total モジュール完了 · 経過 $seconds 秒 · 実行中：$engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return '分析は継続中で、画面は応答しています。$seconds 秒間モジュールの完了がありません。大きな文書やローカルモデルには時間がかかる場合があります。';
  }

  @override
  String get workspaceAnalysisFailed => '分析が予期せず停止しました。再試行するかモデル設定を確認してください。';

  @override
  String get workspaceNewAnalysis => '新しい分析';

  @override
  String get workspaceStopAnalysis => '分析を停止';

  @override
  String get workspaceStopAnalysisTitle => '現在の分析を停止しますか？';

  @override
  String get workspaceStopAnalysisBody =>
      '分析はまだ実行中です。文書テキストは保持されますが、未完了の結果は保存されません。';

  @override
  String get workspaceAnalysisStopped => '分析を停止しました。文書テキストはワークスペースに保持されています。';

  @override
  String get workspaceSelectedEvidence => '選択した証拠';

  @override
  String get workspaceNoEvidence => '各エンジンの完了後、文ごとの証拠がここに表示されます。';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return '暫定AI確率：$percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      'この割合はこの文自体のAI信号であり、文書全体の判定ではありません。数値が高いほど文体がAI生成らしく見え、低いほど一般的な人間の文章に近いことを示します。最終レポートは各文をエンジンの重みで統合します。';

  @override
  String get workspaceSentenceSignalHeader => '文ごとのAI信号';

  @override
  String get workspaceSentenceColumnHeader => '文';

  @override
  String get workspaceAiEvidenceIndexShort => '指数';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine は今回、根拠を見つけられなかったため投票に参加していません（役割重み $weight%）。これは自分の担当する観点でAIの痕跡がなかったという意味であり、人が書いたと判断したわけではありません。';
  }

  @override
  String reportEngineRelationshipDirectionalOnly(String engine, int weight) {
    return '$engine は弱い方向性シグナルのみを検出しました。スクリーニングでは割り引かれ、しきい値を満たす根拠には数えません（役割重みの上限 $weight%）。';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return '今回根拠を見つけたのは$engineだけで、他のエンジンは何も検出しませんでした。結論は単一の観点だけに支えられているため、確信度はその分割り引いてご覧ください。';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return '他に $count 個のエンジンが実行されましたが根拠を見つけられず、投票から除外しました。「言うことがない」を「人が書いたように見える」と誤って数えないためです。';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      '本件では言語モデルのパープレキシティを採用していません。パープレキシティモデル（DistilGPT2）は英語のみで学習されており、中国語・日本語・韓国語ではバイト列の予測しやすさを測っているだけで、言語としての予測しやすさではありません。ラベル付きデータでの実測では、これらの言語で人間とAIを区別できる割合は0%であり、採用しても誤検出を増やすだけです。';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return '言語別の基準集：$breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return '言語タグのない以前のサンプルが $count 件あり、どの言語の基準集にも入れられません。原文は保存されないため、後から言語を判定できないためです。新しい分析が進むにつれて置き換わります。';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return 'この文書では「$variant」を使用しました。選択中のバリアントは $language で検証されておらず、こちらは検証済みです。';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '「$variant」は多言語モデルですが $language では検証されていません。検証済みの言語よりも根拠としては弱いものとしてお読みください。';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '「$variant」は $language をカバーしていません。スコアは参考値であり、どちらの方向の根拠にもなりません。';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      '言語モデルのパープレキシティは採用していません。この文書の言語を判定できず、比較対象となる校正済みのしきい値がないためです。言語を推測すれば誤った尺度を当てることになり、それはこの検査が防ごうとしている誤りそのものです。';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return '言語モデルのパープレキシティは採用していません。使用中のモデル「$model」には $language のしきい値がまだ測定されていません。校正済みの尺度がなければ生の値に意味はないため、推測せずに除外しています。';
  }

  @override
  String get inputNoEditingRecordHint =>
      'この形式には編集記録がありません。PDF・画像・貼り付けたテキストは「どう書かれたか」の履歴を持たないため、分析は文章統計だけに依存します。元の .docx / .odt / .doc を入手できるなら、その編集履歴のほうがはるかに強い根拠になります。しかも文章統計と違い、言語モデルの進歩によって弱まりません。';

  @override
  String get reportLowScoreNotProofOfHuman =>
      'スコアが低いことは、人が書いたことの確認にはなりません。今回は来歴の根拠がなく、この判定は文章統計だけに基づいています。文章統計は型どおりの文章は確実に検出できますが、現行モデルのよく書けた出力は検出できません。';

  @override
  String get reportProvenanceContradictsLowScore =>
      'ファイル自身の編集記録が、この低いスコアと矛盾しています。来歴の根拠は言語モデルの進歩によって弱まりませんが、文章統計は現行モデルのよく書けた出力を見分けられません。上のスコアから結論を出す前に、下の来歴の根拠をご確認ください。';

  @override
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  ) {
    return '$total 段落のうち $paragraphs 段落が同一の編集バッチに属し、全体の $percent% の語数を占めています。ファイルに他の編集バッチがあっても、その部分は一度に書かれた（または貼り付けられた）形跡と整合します。';
  }

  @override
  String findingEvasionDetected(int count) {
    return '文字レベルの回避痕跡が $count 件見つかりました（ゼロ幅文字、見た目の同じ異体文字、方向制御文字）。通常の執筆ツールはこれらを生成しません。検出を逃れるために誰かが加工しています。';
  }

  @override
  String findingCitationsNotFound(int notFound, int total) {
    return '引用された $total 件のうち $notFound 件が、照会したどの文献データベースにも見つかりませんでした。存在しない文献の引用は言語モデルの挙動であり、文体と違って、論文が実在するかどうかは検証可能な事実です。';
  }

  @override
  String findingCitationsAllVerified(int total) {
    return '引用された $total 件はすべて公開データベースで確認できました。';
  }

  @override
  String findingEditingRecordNormal(int minutes, int revisions) {
    return 'ファイルには $revisions 回の保存にわたり $minutes 分の編集時間が記録されており、本文がこの文書内で書かれたことと整合します。';
  }

  @override
  String findingPublicationPredatesGenerativeAi(String doi, int year) {
    return '出典 DOI $doi はこの文書と一致し、$year 年に登録されています。これは現代の生成 AI 執筆システムより前です。';
  }

  @override
  String findingPublicationIdentityMismatch(String doi) {
    return '出典 DOI $doi は解決できますが、登録されている表題がこの文書と一致しません。依拠する前に文書の同一性を確認してください。';
  }

  @override
  String get integratedStabilityUnavailable =>
      'セグメント安定性は利用できません · 文単位の根拠が投票していません';

  @override
  String get integratedNeutralBaseline =>
      '格上げに足るほど強い、執筆者特有の根拠は見つかりませんでした。表示されている結果は入手可能な範囲で最良の方向性スクリーニングであり、AI と人間の根拠が拮抗しているという主張ではありません。';

  @override
  String get reportVerifiableFindingsTitle => '検証できること';

  @override
  String get reportVerifiableFindingsSubtitle =>
      '以下の各項目は独立に確認できます。確率と違い、言語モデルが進歩しても弱まりません。';

  @override
  String findingBulkPaste(int characters) {
    return '入力中に $characters 文字の一括貼り付けが記録されました。テキストがエディタにどう現れるかを言語モデルは偽装できません。この部分はここで打たれたものではありません。';
  }

  @override
  String findingWrittenInApp(int minutes, int deleted) {
    return 'このアプリ内で $minutes 分かけて入力され、途中で $deleted 文字が修正されました。ここで行われた執筆は、言語モデルには再現できない記録を残します。';
  }

  @override
  String get evidenceMatrixTitle => '複数根拠による評価';

  @override
  String get evidenceMatrixSubtitle =>
      '6 つの軸を個別に表示します。執筆者特有の根拠のみが判定に影響します。カバレッジは何を検査できたかを示します。';

  @override
  String evidenceMatrixCoverage(int available, int total) {
    return '根拠のカバレッジ：$total 軸中 $available 軸';
  }

  @override
  String get evidenceAxisText => 'テキスト生成の痕跡';

  @override
  String get evidenceAxisTextNote => '4 つのローカル検出器による確率的パターン';

  @override
  String get evidenceAxisProcess => '執筆プロセス';

  @override
  String get evidenceAxisProcessNote => '内容を保存せずに記録した入力・修正・貼り付けのイベント';

  @override
  String get evidenceAxisOrigin => '文書の由来';

  @override
  String get evidenceAxisOriginNote => '編集時間、保存回数、DOCX／ODT／RSID メタデータ';

  @override
  String get evidenceAxisSources => '主張と出典の整合性';

  @override
  String get evidenceAxisSourcesNote => '検証可能な主張、引用の根拠、書誌情報の照合';

  @override
  String get evidenceStateUnavailable => '利用不可';

  @override
  String get evidenceStateInconclusive => '判断不能';

  @override
  String get evidenceStateReassuring => '整合';

  @override
  String get evidenceStateConcern => '要確認';

  @override
  String get evidenceStrengthNone => '根拠なし';

  @override
  String get evidenceStrengthLimited => '限定的';

  @override
  String get evidenceStrengthModerate => '中程度';

  @override
  String get evidenceStrengthStrong => '強い';

  @override
  String get evidenceMatrixTextOnlyWarning =>
      '利用できたのはテキストパターンの軸のみです。現世代の AI は人間の文章を模倣できるため、このレポートはスコアだけから執筆者を断定できません。';

  @override
  String get evidenceMatrixStrongConcern =>
      '少なくとも 1 つの独立した軸に強い要確認シグナルがあります。テキストスコアに依拠する前に、その根拠を確認してください。';

  @override
  String findingUnsupportedClaims(int unsupported, int total) {
    return '検証可能な主張 $total 件のうち $unsupported 件が、同じ文の中に出典の裏づけがないまま数値・比較・研究への言及を含んでいます。これは誤りであることの証明ではなく、優先して検証すべき主張を示すものです。';
  }

  @override
  String get integratedAssessmentTitle => '統合的な執筆者評価';

  @override
  String get integratedInsufficientEvidence => '定量化できる執筆者シグナルなし';

  @override
  String get integratedLikelyAi => 'AI 生成の可能性が高い';

  @override
  String get integratedLikelyMixed => '人間と AI の混在の可能性が高い';

  @override
  String get integratedLikelyHuman => 'AI 生成ではない可能性が高い';

  @override
  String get integratedBalanced => 'AI が優勢という明確なシグナルは検出されませんでした';

  @override
  String get integratedPreliminaryAi => '現時点では AI 寄り、境界付近';

  @override
  String get integratedPreliminaryHuman => '現時点では人間寄り、境界付近';

  @override
  String integratedLikelihoodLabel(int percent) {
    return 'AI 根拠指数：$percent/100';
  }

  @override
  String get integratedLikelihoodUnavailable => 'AI 根拠指数：推定不可';

  @override
  String integratedTextScoreLabel(int percent) {
    return 'テキストモデルのスコア：$percent%';
  }

  @override
  String integratedConfidenceLabel(String confidence) {
    return '確信度：$confidence';
  }

  @override
  String get integratedConfidenceLow => '低';

  @override
  String get integratedConfidenceModerate => '中';

  @override
  String get integratedConfidenceHigh => '高';

  @override
  String integratedEvidenceSufficiency(int percent, String tier) {
    return '根拠の充足度：$percent/100 · $tier';
  }

  @override
  String get integratedIncompleteModelWarning =>
      'Core text engines did not fully participate. This is a low-coverage screening result and should not be compared directly with a complete model analysis. Complete the recommended analysis models in Model Management; if they are already installed, check tokenizer support, missing files, or Web/ONNX Runtime compatibility.';

  @override
  String get integratedEvidenceTierScreening => '予備的スクリーニング';

  @override
  String get integratedEvidenceTierReference => '参考水準';

  @override
  String get integratedEvidenceTierStrong => '十分に裏づけあり';

  @override
  String integratedBoundaryAi(int index, int gap) {
    return '指数 $index は AI 側の弱い方向性にすぎず、格上げ基準の 60 点まで依然 $gap 点足りません。AI による執筆を立証したわけではありません。';
  }

  @override
  String integratedBoundaryHuman(int index, int gap) {
    return '指数 $index は人間寄りで、AI 格上げ基準の 60 点まで依然 $gap 点足りませんが、根拠が限られるため AI の支援を排除することはできません。';
  }

  @override
  String integratedEvidenceCoverage(int families, int coverage) {
    return '方向性シグナルの系統：$families/4 · 適用可能性カバレッジ $coverage%';
  }

  @override
  String get integratedEvidenceGatePassed => 'AI 根拠ゲート：通過';

  @override
  String get integratedEvidenceGateNotPassed => 'AI 根拠ゲート：未通過 · 方向性スクリーニングのみ';

  @override
  String integratedQualifiedWarning(String reason) {
    return '$reason システムは最も可能性の高い方向を示し続けますが、確信度は下がります。証明ではなくスクリーニング結果として扱ってください。';
  }

  @override
  String get integratedIndexCaveat =>
      '独立した AI 根拠ゲートは、格上げに足るだけの独立した裏づけがあるかどうかを示します。引用の質、貼り付けの挙動、疑わしいメタデータは、それ単独で AI 判定を導くことはできません。これは根拠のスコアであり、較正された統計的確率ではありません。';

  @override
  String get reportTextEngineSignalExplanation =>
      'これらのバーは 4 つのテキストエンジンによる診断シグナルを示します。関連するエンジンは系統ごとにまとめられ（保守的に割り引かれた人間側の分類器出力を含む）、その後で言語・分野の適用可能性と較正の信頼度が適用されます。方向性は「どちらの説明がより裏づけられるか」に答え、独立した AI 根拠ゲートは「その裏づけが格上げに足るか」に答えます。';

  @override
  String reportSynthesisTextScoreContext(int percent) {
    return '4 エンジンのテキストモデル生スコア：$percent%。これは統合評価への入力の一つであり、第二の判定ではありません。';
  }

  @override
  String reportSynthesisStrongestTextSignal(String label, int percent) {
    return '最も強いテキストエンジンのシグナル：$label（$percent%）。テキストモデルのスコアに影響し得ますが、単独で統合評価を覆すことはできません。';
  }

  @override
  String composerTextScoreThresholdReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'テキストモデルの生スコアは $aiPercent% で、診断用の目安 $thresholdPercent% に達しています。これはテキストシグナルの観察にすぎず、レポートの執筆者方向は上記の統合評価のままです。';
  }

  @override
  String composerTextScoreThresholdNotReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'テキストモデルの生スコアは $aiPercent% で、診断用の目安 $thresholdPercent% を下回っています。この目安に届かないことは人間が書いた証拠にはならず、レポートの執筆者方向は上記の統合評価のままです。';
  }

  @override
  String telemetryIntegratedVerdict(
    String direction,
    int percent,
    String confidence,
  ) {
    return '利用可能な根拠を重み付けした結果、この文書は「$direction」です（AI 根拠指数 $percent/100、確信度 $confidence）。';
  }

  @override
  String telemetryIntegratedUnavailable(String direction, String confidence) {
    return '利用可能なモジュールからは定量化できる執筆者の方向性が得られませんでした（「$direction」、確信度 $confidence）。数値指数は発行されていません。';
  }

  @override
  String integratedStabilityLabel(int percent, int lower, int upper) {
    return 'セグメント安定性 $percent% · 区間 $lower〜$upper%';
  }

  @override
  String integratedInputQualityLabel(int percent) {
    return '入力抽出の品質：$percent%';
  }

  @override
  String integratedCalibrationLabel(String value, int count) {
    return '一致したローカル基準：p=$value · n=$count';
  }

  @override
  String analysisReadinessLabel(String level) {
    return '分析前の確信度ベースライン：$level';
  }

  @override
  String get analysisReadinessShortText => 'テキスト量が不足';

  @override
  String get analysisReadinessFewSentences => 'セグメント数が少なすぎる';

  @override
  String get analysisReadinessCoreModel => '中核分類器が利用不可';

  @override
  String get analysisReadinessFewEngines => '有効なエンジンが 2 つ未満';

  @override
  String get analysisReadinessExtraction => '抽出品質が限定的';

  @override
  String get analysisReadinessBaseline => '一致するローカル基準なし';

  @override
  String get ocrChipLocalVerified => 'ローカル OCR（検証済み）';

  @override
  String get ocrChipLocalUntested => 'ローカル OCR（未テスト）';

  @override
  String get ocrChipGeminiVerified => 'Gemini（検証済み）';

  @override
  String get ocrChipGeminiUntested => 'Gemini（未テスト）';

  @override
  String get ocrChipNone => 'OCR エンジン: 未設定';

  @override
  String ocrErrorLocalServerReported(String detail) {
    return 'ローカル OCR サーバーがエラーを報告しました: $detail';
  }

  @override
  String get ocrErrorLocalServerFormat =>
      'ローカル OCR サーバーの応答形式に互換性がありません。テキストブロックの配列、results[].text、または text が必要です。';

  @override
  String get ocrErrorNoTextDetected => 'OCR は完了しましたが、画像から使用可能なテキストは検出されませんでした。';

  @override
  String ocrErrorLocalServerStatus(String status, String detail) {
    return 'ローカル OCR サーバーが HTTP $status を返しました: $detail';
  }

  @override
  String ocrErrorLocalUnreachable(String detail) {
    return 'ローカル OCR サーバーに接続できないか、タイムアウトしました: $detail';
  }

  @override
  String get ocrErrorNotConfigured =>
      'OCR は未設定です。設定で Gemini API キーを入力するか、ローカル OCR サーバーの URL を指定してください。';

  @override
  String get ocrErrorGeminiNoParsableText =>
      'Gemini は応答しましたが、解析可能なテキストが含まれていません。';

  @override
  String get ocrErrorGeminiRateLimited =>
      'Gemini OCR がレート制限またはクォータ上限（429）に達しました。しばらくしてから再試行するか、ローカル OCR サーバーをご利用ください。';

  @override
  String ocrErrorGeminiBadRequest(String detail) {
    return 'Gemini OCR がリクエストを拒否しました（400）: $detail';
  }

  @override
  String get ocrErrorGeminiUnauthorized =>
      'Gemini API キーが無効または未認可です（401）。有効なキーを貼り直してください。';

  @override
  String ocrErrorGeminiHttpFailed(String status, String detail) {
    return 'Gemini OCR に失敗しました（HTTP $status）: $detail';
  }

  @override
  String ocrErrorGeminiException(String detail) {
    return 'Gemini OCR の接続または解析に失敗しました: $detail';
  }

  @override
  String get ocrErrorNoImageData =>
      '画像データを取得できませんでした。画像を選び直してください。それでも失敗する場合、ブラウザーがファイルのバイト列を提供していない可能性があります。';

  @override
  String ocrErrorGeminiKeyInvalid(String status) {
    return 'Gemini API キーが無効または未認可です（HTTP $status）。';
  }

  @override
  String ocrErrorGeminiTestFailed(String status) {
    return 'Gemini API の接続テストに失敗しました（HTTP $status）。';
  }

  @override
  String ocrErrorGeminiTestException(String detail) {
    return 'Gemini API の接続テストに失敗しました: $detail';
  }

  @override
  String get ocrErrorNativePluginNoPing =>
      'このプラットフォームのネイティブ OCR プラグインが ping に応答しませんでした。';

  @override
  String get ocrErrorNativePluginMissing =>
      'このプラットフォームにはネイティブ OCR プラグインが登録されていません。';

  @override
  String ocrErrorNativeCheckFailed(String detail) {
    return 'ネイティブ OCR プラグインの確認に失敗しました: $detail';
  }

  @override
  String ocrErrorNativeFailed(String detail) {
    return 'ネイティブ OCR の実行に失敗しました: $detail';
  }

  @override
  String get settingsEngineLlmTitle => 'レポート生成 LLM';

  @override
  String get modelNameGemma2Llm => 'Gemma 2 · 2B Instruct（Q4_K_M）';

  @override
  String get firstRunModelListTitle => 'ダウンロードするモデル';

  @override
  String get firstRunModelOptionalReason => '任意 — レポートの文章のみに影響し、判定結果には影響しません';

  @override
  String get firstRunModelStorageReason => 'ブラウザーの空き容量に収まらない可能性があります';

  @override
  String firstRunModelRamReason(String ramGb) {
    return '$ramGb GB のメモリーが必要で、このデバイスの報告値を超えています';
  }

  @override
  String firstRunModelSelectionSummary(int count, String size) {
    return '$count 件を選択 · 合計 $size';
  }

  @override
  String get firstRunModelConfirm => '選択した項目をダウンロード';

  @override
  String get firstRunModelCancel => 'キャンセル';

  @override
  String get firstRunModelManualTitle => 'あとで自分でダウンロードする';

  @override
  String get firstRunModelManualBody =>
      'いつでもご自身でダウンロードできます。「設定」（上部ツールバーの歯車アイコン）を開き、「AIモデル管理」を選んでください。それまでも TruthLens は統計エンジンと文体エンジンで動作します。';

  @override
  String get commonGotIt => '了解';
}
