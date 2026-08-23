import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

/// 文件內超連結的存在性驗證。會依需要連線（見
/// [PreferencesService.linkVerificationEnabled]，預設開啟，使用者可在設定關閉），
/// 僅傳送網址／DOI 本身以查證連結或文獻是否存在，不傳送文件內容。
///
/// ## 期刊文獻目錄格式的判斷規則
/// AI 生成內容常附上看似合理但實際不存在的「幻覺引用」。若超連結是 DOI
/// （Digital Object Identifier，如 `https://doi.org/10.xxxx/...`）——這是出版社
/// 向 Crossref／DataCite 等機構登記的學術文獻標準身分證，等同於該文獻在其期刊
/// 出版目錄中的正式登記——則視為「期刊文獻目錄格式」，改用 Crossref 的公開
/// metadata API（`api.crossref.org/works/{doi}`）查詢：
///   - 查得到 → 這筆 DOI 確實登記在其出版社／期刊目錄中，回傳期刊名稱與篇名供比對
///   - 404（查無此 DOI）→ 極可能為虛構引用
///   - 連線失敗 → 無法確認
/// 僅查詢中介 metadata，不下載全文。非 DOI 的一般網址則退回單純的連線可達性檢查
/// （無法宣稱「已列於期刊目錄」，因為那需要逐一期刊網站的專屬解析，不具通用性）。
enum LinkStatus { reachable, notFound, unreachable }

class LinkCheckResult {
  final String url;
  final LinkStatus status;
  final int? statusCode;

  /// 是否依「期刊文獻目錄」規則驗證（DOI → Crossref 登記比對），
  /// 而非僅是單純的連線可達性檢查。
  final bool isCitationVerified;

  /// Crossref 回傳的期刊／出版品名稱（僅 [isCitationVerified] 為 true 且查得到時提供）。
  final String? journalName;

  /// Crossref 回傳的篇名（僅 [isCitationVerified] 為 true 且查得到時提供）。
  final String? articleTitle;

  /// Crossref 登記的 DOI 與最早可用出版年。
  final String? doi;
  final int? publicationYear;

  const LinkCheckResult({
    required this.url,
    required this.status,
    this.statusCode,
    this.isCitationVerified = false,
    this.journalName,
    this.articleTitle,
    this.doi,
    this.publicationYear,
  });
}

class LinkVerifier {
  /// 單次報告最多驗證的連結數，避免內容中含大量連結時拖慢報告載入。
  static const maxLinksPerCheck = 20;

  /// 取得代理 URL（Web 環境中用以繞過 CORS 限制）
  static String _getProxiedUrl(String targetUrl) {
    if (!kIsWeb) return targetUrl;

    // 正式部署優先使用同源代理；本機靜態伺服器沒有 `/api/proxy`，改走目前
    // 可用的正式代理。舊 truth-lens-band-b 專案已失效，不得再作 fallback。
    try {
      if (Uri.base.host == '127.0.0.1' || Uri.base.host == 'localhost') {
        return 'https://truth-lens-roan-three.vercel.app/api/proxy?url=${Uri.encodeComponent(targetUrl)}';
      }
      final proxyPath = '/api/proxy?url=${Uri.encodeComponent(targetUrl)}';
      return Uri.base.resolve(proxyPath).toString();
    } catch (_) {
      return 'https://truth-lens-roan-three.vercel.app/api/proxy?url=${Uri.encodeComponent(targetUrl)}';
    }
  }

  static final RegExp _urlPattern = RegExp(r'''https?://[^\s<>"'`　-￿]+''');

  /// DOI 格式（依 Crossref 規範：字首 `10.` + 4-9 碼註冊者代碼 + `/` + 任意後綴）。
  static final RegExp _doiSuffixPattern = RegExp(r'^10\.\d{4,9}/\S+$');
  static final RegExp _bareDoiPattern = RegExp(
    r'10\.\d{4,9}/[-._;()/:A-Z0-9]+',
    caseSensitive: false,
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

  /// 從文字抽取 DOI（含裸 DOI），並移除句尾標點。
  static List<String> extractDois(String text) {
    final seen = <String>{};
    final result = <String>[];
    for (final match in _bareDoiPattern.allMatches(text)) {
      var doi = match.group(0)!;
      while (doi.isNotEmpty && '.,;:!?)]}、。，；：'.contains(doi[doi.length - 1])) {
        doi = doi.substring(0, doi.length - 1);
      }
      doi = doi.toLowerCase();
      if (doi.isNotEmpty && seen.add(doi)) result.add(doi);
    }
    return result;
  }

  /// 判斷網址是否為 DOI 連結，即「期刊文獻目錄格式」。
  static bool isDoiUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    if (host != 'doi.org' && host != 'dx.doi.org') return false;
    final doi = uri.path.replaceFirst(RegExp(r'^/+'), '');
    return _doiSuffixPattern.hasMatch(doi);
  }

