import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 使用者偏好設定（閾值、主題、ESL 修正開關）
class PreferencesService extends ChangeNotifier {
  static const _kThreshold = 'confidence_threshold';
  static const _kThemeMode = 'theme_mode';
  static const _kEslCorrection = 'esl_correction';
  static const _kFirstRunHandled = 'first_run_handled';

  SharedPreferences? _prefs;

  double confidenceThreshold = 0.6; // 判定為 AI 的信心閾值（可調，降低偽陽性）
  ThemeMode themeMode = ThemeMode.dark; // 深色模式優先
  bool eslCorrectionEnabled = true;
  bool firstRunHandled = false; // 首次啟動的模型引導是否已處理（下載或略過）

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    confidenceThreshold = _prefs!.getDouble(_kThreshold) ?? 0.6;
    themeMode = ThemeMode.values
        .byName(_prefs!.getString(_kThemeMode) ?? ThemeMode.dark.name);
    eslCorrectionEnabled = _prefs!.getBool(_kEslCorrection) ?? true;
    firstRunHandled = _prefs!.getBool(_kFirstRunHandled) ?? false;
    notifyListeners();
  }

  Future<void> setFirstRunHandled() async {
    firstRunHandled = true;
    await _prefs?.setBool(_kFirstRunHandled, true);
    notifyListeners();
  }

  Future<void> setThreshold(double value) async {
    confidenceThreshold = value;
    await _prefs?.setDouble(_kThreshold, value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    await _prefs?.setString(_kThemeMode, mode.name);
    notifyListeners();
  }

  Future<void> setEslCorrection(bool enabled) async {
    eslCorrectionEnabled = enabled;
    await _prefs?.setBool(_kEslCorrection, enabled);
    notifyListeners();
  }
}
