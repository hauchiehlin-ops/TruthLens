import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart';
import 'package:http/http.dart' as http;
import '../utils/ocr_post_processor.dart';

/// Web 版 OCR 服務 — Gemini API + 本地伺服器備援
///
/// 優先順序：
/// 1. 本地伺服器（如果用戶配置了 `localServerUrl`）
/// 2. Gemini API（如果用戶提供了 API 金鑰）
/// 3. 佇列機制避免速率限制（Gemini Free Tier: 1500 req/day）
/// 4. 指數退避重試
class OcrService {
  static const String _storageKeyApiKey = 'ocr_gemini_api_key';
  static const String _storageKeyServerUrl = 'ocr_local_server_url';

  // 佇列與速率限制機制（Gemini Free Tier: 1500 req/day = ~2 req/min）
  static const int _requestDelayMs = 2000; // 相鄰請求間隔（毫秒）
  static const int _maxRetries = 3;
  static const int _initialBackoffMs = 1000;
  static const int _maxBackoffMs = 30000; // 最大退避時間（30秒）

  static DateTime? _lastGeminiRequestTime;
  static String? _lastErrorMessage;

  static String? get lastErrorMessage => _lastErrorMessage;

  /// 此平台是否支援 OCR（Web 版永遠回傳 true）
  Future<bool> get isSupported async => true;

