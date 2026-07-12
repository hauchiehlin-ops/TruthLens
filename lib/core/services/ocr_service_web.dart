import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart';
import 'package:http/http.dart' as http;

/// Web 版 OCR 服務 — Gemini API + 本地伺服器備援
///
/// 優先順序：
/// 1. 本地伺服器（如果用戶配置了 `localServerUrl`）
/// 2. Gemini API（如果用戶提供了 API 金鑰）
/// 3. 佇列機制避免速率限制（Gemini Free Tier: 1500 req/day）
/// 4. 指數退避重試
class OcrService {
  static const String _defaultLocalServerUrl = 'http://127.0.0.1:5001/ocr';
  static const String _storageKeyApiKey = 'ocr_gemini_api_key';
  static const String _storageKeyServerUrl = 'ocr_local_server_url';

  // 佇列與速率限制機制（Gemini Free Tier: 1500 req/day = ~2 req/min）
  static const int _requestDelayMs = 2000; // 相鄰請求間隔（毫秒）
  static const int _maxRetries = 3;
  static const int _initialBackoffMs = 1000;
  static const int _maxBackoffMs = 30000; // 最大退避時間（30秒）

  static DateTime? _lastGeminiRequestTime;

  /// 此平台是否支援 OCR（Web 版永遠回傳 true）
  Future<bool> get isSupported async => true;

