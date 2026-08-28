import 'dart:math' as math;

import 'language_id.dart';

/// 輸入預處理：斷句、斷詞與基礎統計。
/// 中日韓文字以標點斷句、逐字元計詞；其他語言以空白斷詞。
class PreprocessedText {
  static const int maxAnalysisChunkTokens = 120;
  static const int maxAnalysisChunkSentences = 5;

  final String raw;
  final String analysisText;
  final List<String> sentences;
  final List<List<String>> sentenceTokens;
  final List<String> analysisChunks;
  final List<int> sentenceChunkIndices;
  final List<List<int>> sentenceAnalysisChunkIndices;

  /// 文件語言，於預處理時辨識一次。四個引擎、校準查表與模型路由都需要它，
  /// 各自重算不但浪費，還可能因為傳入不同片段而得到不一致的結果。
  final DetectedLanguage language;

  PreprocessedText._(
    this.raw,
    this.analysisText,
    this.sentences,
    this.sentenceTokens,
    this.analysisChunks,
    this.sentenceChunkIndices,
    this.sentenceAnalysisChunkIndices,
    this.language,
  );

  factory PreprocessedText.from(String raw) {
    final normalized = raw.trim();
    final sentences = <String>[];
    final tokens = <List<String>>[];
    final analysisChunks = <String>[];
    final analysisParagraphs = <String>[];
    final sentenceChunkIndices = <int>[];
    final sentenceAnalysisChunkIndices = <List<int>>[];

    for (final paragraph in _reconstructParagraphs(normalized)) {
      final paragraphSentences = _splitSentences(
        paragraph,
      ).map(normalizeSentenceForAnalysis).where(isAnalyzableSentence).toList();
      if (paragraphSentences.isNotEmpty) {
        analysisParagraphs.add(paragraphSentences.join(' '));
      }
      var pendingSentences = <String>[];
      var pendingSentenceIndices = <int>[];
      var pendingTokenCount = 0;

      void flushChunk() {
        if (pendingSentences.isEmpty) return;
        final chunkIndex = analysisChunks.length;
        analysisChunks.add(pendingSentences.join(' '));
        for (final sentenceIndex in pendingSentenceIndices) {
          sentenceAnalysisChunkIndices[sentenceIndex].add(chunkIndex);
        }
        pendingSentences = <String>[];
        pendingSentenceIndices = <int>[];
        pendingTokenCount = 0;
      }

      for (final sentence in paragraphSentences) {
        final sentenceTokenList = _tokenize(sentence);
        final sentenceIndex = sentences.length;
        sentences.add(sentence);
        tokens.add(sentenceTokenList);
        sentenceAnalysisChunkIndices.add(<int>[]);

        final modelUnits = _splitLongAnalysisUnit(sentence);
        if (modelUnits.length > 1) {
          flushChunk();
          for (final unit in modelUnits) {
            final chunkIndex = analysisChunks.length;
            analysisChunks.add(unit);
            sentenceAnalysisChunkIndices[sentenceIndex].add(chunkIndex);
          }
          continue;
        }

        final exceedsSentenceLimit =
            pendingSentences.length >= maxAnalysisChunkSentences;
        final exceedsTokenLimit =
            pendingSentences.isNotEmpty &&
            pendingTokenCount + sentenceTokenList.length >
                maxAnalysisChunkTokens;
        if (exceedsSentenceLimit || exceedsTokenLimit) flushChunk();

        pendingSentences.add(sentence);
        pendingSentenceIndices.add(sentenceIndex);
        pendingTokenCount += sentenceTokenList.length;
      }
      // 不跨越原始段落合併，避免把不同主題的句子放進同一推論區塊。
      flushChunk();
    }

    sentenceChunkIndices.addAll(
      sentenceAnalysisChunkIndices.map((indices) => indices.first),
    );
    final analysisText = analysisParagraphs.join('\n\n');
    final language = detectLanguage(
      analysisText.isNotEmpty ? analysisText : normalized,
    );

    return PreprocessedText._(
      normalized,
      analysisText,
      sentences,
      tokens,
      analysisChunks,
      sentenceChunkIndices,
      sentenceAnalysisChunkIndices,
      language,
    );
  }

  /// 將段落區塊的神經模型分數映射回原始句序，供逐句報告與熱區圖使用。
  List<double> expandChunkScoresToSentences(List<double> chunkScores) {
    if (chunkScores.length != analysisChunks.length) {
      throw ArgumentError.value(
        chunkScores.length,
        'chunkScores',
        'Expected ${analysisChunks.length} analysis chunk scores',
      );
    }
    return sentenceAnalysisChunkIndices.map((indices) {
      final sum = indices.fold<double>(0, (value, index) {
        return value + chunkScores[index];
      });
      return sum / indices.length;
    }).toList();
  }

