/// DOCX 段落級編輯批次（RSID）分析。
///
/// Word 會為每個「編輯工作階段」產生一個 RSID（Revision Save ID），並標在
/// 該階段建立或修改的段落與文字執行區上。**同一個 RSID 代表同一次編輯**。
///
/// 現有的 [DocumentProvenance] 只數全文有幾個相異 RSID，得到的是整份文件
/// 一個結論。逐段展開之後，能指出**哪幾段**屬於同一批——一份逐步寫成的文件
/// 會有許多小批次散在各段，而一次貼上的內容會讓大量文字集中在單一批次裡。
///
/// 這把「這份文件可疑」變成「這三段是一次寫入的」，可指認到具體位置。
///
/// **必須誠實面對的限制**：RSID 不是時間戳，它只是批次識別碼。從別的文件
/// 複製過來的內容會把原本的 RSID 一起帶過來；「另存新檔」與部分線上轉檔會
/// 重置全部 RSID。因此高度集中只是**佐證**，不能單獨當作結論——這與整個
/// 來源證據模組的定位一致。
library;

/// 一個編輯批次：共用同一個 RSID 的段落集合
class RsidBatch {
  final String rsid;

  /// 屬於這個批次的段落序號（以文件中的順序計，從 0 起算）
  final List<int> paragraphIndices;

  /// 這些段落合計的字數
  final int wordCount;

  const RsidBatch({
    required this.rsid,
    required this.paragraphIndices,
    required this.wordCount,
  });
}

/// 整份文件的段落級批次分佈
class RsidMap {
  /// 依字數由多到少排序的批次
  final List<RsidBatch> batches;

  /// 有文字內容的段落總數
  final int paragraphCount;

  /// 全文字數（依同一套斷詞規則計算）
  final int wordCount;

  const RsidMap({
    this.batches = const [],
    this.paragraphCount = 0,
    this.wordCount = 0,
  });

  static const RsidMap empty = RsidMap();

  bool get hasData => batches.isNotEmpty && wordCount > 0;

  /// 最大批次涵蓋的字數佔比
  double get largestBatchShare {
    if (!hasData) return 0;
    return batches.first.wordCount / wordCount;
  }

  /// 內容過度集中於單一批次的門檻。
  ///
  /// 取 0.60 而非更低，是因為短文件本來就只會有一兩個批次；
  /// 要在**有足夠段落**的前提下仍高度集中，才具指示性。
  static const double concentrationThreshold = 0.60;

  /// 需要足夠的段落數，集中度才有意義
  static const int minimumParagraphs = 6;

  /// 內容是否高度集中於單一編輯批次
  bool get isHighlyConcentrated =>
      hasData &&
      paragraphCount >= minimumParagraphs &&
      largestBatchShare >= concentrationThreshold;
}

final _paragraph = RegExp(r'<w:p[ >].*?</w:p>', dotAll: true);
final _rsidAttr = RegExp(r'w:rsid(?:R|RDefault|P|RPr|Tr|Del)?="([0-9A-Fa-f]+)"');
final _textRun = RegExp(r'<w:t(?:\s[^>]*)?>(.*?)</w:t>', dotAll: true);

/// 由 `word/document.xml` 的內容建立段落級批次分佈。
///
/// [countWords] 由呼叫端傳入，確保與其他字數統計使用同一套規則
/// ——中文逐字、拉丁語系以空白斷詞。
RsidMap buildRsidMap(String documentXml, int Function(String) countWords) {
  if (documentXml.isEmpty) return RsidMap.empty;

  final byRsid = <String, List<int>>{};
  final wordsByRsid = <String, int>{};
  var paragraphIndex = 0;
  var totalWords = 0;

  for (final match in _paragraph.allMatches(documentXml)) {
    final xml = match[0]!;
    final text = _textRun
        .allMatches(xml)
        .map((m) => m[1] ?? '')
        .join()
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty) continue;

    // 取這一段裡出現最多次的 RSID 當作它的批次：一個段落可能同時帶有
    // 段落層級與多個執行區層級的 RSID，多數決比取第一個穩定。
    final counts = <String, int>{};
    for (final m in _rsidAttr.allMatches(xml)) {
      final value = m.group(1)?.toUpperCase();
      if (value == null || value.isEmpty) continue;
      counts[value] = (counts[value] ?? 0) + 1;
    }
    if (counts.isEmpty) {
      paragraphIndex++;
      continue;
    }
    final dominant = counts.entries.reduce(
      (a, b) => b.value > a.value ? b : a,
    ).key;

    final words = countWords(text);
    byRsid.putIfAbsent(dominant, () => <int>[]).add(paragraphIndex);
    wordsByRsid[dominant] = (wordsByRsid[dominant] ?? 0) + words;
    totalWords += words;
    paragraphIndex++;
  }

  if (byRsid.isEmpty) return RsidMap.empty;

  final batches =
      byRsid.entries
          .map(
            (e) => RsidBatch(
              rsid: e.key,
              paragraphIndices: e.value,
              wordCount: wordsByRsid[e.key] ?? 0,
            ),
          )
          .toList()
        ..sort((a, b) => b.wordCount.compareTo(a.wordCount));

  return RsidMap(
    batches: batches,
    paragraphCount: paragraphIndex,
    wordCount: totalWords,
  );
}
