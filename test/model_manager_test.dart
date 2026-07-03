import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_manager.dart';

void main() {
  late Directory tmp;
  late ModelManager manager;

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('truthlens_models_');
    manager = ModelManager(modelsDir: tmp);
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  /// 模擬一筆已安裝紀錄（installed.json + 檔案）
  void seedInstalled(String role, String fileName) {
    File('${tmp.path}/$fileName').writeAsBytesSync([1, 2, 3, 4]);
    File('${tmp.path}/installed.json').writeAsStringSync(jsonEncode({
      role: {
        'role': role,
        'variant_id': 'test-variant',
        'file_name': fileName,
        'version': '1.0',
        'size_bytes': 4,
      }
    }));
  }

  test('初始狀態全部未安裝', () async {
    await manager.refreshInstallStates();
    for (final s in manager.statuses.values) {
      expect(s.state, InstallState.notInstalled);
    }
    expect(manager.isInstalled('transformer'), isFalse);
    expect(manager.canRunEngine('transformer'), isFalse);
  });

  test('依 installed.json 偵測已安裝並記錄變體資訊', () async {
    seedInstalled('transformer', 'transformer__v1.onnx');
    await manager.refreshInstallStates();

    expect(manager.isInstalled('transformer'), isTrue);
    expect(manager.canRunEngine('transformer'), isTrue);
    expect(manager.installedInfo('transformer')?.variantId, 'test-variant');
  });

  test('manifest 有紀錄但檔案不存在 → 視為未安裝', () async {
    File('${tmp.path}/installed.json').writeAsStringSync(jsonEncode({
      'transformer': {
        'role': 'transformer',
        'variant_id': 'x',
        'file_name': 'missing.onnx',
        'version': '1.0',
        'size_bytes': 4,
      }
    }));
    await manager.refreshInstallStates();
    expect(manager.isInstalled('transformer'), isFalse);
  });

  test('移除模型後回到未安裝並清除檔案', () async {
    seedInstalled('llm', 'llm__gemma.gguf');
    await manager.refreshInstallStates();
    expect(manager.isInstalled('llm'), isTrue);

    await manager.remove('llm');

    expect(manager.isInstalled('llm'), isFalse);
    expect(File('${tmp.path}/llm__gemma.gguf').existsSync(), isFalse);
  });

  test('canRunEngine 對未知 role 安全回傳 false', () {
    expect(manager.canRunEngine('nonexistent'), isFalse);
  });
}