  /// 以文件段落為第一層邊界，重接 PDF/OCR 因版面寬度產生的硬換行。
  ///
  /// 部分 PDF 文字層會在每一視覺行之間插入空白行，因此空白行只能視為
  /// 「候選段落」而不是絕對句界。候選段落若呈現明確續寫（小寫開頭，或
  /// 中日文及無大小寫語系尚未出現句末標點），會在斷句前先接回原句。
  static List<String> _reconstructParagraphs(String text) {
    if (text.trim().isEmpty) return const [];
    final normalizedLineEndings = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n');
    final candidates = <({String text, bool hardBoundary})>[];
    for (final block in normalizedLineEndings.split(RegExp(r'\n[ \t]*\n+'))) {
      var pendingLines = <String>[];

      void flushPending() {
        final paragraph = _joinWrappedLines(pendingLines.join('\n'));
        if (paragraph.isNotEmpty) {
          candidates.add((text: paragraph, hardBoundary: false));
        }
        pendingLines = <String>[];
      }

      for (final rawLine in block.split('\n')) {
        final line = rawLine.trim();
        if (line.isEmpty || _isDiscardableLayoutLine(line)) continue;
        if (_isReliableDocumentBoundaryLine(line)) {
          flushPending();
          candidates.add((text: line, hardBoundary: true));
        } else {
          pendingLines.add(line);
        }
      }
      flushPending();
    }

    final paragraphs = <String>[];
    for (final candidate in candidates) {
      if (paragraphs.isNotEmpty &&
          _shouldMergeBibliographyBlocks(paragraphs.last, candidate.text)) {
        paragraphs[paragraphs.length - 1] = _joinTextRuns(
          paragraphs.last,
          candidate.text,
        );
      } else if (paragraphs.isNotEmpty &&
          !candidate.hardBoundary &&
          _shouldMergeExtractedBlocks(paragraphs.last, candidate.text)) {
        paragraphs[paragraphs.length - 1] = _joinTextRuns(
          paragraphs.last,
          candidate.text,
        );
      } else {
        paragraphs.add(candidate.text);
      }
    }
    return paragraphs;
  }

  static bool _shouldMergeBibliographyBlocks(String previous, String next) {
    final left = previous.trim();
    final right = next.trim();
    if (left.isEmpty || right.isEmpty) return false;
    if (_looksLikeBibliographyEntryStart(right)) return false;

    final leftIsBibliographic =
        _looksLikeBibliographyEntryStart(left) ||
        _looksLikeBibliographyContinuation(left) ||
        _looksLikeBibliographyEntryOrFragment(left);
    if (!leftIsBibliographic) return false;

    return _looksLikeBibliographyContinuation(right) ||
        _looksLikeBibliographyTitleFragment(right);
  }

  static bool _shouldMergeExtractedBlocks(String previous, String next) {
    final left = previous.trimRight();
    final right = next.trimLeft();
    if (left.isEmpty || right.isEmpty || _endsWithSentenceBoundary(left)) {
      return false;
    }
    if (_isReliableDocumentBoundaryLine(right) ||
        _looksLikeStructuralHeading(left) ||
        _looksLikeStructuralHeading(right)) {
      return false;
    }

    final first = right.substring(0, 1);
    if (RegExp(r'^[\p{Ll}]', unicode: true).hasMatch(first)) return true;
    if (RegExp(r'^[,，、;；:：)）\]】}"”’]', unicode: true).hasMatch(first)) {
      return true;
    }

    // 中文、日文、韓文、泰文、阿拉伯文、天城文等文字沒有可依賴的
    // 大小寫句首。以 Unicode 字母屬性判斷，可涵蓋未逐一列出的語系。
    return RegExp(r'^\p{L}', unicode: true).hasMatch(first) &&
        !RegExp(r'^[\p{Lu}\p{Lt}]', unicode: true).hasMatch(first);
  }

  static bool _isReliableDocumentBoundaryLine(String line) {
    if (RegExp(
      r'^(?:doi\s*:|keywords?\s*:|received\b|revised\b|accepted\b|published\b)',
      caseSensitive: false,
    ).hasMatch(line)) {
      return true;
    }
    return line.length <= 100 &&
        RegExp(
          r'^\d+(?:\.\d+)*[.)]?\s+[\p{L}]',
          unicode: true,
        ).hasMatch(line) &&
        !RegExp(r'[.!?。！？]\s+.+[.!?。！？]$').hasMatch(line);
  }

