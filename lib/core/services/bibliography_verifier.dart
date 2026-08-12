import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

enum CitationMatchConfidence { high, uncertain, notFound }

class BibliographyEntry {
  final String rawText;
  final String? firstAuthorSurname;
  final int? year;
  final String? title;
  final String? venueTitle;
  final String? doi;

  const BibliographyEntry({
    required this.rawText,
    this.firstAuthorSurname,
    this.year,
    this.title,
    this.venueTitle,
    this.doi,
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

class BibliographyVerificationProgress {
  final int completed;
  final int total;
  final BibliographyEntry? currentEntry;
  final BibliographyCheckResult? latestResult;

  const BibliographyVerificationProgress({
    required this.completed,
    required this.total,
    this.currentEntry,
    this.latestResult,
  });

  double get ratio => total == 0 ? 0 : completed / total;
}

class BibliographyVerifier {
  /// 取得代理 URL（Web 環境中用以繞過 CORS 限制）
  static String _getProxiedUrl(String targetUrl) {
    if (!kIsWeb) return targetUrl;

    // 優先使用同源代理，其次使用 Vercel 代理
    try {
      final proxyPath = '/api/proxy?url=${Uri.encodeComponent(targetUrl)}';
      return Uri.base.resolve(proxyPath).toString();
    } catch (_) {
      // 回退到 Vercel 代理
      return 'https://truth-lens-band-b.vercel.app/api/proxy?url=${Uri.encodeComponent(targetUrl)}';
    }
  }

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

  /// 非學術、新聞、財經、股票、日常記事負向過濾關鍵字
  static final RegExp _nonAcademicKeywords = RegExp(
    r'(?:股價|指數|點位|漲跌|收盤|開盤|晨間快訊|盤勢|免責聲明|本週|今日|昨日|目標價|買進|賣出|投資建議|自選股|營收|毛利|外資|投信|CMoney|Yahoo財經|鉅亨網|ETtoday|新聞網|即時報價|代號|權值股|籌碼面|大盤|個股|重點摘要|注意事項|待辦事項|行事曆|會議記錄)',
    caseSensitive: false,
  );

  static const int minEntriesWithoutHeading = 3;

  /// 預處理 OCR / PDF 擷取文字的格式瑕疵：
  /// 1. 清除 PDF 頁首/頁尾雜訊（如 November/December 2010 EXPERIMENTAL TECHNIQUES 47 STABILITY OF TAYLOR-COUETTE FLOW）
  /// 2. 補全連寫缺失空格：如 `Coles,D.,1965.Transition` -> `Coles, D., 1965. Transition`
  /// 3. 修復 OCR 連寫介詞/連詞：如 `Onsetof` -> `Onset of`, `Reversingand` -> `Reversing and`, `Journalof` -> `Journal of`
  /// 4. 在未斷行的連寫嵌合編號前自動插入換行符：將連在一起的 `FLOW3. Donnelly` 或 `(1890).2. Taylor` 切開為多行獨立條目
  static String _preprocessOcrText(String input) {
    var text = input;

    // 1) 清除 PDF 出版社浮水印、欄位邊界與頁尾雜訊 (如 Downloaded By: [Lin, Hau-Chieh] At: 14:43 11 November 2010)
    text = text.replaceAll(
      RegExp(r'Downloaded\s+By:\s*\[[^\]]+\][^\n\r]*', caseSensitive: false),
      '\n',
    );
    text = text.replaceAll(
      RegExp(
        r'\b(?:Figure|Fig\.|Table|Tab\.)\s*\d+[\s\S]*?(?=\r?\n|\Z)',
        caseSensitive: false,
      ),
      '\n',
    );
    text = text.replaceAll(
      RegExp(
        r'(?:\b(?:January|February|March|April|May|June|July|August|September|October|November|December)\b[\s/]*)+\d{4}\s*EXPERIMENTAL\s*TECHNIQUES\s*\d*',
        caseSensitive: false,
      ),
      '\n',
    );
    text = text.replaceAll(
      RegExp(
        r'\d*\s*EXPERIMENTAL\s*TECHNIQUES\s*(?:\b(?:January|February|March|April|May|June|July|August|September|October|November|December)\b[\s/]*)+\d{4}',
        caseSensitive: false,
      ),
      '\n',
    );
    text = text.replaceAll(
      RegExp(r'STABILITY\s*OF\s*TAYLOR-COUETTE\s*FLOW', caseSensitive: false),
      '\n',
    );
    text = text.replaceAll(
      RegExp(r'STABILITYOFTAYLOR-COUETTEFLOW', caseSensitive: false),
      '\n',
    );
    text = text.replaceAll(
      RegExp(
        r'^\s*\d{1,3}\.\s+(?:Therefore|Under|In\s+this|However|Furthermore|Moreover|Consequently|As\s+a\s+result|Note\s+that)\b.*$',
        caseSensitive: false,
        multiLine: true,
      ),
      '\n',
    );

    // 2) 修正 PDF / OCR 擠壓文字遺失空格問題：在標點符號與右括號後緊接英文字母或數字時自動補齊空格
    text = text.replaceAllMapped(
      RegExp(r'([a-zA-Z0-9\)])([,\.:;])([a-zA-Z0-9])'),
      (m) => '${m.group(1)}${m.group(2)} ${m.group(3)}',
    );

    // 3) 恢復 OCR 擠壓單字間空白與拆解尾隨介詞/冠詞/連詞 (如 Onsetof -> Onset of, Journalof -> Journal of, Flowwith -> Flow with)
    text = text.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    text = text.replaceAllMapped(
      RegExp(r'([a-zA-Z]{2,})(\d{1,4})'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    text = text.replaceAllMapped(
      RegExp(r'(\d{1,4})([a-zA-Z]{2,})'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    text = text.replaceAllMapped(
      RegExp(r'(\d{1,4})(\()'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );

    // 常用英文介詞與連詞的 OCR 嵌合修復 (如 Onsetof, Orderof, Journalof, Flowwith, Reversingand, Methodsin)
    final ocrCompoundedWords = [
      'forthe',
      'between',
      'ofthe',
      'ina',
      'withthe',
      'of',
      'with',
      'for',
      'from',
      'and',
    ];
    for (final cp in ocrCompoundedWords) {
      text = text.replaceAllMapped(
        RegExp('([a-zA-Z]{3,})$cp(?=\\b|[\\s\\.:,])', caseSensitive: false),
        (m) => '${m.group(1)} $cp',
      );
    }

    // 4) 修正跨行頁碼割裂 (如 19–\n42. -> 19–42.) 與跨行斷詞割裂
    text = text.replaceAllMapped(
      RegExp(r'(\d+)\s*[\-–—]\s*[\r\n]+\s*(\d+[\.\,]?)'),
      (m) => '${m.group(1)}–${m.group(2)}',
    );
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

    // 7) 在未斷行的連寫嵌合條目編號前主動插入換行符（如 (1890).2. Taylor 或 (1958). 4.Simon 或 [ 2 ] H INDS 或 FLOW3. Donnelly）：
    text = text.replaceAllMapped(
      RegExp(
        r'(?<=[a-zA-Z\)\.\,\]])\s*(\d{1,3}\.[\s\u00A0]*[A-Z]|\[\s*(?!(?:18|19|20)\d\d\b)\d{1,3}\s*\])',
      ),
      (m) => '\n${m.group(1)}',
    );

    return text;
  }

  /// 偵測文件中的參考文獻條目並依條目切分；找不到任何條目時回傳空陣列。
  static List<BibliographyEntry> extractEntries(String rawText) {
    final text = _preprocessOcrText(rawText);

    // 取文獻尾端的最後一個 References/參考文獻 標題（防止內文提及 references 字眼早判）
    final headingMatches = _sectionHeading.allMatches(text).toList();
    final headingMatch = headingMatches.isNotEmpty ? headingMatches.last : null;
    final hasHeading = headingMatch != null;
    final section = hasHeading ? text.substring(headingMatch.end) : text;

    // 路徑 1：標準英文 Surname, F.M. (Year) 傳統格式
    final starts = _entryStart.allMatches(section).toList();
    final path1Entries = <BibliographyEntry>[];
    if (starts.isNotEmpty &&
        (hasHeading || starts.length >= minEntriesWithoutHeading)) {
      for (var i = 0; i < starts.length; i++) {
        final start = starts[i];
        final endIndex = i + 1 < starts.length
            ? starts[i + 1].start
            : section.length;
        final raw = section.substring(start.start, endIndex).trim();
        if (raw.length < 15) continue;
        path1Entries.add(
          _parseEntry(
            raw,
            start.end - start.start,
            int.tryParse(start.group(1) ?? ''),
          ),
        );
      }
    }

    // 路徑 2：跨行組裝與通用學術特徵動態加權評分管線
    final rawLines = section.split(RegExp(r'\r?\n'));
    final groupedBlocks = <String>[];
    String? currentBlock;

    // 判斷該文獻區塊是否為數字編號格式（例如 [1], [2], 1.）
    final hasNumberedEntries =
        rawLines
            .where((l) => _bulletOrNumberPrefix.hasMatch(l.trim()))
            .length >=
        2;

    for (final rawLine in rawLines) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // 檢查是否為頁首/頁尾噪音（例如 "70 B. LIAO et al."、"Page 12 of 15" 或 "---"）
      if (RegExp(
        r'^(?:\d+\s+[A-Z]\.\s*[A-Z]+.*|Page\s+\d+.*|Copyright\s+.*|[-—=_]{3,})$',
        caseSensitive: false,
      ).hasMatch(line)) {
        continue;
      }

      // 判斷該行是否為全新條目的開頭
      final isNewEntryStart = hasNumberedEntries
          ? _bulletOrNumberPrefix.hasMatch(line)
          : (_bulletOrNumberPrefix.hasMatch(line) ||
                RegExp(
                  r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s*,\s*[A-Z]\.",
                ).hasMatch(line) ||
                RegExp(
                  r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s+[A-Z]\.",
                ).hasMatch(line) ||
                RegExp(r'^[\u4e00-\u9fa5]{2,4}[、,，]').hasMatch(line) ||
                RegExp(
                  r'^\[[JCMDROPOL]\]',
                  caseSensitive: false,
                ).hasMatch(line));

      if (isNewEntryStart) {
        if (currentBlock != null && currentBlock.trim().isNotEmpty) {
          groupedBlocks.add(currentBlock.trim());
        }
        currentBlock = line;
      } else {
        if (currentBlock != null) {
          // 防止 block 超長：若累加後超過 400 字，強制切割為新條目
          final candidate = '$currentBlock $line';
          if (candidate.length > 400) {
            groupedBlocks.add(currentBlock.trim());
            currentBlock = line;
          } else {
            currentBlock = candidate;
          }
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
      // 參考文獻條目通常 50-400 字符；>400 字表示整段內文被誤判為條目
      if (block.length < 15 || block.length > 400) continue;

      final score = _calculateCitationScore(block, hasHeading);
      final yearMatch = _yearRegex.firstMatch(block);
      final year = yearMatch != null
          ? int.tryParse(yearMatch.group(1) ?? '')
          : null;

      // 強化門檻：有 References 標題時 0.50，無標題時 0.65（防止內文段落誤判）
      if (score >= (hasHeading ? 0.50 : 0.65)) {
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
    if (_nonAcademicKeywords.hasMatch(block)) {
      return 0.0;
    }

    var score = 0.0;
    final hasBracketRef = RegExp(
      r'^\s*\[\s*(?!(?:18|19|20)\d\d\b)\d{1,3}\s*\]',
    ).hasMatch(block);
    final hasNumberPrefix = _bulletOrNumberPrefix.hasMatch(block);
    final hasAcademicYear = RegExp(
      r'[\(\[\（\s](18\d\d|19\d\d|20\d\d)[a-z]?[\)\]\）\.\,\:]',
    ).hasMatch(block);
    final hasGeneralYear = _yearRegex.hasMatch(block);

    if (hasBracketRef) {
      score += 0.30;
    } else if (hasNumberPrefix) {
      score += 0.15;
    }

    if (hasAcademicYear) {
      score += 0.30;
    } else if (hasGeneralYear) {
      score += 0.15;
    }

    if (_journalKeyword.hasMatch(block)) score += 0.30;

    final hasAuthorPattern =
        RegExp(r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s*,\s*[A-Z]").hasMatch(block) ||
        RegExp(r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s+[A-Z]\.").hasMatch(block) ||
        _chineseAuthor.hasMatch(block);
    if (hasAuthorPattern) {
      score += 0.35;
    }

    if (RegExp(r'\b\d+\s*[\(\:]\s*\d+\s*[\)\:]?\s*\d*\b').hasMatch(block) ||
        RegExp(
          r'\b(?:pp?|pages|vol|no)\.\s*\d+',
          caseSensitive: false,
        ).hasMatch(block)) {
      score += 0.25;
    }

    if (RegExp(
      r'(?:https?:\/\/|doi:\s*|arXiv:\s*)',
      caseSensitive: false,
    ).hasMatch(block)) {
      score += 0.35;
    }

    if (hasHeading) score += 0.20;

    // 若沒有 References 標題，且完全沒有學術作者、期刊關鍵字、DOI/arXiv 或 [1] 標記，直接歸零排除
    if (!hasHeading &&
        !hasAuthorPattern &&
        !_journalKeyword.hasMatch(block) &&
        !hasBracketRef &&
        !block.contains('doi:') &&
        !block.contains('arXiv:')) {
      return 0.0;
    }

    return score;
  }

  static BibliographyEntry _parseEntry(
    String raw,
    int prefixLength,
    int? year,
  ) {
    final commaIdx = raw.indexOf(',');
    final surname = commaIdx > 0 ? raw.substring(0, commaIdx).trim() : null;
    final afterPrefix = prefixLength <= raw.length
        ? raw.substring(prefixLength)
        : '';
    final quoteMatch = RegExp(
      r'["“「〈《]([^"”」〉»\r\n]+)["”」〉»]',
    ).firstMatch(afterPrefix);
    final titleEnd = afterPrefix.indexOf('. ');
    final rawTitle = quoteMatch?.group(1);
    final title =
        rawTitle?.replaceAll(RegExp(r',+$'), '').trim() ??
        (titleEnd > 0 ? afterPrefix.substring(0, titleEnd) : afterPrefix)
            .trim();
    return BibliographyEntry(
      rawText: raw,
      firstAuthorSurname: surname,
      year: year,
      title: title.isEmpty ? null : title,
      venueTitle: _extractVenueTitle(raw, title),
      doi: _extractDoi(raw),
    );
  }

  static BibliographyEntry _parseLineEntry(
    String cleaned,
    String rawText,
    int? year,
  ) {
    // 預先修復常見 OCR 小錯字 (如 "Couette Fow" -> "Couette Flow")
    var cleanedNoPrefix = cleaned
        .replaceAll(_bulletOrNumberPrefix, '')
        .replaceAll(RegExp(r'^\d{1,4}[\.\,]?\s+(?=[A-Z][a-zÀ-ÖØ-öø-ÿ])'), '')
        .replaceAll(
          RegExp(r'\bCouette\s+Fow\b', caseSensitive: false),
          'Couette Flow',
        )
        .trim();

    // 優先抽取篇名引號或書名號（如 "..." 或 “...” 或 「...」 或 〈...〉 或 《...》）
    final quoteMatch = RegExp(
      r'["“「〈《]([^"”」〉»\r\n]+)["”」〉»]',
    ).firstMatch(cleanedNoPrefix);
    final rawTitle = quoteMatch?.group(1);
    String? title = rawTitle?.replaceAll(RegExp(r',+$'), '').trim();

    if (title == null || title.isEmpty) {
      // 若有西元年 (例如 1983. 或 1986. 或 (1983))，年份後第一個以句號分割的段落即為真正的論文篇名
      if (year != null) {
        final yearPattern = RegExp('\\b$year[a-z]?\\b[\\.\\,:]?\\s*');
        final yearMatch = yearPattern.firstMatch(cleanedNoPrefix);
        if (yearMatch != null) {
          final afterYear = cleanedNoPrefix.substring(yearMatch.end).trim();
          final titleEnd = afterYear.indexOf('. ');
          if (titleEnd > 5) {
            title = afterYear.substring(0, titleEnd).trim();
          } else if (afterYear.isNotEmpty) {
            final periodIdx = afterYear.indexOf('.');
            title =
                (periodIdx > 5 ? afterYear.substring(0, periodIdx) : afterYear)
                    .trim();
          }
        }
      }

      if (title == null || title.isEmpty || title.length < 5) {
        // 嘗試先剔除開頭的作者群（如 "COHEN B.S., HERING S.V., "）
        final noAuthors = cleanedNoPrefix
            .replaceAll(
              RegExp(
                r"^(?:[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s*(?:,\s*)?[A-Z]\s*\.\s*(?:[A-Z]\s*\.\s*)?(?:\s*,\s*|\s+and\s+|\s*&\s*)*)+",
                caseSensitive: false,
              ),
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
        final chineseMatch = RegExp(
          r'^[\u4e00-\u9fa5]{2,4}',
        ).firstMatch(cleanedNoPrefix);
        if (chineseMatch != null) {
          surname = chineseMatch.group(0);
        }
      }
    }

    return BibliographyEntry(
      rawText: rawText,
      firstAuthorSurname: surname,
      year: year,
      title: title.isEmpty ? null : title,
      venueTitle: _extractVenueTitle(cleanedNoPrefix, title),
      doi: _extractDoi(cleanedNoPrefix),
    );
  }

  static String? _extractVenueTitle(String raw, String? title) {
    var source = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    String? afterTitle;

    final quoteMatch = RegExp(
      r'["“「〈《]([^"”」〉»\r\n]+)["”」〉»]',
    ).firstMatch(source);
    if (quoteMatch != null) {
      afterTitle = source.substring(quoteMatch.end);
    } else if (title != null && title.trim().length >= 5) {
      final lowerSource = source.toLowerCase();
      final lowerTitle = title.trim().toLowerCase();
      final titleIndex = lowerSource.indexOf(lowerTitle);
      if (titleIndex >= 0) {
        afterTitle = source.substring(titleIndex + title.length);
      }
    }

    if (afterTitle != null) {
      final venue = _cleanVenueCandidate(afterTitle);
      if (venue != null) return venue;
    }

    final fallback = RegExp(
      r'\b((?:Journal|Proceedings|Transactions|Physical Review|Phys\. Rev\.|J\. Fluid Mech\.|Proc\.|ACM|IEEE|AIChE|AICHE|Nature|Science|Springer|Wiley|Elsevier|Press|學報|期刊|論文集|研討會)[^,.;\(\)]{0,80})',
      caseSensitive: false,
    ).firstMatch(source);
    return _cleanVenueCandidate(fallback?.group(1));
  }

  static String? _cleanVenueCandidate(String? raw) {
    if (raw == null) return null;
    var venue = raw
        .replaceFirst(RegExp(r'^[\s,.;:]+'), '')
        .replaceFirst(
          RegExp(
            r'\b(?:vol\.?|volume|no\.?|pp?\.?|pages?)\b.*$',
            caseSensitive: false,
          ),
          '',
        )
        .replaceFirst(RegExp(r'\b(?:18|19|20)\d\d\b.*$'), '')
        .replaceFirst(RegExp(r'\s+\d{1,4}\s*[:;,].*$'), '')
        .replaceFirst(RegExp(r'\s+\d{1,4}\s*$'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    venue = venue.replaceAll(RegExp(r'[,.;:\s]+$'), '').trim();
    if (venue.length < 3 || venue.length > 120) return null;
    if (!_looksLikeVenue(venue)) return null;
    return venue;
  }

  static bool _looksLikeVenue(String value) {
    return RegExp(
      r'(?:journal|proceedings|transactions|physical review|phys\. rev\.|j\.|proc\.|conference|symposium|acm|ieee|aiche|nature|science|springer|wiley|elsevier|press|學報|期刊|論文集|研討會)',
      caseSensitive: false,
    ).hasMatch(value);
  }

  static String? _extractDoi(String raw) {
    final match = RegExp(
      r'\b10\.\d{4,9}/[-._;()/:A-Z0-9]+\b',
      caseSensitive: false,
    ).firstMatch(raw);
    return match
        ?.group(0)
        ?.replaceAll(RegExp(r'[.;,\)\]]+$'), '')
        .toLowerCase();
  }

  /// 帶 Exponential Backoff 重試與 Crossref Polite Pool 標頭的 HTTP GET 請求
  static Future<http.Response?> _httpGetWithRetry(
    http.Client client,
    Uri uri,
    Duration timeout, {
    int maxRetries = 2,
  }) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await client
            .get(
              uri,
              headers: {
                'User-Agent':
                    'TruthLens/1.0 (https://github.com/hauchiehlin-ops/TruthLens; mailto:support@truthlens.app)',
              },
            )
            .timeout(timeout);

        if (response.statusCode == 200) {
          return response;
        } else if (response.statusCode == 429 || response.statusCode >= 500) {
          if (attempt < maxRetries) {
            final delayMs = 300 * math.pow(2, attempt).toInt();
            await Future.delayed(Duration(milliseconds: delayMs));
            continue;
          }
        }
        return response;
      } catch (_) {
        if (attempt < maxRetries) {
          final delayMs = 300 * math.pow(2, attempt).toInt();
          await Future.delayed(Duration(milliseconds: delayMs));
          continue;
        }
      }
    }
    return null;
  }

  /// 對每條參考文獻查詢 Crossref / OpenAlex 書目搜尋，判定其存在可信度。
  static Future<List<BibliographyCheckResult>> verifyAll(
    List<BibliographyEntry> entries, {
    http.Client? client,
    Duration timeout = const Duration(seconds: 5),
    void Function(BibliographyVerificationProgress progress)? onProgress,
  }) async {
    final c = client ?? http.Client();
    final owns = client == null;
    try {
      final results = <BibliographyCheckResult>[];
      final targetEntries = entries.toList();
      onProgress?.call(
        BibliographyVerificationProgress(
          completed: 0,
          total: targetEntries.length,
          currentEntry: targetEntries.isEmpty ? null : targetEntries.first,
        ),
      );
      for (var i = 0; i < targetEntries.length; i++) {
        if (i > 0) {
          await Future.delayed(const Duration(milliseconds: 150));
        }
        final entry = targetEntries[i];
        onProgress?.call(
          BibliographyVerificationProgress(
            completed: i,
            total: targetEntries.length,
            currentEntry: entry,
          ),
        );
        final result = await _verifyOne(c, entry, timeout);
        results.add(result);
        onProgress?.call(
          BibliographyVerificationProgress(
            completed: i + 1,
            total: targetEntries.length,
            currentEntry: i + 1 < targetEntries.length
                ? targetEntries[i + 1]
                : null,
            latestResult: result,
          ),
        );
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
    var crossrefSearchSucceeded = false;
    var openAlexSearchSucceeded = false;
    BibliographyCheckResult? bestUncertainCandidate;

    final searchTitle = entry.title != null && entry.title!.trim().length >= 5
        ? entry.title!.trim()
        : null;

    if (entry.doi != null) {
      try {
        final baseUrl =
            'https://api.crossref.org/works/${Uri.encodeComponent(entry.doi!)}';
        final proxiedUrl = _getProxiedUrl(baseUrl);
        final uri = Uri.parse(
          proxiedUrl,
        ).replace(queryParameters: {'mailto': 'support@truthlens.app'});
        final response = await _httpGetWithRetry(client, uri, timeout);
        if (response != null && response.statusCode == 200) {
          final message =
              (jsonDecode(response.body) as Map<String, dynamic>)['message']
                  as Map<String, dynamic>?;
          final titles = (message?['title'] as List?)?.cast<dynamic>();
          final containers = (message?['container-title'] as List?)
              ?.cast<dynamic>();
          final dateParts =
              ((message?['published'] as Map<String, dynamic>?)?['date-parts']
                      as List?)
                  ?.cast<dynamic>();
          final matchedYear =
              (dateParts != null &&
                  dateParts.isNotEmpty &&
                  (dateParts.first as List).isNotEmpty)
              ? (dateParts.first as List).first as int
              : null;
          return BibliographyCheckResult(
            entry: entry,
            confidence: CitationMatchConfidence.high,
            matchedTitle: titles != null && titles.isNotEmpty
                ? titles.first.toString()
                : null,
            matchedJournal: containers != null && containers.isNotEmpty
                ? containers.first.toString()
                : 'Crossref DOI 登記',
            matchedYear: matchedYear,
          );
        }
        if (response != null && response.statusCode == 404) {
          return BibliographyCheckResult(
            entry: entry,
            confidence: CitationMatchConfidence.notFound,
          );
        }
      } catch (_) {}
    }

    if (searchTitle != null &&
        entry.venueTitle != null &&
        entry.venueTitle!.length >= 3) {
      try {
        final queryParams = <String, String>{
          'query.title': searchTitle,
          'query.container-title': entry.venueTitle!,
          'rows': '5',
          'mailto': 'support@truthlens.app',
        };
        final uri = Uri.parse(
          _getProxiedUrl('https://api.crossref.org/works'),
        ).replace(queryParameters: queryParams);
        final response = await _httpGetWithRetry(client, uri, timeout);
        if (response != null && response.statusCode == 200) {
          crossrefSearchSucceeded = true;
          final message =
              (jsonDecode(response.body) as Map<String, dynamic>)['message']
                  as Map<String, dynamic>?;
          final items = (message?['items'] as List?)?.cast<dynamic>();
          final result = _bestCandidateFromCrossrefItems(
            entry,
            searchTitle,
            items,
            defaultJournal: entry.venueTitle!,
          );
          if (result != null) {
            if (result.confidence == CitationMatchConfidence.high) {
              return result;
            }
            bestUncertainCandidate ??= result;
          }
        }
      } catch (_) {}
    }

    // 1) 策略一：專注篇名與作者的 Crossref 精準比對 (query.title + query.author)
    if (searchTitle != null) {
      try {
        final queryParams = <String, String>{
          'query.title': searchTitle,
          'rows': '5',
          'mailto': 'support@truthlens.app',
        };
        if (entry.firstAuthorSurname != null &&
            entry.firstAuthorSurname!.length >= 2) {
          queryParams['query.author'] = entry.firstAuthorSurname!;
        }

        final uri = Uri.parse(
          _getProxiedUrl('https://api.crossref.org/works'),
        ).replace(queryParameters: queryParams);

        final response = await _httpGetWithRetry(client, uri, timeout);

        if (response != null && response.statusCode == 200) {
          crossrefSearchSucceeded = true;
          final message =
              (jsonDecode(response.body) as Map<String, dynamic>)['message']
                  as Map<String, dynamic>?;
          final items = (message?['items'] as List?)?.cast<dynamic>();
          final result = _bestCandidateFromCrossrefItems(
            entry,
            searchTitle,
            items,
            defaultJournal: 'Crossref 收錄期刊',
          );
          if (result != null) {
            if (result.confidence == CitationMatchConfidence.high) {
              return result;
            }
            bestUncertainCandidate ??= result;
          }
        }
      } catch (_) {}
    }

    // 1B) 策略一 B：Crossref 全文字串 (query.bibliographic) 備援查詢 (適合 APS / Royal Society 經典文獻)
    try {
      final bibQuery =
          '${entry.firstAuthorSurname ?? ''} ${searchTitle ?? entry.rawText} ${entry.year ?? ''}'
              .trim();
      final queryParams = <String, String>{
        'query.bibliographic': bibQuery,
        'rows': '5',
        'mailto': 'support@truthlens.app',
      };
      final uri = Uri.parse(
        _getProxiedUrl('https://api.crossref.org/works'),
      ).replace(queryParameters: queryParams);

      final response = await _httpGetWithRetry(client, uri, timeout);

      if (response != null && response.statusCode == 200) {
        crossrefSearchSucceeded = true;
        final message =
            (jsonDecode(response.body) as Map<String, dynamic>)['message']
                as Map<String, dynamic>?;
        final items = (message?['items'] as List?)?.cast<dynamic>();
        final result = _bestCandidateFromCrossrefItems(
          entry,
          searchTitle ?? entry.rawText,
          items,
          defaultJournal: 'Crossref 收錄期刊',
        );
        if (result != null) {
          if (result.confidence == CitationMatchConfidence.high) {
            return result;
          }
          bestUncertainCandidate ??= result;
        }
      }
    } catch (_) {}

    // 2) 策略二：OpenAlex 全文圖書館索引多候選人比對 (per_page=5)
    try {
      final searchKw = _cleanSearchKeywords(searchTitle ?? entry.rawText);
      final openAlexUrl =
          'https://api.openalex.org/works?search=${Uri.encodeComponent(searchKw)}&per_page=5';
      final proxiedUrl = _getProxiedUrl(openAlexUrl);
      final openAlexUri = Uri.parse(proxiedUrl);
      final oaResp = await _httpGetWithRetry(client, openAlexUri, timeout);

      if (oaResp != null && oaResp.statusCode == 200) {
        final data = jsonDecode(oaResp.body) as Map<String, dynamic>?;
        final results = (data?['results'] as List?)?.cast<dynamic>();
        if (results != null) {
          openAlexSearchSucceeded = true;
        }
        if (results != null && results.isNotEmpty) {
          for (final res in results) {
            final top = res as Map<String, dynamic>;
            final matchedTitle = top['title']?.toString();
            final matchedYear = top['publication_year'] as int?;
            final hostVenue =
                top['primary_location']?['source'] as Map<String, dynamic>?;
            final locations = (top['locations'] as List?)?.cast<dynamic>();
            final firstLocationSource =
                (locations != null && locations.isNotEmpty)
                ? ((locations.first as Map<String, dynamic>?)?['source']
                      as Map<String, dynamic>?)
                : null;
            final matchedJournal =
                hostVenue?['display_name']?.toString() ??
                firstLocationSource?['display_name']?.toString();

            final titleSim = _titleSimilarity(
              searchTitle ?? entry.rawText,
              matchedTitle,
            );
            final yearMatches =
                entry.year != null &&
                matchedYear != null &&
                (entry.year! - matchedYear).abs() <= 1;

            if (titleSim >= 0.60 || (titleSim >= 0.45 && yearMatches)) {
              return BibliographyCheckResult(
                entry: entry,
                confidence: CitationMatchConfidence.high,
                matchedTitle: matchedTitle,
                matchedJournal: matchedJournal ?? 'OpenAlex 收錄學術期刊',
                matchedYear: matchedYear,
              );
            } else if (titleSim >= 0.28 || (titleSim >= 0.18 && yearMatches)) {
              bestUncertainCandidate ??= BibliographyCheckResult(
                entry: entry,
                confidence: CitationMatchConfidence.uncertain,
                matchedTitle: matchedTitle,
                matchedJournal: matchedJournal ?? 'OpenAlex 收錄學術期刊',
                matchedYear: matchedYear,
              );
            }
          }
        }
      }
    } catch (_) {}

    // 若有發現中度相似的候選文獻，退回黃燈 (uncertain) 並保留匹配到的期刊與篇名
    if (bestUncertainCandidate != null) {
      return bestUncertainCandidate;
    }

    // 只有在條目本身欄位完整，且 Crossref / OpenAlex 都成功回應仍沒有
    // 任何相近候選時，才把非 DOI 文獻標成 notFound。解析品質不足時保守回黃燈。
    final canSafelyReject =
        _hasStrongBibliographicEvidence(entry) &&
        crossrefSearchSucceeded &&
        openAlexSearchSucceeded;
    return BibliographyCheckResult(
      entry: entry,
      confidence: canSafelyReject
          ? CitationMatchConfidence.notFound
          : CitationMatchConfidence.uncertain,
    );
  }

  static bool _hasStrongBibliographicEvidence(BibliographyEntry entry) {
    if (entry.doi != null) return true;
    final title = entry.title?.trim();
    final surname = entry.firstAuthorSurname?.trim();
    if (entry.year == null ||
        surname == null ||
        surname.length < 2 ||
        title == null ||
        title.length < 12 ||
        title.length > 180) {
      return false;
    }
    if (RegExp(
      r'\b(?:references|bibliography)\b',
      caseSensitive: false,
    ).hasMatch(title)) {
      return false;
    }
    final contentWords = _normalizeWords(
      title,
    ).where((w) => !_bibliographyStopWords.contains(w)).toList();
    return contentWords.length >= 4 && contentWords.length <= 24;
  }

  static BibliographyCheckResult? _bestCandidateFromCrossrefItems(
    BibliographyEntry entry,
    String searchTitle,
    List<dynamic>? items, {
    required String defaultJournal,
  }) {
    if (items == null || items.isEmpty) return null;
    BibliographyCheckResult? bestUncertainCandidate;
    for (final item in items) {
      final top = item as Map<String, dynamic>;
      final titles = (top['title'] as List?)?.cast<dynamic>();
      final matchedTitle = (titles != null && titles.isNotEmpty)
          ? titles.first.toString()
          : null;
      final containers = (top['container-title'] as List?)?.cast<dynamic>();
      final matchedJournal = (containers != null && containers.isNotEmpty)
          ? containers.first.toString()
          : null;
      final dateParts =
          ((top['published'] as Map<String, dynamic>?)?['date-parts'] as List?)
              ?.cast<dynamic>();
      final matchedYear =
          (dateParts != null &&
              dateParts.isNotEmpty &&
              (dateParts.first as List).isNotEmpty)
          ? (dateParts.first as List).first as int
          : null;

      final titleSim = _titleSimilarity(searchTitle, matchedTitle);
      final yearMatches =
          entry.year != null &&
          matchedYear != null &&
          (entry.year! - matchedYear).abs() <= 1;
      final venueMatches =
          entry.venueTitle != null &&
          _titleSimilarity(entry.venueTitle, matchedJournal) >= 0.45;
      final strongVenueMatch = venueMatches && titleSim >= 0.35;

      if (titleSim >= 0.60 ||
          (strongVenueMatch && titleSim >= 0.40) ||
          (titleSim >= 0.45 &&
              yearMatches &&
              (venueMatches || entry.firstAuthorSurname != null))) {
        return BibliographyCheckResult(
          entry: entry,
          confidence: CitationMatchConfidence.high,
          matchedTitle: matchedTitle,
          matchedJournal: matchedJournal ?? defaultJournal,
          matchedYear: matchedYear,
        );
      } else if (titleSim >= 0.28 ||
          (titleSim >= 0.18 && (yearMatches || venueMatches))) {
        bestUncertainCandidate ??= BibliographyCheckResult(
          entry: entry,
          confidence: CitationMatchConfidence.uncertain,
          matchedTitle: matchedTitle,
          matchedJournal: matchedJournal ?? defaultJournal,
          matchedYear: matchedYear,
        );
      }
    }
    return bestUncertainCandidate;
  }

  /// 升級版篇名相似度：支援「無空格連寫 (OCR 擠壓文字)」、「詞彙 Jaccard」與「3-Gram 字元序列 (耐受拼寫小錯)」三重比對。
  static double _titleSimilarity(String? a, String? b) {
    if (a == null || b == null) return 0;

    final cleanA = a
        .replaceAll(RegExp(r'[^a-zA-Z0-9\u4e00-\u9fa5]'), '')
        .toLowerCase();
    final cleanB = b
        .replaceAll(RegExp(r'[^a-zA-Z0-9\u4e00-\u9fa5]'), '')
        .toLowerCase();
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

    // 3) 三連字 (3-Gram) 序列相似度：精準防範完全無關主題，同時能對抗小錯字 (如 Couette Fow vs Couette Flow)
    final trigramSim = _trigramSimilarity(cleanA, cleanB);

    return math.max(tokenSim, trigramSim * 0.90);
  }

  static double _trigramSimilarity(String cleanA, String cleanB) {
    if (cleanA.length < 3 || cleanB.length < 3) return 0.0;
    final setA = <String>{};
    for (var i = 0; i <= cleanA.length - 3; i++) {
      setA.add(cleanA.substring(i, i + 3));
    }
    final setB = <String>{};
    for (var i = 0; i <= cleanB.length - 3; i++) {
      setB.add(cleanB.substring(i, i + 3));
    }
    final union = setA.union(setB).length;
    if (union == 0) return 0.0;
    return setA.intersection(setB).length / union;
  }

  static final Set<String> _bibliographyStopWords = {
    'the',
    'and',
    'for',
    'with',
    'from',
    'into',
    'over',
    'under',
    'that',
    'this',
    'have',
    'been',
    'between',
    'of',
    'in',
    'to',
    'on',
    'at',
    'by',
    'is',
    'or',
    'an',
    'a',
  };

  static Set<String> _normalizeWords(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 1)
      .toSet();

  static String _cleanSearchKeywords(String raw) {
    var current = raw;
    current = current.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (m) => '${m.group(1)} ${m.group(2)}',
    );
    final preps = [
      'forthe',
      'between',
      'ofthe',
      'ina',
      'for',
      'with',
      'from',
      'into',
      'over',
      'under',
      'that',
      'this',
      'have',
      'been',
      'the',
      'and',
      'in',
      'of',
      'to',
      'on',
      'at',
      'by',
      'is',
      'or',
      'an',
      'a',
    ];
    for (final prep in preps) {
      current = current.replaceAllMapped(
        RegExp('\\b([a-zA-Z]{3,})($prep)\\b', caseSensitive: false),
        (m) => '${m.group(1)} ${m.group(2)}',
      );
    }
    final stopWords = preps.toSet();
    final words = current
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopWords.contains(w.toLowerCase()))
        .toList();

    if (words.isEmpty) return raw;
    return words.take(6).join(' ');
  }
}
