import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/pwa_install.dart';

void main() {
  // 這組測試跑在 VM 上，載入的是 pwa_install_io.dart。它守的是「共用 UI 不必
  // 寫平台分支」這個約定：原生端永遠不會冒出安裝按鈕，也不會宣稱儲存有風險。
  group('原生端的 PWA 介面契約', () {
    test('不提供安裝提示', () {
      expect(PwaInstall.canInstall, isFalse);
    });

    test('視為已安裝——原生儲存本來就不會被回收', () {
      expect(PwaInstall.isInstalled, isTrue);
    });

    test('呼叫提示不拋錯，回報 unavailable', () async {
      expect(await PwaInstall.prompt(), PwaInstallOutcome.unavailable);
    });
  });
}
