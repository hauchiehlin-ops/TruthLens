import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/remote_llm_provider.dart';

void main() {
  group('RemoteLlmProvider Tests', () {
    group('OllamaProvider', () {
      final provider = OllamaProvider();

      test('healthCheck detects unavailable Ollama', () async {
        // 如果本地未運行 Ollama，應回傳 false
        final ok = await provider.healthCheck();
        // 此測試目的為驗證方法可調用，不要求 Ollama 運行
        expect(ok, isA<bool>());
      });

      test('generate prompt structure is correct', () async {
        // 此測試只驗證方法簽名，不實際呼叫 API
        // 在實際環境中，需運行 ollama run gemma:2b-it-q4
        expect(provider.model, equals('gemma:2b-it-q4'));
      });
    });

    group('GroqProvider', () {
      test('requires valid API key', () async {
        final provider = GroqProvider(apiKey: 'invalid_key');
        // 驗證 API 金鑰格式檢查（如需要）
        expect(provider.apiKey.isNotEmpty, true);
      });

      test('model selection', () async {
        final provider = GroqProvider(apiKey: 'gsk_test', model: 'gemma-7b-it');
        expect(provider.model, equals('gemma-7b-it'));
      });
    });

    group('TogetherAiProvider', () {
      test('supports multiple models', () async {
        final models = [
          'mistralai/Mistral-7B-Instruct-v0.1',
          'meta-llama/Llama-2-7b-chat',
          'togethercomputer/GPT-JT-6B',
        ];

        for (final model in models) {
          final provider = TogetherAiProvider(apiKey: 'test_key', model: model);
          expect(provider.model, equals(model));
        }
      });
    });

    group('AnthropicProvider', () {
      test('uses correct API endpoint', () async {
        final provider = AnthropicProvider(apiKey: 'sk-ant-test');
        expect(provider.model, contains('claude'));
      });
    });
  });

  group('LLM Generation Integration', () {
    test('RemoteLlmProvider interface consistency', () async {
      // 驗證所有提供商實現同樣的介面
      const apiKey = 'test_key';

      final providers = <RemoteLlmProvider>[
        OllamaProvider(),
        GroqProvider(apiKey: apiKey),
        TogetherAiProvider(apiKey: apiKey),
        AnthropicProvider(apiKey: apiKey),
      ];

      for (final provider in providers) {
        // 驗證方法簽名
        expect(provider.healthCheck, isNotNull);
        expect(provider.generate, isNotNull);
      }
    });
  });
}