  static bool _isDiscardableLayoutLine(String line) {
    const months =
        r'(?:January|February|March|April|May|June|July|August|September|October|November|December)';
    if (RegExp(
      '^$months\\s+\\d{1,2},\\s+\\d{4}\\s+\\d{1,2}:\\d{2}\\b',
      caseSensitive: false,
    ).hasMatch(line)) {
      return true;
    }
    return RegExp(r'^\d{3,4}\s*[A-Z][A-Za-z.\s&]{2,40}$').hasMatch(line);
  }

  static String _withoutBibliographyPrefix(String text) {
    return text
        .replaceFirst(
          RegExp(r'^\s*(?:\[\s*\d{1,3}\s*\]|\(?\d{1,3}\)?[.)、．])\s*'),
          '',
        )
        .trim();
  }

  static bool _looksLikeBibliographyEntryStart(String text) {
    final cleaned = _withoutBibliographyPrefix(text);
    final authorInitial = RegExp(
      r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+,\s*(?:[A-Z]\.\s*){1,3}"
      r"(?:(?:,\s*|,\s*&\s*|,\s*and\s+|&\s*|and\s+)"
      r"[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+,\s*(?:[A-Z]\.\s*){1,3})*",
    );
    final authorNoComma = RegExp(
      r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s+(?:[A-Z]\.\s*){1,3}"
      r"(?:,\s*[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+\s+(?:[A-Z]\.\s*){1,3})*",
    );
    return authorInitial.hasMatch(cleaned) || authorNoComma.hasMatch(cleaned);
  }

  /// 書目定位特徵：年份、卷(期)頁碼、頁碼區間、DOI／arXiv／URL。
  ///
  /// 這是「這串文字是書目紀錄」與「這串文字只是剛好提到 review／research」
  /// 之間的分界。少了它，`_looksLikeBibliographyContinuation` 的裸詞表會把
  /// 任何含有 review、studies、research 的普通句子當成參考文獻續行。
  static bool _hasBibliographicLocator(String text) {
    if (RegExp(
      r'(?:doi\s*:|https?://|arxiv\s*:)',
      caseSensitive: false,
    ).hasMatch(text)) {
      return true;
    }
    // 卷(期), 起頁–迄頁
    if (RegExp(
      r'\b\d{1,4}\s*[(,]\s*\d{1,5}\s*[-–—]\s*\d{1,5}\b',
    ).hasMatch(text)) {
      return true;
    }
    // 結尾的頁碼區間
    if (RegExp(r'\b\d{1,5}\s*[-–—]\s*\d{1,5}\.?$').hasMatch(text)) {
      return true;
    }
    return RegExp(r'\b(?:18|19|20)\d\d[a-z]?\b').hasMatch(text);
  }

  static bool _looksLikeBibliographyContinuation(String text) {
    final cleaned = _withoutBibliographyPrefix(text);
    if (cleaned.isEmpty) return false;
    if (RegExp(
      r'^(?:doi\s*:|https?://|arxiv\s*:)',
      caseSensitive: false,
    ).hasMatch(cleaned)) {
      return true;
    }
    // 裸詞單獨不算數：review／research／studies 在一般散文裡太常見。
    // 必須同時具備年份、卷頁或 DOI 這類書目定位特徵才視為續行。
    if (RegExp(
      r'\b(?:journal|proceedings|transactions|studies|economics|review|'
      r'letters|research|conference|press|publisher)\b',
      caseSensitive: false,
    ).hasMatch(cleaned)) {
      if (_hasBibliographicLocator(cleaned)) return true;
    }
    if (RegExp(
      r'\b\d{1,4}\s*[(,]\s*\d{1,5}\s*[-–—]\s*\d{1,5}\b',
    ).hasMatch(cleaned)) {
      return true;
    }
    if (RegExp(r'\b\d{1,5}\s*[-–—]\s*\d{1,5}\.?$').hasMatch(cleaned) &&
        RegExp(r'\b\d{1,4}\b').hasMatch(cleaned)) {
      return true;
    }
    if (RegExp(r'\b(?:18|19|20)\d\d[a-z]?[).,]?\s*$').hasMatch(cleaned)) {
      return true;
    }
    return _looksLikeBibliographyTitleFragment(cleaned);
  }

