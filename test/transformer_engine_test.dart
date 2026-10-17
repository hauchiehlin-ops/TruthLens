import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/engines/transformer_engine.dart';
import 'package:omnitrace/core/detection/evidence_fusion.dart';
import 'package:omnitrace/core/detection/model_manager.dart';
import 'package:omnitrace/core/models/detection_result.dart';

/// 驗證 Transformer 引擎的可用性判斷：分類器一定要有真實 tokenizer 且檔案存在。
void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('tf_engine_'));
  tearDown(() => tmp.existsSync() ? tmp.deleteSync(recursive: true) : null);

  void seed(
    String variantId,
    Map<String, dynamic> variant, {
    bool writeModel = true,
    bool writeTokenizer = false,
  }) {
    if (writeModel) File('${tmp.path}/m.onnx').writeAsBytesSync([1, 2, 3]);
    if (writeTokenizer) File('${tmp.path}/t.json').writeAsStringSync('{}');
    File('${tmp.path}/installed.json').writeAsStringSync(
      jsonEncode({
        'transformer': {
          'active': variantId,
          'installed': {variantId: variant},
        },
      }),
    );
  }

  Map<String, dynamic> variant(
    String tokenizer, {
    String? tokenizerFile = 't.json',
  }) => {
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

  group('文件級分數（documentProbability）', () {
    // 2026-10 回報：2.2 萬字 Antigravity 研究計畫有 21 句跨門檻，舊公式卻得到
    // 約 0.30，融合層把它當成「支持人類」，報告翻成「較可能不是 AI 生成」。
    final longDocument = [
      for (var i = 0; i < 40; i++) i % 10 == 0 ? 0.995 : 0.08,
    ];

    test('長文件中少數區塊跨門檻 → 分數仍在 AI 側', () {
      final p = TransformerEngine.documentProbability(longDocument, 0.98);
      expect(p, greaterThanOrEqualTo(0.62));
    });

    test('經融合層後不得成為人類側證據', () {
      final p = TransformerEngine.documentProbability(longDocument, 0.98);
      final fusion = TextEvidenceFusion.evaluate(
        scores: [
          EngineScore(
            engineId: 'transformer',
            engineName: 'transformer',
            aiProbability: p,
            weight: 0.4,
            hasEvidence: true,
            applicability: EngineApplicability.validated,
            calibrationReliability: 0.82,
          ),
        ],
        inputText: '研究計畫。' * 120,
      );
      expect(fusion.humanSupportingFamilies, 0);
      expect(fusion.aiSupportingFamilies, 1);
      expect(fusion.authorshipClass, TextAuthorshipClass.likelyAiGenerated);
    });

    test('單一零星強區塊只保留方向，不跨過 0.62 支持門檻', () {
      final chunks = [0.99, for (var i = 0; i < 39; i++) 0.05];
      final p = TransformerEngine.documentProbability(chunks, 0.98);
      expect(p, greaterThan(0.5));
      expect(p, lessThan(0.62));
    });

    test('沒有區塊跨門檻 → 維持 0–10% 的沉默區間', () {
      final p = TransformerEngine.documentProbability(
        [0.55, 0.52, 0.40, 0.30],
        0.98,
      );
      expect(p, lessThanOrEqualTo(0.10));
    });
  });
}
