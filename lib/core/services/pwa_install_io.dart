/// 安裝提示的結果。
enum PwaInstallOutcome { accepted, dismissed, unavailable }

/// 原生端沒有「安裝成 PWA」這件事，儲存本來就不會被回收。
/// 保留同一組介面，讓共用的 UI 不必寫平台分支。
class PwaInstall {
  const PwaInstall._();

  static bool get canInstall => false;

  static bool get isInstalled => true;

  static Future<PwaInstallOutcome> prompt() async =>
      PwaInstallOutcome.unavailable;
}
