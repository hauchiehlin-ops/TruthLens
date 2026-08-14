import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

enum CitationMatchConfidence { high, uncertain, notFound }

class BibliographyVerificationCredentials {
  final String? webOfScienceApiKey;
  final String? engineeringVillageApiKey;
  final String? engineeringVillageInstitutionToken;

  const BibliographyVerificationCredentials({
    this.webOfScienceApiKey,
    this.engineeringVillageApiKey,
    this.engineeringVillageInstitutionToken,
  });

  bool get hasWebOfScienceKey =>
      webOfScienceApiKey != null && webOfScienceApiKey!.trim().isNotEmpty;
  bool get hasEngineeringVillageKey =>
      engineeringVillageApiKey != null &&
      engineeringVillageApiKey!.trim().isNotEmpty;
}

class BibliographyEntry {
  final String rawText;
  final int sourceOffset;
  final String? firstAuthorSurname;
  final int? year;
  final String? title;
  final String? venueTitle;
  final String? doi;
  final String? volume;
  final String? firstPage;
  final String? lastPage;

  const BibliographyEntry({
    required this.rawText,
    this.sourceOffset = -1,
    this.firstAuthorSurname,
    this.year,
    this.title,
    this.venueTitle,
    this.doi,
    this.volume,
    this.firstPage,
    this.lastPage,
  });
}

class BibliographyCheckResult {
  final BibliographyEntry entry;
  final CitationMatchConfidence confidence;
  final String? matchedTitle;
  final String? matchedJournal;
  final int? matchedYear;
  final bool journalNameMismatch;

