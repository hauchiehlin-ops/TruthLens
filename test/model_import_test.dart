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

  test('importLocalModel 計算並儲存 sha256', () async {
    final mockModelFile = File(p.join(tempDir.path, 'mock_model3.onnx'))
      ..writeAsStringSync('identical content');

    await manager.importLocalModel(
      role: 'transformer',
      name: 'Hashed Model',
      modelFile: mockModelFile,
      tokenizerType: 'none',
    );

    final variant = manager.installedVariants('transformer').first;
    expect(variant.sha256, isNotNull);
    expect(variant.sha256, hasLength(64));
  });

  test('findByHash 找到內容相同的已安裝模型（即使角色不同）', () async {
    final modelA = File(p.join(tempDir.path, 'a.onnx'))
      ..writeAsStringSync('same bytes for dedup test');
    final modelB = File(p.join(tempDir.path, 'b.onnx'))
      ..writeAsStringSync('same bytes for dedup test'); // 內容相同、檔名不同

    await manager.importLocalModel(
      role: 'transformer',
      name: 'Original',
      modelFile: modelA,
      tokenizerType: 'none',
    );

    final hash = await manager.hashOf(modelB);
    final match = manager.findByHash(hash);

    expect(match, isNotNull);
    expect(match!.displayName, 'Original');
  });

  test('findByHash 對未匯入過的內容回傳 null', () async {
    final unique = File(p.join(tempDir.path, 'unique.onnx'))
      ..writeAsStringSync('never seen before');
    final hash = await manager.hashOf(unique);
    expect(manager.findByHash(hash), isNull);
  });

  test('refreshInstallStates 為舊資料（無 sha256）自動補算雜湊', () async {
    // 模擬「本功能上線前」就已存在、manifest 沒有 sha256 欄位的匯入項目
    final legacyFile =
        File(p.join(tempDir.path, 'transformer__legacy_1.onnx'))
          ..writeAsBytesSync([1, 2, 3, 4, 5]);
    File(p.join(tempDir.path, 'installed.json')).writeAsStringSync('''
{
  "transformer": {
    "active": "legacy_1",
    "installed": {
      "legacy_1": {
        "role": "transformer",
        "variant_id": "legacy_1",
        "file_name": "transformer__legacy_1.onnx",
        "tokenizer": "none",
        "ai_label_index": 1,
        "version": "1.0.0 (自訂匯入)",
        "size_bytes": 5,
        "name": "Legacy Import",
        "imported": true
      }
    }
  }
}
''');

    final fresh = ModelManager(modelsDir: tempDir);
    await fresh.refreshInstallStates();

    final legacy = fresh.installedVariants('transformer').first;
    expect(legacy.sha256, isNotNull, reason: '應自動補算並持久化 sha256');

    // 補算後應能被 findByHash 找到（證明持久化成功，非只存在記憶體）
    final expectedHash = await fresh.hashOf(legacyFile);
    expect(legacy.sha256, expectedHash);
  });
}
