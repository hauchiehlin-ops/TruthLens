import '../services/writing_session.dart';

class AnalysisRequest {
  final String text;
  final String sourceFileName;

  /// 使用者若直接在應用程式內輸入，這裡帶著寫作過程的紀錄。
  /// 匯入檔案時為空——那份文字不是在這裡寫的。
  final WritingSession writingSession;

  const AnalysisRequest({
    required this.text,
    this.sourceFileName = '',
    this.writingSession = WritingSession.empty,
  });
}
