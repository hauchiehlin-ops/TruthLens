import 'dart:math' as math;

/// 輸入預處理：斷句、斷詞與基礎統計。
/// 中日韓文字以標點斷句、逐字元計詞；其他語言以空白斷詞。
class PreprocessedText {
  final String raw;
  final List<String> sentences;
  final List<List<String>> sentenceTokens;

  PreprocessedText._(this.raw, this.sentences, this.sentenceTokens);

  factory PreprocessedText.from(String raw) {
    final normalized = raw.trim();
    final sentences = _splitSentences(normalized);
    final tokens = sentences.map(_tokenize).toList();
    return PreprocessedText._(normalized, sentences, tokens);
  }

  static List<String> _splitSentences(String text) {
    final parts = text
        .split(RegExp(r'(?<=[.!?。！？；;\n])\s*'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return parts;
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
  List<int> get sentenceLengths =>
      sentenceTokens.map((t) => t.length).toList();

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
