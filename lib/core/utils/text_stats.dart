import 'dart:math' as math;

/// 輸入預處理：斷句、斷詞與基礎統計。
/// 中日韓文字以標點斷句、逐字元計詞；其他語言以空白斷詞。
class PreprocessedText {
  static const int maxAnalysisChunkTokens = 120;
  static const int maxAnalysisChunkSentences = 5;

  final String raw;
  final List<String> sentences;
  final List<List<String>> sentenceTokens;
  final List<String> analysisChunks;
  final List<int> sentenceChunkIndices;

  PreprocessedText._(
    this.raw,
    this.sentences,
    this.sentenceTokens,
    this.analysisChunks,
    this.sentenceChunkIndices,
  );

  factory PreprocessedText.from(String raw) {
    final normalized = raw.trim();
    final sentences = <String>[];
    final tokens = <List<String>>[];
    final analysisChunks = <String>[];
    final sentenceChunkIndices = <int>[];

    for (final paragraph in normalized.split(RegExp(r'\n\s*\n+'))) {
      final paragraphSentences = _splitSentences(
        paragraph,
      ).map(normalizeSentenceForAnalysis).where(isAnalyzableSentence).toList();
      var pendingSentences = <String>[];
      var pendingTokenCount = 0;

      void flushChunk() {
        if (pendingSentences.isEmpty) return;
        final chunkIndex = analysisChunks.length;
        analysisChunks.add(pendingSentences.join(' '));
        sentenceChunkIndices.addAll(
          List<int>.filled(pendingSentences.length, chunkIndex),
        );
        pendingSentences = <String>[];
        pendingTokenCount = 0;
      }

      for (final sentence in paragraphSentences) {
        final sentenceTokenList = _tokenize(sentence);
        final exceedsSentenceLimit =
            pendingSentences.length >= maxAnalysisChunkSentences;
        final exceedsTokenLimit =
            pendingSentences.isNotEmpty &&
            pendingTokenCount + sentenceTokenList.length >
                maxAnalysisChunkTokens;
        if (exceedsSentenceLimit || exceedsTokenLimit) flushChunk();

        sentences.add(sentence);
        tokens.add(sentenceTokenList);
        pendingSentences.add(sentence);
        pendingTokenCount += sentenceTokenList.length;
      }
      // 不跨越原始段落合併，避免把不同主題的句子放進同一推論區塊。
      flushChunk();
    }

    return PreprocessedText._(
      normalized,
      sentences,
      tokens,
      analysisChunks,
      sentenceChunkIndices,
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
    return sentenceChunkIndices.map((index) => chunkScores[index]).toList();
  }

  static List<String> _splitSentences(String text) {
    final parts = text
        .split(RegExp(r'(?<=[.!?。！？；;\n])\s*'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts;
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
    if (_looksLikeStructuralHeading(trimmed)) return false;

    final tokens = _tokenize(trimmed);
    if (tokens.length < 4) return false;

    final lettersAndNumbers = RegExp(
      r'[\p{L}\p{N}]',
      unicode: true,
    ).allMatches(trimmed).length;
    if (lettersAndNumbers < 4) return false;

    final wordLikeTokens = RegExp(
      r'[\p{L}]{2,}',
      unicode: true,
    ).allMatches(trimmed).length;
    final cjkLikeChars = RegExp(r'[一-鿿぀-ヿ가-힯]').allMatches(trimmed).length;
    final hasSentencePunctuation = RegExp(r'[。！？!?；;.]$').hasMatch(trimmed);
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
    final hasTerminalSentencePunctuation = RegExp(
      r'[。！？!?；;.]$',
    ).hasMatch(withoutTrailingPage);
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

    final titleProbe = withoutTrailingPage.replaceFirst(
      RegExp(r'[.!?。！？]+$'),
      '',
    );
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
        .split(RegExp(r'[^\p{L}\p{N}]+', unicode: true))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  List<String> get allTokens => sentenceTokens.expand((t) => t).toList();

  /// 句長列表（詞數）
  List<int> get sentenceLengths => sentenceTokens.map((t) => t.length).toList();

  /// Type-Token Ratio：詞彙多樣性
  double get typeTokenRatio {
    final tokens = allTokens;
    if (tokens.isEmpty) return 0;
    return tokens.toSet().length / tokens.length;
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
