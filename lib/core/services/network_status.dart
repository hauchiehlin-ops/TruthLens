import 'package:http/http.dart' as http;

/// 輕量連線狀態檢查：在執行超連結／文獻參考真實性驗證前，先快速確認裝置目前
/// 是否有可用的網際網路連線。App 執行時預設假定網路可用；若訊號不佳或離線，
/// 應明確提示使用者「需要網路連線才能完成這兩項分析」，而不是讓每一筆連結／
/// 文獻各自逾時、顯示一堆分散、令人困惑的「無法確認」訊息。
class NetworkStatus {
  static Future<bool> isOnline({
    http.Client? client,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final c = client ?? http.Client();
    final owns = client == null;
    try {
      // Crossref 是超連結（DOI）與文獻參考驗證共同依賴的服務，直接以此探測連線，
      // 不另外引入新的第三方連線探測端點。收到任何 HTTP 回應（含 4xx）即代表
      // 網路本身是通的；只有連線逾時／DNS 失敗等例外才視為離線。
      final response = await c
          .head(Uri.parse('https://api.crossref.org/works'))
          .timeout(timeout);
      return response.statusCode < 500;
    } catch (_) {
      return false;
    } finally {
      if (owns) c.close();
    }
  }
}
