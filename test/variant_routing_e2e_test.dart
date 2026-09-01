import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/engines/transformer_engine.dart';
import 'package:omnitrace/core/detection/model_manager.dart';
import 'package:omnitrace/core/detection/variant_router.dart';
import 'package:omnitrace/core/utils/text_stats.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

Map<String, dynamic> _variant(
  String id,
  String tokenizer,
  List<String> languages,
) => {
  'role': 'transformer',
  'variant_id': id,
  'file_name': '$id.onnx',
  'tokenizer_file_name': '$id.json',
  'tokenizer': tokenizer,
  'ai_label_index': 1,
  'version': '1.0',
  'size_bytes': 3,
  'languages': languages,
};

/// 寫出一份 installed.json 並回傳就緒的 ModelManager
Future<ModelManager> _manager(
  Directory dir,
  Map<String, Map<String, dynamic>> installed, {
  required String active,
}) async {
  for (final id in installed.keys) {
    File('${dir.path}/$id.onnx').writeAsBytesSync([1, 2, 3]);
    File('${dir.path}/$id.json').writeAsStringSync('{}');
  }
  File('${dir.path}/installed.json').writeAsStringSync(
    jsonEncode({
      'transformer': {'active': active, 'installed': installed},
    }),
  );
  final mm = ModelManager(modelsDir: dir);
  await mm.refreshInstallStates();
  return mm;
}

const _zh =
    '本研究採用泰勒庫埃特流場作為實驗載體，透過改變內外圓筒的轉速比，'
    '觀察環狀渦漩在臨界雷諾數附近的形態轉換過程與穩定性邊界的變化情形。';

const _en =
    'The lowest stability boundary on the flow of concentric rotating '
    'cylinders was examined across a range of radius ratios, and the results '
    'are compared with the predictions that follow from the linear theory of '
    'the problem as it is usually stated in the literature.';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l10n = lookupAppLocalizations(const Locale('en'));

  late Directory tmp;
  setUp(() => tmp = Directory.systemTemp.createTempSync('routing_'));
  tearDown(() => tmp.existsSync() ? tmp.deleteSync(recursive: true) : null);

  /// 同時安裝「純英文」與「多語」兩個變體，使用者手動選了純英文那顆——
  /// 這正是實際遇到的狀態：中文文件被純英文模型判為 0%。
  Future<ModelManager> bothVariants() => _manager(tmp, {
    'roberta-en': _variant('roberta-en', 'roberta-bpe', ['en']),
    'mbert-multi': _variant('mbert-multi', 'bert-wordpiece', [
      'en',
      'zh',
      'multi',
    ]),
  }, active: 'roberta-en');

  test('中文文件避開使用者選的純英文模型，改用已驗證中文的變體', () async {
    final mm = await bothVariants();
    final engine = TransformerEngine(modelManager: mm);

    final choice = engine.routeFor(PreprocessedText.from(_zh).language.code);

    expect(choice.variant?.variantId, 'mbert-multi');
    expect(choice.fit, LanguageFit.validated);
    expect(choice.overrodeUserChoice, isTrue);
  });

  test('英文文件維持使用者的選擇，不無謂更換', () async {
    final mm = await bothVariants();
    final engine = TransformerEngine(modelManager: mm);

    final choice = engine.routeFor(PreprocessedText.from(_en).language.code);

    expect(choice.variant?.variantId, 'roberta-en');
    expect(choice.overrodeUserChoice, isFalse);
  });

  test('未安裝多語變體時仍用純英文模型，但標記為不涵蓋該語言', () async {
    final mm = await _manager(tmp, {
      'roberta-en': _variant('roberta-en', 'roberta-bpe', ['en']),
    }, active: 'roberta-en');
    final engine = TransformerEngine(modelManager: mm);

    final choice = engine.routeFor(PreprocessedText.from(_zh).language.code);

    expect(choice.variant?.variantId, 'roberta-en');
    expect(choice.fit, LanguageFit.unsupported);
    expect(choice.isValidated, isFalse);
  });

  test('明確指定 variantId 時不參與路由，呼叫端的意圖優先', () async {
    final mm = await bothVariants();
    final engine = TransformerEngine(modelManager: mm, variantId: 'roberta-en');

    final choice = engine.routeFor(PreprocessedText.from(_zh).language.code);

    expect(choice.variant?.variantId, 'roberta-en');
    expect(choice.overrodeUserChoice, isFalse);
  });

  test('語言由 PreprocessedText 統一提供，各引擎不各自重算', () {
    expect(PreprocessedText.from(_zh).language.code, 'zh');
    expect(PreprocessedText.from(_en).language.code, 'en');
    // 太短的輸入判不出語言，路由必須能接受 null 而不是猜一個
    expect(PreprocessedText.from('短句。').language.isUndetermined, isTrue);
  });

  test('l10n 的路由說明句可正常產生（14 語系皆已補齊）', () {
    expect(
      l10n.engineRoutedToBetterVariant('mbert-multi', 'zh'),
      contains('mbert-multi'),
    );
    expect(l10n.engineLanguageUnsupported('roberta-en', 'zh'), contains('zh'));
    expect(
      l10n.engineLanguageNotValidated('mbert-multi', 'th'),
      contains('th'),
    );
  });
}
