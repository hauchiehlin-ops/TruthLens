import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:truthlens/core/detection/model_manager.dart';

void main() {
  late Directory tempDir;
  late ModelManager manager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('truthlens_import_test');
    manager = ModelManager(modelsDir: tempDir);
    await manager.refreshInstallStates();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('ModelManager importLocalModel copies files and updates manifest', () async {
    // Create mock model and tokenizer files
    final mockModelFile = File(p.join(tempDir.path, 'mock_model.onnx'))..writeAsStringSync('onnx data');
    final mockTokFile = File(p.join(tempDir.path, 'mock_tok.json'))..writeAsStringSync('{"vocab": {}}');

    final success = await manager.importLocalModel(
      role: 'transformer',
      name: 'My Custom Model',
      modelFile: mockModelFile,
      tokenizerFile: mockTokFile,
      tokenizerType: 'bert-wordpiece',
      aiLabelIndex: 0,
    );

    expect(success, isTrue);
    expect(manager.isInstalled('transformer'), isTrue);

    final variants = manager.installedVariants('transformer');
    expect(variants.length, 1);
    expect(variants.first.name, 'My Custom Model');
    expect(variants.first.imported, isTrue);
    expect(variants.first.tokenizer, 'bert-wordpiece');
    expect(variants.first.aiLabelIndex, 0);

    // Verify files were copied to models directory
    final activePath = await manager.activeModelPath('transformer');
    final tokPath = await manager.activeTokenizerPath('transformer');

    expect(activePath, isNotNull);
    expect(File(activePath!).existsSync(), isTrue);
    expect(tokPath, isNotNull);
    expect(File(tokPath!).existsSync(), isTrue);

    // Verify deletion works for custom model
    await manager.removeVariant('transformer', variants.first.variantId);
    expect(manager.isInstalled('transformer'), isFalse);
    expect(File(activePath).existsSync(), isFalse);
    expect(File(tokPath).existsSync(), isFalse);
  });

  test('ModelManager importLocalModel handles none tokenizer correctly', () async {
    final mockModelFile = File(p.join(tempDir.path, 'mock_model2.onnx'))..writeAsStringSync('onnx data 2');

    final success = await manager.importLocalModel(
      role: 'transformer',
      name: 'Custom Model None Tok',
      modelFile: mockModelFile,
      tokenizerType: 'none',
      aiLabelIndex: 1,
    );

    expect(success, isTrue);
    final variants = manager.installedVariants('transformer');
    expect(variants.length, 1);
    expect(variants.first.tokenizer, 'none');
    expect(variants.first.tokenizerFileName, isNull);

    final tokPath = await manager.activeTokenizerPath('transformer');
    expect(tokPath, isNull);
  });
}
