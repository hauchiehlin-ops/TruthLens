// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get commonCancel => 'ยกเลิก';

  @override
  String get commonDelete => 'ลบ';

  @override
  String get commonClose => 'ปิด';

  @override
  String commonCopyrightNotice(Object year) {
    return '© $year B&B出版 · E-mail: dr.cobra.lin@gmail.com';
  }

  @override
  String get verdictHuman => 'มนุษย์เขียน';

  @override
  String get verdictLikelyHuman => 'น่าจะเป็นมนุษย์';

  @override
  String get verdictMixed => 'เนื้อหาผสม';

  @override
  String get verdictLikelyAi => 'น่าจะเป็น AI';

  @override
  String get verdictAi => 'AI สร้างขึ้น';

  @override
  String get inputSubtitle =>
      'วางหรือพิมพ์ข้อความเพื่อตรวจจับเนื้อหาที่สร้างโดย AI';

  @override
  String get inputHint => 'พิมพ์หรือวางข้อความที่ต้องการวิเคราะห์…';

  @override
  String get inputHistoryTooltip => 'ประวัติ';

  @override
  String get inputHelpTooltip => 'คู่มือการใช้งาน';

  @override
  String get inputPrivacyTooltip => 'นโยบายความเป็นส่วนตัว';

  @override
  String get inputSettingsTooltip => 'การตั้งค่า';

  @override
  String get inputPasteButton => 'วาง';

  @override
  String get inputOcrButton => 'OCR รูปภาพ';

  @override
  String get inputImportButton => 'นำเข้าไฟล์';

  @override
  String get inputStartButton => 'เริ่มตรวจสอบ';

  @override
  String get inputClearTooltip => 'ล้างเนื้อหา';

  @override
  String get inputTooShortSnackbar =>
      'กรุณาป้อนข้อความอย่างน้อย 40 ตัวอักษรเพื่อการวิเคราะห์ที่น่าเชื่อถือ';

  @override
  String get inputOcrUnsupported =>
      'แพลตฟอร์มนี้ยังไม่รองรับการรู้จำข้อความด้วย OCR';

  @override
  String get inputOcrRecognizing => 'กำลังรู้จำ…';

  @override
  String get inputOcrNoText => 'ไม่พบข้อความในรูปภาพ';

  @override
  String inputOcrRecognized(int count) {
    return 'รู้จำได้ $count ตัวอักษร';
  }

  @override
  String inputImportNoText(String fileName) {
    return '\"$fileName\" ไม่มีเนื้อหาข้อความที่อ่านได้';
  }

  @override
  String inputImportSuccess(String fileName, int count) {
    return 'นำเข้า \"$fileName\" แล้ว（$count ตัวอักษร）';
  }

  @override
  String inputPdfOcrProgress(int page, int total) {
    return 'ไม่สามารถใช้เลเยอร์ข้อความ PDF ได้ กำลังจดจำหน้า $page จาก $total ด้วย OCR…';
  }

  @override
  String inputPdfOcrSuccess(String fileName, int count) {
    return 'นำเข้า \"$fileName\" ด้วย PDF OCR แล้ว（$count ตัวอักษร）';
  }

  @override
  String inputPdfNeedsOcr(String fileName) {
    return '\"$fileName\" ไม่มีเลเยอร์ข้อความที่เชื่อถือได้ กรุณาตั้งค่า Web OCR หรือใช้แอปที่ติดตั้งซึ่งรองรับ OCR ในตัว จากนั้นนำเข้าใหม่อีกครั้ง';
  }

  @override
  String inputPdfTooManyPages(String fileName, int max) {
    return '\"$fileName\" ต้องใช้ OCR แต่เกินขีดจำกัดความปลอดภัย $max หน้า กรุณาแบ่ง PDF แล้วนำเข้าทีละส่วน';
  }

  @override
  String inputPdfUnreadable(String fileName) {
    return 'ไม่สามารถอ่าน \"$fileName\" ได้อย่างน่าเชื่อถือ อาจเสียหาย มีรหัสผ่านป้องกัน หรือไม่รองรับโดยบริการ OCR ที่ตั้งค่าไว้';
  }

  @override
  String inputDocLegacyUnreadable(Object fileName) {
    return '\"$fileName\" เป็นไฟล์ .doc รุ่นเก่า ไม่สามารถดึงข้อความได้อย่างน่าเชื่อถือ กรุณาบันทึกเป็น .docx ใน Word หรือส่งออกเป็น PDF แล้วนำเข้าใหม่อีกครั้ง';
  }

  @override
  String inputActiveModel(String modelId) {
    return 'โมเดล: $modelId';
  }

  @override
  String get inputNoModel =>
      'ไม่ได้ติดตั้งโมเดล（ใช้เฉพาะการวิเคราะห์เชิงสถิติ/รูปแบบการเขียน）';

  @override
  String inputCharCount(int count) {
    return '$count ตัวอักษร';
  }

  @override
  String get analysisAppBarTitle => 'กำลังวิเคราะห์';

  @override
  String get analysisEngineTransformer => 'ตัวจำแนก Transformer';

  @override
  String get analysisEngineStatistical => 'การวิเคราะห์เชิงสถิติ';

  @override
  String get analysisEngineStylometry => 'การวิเคราะห์รูปแบบการเขียน';

  @override
  String get analysisEngineAdversarial => 'การป้องกันเชิงต่อต้าน';

  @override
  String analysisProgressSemantics(int done, int total) {
    return 'กำลังวิเคราะห์ เสร็จแล้ว $done จาก $total เอนจิน';
  }

  @override
  String get analysisDoneSemantics => 'เสร็จสิ้น';

  @override
  String analysisPreliminaryResult(int percent) {
    return 'ผลเบื้องต้น: ความน่าจะเป็น AI $percent%';
  }

  @override
  String analysisPreliminaryResultRefining(int percent) {
    return 'ผลเบื้องต้น: ความน่าจะเป็น AI $percent%（กำลังปรับแต่ง…）';
  }

  @override
  String get engineNameAdversarialFull =>
      'การป้องกันเชิงต่อต้าน（ตรวจจับการเขียนใหม่）';

  @override
  String get modelNecessityText =>
      'หากไม่ได้ดาวน์โหลดโมเดลตรวจจับแบบโครงข่ายประสาทเทียม TruthLens ยังคงทำงานได้ แต่จะใช้เพียงการวิเคราะห์เชิงสถิติและรูปแบบการเขียนเท่านั้น ซึ่งมีความแม่นยำและการรองรับหลายภาษาที่จำกัด หลังจากดาวน์โหลดโมเดลแล้ว ตัวจำแนก Transformer หลายภาษาจะเข้าร่วมการโหวตแบบรวมกลุ่ม ซึ่งจะเพิ่มความแม่นยำและความน่าเชื่อถือของการตัดสินอย่างมาก โมเดลทำงานบนอุปกรณ์ของคุณ และหลังจากดาวน์โหลดแล้วจะไม่มีการอัปโหลดเนื้อหาใดๆ';

  @override
  String get modelPromptTitle =>
      'แนะนำให้ดาวน์โหลดโมเดลตรวจจับเพื่อการวิเคราะห์ที่สมบูรณ์';

  @override
  String get modelPromptDontRemind => 'ไม่ต้องเตือนอีก';

  @override
  String get modelPromptSkip => 'ข้ามไปก่อน';

  @override
  String get modelPromptDownload => 'ไปที่การดาวน์โหลด';

  @override
  String get firstRunModelPromptTitle => 'เพิ่มโมเดลตรวจจับหรือไม่?';

  @override
  String get firstRunModelPromptBody =>
      'TruthLens ใช้งานได้อยู่แล้ว เอนจินเชิงสถิติและเชิงลีลาการเขียนพร้อมใช้งานทันที การเพิ่มโมเดลนิวรัลที่ทำงานบนเครื่องจะทำให้ตัวจำแนกหลายภาษาเข้าร่วมการโหวตแบบรวมกลุ่ม ซึ่งช่วยเพิ่มความแม่นยำและความครอบคลุมภาษาอย่างชัดเจน โมเดลทำงานภายในเบราว์เซอร์ของคุณทั้งหมดและไม่เคยอัปโหลดเอกสารของคุณ คุณเลือกภายหลังได้จาก \"การตั้งค่า → การจัดการโมเดล AI\"';

  @override
  String get firstRunModelPromptLater => 'ยังไม่ต้อง';

  @override
  String get firstRunModelPromptGo => 'เลือกโมเดล';

  @override
  String get modernChineseModelPromptTitle => 'ปรับปรุงการตรวจจับภาษาจีน';

  @override
  String get modernChineseModelPromptBody =>
      'ขณะนี้เอกสารภาษาจีนฉบับนี้ยังไม่มีตัวตรวจจับภาษาจีนสมัยใหม่ (ประมาณ 98 MB) โมเดลหลายภาษารุ่นเก่าถูกปรับเทียบด้วยข้อความรุ่นแรก ๆ และอาจพลาดงานเขียนภาษาจีนปัจจุบันในแบบ DeepSeek, Gemini และ GPT ดาวน์โหลดโมเดลเฉพาะทางที่ทำงานบนเครื่องเพื่อผลลัพธ์ที่ปรับเทียบดีกว่า หรือใช้ตัวสำรองข้ามภาษาที่อ่อนกว่าต่อไปก็ได้';

  @override
  String get onboardingWelcomeTitle => 'ยินดีต้อนรับสู่ TruthLens';

  @override
  String get onboardingHeadline => 'การตรวจจับเนื้อหา AI บนอุปกรณ์';

  @override
  String get onboardingDetectedDevice => 'อุปกรณ์ที่ตรวจพบ';

  @override
  String get onboardingChooseModel => 'เลือกโมเดลที่จะดาวน์โหลด';

  @override
  String get onboardingRecommendHint =>
      'ระบบได้ทำเครื่องหมาย \"แนะนำ\" ตามฮาร์ดแวร์ของคุณแล้ว คุณสามารถเลือกตัวเลือกอื่นได้เช่นกัน';

  @override
  String get onboardingBundleTitle => 'ข้อแนะนำสำหรับเครื่องนี้';

  @override
  String onboardingBundleSummary(int count, String size) {
    return '$count โมเดล · รวม $size MB';
  }

  @override
  String onboardingBundleStorage(String available, String remaining) {
    return 'พื้นที่จัดเก็บของเบราว์เซอร์: ใช้ได้ $available MB เหลือประมาณ $remaining MB หลังดาวน์โหลด';
  }

  @override
  String get onboardingStorageNotPersisted =>
      'โมเดลที่ดาวน์โหลดแล้วยังไม่ได้รับการป้องกันจากการล้างข้อมูลอัตโนมัติ หากพื้นที่ดิสก์เหลือน้อย เบราว์เซอร์อาจเรียกคืนพื้นที่และคุณจะต้องดาวน์โหลดใหม่ การติดตั้ง TruthLens เป็นแอปจะเพิ่มโอกาสที่เบราว์เซอร์จะเก็บโมเดลไว้อย่างมาก';

  @override
  String get onboardingInstallAppButton => 'ติดตั้งเป็นแอป';

  @override
  String get onboardingSkipButton =>
      'ไว้ทีหลัง（ใช้การวิเคราะห์เชิงสถิติ/รูปแบบการเขียนโดยไม่ใช้โมเดล）';

  @override
  String get onboardingSkipHint =>
      'แม้จะข้ามไปแล้ว คุณยังสามารถดาวน์โหลดได้ทุกเมื่อจาก \"การตั้งค่า → การจัดการโมเดล AI\" และจะมีการแจ้งเตือนอีกครั้งเมื่อใช้การวิเคราะห์ที่ต้องใช้โมเดล';

  @override
  String get modelListCustomImportedLabel => 'โมเดลที่นำเข้าแบบกำหนดเอง:';

  @override
  String get modelListActiveChip => 'กำลังใช้งาน';

  @override
  String get modelListRecommendedChip => 'แนะนำ';

  @override
  String get modelListCustomChip => 'กำหนดเอง';

  @override
  String modelListSizeLangRam(
    String size,
    String langs,
    int ram,
    String version,
  ) {
    return '$size · $langs · ต้องการ RAM ${ram}GB · v$version';
  }

  @override
  String modelListSizeTokenizerLabel(String size, String tokenizer, int index) {
    return 'ขนาด: $size · Tokenizer: $tokenizer · ดัชนีป้ายกำกับ AI: $index';
  }

  @override
  String modelListDownloadingProgress(
    int percent,
    String downloaded,
    String total,
  ) {
    return 'กำลังดาวน์โหลด… $percent%（$downloaded / $total）';
  }

  @override
  String modelListDownloadButton(String size) {
    return 'ดาวน์โหลด（$size）';
  }

  @override
  String get modelListComingSoonChip => 'เร็วๆ นี้';

  @override
  String get modelListSetActiveButton => 'ตั้งเป็นใช้งาน';

  @override
  String get modelListUpdateButton => 'อัปเดต';

  @override
  String get modelListDeleteTooltip => 'ลบ';

  @override
  String get modelListPageButton => 'หน้าโมเดล';

  @override
  String get modelListMayExceedMemory => 'อาจเกินหน่วยความจำของอุปกรณ์';

  @override
  String modelListFailedPrefix(String error) {
    return 'ล้มเหลว: $error';
  }

  @override
  String get modelCatalogLoadFailed => 'ไม่สามารถโหลดแคตตาล็อกโมเดลได้';

  @override
  String get modelCatalogEmpty => 'ไม่มีโมเดลที่ใช้งานได้';

  @override
  String modelDownloadPathChip(String label) {
    return 'เส้นทางดาวน์โหลด $label';
  }

  @override
  String get modelDownloadPathModelFile => 'ไฟล์โมเดล';

  @override
  String get modelDownloadPathCopied => 'คัดลอกเส้นทางดาวน์โหลดแล้ว';

  @override
  String settingsSaveFailed(String error) {
    return 'บันทึกการตั้งค่าไม่สำเร็จ: $error';
  }

  @override
  String get modelListDeleteConfirmTitle => 'ลบโมเดลหรือไม่?';

  @override
  String modelListDeleteConfirmBody(String name, String size) {
    return 'จะลบ \"$name\"（$size）คุณต้องดาวน์โหลดใหม่เพื่อใช้งานอีกครั้ง';
  }

  @override
  String modelListDeleteCustomConfirmBody(String name, String size) {
    return 'จะลบ \"$name\" ที่นำเข้าแบบกำหนดเอง（$size）คุณต้องนำเข้าใหม่เพื่อใช้งานอีกครั้ง';
  }

  @override
  String get modelImportAppBarTitle => 'นำเข้าโมเดล ONNX แบบกำหนดเอง';

  @override
  String get modelImportStep1Title => '1. เลือกไฟล์โมเดล ONNX';

  @override
  String modelImportSelectedFile(String name) {
    return 'เลือกแล้ว: $name';
  }

  @override
  String get modelImportNoFileSelected => 'ยังไม่ได้เลือกไฟล์โมเดล (.onnx)';

  @override
  String get modelImportBrowseButton => 'เรียกดู';

  @override
  String get modelImportCheckingDuplicate =>
      'กำลังตรวจสอบว่านำเข้าไฟล์เดียวกันไปแล้วหรือไม่…';

  @override
  String get modelImportDuplicateTitle =>
      'ตรวจพบโมเดลที่มีเนื้อหาเดียวกันถูกนำเข้าแล้ว';

  @override
  String modelImportDuplicateBody(String name, String role) {
    return 'ไฟล์นี้มีเนื้อหาเหมือนกับ \"$name\"（บทบาท: $role）ทุกประการ หากคุณต้องการเพียงเปลี่ยนโมเดลที่ใช้งาน สามารถไปที่ \"การจัดการโมเดล AI\" แล้วตั้งเป็นใช้งานได้โดยตรง ไม่จำเป็นต้องนำเข้าใหม่ คุณยังสามารถดำเนินการตามขั้นตอนด้านล่างต่อไปได้';
  }

  @override
  String get modelImportStep2Title => '2. ตั้งค่าพารามิเตอร์';

  @override
  String get modelImportNameLabel => 'ชื่อที่แสดงของโมเดล';

  @override
  String get modelImportNameRequired => 'ชื่อต้องไม่ว่างเปล่า';

  @override
  String get modelImportRoleLabel => 'บทบาทเอนจินเป้าหมาย';

  @override
  String get modelImportTokenizerTypeLabel => 'ประเภท Tokenizer';

  @override
  String get modelImportTokenizerBert => 'BERT (WordPiece)';

  @override
  String get modelImportTokenizerRoberta => 'RoBERTa (BPE)';

  @override
  String get modelImportTokenizerNone => 'ไม่มี（ไม่มี Tokenizer/ระดับตัวอักษร）';

  @override
  String get modelImportNoTokenizerSelected =>
      'ยังไม่ได้เลือกไฟล์ Tokenizer (.json)';

  @override
  String modelImportTokenizerSelected(String name) {
    return 'เลือกแล้ว: $name';
  }

  @override
  String get modelImportAiLabelIndexLabel => 'ดัชนีผลลัพธ์ป้ายกำกับ AI';

  @override
  String get modelImportIndex0 => 'ดัชนี 0（เช่น RoBERTa）';

  @override
  String get modelImportIndex1 => 'ดัชนี 1（เช่น DistilBERT）';

  @override
  String get modelImportStep3Title => '3. ทดสอบและตรวจสอบ';

  @override
  String get modelImportTestInputLabel => 'ข้อความทดสอบ';

  @override
  String get modelImportRunTestButton => 'รันการทดสอบการอนุมาน';

  @override
  String get modelImportResultLabel => 'ผลการอนุมาน（ความน่าจะเป็น AI）:';

  @override
  String modelImportTestFailed(String error) {
    return 'การทดสอบล้มเหลว: $error';
  }

  @override
  String get modelImportConfirmButton => 'ยืนยันการนำเข้าและเปิดใช้งานโมเดล';

  @override
  String get modelImportSelectTokenizerFirst => 'กรุณาเลือกไฟล์ Tokenizer ก่อน';

  @override
  String get modelImportSelectTokenizer => 'กรุณาเลือกไฟล์ Tokenizer';

  @override
  String get modelImportSuccessSnackbar =>
      'นำเข้าโมเดลสำเร็จแล้ว! ตั้งเป็นโมเดลที่ใช้งานโดยอัตโนมัติ';

  @override
  String get modelImportFailedSnackbar =>
      'นำเข้าโมเดลล้มเหลว กรุณาตรวจสอบสิทธิ์หรือบันทึกการทำงาน';

  @override
  String get settingsAppBarTitle => 'การตั้งค่า';

  @override
  String get settingsEslTitle =>
      'การปรับแก้ความเอนเอียงสำหรับผู้ไม่ใช่เจ้าของภาษา (ESL)';

  @override
  String get settingsEslSubtitle =>
      'เมื่อตรวจพบรูปแบบการเขียนของผู้ไม่ใช่เจ้าของภาษา จะลดน้ำหนักโมเดลเชิงสถิติโดยอัตโนมัติ';

  @override
  String get settingsEngineSectionTitle =>
      'การตั้งค่าเอนจินตรวจจับย่อย (Ensemble)';

  @override
  String get settingsEngineTransformerTitle =>
      'ตัวจำแนก AI หลายภาษา (Transformer)';

  @override
  String get settingsEngineTransformerSubtitle =>
      'ใช้โมเดลโครงข่ายประสาทเทียม Transformer เพื่อทำนายความน่าจะเป็น AI บนอุปกรณ์';

  @override
  String get settingsEngineStatisticalTitle =>
      'เอนจินวิเคราะห์เชิงสถิติ (Statistical)';

  @override
  String get settingsEngineStatisticalSubtitle =>
      'ตัดสินความสม่ำเสมอของภาษาผ่านความผันผวนของความยาวประโยค, Burstiness และ PPL';

  @override
  String get settingsEngineStylometryTitle =>
      'การวิเคราะห์รูปแบบการเขียน (Stylometry)';

  @override
  String get settingsEngineStylometrySubtitle =>
      'วิเคราะห์ความลื่นไหลของความหมาย รูปแบบประโยคซ้ำ และการใช้คำเชื่อม';

  @override
  String get settingsEngineAdversarialTitle =>
      'การตรวจจับการเขียนใหม่เชิงต่อต้าน (Adversarial)';

  @override
  String get settingsEngineAdversarialSubtitle =>
      'ตรวจจับว่าข้อความถูกเขียนใหม่โดยเครื่องหรือผ่านการลบร่องรอย AI หรือไม่';

  @override
  String get settingsEngineWeightsTitle => 'น้ำหนักโมเดล AI';

  @override
  String get settingsEngineWeightsSubtitle =>
      'กำหนดอิทธิพลของแต่ละเอนจินต่อผลรวม ยอดรวมต้องเท่ากับ 100% ก่อนบันทึก';

  @override
  String get settingsEngineInfoTooltip => 'หน้าที่ของเอนจินนี้';

  @override
  String get settingsEngineTransformerHelp =>
      'ประเมินบล็อกย่อหน้าที่คงบริบทด้วย Transformer หลายภาษา แล้วจับคู่คะแนนบล็อกกลับไปยังประโยคสำหรับรายงานโดยละเอียด น้ำหนักกำหนดอิทธิพล ส่วนสัญญาณ AI กำหนดผลต่อคะแนนจริง';

  @override
  String get settingsEngineStatisticalHelp =>
      'วัด perplexity ความคาดเดาได้ burstiness และความแปรผันของความยาวประโยค การแก้ไข ESL อาจลดน้ำหนักที่ใช้จริง';

  @override
  String get settingsEngineStylometryHelp =>
      'ตรวจลักษณะสำนวนที่อธิบายได้ เช่น การขึ้นต้นซ้ำ คำเชื่อมแบบสูตร และรายการมากเกินไป หากไม่พบ สัญญาณเป็น 0%';

  @override
  String get settingsEngineAdversarialHelp =>
      'ค้นหาข้อความ AI ที่ถูกเขียนใหม่หรือลบร่องรอย คะแนนต่ำหมายถึงหลักฐานตกค้างที่อ่อน ไม่ใช่ผลตรวจเชิงบวก';

  @override
  String settingsEngineWeightsTotalValid(int total) {
    return 'รวม: $total% — พร้อมบันทึก';
  }

  @override
  String settingsEngineWeightsTotalInvalid(int total) {
    return 'รวม: $total% — ปรับให้เท่ากับ 100%';
  }

  @override
  String get settingsEngineWeightsSave => 'บันทึกน้ำหนัก';

  @override
  String get settingsEngineWeightsSaved =>
      'บันทึกน้ำหนักโมเดล AI บนอุปกรณ์นี้แล้ว';

  @override
  String get settingsEngineWeightsRestoreDefaults => 'คืนค่าเริ่มต้น';

  @override
  String get engineReasonDisabledByUser => 'ผู้ใช้ปิดเอนจินนี้ในการตั้งค่า';

  @override
  String engineReasonTransformerNoStrongSentence(
    String model,
    int total,
    int percent,
  ) {
    return '$model: ไม่มีประโยคใดจาก $total ประโยคผ่านเกณฑ์ AI ระดับสูง สัญญาณอ่อนหลังปรับเทียบคือ $percent%';
  }

  @override
  String reportEngineSignalLabel(int percent) {
    return 'สัญญาณ AI $percent%';
  }

  @override
  String reportEngineDirectionalIndex(int percent) {
    return 'ทิศทางอ่อน $percent/100';
  }

  @override
  String get reportEngineNoDirectionalSignal => 'ไม่มีสัญญาณบอกทิศทาง';

  @override
  String get reportEngineSignalExplanation =>
      'สัญญาณ AI คือความน่าจะเป็นที่แต่ละเอนจินประเมินให้เอกสารนี้ น้ำหนักที่ตั้งไว้กำหนดอิทธิพล และคะแนนการมีส่วนร่วมจะถูกจัดสรรให้ผลรวมที่แสดงตรงกับความน่าจะเป็น AI โดยรวมพอดี ‘ไม่พบ’ หมายถึงต่ำกว่าเกณฑ์สัญญาณชัดเจน 60% ไม่ได้หมายความว่าค่าต้องเป็นศูนย์';

  @override
  String engineReasonAdversarialNoStrongSentence(int total, int percent) {
    return 'ไม่มีประโยคใดจาก $total ประโยคเกินเกณฑ์สัญญาณการถอดความที่ชัดเจน สัญญาณอ่อนหลังการปรับเทียบคือ $percent%';
  }

  @override
  String engineReasonAdversarialStrongSentences(
    int count,
    int total,
    int percent,
  ) {
    return '$count จาก $total ประโยคเกินเกณฑ์สัญญาณการถอดความที่ชัดเจน สัญญาณเอกสารหลังการปรับเทียบคือ $percent%';
  }

  @override
  String get settingsLinkVerificationTitle =>
      'การตรวจสอบความถูกต้องของลิงก์และบรรณานุกรม';

  @override
  String get settingsLinkVerificationSubtitle =>
      'รายงานจะเชื่อมต่อเพื่อตรวจสอบว่า URL และรายการบรรณานุกรมที่ตรวจพบในเอกสารมีอยู่จริงหรือไม่（เนื้อหาที่สร้างโดย AI มักมีการอ้างอิงที่ดูสมเหตุสมผลแต่ไม่มีอยู่จริง） ลิงก์วิชาการรูปแบบ DOI และบรรณานุกรมรูปแบบ \"ผู้แต่ง—ปี\" ที่ไม่มีลิงก์ จะถูกตรวจสอบกับข้อมูลทะเบียนสาธารณะของ Crossref ทั้งคู่ โมเดลตรวจจับ AI หลักยังคงทำงานบนอุปกรณ์ทั้งหมด และไม่ส่งเนื้อหาเอกสาร การเชื่อมต่อใช้เพียงเพื่อการตรวจสอบนี้และการตรวจสอบการอัปเดตโมเดลเท่านั้น และสามารถปิดได้ที่นี่';

  @override
  String get settingsThemeTitle => 'ธีมการแสดงผล';

  @override
  String get settingsLanguageTitle => 'ภาษา';

  @override
  String get settingsLanguageSubtitle => 'เลือกภาษาที่แสดงในแอป';

  @override
  String get settingsModelManagementTitle => 'การจัดการโมเดล AI';

  @override
  String get settingsModelManagementSubtitle =>
      'ดาวน์โหลดโมเดลตรวจจับและ LLM สำหรับสร้างรายงานเพื่อเปิดใช้ความสามารถการอนุมานแบบเต็มรูปแบบ';

  @override
  String get settingsModelManagementUpdateSubtitle =>
      'ตรวจพบการอัปเดตโมเดล แนะนำให้เข้าไปดู';

  @override
  String get settingsOpenButton => 'เปิด';

  @override
  String get settingsCustomImportTitle =>
      'นำเข้าและทดสอบโมเดล ONNX แบบกำหนดเอง';

  @override
  String get settingsCustomImportSubtitle =>
      'นำเข้าโมเดล ONNX และการตั้งค่า Tokenizer แบบกำหนดเองในเครื่อง แล้วทำการทดสอบการอนุมาน';

  @override
  String get modelImportWebUnsupported =>
      'การนำเข้าโมเดลกำหนดเองยังไม่รองรับในเวอร์ชันเว็บ กรุณาใช้เวอร์ชันแอป';

  @override
  String get settingsModelManagerAppBarTitle => 'การจัดการโมเดล AI';

  @override
  String get settingsImportTooltip => 'นำเข้าโมเดล ONNX ในเครื่อง';

  @override
  String settingsDeviceLabel(String summary) {
    return 'อุปกรณ์: $summary';
  }

  @override
  String get historyAppBarTitle => 'ประวัติ';

  @override
  String get historyClearAllTooltip => 'ล้างทั้งหมด';

  @override
  String get historySearchHint => 'ค้นหาประวัติ…';

  @override
  String get historyUntitledDocument => 'เอกสารไม่มีชื่อ';

  @override
  String get historyDeletedSnackbar => 'ลบรายการนี้แล้ว';

  @override
  String get historyClearAllTitle => 'ล้างประวัติทั้งหมดหรือไม่?';

  @override
  String historyClearAllBody(int count) {
    return 'จะลบรายการทั้งหมด $count รายการ การกระทำนี้ไม่สามารถย้อนกลับได้';
  }

  @override
  String get historyClearButton => 'ล้าง';

  @override
  String get historyDeleteEntryTitle => 'ลบรายการนี้หรือไม่?';

  @override
  String get historyReanalyzeTooltip => 'วิเคราะห์ใหม่';

  @override
  String get historyEmptyDefault => 'ยังไม่มีประวัติการตรวจจับ';

  @override
  String historyEmptySearch(String query) {
    return 'ไม่พบรายการที่ตรงกับ \"$query\"';
  }

  @override
  String historyEntrySemantics(
    String verdict,
    int percent,
    String time,
    String text,
  ) {
    return '$verdict, ความน่าจะเป็น AI $percent%, $time. $text';
  }

  @override
  String get reportAppBarTitle => 'รายงานการตรวจจับ';

  @override
  String get reportExportTooltip => 'ส่งออกรายงาน';

  @override
  String get reportHomeTooltip => 'กลับหน้าหลัก';

  @override
  String get reportGeneratingTitle => 'กำลังสร้างรายงาน…';

  @override
  String get reportSourceLlm => 'รายงานที่สร้างโดย AI';

  @override
  String get reportSourceTemplate => 'รายงานที่สร้างจากเทมเพลต';

  @override
  String reportSentenceSummary(int total, int ai, int human, String seconds) {
    return 'รวม $total ประโยค · น่าจะเป็น AI $ai ประโยค · น่าจะเป็นมนุษย์ $human ประโยค · ใช้เวลา $seconds วินาที';
  }

  @override
  String get reportExportPdf => 'ส่งออกรายงาน PDF';

  @override
  String get reportExportCsv => 'ส่งออกข้อมูล CSV';

  @override
  String get reportExportJson => 'ส่งออก JSON（สำหรับเชื่อมต่อระบบ）';

  @override
  String get reportExportPng => 'ส่งออกการ์ดสรุป（PNG）';

  @override
  String reportExported(String path) {
    return 'ส่งออกแล้ว: $path';
  }

  @override
  String reportExportFailed(String error) {
    return 'ส่งออกล้มเหลว: $error';
  }

  @override
  String get reportEngineWeightLabel => 'น้ำหนัก';

  @override
  String get privacySealNoticeText =>
      'ตราประทับความเป็นส่วนตัว 100% บนเครื่อง TruthLens: ประมวลผลบนอุปกรณ์โดยไม่มีการบันทึกบนคลาวด์';

  @override
  String get reportModelCalibrationTitle => 'การปรับเกณฑ์มาตรฐานโมเดลอัตโนมัติ';

  @override
  String get reportCommunityDiscoveredTag => 'โมเดลชุมชน (HuggingFace)';

  @override
  String get reportEngineBreakdownTitle => 'รายละเอียดเครื่องมือ';

  @override
  String get reportEngineNotInstalled => 'ยังไม่ได้ติดตั้ง';

  @override
  String get reportEngineLoadFailedBadge => 'โหลดล้มเหลว';

  @override
  String get reportEngineAnalysisLevelTitle => 'ชั้นการวิเคราะห์เอนจิน';

  @override
  String get reportVerdictAiLikelihood => 'แนวโน้ม AI';

  @override
  String get reportVerdictHumanLikelihood => 'การเขียนของมนุษย์';

  @override
  String get reportRadarRoleTransformer => 'ตัวจำแนก Transformer';

  @override
  String get reportRadarRoleStatistical => 'การวิเคราะห์ทางสถิติ';

  @override
  String get reportRadarRoleStylometry => 'การวิเคราะห์โวหาร';

  @override
  String get reportRadarRoleAdversarial => 'การป้องกันเชิงปรปักษ์';

  @override
  String get reportRadarAxisTransformer => 'ตัวจำแนกประโยค';

  @override
  String get reportRadarAxisStatistical => 'ความสม่ำเสมอของภาษา';

  @override
  String get reportRadarAxisStylometry => 'รูปแบบการเขียน';

  @override
  String get reportRadarAxisAdversarial => 'การป้องกันการเขียนใหม่';

  @override
  String get reportVerdictBadgeTitle => 'คำตัดสินโดยรวม';

  @override
  String reportVerdictBadgeProbability(int percent) {
    return 'ความน่าจะเป็น AI โดยรวม $percent%';
  }

  @override
  String get reportVerdictHintHuman =>
      'สัญญาณจากเอนจินส่วนใหญ่โน้มเอียงไปทางการเขียนของมนุษย์ตามธรรมชาติ';

  @override
  String get reportVerdictHintLikelyHuman =>
      'โดยรวมโน้มเอียงไปทางมนุษย์ โดยยังมีความไม่แน่นอนของโมเดลเหลืออยู่เล็กน้อย';

  @override
  String get reportVerdictHintMixed =>
      'สัญญาณจากเอนจินมีความหลากหลาย ควรอ่านการวิเคราะห์โดยละเอียดควบคู่กับผลลัพธ์นี้';

  @override
  String get reportVerdictHintLikelyAi =>
      'ตัวชี้วัดหลายตัวโน้มเอียงไปทาง AI แนะนำให้ตรวจสอบส่วนที่มีคะแนนสูง';

  @override
  String get reportVerdictHintAi =>
      'สัญญาณโดยรวมโน้มเอียงไปทาง AI สร้างขึ้นหรือเขียนใหม่อย่างมาก';

  @override
  String reportSynthesisOverall(String verdict, int percent) {
    return 'คำตัดสินโดยรวม: $verdict ความน่าจะเป็น AI โดยรวม $percent%';
  }

  @override
  String reportSynthesisStrongestSignal(String label, int percent) {
    return 'สัญญาณเดี่ยวที่แข็งแกร่งที่สุด: $label（$percent%）แต่ผลลัพธ์สุดท้ายรวมน้ำหนักของทุกเอนจินเข้าด้วยกัน ไม่ใช่ข้อสรุปจากเอนจินเดียว';
  }

  @override
  String reportSynthesisStrongestContribution(String label, int points) {
    return 'การมีส่วนร่วมแบบถ่วงน้ำหนักสูงสุดในขณะนี้มาจาก $label（ประมาณ $points จุดเปอร์เซ็นต์）';
  }

  @override
  String get reportSynthesisStyleCaveat =>
      '\"ไม่พบรูปแบบการเขียนของ AI ที่ชัดเจน\" หมายความเพียงว่าเอนจินด้านรูปแบบไม่พบรูปแบบประโยคตายตัวหรือคำเชื่อมที่ตายตัว โมเดลอื่นยังอาจเพิ่มคะแนนโดยรวมผ่านความสม่ำเสมอของภาษา การจำแนกประโยค หรือสัญญาณการเขียนใหม่';

  @override
  String get reportSynthesisModelGap =>
      'เมื่อบางเอนจินไม่ได้เข้าร่วม ให้ใช้ \"เติมโมเดลวิเคราะห์ที่แนะนำให้ครบ\" ในการจัดการโมเดลก่อน หากยังล้มเหลว การวิเคราะห์โดยละเอียดจะระบุว่าสาเหตุคือโมเดลขาดหาย tokenizer ที่ไม่รองรับ ไฟล์ขาดหาย หรือข้อจำกัดความเข้ากันได้ของ Web/ONNX Runtime';

  @override
  String reportEngineRelationshipUnavailable(String label, String hint) {
    return '$label ไม่ได้เข้าร่วมการโหวตแบบถ่วงน้ำหนักนี้ จึงแสดงมิตินี้เป็น 0% $hint';
  }

  @override
  String reportEngineRelationshipAvailable(
    int weight,
    int points,
    String variantText,
  ) {
    return 'น้ำหนักบทบาท $weight% มีส่วนสนับสนุนคะแนนโดยรวมประมาณ $points จุดเปอร์เซ็นต์$variantText';
  }

  @override
  String reportEngineVariantMerged(int count) {
    return '（รวม $count รูปแบบโมเดล）';
  }

  @override
  String reportEngineFallbackUnavailable(String label) {
    return '$label ไม่ได้เข้าร่วมการโหวตนี้';
  }

  @override
  String reportEngineFallbackAvailable(String label) {
    return '$label ไม่ได้ส่งคืนคำอธิบายข้อความเพิ่มเติม';
  }

  @override
  String get reportEngineResolutionTransformer =>
      'วิธีแก้ไข: ดาวน์โหลดและเปิดใช้งาน Transformer หลายภาษาในการจัดการโมเดล หากดาวน์โหลดแล้ว กรุณาดาวน์โหลดโมเดลและ tokenizer ใหม่';

  @override
  String get reportEngineResolutionAdversarial =>
      'วิธีแก้ไข: ดาวน์โหลดโมเดลตรวจจับการเขียนใหม่และ tokenizer ใหม่ในการจัดการโมเดล ในเว็บกรุณาอัปเดตเป็นเวอร์ชันที่แก้ไขความเข้ากันได้ของ BigInt แล้ววิเคราะห์อีกครั้ง';

  @override
  String reportEngineReasonBigInt(String reason) {
    return '$reason สาเหตุ: ONNX Runtime บนเว็บส่งคืนเทนเซอร์ BigInt ที่บริดจ์รุ่นเก่าไม่สามารถแปลงได้ กรุณาอัปเดตเป็นเวอร์ชันที่แก้ไขแล้วและวิเคราะห์อีกครั้ง';
  }

  @override
  String reportEngineReasonTokenizer(String reason) {
    return '$reason วิธีแก้ไข: เปลี่ยนไปใช้โมเดลจากแคตตาล็อก หรือดาวน์โหลดโมเดลและ tokenizer ใหม่';
  }

  @override
  String reportEngineReasonNoActiveTransformer(String reason) {
    return '$reason วิธีแก้ไข: เปิดการจัดการโมเดล แตะ \"เติมโมเดลวิเคราะห์ที่แนะนำให้ครบ\" และยืนยันว่า Transformer หลายภาษาถูกทำเครื่องหมายว่าใช้งานอยู่';
  }

  @override
  String get reportDetailAnalysisTitle => 'การวิเคราะห์โดยละเอียด';

  @override
  String get reportNoEngineData => 'ไม่มีข้อมูลเอนจิน';

  @override
  String get ocrGeminiKeyRequired => 'กรุณาใส่คีย์ Gemini API ก่อน';

  @override
  String get ocrGeminiKeyValid => 'คีย์ Gemini API ถูกต้องและเชื่อมต่อได้';

  @override
  String get ocrGeminiKeyUnreachable =>
      'เชื่อมต่อ Gemini API ไม่ได้ กรุณาตรวจสอบคีย์';

  @override
  String get ocrStatusLocalUnset => 'OCR ในเครื่อง: ยังไม่ได้ตั้งค่าปลายทาง';

  @override
  String get ocrStatusLocalUntested =>
      'OCR ในเครื่อง: ตั้งค่าแล้ว ยังไม่ได้ทดสอบ';

  @override
  String get ocrStatusLocalTesting => 'OCR ในเครื่อง: กำลังทดสอบการเชื่อมต่อ';

  @override
  String get ocrStatusLocalReady => 'OCR ในเครื่อง: พร้อมใช้งาน';

  @override
  String get ocrStatusLocalUnreachable => 'OCR ในเครื่อง: เชื่อมต่อไม่ได้';

  @override
  String get ocrStatusGeminiUnset => 'Gemini: ยังไม่ได้ตั้งคีย์';

  @override
  String get ocrStatusGeminiUntested => 'Gemini: ตั้งคีย์แล้ว ยังไม่ได้ทดสอบ';

  @override
  String get ocrStatusGeminiVerifying => 'Gemini: กำลังตรวจสอบคีย์';

  @override
  String get ocrStatusGeminiValid => 'Gemini: คีย์ถูกต้อง';

  @override
  String get ocrStatusGeminiInvalid => 'Gemini: ไม่ถูกต้องหรือเชื่อมต่อไม่ได้';

  @override
  String get ocrActiveLocalVerified =>
      'เอนจินที่ใช้งาน: เซิร์ฟเวอร์ OCR ในเครื่อง (ทดสอบแล้ว)';

  @override
  String get ocrActiveLocalUntested =>
      'เอนจินที่ใช้งาน: เซิร์ฟเวอร์ OCR ในเครื่อง (ยังไม่ได้ทดสอบ)';

  @override
  String get ocrActiveGeminiVerified =>
      'เอนจินที่ใช้งาน: Gemini API (ทดสอบแล้ว)';

  @override
  String get ocrActiveGeminiUntested =>
      'เอนจินที่ใช้งาน: Gemini API (ยังไม่ได้ทดสอบ)';

  @override
  String get ocrActiveNone => 'ยังไม่ได้ตั้งค่าเอนจิน OCR';

  @override
  String get ocrDetectAndDownload => 'ตรวจหาระบบและดาวน์โหลดตัวติดตั้ง';

  @override
  String get ocrAutoInstallUnavailable => 'ไม่สามารถติดตั้งอัตโนมัติได้';

  @override
  String get ocrUnsupportedPlatformBody =>
      'แพลตฟอร์มปัจจุบันไม่รองรับการติดตั้งบนเดสก์ท็อปแบบคลิกเดียว เว็บเบราว์เซอร์ไม่สามารถติดตั้งและเริ่มบริการ OCR ในเครื่องบน iOS, Android, Linux หรือระบบที่ไม่รู้จักได้\n\nทางเลือก:\n1. ใช้ตัวช่วยนี้จากเบราว์เซอร์เดสก์ท็อป macOS หรือ Windows\n2. ใช้คีย์ Gemini API เป็นตัวสำรองสำหรับ Web OCR\n3. ผู้ใช้ขั้นสูงสามารถเปิดโปรเจกต์ OCR ตั้งปลายทาง /ocr ที่รองรับเอง แล้วกรอก URL ที่นี่';

  @override
  String ocrInstallerReady(String osName) {
    return 'ตัวติดตั้งสำหรับ $osName พร้อมแล้ว';
  }

  @override
  String get ocrRunInstructionMac => 'bash ~/Downloads/setup_and_run_ocr.sh';

  @override
  String get ocrRunInstructionWindows =>
      'ดับเบิลคลิก setup_and_run_ocr.bat ในโฟลเดอร์ Downloads';

  @override
  String ocrAssistantDownloadedBody(
    String osName,
    String endpoint,
    String fileName,
    String runInstruction,
    String testButton,
  ) {
    return 'ตรวจพบ $osName และกรอกปลายทางในเครื่องให้อัตโนมัติแล้ว:\n$endpoint\n\nเบราว์เซอร์เริ่มดาวน์โหลด $fileName แล้ว ด้วยข้อจำกัดด้านความปลอดภัยของเบราว์เซอร์ TruthLens Web ไม่สามารถรันตัวติดตั้งหรือแก้ไขการตั้งค่าเริ่มระบบแทนคุณได้\n\nขั้นตอนถัดไป:\n1. รันตัวติดตั้งที่ดาวน์โหลด: $runInstruction\n2. รอจนเทอร์มินัลหรือหน้าต่างแจ้งว่าบริการ OCR พร้อมแล้ว\n3. กลับมาที่นี่แล้วเลือก \"$testButton\"\n\nเมื่อทดสอบสำเร็จ OCR รูปภาพจะใช้บริการในเครื่องนี้ก่อน รูปภาพจะไม่ถูกส่งไปยัง Gemini เว้นแต่คุณตั้งค่าคีย์ Gemini API เป็นตัวสำรองด้วย';
  }

  @override
  String get reportEngineNotParticipated => 'ไม่ได้เข้าร่วม';

  @override
  String get reportAiContentReportTitle => 'รายงานการตรวจจับเนื้อหา AI';

  @override
  String reportAnalysisTimeLabel(String time) {
    return 'เวลาวิเคราะห์: $time';
  }

  @override
  String get reportDownloadPdfButton => 'ดาวน์โหลด PDF';

  @override
  String get reportSuspiciousLocationsTitle => 'ตำแหน่งเนื้อหาที่น่าสงสัย';

  @override
  String reportSentenceCount(int count) {
    return '$count ประโยค';
  }

  @override
  String get reportAiProbabilityPrefix => 'ความน่าจะเป็น AI: ';

  @override
  String get helpAdvantage5 =>
      'การพิสูจน์ที่มาของเอกสาร: อ่านบันทึกการแก้ไขภายในไฟล์ .docx / .odt / .doc ได้แก่ เวลาที่ใช้ จำนวนครั้งที่บันทึก และการกระจายของรอบแก้ไข หลักฐานนี้เป็นอิสระจากการตัดสินตัวข้อความ และแสดงแยกจากความน่าจะเป็น AI ส่วน PDF และรูปภาพไม่มีประวัติการแก้ไขของตัวเอง จึงให้หลักฐานแบบนี้ไม่ได้';

  @override
  String get helpAdvantage6 =>
      'เมื่อหลักฐานบาง ระบบจะงดตัดสินอย่างซื่อตรง: ประโยคที่วิเคราะห์ได้น้อยกว่า 5 ประโยค เนื้อหาน้อยกว่า 100 คำ เอนจินร่วมน้อยกว่า 2 ตัว หรือเอนจินต่างกันเกิน 60 จุดเปอร์เซ็นต์ ล้วนทำให้ขึ้นว่า «หลักฐานไม่พอที่จะตัดสิน» การกล่าวหาผิดส่วนใหญ่เริ่มจากการคืนตัวเลขอย่างมั่นใจให้กับข้อมูลที่อ่อนเกินไป';

  @override
  String get settingsAiSampleTitle => 'เพิ่มตัวอย่างที่ AI สร้าง';

  @override
  String get settingsAiSampleSubtitle =>
      'การปรับเทียบเบื้องหลังจะเก็บเฉพาะตัวอย่างของคนโดยอัตโนมัติ หากต้องการเปิดใช้น้ำหนักเอนจินจากการเรียนรู้ ยังต้องมีงานเขียนที่รู้แน่ว่า AI สร้างด้วย เพียงวางหรือนำเข้า ระบบจะวิเคราะห์และบันทึกเป็นตัวอย่าง AI ทันที';

  @override
  String get settingsAiSampleFromClipboard => 'วางจากคลิปบอร์ด';

  @override
  String get settingsAiSampleFromFile => 'นำเข้าเอกสาร';

  @override
  String get settingsAiSampleAnalyzing => 'กำลังวิเคราะห์…';

  @override
  String settingsAiSampleAdded(int count) {
    return 'เพิ่มตัวอย่าง AI แล้ว รวม $count ชิ้น';
  }

  @override
  String get settingsAiSampleTooShort =>
      'สั้นเกินกว่าจะใช้เป็นตัวอย่าง (ต้องมีอย่างน้อย 100 คำ)';

  @override
  String get settingsAiSampleFailed => 'ไม่พบเนื้อหาที่ใช้ได้';

  @override
  String get helpFormatCoverageTitle => '2ก. ข้อจำกัดด้านรูปแบบของหลักฐานที่มา';

  @override
  String get helpFormatCoverage =>
      '**ข้อจำกัดสำคัญ: มีเพียง .docx และ .odt เท่านั้นที่พกบันทึกการแก้ไข**\n\n| แหล่งที่มา | บันทึกการแก้ไข |\n|---|---|\n| .docx / .odt | ✅ มี |\n| .pdf | ❌ รูปแบบนี้ไม่มีประวัติการแก้ไขเลย |\n| .doc (รุ่นเก่า) | ✅ มี (OLE2 SummaryInformation) |\n| .txt / .md | ❌ ไม่มีคอนเทนเนอร์ |\n| OCR จากภาพ | ❌ เหลือแต่พิกเซล |\n| ข้อความที่วาง | ❌ ไม่มีไฟล์เลย |\n\nเรื่องนี้กระทบเสาหลักที่ 3 โดยตรง: **เฉพาะเอกสารที่มีบันทึกการแก้ไขเท่านั้นที่จะถูกเพิ่มเข้าชุดฐานเทียบซึ่งมีการรับประกันทางสถิติโดยอัตโนมัติ** หากสิ่งที่คุณได้รับเป็น PDF ทั้งหมด ชุดฐานนั้นจะไม่มีวันเติบโต จะสะสมได้เพียงตัวอย่างอ้างอิงที่ไม่มีการรับประกัน\n\nเพื่อให้หลักฐานที่มาและการปรับเทียบอัตโนมัติทำงานได้จริง โปรดเก็บไฟล์ต้นฉบับ .docx หรือ .odt จากผู้เขียน แทนที่จะเป็น PDF ที่พิมพ์หรือส่งออก นี่เป็นข้อกำหนดเชิงกระบวนการ ไม่ใช่ข้อจำกัดที่ซอฟต์แวร์จะเลี่ยงได้ เพราะ PDF เป็นรูปแบบผลลัพธ์ และไม่ได้บันทึกว่าข้อความถูกเขียนขึ้นมาอย่างไร';

  @override
  String provenanceUnsupportedFormat(String format) {
    return 'รูปแบบ $format ไม่ได้พกประวัติการแก้ไขมาด้วยตั้งแต่ต้น จึงไม่ใช่กรณี «บันทึกถูกลบ» แต่คือไม่เคยมีเลย มีเพียง .docx และ .odt เท่านั้นที่บันทึกเวลาแก้ไข จำนวนครั้งที่บันทึก และรอบการแก้ไข';
  }

  @override
  String get provenanceStripped =>
      'รูปแบบนี้รองรับ แต่ไม่พบบันทึกการแก้ไขในไฟล์ โดยทั่วไปหมายความว่าไฟล์ถูกบันทึกเป็นไฟล์ใหม่ แปลงออนไลน์ หรือส่งออกจาก Google เอกสาร ซึ่งล้วนรีเซ็ตบันทึก';

  @override
  String get provenanceHowToGetRecord =>
      'หากต้องการให้หลักฐานที่มาใช้ได้จริง โปรดขอ **ไฟล์ต้นฉบับ .docx, .odt หรือ .doc** ไม่ใช่ PDF ที่พิมพ์หรือส่งออก เพราะมีเพียงไฟล์ต้นฉบับที่ยังเก็บประวัติการแก้ไขไว้ และมีเพียงไฟล์นั้นที่จะเข้าชุดฐานเทียบซึ่งมีการรับประกันทางสถิติได้โดยอัตโนมัติ';

  @override
  String get calibrationAutoTitle => 'กำลังเก็บในเบื้องหลัง';

  @override
  String get calibrationAutoSubtitle =>
      'เอกสารที่คุณวิเคราะห์จะถูกเพิ่มเข้าชุดฐานเทียบโดยอัตโนมัติ ไม่ต้องติดป้ายเอง';

  @override
  String calibrationAutoStatus(int auto, int observed) {
    return 'ยืนยันว่าคนเขียนจากบันทึกการแก้ไข: $auto ชิ้น / ตัวอย่างสำหรับอ้างอิงเท่านั้น: $observed ชิ้น';
  }

  @override
  String get calibrationAutoWhy =>
      'เฉพาะเอกสารที่มีบันทึกการแก้ไข (เวลาที่ใช้ จำนวนครั้งที่บันทึก การกระจายของรอบแก้ไข) เท่านั้นที่จะเข้าชุดฐานเทียบซึ่งมีการรับประกันทางสถิติ เพราะนั่นเป็นหลักฐานที่**เป็นอิสระจากการตัดสินตัวข้อความ** หากใช้ผลตัดสินของเครื่องมือเองมาติดป้าย ก็เท่ากับตรวจข้อสอบตัวเอง งานที่ถูกตัดสินผิดจะไม่มีวันเข้าชุดฐาน เกณฑ์จะเข้มขึ้นทุกรอบ และสุดท้ายงานที่คนเขียนจริงจะถูกทำเครื่องหมายมากขึ้น ข้อความที่วางมาไม่มีบันทึกการแก้ไข จึงนับเฉพาะในเปอร์เซ็นไทล์อ้างอิงด้านล่าง';

  @override
  String calibrationObservedPercentile(int percentile, int count) {
    return 'อ้างอิง: คะแนนนี้อยู่ที่เปอร์เซ็นไทล์ที่ $percentile จากเอกสาร $count ชิ้นที่คุณวิเคราะห์ (ไม่มีการรับประกันทางสถิติ)';
  }

  @override
  String get settingsAutoCollectTitle => 'เก็บตัวอย่างปรับเทียบในเบื้องหลัง';

  @override
  String get settingsAutoCollectSubtitle =>
      'เพิ่มเอกสารที่วิเคราะห์แล้วเข้าชุดฐานเทียบโดยอัตโนมัติ ป้ายกำกับมาจากบันทึกการแก้ไขของเอกสาร ไม่ใช่จากผลตัดสินของเครื่องมือนี้';

  @override
  String get settingsStoreTextTitle =>
      'เก็บเนื้อความไว้สำหรับการตรวจสอบออฟไลน์';

  @override
  String get settingsStoreTextSubtitle =>
      'เมื่อเปิด งานที่เพิ่มเข้าชุดฐานเทียบจะถูกเก็บไว้ในเครื่องพร้อมเนื้อความเต็ม เพื่อให้ส่งออกเป็นไฟล์คลังข้อความสำหรับประเมินแบบออฟไลน์ได้ในภายหลัง';

  @override
  String get settingsStoreTextWarning =>
      'เนื้อความเหล่านี้ส่วนใหญ่เป็นงานของผู้อื่นจึงเป็นข้อมูลอ่อนไหว ควรเปิดเฉพาะตอนที่กำลังรวบรวมคลังข้อความจริง ๆ และเมื่อส่งออกเสร็จให้ใช้ «ลบเนื้อความที่เก็บไว้» ด้านล่างทันที การลบไม่กระทบการทำนายเชิงคอนฟอร์มัล เพราะใช้เพียงคะแนนเท่านั้น';

  @override
  String get settingsExportCorpusTitle => 'ส่งออกคลังข้อความสำหรับปรับเทียบ';

  @override
  String settingsExportCorpusSubtitle(int human, int ai, int required) {
    return 'พร้อมส่งออก: ของคน $human ชิ้น, ของ AI $ai ชิ้น (การประเมินออฟไลน์ต้องมีอย่างละ $required ชิ้น)';
  }

  @override
  String get settingsExportCorpusButton => 'ส่งออกเป็น JSONL';

  @override
  String get settingsExportCorpusEmpty =>
      'ไม่มีอะไรให้ส่งออก โปรดเปิด «เก็บเนื้อความ» ก่อนแล้วค่อยสะสมชุดฐานเทียบ';

  @override
  String settingsExportCorpusDone(int count, int skipped) {
    return 'ส่งออกแล้ว $count ชิ้น (ข้าม $skipped ชิ้นที่ไม่ได้เก็บเนื้อความ)';
  }

  @override
  String get settingsClearStoredText => 'ลบเนื้อความที่เก็บไว้';

  @override
  String get settingsClearStoredTextDone =>
      'ลบเนื้อความที่เก็บไว้ทั้งหมดแล้ว คะแนนและการปรับเทียบยังคงเดิม';

  @override
  String get helpDesignTitle => 'แนวคิดการออกแบบและข้อจำกัดที่ทราบ';

  @override
  String get helpShiftTitle =>
      '1. การเปลี่ยนจุดยืน: เราไม่แข่งกันที่ความแม่นของคะแนน';

  @override
  String get helpShiftBody =>
      'เครื่องมือตรวจจับแทบทุกตัวในตลาดตอบคำถามเดียวกัน: ข้อความนี้ดูเหมือน AI เขียนหรือไม่?\n\nนั่นคือการแข่งขันสะสมอาวุธที่แพ้แน่นอน ยิ่งโมเดลเก่งขึ้น ลักษณะทางสถิติของข้อความที่สร้างก็ยิ่งใกล้เคียงงานเขียนของมนุษย์ และเครื่องมือเรียบเรียงใหม่ก็พัฒนาเร็วกว่าเครื่องมือตรวจจับมาก บนเส้นทางนี้ โมเดลขนาดใหญ่ฝั่งเซิร์ฟเวอร์เพียงแค่แพ้ช้ากว่าเท่านั้น\n\nTruthLens ตั้งคำถามอีกแบบ: เรามีหลักฐานอะไรบ้างเกี่ยวกับที่มาของเอกสารฉบับนี้ และแต่ละชิ้นหนักแน่นเพียงใด?\n\nนั่นคือการย้ายจากการเดาสไตล์การเขียน ไปสู่การชั่งน้ำหนักหลักฐานที่มาควบคู่กับข้อสรุปที่ซื่อตรงทางสถิติ นี่คือเหตุผลที่เครื่องมือนี้จงใจไม่ไล่ตามอันดับความแม่นของคะแนนเดี่ยว แต่กางหลักฐานแต่ละชิ้นให้ดูแยกกัน และบอกตรง ๆ เมื่อไม่รู้ ข้อได้เปรียบที่แท้จริงของการทำงานในเบราว์เซอร์ไม่ใช่ความเร็ว แต่คือการมองเห็นสิ่งที่เซิร์ฟเวอร์ไม่มีวันเห็น นั่นคือไฟล์ทั้งไฟล์ และชุดฐานเทียบที่คุณเก็บรวบรวมเอง';

  @override
  String get helpPillarsTitle => '2. เสาหลักทั้งห้า';

  @override
  String get helpPillarsBody =>
      '1. การพิสูจน์ที่มาของเอกสาร (ใช้งานแล้ว)\nอ่านบันทึกการแก้ไขภายในคอนเทนเนอร์ DOCX และ ODT: เวลาแก้ไขรวม จำนวนครั้งที่บันทึก เวลาสร้างและแก้ไข รวมถึงเครื่องหมายรอบการแก้ไข (RSID) ในเนื้อความ การมี RSID เพียงหนึ่งถึงสองชุดตลอดทั้งงานมักหมายความว่าข้อความเข้ามาทีเดียว ส่วนงาน 3,000 คำที่ใช้เวลาแก้ไขเพียงสี่นาที เป็นหลักฐานที่หนักแน่นกว่าคะแนนความสับสนใด ๆ สิ่งนี้นับเป็นหลักฐานที่มา และแสดงแยกจากความน่าจะเป็น AI โดยจงใจไม่นำไปรวมกับคะแนน\n\n2. การปรับเทียบด้วยฐานในเครื่องและการทำนายเชิงคอนฟอร์มัล (ใช้งานแล้ว)\nเพิ่มงานเขียนที่คุณแน่ใจว่าผู้เขียนเขียนเอง ระบบจะตัดสินโดยเทียบกับการกระจายตัวของกลุ่มนี้เอง แทนเกณฑ์เดียวกันทั้งโลก การทำนายเชิงคอนฟอร์มัลให้การรับประกันที่ไม่ขึ้นกับรูปแบบการแจกแจง หากชุดฐานและตัวอย่างที่ตรวจสลับกันได้ อัตราแจ้งเตือนผิดพลาดจะไม่เกินค่าแอลฟาที่คุณตั้ง นี่คือกุญแจสำคัญในการลดการตัดสินผิดกับงานเขียนของผู้ที่ไม่ใช่เจ้าของภาษา และเป็นสิ่งที่ผลิตภัณฑ์เชิงพาณิชย์ทำไม่ได้ เพราะพวกเขาไม่มีงานฐานเทียบของผู้เขียนคุณ\n\n3. น้ำหนักเอนจินจากการเรียนรู้ (ใช้งานแล้ว)\nเมื่อชุดฐานมีทั้งตัวอย่างของคนและของ AI ระบบจะวัดว่าแต่ละเอนจินแยกสองกลุ่มได้ดีเพียงใด (ขนาดอิทธิพลแบบ Cohen\'s d) แล้วเสนอน้ำหนักตามนั้น แทนสัดส่วนตายตัวที่ตั้งด้วยมือ ทั้งนี้จะไม่มีอะไรเปลี่ยนจนกว่าคุณจะกดใช้งาน การตั้งค่าจะไม่ถูกแก้แบบเงียบ ๆ\n\n4. ความสับสนไขว้ Binoculars (แกนการให้คะแนนเสร็จแล้ว ยังไม่เปิดใช้)\nความสับสนแบบดิบถือว่าความง่ายในการทำนายเท่ากับความเป็น AI ซึ่งเป็นที่มาของการแจ้งเตือนผิดพลาดอย่างเป็นระบบกับงานเขียนภาษาเรียบง่ายของผู้ที่ไม่ใช่เจ้าของภาษา Binoculars วัดความง่ายในการทำนายนั้นเทียบกับระดับที่โมเดลสองตัวเห็นต่างกัน คณิตศาสตร์ของการให้คะแนนถูกพัฒนาและทดสอบแล้ว แต่การเปิดใช้จริงยังต้องมีคู่โมเดลภาษาขนาดเล็กที่รันในเบราว์เซอร์ได้ พร้อมการตรวจสอบกับข้อมูลที่มีป้ายกำกับ\n\n5. การตรวจลายน้ำ (ตรวจสอบแล้วว่าทำไม่ได้ จึงไม่พัฒนา)\nการตรวจ SynthID-Text ผูกกับกุญแจ ตัวตรวจต้องคำนวณด้วยกุญแจชุดเดียวกับตอนสร้าง แต่กุญแจของระบบใช้งานจริงของ Google ไม่ได้เปิดเผย การทำสิ่งนี้ในเบราว์เซอร์จะไม่มีวันตอบสนองต่อผลลัพธ์จริงของ ChatGPT, Claude หรือ Gemini กลายเป็นฟีเจอร์ที่ไม่เคยทำงาน แต่ทำให้คุณเข้าใจผิดว่ามีการตรวจลายน้ำอยู่ จึงจงใจไม่ทำ';

  @override
  String get helpCascadeTitle => '3. การไล่ระดับแบบขั้นบันไดและการงดตัดสิน';

  @override
  String get helpCascadeBody =>
      'เพื่อรักษาความเร็วภายใต้งบประมาณการคำนวณอันจำกัดของเบราว์เซอร์ การวิเคราะห์จึงทำเป็นชั้น สัญญาณราคาถูกก่อน ส่วนที่แพงจะทำเมื่อจำเป็นเท่านั้น\n\nชั้นที่ 0  หลักฐานที่มาของเอกสาร (แทบไม่มีต้นทุน)\nชั้นที่ 1  ลักษณะเชิงสถิติและเชิงสำนวน (เอนจินที่มีอยู่ ราคาถูก)\nชั้นที่ 2  ตัวจำแนกระดับประโยคแบบ Transformer\nชั้นที่ 3  ความสับสนไขว้ (แพงที่สุด ใช้เมื่อภาพยังไม่ชัดเท่านั้น)\n\nจากนั้นผลลัพธ์จะส่งต่อไปยังการปรับเทียบในเครื่อง ซึ่งให้ข้อสรุปที่มาพร้อมการรับประกันอัตราแจ้งเตือนผิดพลาด หรือการงดตัดสินอย่างชัดเจน\n\n[ทำไมการงดตัดสินจึงสำคัญ]\nการกล่าวหาผิดส่วนใหญ่เกิดจากการคืนตัวเลขอย่างมั่นใจให้กับข้อมูลที่สั้นหรืออ่อนเกินกว่าจะรองรับได้ เครื่องมือนี้จะแสดงตรง ๆ ว่า \"หลักฐานไม่พอที่จะตัดสิน\" แทนที่จะฝืนให้คะแนน เมื่อ:\n\n- มีประโยคที่วิเคราะห์ได้น้อยกว่า 5 ประโยค\n- มีเนื้อหาน้อยกว่า 100 คำ\n- มีเอนจินร่วมน้อยกว่า 2 ตัว\n- เอนจินต่างกันเกิน 60 จุดเปอร์เซ็นต์ (การเฉลี่ยหมดความหมายแล้ว)\n\nเมื่องดตัดสิน คะแนนเต็มและหลักฐานรายประโยคจะยังคงแสดงอยู่ด้านล่างเพื่อการอ้างอิง แต่โปรดอย่าถือเป็นข้อสรุป ระบบที่ยอมพูดว่า \"ไม่ทราบ\" น่าเชื่อถือกว่าระบบที่ยื่นตัวเลขให้เสมอ';

  @override
  String get helpRisksTitle => '4. ความเสี่ยงที่ต้องเผชิญอย่างซื่อตรง';

  @override
  String get helpRisksBody =>
      'ทุกข้อต่อไปนี้คือข้อจำกัดที่มีอยู่จริงของเครื่องมือนี้ โปรดชั่งน้ำหนักก่อนดำเนินการใด ๆ ตามสิ่งที่รายงาน\n\n1. หลักฐานที่มาถูกลบหรือปลอมได้\nการบันทึกเป็นไฟล์ใหม่ การแปลงไฟล์ออนไลน์ การส่งออกจาก Google เอกสาร หรือการคัดลอกไปยังเอกสารใหม่ ล้วนรีเซ็ตบันทึกการแก้ไข สัญญาณตรงนี้เป็นเพียงหลักฐานประกอบ และการไม่มีสัญญาณก็ไม่ได้พิสูจน์ว่าคนเป็นผู้เขียนแน่นอน\n\n2. การรับประกันเชิงคอนฟอร์มัลตั้งอยู่บนความสลับกันได้\nจะเป็นจริงก็ต่อเมื่อตัวอย่างฐานและข้อความที่ตรวจมาจากคนกลุ่มเดียวกันและงานเขียนประเภทเดียวกัน หากทักษะการเขียนของผู้เขียนดีขึ้นชัดเจน หรือประเภทของงานเปลี่ยนไปคนละแบบ สมมติฐานก็พังและต้องสร้างชุดฐานใหม่\n\n3. ชุดฐานเทียบเองก็อาจปนเปื้อนได้\nหากงานที่ใช้เป็นฐานแท้จริงแล้ว AI เขียนแทน การปรับเทียบทั้งหมดจะเพี้ยน ตัวอย่างฐานต้องเก็บในสภาพแวดล้อมที่ควบคุมได้ เช่น งานที่ทำเสร็จภายใต้การกำกับดูแล\n\n4. โมเดลขนาดเล็กในเบราว์เซอร์แม่นยำน้อยกว่าโมเดลขนาดใหญ่ฝั่งเซิร์ฟเวอร์\nนี่คือราคาที่หลีกเลี่ยงไม่ได้ซึ่งการตัดสินใจทำเฉพาะบนเว็บจ่ายไปเพื่อความเป็นส่วนตัว คุณค่าของเครื่องมือนี้ไม่ได้อยู่ที่คะแนนเดี่ยวที่แม่นกว่า แต่อยู่ที่การอธิบายได้ ปรับเทียบได้ และซื่อตรงพอที่จะงดตัดสิน\n\n5. ไม่ควรใช้คะแนนใดเพียงลำพังเป็นเหตุผลในการกล่าวหา\nโปรดอ่านควบคู่กับหลักฐานรายประโยค ที่มาของเอกสาร และสิ่งที่คุณรู้อยู่แล้วเกี่ยวกับผู้เขียนคนนั้น เครื่องมือนี้ออกแบบมาเพื่อสนับสนุนการสนทนาที่คุณเป็นผู้ดำเนิน ไม่ใช่เพื่อตัดสินแทนคุณ';

  @override
  String get calibrationAddHuman => 'เพิ่มเป็นฐานเทียบ «คนเขียน»';

  @override
  String get calibrationAddAi => 'เพิ่มเป็นตัวอย่าง «AI สร้าง»';

  @override
  String calibrationCounts(int human, int ai) {
    return 'ชุดฐานเทียบ: คน $human ชิ้น, AI $ai ชิ้น';
  }

  @override
  String get learnedWeightsTitle => 'น้ำหนักเอนจินจากการเรียนรู้';

  @override
  String learnedWeightsNeedMore(int human, int ai, int required) {
    return 'ขณะนี้มีของคน $human ชิ้น และของ AI $ai ชิ้น แต่ละประเภทต้องมีอย่างน้อย $required ชิ้นจึงจะเรียนรู้น้ำหนักได้อย่างน่าเชื่อถือ ระหว่างนี้จะใช้น้ำหนักที่คุณตั้งเองต่อไป';
  }

  @override
  String learnedWeightsReady(int human, int ai) {
    return 'ตอนนี้เรียนรู้น้ำหนักจากตัวอย่างของคน $human ชิ้น และของ AI $ai ชิ้นได้แล้ว';
  }

  @override
  String learnedWeightsRow(String engine, int weight, String effect) {
    return '$engine: น้ำหนักที่แนะนำ $weight% (ค่าการแยก $effect)';
  }

  @override
  String learnedWeightsReversed(String engine) {
    return 'ข้อสังเกต: $engine แยกสองกลุ่มกลับด้าน (ตัวอย่าง AI กลับได้คะแนนต่ำกว่า) น้ำหนักจึงเป็นศูนย์ โดยทั่วไปหมายความว่าเอนจินนี้ไม่เหมาะกับข้อความประเภทนี้';
  }

  @override
  String get learnedWeightsApply => 'ใช้น้ำหนักที่เรียนรู้ได้';

  @override
  String get learnedWeightsApplied => 'ใช้น้ำหนักที่เรียนรู้ได้แล้ว';

  @override
  String get learnedWeightsExplain =>
      'น้ำหนักคำนวณจากความสามารถของแต่ละเอนจินในการแยกตัวอย่างของคนออกจากตัวอย่างของ AI (ขนาดอิทธิพลแบบ Cohen\'s d) ยิ่งสองกลุ่มห่างกันและแต่ละกลุ่มยิ่งนิ่ง เอนจินนั้นก็ยิ่งได้น้ำหนักมาก วิธีนี้แทนที่น้ำหนักตายตัวที่ตั้งด้วยมือ เพื่อให้การรวมผลเข้ากับประเภทข้อความที่คุณใช้งานจริง';

  @override
  String get calibrationTitle => 'การปรับเทียบด้วยฐานข้อมูลในเครื่อง';

  @override
  String get calibrationEmpty =>
      'ยังไม่มีชุดฐานเทียบ ลองเพิ่มงานเขียนที่แน่ใจว่าผู้เขียนเขียนเองสัก 2-3 ชิ้น (เช่น งานที่ทำเสร็จภายใต้การกำกับดูแล) ระบบจะได้ตัดสินโดยเทียบกับการกระจายตัวของกลุ่มนี้เอง แทนที่จะใช้เกณฑ์เดียวกันทั้งโลก ซึ่งนี่แหละคือกุญแจสำคัญที่ลดการแจ้งเตือนผิดพลาดกับงานเขียนของผู้ที่ไม่ใช่เจ้าของภาษา';

  @override
  String calibrationNotEnough(int count, int required, int alpha) {
    return 'ชุดฐานเทียบมี $count ชิ้น แต่การจะให้เพดานอัตราแจ้งเตือนผิดพลาด $alpha% เป็นจริงได้ ต้องมีอย่างน้อย $required ชิ้น ระหว่างนี้จะแสดงตัวเลขไว้อ้างอิงเท่านั้น และจะไม่ใช้ทำเครื่องหมายงานใด ๆ';
  }

  @override
  String calibrationFlagged(int alpha) {
    return 'ที่เพดานอัตราแจ้งเตือนผิดพลาด $alpha% งานชิ้นนี้**ถูกทำเครื่องหมาย**';
  }

  @override
  String calibrationNotFlagged(int alpha) {
    return 'ที่เพดานอัตราแจ้งเตือนผิดพลาด $alpha% งานชิ้นนี้**ไม่ถูกทำเครื่องหมาย**';
  }

  @override
  String calibrationPValue(String value, int count) {
    return 'ค่า p แบบอนุรักษ์ $value (เทียบกับตัวอย่างฐาน $count ชิ้น)';
  }

  @override
  String calibrationPercentile(int percentile) {
    return 'คะแนนอยู่ที่เปอร์เซ็นไทล์ที่ $percentile ของชุดฐานเทียบ';
  }

  @override
  String get calibrationCaveat =>
      'การรับประกันนี้ตั้งอยู่บนสมมติฐานว่าตัวอย่างฐานและงานที่ตรวจสลับกันได้ คือมาจากคนกลุ่มเดียวกันและงานเขียนประเภทเดียวกัน หากทักษะการเขียนของผู้เขียนดีขึ้นชัดเจน หรือเปลี่ยนประเภทของงานไปคนละแบบ สมมติฐานก็ใช้ไม่ได้ ต้องสร้างชุดฐานใหม่ อีกข้อควรระวัง: หากงานที่ใช้เป็นฐานถูก AI เขียนแทนเสียเอง การปรับเทียบทั้งหมดจะเพี้ยน จึงควรเก็บตัวอย่างในสภาพแวดล้อมที่ควบคุมได้';

  @override
  String get calibrationAddButton => 'เพิ่มงานชิ้นนี้เข้าชุดฐานเทียบ';

  @override
  String calibrationAdded(int count) {
    return 'เพิ่มเข้าชุดฐานเทียบแล้ว ขณะนี้มี $count ชิ้น';
  }

  @override
  String get settingsCalibrationTitle => 'ชุดฐานเทียบในเครื่อง';

  @override
  String settingsCalibrationSubtitle(int count, int required) {
    return 'ขณะนี้มี $count ชิ้น (ค่า α นี้ต้องการ $required ชิ้น)';
  }

  @override
  String get settingsCalibrationClear => 'ล้างชุดฐานเทียบ';

  @override
  String get settingsCalibrationCleared => 'ล้างชุดฐานเทียบแล้ว';

  @override
  String get settingsAlphaTitle => 'เพดานอัตราแจ้งเตือนผิดพลาด (α)';

  @override
  String settingsAlphaSubtitle(int alpha, int required) {
    return 'ขณะนี้ $alpha% — ยิ่งต่ำยิ่งเข้มงวด แต่ต้องใช้ตัวอย่างฐานมากขึ้น (อย่างน้อย $required ชิ้น)';
  }

  @override
  String get abstentionHeadline => 'หลักฐานไม่พอที่จะตัดสิน';

  @override
  String abstentionTooFewSentences(int count, int required) {
    return 'มีประโยคที่วิเคราะห์ได้เพียง $count ประโยค ขณะที่ต้องการอย่างน้อย $required ประโยค ที่ความยาวเท่านี้สัญญาณเชิงสถิติและรายประโยคไม่มีน้ำหนัก การฝืนให้คะแนนมีแต่จะทำให้เข้าใจผิด';
  }

  @override
  String abstentionTooFewWords(int count, int required) {
    return 'เนื้อหามี $count คำ แต่ต้องการอย่างน้อย $required คำ ต่ำกว่านั้นลักษณะการเขียนใด ๆ อาจเป็นเพียงความบังเอิญ';
  }

  @override
  String abstentionTooFewEngines(int available, int total) {
    return 'มีเอนจินร่วมเพียง $available จาก $total ตัว จึงไม่มีทางตรวจทานจากอีกมุมหนึ่ง กรุณาเติมโมเดลที่ขาดในหน้าจัดการโมเดลแล้วรันใหม่';
  }

  @override
  String abstentionEnginesConflict(int spread) {
    return 'เอนจินต่างกันถึง $spread จุดเปอร์เซ็นต์ มากพอที่การเฉลี่ยจะหมดความหมาย แนะนำให้ดูหลักฐานรายประโยคและที่มาของเอกสารแล้วตัดสินด้วยตัวเอง';
  }

  @override
  String get abstentionNoEvidenceFound =>
      'เอนจินทั้งหมดทำงานแล้ว แต่ไม่มีตัวใดพบหลักฐานที่ใช้ได้ คะแนนสำรองที่ต่ำเป็นผลลัพธ์เชิงวินิจฉัย ไม่ใช่หลักฐานว่ามนุษย์เป็นผู้เขียน';

  @override
  String abstentionSingleWeakEvidenceSource(int count) {
    return 'มีเพียง $count เอนจินที่พบหลักฐานใช้ได้ และคะแนนรวมยังต่ำกว่าเกณฑ์ AI ให้ถือว่าความครอบคลุมของหลักฐานยังน้อย ไม่ใช่หลักฐานว่ามนุษย์เป็นผู้เขียน';
  }

  @override
  String get abstentionScoreStillShown =>
      'ด้านล่างยังคงแสดงคะแนนเต็มและหลักฐานรายประโยคไว้ให้อ้างอิง แต่โปรดอย่าถือเป็นข้อสรุป';

  @override
  String get provenanceTitle => 'หลักฐานที่มาของเอกสาร';

  @override
  String get provenanceRiskHigh => 'ประวัติการแก้ไขผิดปกติอย่างชัดเจน';

  @override
  String get provenanceRiskMedium => 'ประวัติการแก้ไขมีจุดน่าสงสัย';

  @override
  String get provenanceRiskLow => 'ประวัติการแก้ไขดูปกติ';

  @override
  String get provenanceRiskUnknown => 'ไม่มีประวัติการแก้ไขให้ใช้';

  @override
  String get provenanceNoMetadata =>
      'ข้อมูลที่นำเข้านี้ไม่มีประวัติการแก้ไขติดมา (ข้อความที่วาง ไฟล์ PDF หรือไฟล์ที่ถูกลบบันทึกไปแล้ว) จึงตัดสินจากที่มาไม่ได้ เหลือเพียงการวิเคราะห์ตัวข้อความ';

  @override
  String provenanceEditingDuration(int minutes) {
    return 'เวลาแก้ไขที่บันทึกในไฟล์: $minutes นาที';
  }

  @override
  String provenanceRevisionCount(int count) {
    return 'จำนวนครั้งที่บันทึก: $count ครั้ง';
  }

  @override
  String provenanceApplication(String name) {
    return 'สร้างด้วย: $name';
  }

  @override
  String provenanceSignalSingleSession(int count, int words) {
    return 'เนื้อความมีเครื่องหมายรอบการแก้ไขเพียง $count ชุด สำหรับเนื้อหา $words คำ การเขียนไปคิดไปตามปกติจะทิ้งไว้หลายสิบชุด การกระจุกตัวขนาดนี้มักหมายความว่าข้อความเข้ามาทีเดียว เช่น การวาง';
  }

  @override
  String provenanceSignalTypingSpeed(int words, int minutes, int wpm) {
    return '$words คำ เทียบกับเวลาแก้ไขที่บันทึกไว้ $minutes นาที คิดเป็น $wpm คำต่อนาที ซึ่งสูงกว่าที่คนทั่วไปจะรักษาไว้ได้ขณะเขียนจริงมาก';
  }

  @override
  String provenanceSignalNoEditingTime(int words) {
    return 'ไฟล์บันทึกเวลาแก้ไขไว้เกือบเป็นศูนย์ แต่เนื้อความมีถึง $words คำ';
  }

  @override
  String provenanceSignalFewRevisions(int count, int words) {
    return 'เนื้อหา $words คำ ถูกบันทึกเพียง $count ครั้ง';
  }

  @override
  String get provenanceCaveat =>
      'ควรทราบไว้: บันทึกเหล่านี้ถูกลบหรือรีเซ็ตได้ ไม่ว่าจะบันทึกเป็นไฟล์ใหม่ แปลงไฟล์ออนไลน์ ส่งออกจาก Google เอกสาร หรือคัดลอกไปไฟล์ใหม่ ล้วนทำให้กลับเป็นศูนย์ สัญญาณตรงนี้จึงเป็นเพียงหลักฐานประกอบ ไม่ใช่ข้อสรุปในตัวเอง และการไม่มีสัญญาณก็ไม่ได้พิสูจน์ว่าคนเป็นผู้เขียน';

  @override
  String get telemetrySummaryTitle => 'สรุปผลการวิเคราะห์';

  @override
  String telemetrySummaryVerdict(
    int engines,
    int total,
    int percent,
    String verdict,
  ) {
    return 'เอนจิน $engines จาก $total ตัวทำงานเสร็จ ความน่าจะเป็น AI โดยรวมอยู่ที่ $percent% จึงตัดสินเป็น “$verdict”';
  }

  @override
  String telemetrySummaryAgreement(int high, int low) {
    return 'เอนจินแต่ละตัวมองตรงกันพอสมควร (สูงสุด $high% ต่ำสุด $low%) ข้อสรุปนี้จึงค่อนข้างหนักแน่น';
  }

  @override
  String telemetrySummaryDisagreement(
    String highLabel,
    int high,
    String lowLabel,
    int low,
  ) {
    return 'เอนจินมองไม่ตรงกัน: $highLabel ให้ $high% แต่ $lowLabel ให้แค่ $low% กรณีแบบนี้อย่าดูแค่คะแนนรวม ลองไล่ดูหลักฐานรายประโยคด้านล่างจะแม่นกว่ามาก';
  }

  @override
  String telemetrySummaryDriver(String label, int points) {
    return 'ตัวที่ดันคะแนนขึ้นมาหลัก ๆ คือ$label คิดเป็นราว $points จุดเปอร์เซ็นต์';
  }

  @override
  String telemetrySummarySentencesNone(int total) {
    return 'ไล่ดูครบทั้ง $total ประโยคแล้ว ไม่มีประโยคไหนข้ามเส้นสัญญาณ AI ที่ชัดเจนเลย';
  }

  @override
  String telemetrySummarySentencesSome(int count, int total) {
    return 'จาก $total ประโยค มี $count ประโยคที่ข้ามเส้นสัญญาณ AI ที่ชัดเจน ควรไล่อ่านทีละประโยค';
  }

  @override
  String get telemetrySummaryAdviceHuman =>
      'อ่านแล้วเหมือนคนเขียนเองจริง ๆ ไม่มีจุดไหนที่ต้องตามต่อ';

  @override
  String get telemetrySummaryAdviceMixed =>
      'ฉบับนี้อยู่ในโซนก้ำกึ่ง จะสรุปจากคะแนนอย่างเดียวเสี่ยงเกินไป แนะนำให้ดูควบคู่กับหลักฐานรายประโยคและที่มาของเอกสาร';

  @override
  String get telemetrySummaryAdviceAi =>
      'สัญญาณชี้ชัดไปทาง AI สร้างหรือเขียนใหม่ แนะนำให้ตรวจประโยคที่ถูกทำเครื่องหมายทีละประโยคก่อนตัดสินใจ';

  @override
  String telemetrySummaryModelGap(int count) {
    return 'นอกจากนี้ยังมีเอนจิน $count ตัวที่ไม่ได้ร่วมโหวตรอบนี้ ความมั่นใจจึงต้องหักลบไว้บ้าง ลองเติมให้ครบในหน้าจัดการโมเดลแล้วรันใหม่จะแม่นขึ้น';
  }

  @override
  String reportVerdictRangeBelow(int value) {
    return 'ความน่าจะเป็น AI < $value%';
  }

  @override
  String reportVerdictRangeBetween(int low, int high) {
    return 'ความน่าจะเป็น AI $low%–$high%';
  }

  @override
  String reportVerdictRangeAbove(int value) {
    return 'ความน่าจะเป็น AI ≥ $value%';
  }

  @override
  String reportConfidenceLowTooltip(int threshold, int available, int total) {
    return 'ความเชื่อมั่นต่ำ: น้ำหนักโมเดลที่ใช้ได้ต่ำกว่า 60%（เกณฑ์ $threshold%）ม เอนจิน $available/$total เข้าร่วม กรุณาตรวจสอบการวิเคราะห์เอนจินโดยละเอียด';
  }

  @override
  String reportConfidenceHighTooltip(int available, int total, int threshold) {
    return 'ความเชื่อมั่นสูง: โมเดลตรวจจับ $available/$total โมเดลบรรลุฉันทามติ（น้ำหนัก $threshold% ขึ้นไปเห็นด้วยกับคำตัดสินนี้）';
  }

  @override
  String reportConfidenceLowBadge(int available, int total) {
    return 'ความเชื่อมั่นต่ำ（$available/$total）';
  }

  @override
  String reportConfidenceHighBadge(int available, int total) {
    return 'ความเชื่อมั่นสูง（$available/$total）';
  }

  @override
  String get reportMetricAiSentenceRatio =>
      'สัดส่วนประโยคที่มีสัญญาณ AI ชัดเจน';

  @override
  String reportStrongAiSentenceCount(int count, int total) {
    return '$count จาก $total ประโยคเกินเกณฑ์สัญญาณชัดเจน 60%';
  }

  @override
  String get reportMetricElapsed => 'เวลาวิเคราะห์';

  @override
  String get reportMetricElapsedNormal => '0.5-5 วินาที ปกติ';

  @override
  String get reportMetricReliability => 'ความน่าเชื่อถือ';

  @override
  String get reportReliabilityLow => 'ต่ำ';

  @override
  String get reportReliabilityHigh => 'สูง';

  @override
  String get reportReliabilityNeedsReview => 'ต้องตรวจสอบ';

  @override
  String get reportReliabilityHighTrust => 'น่าเชื่อถือสูง';

  @override
  String get reportSentenceAnalysisTitle => 'การวิเคราะห์ระดับประโยค';

  @override
  String get suspiciousFilterAll => 'น่าสงสัย';

  @override
  String get suspiciousFilterHigh => 'สูง';

  @override
  String get suspiciousFilterMedium => 'ปานกลาง';

  @override
  String get suspiciousExcludedTooltip =>
      'ตัวอักษรเดี่ยว หมายเลขหน้า หมายเลขส่วน และชิ้นส่วน OCR/PDF ที่สั้นเกินไปถูกยกเว้นแล้ว';

  @override
  String suspiciousCount(int count) {
    return '$count รายการ';
  }

  @override
  String get suspiciousEmpty => 'ไม่มีเนื้อหาที่น่าสงสัย';

  @override
  String get suspiciousRiskHigh => 'สูง';

  @override
  String get suspiciousRiskMedium => 'ปานกลาง';

  @override
  String get suspiciousReasonHighModelSignals =>
      'สัญญาณโมเดลหลายตัวโน้มเอียงไปทาง AI อย่างมาก';

  @override
  String get suspiciousReasonSentenceSignal => 'สัญญาณโมเดลระดับประโยคสูงขึ้น';

  @override
  String suspiciousOriginalLocation(String location) {
    return 'ตำแหน่งต้นฉบับ $location';
  }

  @override
  String suspiciousOriginalLocationWithReason(String location, String reason) {
    return 'ตำแหน่งต้นฉบับ $location · $reason';
  }

  @override
  String suspiciousSentenceNumber(int number) {
    return 'ประโยค #$number';
  }

  @override
  String get suspiciousEvidenceLabel => 'หลักฐาน:';

  @override
  String reportSentenceTooltip(String text, int percent, String patterns) {
    return '$text. ความน่าจะเป็น AI $percent%$patterns';
  }

  @override
  String get reportLinkAuthenticityTitle => 'ความถูกต้องของลิงก์';

  @override
  String get reportLinkNoneDetected => 'ไม่พบลิงก์ในเอกสาร';

  @override
  String get reportLinkCheckingProgress => 'กำลังตรวจสอบลิงก์…';

  @override
  String reportLinkDetectedPending(int count) {
    return 'ตรวจพบลิงก์ $count รายการ ยังไม่ได้ตรวจสอบว่ามีอยู่จริงหรือไม่';
  }

  @override
  String get reportLinkDisabledHint =>
      'เนื้อหาที่สร้างโดย AI มักมีลิงก์อ้างอิงที่ดูสมเหตุสมผลแต่ไม่มีอยู่จริง คุณได้ปิดการตรวจสอบลิงก์ใน \"การตั้งค่า\" แล้ว สามารถเปิดอีกครั้งเพื่อตรวจสอบอัตโนมัติ หรือแตะปุ่มด้านล่างเพื่อตรวจสอบเพียงครั้งเดียว';

  @override
  String get reportVerifyNowButton => 'ตรวจสอบตอนนี้（ต้องใช้เครือข่าย）';

  @override
  String get reportLinkReachable => 'เชื่อมต่อได้ URL มีอยู่จริง';

  @override
  String get reportLinkNotFound =>
      'ไม่พบ URL (404) อาจเป็นการอ้างอิงที่ปลอมแปลง';

  @override
  String get reportLinkUnreachable =>
      'ไม่สามารถยืนยันได้（หมดเวลาเชื่อมต่อหรือเซิร์ฟเวอร์ไม่ตอบสนอง）';

  @override
  String reportLinkCitationVerified(String journal, String title) {
    return 'ยืนยันในทะเบียนวารสารแล้ว: ลงทะเบียนกับ $journal$title';
  }

  @override
  String get reportLinkCitationNotFound =>
      'ไม่พบ DOI ที่ตรงกันในทะเบียน อาจเป็นการอ้างอิงที่ปลอมแปลง';

  @override
  String get reportLinkCitationUnreachable =>
      'ไม่สามารถยืนยันได้（หมดเวลาเชื่อมต่อหรือ Crossref ไม่ตอบสนอง）';

  @override
  String reportLinkTruncated(int max, int count) {
    return 'ตรวจสอบเฉพาะลิงก์ $max รายการแรก（ตรวจพบทั้งหมด $count รายการ）';
  }

  @override
  String get reportBibAuthenticityTitle => 'ความถูกต้องของการอ้างอิง';

  @override
  String get reportBibNoneDetected => 'ไม่พบรายการบรรณานุกรมในเอกสาร';

  @override
  String get reportBibCheckingProgress => 'กำลังตรวจสอบรายการบรรณานุกรม…';

  @override
  String reportBibDetectedPending(int count) {
    return 'ตรวจพบบรรณานุกรม（$count รายการ）ยังไม่ได้ตรวจสอบว่ามีอยู่จริงหรือไม่';
  }

  @override
  String get reportBibDisabledHint =>
      'เนื้อหาที่สร้างโดย AI มักมีการอ้างอิงที่ดูสมเหตุสมผลแต่ไม่มีอยู่จริง คุณได้ปิดการตรวจสอบลิงก์ใน \"การตั้งค่า\" แล้ว สามารถเปิดอีกครั้งเพื่อตรวจสอบอัตโนมัติ หรือแตะปุ่มด้านล่างเพื่อตรวจสอบเพียงครั้งเดียว';

  @override
  String get reportVerifyNowBibButton => 'ตรวจสอบตอนนี้（ต้องใช้เครือข่าย）';

  @override
  String get reportBibRecheckAllUnreliableButton =>
      'ตรวจสอบการอ้างอิงที่ยังไม่ได้ยืนยันทั้งหมดอีกครั้ง';

  @override
  String get reportBibRecheckOneTooltip => 'ตรวจสอบการอ้างอิงนี้อีกครั้ง';

  @override
  String get reportBibResultHint =>
      'จับคู่กับข้อมูลทะเบียนสาธารณะของ Crossref โดยใช้ความคล้ายคลึงของผู้แต่ง ปี และชื่อเรื่อง ไม่ใช่การรับประกันที่แน่นอน หากผลลัพธ์ \"ไม่แน่ใจ\" แนะนำให้ตรวจสอบด้วยตนเอง';

  @override
  String reportBibVerificationSource(String source) {
    return 'แหล่งที่มาการตรวจสอบ: $source';
  }

  @override
  String get reportBibGoogleScholarManualLookup =>
      'ตรวจสอบด้วยตนเองใน Google Scholar';

  @override
  String reportBibHighConfidence(String journal) {
    return 'ความเชื่อมั่นสูง: น่าจะมีอยู่จริง$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（ลงทะเบียนกับ $journal）';
  }

  @override
  String reportBibJournalMismatch(String reported, String registered) {
    return 'ชื่อวารสารไม่ตรงกัน: เอกสารระบุว่า \"$reported\" ในขณะที่ทะเบียนที่ยืนยันแล้วระบุว่า \"$registered\" กรุณาตรวจสอบการอ้างอิงนี้';
  }

  @override
  String get reportBibNotFound =>
      'ไม่พบรายการที่ใกล้เคียง อาจเป็นบรรณานุกรมที่ปลอมแปลง';

  @override
  String get reportBibUncertain =>
      'น่าสงสัย: ยังไม่ได้รับการยืนยันจากการจับคู่ทะเบียน';

  @override
  String reportBibTruncated(int max, int count) {
    return 'ตรวจสอบเฉพาะ $max รายการแรก（ตรวจพบทั้งหมด $count รายการ）';
  }

  @override
  String reportBibCompletedPreview(int count) {
    return 'เสร็จสิ้น $count รายการ ผลลัพธ์จะยังคงอัปเดตต่อไป';
  }

  @override
  String reportBibProgress(int completed, int total, String current) {
    return 'ความคืบหน้า $completed/$total, $current';
  }

  @override
  String reportBibProgressCurrent(String text) {
    return 'ปัจจุบัน: $text';
  }

  @override
  String get reportBibProgressFinalizing => 'กำลังสรุปผลลัพธ์';

  @override
  String reportBibUncertainWithCandidate(String base, String candidate) {
    return '$base: พบตัวเลือกที่คล้ายกัน \"$candidate\" แต่ผู้เขียน ปี หรือชื่อเรื่องไม่ถึงเกณฑ์การจับคู่ที่น่าเชื่อถือ';
  }

  @override
  String reportBibUncertainNoReliableResponse(String base) {
    return '$base: แหล่งตรวจสอบไม่ให้การตอบสนองที่น่าเชื่อถือ หรือรายการมีข้อมูลไม่เพียงพอ TruthLens จึงไม่ถือว่าการอ้างอิงนี้ได้รับการยืนยัน';
  }

  @override
  String get reportNetworkWarningTitle => 'การเชื่อมต่อเครือข่ายไม่ดี';

  @override
  String get reportNetworkWarningBody =>
      'แอปนี้ถือว่ามีการเชื่อมต่อเครือข่ายเป็นค่าเริ่มต้นเมื่อทำงาน การวิเคราะห์ความถูกต้องของลิงก์และการอ้างอิงต้องใช้การเชื่อมต่อเครือข่ายเพื่อให้ได้ผลลัพธ์ ขณะนี้ไม่สามารถเชื่อมต่อได้ กรุณาตรวจสอบสถานะเครือข่ายแล้วลองใหม่อีกครั้ง';

  @override
  String get reportRetryConnectionButton => 'ตรวจสอบการเชื่อมต่ออีกครั้ง';

  @override
  String get reportAiProbabilityLabel => 'ความน่าจะเป็น AI';

  @override
  String summaryCardStats(int total, int ai, int human) {
    return 'รวม $total ประโยค\nน่าจะเป็น AI $ai ประโยค\nน่าจะเป็นมนุษย์ $human ประโยค';
  }

  @override
  String get summaryCardFooter => 'การอนุมาน AI หลักทั้งหมดทำงานบนอุปกรณ์';

  @override
  String get exportReportTitle => 'รายงานการตรวจจับ TruthLens';

  @override
  String pdfPageFooter(int page, int total) {
    return 'TruthLens · หน้า $page / $total';
  }

  @override
  String pdfAnalyzedAtElapsed(String datetime, String seconds) {
    return 'เวลาวิเคราะห์: $datetime · ใช้เวลา $seconds วินาที';
  }

  @override
  String reportOverallVerdictLabel(String verdict) {
    return 'การตัดสินโดยรวม: $verdict';
  }

  @override
  String get pdfEslAppliedSuffix => '（ใช้การปรับแก้ ESL แล้ว）';

  @override
  String pdfSentenceCounts(int total, int ai, int human) {
    return 'รวม $total ประโยค · น่าจะเป็น AI $ai ประโยค · น่าจะเป็นมนุษย์ $human ประโยค';
  }

  @override
  String pdfTruncationNotice(
    int max,
    int count,
    String csvLabel,
    String jsonLabel,
  ) {
    return 'เพื่อรักษาความสามารถในการอ่าน PDF จะแสดงเฉพาะ $max ประโยคแรก（จากทั้งหมด $count ประโยค）หากต้องการข้อมูลครบถ้วน กรุณาใช้ \"$csvLabel\" หรือ \"$jsonLabel\" แทน';
  }

  @override
  String get pdfSentenceColumnHeader => 'ประโยค（พร้อมรูปแบบที่ตรงกัน）';

  @override
  String composerHeadlineAi(int percent) {
    return 'ข้อความนี้มีแนวโน้มสูงมากว่าถูกสร้างโดย AI（ความน่าจะเป็น AI $percent%）';
  }

  @override
  String composerHeadlineLikelyAi(int percent) {
    return 'ข้อความนี้มีแนวโน้มว่าสร้างโดย AI แนะนำให้ตรวจสอบเพิ่มเติม（ความน่าจะเป็น AI $percent%）';
  }

  @override
  String composerHeadlineMixed(int percent) {
    return 'ข้อความนี้แสดงลักษณะผสมระหว่างมนุษย์และ AI（ความน่าจะเป็น AI $percent%）';
  }

  @override
  String composerHeadlineLikelyHuman(int percent) {
    return 'ข้อความนี้มีแนวโน้มว่าเขียนโดยมนุษย์（ความน่าจะเป็น AI $percent%）';
  }

  @override
  String composerHeadlineHuman(int percent) {
    return 'ข้อความนี้มีแนวโน้มสูงมากว่าเขียนโดยมนุษย์（ความน่าจะเป็น AI $percent%）';
  }

  @override
  String composerThresholdFlagged(int percent) {
    return 'ความน่าจะเป็น AI โดยรวมเกินเกณฑ์คงที่ $percent% และถูกทำเครื่องหมายว่าเป็น AI';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'ความน่าจะเป็น AI โดยรวมต่ำกว่าเกณฑ์คงที่ $percent%';
  }

  @override
  String composerThresholdFlaggedDetailed(int aiPercent, int thresholdPercent) {
    return 'ความน่าจะเป็น AI โดยรวมคือ $aiPercent% ซึ่งถึงเกณฑ์คงที่การตั้งค่าสถานะ AI ที่ $thresholdPercent% รายงานจึงทำเครื่องหมายข้อความนี้ว่าเป็น AI กรุณาตรวจสอบหลักฐานระดับประโยคและเหตุผลของเอนจินก่อนตัดสินใจขั้นสุดท้าย';
  }

  @override
  String composerThresholdNotFlaggedDetailed(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'ความน่าจะเป็น AI โดยรวมคือ $aiPercent% ต่ำกว่าเกณฑ์คงที่การตั้งค่าสถานะ AI ที่ $thresholdPercent% รายงานจึงไม่ทำเครื่องหมายข้อความนี้ว่าเป็น AI อย่างเป็นทางการ ความน่าจะเป็นและหลักฐานยังคงแสดงไว้เพื่อตรวจสอบ';
  }

  @override
  String get composerNarrativeTitle => 'การตีความผลวิเคราะห์';

  @override
  String get composerParaphraseTitle => 'ตรวจพบร่องรอยการเขียนใหม่';

  @override
  String get composerParaphraseBody =>
      'ข้อความนี้อาจถูกประมวลผลด้วยเครื่องมือเขียนใหม่（เช่น QuillBot, Undetectable.ai）เพื่อหลบเลี่ยงการตรวจจับ แม้จะอ่านดูเป็นธรรมชาติในแต่ละประโยค แต่ลักษณะทางสถิติโดยรวมยังคงแตกต่างจากงานเขียนของมนุษย์แท้ กรุณาให้ความสนใจเป็นพิเศษ';

  @override
  String get composerPatternListTitle => 'รูปแบบการเขียนหลักของ AI';

  @override
  String get composerEslTitle =>
      'การปรับแก้ความเอนเอียงสำหรับผู้ไม่ใช่เจ้าของภาษา (ESL)';

  @override
  String get composerEslBody =>
      'ข้อความนี้อาจมาจากผู้เขียนที่ไม่ใช่เจ้าของภาษา ความสับสน（perplexity）ที่ต่ำและรูปแบบประโยคที่สม่ำเสมอซึ่งพบได้ทั่วไปในผู้ไม่ใช่เจ้าของภาษาไม่ใช่ลักษณะของ AI ในตัวมันเอง ดังนั้นระบบจึงลดน้ำหนักของโมเดลเชิงสถิติลงเพื่อหลีกเลี่ยงการตัดสินผิดพลาด';

  @override
  String composerNarrativeIntro(int total, int ai, int human) {
    return 'เนื้อหามีทั้งหมด $total ประโยค โดยมี $ai ประโยคที่แสดงลักษณะ AI ที่ชัดเจน และ $human ประโยคที่มีแนวโน้มว่าเขียนโดยมนุษย์';
  }

  @override
  String get composerNarrativeAiPattern =>
      'ประโยคส่วนใหญ่มีความสม่ำเสมอสูงในจังหวะความยาวประโยค การเลือกใช้คำ และการใช้คำเชื่อม ซึ่งเป็นลักษณะทั่วไปของข้อความที่สร้างโดย AI';

  @override
  String get composerNarrativeMixedPattern =>
      'เนื้อหามีทั้งส่วนที่สม่ำเสมอและส่วนที่มีความหลากหลายตามธรรมชาติปะปนกัน แสดงให้เห็นว่าอาจเป็นร่างต้นฉบับของมนุษย์ที่ผ่านการปรับแต่งโดย AI หรือเป็นการทำงานร่วมกันระหว่างมนุษย์กับ AI';

  @override
  String get composerNarrativeHumanPattern =>
      'ความยาวประโยคและการเลือกใช้คำแสดงความหลากหลายตามธรรมชาติและสไตล์ส่วนตัว ไม่พบร่องรอยความสม่ำเสมอของ AI ที่ชัดเจน';

  @override
  String engineReasonPplLow(String ppl) {
    return 'ความสับสนของโมเดลภาษาต่ำ（$ppl）ข้อความมีความสามารถในการคาดเดาได้สูง ซึ่งเป็นตัวบ่งชี้การสร้างโดย AI';
  }

  @override
  String engineReasonPplHigh(String ppl) {
    return 'ความสับสนของโมเดลภาษาสูง（$ppl）สอดคล้องกับความไม่สามารถคาดเดาได้ของงานเขียนมนุษย์';
  }

  @override
  String engineReasonPplMid(String ppl) {
    return 'ความสับสนของโมเดลภาษาอยู่ในระดับปานกลาง（$ppl）';
  }

  @override
  String engineReasonBurstinessLow(String value) {
    return 'ความยาวประโยคมีความสม่ำเสมอสูงมาก（burstiness $value）จังหวะที่สม่ำเสมอเป็นลักษณะทางสถิติทั่วไปของข้อความที่สร้างโดย AI';
  }

  @override
  String engineReasonBurstinessHigh(String value) {
    return 'ความยาวประโยคมีความผันแปรที่ชัดเจน（burstiness $value）สอดคล้องกับการเปลี่ยนแปลงจังหวะตามธรรมชาติของงานเขียนมนุษย์';
  }

  @override
  String engineReasonBurstinessMid(String value) {
    return 'ความผันแปรของความยาวประโยค (burstiness $value) ยังอยู่ในช่วงกลาง 0.30–0.55';
  }

  @override
  String engineReasonTtrLow(String value) {
    return 'ความหลากหลายของคำศัพท์ต่ำ（TTR $value）มีการซ้ำคำสูง';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'ความหลากหลายของคำศัพท์สูง（TTR $value）';
  }

  @override
  String engineReasonMattrNoAiSignal(String value, String cut) {
    return 'ความหลากหลายของคำศัพท์ (MATTR $value) ไม่ผ่านเกณฑ์สัญญาณ AI ที่ปรับเทียบไว้ $cut';
  }

  @override
  String engineReasonStatisticalSummaryAi(String percent) {
    return 'สรุปสถิติโดยรวม: โน้มเอียงไปทางลักษณะที่สร้างโดย AI（ความน่าจะเป็น AI $percent%）';
  }

  @override
  String engineReasonStatisticalSummaryHuman(String percent) {
    return 'สรุปสถิติโดยรวม: โน้มเอียงไปทางการเขียนของมนุษย์ตามธรรมชาติ（ความน่าจะเป็น AI $percent%）';
  }

  @override
  String engineReasonStatisticalSummaryNeutral(String percent) {
    return 'สรุปสถิติโดยรวม: ตัวชี้วัดสมดุลกัน แสดงลักษณะเป็นกลาง（ความน่าจะเป็น AI $percent%）';
  }

  @override
  String get reportFormulaTitle =>
      'ความโปร่งใสของการคำนวณถ่วงน้ำหนักและรายละเอียดพารามิเตอร์';

  @override
  String get reportFormulaExplanation =>
      'ความน่าจะเป็น AI โดยรวมคำนวณเป็นค่าเฉลี่ยถ่วงน้ำหนักของความน่าจะเป็นจากเอนจินที่ใช้งานอยู่ทั้งหมด:';

  @override
  String get reportFormulaActiveEngines =>
      'เอนจินที่ใช้งานอยู่และน้ำหนักที่กำหนด';

  @override
  String get reportFormulaCalculation => 'การคำนวณสูตรถ่วงน้ำหนัก';

  @override
  String get reportFormulaFinalResult =>
      'ความน่าจะเป็น AI ถ่วงน้ำหนักขั้นสุดท้าย';

  @override
  String get reportFormulaEslApplied =>
      'ใช้การปรับแก้การเขียน ESL ที่ไม่ใช่เจ้าของภาษาแล้ว（น้ำหนักโมเดลสถิติลดลงครึ่งหนึ่ง）';

  @override
  String get engineReasonNeutral =>
      'ตัวชี้วัดทางสถิติไม่แสดงแนวโน้มที่ชัดเจน คงการตัดสินแบบเป็นกลาง';

  @override
  String engineReasonTransitionWords(String words, String density) {
    return 'ใช้คำเชื่อมทั่วไป（$words）บ่อยครั้ง เฉลี่ย $density ครั้งต่อประโยค ซึ่งงานเขียนมนุษย์มักไม่หนาแน่นเช่นนี้';
  }

  @override
  String engineReasonRepeatedOpeners(int count) {
    return 'ประโยคที่อยู่ติดกันหลายประโยคขึ้นต้นด้วยคำเดียวกัน（$count จุด）รูปแบบประโยคซ้ำกัน';
  }

  @override
  String get engineReasonNoStyleMarkers =>
      'ไม่พบรูปแบบการเขียนแบบ AI ที่ชัดเจน';

  @override
  String get engineStatisticalPerplexityModule => 'ความยากของโมเดลภาษา';

  @override
  String get engineStatisticalLexicalModule => 'ลายนิ้วมือเชิงคำศัพท์';

  @override
  String get engineStatisticalHeuristicModule => 'สถิติเชิงฮิวริสติก';

  @override
  String get engineStylometryRulesModule => 'ลักษณะลีลาเชิงกฎ';

  @override
  String get engineStylometryPan25Module => 'ลายนิ้วมือคำศัพท์ PAN 2025';

  @override
  String get engineStylometryDetectRlModule => 'ลายนิ้วมืออักขระ DetectRL-ZH';

  @override
  String get modelNameMbertMultilingual => 'ตัวตรวจจับหลายภาษา (EN+ZH · INT8)';

  @override
  String get modelNameTruthlensZh =>
      'ตัวตรวจจับภาษาจีน TruthLens (รุ่นปี 2026 · INT8)';

  @override
  String get modelNameAigcZhv3 =>
      'ตัวตรวจจับภาษาจีนสมัยใหม่ (DeepSeek/GPT-4 · INT8)';

  @override
  String get modelNameRobertaEn => 'ตัวตรวจจับ RoBERTa (อังกฤษ · ChatGPT)';

  @override
  String get modelNameQwenPpl => 'โมเดลความยากหลายภาษา (Qwen2.5-0.5B · INT8)';

  @override
  String get modelNameDistilgpt2Ppl => 'โมเดลความยาก DistilGPT2 (INT8)';

  @override
  String get modelNameAdversarial => 'ตัวตรวจจับการเขียนใหม่ (INT8)';

  @override
  String get modelErrorNoSource => 'รุ่นนี้ยังไม่มีแหล่งดาวน์โหลด';

  @override
  String modelErrorStorageShort(String mb) {
    return 'พื้นที่จัดเก็บของเบราว์เซอร์ไม่พอ ขาดอีกประมาณ $mb MB โปรดลบโมเดลที่ไม่ต้องการหรือเพิ่มพื้นที่ดิสก์';
  }

  @override
  String get modelErrorChecksum => 'ค่าตรวจสอบไม่ตรงกัน ไฟล์อาจเสียหาย';

  @override
  String get modelErrorTokenizerIncomplete =>
      'ไฟล์ Tokenizer JSON ที่ดาวน์โหลดไม่สมบูรณ์ หรือการเชื่อมต่อหลุด';

  @override
  String modelErrorSizeMismatch(String got, String expected) {
    return 'ดาวน์โหลดไม่สมบูรณ์: ได้รับ $got MB คาดว่าประมาณ $expected MB';
  }

  @override
  String get modelErrorChunkAborted =>
      'การดาวน์โหลดหยุดกลางบล็อกและลองใหม่หลายครั้งไม่สำเร็จ';

  @override
  String get modelErrorTokenizerInvalid => 'รูปแบบ Tokenizer JSON ไม่ถูกต้อง';

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
  String get deviceCapabilityEstimated => ' (ประมาณ)';

  @override
  String engineReasonPan25LexicalAi(int percent) {
    return 'ลายนิ้วมือเชิงคำศัพท์ PAN 2025 เอียงไปทาง AI ($percent/100) เกณฑ์อ้างอิงภาษาอังกฤษอิสระนี้ตรวจจับการกระจายของคำและวลีที่ต่างจากคลังข้อความมนุษย์ของมัน';
  }

  @override
  String engineReasonPan25LexicalHuman(int percent) {
    return 'ลายนิ้วมือเชิงคำศัพท์ PAN 2025 เอียงไปทางมนุษย์ ($percent/100) สิ่งนี้ยังเป็นหลักฐานจากโมเดล ไม่ใช่ข้อพิสูจน์ความเป็นผู้เขียน';
  }

  @override
  String engineReasonPan25LexicalNeutral(int percent) {
    return 'ลายนิ้วมือเชิงคำศัพท์ PAN 2025 เป็นกลาง ($percent/100) และไม่ได้ชี้ทิศทางใด';
  }

  @override
  String engineReasonDetectRlZhAi(int percent) {
    return 'ลายนิ้วมือตัวอักษรจีนของ DetectRL-ZH ผ่านประตูหลักฐาน AI แบบระมัดระวัง ($percent/100) โดยได้รับการทดสอบอิสระกับ DeepSeek-V3 ข้อความผสม การแปลกลับ การรบกวนตัวอักษร และความยาวที่แตกต่างกัน';
  }

  @override
  String engineReasonDetectRlZhNoAiSignal(int percent) {
    return 'ลายนิ้วมือตัวอักษรจีนของ DetectRL-ZH ไม่ผ่านประตูหลักฐาน AI แบบระมัดระวัง ($percent/100) นี่คือการงดออกเสียง ไม่ใช่หลักฐานว่ามนุษย์เป็นผู้เขียน';
  }

  @override
  String engineReasonCompressionCoherence(String value) {
    return 'ความสอดคล้องของการบีบอัดข้ามขอบเขต ($value) สูงกว่าเกณฑ์คัดกรองเปอร์เซ็นไทล์ที่ 95 ของข้อความมนุษย์ใน PAN 2025 [สัญญาณอ่อนฝั่ง AI]';
  }

  @override
  String engineReasonAssistantResponseArtifact(int count) {
    return 'ตรวจพบร่องรอยการตอบแบบผู้ช่วยสนทนา $count จุด เช่น การเอ่ยถึงผู้ร้องขอ หรือการเสนอตัวแก้ไขข้อความที่ร้องขอ';
  }

  @override
  String get engineReasonAdversarialNotInstalled =>
      'ยังไม่ได้ติดตั้งโมเดลตรวจจับการเขียนใหม่ จึงไม่ได้เข้าร่วมการโหวตครั้งนี้';

  @override
  String get engineReasonTransformerNotInstalled =>
      'ยังไม่ได้ติดตั้งโมเดล หรือโมเดลที่ใช้งานไม่รองรับ จึงไม่ได้เข้าร่วมการโหวตครั้งนี้';

  @override
  String get modelRepairNoActiveVariant =>
      'ไม่พบโมเดลที่ใช้งานอยู่ กรุณาดาวน์โหลดโมเดลที่แนะนำในการจัดการโมเดล';

  @override
  String get modelRepairCustomRemoved =>
      'ลบโมเดลกำหนดเองที่โหลดล้มเหลวแล้ว โมเดลกำหนดเองไม่สามารถดาวน์โหลดซ้ำโดยอัตโนมัติได้ กรุณานำเข้าโมเดลและ tokenizer ใหม่';

  @override
  String get modelRepairNoSource =>
      'ลบไฟล์โมเดลที่โหลดล้มเหลวแล้ว แต่ขณะนี้ไม่พบแหล่งแคตตาล็อกสำหรับดาวน์โหลดซ้ำ กรุณาดาวน์โหลดโมเดลที่แนะนำใหม่ในการจัดการโมเดล';

  @override
  String modelRepairRedownloaded(Object name) {
    return 'ตรวจพบว่าไฟล์โมเดลอาจเสียหายหรือไม่เข้ากัน จึงดาวน์โหลด $name ซ้ำโดยอัตโนมัติแล้ว กรุณาวิเคราะห์อีกครั้ง';
  }

  @override
  String modelRepairRedownloadFailed(Object name) {
    return 'ลบไฟล์โมเดลที่โหลดล้มเหลวแล้ว แต่การดาวน์โหลดซ้ำอัตโนมัติไม่สำเร็จ กรุณาตรวจสอบการเชื่อมต่อเครือข่ายแล้วดาวน์โหลด $name ใหม่ในการจัดการโมเดล';
  }

  @override
  String get engineTransformerNoActiveVariant =>
      'ไม่พบโมเดล Transformer ที่ใช้งานอยู่ กรุณาดาวน์โหลดหรือตั้งค่าให้ใช้งานในการจัดการโมเดล';

  @override
  String engineTransformerUnsupportedTokenizer(Object tokenizer) {
    return 'ประเภท tokenizer ของโมเดลที่ใช้งานอยู่ไม่รองรับ（$tokenizer）กรุณาเปลี่ยนไปใช้โมเดลที่รองรับ bert-wordpiece หรือ roberta-bpe';
  }

  @override
  String get engineTransformerMissingPaths =>
      'ไม่พบเส้นทางโมเดล Transformer หรือ tokenizer กรุณาดาวน์โหลดใหม่ในการจัดการโมเดล';

  @override
  String get engineTransformerMissingFiles =>
      'ไม่พบไฟล์โมเดล Transformer หรือ tokenizer กรุณาดาวน์โหลดใหม่ในการจัดการโมเดล';

  @override
  String engineTransformerOpsetUnsupported(Object variantId) {
    return 'เวอร์ชัน ONNX opset ไม่รองรับ（โมเดลเวอร์ชันนี้ใหม่เกินไป กรุณาอัปเดตแอป）: $variantId';
  }

  @override
  String engineTransformerTokenizerCorrupt(Object message) {
    return 'รูปแบบ tokenizer เสียหาย: $message';
  }

  @override
  String get engineTransformerRepairFailed =>
      'โหลดหรือประมวลผลโมเดลล้มเหลว และการซ่อมแซมอัตโนมัติไม่สำเร็จ กรุณาดาวน์โหลดโมเดล Transformer ที่ใช้งานอยู่และ tokenizer ใหม่ในการจัดการโมเดล';

  @override
  String get engineAdversarialNoActiveVariant =>
      'ไม่พบโมเดลตรวจจับการเขียนใหม่ที่ใช้งานอยู่';

  @override
  String get engineAdversarialMissingFiles =>
      'ไม่พบไฟล์โมเดลหรือ tokenizer กรุณาดาวน์โหลดใหม่ในการจัดการโมเดล';

  @override
  String get engineAdversarialRepairFailed =>
      'โหลดหรือประมวลผลโมเดลล้มเหลว และการซ่อมแซมอัตโนมัติไม่สำเร็จ กรุณาดาวน์โหลดโมเดลตรวจจับการเขียนใหม่และ tokenizer ใหม่ในการจัดการโมเดล';

  @override
  String engineReasonNotParticipatedWithError(Object error) {
    return 'โมเดลไม่ได้เข้าร่วมการโหวตนี้ $error';
  }

  @override
  String get patternNotAnalyzable =>
      'ส่วนนี้สั้นเกินไปหรือสงสัยว่าเป็นสัญญาณรบกวนจาก PDF/OCR จึงไม่ได้ประเมิน AI ระดับประโยค';

  @override
  String engineReasonTransformerLoadFailed(String error) {
    return 'โหลดโมเดลล้มเหลว จึงไม่ได้เข้าร่วมการโหวตครั้งนี้（$error）';
  }

  @override
  String engineReasonTransformerResult(String model, int aiCount, int total) {
    return '$model ตัดสินว่า $aiCount จาก $total ประโยคแสดงลักษณะ AI';
  }

  @override
  String get engineReasonAdversarialDetected =>
      'โมเดลต่อต้านตรวจพบร่องรอย AI ที่น่าสงสัยว่าผ่านการประมวลผลด้วยเครื่องมือเขียนใหม่（เช่น QuillBot / Undetectable.ai）';

  @override
  String get engineReasonAdversarialClean =>
      'ไม่พบร่องรอยการหลบเลี่ยงด้วยการเขียนใหม่ที่ชัดเจน';

  @override
  String get engineReasonGenericNotInstalled =>
      'ยังไม่ได้ติดตั้งโมเดล จึงไม่ได้เข้าร่วมการโหวตครั้งนี้';

  @override
  String patternGenericTransition(String word) {
    return 'คำเชื่อมทั่วไป \"$word\"';
  }

  @override
  String get helpAppBarTitle => 'คู่มือการใช้งาน';

  @override
  String get helpAboutTitle => 'เกี่ยวกับ TruthLens';

  @override
  String get helpAboutBody =>
      'TruthLens คือเครื่องมือตรวจเนื้อหา AI ที่ทำงาน**ภายในเบราว์เซอร์ของคุณทั้งหมด** เอนจินอิสระสี่ตัว ได้แก่ ตัวจำแนกโครงข่ายประสาท Transformer การวิเคราะห์เชิงสถิติ การวิเคราะห์สำนวน และการตรวจจับการเขียนใหม่เชิงปฏิปักษ์ จะลงคะแนนแบบถ่วงน้ำหนักว่าข้อความถูกสร้างโดย AI หรือไม่ และเอกสารของคุณจะไม่ถูกส่งออกไปไหน\n\nรายงานแสดงผลตัดสินเป็นความน่าจะเป็น AI โดยจัดเข้าห้าช่วงคงที่ (ต่ำกว่า 20%, 20–40%, 40–60%, 60–80%, 80% ขึ้นไป) พร้อมหลักฐานรายประโยค สัดส่วนที่แต่ละเอนจินมีส่วนร่วม หลักฐานที่มาของเอกสาร และชื่อไฟล์เมื่อนำเข้า จุดแบ่งช่วงปรับไม่ได้ ดังนั้นเอกสารเดียวกันจะอยู่ในช่วงเดิมเสมอ หากหลักฐานบางเกินไป (ประโยคหรือคำน้อยเกินไป หรือเอนจินขัดแย้งกันมาก) ระบบจะบอกตรง ๆ แทนที่จะฝืนให้คะแนน';

  @override
  String get helpComparisonTitle => 'การเปรียบเทียบกับเครื่องมือชั้นนำ';

  @override
  String get helpComparisonDisclaimer =>
      'การเปรียบเทียบนี้รวบรวมจากข้อมูลสาธารณะของแต่ละเครื่องมือและการรับรู้ทั่วไปในตลาด เพื่อใช้อ้างอิงด้านตำแหน่งทางการตลาดเท่านั้น ไม่ใช่ข้อมูลเปรียบเทียบประสิทธิภาพที่รับรองโดยบุคคลที่สาม';

  @override
  String get helpVsGptZeroTitle => 'เทียบกับ GPTZero';

  @override
  String get helpVsGptZero1 =>
      'GPTZero ประมวลผลส่วนใหญ่บนคลาวด์และต้องอัปโหลดเอกสาร ส่วน TruthLens รันเอนจินทั้งสี่ในเบราว์เซอร์ของคุณเอง และเนื้อหาไม่ถูกส่งไปที่ใดเลย';

  @override
  String get helpVsGptZero2 =>
      'ตัวชี้วัด Perplexity/Burstiness และการไฮไลต์ระดับประโยคที่ GPTZero เป็นผู้บุกเบิก TruthLens ได้นำมาใช้ พร้อมเสริมด้วยตัวจำแนก Transformer, การวิเคราะห์รูปแบบการเขียน และการป้องกันเชิงต่อต้าน ทำให้เกิดการโหวตแบบรวมกลุ่มสี่โมเดลแทนที่จะใช้ตัวชี้วัดเดียว';

  @override
  String get helpVsGptZero3 =>
      'GPTZero เป็นระบบสมัครสมาชิก ในขณะที่ TruthLens ไม่ต้องสมัครสมาชิกและไม่จำกัดจำนวนการใช้งาน';

  @override
  String get helpVsTurnitinTitle => 'เทียบกับ Turnitin';

  @override
  String get helpVsTurnitin1 =>
      'Turnitin จำหน่ายให้เฉพาะสถาบันเท่านั้น บุคคลทั่วไปไม่สามารถซื้อได้โดยตรง ในขณะที่ TruthLens ใครก็สามารถติดตั้งและใช้งานได้';

  @override
  String get helpVsTurnitin2 =>
      'กระบวนการตัดสินของ Turnitin ค่อนข้างเป็นกล่องดำ ในขณะที่ TruthLens ให้ความน่าจะเป็น AI รายประโยค รูปแบบการเขียนที่ตรงกัน และรายละเอียดคะแนนพร้อมเหตุผลของแต่ละเอนจินทั้งสี่';

  @override
  String get helpVsTurnitin3 =>
      'Turnitin ให้การตัดสินแบบสองทางเลือกว่า \"เป็น AI หรือไม่\" เป็นหลัก ในขณะที่ TruthLens รองรับการทำเครื่องหมายระดับย่อหน้า/ประโยคว่าเป็นมนุษย์/AI/ผสม';

  @override
  String get helpVsOriginalityTitle => 'เทียบกับ Originality.ai';

  @override
  String get helpVsOriginality1 =>
      'Originality.ai คิดค่าบริการรายชิ้นแบบสมัครสมาชิกและต้องอัปโหลดขึ้นคลาวด์ ส่วน TruthLens ทำงานหลักในเบราว์เซอร์ ไม่ต้องสมัครสมาชิกและไม่จำกัดจำนวนครั้ง';

  @override
  String get helpVsOriginality2 =>
      'Originality.ai มีแนวคิดการตรวจสอบข้อเท็จจริงและการวิเคราะห์ความอ่านง่าย TruthLens ตอบสนองด้วยโมดูลลักษณะการเขียนบนอุปกรณ์ และสามารถวิเคราะห์พื้นฐานได้แม้ออฟไลน์';

  @override
  String get helpVsCopyleaksTitle => 'เทียบกับ Copyleaks';

  @override
  String get helpVsCopyleaks1 =>
      'Copyleaks ใช้ API บนคลาวด์เป็นหลัก จุดแข็งคืออัตราผลบวกลวงต่ำและรองรับหลายภาษาได้ดี TruthLens ใช้แนวคิดเดียวกันด้วยโมเดลพื้นฐานหลายภาษา XLM-RoBERTa และการโหวตแบบรวมหลายโมเดล แต่เนื้อหาเอกสารจะไม่ถูกอัปโหลดไปยังเซิร์ฟเวอร์ใดๆ';

  @override
  String get helpVsCopyleaks2 =>
      'Copyleaks มีข้อจำกัดการใช้งาน API ขึ้นอยู่กับแผนบริการ ในขณะที่ TruthLens ไม่มีข้อจำกัดการใช้งาน';

  @override
  String get helpVsWinstonTitle => 'เทียบกับ Winston AI';

  @override
  String get helpVsWinston1 =>
      'OCR รูปภาพของ Winston AI จะอัปโหลดภาพขึ้นคลาวด์ ส่วน OCR ของ TruthLens จะใช้เซิร์ฟเวอร์ OCR ในเครื่องที่คุณตั้งค่าไว้ก่อน และจะใช้คลาวด์เป็นตัวสำรองก็ต่อเมื่อคุณให้คีย์ Gemini API เอง — จะใช้คลาวด์หรือไม่ขึ้นอยู่กับคุณ';

  @override
  String get helpVsWinston2 =>
      'Winston AI มีชื่อเสียงด้านการจัดวางรายงานที่สวยงาม TruthLens นำเสนอการสร้างรูปแบบรายงานแบบไดนามิกโดย AI（กลับไปใช้เทมเพลตอัตโนมัติเมื่อไม่ได้ติดตั้ง LLM）และสามารถส่งออกได้ทั้งสี่รูปแบบ PDF/CSV/JSON/PNG';

  @override
  String get helpAdvantagesTitle => 'จุดเด่นเฉพาะของ TruthLens';

  @override
  String get helpAdvantage1 =>
      'การตรวจสอบความถูกต้องของลิงก์: ตรวจสอบโดยอัตโนมัติว่า URL ในเอกสารสามารถเชื่อมต่อและมีอยู่จริงหรือไม่ ลิงก์วิชาการรูปแบบ DOI จะถูกตรวจสอบเพิ่มเติมกับข้อมูลทะเบียนสาธารณะของ Crossref เพื่อยืนยันว่าวารสารได้จัดทำดัชนีผลงานนั้นจริงหรือไม่';

  @override
  String get helpAdvantage2 =>
      'การตรวจสอบความถูกต้องของการอ้างอิง: แม้แต่การอ้างอิงที่ไม่มีลิงก์เลย（รูปแบบ \"ผู้แต่ง—ปี\" ล้วนๆ）ก็สามารถตรวจสอบกับทะเบียนบรรณานุกรมเพื่อจับการอ้างอิงที่น่าจะปลอมแปลงได้ ซึ่งเป็นสัญญาณทั่วไปของภาพหลอนจาก AI';

  @override
  String get helpAdvantage3 =>
      'การปรับแก้ความเอนเอียงสำหรับผู้ไม่ใช่เจ้าของภาษา (ESL): ตรวจจับลักษณะการเขียนของผู้ไม่ใช่เจ้าของภาษาโดยอัตโนมัติและลดน้ำหนักของโมเดลเชิงสถิติ เพื่อหลีกเลี่ยงการตัดสินงานเขียนตามธรรมชาติของผู้ไม่ใช่เจ้าของภาษาผิดว่าเป็น AI';

  @override
  String get helpAdvantage4 =>
      'การนำเข้าโมเดลแบบกำหนดเอง: ผู้ใช้ขั้นสูงสามารถนำเข้าโมเดล ONNX ในเครื่องของตนเองเพื่อแทนที่หรือเสริมเอนจินตรวจจับในตัว';

  @override
  String get helpWorkflowTitle => 'ขั้นตอนการทำงานแบบสมบูรณ์';

  @override
  String helpWorkflowStepLabel(int step) {
    return 'ขั้นตอน $step';
  }

  @override
  String get helpWorkflowStep1Title => 'การดาวน์โหลดและอัปเดตโมเดล';

  @override
  String get helpWorkflowStep1Body =>
      'แอปจะเปิดที่หน้าจอหลักเสมอ เมื่อเปิดใช้งานครั้งแรก หากยังไม่ได้ติดตั้งโมเดลตรวจจับใด ๆ จะมีข้อความถามว่าต้องการเลือกโมเดลหรือไม่ — หากปฏิเสธ คุณยังวิเคราะห์ได้ทันทีด้วยเอนจินเชิงสถิติและเชิงลีลาการเขียน คุณสามารถตรวจสอบ ดาวน์โหลด อัปเดต หรือลบโมเดลได้ตลอดเวลาจาก \"การตั้งค่า → การจัดการโมเดล AI\" แอปจะตรวจหาเวอร์ชันล่าสุดเมื่อเปิดใช้งาน และแสดงเครื่องหมายบนไอคอนการตั้งค่าและรายการ \"การจัดการโมเดล AI\" เมื่อมีการอัปเดต';

  @override
  String get helpWorkflowStep2Title => 'วิธีเลือกโมเดล（วัตถุประสงค์และผล）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'ตัวจำแนก AI หลายภาษา (น้ำหนัก 40%): วิเคราะห์บล็อกย่อหน้าที่กำหนดขอบเขตเพื่อรักษาบริบท แล้วจับคู่ค่าความน่าจะเป็นกลับไปยังแต่ละประโยคเพื่อให้หลักฐานโดยละเอียด เมื่อติดตั้งตัวจำแนกไว้หลายรุ่น การวิเคราะห์แต่ละครั้งจะเลือกรุ่นที่ผ่านการตรวจสอบสำหรับภาษาของเอกสาร — เอกสารภาษาจีนต้องใช้ตัวตรวจจับภาษาจีนสมัยใหม่โดยเฉพาะ และแอปจะแจ้งเตือนเมื่อยังไม่มีโมเดลนั้น';

  @override
  String get helpWorkflowStep2Bullet2 =>
      'เอนจินวิเคราะห์เชิงสถิติ（น้ำหนัก 25%）: การวิเคราะห์แบบหน้าต่างเลื่อนของความสับสนและ Burstiness เพื่อจับจังหวะที่สม่ำเสมอและการเลือกใช้คำที่คาดเดาได้ของข้อความ AI';

  @override
  String get helpWorkflowStep2Bullet3 =>
      'การวิเคราะห์รูปแบบการเขียน（น้ำหนัก 20%）: ความลื่นไหลของความหมาย รูปแบบประโยคซ้ำ การใช้คำเชื่อม มีความสามารถในการอธิบายสูงที่สุด เข้าใจ \"ทำไม\" ได้ง่ายที่สุด';

  @override
  String get helpWorkflowStep2Bullet4 =>
      'การป้องกันเชิงต่อต้าน（น้ำหนัก 15%）: ตรวจจับข้อความที่ผ่านการประมวลผลด้วยเครื่องมือเขียนใหม่（เช่น QuillBot, Undetectable.ai）';

  @override
  String get helpWorkflowStep2Bullet5 =>
      'LLM สำหรับสร้างรายงาน（ทางเลือก）: เมื่อติดตั้งแล้ว เนื้อหารายงานจะถูกสร้างแบบไดนามิกโดย LLM บนอุปกรณ์ หากไม่ได้ติดตั้งจะกลับไปใช้เทมเพลตคงที่โดยอัตโนมัติ ไม่ส่งผลกระทบต่อฟังก์ชันการวิเคราะห์';

  @override
  String get helpWorkflowStep2Bullet6 =>
      'สามารถเปิด/ปิดแต่ละเอนจินและปรับน้ำหนักของเอนจินได้ที่ \"การตั้งค่า\" ห้าช่วงผลตัดสินใช้จุดแบ่งคงที่ (20% / 40% / 60% / 80%) และเปลี่ยนไม่ได้ ดังนั้นเอกสารเดียวกันจะให้ผลตัดสินเหมือนกันสำหรับทุกคน';

  @override
  String get helpWorkflowStep3Title => 'การอัปโหลดเอกสาร';

  @override
  String get helpWorkflowStep3Body =>
      'มีสามวิธีนำเข้า: วางข้อความโดยตรง อ่านภาพด้วย OCR หรือนำเข้าเอกสาร (txt / md / pdf / docx / doc / odt) การนำเข้า PDF จะเทียบผลจากตัวแยกชั้นข้อความสองชุดและคัดข้อความเพี้ยนออก ส่วน PDF แบบสแกนจะอ่านทีละหน้าเมื่อมี OCR ให้ใช้ เมื่อนำเข้า ชื่อไฟล์จะปรากฏใต้หัวข้อช่องป้อนและอยู่บนบรรทัดของตัวเองในหัวข้อรายงาน หากวางหรือพิมพ์เอง ชื่อไฟล์จะเว้นว่าง\n\nOCR จะใช้เซิร์ฟเวอร์ในเครื่องที่คุณตั้งค่าก่อน และใช้คลาวด์เป็นตัวสำรองเฉพาะเมื่อคุณให้คีย์ Gemini API เอง';

  @override
  String get helpWorkflowStep4Title => 'เริ่มการวิเคราะห์';

  @override
  String get helpWorkflowStep4Body =>
      'แตะ \"เริ่มตรวจสอบ\" เอนจินทั้งสี่จะทำงานพร้อมกัน และหน้าจอจะแสดงความคืบหน้าของแต่ละเอนจินแบบเรียลไทม์ หากตรวจพบลักษณะการเขียนของผู้ไม่ใช่เจ้าของภาษา จะใช้การปรับแก้ ESL โดยอัตโนมัติ（สามารถปิดได้ในการตั้งค่า）';

  @override
  String get helpWorkflowStep5Title => 'การดูและส่งออกผลลัพธ์';

  @override
  String get helpWorkflowStep5Body =>
      'หน้ารายงานประกอบด้วย: มาตรวัดความน่าจะเป็น AI โดยรวม, แผนที่ความร้อนระดับประโยค, รายละเอียดคะแนนและเหตุผลของเอนจินทั้งสี่, ความถูกต้องของลิงก์, ความถูกต้องของการอ้างอิง สามารถส่งออกรายงาน PDF ฉบับสมบูรณ์, ข้อมูล CSV รายประโยค, JSON（สำหรับเชื่อมต่อระบบ）, การ์ดสรุป PNG（สำหรับแชร์） ผลการวิเคราะห์แต่ละครั้งจะถูกบันทึกใน \"ประวัติ\" โดยอัตโนมัติเพื่อให้ดูย้อนหลังได้ทุกเมื่อ';

  @override
  String get helpWorkflowStep1ChipOnboarding => 'เริ่มใช้งานครั้งแรก';

  @override
  String get helpWorkflowStep1ChipModelManager => 'จัดการโมเดล';

  @override
  String get helpWorkflowStep1ChipUpdateCheck => 'ตรวจอัปเดตอัตโนมัติ';

  @override
  String get helpWorkflowStep2ChipTransformer => 'Transformer (40%)';

  @override
  String get helpWorkflowStep2ChipStatistics => 'วิเคราะห์สถิติ (25%)';

  @override
  String get helpWorkflowStep2ChipStylometry => 'วิเคราะห์สำนวน (20%)';

  @override
  String get helpWorkflowStep2ChipAdversarial => 'ป้องกัน adversarial (15%)';

  @override
  String get helpWorkflowStep2ChipReportLlm => 'LLM รายงาน (เลือกได้)';

  @override
  String get helpWorkflowStep3ChipPaste => 'วางข้อความ';

  @override
  String get helpWorkflowStep3ChipImageOcr => 'OCR รูปภาพ';

  @override
  String get helpWorkflowStep3ChipImportFormats =>
      'PDF / DOCX / DOC / ODT / TXT / MD';

  @override
  String get helpWorkflowStep3ChipCodeFormulaIsolation => 'แยกโค้ด/สูตร';

  @override
  String get helpWorkflowStep4ChipEnsemble => 'อนุมาน 4 เอนจิน';

  @override
  String get helpWorkflowStep4ChipLiveProgress => 'ความคืบหน้าแบบสด';

  @override
  String get helpWorkflowStep4ChipEslCorrection => 'แก้ไข ESL';

  @override
  String get helpWorkflowStep4ChipStoppable => 'หยุดได้ทุกเมื่อ';

  @override
  String get helpWorkflowStep5ChipOverviewGauge => 'มาตรวัด AI รวม';

  @override
  String get helpWorkflowStep5ChipSentenceHeatmap => 'ฮีตแมปประโยค';

  @override
  String get helpWorkflowStep5ChipCitationVerification => 'ตรวจสอบการอ้างอิง';

  @override
  String get helpWorkflowStep5ChipExportFormats =>
      'ส่งออก PDF / CSV / JSON / PNG';

  @override
  String get helpTuningTitle =>
      'คู่มือการดาวน์โหลดและปรับแต่งโมเดล（สำหรับผู้เริ่มต้น）';

  @override
  String get helpTuningStep1Title => 'เปิดหน้าจัดการโมเดล';

  @override
  String get helpTuningStep1Body =>
      'จากหน้าหลัก แตะไอคอนฟันเฟืองเพื่อเข้า \"การตั้งค่า\" จากนั้นแตะ \"เปิด\" ข้าง \"การจัดการโมเดล AI\"';

  @override
  String get helpTuningStep2Title => 'เลือกโมเดลตามความสามารถของอุปกรณ์';

  @override
  String get helpTuningStep2Body =>
      'หน้าจอจะแนะนำระดับโมเดลที่เหมาะสมโดยอัตโนมัติตามประสิทธิภาพอุปกรณ์ของคุณ（RAM, จำนวนคอร์ CPU）และแสดงรายการตัวแปรทั้งหมดที่มีสำหรับแต่ละบทบาท（ตัวจำแนกหลายภาษา/การวิเคราะห์เชิงสถิติ/การป้องกันเชิงต่อต้าน/LLM สำหรับรายงาน）';

  @override
  String get helpTuningStep3Title => 'ดาวน์โหลดและใช้งาน';

  @override
  String get helpTuningStep3Body =>
      'แตะ \"ดาวน์โหลด\" ข้างโมเดลที่ต้องการและรอจนเสร็จ—โมเดลแรกที่ดาวน์โหลดจะถูกตั้งเป็นใช้งานโดยอัตโนมัติ หากมีหลายตัวแปรติดตั้งแล้ว สามารถแตะ \"ตั้งเป็นใช้งาน\" เพื่อสลับได้ทุกเมื่อ แตะไอคอนถังขยะเพื่อลบโมเดลที่ไม่ต้องการและเพิ่มพื้นที่ว่าง';

  @override
  String get helpTuningStep4Title => 'การอัปเดตโมเดล';

  @override
  String get helpTuningStep4Body =>
      'เมื่อมีเวอร์ชันใหม่ จะมีแบดจ์แจ้งเตือนปรากฏที่ \"การจัดการโมเดล AI\" และไอคอนฟันเฟืองการตั้งค่า กลับมาที่หน้าจอนี้เพื่อดูเวอร์ชันใหม่และดาวน์โหลดอัปเดต（เวอร์ชันเดิมจะยังคงอยู่เว้นแต่จะลบด้วยตนเอง）';

  @override
  String get helpTuningStep5Title => 'ขั้นสูง: การนำเข้าโมเดลแบบกำหนดเอง';

  @override
  String get helpTuningStep5Body =>
      'หากคุณมีโมเดล .onnx ที่เข้ากันได้อยู่แล้วหรือปรับแต่งเอง สามารถนำเข้าผ่าน \"การตั้งค่า → นำเข้าและทดสอบโมเดล ONNX แบบกำหนดเอง\" โดยต้องระบุไฟล์โมเดล การตั้งค่า Tokenizer ที่ตรงกัน（หรือเลือก \"ไม่ต้องการ\"）และดัชนีคลาส AI ก่อนนำเข้า ระบบจะตรวจสอบโดยอัตโนมัติว่าไฟล์เดียวกันนี้เคยถูกนำเข้าไปแล้วหรือไม่ เพื่อป้องกันการติดตั้งซ้ำโดยไม่ตั้งใจ';

  @override
  String get helpOfficialLinksTitle => 'ลิงก์ดาวน์โหลดโมเดลอย่างเป็นทางการ';

  @override
  String get helpOfficialLinksHint =>
      'การแตะรายการจะเปิดหน้าอย่างเป็นทางการของโมเดลนั้นในเบราว์เซอร์ของระบบ';

  @override
  String get helpLinkRoleTransformer =>
      'ตัวจำแนก AI หลายภาษา（Transformer, น้ำหนัก 40%）';

  @override
  String get helpLinkRoleStatistical =>
      'โมเดลสถิติความสับสน（Statistical, น้ำหนัก 25%）';

  @override
  String get helpLinkRoleAdversarial =>
      'โมเดลตรวจจับการเขียนใหม่เชิงต่อต้าน（Adversarial, น้ำหนัก 15%）';

  @override
  String get helpLinkRoleLlm => 'LLM สำหรับสร้างรายงาน（ทางเลือก）';

  @override
  String get privacyAppBarTitle => 'นโยบายความเป็นส่วนตัว';

  @override
  String privacyPlatformTitle(String platform) {
    return 'นโยบายความเป็นส่วนตัวสำหรับ $platform';
  }

  @override
  String privacyLastUpdated(String date) {
    return 'อัปเดตล่าสุด: $date';
  }

  @override
  String get privacyWebOverview1 =>
      'TruthLens ทำงานเป็นเว็บแอปทั้งหมดในแท็บเบราว์เซอร์ของคุณ ไม่ต้องติดตั้งใด ๆ ข้อความในเอกสารและผลการวิเคราะห์จะไม่ออกจากอุปกรณ์ของคุณ และโมเดลตรวจจับที่ดาวน์โหลดจะถูกแคชไว้ในที่จัดเก็บข้อมูลแบบแซนด์บ็อกซ์ของเบราว์เซอร์เอง（OPFS）เท่านั้น ไม่ใช่บนเซิร์ฟเวอร์ใด ๆ';

  @override
  String get privacyWebOverview2 =>
      'หน้านี้จะอ่านไฟล์ รูปภาพ หรือเนื้อหาคลิปบอร์ดเฉพาะเมื่อคุณเลือกที่จะนำเข้า สแกน หรือวางอย่างจริงจังเท่านั้น จะไม่อ่านแท็บอื่น ข้อมูลของเว็บไซต์อื่น หรือไฟล์ที่คุณไม่ได้เลือก';

  @override
  String get privacySectionOverviewWeb => 'ภาพรวม';

  @override
  String get privacyRemoveWeb =>
      'ล้างข้อมูลของเว็บไซต์นี้ในการตั้งค่าเบราว์เซอร์ของคุณ（หรือเพียงปิดแท็บ เนื่องจากไม่มีการจัดเก็บข้อมูลใด ๆ บนเซิร์ฟเวอร์）';

  @override
  String get privacyIosOverview1 =>
      'TruthLens ไม่เก็บรวบรวมข้อมูลใดๆ ที่เชื่อมโยงกับตัวตนของคุณ และไม่ใช้ข้อมูลใดๆ เพื่อการติดตาม จึงไม่จำเป็นต้องขอสิทธิ์ App Tracking Transparency (ATT)';

  @override
  String get privacyIosOverview2 =>
      'แอปนี้ใช้ตัวเลือกไฟล์ของระบบเพื่อเข้าถึงเอกสารหรือรูปภาพที่คุณเลือกเอง ไฟล์ที่คุณไม่ได้เลือกจะไม่สามารถเข้าถึงได้（ข้อจำกัดของ iOS App Sandbox）';

  @override
  String get privacyAndroidOverview1 =>
      'TruthLens ไม่เก็บรวบรวมข้อมูลส่วนบุคคล และไม่แบ่งปันข้อมูลผู้ใช้กับบุคคลที่สามใดๆ';

  @override
  String get privacyAndroidOverview2 =>
      'แอปนี้จะเข้าถึงสิทธิ์การจัดเก็บข้อมูลที่เกี่ยวข้องเฉพาะเมื่อคุณเลือกนำเข้าเอกสารหรือรูปภาพด้วยตนเองเท่านั้น จะไม่สแกนหรือเข้าถึงไฟล์อื่นในเบื้องหลัง';

  @override
  String get privacyMacosOverview1 =>
      'TruthLens ทำงานภายใต้ macOS App Sandbox และสามารถเข้าถึงได้เฉพาะไฟล์ที่คุณเลือกด้วยตนเองผ่านกล่องโต้ตอบไฟล์ของระบบ（files.user-selected.read-write）เท่านั้น ไม่สามารถเรียกดูหรือเข้าถึงไฟล์หรือโฟลเดอร์อื่นได้เอง';

  @override
  String get privacyMacosOverview2 =>
      'สิทธิ์การเข้าถึงเครือข่าย（network.client）ใช้เฉพาะสำหรับฟังก์ชันที่ระบุไว้ใน \"พฤติกรรมการเชื่อมต่อที่จำเป็น\" ด้านล่างเท่านั้น';

  @override
  String get privacyWindowsOverview1 =>
      'TruthLens เป็นแอปเดสก์ท็อปแบบสแตนด์อโลน ข้อมูลจัดเก็บในโฟลเดอร์ผู้ใช้ในเครื่องของคุณ（เช่น AppData／Documents）และจะไม่ซิงค์ไปยังคลาวด์';

  @override
  String get privacyWindowsOverview2 =>
      'แอปนี้จะเข้าถึงไฟล์ที่เกี่ยวข้องเฉพาะเมื่อคุณเลือกนำเข้าเอกสารหรือรูปภาพด้วยตนเองเท่านั้น จะไม่สแกนไฟล์อื่นในเบื้องหลัง';

  @override
  String get privacyDataHandling1 =>
      'TruthLens ไม่มีบัญชีผู้ใช้ ไม่ต้องเข้าสู่ระบบ และไม่มี SDK โฆษณาหรือการติดตามจากบุคคลที่สามในรูปแบบใดๆ';

  @override
  String get privacyDataHandling2 =>
      'เนื้อหาเอกสารที่คุณพิมพ์ วาง หรือนำเข้า จะถูกวิเคราะห์โดยโมเดล AI ในเครื่องบนอุปกรณ์ของคุณทั้งหมด จะไม่ถูกอัปโหลดไปยัง TruthLens หรือเซิร์ฟเวอร์บุคคลที่สามใดๆ';

  @override
  String get privacyDataHandling3 =>
      'ผลการวิเคราะห์และประวัติจะถูกจัดเก็บเฉพาะในฐานข้อมูลในเครื่องของอุปกรณ์คุณเท่านั้น การถอนการติดตั้งแอปหรือล้างประวัติจะลบข้อมูลเหล่านี้ทั้งหมด TruthLens จะไม่เก็บสำเนาไว้ที่ใดเลย';

  @override
  String get privacyNetworkIntro =>
      'การตรวจจับ AI หลักของแอปนี้ทำงานบนอุปกรณ์ทั้งหมด แต่ฟังก์ชันสามอย่างต่อไปนี้ต้องการการเชื่อมต่อเครือข่าย:';

  @override
  String get privacyNetwork1 =>
      '1. แคตตาล็อกโมเดลและการดาวน์โหลด: เชื่อมต่อกับ GitHub Releases／Hugging Face เพื่อดาวน์โหลดไฟล์โมเดลตรวจจับที่คุณเลือก เป็นเพียงการดาวน์โหลดโมเดลเท่านั้น จะไม่อัปโหลดข้อมูลผู้ใช้ใดๆ';

  @override
  String get privacyNetwork2 =>
      '2. การตรวจสอบการอัปเดตโมเดล: เมื่อเปิดใช้งานจะเชื่อมต่อเพื่อเปรียบเทียบหมายเลขเวอร์ชันเท่านั้น ใช้เพื่อแจ้งว่ามีเวอร์ชันใหม่หรือไม่';

  @override
  String get privacyNetwork3 =>
      '3. การตรวจสอบความถูกต้องของลิงก์และการอ้างอิง: เปิดใช้งานเป็นค่าเริ่มต้น สามารถปิดได้ใน \"การตั้งค่า\" เมื่อเปิดใช้งาน URL หรือข้อความบรรณานุกรมที่ตรวจพบในเอกสารจะถูกส่งไปยัง URL นั้นโดยตรงหรือ API สาธารณะของ Crossref โดยส่งเฉพาะข้อความ URL／DOI／บรรณานุกรมเท่านั้น ไม่รวมเนื้อหาอื่นในเอกสาร';

  @override
  String get privacyNetwork4 =>
      '4. ทางเลือกสำรอง Web OCR: เฉพาะเวอร์ชันเว็บเท่านั้น OCR จะใช้เซิร์ฟเวอร์ OCR ในเครื่องก่อนหากตั้งค่าไว้ หากคุณเลือกป้อนคีย์ Gemini API รูปภาพที่เลือกและหน้า PDF ที่แสดงผลซึ่งต้องใช้ OCR จะถูกส่งจากเบราว์เซอร์ของคุณโดยตรงไปยัง Gemini API ของ Google โดยคีย์จะถูกเก็บไว้ในที่จัดเก็บข้อมูลท้องถิ่นของเบราว์เซอร์นั้นเท่านั้น';

  @override
  String get privacyRightsIntro =>
      'คุณสามารถล้างประวัติการวิเคราะห์ในเครื่องได้ทุกเมื่อที่ \"ประวัติ\" หรือปิดฟังก์ชันตรวจสอบลิงก์／บรรณานุกรมได้ที่ \"การตั้งค่า\" หรือ';

  @override
  String get privacyRemoveIos => 'ลบแอปโดยตรง';

  @override
  String get privacyRemoveAndroid => 'ถอนการติดตั้งแอปโดยตรง';

  @override
  String get privacyRemoveMacos => 'ย้ายแอปไปที่ถังขยะโดยตรง';

  @override
  String get privacyRemoveWindows => 'ถอนการติดตั้งแอปโดยตรง';

  @override
  String get privacyDisclaimer =>
      'เนื้อหาในหน้านี้เป็นคำอธิบายด้านความเป็นส่วนตัวที่ TruthLens เขียนขึ้นตามพฤติกรรมการทำงานจริง ไม่ใช่เอกสารทางกฎหมายที่ผ่านการตรวจสอบโดยทนายความ หากต้องการการตรวจสอบการปฏิบัติตามกฎหมายอย่างเป็นทางการตามกฎหมายในภูมิภาคของคุณ แนะนำให้ปรึกษาที่ปรึกษากฎหมายมืออาชีพแยกต่างหาก';

  @override
  String get privacySectionOverviewIos =>
      'ภาพรวม（เทียบเท่ากับ \"ฉลากโภชนาการ\" ความเป็นส่วนตัวของ App Store）';

  @override
  String get privacySectionOverviewAndroid =>
      'ภาพรวม（เทียบเท่ากับการเปิดเผย \"ความปลอดภัยของข้อมูล\" ของ Google Play）';

  @override
  String get privacySectionOverviewMacos =>
      'ภาพรวม（คำอธิบายสิทธิ์ App Sandbox）';

  @override
  String get privacySectionOverviewWindows => 'ภาพรวม';

  @override
  String get privacySectionDataHandling => 'วิธีที่เราจัดการข้อมูลของคุณ';

  @override
  String get privacySectionNetwork => 'พฤติกรรมการเชื่อมต่อที่จำเป็น';

  @override
  String get privacySectionRights => 'สิทธิ์ของคุณ';

  @override
  String get privacyGenericPlatformName => 'แพลตฟอร์มนี้';

  @override
  String settingsVersionSubtitle(String version, String build) {
    return 'เวอร์ชัน $version (Build $build) · กลไกตรวจจับแบบเน้นการประมวลผลในเครื่อง';
  }

  @override
  String get webOcrSettingsTitle => 'การตั้งค่า Web OCR';

  @override
  String get webOcrPurpose =>
      'อ่านข้อความพิมพ์หรือลายมือในรูปภาพก่อนการวิเคราะห์';

  @override
  String get webOcrGeminiKeyTitle => 'คีย์ Gemini API (ไม่บังคับ)';

  @override
  String get webOcrGetKeyButton => 'รับคีย์';

  @override
  String get webOcrGeminiDescription =>
      'ใช้เมื่อเซิร์ฟเวอร์ OCR ในเครื่องไม่พร้อมเท่านั้น คีย์จะเก็บไว้ในเบราว์เซอร์นี้';

  @override
  String get webOcrLocalServerTitle => 'เซิร์ฟเวอร์ OCR ในเครื่อง (แนะนำ)';

  @override
  String get webOcrLocalServerDescription =>
      'เรียกใช้ OCR บนคอมพิวเตอร์ด้วย Apple Vision บน macOS หรือ Windows OCR บน Windows โปรดป้อนปลายทางในเครื่องด้านล่าง';

  @override
  String get webOcrSetupGuideButton => 'คู่มือการตั้งค่าสำหรับผู้เริ่มต้น';

  @override
  String get webOcrPriorityTitle => 'ลำดับการอ่านข้อความ';

  @override
  String get webOcrPriorityDescription =>
      '1. เซิร์ฟเวอร์ OCR ในเครื่องเมื่อกำหนด URL\n2. Gemini เมื่อกำหนดคีย์ API\n3. แสดงสาเหตุโดยละเอียดเมื่อทั้งสองวิธีล้มเหลว';

  @override
  String get webOcrSetupGuideTitle => 'ตั้งค่าเซิร์ฟเวอร์ OCR ในเครื่อง';

  @override
  String get webOcrSetupGuideBody =>
      '1. เลือก เปิดโครงการ OCR ด้านล่าง\n2. macOS: ดาวน์โหลด setup_and_run_ocr.sh เปิด Terminal แล้วรัน: bash ~/Downloads/setup_and_run_ocr.sh\n3. Windows: ดาวน์โหลด setup_and_run_ocr.bat ดับเบิลคลิกและอนุญาตการติดตั้ง\n4. รอจนตัวติดตั้งแจ้งว่า OCR พร้อมใช้งาน ระบบจะตั้งค่าเริ่มอัตโนมัติด้วย\n5. ป้อน http://127.0.0.1:5001/ocr แล้วเลือก ทดสอบการเชื่อมต่อ\n6. เปิด OCR รูปภาพและเลือกรูปที่ชัดเจนเพื่อทดสอบ\n\nเมื่อใช้ 127.0.0.1 เบราว์เซอร์และเซิร์ฟเวอร์ต้องทำงานบนคอมพิวเตอร์เครื่องเดียวกัน หากล้มเหลวให้ตรวจสอบการติดตั้ง พอร์ต 5001 และส่วนท้าย /ocr';

  @override
  String get webOcrOpenProjectButton => 'เปิดโครงการ OCR';

  @override
  String get webOcrTestServerButton => 'ทดสอบการเชื่อมต่อ';

  @override
  String get webOcrTestServerMissingUrl =>
      'โปรดป้อน URL เซิร์ฟเวอร์ OCR ในเครื่องก่อน';

  @override
  String get webOcrTestServerSuccess =>
      'เซิร์ฟเวอร์ OCR ในเครื่องทำงานและพร้อมใช้งาน';

  @override
  String get webOcrTestServerFailure =>
      'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ OCR ในเครื่อง โปรดตรวจสอบคู่มือ ไฟร์วอลล์ และ URL';

  @override
  String get workspaceModeSectionTitle => 'โหมดพื้นที่ทำงาน';

  @override
  String get workspaceModeSectionSubtitle =>
      'เลือกวิธีแสดงต้นฉบับ การวิเคราะห์สด และหลักฐานสุดท้ายในพื้นที่เดียวกัน';

  @override
  String get workspaceModeOriginal => 'รูปแบบดั้งเดิม';

  @override
  String get workspaceModeAuto => 'อัตโนมัติ';

  @override
  String get workspaceModeCommandGrid => 'ตารางบัญชาการ';

  @override
  String get workspaceModeTimeline => 'ไทม์ไลน์ภารกิจ';

  @override
  String get workspaceModeEvidence => 'ผืนผ้าใบหลักฐาน';

  @override
  String get workspaceModeCosmicFuture => 'อนาคตจักรวาล';

  @override
  String get workspaceModeSoftEducation => 'การศึกษาแบบอ่อนโยน';

  @override
  String get workspaceModeTooltip => 'สลับโหมดพื้นที่ทำงาน';

  @override
  String get workspaceMoreMenuTooltip => 'ตัวเลือกเพิ่มเติม';

  @override
  String get workspaceLanguageMenuTitle => 'ภาษา';

  @override
  String get workspaceStageImport => 'นำเข้า';

  @override
  String get workspaceStageParse => 'แยกข้อมูล';

  @override
  String get workspaceStageAnalyze => 'วิเคราะห์สี่เอนจิน';

  @override
  String get workspaceStageVerify => 'ตรวจสอบ';

  @override
  String get workspaceStageReport => 'รายงาน';

  @override
  String get workspaceLiveFindings => 'ผลที่พบสด';

  @override
  String get workspaceTelemetry => 'ข้อมูลการวิเคราะห์';

  @override
  String get workspaceDocument => 'พื้นที่เอกสาร';

  @override
  String get workspaceOverallProgress => 'ความคืบหน้ารวม';

  @override
  String workspaceProgressStatusSummary(
    Object current,
    Object stage,
    Object total,
  ) {
    return 'ขั้นตอน $current/$total · $stage';
  }

  @override
  String get workspaceWaiting => 'รอเอกสาร';

  @override
  String get workspaceAnalyzing => 'กำลังวิเคราะห์';

  @override
  String get workspaceAnalysisComplete => 'วิเคราะห์เสร็จแล้ว';

  @override
  String workspaceAnalysisActivity(
    Object done,
    Object engines,
    Object seconds,
    Object total,
  ) {
    return 'เสร็จแล้ว $done/$total โมดูล · ผ่านไป $seconds วินาที · กำลังทำงาน: $engines';
  }

  @override
  String workspaceAnalysisSlow(Object seconds) {
    return 'การวิเคราะห์ยังดำเนินอยู่และหน้าจอยังตอบสนอง ไม่มีโมดูลเสร็จในช่วง $seconds วินาทีที่ผ่านมา เอกสารขนาดใหญ่หรือโมเดลภายในเครื่องอาจใช้เวลานานขึ้น';
  }

  @override
  String get workspaceAnalysisFailed =>
      'การวิเคราะห์หยุดโดยไม่คาดคิด โปรดลองอีกครั้งหรือตรวจสอบการตั้งค่าโมเดล';

  @override
  String get workspaceNewAnalysis => 'การวิเคราะห์ใหม่';

  @override
  String get workspaceStopAnalysis => 'หยุดการวิเคราะห์';

  @override
  String get workspaceStopAnalysisTitle => 'หยุดการวิเคราะห์ปัจจุบันหรือไม่';

  @override
  String get workspaceStopAnalysisBody =>
      'การวิเคราะห์ยังดำเนินอยู่ ระบบจะเก็บข้อความเอกสารไว้ แต่จะไม่บันทึกผลลัพธ์ที่ยังไม่เสร็จ';

  @override
  String get workspaceAnalysisStopped =>
      'หยุดการวิเคราะห์แล้ว ข้อความเอกสารยังคงอยู่ในพื้นที่ทำงาน';

  @override
  String get workspaceSelectedEvidence => 'หลักฐานที่เลือก';

  @override
  String get workspaceNoEvidence =>
      'หลักฐานระดับประโยคจะแสดงเมื่อแต่ละเอนจินทำงานเสร็จ';

  @override
  String workspacePreliminaryVerdict(int percent) {
    return 'ความน่าจะเป็น AI เบื้องต้น: $percent%';
  }

  @override
  String get workspaceSentenceSignalTooltip =>
      'เปอร์เซ็นต์นี้คือสัญญาณ AI ของประโยคนี้เอง ไม่ใช่คำตัดสินโดยรวมของเอกสาร ค่าที่สูงกว่าหมายถึงรูปแบบถ้อยคำดูเหมือนสร้างโดย AI มากกว่า ค่าที่ต่ำกว่าหมายถึงอ่านดูเหมือนการเขียนของมนุษย์ทั่วไปมากกว่า รายงานฉบับสุดท้ายจะรวมทุกประโยคเข้ากับการถ่วงน้ำหนักของเอนจิน';

  @override
  String get workspaceSentenceSignalHeader => 'สัญญาณ AI ต่อประโยค';

  @override
  String get workspaceSentenceColumnHeader => 'ประโยค';

  @override
  String get workspaceAiEvidenceIndexShort => 'ดัชนี';

  @override
  String reportEngineRelationshipNoEvidence(String engine, int weight) {
    return '$engine ไม่พบหลักฐานในครั้งนี้ จึงไม่ได้ร่วมลงคะแนน (น้ำหนักบทบาท $weight%) หมายความว่าไม่พบร่องรอย AI ในแกนที่ตนรับผิดชอบ ไม่ได้แปลว่าเห็นว่าข้อความนี้เขียนโดยมนุษย์';
  }

  @override
  String reportEngineRelationshipDirectionalOnly(String engine, int weight) {
    return '$engine พบเพียงสัญญาณบอกทิศทางที่อ่อน จึงถูกลดน้ำหนักในการคัดกรองและไม่นับเป็นหลักฐานที่ผ่านเกณฑ์ (เพดานน้ำหนักบทบาท $weight%)';
  }

  @override
  String telemetrySummarySingleSource(String engine) {
    return 'ครั้งนี้มีเพียง $engine ที่พบหลักฐาน เอนจินอื่นไม่พบอะไรเลย ข้อสรุปจึงตั้งอยู่บนหลักฐานด้านเดียว กรุณาลดระดับความเชื่อมั่นตามนั้น';
  }

  @override
  String telemetrySummarySilentEngines(int count) {
    return 'มีอีก $count เอนจินที่ทำงานแต่ไม่พบหลักฐาน จึงถูกตัดออกจากการลงคะแนน เพื่อไม่ให้ \'ไม่มีอะไรจะรายงาน\' ถูกนับผิดเป็น \'ดูเหมือนมนุษย์เขียน\'';
  }

  @override
  String get engineReasonPplUncalibratedLanguage =>
      'ไม่ได้นำค่าความสับสนของโมเดลภาษามาคิดในเอกสารนี้ เนื่องจากโมเดลความสับสน (DistilGPT2) ฝึกด้วยภาษาอังกฤษเท่านั้น และกับข้อความจีน ญี่ปุ่น หรือเกาหลี มันวัดความคาดเดาได้ของไบต์ ไม่ใช่ของภาษา จากการวัดด้วยข้อมูลที่มีป้ายกำกับ พบว่ามันแยกงานเขียนของมนุษย์ออกจาก AI ได้ 0% การนำมาคิดจึงมีแต่จะสร้างผลบวกลวง';

  @override
  String settingsCalibrationByLanguage(String breakdown) {
    return 'ชุดฐานแยกตามภาษา: $breakdown';
  }

  @override
  String settingsCalibrationLegacySamples(int count) {
    return 'มีตัวอย่างเดิมอีก $count รายการที่ไม่มีการระบุภาษา จึงเข้าชุดฐานของภาษาใดไม่ได้ เนื่องจากไม่ได้เก็บข้อความต้นฉบับไว้ จึงย้อนกลับไปหาภาษาไม่ได้ ตัวอย่างเหล่านี้จะถูกแทนที่เมื่อมีการวิเคราะห์ใหม่';
  }

  @override
  String engineRoutedToBetterVariant(String variant, String language) {
    return 'เอกสารนี้เปลี่ยนไปใช้ \"$variant\" เนื่องจากตัวเลือกที่คุณเลือกยังไม่ได้ตรวจสอบกับ $language แต่ตัวนี้ตรวจสอบแล้ว';
  }

  @override
  String engineLanguageNotValidated(String variant, String language) {
    return '\"$variant\" เป็นโมเดลหลายภาษาแต่ยังไม่ได้ตรวจสอบกับ $language จึงควรถือว่าคะแนนเป็นหลักฐานที่อ่อนกว่าภาษาที่ตรวจสอบแล้ว';
  }

  @override
  String engineLanguageUnsupported(String variant, String language) {
    return '\"$variant\" ไม่ครอบคลุม $language คะแนนแสดงไว้เพื่ออ้างอิงเท่านั้น และไม่ควรถือเป็นหลักฐานในทิศทางใด';
  }

  @override
  String get engineReasonPplLanguageUndetermined =>
      'ไม่ได้นำค่าความสับสนของโมเดลภาษามาคิด เนื่องจากไม่สามารถระบุภาษาของเอกสารนี้ได้ จึงไม่มีเกณฑ์ที่ปรับเทียบไว้ให้เปรียบเทียบ การเดาภาษาจะทำให้ใช้มาตรวัดผิด ซึ่งเป็นความผิดพลาดที่การตรวจสอบนี้ต้องการป้องกัน';

  @override
  String engineReasonPplNoCalibrationForModel(String model, String language) {
    return 'ไม่ได้นำค่าความสับสนของโมเดลภาษามาคิด เนื่องจากโมเดลที่ใช้ (\"$model\") ยังไม่ได้วัดเกณฑ์สำหรับ $language หากไม่มีมาตรวัดที่ปรับเทียบไว้ ค่าดิบก็ไม่มีความหมาย จึงไม่นำมาคิดแทนที่จะเดา';
  }

  @override
  String get inputNoEditingRecordHint =>
      'รูปแบบนี้ไม่มีบันทึกการแก้ไข PDF รูปภาพ และข้อความที่วางมาไม่มีประวัติว่าเขียนขึ้นมาอย่างไร การวิเคราะห์จึงอาศัยสถิติของข้อความเพียงอย่างเดียว หากคุณหาไฟล์ต้นฉบับ .docx .odt หรือ .doc ได้ ประวัติการแก้ไขของมันเป็นหลักฐานที่หนักแน่นกว่ามาก และต่างจากสถิติข้อความตรงที่มันไม่อ่อนลงเมื่อโมเดลภาษาพัฒนาขึ้น';

  @override
  String get reportLowScoreNotProofOfHuman =>
      'คะแนนต่ำไม่ได้ยืนยันว่ามนุษย์เป็นผู้เขียน ครั้งนี้ไม่มีหลักฐานที่มา ผลตัดสินจึงอาศัยสถิติของข้อความเท่านั้น ซึ่งชี้ชัดงานเขียนแบบสูตรสำเร็จได้ดี แต่ชี้ไม่ได้กับผลลัพธ์ที่เขียนดีจากโมเดลรุ่นปัจจุบัน';

  @override
  String get reportProvenanceContradictsLowScore =>
      'บันทึกการแก้ไขของไฟล์เองขัดแย้งกับคะแนนต่ำนี้ หลักฐานที่มาไม่อ่อนลงเมื่อโมเดลภาษาพัฒนาขึ้น ขณะที่สถิติข้อความชี้ไม่ได้กับผลลัพธ์ที่เขียนดีจากโมเดลรุ่นปัจจุบัน กรุณาดูหลักฐานที่มาด้านล่างก่อนสรุปจากคะแนนด้านบน';

  @override
  String provenanceSignalConcentratedBatch(
    int paragraphs,
    int total,
    int percent,
  ) {
    return '$paragraphs จาก $total ย่อหน้าอยู่ในชุดการแก้ไขเดียวกันและมีสัดส่วน $percent% ของคำทั้งหมด ซึ่งสอดคล้องกับการที่ส่วนนั้นถูกเขียนหรือวางในคราวเดียว แม้ไฟล์จะมีชุดการแก้ไขอื่นก็ตาม';
  }

  @override
  String findingEvasionDetected(int count) {
    return 'พบร่องรอยการหลบเลี่ยงระดับอักขระ $count จุด (อักขระความกว้างศูนย์ ตัวอักษรหน้าตาเหมือนกัน หรืออักขระควบคุมทิศทาง) เครื่องมือเขียนทั่วไปไม่สร้างสิ่งเหล่านี้ มีผู้ประมวลผลข้อความเพื่อหลบการตรวจจับ';
  }

  @override
  String findingCitationsNotFound(int notFound, int total) {
    return 'จากงานที่อ้างอิง $total ชิ้น มี $notFound ชิ้นที่ไม่พบในฐานข้อมูลอ้างอิงใดเลยที่ตรวจสอบ การอ้างอิงที่กุขึ้นเป็นพฤติกรรมของโมเดลภาษา และต่างจากสำนวน ตรงที่การมีอยู่จริงของบทความเป็นข้อเท็จจริงที่ตรวจสอบได้';
  }

  @override
  String findingCitationsAllVerified(int total) {
    return 'งานที่อ้างอิงทั้ง $total ชิ้นพบในฐานข้อมูลสาธารณะครบถ้วน';
  }

  @override
  String findingEditingRecordNormal(int minutes, int revisions) {
    return 'ไฟล์บันทึกเวลาแก้ไข $minutes นาที จากการบันทึก $revisions ครั้ง ซึ่งสอดคล้องกับการที่ข้อความถูกเขียนขึ้นในเอกสารนี้';
  }

  @override
  String findingPublicationPredatesGenerativeAi(String doi, int year) {
    return 'DOI ต้นทาง $doi ตรงกับเอกสารนี้ และจดทะเบียนในปี $year ซึ่งก่อนระบบเขียนด้วย AI เชิงสร้างสรรค์สมัยใหม่';
  }

  @override
  String findingPublicationIdentityMismatch(String doi) {
    return 'DOI ต้นทาง $doi เปิดดูได้ แต่ชื่อเรื่องที่จดทะเบียนไว้ไม่ตรงกับเอกสารนี้ โปรดยืนยันตัวตนของเอกสารก่อนนำไปใช้อ้างอิง';
  }

  @override
  String get integratedStabilityUnavailable =>
      'ไม่มีข้อมูลความเสถียรระดับช่วง · ไม่มีหลักฐานระดับประโยคเข้าร่วมโหวต';

  @override
  String get integratedNeutralBaseline =>
      'ไม่พบหลักฐานเฉพาะด้านความเป็นผู้เขียนที่หนักแน่นพอจะยกระดับ ผลที่แสดงคือการคัดกรองเชิงทิศทางที่ดีที่สุดเท่าที่มี ไม่ใช่การอ้างว่าหลักฐานฝั่ง AI และมนุษย์เท่ากัน';

  @override
  String get reportVerifiableFindingsTitle => 'สิ่งที่ตรวจสอบได้';

  @override
  String get reportVerifiableFindingsSubtitle =>
      'แต่ละรายการด้านล่างตรวจสอบได้อย่างอิสระ ต่างจากค่าความน่าจะเป็น ตรงที่สิ่งเหล่านี้ไม่อ่อนลงเมื่อโมเดลภาษาพัฒนาขึ้น';

  @override
  String findingBulkPaste(int characters) {
    return 'ระหว่างการพิมพ์ มีการบันทึกการวางข้อความครั้งเดียวจำนวน $characters อักขระ โมเดลภาษาปลอมแปลงไม่ได้ว่าข้อความปรากฏในตัวแก้ไขอย่างไร ส่วนนี้ไม่ได้พิมพ์ขึ้นที่นี่';
  }

  @override
  String findingWrittenInApp(int minutes, int deleted) {
    return 'ข้อความถูกพิมพ์ในแอปนี้เป็นเวลา $minutes นาที และมีการแก้ไข $deleted อักขระระหว่างทาง การเขียนที่เกิดขึ้นที่นี่ทิ้งร่องรอยที่ไม่มีโมเดลภาษาใดสร้างซ้ำได้';
  }

  @override
  String get evidenceMatrixTitle => 'การประเมินจากหลักฐานหลายด้าน';

  @override
  String get evidenceMatrixSubtitle =>
      'แสดงหกแกนแยกจากกัน เฉพาะหลักฐานที่จำเพาะต่อความเป็นผู้เขียนเท่านั้นที่มีผลต่อคำวินิจฉัย ส่วนความครอบคลุมบอกว่าตรวจสอบอะไรได้บ้าง';

  @override
  String evidenceMatrixCoverage(int available, int total) {
    return 'ความครอบคลุมของหลักฐาน: $available จาก $total แกน';
  }

  @override
  String get evidenceAxisText => 'ร่องรอยการสร้างข้อความ';

  @override
  String get evidenceAxisTextNote =>
      'รูปแบบเชิงความน่าจะเป็นจากตัวตรวจจับในเครื่องทั้งสี่ตัว';

  @override
  String get evidenceAxisProcess => 'กระบวนการเขียน';

  @override
  String get evidenceAxisProcessNote =>
      'เหตุการณ์การพิมพ์ แก้ไข และวาง ที่บันทึกไว้โดยไม่เก็บเนื้อหา';

  @override
  String get evidenceAxisOrigin => 'ที่มาของเอกสาร';

  @override
  String get evidenceAxisOriginNote =>
      'เวลาที่ใช้แก้ไข จำนวนครั้งที่บันทึก และเมทาดาตา DOCX/ODT/RSID';

  @override
  String get evidenceAxisSources => 'ความถูกต้องของข้ออ้างและแหล่งที่มา';

  @override
  String get evidenceAxisSourcesNote =>
      'ข้ออ้างที่ตรวจสอบได้ จุดยึดการอ้างอิง และการตรวจสอบบรรณานุกรม';

  @override
  String get evidenceStateUnavailable => 'ไม่พร้อมใช้งาน';

  @override
  String get evidenceStateInconclusive => 'สรุปไม่ได้';

  @override
  String get evidenceStateReassuring => 'สอดคล้อง';

  @override
  String get evidenceStateConcern => 'ควรตรวจสอบ';

  @override
  String get evidenceStrengthNone => 'ไม่มีหลักฐาน';

  @override
  String get evidenceStrengthLimited => 'จำกัด';

  @override
  String get evidenceStrengthModerate => 'ปานกลาง';

  @override
  String get evidenceStrengthStrong => 'หนักแน่น';

  @override
  String get evidenceMatrixTextOnlyWarning =>
      'มีเพียงแกนรูปแบบข้อความที่ใช้ได้ AI รุ่นปัจจุบันเลียนแบบงานเขียนของมนุษย์ได้ รายงานนี้จึงไม่สามารถชี้ขาดความเป็นผู้เขียนจากคะแนนเพียงอย่างเดียว';

  @override
  String get evidenceMatrixStrongConcern =>
      'มีอย่างน้อยหนึ่งแกนอิสระที่ให้สัญญาณควรตรวจสอบอย่างหนักแน่น โปรดพิจารณาหลักฐานนั้นก่อนพึ่งพาคะแนนข้อความ';

  @override
  String findingUnsupportedClaims(int unsupported, int total) {
    return 'ข้ออ้างที่ตรวจสอบได้ $unsupported จาก $total ข้อ มีตัวเลข การเปรียบเทียบ หรือการอ้างถึงงานวิจัย โดยไม่มีจุดยึดแหล่งที่มาในประโยคเดียวกัน สิ่งนี้ไม่ได้พิสูจน์ว่าเป็นเท็จ แต่ชี้ว่าข้ออ้างใดควรตรวจสอบก่อน';
  }

  @override
  String get integratedAssessmentTitle =>
      'การประเมินความเป็นผู้เขียนแบบบูรณาการ';

  @override
  String get integratedInsufficientEvidence =>
      'ไม่มีสัญญาณความเป็นผู้เขียนที่วัดได้';

  @override
  String get integratedLikelyAi => 'มีแนวโน้มถูกสร้างโดย AI';

  @override
  String get integratedLikelyMixed => 'มีแนวโน้มเป็นงานผสมระหว่างมนุษย์กับ AI';

  @override
  String get integratedLikelyHuman => 'มีแนวโน้มไม่ได้ถูกสร้างโดย AI';

  @override
  String get integratedBalanced => 'ไม่พบสัญญาณที่ AI มีอิทธิพลเด่นชัด';

  @override
  String get integratedPreliminaryAi => 'ขณะนี้เอียงไปทาง AI ใกล้เส้นแบ่ง';

  @override
  String get integratedPreliminaryHuman =>
      'ขณะนี้เอียงไปทางมนุษย์ ใกล้เส้นแบ่ง';

  @override
  String integratedLikelihoodLabel(int percent) {
    return 'ดัชนีหลักฐาน AI: $percent/100';
  }

  @override
  String get integratedLikelihoodUnavailable =>
      'ดัชนีหลักฐาน AI: ประเมินไม่ได้';

  @override
  String integratedTextScoreLabel(int percent) {
    return 'คะแนนโมเดลข้อความ: $percent%';
  }

  @override
  String integratedConfidenceLabel(String confidence) {
    return 'ความเชื่อมั่น: $confidence';
  }

  @override
  String get integratedConfidenceLow => 'ต่ำ';

  @override
  String get integratedConfidenceModerate => 'ปานกลาง';

  @override
  String get integratedConfidenceHigh => 'สูง';

  @override
  String integratedEvidenceSufficiency(int percent, String tier) {
    return 'ความเพียงพอของหลักฐาน: $percent/100 · $tier';
  }

  @override
  String get integratedEvidenceTierScreening => 'การคัดกรองเบื้องต้น';

  @override
  String get integratedEvidenceTierReference => 'ระดับใช้อ้างอิงได้';

  @override
  String get integratedEvidenceTierStrong => 'มีหลักฐานรองรับดี';

  @override
  String integratedBoundaryAi(int index, int gap) {
    return 'ดัชนี $index เป็นเพียงทิศทางอ่อน ๆ ฝั่ง AI และยังต่ำกว่าเส้นยกระดับที่ 60 คะแนนอยู่ $gap คะแนน ยังไม่ได้พิสูจน์ว่า AI เป็นผู้เขียน';
  }

  @override
  String integratedBoundaryHuman(int index, int gap) {
    return 'ดัชนี $index เอียงไปทางมนุษย์ และยังต่ำกว่าเส้นยกระดับ AI ที่ 60 คะแนนอยู่ $gap คะแนน แต่หลักฐานที่จำกัดยังตัดความเป็นไปได้ที่ AI ช่วยเขียนไม่ได้';
  }

  @override
  String integratedEvidenceCoverage(int families, int coverage) {
    return 'กลุ่มสัญญาณบอกทิศทาง: $families/4 · ความครอบคลุมการใช้ได้ $coverage%';
  }

  @override
  String get integratedEvidenceGatePassed => 'ประตูหลักฐาน AI: ผ่าน';

  @override
  String get integratedEvidenceGateNotPassed =>
      'ประตูหลักฐาน AI: ไม่ผ่าน · เป็นเพียงการคัดกรองเชิงทิศทาง';

  @override
  String integratedQualifiedWarning(String reason) {
    return '$reason ระบบยังคงระบุทิศทางที่เป็นไปได้มากที่สุด แต่ความเชื่อมั่นลดลง โปรดถือเป็นผลการคัดกรอง ไม่ใช่ข้อพิสูจน์';
  }

  @override
  String get integratedIndexCaveat =>
      'ประตูหลักฐาน AI ที่แยกต่างหากบอกว่าหลักฐานอิสระหนักแน่นพอจะยกระดับหรือไม่ คุณภาพการอ้างอิง พฤติกรรมการวาง และเมทาดาตาที่น่าสงสัย ไม่สามารถให้คำวินิจฉัยว่าเป็น AI ได้ด้วยตัวเอง นี่คือคะแนนหลักฐาน ไม่ใช่ความน่าจะเป็นทางสถิติที่ปรับเทียบแล้ว';

  @override
  String get reportTextEngineSignalExplanation =>
      'แถบเหล่านี้แสดงสัญญาณเชิงวินิจฉัยจากเอนจินข้อความทั้งสี่ตัว เอนจินที่เกี่ยวข้องกันจะถูกรวมตามกลุ่ม รวมถึงผลลัพธ์ฝั่งมนุษย์จากตัวจำแนกที่ถูกลดน้ำหนักอย่างระมัดระวัง ก่อนจะนำความเหมาะสมด้านภาษา/สาขา และความน่าเชื่อถือของการปรับเทียบมาใช้ ทิศทางตอบว่าคำอธิบายใดมีหลักฐานรองรับมากกว่า ส่วนประตูหลักฐาน AI ที่แยกต่างหากตอบว่าหลักฐานนั้นหนักแน่นพอจะยกระดับหรือไม่';

  @override
  String reportSynthesisTextScoreContext(int percent) {
    return 'คะแนนดิบของโมเดลข้อความสี่เอนจิน: $percent% นี่คือข้อมูลนำเข้าหนึ่งของการประเมินแบบบูรณาการ ไม่ใช่คำวินิจฉัยที่สอง';
  }

  @override
  String reportSynthesisStrongestTextSignal(String label, int percent) {
    return 'สัญญาณเอนจินข้อความที่แรงที่สุด: $label ($percent%) สัญญาณนี้มีผลต่อคะแนนโมเดลข้อความได้ แต่ไม่สามารถล้มการประเมินแบบบูรณาการได้ด้วยตัวเอง';
  }

  @override
  String composerTextScoreThresholdReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'คะแนนดิบของโมเดลข้อความคือ $aiPercent% ซึ่งถึงเครื่องหมายเชิงวินิจฉัยที่ $thresholdPercent% นี่เป็นเพียงการสังเกตสัญญาณข้อความ ทิศทางความเป็นผู้เขียนของรายงานยังคงเป็นการประเมินแบบบูรณาการด้านบน';
  }

  @override
  String composerTextScoreThresholdNotReached(
    int aiPercent,
    int thresholdPercent,
  ) {
    return 'คะแนนดิบของโมเดลข้อความคือ $aiPercent% ซึ่งต่ำกว่าเครื่องหมายเชิงวินิจฉัยที่ $thresholdPercent% การไม่ถึงเครื่องหมายนี้ไม่ใช่หลักฐานว่ามนุษย์เป็นผู้เขียน ทิศทางความเป็นผู้เขียนของรายงานยังคงเป็นการประเมินแบบบูรณาการด้านบน';
  }

  @override
  String telemetryIntegratedVerdict(
    String direction,
    int percent,
    String confidence,
  ) {
    return 'หลังถ่วงน้ำหนักหลักฐานที่มี เอกสารนี้จัดเป็น “$direction” (ดัชนีหลักฐาน AI $percent/100, ความเชื่อมั่น $confidence)';
  }

  @override
  String telemetryIntegratedUnavailable(String direction, String confidence) {
    return 'โมดูลที่ใช้ได้ไม่ได้ให้ทิศทางความเป็นผู้เขียนที่วัดได้ (“$direction”, ความเชื่อมั่น $confidence) จึงไม่มีการออกดัชนีเชิงตัวเลข';
  }

  @override
  String integratedStabilityLabel(int percent, int lower, int upper) {
    return 'ความเสถียรระดับช่วง $percent% · ช่วง $lower–$upper%';
  }

  @override
  String integratedInputQualityLabel(int percent) {
    return 'คุณภาพการดึงข้อมูลนำเข้า: $percent%';
  }

  @override
  String integratedCalibrationLabel(String value, int count) {
    return 'เกณฑ์ฐานในเครื่องที่ตรงกัน: p=$value · n=$count';
  }

  @override
  String analysisReadinessLabel(String level) {
    return 'เกณฑ์ความเชื่อมั่นก่อนวิเคราะห์: $level';
  }

  @override
  String get analysisReadinessShortText => 'ต้องการข้อความเพิ่ม';

  @override
  String get analysisReadinessFewSentences => 'จำนวนช่วงข้อความน้อยเกินไป';

  @override
  String get analysisReadinessCoreModel => 'ตัวจำแนกหลักไม่พร้อมใช้งาน';

  @override
  String get analysisReadinessFewEngines => 'เปิดใช้เอนจินไม่ถึงสองตัว';

  @override
  String get analysisReadinessExtraction => 'คุณภาพการดึงข้อมูลจำกัด';

  @override
  String get analysisReadinessBaseline => 'ไม่มีเกณฑ์ฐานในเครื่องที่ตรงกัน';

  @override
  String get ocrChipLocalVerified => 'OCR ในเครื่อง (ตรวจสอบแล้ว)';

  @override
  String get ocrChipLocalUntested => 'OCR ในเครื่อง (ยังไม่ทดสอบ)';

  @override
  String get ocrChipGeminiVerified => 'Gemini (ตรวจสอบแล้ว)';

  @override
  String get ocrChipGeminiUntested => 'Gemini (ยังไม่ทดสอบ)';

  @override
  String get ocrChipNone => 'เครื่องมือ OCR: ยังไม่ได้ตั้งค่า';

  @override
  String ocrErrorLocalServerReported(String detail) {
    return 'เซิร์ฟเวอร์ OCR ในเครื่องรายงานข้อผิดพลาด: $detail';
  }

  @override
  String get ocrErrorLocalServerFormat =>
      'เซิร์ฟเวอร์ OCR ในเครื่องส่งรูปแบบการตอบกลับที่ไม่รองรับ โดยคาดว่าจะเป็นอาร์เรย์ของบล็อกข้อความ results[].text หรือ text';

  @override
  String get ocrErrorNoTextDetected =>
      'OCR เสร็จสิ้นแล้ว แต่ไม่พบข้อความที่ใช้งานได้ในภาพ';

  @override
  String ocrErrorLocalServerStatus(String status, String detail) {
    return 'เซิร์ฟเวอร์ OCR ในเครื่องตอบกลับ HTTP $status: $detail';
  }

  @override
  String ocrErrorLocalUnreachable(String detail) {
    return 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ OCR ในเครื่อง หรือคำขอหมดเวลา: $detail';
  }

  @override
  String get ocrErrorNotConfigured =>
      'ยังไม่ได้ตั้งค่า OCR โปรดใส่คีย์ Gemini API ในการตั้งค่า หรือระบุ URL ของเซิร์ฟเวอร์ OCR ในเครื่อง';

  @override
  String get ocrErrorGeminiNoParsableText =>
      'Gemini ตอบกลับแล้ว แต่ในการตอบกลับไม่มีข้อความที่อ่านได้';

  @override
  String get ocrErrorGeminiRateLimited =>
      'Gemini OCR ถึงขีดจำกัดอัตราหรือโควตา (429) โปรดลองใหม่ภายหลัง หรือเปลี่ยนไปใช้เซิร์ฟเวอร์ OCR ในเครื่อง';

  @override
  String ocrErrorGeminiBadRequest(String detail) {
    return 'Gemini OCR ปฏิเสธคำขอ (400): $detail';
  }

  @override
  String get ocrErrorGeminiUnauthorized =>
      'คีย์ Gemini API ไม่ถูกต้องหรือไม่ได้รับอนุญาต (401) โปรดวางคีย์ที่ถูกต้องอีกครั้ง';

  @override
  String ocrErrorGeminiHttpFailed(String status, String detail) {
    return 'Gemini OCR ล้มเหลว (HTTP $status): $detail';
  }

  @override
  String ocrErrorGeminiException(String detail) {
    return 'Gemini OCR เชื่อมต่อหรือแปลผลการตอบกลับไม่สำเร็จ: $detail';
  }

  @override
  String get ocrErrorNoImageData =>
      'ไม่ได้รับข้อมูลภาพ โปรดเลือกภาพอีกครั้ง หากยังล้มเหลว เบราว์เซอร์อาจไม่ได้ส่งข้อมูลไบต์ของไฟล์';

  @override
  String ocrErrorGeminiKeyInvalid(String status) {
    return 'คีย์ Gemini API ไม่ถูกต้องหรือไม่ได้รับอนุญาต (HTTP $status)';
  }

  @override
  String ocrErrorGeminiTestFailed(String status) {
    return 'การทดสอบการเชื่อมต่อ Gemini API ล้มเหลว (HTTP $status)';
  }

  @override
  String ocrErrorGeminiTestException(String detail) {
    return 'การทดสอบการเชื่อมต่อ Gemini API ล้มเหลว: $detail';
  }

  @override
  String get ocrErrorNativePluginNoPing =>
      'ปลั๊กอิน OCR ดั้งเดิมของแพลตฟอร์มนี้ไม่ตอบสนองต่อ ping';

  @override
  String get ocrErrorNativePluginMissing =>
      'แพลตฟอร์มนี้ยังไม่ได้ลงทะเบียนปลั๊กอิน OCR ดั้งเดิม';

  @override
  String ocrErrorNativeCheckFailed(String detail) {
    return 'การตรวจสอบปลั๊กอิน OCR ดั้งเดิมล้มเหลว: $detail';
  }

  @override
  String ocrErrorNativeFailed(String detail) {
    return 'OCR ดั้งเดิมทำงานล้มเหลว: $detail';
  }

  @override
  String get settingsEngineLlmTitle => 'LLM สร้างรายงาน';

  @override
  String get modelNameGemma2Llm => 'Gemma 2 · 2B Instruct (Q4_K_M)';

  @override
  String get firstRunModelListTitle => 'โมเดลที่จะดาวน์โหลด';

  @override
  String get firstRunModelOptionalReason =>
      'ตัวเลือกเสริม — มีผลต่อข้อความในรายงานเท่านั้น ไม่มีผลต่อผลการวิเคราะห์';

  @override
  String get firstRunModelStorageReason =>
      'อาจไม่พอดีกับพื้นที่จัดเก็บที่เบราว์เซอร์มีอยู่';

  @override
  String firstRunModelRamReason(String ramGb) {
    return 'ต้องใช้แรม $ramGb GB ซึ่งมากกว่าที่อุปกรณ์นี้รายงาน';
  }

  @override
  String firstRunModelSelectionSummary(int count, String size) {
    return 'เลือกแล้ว $count รายการ · รวม $size';
  }

  @override
  String get firstRunModelConfirm => 'ดาวน์โหลดรายการที่เลือก';

  @override
  String get firstRunModelCancel => 'ยกเลิก';

  @override
  String get firstRunModelManualTitle => 'ดาวน์โหลดโมเดลภายหลัง';

  @override
  String get firstRunModelManualBody =>
      'คุณดาวน์โหลดเองได้ทุกเมื่อ เปิด «การตั้งค่า» (ไอคอนรูปเฟืองบนแถบด้านบน) แล้วเลือก «การจัดการโมเดล AI» ในระหว่างนี้ TruthLens ยังทำงานได้ด้วยเครื่องมือเชิงสถิติและเชิงรูปแบบการเขียน';

  @override
  String get commonGotIt => 'เข้าใจแล้ว';
}
