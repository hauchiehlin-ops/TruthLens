/// 文件與使用者提供之任務要求的契合度檢查。
///
/// 這不是作者身分判定。它只回答文件是否涵蓋題目中的核心概念與可機械檢查的
/// 字數要求；偏離題目可能來自誤解、離題或代寫，原因仍需由人釐清。
library;

enum TaskAlignmentRisk { unknown, low, medium, high }

class TaskAlignment {
  final int promptTermCount;
  final int coveredTermCount;
  final List<String> missingTerms;
  final int? minimumWords;
  final int documentWords;

  const TaskAlignment({
    this.promptTermCount = 0,
    this.coveredTermCount = 0,
    this.missingTerms = const [],
    this.minimumWords,
    this.documentWords = 0,
  });

  static const TaskAlignment none = TaskAlignment();

  bool get hasData => promptTermCount >= 4 || minimumWords != null;
  double get conceptCoverage =>
      promptTermCount == 0 ? 0 : coveredTermCount / promptTermCount;
  bool get missesWordMinimum =>
      minimumWords != null && documentWords < minimumWords!;

  TaskAlignmentRisk get risk {
    if (!hasData) return TaskAlignmentRisk.unknown;
    if (missesWordMinimum || (promptTermCount >= 4 && conceptCoverage < 0.25)) {
      return TaskAlignmentRisk.high;
    }
    if (promptTermCount >= 4 && conceptCoverage < 0.50) {
      return TaskAlignmentRisk.medium;
    }
    return TaskAlignmentRisk.low;
  }

  factory TaskAlignment.analyze(String prompt, String document) {
    if (prompt.trim().isEmpty) return none;
    final promptTerms = _terms(prompt);
    final documentTerms = _terms(document);
    final covered = promptTerms.where(documentTerms.contains).toSet();
    final missing = promptTerms
        .where((term) => !covered.contains(term))
        .take(8)
        .toList();
    return TaskAlignment(
      promptTermCount: promptTerms.length,
      coveredTermCount: covered.length,
      missingTerms: missing,
      minimumWords: _minimumWords(prompt),
      documentWords: _countWords(document),
    );
  }

  static Set<String> _terms(String text) {
    final terms = <String>{};
    for (final match in RegExp(
      r'[A-Za-zÀ-ɏ]{3,}',
      unicode: true,
    ).allMatches(text.toLowerCase())) {
      final word = match.group(0)!;
      if (!_stopWords.contains(word)) terms.add(word);
    }
    for (final match in RegExp(r'[一-鿿]{2,}').allMatches(text)) {
      final run = match.group(0)!;
      for (var i = 0; i + 1 < run.length; i++) {
        final pair = run.substring(i, i + 2);
        if (!_cjkStopTerms.contains(pair)) terms.add(pair);
      }
    }
    return terms;
  }

  static int _countWords(String text) {
    final cjk = RegExp(r'[一-鿿぀-ヿ가-힯]').allMatches(text).length;
    final latin = RegExp(r'[A-Za-zÀ-ɏ]+').allMatches(text).length;
    return cjk + latin;
  }

  static int? _minimumWords(String prompt) {
    final patterns = [
      RegExp(
        r'(?:at least|minimum(?: of)?)\s*(\d{2,5})\s*words?',
        caseSensitive: false,
      ),
      RegExp(r'(?:至少|不得少於|不低於)\s*(\d{2,5})\s*(?:字|詞|个字|個字)'),
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(prompt);
      final value = match == null ? null : int.tryParse(match.group(1)!);
      if (value != null) return value;
    }
    return null;
  }

  static const Set<String> _stopWords = {
    'the',
    'and',
    'for',
    'with',
    'from',
    'this',
    'that',
    'your',
    'you',
    'write',
    'essay',
    'paper',
    'words',
    'word',
    'about',
    'into',
    'using',
    'include',
    'must',
    'should',
    'please',
    'between',
    'than',
    'each',
    'have',
    'will',
  };

  static const Set<String> _cjkStopTerms = {
    '請撰',
    '撰寫',
    '文章',
    '一篇',
    '內容',
    '說明',
    '至少',
    '不得',
    '字數',
    '並且',
    '以及',
    '使用',
    '包含',
    '請以',
    '進行',
    '分析',
  };
}
