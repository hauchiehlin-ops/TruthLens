import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/task_alignment.dart';

void main() {
  test('涵蓋題目核心概念且達到字數時為低風險', () {
    final result = TaskAlignment.analyze(
      'Discuss renewable energy storage policy in at least 100 words.',
      List.filled(
        30,
        'Renewable energy storage policy requires planning and investment.',
      ).join(' '),
    );
    expect(result.conceptCoverage, greaterThanOrEqualTo(0.5));
    expect(result.missesWordMinimum, isFalse);
    expect(result.risk, TaskAlignmentRisk.low);
  });

  test('完全離題會列高契合風險，但不推論作者', () {
    final result = TaskAlignment.analyze(
      '分析再生能源儲存政策、電網韌性與成本，至少 100 字。',
      List.filled(120, '這篇文章討論古典音樂與舞台表演。').join(),
    );
    expect(result.risk, TaskAlignmentRisk.high);
  });
}
