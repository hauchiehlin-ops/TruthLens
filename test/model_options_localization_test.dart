import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_catalog.dart';
import 'package:truthlens/core/detection/model_display_names.dart';
import 'package:truthlens/features/onboarding/model_options_list.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('built-in model catalog copy follows the English interface locale', () {
    const variant = ModelVariant(
      id: 'truthlens-multilingual-distil-int8',
      name: '多語言輕量偵測器（英+中・INT8）',
      backend: 'transformer',
      languages: ['en', 'zh', 'multi'],
      quant: 'int8',
      sizeBytes: 1,
      minRamMb: 1,
      tier: PerformanceTier.low,
      version: '1.0',
      source: 'test',
      license: 'test',
      note: '中文目錄說明',
    );

    expect(
      ModelOptionsList.roleLabel('transformer', 'AI 文字偵測器', l10n),
      l10n.settingsEngineTransformerTitle,
    );
    // 未知變體（catalog 可遠端新增）回退目錄名稱，不因此顯示 id
    expect(ModelOptionsList.variantLabel(variant, l10n), variant.name);
    expect(
      ModelOptionsList.variantDescription('transformer', variant, l10n),
      l10n.settingsEngineTransformerSubtitle,
    );
  });

  test('模型名稱依介面語系在地化，不再中英混雜', () async {
    // 實測回報：英文介面下模型清單顯示「多語言偵測器（英+中・INT8）」。
    // 成因是一張寫死英文的覆寫表——表中有的顯示英文、沒有的落回 catalog 的
    // 中文，於是同一份清單兩種語言並存。
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final zh = await AppLocalizations.delegate.load(const Locale('zh'));

    const knownIds = [
      'truthlens-mbert-multilingual-int8',
      'truthlens-zh-detector-int8',
      'aigc-detector-zhv3-int8',
      'chatgpt-detector-roberta-onnx-int8',
      'qwen05b-ppl-int8',
      'distilgpt2-ppl-int8',
      'truthlens-adversarial-distil-int8',
    ];
    final han = RegExp('[一-鿿]');
    for (final id in knownIds) {
      final english = localizedModelName(id, '目錄中文名稱', en);
      expect(
        han.hasMatch(english),
        isFalse,
        reason: '$id 在英文介面下不得出現中文',
      );
      expect(
        localizedModelName(id, '目錄中文名稱', zh),
        isNot(english),
        reason: '$id 中英文名稱應不同，否則等於沒有在地化',
      );
    }

    // 未知 id 仍回退目錄名稱，遠端新增的模型才不會顯示成裸 id
    expect(localizedModelName('brand-new-model', '新模型', en), '新模型');
    expect(localizedModelName('brand-new-model', null, en), 'brand-new-model');
  });
}
