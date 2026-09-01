import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/orchestrator.dart';

void main() {
  group('Dynamic Ensemble Weighted Routing (Option B)', () {
    test('EnsembleOrchestrator 每個模型角色只註冊一個使用中變體', () async {
      final orchestrator = EnsembleOrchestrator();

      expect(orchestrator.engines.isNotEmpty, isTrue);
      final engineIds = orchestrator.engines.map((e) => e.id).toList();
      final transformerCount = engineIds
          .where((id) => id.startsWith('transformer'))
          .length;
      final adversarialCount = engineIds
          .where((id) => id.startsWith('adversarial'))
          .length;

      expect(transformerCount, 1);
      expect(engineIds, contains('statistical'));
      expect(engineIds, contains('stylometry'));
      expect(adversarialCount, 1);
    });

    test('多模型句子級評分平均計算正確', () async {
      final result = await EnsembleOrchestrator().analyze(
        'This is a sample test paragraph written to test dynamic sentence scoring. '
        'Artificial intelligence is advancing rapidly every single day.',
      );

      expect(result.sentences.length, 2);
      for (final s in result.sentences) {
        expect(s.aiProbability, inInclusiveRange(0.0, 1.0));
      }
    });
  });
}
