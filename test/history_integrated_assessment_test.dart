import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/history_repository.dart';
import 'package:truthlens/core/services/integrated_assessment.dart';

void main() {
  test('舊歷史資料沒有整合欄位時以原分數低信心回退', () {
    final entry = HistoryEntry.fromRow({
      'id': 'legacy',
      'analyzed_at': 0,
      'input_text': 'legacy text',
      'source_file_name': '',
      'ai_probability': 0.72,
      'verdict': 'likelyAi',
    });

    expect(entry.integratedAiLikelihood, 0.72);
    expect(entry.integratedDirection, IntegratedDirection.likelyAi);
    expect(entry.integratedConfidence, IntegratedConfidence.low);
  });

  test('新歷史資料保留分析當下的整合方向與信心', () {
    final entry = HistoryEntry.fromRow({
      'id': 'new',
      'analyzed_at': 0,
      'input_text': 'new text',
      'source_file_name': '',
      'ai_probability': 0.20,
      'verdict': 'likelyHuman',
      'integrated_likelihood': 0.81,
      'integrated_direction': 'likelyAi',
      'integrated_confidence': 'high',
    });

    expect(entry.integratedAiLikelihood, 0.81);
    expect(entry.integratedDirection, IntegratedDirection.likelyAi);
    expect(entry.integratedConfidence, IntegratedConfidence.high);
  });
}
