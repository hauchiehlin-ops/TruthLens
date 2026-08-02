import 'package:package_info_plus/package_info_plus.dart';

/// 應用程式版本控制常數（動態讀取系統版號）
class AppVersion {
  static String _version = '1.4.0';
  static String _buildNumber = '5';

  /// 版本名稱（版號，例如 1.1.0）
  static String get version => _version;

  /// 建置編號（例如 3）
  static String get buildNumber => _buildNumber;

  /// 顯示用完整字串 (例如 v1.1.0)
  static String get displayVersion => 'v$_version';

  /// 初始化並由平台層動態讀取 pubspec.yaml / AppInfo / Info.plist 版本號
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        _version = info.version;
        _buildNumber = info.buildNumber;
      }
    } catch (_) {
      // 若平台層尚未初始化，保留預設值
    }
  }
}
