import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:omnitrace/core/detection/engines/stylometry_engine.dart';
import 'package:omnitrace/core/detection/model_catalog_service.dart';
import 'package:omnitrace/core/detection/services/huggingface_hub_explorer.dart';
import 'package:omnitrace/core/detection/services/model_benchmark_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Option C: ModelBenchmarkService 自動校準', () {
    test('對可用引擎產出校準分數與推薦權重', () async {
      final benchmark = ModelBenchmarkService();
      final engine = StylometryEngine();

      final report = await benchmark.benchmarkEngine(engine);
      expect(report.engineId, 'stylometry');
      expect(report.accuracy, inInclusiveRange(0.0, 1.0));
      expect(report.avgLatencyMs, greaterThanOrEqualTo(0.0));
      expect(report.recommendedWeight, inInclusiveRange(0.05, 0.50));
    });
  });

  group('Option A: HuggingFaceHubExplorer 自動探尋', () {
    test('成功解析 HuggingFace API 回傳之社群模型', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('huggingface.co/api/models')) {
          return http.Response('''[
              {
                "id": "community/deberta-v3-detector",
                "tags": ["onnx", "transformers", "truthlens-detector"]
              }
            ]''', 200);
        }
        return http.Response('Not Found', 404);
      });

      final explorer = HuggingFaceHubExplorer(client: mockClient);
      final variants = await explorer.discoverCommunityModels();

      expect(variants.length, 1);
      expect(variants.first.id, 'hf_community__deberta-v3-detector');
      expect(variants.first.url, contains('community/deberta-v3-detector'));
      expect(variants.first.isDownloadable, isTrue);
    });

    test('ModelCatalogService load 時支援 discoverCommunity 自動合併社群模型', () async {
      final mockClient = MockClient((request) async {
        if (request.url.toString().contains('huggingface.co/api/models')) {
          return http.Response('''[
              {
                "id": "community/qwen-detector",
                "tags": ["onnx", "truthlens-detector"]
              }
            ]''', 200);
        }
        return http.Response('''{
            "catalog_version": "1.0.0",
            "models": [
              {
                "role": "transformer",
                "name": "多語言 AI 分類器",
                "variants": []
              }
            ]
          }''', 200);
      });

      final service = ModelCatalogService(client: mockClient);
      final catalog = await service.load(
        preferRemote: true,
        discoverCommunity: true,
      );

      final transformerModel = catalog.forRole('transformer');
      expect(transformerModel, isNotNull);
      final hasCommunityVariant = transformerModel!.variants.any(
        (v) => v.id.contains('qwen-detector'),
      );
      expect(hasCommunityVariant, isTrue);
    });
  });
}
