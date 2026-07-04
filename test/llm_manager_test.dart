import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/llama_ffi.dart';
import 'package:truthlens/core/detection/llm_manager.dart';
import 'package:truthlens/core/detection/model_manager.dart';

void main() {
  test('LlamaFfi availability and loading check', () {
    // Verify it evaluates without throwing errors
    expect(LlamaFfi.isAvailable, isA<bool>());
  });

  test('LlmManager initialization and loading fails gracefully when not installed', () async {
    final modelManager = ModelManager();
    final llmManager = LlmManager(modelManager: modelManager);
    
    expect(llmManager.isLoaded, isFalse);
    expect(llmManager.isLoading, isFalse);
    
    // Attempting load should fail because model is not installed and dylib is missing
    final success = await llmManager.loadIfAvailable();
    expect(success, isFalse);
    expect(llmManager.isLoaded, isFalse);
  });
}
