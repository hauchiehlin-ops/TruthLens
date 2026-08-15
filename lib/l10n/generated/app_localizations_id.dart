// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonClose => 'Tutup';

  @override
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

  @override
  String get verdictHuman => 'Ditulis manusia';

  @override
  String get verdictLikelyHuman => 'Kemungkinan manusia';

  @override
  String get verdictMixed => 'Konten campuran';

  @override
  String get verdictLikelyAi => 'Kemungkinan AI';

  @override
  String get verdictAi => 'Dihasilkan AI';

  @override
  String get inputSubtitle =>
      'Tempel atau ketik teks untuk mendeteksi konten yang dihasilkan AI';

  @override
  String get inputHint => 'Ketik atau tempel teks untuk dianalisis…';

  @override
  String get inputHistoryTooltip => 'Riwayat';

  @override
  String get inputHelpTooltip => 'Panduan Pengguna';

  @override
  String get inputPrivacyTooltip => 'Kebijakan Privasi';

  @override
  String get inputSettingsTooltip => 'Pengaturan';

  @override
  String get inputPasteButton => 'Tempel';

  @override
  String get inputOcrButton => 'OCR Gambar';

  @override
  String get inputImportButton => 'Impor Berkas';

  @override
  String get inputStartButton => 'Mulai Deteksi';

  @override
  String get inputClearTooltip => 'Bersihkan konten';

  @override
  String get inputTooShortSnackbar =>
      'Masukkan minimal 40 karakter untuk analisis yang andal';

  @override
  String get inputOcrUnsupported =>
      'Pengenalan teks OCR tidak didukung pada platform ini';

  @override
  String get inputOcrRecognizing => 'Mengenali…';

  @override
  String get inputOcrNoText =>
      'Tidak ada teks yang teridentifikasi dalam gambar';

  @override
  String inputOcrRecognized(int count) {
    return 'Berhasil mengenali $count karakter';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\" tidak memiliki konten teks yang dapat dibaca';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return '\"$fileName\" telah diimpor ($count karakter)';
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
    return 'Model: $modelId';
  }

  @override
  String get inputNoModel =>
      'Tidak ada model terpasang (hanya analisis statistik/gaya)';

  @override
  String inputCharCount(int count) {
    return '$count karakter';
  }

  @override
  String get analysisAppBarTitle => 'Menganalisis';

  @override
  String get analysisEngineTransformer => 'Pengklasifikasi Transformer';

  @override
  String get analysisEngineStatistical => 'Analisis Statistik';

  @override
  String get analysisEngineStylometry => 'Analisis Gaya Penulisan';

  @override
  String get analysisEngineAdversarial => 'Pertahanan Adversarial';

  @override
  String analysisProgressSemantics(int done, int total) {
    return 'Analisis sedang berjalan, $done dari $total mesin selesai';
  }

  @override
  String get analysisDoneSemantics => 'Selesai';

  @override
  String analysisPreliminaryResult(int percent) {
    return 'Hasil awal: probabilitas AI $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return 'Hasil awal: probabilitas AI $percent% (menyempurnakan…)';
  }

  @override
  String get engineNameAdversarialFull =>
      'Pertahanan Adversarial (Deteksi Parafrasa)';

  @override
  String get modelNecessityText =>
      'Tanpa mengunduh model deteksi jaringan saraf, TruthLens tetap berfungsi tetapi hanya menggunakan analisis statistik dan gaya penulisan, dengan akurasi dan dukungan multibahasa yang terbatas. Setelah model diunduh, pengklasifikasi Transformer multibahasa akan ikut serta dalam pemungutan suara ensemble, secara signifikan meningkatkan akurasi dan keandalan. Model berjalan di perangkat; setelah diunduh, model tidak mengunggah konten apa pun.';

  @override
  String get modelPromptTitle =>
      'Disarankan mengunduh model deteksi untuk analisis lengkap';

  @override
  String get modelPromptDontRemind => 'Jangan ingatkan lagi';

  @override
  String get modelPromptSkip => 'Lewati untuk saat ini';

  @override
  String get modelPromptDownload => 'Unduh sekarang';

  @override
  String get onboardingWelcomeTitle => 'Selamat datang di TruthLens';

  @override
  String get onboardingHeadline => 'Deteksi konten AI di perangkat';

  @override
  String get onboardingDetectedDevice => 'Perangkat terdeteksi';

  @override
  String get onboardingChooseModel => 'Pilih model untuk diunduh';

  @override
  String get onboardingRecommendHint =>
      '\"Direkomendasikan\" ditandai berdasarkan perangkat keras Anda; Anda juga dapat memilih opsi lain.';

  @override
  String get onboardingSkipButton =>
      'Putuskan nanti (gunakan analisis statistik/gaya tanpa model)';

  @override
  String get onboardingSkipHint =>
      'Anda tetap dapat mengunduh kapan saja dari \"Pengaturan → Manajemen Model AI\"; Anda akan diingatkan kembali saat menggunakan analisis yang memerlukan model.';

  @override
  String get modelListCustomImportedLabel => 'Model impor kustom:';

  @override
  String get modelListActiveChip => 'Digunakan';

  @override
  String get modelListRecommendedChip => 'Direkomendasikan';

  @override
  String get modelListCustomChip => 'Kustom';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · Butuh ${ram}GB RAM · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'Ukuran: $size · Tokenizer: $tokenizer · Indeks Label AI: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'Mengunduh… $percent% ($downloaded / $total)';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'Unduh ($size)';
  }

  @override
  String get modelListComingSoonChip => 'Segera hadir';

  @override
  String get modelListSetActiveButton => 'Jadikan aktif';

  @override
  String get modelListUpdateButton => 'Perbarui';

  @override
  String get modelListDeleteTooltip => 'Hapus';

  @override
  String get modelListPageButton => 'Halaman model';

  @override
  String get modelListMayExceedMemory => 'Mungkin melebihi memori perangkat';

  @override
  String modelListFailedPrefix(String error) {
    return 'Gagal: $error';
  }

  @override
  String get modelCatalogLoadFailed => 'Tidak dapat memuat katalog model';

  @override
  String get modelCatalogEmpty => 'Tidak ada model yang tersedia';

  @override
  String modelDownloadPathChip(String label) {
    return 'Jalur unduhan $label';
  }

  @override
  String get modelDownloadPathModelFile => 'File model';

  @override
  String get modelDownloadPathCopied => 'Jalur unduhan disalin';

  @override
  String settingsSaveFailed(String error) {
    return 'Gagal menyimpan pengaturan: $error';
  }

  @override
  String get modelListDeleteConfirmTitle => 'Hapus model?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return 'Ini akan menghapus \"$name\" ($size). Anda perlu mengunduh ulang untuk menggunakannya lagi.';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'Ini akan menghapus model impor kustom \"$name\" ($size). Anda perlu mengimpor ulang untuk menggunakannya lagi.';
  }

  @override
  String get modelImportAppBarTitle => 'Impor Model ONNX Kustom';

  @override
  String get modelImportStep1Title => '1. Pilih berkas model ONNX';

  @override
  String modelImportSelectedFile(String name) {
    return 'Dipilih: $name';
  }

  @override
  String get modelImportNoFileSelected =>
      'Belum ada berkas model dipilih (.onnx)';

  @override
  String get modelImportBrowseButton => 'Jelajahi';

  @override
  String get modelImportCheckingDuplicate =>
      'Memeriksa apakah berkas identik sudah diimpor…';

  @override
  String get modelImportDuplicateTitle =>
      'Model dengan konten identik telah diimpor';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'Berkas ini memiliki konten yang sepenuhnya identik dengan \"$name\" (peran: $role). Jika Anda hanya ingin mengganti model aktif, buka \"Manajemen Model AI\" dan jadikan aktif secara langsung — tidak perlu mengimpor ulang. Anda tetap dapat melanjutkan langkah di bawah.';
  }

  @override
  String get modelImportStep2Title => '2. Konfigurasi';

  @override
  String get modelImportNameLabel => 'Nama tampilan model';

  @override
  String get modelImportNameRequired => 'Nama tidak boleh kosong';

  @override
  String get modelImportRoleLabel => 'Peran mesin target';

  @override
  String get modelImportTokenizerTypeLabel => 'Jenis Tokenizer';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone =>
      'Tidak ada (tanpa Tokenizer/tingkat karakter)';

  @override
  String get modelImportNoTokenizerSelected =>
      'Belum ada berkas Tokenizer dipilih (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return 'Dipilih: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'Indeks output label AI';

  @override
  String get modelImportIndex0 => 'Indeks 0 (mis. RoBERTa)';

  @override
  String get modelImportIndex1 => 'Indeks 1 (mis. DistilBERT)';

  @override
  String get modelImportStep3Title => '3. Uji & verifikasi';

  @override
  String get modelImportTestInputLabel => 'Teks input uji';

  @override
  String get modelImportRunTestButton => 'Jalankan inferensi uji';

  @override
  String get modelImportResultLabel => 'Hasil inferensi (probabilitas AI):';

  @override
  String modelImportTestFailed(String error) {
    return 'Pengujian gagal: $error';
  }

  @override
  String get modelImportConfirmButton => 'Konfirmasi impor dan aktifkan model';

  @override
  String get modelImportSelectTokenizerFirst =>
      'Silakan pilih berkas Tokenizer terlebih dahulu';

  @override
  String get modelImportSelectTokenizer => 'Silakan pilih berkas Tokenizer';

  @override
  String get modelImportSuccessSnackbar =>
      'Model berhasil diimpor! Otomatis diatur sebagai model aktif.';

  @override
  String get modelImportFailedSnackbar =>
      'Impor model gagal. Periksa izin atau log';

  @override
  String get settingsAppBarTitle => 'Pengaturan';

  @override
  String get settingsThresholdTitle => 'Ambang kepercayaan penentuan AI';

  @override
  String get settingsThresholdInfoTooltip =>
      'How the AI flagging threshold affects the conclusion';

  @override
  String get settingsThresholdInfoBody =>
      'The enabled engines first calculate the overall AI probability. This setting does not change any engine score or that overall probability; it changes which conclusion is applied to the score. A lower threshold makes the same probability more likely to be concluded and marked as AI, while a higher threshold requires stronger AI probability and is more likely to conclude human writing. The report always retains the original probability and supporting evidence.';

  @override
  String settingsThresholdSubtitle(int percent) {
    return 'Saat ini: $percent% — meningkatkannya mengurangi positif palsu (teks manusia salah dinilai sebagai AI)';
  }

  @override
  String get settingsEslTitle => 'Koreksi bias ESL (bukan penutur asli)';

  @override
  String get settingsEslSubtitle =>
      'Secara otomatis mengurangi bobot model statistik saat gaya penulisan bukan penutur asli terdeteksi';

  @override
  String get settingsEngineSectionTitle =>
      'Pengaturan sub-mesin deteksi (Ensemble)';

  @override
  String get settingsEngineTransformerTitle =>
      'Pengklasifikasi AI multibahasa (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      'Menggunakan model jaringan saraf Transformer untuk memprediksi probabilitas AI di perangkat';

  @override
  String get settingsEngineStatisticalTitle =>
      'Mesin analisis statistik (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      'Menentukan keteraturan bahasa melalui variasi panjang kalimat, Burstiness, dan PPL';

  @override
  String get settingsEngineStylometryTitle =>
      'Analisis gaya penulisan (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle =>
      'Menganalisis kelancaran semantik, pola kalimat berulang, dan penggunaan kata penghubung';

  @override
  String get settingsEngineAdversarialTitle =>
      'Deteksi parafrasa adversarial (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle =>
      'Mendeteksi apakah teks telah diparafrasakan mesin atau diproses untuk menghilangkan jejak AI';

  @override
  String get settingsEngineWeightsTitle => 'Bobot model AI';

  @override
  String get settingsEngineWeightsSubtitle =>
      'Atur pengaruh setiap mesin pada hasil gabungan. Total harus tepat 100% sebelum disimpan.';

  @override
  String get settingsEngineInfoTooltip => 'Fungsi mesin ini';

  @override
  String get settingsEngineTransformerHelp =>
      'Menilai blok paragraf yang mempertahankan konteks dengan Transformer multibahasa, lalu memetakan skor blok kembali ke kalimat untuk laporan terperinci. Bobot mengatur pengaruh, sedangkan sinyal AI menentukan kontribusi aktual.';

  @override
  String get settingsEngineStatisticalHelp =>
      'Mengukur perplexity, prediktabilitas, burstiness, dan variasi panjang kalimat. Koreksi ESL dapat mengurangi bobot efektifnya.';

  @override
  String get settingsEngineStylometryHelp =>
      'Memeriksa penanda gaya yang dapat dijelaskan seperti pembuka berulang, transisi formulaik, dan daftar berlebihan. Tanpa penanda, sinyalnya 0%.';

  @override
  String get settingsEngineAdversarialHelp =>
      'Mencari teks AI yang diparafrase atau dibersihkan jejaknya. Skor rendah hanya berarti bukti sisa yang lemah, bukan deteksi positif.';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return 'Total: $total% — siap disimpan';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return 'Total: $total% — sesuaikan tepat menjadi 100%';
  }

  @override
  String get settingsEngineWeightsSave => 'Simpan bobot';

  @override
  String get settingsEngineWeightsSaved =>
      'Bobot model AI disimpan di perangkat ini';

  @override
  String get settingsEngineWeightsRestoreDefaults => 'Pulihkan default';

  @override
  String get engineReasonDisabledByUser =>
      'Pengguna telah mematikan mesin ini di Pengaturan';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model: tidak ada dari $total kalimat yang melewati ambang AI kuat; sinyal lemah terkalibrasi adalah $percent%';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'Sinyal AI $percent%';
  }

  @override
  String get reportEngineSignalExplanation =>
      'Sinyal AI adalah probabilitas mesin untuk dokumen ini. Bobot yang diatur mengendalikan pengaruhnya, dan poin kontribusi dialokasikan agar jumlah yang ditampilkan sama persis dengan probabilitas AI keseluruhan. ‘Tidak terdeteksi’ berarti di bawah ambang sinyal kuat 60%, bukan berarti nilainya harus nol.';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return 'Tidak satu pun dari $total kalimat melewati ambang parafrasa kuat; sinyal lemah yang dikalibrasi adalah $percent%';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$count dari $total kalimat melewati ambang parafrasa kuat; sinyal dokumen yang dikalibrasi adalah $percent%';
  }

  @override
  String get settingsLinkVerificationTitle =>
      'Verifikasi hyperlink & bibliografi';

  @override
  String get settingsLinkVerificationSubtitle =>
      'Laporan akan terhubung untuk memeriksa apakah URL dan entri bibliografi yang terdeteksi dalam dokumen benar-benar ada (konten yang dihasilkan AI sering menyertakan referensi yang tampak masuk akal tetapi fiktif). Tautan akademis berformat DOI, dan referensi berformat \"penulis-tahun\" tanpa tautan, keduanya diperiksa terhadap registri publik Crossref. Model deteksi AI inti tetap berjalan sepenuhnya di perangkat dan tidak pernah mengirim konten dokumen; koneksi hanya digunakan untuk verifikasi ini dan pemeriksaan pembaruan model, dan dapat dimatikan di sini.';

  @override
  String get settingsThemeTitle => 'Tema tampilan';

  @override
  String get settingsLanguageTitle => 'Bahasa';

  @override
  String get settingsLanguageSubtitle => 'Pilih bahasa tampilan aplikasi';

  @override
  String get settingsModelManagementTitle => 'Manajemen Model AI';

  @override
  String get settingsModelManagementSubtitle =>
      'Unduh model deteksi dan LLM penulisan laporan untuk mengaktifkan kemampuan inferensi penuh';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'Pembaruan model terdeteksi — disarankan untuk diperiksa';

  @override
  String get settingsOpenButton => 'Buka';

  @override
  String get settingsCustomImportTitle => 'Impor & uji model ONNX kustom';

  @override
  String get settingsCustomImportSubtitle =>
      'Impor model ONNX kustom lokal dan konfigurasikan Tokenizer serta jalankan uji inferensi';

  @override
  String get modelImportWebUnsupported =>
      'Impor model kustom belum didukung di versi web. Silakan gunakan versi aplikasi.';

  @override
  String get settingsModelManagerAppBarTitle => 'Manajemen Model AI';

  @override
  String get settingsImportTooltip => 'Impor model ONNX lokal';

  @override
  String settingsDeviceLabel(String summary) {
    return 'Perangkat: $summary';
  }

  @override
  String get historyAppBarTitle => 'Riwayat';

  @override
  String get historyClearAllTooltip => 'Bersihkan semua';

  @override
  String get historySearchHint => 'Cari riwayat…';

  @override
  String get historyDeletedSnackbar => 'Entri telah dihapus';

  @override
  String get historyClearAllTitle => 'Bersihkan semua riwayat?';

  @override
  String historyClearAllBody(int count) {
    return 'Ini akan menghapus semua $count entri. Tindakan ini tidak dapat dibatalkan.';
  }

  @override
  String get historyClearButton => 'Bersihkan';

  @override
  String get historyDeleteEntryTitle => 'Hapus entri ini?';

  @override
  String get historyReanalyzeTooltip => 'Analisis ulang';

  @override
  String get historyEmptyDefault => 'Belum ada riwayat deteksi';

  @override
  String historyEmptySearch(String query) {
    return 'Tidak ada entri yang cocok dengan \"$query\"';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, probabilitas AI $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => 'Laporan Deteksi';

  @override
  String get reportExportTooltip => 'Ekspor laporan';

  @override
  String get reportHomeTooltip => 'Kembali ke beranda';

  @override
  String get reportGeneratingTitle => 'Membuat laporan…';

  @override
  String get reportSourceLlm => 'Laporan dihasilkan AI';

  @override
  String get reportSourceTemplate => 'Laporan dihasilkan templat';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return '$total kalimat · $ai kemungkinan AI · $human kemungkinan manusia · $seconds detik berlalu';
  }

  @override
  String get reportExportPdf => 'Ekspor laporan PDF';

  @override
  String get reportExportCsv => 'Ekspor data CSV';

  @override
  String get reportExportJson => 'Ekspor JSON (integrasi sistem)';

  @override
  String get reportExportPng => 'Ekspor kartu ringkasan (PNG)';

  @override
  String reportExported(String path) {
    return 'Diekspor: $path';
  }

  @override
  String reportExportFailed(String error) {
    return 'Ekspor gagal: $error';
  }

  @override
  String get reportEngineWeightLabel => 'Bobot';

  @override
  String get privacySealNoticeText =>
      'Segel Privasi 100% Offline TruthLens: Diproses di perangkat tanpa penyimpanan awan.';

  @override
  String get reportModelCalibrationTitle =>
      'Kalibrasi Otomatis Benchmark Model';

  @override
  String get reportCommunityDiscoveredTag => 'Komunitas (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => 'Rincian mesin';

  @override
  String get reportEngineNotInstalled => 'Belum terpasang';

  @override
  String get reportEngineLoadFailedBadge => 'Gagal memuat';

  @override
  String get reportEngineAnalysisLevelTitle => 'Engine analysis layers';

  @override
  String get reportVerdictAiLikelihood => 'AI Leaning';

  @override
  String get reportVerdictHumanLikelihood => 'Human Writing';

  @override
  String get reportRadarRoleTransformer => 'Pengklasifikasi Transformer';

  @override
  String get reportRadarRoleStatistical => 'Analisis statistik';

  @override
  String get reportRadarRoleStylometry => 'Analisis stilometri';

  @override
  String get reportRadarRoleAdversarial => 'Pertahanan adversarial';

  @override
  String get reportRadarAxisTransformer => 'Pengklasifikasi kalimat';

  @override
  String get reportRadarAxisStatistical => 'Keteraturan bahasa';

  @override
  String get reportRadarAxisStylometry => 'Gaya penulisan';

  @override
  String get reportRadarAxisAdversarial => 'Pertahanan penulisan ulang';

  @override
  String get reportVerdictBadgeTitle => 'Putusan keseluruhan';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return 'Probabilitas AI keseluruhan $percent%';
  }

  @override
  String get reportVerdictHintHuman =>
      'Sebagian besar sinyal mesin condong ke tulisan manusia alami.';

  @override
  String get reportVerdictHintLikelyHuman =>
      'Secara keseluruhan condong ke manusia, dengan sedikit ketidakpastian model yang tersisa.';

  @override
  String get reportVerdictHintMixed =>
      'Sinyal mesin beragam; baca analisis terperinci bersama hasil ini.';

  @override
  String get reportVerdictHintLikelyAi =>
      'Beberapa indikator condong ke AI; tinjau bagian dengan skor tinggi.';

  @override
  String get reportVerdictHintAi =>
      'Sinyal keseluruhan sangat condong ke konten yang dihasilkan atau ditulis ulang oleh AI.';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return 'Putusan keseluruhan: $verdict; probabilitas AI keseluruhan $percent%.';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return 'Sinyal tunggal terkuat: $label ($percent%), tetapi hasil akhir menggabungkan bobot mesin dan bukan kesimpulan dari satu mesin saja.';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return 'Kontribusi berbobot terbesar saat ini berasal dari $label (sekitar $points poin persentase).';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '\"Tidak ada gaya penulisan AI yang jelas terdeteksi\" hanya berarti mesin gaya tidak menemukan pola kalimat tetap atau pola kata transisi; model lain masih dapat meningkatkan skor keseluruhan melalui keteraturan bahasa, klasifikasi kalimat, atau sinyal penulisan ulang.';

  @override
  String get reportSynthesisModelGap =>
      'Jika beberapa mesin tidak berpartisipasi, gunakan dahulu \"Lengkapi model analisis yang direkomendasikan\" di Manajemen Model; jika masih gagal, analisis terperinci akan menyatakan apakah penyebabnya adalah model yang hilang, tokenizer yang tidak didukung, file yang hilang, atau batasan kompatibilitas Web/ONNX Runtime.';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label tidak berpartisipasi dalam voting berbobot ini, sehingga dimensi ini ditampilkan sebagai 0%. $hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return 'Bobot peran $weight%, berkontribusi sekitar $points poin persentase pada skor keseluruhan$variantText.';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return ' (menggabungkan $count varian model)';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label tidak berpartisipasi dalam voting ini.';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label tidak mengembalikan penjelasan teks tambahan.';
  }

  @override
  String get reportEngineResolutionTransformer =>
      'Solusi: unduh dan aktifkan Transformer multibahasa di Manajemen Model; jika sudah diunduh, unduh ulang model dan tokenizer.';

  @override
  String get reportEngineResolutionAdversarial =>
      'Solusi: unduh ulang model deteksi penulisan ulang dan tokenizer di Manajemen Model; di web, perbarui ke versi dengan perbaikan kompatibilitas BigInt dan analisis lagi.';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason. Penyebab: ONNX Runtime web mengembalikan tensor BigInt yang tidak dapat dikonversi oleh jembatan versi lama; perbarui ke build yang telah diperbaiki dan analisis lagi.';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason. Solusi: beralih ke model katalog, atau unduh ulang model dan tokenizer.';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason. Solusi: buka Manajemen Model, ketuk \"Lengkapi model analisis yang direkomendasikan\", dan pastikan Transformer multibahasa ditandai aktif.';
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
      'Rasio kalimat dengan sinyal AI kuat';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count dari $total melewati ambang sinyal kuat 60%';
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
  String get reportSentenceAnalysisTitle => 'Analisis tingkat kalimat';

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
    return '$text. Probabilitas AI $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'Keaslian hyperlink';

  @override
  String get reportLinkNoneDetected =>
      'Tidak ada hyperlink terdeteksi dalam dokumen ini.';

  @override
  String get reportLinkCheckingProgress => 'Memverifikasi tautan…';

  @override
  String reportLinkDetectedPending(int count) {
    return '$count hyperlink terdeteksi; belum diverifikasi';
  }

  @override
  String get reportLinkDisabledHint =>
      'Konten yang dihasilkan AI sering menyertakan tautan referensi yang tampak masuk akal tetapi fiktif. Anda telah mematikan verifikasi hyperlink di Pengaturan; Anda dapat mengaktifkannya kembali untuk verifikasi otomatis, atau ketuk di bawah untuk pemeriksaan sekali.';

  @override
  String get reportVerifyNowButton => 'Verifikasi sekarang (perlu jaringan)';

  @override
  String get reportLinkReachable => 'Dapat dijangkau — URL ada';

  @override
  String get reportLinkNotFound =>
      'URL tidak ada (404) — mungkin referensi fiktif';

  @override
  String get reportLinkUnreachable =>
      'Tidak dapat diverifikasi (waktu habis atau tanpa respons server)';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'Diverifikasi dalam registri jurnal: terdaftar dengan $journal$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      'Tidak ditemukan registrasi DOI yang cocok — mungkin referensi fiktif';

  @override
  String get reportLinkCitationUnreachable =>
      'Tidak dapat diverifikasi (waktu habis atau tanpa respons dari Crossref)';

  @override
  String reportLinkTruncated(int max, int count) {
    return 'Hanya $max tautan pertama yang diverifikasi (total $count terdeteksi)';
  }

  @override
  String get reportBibAuthenticityTitle => 'Keaslian kutipan';

  @override
  String get reportBibNoneDetected =>
      'Tidak ada entri bibliografi terdeteksi dalam dokumen ini.';

  @override
  String get reportBibCheckingProgress => 'Memverifikasi bibliografi…';

  @override
  String reportBibDetectedPending(int count) {
    return 'Bibliografi terdeteksi ($count entri); belum diverifikasi';
  }

  @override
  String get reportBibDisabledHint =>
      'Konten yang dihasilkan AI sering menyertakan referensi yang tampak masuk akal tetapi fiktif. Anda telah mematikan verifikasi hyperlink di Pengaturan; Anda dapat mengaktifkannya kembali untuk verifikasi otomatis, atau ketuk di bawah untuk pemeriksaan sekali.';

  @override
  String get reportVerifyNowBibButton => 'Verifikasi sekarang (perlu jaringan)';

  @override
  String get reportBibRecheckAllUnreliableButton =>
      'Periksa ulang semua kutipan yang belum diverifikasi';

  @override
  String get reportBibRecheckOneTooltip => 'Periksa ulang kutipan ini';

  @override
  String get reportBibResultHint =>
      'Dicocokkan dengan registri publik Crossref berdasarkan kemiripan penulis, tahun, dan judul. Bukan jaminan mutlak — saat \"tidak pasti\", harap verifikasi secara manual.';

  @override
  String reportBibVerificationSource(String source) {
    return 'Verification source: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'Check manually in Google Scholar';

  @override
  String reportBibHighConfidence(String journal) {
    return 'Kepercayaan tinggi: kemungkinan ada$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return ' (terdaftar dengan $journal)';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'Journal name mismatch: the document says “$reported”, while the verified registry says “$registered”. Please review this citation.';
  }

  @override
  String get reportBibNotFound =>
      'Tidak ditemukan kecocokan dekat — mungkin referensi fiktif';

  @override
  String get reportBibUncertain =>
      'Dicurigai: tidak diverifikasi melalui pencocokan registri';

  @override
  String reportBibTruncated(int max, int count) {
    return 'Hanya $max entri pertama yang diverifikasi (total $count terdeteksi)';
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
  String get reportNetworkWarningTitle => 'Koneksi jaringan lemah';

  @override
  String get reportNetworkWarningBody =>
      'Aplikasi ini secara default mengasumsikan koneksi jaringan tersedia; analisis keaslian hyperlink dan kutipan keduanya memerlukan akses jaringan untuk menghasilkan hasil. Koneksi tidak dapat dibuat — periksa jaringan Anda dan coba lagi.';

  @override
  String get reportRetryConnectionButton => 'Coba koneksi lagi';

  @override
  String get reportAiProbabilityLabel => 'Probabilitas AI';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return '$total kalimat\n$ai kemungkinan AI\n$human kemungkinan manusia';
  }

  @override
  String get summaryCardFooter =>
      'Inferensi AI inti berjalan sepenuhnya di perangkat';

  @override
  String get exportReportTitle => 'Laporan Deteksi TruthLens';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · Halaman $page / $total';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return 'Dianalisis: $datetime · $seconds detik berlalu';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return 'Penilaian keseluruhan: $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => ' (koreksi ESL diterapkan)';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return '$total kalimat · $ai kemungkinan AI · $human kemungkinan manusia';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'Untuk menjaga keterbacaan PDF, hanya $max kalimat pertama yang ditampilkan (dari total $count); untuk data lengkap tiap kalimat, gunakan \"$csvLabel\" atau \"$jsonLabel\" sebagai gantinya.';
  }

  @override
  String get pdfSentenceColumnHeader => 'Kalimat (dengan pola yang cocok)';

  @override
  String composerHeadlineAi(int percent) {
    return 'Teks ini kemungkinan besar dihasilkan AI (probabilitas AI $percent%)';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'Teks ini cenderung dihasilkan AI; disarankan tinjauan lebih lanjut (probabilitas AI $percent%)';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'Teks ini menunjukkan karakteristik campuran manusia dan AI (probabilitas AI $percent%)';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'Teks ini cenderung ditulis manusia (probabilitas AI $percent%)';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'Teks ini kemungkinan besar ditulis manusia (probabilitas AI $percent%)';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return 'Probabilitas AI keseluruhan melebihi ambang $percent% yang Anda tetapkan dan ditandai sebagai AI.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'Probabilitas AI keseluruhan di bawah ambang penandaan $percent% yang Anda tetapkan.';
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
  String get composerNarrativeTitle => 'Interpretasi analisis';

  @override
  String get composerParaphraseTitle => 'Jejak parafrasa terdeteksi';

  @override
  String get composerParaphraseBody =>
      'Teks ini mungkin telah diproses oleh alat parafrasa (mis. QuillBot, Undetectable.ai) untuk menghindari deteksi. Meskipun tampak alami kalimat demi kalimat, jejak statistik keseluruhannya tetap berbeda dari tulisan manusia asli — harap perhatikan secara khusus.';

  @override
  String get composerPatternListTitle => 'Pola penulisan AI utama';

  @override
  String get composerEslTitle => 'Koreksi bias ESL (bukan penutur asli)';

  @override
  String get composerEslBody =>
      'Teks ini mungkin berasal dari penulis bukan penutur asli. Perplexity rendah dan pola kalimat teratur yang umum di antara penulis bukan penutur asli bukan dengan sendirinya tanda AI, sehingga sistem telah mengurangi bobot model statistik untuk menghindari kesalahan penilaian.';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return 'Teks ini memiliki total $total kalimat, di mana $ai menunjukkan karakteristik AI yang kuat dan $human cenderung ditulis manusia.';
  }

  @override
  String get composerNarrativeAiPattern =>
      'Sebagian besar kalimat sangat teratur dalam ritme, pilihan kata, dan penggunaan kata penghubung — jejak umum teks yang dihasilkan AI.';

  @override
  String get composerNarrativeMixedPattern =>
      'Teks mengandung bagian yang teratur dan yang bervariasi secara alami, menunjukkan draf manusia yang dipoles AI, atau kolaborasi manusia-AI.';

  @override
  String get composerNarrativeHumanPattern =>
      'Panjang kalimat dan pilihan kata menunjukkan variasi alami dan gaya pribadi, tanpa tanda keteraturan AI yang jelas.';

  @override
  String engineReasonPplLow(String ppl) {
    return 'Perplexity model bahasa rendah ($ppl) — teks sangat dapat diprediksi, indikator hasil AI';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'Perplexity model bahasa tinggi ($ppl), sesuai dengan sifat tak terduga tulisan manusia';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'Perplexity model bahasa sedang ($ppl)';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'Panjang kalimat sangat seragam (burstiness $value) — ritme yang rata adalah jejak statistik umum teks yang dihasilkan AI';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'Variasi mencolok dalam panjang kalimat (burstiness $value), sesuai dengan ritme alami tulisan manusia';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'Keragaman kosakata rendah (TTR $value) — pengulangan kata tinggi';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'Keragaman kosakata tinggi (TTR $value)';
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
      'Indikator statistik tidak menunjukkan kecenderungan jelas — penilaian netral dipertahankan';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return 'Penggunaan sering kata penghubung generik ($words), rata-rata $density per kalimat — kepadatan yang jarang terjadi dalam tulisan manusia';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return 'Beberapa kalimat berurutan dimulai dengan kata yang sama ($count kali) — struktur kalimat berulang';
  }

  @override
  String get engineReasonNoStyleMarkers =>
      'Tidak ada pola penulisan AI yang mencolok terdeteksi';

  @override
  String get engineReasonAdversarialNotInstalled =>
      'Model deteksi parafrasa belum terpasang; tidak ikut serta dalam pemungutan suara ini';

  @override
  String get engineReasonTransformerNotInstalled =>
      'Tidak ada model terpasang atau model aktif tidak didukung; tidak ikut serta dalam pemungutan suara ini';

  @override
  String get modelRepairNoActiveVariant =>
      'Tidak ditemukan model aktif; unduh model yang direkomendasikan di Manajemen Model.';

  @override
  String get modelRepairCustomRemoved =>
      'Model kustom yang gagal dimuat telah dihapus. Model kustom tidak dapat diunduh ulang secara otomatis; silakan impor ulang model dan tokenizer.';

  @override
  String get modelRepairNoSource =>
      'File model yang gagal dimuat telah dihapus, tetapi saat ini tidak ada sumber katalog yang tersedia untuk mengunduh ulang; silakan unduh ulang model yang direkomendasikan di Manajemen Model.';

  @override
  String modelRepairRedownloaded(Object name) {
    return 'Terdeteksi bahwa file model mungkin rusak atau tidak kompatibel; $name telah diunduh ulang secara otomatis. Silakan jalankan analisis lagi.';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return 'File model yang gagal dimuat telah dihapus, tetapi pengunduhan ulang otomatis tidak selesai; periksa koneksi jaringan Anda dan unduh ulang $name di Manajemen Model.';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      'Tidak ditemukan model Transformer aktif; unduh atau aktifkan di Manajemen Model';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return 'Jenis tokenizer model aktif tidak didukung ($tokenizer); beralihlah ke model yang mendukung bert-wordpiece atau roberta-bpe';
  }

  @override
  String get engineTransformerMissingPaths =>
      'Jalur model Transformer atau tokenizer tidak ada; unduh ulang di Manajemen Model';

  @override
  String get engineTransformerMissingFiles =>
      'File model Transformer atau tokenizer tidak ada; unduh ulang di Manajemen Model';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'Versi opset ONNX tidak didukung (versi model ini terlalu baru; perbarui aplikasi): $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'Format tokenizer rusak: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      'Pemuatan atau inferensi model gagal, dan perbaikan otomatis tidak selesai; unduh ulang model Transformer aktif dan tokenizer di Manajemen Model.';

  @override
  String get engineAdversarialNoActiveVariant =>
      'Tidak ditemukan model deteksi penulisan ulang yang aktif';

  @override
  String get engineAdversarialMissingFiles =>
      'File model atau tokenizer tidak ada; unduh ulang di Manajemen Model';

  @override
  String get engineAdversarialRepairFailed =>
      'Pemuatan atau inferensi model gagal, dan perbaikan otomatis tidak selesai; unduh ulang model deteksi penulisan ulang dan tokenizer di Manajemen Model.';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return 'Model tidak berpartisipasi dalam voting ini. $error';
  }

  @override
  String get patternNotAnalyzable =>
      'Segmen terlalu pendek atau diduga noise PDF/OCR; penilaian AI tingkat kalimat tidak dilakukan';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'Model gagal dimuat dan tidak ikut serta dalam pemungutan suara ini ($error)';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model menilai $aiCount dari $total kalimat menunjukkan karakteristik AI';
  }

  @override
  String get engineReasonAdversarialDetected =>
      'Model adversarial mendeteksi kemungkinan jejak AI yang dihilangkan oleh alat parafrasa (mis. QuillBot / Undetectable.ai)';

  @override
  String get engineReasonAdversarialClean =>
      'Tidak ada jejak penghindaran parafrasa yang jelas terdeteksi';

  @override
  String get engineReasonGenericNotInstalled =>
      'Model belum terpasang; tidak ikut serta dalam pemungutan suara ini';

  @override
  String patternGenericTransition(String word) {
    return 'kata penghubung generik \"$word\"';
  }

  @override
  String get helpAppBarTitle => 'Panduan Pengguna';

  @override
  String get helpAboutTitle => 'Tentang TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens adalah aplikasi deteksi konten lintas platform (iOS / Android / macOS / Windows) yang inferensi AI intinya berjalan sepenuhnya di perangkat. Empat sub-model independen — pengklasifikasi saraf Transformer, analisis statistik, analisis stilometri, dan deteksi parafrasa adversarial — melakukan pemungutan suara bersama untuk menentukan apakah teks dihasilkan AI, dengan alasan yang dapat dijelaskan kalimat demi kalimat: bukan sekadar persentase \"terlihat seperti AI\", tetapi penjelasan \"mengapa\".';

  @override
  String get helpComparisonTitle => 'Perbandingan dengan alat terkemuka';

  @override
  String get helpComparisonDisclaimer =>
      'Perbandingan ini disusun dari informasi publik masing-masing alat dan persepsi pasar umum, hanya untuk referensi posisi fungsional — bukan data benchmark yang diverifikasi pihak ketiga.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'Pemrosesan GPTZero terutama berjalan di cloud dan memerlukan pengunggahan dokumen Anda; keempat mesin deteksi TruthLens berjalan di perangkat.';

  @override
  String get helpVsGptZero2 =>
      'GPTZero mempelopori metrik Perplexity/Burstiness dan penyorotan kalimat — TruthLens menggabungkan ini dan menambahkan pengklasifikasi Transformer, analisis stilometri, dan pertahanan adversarial, membentuk pemungutan suara ensemble empat model, bukan metrik tunggal.';

  @override
  String get helpVsGptZero3 =>
      'GPTZero berbasis langganan; TruthLens tidak memerlukan langganan dan tidak ada batas penggunaan.';

  @override
  String get helpVsTurnitinTitle => 'vs Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin hanya dijual kepada institusi; individu tidak dapat membelinya secara langsung. Siapa pun dapat memasang dan menggunakan TruthLens.';

  @override
  String get helpVsTurnitin2 =>
      'Proses keputusan Turnitin hampir seperti kotak hitam; TruthLens menyediakan probabilitas AI tiap kalimat, pola penulisan yang cocok, serta rincian skor dan alasan tiap mesin.';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin sebagian besar memberikan hasil biner \"apakah ini AI\"; TruthLens mendukung pelabelan manusia/AI/campuran di tingkat paragraf/kalimat.';

  @override
  String get helpVsOriginalityTitle => 'vs Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai adalah langganan per dokumen yang memerlukan pengunggahan dokumen Anda ke cloud; pemrosesan inti TruthLens berjalan di perangkat tanpa langganan berkelanjutan yang diperlukan untuk deteksi.';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai menawarkan konsep pemeriksaan fakta dan analisis keterbacaan; TruthLens menjawab ini dengan modul fitur gaya di perangkat, dan dapat melakukan analisis dasar bahkan secara offline.';

  @override
  String get helpVsCopyleaksTitle => 'vs Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks terutama adalah API cloud yang dikenal karena tingkat positif palsu yang rendah dan dukungan multibahasa yang kuat; TruthLens berbagi filosofi ini dengan model dasar multibahasa XLM-RoBERTa dan pemungutan suara ensemble multi-model, tetapi konten dokumen Anda tidak pernah diunggah ke server mana pun.';

  @override
  String get helpVsCopyleaks2 =>
      'Copyleaks memiliki batas penggunaan API tergantung paket; TruthLens tidak memiliki batas penggunaan.';

  @override
  String get helpVsWinstonTitle => 'vs Winston AI';

  @override
  String get helpVsWinston1 =>
      'Pengenalan gambar OCR Winston AI memerlukan pengunggahan gambar ke cloud; TruthLens menggunakan kerangka kerja asli tiap platform (Vision di iOS/macOS, ML Kit di Android, Windows.Media.Ocr di Windows) untuk mengenali teks di perangkat.';

  @override
  String get helpVsWinston2 =>
      'Winston AI dikenal karena laporan yang rapi dan dapat dicetak; TruthLens secara dinamis membuat tata letak laporan melalui AI (kembali ke templat jika tidak ada LLM terpasang), dapat diekspor sebagai PDF/CSV/JSON/PNG.';

  @override
  String get helpAdvantagesTitle => 'Keunggulan eksklusif TruthLens';

  @override
  String get helpAdvantage1 =>
      'Verifikasi keaslian hyperlink: secara otomatis memeriksa apakah URL yang ditemukan dalam dokumen benar-benar dapat dijangkau; tautan akademis berformat DOI selanjutnya diverifikasi terhadap registri publik Crossref untuk mengonfirmasi bahwa jurnal benar-benar mengindeks karya tersebut.';

  @override
  String get helpAdvantage2 =>
      'Verifikasi keaslian kutipan: bahkan referensi tanpa hyperlink apa pun (gaya umum \"penulis-tahun\") dapat diperiksa terhadap registri bibliografi untuk mendeteksi kutipan yang mungkin fiktif — tanda umum halusinasi AI.';

  @override
  String get helpAdvantage3 =>
      'Koreksi bias ESL (bukan penutur asli): secara otomatis mendeteksi karakteristik tulisan bukan penutur asli dan mengurangi bobot model statistik, menghindari kesalahan penilaian tulisan alami bukan penutur asli sebagai AI.';

  @override
  String get helpAdvantage4 =>
      'Impor model kustom: pengguna tingkat lanjut dapat mengimpor model ONNX lokal mereka sendiri untuk menggantikan atau melengkapi mesin deteksi bawaan.';

  @override
  String get helpWorkflowTitle => 'Alur kerja operasional lengkap';

  @override
  String helpWorkflowStepLabel(int step) {
    return 'Langkah $step';
  }

  @override
  String get helpWorkflowStep1Title => 'Unduh & perbarui model';

  @override
  String get helpWorkflowStep1Body =>
      'Peluncuran pertama memandu Anda memasang model deteksi inti; setelah itu Anda selalu dapat memeriksa, mengunduh, memperbarui, atau menghapus model dari \"Pengaturan → Manajemen Model AI\". Aplikasi secara proaktif memeriksa versi terbaru saat peluncuran, dan menunjukkan lencana pada ikon pengaturan serta entri \"Manajemen Model AI\" jika pembaruan tersedia.';

  @override
  String get helpWorkflowStep2Title => 'Memilih model (tujuan & dampak)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Pengklasifikasi AI multibahasa (bobot 40%): menganalisis blok paragraf terbatas untuk mempertahankan konteks, lalu memetakan probabilitas kembali ke kalimat.';

  @override
  String get helpWorkflowStep2Bullet2 =>
      'Mesin analisis statistik (bobot 25%): analisis jendela geser perplexity dan burstiness, menangkap ritme teratur dan pilihan kata dapat diprediksi teks AI.';

  @override
  String get helpWorkflowStep2Bullet3 =>
      'Analisis stilometri (bobot 20%): kelancaran semantik, pola kalimat berulang, penggunaan kata penghubung — paling dapat dijelaskan, paling mudah dipahami \"mengapa\".';

  @override
  String get helpWorkflowStep2Bullet4 =>
      'Pertahanan adversarial (bobot 15%): mendeteksi teks yang telah \"dibersihkan\" melalui alat parafrasa (mis. QuillBot, Undetectable.ai).';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'LLM penulisan laporan (opsional): setelah terpasang, teks laporan ditulis secara dinamis oleh LLM di perangkat; tanpanya, aplikasi kembali ke templat tetap — analisis itu sendiri tidak terpengaruh.';

  @override
  String get helpWorkflowStep2Bullet6 =>
      'Anda dapat mengaktifkan/menonaktifkan mesin secara individual dan menyesuaikan ambang kepercayaan deteksi AI di Pengaturan (meningkatkannya mengurangi kemungkinan salah menilai tulisan manusia sebagai AI).';

  @override
  String get helpWorkflowStep3Title => 'Mengunggah dokumen';

  @override
  String get helpWorkflowStep3Body =>
      'Tiga metode input: menempel teks langsung, OCR gambar (dikenali di perangkat dengan kerangka kerja asli tiap platform), atau impor berkas (txt / md / pdf / docx / doc). Teks harus minimal 40 karakter untuk dikirim ke analisis.';

  @override
  String get helpWorkflowStep4Title => 'Menjalankan analisis';

  @override
  String get helpWorkflowStep4Body =>
      'Ketuk \"Mulai Deteksi\" dan keempat mesin berjalan paralel, dengan kemajuan langsung ditampilkan di layar. Jika karakteristik tulisan bukan penutur asli terdeteksi, koreksi bias ESL diterapkan secara otomatis (dapat dimatikan di Pengaturan).';

  @override
  String get helpWorkflowStep5Title => 'Melihat & mengekspor hasil';

  @override
  String get helpWorkflowStep5Body =>
      'Halaman laporan mencakup: indikator probabilitas AI keseluruhan, peta panas tingkat kalimat, rincian skor dan alasan tiap mesin, keaslian hyperlink, dan keaslian kutipan. Anda dapat mengekspor laporan PDF lengkap, data CSV per kalimat, JSON (untuk integrasi sistem), atau kartu ringkasan PNG (untuk berbagi). Setiap analisis secara otomatis disimpan di \"Riwayat\" untuk ditinjau nanti.';

  @override
  String get helpWorkflowStep1ChipOnboarding => 'Peluncuran pertama';

  @override
  String get helpWorkflowStep1ChipModelManager => 'Manajemen model';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => 'Cek pembaruan otomatis';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => 'Analisis statistik (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => 'Stilometri (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => 'Pertahanan adversarial (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => 'LLM laporan (opsional)';

  @override
  String get helpWorkflowStep3ChipPaste => 'Tempel teks';

  @override
  String get helpWorkflowStep3ChipImageOcr => 'OCR gambar';

  @override
  String get helpWorkflowStep3ChipImportFormats => 'PDF / DOCX / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation => 'Pisahkan kode/rumus';

  @override
  String get helpWorkflowStep4ChipEnsemble => 'Ansambel 4 mesin';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'Progres langsung';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'Koreksi ESL';

  @override
  String get helpWorkflowStep4ChipStoppable => 'Stop anytime';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'Pengukur AI keseluruhan';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => 'Heatmap kalimat';

  @override
  String get helpWorkflowStep5ChipCitationVerification => 'Verifikasi kutipan';

  @override
  String get helpWorkflowStep5ChipExportFormats =>
      'Ekspor PDF / CSV / JSON / PNG';

  @override
  String get helpTuningTitle =>
      'Panduan mengunduh & menyesuaikan model (tanpa pengalaman diperlukan)';

  @override
  String get helpTuningStep1Title => 'Buka Manajemen Model';

  @override
  String get helpTuningStep1Body =>
      'Dari layar utama, ketuk ikon roda gigi untuk membuka \"Pengaturan\", lalu ketuk \"Buka\" di sebelah \"Manajemen Model AI\".';

  @override
  String get helpTuningStep2Title => 'Pilih model untuk perangkat Anda';

  @override
  String get helpTuningStep2Body =>
      'Layar secara otomatis menyarankan tingkat model yang sesuai berdasarkan kemampuan perangkat Anda (RAM, inti CPU), dan mencantumkan setiap varian yang tersedia untuk tiap peran (pengklasifikasi multibahasa / analisis statistik / pertahanan adversarial / LLM laporan).';

  @override
  String get helpTuningStep3Title => 'Unduh & gunakan';

  @override
  String get helpTuningStep3Body =>
      'Ketuk \"Unduh\" di sebelah model yang Anda inginkan dan tunggu hingga selesai — model pertama yang Anda unduh akan otomatis diatur sebagai aktif. Jika Anda memiliki beberapa varian terpasang, ketuk \"Jadikan aktif\" untuk beralih kapan saja; ketuk ikon tempat sampah untuk menghapus model yang tidak diperlukan guna membebaskan ruang.';

  @override
  String get helpTuningStep4Title => 'Memperbarui model';

  @override
  String get helpTuningStep4Body =>
      'Saat versi baru tersedia, \"Manajemen Model AI\" dan ikon roda gigi pengaturan akan menampilkan lencana — kembali ke layar ini untuk melihat dan mengunduh pembaruan (versi yang terpasang sebelumnya dipertahankan kecuali Anda menghapusnya secara manual).';

  @override
  String get helpTuningStep5Title => 'Lanjutan: mengimpor model kustom';

  @override
  String get helpTuningStep5Body =>
      'Jika Anda sudah memiliki, atau telah menyesuaikan, model .onnx yang kompatibel di tempat lain, Anda dapat mengimpornya melalui \"Pengaturan → Impor & uji model ONNX kustom\" — Anda perlu menyediakan berkas model, konfigurasi Tokenizer yang sesuai (atau pilih \"tidak ada\"), dan indeks kelas AI. Sebelum mengimpor, aplikasi secara otomatis memeriksa apakah berkas yang sama ini sudah diimpor, untuk menghindari duplikasi yang tidak disengaja.';

  @override
  String get helpOfficialLinksTitle => 'Tautan unduhan model resmi';

  @override
  String get helpOfficialLinksHint =>
      'Mengetuk item akan membuka halaman resmi model tersebut di peramban sistem Anda.';

  @override
  String get helpLinkRoleTransformer =>
      'Pengklasifikasi AI multibahasa (Transformer, bobot 40%)';

  @override
  String get helpLinkRoleStatistical =>
      'Model statistik perplexity (Statistical, bobot 25%)';

  @override
  String get helpLinkRoleAdversarial =>
      'Model deteksi parafrasa adversarial (Adversarial, bobot 15%)';

  @override
  String get helpLinkRoleLlm => 'LLM penulisan laporan (opsional)';

  @override
  String get privacyAppBarTitle => 'Kebijakan Privasi';

  @override
  String privacyPlatformTitle(String platform) {
    return 'Kebijakan Privasi $platform';
  }

  @override
  String privacyLastUpdated(String date) {
    return 'Terakhir diperbarui: $date';
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
      'TruthLens tidak mengumpulkan data apa pun yang terkait dengan identitas Anda, dan tidak menggunakan data apa pun untuk pelacakan, sehingga tidak memerlukan izin App Tracking Transparency (ATT).';

  @override
  String get privacyIosOverview2 =>
      'Aplikasi ini menggunakan pemilih berkas sistem untuk mengakses berkas atau gambar yang Anda pilih secara aktif; tidak dapat mengakses berkas yang tidak Anda pilih (diberlakukan oleh App Sandbox iOS).';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLens tidak mengumpulkan data pribadi, dan tidak membagikan data pengguna dengan pihak ketiga mana pun.';

  @override
  String get privacyAndroidOverview2 =>
      'Aplikasi ini hanya mengakses penyimpanan saat Anda secara aktif memilih untuk mengimpor berkas atau gambar; tidak menjelajahi atau mengakses berkas lain di latar belakang.';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens berjalan di bawah App Sandbox macOS dan hanya dapat mengakses berkas yang Anda pilih secara aktif melalui dialog berkas sistem (files.user-selected.read-write) — tidak dapat menjelajahi atau mengakses berkas atau folder lain dengan sendirinya.';

  @override
  String get privacyMacosOverview2 =>
      'Akses jaringan (network.client) hanya digunakan untuk fungsi yang tercantum dalam \"Perilaku koneksi yang diperlukan\" di bawah.';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens adalah aplikasi desktop mandiri; data disimpan di folder pengguna lokal Anda (mis. AppData/Documents) dan tidak pernah disinkronkan ke cloud.';

  @override
  String get privacyWindowsOverview2 =>
      'Aplikasi ini hanya mengakses berkas yang Anda pilih secara aktif untuk diimpor; tidak menjelajahi berkas lain di latar belakang.';

  @override
  String get privacyDataHandling1 =>
      'TruthLens tidak memiliki akun pengguna, tidak memerlukan login, dan tidak mengandung SDK iklan atau pelacakan pihak ketiga dalam bentuk apa pun.';

  @override
  String get privacyDataHandling2 =>
      'Konten dokumen apa pun yang Anda ketik, tempel, atau impor dianalisis sepenuhnya oleh model AI di perangkat Anda sendiri — tidak pernah diunggah ke TruthLens atau server pihak ketiga mana pun.';

  @override
  String get privacyDataHandling3 =>
      'Hasil analisis dan riwayat hanya disimpan dalam basis data lokal di perangkat Anda; menghapus aplikasi atau membersihkan riwayat menghapusnya sepenuhnya — TruthLens tidak menyimpan salinan apa pun di mana pun.';

  @override
  String get privacyNetworkIntro =>
      'Deteksi AI inti aplikasi ini berjalan sepenuhnya di perangkat, tetapi tiga fitur berikut memerlukan akses jaringan:';

  @override
  String get privacyNetwork1 =>
      '1. Katalog & unduhan model: terhubung ke GitHub Releases/Hugging Face untuk mengunduh model deteksi yang Anda pilih — ini hanya mengunduh model dan tidak pernah mengunggah data pengguna apa pun.';

  @override
  String get privacyNetwork2 =>
      '2. Pemeriksaan pembaruan model: saat peluncuran, aplikasi terhubung hanya untuk membandingkan nomor versi, digunakan untuk menunjukkan apakah versi baru tersedia.';

  @override
  String get privacyNetwork3 =>
      '3. Verifikasi keaslian hyperlink & kutipan: diaktifkan secara default, dapat dimatikan di Pengaturan. Saat diaktifkan, URL atau teks bibliografi yang terdeteksi dalam dokumen dikirim langsung ke URL itu sendiri, atau ke API publik Crossref, hanya mengirim teks URL/DOI/kutipan itu sendiri — tidak pernah konten dokumen lainnya.';

  @override
  String get privacyNetwork4 =>
      '4. Web OCR fallback: on the Web version only, OCR first uses a local OCR server if configured. If you choose to enter a Gemini API key, selected images and rendered pages from PDFs that require OCR are sent directly from your browser to Google\'s Gemini API; the key is stored only in that browser\'s local storage.';

  @override
  String get privacyRightsIntro =>
      'Anda dapat membersihkan riwayat analisis lokal Anda kapan saja di \"Riwayat\", atau mematikan verifikasi hyperlink/kutipan di \"Pengaturan\", atau menghapus semua data lokal dengan';

  @override
  String get privacyRemoveIos => 'menghapus aplikasi';

  @override
  String get privacyRemoveAndroid => 'membongkar pemasangan aplikasi';

  @override
  String get privacyRemoveMacos => 'memindahkan aplikasi ke Sampah';

  @override
  String get privacyRemoveWindows => 'membongkar pemasangan aplikasi';

  @override
  String get privacyDisclaimer =>
      'Halaman ini adalah penjelasan privasi yang ditulis oleh TruthLens untuk mencerminkan perilaku fungsional aktual, bukan dokumen hukum formal yang ditinjau pengacara; untuk tinjauan kepatuhan formal berdasarkan hukum wilayah Anda, silakan konsultasikan pengacara independen.';

  @override
  String get privacySectionOverviewIos =>
      'Ringkasan (setara dengan \"Label Privasi\" App Store)';

  @override
  String get privacySectionOverviewAndroid =>
      'Ringkasan (setara dengan pengungkapan \"Keamanan Data\" Google Play)';

  @override
  String get privacySectionOverviewMacos => 'Ringkasan (izin App Sandbox)';

  @override
  String get privacySectionOverviewWindows => 'Ringkasan';

  @override
  String get privacySectionDataHandling => 'Cara kami menangani data Anda';

  @override
  String get privacySectionNetwork => 'Koneksi jaringan yang diperlukan';

  @override
  String get privacySectionRights => 'Hak Anda';

  @override
  String get privacyGenericPlatformName => 'Platform ini';

  @override
  String settingsVersionSubtitle(String version, String build) {
    return 'Versi $version (Build $build) · Mesin privasi yang mengutamakan lokal';
  }

  @override
  String get webOcrSettingsTitle => 'Pengaturan OCR Web';

  @override
  String get webOcrPurpose =>
      'Mengenali teks cetak atau tulisan tangan dalam gambar sebelum analisis.';

  @override
  String get webOcrGeminiKeyTitle => 'Kunci API Gemini (opsional)';

  @override
  String get webOcrGetKeyButton => 'Dapatkan kunci';

  @override
  String get webOcrGeminiDescription =>
      'Hanya digunakan saat server OCR lokal tidak tersedia. Kunci disimpan di browser ini.';

  @override
  String get webOcrLocalServerTitle => 'Server OCR lokal (disarankan)';

  @override
  String get webOcrLocalServerDescription =>
      'Menjalankan OCR di komputer dengan Apple Vision pada macOS atau Windows OCR pada Windows. Masukkan endpoint lokal di bawah.';

  @override
  String get webOcrSetupGuideButton => 'Panduan penyiapan';

  @override
  String get webOcrPriorityTitle => 'Urutan pengenalan';

  @override
  String get webOcrPriorityDescription =>
      '1. Server OCR lokal jika URL diatur\n2. Gemini jika kunci API diatur\n3. Diagnosis khusus jika keduanya gagal';

  @override
  String get webOcrSetupGuideTitle => 'Siapkan server OCR lokal';

  @override
  String get webOcrSetupGuideBody =>
      '1. Pilih Buka proyek OCR di bawah.\n2. macOS: unduh setup_and_run_ocr.sh, buka Terminal, lalu jalankan: bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows: unduh setup_and_run_ocr.bat, klik dua kali, lalu izinkan pemasangan.\n4. Tunggu sampai pemasang menyatakan OCR siap; mulai otomatis juga akan disiapkan.\n5. Masukkan http://127.0.0.1:5001/ocr lalu pilih Uji koneksi.\n6. Buka OCR Gambar dan pilih gambar yang jelas.\n\nUntuk memakai 127.0.0.1, browser dan server harus berjalan di komputer yang sama. Jika gagal, periksa pemasangan, port 5001, dan akhiran /ocr.';

  @override
  String get webOcrOpenProjectButton => 'Buka proyek OCR';

  @override
  String get webOcrTestServerButton => 'Uji koneksi';

  @override
  String get webOcrTestServerMissingUrl =>
      'Masukkan URL server OCR lokal terlebih dahulu.';

  @override
  String get webOcrTestServerSuccess => 'Server OCR lokal berjalan dan siap.';

  @override
  String get webOcrTestServerFailure =>
      'Server OCR lokal tidak dapat dijangkau. Periksa panduan, firewall, dan URL.';

  @override
  String get workspaceModeSectionTitle => 'Mode ruang kerja';

  @override
  String get workspaceModeSectionSubtitle =>
      'Pilih cara sumber, analisis langsung, dan bukti akhir berbagi satu ruang kerja.';

  @override
  String get workspaceModeOriginal => 'Tata letak asli';

  @override
  String get workspaceModeAuto => 'Otomatis';

  @override
  String get workspaceModeCommandGrid => 'Kisi komando';

  @override
  String get workspaceModeTimeline => 'Linimasa misi';

  @override
  String get workspaceModeEvidence => 'Kanvas bukti';

  @override
  String get workspaceModeCosmicFuture => 'Cosmic Future';

  @override
  String get workspaceModeSoftEducation => 'Soft Education';

  @override
  String get workspaceModeTooltip => 'Ganti mode ruang kerja';

  @override
  String get workspaceMoreMenuTooltip => 'More options';

  @override
  String get workspaceLanguageMenuTitle => 'Language';

  @override
  String get workspaceStageImport => 'Impor';

  @override
  String get workspaceStageParse => 'Urai';

  @override
  String get workspaceStageAnalyze => 'Analisis empat mesin';

  @override
  String get workspaceStageVerify => 'Verifikasi';

  @override
  String get workspaceStageReport => 'Laporan';

  @override
  String get workspaceLiveFindings => 'Temuan langsung';

  @override
  String get workspaceTelemetry => 'Telemetri analisis';

  @override
  String get workspaceDocument => 'Ruang dokumen';

  @override
  String get workspaceOverallProgress => 'Progres keseluruhan';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return 'Langkah $current/$total · $stage';
  }

  @override
  String get workspaceWaiting => 'Menunggu dokumen';

  @override
  String get workspaceAnalyzing => 'Analisis berlangsung';

  @override
  String get workspaceAnalysisComplete => 'Analisis selesai';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return '$done/$total modul selesai · $seconds dtk berlalu · Berjalan: $engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return 'Analisis masih berjalan dan antarmuka tetap responsif. Belum ada modul selesai selama $seconds dtk; dokumen besar atau model lokal dapat memerlukan waktu lebih lama.';
  }

  @override
  String get workspaceAnalysisFailed =>
      'Analisis berhenti secara tak terduga. Coba lagi atau periksa pengaturan model.';

  @override
  String get workspaceNewAnalysis => 'Analisis baru';

  @override
  String get workspaceStopAnalysis => 'Hentikan analisis';

  @override
  String get workspaceStopAnalysisTitle => 'Hentikan analisis saat ini?';

  @override
  String get workspaceStopAnalysisBody =>
      'Analisis masih berjalan. Teks dokumen akan dipertahankan, tetapi hasil yang belum selesai tidak akan disimpan.';

  @override
  String get workspaceAnalysisStopped =>
      'Analisis dihentikan. Teks dokumen tetap tersedia di ruang kerja.';

  @override
  String get workspaceSelectedEvidence => 'Bukti terpilih';

  @override
  String get workspaceNoEvidence =>
      'Bukti kalimat muncul saat setiap mesin selesai.';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return 'Probabilitas AI sementara: $percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      'This percentage is this sentence\'s own AI signal, not the overall document verdict. Higher means the wording pattern looks more AI-generated; lower means it reads more like typical human writing. The final report combines every sentence with engine weighting.';

  @override
  String get workspaceSentenceSignalHeader => 'AI signal per sentence';

  @override
  String get workspaceSentenceColumnHeader => 'Sentence';
}
