import 'package:http/http.dart' as http;

/// 文件內超連結的存在性驗證。**唯一**需要連線的功能，預設關閉
/// （見 [PreferencesService.linkVerificationEnabled]），使用者需在設定中手動開啟。
/// 開啟後，僅對偵測到的網址發出 HEAD/GET 請求以確認是否可解析，不傳送文件內容。
enum LinkStatus { reachable, notFound, unreachable }

class LinkCheckResult {
  final String url;
  final LinkStatus status;
  final int? statusCode;

  const LinkCheckResult({
    required this.url,
    required this.status,
    this.statusCode,
  });
}

class LinkVerifier {
  /// 單次報告最多驗證的連結數，避免內容中含大量連結時拖慢報告載入。
  static const maxLinksPerCheck = 20;

  static final RegExp _urlPattern = RegExp(
    r'''https?://[^\s<>"'`　-￿]+''',
  );

  /// 從文字中抽取所有網址（依出現順序去重）；不做任何連線動作。
  static List<String> extractUrls(String text) {
    final seen = <String>{};
    final result = <String>[];
    for (final match in _urlPattern.allMatches(text)) {
      var url = match.group(0)!;
      // 去除常見的尾隨標點（句尾的網址常黏著標點符號）
      while (url.isNotEmpty && '.,;:!?)]}、。，；：'.contains(url[url.length - 1])) {
        url = url.substring(0, url.length - 1);
      }
      if (url.isEmpty || seen.contains(url)) continue;
      seen.add(url);
      result.add(url);
    }
    return result;
  }

  /// 對每個網址發出連線請求以確認是否可解析。**僅在使用者已手動開啟此功能時呼叫**。
  static Future<List<LinkCheckResult>> verifyAll(
    List<String> urls, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final c = client ?? http.Client();
    final owns = client == null;
    try {
      final results = <LinkCheckResult>[];
      for (final url in urls.take(maxLinksPerCheck)) {
        results.add(await _verifyOne(c, url, timeout));
      }
      return results;
    } finally {
      if (owns) c.close();
    }
  }

  static Future<LinkCheckResult> _verifyOne(
    http.Client client,
    String url,
    Duration timeout,
  ) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return LinkCheckResult(url: url, status: LinkStatus.unreachable);
    }
    try {
      var response = await client.head(uri).timeout(timeout);
      if (response.statusCode == 405) {
        // 部分伺服器不支援 HEAD，改用 GET 重試
        response = await client.get(uri).timeout(timeout);
      }
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return LinkCheckResult(
          url: url,
          status: LinkStatus.reachable,
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode == 404 || response.statusCode == 410) {
        return LinkCheckResult(
          url: url,
          status: LinkStatus.notFound,
          statusCode: response.statusCode,
        );
      }
      return LinkCheckResult(
        url: url,
        status: LinkStatus.unreachable,
        statusCode: response.statusCode,
      );
    } catch (_) {
      return LinkCheckResult(url: url, status: LinkStatus.unreachable);
    }
  }
}
