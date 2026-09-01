import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/history_metadata.dart';
import 'package:omnitrace/core/services/history_repository.dart';

void main() {
  group('歷史紀錄文件標題', () {
    test('匯入文件一律優先保存原始檔名，不顯示正文開頭', () {
      final title = resolveHistoryDocumentTitle(
        sourceFileName: '/imports/2010-Wet scrubber analysis.pdf',
        inputText: 'TECHNIQUES\nby W.M. Yang and H.C. Lin',
      );
      expect(title, '2010-Wet scrubber analysis.pdf');
    });

    test('直接貼上文字可辨識 Markdown 標題', () {
      final title = resolveHistoryDocumentTitle(
        inputText: '# Navigating the Crucible\n\nThe article begins here.',
      );
      expect(title, 'Navigating the Crucible');
    });

    test('長正文與下載提示不會冒充文件標題', () {
      expect(
        resolveHistoryDocumentTitle(
          inputText:
              'This article was downloaded by: [Lin, Hau-Chieh]\nThe article begins.',
        ),
        isEmpty,
      );
      expect(
        resolveHistoryDocumentTitle(
          inputText: List.filled(30, '這是一段匯入文件的正文內容，不應該顯示在歷史紀錄標題欄位。').join(),
        ),
        isEmpty,
      );
    });

    test('舊歷史資料沒有 document_title 時以檔名相容回退', () {
      final entry = HistoryEntry.fromMap({
        'id': 'legacy',
        'analyzed_at': 0,
        'input_text': 'A body paragraph that should remain hidden.',
        'source_file_name': 'legacy-paper.docx',
        'ai_probability': 0.35,
        'verdict': 'likelyHuman',
        'integrated_likelihood': 0.35,
        'integrated_direction': 'likelyHuman',
        'integrated_confidence': 'moderate',
      });
      expect(entry.documentTitle, 'legacy-paper.docx');
      expect(entry.matchesMetadata('legacy-paper'), isTrue);
      expect(entry.matchesMetadata('body paragraph'), isFalse);
    });
  });
}
