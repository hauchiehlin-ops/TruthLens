import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WorkspaceMode { original, commandGrid, missionTimeline, evidenceCanvas }

/// 使用者偏好設定（閾值、主題、ESL 修正開關）
class PreferencesService extends ChangeNotifier {
  static const engineRoles = <String>[
    'transformer',
    'statistical',
    'stylometry',
    'adversarial',
  ];
  static const defaultEngineWeights = <String, double>{
    'transformer': 0.40,
    'statistical': 0.25,
    'stylometry': 0.20,
    'adversarial': 0.15,
  };
  static const _kThemeMode = 'theme_mode';
  static const _kEslCorrection = 'esl_correction';
  static const _kFirstRunHandled = 'first_run_handled';
  static const _kModelPromptSuppressed = 'model_prompt_suppressed';
  static const _kDisabledEngines = 'disabled_engines';
  static const _kLinkVerificationEnabled = 'link_verification_enabled';
  static const _kLocale = 'app_locale';
  static const _kWorkspaceMode = 'workspace_mode';
  static const _kEngineWeightPrefix = 'engine_weight_';
  static const _kEnginePreferencesSchema = 'engine_preferences_schema';
  static const _currentEnginePreferencesSchema = 2;

  SharedPreferences? _prefs;

  ThemeMode themeMode = ThemeMode.system;
  bool eslCorrectionEnabled = true;
  bool firstRunHandled = false; // 首次啟動的模型引導是否已處理（下載或略過）
  bool modelPromptSuppressed = false; // 使用者選擇「不再提醒下載模型」
  // 是否允許連線驗證文件中的超連結／期刊引用是否真實存在；核心 AI 推論仍完全
  // 在裝置端執行，但此為主動分析所需的必要連線功能，預設開啟，使用者可在設定關閉。
  bool linkVerificationEnabled = true;
  // null＝使用專案預設英文；非 null＝使用者於設定手動選擇的語系。
  Locale? locale;
  WorkspaceMode workspaceMode = WorkspaceMode.commandGrid;
  Set<String> _disabledEngines = {};
  Map<String, double> _engineWeights = Map.of(defaultEngineWeights);

  Map<String, double> get engineWeights => Map.unmodifiable(_engineWeights);

  double engineWeight(String engineId) =>
      _engineWeights[engineId] ?? defaultEngineWeights[engineId] ?? 0;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    themeMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == _prefs!.getString(_kThemeMode),
      orElse: () => ThemeMode.system,
    );
    eslCorrectionEnabled = _prefs!.getBool(_kEslCorrection) ?? true;
    firstRunHandled = _prefs!.getBool(_kFirstRunHandled) ?? false;
    modelPromptSuppressed = _prefs!.getBool(_kModelPromptSuppressed) ?? false;
    linkVerificationEnabled =
        _prefs!.getBool(_kLinkVerificationEnabled) ?? true;
    await Future.wait([
      _prefs!.remove('web_of_science_api_key'),
      _prefs!.remove('engineering_village_api_key'),
      _prefs!.remove('engineering_village_institution_token'),
    ]);
    final engineSchema = _prefs!.getInt(_kEnginePreferencesSchema) ?? 0;
    if (engineSchema < _currentEnginePreferencesSchema) {
      await _prefs!.remove(_kDisabledEngines);
      await _prefs!.setInt(
        _kEnginePreferencesSchema,
        _currentEnginePreferencesSchema,
      );
    }
    locale = _decodeLocale(_prefs!.getString(_kLocale));
    workspaceMode = WorkspaceMode.values.firstWhere(
      (mode) => mode.name == _prefs!.getString(_kWorkspaceMode),
      orElse: () => WorkspaceMode.commandGrid,
    );
    _disabledEngines = (_prefs!.getStringList(_kDisabledEngines) ?? []).toSet();
    final loadedWeights = <String, double>{
      for (final role in engineRoles)
        role:
            _prefs!.getDouble('$_kEngineWeightPrefix$role') ??
            defaultEngineWeights[role]!,
    };
    _engineWeights = _isValidWeightSet(loadedWeights)
        ? loadedWeights
        : Map.of(defaultEngineWeights);
    notifyListeners();
  }

  static bool _isValidWeightSet(Map<String, double> values) {
    if (!engineRoles.every(values.containsKey)) return false;
    if (values.values.any((value) => value < 0 || value > 1)) return false;
    final total = engineRoles.fold<double>(
      0,
      (sum, role) => sum + values[role]!,
    );
    return (total - 1).abs() < 0.0001;
  }

  Future<void> setEngineWeights(Map<String, double> values) async {
    final normalized = <String, double>{
      for (final role in engineRoles) role: values[role] ?? -1,
    };
    if (!_isValidWeightSet(normalized)) {
      throw ArgumentError('Engine weights must total 100%.');
    }
    _engineWeights = normalized;
    for (final entry in normalized.entries) {
      await _prefs?.setDouble('$_kEngineWeightPrefix${entry.key}', entry.value);
    }
    notifyListeners();
  }

  static Locale? _decodeLocale(String? tag) {
    if (tag == null || tag.isEmpty) return null;
    final parts = tag.split('_');
    return parts.length > 1
        ? Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1])
        : Locale(parts[0]);
  }

  static String _encodeLocale(Locale locale) => locale.scriptCode != null
      ? '${locale.languageCode}_${locale.scriptCode}'
      : locale.languageCode;

  Future<void> setLocale(Locale? value) async {
    locale = value;
    if (value == null) {
      await _prefs?.remove(_kLocale);
    } else {
      await _prefs?.setString(_kLocale, _encodeLocale(value));
    }
    notifyListeners();
  }

  Future<void> setWorkspaceMode(WorkspaceMode value) async {
    if (workspaceMode == value) return;
    workspaceMode = value;
    notifyListeners();
    await _prefs?.setString(_kWorkspaceMode, value.name);
  }

  Future<void> setLinkVerificationEnabled(bool value) async {
    linkVerificationEnabled = value;
    await _prefs?.setBool(_kLinkVerificationEnabled, value);
    notifyListeners();
  }

  bool isEngineEnabled(String engineId) => !_disabledEngines.contains(engineId);

  Future<void> setEngineEnabled(String engineId, bool enabled) async {
    if (enabled) {
      _disabledEngines.remove(engineId);
    } else {
      _disabledEngines.add(engineId);
    }
    await _prefs?.setStringList(_kDisabledEngines, _disabledEngines.toList());
    notifyListeners();
  }

  Future<void> setFirstRunHandled() async {
    firstRunHandled = true;
    await _prefs?.setBool(_kFirstRunHandled, true);
    notifyListeners();
  }

  Future<void> setModelPromptSuppressed(bool value) async {
    modelPromptSuppressed = value;
    await _prefs?.setBool(_kModelPromptSuppressed, value);
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