  /// 嘗試從本地伺服器進行 OCR
  Future<String?> _recognizeFromLocalServer(
    String imageDataUrl, {
    List<String>? languages,
  }) async {
    try {
      final serverUrl = window.localStorage
          .getItem(_storageKeyServerUrl)
          ?.trim();
      if (serverUrl == null || serverUrl.isEmpty) return null;
      final response = await http
          .post(
            Uri.parse(serverUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'image': imageDataUrl,
              'languages': languages ?? ['zh-Hant', 'zh-Hans', 'en-US'],
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final results = json['results'] as List<dynamic>? ?? [];
        if (results.isNotEmpty) {
          // 本地伺服器回傳的是結構化結果，這裡簡單合併為文字
          return OcrPostProcessor.clean(
            results
                .map(
                  (r) => (r as Map<String, dynamic>)['text'] as String? ?? '',
                )
                .join('\n'),
          );
        }
        final text = json['text'] as String?;
        if (text != null && text.trim().isNotEmpty) {
          return OcrPostProcessor.clean(text);
        }
        _lastErrorMessage =
            '本地 OCR 伺服器有回應，但未回傳文字。請確認回應格式含 results[].text 或 text。';
      } else {
        _lastErrorMessage =
            '本地 OCR 伺服器回應 ${response.statusCode}：${response.body}';
      }
    } catch (e) {
      _lastErrorMessage = '本地 OCR 伺服器無法連線或逾時：$e';
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
      _lastErrorMessage =
          'Web OCR 尚未設定：請在設定輸入 Gemini API 金鑰，或填入本地 OCR 伺服器 URL。';
      return null; // 使用者未提供 API 金鑰
    }

    // 實施指數退避重試
    int retryCount = 0;
    int backoffMs = _initialBackoffMs;

    while (retryCount <= _maxRetries) {
      try {
        // 尊重相鄰請求間隔（避免速率限制）
        if (_lastGeminiRequestTime != null) {
          final timeSinceLastRequest = DateTime.now()
              .difference(_lastGeminiRequestTime!)
              .inMilliseconds;
          if (timeSinceLastRequest < _requestDelayMs) {
            await Future.delayed(
              Duration(milliseconds: _requestDelayMs - timeSinceLastRequest),
            );
          }
        }

        final prompt = languages?.contains('zh-Hant') == true
            ? '請精準辨識並轉錄此圖片中的所有文字。保持文字閱讀順序與段落結構。中文請不要在字與字之間加入額外空格。只回傳轉錄出的文字內容，切勿包含任何Markdown引號、解說或附加說明。'
            : 'Extract and transcribe all text from this image with high precision. Maintain reading order and paragraph structure. Return ONLY the transcribed text without any conversational remarks, markdown code blocks, or extra commentary.';

        final response = await http
            .post(
              Uri.parse(
                'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey',
              ),
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
              final rawText =
                  (parts[0] as Map<String, dynamic>)['text'] as String? ?? '';
              final text = OcrPostProcessor.clean(rawText);
              if (text.isEmpty) {
                _lastErrorMessage = 'Gemini 已回應，但圖片中未偵測到可用文字。';
              }
              return text.isEmpty ? null : text;
            }
          }
          _lastErrorMessage = 'Gemini 已回應，但回應中沒有可解析文字。';
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
            _lastErrorMessage = 'Gemini OCR 達到速率或配額限制（429），請稍後再試或改用本地 OCR 伺服器。';
            return null; // 超過重試次數，回傳 null
          }
        } else if (response.statusCode == 400) {
          // 無效參數 — 不重試
          debugPrint('Gemini API invalid request (400): ${response.body}');
          _lastErrorMessage = 'Gemini OCR 請求格式錯誤（400）：${response.body}';
          return null;
        } else if (response.statusCode == 401) {
          // 無效金鑰 — 不重試
          debugPrint('Gemini API unauthorized (401): invalid API key');
          _lastErrorMessage = 'Gemini API 金鑰無效或未授權（401），請重新貼上有效金鑰。';
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
            _lastErrorMessage =
                'Gemini OCR 失敗（HTTP ${response.statusCode}）：${response.body}';
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
          _lastErrorMessage = 'Gemini OCR 連線或解析失敗：$e';
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
  Future<String?> recognize(String imagePath, {List<String>? languages}) async {
    _lastErrorMessage = null;

    // Web 版本由 ImagePicker 傳入 data URL。
    String imageDataUrl;
    if (imagePath.startsWith('data:image/')) {
      imageDataUrl = imagePath;
    } else {
      _lastErrorMessage = 'Web OCR 未取得圖片資料。請重新選取圖片；若仍失敗，可能是瀏覽器未提供檔案 bytes。';
      return null;
    }

    // 優先嘗試本地伺服器
    final hasLocalServer =
        (window.localStorage.getItem(_storageKeyServerUrl)?.trim() ?? '')
            .isNotEmpty;
    final hasApiKey =
        (window.localStorage.getItem(_storageKeyApiKey)?.trim() ?? '')
            .isNotEmpty;

    if (!hasLocalServer && !hasApiKey) {
      _lastErrorMessage =
          'Web OCR 尚未設定：請在設定輸入 Gemini API 金鑰，或填入本地 OCR 伺服器 URL。';
      return null;
    }

    final localResult = await _recognizeFromLocalServer(
      imageDataUrl,
      languages: languages,
    );
    if (localResult != null && localResult.isNotEmpty) {
      return localResult;
    }

    // 備援：Gemini API（自動處理速率限制與重試）
    return await _recognizeFromGemini(imageDataUrl, languages: languages);
  }

  /// Web 版設定即時存取 localStorage，無需預先載入；提供空實作以對齊原生 API。
  static Future<void> hydrate() async {}

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

  /// Checks the companion server's lightweight status endpoint without
  /// sending any image data.
  static Future<bool> testLocalServer() async {
    final configured = getLocalServerUrl()?.trim();
    if (configured == null || configured.isEmpty) return false;
    try {
      final endpoint = Uri.parse(configured);
      final segments = [...endpoint.pathSegments];
      if (segments.isNotEmpty && segments.last.toLowerCase() == 'ocr') {
        segments[segments.length - 1] = 'status';
      } else {
        segments.add('status');
      }
      final statusUri = endpoint.replace(pathSegments: segments);
      final response = await http
          .get(statusUri)
          .timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return false;
      final payload = jsonDecode(response.body);
      return payload is Map<String, dynamic> && payload['status'] == 'running';
    } catch (_) {
      return false;
    }
  }

  /// 檢查是否配置了任何 OCR 方案
  static bool hasAnyOcrConfigured() {
    final hasApiKey =
        (window.localStorage.getItem(_storageKeyApiKey)?.trim() ?? '')
            .isNotEmpty;
    final hasServerUrl =
        (window.localStorage.getItem(_storageKeyServerUrl)?.trim() ?? '')
            .isNotEmpty;
    return hasApiKey || hasServerUrl;
  }

  /// ===== 助手方法 =====
}