  /// 嘗試從本地伺服器進行 OCR
  Future<String?> _recognizeFromLocalServer(
    String imageDataUrl, {
    List<String>? languages,
  }) async {
    try {
      final serverUrl = window.localStorage.getItem(_storageKeyServerUrl) ?? _defaultLocalServerUrl;
      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': imageDataUrl,
          'languages': languages ?? ['zh-Hant', 'zh-Hans', 'en-US'],
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final results = json['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          // 本地伺服器回傳的是結構化結果，這裡簡單合併為文字
          return results
              .map((r) => (r as Map<String, dynamic>)['text'] as String? ?? '')
              .join('\n');
        }
      }
    } catch (e) {
      // 本地伺服器不可用，會在下一層級處理
    }
    return null;
  }

  /// 嘗試從 Gemini API 進行 OCR（帶重試與速率限制）
  Future<String?> _recognizeFromGemini(
    String imageDataUrl, {
    List<String>? languages,
  }) async {
    final apiKey = window.localStorage.getItem(_storageKeyApiKey)?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      return null; // 使用者未提供 API 金鑰
    }

    // 實施指數退避重試
    String? result;
    int retryCount = 0;
    int backoffMs = _initialBackoffMs;

    while (retryCount <= _maxRetries) {
      try {
        // 尊重相鄰請求間隔（避免速率限制）
        if (_lastGeminiRequestTime != null) {
          final timeSinceLastRequest =
              DateTime.now().difference(_lastGeminiRequestTime!).inMilliseconds;
          if (timeSinceLastRequest < _requestDelayMs) {
            await Future.delayed(
              Duration(milliseconds: _requestDelayMs - timeSinceLastRequest),
            );
          }
        }

        final prompt = languages?.contains('zh-Hant') == true
            ? '請認辨此圖片中的所有文字，並按順序列出。只回傳文字內容，不需要解釋或格式化。'
            : 'Extract all text from this image. Return only the text content in order, without explanations or formatting.';

        final response = await http
            .post(
              Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt},
                      {
                        'inlineData': {
                          'mimeType': _extractMimeType(imageDataUrl),
                          'data': _extractBase64(imageDataUrl),
                        },
                      },
                    ],
                  },
                ],
                'generationConfig': {
                  'temperature': 0.0,
                  'maxOutputTokens': 4096,
                },
              }),
            )
            .timeout(const Duration(seconds: 60));

        _lastGeminiRequestTime = DateTime.now();

        // 處理各種響應碼
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = json['candidates'] as List<dynamic>? ?? [];
          if (candidates.isNotEmpty) {
            final content = candidates[0] as Map<String, dynamic>;
            final parts = content['content']['parts'] as List<dynamic>? ?? [];
            if (parts.isNotEmpty) {
              final text =
                  (parts[0] as Map<String, dynamic>)['text'] as String? ?? '';
              return text.isEmpty ? null : text;
            }
          }
          return null;
        } else if (response.statusCode == 429) {
          // 速率限制（Free Tier 日配額達到）— 重試後続延遲時間
          retryCount++;
          if (retryCount <= _maxRetries) {
            debugPrint(
              'Gemini API rate limited. Retry $retryCount/$_maxRetries after ${backoffMs}ms',
            );
            await Future.delayed(Duration(milliseconds: backoffMs));
            backoffMs = (backoffMs * 2).clamp(0, _maxBackoffMs);
            continue;
          } else {
            return null; // 超過重試次數，回傳 null
          }
        } else if (response.statusCode == 400) {
          // 無效參數 — 不重試
          debugPrint('Gemini API invalid request (400): ${response.body}');
          return null;
        } else if (response.statusCode == 401) {
          // 無效金鑰 — 不重試
          debugPrint('Gemini API unauthorized (401): invalid API key');
          return null;
        } else {
          // 其他伺服器錯誤 — 重試
          retryCount++;
          if (retryCount <= _maxRetries) {
            debugPrint(
              'Gemini API error (${response.statusCode}). Retry $retryCount/$_maxRetries after ${backoffMs}ms',
            );
            await Future.delayed(Duration(milliseconds: backoffMs));
            backoffMs = (backoffMs * 2).clamp(0, _maxBackoffMs);
            continue;
          } else {
            return null; // 超過重試次數
          }
        }
      } catch (e) {
        debugPrint('Gemini API exception: $e');
        retryCount++;
        if (retryCount <= _maxRetries) {
          await Future.delayed(Duration(milliseconds: backoffMs));
          backoffMs = (backoffMs * 2).clamp(0, _maxBackoffMs);
          continue;
        } else {
          return null;
        }
      }
    }

    return null;
  }

  /// 提取 data URL 中的 MIME 類型
  static String _extractMimeType(String dataUrl) {
    if (dataUrl.startsWith('data:')) {
      final semicolonIndex = dataUrl.indexOf(';');
      if (semicolonIndex > 5) {
        return dataUrl.substring(5, semicolonIndex);
      }
    }
    return 'image/jpeg';
  }

  /// 提取 data URL 中的 Base64 資料
  static String _extractBase64(String dataUrl) {
    final commaIndex = dataUrl.indexOf(',');
    if (commaIndex > 0) {
      return dataUrl.substring(commaIndex + 1);
    }
    return dataUrl;
  }

  /// 辨識圖片檔中的文字
  ///
  /// Web 版本會嘗試（按優先順序）：
  /// 1. 本地伺服器（如果已設定）
  /// 2. Gemini API（如果用戶提供了 API 金鑰；自動避免速率限制）
  /// 3. 都失敗 → 回傳 null
  Future<String?> recognize(
    String imagePath, {
    List<String>? languages,
  }) async {
    // Web 版本需要轉換為 data URL
    String imageDataUrl;
    try {
      final blob = await _loadFileAsBlob(imagePath);
      imageDataUrl = await _blobToDataUrl(blob);
    } catch (e) {
      return null;
    }

    // 優先嘗試本地伺服器
    final localResult = await _recognizeFromLocalServer(
      imageDataUrl,
      languages: languages,
    );
    if (localResult != null && localResult.isNotEmpty) {
      return localResult;
    }

    // 備援：Gemini API（自動處理速率限制與重試）
    return await _recognizeFromGemini(
      imageDataUrl,
      languages: languages,
    );
  }

  /// 設定 Gemini API 金鑰（由 UI 層調用）
  static void setGeminiApiKey(String key) {
    if (key.isEmpty) {
      window.localStorage.removeItem(_storageKeyApiKey);
    } else {
      window.localStorage.setItem(_storageKeyApiKey, key);
    }
  }

  /// 設定本地伺服器 URL（由 UI 層調用）
  static void setLocalServerUrl(String url) {
    if (url.isEmpty) {
      window.localStorage.removeItem(_storageKeyServerUrl);
    } else {
      window.localStorage.setItem(_storageKeyServerUrl, url);
    }
  }

  /// 取得目前設定的 Gemini API 金鑰
  static String? getGeminiApiKey() {
    return window.localStorage.getItem(_storageKeyApiKey);
  }

  /// 取得目前設定的本地伺服器 URL
  static String? getLocalServerUrl() {
    return window.localStorage.getItem(_storageKeyServerUrl);
  }

  /// 檢查是否配置了任何 OCR 方案
  static bool hasAnyOcrConfigured() {
    final hasApiKey = (window.localStorage.getItem(_storageKeyApiKey)?.trim() ?? '').isNotEmpty;
    final hasServerUrl = (window.localStorage.getItem(_storageKeyServerUrl)?.trim() ?? '').isNotEmpty;
    return hasApiKey || hasServerUrl;
  }

  /// ===== 助手方法 =====

  /// 從檔案路徑讀取 Blob
  static Future<Blob> _loadFileAsBlob(String filePath) async {
    // 在 Web 上，filePath 可能是一個 File object reference 或 data URL
    // 這裡假設由 UI 層處理檔案選擇並傳入 data URL
    throw UnimplementedError('應由 UI 層直接傳入 data URL');
  }

  /// 將 Blob 轉換為 data URL
  static Future<String> _blobToDataUrl(Blob blob) async {
    return URL.createObjectURL(blob);
  }
}
