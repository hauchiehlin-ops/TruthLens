import 'dart:convert';

import 'package:http/http.dart' as http;

/// 「參考文獻目錄」核實：許多學術文件的參考文獻條目沒有 DOI 或任何超連結
/// （純作者—年份格式，如 `Ahlers, G., Cannell, D.S., 1983. 篇名. 期刊, 卷, 頁碼.`），
/// [LinkVerifier] 的 DOI 核實規則無法涵蓋。這裡改用 Crossref 的「書目查詢」
/// （bibliographic query）端點——直接把整條參考文獻字串送去搜尋最相近的登記文獻，
/// 再比對篇名相似度、年份與第一作者姓氏，分三檔回報：
///   - 高可信度：篇名高度相似，且年份或作者其中至少一項吻合 → 應存在
///   - 查無相近匹配 → 可能為虛構文獻
///   - 其餘（部分吻合）→ 無法確定，需自行核對
/// 僅送出參考文獻的文字本身（書名/篇名/作者/年份等已公開於文件中的資訊），
/// 不下載全文、不涉及使用者的其他文件內容。
///
/// 偵測不依賴文件明確標示「這是參考文獻」：優先找 References/參考文獻等標題，
/// 找不到時改為主動掃描全文比對作者—年份格式（見 [extractEntries]），
/// 只要累積達 [minEntriesWithoutHeading] 筆以上即視為文獻目錄並主動分析。
enum CitationMatchConfidence { high, uncertain, notFound }

class BibliographyEntry {
  final String rawText;
  final String? firstAuthorSurname;
  final int? year;
  final String? title;

  const BibliographyEntry({
    required this.rawText,
    this.firstAuthorSurname,
    this.year,
    this.title,
  });
}

class BibliographyCheckResult {
  final BibliographyEntry entry;
  final CitationMatchConfidence confidence;
  final String? matchedTitle;
  final String? matchedJournal;
  final int? matchedYear;

  const BibliographyCheckResult({
    required this.entry,
    required this.confidence,
    this.matchedTitle,
    this.matchedJournal,
    this.matchedYear,
  });
}

class BibliographyVerifier {
  /// 單次報告最多驗證的條目數，避免長篇文獻目錄拖慢報告載入。
  static const maxEntriesPerCheck = 15;

  static final RegExp _sectionHeading = RegExp(
    r'^\s*(references|bibliography|works cited|參考文獻|參考書目|引用文獻)\s*$',
    caseSensitive: false,
    multiLine: true,
  );

  /// 條目起始樣式：一位以上作者「Surname, Initials.」（以純逗號、"and"、"&" 任意
  /// 組合連接，如 "A, B., C, D., and E, F."）後接四位數年份與句點。
  static final RegExp _entryStart = RegExp(
    r"(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+,\s*(?:[A-Z]\.\s*)+)"
    r"(?:(?:,\s*(?:and\s+)?|and\s+|&\s*)"
    r"[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+,\s*(?:[A-Z]\.\s*)+)*"
    r'(?:,\s*)?(\d{4})\.\s*',
  );

  /// 沒有明確「References」等標題時，判定為參考文獻目錄所需的最少條目數。
  /// 文件不一定會標示「這是文獻目錄」，但真正的文獻清單通常會有好幾筆緊鄰的
  /// 作者—年份格式條目；門檻用來過濾掉內文中偶然出現、單一一兩筆的巧合
  /// （例如一般敘述中剛好出現類似「Surname, X., 年份.」的片段）。
  static const minEntriesWithoutHeading = 3;

  /// 偵測文件中的參考文獻條目並依條目切分；找不到任何條目時回傳空陣列，
  /// 不做任何連線動作。
  ///
  /// 兩種偵測路徑：
  /// 1. 找得到「References/Bibliography/參考文獻」等標題 → 標題後的內容視為
  ///    文獻目錄，即使只有 1 筆也算數（標題本身就是明確訊號）
  /// 2. 找不到標題（文件未必會明確標示「他們是文獻」）→ 改為對整份文件掃描
  ///    作者—年份格式的條目，但需累積達 [minEntriesWithoutHeading] 筆以上
  ///    才視為真正的文獻目錄，避免內文偶然出現的單一巧合片段被誤判
  static List<BibliographyEntry> extractEntries(String text) {
    final headingMatch = _sectionHeading.firstMatch(text);
    final hasHeading = headingMatch != null;
    final section = hasHeading ? text.substring(headingMatch.end) : text;

    final starts = _entryStart.allMatches(section).toList();
    if (starts.isEmpty) return [];
    if (!hasHeading && starts.length < minEntriesWithoutHeading) return [];

    final entries = <BibliographyEntry>[];
    for (var i = 0; i < starts.length; i++) {
      final start = starts[i];
      final endIndex =
          i + 1 < starts.length ? starts[i + 1].start : section.length;
      final raw = section.substring(start.start, endIndex).trim();
      if (raw.length < 15) continue; // 過短，可能是誤判的斷點
      entries.add(_parseEntry(raw, start.end - start.start,
          int.tryParse(start.group(1) ?? '')));
    }
    return entries;
  }

