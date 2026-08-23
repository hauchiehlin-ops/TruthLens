import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_manager_types.dart';
import 'package:truthlens/core/detection/variant_router.dart';

InstalledModel _m(String id, List<String> languages) => InstalledModel(
  role: 'transformer',
  variantId: id,
  fileName: '$id.onnx',
  version: '1',
  sizeBytes: 1,
  languages: languages,
);

final _enOnly = _m('roberta-en', ['en']);
final _multi = _m('mbert-multi', ['en', 'zh', 'multi']);
final _legacy = _m('legacy', const []);

void main() {
  group('語言適用程度', () {
    test('明確列出的語言為已驗證', () {
      expect(fitFor(_multi, 'zh'), LanguageFit.validated);
      expect(fitFor(_enOnly, 'en'), LanguageFit.validated);
    });

    test('僅有 multi 標記的語言為未驗證，不得當成已驗證', () {
      // mBERT 架構支援 104 語言，實測只有英中；拿它對泰文下結論
      // 等於宣稱沒有的證據
      expect(fitFor(_multi, 'th'), LanguageFit.plausible);
    });

    test('明確不涵蓋的語言為不支援', () {
      expect(fitFor(_enOnly, 'zh'), LanguageFit.unsupported);
    });

    test('舊版安裝紀錄沒有語言欄位時為未知，不假設涵蓋也不假設不涵蓋', () {
      expect(fitFor(_legacy, 'zh'), LanguageFit.unknown);
    });
  });

  group('選擇邏輯', () {
    test('中文文件會避開純英文模型，改用已驗證中文的變體', () {
      final choice = chooseVariant(
        installed: [_enOnly, _multi],
        language: 'zh',
        userActiveVariantId: 'roberta-en',
      );
      expect(choice.variant, _multi);
      expect(choice.fit, LanguageFit.validated);
      expect(choice.overrodeUserChoice, isTrue);
      expect(choice.isValidated, isTrue);
    });

    test('使用者選的變體已驗證時不換，尊重手動選擇', () {
      final choice = chooseVariant(
        installed: [_enOnly, _multi],
        language: 'en',
        userActiveVariantId: 'roberta-en',
      );
      expect(choice.variant, _enOnly);
      expect(choice.overrodeUserChoice, isFalse);
    });

    test('沒有任何變體驗證過該語言時，仍給出結果但標記為未驗證', () {
      final choice = chooseVariant(
        installed: [_enOnly, _multi],
        language: 'th',
        userActiveVariantId: 'roberta-en',
      );
      // multi 至少架構上可能支援，優於明確不涵蓋的純英文模型
      expect(choice.variant, _multi);
      expect(choice.fit, LanguageFit.plausible);
      expect(choice.isValidated, isFalse);
    });

    test('語言無法判定時直接沿用使用者的選擇，不憑猜測換模型', () {
      final choice = chooseVariant(
        installed: [_enOnly, _multi],
        language: null,
        userActiveVariantId: 'roberta-en',
      );
      expect(choice.variant, _enOnly);
      expect(choice.fit, LanguageFit.unknown);
      expect(choice.overrodeUserChoice, isFalse);
    });

    test('只裝一個變體時不論適用程度都用它，並誠實標記', () {
      final choice = chooseVariant(
        installed: [_enOnly],
        language: 'zh',
        userActiveVariantId: 'roberta-en',
      );
      expect(choice.variant, _enOnly);
      expect(choice.fit, LanguageFit.unsupported);
      expect(choice.overrodeUserChoice, isFalse);
    });

    test('沒有任何已安裝變體時回傳 none', () {
      final choice = chooseVariant(installed: const [], language: 'zh');
      expect(choice.variant, isNull);
      expect(choice, VariantChoice.none);
    });

    test('使用者未指定時仍會依語言挑最適用的', () {
      final choice = chooseVariant(
        installed: [_enOnly, _multi],
        language: 'zh',
      );
      expect(choice.variant, _multi);
      // 使用者沒有選擇，就談不上覆寫
      expect(choice.overrodeUserChoice, isFalse);
    });

    test('已驗證優於未知，未知優於明確不支援', () {
      expect(
        chooseVariant(installed: [_legacy, _enOnly], language: 'zh').variant,
        _legacy,
        reason: '涵蓋範圍未知也好過明確不涵蓋中文的模型',
      );
      expect(
        chooseVariant(installed: [_legacy, _multi], language: 'zh').variant,
        _multi,
      );
    });
  });
}
