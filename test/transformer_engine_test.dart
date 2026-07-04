import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/engines/transformer_engine.dart';
import 'package:truthlens/core/detection/model_manager.dart';

/// 驗證 Transformer 引擎的可用性判斷：分類器一定要有真實 tokenizer 且檔案存在。
void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('tf_engine_'));
  tearDown(() => tmp.existsSync() ? tmp.deleteSync(recursive: true) : null);

  void seed(String variantId, Map<String, dynamic> variant,
      {bool writeModel = true, bool writeTokenizer = false}) {
    if (writeModel) File('${tmp.path}/m.onnx').writeAsBytesSync([1, 2, 3]);
    if (writeTokenizer) File('${tmp.path}/t.json').writeAsStringSync('{}');
    File('${tmp.path}/installed.json').writeAsStringSync(jsonEncode({
      'transformer': {
        'active': variantId,
        'installed': {variantId: variant},
      }
    }));
  }

  Map<String, dynamic> variant(String tokenizer,
          {String? tokenizerFile = 't.json'}) =>
      {
        'role': 'transformer',
        'variant_id': 'v',
        'file_name': 'm.onnx',
        'tokenizer_file_name': tokenizerFile,
        'tokenizer': tokenizer,
        'ai_label_index': 1,
        'version': '1.0',
        'size_bytes': 3,
      };

  Future<bool> availability(ModelManager mm) async {
    await mm.refreshInstallStates();
    return TransformerEngine(modelManager: mm).isAvailable();
  }

  test('模型 + tokenizer 檔都存在 → 可用', () async {
    seed('v', variant('bert-wordpiece'), writeTokenizer: true);
    expect(await availability(ModelManager(modelsDir: tmp)), isTrue);
  });

  test('tokenizer 檔缺失（自動掃描孤兒模型）→ 不可用', () async {
    seed('v', variant('bert-wordpiece'), writeTokenizer: false);
    expect(await availability(ModelManager(modelsDir: tmp)), isFalse);
  });

  test("tokenizer='none' → 不可用（分類器必須有 tokenizer）", () async {
    seed('v', variant('none', tokenizerFile: null), writeTokenizer: false);
    expect(await availability(ModelManager(modelsDir: tmp)), isFalse);
  });

  test('未安裝任何模型 → 不可用', () async {
    expect(await availability(ModelManager(modelsDir: tmp)), isFalse);
  });
}
