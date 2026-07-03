import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:truthlens/core/detection/onnx_detector.dart';
import 'package:truthlens/core/detection/perplexity_scorer.dart';

/// 在真實裝置/桌面上（原生 ONNX Runtime 可用）驗證端上推論。
/// 使用本地訓練的 distilbert-multilingual INT8 模型。
///
/// 執行：flutter test integration_test/onnx_detector_test.dart -d macos
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // 本地驗證用。模型須先放入 App 沙盒容器（模擬「下載到容器」的正式流程）：
  //   DEST=~/Library/Containers/com.truthlens.truthlens/Data/Library/Application\ Support/truthlens/models
  //   cp training/artifacts/detector_int8.onnx "$DEST/verify_model.onnx"
  //   cp training/artifacts/classifier/tokenizer.json "$DEST/verify_tokenizer.json"

  test('ONNX Runtime 端上推論：載入模型並分類中英文', () async {
    final support = await getApplicationSupportDirectory();
    final modelPath = p.join(support.path, 'models', 'verify_model.onnx');
    final tokenizerPath =
        p.join(support.path, 'models', 'verify_tokenizer.json');
    expect(File(modelPath).existsSync(), isTrue,
        reason: '請先把模型複製進沙盒容器（見檔案上方註解）');

    final detector = await OnnxDetector.load(
      modelPath: modelPath,
      tokenizerJsonPath: tokenizerPath,
    );

    // 典型 AI 風格（正式、過渡詞堆疊）vs 人類口語
    const aiText =
        'It is important to note that artificial intelligence is transforming '
        'various industries. Furthermore, these advancements offer significant '
        'benefits. In conclusion, we must adapt to these changes accordingly.';
    const humanText =
        'ugh my train was late again lol, ended up walking half way and my '
        'coffee spilled everywhere. what a morning honestly.';

    final aiProb = await detector.classify(aiText);
    final humanProb = await detector.classify(humanText);
    final zhProb =
        await detector.classify('人工智慧正在深刻地改變我們的生活與工作方式。');

    // 機率合法
    for (final p in [aiProb, humanProb, zhProb]) {
      expect(p, inInclusiveRange(0.0, 1.0));
    }
    // 中文也能推論（不崩潰、產出合法機率）
    expect(zhProb, inInclusiveRange(0.0, 1.0));
    // 方向性：AI 風格文本的 AI 機率高於人類口語
    expect(aiProb, greaterThan(humanProb),
        reason: 'AI=$aiProb human=$humanProb');

    detector.dispose();
    // ignore: avoid_print
    print('WordPiece 推論 → AI:$aiProb human:$humanProb zh:$zhProb');
  });

  test('RoBERTa BPE 端上推論（若容器內有模型）', () async {
    final support = await getApplicationSupportDirectory();
    final modelPath = p.join(support.path, 'models', 'verify_roberta.onnx');
    final tokPath =
        p.join(support.path, 'models', 'verify_roberta_tokenizer.json');
    if (!File(modelPath).existsSync()) {
      markTestSkipped('容器內無 roberta 模型；跳過');
      return;
    }
    final detector = await OnnxDetector.load(
      modelPath: modelPath,
      tokenizerJsonPath: tokPath,
      tokenizerType: 'roberta-bpe',
      aiLabelIndex: 0, // roberta-openai-detector：index 0 = fake/AI
    );
    final p1 = await detector.classify(
        'The quick brown fox jumps over the lazy dog near the river bank.');
    expect(p1, inInclusiveRange(0.0, 1.0));
    detector.dispose();
    // ignore: avoid_print
    print('RoBERTa BPE 推論成功 → prob:$p1');
  });

  test('DistilGPT2 困惑度：AI 風格低於人類口語', () async {
    final support = await getApplicationSupportDirectory();
    final modelPath = p.join(support.path, 'models', 'verify_gpt2.onnx');
    final tokPath =
        p.join(support.path, 'models', 'verify_gpt2_tokenizer.json');
    if (!File(modelPath).existsSync()) {
      markTestSkipped('容器內無 distilgpt2 模型；跳過');
      return;
    }
    final scorer = await PerplexityScorer.load(
      modelPath: modelPath,
      tokenizerJsonPath: tokPath,
    );
    final aiPpl = await scorer.perplexity(
        'It is important to note that artificial intelligence is transforming '
        'industries. Furthermore, these advancements offer significant benefits.');
    final humanPpl = await scorer.perplexity(
        'ugh my train was late again lol, ended up walking half way and my '
        'coffee spilled everywhere, what a morning honestly');
    scorer.dispose();

    expect(aiPpl, isNotNull);
    expect(humanPpl, isNotNull);
    // AI 風格文本更可預測 → 困惑度較低
    expect(aiPpl!, lessThan(humanPpl!));
    // ignore: avoid_print
    print('困惑度 → AI:$aiPpl human:$humanPpl');
  });
}
