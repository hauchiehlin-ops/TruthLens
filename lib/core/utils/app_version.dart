import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 版本資訊快照（版號 + 建置編號）。
@immutable
class AppVersionInfo {
  /// 平台版號尚未讀取成功時的佔位符。刻意不寫死任何版號，避免讀取失敗時
  /// 偽裝成一個看起來合理的舊版本（歷史問題：曾固定回退成 v1.4.0）。
  static const String unknown = '—';

  static const AppVersionInfo pending = AppVersionInfo(
    version: unknown,
    buildNumber: unknown,
  );

  /// 版本名稱（版號，例如 4.6.8）
  final String version;

  /// 建置編號（例如 1441）
  final String buildNumber;

  const AppVersionInfo({required this.version, required this.buildNumber});

  /// 顯示用完整字串 (例如 v4.6.8)
  String get displayVersion => version == unknown ? unknown : 'v$version';

  @override
  bool operator ==(Object other) =>
      other is AppVersionInfo &&
      other.version == version &&
      other.buildNumber == buildNumber;

  @override
  int get hashCode => Object.hash(version, buildNumber);
}

/// 應用程式版本控制常數（動態讀取系統版號）
///
/// Web 啟動路徑上 [init] 是在 `runApp` 之後才於背景完成的，因此顯示版本號的
/// widget 必須監聽 [listenable]（例如以 `ValueListenableBuilder` 包起來），
/// 否則畫面會停在讀取前的佔位符、直到其他原因觸發 rebuild 才更新。
class AppVersion {
  AppVersion._();

  static final ValueNotifier<AppVersionInfo> _info = ValueNotifier(
    AppVersionInfo.pending,
  );

  /// 供 UI 監聽；[init] 完成後會自動通知重建。
  static ValueListenable<AppVersionInfo> get listenable => _info;

  /// 版本名稱（版號，例如 4.6.8）
  static String get version => _info.value.version;

  /// 建置編號（例如 1441）
  static String get buildNumber => _info.value.buildNumber;

  /// 顯示用完整字串 (例如 v4.6.8)
  static String get displayVersion => _info.value.displayVersion;

  /// 初始化並由平台層動態讀取 pubspec.yaml / AppInfo / Info.plist 版本號
  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) {
        _info.value = AppVersionInfo(
          version: info.version,
          buildNumber: info.buildNumber,
        );
      }
    } catch (_) {
      // 若平台層尚未初始化，保留佔位符
    }
  }
}