  static bool _looksLikeBibliographyTitleFragment(String text) {
    final cleaned = _withoutBibliographyPrefix(text);
    if (!_endsWithSentenceBoundary(cleaned)) return false;
    final tokenCount = _tokenize(cleaned).length;
    if (tokenCount < 4 || tokenCount > 22) return false;
    final hasTitleColon = RegExp(r'[:：]').hasMatch(cleaned);
    final hasFiniteVerb = RegExp(
      r'\b(?:am|is|are|was|were|be|been|being|has|have|had|do|does|did|'
      r'can|could|may|might|must|shall|should|will|would|'
      r'argues?|claims?|shows?|finds?|reports?|suggests?|indicates?|'
      r'demonstrates?|reveals?|concludes?)\b',
      caseSensitive: false,
    ).hasMatch(cleaned);
    final hasTitleKeyword = RegExp(
      r'\b(?:impact|effect|role|intention|performance|recognition|'
      r'advertising|consumer|consumers|products|robots|exchange|'
      r'generative|deepfake|stereoscopic|presence)\b',
      caseSensitive: false,
    ).hasMatch(cleaned);
    // 「沒有限定動詞」原本是硬性條件，但那描述的是一大片普通名詞句。
    // 改為加分項：沒有動詞時，單一標題特徵即可；有動詞時要求兩項都命中。
    return hasFiniteVerb
        ? (hasTitleColon && hasTitleKeyword)
        : (hasTitleColon || hasTitleKeyword);
  }

  static String _joinWrappedLines(String paragraph) {
    final lines = paragraph
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty) return '';

