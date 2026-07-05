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
  String get settingsThresholdTitle => 'AI判定の信頼度しきい値';

  @override
  String settingsThresholdSubtitle(int percent) {
    return '現在：$percent% — 上げると誤検知（人間の文章をAIと誤判定）を減らせます';
  }

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
  String get settingsLanguagePackTitle => '言語パック';

  @override
  String get settingsLanguagePackSubtitle => '追加の言語微調整モデル（フェーズ4で提供予定）';

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
  String get reportEngineBreakdownTitle => 'エンジン内訳';

  @override
  String get reportEngineNotInstalled => '未インストール';

  @override
  String get reportSentenceAnalysisTitle => '文単位の分析';

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
  String get reportBibResultHint =>
      '著者名、発行年、タイトルの類似度でCrossrefの公開登録データと照合します。絶対的な保証ではありません。「不確定」の場合は自分で確認することをお勧めします。';

  @override
  String reportBibHighConfidence(String journal) {
    return '高信頼度：実在する可能性が高い$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（$journalに登録済み）';
  }

  @override
  String get reportBibNotFound => '近い一致が見つかりません。虚偽の参考文献の可能性があります';

  @override
  String get reportBibUncertain =>
      '類似度が中程度、または接続に失敗しました。不確定のため、自分で確認することをお勧めします';

  @override
  String reportBibTruncated(int max, int count) {
    return '最初の $max 件のみ検証しました（検出総数 $count 件）';
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
    return '総合AI確率が設定した $percent% のしきい値を超え、AIとしてフラグが立てられました。';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return '総合AI確率は設定した $percent% のフラグしきい値未満です。';
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
  String engineReasonTtrLow(String value) {
    return '語彙の多様性が低く（TTR $value）、単語の反復度が高いです';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return '語彙の多様性が高いです（TTR $value）';
  }

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
  String get engineReasonAdversarialNotInstalled =>
      '言い換え検出モデルが未インストールのため、今回の投票に参加していません';

  @override
  String get engineReasonTransformerNotInstalled =>
      'モデルが未インストール、または使用中のモデルがサポートされていないため、今回の投票に参加していません';

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
  String get engineReasonDisabledByUser => 'ユーザーが設定でこのエンジンを無効にしています';

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
      'TruthLensは、コアAI推論を完全にデバイス上で実行するクロスプラットフォームのコンテンツ検出アプリです（iOS / Android / macOS / Windows）。Transformerニューラルネットワーク分類器、統計分析、文体分析、敵対的言い換え検出という4つの独立したサブモデルが加重投票を行い、テキストがAI生成かどうかを判定し、文単位で説明可能な分析理由を提供します。「AIらしい」というパーセンテージを示すだけでなく、「なぜ」なのかを説明します。';

  @override
  String get helpComparisonTitle => '主要ツールとの比較';

  @override
  String get helpComparisonDisclaimer =>
      '以下の比較は各ツールの公開情報と一般的な市場認識に基づいて整理したものであり、機能的な位置付けの参考のみを目的としています。第三者認証によるベンチマークデータではありません。';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZeroの処理は主にクラウドで行われ、文書のアップロードが必要です。TruthLensの4つの検出エンジンはすべてデバイス上で実行されます。';

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
      'Originality.aiは文書ごとの課金制サブスクリプションで、文書をクラウドにアップロードする必要があります。TruthLensのコア処理はデバイス上で実行され、検出機能の使用に継続的な支払いは不要です。';

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
      'Winston AIのOCR画像認識は画像をクラウドにアップロードする必要があります。TruthLensは各プラットフォームのネイティブフレームワーク（iOS／macOSのVision、AndroidのML Kit、WindowsのWindows.Media.Ocr）を使用してデバイス上で認識を行います。';

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
  String get helpWorkflowStep1Title => 'モデルのダウンロードと更新';

  @override
  String get helpWorkflowStep1Body =>
      '初回起動時にコア検出モデルのインストールが案内されます。その後はいつでも「設定 → AIモデル管理」から確認、ダウンロード、更新、削除ができます。アプリは起動時に最新バージョンを自動的に確認し、更新がある場合は設定の歯車アイコンと「AIモデル管理」項目に通知バッジが表示されます。';

  @override
  String get helpWorkflowStep2Title => 'モデルの選び方（目的と効果）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      '多言語AI分類器（重み40%）：総合判定の主力で、文単位のAI確率予測を行い、精度向上への貢献が最も大きいです。';

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
      '「設定」で各エンジンの有効／無効を個別に切り替えたり、AI判定の信頼度しきい値を調整したりできます（上げると人間の文章をAIと誤判定する確率を下げられます）。';

  @override
  String get helpWorkflowStep3Title => '文書のアップロード';

  @override
  String get helpWorkflowStep3Body =>
      '3つの入力方法：テキストを直接貼り付け、画像OCR（各プラットフォームのネイティブフレームワークでオフライン認識）、ファイルの読み込み（txt / md / pdf / docx / doc）。分析を送信するにはテキストが40文字以上必要です。';

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
}
