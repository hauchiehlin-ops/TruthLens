import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/ocr_post_processor.dart';

/// 原生平台 OCR 服務（macOS、iOS、Android；Windows 需註冊對應外掛後才可用）
///
/// 透過 MethodChannel 呼叫各平台的 on-device 文字辨識：
///   macOS  → Vision 框架（VNRecognizeTextRequest，已實作）
///   iOS    → Vision 框架
///   Android→ ML Kit Text Recognition
///   Windows→ Windows.Media.Ocr（規劃/需外掛註冊）
///
/// 原生端未實作的平台會拋 [MissingPluginException]，此處捕捉後回傳 null，
/// UI 顯示「此平台尚未支援 OCR」。
class OcrService {
  static const _channel = MethodChannel('com.truthlens/ocr');

  // Web 版以 localStorage 存放，原生版以 SharedPreferences 持久化；
  // 為維持與共用 UI（settings_screen）相同的同步 API，採記憶體快取 + 非同步落地。
  static const String _storageKeyApiKey = 'ocr_gemini_api_key';
  static const String _storageKeyServerUrl = 'ocr_local_server_url';
  static String? _cachedApiKey;
  static String? _cachedServerUrl;
  static bool _hydrated = false;
  static String? _lastErrorMessage;

  static String? get lastErrorMessage => _lastErrorMessage;

  /// 由 App 啟動時呼叫一次，將持久化的設定載入記憶體快取。
  static Future<void> hydrate() async {
    if (_hydrated) return;
    final prefs = await SharedPreferences.getInstance();
    _cachedApiKey = prefs.getString(_storageKeyApiKey);
    _cachedServerUrl = prefs.getString(_storageKeyServerUrl);
    _hydrated = true;
  }

  /// 設定 Gemini API 金鑰（由 UI 層調用）
  static void setGeminiApiKey(String key) {
    _cachedApiKey = key.isEmpty ? null : key;
    SharedPreferences.getInstance().then((p) {
      if (key.isEmpty) {
        p.remove(_storageKeyApiKey);
      } else {
        p.setString(_storageKeyApiKey, key);
      }
    });
  }

  /// 設定本地伺服器 URL（由 UI 層調用）
  static void setLocalServerUrl(String url) {
    _cachedServerUrl = url.isEmpty ? null : url;
    SharedPreferences.getInstance().then((p) {
      if (url.isEmpty) {
        p.remove(_storageKeyServerUrl);
      } else {
        p.setString(_storageKeyServerUrl, url);
      }
    });
  }

  /// 取得目前設定的 Gemini API 金鑰
  static String? getGeminiApiKey() => _cachedApiKey;

  /// 取得目前設定的本地伺服器 URL
  static String? getLocalServerUrl() => _cachedServerUrl;

  /// 此平台是否已實作 OCR
  Future<bool> get isSupported async {
    try {
      final ok = await _channel.invokeMethod<bool>('ping');
      if (ok != true) {
        _lastErrorMessage = '此平台的原生 OCR 外掛未回應 ping。';
      }
      return ok ?? false;
    } on MissingPluginException {
      _lastErrorMessage = '此平台尚未註冊原生 OCR 外掛。';
      return false;
    } catch (e) {
      _lastErrorMessage = '原生 OCR 外掛檢查失敗：$e';
      return false;
    }
  }

  /// 辨識圖片檔中的文字。回傳 null 表示平台不支援或辨識失敗。
  /// [languages] 為 BCP-47 語言提示（如 ['zh-Hant','en-US']），部分平台會參考。
  Future<String?> recognize(String imagePath, {List<String>? languages}) async {
    _lastErrorMessage = null;
    try {
      final text = await _channel.invokeMethod<String>('recognize', {
        'path': imagePath,
        'languages': languages ?? const ['zh-Hant', 'zh-Hans', 'en-US'],
      });
      if (text == null || text.trim().isEmpty) {
        _lastErrorMessage = '原生 OCR 已執行，但圖片中未辨識到可用文字。';
      }
      return text == null ? null : OcrPostProcessor.clean(text);
    } on MissingPluginException {
      _lastErrorMessage = '此平台尚未註冊原生 OCR 外掛。';
      return null;
    } on PlatformException catch (e) {
      _lastErrorMessage =
          '原生 OCR 執行失敗：${e.code}${e.message == null ? '' : '，${e.message}'}';
      return null;
    }
  }
}
