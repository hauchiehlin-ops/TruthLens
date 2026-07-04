import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:truthlens/core/detection/onnx_detector.dart';
import 'package:truthlens/core/detection/perplexity_scorer.dart';
import 'package:truthlens/core/utils/text_stats.dart';

/// 真實 ONNX 推論效能基準（macOS），對照 implementation_plan.md 第十節：
///   500 字 < 5 秒、5000 字 < 30 秒。
/// 需先把 distilbert（verify_model）與 distilgpt2（verify_gpt2）放進沙盒容器。
String _text(int chars) {
  const pool = [
    'Artificial intelligence is transforming how we work and communicate today. ',
    'It is important to note that these advancements bring both benefits and risks. ',
    'Furthermore, careful evaluation is required before any large-scale deployment. ',
    'Researchers continue to study the long term effects of these systems. ',
  ];
  final buf = StringBuffer();
  var i = 0;
  while (buf.length < chars) {
    buf.write(pool[i % pool.length]);
    i++;
  }
  return buf.toString().substring(0, chars);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> bench(int chars, int budgetSeconds) async {
    final support = await getApplicationSupportDirectory();
    final modelPath = p.join(support.path, 'models', 'verify_model.onnx');
    final gpt2Path = p.join(support.path, 'models', 'verify_gpt2.onnx');
    if (!File(modelPath).existsSync() || !File(gpt2Path).existsSync()) {
      markTestSkipped('容器內缺少模型；跳過');
      return;
    }
    final detector = await OnnxDetector.load(
      modelPath: modelPath,
      tokenizerJsonPath: p.join(support.path, 'models', 'verify_tokenizer.json'),
    );
    final scorer = await PerplexityScorer.load(
      modelPath: gpt2Path,
      tokenizerJsonPath:
          p.join(support.path, 'models', 'verify_gpt2_tokenizer.json'),
    );

    final text = _text(chars);
    final sentences = PreprocessedText.from(text).sentences;

    final sw = Stopwatch()..start();
    await detector.classifySentences(sentences); // 子模型 A
    await scorer.perplexity(text); // 子模型 B
    sw.stop();

    detector.dispose();
    scorer.dispose();

    final secs = sw.elapsedMilliseconds / 1000;
    // ignore: avoid_print
    print('[$chars 字 / ${sentences.length} 句] 分類+困惑度 = '
        '${secs.toStringAsFixed(2)}s（目標 < ${budgetSeconds}s）');
    expect(secs, lessThan(budgetSeconds));
  }

  test('500 字真實推論 < 5 秒', () => bench(500, 5));
  test('5000 字真實推論 < 30 秒', () => bench(5000, 30));
}
