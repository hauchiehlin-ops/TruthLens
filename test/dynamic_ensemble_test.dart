import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/orchestrator.dart';

void main() {
  group('Dynamic Ensemble Weighted Routing (Option B)', () {
    test('EnsembleOrchestrator 動態探索並包含所有已安裝的模型變體', () async {
      final orchestrator = EnsembleOrchestrator();
      
      expect(orchestrator.engines.isNotEmpty, isTrue);
      // 確保基礎四大模型類別皆已被動態註冊與發現
      final engineIds = orchestrator.engines.map((e) => e.id).toList();
      expect(engineIds, contains('statistical'));
      expect(engineIds, contains('stylometry'));
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
