import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:truthlens/core/detection/model_catalog.dart';
import 'package:truthlens/core/detection/model_catalog_service.dart';
import 'package:truthlens/core/detection/model_manager.dart';

ModelVariant _variant(
  String id, {
  int minRamMb = 4096,
  String? url,
  String version = '1.0',
  double aiEvidenceThreshold = 0.60,
}) => ModelVariant(
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
  aiEvidenceThreshold: aiEvidenceThreshold,
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
      'transformer',
      _variant('roberta', url: 'https://x/m.onnx'),
    );
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

  test('變體校準後的 AI 證據門檻會寫入 manifest 並於重啟後保留', () async {
    await manager.downloadVariant(
      'transformer',
      _variant(
        'modern-zh',
        url: 'https://x/zh.onnx',
        aiEvidenceThreshold: 0.99,
      ),
    );

    final restored = ModelManager(modelsDir: tmp);
    await restored.refreshInstallStates();
    expect(restored.activeVariant('transformer')?.aiEvidenceThreshold, 0.99);
  });

  group('校準中繼資料同步', () {
    test('withCalibration 只換門檻與語言，其餘欄位原封不動', () {
      const before = InstalledModel(
        role: 'transformer',
        variantId: 'aigc-detector-zhv3-int8',
        fileName: 'zh.onnx',
        tokenizerFileName: 'zh_tok.json',
        tokenizer: 'bert-wordpiece',
        aiLabelIndex: 1,
        aiEvidenceThreshold: 0.99,
        version: '3.0-truthlens-cal1',
        sizeBytes: 103073737,
        sha256: 'abc123',
        languages: ['zh'],
      );

      final after = before.withCalibration(
        aiEvidenceThreshold: 0.97,
        languages: const ['zh'],
      );

      expect(after.aiEvidenceThreshold, 0.97);
      expect(after.variantId, before.variantId);
      expect(after.fileName, before.fileName);
      expect(after.tokenizerFileName, before.tokenizerFileName);
      expect(after.tokenizer, before.tokenizer);
      expect(after.aiLabelIndex, before.aiLabelIndex);
      expect(after.version, before.version);
      expect(after.sizeBytes, before.sizeBytes);
      expect(after.sha256, before.sha256);
    });

    test('sha256 不同時不得同步——那代表模型換了，不是只換校準', () async {
      // 下載出來的檔案雜湊必然與 catalog 宣告的不同，正好模擬「模型檔不一致」。
      await manager.downloadVariant(
        'transformer',
        _variant(
          'aigc-detector-zhv3-int8',
          url: 'https://x/zh.onnx',
          aiEvidenceThreshold: 0.99,
        ),
      );
      final before = manager.activeVariant('transformer')!;
      expect(before.aiEvidenceThreshold, 0.99);

      await manager.syncCalibrationFromCatalog(ModelCatalogService());

      expect(
        manager.activeVariant('transformer')?.aiEvidenceThreshold,
        0.99,
        reason: '模型檔與 catalog 宣告不符時，門檻不得被靜默改寫',
      );
    });
  });

  test('多變體並存並可切換使用中', () async {
    await manager.downloadVariant(
      'transformer',
      _variant('a', url: 'https://x/a.onnx'),
    );
    await manager.downloadVariant(
      'transformer',
      _variant('b', url: 'https://x/b.onnx'),
    );

    expect(manager.installedVariants('transformer').length, 2);
    expect(manager.activeVariant('transformer')?.variantId, 'a'); // 首個

    await manager.setActive('transformer', 'b');
    expect(manager.activeVariant('transformer')?.variantId, 'b');
  });

  test('刪除使用中變體會改用其餘變體', () async {
    await manager.downloadVariant(
      'transformer',
      _variant('a', url: 'https://x/a.onnx'),
    );
    await manager.downloadVariant(
      'transformer',
      _variant('b', url: 'https://x/b.onnx'),
    );
    await manager.setActive('transformer', 'a');

    await manager.removeVariant('transformer', 'a');

    expect(manager.isVariantInstalled('transformer', 'a'), isFalse);
    expect(manager.activeVariant('transformer')?.variantId, 'b');
  });

  test('刪除最後一個變體 → 回到未安裝', () async {
    await manager.downloadVariant(
      'transformer',
      _variant('a', url: 'https://x/a.onnx'),
    );
    await manager.removeVariant('transformer', 'a');
    expect(manager.isInstalled('transformer'), isFalse);
  });

  test('hasUpdate：安裝版本落後 catalog 版本時為 true', () async {
    await manager.downloadVariant(
      'transformer',
      _variant('a', url: 'https://x/a.onnx', version: '1.0'),
    );
    expect(
      manager.hasUpdate(
        'transformer',
        _variant('a', url: 'https://x/a.onnx', version: '1.0'),
      ),
      isFalse,
    );
    expect(
      manager.hasUpdate(
        'transformer',
        _variant('a', url: 'https://x/a.onnx', version: '2.0'),
      ),
      isTrue,
    );
  });

  test('manifest 有紀錄但檔案不存在 → 視為未安裝', () async {
    File('${tmp.path}/installed.json').writeAsStringSync(
      jsonEncode({
        'transformer': {
          'active': 'x',
          'installed': {
            'x': {
              'role': 'transformer',
              'variant_id': 'x',
              'file_name': 'missing.onnx',
              'version': '1.0',
              'size_bytes': 4,
            },
          },
        },
      }),
    );
    await manager.refreshInstallStates();
    expect(manager.isInstalled('transformer'), isFalse);
  });

  test('manifest 有紀錄但模型不完整或 tokenizer 損毀 → 自動清除', () async {
    File('${tmp.path}/broken.onnx').writeAsStringSync('partial');
    File('${tmp.path}/broken.tokenizer.json').writeAsStringSync('{bad json');
    File('${tmp.path}/installed.json').writeAsStringSync(
      jsonEncode({
        'transformer': {
          'active': 'broken',
          'installed': {
            'broken': {
              'role': 'transformer',
              'variant_id': 'broken',
              'file_name': 'broken.onnx',
              'tokenizer_file_name': 'broken.tokenizer.json',
              'tokenizer': 'bert-wordpiece',
              'version': '1.0',
              'size_bytes': 2048,
            },
          },
        },
      }),
    );

    await manager.refreshInstallStates();

    expect(manager.isInstalled('transformer'), isFalse);
    expect(File('${tmp.path}/broken.onnx').existsSync(), isFalse);
    expect(File('${tmp.path}/broken.tokenizer.json').existsSync(), isFalse);
  });

  test('下載無 url 的變體 → 標記失敗', () async {
    final ok = await manager.downloadVariant(
      'transformer',
      _variant('pending'),
    );
    expect(ok, isFalse);
    expect(
      manager.roleState('transformer')?.transientState,
      InstallState.failed,
    );
  });

  test('canRunEngine 對未知 role 安全回傳 false', () {
    expect(manager.canRunEngine('nonexistent'), isFalse);
  });

  group('checkForUpdates（主動連線比對 catalog 版本）', () {
    ModelCatalogService catalogServiceReturning(String version) {
      final client = MockClient(
        (req) async => http.Response(
          jsonEncode({
            'catalog_version': '1',
            'models': [
              {
                'role': 'transformer',
                'name': 'Transformer',
                'variants': [
                  {
                    'id': 'a',
                    'name': 'a',
                    'backend': 'transformer',
                    'languages': ['en'],
                    'quant': 'int8',
                    'size_bytes': 2048,
                    'min_ram_mb': 4096,
                    'tier': 'high',
                    'version': version,
                    'source': 'hf',
                    'license': 'mit',
                  },
                ],
              },
            ],
          }),
          200,
        ),
      );
      return ModelCatalogService(client: client);
    }

    test('catalog 版本較新時 hasAnyUpdate 為 true', () async {
      await manager.downloadVariant(
        'transformer',
        _variant('a', url: 'https://x/a.onnx', version: '1.0'),
      );
      expect(manager.hasAnyUpdate, isFalse);

      await manager.checkForUpdates(catalogServiceReturning('2.0'));

      expect(manager.hasAnyUpdate, isTrue);
      expect(manager.roleHasUpdate('transformer'), isTrue);
    });

    test('catalog 版本相同時不標記更新', () async {
      await manager.downloadVariant(
        'transformer',
        _variant('a', url: 'https://x/a.onnx', version: '1.0'),
      );

      await manager.checkForUpdates(catalogServiceReturning('1.0'));

      expect(manager.hasAnyUpdate, isFalse);
    });

    test('連線失敗（離線）時靜默略過，不拋出例外', () async {
      final failingClient = MockClient(
        (req) async => throw Exception('offline'),
      );
      await manager.downloadVariant(
        'transformer',
        _variant('a', url: 'https://x/a.onnx', version: '1.0'),
      );

      await manager.checkForUpdates(ModelCatalogService(client: failingClient));

      expect(manager.hasAnyUpdate, isFalse);
    });
  });
}
