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
  String get settingsThresholdTitle => 'เกณฑ์ความเชื่อมั่นในการตัดสิน AI';

  @override
  String settingsThresholdSubtitle(int percent) {
    return 'ปัจจุบัน: $percent% — เพิ่มค่านี้เพื่อลดผลบวกลวง（การตัดสินบทความมนุษย์ผิดว่าเป็น AI）';
  }

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
  String get settingsLanguagePackTitle => 'แพ็กภาษา';

  @override
  String get settingsLanguagePackSubtitle =>
      'โมเดลปรับแต่งภาษาเพิ่มเติม（เปิดให้ใช้ในระยะที่ 4）';

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
  String get reportEngineBreakdownTitle => 'รายละเอียดเอนจิน';

  @override
  String get reportEngineNotInstalled => 'ยังไม่ได้ติดตั้ง';

  @override
  String get reportSentenceAnalysisTitle => 'การวิเคราะห์ระดับประโยค';

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
  String get reportBibResultHint =>
      'จับคู่กับข้อมูลทะเบียนสาธารณะของ Crossref โดยใช้ความคล้ายคลึงของผู้แต่ง ปี และชื่อเรื่อง ไม่ใช่การรับประกันที่แน่นอน หากผลลัพธ์ \"ไม่แน่ใจ\" แนะนำให้ตรวจสอบด้วยตนเอง';

  @override
  String reportBibHighConfidence(String journal) {
    return 'ความเชื่อมั่นสูง: น่าจะมีอยู่จริง$journal';
  }

  @override
  String reportBibJournalSuffix(String journal) {
    return '（ลงทะเบียนกับ $journal）';
  }

  @override
  String get reportBibNotFound =>
      'ไม่พบรายการที่ใกล้เคียง อาจเป็นบรรณานุกรมที่ปลอมแปลง';

  @override
  String get reportBibUncertain =>
      'ความคล้ายคลึงปานกลางหรือการเชื่อมต่อล้มเหลว ไม่แน่ใจ แนะนำให้ตรวจสอบด้วยตนเอง';

  @override
  String reportBibTruncated(int max, int count) {
    return 'ตรวจสอบเฉพาะ $max รายการแรก（ตรวจพบทั้งหมด $count รายการ）';
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
    return 'ความน่าจะเป็น AI โดยรวมเกินเกณฑ์ $percent% ที่คุณตั้งไว้ และถูกทำเครื่องหมายว่าเป็น AI';
  }

  @override
  String composerThresholdNotFlagged(int percent) {
    return 'ความน่าจะเป็น AI โดยรวมต่ำกว่าเกณฑ์ $percent% ที่คุณตั้งไว้';
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
  String engineReasonTtrLow(String value) {
    return 'ความหลากหลายของคำศัพท์ต่ำ（TTR $value）มีการซ้ำคำสูง';
  }

  @override
  String engineReasonTtrHigh(String value) {
    return 'ความหลากหลายของคำศัพท์สูง（TTR $value）';
  }

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
  String get engineReasonAdversarialNotInstalled =>
      'ยังไม่ได้ติดตั้งโมเดลตรวจจับการเขียนใหม่ จึงไม่ได้เข้าร่วมการโหวตครั้งนี้';

  @override
  String get engineReasonTransformerNotInstalled =>
      'ยังไม่ได้ติดตั้งโมเดล หรือโมเดลที่ใช้งานไม่รองรับ จึงไม่ได้เข้าร่วมการโหวตครั้งนี้';

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
  String get engineReasonDisabledByUser => 'ผู้ใช้ปิดเอนจินนี้ในการตั้งค่า';

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
      'TruthLens เป็นแอปตรวจจับเนื้อหาข้ามแพลตฟอร์มที่การอนุมาน AI หลักทำงานบนอุปกรณ์ทั้งหมด（iOS / Android / macOS / Windows） โดยใช้โมเดลย่อยอิสระสี่ตัว ได้แก่ ตัวจำแนกโครงข่ายประสาทเทียม Transformer, การวิเคราะห์เชิงสถิติ, การวิเคราะห์รูปแบบการเขียน และการตรวจจับการเขียนใหม่เชิงต่อต้าน ร่วมกันโหวตแบบถ่วงน้ำหนักเพื่อตัดสินว่าข้อความสร้างโดย AI หรือไม่ พร้อมให้เหตุผลการวิเคราะห์ที่อธิบายได้ทีละประโยค ไม่ใช่แค่แสดงเปอร์เซ็นต์ว่า \"ดูเหมือน AI\" แต่อธิบายว่า \"ทำไม\"';

  @override
  String get helpComparisonTitle => 'การเปรียบเทียบกับเครื่องมือชั้นนำ';

  @override
  String get helpComparisonDisclaimer =>
      'การเปรียบเทียบนี้รวบรวมจากข้อมูลสาธารณะของแต่ละเครื่องมือและการรับรู้ทั่วไปในตลาด เพื่อใช้อ้างอิงด้านตำแหน่งทางการตลาดเท่านั้น ไม่ใช่ข้อมูลเปรียบเทียบประสิทธิภาพที่รับรองโดยบุคคลที่สาม';

  @override
  String get helpVsGptZeroTitle => 'เทียบกับ GPTZero';

  @override
  String get helpVsGptZero1 =>
      'การประมวลผลของ GPTZero ส่วนใหญ่ทำงานบนคลาวด์และต้องอัปโหลดเอกสาร ในขณะที่เอนจินตรวจจับทั้งสี่ของ TruthLens ทำงานบนอุปกรณ์ทั้งหมด';

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
      'Originality.ai เป็นระบบสมัครสมาชิกคิดค่าบริการตามเอกสาร และต้องอัปโหลดเอกสารขึ้นคลาวด์ ในขณะที่การประมวลผลหลักของ TruthLens ทำงานบนอุปกรณ์ ไม่ต้องเสียค่าใช้จ่ายต่อเนื่องเพื่อใช้ฟังก์ชันตรวจจับ';

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
      'การรู้จำรูปภาพด้วย OCR ของ Winston AI ต้องอัปโหลดรูปภาพขึ้นคลาวด์ ในขณะที่ TruthLens ใช้เฟรมเวิร์กดั้งเดิมของแต่ละแพลตฟอร์ม（Vision บน iOS/macOS, ML Kit บน Android, Windows.Media.Ocr บน Windows）เพื่อรู้จำบนอุปกรณ์';

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
  String get helpWorkflowStep1Title => 'การดาวน์โหลดและอัปเดตโมเดล';

  @override
  String get helpWorkflowStep1Body =>
      'การเปิดใช้งานครั้งแรกจะแนะนำการติดตั้งโมเดลตรวจจับหลัก หลังจากนั้นสามารถตรวจสอบ ดาวน์โหลด อัปเดต หรือลบได้ทุกเมื่อจาก \"การตั้งค่า → การจัดการโมเดล AI\" แอปจะตรวจสอบเวอร์ชันล่าสุดโดยอัตโนมัติเมื่อเปิดใช้งาน หากมีการอัปเดต จะมีแบดจ์แจ้งเตือนปรากฏที่ไอคอนฟันเฟืองการตั้งค่าและรายการ \"การจัดการโมเดล AI\"';

  @override
  String get helpWorkflowStep2Title => 'วิธีเลือกโมเดล（วัตถุประสงค์และผล）';

  @override
  String get helpWorkflowStep2Bullet1 =>
      'ตัวจำแนก AI หลายภาษา（น้ำหนัก 40%）: แกนหลักของการตัดสินโดยรวม ทำนายความน่าจะเป็น AI ระดับประโยค ส่งผลต่อการเพิ่มความแม่นยำมากที่สุด';

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
      'สามารถเปิด/ปิดแต่ละเอนจินและปรับเกณฑ์ความเชื่อมั่นในการตัดสิน AI ได้ที่ \"การตั้งค่า\"（การเพิ่มค่าจะลดโอกาสตัดสินบทความมนุษย์ผิดว่าเป็น AI）';

  @override
  String get helpWorkflowStep3Title => 'การอัปโหลดเอกสาร';

  @override
  String get helpWorkflowStep3Body =>
      'มีสามวิธีในการป้อนข้อมูล: วางข้อความโดยตรง, OCR รูปภาพ（รู้จำแบบออฟไลน์ด้วยเฟรมเวิร์กดั้งเดิมของแต่ละแพลตฟอร์ม）, นำเข้าไฟล์（txt / md / pdf / docx / doc） ข้อความต้องมีอย่างน้อย 40 ตัวอักษรจึงจะส่งวิเคราะห์ได้';

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
}
