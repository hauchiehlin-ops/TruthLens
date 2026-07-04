import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:truthlens/core/detection/model_manager.dart';
import 'package:truthlens/core/detection/orchestrator.dart';

/// 端到端驗證：匯入本機模型 → 完整集成分析 → Transformer 引擎真的參與投票。
/// 驗證合併後的 orchestrator（並行）+ transformer_engine + importLocalModel 串接無誤。
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test('匯入模型後完整分析：Transformer 引擎參與且產出逐句分數', () async {
    final support = await getApplicationSupportDirectory();
    final modelFile =
        File(p.join(support.path, 'models', 'verify_model.onnx'));
    final tokFile =
        File(p.join(support.path, 'models', 'verify_tokenizer.json'));
    if (!modelFile.existsSync() || !tokFile.existsSync()) {
      markTestSkipped('容器內缺少 distilbert 模型；跳過');
      return;
    }

    final mm = ModelManager();
    await mm.importLocalModel(
      role: 'transformer',
      name: '測試匯入模型',
      modelFile: modelFile,
      tokenizerFile: tokFile,
      tokenizerType: 'bert-wordpiece',
      aiLabelIndex: 1,
    );
    expect(mm.activeVariant('transformer'), isNotNull);

    final orchestrator = EnsembleOrchestrator(modelManager: mm);
    final result = await orchestrator.analyze(
      'It is important to note that artificial intelligence is transforming '
      'industries. Furthermore, these advancements offer significant benefits. '
      'In conclusion, we must adapt accordingly.',
    );

    final transformer =
        result.engineScores.firstWhere((s) => s.engineId == 'transformer');
    expect(transformer.available, isTrue,
        reason: 'Transformer 引擎應已載入匯入的模型並參與投票');
    expect(transformer.sentenceScores, isNotNull);
    expect(result.aiProbability, inInclusiveRange(0.0, 1.0));

    // 清理：移除測試匯入的變體
    await mm.removeVariant('transformer', mm.activeVariant('transformer')!.variantId);
    // ignore: avoid_print
    print('完整分析 → 整體 AI:${result.aiProbability} '
        'transformer:${transformer.aiProbability}');
  });
}
