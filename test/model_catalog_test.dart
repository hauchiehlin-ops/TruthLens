import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_catalog.dart';

ModelVariant _variant({
  required String id,
  required int minRamMb,
  required PerformanceTier tier,
  String? url,
}) =>
    ModelVariant(
      id: id,
      name: id,
      backend: 'transformer',
      languages: const ['en'],
      quant: 'int8',
      sizeBytes: 100,
      minRamMb: minRamMb,
      tier: tier,
      version: '1',
      source: 's',
      license: 'l',
      url: url,
    );

void main() {
  group('CatalogModel.bestFor（硬體感知選型）', () {
    // 依品質排序：high(需 4GB) 在前、low(需 2GB) 在後
    final model = CatalogModel(
      role: 'transformer',
      name: 'detector',
      variants: [
        _variant(
            id: 'high', minRamMb: 4096, tier: PerformanceTier.high,
            url: 'https://x/high.onnx'),
        _variant(
            id: 'low', minRamMb: 2048, tier: PerformanceTier.low,
            url: 'https://x/low.onnx'),
      ],
    );

    test('高階裝置取品質最高且 RAM 足夠者', () {
      final v = model.bestFor(PerformanceTier.high, 8192);
      expect(v?.id, 'high');
    });

    test('低 RAM 裝置退而取較輕的變體', () {
      final v = model.bestFor(PerformanceTier.low, 3072); // 不足 4GB
      expect(v?.id, 'low');
    });

    test('只在可下載者中選擇；跳過無 url 的變體', () {
      final m = CatalogModel(
        role: 'r',
        name: 'r',
        variants: [
          _variant(id: 'pending', minRamMb: 2048, tier: PerformanceTier.high),
          _variant(
              id: 'ready', minRamMb: 2048, tier: PerformanceTier.low,
              url: 'https://x/ready.onnx'),
        ],
      );
      expect(m.bestFor(PerformanceTier.high, 8192)?.id, 'ready');
    });

    test('無任何變體可下載時回退為最小可執行者（供 UI 顯示即將推出）', () {
      final m = CatalogModel(
        role: 'r',
        name: 'r',
        variants: [
          _variant(id: 'big', minRamMb: 8192, tier: PerformanceTier.high),
          _variant(id: 'small', minRamMb: 2048, tier: PerformanceTier.low),
        ],
      );
      final v = m.bestFor(PerformanceTier.low, 3072);
      expect(v?.id, 'small'); // 唯一 RAM 足夠者
      expect(v?.isDownloadable, isFalse);
    });
  });

  group('ModelCatalog 解析', () {
    test('自 JSON 建構並依 role 查詢', () {
      final catalog = ModelCatalog.fromJson({
        'catalog_version': '2026-07-03',
        'models': [
          {
            'role': 'transformer',
            'name': '偵測器',
            'variants': [
              {
                'id': 'v1',
                'name': 'V1',
                'backend': 'transformer',
                'languages': ['en', 'zh'],
                'quant': 'int8',
                'size_bytes': 1000,
                'min_ram_mb': 2048,
                'tier': 'low',
                'url': 'https://x/v1.onnx',
                'version': '1',
                'source': 'hf',
                'license': 'mit',
              }
            ],
          }
        ],
      });
      expect(catalog.catalogVersion, '2026-07-03');
      expect(catalog.forRole('transformer')?.variants.first.languages,
          ['en', 'zh']);
      expect(catalog.forRole('llm'), isNull);
    });
  });
}
