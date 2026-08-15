import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model_catalog.dart';

/// HuggingFace 社群探尋服務 (Option A)
/// 動態查詢 HuggingFace Hub REST API 獲取最新的 AI 檢測開源 ONNX / GGUF 模型。
class HuggingFaceHubExplorer {
  static const searchApiUrl =
      'https://huggingface.co/api/models?search=truthlens-detector&full=true';

  final http.Client _client;
  HuggingFaceHubExplorer({http.Client? client})
    : _client = client ?? http.Client();

  /// 動態查詢 HuggingFace 社群發布的全新 AI 檢測模型
  Future<List<ModelVariant>> discoverCommunityModels() async {
    try {
      final response = await _client
          .get(Uri.parse(searchApiUrl))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode != 200) return [];

      final list = jsonDecode(response.body) as List;
      final variants = <ModelVariant>[];

      for (final item in list) {
        if (item is! Map<String, dynamic>) continue;
        final modelId = item['id'] as String? ?? '';
        if (modelId.isEmpty) continue;

        final tags = (item['tags'] as List? ?? []).cast<String>();
        final isOnnx = tags.contains('onnx') || tags.contains('transformers');
        final backend = isOnnx ? 'transformer' : 'languageModel';

        final safeId = modelId.replaceAll('/', '__');
        final rawUrl = 'https://huggingface.co/$modelId/resolve/main';

        variants.add(
          ModelVariant(
            id: 'hf_$safeId',
            name: 'HF: $modelId',
            backend: backend,
            languages: const ['en', 'zh', 'multi'],
            quant: 'int8',
            sizeBytes: 120 * 1024 * 1024,
            minRamMb: 512,
            tier: PerformanceTier.mid,
            version: '1.0.0',
            source: 'HuggingFace Hub ($modelId)',
            license: 'apache-2.0',
            note: '社群動態探尋發現之開源 AI 檢測模型',
            url: '$rawUrl/model.onnx',
            tokenizerUrl: '$rawUrl/tokenizer.json',
            pageUrl: 'https://huggingface.co/$modelId',
            tokenizer: 'roberta-bpe',
            aiLabelIndex: 1,
          ),
        );
      }

      return variants;
    } catch (_) {
      return []; // 離線或超時時返回空清單，不破壞核心 catalog
    }
  }
}
