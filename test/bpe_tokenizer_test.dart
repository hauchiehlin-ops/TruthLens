import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/bpe_tokenizer.dart';

/// 以真實 RoBERTa tokenizer.json 驗證 byte-level BPE，逐 id 對照原生 tokenizer 輸出。
/// tokenizer.json 為本地快取（gitignored）；不存在時跳過，不影響 CI。
/// 產生方式：見 training/（hf_hub_download 'joaopn/roberta-large-openai-detector-onnx-fp16'）。
void main() {
  const path = String.fromEnvironment(
    'ROBERTA_TOKENIZER',
    defaultValue:
        '/Users/barretlin/GitProjects/TruthLens/training/artifacts/roberta_tokenizer.json',
  );

  // 期望值取自真實 roberta-large-openai-detector tokenizer
  const cases = <String, List<int>>{
    'Hello world': [0, 31414, 232, 2],
    'Hello, world!': [0, 31414, 6, 232, 328, 2],
    'tokenization': [0, 46657, 1938, 2],
    'AI-generated text.': [0, 15238, 12, 21842, 2788, 4, 2],
    '人工智慧': [0, 47973, 48494, 8210, 37127, 27, 3070, 37127, 5782, 6248, 2],
    '  spaced': [0, 1437, 42926, 2],
  };

  test('byte-level BPE 與原生 tokenizer 逐 id 一致', () {
    if (!File(path).existsSync()) {
      markTestSkipped('缺少 roberta tokenizer.json（本地快取）；跳過');
      return;
    }
    final tok = BpeTokenizer.fromTokenizerJson(File(path).readAsStringSync());
    cases.forEach((text, expected) {
      expect(tok.encode(text).inputIds, expected, reason: '文本：$text');
    });
  });

  test('特殊 token 與截斷', () {
    if (!File(path).existsSync()) {
      markTestSkipped('缺少 roberta tokenizer.json；跳過');
      return;
    }
    final tok = BpeTokenizer.fromTokenizerJson(File(path).readAsStringSync());
    final e = tok.encode('word ' * 300, maxLen: 20);
    expect(e.inputIds.length, 20);
    expect(e.inputIds.first, 0); // <s>
    expect(e.inputIds.last, 2); // </s>
    expect(e.attentionMask.length, e.inputIds.length);
  });
}