  const BibliographyCheckResult({
    required this.entry,
    required this.confidence,
    this.matchedTitle,
    this.matchedJournal,
    this.matchedYear,
    this.journalNameMismatch = false,
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

class _BibliographicLocator {
  final String? volume;
  final String? firstPage;
  final String? lastPage;

  const _BibliographicLocator({this.volume, this.firstPage, this.lastPage});
}

class _CrossrefCandidateScore {
  final BibliographyCheckResult result;
  final double score;
  final bool highConfidence;

  const _CrossrefCandidateScore({
    required this.result,
    required this.score,
    required this.highConfidence,
  });
}

class _BibliographyCandidate {
  final String? title;
  final String? venue;
  final int? year;
  final String? firstAuthor;
  final String sourceLabel;

  const _BibliographyCandidate({
    required this.sourceLabel,
    this.title,
    this.venue,
    this.year,
    this.firstAuthor,
  });
}

class _KnownBibliographyRecord {
  final String title;
  final String venue;
  final int year;
  final String? firstAuthorSurname;
  final String? volume;
  final String? firstPage;
  final String? lastPage;

  const _KnownBibliographyRecord({
    required this.title,
    required this.venue,
    required this.year,
    this.firstAuthorSurname,
    this.volume,
    this.firstPage,
    this.lastPage,
  });
}

class BibliographyVerifier {
  /// 取得代理 URL（Web 環境中用以繞過 CORS 限制）
  static String _getProxiedUrl(String targetUrl) {
    if (!kIsWeb) return targetUrl;

    // Crossref 與 OpenAlex 兩個官方 API 都允許瀏覽器跨網域 GET。
    // 直連可避免文獻核實被同源代理的部署、驗證或暫時故障連帶阻斷。
    final targetHost = Uri.tryParse(targetUrl)?.host.toLowerCase();
    if (targetHost == 'api.crossref.org' || targetHost == 'api.openalex.org') {
      return targetUrl;
    }

    // `flutter run -d chrome` 沒有提供 Vercel Edge Function；本機 Web 開發時
    // 改走正式代理，否則 DataCite、Semantic Scholar、Europe PMC 與 ERIC
    // 都會請求到不存在的 localhost `/api/proxy`。
    final appHost = Uri.base.host.toLowerCase();
    if (appHost == 'localhost' || appHost == '127.0.0.1' || appHost == '::1') {
      return 'https://truth-lens-band-b.vercel.app/api/proxy?url='
          '${Uri.encodeComponent(targetUrl)}';
    }

    final proxyPath = '/api/proxy?url=${Uri.encodeComponent(targetUrl)}';
    return Uri.base.resolve(proxyPath).toString();
  }

  static final RegExp _sectionHeading = RegExp(
    r'(?:\b(?:references|bibliography|works cited|literature cited|sources)\b|參考文獻|參考書目|引用文獻|主要參考文獻|文獻目錄)',
    caseSensitive: false,
  );

  /// 常用學術期刊、研討會、出版社、文獻標記與數位識別碼特徵
  static final RegExp _journalKeyword = RegExp(
    r'(?:Journal of|Transactions|Proceedings|Proc\.|Physical Review|Phys\. Rev\.|Physical Fluids|Phys\. Fluids|Fluid Dynamics Research|Computational Fluid Dynamics|Physics Letters|Annales|Z\.?\s*Flugwiss|AIChE|AICHE|IEEE|ACM|Springer|Elsevier|Nature|Science|arXiv|doi\.org|DOI:|PMID:|vol\.|no\.|pp\.|p\.|pages|Wiley|Press|Inc\.|Ed\.|Edition|學報|期刊|論文集|研討會|出版社|第\s*\d+\s*卷|第\s*\d+\s*期|第\s*\d+\s*頁|頁\s*\d+|\[[JCMDROPOL]\])',
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
    r"(?:(?!\b(?:18|19|20)\d{2}\b)[\s\S]){0,180}?"
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
    text = _stripBibliographyPageNoise(text);
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

    text = _repairCompoundedBibliographyText(text);

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

  static String _stripBibliographyPageNoise(String input) {
    var text = input;
    const months =
        'January|February|March|April|May|June|July|August|September|October|November|December';
    text = text.replaceAll(
      RegExp(
        r'\b(?:' +
            months +
            r')(?:\s*/\s*(?:' +
            months +
            r'))?\s*\d{4}\s*EXPERIMENTAL\s*TECHNIQUES\s*\d*',
        caseSensitive: false,
      ),
      ' ',
    );
    text = text.replaceAll(
      RegExp(
        r'\b(?:square\s*solid|squaresolid)\s*\d+\s*EXPERIMENTAL\s*TECHNIQUES\s*(?:' +
            months +
            r')?(?:\s*/\s*(?:' +
            months +
            r'))?\s*\d{4}?',
        caseSensitive: false,
      ),
      ' ',
    );
    text = text.replaceAll(
      RegExp(
        r'\bEXPERIMENTAL\s*TECHNIQUES\s*(?:' +
            months +
            r')?(?:\s*/\s*(?:' +
            months +
            r'))?\s*\d{4}?\s*\d*',
        caseSensitive: false,
      ),
      ' ',
    );
    text = text.replaceAll(
      RegExp(
        r'\bSTABILITY\s*OF\s*TAYLOR-COUETTE\s*FLOW\b',
        caseSensitive: false,
      ),
      ' ',
    );
    return text;
  }

  static String _normalizeBibliographyEntryText(String raw) {
    return _stripBibliographyPageNoise(_repairCompoundedBibliographyText(raw))
        .replaceAll(
          RegExp(r'\bPeriod-ically\b', caseSensitive: false),
          'Periodically',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// 修復 PDF/OCR 常見的英文連寫，並保留查詢與顯示所需的語意詞。
  ///
  /// 這裡特別針對文獻目錄常見破損，例如 `Stabilityofa`、`Experimentonthe`、
  /// `Proceedingsofthe`、`Methodsin`、`containedbetween`。若不先修復，Crossref /
  /// OpenAlex 會收到污染篇名，常把真實文獻誤判為未核實。
  static String _repairCompoundedBibliographyText(String input) {
    var text = input;
    final phraseFixes = <String, String>{
      'ofthe': 'of the',
      'offthe': 'of the',
      'ofa': 'of a',
      'onthe': 'on the',
      'inthe': 'in the',
      'ina': 'in a',
      'forthe': 'for the',
      'withthe': 'with the',
      'betweenthe': 'between the',
      'between': 'between',
      'andthe': 'and the',
      'of': 'of',
      'in': 'in',
      'with': 'with',
      'for': 'for',
      'from': 'from',
      'into': 'into',
      'and': 'and',
    };

    for (final entry in phraseFixes.entries) {
      text = text.replaceAllMapped(
        RegExp(
          '([A-Za-zÀ-ÖØ-öø-ÿ]{3,})${entry.key}(?=\\b|[\\s\\.:,;])',
          caseSensitive: false,
        ),
        (m) => '${m.group(1)} ${entry.value}',
      );
    }

    return text
        .replaceAll(
          RegExp(r'\bPeriod-ically\b', caseSensitive: false),
          'Periodically',
        )
        .replaceAll(
          RegExp(
            r'\bAnnales\s*de\s*chimie\s*et\s*de\s*physique\b',
            caseSensitive: false,
          ),
          'Annales de chimie et de physique',
        )
        .replaceAll(
          RegExp(r'\bAnnalesdechimieetdephysique\b', caseSensitive: false),
          'Annales de chimie et de physique',
        )
        .replaceAll(
          RegExp(r'\bFluid\s*Dynamics\s*Research\b', caseSensitive: false),
          'Fluid Dynamics Research',
        )
        .replaceAll(
          RegExp(r'\bPhysics\s*Letters\b', caseSensitive: false),
          'Physics Letters',
        )
        .replaceAll(
          RegExp(r'\bPhysical\s*Review\s*Letters\b', caseSensitive: false),
          'Physical Review Letters',
        )
        .replaceAll(RegExp(r'\bOnthe\b', caseSensitive: false), 'On the')
        .replaceAll(RegExp(r'\bIna\b', caseSensitive: false), 'In a')
        .replaceAll(
          RegExp(r'\bExperiment\s+on\s+the\b', caseSensitive: false),
          'Experiment on the',
        )
        .replaceAll(
          RegExp(r'\bProceedings\s+of\s+the\b', caseSensitive: false),
          'Proceedings of the',
        )
        .replaceAll(
          RegExp(r'\bTransactions\s+of\s+the\b', caseSensitive: false),
          'Transactions of the',
        )
        .replaceAll(
          RegExp(r'\bJournal\s+of\b', caseSensitive: false),
          'Journal of',
        )
        .replaceAll(
          RegExp(r'\bMethods\s+in\b', caseSensitive: false),
          'Methods in',
        )
        .replaceAll(
          RegExp(r'\bContained\s+between\b', caseSensitive: false),
          'Contained between',
        )
        .replaceAll(
          RegExp(r'\bContained\s+Between\b', caseSensitive: false),
          'Contained between',
        );
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
        final raw = _normalizeBibliographyEntryText(
          section.substring(start.start, endIndex).trim(),
        );
        if (raw.length < 15) continue;
        path1Entries.add(
          _parseEntry(
            raw,
            start.end - start.start,
            int.tryParse(start.group(1) ?? ''),
            sourceOffset: start.start,
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

    for (var blockIndex = 0; blockIndex < groupedBlocks.length; blockIndex++) {
      final block = groupedBlocks[blockIndex];
      // 參考文獻條目通常 50-400 字符；>400 字表示整段內文被誤判為條目
      final normalizedBlock = _normalizeBibliographyEntryText(block);
      if (normalizedBlock.length < 15 || normalizedBlock.length > 400) continue;

      final score = _calculateCitationScore(normalizedBlock, hasHeading);
      final yearMatch = _yearRegex.firstMatch(normalizedBlock);
      final year = yearMatch != null
          ? int.tryParse(yearMatch.group(1) ?? '')
          : null;

      // 強化門檻：有 References 標題時 0.50，無標題時 0.65（防止內文段落誤判）
      if (score >= (hasHeading ? 0.50 : 0.65)) {
        final cleaned = normalizedBlock.replaceAll(_bulletOrNumberPrefix, '');
        candidates.add(
          _parseLineEntry(
            cleaned,
            normalizedBlock,
            year,
            sourceOffset: blockIndex,
          ),
        );
      }
    }

    // 擇優機制：當路徑 2 擷取到相同或更多條目時優先採用 (路徑 2 具備完整跨行組裝能力)
    if (candidates.length >= path1Entries.length && candidates.isNotEmpty) {
      if (!hasHeading && candidates.length < minEntriesWithoutHeading) {
        return [];
      }
      return candidates
        ..sort((a, b) => a.sourceOffset.compareTo(b.sourceOffset));
    } else {
      if (!hasHeading && path1Entries.length < minEntriesWithoutHeading) {
        return [];
      }
      return path1Entries
        ..sort((a, b) => a.sourceOffset.compareTo(b.sourceOffset));
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
    int? year, {
    int sourceOffset = -1,
  }) {
    final normalizedRaw = _normalizeBibliographyEntryText(raw);
    final commaIdx = normalizedRaw.indexOf(',');
    final surname = commaIdx > 0
        ? normalizedRaw.substring(0, commaIdx).trim()
        : null;
    final safePrefixLength = math.min(prefixLength, normalizedRaw.length);
    final afterPrefix = safePrefixLength <= normalizedRaw.length
        ? normalizedRaw.substring(safePrefixLength)
        : '';
    final quoteMatch = RegExp(
      r'["“「〈《]([^"”」〉»\r\n]+)["”」〉»]',
    ).firstMatch(afterPrefix);
    final titleEnd = afterPrefix.indexOf('. ');
    final rawTitle = quoteMatch?.group(1);
    final title =
        _normalizeBibliographyTitle(rawTitle) ??
        _normalizeBibliographyTitle(
          titleEnd > 0 ? afterPrefix.substring(0, titleEnd) : afterPrefix,
        ) ??
        '';
    final locator = _extractBibliographicLocator(normalizedRaw);
    return BibliographyEntry(
      rawText: normalizedRaw,
      sourceOffset: sourceOffset,
      firstAuthorSurname: surname,
      year: year,
      title: title.isEmpty ? null : title,
      venueTitle: _extractVenueTitle(normalizedRaw, title),
      doi: _extractDoi(normalizedRaw),
      volume: locator?.volume,
      firstPage: locator?.firstPage,
      lastPage: locator?.lastPage,
    );
  }

  static BibliographyEntry _parseLineEntry(
    String cleaned,
    String rawText,
    int? year, {
    int sourceOffset = -1,
  }) {
    // 預先修復常見 OCR 小錯字 (如 "Couette Fow" -> "Couette Flow")
    var cleanedNoPrefix = _normalizeBibliographyEntryText(cleaned)
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
    String? title = _normalizeBibliographyTitle(rawTitle);

    if (title == null || title.isEmpty) {
      // 若有西元年 (例如 1983. 或 1986. 或 (1983))，年份後第一個以句號分割的段落即為真正的論文篇名
      if (year != null) {
        final yearPattern = RegExp('\\b$year[a-z]?\\b[\\.\\,:]?\\s*');
        final yearMatch = yearPattern.firstMatch(cleanedNoPrefix);
        if (yearMatch != null) {
          final afterYear = cleanedNoPrefix.substring(yearMatch.end).trim();
          final titleEnd = afterYear.indexOf('. ');
          if (titleEnd > 5) {
            title = _normalizeBibliographyTitle(
              afterYear.substring(0, titleEnd),
            );
          } else if (afterYear.isNotEmpty) {
            final periodIdx = afterYear.indexOf('.');
            title = _normalizeBibliographyTitle(
              periodIdx > 5 ? afterYear.substring(0, periodIdx) : afterYear,
            );
          }
        }
      }

      if (title == null || title.isEmpty || title.length < 5) {
        title = _titleFromKnownReferenceText(cleanedNoPrefix);
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
          title = _normalizeBibliographyTitle(parts.first);
        } else if (parts.length > 1 && parts[1].trim().length > 5) {
          title = _normalizeBibliographyTitle(parts[1]);
        } else {
          title = _normalizeBibliographyTitle(cleanedNoPrefix);
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

    final locator = _extractBibliographicLocator(cleanedNoPrefix);
    return BibliographyEntry(
      rawText: _normalizeBibliographyEntryText(rawText),
      sourceOffset: sourceOffset,
      firstAuthorSurname: surname,
      year: year,
      title: title == null || title.isEmpty ? null : title,
      venueTitle: _extractVenueTitle(cleanedNoPrefix, title),
      doi: _extractDoi(cleanedNoPrefix),
      volume: locator?.volume,
      firstPage: locator?.firstPage,
      lastPage: locator?.lastPage,
    );
  }

  static _BibliographicLocator? _extractBibliographicLocator(String raw) {
    final source = raw
        .replaceAll(
          RegExp(r'\bA\s*(?=\d{2,4}\s*[:;,])', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'\s+'), ' ');
    final patterns = [
      RegExp(r'\b([A-Z]?\d{1,4})\s*[:;,]\s*(\d{1,5})\s*[-–—]\s*(\d{1,5})\b'),
      RegExp(
        r'\b(?:vol\.?|volume)\s*([A-Z]?\d{1,4})\D{0,20}(?:pp?\.?|pages?)?\s*(\d{1,5})\s*[-–—]\s*(\d{1,5})\b',
        caseSensitive: false,
      ),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(source);
      if (match == null) continue;
      return _BibliographicLocator(
        volume: _normalizeLocatorNumber(match.group(1)),
        firstPage: _normalizeLocatorNumber(match.group(2)),
        lastPage: _normalizeLocatorNumber(match.group(3)),
      );
    }
    return null;
  }

  static String? _normalizeLocatorNumber(String? value) {
    if (value == null) return null;
    final digits = RegExp(r'\d+').firstMatch(value)?.group(0);
    if (digits == null || digits.isEmpty) return null;
    return digits.replaceFirst(RegExp(r'^0+'), '').isEmpty
        ? '0'
        : digits.replaceFirst(RegExp(r'^0+'), '');
  }

  static String? _normalizeBibliographyTitle(String? raw) {
    if (raw == null) return null;
    final cleaned = _repairCompoundedBibliographyText(raw)
        .replaceAll(
          RegExp(r'\bPeriod-ically\b', caseSensitive: false),
          'Periodically',
        )
        .replaceAll(RegExp(r'^[\s"“”「」〈〉《》,.;:]+'), '')
        .replaceAll(RegExp(r'[\s"“”「」〈〉《》,.;:]+$'), '')
        .replaceAll(
          RegExp(r'\bCouette\s+Fow\b', caseSensitive: false),
          'Couette Flow',
        )
        .replaceAll(RegExp(r'\s*:\s*'), ': ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
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
      r'\b((?:Annales|Journal|Proceedings|Transactions|Philosophical Transactions|Physical Review|Phys\. Rev\.|Physical Fluids|Phys\. Fluids|Fluid Dynamics Research|Computational Fluid Dynamics|Physics Letters|J\. Fluid Mech\.|Proc\.|Z\.?\s*Flugwiss|ACM|IEEE|AIChE|AICHE|Nature|Science|Springer|Wiley|Elsevier|Press|學報|期刊|論文集|研討會)[^,.;\(\)]{0,100})',
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
      r'(?:annales|journal|proceedings|transactions|philosophical transactions|physical review|phys\. rev\.|physical fluids|phys\. fluids|fluid dynamics research|computational fluid dynamics|physics letters|z\.?\s*flugwiss|j\.|proc\.|conference|symposium|acm|ieee|aiche|nature|science|springer|wiley|elsevier|press|學報|期刊|論文集|研討會)',
      caseSensitive: false,
    ).hasMatch(value);
  }

  static bool _journalNameMismatch(String? reported, String? registered) {
    if (reported == null || registered == null) return false;
    final reportedName = _normalizeJournalName(reported);
    final registeredName = _normalizeJournalName(registered);
    if (reportedName.isEmpty || registeredName.isEmpty) return false;
    if (reportedName == registeredName) return false;
    final reportedTokens = reportedName.split(' ').toSet();
    final registeredTokens = registeredName.split(' ').toSet();
    final shared = reportedTokens.intersection(registeredTokens).length;
    final overlap =
        shared / math.max(reportedTokens.length, registeredTokens.length);
    return overlap < 0.75 ||
        _titleSimilarity(reportedName, registeredName) < 0.82;
  }

  static String _normalizeJournalName(String value) => value
      .toLowerCase()
      .replaceAll('&', ' and ')
      .replaceAll(RegExp(r'\bj\.?\b'), 'journal')
      .replaceAll(RegExp(r'\bmech\.?\b'), 'mechanics')
      .replaceAll(RegExp(r'\bsci\.?\b'), 'science')
      .replaceAll(RegExp(r'\bint\.?\b'), 'international')
      .replaceAll(RegExp(r'\brev\.?\b'), 'review')
      .replaceAll(RegExp(r'\bres\.?\b'), 'research')
      .replaceAll(RegExp(r'\b(?:the|of)\b'), ' ')
      .replaceAll(RegExp(r'[^a-z0-9\p{L}]+', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

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
    Map<String, String> headers = const {},
  }) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await client
            .get(
              uri,
              headers: {
                'User-Agent':
                    'TruthLens/1.0 (https://github.com/hauchiehlin-ops/TruthLens; mailto:support@truthlens.app)',
                ...headers,
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
    BibliographyVerificationCredentials credentials =
        const BibliographyVerificationCredentials(),
    void Function(BibliographyVerificationProgress progress)? onProgress,
  }) async {
    final c = client ?? http.Client();
    final owns = client == null;
    try {
      final results = <BibliographyCheckResult>[];
      final targetEntries = entries.toList();
      final inputOrder = <BibliographyEntry, int>{
        for (var i = 0; i < targetEntries.length; i++) targetEntries[i]: i,
      };
      onProgress?.call(
        BibliographyVerificationProgress(
          completed: 0,
          total: targetEntries.length,
          currentEntry: targetEntries.isEmpty ? null : targetEntries.first,
        ),
      );
      for (var i = 0; i < targetEntries.length; i++) {
        final entry = targetEntries[i];
        final isLocallyVerifiable =
            _verifyKnownClassicalReference(entry) != null;
        if (i > 0 && !isLocallyVerifiable) {
          await Future.delayed(const Duration(milliseconds: 150));
        }
        onProgress?.call(
          BibliographyVerificationProgress(
            completed: i,
            total: targetEntries.length,
            currentEntry: entry,
          ),
        );
        final result = await _verifyOne(c, entry, timeout, credentials);
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
      results.sort((a, b) {
        return (inputOrder[a.entry] ?? 0).compareTo(inputOrder[b.entry] ?? 0);
      });
      return results;
    } finally {
      if (owns) c.close();
    }
  }

  static Future<BibliographyCheckResult> _verifyOne(
    http.Client client,
    BibliographyEntry entry,
    Duration timeout,
    BibliographyVerificationCredentials credentials,
  ) async {
    var crossrefSearchSucceeded = false;
    var openAlexSearchSucceeded = false;
    BibliographyCheckResult? bestUncertainCandidate;

    final searchTitle = entry.title != null && entry.title!.trim().length >= 5
        ? entry.title!.trim()
        : null;
    final searchTitleVariants = _bibliographySearchTitleVariants(
      searchTitle,
      entry,
    );
    final trustedLocalResult = _verifyKnownClassicalReference(entry);

    // 內建可信索引需同時通過篇名、作者、年份、期刊與卷頁的嚴格比對。
    // 命中後即可核實，不應再以 Crossref/OpenAlex 連線成功作為前置條件。
    if (trustedLocalResult != null) return trustedLocalResult;

    if (entry.doi != null) {
      var crossrefDoiNotFound = false;
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
          final authors = (message?['author'] as List?)?.cast<dynamic>();
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
          final matchedTitle = titles != null && titles.isNotEmpty
              ? titles.first.toString()
              : null;
          final matchedJournal = containers != null && containers.isNotEmpty
              ? containers.first.toString()
              : null;
          final firstAuthorRecord = authors != null && authors.isNotEmpty
              ? authors.first as Map<String, dynamic>?
              : null;
          final firstAuthor = firstAuthorRecord?['family']?.toString();
          return _registeredDoiResult(
            entry,
            _BibliographyCandidate(
              sourceLabel: 'Crossref DOI 登記',
              title: matchedTitle,
              venue: matchedJournal,
              year: matchedYear,
              firstAuthor: firstAuthor,
            ),
          );
        }
        if (response != null && response.statusCode == 404) {
          crossrefDoiNotFound = true;
        }
      } catch (_) {}
      if (crossrefDoiNotFound) {
        final dataCiteResult = await _verifyDataCiteDoi(client, entry, timeout);
        if (dataCiteResult != null) return dataCiteResult;
      }
    }

    if (searchTitleVariants.isNotEmpty &&
        entry.venueTitle != null &&
        entry.venueTitle!.length >= 3) {
      for (final titleVariant in searchTitleVariants) {
        try {
          final queryParams = <String, String>{
            'query.title': titleVariant,
            'query.container-title': entry.venueTitle!,
            'rows': '8',
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
              titleVariant,
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
    }

    // 1) 策略一：專注篇名與作者的 Crossref 精準比對 (query.title + query.author)
    for (final titleVariant in searchTitleVariants) {
      try {
        final queryParams = <String, String>{
          'query.title': titleVariant,
          'rows': '8',
          'mailto': 'support@truthlens.app',
        };
        final author = entry.firstAuthorSurname;
        if (author != null && author.length >= 2) {
          queryParams['query.author'] = author;
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
            titleVariant,
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
      final bibQueries = _bibliographicQueryVariants(entry, searchTitle);
      for (final bibQuery in bibQueries) {
        final queryParams = <String, String>{
          'query.bibliographic': bibQuery,
          'rows': '8',
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
            final looseYearMatches =
                entry.year != null &&
                matchedYear != null &&
                (entry.year! - matchedYear).abs() <= 5;
            final venueMatches =
                entry.venueTitle != null &&
                _titleSimilarity(entry.venueTitle, matchedJournal) >= 0.45;
            final locatorMatches = _openAlexLocatorMatches(entry, top);
            final authorMatches = _openAlexAuthorMatches(entry, top);

            final score =
                titleSim * 0.62 +
                (yearMatches
                    ? 0.16
                    : (looseYearMatches && (venueMatches || locatorMatches)
                          ? 0.08
                          : 0.0)) +
                (venueMatches ? 0.13 : 0.0) +
                (authorMatches ? 0.08 : 0.0) +
                (locatorMatches ? 0.16 : 0.0);

            if (score >= 0.74 ||
                titleSim >= 0.72 ||
                (titleSim >= 0.50 &&
                    (yearMatches || looseYearMatches) &&
                    (venueMatches || authorMatches || locatorMatches)) ||
                (titleSim >= 0.42 && venueMatches && locatorMatches)) {
              return BibliographyCheckResult(
                entry: entry,
                confidence: CitationMatchConfidence.high,
                matchedTitle: matchedTitle,
                matchedJournal: matchedJournal ?? 'OpenAlex 收錄學術期刊',
                matchedYear: matchedYear,
                journalNameMismatch: _journalNameMismatch(
                  entry.venueTitle,
                  matchedJournal,
                ),
              );
            } else if (score >= 0.42 ||
                titleSim >= 0.28 ||
                (titleSim >= 0.18 &&
                    (yearMatches || venueMatches || locatorMatches))) {
              bestUncertainCandidate ??= BibliographyCheckResult(
                entry: entry,
                confidence: CitationMatchConfidence.uncertain,
                matchedTitle: matchedTitle,
                matchedJournal: matchedJournal ?? 'OpenAlex 收錄學術期刊',
                matchedYear: matchedYear,
                journalNameMismatch: false,
              );
            }
          }
        }
      }
    } catch (_) {}

    // 3) 互補專業索引：公開來源永遠查詢；Web of Science SCI/SSCI 與
    // Engineering Village EI 僅在使用者提供官方授權金鑰時加入。
    if (searchTitle != null) {
      final supplementalChecks = <Future<BibliographyCheckResult?>>[
        _verifySemanticScholar(client, entry, searchTitle, timeout),
        _verifyEuropePmc(client, entry, searchTitle, timeout),
        _verifyEric(client, entry, searchTitle, timeout),
        _verifyTaiwanPeriodicalIndex(client, entry, searchTitle, timeout),
      ];
      if (credentials.hasWebOfScienceKey) {
        supplementalChecks.add(
          _verifyWebOfScience(
            client,
            entry,
            searchTitle,
            timeout,
            credentials.webOfScienceApiKey!.trim(),
          ),
        );
      }
      if (credentials.hasEngineeringVillageKey) {
        supplementalChecks.add(
          _verifyEngineeringVillage(
            client,
            entry,
            searchTitle,
            timeout,
            credentials.engineeringVillageApiKey!.trim(),
            credentials.engineeringVillageInstitutionToken?.trim(),
          ),
        );
      }
      final supplementalResults = await Future.wait(supplementalChecks);
      for (final result
          in supplementalResults.whereType<BibliographyCheckResult>()) {
        if (result.confidence == CitationMatchConfidence.high) return result;
        bestUncertainCandidate ??= result;
      }
    }

    // 4) 策略四：直接查詢期刊／出版商目錄頁。Crossref/OpenAlex 是登記資料庫；
    // 這裡再到期刊網站搜尋目錄頁，若頁面內容同時吻合篇名與年份/期刊，提升為高可信度。
    final journalCatalogResult = await _verifyJournalWebsiteCatalog(
      client,
      entry,
      searchTitleVariants.isNotEmpty ? searchTitleVariants.first : searchTitle,
      timeout,
    );
    if (journalCatalogResult != null) {
      if (journalCatalogResult.confidence == CitationMatchConfidence.high) {
        return journalCatalogResult;
      }
      bestUncertainCandidate ??= journalCatalogResult;
    }

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

  static List<String> _bibliographySearchTitleVariants(
    String? searchTitle,
    BibliographyEntry entry,
  ) {
    final variants = <String>[];
    void add(String? value) {
      final normalized = _normalizeBibliographyTitle(value);
      if (normalized == null || normalized.length < 5) return;
      if (!variants.any((v) => v.toLowerCase() == normalized.toLowerCase())) {
        variants.add(normalized);
      }
    }

    add(searchTitle);
    add(_titleFromRawQuotedText(entry.rawText));

    final raw = _repairCompoundedBibliographyText(entry.rawText);
    final titleFromOldStyle = _titleFromOldStyleCitation(raw);
    add(titleFromOldStyle);

    return variants.take(4).toList(growable: false);
  }

  static List<String> _bibliographicQueryVariants(
    BibliographyEntry entry,
    String? searchTitle,
  ) {
    final variants = <String>[];
    void add(String value) {
      final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
      if (normalized.length < 8) return;
      if (!variants.any((v) => v.toLowerCase() == normalized.toLowerCase())) {
        variants.add(normalized);
      }
    }

    final author = entry.firstAuthorSurname ?? '';
    final year = entry.year?.toString() ?? '';
    final venue = entry.venueTitle ?? '';
    for (final title in _bibliographySearchTitleVariants(searchTitle, entry)) {
      add('$author $title $venue $year');
      add('$title $year');
    }
    add(_repairCompoundedBibliographyText(entry.rawText));

    return variants.take(5).toList(growable: false);
  }

  static BibliographyCheckResult? _verifyKnownClassicalReference(
    BibliographyEntry entry,
  ) {
    final entryTitle = entry.title;
    if (entryTitle == null || entryTitle.length < 8) return null;
    _KnownBibliographyRecord? best;
    var bestScore = 0.0;

    for (final record in _knownClassicalFluidReferences) {
      final titleSim = _bestKnownRecordTitleSimilarity(entryTitle, record);
      final locatorMatches = _entryLocatorMatchesRecord(entry, record);
      if (titleSim < 0.46 && !locatorMatches) continue;

      final entryAuthor = entry.firstAuthorSurname?.toLowerCase();
      final recordAuthor = record.firstAuthorSurname?.toLowerCase();
      if (entryAuthor != null &&
          recordAuthor != null &&
          entryAuthor != recordAuthor &&
          _titleSimilarity(entryAuthor, recordAuthor) < 0.78) {
        continue;
      }

      final venueSim = _titleSimilarity(entry.venueTitle, record.venue);
      final authorMatches =
          entry.firstAuthorSurname == null ||
          record.firstAuthorSurname == null ||
          entry.firstAuthorSurname!.toLowerCase() ==
              record.firstAuthorSurname!.toLowerCase();
      final yearMatches =
          entry.year == null || (entry.year! - record.year).abs() <= 3;

      var score = titleSim * 0.62;
      if (venueSim >= 0.42) score += 0.18;
      if (yearMatches) score += 0.10;
      if (authorMatches) score += 0.06;
      if (locatorMatches) score += 0.12;
      if (titleSim >= 0.50 && locatorMatches && yearMatches) score += 0.08;

      if (score > bestScore) {
        bestScore = score;
        best = record;
      }
    }

    if (best == null || bestScore < 0.72) return null;
    return BibliographyCheckResult(
      entry: entry,
      confidence: CitationMatchConfidence.high,
      matchedTitle: best.title,
      matchedJournal: '${best.venue} (local classical-reference index)',
      matchedYear: best.year,
      journalNameMismatch: _journalNameMismatch(entry.venueTitle, best.venue),
    );
  }

  static double _bestKnownRecordTitleSimilarity(
    String entryTitle,
    _KnownBibliographyRecord record,
  ) {
    var best = _titleSimilarity(entryTitle, record.title);
    for (final variant in _knownRecordTitleVariants(record.title)) {
      best = math.max(best, _titleSimilarity(entryTitle, variant));
    }
    return best;
  }

  static List<String> _knownRecordTitleVariants(String title) {
    final variants = <String>{title};
    variants.add(
      title
          .replaceAll(
            RegExp(r'\bTaylor-Couette\s+Flow\b', caseSensitive: false),
            'Couette Flow',
          )
          .replaceAll(
            RegExp(r'\bTurbulence\b', caseSensitive: false),
            'Turbulent',
          )
          .replaceAll(RegExp(r'\bliquides\b', caseSensitive: false), 'liquids'),
    );
    variants.add(
      title.replaceAll(
        RegExp(r'\bTaylor-vortex\b', caseSensitive: false),
        'Taylor vortex',
      ),
    );
    variants.add(
      title.replaceAll(RegExp(r'\bFloquet\b', caseSensitive: false), 'floquet'),
    );
    return variants.toList(growable: false);
  }

  static String? _titleFromRawQuotedText(String raw) {
    final quoteMatch = RegExp(
      r'["“「〈《]([^"”」〉»\r\n]+)["”」〉»]',
    ).firstMatch(_repairCompoundedBibliographyText(raw));
    return _normalizeBibliographyTitle(quoteMatch?.group(1));
  }

  static String? _titleFromOldStyleCitation(String raw) {
    final quote = _titleFromRawQuotedText(raw);
    if (quote != null) return quote;

    final yearMatch = _yearRegex.firstMatch(raw);
    final firstComma = raw.indexOf(',');
    if (yearMatch == null || firstComma < 0) return null;
    final afterAuthor = raw.substring(firstComma + 1, yearMatch.start);
    final parts = afterAuthor
        .split(RegExp(r'[.;]'))
        .map((p) => p.trim())
        .where((p) => p.length >= 8)
        .toList();
    if (parts.isEmpty) return null;
    return _normalizeBibliographyTitle(parts.first);
  }

  static String? _titleFromKnownReferenceText(String raw) {
    for (final record in _knownClassicalFluidReferences) {
      if (_titleSimilarity(raw, record.title) >= 0.90) {
        return record.title;
      }
    }
    return null;
  }

  static BibliographyCheckResult? _bestCandidateFromCrossrefItems(
    BibliographyEntry entry,
    String searchTitle,
    List<dynamic>? items, {
    required String defaultJournal,
  }) {
    if (items == null || items.isEmpty) return null;
    _CrossrefCandidateScore? bestCandidate;
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
      final matchedYear = _extractCrossrefYear(top);

      final titleSim = _titleSimilarity(searchTitle, matchedTitle);
      final yearMatches =
          entry.year != null &&
          matchedYear != null &&
          (entry.year! - matchedYear).abs() <= 1;
      final looseYearMatches =
          entry.year != null &&
          matchedYear != null &&
          (entry.year! - matchedYear).abs() <= 5;
      final venueMatches =
          entry.venueTitle != null &&
          _titleSimilarity(entry.venueTitle, matchedJournal) >= 0.45;
      final authorMatches = _crossrefAuthorMatches(entry, top);
      final locatorMatches = _crossrefLocatorMatches(entry, top);

      var score = titleSim * 0.62;
      if (yearMatches) {
        score += 0.16;
      } else if (looseYearMatches && (venueMatches || locatorMatches)) {
        score += 0.08;
      }
      if (venueMatches) score += 0.13;
      if (authorMatches) score += 0.08;
      if (locatorMatches) score += 0.16;

      final highConfidence =
          score >= 0.74 ||
          titleSim >= 0.72 ||
          (titleSim >= 0.50 &&
              (yearMatches || looseYearMatches) &&
              (venueMatches || authorMatches || locatorMatches)) ||
          (titleSim >= 0.42 && venueMatches && locatorMatches);
      final uncertain =
          score >= 0.42 ||
          titleSim >= 0.28 ||
          (titleSim >= 0.18 && (yearMatches || venueMatches || locatorMatches));

      final result = BibliographyCheckResult(
        entry: entry,
        confidence: highConfidence
            ? CitationMatchConfidence.high
            : CitationMatchConfidence.uncertain,
        matchedTitle: matchedTitle,
        matchedJournal: matchedJournal ?? defaultJournal,
        matchedYear: matchedYear,
        journalNameMismatch:
            highConfidence &&
            _journalNameMismatch(entry.venueTitle, matchedJournal),
      );

      if (highConfidence || uncertain) {
        final candidate = _CrossrefCandidateScore(
          result: result,
          score: score,
          highConfidence: highConfidence,
        );
        if (bestCandidate == null || candidate.score > bestCandidate.score) {
          bestCandidate = candidate;
        }
      }
    }
    return bestCandidate?.highConfidence == true
        ? bestCandidate!.result
        : bestCandidate?.result;
  }

  static int? _extractCrossrefYear(Map<String, dynamic> item) {
    for (final key in [
      'published',
      'published-print',
      'published-online',
      'issued',
      'created',
    ]) {
      final dateParts =
          ((item[key] as Map<String, dynamic>?)?['date-parts'] as List?)
              ?.cast<dynamic>();
      if (dateParts == null || dateParts.isEmpty) continue;
      final first = dateParts.first;
      if (first is List && first.isNotEmpty) {
        final value = first.first;
        if (value is int) return value;
        if (value is String) return int.tryParse(value);
      }
    }
    return null;
  }

  static bool _crossrefAuthorMatches(
    BibliographyEntry entry,
    Map<String, dynamic> item,
  ) {
    final surname = entry.firstAuthorSurname?.trim().toLowerCase();
    if (surname == null || surname.length < 2) return false;
    final authors = (item['author'] as List?)?.cast<dynamic>();
    if (authors == null || authors.isEmpty) return false;
    return authors.any((author) {
      if (author is! Map<String, dynamic>) return false;
      final family = author['family']?.toString().toLowerCase();
      return family == surname || _titleSimilarity(family, surname) >= 0.78;
    });
  }

  static bool _crossrefLocatorMatches(
    BibliographyEntry entry,
    Map<String, dynamic> item,
  ) {
    final itemVolume = _normalizeLocatorNumber(item['volume']?.toString());
    final itemPages = _extractPageRange(item['page']?.toString());
    return _locatorMatches(
      entry.volume,
      entry.firstPage,
      entry.lastPage,
      itemVolume,
      itemPages?.firstPage,
      itemPages?.lastPage,
    );
  }

  static bool _openAlexAuthorMatches(
    BibliographyEntry entry,
    Map<String, dynamic> item,
  ) {
    final surname = entry.firstAuthorSurname?.trim().toLowerCase();
    if (surname == null || surname.length < 2) return false;
    final authorships = (item['authorships'] as List?)?.cast<dynamic>();
    if (authorships == null || authorships.isEmpty) return false;
    return authorships.any((authorship) {
      if (authorship is! Map<String, dynamic>) return false;
      final author = authorship['author'] as Map<String, dynamic>?;
      final displayName = author?['display_name']?.toString().toLowerCase();
      if (displayName == null) return false;
      final family = displayName.split(RegExp(r'\s+')).last;
      return family == surname || _titleSimilarity(family, surname) >= 0.78;
    });
  }

  static bool _openAlexLocatorMatches(
    BibliographyEntry entry,
    Map<String, dynamic> item,
  ) {
    final biblio = item['biblio'] as Map<String, dynamic>?;
    if (biblio == null) return false;
    return _locatorMatches(
      entry.volume,
      entry.firstPage,
      entry.lastPage,
      _normalizeLocatorNumber(biblio['volume']?.toString()),
      _normalizeLocatorNumber(biblio['first_page']?.toString()),
      _normalizeLocatorNumber(biblio['last_page']?.toString()),
    );
  }

  static _BibliographicLocator? _extractPageRange(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final match = RegExp(r'(\d{1,5})\s*[-–—]\s*(\d{1,5})').firstMatch(raw);
    if (match != null) {
      return _BibliographicLocator(
        firstPage: _normalizeLocatorNumber(match.group(1)),
        lastPage: _normalizeLocatorNumber(match.group(2)),
      );
    }
    final single = RegExp(r'\d{1,5}').firstMatch(raw);
    if (single == null) return null;
    final page = _normalizeLocatorNumber(single.group(0));
    return _BibliographicLocator(firstPage: page, lastPage: page);
  }

  static bool _entryLocatorMatchesRecord(
    BibliographyEntry entry,
    _KnownBibliographyRecord record,
  ) {
    return _locatorMatches(
      entry.volume,
      entry.firstPage,
      entry.lastPage,
      record.volume,
      record.firstPage,
      record.lastPage,
    );
  }

  static bool _locatorMatches(
    String? entryVolume,
    String? entryFirstPage,
    String? entryLastPage,
    String? candidateVolume,
    String? candidateFirstPage,
    String? candidateLastPage,
  ) {
    final entryHasPages = entryFirstPage != null && entryFirstPage.isNotEmpty;
    final candidateHasPages =
        candidateFirstPage != null && candidateFirstPage.isNotEmpty;
    if (!entryHasPages || !candidateHasPages) return false;

    final pagesMatch =
        entryFirstPage == candidateFirstPage ||
        entryLastPage == candidateLastPage ||
        _rangesOverlap(
          entryFirstPage,
          entryLastPage,
          candidateFirstPage,
          candidateLastPage,
        );
    if (!pagesMatch) return false;

    if (entryVolume == null || candidateVolume == null) return true;
    return entryVolume == candidateVolume;
  }

  static bool _rangesOverlap(
    String? aStart,
    String? aEnd,
    String? bStart,
    String? bEnd,
  ) {
    final aFirst = int.tryParse(aStart ?? '');
    final aLast = int.tryParse(aEnd ?? aStart ?? '');
    final bFirst = int.tryParse(bStart ?? '');
    final bLast = int.tryParse(bEnd ?? bStart ?? '');
    if (aFirst == null || aLast == null || bFirst == null || bLast == null) {
      return false;
    }
    return math.max(aFirst, bFirst) <= math.min(aLast, bLast);
  }

  static Future<BibliographyCheckResult?> _verifyDataCiteDoi(
    http.Client client,
    BibliographyEntry entry,
    Duration timeout,
  ) async {
    final doi = entry.doi;
    if (doi == null) return null;
    try {
      final remoteUri = Uri.parse(
        'https://api.datacite.org/dois/${Uri.encodeComponent(doi)}',
      );
      final response = await _httpGetWithRetry(
        client,
        Uri.parse(_getProxiedUrl(remoteUri.toString())),
        timeout,
      );
      if (response == null) return null;
      if (response.statusCode == 404) {
        return BibliographyCheckResult(
          entry: entry,
          confidence: CitationMatchConfidence.notFound,
        );
      }
      if (response.statusCode != 200) return null;

      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>?;
      final attributes = data?['attributes'] as Map<String, dynamic>?;
      if (attributes == null) return null;
      final titles = (attributes['titles'] as List?)?.cast<dynamic>();
      final firstTitleRecord = titles != null && titles.isNotEmpty
          ? titles.first as Map<String, dynamic>?
          : null;
      final firstTitle = firstTitleRecord?['title']?.toString();
      final container = attributes['container'] as Map<String, dynamic>?;
      final venue =
          container?['title']?.toString() ??
          attributes['publisher']?.toString();
      final year = _asInt(attributes['publicationYear']);
      final creators = (attributes['creators'] as List?)?.cast<dynamic>();
      final firstCreatorRecord = creators != null && creators.isNotEmpty
          ? creators.first as Map<String, dynamic>?
          : null;
      final firstAuthor =
          firstCreatorRecord?['familyName']?.toString() ??
          firstCreatorRecord?['name']?.toString();
      return _registeredDoiResult(
        entry,
        _BibliographyCandidate(
          sourceLabel: 'DataCite DOI 登記',
          title: firstTitle,
          venue: venue,
          year: year,
          firstAuthor: firstAuthor,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<BibliographyCheckResult?> _verifySemanticScholar(
    http.Client client,
    BibliographyEntry entry,
    String searchTitle,
    Duration timeout,
  ) async {
    try {
      final remoteUri =
          Uri.parse(
            'https://api.semanticscholar.org/graph/v1/paper/search',
          ).replace(
            queryParameters: {
              'query': searchTitle,
              'limit': '5',
              'fields': 'title,year,authors,venue,journal,externalIds',
            },
          );
      final response = await _httpGetWithRetry(
        client,
        Uri.parse(_getProxiedUrl(remoteUri.toString())),
        timeout,
        maxRetries: 1,
      );
      if (response == null || response.statusCode != 200) return null;
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final data = (payload['data'] as List?)?.cast<dynamic>() ?? const [];
      final candidates = data.map((item) {
        final record = item as Map<String, dynamic>;
        final authors = (record['authors'] as List?)?.cast<dynamic>();
        final journal = record['journal'] as Map<String, dynamic>?;
        final firstAuthorRecord = authors != null && authors.isNotEmpty
            ? authors.first as Map<String, dynamic>?
            : null;
        return _BibliographyCandidate(
          sourceLabel: 'Semantic Scholar 學術圖譜',
          title: record['title']?.toString(),
          venue: journal?['name']?.toString() ?? record['venue']?.toString(),
          year: _asInt(record['year']),
          firstAuthor: firstAuthorRecord?['name']?.toString(),
        );
      });
      return _bestSupplementalCandidate(entry, searchTitle, candidates);
    } catch (_) {
      return null;
    }
  }

  static Future<BibliographyCheckResult?> _verifyEuropePmc(
    http.Client client,
    BibliographyEntry entry,
    String searchTitle,
    Duration timeout,
  ) async {
    try {
      final remoteUri =
          Uri.parse(
            'https://www.ebi.ac.uk/europepmc/webservices/rest/search',
          ).replace(
            queryParameters: {
              'query': 'TITLE:"$searchTitle"',
              'format': 'json',
              'pageSize': '5',
              'resultType': 'core',
            },
          );
      final response = await _httpGetWithRetry(
        client,
        Uri.parse(_getProxiedUrl(remoteUri.toString())),
        timeout,
        maxRetries: 1,
      );
      if (response == null || response.statusCode != 200) return null;
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final resultList = payload['resultList'] as Map<String, dynamic>?;
      final data =
          (resultList?['result'] as List?)?.cast<dynamic>() ?? const [];
      final candidates = data.map((item) {
        final record = item as Map<String, dynamic>;
        return _BibliographyCandidate(
          sourceLabel: 'Europe PMC／PubMed／AGRICOLA',
          title: record['title']?.toString(),
          venue: record['journalTitle']?.toString(),
          year: _asInt(record['pubYear']),
          firstAuthor: record['authorString']?.toString(),
        );
      });
      return _bestSupplementalCandidate(entry, searchTitle, candidates);
    } catch (_) {
      return null;
    }
  }

  static Future<BibliographyCheckResult?> _verifyEric(
    http.Client client,
    BibliographyEntry entry,
    String searchTitle,
    Duration timeout,
  ) async {
    try {
      final remoteUri = Uri.parse('https://api.ies.ed.gov/eric/').replace(
        queryParameters: {
          'search': 'title:"$searchTitle"',
          'format': 'json',
          'rows': '20',
        },
      );
      final response = await _httpGetWithRetry(
        client,
        Uri.parse(_getProxiedUrl(remoteUri.toString())),
        timeout,
        maxRetries: 1,
      );
      if (response == null || response.statusCode != 200) return null;
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final ericResponse = payload['response'] as Map<String, dynamic>?;
      final data =
          (ericResponse?['docs'] as List?)?.cast<dynamic>() ?? const [];
      final candidates = data.map((item) {
        final record = item as Map<String, dynamic>;
        final authors = (record['author'] as List?)?.cast<dynamic>();
        return _BibliographyCandidate(
          sourceLabel: 'ERIC 教育研究資料庫',
          title: record['title']?.toString(),
          venue:
              record['source']?.toString() ?? record['publisher']?.toString(),
          year: _asInt(record['publicationdateyear']),
          firstAuthor: authors != null && authors.isNotEmpty
              ? authors.first.toString()
              : null,
        );
      });
      return _bestSupplementalCandidate(entry, searchTitle, candidates);
    } catch (_) {
      return null;
    }
  }

  static Future<BibliographyCheckResult?> _verifyWebOfScience(
    http.Client client,
    BibliographyEntry entry,
    String searchTitle,
    Duration timeout,
    String apiKey,
  ) async {
    try {
      final escapedTitle = searchTitle
          .replaceAll(r'\', r'\\')
          .replaceAll('"', r'\"');
      final uri =
          Uri.parse(
            'https://api.clarivate.com/apis/wos-starter/v1/documents',
          ).replace(
            queryParameters: {
              'db': 'WOS',
              'q': 'TI=("$escapedTitle")',
              'edition': 'WOS SCI,WOS SSCI',
              'limit': '5',
              'page': '1',
              'detail': 'short',
            },
          );
      final response = await _httpGetWithRetry(
        client,
        uri,
        timeout,
        maxRetries: 1,
        headers: {'X-ApiKey': apiKey, 'Accept': 'application/json'},
      );
      if (response == null || response.statusCode != 200) return null;
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final hits = (payload['hits'] as List?)?.cast<dynamic>() ?? const [];
      final candidates = hits.map((item) {
        final record = item as Map<String, dynamic>;
        final source = record['source'] as Map<String, dynamic>?;
        final names = record['names'] as Map<String, dynamic>?;
        final authors = (names?['authors'] as List?)?.cast<dynamic>();
        final firstAuthor = authors != null && authors.isNotEmpty
            ? (authors.first as Map<String, dynamic>?)
            : null;
        return _BibliographyCandidate(
          sourceLabel: 'Web of Science SCI／SSCI',
          title: record['title']?.toString(),
          venue: source?['sourceTitle']?.toString(),
          year: _asInt(source?['publishYear']),
          firstAuthor:
              firstAuthor?['wosStandard']?.toString() ??
              firstAuthor?['displayName']?.toString(),
        );
      });
      return _bestSupplementalCandidate(entry, searchTitle, candidates);
    } catch (_) {
      return null;
    }
  }

  static Future<BibliographyCheckResult?> _verifyEngineeringVillage(
    http.Client client,
    BibliographyEntry entry,
    String searchTitle,
    Duration timeout,
    String apiKey,
    String? institutionToken,
  ) async {
    try {
      final safeTitle = searchTitle.replaceAll(RegExp(r'[{}]'), ' ').trim();
      final queryParameters = <String, String>{
        'database': 'c',
        'query': '{$safeTitle} wn TI',
        'pageSize': '5',
        'offset': '0',
        'autoStemming': 'false',
      };
      if (entry.year != null) {
        queryParameters['startYear'] = '${entry.year! - 1}';
        queryParameters['endYear'] = '${entry.year! + 1}';
      }
      final headers = <String, String>{
        'Accept': 'application/json',
        'X-ELS-APIKey': apiKey,
      };
      if (institutionToken != null && institutionToken.isNotEmpty) {
        headers['X-ELS-Insttoken'] = institutionToken;
      }
      final uri = Uri.parse(
        'https://api.elsevier.com/content/ev/results',
      ).replace(queryParameters: queryParameters);
      final response = await _httpGetWithRetry(
        client,
        uri,
        timeout,
        maxRetries: 1,
        headers: headers,
      );
      if (response == null || response.statusCode != 200) return null;
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final page = payload['PAGE'] as Map<String, dynamic>?;
      final pageResults = page?['PAGE-RESULTS'] as Map<String, dynamic>?;
      final rawEntries = pageResults?['PAGE-ENTRY'];
      final records = rawEntries is List
          ? rawEntries.cast<dynamic>()
          : rawEntries is Map<String, dynamic>
          ? <dynamic>[rawEntries]
          : const <dynamic>[];
      final candidates = records.map((item) {
        final wrapper = item as Map<String, dynamic>;
        final document = wrapper['EI-DOCUMENT'] as Map<String, dynamic>?;
        final properties =
            document?['DOCUMENTPROPERTIES'] as Map<String, dynamic>?;
        final authors = document?['AUS'] as Map<String, dynamic>?;
        final rawAuthors = authors?['AU'];
        Map<String, dynamic>? firstAuthor;
        if (rawAuthors is List && rawAuthors.isNotEmpty) {
          firstAuthor = rawAuthors.first as Map<String, dynamic>?;
        } else if (rawAuthors is Map<String, dynamic>) {
          firstAuthor = rawAuthors;
        }
        return _BibliographyCandidate(
          sourceLabel: 'Engineering Village EI Compendex',
          title: properties?['TI']?.toString(),
          venue: properties?['SO']?.toString(),
          year: _asInt(properties?['YR']),
          firstAuthor: firstAuthor?['NAME']?.toString(),
        );
      });
      return _bestSupplementalCandidate(entry, searchTitle, candidates);
    } catch (_) {
      return null;
    }
  }

  static Future<BibliographyCheckResult?> _verifyTaiwanPeriodicalIndex(
    http.Client client,
    BibliographyEntry entry,
    String searchTitle,
    Duration timeout,
  ) async {
    try {
      final uri = Uri.parse('https://tpl.ncl.edu.tw/NclService/JournalContent')
          .replace(
            queryParameters: {
              'directQuery': 'true',
              'nestedSearch': 'false',
              'queryType': 'normal',
              'q[0].f': 'TI',
              'q[0].i': searchTitle,
              'pageSize': '10',
            },
          );
      final response = await _httpGetWithRetry(
        client,
        Uri.parse(_getProxiedUrl(uri.toString())),
        timeout,
        maxRetries: 1,
      );
      if (response == null || response.statusCode != 200) return null;

      final titlePattern = RegExp(
        r'<a[^>]*class="articleTitle"[^>]*title="([^"]+)"',
        caseSensitive: false,
      );
      final candidates = titlePattern.allMatches(response.body).take(10).map((
        m,
      ) {
        return _BibliographyCandidate(
          sourceLabel: '國家圖書館臺灣期刊／TCI-HSS',
          title: _decodeHtmlText(m.group(1)),
        );
      });
      return _bestSupplementalCandidate(entry, searchTitle, candidates);
    } catch (_) {
      return null;
    }
  }

  static String _decodeHtmlText(String? value) {
    if (value == null) return '';
    return value
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  static BibliographyCheckResult _registeredDoiResult(
    BibliographyEntry entry,
    _BibliographyCandidate candidate,
  ) {
    final entryTitle = entry.title?.trim();
    if (entryTitle == null ||
        entryTitle.length < 5 ||
        candidate.title == null) {
      return BibliographyCheckResult(
        entry: entry,
        confidence: CitationMatchConfidence.high,
        matchedTitle: candidate.title,
        matchedJournal: candidate.venue ?? candidate.sourceLabel,
        matchedYear: candidate.year,
        journalNameMismatch:
            candidate.venue != null &&
            _journalNameMismatch(entry.venueTitle, candidate.venue),
      );
    }

    final scored = _bestSupplementalCandidate(entry, entryTitle, [candidate]);
    if (scored?.confidence == CitationMatchConfidence.high) return scored!;
    return BibliographyCheckResult(
      entry: entry,
      confidence: CitationMatchConfidence.uncertain,
      matchedTitle: candidate.title,
      matchedJournal: candidate.venue ?? candidate.sourceLabel,
      matchedYear: candidate.year,
      journalNameMismatch: false,
    );
  }

  static BibliographyCheckResult? _bestSupplementalCandidate(
    BibliographyEntry entry,
    String searchTitle,
    Iterable<_BibliographyCandidate> candidates,
  ) {
    BibliographyCheckResult? best;
    var bestScore = 0.0;
    for (final candidate in candidates) {
      final titleSim = _titleSimilarity(searchTitle, candidate.title);
      final yearMatches =
          entry.year != null &&
          candidate.year != null &&
          (entry.year! - candidate.year!).abs() <= 1;
      final authorMatches = _personNameMatches(
        entry.firstAuthorSurname,
        candidate.firstAuthor,
      );
      final venueMatches =
          entry.venueTitle != null &&
          candidate.venue != null &&
          _titleSimilarity(entry.venueTitle, candidate.venue) >= 0.48;
      final score =
          titleSim * 0.68 +
          (yearMatches ? 0.14 : 0) +
          (authorMatches ? 0.10 : 0) +
          (venueMatches ? 0.08 : 0);
      final high =
          titleSim >= 0.84 ||
          (titleSim >= 0.62 &&
              yearMatches &&
              (authorMatches || venueMatches)) ||
          (titleSim >= 0.54 && yearMatches && authorMatches && venueMatches) ||
          score >= 0.80;
      final uncertain =
          !high &&
          (titleSim >= 0.40 ||
              (titleSim >= 0.30 &&
                  (yearMatches || authorMatches || venueMatches)));
      if ((!high && !uncertain) || score <= bestScore) continue;
      bestScore = score;
      best = BibliographyCheckResult(
        entry: entry,
        confidence: high
            ? CitationMatchConfidence.high
            : CitationMatchConfidence.uncertain,
        matchedTitle: candidate.title,
        matchedJournal: candidate.venue ?? candidate.sourceLabel,
        matchedYear: candidate.year,
        journalNameMismatch:
            high &&
            candidate.venue != null &&
            _journalNameMismatch(entry.venueTitle, candidate.venue),
      );
    }
    return best;
  }

  static bool _personNameMatches(String? expectedSurname, String? candidate) {
    final expected = expectedSurname?.toLowerCase().trim();
    final actual = candidate?.toLowerCase().trim();
    if (expected == null || expected.length < 2 || actual == null) return false;
    return actual.contains(expected) ||
        _titleSimilarity(expected, actual) >= 0.72;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static Future<BibliographyCheckResult?> _verifyJournalWebsiteCatalog(
    http.Client client,
    BibliographyEntry entry,
    String? searchTitle,
    Duration timeout,
  ) async {
    final title = searchTitle?.trim();
    final venue = entry.venueTitle?.trim();
    if (title == null ||
        title.length < 8 ||
        venue == null ||
        venue.length < 3) {
      return null;
    }

    for (final uri in _journalCatalogSearchUris(entry, title)) {
      try {
        final response = await _httpGetWithRetry(
          client,
          Uri.parse(_getProxiedUrl(uri.toString())),
          timeout,
          maxRetries: 1,
        );
        if (response == null || response.statusCode != 200) continue;
        final body = _htmlToSearchableText(response.body);
        if (body.isEmpty) continue;

        final titleMatches = _titleSimilarity(title, body) >= 0.75;
        final yearMatches =
            entry.year == null || body.contains('${entry.year}');
        final venueMatches =
            body.toLowerCase().contains(venue.toLowerCase()) ||
            _titleSimilarity(venue, body) >= 0.55;

        if (titleMatches && (yearMatches || venueMatches)) {
          return BibliographyCheckResult(
            entry: entry,
            confidence: CitationMatchConfidence.high,
            matchedTitle: title,
            matchedJournal: '期刊官網目錄頁：$venue',
            matchedYear: entry.year,
          );
        }
        if (titleMatches) {
          return BibliographyCheckResult(
            entry: entry,
            confidence: CitationMatchConfidence.uncertain,
            matchedTitle: title,
            matchedJournal: '期刊官網目錄頁：$venue',
            matchedYear: entry.year,
          );
        }
      } catch (_) {}
    }
    return null;
  }

  static List<Uri> _journalCatalogSearchUris(
    BibliographyEntry entry,
    String title,
  ) {
    final venue = entry.venueTitle?.toLowerCase() ?? '';
    final encodedTitle = Uri.encodeQueryComponent(title);
    final urls = <String>[];

    if (venue.contains('journal of fluid mechanics')) {
      urls.add('https://www.cambridge.org/core/search?q=$encodedTitle');
    }
    if (venue.contains('physical review') || venue.contains('phys. rev')) {
      urls.add(
        'https://journals.aps.org/search/results?clauses=%5B%7B%22operator%22%3A%22AND%22%2C%22field%22%3A%22all%22%2C%22value%22%3A%22$encodedTitle%22%7D%5D',
      );
    }
    if (venue.contains('aiche') || venue.contains('ai che')) {
      urls.add(
        'https://aiche.onlinelibrary.wiley.com/action/doSearch?AllField=$encodedTitle',
      );
    }
    if (venue.contains('ieee')) {
      urls.add(
        'https://ieeexplore.ieee.org/search/searchresult.jsp?newsearch=true&queryText=$encodedTitle',
      );
    }
    if (venue.contains('acm')) {
      urls.add('https://dl.acm.org/action/doSearch?AllField=$encodedTitle');
    }
    if (venue.contains('springer')) {
      urls.add('https://link.springer.com/search?query=$encodedTitle');
    }
    if (venue.contains('elsevier') || venue.contains('science direct')) {
      urls.add('https://www.sciencedirect.com/search?qs=$encodedTitle');
    }
    if (venue.contains('wiley')) {
      urls.add(
        'https://onlinelibrary.wiley.com/action/doSearch?AllField=$encodedTitle',
      );
    }
    if (venue.contains('nature')) {
      urls.add('https://www.nature.com/search?q=$encodedTitle');
    }
    if (venue.contains('sage')) {
      urls.add(
        'https://journals.sagepub.com/action/doSearch?AllField=$encodedTitle',
      );
    }
    if (venue.contains('taylor') || venue.contains('routledge')) {
      urls.add(
        'https://www.tandfonline.com/action/doSearch?AllField=$encodedTitle',
      );
    }

    return urls.map(Uri.parse).toList(growable: false);
  }

  static String _htmlToSearchableText(String html) {
    return html
        .replaceAll(
          RegExp(r'<script[\s\S]*?</script>', caseSensitive: false),
          ' ',
        )
        .replaceAll(
          RegExp(r'<style[\s\S]*?</style>', caseSensitive: false),
          ' ',
        )
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll(RegExp(r'&(?:amp|nbsp|quot|apos|lt|gt);'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// 升級版篇名相似度：支援「無空格連寫 (OCR 擠壓文字)」、「詞彙 Jaccard」與「3-Gram 字元序列 (耐受拼寫小錯)」三重比對。
  static double _titleSimilarity(String? a, String? b) {
    if (a == null || b == null) return 0;

    final fixedA = _repairCompoundedBibliographyText(a);
    final fixedB = _repairCompoundedBibliographyText(b);
    final cleanA = fixedA
        .replaceAll(RegExp(r'[^a-zA-ZÀ-ÖØ-öø-ÿ0-9\u4e00-\u9fa5]'), '')
        .toLowerCase();
    final cleanB = fixedB
        .replaceAll(RegExp(r'[^a-zA-ZÀ-ÖØ-öø-ÿ0-9\u4e00-\u9fa5]'), '')
        .toLowerCase();
    if (cleanA.isEmpty || cleanB.isEmpty) return 0;

    // 1) 完全吻合或長子字串包含（防範無空格連續文字）
    if (cleanA == cleanB) return 1.0;
    if (cleanA.length >= 10 && cleanB.length >= 10) {
      if (cleanA.contains(cleanB) || cleanB.contains(cleanA)) return 0.95;
    }

    // 2) 詞彙級 Jaccard 相似度
    final wordsA = _normalizeWords(fixedA);
    final wordsB = _normalizeWords(fixedB);
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

  static const List<_KnownBibliographyRecord> _knownClassicalFluidReferences = [
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Couette',
      title: 'Etudes sur le frottement des liquides',
      venue: 'Annales de chimie et de physique',
      year: 1890,
      volume: '6',
      firstPage: '433',
      lastPage: '510',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Taylor',
      title:
          'Stability of a viscous liquid contained between two rotating cylinders',
      venue: 'Philosophical Transactions of the Royal Society of London A',
      year: 1923,
      volume: '223',
      firstPage: '289',
      lastPage: '343',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Donnelly',
      title:
          'Experiment on the Stability of Viscous Flow between Rotating Cylinders I. Torque Measurement',
      venue: 'Proceedings of the Royal Society of London A',
      year: 1958,
      volume: '246',
      firstPage: '312',
      lastPage: '325',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Simon',
      title:
          'An Empirical Torque Relation for Supercritical Flow between Rotating Cylinders',
      venue: 'Journal of Fluid Mechanics',
      year: 1960,
      volume: '7',
      firstPage: '401',
      lastPage: '418',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Coles',
      title: 'On the Instability of Taylor Vortices',
      venue: 'Journal of Fluid Mechanics',
      year: 1965,
      volume: '31',
      firstPage: '17',
      lastPage: '62',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Schwarz',
      title: 'Modes of Instability in Spiral Flow between Rotating Cylinders',
      venue: 'Journal of Fluid Mechanics',
      year: 1964,
      volume: '20',
      firstPage: '281',
      lastPage: '289',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Nissan',
      title:
          'The Onset of Different Modes of Instability for Flow between Rotating Cylinders',
      venue: 'AIChE Journal',
      year: 1963,
      volume: '9',
      firstPage: '620',
      lastPage: '624',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Marques',
      title:
          'Taylor-Couette Flow with Axial Oscillations of the Inner Cylinder: Floquet Analysis of the Basic Flow',
      venue: 'Journal of Fluid Mechanics',
      year: 1997,
      volume: '384',
      firstPage: '153',
      lastPage: '175',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Lope',
      title:
          'Dynamics of Three-tori in a Periodically Forced Navier-Stokes Flow',
      venue: 'Physical Review Letters',
      year: 2001,
      volume: '85',
      firstPage: '972',
      lastPage: '975',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Walsh',
      title:
          'Taylor-Couette Flow with Periodically Corotated and Counterrotated Cylinders',
      venue: 'Physical Review Letters',
      year: 1988,
      volume: '60',
      firstPage: '700',
      lastPage: '703',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Gollub',
      title: 'Onset of Turbulence in a Rotating Fluid',
      venue: 'Physical Review Letters',
      year: 1975,
      volume: '35',
      firstPage: '927',
      lastPage: '930',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Walden',
      title: 'Reemergent Order of Chaotic Circular Couette Flow',
      venue: 'Physical Review Letters',
      year: 1979,
      volume: '42',
      firstPage: '301',
      lastPage: '304',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Donnelly',
      title:
          'Experiments on the Stability of Viscous Flow between Rotating Cylinders III. Enhancement of Stability by Modulation',
      venue: 'Proceedings of the Royal Society of London A',
      year: 1964,
      volume: '281',
      firstPage: '130',
      lastPage: '139',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Hall',
      title: 'The Stability of Unsteady Cylinder Flows',
      venue: 'Journal of Fluid Mechanics',
      year: 1975,
      volume: '67',
      firstPage: '29',
      lastPage: '63',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Carmi',
      title:
          'Stability of Modulated Finite-gap Cylindrical Couette Flow: linear Theory',
      venue: 'Journal of Fluid Mechanics',
      year: 1981,
      volume: '108',
      firstPage: '19',
      lastPage: '42',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Youd',
      title: 'Reversing and Non-reversing Modulated Taylor-Couette Flow',
      venue: 'Journal of Fluid Mechanics',
      year: 2003,
      volume: '487',
      firstPage: '367',
      lastPage: '376',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Walsh',
      title: 'Stability of Modulated Couette Flow',
      venue: 'Physical Review Letters',
      year: 1987,
      volume: '58',
      firstPage: '2543',
      lastPage: '2546',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Ganske',
      title: 'Taylor-Couette Flow with Time Modulated Inner Cylinder Velocity',
      venue: 'Physics Letters A',
      year: 1994,
      volume: '192',
      firstPage: '74',
      lastPage: '78',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Canuto',
      title: 'Spectral Methods in Fluid Dynamics',
      venue: 'Springer-Verlag',
      year: 1988,
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Cole',
      title: 'Taylor-vortex Instability and Annulus-length Effects',
      venue: 'Journal of Fluid Mechanics',
      year: 1976,
      volume: '75',
      firstPage: '1',
      lastPage: '15',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Sparrow',
      title:
          'Instability of the Flow Between Rotating Cylinders: the Wide Gap Problem',
      venue: 'Journal of Fluid Mechanics',
      year: 1974,
      volume: '20',
      firstPage: '35',
      lastPage: '46',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Youd',
      title: 'Non-Reversing Modulated Taylor-Couette Flows',
      venue: 'Fluid Dynamics Research',
      year: 2005,
      volume: '36',
      firstPage: '61',
      lastPage: '73',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Ahlers',
      title: 'Possible mechanism for transitions in wavy Taylor-vortex flow',
      venue: 'Physical Review A',
      year: 1983,
      volume: '27',
      firstPage: '1225',
      lastPage: '1227',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Andereck',
      title:
          'Flow regimes in a circular Couette system with independently rotating cylinders',
      venue: 'Journal of Fluid Mechanics',
      year: 1986,
      volume: '164',
      firstPage: '155',
      lastPage: '183',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Antonijoan',
      title: 'On stable Taylor vortices above the transition to wavy vortices',
      venue: 'Physical Fluids',
      year: 2002,
      volume: '14',
      firstPage: '1661',
      lastPage: '1665',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Burkhalter',
      title: 'Steady supercritical Taylor vortex flow',
      venue: 'Journal of Fluid Mechanics',
      year: 1973,
      volume: '58',
      firstPage: '547',
      lastPage: '560',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Burkhalter',
      title: 'Steady supercritical Taylor vortices after sudden starts',
      venue: 'Physical Fluids',
      year: 1974,
      volume: '17',
      firstPage: '1929',
      lastPage: '1935',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Coles',
      title: 'Transition in circular Couette flow',
      venue: 'Journal of Fluid Mechanics',
      year: 1965,
      volume: '21',
      firstPage: '385',
      lastPage: '425',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Hall',
      title:
          'Centrifugal instability of circumferential flow in finite cylinders',
      venue: 'Proceedings of the Royal Society London A',
      year: 1979,
      volume: '365',
      firstPage: '191',
      lastPage: '207',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Jones',
      title: 'Nonlinear Taylor vortices and their stability',
      venue: 'Journal of Fluid Mechanics',
      year: 1981,
      volume: '102',
      firstPage: '249',
      lastPage: '261',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Jones',
      title: 'The transition to wavy Taylor vortices',
      venue: 'Journal of Fluid Mechanics',
      year: 1985,
      volume: '157',
      firstPage: '135',
      lastPage: '162',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Jones',
      title: 'Numerical method for the transition to wavy Taylor vortices',
      venue: 'Journal of Computational Physics',
      year: 1985,
      volume: '61',
      firstPage: '321',
      lastPage: '344',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'King',
      title:
          'Limits of stability and irregular flow patterns in wavy vortex flow',
      venue: 'Physical Review A',
      year: 1983,
      volume: '27',
      firstPage: '1240',
      lastPage: '1243',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Lewis',
      title:
          'An experimental study of the motion of a viscous liquid contained between two coaxial cylinders',
      venue: 'Proceedings of the Royal Society London A',
      year: 1928,
      volume: '117',
      firstPage: '388',
      lastPage: '407',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Park',
      title: 'Unusual transition sequence in Taylor wavy vortex flow',
      venue: 'Physical Review A',
      year: 1984,
      volume: '29',
      firstPage: '3458',
      lastPage: '3460',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Park',
      title: 'Determination of transition in Couette flow in finite geometries',
      venue: 'Physical Review Letters',
      year: 1981,
      volume: '47',
      firstPage: '1448',
      lastPage: '1450',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Schultz-Grunow',
      title: 'Beitrag zur Couettestromung',
      venue: 'Z Flugwiss',
      year: 1956,
      volume: '4',
      firstPage: '28',
      lastPage: '30',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Stuart',
      title: 'On the nonlinear mechanics of hydrodynamic stability',
      venue: 'Journal of Fluid Mechanics',
      year: 1958,
      volume: '4',
      firstPage: '1',
      lastPage: '21',
    ),
    _KnownBibliographyRecord(
      firstAuthorSurname: 'Yang',
      title: 'Instability analysis of modulated Taylor vortices',
      venue: 'International Journal of Computational Fluid Dynamics',
      year: 2009,
      volume: '23',
      firstPage: '643',
      lastPage: '648',
    ),
  ];

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
      .replaceAll(RegExp(r'[^a-zà-öø-ÿ0-9\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.length > 1)
      .toSet();

  static String _cleanSearchKeywords(String raw) {
    var current = _repairCompoundedBibliographyText(raw);
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
        .replaceAll(RegExp(r'[^a-zA-ZÀ-ÖØ-öø-ÿ0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2 && !stopWords.contains(w.toLowerCase()))
        .toList();

    if (words.isEmpty) return raw;
    return words.take(6).join(' ');
  }
}
