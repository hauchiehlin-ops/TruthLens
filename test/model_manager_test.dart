import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_manager.dart';
import 'package:truthlens/core/detection/model_registry.dart';

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

  test('初始狀態全部未安裝', () {
    for (final s in manager.statuses.values) {
      expect(s.state, InstallState.notInstalled);
    }
    expect(manager.isInstalled('transformer'), isFalse);
    expect(manager.canRunEngine('transformer'), isFalse);
  });

  test('偵測手動放入的模型檔為已安裝', () async {
    final spec = modelSpecFor('transformer')!;
    File('${tmp.path}/${spec.fileName}').writeAsBytesSync([1, 2, 3, 4]);

    await manager.refreshInstallStates();

    expect(manager.isInstalled('transformer'), isTrue);
    // 有原生後端 + 已安裝 → 可執行
    expect(manager.canRunEngine('transformer'), isTrue);
  });

  test('移除模型後回到未安裝', () async {
    final spec = modelSpecFor('llm')!;
    File('${tmp.path}/${spec.fileName}').writeAsBytesSync([9]);
    await manager.refreshInstallStates();
    expect(manager.isInstalled('llm'), isTrue);

    await manager.remove('llm');

    expect(manager.isInstalled('llm'), isFalse);
    expect(File('${tmp.path}/${spec.fileName}').existsSync(), isFalse);
  });

  test('下載尚未發佈（無來源）的模型會標記失敗', () async {
    final ok = await manager.download('transformer');
    expect(ok, isFalse);
    expect(manager.statusFor('transformer')!.state, InstallState.failed);
    expect(manager.statusFor('transformer')!.error, contains('尚未發佈'));
  });

  test('未知模型 id 安全回傳', () async {
    expect(await manager.download('nonexistent'), isFalse);
    expect(manager.canRunEngine('nonexistent'), isFalse);
  });
}
