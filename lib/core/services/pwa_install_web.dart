import 'dart:js_interop';

/// 安裝提示的結果。
enum PwaInstallOutcome {
  /// 使用者同意安裝
  accepted,

  /// 使用者婉拒
  dismissed,

  /// 這個瀏覽器沒有可用的安裝提示（Safari／已安裝／事件已用過）
  unavailable,
}

@JS('truthlensPwa.canInstall')
external JSBoolean _canInstall();

@JS('truthlensPwa.isInstalled')
external JSBoolean _isInstalled();

@JS('truthlensPwa.promptInstall')
external JSPromise<JSString> _promptInstall();

/// 對 web/pwa_bridge.js 的薄封裝。
///
/// 為什麼要走 JS 端：`beforeinstallprompt` 早於 Flutter 啟動就會派送，且只派送一次，
/// 從 Dart 註冊監聽器已經來不及。
class PwaInstall {
  const PwaInstall._();

  /// 現在能不能叫出安裝提示。Safari／Firefox 沒有這個事件，恆為 false；
  /// 已安裝或提示已用過也是 false。
  static bool get canInstall {
    try {
      return _canInstall().toDart;
    } catch (_) {
      return false;
    }
  }

  /// 是否已經以獨立應用程式的形式執行。
  static bool get isInstalled {
    try {
      return _isInstalled().toDart;
    } catch (_) {
      return false;
    }
  }

  static Future<PwaInstallOutcome> prompt() async {
    try {
      final outcome = (await _promptInstall().toDart).toDart;
      return switch (outcome) {
        'accepted' => PwaInstallOutcome.accepted,
        'dismissed' => PwaInstallOutcome.dismissed,
        _ => PwaInstallOutcome.unavailable,
      };
    } catch (_) {
      return PwaInstallOutcome.unavailable;
    }
  }
}