  static BibliographyEntry _parseEntry(
      String raw, int prefixLength, int? year) {
    final commaIdx = raw.indexOf(',');
    final surname = commaIdx > 0 ? raw.substring(0, commaIdx).trim() : null;
    final afterPrefix =
        prefixLength <= raw.length ? raw.substring(prefixLength) : '';
    final titleEnd = afterPrefix.indexOf('. ');
    final title =
        (titleEnd > 0 ? afterPrefix.substring(0, titleEnd) : afterPrefix)
            .trim();
    return BibliographyEntry(
      rawText: raw,
      firstAuthorSurname: surname,
      year: year,
      title: title.isEmpty ? null : title,
    );
  }

  /// 對每條參考文獻查詢 Crossref 書目搜尋，判定其存在可信度。
  static Future<List<BibliographyCheckResult>> verifyAll(
    List<BibliographyEntry> entries, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final c = client ?? http.Client();
    final owns = client == null;
    try {
      final results = <BibliographyCheckResult>[];
      for (final entry in entries.take(maxEntriesPerCheck)) {
        results.add(await _verifyOne(c, entry, timeout));
      }
      return results;
    } finally {
      if (owns) c.close();
    }
  }

  static Future<BibliographyCheckResult> _verifyOne(
    http.Client client,
    BibliographyEntry entry,
    Duration timeout,
  ) async {
    final uri = Uri.parse('https://api.crossref.org/works').replace(
      queryParameters: {
        'query.bibliographic': entry.rawText,
        'rows': '1',
      },
    );
    try {
      final response = await client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        return BibliographyCheckResult(
            entry: entry, confidence: CitationMatchConfidence.uncertain);
      }
      final message = (jsonDecode(response.body)
          as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
      final items = (message?['items'] as List?)?.cast<dynamic>();
      if (items == null || items.isEmpty) {
        return BibliographyCheckResult(
            entry: entry, confidence: CitationMatchConfidence.notFound);
      }

      final top = items.first as Map<String, dynamic>;
      final titles = (top['title'] as List?)?.cast<dynamic>();
      final matchedTitle =
          (titles != null && titles.isNotEmpty) ? titles.first.toString() : null;
      final containers = (top['container-title'] as List?)?.cast<dynamic>();
      final matchedJournal = (containers != null && containers.isNotEmpty)
          ? containers.first.toString()
          : null;
      final dateParts = ((top['published'] as Map<String, dynamic>?)
              ?['date-parts'] as List?)
          ?.cast<dynamic>();
      final matchedYear = (dateParts != null &&
              dateParts.isNotEmpty &&
              (dateParts.first as List).isNotEmpty)
          ? (dateParts.first as List).first as int
          : null;
      final authors = (top['author'] as List?)?.cast<dynamic>() ?? const [];
      final authorSurnames = authors
          .map((a) =>
              (a as Map<String, dynamic>)['family']?.toString().toLowerCase())
          .whereType<String>()
          .toSet();

      final titleSim = _titleSimilarity(entry.title, matchedTitle);
      final yearMatches = entry.year != null &&
          matchedYear != null &&
          (entry.year! - matchedYear).abs() <= 1;
      final authorMatches = entry.firstAuthorSurname != null &&
          authorSurnames.contains(entry.firstAuthorSurname!.toLowerCase());

      final confidence = (titleSim >= 0.5 && (yearMatches || authorMatches))
          ? CitationMatchConfidence.high
          : (titleSim < 0.2 && !yearMatches && !authorMatches)
              ? CitationMatchConfidence.notFound
              : CitationMatchConfidence.uncertain;

      return BibliographyCheckResult(
        entry: entry,
        confidence: confidence,
        matchedTitle: matchedTitle,
        matchedJournal: matchedJournal,
        matchedYear: matchedYear,
      );
    } catch (_) {
      return BibliographyCheckResult(
          entry: entry, confidence: CitationMatchConfidence.uncertain);
    }
  }

  /// 篇名相似度：正規化後的詞彙集合做 Jaccard 相似度（交集/聯集），
  /// 不需額外依賴套件即可粗略判斷「是否為同一篇文獻」。
  static double _titleSimilarity(String? a, String? b) {
    if (a == null || b == null) return 0;
    final wordsA = _normalizeWords(a);
    final wordsB = _normalizeWords(b);
    if (wordsA.isEmpty || wordsB.isEmpty) return 0;
    final intersection = wordsA.intersection(wordsB).length;
    final union = wordsA.union(wordsB).length;
    return union == 0 ? 0 : intersection / union;
  }

  static Set<String> _normalizeWords(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 2)
      .toSet();
}
