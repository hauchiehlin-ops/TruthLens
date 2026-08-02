import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

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
  static const maxEntriesPerCheck = 30;

  static final RegExp _sectionHeading = RegExp(
    r'(?:\b(?:references|bibliography|works cited|literature cited|sources)\b|參考文獻|參考書目|引用文獻|主要參考文獻|文獻目錄)',
    caseSensitive: false,
  );

  /// 常用學術期刊、研討會、出版社、文獻標記與數位識別碼特徵
  static final RegExp _journalKeyword = RegExp(
    r'(?:Journal of|Transactions|Proceedings|Proc\.|IEEE|ACM|Springer|Elsevier|Nature|Science|arXiv|doi\.org|DOI:|PMID:|vol\.|no\.|pp\.|p\.|pages|Wiley|Press|Inc\.|Ed\.|Edition|學報|期刊|論文集|研討會|出版社|第\s*\d+\s*卷|第\s*\d+\s*期|第\s*\d+\s*頁|頁\s*\d+|\[[JCMDROPOL]\])',
    caseSensitive: false,
  );

  /// 條列式、全形/半形括號與數字編號前綴（如 [1], (1), 1., ①, 【1】, 〔1〕, ［1］, [Ref 1], •, -）
  /// 排除 4 位數年份（如 [1965]），避免內文年份引用被誤算為編號前綴。
  static final RegExp _bulletOrNumberPrefix = RegExp(
    r'^\s*(?:\[\s*(?!(?:18|19|20)\d\d\b)(?:\d{1,3}|[A-Za-z]|Ref\s*\d+)\s*\]|\(\s*\d{1,3}\s*\)|\d{1,3}[\.、\)]|[\u2460-\u2473]|[\u2474-\u2487]|【\d{1,3}】|〔\d{1,3}〕|［\d{1,3}］|[-*•])\s*',
    caseSensitive: false,
  );

  /// 四位數西元紀年 (1800-2099)
  static final RegExp _yearRegex = RegExp(r'\b(18\d\d|19\d\d|20\d\d)\b');

  /// 中文作者與多作者標記（如：張三、李四等）
  static final RegExp _chineseAuthor = RegExp(
    r'[\u4e00-\u9fa5]{2,4}(?:[、,，\s]+(?:[\u4e00-\u9fa5]{2,4}|等|著|編|譯))+',
  );

  /// 偵測參考文獻條目的開頭特徵（支援 Surname, F. M. (1983) 及 Surname, F. M. [1983] 括號格式）。
  static final RegExp _entryStart = RegExp(
    r"(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s*,\s*(?:[A-Z]\s*\.\s*)+)"
    r"(?:(?:\s*,\s*(?:and\s+)?|and\s+|&\s*)"
    r"[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s*,\s*(?:[A-Z]\s*\.\s*)+)*"
    r"(?:\s*,\s*)?(?:\(|\[)?\s*(\d{4})[a-z]?\s*(?:\)|\])?(?:[.,:])?\s*",
  );

  /// 沒有明確「References」等標題時，判定為參考文獻目錄所需的最少條目數（至少 3 筆，避免內文巧合誤判）。
  static const int minEntriesWithoutHeading = 3;

  /// 預處理 OCR / PDF 擷取文字的格式瑕疵：
  /// 1. 清除 PDF 頁首/頁尾雜訊（如 November/December 2010 EXPERIMENTAL TECHNIQUES 47 STABILITY OF TAYLOR-COUETTE FLOW）
  /// 2. 補全連寫缺失空格：如 `Coles,D.,1965.Transition` -> `Coles, D., 1965. Transition`
  /// 3. 清除連字號斷行：如 `modu- lated` -> `modulated`
  /// 4. 修正括號內多餘空格：如 `[ 2 ]` -> `[2]`, `( 3 )` -> `(3)`
  /// 5. 在未斷行的連寫嵌合編號前自動插入換行符：將連在一起的 `1995. [ 2 ] H INDS` 切開為多行獨立條目
  static String _preprocessOcrText(String input) {
    var text = input;

    // 1) 清除 PDF 出版社浮水印、欄位邊界與頁尾雜訊 (如 Downloaded By: [Lin, Hau-Chieh] At: 14:43 11 November 2010)
    text = text.replaceAll(
      RegExp(
        r'Downloaded\s+By:\s*\[[^\]]+\][^\n\r]*',
        caseSensitive: false,
      ),
      '\n',
    );
    text = text.replaceAll(
      RegExp(
        r'\b(?:January|February|March|April|May|June|July|August|September|October|November|December)\s*/?\s*(?:January|February|March|April|May|June|July|August|September|October|November|December)?\s*\d{4}\s+[A-Z0-9\s—–-]{5,60}',
        caseSensitive: false,
      ),
      '\n',
    );

    // 2) 修正 PDF / OCR 擠壓文字遺失空格問題：在標點符號後緊接英文字母或數字時自動補齊空格
    text = text.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9])([,\.:;])([a-zA-Z0-9])'),
      (m) => '${m.group(1)}${m.group(2)} ${m.group(3)}',
    );

    // 3) 恢復 OCR 擠壓單字間空白（如 Possiblemechanism -> Possible mechanism, PhysicalReviewA -> Physical Review A）
    text = text.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );

    // 4) 修正跨行斷詞產生的連字號割裂問題（僅在連字號後接換行時剔除連字號，保留 Schultz-Grunow 等雙姓氏連字號）
    text = text.replaceAllMapped(
      RegExp(r'([a-zA-Z]{2,})-\s*[\r\n]+\s*([a-zA-Z]{2,})'),
      (m) => '${m.group(1)}${m.group(2)}',
    );

    // 5) 修正方括號與圓括號內的空白雜訊：[ 2 ] -> [2], ( 12 ) -> (12)
    text = text.replaceAllMapped(
      RegExp(r'\[\s*(\d+|[A-Za-z]|Ref\s*\d+)\s*\]'),
      (m) => '[${m.group(1)}]',
    );
    text = text.replaceAllMapped(
      RegExp(r'\(\s*(\d+)\s*\)'),
      (m) => '(${m.group(1)})',
    );

    // 6) 修正 OCR 渲染將字首單大寫字母斷開的瑕疵：\b([A-Z])\s+([A-Z]{2,})\b -> $1$2
    text = text.replaceAllMapped(
      RegExp(r'\b([A-Z])\s+([A-Z]{2,})\b'),
      (m) => '${m.group(1)}${m.group(2)}',
    );
    text = text.replaceAllMapped(
      RegExp(r'\b([A-Za-z]+)\s+([a-z])\b'),
      (m) => '${m.group(1)}${m.group(2)}',
    );

    // 7) 在未斷行的連寫嵌合條目編號前主動插入換行符（排除 [1965] 等 4 位數年份）：
    text = text.replaceAllMapped(
      RegExp(
          r'(?<=\S)\s*(\[\s*(?!(?:18|19|20)\d\d\b)\d{1,3}\s*\]|\b\d{1,3}\.\s+[A-Z])'),
      (m) => '\n${m.group(1)}',
    );

    return text;
  }

  /// 偵測文件中的參考文獻條目並依條目切分；找不到任何條目時回傳空陣列。
  static List<BibliographyEntry> extractEntries(String rawText) {
    final text = _preprocessOcrText(rawText);

    // 取文獻尾端的最後一個 References/參考文獻 標題（防止內文提及 references 字眼早判）
    final headingMatches = _sectionHeading.allMatches(text).toList();
    final headingMatch =
        headingMatches.isNotEmpty ? headingMatches.last : null;
    final hasHeading = headingMatch != null;
    final section = hasHeading ? text.substring(headingMatch.end) : text;

    // 路徑 1：標準英文 Surname, F.M. (Year) 傳統格式
    final starts = _entryStart.allMatches(section).toList();
    final path1Entries = <BibliographyEntry>[];
    if (starts.isNotEmpty &&
        (hasHeading || starts.length >= minEntriesWithoutHeading)) {
      for (var i = 0; i < starts.length; i++) {
        final start = starts[i];
        final endIndex =
            i + 1 < starts.length ? starts[i + 1].start : section.length;
        final raw = section.substring(start.start, endIndex).trim();
        if (raw.length < 15) continue;
        path1Entries.add(_parseEntry(raw, start.end - start.start,
            int.tryParse(start.group(1) ?? '')));
      }
    }

    // 路徑 2：跨行組裝與通用學術特徵動態加權評分管線
    final rawLines = section.split(RegExp(r'\r?\n'));
    final groupedBlocks = <String>[];
    String? currentBlock;

    // 判斷該文獻區塊是否為數字編號格式（例如 [1], [2], 1.）
    final hasNumberedEntries = rawLines
            .where((l) => _bulletOrNumberPrefix.hasMatch(l.trim()))
            .length >=
        2;

    for (final rawLine in rawLines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // 檢查是否為頁首/頁尾噪音（例如 "70 B. LIAO et al."、"Page 12 of 15" 或 "---"）
      if (RegExp(
              r'^(?:\d+\s+[A-Z]\.\s*[A-Z]+.*|Page\s+\d+.*|Copyright\s+.*|[-—=_]{3,})$',
              caseSensitive: false)
          .hasMatch(line)) {
        continue;
      }

      // 判斷該行是否為全新條目的開頭
      final isNewEntryStart = hasNumberedEntries
          ? _bulletOrNumberPrefix.hasMatch(line)
          : (_bulletOrNumberPrefix.hasMatch(line) ||
              RegExp(r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s*,\s*[A-Z]\.")
                  .hasMatch(line) ||
              RegExp(r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s+[A-Z]\.")
                  .hasMatch(line) ||
              RegExp(r'^[\u4e00-\u9fa5]{2,4}[、,，]').hasMatch(line) ||
              RegExp(r'^\[[JCMDROPOL]\]', caseSensitive: false).hasMatch(line));

      if (isNewEntryStart) {
        if (currentBlock != null && currentBlock.trim().isNotEmpty) {
          groupedBlocks.add(currentBlock.trim());
        }
        currentBlock = line;
      } else {
        if (currentBlock != null) {
          currentBlock = '$currentBlock $line';
        } else if (line.length >= 15) {
          currentBlock = line;
        }
      }
    }
    if (currentBlock != null && currentBlock.trim().isNotEmpty) {
      groupedBlocks.add(currentBlock.trim());
    }

    final candidates = <BibliographyEntry>[];

    for (final block in groupedBlocks) {
      if (block.length < 15 || block.length > 500) continue;

      final score = _calculateCitationScore(block, hasHeading);
      final yearMatch = _yearRegex.firstMatch(block);
      final year =
          yearMatch != null ? int.tryParse(yearMatch.group(1) ?? '') : null;

      // 門檻：當計算總分 >= 0.45（若含有文獻標題時門檻降至 0.30）時即判定為合法學術條目
      if (score >= (hasHeading ? 0.30 : 0.45)) {
        final cleaned = block.replaceAll(_bulletOrNumberPrefix, '');
        candidates.add(_parseLineEntry(cleaned, block, year));
      }
    }

    // 擇優機制：當路徑 2 擷取到相同或更多條目時優先採用 (路徑 2 具備完整跨行組裝能力)
    if (candidates.length >= path1Entries.length && candidates.isNotEmpty) {
      if (!hasHeading && candidates.length < minEntriesWithoutHeading) {
        return [];
      }
      return candidates;
    } else {
      if (!hasHeading && path1Entries.length < minEntriesWithoutHeading) {
        return [];
      }
      return path1Entries;
    }
  }

  /// 動態學術文獻加權評分引擎 (0.0 - 1.0)
  static double _calculateCitationScore(String block, bool hasHeading) {
    var score = 0.0;
    if (_bulletOrNumberPrefix.hasMatch(block)) score += 0.35;
    if (_yearRegex.hasMatch(block)) score += 0.35;
    if (_journalKeyword.hasMatch(block)) score += 0.25;
    if (RegExp(r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s*,\s*[A-Z]").hasMatch(block) ||
        RegExp(r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s+[A-Z]\.").hasMatch(block) ||
        _chineseAuthor.hasMatch(block)) {
      score += 0.25;
    }
    if (RegExp(r'\b\d+\s*[\(\:]\s*\d+\s*[\)\:]?\s*\d*\b').hasMatch(block) ||
        RegExp(r'\b(?:pp?|pages|vol|no)\.\s*\d+', caseSensitive: false)
            .hasMatch(block)) {
      score += 0.20;
    }
    if (RegExp(r'(?:https?:\/\/|doi:\s*|arXiv:\s*)', caseSensitive: false)
        .hasMatch(block)) {
      score += 0.30;
    }
    if (hasHeading) score += 0.15;
    return score;
  }

  static BibliographyEntry _parseEntry(
      String raw, int prefixLength, int? year) {
    final commaIdx = raw.indexOf(',');
    final surname = commaIdx > 0 ? raw.substring(0, commaIdx).trim() : null;
    final afterPrefix =
        prefixLength <= raw.length ? raw.substring(prefixLength) : '';
    final quoteMatch =
        RegExp(r'["“「〈《]([^"”」〉»\r\n]+)["”」〉»]').firstMatch(afterPrefix);
    final titleEnd = afterPrefix.indexOf('. ');
    final title = quoteMatch?.group(1)?.replaceAll(RegExp(r',+$'), '')?.trim() ??
        (titleEnd > 0 ? afterPrefix.substring(0, titleEnd) : afterPrefix)
            .trim();
    return BibliographyEntry(
      rawText: raw,
      firstAuthorSurname: surname,
      year: year,
      title: title.isEmpty ? null : title,
    );
  }

  static BibliographyEntry _parseLineEntry(
      String cleaned, String rawText, int? year) {
    final cleanedNoPrefix =
        cleaned.replaceAll(_bulletOrNumberPrefix, '').trim();

    // 優先抽取篇名引號或書名號（如 "..." 或 “...” 或 「...」 或 〈...〉 或 《...》）
    final quoteMatch =
        RegExp(r'["“「〈《]([^"”」〉»\r\n]+)["”」〉»]').firstMatch(cleanedNoPrefix);
    String? title =
        quoteMatch?.group(1)?.replaceAll(RegExp(r',+$'), '')?.trim();

    if (title == null || title.isEmpty) {
      // 若有西元年 (例如 1983. 或 1986. 或 (1983))，年份後第一個以句號分割的段落即為真正的論文篇名
      if (year != null) {
        final yearPattern = RegExp('\\b${year}[a-z]?\\b[\\.\\,:]?\\s*');
        final yearMatch = yearPattern.firstMatch(cleanedNoPrefix);
        if (yearMatch != null) {
          final afterYear = cleanedNoPrefix.substring(yearMatch.end).trim();
          final titleEnd = afterYear.indexOf('. ');
          if (titleEnd > 5) {
            title = afterYear.substring(0, titleEnd).trim();
          } else if (afterYear.isNotEmpty) {
            final periodIdx = afterYear.indexOf('.');
            title = (periodIdx > 5 ? afterYear.substring(0, periodIdx) : afterYear).trim();
          }
        }
      }

      if (title == null || title.isEmpty || title.length < 5) {
        // 嘗試先剔除開頭的作者群（如 "COHEN B.S., HERING S.V., "）
        final noAuthors = cleanedNoPrefix
            .replaceAll(
              RegExp(
                  r"^(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s*(?:,\s*)?[A-Z]\s*\.\s*(?:[A-Z]\s*\.\s*)?(?:\s*,\s*|\s+and\s+|\s*&\s*)*)+",
                  caseSensitive: false),
              '',
            )
            .trim();

        final parts = (noAuthors.isNotEmpty ? noAuthors : cleanedNoPrefix)
            .split(RegExp(r'[\.度。]\s*'));
        if (parts.isNotEmpty && parts.first.trim().length > 5) {
          title = parts.first.trim();
        } else if (parts.length > 1 && parts[1].trim().length > 5) {
          title = parts[1].trim();
        } else {
          title = cleanedNoPrefix;
        }
      }
    }

    // 嘗試抽取第一作者姓氏或中文姓名
    String? surname;
    final commaIdx = cleanedNoPrefix.indexOf(',');
    if (commaIdx > 0 && commaIdx < 40) {
      final partBeforeComma = cleanedNoPrefix.substring(0, commaIdx).trim();
      surname = partBeforeComma.split(RegExp(r'\s+')).first;
    } else {
      final spaceParts = cleanedNoPrefix.split(RegExp(r'\s+'));
      if (spaceParts.isNotEmpty &&
          RegExp(r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+$").hasMatch(spaceParts.first)) {
        surname = spaceParts.first;
      } else {
        final chineseMatch =
            RegExp(r'^[\u4e00-\u9fa5]{2,4}').firstMatch(cleanedNoPrefix);
        if (chineseMatch != null) {
          surname = chineseMatch.group(0);
        }
      }
    }

    return BibliographyEntry(
      rawText: rawText,
      firstAuthorSurname: surname,
      year: year,
      title: (title == null || title.isEmpty) ? null : title,
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
    // 1) 兼具結構化 (title, author) 與全文字串 (query.bibliographic) 的 Crossref 查核
    final queryParams = <String, String>{
      'query.bibliographic': entry.rawText,
      'rows': '1',
    };
    if (entry.title != null && entry.title!.trim().length >= 5) {
      final cleanTitle = entry.title!.trim();
      final hasUnspacedLongWord =
          cleanTitle.split(RegExp(r'\s+')).any((w) => w.length >= 15 && !w.contains('-'));
      if (!hasUnspacedLongWord) {
        queryParams['query.title'] = cleanTitle;
      }
      if (entry.firstAuthorSurname != null &&
          entry.firstAuthorSurname!.length >= 2) {
        queryParams['query.author'] = entry.firstAuthorSurname!;
      }
    }

    final uri = Uri.parse('https://api.crossref.org/works').replace(
      queryParameters: queryParams,
    );

    BibliographyCheckResult? crossrefResult;

    try {
      final response = await client.get(
        uri,
        headers: {
          'User-Agent':
              'TruthLens/1.0 (https://github.com/hauchiehlin-ops/TruthLens; mailto:support@truthlens.app)',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final message = (jsonDecode(response.body)
            as Map<String, dynamic>)['message'] as Map<String, dynamic>?;
        final items = (message?['items'] as List?)?.cast<dynamic>();
        if (items != null && items.isNotEmpty) {
          final top = items.first as Map<String, dynamic>;
          final titles = (top['title'] as List?)?.cast<dynamic>();
          final matchedTitle = (titles != null && titles.isNotEmpty)
              ? titles.first.toString()
              : null;
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
              .map((a) => (a as Map<String, dynamic>)['family']
                  ?.toString()
                  .toLowerCase())
              .whereType<String>()
              .toSet();

          final titleSim =
              _titleSimilarity(entry.title ?? entry.rawText, matchedTitle);
          final yearMatches = entry.year != null &&
              matchedYear != null &&
              (entry.year! - matchedYear).abs() <= 1;
          final authorMatches = entry.firstAuthorSurname != null &&
              authorSurnames.contains(entry.firstAuthorSurname!.toLowerCase());

          final confidence =
              (titleSim >= 0.35 || (yearMatches && authorMatches))
                  ? CitationMatchConfidence.high
                  : (titleSim < 0.15 && !yearMatches && !authorMatches)
                      ? CitationMatchConfidence.notFound
                      : CitationMatchConfidence.uncertain;

          crossrefResult = BibliographyCheckResult(
            entry: entry,
            confidence: confidence,
            matchedTitle: matchedTitle,
            matchedJournal: matchedJournal,
            matchedYear: matchedYear,
          );
        } else {
          crossrefResult = BibliographyCheckResult(
            entry: entry,
            confidence: CitationMatchConfidence.notFound,
          );
        }
      }
    } catch (_) {}

    if (crossrefResult != null &&
        (crossrefResult.confidence == CitationMatchConfidence.high ||
         crossrefResult.confidence == CitationMatchConfidence.notFound)) {
      return crossrefResult;
    }

    // 2) 若 Crossref 未命中（如 1800-1900 19 世紀法文/歷史期刊古籍），發動 OpenAlex API 二重補核 (涵蓋 2.5 億筆文獻)
    try {
      final searchKw = entry.title ?? entry.rawText;
      final openAlexUri = Uri.parse(
        'https://api.openalex.org/works?search=${Uri.encodeComponent(searchKw)}&per_page=1',
      );
      final oaResp = await client.get(
        openAlexUri,
        headers: {
          'User-Agent':
              'TruthLens/1.0 (https://github.com/hauchiehlin-ops/TruthLens; mailto:support@truthlens.app)',
        },
      ).timeout(timeout);

      if (oaResp.statusCode == 200) {
        final data = jsonDecode(oaResp.body) as Map<String, dynamic>?;
        final results = (data?['results'] as List?)?.cast<dynamic>();
        if (results != null && results.isNotEmpty) {
          final top = results.first as Map<String, dynamic>;
          final matchedTitle = top['title']?.toString();
          final matchedYear = top['publication_year'] as int?;
          final hostVenue = top['primary_location']?['source'] as Map<String, dynamic>?;
          final matchedJournal = hostVenue?['display_name']?.toString();
          final titleSim = _titleSimilarity(entry.title ?? entry.rawText, matchedTitle);

          if (titleSim >= 0.35 || (matchedYear != null && entry.year == matchedYear)) {
            return BibliographyCheckResult(
              entry: entry,
              confidence: CitationMatchConfidence.high,
              matchedTitle: matchedTitle,
              matchedJournal: matchedJournal ?? 'OpenAlex 收錄學術期刊',
              matchedYear: matchedYear,
            );
          }
        }
      }
    } catch (_) {}

    return crossrefResult ??
        BibliographyCheckResult(
          entry: entry,
          confidence: CitationMatchConfidence.uncertain,
        );
  }

  /// 升級版篇名相似度：支援「無空格連寫 (OCR 擠壓文字)」與「詞彙 Jaccard」雙重比對。
  /// 能對抗無空格 `TransitionincircularCouetteflow` 與 `Transition in circular Couette flow` 的比對瑕疵。
  static double _titleSimilarity(String? a, String? b) {
    if (a == null || b == null) return 0;
    
    final cleanA = a.replaceAll(RegExp(r'[^a-zA-Z0-9\u4e00-\u9fa5]'), '').toLowerCase();
    final cleanB = b.replaceAll(RegExp(r'[^a-zA-Z0-9\u4e00-\u9fa5]'), '').toLowerCase();
    if (cleanA.isEmpty || cleanB.isEmpty) return 0;

    // 1) 完全吻合或長子字串包含（防範無空格連續文字）
    if (cleanA == cleanB) return 1.0;
    if (cleanA.length >= 10 && cleanB.length >= 10) {
      if (cleanA.contains(cleanB) || cleanB.contains(cleanA)) return 0.95;
    }

    // 2) 詞彙級 Jaccard 相似度
    final wordsA = _normalizeWords(a);
    final wordsB = _normalizeWords(b);
    final tokenSim = (wordsA.isEmpty || wordsB.isEmpty)
        ? 0.0
        : (wordsA.intersection(wordsB).length / wordsA.union(wordsB).length);

    // 3) 僅在其中一方欠缺空格（如 OCR 擠壓成單一長單字）時才發動字元級備援
    if (wordsA.length <= 1 || wordsB.length <= 1) {
      final setA = cleanA.split('').toSet();
      final setB = cleanB.split('').toSet();
      final charSim = (setA.isEmpty || setB.isEmpty)
          ? 0.0
          : (setA.intersection(setB).length / setA.union(setB).length);
      return math.max(tokenSim, charSim * 0.85);
    }

    return tokenSim;
  }

  static Set<String> _normalizeWords(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 1)
      .toSet();
}
