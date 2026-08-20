/// 目前文件與使用者提供之前一版草稿的演化比較。
///
/// 只比較兩份文件的結構與詞彙保留程度，不推測作者。大面積替換值得詢問，
/// 但可能來自正常重寫、編輯協作或格式轉換，不能直接等同 AI。
library;

enum RevisionPattern {
  unavailable,
  incremental,
  largeReplacement,
  nearDuplicate,
  mixed,
}

class RevisionEvidence {
  final RevisionPattern pattern;
  final double shingleSimilarity;
  final int previousWords;
  final int currentWords;

  const RevisionEvidence({
    this.pattern = RevisionPattern.unavailable,
    this.shingleSimilarity = 0,
    this.previousWords = 0,
    this.currentWords = 0,
  });

  static const RevisionEvidence none = RevisionEvidence();
  bool get hasData => pattern != RevisionPattern.unavailable;
  bool get indicatesLargeReplacement =>
      pattern == RevisionPattern.largeReplacement;

  factory RevisionEvidence.compare(String previous, String current) {
    final before = _tokens(previous);
    final after = _tokens(current);
    if (before.length < 80 || after.length < 80) return none;
    final a = _shingles(before);
    final b = _shingles(after);
    final union = a.union(b).length;
    final similarity = union == 0 ? 0.0 : a.intersection(b).length / union;
    final sizeRatio = after.length / before.length;
    final pattern = similarity >= 0.90
        ? RevisionPattern.nearDuplicate
        : similarity < 0.18 && sizeRatio >= 0.55 && sizeRatio <= 1.80
        ? RevisionPattern.largeReplacement
        : similarity >= 0.40 && sizeRatio >= 0.65 && sizeRatio <= 1.55
        ? RevisionPattern.incremental
        : RevisionPattern.mixed;
    return RevisionEvidence(
      pattern: pattern,
      shingleSimilarity: similarity,
      previousWords: before.length,
      currentWords: after.length,
    );
  }

  static List<String> _tokens(String text) => RegExp(
    r'[A-Za-zÀ-ɏ]+[0-9]*|[一-鿿]',
    unicode: true,
  ).allMatches(text.toLowerCase()).map((match) => match.group(0)!).toList();

  static Set<String> _shingles(List<String> tokens) {
    const width = 5;
    if (tokens.length < width) return {tokens.join(' ')};
    return {
      for (var i = 0; i + width <= tokens.length; i++)
        tokens.sublist(i, i + width).join('\u0001'),
    };
  }
}