  /// 對每個網址發出連線請求以確認是否可解析／文獻是否確實登記存在。
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
        results.add(
          isDoiUrl(url)
              ? await _verifyDoiCitation(c, url, timeout)
              : await _verifyOne(c, url, timeout),
        );
      }
      return results;
    } finally {
      if (owns) c.close();
    }
  }

  /// 核實單一 DOI；可接受裸 DOI 或 doi.org 網址。
  static Future<LinkCheckResult> verifyDoi(
    String doiOrUrl, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final normalized = isDoiUrl(doiOrUrl)
        ? doiOrUrl
        : 'https://doi.org/${doiOrUrl.trim()}';
    final c = client ?? http.Client();
    final owns = client == null;
    try {
      return await _verifyDoiCitation(c, normalized, timeout);
    } finally {
      if (owns) c.close();
    }
  }

  /// 期刊文獻目錄核實：查詢 Crossref 的 DOI 登記資料（不下載全文）。
  static Future<LinkCheckResult> _verifyDoiCitation(
    http.Client client,
    String url,
    Duration timeout,
  ) async {
    final uri = Uri.tryParse(url)!;
    final doi = uri.path.replaceFirst(RegExp(r'^/+'), '');
    final crossrefUrl = 'https://api.crossref.org/works/$doi';

    // 在 Web 環境中使用代理以解決 CORS 問題
    final apiUri = Uri.parse(_getProxiedUrl(crossrefUrl));
    try {
      final response = await client.get(apiUri).timeout(timeout);
      if (response.statusCode == 200) {
        final message =
            (jsonDecode(response.body) as Map<String, dynamic>)['message']
                as Map<String, dynamic>?;
        final titles = (message?['title'] as List?)?.cast<dynamic>();
        final containers = (message?['container-title'] as List?)
            ?.cast<dynamic>();
        final registeredDoi = message?['DOI']?.toString();
        return LinkCheckResult(
          url: url,
          status: LinkStatus.reachable,
          statusCode: 200,
          isCitationVerified: true,
          articleTitle: (titles != null && titles.isNotEmpty)
              ? titles.first.toString()
              : null,
          journalName: (containers != null && containers.isNotEmpty)
              ? containers.first.toString()
              : null,
          doi: registeredDoi ?? doi,
          publicationYear: _publicationYear(message),
        );
      }
      if (response.statusCode == 404) {
        return LinkCheckResult(
          url: url,
          status: LinkStatus.notFound,
          statusCode: 404,
          isCitationVerified: true,
          doi: doi,
        );
      }
      return LinkCheckResult(
        url: url,
        status: LinkStatus.unreachable,
        statusCode: response.statusCode,
        isCitationVerified: true,
        doi: doi,
      );
    } catch (_) {
      return LinkCheckResult(
        url: url,
        status: LinkStatus.unreachable,
        isCitationVerified: true,
      );
    }
  }

  static int? _publicationYear(Map<String, dynamic>? message) {
    if (message == null) return null;
    for (final key in const [
      'published-print',
      'published-online',
      'published',
      'issued',
      'created',
    ]) {
      final value = message[key];
      if (value is! Map) continue;
      final parts = value['date-parts'];
      if (parts is List && parts.isNotEmpty && parts.first is List) {
        final first = parts.first as List;
        if (first.isNotEmpty && first.first is num) {
          return (first.first as num).toInt();
        }
      }
      final timestamp = value['date-time']?.toString();
      final parsed = timestamp == null ? null : DateTime.tryParse(timestamp);
      if (parsed != null) return parsed.year;
    }
    return null;
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
