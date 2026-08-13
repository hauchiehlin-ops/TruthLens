/// 全平台通用 OCR 文字後處理工具。
///
/// 修正各平台 OCR 引擎（Apple Vision, ML Kit, Windows Media OCR, Gemini Vision）常見的缺陷：
/// 1. 中文/日文/韓文（CJK）字元邊界多餘空格消除（例如 `這 是 一 個 範 例` → `這是一個範例`）。
/// 2. 標點符號與 CJK 字元之間的空隙清理。
/// 3. 英文單字結尾跨行連字號還原（例如 `environ-\nment` → `environment`）。
/// 4. 學術文獻常見 PDF/OCR 擠壓修復（例如 `Journalof`、`Stabilityofa`、`ina`）。
/// 5. Gemini/視覺模型常見 Markdown 包裹與 Unicode 字形正規化。
/// 6. 多餘空白行清理與自然段落格式化。
class OcrPostProcessor {
  // CJK 字元範圍：中文 (4E00-9FFF, 3400-4DBF), 日文平假名/片假名 (3040-30FF), 韓文 (AC00-D7AF)
  static final RegExp _cjkToCjkSpace = RegExp(
    r'([\u4e00-\u9fa5\u3040-\u30ff\u3400-\u4dbf\uac00-\ud7af])[ \t\r\f]+([\u4e00-\u9fa5\u3040-\u30ff\u3400-\u4dbf\uac00-\ud7af])',
  );

  // CJK 與中文全形標點符號間的空格
  static final RegExp _cjkToPunctSpace = RegExp(
    r'([\u4e00-\u9fa5\u3040-\u30ff])[ \t\r\f]+([，。！？；：、「」『』（）《》【】])',
  );
  static final RegExp _punctToCjkSpace = RegExp(
    r'([，。！？；：、「」『』（）《》【】])[ \t\r\f]+([\u4e00-\u9fa5\u3040-\u30ff])',
  );

  // 英文跨行連字號 (e.g. "com-\nputer" -> "computer")
  static final RegExp _hyphenatedLineBreak = RegExp(
    r'(\b[a-zA-Z]+)-\s*\n\s*([a-zA-Z]+\b)',
  );

  // 修正 OCR 誤將英文與數字連字標點的空格問題
  static final RegExp _multipleBlankLines = RegExp(r'\n{3,}');
  static final RegExp _markdownFence = RegExp(
    r'^\s*```(?:text|txt|plain)?\s*|\s*```\s*$',
    caseSensitive: false,
    multiLine: true,
  );
  static final RegExp _missingSpaceAfterPunctuation = RegExp(
    r'([,;:])(?=[A-Za-zÀ-ÖØ-öø-ÿ0-9])',
  );
  static final RegExp _missingSpaceAfterSentencePunctuation = RegExp(
    r'([.!?])(?=[A-ZÀ-ÖØ-Þ])',
  );

  static const Map<String, String> _ligatures = {
    'ﬁ': 'fi',
    'ﬂ': 'fl',
    'ﬀ': 'ff',
    'ﬃ': 'ffi',
    'ﬄ': 'ffl',
  };

  /// 對 OCR 辨識出的文字進行精緻化清洗
  static String clean(String text) {
    if (text.isEmpty) return text;

    var cleaned = text;

    // 0. 移除視覺模型偶爾包上的 Markdown code fence，並正規化常見 Unicode 字形。
    cleaned = cleaned.replaceAll(_markdownFence, '');
    _ligatures.forEach((from, to) {
      cleaned = cleaned.replaceAll(from, to);
    });
    cleaned = cleaned
        .replaceAll('\u00A0', ' ')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('–', '-')
        .replaceAll('—', '-');

    // 1. 英文跨行連字還原
    cleaned = cleaned.replaceAllMapped(
      _hyphenatedLineBreak,
      (m) => '${m[1]}${m[2]}',
    );

    // 1B. 修復學術文獻與 PDF 抽字常見擠壓，提前降低後續文獻查核與 AI 句級判斷的髒訊號。
    cleaned = _repairAcademicOcrCompounds(cleaned);
    cleaned = cleaned
        .replaceAll(
          RegExp(r'\bCouette\s+Fow\b', caseSensitive: false),
          'Couette Flow',
        )
        .replaceAllMapped(
          _missingSpaceAfterPunctuation,
          (m) => '${m.group(1)} ',
        )
        .replaceAllMapped(
          _missingSpaceAfterSentencePunctuation,
          (m) => '${m.group(1)} ',
        )
        .replaceAllMapped(RegExp(r'\s+([,;:])'), (m) => m.group(1)!)
        .replaceAllMapped(RegExp(r'\s+([.!?])(?=\s|$)'), (m) => m.group(1)!);

    // 2. 消除 CJK 字元之間被誤植的空格（重複清洗直到沒有連續獨立空格）
    var prev = '';
    while (prev != cleaned) {
      prev = cleaned;
      cleaned = cleaned.replaceAllMapped(
        _cjkToCjkSpace,
        (m) => '${m[1]}${m[2]}',
      );
    }

    // 3. 清除 CJK 與全形標點之間的空格
    cleaned = cleaned.replaceAllMapped(
      _cjkToPunctSpace,
      (m) => '${m[1]}${m[2]}',
    );
    cleaned = cleaned.replaceAllMapped(
      _punctToCjkSpace,
      (m) => '${m[1]}${m[2]}',
    );

    // 4. 清理行尾多餘空白與過多連續換行（最多保留 2 個換行，即一個空行）
    cleaned = cleaned.split('\n').map((line) => line.trimRight()).join('\n');
    cleaned = cleaned.replaceAll(_multipleBlankLines, '\n\n');

    return cleaned.trim();
  }

  static String _repairAcademicOcrCompounds(String input) {
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
          RegExp(r'\bJournalof\b', caseSensitive: false),
          'Journal of',
        )
        .replaceAll(
          RegExp(r'\bMethodsin\b', caseSensitive: false),
          'Methods in',
        )
        .replaceAll(RegExp(r'\bOnsetof\b', caseSensitive: false), 'Onset of')
        .replaceAll(RegExp(r'\bOrderof\b', caseSensitive: false), 'Order of')
        .replaceAll(RegExp(r'\bFlowwith\b', caseSensitive: false), 'Flow with')
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
        );
  }
}
