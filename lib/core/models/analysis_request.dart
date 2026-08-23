import '../services/writing_session.dart';
import '../services/document_provenance.dart';
import 'input_quality.dart';

class AnalysisRequest {
  final String text;
  final String sourceFileName;

  /// 使用者若直接在應用程式內輸入，這裡帶著寫作過程的紀錄。
  /// 匯入檔案時為空——那份文字不是在這裡寫的。
  final WritingSession writingSession;

  /// 匯入原始文件時解析出的編輯紀錄。必須跟著請求進入工作台，否則舊版
  /// 輸入頁雖然成功解析 DOCX／ODT，分析結果仍會退回「沒有來源證據」。
  final DocumentProvenance provenance;

  final InputQualityEvidence inputQuality;

  const AnalysisRequest({
    required this.text,
    this.sourceFileName = '',
    this.writingSession = WritingSession.empty,
    this.provenance = DocumentProvenance.none,
    this.inputQuality = InputQualityEvidence.directText,
  });
}
