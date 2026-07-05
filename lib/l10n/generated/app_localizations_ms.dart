// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonDelete => 'Padam';

  @override
  String get commonClose => 'Tutup';

  @override
  String get verdictHuman => 'Ditulis oleh manusia';

  @override
  String get verdictLikelyHuman => 'Kemungkinan manusia';

  @override
  String get verdictMixed => 'Kandungan campuran';

  @override
  String get verdictLikelyAi => 'Kemungkinan AI';

  @override
  String get verdictAi => 'Dijana AI';

  @override
  String get inputSubtitle =>
      'Tampal atau taip teks untuk mengesan kandungan yang dijana AI';

  @override
  String get inputHint => 'Taip atau tampal teks untuk dianalisis…';

  @override
  String get inputHistoryTooltip => 'Sejarah';

  @override
  String get inputHelpTooltip => 'Panduan Pengguna';

  @override
  String get inputPrivacyTooltip => 'Dasar Privasi';

  @override
  String get inputSettingsTooltip => 'Tetapan';

  @override
  String get inputPasteButton => 'Tampal';

  @override
  String get inputOcrButton => 'OCR Imej';

  @override
  String get inputImportButton => 'Import Fail';

  @override
  String get inputStartButton => 'Mula Mengesan';

  @override
  String get inputClearTooltip => 'Kosongkan kandungan';

  @override
  String get inputTooShortSnackbar =>
      'Sila masukkan sekurang-kurangnya 40 aksara untuk analisis yang boleh dipercayai';

  @override
  String get inputOcrUnsupported =>
      'Pengecaman teks OCR tidak disokong pada platform ini';

  @override
  String get inputOcrRecognizing => 'Sedang mengecam…';

  @override
  String get inputOcrNoText => 'Tiada teks dikenal pasti dalam imej';

  @override
  String inputOcrRecognized(int count) {
    return 'Berjaya kenal pasti $count aksara';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\" tiada kandungan teks yang boleh dibaca';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '\"$fileName\" telah diimport（$count aksara）';
  }

  @override
  String inputActiveModel(String modelId) {
    return 'Model: $modelId';
  }

  @override
  String get inputNoModel =>
      'Tiada model dipasang（hanya analisis statistik/gaya）';

  @override
  String inputCharCount(int count) {
    return '$count aksara';
  }

  @override
  String get analysisAppBarTitle => 'Menganalisis';

  @override
  String get analysisEngineTransformer => 'Pengelas Transformer';

  @override
  String get analysisEngineStatistical => 'Analisis Statistik';

  @override
  String get analysisEngineStylometry => 'Analisis Gaya Penulisan';

  @override
  String get analysisEngineAdversarial => 'Pertahanan Adversarial';

  @override
  String analysisProgressSemantics(int done, int total) {
    return 'Analisis sedang berjalan, $done daripada $total enjin selesai';
  }

  @override
  String get analysisDoneSemantics => 'Selesai';

  @override
  String get engineNameAdversarialFull =>
      'Pertahanan Adversarial（Pengesanan Parafrasa）';

  @override
  String get modelNecessityText =>
      'Tanpa memuat turun model pengesanan rangkaian neural, TruthLens masih berfungsi tetapi hanya menggunakan analisis statistik dan gaya penulisan, dengan ketepatan dan sokongan berbilang bahasa yang terhad. Selepas memuat turun model, pengelas Transformer berbilang bahasa akan menyertai undian ensemble, meningkatkan ketepatan dan kebolehpercayaan dengan ketara. Model dijalankan pada peranti; selepas dimuat turun, ia tidak memuat naik sebarang kandungan.';

  @override
  String get modelPromptTitle =>
      'Disyorkan memuat turun model pengesanan untuk analisis lengkap';

  @override
  String get modelPromptDontRemind => 'Jangan ingatkan saya lagi';

  @override
  String get modelPromptSkip => 'Langkau buat masa ini';

  @override
  String get modelPromptDownload => 'Pergi memuat turun';

  @override
  String get onboardingWelcomeTitle => 'Selamat datang ke TruthLens';

  @override
  String get onboardingHeadline => 'Pengesanan kandungan AI pada peranti';

  @override
  String get onboardingDetectedDevice => 'Peranti dikesan';

  @override
  String get onboardingChooseModel => 'Pilih model untuk dimuat turun';

  @override
  String get onboardingRecommendHint =>
      '\"Disyorkan\" ditanda berdasarkan perkakasan anda; anda juga boleh memilih pilihan lain.';

  @override
  String get onboardingSkipButton =>
      'Putuskan kemudian（guna analisis statistik/gaya tanpa model）';

  @override
  String get onboardingSkipHint =>
      'Anda masih boleh memuat turun bila-bila masa dari \"Tetapan → Pengurusan Model AI\"; anda akan diingatkan semula apabila menggunakan analisis yang memerlukan model.';

  @override
  String get modelListCustomImportedLabel => 'Model diimport tersuai:';

  @override
  String get modelListActiveChip => 'Digunakan';

  @override
  String get modelListRecommendedChip => 'Disyorkan';

  @override
  String get modelListCustomChip => 'Tersuai';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · Perlu ${ram}GB RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'Saiz: $size · Tokenizer: $tokenizer · Indeks Label AI: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'Memuat turun… $percent%（$downloaded / $total）';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'Muat turun（$size）';
  }

  @override
  String get modelListComingSoonChip => 'Akan datang';

  @override
  String get modelListSetActiveButton => 'Tetapkan sebagai aktif';

  @override
  String get modelListUpdateButton => 'Kemas kini';

  @override
  String get modelListDeleteTooltip => 'Padam';

  @override
  String get modelListPageButton => 'Halaman model';

  @override
  String get modelListMayExceedMemory => 'Mungkin melebihi memori peranti';

  @override
  String modelListFailedPrefix(String error) {
    return 'Gagal: $error';
  }

  @override
  String get modelListDeleteConfirmTitle => 'Padam model?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return 'Ini akan memadam \"$name\"（$size）. Anda perlu memuat turun semula untuk menggunakannya lagi.';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'Ini akan memadam \"$name\" yang diimport tersuai（$size）. Anda perlu mengimport semula untuk menggunakannya lagi.';
  }

  @override
  String get modelImportAppBarTitle => 'Import Model ONNX Tersuai';

  @override
  String get modelImportStep1Title => '1. Pilih fail model ONNX';

  @override
  String modelImportSelectedFile(String name) {
    return 'Dipilih: $name';
  }

  @override
  String get modelImportNoFileSelected => 'Tiada fail model dipilih (.onnx)';

  @override
  String get modelImportBrowseButton => 'Semak imbas';

  @override
  String get modelImportCheckingDuplicate =>
      'Menyemak sama ada fail yang sama telah diimport…';

  @override
  String get modelImportDuplicateTitle =>
      'Model dengan kandungan yang sama telah diimport';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'Fail ini mempunyai kandungan yang sama sepenuhnya dengan \"$name\"（peranan: $role）. Jika anda hanya ingin menukar model aktif, pergi ke \"Pengurusan Model AI\" dan tetapkan sebagai aktif secara terus — tidak perlu import semula. Anda masih boleh meneruskan langkah di bawah.';
  }

  @override
  String get modelImportStep2Title => '2. Konfigurasi';

  @override
  String get modelImportNameLabel => 'Nama paparan model';

  @override
  String get modelImportNameRequired => 'Nama tidak boleh kosong';

  @override
  String get modelImportRoleLabel => 'Peranan enjin sasaran';

  @override
  String get modelImportTokenizerTypeLabel => 'Jenis Tokenizer';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => 'Tiada (tiada Tokenizer/aras aksara)';

  @override
  String get modelImportNoTokenizerSelected =>
      'Tiada fail Tokenizer dipilih (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return 'Dipilih: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'Indeks output label AI';

  @override
  String get modelImportIndex0 => 'Indeks 0 (cth. RoBERTa)';

  @override
  String get modelImportIndex1 => 'Indeks 1 (cth. DistilBERT)';

  @override
  String get modelImportStep3Title => '3. Uji & sahkan';

  @override
  String get modelImportTestInputLabel => 'Teks input ujian';

  @override
  String get modelImportRunTestButton => 'Jalankan inferens ujian';

  @override
  String get modelImportResultLabel => 'Hasil inferens (kebarangkalian AI):';

  @override
  String modelImportTestFailed(String error) {
    return 'Ujian gagal: $error';
  }

  @override
  String get modelImportConfirmButton => 'Sahkan import dan aktifkan model';

  @override
  String get modelImportSelectTokenizerFirst =>
      'Sila pilih fail Tokenizer dahulu';

  @override
  String get modelImportSelectTokenizer => 'Sila pilih fail Tokenizer';

  @override
  String get modelImportSuccessSnackbar =>
      'Model berjaya diimport! Ditetapkan secara automatik sebagai model aktif.';

  @override
  String get modelImportFailedSnackbar =>
      'Import model gagal. Sila semak kebenaran atau log';

  @override
  String get settingsAppBarTitle => 'Tetapan';

  @override
  String get settingsThresholdTitle => 'Ambang keyakinan penentuan AI';

  @override
  String settingsThresholdSubtitle(int percent) {
    return 'Semasa: $percent% — meningkatkannya mengurangkan positif palsu (teks manusia disalah anggap sebagai AI)';
  }

  @override
  String get settingsEslTitle => 'Pembetulan bias ESL (bukan penutur asli)';

  @override
  String get settingsEslSubtitle =>
      'Secara automatik mengurangkan pemberat model statistik apabila gaya penulisan bukan penutur asli dikesan';

  @override
  String get settingsEngineSectionTitle =>
      'Tetapan enjin sub-pengesanan (Ensemble)';

  @override
  String get settingsEngineTransformerTitle =>
      'Pengelas AI berbilang bahasa (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Menggunakan model rangkaian neural Transformer untuk ramalan kebarangkalian AI pada peranti';

  @override
  String get settingsEngineStatisticalTitle =>
      'Enjin analisis statistik (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      'Menentukan keteraturan bahasa melalui variasi panjang ayat, Burstiness dan PPL';

  @override
  String get settingsEngineStylometryTitle =>
      'Analisis gaya penulisan (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle =>
      'Menganalisis kelancaran semantik, corak ayat berulang dan penggunaan kata hubung';

  @override
  String get settingsEngineAdversarialTitle =>
      'Pengesanan parafrasa adversarial (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle =>
      'Mengesan sama ada teks telah diparafrasa mesin atau diproses untuk menghapuskan kesan AI';

  @override
  String get settingsLinkVerificationTitle =>
      'Pengesahan pautan hiper & bibliografi';

  @override
  String get settingsLinkVerificationSubtitle =>
      'Laporan akan menyambung untuk menyemak sama ada URL dan entri bibliografi yang dikesan dalam dokumen benar-benar wujud (kandungan yang dijana AI sering menyertakan rujukan yang kelihatan munasabah tetapi rekaan). Pautan akademik format DOI, dan rujukan format \"pengarang—tahun\" tanpa pautan, kedua-duanya disemak terhadap daftar awam Crossref. Model pengesanan AI teras masih berjalan sepenuhnya pada peranti dan tidak pernah menghantar kandungan dokumen; sambungan hanya digunakan untuk pengesahan ini dan semakan kemas kini model, dan boleh dimatikan di sini.';

  @override
  String get settingsThemeTitle => 'Tema paparan';

  @override
  String get settingsLanguageTitle => 'Bahasa';

  @override
  String get settingsLanguageSubtitle => 'Pilih bahasa paparan aplikasi';

  @override
  String get settingsModelManagementTitle => 'Pengurusan Model AI';

  @override
  String get settingsModelManagementSubtitle =>
      'Muat turun model pengesanan dan LLM penulisan laporan untuk mengaktifkan keupayaan inferens penuh';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'Kemas kini model dikesan — disyorkan untuk disemak';

  @override
  String get settingsOpenButton => 'Buka';

  @override
  String get settingsCustomImportTitle => 'Import & uji model ONNX tersuai';

  @override
  String get settingsCustomImportSubtitle =>
      'Import model ONNX tersuai tempatan dan konfigurasi Tokenizer serta jalankan ujian inferens';

  @override
  String get settingsLanguagePackTitle => 'Pek bahasa';

  @override
  String get settingsLanguagePackSubtitle =>
      'Model penalaan bahasa tambahan (tersedia dalam fasa 4)';

  @override
  String get settingsModelManagerAppBarTitle => 'Pengurusan Model AI';

  @override
  String get settingsImportTooltip => 'Import model ONNX tempatan';

  @override
  String settingsDeviceLabel(String summary) {
    return 'Peranti: $summary';
  }

  @override
  String get historyAppBarTitle => 'Sejarah';

  @override
  String get historyClearAllTooltip => 'Kosongkan semua';

  @override
  String get historySearchHint => 'Cari sejarah…';

  @override
  String get historyDeletedSnackbar => 'Entri telah dipadam';

  @override
  String get historyClearAllTitle => 'Kosongkan semua sejarah?';

  @override
  String historyClearAllBody(int count) {
    return 'Ini akan memadam semua $count entri. Tindakan ini tidak boleh dibatalkan.';
  }

  @override
  String get historyClearButton => 'Kosongkan';

  @override
  String get historyDeleteEntryTitle => 'Padam entri ini?';

  @override
  String get historyReanalyzeTooltip => 'Analisis semula';

  @override
  String get historyEmptyDefault => 'Belum ada sejarah pengesanan';

  @override
  String historyEmptySearch(String query) {
    return 'Tiada entri sepadan dengan \"$query\"';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, kebarangkalian AI $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => 'Laporan Pengesanan';

  @override
  String get reportExportTooltip => 'Eksport laporan';

  @override
  String get reportHomeTooltip => 'Kembali ke utama';

  @override
  String get reportGeneratingTitle => 'Menjana laporan…';

  @override
  String get reportSourceLlm => 'Laporan dijana AI';

  @override
  String get reportSourceTemplate => 'Laporan dijana templat';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '$total ayat · $ai kemungkinan AI · $human kemungkinan manusia · $seconds saat berlalu';
  }

  @override
  String get reportExportPdf => 'Eksport laporan PDF';

  @override
  String get reportExportCsv => 'Eksport data CSV';

  @override
  String get reportExportJson => 'Eksport JSON (integrasi sistem)';

  @override
  String get reportExportPng => 'Eksport kad ringkasan (PNG)';

  @override
  String reportExported(String path) {
    return 'Dieksport: $path';
  }

  @override
  String reportExportFailed(String error) {
    return 'Eksport gagal: $error';
  }

  @override
  String get reportEngineBreakdownTitle => 'Perincian enjin';

  @override
  String get reportEngineNotInstalled => 'Tidak dipasang';

  @override
  String get reportSentenceAnalysisTitle => 'Analisis peringkat ayat';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text. Kebarangkalian AI $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'Ketulenan pautan hiper';

  @override
  String get reportLinkNoneDetected =>
      'Tiada pautan hiper dikesan dalam dokumen ini.';

  @override
  String get reportLinkCheckingProgress => 'Mengesahkan pautan…';

  @override
  String reportLinkDetectedPending(int count) {
    return '$count pautan hiper dikesan; belum disahkan';
  }

  @override
  String get reportLinkDisabledHint =>
      'Kandungan yang dijana AI sering menyertakan pautan rujukan yang kelihatan munasabah tetapi rekaan. Anda telah mematikan pengesahan pautan hiper dalam Tetapan; anda boleh menghidupkannya semula untuk pengesahan automatik, atau ketik di bawah untuk semakan sekali sahaja.';

  @override
  String get reportVerifyNowButton => 'Sahkan sekarang (perlu rangkaian)';

  @override
  String get reportLinkReachable => 'Boleh dicapai — URL wujud';

  @override
  String get reportLinkNotFound =>
      'URL tidak wujud (404) — mungkin rujukan rekaan';

  @override
  String get reportLinkUnreachable =>
      'Tidak dapat disahkan (tamat masa atau tiada respons pelayan)';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'Disahkan dalam daftar jurnal: berdaftar dengan $journal$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      'Tiada pendaftaran DOI sepadan ditemui — mungkin rujukan rekaan';

  @override
  String get reportLinkCitationUnreachable =>
      'Tidak dapat disahkan (tamat masa atau tiada respons daripada Crossref)';

  @override
  String reportLinkTruncated(int max, int count) {
    return 'Hanya $max pautan pertama disahkan (jumlah $count dikesan)';
  }

  @override
  String get reportBibAuthenticityTitle => 'Ketulenan petikan';

  @override
  String get reportBibNoneDetected =>
      'Tiada entri bibliografi dikesan dalam dokumen ini.';

  @override
  String get reportBibCheckingProgress => 'Mengesahkan bibliografi…';

  @override
  String reportBibDetectedPending(int count) {
    return 'Bibliografi dikesan ($count entri); belum disahkan';
  }

  @override
  String get reportBibDisabledHint =>
      'Kandungan yang dijana AI sering menyertakan rujukan yang kelihatan munasabah tetapi rekaan. Anda telah mematikan pengesahan pautan hiper dalam Tetapan; anda boleh menghidupkannya semula untuk pengesahan automatik, atau ketik di bawah untuk semakan sekali sahaja.';

  @override
  String get reportVerifyNowBibButton => 'Sahkan sekarang (perlu rangkaian)';

  @override
  String get reportBibResultHint =>
      'Dipadankan terhadap daftar awam Crossref mengikut persamaan pengarang, tahun dan tajuk. Bukan jaminan mutlak — apabila \"tidak pasti\", sila sahkan secara manual.';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Keyakinan tinggi: kemungkinan wujud$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (berdaftar dengan $journal)';
  }

  @override
  String get reportBibNotFound =>
      'Tiada padanan hampir ditemui — mungkin rujukan rekaan';

  @override
  String get reportBibUncertain =>
      'Persamaan sederhana atau sambungan gagal — tidak pasti, sila sahkan secara manual';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Hanya $max entri pertama disahkan (jumlah $count dikesan)';
  }

  @override
  String get reportNetworkWarningTitle => 'Sambungan rangkaian lemah';

  @override
  String get reportNetworkWarningBody =>
      'Apl ini mengandaikan sambungan rangkaian tersedia secara lalai; analisis ketulenan pautan hiper dan petikan kedua-duanya memerlukan akses rangkaian untuk menghasilkan keputusan. Sambungan tidak dapat diwujudkan — sila semak rangkaian anda dan cuba lagi.';

  @override
  String get reportRetryConnectionButton => 'Semak semula sambungan';

  @override
  String get reportAiProbabilityLabel => 'Kebarangkalian AI';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '$total ayat\n$ai kemungkinan AI\n$human kemungkinan manusia';
  }

  @override
  String get summaryCardFooter =>
      'Inferens AI teras berjalan sepenuhnya pada peranti';

  @override
  String get exportReportTitle => 'Laporan Pengesanan TruthLens';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · Halaman $page / $total';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return 'Dianalisis: $datetime · $seconds saat berlalu';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return 'Penentuan keseluruhan: $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => ' (pembetulan ESL digunakan)';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '$total ayat · $ai kemungkinan AI · $human kemungkinan manusia';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'Untuk mengekalkan kebolehbacaan PDF, hanya $max ayat pertama dipaparkan (daripada jumlah $count); untuk data penuh setiap ayat, gunakan \"$csvLabel\" atau \"$jsonLabel\" sebagai gantinya.';
  }

  @override
  String get pdfSentenceColumnHeader => 'Ayat (dengan corak sepadan)';

  @override
  String composerHeadlineAi(int percent) {
    return 'Teks ini berkemungkinan besar dijana AI (kebarangkalian AI $percent%)';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'Teks ini cenderung dijana AI; disyorkan semakan lanjut (kebarangkalian AI $percent%)';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'Teks ini menunjukkan ciri campuran manusia dan AI (kebarangkalian AI $percent%)';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'Teks ini cenderung ditulis oleh manusia (kebarangkalian AI $percent%)';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'Teks ini berkemungkinan besar ditulis oleh manusia (kebarangkalian AI $percent%)';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return 'Kebarangkalian AI keseluruhan melebihi ambang $percent% yang anda tetapkan dan ditandakan sebagai AI.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'Kebarangkalian AI keseluruhan di bawah ambang penandaan $percent% yang anda tetapkan.';
  }

  @override
  String get composerNarrativeTitle => 'Interpretasi analisis';

  @override
  String get composerParaphraseTitle => 'Kesan parafrasa dikesan';

  @override
  String get composerParaphraseBody =>
      'Teks ini mungkin telah diproses oleh alat parafrasa (cth. QuillBot, Undetectable.ai) untuk mengelak pengesanan. Walaupun ia kelihatan semula jadi ayat demi ayat, cap jari statistik keseluruhannya masih berbeza daripada penulisan manusia yang tulen — sila beri perhatian khusus.';

  @override
  String get composerPatternListTitle => 'Corak penulisan AI utama';

  @override
  String get composerEslTitle => 'Pembetulan bias ESL (bukan penutur asli)';

  @override
  String get composerEslBody =>
      'Teks ini mungkin daripada penulis bukan penutur asli. Kekeliruan rendah dan corak ayat teratur yang biasa dalam kalangan penulis bukan penutur asli bukanlah tanda AI dengan sendirinya, jadi sistem telah mengurangkan pemberat model statistik untuk mengelakkan salah anggap.';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return 'Teks ini mempunyai $total ayat secara keseluruhan, di mana $ai menunjukkan ciri AI yang kuat dan $human cenderung ditulis manusia.';
  }

  @override
  String get composerNarrativeAiPattern =>
      'Kebanyakan ayat sangat teratur dari segi rentak, pilihan perkataan dan penggunaan kata hubung — cap jari biasa teks yang dijana AI.';

  @override
  String get composerNarrativeMixedPattern =>
      'Teks mengandungi kedua-dua bahagian yang teratur dan berubah-ubah secara semula jadi, menunjukkan draf manusia yang digilap AI, atau kerjasama manusia-AI.';

  @override
  String get composerNarrativeHumanPattern =>
      'Panjang ayat dan pilihan perkataan menunjukkan variasi semula jadi dan gaya peribadi, tanpa tanda keteraturan AI yang jelas.';

  @override
  String engineReasonPplLow(String ppl) {
    return 'Kekeliruan model bahasa rendah ($ppl) — teks sangat boleh diramal, penunjuk penjanaan AI';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'Kekeliruan model bahasa tinggi ($ppl), selaras dengan sifat tidak boleh diramal penulisan manusia';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'Kekeliruan model bahasa sederhana ($ppl)';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'Panjang ayat sangat seragam (burstiness $value) — rentak yang sekata adalah tanda statistik biasa teks yang dijana AI';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'Variasi ketara dalam panjang ayat (burstiness $value), selaras dengan rentak semula jadi penulisan manusia';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'Kepelbagaian perbendaharaan kata rendah (TTR $value) — pengulangan perkataan tinggi';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'Kepelbagaian perbendaharaan kata tinggi (TTR $value)';
  }

  @override
  String get engineReasonNeutral =>
      'Petunjuk statistik tidak menunjukkan kecenderungan ketara — penentuan neutral dikekalkan';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return 'Penggunaan kerap kata hubung generik ($words), purata $density setiap ayat — jarang sepadat ini dalam penulisan manusia';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return 'Beberapa ayat bersebelahan bermula dengan perkataan yang sama ($count kejadian) — struktur ayat berulang';
  }

  @override
  String get engineReasonNoStyleMarkers =>
      'Tiada corak penulisan AI yang ketara dikesan';

  @override
  String get engineReasonAdversarialNotInstalled =>
      'Model pengesanan parafrasa tidak dipasang; ia tidak mengambil bahagian dalam undian ini';

  @override
  String get engineReasonTransformerNotInstalled =>
      'Tiada model dipasang atau model aktif tidak disokong; ia tidak mengambil bahagian dalam undian ini';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'Model gagal dimuatkan dan tidak mengambil bahagian dalam undian ini ($error)';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model menilai $aiCount daripada $total ayat menunjukkan ciri AI';
  }

  @override
  String get engineReasonAdversarialDetected =>
      'Model adversarial mengesan kesan AI yang mungkin dihapuskan oleh alat parafrasa (cth. QuillBot / Undetectable.ai)';

  @override
  String get engineReasonAdversarialClean =>
      'Tiada kesan pengelakan parafrasa yang jelas dikesan';

  @override
  String get engineReasonDisabledByUser =>
      'Pengguna telah mematikan enjin ini dalam Tetapan';

  @override
  String get engineReasonGenericNotInstalled =>
      'Model tidak dipasang; tidak mengambil bahagian dalam undian ini';

  @override
  String patternGenericTransition(String word) {
    return 'kata hubung generik \"$word\"';
  }

  @override
  String get helpAppBarTitle => 'Panduan Pengguna';

  @override
  String get helpAboutTitle => 'Mengenai TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens ialah aplikasi pengesanan kandungan merentas platform (iOS / Android / macOS / Windows) yang mana inferens AI terasnya berjalan sepenuhnya pada peranti. Empat sub-model bebas — pengelas neural Transformer, analisis statistik, analisis stilometrik, dan pengesanan parafrasa adversarial — mengundi bersama untuk menentukan sama ada teks dijana AI, dengan sebab yang boleh dijelaskan ayat demi ayat: bukan sekadar peratusan \"kelihatan seperti AI\", tetapi penjelasan \"mengapa\".';

  @override
  String get helpComparisonTitle => 'Perbandingan dengan alat terkemuka';

  @override
  String get helpComparisonDisclaimer =>
      'Perbandingan ini disusun daripada maklumat awam setiap alat dan persepsi pasaran umum, hanya untuk rujukan kedudukan fungsi — bukan data penanda aras yang disahkan pihak ketiga.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'Pemprosesan GPTZero berjalan terutamanya di awan dan memerlukan muat naik dokumen anda; keempat-empat enjin pengesanan TruthLens berjalan pada peranti.';

  @override
  String get helpVsGptZero2 =>
      'GPTZero mempelopori metrik Perplexity/Burstiness dan penyerlahan ayat — TruthLens menggabungkan ini dan menambah pengelas Transformer, analisis stilometrik, dan pertahanan adversarial, membentuk undian ensemble empat model dan bukan metrik tunggal.';

  @override
  String get helpVsGptZero3 =>
      'GPTZero berasaskan langganan; TruthLens tidak memerlukan langganan dan tiada had penggunaan.';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin dijual hanya kepada institusi; individu tidak boleh membelinya secara langsung. Sesiapa sahaja boleh memasang dan menggunakan TruthLens.';

  @override
  String get helpVsTurnitin2 =>
      'Proses keputusan Turnitin hampir seperti kotak hitam; TruthLens menyediakan kebarangkalian AI setiap ayat, corak penulisan yang sepadan, dan perincian skor serta sebab setiap enjin.';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin kebanyakannya memberikan keputusan binari \"adakah ia AI\"; TruthLens menyokong pelabelan manusia/AI/campuran pada peringkat perenggan/ayat.';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai ialah langganan setiap dokumen yang memerlukan muat naik dokumen anda ke awan; pemprosesan teras TruthLens berjalan pada peranti tanpa langganan berterusan diperlukan untuk pengesanan.';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai menawarkan konsep semakan fakta dan analisis kebolehbacaan; TruthLens menyahut ini dengan modul ciri gaya pada peranti, dan boleh melakukan analisis asas walaupun luar talian.';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks terutamanya API awan yang terkenal dengan kadar positif palsu yang rendah dan sokongan berbilang bahasa yang kukuh; TruthLens menggunakan falsafah yang sama dengan model asas berbilang bahasa XLM-RoBERTa dan undian ensemble berbilang model, tetapi kandungan dokumen anda tidak pernah dimuat naik ke mana-mana pelayan.';

  @override
  String get helpVsCopyleaks2 =>
      'Copyleaks mempunyai had penggunaan API bergantung pada pelan; TruthLens tiada had penggunaan.';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'Pengecaman imej OCR Winston AI memerlukan muat naik imej ke awan; TruthLens menggunakan rangka kerja natif setiap platform (Vision pada iOS/macOS, ML Kit pada Android, Windows.Media.Ocr pada Windows) untuk mengecam teks pada peranti.';

  @override
  String get helpVsWinston2 =>
      'Winston AI terkenal dengan laporan yang kemas dan boleh dicetak; TruthLens menjana susun atur laporan dinamik oleh AI (kembali kepada templat jika tiada LLM dipasang), boleh dieksport sebagai PDF/CSV/JSON/PNG.';

  @override
  String get helpAdvantagesTitle => 'Kelebihan khusus TruthLens';

  @override
  String get helpAdvantage1 =>
      'Pengesahan ketulenan pautan hiper: secara automatik menyemak sama ada URL yang ditemui dalam dokumen benar-benar boleh dicapai; pautan akademik format DOI disemak lagi terhadap daftar awam Crossref untuk mengesahkan jurnal benar-benar mengindeks karya tersebut.';

  @override
  String get helpAdvantage2 =>
      'Pengesahan ketulenan petikan: walaupun rujukan tanpa sebarang pautan hiper (gaya \"pengarang—tahun\" biasa) boleh disemak terhadap daftar bibliografi untuk mengesan petikan yang berkemungkinan rekaan — tanda biasa halusinasi AI.';

  @override
  String get helpAdvantage3 =>
      'Pembetulan bias ESL (bukan penutur asli): secara automatik mengesan ciri penulisan bukan penutur asli dan mengurangkan pemberat model statistik, mengelakkan salah anggap penulisan semula jadi bukan penutur asli sebagai AI.';

  @override
  String get helpAdvantage4 =>
      'Import model tersuai: pengguna lanjutan boleh mengimport model ONNX tempatan mereka sendiri untuk menggantikan atau menambah enjin pengesanan terbina dalam.';

  @override
  String get helpWorkflowTitle => 'Aliran kerja operasi penuh';

  @override
  String get helpWorkflowStep1Title => 'Muat turun & kemas kini model';

  @override
  String get helpWorkflowStep1Body =>
      'Pelancaran pertama membimbing anda memasang model pengesanan teras; selepas itu anda boleh sentiasa menyemak, memuat turun, mengemas kini, atau membuang model dari \"Tetapan → Pengurusan Model AI\". Apl secara proaktif menyemak versi terkini semasa pelancaran, dan menunjukkan lencana pada ikon tetapan serta entri \"Pengurusan Model AI\" jika kemas kini tersedia.';

  @override
  String get helpWorkflowStep2Title => 'Memilih model (tujuan & kesan)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Pengelas AI berbilang bahasa (pemberat 40%): pemacu utama penentuan keseluruhan, dengan ramalan kebarangkalian AI peringkat ayat — meningkatkan ketepatan paling banyak.';

  @override
  String get helpWorkflowStep2Bullet2 =>
      'Enjin analisis statistik (pemberat 25%): analisis tetingkap gelongsor kekeliruan dan burstiness, menangkap rentak teratur dan pilihan perkataan boleh diramal teks AI.';

  @override
  String get helpWorkflowStep2Bullet3 =>
      'Analisis stilometrik (pemberat 20%): kelancaran semantik, corak ayat berulang, penggunaan kata hubung — paling boleh dijelaskan, paling mudah difahami \"mengapa\".';

  @override
  String get helpWorkflowStep2Bullet4 =>
      'Pertahanan adversarial (pemberat 15%): mengesan teks yang telah dicuci melalui alat parafrasa (cth. QuillBot, Undetectable.ai).';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'LLM penulisan laporan (pilihan): setelah dipasang, teks laporan ditulis secara dinamik oleh LLM pada peranti; tanpanya, apl kembali kepada templat tetap — analisis itu sendiri tidak terjejas.';

  @override
  String get helpWorkflowStep2Bullet6 =>
      'Anda boleh mengaktifkan/menyahaktifkan enjin secara individu dan melaraskan ambang keyakinan pengesanan AI dalam Tetapan (meningkatkannya mengurangkan peluang salah anggap penulisan manusia sebagai AI).';

  @override
  String get helpWorkflowStep3Title => 'Memuat naik dokumen';

  @override
  String get helpWorkflowStep3Body =>
      'Tiga kaedah input: tampal teks terus, OCR imej (dikenal pasti pada peranti dengan rangka kerja natif setiap platform), atau import fail (txt / md / pdf / docx / doc). Teks mesti sekurang-kurangnya 40 aksara untuk dihantar untuk analisis.';

  @override
  String get helpWorkflowStep4Title => 'Menjalankan analisis';

  @override
  String get helpWorkflowStep4Body =>
      'Ketik \"Mula Mengesan\" dan keempat-empat enjin berjalan selari, dengan kemajuan langsung dipaparkan pada skrin. Jika ciri penulisan bukan penutur asli dikesan, pembetulan bias ESL digunakan secara automatik (boleh dimatikan dalam Tetapan).';

  @override
  String get helpWorkflowStep5Title => 'Melihat & mengeksport hasil';

  @override
  String get helpWorkflowStep5Body =>
      'Halaman laporan termasuk: tolok kebarangkalian AI keseluruhan, peta haba peringkat ayat, perincian skor dan sebab setiap enjin, ketulenan pautan hiper, dan ketulenan petikan. Anda boleh mengeksport laporan PDF penuh, data CSV setiap ayat, JSON (untuk integrasi sistem), atau kad ringkasan PNG (untuk perkongsian). Setiap analisis disimpan secara automatik dalam \"Sejarah\" untuk semakan kemudian.';

  @override
  String get helpTuningTitle =>
      'Panduan muat turun & penalaan model (tiada pengalaman diperlukan)';

  @override
  String get helpTuningStep1Title => 'Buka Pengurusan Model';

  @override
  String get helpTuningStep1Body =>
      'Dari skrin utama, ketik ikon gear untuk membuka \"Tetapan\", kemudian ketik \"Buka\" di sebelah \"Pengurusan Model AI\".';

  @override
  String get helpTuningStep2Title => 'Pilih model untuk peranti anda';

  @override
  String get helpTuningStep2Body =>
      'Skrin secara automatik mencadangkan tahap model yang sesuai berdasarkan keupayaan peranti anda (RAM, teras CPU), dan menyenaraikan setiap varian yang tersedia bagi setiap peranan (pengelas berbilang bahasa / analisis statistik / pertahanan adversarial / LLM laporan).';

  @override
  String get helpTuningStep3Title => 'Muat turun & gunakan';

  @override
  String get helpTuningStep3Body =>
      'Ketik \"Muat turun\" di sebelah model yang anda mahu dan tunggu sehingga selesai — model pertama yang anda muat turun akan ditetapkan sebagai aktif secara automatik. Jika anda mempunyai beberapa varian dipasang, ketik \"Tetapkan sebagai aktif\" untuk bertukar bila-bila masa; ketik ikon tong sampah untuk membuang model yang tidak diperlukan bagi membebaskan ruang.';

  @override
  String get helpTuningStep4Title => 'Mengemas kini model';

  @override
  String get helpTuningStep4Body =>
      'Apabila versi baharu tersedia, \"Pengurusan Model AI\" dan ikon gear tetapan menunjukkan lencana — kembali ke skrin ini untuk melihat dan memuat turun kemas kini (versi yang dipasang sebelum ini dikekalkan melainkan anda membuangnya secara manual).';

  @override
  String get helpTuningStep5Title => 'Lanjutan: mengimport model tersuai';

  @override
  String get helpTuningStep5Body =>
      'Jika anda sudah mempunyai, atau telah menala halus, model .onnx yang serasi di tempat lain, anda boleh mengimportnya melalui \"Tetapan → Import & uji model ONNX tersuai\" — anda perlu menyediakan fail model, konfigurasi Tokenizer yang sepadan (atau pilih \"tiada\"), dan indeks kelas AI. Sebelum mengimport, apl secara automatik menyemak sama ada fail yang sama ini telah diimport, untuk mengelakkan pertindanan tidak sengaja.';

  @override
  String get helpOfficialLinksTitle => 'Pautan muat turun model rasmi';

  @override
  String get helpOfficialLinksHint =>
      'Mengetik item akan membuka halaman rasmi model tersebut dalam pelayar sistem anda.';

  @override
  String get helpLinkRoleTransformer =>
      'Pengelas AI berbilang bahasa (Transformer, pemberat 40%)';

  @override
  String get helpLinkRoleStatistical =>
      'Model statistik kekeliruan (Statistical, pemberat 25%)';

  @override
  String get helpLinkRoleAdversarial =>
      'Model pengesanan parafrasa adversarial (Adversarial, pemberat 15%)';

  @override
  String get helpLinkRoleLlm => 'LLM penulisan laporan (pilihan)';

  @override
  String get privacyAppBarTitle => 'Dasar Privasi';

  @override
  String privacyPlatformTitle(String platform) {
    return 'Dasar Privasi $platform';
  }

  @override
  String privacyLastUpdated(String date) {
    return 'Kemas kini terakhir: $date';
  }

  @override
  String get privacyIosOverview1 =>
      'TruthLens tidak mengumpul sebarang data yang dikaitkan dengan identiti anda, dan tidak menggunakan sebarang data untuk penjejakan, jadi ia tidak memerlukan kebenaran Ketelusan Penjejakan Apl (ATT).';

  @override
  String get privacyIosOverview2 =>
      'Apl ini menggunakan pemilih fail sistem untuk mengakses fail atau imej yang anda pilih secara aktif; ia tidak boleh mengakses fail yang tidak anda pilih (dikuatkuasakan oleh Sandbox Apl iOS).';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLens tidak mengumpul data peribadi, dan tidak berkongsi data pengguna dengan mana-mana pihak ketiga.';

  @override
  String get privacyAndroidOverview2 =>
      'Apl ini hanya mengakses storan apabila anda secara aktif memilih untuk mengimport fail atau imej; ia tidak mengimbas atau mengakses fail lain di latar belakang.';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens berjalan di bawah Sandbox Apl macOS dan hanya boleh mengakses fail yang anda pilih secara aktif melalui dialog fail sistem (files.user-selected.read-write) — ia tidak boleh menyemak imbas atau mengakses mana-mana fail atau folder lain sendiri.';

  @override
  String get privacyMacosOverview2 =>
      'Akses rangkaian (network.client) hanya digunakan untuk fungsi yang disenaraikan dalam \"Perilaku sambungan yang diperlukan\" di bawah.';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens ialah aplikasi desktop mandiri; data disimpan dalam folder pengguna tempatan anda (cth. AppData/Documents) dan tidak pernah disegerakkan ke awan.';

  @override
  String get privacyWindowsOverview2 =>
      'Apl ini hanya mengakses fail yang anda pilih secara aktif untuk diimport; ia tidak mengimbas fail lain di latar belakang.';

  @override
  String get privacyDataHandling1 =>
      'TruthLens tiada akaun pengguna, tidak memerlukan log masuk, dan tidak mengandungi sebarang SDK pengiklanan atau penjejakan pihak ketiga dalam apa jua bentuk.';

  @override
  String get privacyDataHandling2 =>
      'Sebarang kandungan dokumen yang anda taip, tampal, atau import dianalisis sepenuhnya oleh model AI pada peranti anda sendiri — ia tidak pernah dimuat naik ke TruthLens atau mana-mana pelayan pihak ketiga.';

  @override
  String get privacyDataHandling3 =>
      'Hasil analisis dan sejarah hanya disimpan dalam pangkalan data tempatan pada peranti anda; menyahpasang apl atau mengosongkan sejarah membuangnya sepenuhnya — TruthLens tidak menyimpan sebarang salinan di mana-mana.';

  @override
  String get privacyNetworkIntro =>
      'Pengesanan AI teras apl ini berjalan sepenuhnya pada peranti, tetapi tiga ciri berikut memerlukan akses rangkaian:';

  @override
  String get privacyNetwork1 =>
      '1. Katalog & muat turun model: menyambung ke GitHub Releases/Hugging Face untuk memuat turun model pengesanan yang anda pilih — ini hanya memuat turun model dan tidak pernah memuat naik sebarang data pengguna.';

  @override
  String get privacyNetwork2 =>
      '2. Semakan kemas kini model: semasa pelancaran, apl menyambung untuk membandingkan nombor versi sahaja, digunakan untuk menunjukkan sama ada versi baharu tersedia.';

  @override
  String get privacyNetwork3 =>
      '3. Pengesahan ketulenan pautan hiper & petikan: dihidupkan secara lalai, boleh dimatikan dalam Tetapan. Apabila diaktifkan, URL atau teks bibliografi yang dikesan dalam dokumen dihantar terus ke URL itu sendiri, atau ke API awam Crossref, menghantar hanya teks URL/DOI/petikan itu sendiri — tidak pernah kandungan lain dokumen.';

  @override
  String get privacyRightsIntro =>
      'Anda boleh mengosongkan sejarah analisis tempatan bila-bila masa dalam \"Sejarah\", atau mematikan pengesahan pautan hiper/petikan dalam \"Tetapan\", atau membuang semua data tempatan dengan';

  @override
  String get privacyRemoveIos => 'memadam apl';

  @override
  String get privacyRemoveAndroid => 'menyahpasang apl';

  @override
  String get privacyRemoveMacos => 'mengalihkan apl ke Tong Sampah';

  @override
  String get privacyRemoveWindows => 'menyahpasang apl';

  @override
  String get privacyDisclaimer =>
      'Halaman ini ialah penjelasan privasi yang ditulis TruthLens untuk mencerminkan perilaku fungsi sebenarnya, bukan dokumen undang-undang formal yang disemak peguam; untuk semakan pematuhan formal di bawah undang-undang wilayah anda, sila rujuk peguam bebas.';

  @override
  String get privacySectionOverviewIos =>
      'Gambaran keseluruhan (setara dengan \"Label Pemakanan\" Privasi App Store)';

  @override
  String get privacySectionOverviewAndroid =>
      'Gambaran keseluruhan (setara dengan pendedahan \"Keselamatan Data\" Google Play)';

  @override
  String get privacySectionOverviewMacos =>
      'Gambaran keseluruhan (kebenaran Sandbox Apl)';

  @override
  String get privacySectionOverviewWindows => 'Gambaran keseluruhan';

  @override
  String get privacySectionDataHandling => 'Cara kami mengendalikan data anda';

  @override
  String get privacySectionNetwork => 'Sambungan rangkaian yang diperlukan';

  @override
  String get privacySectionRights => 'Hak anda';

  @override
  String get privacyGenericPlatformName => 'Platform ini';
}
