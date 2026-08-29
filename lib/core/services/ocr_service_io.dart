import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/ocr_post_processor.dart';
import 'ocr_failure.dart';

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
  static OcrFailure? _lastFailure;

  /// 見 web 實作的說明：服務層只回報成因，字串由顯示端依語系產生。
  static OcrFailure? get lastFailure => _lastFailure;

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

  /// The local companion server is only used by the Web build.
  static Future<bool> testLocalServer() async => false;

  /// Gemini 連線驗證與「已驗證」狀態記憶僅適用於 Web 版設定卡。
  static Future<bool> testGeminiKey() async => false;
  static String? getVerifiedLocalServerUrl() => null;
  static String? getVerifiedGeminiApiKey() => null;

  /// 此平台是否已實作 OCR
  Future<bool> get isSupported async {
    try {
      final ok = await _channel.invokeMethod<bool>('ping');
      if (ok != true) {
        _lastFailure = const OcrFailure(OcrFailureKind.nativePluginNoPing);
      }
      return ok ?? false;
    } on MissingPluginException {
      _lastFailure = const OcrFailure(OcrFailureKind.nativePluginMissing);
      return false;
    } catch (e) {
      _lastFailure = OcrFailure(
        OcrFailureKind.nativeCheckFailed,
        detail: '$e',
      );
      return false;
    }
  }

  Future<bool> get isReadyForPdfOcr => isSupported;

  /// 辨識圖片檔中的文字。回傳 null 表示平台不支援或辨識失敗。
  /// [languages] 為 BCP-47 語言提示（如 ['zh-Hant','en-US']），部分平台會參考。
  Future<String?> recognize(String imagePath, {List<String>? languages}) async {
    _lastFailure = null;
    try {
      final text = await _channel.invokeMethod<String>('recognize', {
        'path': imagePath,
        'languages': languages ?? const ['zh-Hant', 'zh-Hans', 'en-US'],
      });
      if (text == null || text.trim().isEmpty) {
        _lastFailure = const OcrFailure(OcrFailureKind.noTextDetected);
      }
      return text == null ? null : OcrPostProcessor.clean(text);
    } on MissingPluginException {
      _lastFailure = const OcrFailure(OcrFailureKind.nativePluginMissing);
      return null;
    } on PlatformException catch (e) {
      _lastFailure = OcrFailure(
        OcrFailureKind.nativeFailed,
        detail: e.message == null ? e.code : '${e.code}: ${e.message}',
      );
      return null;
    }
  }

  Future<String?> recognizeBytes(
    Uint8List bytes, {
    String mimeType = 'image/png',
    List<String>? languages,
  }) async {
    final extension = mimeType == 'image/jpeg' ? 'jpg' : 'png';
    final file = File(
      '${Directory.systemTemp.path}/truthlens_pdf_ocr_${DateTime.now().microsecondsSinceEpoch}.$extension',
    );
    try {
      await file.writeAsBytes(bytes, flush: true);
      return await recognize(file.path, languages: languages);
    } finally {
      try {
        if (await file.exists()) await file.delete();
      } catch (_) {}
    }
  }
}
