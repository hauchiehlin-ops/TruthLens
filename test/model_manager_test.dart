import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:truthlens/core/detection/model_catalog.dart';
import 'package:truthlens/core/detection/model_manager.dart';

ModelVariant _variant(String id,
        {int minRamMb = 4096, String? url, String version = '1.0'}) =>
    ModelVariant(
      id: id,
      name: id,
      backend: 'transformer',
      languages: const ['en'],
      quant: 'int8',
      sizeBytes: 2048,
      minRamMb: minRamMb,
      tier: PerformanceTier.high,
      version: version,
      source: 'hf',
      license: 'mit',
      url: url,
    );

void main() {
  late Directory tmp;
  late ModelManager manager;

  http.Client bytesClient() =>
      MockClient((req) async => http.Response.bytes(List.filled(2048, 7), 200));

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('truthlens_models_');
    manager = ModelManager(modelsDir: tmp, client: bytesClient());
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  test('初始狀態全部未安裝', () async {
    await manager.refreshInstallStates();
    expect(manager.isInstalled('transformer'), isFalse);
    expect(manager.canRunEngine('transformer'), isFalse);
    expect(await manager.activeModelPath('transformer'), isNull);
  });

  test('下載變體：寫檔、記錄 manifest、首個自動設為使用中', () async {
    final ok = await manager.downloadVariant(
        'transformer', _variant('roberta', url: 'https://x/m.onnx'));
    expect(ok, isTrue);
    expect(manager.isInstalled('transformer'), isTrue);
    expect(manager.activeVariant('transformer')?.variantId, 'roberta');
    expect(await manager.activeModelPath('transformer'), isNotNull);

    // 重新掃描仍為已安裝（安裝檢查機制）
    final m2 = ModelManager(modelsDir: tmp);
    await m2.refreshInstallStates();
    expect(m2.isInstalled('transformer'), isTrue);
    expect(m2.activeVariant('transformer')?.variantId, 'roberta');
  });

  test('多變體並存並可切換使用中', () async {
    await manager.downloadVariant(
        'transformer', _variant('a', url: 'https://x/a.onnx'));
    await manager.downloadVariant(
        'transformer', _variant('b', url: 'https://x/b.onnx'));

    expect(manager.installedVariants('transformer').length, 2);
    expect(manager.activeVariant('transformer')?.variantId, 'a'); // 首個

    await manager.setActive('transformer', 'b');
    expect(manager.activeVariant('transformer')?.variantId, 'b');
  });

  test('刪除使用中變體會改用其餘變體', () async {
    await manager.downloadVariant(
        'transformer', _variant('a', url: 'https://x/a.onnx'));
    await manager.downloadVariant(
        'transformer', _variant('b', url: 'https://x/b.onnx'));
    await manager.setActive('transformer', 'a');

    await manager.removeVariant('transformer', 'a');

    expect(manager.isVariantInstalled('transformer', 'a'), isFalse);
    expect(manager.activeVariant('transformer')?.variantId, 'b');
  });

  test('刪除最後一個變體 → 回到未安裝', () async {
    await manager.downloadVariant(
        'transformer', _variant('a', url: 'https://x/a.onnx'));
    await manager.removeVariant('transformer', 'a');
    expect(manager.isInstalled('transformer'), isFalse);
  });

  test('hasUpdate：安裝版本落後 catalog 版本時為 true', () async {
    await manager.downloadVariant(
        'transformer', _variant('a', url: 'https://x/a.onnx', version: '1.0'));
    expect(
        manager.hasUpdate(
            'transformer', _variant('a', url: 'https://x/a.onnx', version: '1.0')),
        isFalse);
    expect(
        manager.hasUpdate(
            'transformer', _variant('a', url: 'https://x/a.onnx', version: '2.0')),
        isTrue);
  });

  test('manifest 有紀錄但檔案不存在 → 視為未安裝', () async {
    File('${tmp.path}/installed.json').writeAsStringSync(jsonEncode({
      'transformer': {
        'active': 'x',
        'installed': {
          'x': {
            'role': 'transformer',
            'variant_id': 'x',
            'file_name': 'missing.onnx',
            'version': '1.0',
            'size_bytes': 4,
          }
        }
      }
    }));
    await manager.refreshInstallStates();
    expect(manager.isInstalled('transformer'), isFalse);
  });

  test('下載無 url 的變體 → 標記失敗', () async {
    final ok = await manager.downloadVariant('transformer', _variant('pending'));
    expect(ok, isFalse);
    expect(manager.roleState('transformer')?.transientState,
        InstallState.failed);
  });

  test('canRunEngine 對未知 role 安全回傳 false', () {
    expect(manager.canRunEngine('nonexistent'), isFalse);
  });
}
