import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_catalog.dart';
import 'package:truthlens/core/detection/model_manager_types.dart';

/// KV cache 的 heads/head_dim 是**靜態維度**，錯了會直接推論失敗。
/// onnxruntime-web 1.19.2 的 inputMetadata 不保證提供形狀，因此這些數字
/// 只能由 catalog 明確宣告——這裡守住解析與傳遞不出錯。
void main() {
  group('KvCacheSpec 解析', () {
    test('完整規格可解析', () {
      final spec = KvCacheSpec.fromJson(const {
        'layers': 24,
        'heads': 2,
        'head_dim': 64,
      });
      expect(spec, isNotNull);
      expect(spec!.layers, 24);
      expect(spec.heads, 2);
      expect(spec.headDim, 64);
    });

    test('缺欄位或值不合法時回傳 null，不得給出半套規格', () {
      // 半套規格會建出錯誤形狀的張量，比完全沒有規格更難除錯
      expect(KvCacheSpec.fromJson(null), isNull);
      expect(KvCacheSpec.fromJson(const {'layers': 24, 'heads': 2}), isNull);
      expect(
        KvCacheSpec.fromJson(const {'layers': 0, 'heads': 2, 'head_dim': 64}),
        isNull,
      );
      expect(
        KvCacheSpec.fromJson(const {'layers': 24, 'heads': -1, 'head_dim': 64}),
        isNull,
      );
    });
  });

  group('runtimeJson 傳給 JS 橋接的表示法', () {
    test('沒有 KV cache 的模型不產生 runtime 規格', () {
      const variant = ModelVariant(
        id: 'plain',
        name: 'plain',
        backend: 'transformer',
        languages: ['en'],
        quant: 'int8',
        sizeBytes: 1,
        minRamMb: 1,
        tier: PerformanceTier.low,
        version: '1',
        source: 's',
        license: 'l',
      );
      expect(variant.runtimeJson, isNull);
    });

    test('有 KV cache 時產生 JS 端可解析的 JSON', () {
      const variant = ModelVariant(
        id: 'qwen',
        name: 'qwen',
        backend: 'transformer',
        languages: ['en', 'zh'],
        quant: 'int8',
        sizeBytes: 1,
        minRamMb: 1,
        tier: PerformanceTier.mid,
        version: '1',
        source: 's',
        license: 'l',
        kvCache: KvCacheSpec(layers: 24, heads: 2, headDim: 64),
      );

      final decoded =
          jsonDecode(variant.runtimeJson!) as Map<String, dynamic>;
      final kv = decoded['kvCache'] as Map<String, dynamic>;
      expect(kv['layers'], 24);
      expect(kv['heads'], 2);
      expect(kv['headDim'], 64);
    });
  });

  group('安裝紀錄保存 runtime 規格', () {
    test('規格隨安裝紀錄持久化，離線也能正確推論', () {
      const model = InstalledModel(
        role: 'statistical',
        variantId: 'qwen05b',
        fileName: 'm.onnx',
        version: '1',
        sizeBytes: 1,
        runtimeJson: '{"kvCache":{"layers":24,"heads":2,"headDim":64}}',
      );
      final restored = InstalledModel.fromJson(model.toJson());
      expect(restored.runtimeJson, model.runtimeJson);
    });

    test('舊版紀錄沒有此欄位時為 null，代表模型不需要額外輸入', () {
      final restored = InstalledModel.fromJson(const {
        'role': 'statistical',
        'variant_id': 'distilgpt2',
        'file_name': 'm.onnx',
        'version': '1',
        'size_bytes': 1,
      });
      expect(restored.runtimeJson, isNull);
    });
  });

  test('catalog 中宣告 KV cache 的變體，規格必須完整', () {
    final catalog =
        jsonDecode(File('assets/model_catalog.json').readAsStringSync())
            as Map<String, dynamic>;
    for (final model in catalog['models'] as List) {
      for (final v in ((model as Map)['variants'] as List)) {
        final variant = ModelVariant.fromJson(v as Map<String, dynamic>);
        final declared =
            ((v)['runtime'] as Map<String, dynamic>?)?['kv_cache'] != null;
        if (declared) {
          expect(
            variant.kvCache,
            isNotNull,
            reason: '${variant.id} 宣告了 kv_cache 但欄位不完整，會在推論時才失敗',
          );
        }
      }
    }
  });
}