    final buffer = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].replaceAll('\u00ad', '');

      // PDF 上標註腳常被抽成獨立的一行；保留在正文只會破壞句法與統計。
      if (_isIsolatedCitationMarker(lines, i)) {
        continue;
      }

      // 欄寬或字型定位偶爾會把單字首字母單獨抽出，例如 C\nircular。
      if (RegExp(r'^[A-Za-z]$').hasMatch(line) && i + 1 < lines.length) {
        final next = lines[i + 1].trim();
        if (RegExp(r'^[a-z]').hasMatch(next)) {
          line += next;
          i++;
        }
      }

      if (buffer.isNotEmpty && _needsWrapSpace(buffer.toString(), line)) {
        buffer.write(' ');
      }
      buffer.write(line);
    }
    return buffer.toString().replaceAll(RegExp(r'[ \t]+'), ' ').trim();
  }

  static String _joinTextRuns(String previous, String next) {
    final left = previous.trimRight();
    final right = next.trimLeft();
    return _needsWrapSpace(left, right) ? '$left $right' : '$left$right';
  }

  static bool _needsWrapSpace(String previous, String next) {
    if (previous.isEmpty || next.isEmpty) return false;
    final joinsHyphenatedWord =
        RegExp(r'[\p{L}]-$', unicode: true).hasMatch(previous) &&
        RegExp(r'^[\p{Ll}]', unicode: true).hasMatch(next);
    if (joinsHyphenatedWord) return false;
    if (RegExp(r'[（(「『【\[〈《]$').hasMatch(previous) ||
        RegExp(r'^[，。！？、；：,.!?;:）)」』】\]〉》]').hasMatch(next)) {
      return false;
    }

    // 漢字、假名、泰文、高棉文與寮文的版面折行不代表詞間空白。
    const noSpaceScripts =
        r'\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}'
        r'\p{Script=Thai}\p{Script=Lao}\p{Script=Khmer}';
    return !(RegExp('[$noSpaceScripts]\$', unicode: true).hasMatch(previous) &&
        RegExp('^[$noSpaceScripts]', unicode: true).hasMatch(next));
  }

  static bool _isIsolatedCitationMarker(List<String> lines, int index) {
    if (index == 0 || index >= lines.length - 1) return false;
    if (!RegExp(r'^\d{1,3}(?:\s*,\s*\d{1,3})*$').hasMatch(lines[index])) {
      return false;
    }
    final hasLetters = RegExp(r'[\p{L}]', unicode: true);
    return hasLetters.hasMatch(lines[index - 1]) &&
        hasLetters.hasMatch(lines[index + 1]);
  }

  static List<String> _splitSentences(String text) {
    final normalized = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return const [];

    final sentences = <String>[];
    var start = 0;
    var index = 0;
    while (index < normalized.length) {
      if (!_isSentenceBoundary(normalized, index)) {
        index++;
        continue;
      }

      var end = index + 1;
      while (end < normalized.length && _isSentenceMark(normalized, end)) {
        end++;
      }
      while (end < normalized.length &&
          RegExp(r'''["'”’»›」』）)\]】〕〗〙〛〉》]''').hasMatch(normalized[end])) {
        end++;
      }

      final sentence = normalized.substring(start, end).trim();
      if (sentence.isNotEmpty) sentences.add(sentence);
      while (end < normalized.length && normalized[end].trim().isEmpty) {
        end++;
      }
      start = end;
      index = end;
    }

    final tail = normalized.substring(start).trim();
    if (tail.isNotEmpty) sentences.add(tail);
    return sentences;
  }

  static bool _isSentenceBoundary(String text, int index) {
    final mark = text[index];
    if ('。｡！？!?؟۔։՜՞።፧।॥။'.contains(mark)) return true;
    if (mark == '…') {
      var nextIndex = index + 1;
      while (nextIndex < text.length && text[nextIndex] == '…') {
        nextIndex++;
      }
      while (nextIndex < text.length && text[nextIndex].trim().isEmpty) {
        nextIndex++;
      }
      return nextIndex >= text.length ||
          RegExp(
            r'[\p{Lu}\p{Script=Han}\p{Script=Hiragana}'
            r'\p{Script=Katakana}\p{Script=Hangul}]',
            unicode: true,
          ).hasMatch(text[nextIndex]);
    }
    if (mark == ';' &&
        RegExp(r'[\p{Script=Greek}]', unicode: true).hasMatch(text)) {
      return true;
    }
    if (mark != '.') return false;

    final previous = index > 0 ? text[index - 1] : '';
    final next = index + 1 < text.length ? text[index + 1] : '';
    if (RegExp(r'\d').hasMatch(previous) && RegExp(r'\d').hasMatch(next)) {
      return false;
    }
    if (next == '.') return false;
    if (next.isNotEmpty &&
        next.trim().isNotEmpty &&
        !RegExp(r'''["'”’」』）)\]]''').hasMatch(next)) {
      return false;
    }

    final prefix = text.substring(0, index + 1);
    final tokenMatch = RegExp(r'([A-Za-z][A-Za-z.]*)\.$').firstMatch(prefix);
    final token = tokenMatch?.group(1)?.toLowerCase() ?? '';
    final dottedToken = tokenMatch?.group(0)?.toLowerCase() ?? '';
    final atEnd = index == text.length - 1;
    if (atEnd) return true;

    const neverTerminal = {
      'mr',
      'mrs',
      'ms',
      'dr',
      'prof',
      'fig',
      'figs',
      'eq',
      'eqs',
      'no',
      'nos',
      'vol',
      'vols',
      'pp',
      'p',
      'sec',
      'secs',
      'ch',
      'approx',
      'vs',
      'cf',
      'dept',
      'univ',
      'inc',
      'ltd',
    };
    if (neverTerminal.contains(token)) return false;
    if (const {'e.g.', 'i.e.', 'a.k.a.'}.contains(dottedToken)) return false;
    if (RegExp(r'^(?:[a-z]\.){2,}$').hasMatch(dottedToken)) return false;

    var nextIndex = index + 1;
    while (nextIndex < text.length && text[nextIndex].trim().isEmpty) {
      nextIndex++;
    }
    if (nextIndex >= text.length) return true;
    final nextVisible = text[nextIndex];

    // 單一姓名縮寫（W. M. Yang）與句中 et al. 不應被切開。
    if (token.length == 1 && RegExp(r'[A-Z]').hasMatch(nextVisible)) {
      return false;
    }
    if (token == 'al' && !RegExp(r'[A-Z一-鿿]').hasMatch(nextVisible)) {
      return false;
    }

    return true;
  }

  static bool _isSentenceMark(String text, int index) {
    final mark = text[index];
    return mark == '.' || _isSentenceBoundary(text, index);
  }

  static bool _endsWithSentenceBoundary(String text) {
    final stripped = text.replaceFirst(
      RegExp(r'''[\s"'”’»›」』）)\]】〕〗〙〛〉》]+$'''),
      '',
    );
    return stripped.isNotEmpty &&
        _isSentenceBoundary(stripped, stripped.length - 1);
  }

  /// 完整句子是使用者可讀的證據單位；模型 token 上限只影響內部分片。
  static List<String> _splitLongAnalysisUnit(String sentence) {
    if (_tokenize(sentence).length <= maxAnalysisChunkTokens) {
      return [sentence];
    }

    final isCjk = RegExp(r'[一-鿿぀-ヿ가-힯]').hasMatch(sentence);
    final units = isCjk ? sentence.split('') : sentence.split(RegExp(r'\s+'));
    final chunks = <String>[];
    var pending = <String>[];
    var pendingTokens = 0;

    void flush() {
      if (pending.isEmpty) return;
      chunks.add(isCjk ? pending.join() : pending.join(' '));
      pending = <String>[];
      pendingTokens = 0;
    }

    for (final unit in units) {
      final count = _tokenize(unit).length;
      if (pending.isNotEmpty &&
          pendingTokens + count > maxAnalysisChunkTokens) {
        flush();
      }
      pending.add(unit);
      pendingTokens += count;
    }
    flush();
    return chunks;
  }

  /// 判斷一段斷句是否有足夠語義內容可做 AI 句級判讀。
  ///
  /// PDF/OCR 來源常會產生 `J.`、`S.`、`C.`、頁碼、章節序號、章節標題、
  /// 表格/目錄列或引用殘片。這些片段不能可靠代表作者寫作風格，應排除在
  /// 句級判讀、可疑句子排名與匯出報表之外。
  static bool isAnalyzableSentence(String sentence) {
    final trimmed = normalizeSentenceForAnalysis(sentence);
    if (trimmed.isEmpty) return false;
    if (RegExp(r'^[A-Za-z]\.$').hasMatch(trimmed)) return false;
    if (RegExp(r'^[A-Za-z]{1,2}$').hasMatch(trimmed)) return false;
    if (RegExp(r'^\d{1,4}[.)、]?$').hasMatch(trimmed)) return false;
    if (RegExp(r'^[,，;；:：)\]）]+\s*\d{4}[.)）]?$').hasMatch(trimmed)) {
      return false;
    }
    if (RegExp(
      r'^(?:doi\s*:|keywords?\s*:|received\b|revised\b|accepted\b|published\b)',
      caseSensitive: false,
    ).hasMatch(trimmed)) {
      return false;
    }
    if (RegExp(r'\bdoi\s*:', caseSensitive: false).hasMatch(trimmed)) {
      return false;
    }
    if (RegExp(
          r'\b(?:international journal|publishing company|department of|university|issn|copyright)\b',
          caseSensitive: false,
        ).hasMatch(trimmed) &&
        !RegExp(
          r'\b(is|are|was|were|has|have|shows?|finds?|reports?)\b',
          caseSensitive: false,
        ).hasMatch(trimmed)) {
      return false;
    }
    // 句子層是孤立判斷，沒有「前一段已是書目」這種上下文佐證，因此門檻要高：
    // 除非開頭就是作者樣式，否則必須帶有書目定位特徵才排除。否則一句剛好
    // 含 review 的普通內文會被整句刪掉，統計引擎連句長起伏都算不出來。
    if (_looksLikeBibliographyEntryOrFragment(trimmed) &&
        (_looksLikeBibliographyEntryStart(trimmed) ||
            _hasBibliographicLocator(trimmed))) {
      return false;
    }
    if (_looksLikeStructuralHeading(trimmed)) return false;
    if (_looksLikeTableRow(trimmed)) return false;
    if (!_endsWithSentenceBoundary(trimmed) &&
        _endsWithIncompleteConnector(trimmed)) {
      return false;
    }

    final tokens = _tokenize(trimmed);
    if (tokens.length < 4) return false;

    final lettersAndNumbers = RegExp(
      r'[\p{L}\p{N}]',
      unicode: true,
    ).allMatches(trimmed).length;
    if (lettersAndNumbers < 4) return false;

    final wordLikeTokens = RegExp(
      r'[\p{L}\p{M}]{2,}',
      unicode: true,
    ).allMatches(trimmed).length;
    final cjkLikeChars = RegExp(r'[一-鿿぀-ヿ가-힯]').allMatches(trimmed).length;
    final hasSentencePunctuation = _endsWithSentenceBoundary(trimmed);
    final hasClausePunctuation = RegExp(r'[，,、：:]').hasMatch(trimmed);

    if (cjkLikeChars == 0 && wordLikeTokens < 5 && !hasSentencePunctuation) {
      return false;
    }
    if (cjkLikeChars > 0 && cjkLikeChars < 6) {
      return false;
    }
    if (cjkLikeChars > 0 &&
        cjkLikeChars < 12 &&
        !hasSentencePunctuation &&
        !hasClausePunctuation) {
      return false;
    }

    return true;
  }

  static bool _looksLikeBibliographyEntryOrFragment(String text) {
    final cleaned = _withoutBibliographyPrefix(text);
    if (cleaned.isEmpty) return false;
    if (_looksLikeBibliographyEntryStart(cleaned)) return true;
    if (_looksLikeBibliographyContinuation(cleaned)) return true;
    if (RegExp(
      r"^[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+,\s*(?:[A-Z]\.\s*){1,3}"
      r"(?:,\s*&\s*[A-Z][A-Za-zÀ-ÖØ-öø-ÿ'\-]+,\s*(?:[A-Z]\.\s*){1,3})?"
      r"\.?$",
    ).hasMatch(cleaned)) {
      return true;
    }
    return false;
  }

  static bool _looksLikeTableRow(String text) {
    final numbers = RegExp(
      r'(?<![\p{L}])\d+(?:[.,]\d+)*(?![\p{L}])',
      unicode: true,
    ).allMatches(text).length;
    if (numbers < 6) return false;
    final words = RegExp(r'[\p{L}]{2,}', unicode: true).allMatches(text).length;
    return numbers / math.max(1, numbers + words) >= 0.30;
  }

  static bool _endsWithIncompleteConnector(String text) {
    if (RegExp(r'[,，、;；:：/\-–—]$').hasMatch(text)) return true;
    final lastWord = RegExp(
      r'([\p{L}]+)[\s\u00a0]*$',
      unicode: true,
    ).firstMatch(text)?.group(1)?.toLowerCase();
    if (lastWord == null) return false;
    const danglingWords = {
      // Germanic / Romance languages.
      'a', 'an', 'the', 'of', 'to', 'for', 'from', 'with', 'without', 'by',
      'and', 'or', 'but', 'because', 'if', 'when', 'while', 'that', 'which',
      'de', 'del', 'la', 'el', 'los', 'las', 'para', 'por', 'con', 'sin',
      'y', 'o', 'que', 'du', 'des', 'avec', 'sans', 'et', 'ou', 'von',
      'zu', 'mit', 'ohne', 'und', 'oder', 'do', 'da', 'dos', 'das', 'com',
      'sem', 'e', 'di', 'della', 'delle', 'che',
      // Chinese / Japanese / Korean and Indic connectors.
      '的', '與', '和', '及', '或', '在', '由', '對', '為', '因為', '如果',
      '當', '而', '但', '並', '以及', 'について', 'により', '및', '또는',
      'और', 'या', 'के', 'की', 'का', 'से', 'में', 'पर',
    };
    return danglingWords.contains(lastWord);
  }

  /// 移除 OCR/PDF 常見的前導項次，但保留真正句子本體。
  static String normalizeSentenceForAnalysis(String sentence) {
    var text = sentence
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^[\u2022·●○◆◇▪▫\-–—]+\s*'), '')
        .trim();

    text = text.replaceFirst(
      RegExp(r'^(?:\(?\d{1,3}(?:\.\d{1,3})*\)?|[一二三四五六七八九十]+)[.)、．]\s+'),
      '',
    );
    text = text.replaceFirst(
      RegExp(r'^\d{1,3}\s+(?=[\p{L}])', unicode: true),
      '',
    );
    return text.trim();
  }

  static bool _looksLikeStructuralHeading(String text) {
    final withoutTrailingPage = text
        .replaceFirst(RegExp(r'\s+\d{1,4}[.)、．]?$'), '')
        .trim();
    final normalized = withoutTrailingPage
        .replaceAll(RegExp(r'[\s　]+'), ' ')
        .replaceAll(RegExp(r'[()（）]'), '')
        .toLowerCase();

    if (normalized.isEmpty) return true;
    if (RegExp(
      r'^(第[一二三四五六七八九十百\d]+[章節篇部]|chapter \d+)',
    ).hasMatch(normalized)) {
      return true;
    }

    const headingWords = {
      'abstract',
      'introduction',
      'literature review',
      'methodology',
      'methods',
      'results',
      'discussion',
      'conclusion',
      'references',
      'appendix',
      '摘要',
      '緒論',
      '前言',
      '研究背景',
      '研究背景與動機',
      '文獻探討',
      '研究方法',
      '研究結果',
      '結論',
      '參考文獻',
      '附錄',
    };
    if (headingWords.contains(normalized)) return true;
    for (final heading in headingWords) {
      final cjkHeading = RegExp(r'[一-鿿]').hasMatch(heading);
      if ((cjkHeading
              ? normalized.startsWith(heading)
              : normalized.startsWith('$heading ')) &&
          withoutTrailingPage.length <= 100) {
        return true;
      }
    }

    final hasSentenceVerbOrClause = RegExp(
      r'(是|為|有|能|會|可|已|將|使|讓|指出|認為|發現|'
      r'\b(is|are|was|were|be|been|being|has|have|had|do|does|did|'
      r'can|could|may|might|will|would|should|suggests?|shows?|finds?)\b)',
      caseSensitive: false,
    ).hasMatch(normalized);
    final hasTerminalSentencePunctuation = _endsWithSentenceBoundary(
      withoutTrailingPage,
    );
    final tokenCount = _tokenize(withoutTrailingPage).length;

    if (!hasTerminalSentencePunctuation &&
        !hasSentenceVerbOrClause &&
        tokenCount <= 10 &&
        withoutTrailingPage.length <= 80) {
      return true;
    }

    final hasBilingualTitleMarker = RegExp(
      r'[（(][^）)]{3,}[）)]',
    ).hasMatch(withoutTrailingPage);
    if (!hasTerminalSentencePunctuation &&
        hasBilingualTitleMarker &&
        !hasSentenceVerbOrClause &&
        withoutTrailingPage.length <= 100) {
      return true;
    }

    final titleProbe = hasTerminalSentencePunctuation
        ? withoutTrailingPage.substring(0, withoutTrailingPage.length - 1)
        : withoutTrailingPage;
    final titleWords = RegExp(r'[A-Za-z]{2,}').allMatches(titleProbe).toList();
    final capitalizedTitleWords = titleWords
        .where((m) => RegExp(r'^[A-Z][a-z]+$').hasMatch(m.group(0)!))
        .length;
    final mostlyTitleCase =
        titleWords.length >= 4 &&
        capitalizedTitleWords / titleWords.length >= 0.65;
    if (mostlyTitleCase && !hasSentenceVerbOrClause && tokenCount <= 12) {
      return true;
    }

    return false;
  }

  static List<String> _tokenize(String sentence) {
    final cjk = RegExp(r'[一-鿿぀-ヿ가-힯]');
    if (cjk.hasMatch(sentence)) {
      // CJK：以單一字元為 token（去除標點與空白）
      return sentence
          .split('')
          .where((c) => RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(c))
          .toList();
    }
    return sentence
        .toLowerCase()
        .split(RegExp(r'[^\p{L}\p{M}\p{N}]+', unicode: true))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  List<String> get allTokens => sentenceTokens.expand((t) => t).toList();

  /// 句長列表（詞數）
  List<int> get sentenceLengths => sentenceTokens.map((t) => t.length).toList();

  /// Type-Token Ratio：詞彙多樣性。
  ///
  /// **強烈受長度影響**，不適合用固定門檻判讀：同一篇英文論文，
  /// 取前 15% 時為 0.584、全文時為 0.405。文件愈長，重複用詞的機會愈多，
  /// 比值必然下降。若拿固定門檻套用，判定會隨文件長度漂移而與內容無關。
  /// 需要跨文件比較時請改用 [movingAverageTypeTokenRatio]。
  double get typeTokenRatio {
    final tokens = allTokens;
    if (tokens.isEmpty) return 0;
    return tokens.toSet().length / tokens.length;
  }

  /// MATTR 的滑動窗口長度（詞元數）。
  ///
  /// 取 100 是文獻上的常見值：夠長到能反映用詞多樣性，又夠短到讓多數
  /// 可分析的文件都至少涵蓋一個完整窗口。
  static const int mattrWindow = 100;

  /// Moving-Average Type-Token Ratio：長度不變的詞彙多樣性。
  ///
  /// 在固定長度的窗口內計算 TTR 再取平均，因此與文件總長度無關——
  /// 這是它能用固定門檻、而 [typeTokenRatio] 不能的原因。
  ///
  /// 詞元數不足一個窗口時退回 [typeTokenRatio]：此時兩者等價，
  /// 但呼叫端仍應注意短文本的比值本來就偏高。
  double get movingAverageTypeTokenRatio {
    final tokens = allTokens;
    if (tokens.length <= mattrWindow) return typeTokenRatio;
    var sum = 0.0;
    var windows = 0;
    for (var start = 0; start + mattrWindow <= tokens.length; start++) {
      final window = tokens.sublist(start, start + mattrWindow);
      sum += window.toSet().length / mattrWindow;
      windows++;
    }
    return windows == 0 ? typeTokenRatio : sum / windows;
  }

  /// Burstiness：句長變異係數（人類寫作節奏起伏大 → 值高；AI 均勻 → 值低）
  double get burstiness {
    final lengths = sentenceLengths.where((l) => l > 0).toList();
    if (lengths.length < 2) return 0;
    final mean = lengths.reduce((a, b) => a + b) / lengths.length;
    if (mean == 0) return 0;
    final variance =
        lengths.map((l) => math.pow(l - mean, 2)).reduce((a, b) => a + b) /
        lengths.length;
    return math.sqrt(variance) / mean;
  }

  /// 詞頻分佈的 Shannon entropy（bits/token）
  double get entropy {
    final tokens = allTokens;
    if (tokens.isEmpty) return 0;
    final freq = <String, int>{};
    for (final t in tokens) {
      freq[t] = (freq[t] ?? 0) + 1;
    }
    var h = 0.0;
    for (final count in freq.values) {
      final p = count / tokens.length;
      h -= p * (math.log(p) / math.ln2);
    }
    return h;
  }
}
