import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// 輕量連線狀態檢查：在執行超連結／文獻參考真實性驗證前，先快速確認裝置目前
/// 是否有可用的網際網路連線。App 執行時預設假定網路可用；若訊號不佳或離線，
/// 應明確提示使用者「需要網路連線才能完成這兩項分析」，而不是讓每一筆連結／
/// 文獻各自逾時、顯示一堆分散、令人困惑的「無法確認」訊息。
class NetworkStatus {
  static String _getProxiedUrl(String targetUrl) {
    if (!kIsWeb) return targetUrl;
    try {
      final proxyPath = '/api/proxy?url=${Uri.encodeComponent(targetUrl)}';
      return Uri.base.resolve(proxyPath).toString();
    } catch (_) {
      return 'https://truth-lens-band-b.vercel.app/api/proxy?url=${Uri.encodeComponent(targetUrl)}';
    }
  }

  static Future<bool> isOnline({
    http.Client? client,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final c = client ?? http.Client();
    final owns = client == null;
    try {
      // 1) 首選探測端點：直接 GET 請求 Crossref API (rows=0 傳回輕量 200 OK)。
      // 避免使用 HEAD 請求，因為 Crossref API 會回傳 HTTP 405 (Method Not Allowed)
      // 導致被誤判為連線失敗。帶上標準 User-Agent 防範 Cloudflare / WAF 阻擋。
      final uri = Uri.parse(
        _getProxiedUrl('https://api.crossref.org/works?rows=0'),
      );
      final response = await c
          .get(
            uri,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) TruthLens/1.0',
            },
          )
          .timeout(timeout);

      if (response.statusCode < 500) {
        return true;
      }
    } catch (_) {
      // 2) 備援探測端點：若 Crossref API 服務維護中，備援探測輕量標準 204 端點
      try {
        final fallbackUri = Uri.parse(
          'https://clients3.google.com/generate_204',
        );
        final response = await c
            .get(fallbackUri)
            .timeout(const Duration(seconds: 3));
        return response.statusCode == 204 || response.statusCode == 200;
      } catch (_) {}
    } finally {
      if (owns) c.close();
    }
    return false;
  }
}
