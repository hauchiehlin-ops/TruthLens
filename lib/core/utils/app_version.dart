/// 應用程式版本控制常數
class AppVersion {
  /// 版本名稱（版號，與 pubspec.yaml 同步）
  static const String version = '1.0.0';

  /// 建置編號
  static const String buildNumber = '1';

  /// 顯示用完整字串 (例如 v1.0.0)
  static String get displayVersion => 'v$version';
}
