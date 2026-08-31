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
    return 'Lapisan teks PDF tidak tersedia; mengenali halaman $page dari $total dengan OCR…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return 'Mengimpor \"$fileName\" dengan OCR PDF ($count karakter)';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '\"$fileName\" tidak memiliki lapisan teks yang andal. Konfigurasikan Web OCR atau gunakan aplikasi terpasang dengan OCR native, lalu impor ulang.';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '\"$fileName\" memerlukan OCR tetapi melebihi batas keamanan $max halaman. Pisahkan PDF dan impor setiap bagian.';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return '\"$fileName\" tidak dapat dibaca dengan andal. Mungkin rusak, dilindungi kata sandi, atau tidak didukung oleh layanan OCR yang dikonfigurasi.';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '\"$fileName\" adalah file .doc lama dan teksnya tidak dapat diekstrak dengan andal. Simpan sebagai .docx di Word atau ekspor ke PDF, lalu impor ulang.';
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
  String get firstRunModelPromptTitle => 'Tambahkan model deteksi?';

  @override
  String get firstRunModelPromptBody =>
      'TruthLens sudah dapat digunakan: mesin statistik dan stilistika siap sekarang. Menambahkan model neural di perangkat akan menyertakan pengklasifikasi multibahasa dalam pemungutan suara ensemble, sehingga akurasi dan cakupan bahasa meningkat nyata. Model berjalan sepenuhnya di peramban Anda dan tidak pernah mengunggah dokumen Anda. Anda juga dapat memutuskannya nanti dari \"Pengaturan → Manajemen Model AI\".';

  @override
  String get firstRunModelPromptLater => 'Nanti saja';

  @override
  String get firstRunModelPromptGo => 'Pilih model';

  @override
  String get modernChineseModelPromptTitle =>
      'Tingkatkan deteksi bahasa Tionghoa';

  @override
  String get modernChineseModelPromptBody =>
      'Dokumen berbahasa Tionghoa ini saat ini belum memiliki detektor Tionghoa modern (sekitar 98 MB). Model multibahasa yang lama dikalibrasi pada teks generasi awal dan dapat melewatkan tulisan Tionghoa masa kini bergaya DeepSeek, Gemini, dan GPT. Unduh model khusus di perangkat untuk hasil yang lebih terkalibrasi, atau lanjutkan dengan cadangan lintas bahasa yang lebih lemah.';

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
  String get onboardingBundleTitle => 'Rekomendasi untuk perangkat ini';

  @override
  String onboardingBundleSummary(int count, String size) {
    return '$count model · total $size MB';
  }

  @override
  String onboardingBundleStorage(String available, String remaining) {
    return 'Penyimpanan peramban: $available MB tersedia, tersisa sekitar $remaining MB setelah pengunduhan';
  }

  @override
  String get onboardingStorageNotPersisted =>
      'Model yang sudah diunduh belum terlindungi dari pembersihan otomatis. Jika ruang disk menipis, peramban dapat menghapusnya dan Anda harus mengunduh ulang. Memasang TruthLens sebagai aplikasi membuat peramban jauh lebih mungkin mempertahankannya.';

  @override
  String get onboardingInstallAppButton => 'Pasang sebagai aplikasi';

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
  String reportEngineDirectionalIndex(int percent) {
    return 'Arah lemah $percent/100';
  }

  @override
  String get reportEngineNoDirectionalSignal => 'Tidak ada sinyal arah';

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
  String get historyUntitledDocument => 'Dokumen tanpa judul';

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
  String get reportEngineAnalysisLevelTitle => 'Lapisan analisis mesin';

  @override
  String get reportVerdictAiLikelihood => 'Kecenderungan AI';

  @override
  String get reportVerdictHumanLikelihood => 'Tulisan Manusia';

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
  String get reportDetailAnalysisTitle => 'Analisis terperinci';

  @override
  String get reportNoEngineData => 'Tidak ada data mesin';

  @override
  String get ocrGeminiKeyRequired =>
      'Masukkan kunci API Gemini terlebih dahulu.';

  @override
  String get ocrGeminiKeyValid => 'Kunci API Gemini valid dan dapat dijangkau.';

  @override
  String get ocrGeminiKeyUnreachable =>
      'Tidak dapat menjangkau API Gemini. Periksa kuncinya.';

  @override
  String get ocrStatusLocalUnset => 'OCR lokal: endpoint belum diatur';

  @override
  String get ocrStatusLocalUntested =>
      'OCR lokal: endpoint diatur, belum diuji';

  @override
  String get ocrStatusLocalTesting => 'OCR lokal: menguji koneksi';

  @override
  String get ocrStatusLocalReady => 'OCR lokal: siap';

  @override
  String get ocrStatusLocalUnreachable => 'OCR lokal: tidak terjangkau';

  @override
  String get ocrStatusGeminiUnset => 'Gemini: belum ada kunci';

  @override
  String get ocrStatusGeminiUntested => 'Gemini: kunci diatur, belum diuji';

  @override
  String get ocrStatusGeminiVerifying => 'Gemini: memverifikasi kunci';

  @override
  String get ocrStatusGeminiValid => 'Gemini: kunci valid';

  @override
  String get ocrStatusGeminiInvalid =>
      'Gemini: tidak valid atau tak terjangkau';

  @override
  String get ocrActiveLocalVerified =>
      'Mesin aktif: server OCR lokal (terverifikasi)';

  @override
  String get ocrActiveLocalUntested =>
      'Mesin aktif: server OCR lokal (belum diuji)';

  @override
  String get ocrActiveGeminiVerified =>
      'Mesin aktif: API Gemini (terverifikasi)';

  @override
  String get ocrActiveGeminiUntested => 'Mesin aktif: API Gemini (belum diuji)';

  @override
  String get ocrActiveNone => 'Belum ada mesin OCR yang dikonfigurasi';

  @override
  String get ocrDetectAndDownload => 'Deteksi sistem & unduh pemasang';

  @override
  String get ocrAutoInstallUnavailable => 'Pemasangan otomatis tidak tersedia';

  @override
  String get ocrUnsupportedPlatformBody =>
      'Platform saat ini tidak mendukung pemasangan desktop sekali klik. Peramban web tidak dapat memasang dan menjalankan layanan OCR lokal di iOS, Android, Linux, atau sistem yang tidak dikenal.\n\nPilihan:\n1. Gunakan asisten ini dari peramban desktop macOS atau Windows.\n2. Gunakan kunci API Gemini sebagai cadangan OCR web.\n3. Pengguna tingkat lanjut dapat membuka proyek OCR, menjalankan endpoint /ocr yang kompatibel, lalu memasukkan URL di sini.';

  @override
  String ocrInstallerReady(String osName) {
    return 'Pemasang $osName siap';
  }

  @override
  String get ocrRunInstructionMac => 'bash ~/Downloads/setup_and_run_ocr.sh';

  @override
  String get ocrRunInstructionWindows =>
      'klik dua kali setup_and_run_ocr.bat di folder Downloads';

  @override
  String ocrAssistantDownloadedBody(
    String osName,
    String endpoint,
    String fileName,
    String runInstruction,
    String testButton,
  ) {
    return '$osName terdeteksi, dan endpoint lokal telah diisi otomatis:\n$endpoint\n\nPeramban Anda mulai mengunduh $fileName. Demi keamanan peramban, TruthLens Web tidak dapat menjalankan pemasang atau mengubah pengaturan startup.\n\nLangkah berikutnya:\n1. Jalankan pemasang yang diunduh: $runInstruction\n2. Tunggu hingga terminal atau jendela menyatakan layanan OCR siap.\n3. Kembali ke sini dan pilih \"$testButton\".\n\nSetelah pengujian berhasil, OCR gambar akan memakai layanan lokal ini lebih dulu. Gambar tidak dikirim ke Gemini kecuali Anda juga mengatur kunci API Gemini sebagai cadangan.';
  }

  @override
  String get reportEngineNotParticipated => 'Tidak terlibat';

  @override
  String get reportAiContentReportTitle => 'Laporan Deteksi Konten AI';

  @override
  String reportAnalysisTimeLabel(String time) {
    return 'Waktu analisis: $time';
  }

  @override
  String get reportDownloadPdfButton => 'Unduh PDF';

  @override
  String get reportSuspiciousLocationsTitle => 'Lokasi konten mencurigakan';

  @override
  String reportSentenceCount(int count) {
    return '$count kalimat';
  }

  @override
  String get reportAiProbabilityPrefix => 'Probabilitas AI: ';

  @override
  String get helpAdvantage5 =>
      'Forensik asal dokumen: membaca catatan penyuntingan di dalam berkas .docx / .odt / .doc — waktu yang dipakai, jumlah penyimpanan, sebaran sesi penyuntingan. Bukti itu terlepas dari putusan atas teks dan ditampilkan terpisah dari probabilitas AI. PDF dan gambar tidak punya riwayat penyuntingan sendiri sehingga tidak dapat menyediakannya.';

  @override
  String get helpAdvantage6 =>
      'Ia abstain dengan jujur bila buktinya tipis: kalimat yang bisa dianalisis kurang dari 5, kata kurang dari 100, mesin yang ikut kurang dari 2, atau mesin berselisih lebih dari 60 poin persen semuanya menghasilkan “bukti tidak cukup untuk menilai”. Sebagian besar tuduhan keliru berawal dari angka meyakinkan yang dikembalikan atas masukan yang terlalu lemah.';

  @override
  String get settingsAiSampleTitle => 'Tambah sampel buatan AI';

  @override
  String get settingsAiSampleSubtitle =>
      'Kalibrasi latar belakang hanya mengumpulkan sampel manusia dengan sendirinya. Untuk mengaktifkan bobot mesin hasil pembelajaran, Anda juga perlu tulisan yang diketahui dibuat AI — tempel atau impor satu, dan teks itu langsung dianalisis serta dilabeli sebagai sampel AI.';

  @override
  String get settingsAiSampleFromClipboard => 'Tempel dari papan klip';

  @override
  String get settingsAiSampleFromFile => 'Impor dokumen';

  @override
  String get settingsAiSampleAnalyzing => 'Menganalisis…';

  @override
  String settingsAiSampleAdded(int count) {
    return 'Sampel AI ditambahkan — total $count';
  }

  @override
  String get settingsAiSampleTooShort =>
      'Terlalu pendek untuk dijadikan sampel (minimal 100 kata)';

  @override
  String get settingsAiSampleFailed =>
      'Tidak ditemukan konten yang dapat digunakan';

  @override
  String get helpFormatCoverageTitle => '2a. Batasan format pada bukti asal';

  @override
  String get helpFormatCoverage =>
      '**Batasan penting: hanya .docx dan .odt yang membawa catatan penyuntingan.**\n\n| Sumber | Catatan penyuntingan |\n|---|---|\n| .docx / .odt | ✅ ada |\n| .pdf | ❌ formatnya memang tidak menyimpan riwayat |\n| .doc (lama) | ✅ ada (OLE2 SummaryInformation) |\n| .txt / .md | ❌ tanpa kontainer |\n| OCR gambar | ❌ hanya tersisa piksel |\n| Teks tempelan | ❌ tidak ada berkas |\n\nIni berdampak langsung pada pilar 3: **hanya dokumen dengan catatan penyuntingan yang otomatis masuk ke basis berjaminan statistik.** Bila semua yang Anda terima berupa PDF, basis itu tidak akan pernah bertambah — yang menumpuk hanyalah sampel rujukan tanpa jaminan.\n\nAgar bukti asal dan kalibrasi otomatis benar-benar berfungsi, kumpulkan berkas asli .docx, .odt, atau .doc, bukan PDF hasil cetak atau ekspor. Ini kebutuhan alur kerja, bukan batasan yang bisa diakali perangkat lunak: PDF adalah format keluaran dan memang tidak mencatat bagaimana teks itu ditulis.';

  @override
  String provenanceUnsupportedFormat(String format) {
    return 'Format $format sama sekali tidak membawa riwayat penyuntingan, jadi ini bukan kasus catatannya dihapus — memang tidak pernah ada. Hanya .docx dan .odt yang mencatat waktu penyuntingan, jumlah penyimpanan, dan sesi penyuntingan.';
  }

  @override
  String get provenanceStripped =>
      'Format ini didukung, tetapi tidak ditemukan catatan penyuntingan di dalam berkas. Biasanya itu berarti berkas disimpan sebagai berkas baru, dikonversi daring, atau diekspor dari Google Dokumen — semuanya menolkan catatan.';

  @override
  String get provenanceHowToGetRecord =>
      'Agar bukti asal berguna, dapatkan **berkas asli .docx, .odt, atau .doc**, bukan PDF hasil cetak atau ekspor. Hanya berkas asli yang menyimpan riwayat penyuntingan, dan hanya itu yang bisa masuk otomatis ke basis berjaminan statistik.';

  @override
  String get calibrationAutoTitle => 'Mengumpulkan di latar belakang';

  @override
  String get calibrationAutoSubtitle =>
      'Dokumen yang Anda analisis masuk ke basis secara otomatis — tidak perlu memberi label manual.';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return 'Dipastikan ditulis manusia lewat catatan penyuntingan: $auto; sampel rujukan saja: $observed';
  }

  @override
  String get calibrationAutoWhy =>
      'Hanya dokumen dengan catatan penyuntingan (waktu yang dipakai, jumlah penyimpanan, sebaran sesi) yang masuk ke basis berjaminan statistik, sebab bukti itu **terlepas dari putusan atas teksnya**. Memberi label dari putusan alat ini sendiri sama saja memeriksa pekerjaan sendiri: tulisan yang salah ditandai tak akan pernah masuk basis, ambangnya mengetat tiap putaran, dan makin banyak tulisan manusia asli yang justru ditandai. Teks tempelan tidak punya catatan penyuntingan, jadi hanya dihitung untuk persentil rujukan di bawah.';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return 'Sebagai rujukan: skor ini berada di persentil ke-$percentile dari $count dokumen yang telah Anda analisis (tanpa jaminan statistik)';
  }

  @override
  String get settingsAutoCollectTitle =>
      'Kumpulkan sampel kalibrasi di latar belakang';

  @override
  String get settingsAutoCollectSubtitle =>
      'Menambahkan dokumen yang dianalisis ke basis secara otomatis. Label berasal dari catatan penyuntingan dokumen, bukan dari putusan alat ini.';

  @override
  String get settingsStoreTextTitle => 'Simpan teks untuk validasi luring';

  @override
  String get settingsStoreTextSubtitle =>
      'Bila aktif, tulisan yang Anda tambahkan ke basis disimpan di perangkat beserta teks lengkapnya, sehingga nanti bisa diekspor sebagai berkas korpus untuk evaluasi luring.';

  @override
  String get settingsStoreTextWarning =>
      'Teks itu umumnya karya orang lain sehingga bersifat sensitif. Aktifkan hanya selama Anda benar-benar mengumpulkan korpus validasi, dan gunakan “Hapus teks tersimpan” begitu selesai mengekspor. Menghapusnya tidak memengaruhi prediksi konformal — ia hanya perlu skornya.';

  @override
  String get settingsExportCorpusTitle => 'Ekspor korpus kalibrasi';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return 'Siap diekspor: $human manusia, $ai AI (dibutuhkan $required untuk tiap kelas)';
  }

  @override
  String get settingsExportCorpusButton => 'Ekspor sebagai JSONL';

  @override
  String get settingsExportCorpusEmpty =>
      'Tidak ada yang bisa diekspor — aktifkan dulu “simpan teks”, lalu kumpulkan basisnya';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return '$count sampel diekspor; $skipped dilewati karena tanpa teks tersimpan';
  }

  @override
  String get settingsClearStoredText => 'Hapus teks tersimpan';

  @override
  String get settingsClearStoredTextDone =>
      'Semua teks tersimpan telah dihapus. Skor dan kalibrasi tidak berubah.';

  @override
  String get helpDesignTitle => 'Filosofi desain dan batasan yang diketahui';

  @override
  String get helpShiftTitle =>
      '1. Pergeseran: kami tidak bersaing soal ketepatan skor';

  @override
  String get helpShiftBody =>
      'Hampir semua detektor di pasaran menjawab pertanyaan yang sama: apakah teks ini tampak ditulis AI?\n\nItu perlombaan senjata yang pasti kalah. Makin kuat modelnya, makin dekat keluarannya dengan tulisan manusia secara statistik — dan alat parafrase membaik jauh lebih cepat daripada detektor. Di jalur itu, model besar di server hanya kalah lebih lambat.\n\nTruthLens mengajukan pertanyaan lain: bukti apa yang sebenarnya kita pegang tentang bagaimana dokumen ini terwujud, dan seberapa kuat masing-masing?\n\nItulah pergeseran dari menebak gaya tulisan menuju menimbang bukti asal-usul beserta kesimpulan yang jujur secara statistik. Karena itulah alat ini sengaja tidak mengejar peringkat ketepatan skor tunggal, melainkan membentangkan tiap bukti secara terpisah dan berterus terang ketika tidak tahu. Keunggulan sesungguhnya dari berjalan di peramban bukan kecepatan, melainkan melihat apa yang tak pernah dilihat server: berkas yang utuh, dan basis yang Anda kumpulkan sendiri.';

  @override
  String get helpPillarsTitle => '2. Lima pilar';

  @override
  String get helpPillarsBody =>
      '1. Forensik asal dokumen (aktif)\nMembaca catatan penyuntingan di dalam kontainer DOCX dan ODT: total waktu penyuntingan, jumlah penyimpanan, waktu pembuatan dan perubahan, serta penanda sesi penyuntingan (RSID) pada isi. Satu atau dua RSID untuk satu tulisan penuh biasanya berarti teks masuk sekaligus; 3.000 kata dengan empat menit penyuntingan adalah bukti yang lebih keras daripada skor perpleksitas mana pun. Ini dihitung sebagai bukti asal dan ditampilkan terpisah dari probabilitas AI — sengaja tidak pernah dilebur ke dalam skor.\n\n2. Kalibrasi basis lokal dan prediksi konformal (aktif)\nTambahkan tulisan yang Anda yakin ditulis sendiri oleh penulisnya, dan sistem akan menilai berdasarkan sebaran kelompok ini, bukan ambang global. Prediksi konformal memberi jaminan bebas asumsi sebaran: bila basis dan sampel yang diuji dapat dipertukarkan, tingkat positif palsu tetap di bawah alfa yang Anda tetapkan. Inilah kunci menekan salah nilai pada tulisan penutur non-asli, dan hal yang tak bisa dilakukan produk komersial: mereka tidak punya tulisan basis dari orang yang Anda nilai.\n\n3. Bobot mesin hasil pembelajaran (aktif)\nBegitu basis memuat sampel manusia dan AI, sistem mengukur seberapa baik tiap mesin memisahkan kedua kelompok (ukuran efek Cohen\'s d) lalu menyarankan bobot yang sesuai, menggantikan rasio tetap yang disetel manual. Tidak ada yang berubah sampai Anda menekan Terapkan — pengaturan tidak pernah diubah diam-diam.\n\n4. Perpleksitas silang Binoculars (inti penilaian selesai, belum aktif)\nPerpleksitas mentah memperlakukan seberapa mudah teks diprediksi seolah itu mengukur seberapa mirip AI — persis dari situlah positif palsu sistematisnya pada tulisan penutur non-asli yang bersahaja. Binoculars mengukur keterprediksian itu relatif terhadap seberapa jauh dua model saling berbeda. Matematikanya sudah diterapkan dan diuji, tetapi mengaktifkannya masih perlu sepasang model bahasa kecil yang bisa berjalan di peramban, ditambah validasi dengan data berlabel.\n\n5. Deteksi tanda air (diperiksa, tidak layak, tidak dibangun)\nDeteksi SynthID-Text terikat kunci: detektor harus menghitung dengan kunci yang sama seperti saat pembuatan, sementara kunci produksi Google tidak dipublikasikan. Melakukannya di peramban tidak akan pernah terpicu pada keluaran nyata ChatGPT, Claude, atau Gemini — hanya akan menjadi fitur yang tak pernah aktif sembari membuat Anda percaya tanda air sedang diperiksa. Maka sengaja ditinggalkan.';

  @override
  String get helpCascadeTitle => '3. Kaskade berjenjang dan abstain';

  @override
  String get helpCascadeBody =>
      'Agar tetap cepat dalam anggaran komputasi peramban yang terbatas, analisis berjalan berjenjang: sinyal murah dulu, yang mahal hanya bila perlu.\n\nJenjang 0  Bukti asal dokumen (nyaris tanpa biaya)\nJenjang 1  Ciri statistik dan stilometrik (mesin yang ada, murah)\nJenjang 2  Pengklasifikasi Transformer tingkat kalimat\nJenjang 3  Perpleksitas silang (paling mahal, hanya bila gambarannya masih kabur)\n\nHasilnya lalu masuk ke kalibrasi lokal, yang menghasilkan kesimpulan berjaminan positif palsu — atau abstain secara eksplisit.\n\n[Mengapa abstain itu penting]\nSebagian besar tuduhan keliru lahir dari mengembalikan angka yang meyakinkan atas masukan yang terlalu pendek atau terlalu lemah untuk menopangnya. Alat ini menampilkan terus terang \"Bukti tidak cukup untuk menilai\", alih-alih memaksakan skor, ketika:\n\n- kalimat yang bisa dianalisis kurang dari 5\n- teks kurang dari 100 kata\n- mesin yang ikut kurang dari 2\n- mesin berselisih lebih dari 60 poin persen (merata-ratakannya sudah kehilangan makna)\n\nSaat abstain, skor lengkap dan bukti per kalimat tetap ada di bawah sebagai rujukan — tetapi mohon jangan diperlakukan sebagai kesimpulan. Sistem yang bersedia berkata \"saya tidak tahu\" lebih layak dipercaya daripada yang selalu menyodorkan angka.';

  @override
  String get helpRisksTitle => '4. Risiko yang layak dihadapi dengan jujur';

  @override
  String get helpRisksBody =>
      'Setiap butir di bawah ini adalah batasan nyata alat ini. Timbanglah sebelum bertindak atas apa pun yang dilaporkannya.\n\n1. Bukti asal bisa dihapus atau dipalsukan\nMenyimpan sebagai berkas baru, mengonversi daring, mengekspor dari Google Dokumen, atau menyalin ke dokumen baru semuanya menolkan catatan penyuntingan. Sinyal di sini hanyalah bukti pendukung, dan ketiadaannya jelas tidak membuktikan bahwa manusia yang menulisnya.\n\n2. Jaminan konformal bersandar pada keterpertukaran\nIa hanya berlaku bila sampel basis dan teks yang diuji berasal dari kelompok orang yang sama mengerjakan jenis tugas yang sama. Bila tulisan penulis jelas membaik, atau jenis tugas berubah total, premisnya gugur dan basis perlu dibangun ulang.\n\n3. Basis itu sendiri bisa terkontaminasi\nBila tugas yang dipakai sebagai basis sebenarnya ditulis AI, seluruh kalibrasi menjadi miring. Sampel basis harus dikumpulkan dalam kondisi terkendali — misalnya karya yang diselesaikan di bawah pengawasan.\n\n4. Model kecil di peramban kurang akurat dibanding model besar di server\nItulah harga tak terhindarkan yang dibayar keputusan Web-only demi privasi. Nilai alat ini bukan skor tunggal yang lebih akurat, melainkan dapat dijelaskan, dapat dikalibrasi, dan cukup jujur untuk abstain.\n\n5. Tidak ada skor yang boleh berdiri sendiri sebagai dasar tuduhan\nSelalu baca bersama bukti per kalimat, asal dokumen, dan apa yang sudah Anda ketahui tentang penulis tersebut. Alat ini dirancang untuk menopang percakapan yang Anda lakukan, bukan menjatuhkan vonis menggantikan Anda.';

  @override
  String get calibrationAddHuman => 'Tambahkan sebagai basis tulisan manusia';

  @override
  String get calibrationAddAi => 'Tambahkan sebagai sampel AI yang diketahui';

  @override
  String calibrationCounts(int human, int ai) {
    return 'Basis: $human manusia, $ai AI';
  }

  @override
  String get learnedWeightsTitle => 'Bobot mesin hasil pembelajaran';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return 'Saat ini ada $human sampel manusia dan $ai sampel AI. Tiap kelas butuh setidaknya $required agar bobot dapat dipelajari dengan andal; sampai saat itu bobot manual Anda tetap berlaku.';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return 'Bobot kini dapat dipelajari dari $human sampel manusia dan $ai sampel AI Anda.';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine: bobot disarankan $weight% (pemisahan $effect)';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return 'Catatan: $engine membalik kedua kelompok — sampel AI justru bernilai lebih rendah — sehingga bobotnya menjadi nol. Biasanya ini berarti mesin tersebut tidak cocok untuk jenis teks ini.';
  }

  @override
  String get learnedWeightsApply => 'Terapkan bobot hasil pembelajaran';

  @override
  String get learnedWeightsApplied => 'Bobot hasil pembelajaran diterapkan';

  @override
  String get learnedWeightsExplain =>
      'Bobot berasal dari seberapa baik tiap mesin memisahkan sampel manusia dari sampel AI Anda (ukuran efek Cohen\'s d): makin jauh kedua kelompok terpisah dan makin stabil masing-masing, makin besar bobot mesin itu. Ini menggantikan bobot tetap yang disetel manual agar ansambel cocok dengan jenis teks yang benar-benar Anda tangani.';

  @override
  String get calibrationTitle => 'Kalibrasi basis lokal';

  @override
  String get calibrationEmpty =>
      'Belum ada himpunan basis. Tambahkan beberapa tulisan yang Anda yakin ditulis sendiri oleh penulisnya — misalnya karya yang diselesaikan di bawah pengawasan — agar sistem bisa menilai berdasarkan sebaran kelompok ini sendiri, bukan ambang global yang sama untuk semua. Justru inilah yang menekan positif palsu pada tulisan penutur non-asli.';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return 'Himpunan basis berisi $count sampel; agar batas atas positif palsu $alpha% benar-benar berlaku, dibutuhkan setidaknya $required. Sampai itu tercapai, angka hanya ditampilkan sebagai rujukan dan tidak dipakai menandai apa pun.';
  }

  @override
  String calibrationFlagged(int alpha) {
    return 'Pada batas atas positif palsu $alpha%, teks ini **ditandai**.';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return 'Pada batas atas positif palsu $alpha%, teks ini **tidak ditandai**.';
  }

  @override
  String calibrationPValue(String value, int count) {
    return 'Nilai p konservatif $value (terhadap $count sampel basis)';
  }

  @override
  String calibrationPercentile(int percentile) {
    return 'Skor berada di persentil ke-$percentile dari himpunan basis';
  }

  @override
  String get calibrationCaveat =>
      'Jaminan ini bersandar pada sampel basis dan teks yang diuji bersifat dapat dipertukarkan — kelompok orang yang sama, jenis tugas menulis yang sama. Bila tulisan penulis jelas membaik, atau jenis tugas berubah total, syarat itu tidak lagi berlaku dan himpunan basis perlu dibangun ulang. Perhatikan juga: bila tulisan basisnya sendiri dibuatkan AI, seluruh kalibrasi menjadi miring, jadi kumpulkan dalam kondisi terkendali.';

  @override
  String get calibrationAddButton => 'Tambahkan ini ke himpunan basis';

  @override
  String calibrationAdded(int count) {
    return 'Ditambahkan ke himpunan basis — kini $count sampel';
  }

  @override
  String get settingsCalibrationTitle => 'Himpunan basis lokal';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return 'Tersimpan $count sampel ($required dibutuhkan pada α ini)';
  }

  @override
  String get settingsCalibrationClear => 'Kosongkan himpunan basis';

  @override
  String get settingsCalibrationCleared => 'Himpunan basis dikosongkan';

  @override
  String get settingsAlphaTitle => 'Batas atas positif palsu (α)';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return 'Saat ini $alpha% — makin rendah makin ketat, tetapi butuh lebih banyak sampel basis (minimal $required)';
  }

  @override
  String get abstentionHeadline => 'Bukti tidak cukup untuk menilai';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return 'Hanya $count kalimat yang bisa dianalisis, padahal dibutuhkan setidaknya $required. Pada panjang ini sinyal statistik dan per kalimat tidak berbobot, dan memaksakan skor darinya hanya akan menyesatkan.';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return 'Teks berisi $count kata, dibutuhkan setidaknya $required. Di bawah itu, ciri tulisan apa pun bisa jadi kebetulan.';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return 'Hanya $available dari $total mesin yang ikut, jadi tidak ada yang bisa diperiksa silang dari sudut lain. Lengkapi model yang hilang di manajemen model lalu jalankan lagi.';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return 'Antar-mesin berselisih $spread poin persen — cukup jauh sehingga merata-ratakannya kehilangan makna. Gunakan bukti per kalimat dan asal dokumen, lalu nilai sendiri.';
  }

  @override
  String get abstentionNoEvidenceFound =>
      'Semua mesin berjalan, tetapi tidak satu pun menemukan bukti yang dapat dipakai. Skor cadangan yang rendah adalah keluaran diagnostik, bukan bukti bahwa teks ditulis manusia.';

  @override
  String abstentionSingleWeakEvidenceSource(int count) {
    return 'Hanya $count mesin yang menemukan bukti yang dapat dipakai, dan skor keseluruhan masih di bawah ambang AI. Anggap ini cakupan yang lemah, bukan bukti bahwa teks ditulis manusia.';
  }

  @override
  String get abstentionScoreStillShown =>
      'Skor lengkap dan bukti per kalimat tetap ditampilkan di bawah sebagai rujukan. Mohon jangan diperlakukan sebagai kesimpulan.';

  @override
  String get provenanceTitle => 'Bukti asal dokumen';

  @override
  String get provenanceRiskHigh => 'Riwayat penyuntingan jelas tidak wajar';

  @override
  String get provenanceRiskMedium =>
      'Ada yang janggal pada riwayat penyuntingan';

  @override
  String get provenanceRiskLow => 'Riwayat penyuntingan tampak wajar';

  @override
  String get provenanceRiskUnknown => 'Tidak ada riwayat penyuntingan';

  @override
  String get provenanceNoMetadata =>
      'Masukan ini tidak membawa riwayat penyuntingan — teks tempelan, PDF, atau berkas yang catatannya sudah dihapus. Tidak ada yang bisa dinilai dari asal-usulnya, hanya analisis teksnya saja.';

  @override
  String provenanceEditingDuration(int minutes) {
    return 'Waktu penyuntingan yang tercatat: $minutes menit';
  }

  @override
  String provenanceRevisionCount(int count) {
    return 'Jumlah penyimpanan: $count kali';
  }

  @override
  String provenanceApplication(String name) {
    return 'Dibuat dengan: $name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return 'Isi dokumen hanya membawa $count penanda sesi penyuntingan untuk $words kata. Menulis sambil berpikir biasanya meninggalkan puluhan; sepekat ini umumnya berarti teks masuk sekaligus — misalnya ditempel.';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words kata berbanding $minutes menit penyuntingan tercatat menghasilkan $wpm kata per menit, jauh di atas yang bisa dipertahankan orang saat benar-benar menulis.';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return 'Berkas nyaris tidak mencatat waktu penyuntingan, padahal isinya $words kata.';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return 'Konten $words kata, hanya disimpan $count kali.';
  }

  @override
  String get provenanceCaveat =>
      'Perlu diketahui: catatan ini bisa dihapus atau direset — menyimpan sebagai berkas baru, mengonversi daring, mengekspor dari Google Dokumen, atau menyalin ke dokumen baru semuanya menolkannya. Jadi sinyal di sini adalah bukti pendukung, bukan kesimpulan tersendiri; dan ketiadaannya tidak membuktikan bahwa manusia yang menulisnya.';

  @override
  String get telemetrySummaryTitle => 'Ringkasan analisis';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return '$engines dari $total mesin sudah selesai. Probabilitas AI keseluruhan $percent%, sehingga masuk ke “$verdict”.';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return 'Antar-mesin cukup sepakat (tertinggi $high%, terendah $low%), jadi kesimpulan ini cukup kokoh.';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return 'Mesin-mesinnya berbeda pendapat: $highLabel memberi $high% sementara $lowLabel cuma $low%. Kalau begini, jangan cuma pegang skor total — bukti per kalimat di bawah jauh lebih memberi tahu.';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return 'Yang paling menarik skor ke atas adalah $label, sekitar $points poin persen.';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return 'Dari $total kalimat yang ditelusuri, tidak satu pun melewati garis sinyal AI yang kuat.';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return 'Dari $total kalimat, $count melewati garis sinyal AI yang kuat — layak dibaca satu per satu.';
  }

  @override
  String get telemetrySummaryAdviceHuman =>
      'Bacanya memang seperti tulisan orang sendiri, tidak ada yang perlu ditelusuri lebih jauh.';

  @override
  String get telemetrySummaryAdviceMixed =>
      'Yang ini ada di zona abu-abu. Menyimpulkan hanya dari skor terlalu berisiko — lihat bersama bukti per kalimat dan asal-usul dokumennya.';

  @override
  String get telemetrySummaryAdviceAi =>
      'Sinyalnya jelas mengarah ke hasil buatan atau tulisan ulang AI. Periksa kalimat yang ditandai satu per satu sebelum memutuskan.';

  @override
  String telemetrySummaryModelGap(int count) {
    return 'Selain itu ada $count mesin yang tidak ikut memilih kali ini, jadi tingkat keyakinannya perlu dikurangi sedikit; lengkapi di manajemen model lalu jalankan ulang agar lebih tajam.';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'Probabilitas AI < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'Probabilitas AI $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'Probabilitas AI ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return 'Keyakinan rendah: bobot model yang tersedia di bawah 60% (ambang batas $threshold%). $available/$total mesin berpartisipasi. Tinjau analisis mesin terperinci.';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return 'Keyakinan tinggi: $available/$total model deteksi mencapai konsensus (bobot $threshold% atau lebih setuju dengan putusan ini).';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return 'Keyakinan rendah ($available/$total)';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return 'Keyakinan tinggi ($available/$total)';
  }

  @override
  String get reportMetricAiSentenceRatio =>
      'Rasio kalimat dengan sinyal AI kuat';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count dari $total melewati ambang sinyal kuat 60%';
  }

  @override
  String get reportMetricElapsed => 'Waktu analisis';

  @override
  String get reportMetricElapsedNormal => '0,5-5 detik normal';

  @override
  String get reportMetricReliability => 'Keandalan';

  @override
  String get reportReliabilityLow => 'Rendah';

  @override
  String get reportReliabilityHigh => 'Tinggi';

  @override
  String get reportReliabilityNeedsReview => 'Perlu ditinjau';

  @override
  String get reportReliabilityHighTrust => 'Sangat andal';

  @override
  String get reportSentenceAnalysisTitle => 'Analisis tingkat kalimat';

  @override
  String get suspiciousFilterAll => 'Mencurigakan';

  @override
  String get suspiciousFilterHigh => 'Tinggi';

  @override
  String get suspiciousFilterMedium => 'Sedang';

  @override
  String get suspiciousExcludedTooltip =>
      'Huruf tunggal, nomor halaman, nomor bagian, dan fragmen OCR/PDF yang terlalu pendek telah dikecualikan.';

  @override
  String suspiciousCount(int count) {
    return '$count item';
  }

  @override
  String get suspiciousEmpty => 'Tidak ada konten mencurigakan';

  @override
  String get suspiciousRiskHigh => 'Tinggi';

  @override
  String get suspiciousRiskMedium => 'Sedang';

  @override
  String get suspiciousReasonHighModelSignals =>
      'Beberapa sinyal model sangat condong ke AI';

  @override
  String get suspiciousReasonSentenceSignal =>
      'Sinyal model tingkat kalimat meningkat';

  @override
  String suspiciousOriginalLocation(String location) {
    return 'Lokasi asli $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return 'Lokasi asli $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return 'Kalimat #$number';
  }

  @override
  String get suspiciousEvidenceLabel => 'Bukti:';

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
    return 'Sumber verifikasi: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'Periksa secara manual di Google Scholar';

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
    return 'Nama jurnal tidak cocok: dokumen menyatakan \"$reported\", sedangkan registri terverifikasi menyatakan \"$registered\". Harap tinjau kutipan ini.';
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
    return '$count selesai; hasil akan terus diperbarui.';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return 'Kemajuan $completed/$total, $current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return 'Saat ini: $text';
  }

  @override
  String get reportBibProgressFinalizing => 'Menyelesaikan hasil';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base: ditemukan kandidat serupa \"$candidate\", tetapi penulis, tahun, atau judul tidak memenuhi ambang batas kecocokan yang andal.';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base: sumber verifikasi tidak memberikan respons yang andal atau entri kekurangan informasi yang cukup; TruthLens tidak menganggap kutipan ini terverifikasi.';
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
    return 'Probabilitas AI keseluruhan melebihi ambang tetap $percent% dan ditandai sebagai AI.';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'Probabilitas AI keseluruhan di bawah ambang penandaan tetap $percent%.';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return 'Probabilitas AI keseluruhan adalah $aiPercent%, yang mencapai ambang batas penandaan AI tetap $thresholdPercent%, sehingga laporan menandai teks ini sebagai AI. Tinjau bukti tingkat kalimat dan alasan mesin sebelum membuat keputusan akhir.';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'Probabilitas AI keseluruhan adalah $aiPercent%, di bawah ambang batas penandaan AI tetap $thresholdPercent%, sehingga laporan tidak secara resmi menandai teks ini sebagai AI. Probabilitas dan bukti tetap ditampilkan untuk ditinjau.';
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
  String engineReasonBurstinessMid(String value) {
    return 'Variasi panjang kalimat (burstiness $value) tetap berada di pita netral 0,30–0,55';
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
  String engineReasonMattrNoAiSignal(String value, String cut) {
    return 'Keragaman kosakata (MATTR $value) tidak melewati batas sinyal AI terkalibrasi $cut';
  }

  @override
  String engineReasonStatisticalSummaryAi(String percent) {
    return 'Ringkasan statistik keseluruhan: Condong ke karakteristik yang dihasilkan AI (probabilitas AI $percent%)';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return 'Ringkasan statistik keseluruhan: Condong ke tulisan manusia alami (probabilitas AI $percent%)';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return 'Ringkasan statistik keseluruhan: Indikator seimbang, menunjukkan karakteristik netral (probabilitas AI $percent%)';
  }

  @override
  String get reportFormulaTitle =>
      'Transparansi Perhitungan Tertimbang & Rincian Parameter';

  @override
  String get reportFormulaExplanation =>
      'Probabilitas AI keseluruhan dihitung sebagai rata-rata tertimbang dari probabilitas semua mesin aktif:';

  @override
  String get reportFormulaActiveEngines =>
      'Mesin aktif & bobot yang ditetapkan';

  @override
  String get reportFormulaCalculation => 'Perhitungan rumus berbobot';

  @override
  String get reportFormulaFinalResult => 'Probabilitas AI Tertimbang Akhir';

  @override
  String get reportFormulaEslApplied =>
      'Penyesuaian penulisan non-native ESL diterapkan (bobot model statistik dibagi dua)';

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
  String get engineStatisticalPerplexityModule => 'Perpleksitas model bahasa';

  @override
  String get engineStatisticalLexicalModule => 'Sidik leksikal';

  @override
  String get engineStatisticalHeuristicModule => 'Statistik heuristik';

  @override
  String get engineStylometryRulesModule => 'Penanda gaya berbasis aturan';

  @override
  String get engineStylometryPan25Module => 'Sidik leksikal PAN 2025';

  @override
  String get engineStylometryDetectRlModule => 'Sidik karakter DetectRL-ZH';

  @override
  String get modelNameMbertMultilingual =>
      'Detektor multibahasa (EN+ZH · INT8)';

  @override
  String get modelNameTruthlensZh =>
      'Detektor Tionghoa TruthLens (generator 2026 · INT8)';

  @override
  String get modelNameAigcZhv3 =>
      'Detektor Tionghoa modern (DeepSeek/GPT-4 · INT8)';

  @override
  String get modelNameRobertaEn => 'Detektor RoBERTa (Inggris · ChatGPT)';

  @override
  String get modelNameQwenPpl =>
      'Model perpleksitas multibahasa (Qwen2.5-0.5B · INT8)';

  @override
  String get modelNameDistilgpt2Ppl => 'Model perpleksitas DistilGPT2 (INT8)';

  @override
  String get modelNameAdversarial => 'Detektor penulisan ulang (INT8)';

  @override
  String get modelErrorNoSource => 'Varian ini belum memiliki sumber unduhan.';

  @override
  String modelErrorStorageShort(String mb) {
    return 'Penyimpanan peramban tidak cukup — kurang sekitar $mb MB. Hapus model yang tidak diperlukan atau kosongkan ruang disk.';
  }

  @override
  String get modelErrorChecksum =>
      'Checksum tidak cocok — berkas mungkin rusak.';

  @override
  String get modelErrorTokenizerIncomplete =>
      'JSON tokenizer yang diunduh tidak lengkap atau koneksi terputus.';

  @override
  String modelErrorSizeMismatch(String got, String expected) {
    return 'Unduhan tidak lengkap: diterima $got MB, diharapkan sekitar $expected MB.';
  }

  @override
  String get modelErrorChunkAborted =>
      'Unduhan terputus di tengah blok dan percobaan ulang gagal.';

  @override
  String get modelErrorTokenizerInvalid => 'JSON tokenizer tidak valid.';

  @override
  String deviceCapabilitySummary(
    String platform,
    int cpu,
    String ram,
    String estimated,
    String tier,
  ) {
    return '$platform · $cpu CPU · $ram GB RAM$estimated · $tier';
  }

  @override
  String get deviceCapabilityEstimated => ' (perkiraan)';

  @override
  String engineReasonPan25LexicalAi(int percent) {
    return 'Sidik leksikal PAN 2025 condong ke AI ($percent/100); baseline bahasa Inggris independen ini mendeteksi distribusi kata dan frasa yang berbeda dari korpus manusianya';
  }

  @override
  String engineReasonPan25LexicalHuman(int percent) {
    return 'Sidik leksikal PAN 2025 condong ke manusia ($percent/100); ini tetap bukti dari model, bukan bukti kepengarangan';
  }

  @override
  String engineReasonPan25LexicalNeutral(int percent) {
    return 'Sidik leksikal PAN 2025 netral ($percent/100) dan tidak memberikan arah';
  }

  @override
  String engineReasonDetectRlZhAi(int percent) {
    return 'Sidik karakter Tionghoa DetectRL-ZH melewati gerbang bukti AI yang konservatif ($percent/100); sidik ini diuji secara independen terhadap DeepSeek-V3, teks campuran, terjemahan balik, perturbasi karakter, dan panjang yang bervariasi';
  }

  @override
  String engineReasonDetectRlZhNoAiSignal(int percent) {
    return 'Sidik karakter Tionghoa DetectRL-ZH tidak melewati gerbang bukti AI yang konservatif ($percent/100); ini adalah abstain, bukan bukti bahwa teks ditulis manusia';
  }

  @override
  String engineReasonCompressionCoherence(String value) {
    return 'Koherensi kompresi lintas batas ($value) melampaui saringan persentil ke-95 manusia PAN 2025 [sinyal lemah di sisi AI]';
  }

  @override
  String engineReasonAssistantResponseArtifact(int count) {
    return 'Terdeteksi $count artefak respons asisten percakapan, seperti menyapa pemohon atau menawarkan merevisi teks yang diminta';
  }

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
      'TruthLens adalah pendeteksi konten AI yang berjalan **sepenuhnya di dalam peramban Anda**. Empat mesin independen — pengklasifikasi neural Transformer, analisis ciri statistik, stilometri, dan deteksi penulisan ulang adversarial — memberi suara berbobot apakah teks dibuat AI, dan dokumen Anda tidak pernah meninggalkan perangkat.\n\nLaporan menyatakan putusannya sebagai probabilitas AI yang digolongkan ke lima rentang tetap (di bawah 20%, 20–40%, 40–60%, 60–80%, 80% ke atas), disertai bukti per kalimat, kontribusi tiap mesin, bukti asal dokumen, dan nama berkas saat mengimpor. Titik potongnya tidak dapat diubah, sehingga dokumen yang sama selalu jatuh di rentang yang sama. Bila buktinya tipis — kalimat atau kata terlalu sedikit, atau mesin terlalu berselisih — ia mengatakannya terus terang alih-alih memaksakan skor.';

  @override
  String get helpComparisonTitle => 'Perbandingan dengan alat terkemuka';

  @override
  String get helpComparisonDisclaimer =>
      'Perbandingan ini disusun dari informasi publik masing-masing alat dan persepsi pasar umum, hanya untuk referensi posisi fungsional — bukan data benchmark yang diverifikasi pihak ketiga.';

  @override
  String get helpVsGptZeroTitle => 'vs GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero mengerjakan sebagian besar prosesnya di awan dan mengharuskan unggah dokumen; keempat mesin TruthLens berjalan di peramban Anda sendiri dan isinya tidak dikirim ke mana pun.';

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
      'Originality.ai menagih per naskah lewat langganan dan mengharuskan unggah ke awan; TruthLens mengerjakan bagian intinya di peramban, tanpa langganan dan tanpa batas pemakaian.';

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
      'OCR gambar Winston AI mengunggah foto ke awan; OCR TruthLens mengutamakan server OCR lokal yang Anda siapkan, dan hanya beralih ke awan bila Anda sendiri memberikan kunci API Gemini — apakah awan terlibat sama sekali tetap keputusan Anda.';

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
      'Aplikasi selalu terbuka di layar utama. Pada peluncuran pertama, jika belum ada model deteksi yang terpasang, sebuah permintaan menanyakan apakah Anda ingin memilih satu — jika menolak, Anda dapat langsung menganalisis menggunakan mesin statistik dan stilistika. Anda dapat memeriksa, mengunduh, memperbarui, atau menghapus model kapan saja dari \"Pengaturan → Manajemen Model AI\". Aplikasi memeriksa versi terbaru saat diluncurkan dan menampilkan tanda pada ikon pengaturan serta entri \"Manajemen Model AI\" bila pembaruan tersedia.';

  @override
  String get helpWorkflowStep2Title => 'Memilih model (tujuan & dampak)';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'Pengklasifikasi AI multibahasa (bobot 40%): menganalisis blok paragraf terbatas untuk mempertahankan konteks, lalu memetakan probabilitas kembali ke kalimat sebagai bukti terperinci. Bila beberapa varian pengklasifikasi terpasang, setiap analisis memilih varian yang tervalidasi untuk bahasa dokumen — dokumen berbahasa Tionghoa memerlukan detektor Tionghoa modern khusus, dan aplikasi akan mengingatkan bila model tersebut belum ada.';

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
      'Anda dapat mengaktifkan/menonaktifkan mesin secara individual dan menyesuaikan bobot mesin di Pengaturan. Lima rentang putusan memakai titik potong tetap (20% / 40% / 60% / 80%) dan tidak dapat diubah, jadi dokumen yang sama memberi putusan yang sama bagi semua orang.';

  @override
  String get helpWorkflowStep3Title => 'Mengunggah dokumen';

  @override
  String get helpWorkflowStep3Body =>
      'Tiga cara memasukkan: tempel teks langsung, kenali gambar dengan OCR, atau impor dokumen (txt / md / pdf / docx / doc / odt). Impor PDF membandingkan dua pengurai lapisan teks dan membuang keluaran kacau; PDF pindaian dikenali per halaman bila OCR tersedia. Saat mengimpor, nama berkas muncul di bawah judul masukan dan pada barisnya sendiri di judul laporan; saat menempel atau mengetik, ia tetap kosong.\n\nOCR mengutamakan server lokal yang Anda siapkan dan hanya memakai awan bila Anda sendiri memberikan kunci API Gemini.';

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
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation => 'Pisahkan kode/rumus';

  @override
  String get helpWorkflowStep4ChipEnsemble => 'Ansambel 4 mesin';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'Progres langsung';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'Koreksi ESL';

  @override
  String get helpWorkflowStep4ChipStoppable => 'Dapat dihentikan kapan saja';

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
      'TruthLens berjalan sepenuhnya sebagai aplikasi web di tab browser Anda. Tidak ada yang perlu diinstal; teks dokumen dan hasil analisis tidak pernah meninggalkan perangkat Anda, dan model deteksi yang diunduh disimpan dalam cache hanya di penyimpanan sandbox browser Anda sendiri (OPFS), bukan di server mana pun.';

  @override
  String get privacyWebOverview2 =>
      'Halaman hanya membaca file, gambar, atau konten clipboard saat Anda secara aktif memilih untuk mengimpor, memindai, atau menempelkannya; halaman tidak pernah membaca tab lain, data situs lain, atau file yang belum Anda pilih.';

  @override
  String get privacySectionOverviewWeb => 'Ikhtisar';

  @override
  String get privacyRemoveWeb =>
      'menghapus data situs ini di pengaturan browser Anda (atau cukup menutup tab, karena tidak ada yang disimpan di server mana pun)';

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
      '4. Cadangan Web OCR: hanya pada versi web, OCR pertama-tama menggunakan server OCR lokal jika dikonfigurasi. Jika Anda memilih memasukkan kunci API Gemini, gambar yang dipilih dan halaman PDF yang dirender yang memerlukan OCR dikirim langsung dari browser Anda ke API Gemini Google; kunci hanya disimpan di penyimpanan lokal browser tersebut.';

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
  String get workspaceModeTooltip => 'Ganti mode ruang kerja';

  @override
  String get workspaceMoreMenuTooltip => 'Opsi lainnya';

  @override
  String get workspaceLanguageMenuTitle => 'Bahasa';

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
      'Persentase ini adalah sinyal AI kalimat itu sendiri, bukan putusan keseluruhan dokumen. Semakin tinggi berarti pola kata terlihat lebih dihasilkan AI; semakin rendah berarti lebih mirip tulisan manusia biasa. Laporan akhir menggabungkan setiap kalimat dengan pembobotan mesin.';

  @override
  String get workspaceSentenceSignalHeader => 'Sinyal AI per kalimat';

  @override
  String get workspaceSentenceColumnHeader => 'Kalimat';

  @override
  String get workspaceAiEvidenceIndexShort => 'indeks';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine tidak menemukan bukti kali ini, sehingga tidak ikut memilih (bobot peran $weight%). Artinya tidak ada jejak AI pada sumbunya sendiri — bukan berarti ia menilai teks ini ditulis manusia.';
  }

  @override
  String reportEngineRelationshipDirectionalOnly(String engine, int weight) {
    return '$engine hanya menemukan sinyal arah yang lemah. Sinyal ini didiskon untuk penyaringan dan tidak dihitung sebagai bukti yang lolos ambang (batas bobot peran $weight%).';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return 'Hanya $engine yang menemukan sesuatu; mesin lain tidak menemukan apa pun kali ini. Kesimpulan bertumpu pada satu jalur bukti saja, jadi sesuaikan tingkat keyakinannya.';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return '$count mesin lain berjalan tetapi tidak menemukan bukti, dan dikeluarkan dari pemungutan suara agar \'tidak ada yang dilaporkan\' tidak salah dihitung sebagai \'tampak ditulis manusia\'.';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      'Perpleksitas tidak diperhitungkan untuk dokumen ini: model perpleksitas (DistilGPT2) hanya dilatih pada bahasa Inggris, dan pada teks Tionghoa, Jepang, atau Korea ia mengukur keterdugaan byte, bukan keterdugaan bahasa. Diukur pada data berlabel, kemampuannya memisahkan tulisan manusia dari AI adalah 0%, jadi memperhitungkannya hanya akan menghasilkan positif palsu.';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return 'Basis per bahasa: $breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return 'Ada $count sampel lama tanpa penanda bahasa yang tidak dapat masuk ke basis bahasa mana pun — teks asli tidak disimpan, sehingga bahasanya tidak dapat dipulihkan kemudian. Sampel ini akan tergantikan seiring analisis baru.';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return 'Dokumen ini dialihkan ke \"$variant\": varian yang Anda pilih belum divalidasi untuk $language, sedangkan yang ini sudah.';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '\"$variant\" adalah model multibahasa tetapi belum divalidasi pada $language, jadi anggap skornya bukti yang lebih lemah daripada bahasa yang sudah divalidasi.';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '\"$variant\" tidak mencakup $language. Skornya hanya untuk rujukan dan tidak boleh dibaca sebagai bukti ke arah mana pun.';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      'Perpleksitas tidak diperhitungkan: bahasa dokumen ini tidak dapat ditentukan, jadi tidak ada ambang terkalibrasi untuk dibandingkan. Menebak bahasa berarti memakai skala yang salah — justru kesalahan yang ingin dicegah pemeriksaan ini.';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return 'Perpleksitas tidak diperhitungkan: model yang digunakan (\"$model\") belum memiliki ambang terukur untuk $language. Tanpa skala terkalibrasi, nilai mentahnya tidak bermakna, jadi diabaikan alih-alih ditebak.';
  }

  @override
  String get inputNoEditingRecordHint =>
      'Format ini tidak membawa catatan penyuntingan. PDF, gambar, dan teks yang ditempel tidak menyimpan riwayat cara penulisannya, sehingga analisis sepenuhnya bertumpu pada statistik teks. Jika Anda bisa memperoleh berkas .docx, .odt, atau .doc aslinya, riwayat suntingannya adalah bukti yang jauh lebih kuat — dan tidak seperti statistik teks, kekuatannya tidak menurun seiring membaiknya model bahasa.';

  @override
  String get reportLowScoreNotProofOfHuman =>
      'Skor rendah bukan konfirmasi bahwa tulisan ini dibuat manusia. Tanpa bukti asal-usul, putusan ini hanya bertumpu pada statistik teks, yang andal menandai tulisan berpola baku tetapi tidak menandai keluaran model masa kini yang ditulis dengan baik.';

  @override
  String get reportProvenanceContradictsLowScore =>
      'Catatan penyuntingan berkas ini bertentangan dengan skor rendah tersebut. Bukti asal-usul tidak melemah seiring membaiknya model bahasa, sedangkan statistik teks tidak dapat mengenali keluaran model masa kini yang ditulis dengan baik. Baca dahulu bukti asal-usul di bawah sebelum menyimpulkan apa pun dari skor di atas.';

  @override
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  ) {
    return '$paragraphs dari $total paragraf berada dalam satu batch penyuntingan dan memuat $percent% dari seluruh kata — sesuai dengan blok yang ditulis atau ditempel sekaligus, meskipun berkas ini memiliki batch penyuntingan lain.';
  }

  @override
  String findingEvasionDetected(int count) {
    return 'Ditemukan $count jejak penghindaran pada tingkat karakter (karakter lebar nol, huruf serupa, atau kontrol arah). Alat tulis biasa tidak menghasilkan ini — seseorang memproses teks untuk mengelabui deteksi.';
  }

  @override
  String findingCitationsNotFound(int notFound, int total) {
    return 'Dari $total karya yang dikutip, $notFound tidak ditemukan di basis data rujukan mana pun yang diperiksa. Kutipan fiktif adalah perilaku model bahasa, dan tidak seperti gaya tulisan, ada atau tidaknya sebuah makalah adalah fakta yang dapat diverifikasi.';
  }

  @override
  String findingCitationsAllVerified(int total) {
    return 'Seluruh $total karya yang dikutip ditemukan di basis data publik.';
  }

  @override
  String findingEditingRecordNormal(int minutes, int revisions) {
    return 'Berkas mencatat $minutes menit penyuntingan dalam $revisions kali penyimpanan, sesuai dengan teks yang ditulis di dokumen ini.';
  }

  @override
  String findingPublicationPredatesGenerativeAi(String doi, int year) {
    return 'DOI sumber $doi cocok dengan dokumen ini dan terdaftar pada $year, sebelum sistem penulisan AI generatif modern.';
  }

  @override
  String findingPublicationIdentityMismatch(String doi) {
    return 'DOI sumber $doi dapat ditemukan, tetapi judul terdaftarnya tidak cocok dengan dokumen ini. Verifikasi identitas dokumen sebelum mengandalkannya.';
  }

  @override
  String get integratedStabilityUnavailable =>
      'Stabilitas segmen tidak tersedia · tidak ada bukti tingkat kalimat yang memberi suara';

  @override
  String get integratedNeutralBaseline =>
      'Tidak ditemukan bukti khusus kepengarangan yang cukup kuat untuk dinaikkan tingkatnya. Hasil yang ditampilkan adalah penyaringan arah terbaik yang tersedia, bukan klaim bahwa bukti AI dan manusia seimbang.';

  @override
  String get reportVerifiableFindingsTitle => 'Yang dapat diverifikasi';

  @override
  String get reportVerifiableFindingsSubtitle =>
      'Setiap butir di bawah dapat diperiksa secara independen. Tidak seperti probabilitas, hal-hal ini tidak melemah seiring membaiknya model bahasa.';

  @override
  String findingBulkPaste(int characters) {
    return 'Saat teks diketik, tercatat satu kali tempel sebanyak $characters karakter. Model bahasa tidak dapat memalsukan cara teks muncul di editor — blok ini tidak diketik di sini.';
  }

  @override
  String findingWrittenInApp(int minutes, int deleted) {
    return 'Teks diketik di aplikasi ini selama $minutes menit, dengan $deleted karakter yang direvisi. Penulisan yang terjadi di sini meninggalkan jejak yang tidak dapat ditiru model bahasa mana pun.';
  }

  @override
  String get evidenceMatrixTitle => 'Penilaian multi-bukti';

  @override
  String get evidenceMatrixSubtitle =>
      'Enam sumbu ditampilkan terpisah. Hanya bukti khusus kepengarangan yang memengaruhi putusan; cakupan menunjukkan apa yang dapat diperiksa.';

  @override
  String evidenceMatrixCoverage(int available, int total) {
    return 'Cakupan bukti: $available dari $total sumbu';
  }

  @override
  String get evidenceAxisText => 'Jejak pembuatan teks';

  @override
  String get evidenceAxisTextNote =>
      'Pola probabilistik dari empat detektor lokal';

  @override
  String get evidenceAxisProcess => 'Proses penulisan';

  @override
  String get evidenceAxisProcessNote =>
      'Peristiwa pengetikan, revisi, dan tempel yang dicatat tanpa menyimpan isinya';

  @override
  String get evidenceAxisOrigin => 'Asal dokumen';

  @override
  String get evidenceAxisOriginNote =>
      'Waktu penyuntingan, jumlah penyimpanan, dan metadata DOCX/ODT/RSID';

  @override
  String get evidenceAxisSources => 'Integritas klaim dan sumber';

  @override
  String get evidenceAxisSourcesNote =>
      'Klaim yang dapat diperiksa, jangkar sitasi, dan verifikasi bibliografis';

  @override
  String get evidenceStateUnavailable => 'Tidak tersedia';

  @override
  String get evidenceStateInconclusive => 'Tidak konklusif';

  @override
  String get evidenceStateReassuring => 'Konsisten';

  @override
  String get evidenceStateConcern => 'Perlu ditinjau';

  @override
  String get evidenceStrengthNone => 'Tidak ada bukti';

  @override
  String get evidenceStrengthLimited => 'Terbatas';

  @override
  String get evidenceStrengthModerate => 'Sedang';

  @override
  String get evidenceStrengthStrong => 'Kuat';

  @override
  String get evidenceMatrixTextOnlyWarning =>
      'Hanya sumbu pola teks yang tersedia. AI generasi sekarang dapat meniru prosa manusia, sehingga laporan ini tidak dapat menetapkan kepengarangan hanya dari skor.';

  @override
  String get evidenceMatrixStrongConcern =>
      'Setidaknya satu sumbu independen memuat sinyal tinjauan yang kuat. Periksa bukti tersebut sebelum mengandalkan skor teks.';

  @override
  String findingUnsupportedClaims(int unsupported, int total) {
    return '$unsupported dari $total klaim yang dapat diperiksa memuat angka, perbandingan, atau rujukan penelitian tanpa jangkar sumber pada kalimat yang sama. Ini tidak membuktikan klaim itu salah, tetapi menandai klaim yang perlu diverifikasi lebih dulu.';
  }

  @override
  String get integratedAssessmentTitle => 'Penilaian kepengarangan terpadu';

  @override
  String get integratedInsufficientEvidence =>
      'Tidak ada sinyal kepengarangan yang terukur';

  @override
  String get integratedLikelyAi => 'Lebih mungkin dihasilkan AI';

  @override
  String get integratedLikelyMixed => 'Lebih mungkin campuran manusia dan AI';

  @override
  String get integratedLikelyHuman => 'Lebih mungkin bukan dihasilkan AI';

  @override
  String get integratedBalanced =>
      'Tidak terdeteksi sinyal yang jelas didominasi AI';

  @override
  String get integratedPreliminaryAi => 'Saat ini condong ke AI, dekat batas';

  @override
  String get integratedPreliminaryHuman =>
      'Saat ini condong ke manusia, dekat batas';

  @override
  String integratedLikelihoodLabel(int percent) {
    return 'Indeks bukti AI: $percent/100';
  }

  @override
  String get integratedLikelihoodUnavailable =>
      'Indeks bukti AI: tidak dapat diperkirakan';

  @override
  String integratedTextScoreLabel(int percent) {
    return 'Skor model teks: $percent%';
  }

  @override
  String integratedConfidenceLabel(String confidence) {
    return 'Keyakinan: $confidence';
  }

  @override
  String get integratedConfidenceLow => 'Rendah';

  @override
  String get integratedConfidenceModerate => 'Sedang';

  @override
  String get integratedConfidenceHigh => 'Tinggi';

  @override
  String integratedEvidenceSufficiency(int percent, String tier) {
    return 'Kecukupan bukti: $percent/100 · $tier';
  }

  @override
  String get integratedIncompleteModelWarning =>
      'Core text engines did not fully participate. This is a low-coverage screening result and should not be compared directly with a complete model analysis. Complete the recommended analysis models in Model Management; if they are already installed, check tokenizer support, missing files, or Web/ONNX Runtime compatibility.';

  @override
  String get integratedEvidenceTierScreening => 'penyaringan awal';

  @override
  String get integratedEvidenceTierReference => 'setingkat rujukan';

  @override
  String get integratedEvidenceTierStrong => 'didukung dengan baik';

  @override
  String integratedBoundaryAi(int index, int gap) {
    return 'Indeks $index hanya arah lemah di sisi AI dan masih $gap poin di bawah garis eskalasi 60 poin. Kepengarangan AI belum terbukti.';
  }

  @override
  String integratedBoundaryHuman(int index, int gap) {
    return 'Indeks $index condong ke manusia dan masih $gap poin di bawah garis eskalasi AI 60 poin, tetapi bukti yang terbatas tidak dapat menyingkirkan bantuan AI.';
  }

  @override
  String integratedEvidenceCoverage(int families, int coverage) {
    return 'Keluarga sinyal arah: $families/4 · cakupan keberlakuan $coverage%';
  }

  @override
  String get integratedEvidenceGatePassed => 'Gerbang bukti AI: lolos';

  @override
  String get integratedEvidenceGateNotPassed =>
      'Gerbang bukti AI: tidak lolos · hanya penyaringan arah';

  @override
  String integratedQualifiedWarning(String reason) {
    return '$reason Sistem tetap memberikan arah yang paling mungkin, tetapi keyakinannya berkurang; perlakukan sebagai hasil penyaringan, bukan bukti.';
  }

  @override
  String get integratedIndexCaveat =>
      'Gerbang bukti AI yang terpisah menunjukkan apakah dukungan independen cukup kuat untuk eskalasi. Kualitas sitasi, perilaku menempel, dan metadata mencurigakan tidak dapat menghasilkan putusan AI secara sendiri. Ini adalah skor bukti, bukan probabilitas statistik terkalibrasi.';

  @override
  String get reportTextEngineSignalExplanation =>
      'Batang ini menunjukkan sinyal diagnostik dari empat mesin teks. Mesin yang berkaitan digabungkan per keluarga, termasuk keluaran pengklasifikasi sisi manusia yang didiskon secara konservatif, sebelum keberlakuan bahasa/domain dan keandalan kalibrasi diterapkan. Arah menjawab penjelasan mana yang lebih didukung; gerbang bukti AI yang terpisah menjawab apakah dukungan itu cukup untuk eskalasi.';

  @override
  String reportSynthesisTextScoreContext(int percent) {
    return 'Skor mentah model teks empat mesin: $percent%. Ini satu masukan bagi penilaian terpadu, bukan putusan kedua.';
  }

  @override
  String reportSynthesisStrongestTextSignal(String label, int percent) {
    return 'Sinyal mesin teks terkuat: $label ($percent%). Sinyal ini dapat memengaruhi skor model teks, tetapi tidak dapat sendirian membatalkan penilaian terpadu.';
  }

  @override
  String composerTextScoreThresholdReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'Skor mentah model teks adalah $aiPercent%, mencapai penanda diagnostik $thresholdPercent%. Ini hanya pengamatan sinyal teks; penilaian terpadu di atas tetap menjadi arah kepengarangan laporan.';
  }

  @override
  String composerTextScoreThresholdNotReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'Skor mentah model teks adalah $aiPercent%, di bawah penanda diagnostik $thresholdPercent%. Tidak tercapainya penanda itu bukan bukti kepengarangan manusia; penilaian terpadu di atas tetap menjadi arah kepengarangan laporan.';
  }

  @override
  String telemetryIntegratedVerdict(
    String direction,
    int percent,
    String confidence,
  ) {
    return 'Setelah menimbang bukti yang tersedia, dokumen ini adalah \"$direction\" (indeks bukti AI $percent/100, keyakinan $confidence).';
  }

  @override
  String telemetryIntegratedUnavailable(String direction, String confidence) {
    return 'Modul yang tersedia tidak menghasilkan arah kepengarangan yang terukur (\"$direction\", keyakinan $confidence); tidak ada indeks numerik yang diterbitkan.';
  }

  @override
  String integratedStabilityLabel(int percent, int lower, int upper) {
    return 'Stabilitas segmen $percent% · rentang $lower–$upper%';
  }

  @override
  String integratedInputQualityLabel(int percent) {
    return 'Kualitas ekstraksi masukan: $percent%';
  }

  @override
  String integratedCalibrationLabel(String value, int count) {
    return 'Baseline lokal yang cocok: p=$value · n=$count';
  }

  @override
  String analysisReadinessLabel(String level) {
    return 'Dasar keyakinan pra-analisis: $level';
  }

  @override
  String get analysisReadinessShortText => 'perlu lebih banyak teks';

  @override
  String get analysisReadinessFewSentences => 'segmen terlalu sedikit';

  @override
  String get analysisReadinessCoreModel =>
      'pengklasifikasi inti tidak tersedia';

  @override
  String get analysisReadinessFewEngines => 'kurang dari dua mesin aktif';

  @override
  String get analysisReadinessExtraction => 'kualitas ekstraksi terbatas';

  @override
  String get analysisReadinessBaseline => 'tidak ada baseline lokal yang cocok';

  @override
  String get ocrChipLocalVerified => 'OCR lokal (terverifikasi)';

  @override
  String get ocrChipLocalUntested => 'OCR lokal (belum diuji)';

  @override
  String get ocrChipGeminiVerified => 'Gemini (terverifikasi)';

  @override
  String get ocrChipGeminiUntested => 'Gemini (belum diuji)';

  @override
  String get ocrChipNone => 'Mesin OCR: belum dikonfigurasi';

  @override
  String ocrErrorLocalServerReported(String detail) {
    return 'Server OCR lokal melaporkan galat: $detail';
  }

  @override
  String get ocrErrorLocalServerFormat =>
      'Server OCR lokal mengembalikan format respons yang tidak kompatibel; diharapkan larik blok teks, results[].text, atau text.';

  @override
  String get ocrErrorNoTextDetected =>
      'OCR selesai, tetapi tidak ada teks yang dapat digunakan pada gambar.';

  @override
  String ocrErrorLocalServerStatus(String status, String detail) {
    return 'Server OCR lokal merespons HTTP $status: $detail';
  }

  @override
  String ocrErrorLocalUnreachable(String detail) {
    return 'Tidak dapat menghubungi server OCR lokal, atau permintaan melampaui batas waktu: $detail';
  }

  @override
  String get ocrErrorNotConfigured =>
      'OCR belum disiapkan. Tambahkan kunci API Gemini di pengaturan, atau isi URL server OCR lokal.';

  @override
  String get ocrErrorGeminiNoParsableText =>
      'Gemini merespons, tetapi respons tidak memuat teks yang dapat dibaca.';

  @override
  String get ocrErrorGeminiRateLimited =>
      'Gemini OCR mencapai batas laju atau kuota (429). Coba lagi nanti, atau beralih ke server OCR lokal.';

  @override
  String ocrErrorGeminiBadRequest(String detail) {
    return 'Gemini OCR menolak permintaan (400): $detail';
  }

  @override
  String get ocrErrorGeminiUnauthorized =>
      'Kunci API Gemini tidak valid atau tidak diizinkan (401). Tempelkan kembali kunci yang valid.';

  @override
  String ocrErrorGeminiHttpFailed(String status, String detail) {
    return 'Gemini OCR gagal (HTTP $status): $detail';
  }

  @override
  String ocrErrorGeminiException(String detail) {
    return 'Gemini OCR tidak dapat terhubung atau mengurai respons: $detail';
  }

  @override
  String get ocrErrorNoImageData =>
      'Tidak ada data gambar yang diterima. Pilih ulang gambar; jika tetap gagal, peramban mungkin tidak menyediakan byte berkas.';

  @override
  String ocrErrorGeminiKeyInvalid(String status) {
    return 'Kunci API Gemini tidak valid atau tidak diizinkan (HTTP $status).';
  }

  @override
  String ocrErrorGeminiTestFailed(String status) {
    return 'Uji koneksi API Gemini gagal (HTTP $status).';
  }

  @override
  String ocrErrorGeminiTestException(String detail) {
    return 'Uji koneksi API Gemini gagal: $detail';
  }

  @override
  String get ocrErrorNativePluginNoPing =>
      'Plugin OCR bawaan pada platform ini tidak merespons ping.';

  @override
  String get ocrErrorNativePluginMissing =>
      'Tidak ada plugin OCR bawaan yang terdaftar pada platform ini.';

  @override
  String ocrErrorNativeCheckFailed(String detail) {
    return 'Pemeriksaan plugin OCR bawaan gagal: $detail';
  }

  @override
  String ocrErrorNativeFailed(String detail) {
    return 'OCR bawaan gagal: $detail';
  }

  @override
  String get settingsEngineLlmTitle => 'LLM penulis laporan';

  @override
  String get modelNameGemma2Llm => 'Gemma 2 · 2B Instruct (Q4_K_M)';

  @override
  String get firstRunModelListTitle => 'Model yang akan diunduh';

  @override
  String get firstRunModelOptionalReason =>
      'Opsional — hanya memengaruhi teks laporan, bukan hasil analisis';

  @override
  String get firstRunModelStorageReason =>
      'Mungkin tidak muat di penyimpanan peramban yang tersedia';

  @override
  String firstRunModelRamReason(String ramGb) {
    return 'Memerlukan RAM $ramGb GB — lebih besar daripada yang dilaporkan perangkat ini';
  }

  @override
  String firstRunModelSelectionSummary(int count, String size) {
    return '$count dipilih · total $size';
  }

  @override
  String get firstRunModelConfirm => 'Unduh yang dipilih';

  @override
  String get firstRunModelCancel => 'Batal';

  @override
  String get firstRunModelManualTitle => 'Mengunduh model nanti';

  @override
  String get firstRunModelManualBody =>
      'Anda dapat mengunduhnya kapan saja: buka Pengaturan (ikon roda gigi di bilah atas) lalu pilih «Manajemen Model AI». Sementara itu TruthLens tetap bekerja dengan mesin statistik dan stilistiknya.';

  @override
  String get commonGotIt => 'Mengerti';
}
