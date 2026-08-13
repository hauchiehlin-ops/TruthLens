import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_catalog.dart';
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
    expect(
      ModelOptionsList.variantLabel(variant),
      'TruthLens Multilingual Detector (INT8)',
    );
    expect(
      ModelOptionsList.variantDescription('transformer', variant, l10n),
      l10n.settingsEngineTransformerSubtitle,
    );
  });
}
