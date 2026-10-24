import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:omnitrace/core/detection/engines/adversarial_engine.dart';
import 'package:omnitrace/core/detection/model_manager.dart';
import 'package:omnitrace/core/detection/orchestrator.dart';
import 'package:omnitrace/core/detection/variant_router.dart';

InstalledModel _variant(String id, List<String> languages) => InstalledModel(
  role: 'adversarial',
  variantId: id,
  fileName: '$id.onnx',
  version: '1',
  sizeBytes: 1,
  languages: languages,
);

final _english = _variant('adv-en', ['en']);
final _chinese = _variant('adv-zh', ['zh']);

class _FakeModelManager extends ModelManager {
  final List<InstalledModel> installed;
  final InstalledModel? active;
  final bool manual;

  _FakeModelManager(this.installed, {this.active, this.manual = false})
    : super(client: MockClient((_) async => http.Response('', 404)));

  @override
  List<InstalledModel> installedVariants(String role) =>
      role == 'adversarial' ? installed : const [];

  @override
  InstalledModel? activeVariant(String role) =>
      role == 'adversarial' ? active : null;

  @override
  bool isManualSelection(String role) => manual;
}

void main() {
  test('中文文件改用中文改寫偵測模型，即使使用中的是英文模型', () {
    final engine = AdversarialEngine(
      modelManager: _FakeModelManager([_english, _chinese], active: _english),
    );
    final zh = engine.routeFor('zh');
    expect(zh.variant?.variantId, 'adv-zh');
    expect(zh.fit, LanguageFit.validated);
    expect(engine.routeFor('en').variant?.variantId, 'adv-en');
  });

  test('手動鎖定在語言適用時保留；不支援文件語言時改選並標明', () {
    final engine = AdversarialEngine(
      modelManager: _FakeModelManager(
        [_english, _chinese],
        active: _english,
        manual: true,
      ),
    );
    final en = engine.routeFor('en');
    expect(en.variant?.variantId, 'adv-en');
    expect(en.basis, RoutingBasis.userPinned);
    // 鎖定的英文模型讀中文沒有意義，改用中文模型並記錄推翻了使用者的選擇
    final zh = engine.routeFor('zh');
    expect(zh.variant?.variantId, 'adv-zh');
    expect(zh.overrodeUserChoice, isTrue);
  });

  test('預設引擎組不再於建構時鎖定改寫偵測變體', () {
    final orchestrator = EnsembleOrchestrator(
      modelManager: _FakeModelManager([_english, _chinese], active: _english),
    );
    final adversarial = orchestrator.engines
        .whereType<AdversarialEngine>()
        .single;
    expect(adversarial.variantId, isNull);
    expect(adversarial.routeFor('zh').variant?.variantId, 'adv-zh');
  });
}
