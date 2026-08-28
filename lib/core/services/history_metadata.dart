/// 產生歷史清單使用的文件標題。
///
/// 匯入檔案以使用者看到的原始檔名為準；只有直接貼上文字且第一行具備明確
/// 標題形態時才從內容推導。寧可回傳空字串讓 UI 顯示「未命名文件」，也不
/// 把正文段落、PDF 頁首或下載提示誤當成標題。
String resolveHistoryDocumentTitle({
  String storedTitle = '',
  String sourceFileName = '',
  String inputText = '',
}) {
  final saved = _cleanTitle(storedTitle);
  if (saved.isNotEmpty) return saved;

  final fileName = sourceFileName
      .trim()
      .split(RegExp(r'[/\\]'))
      .where((part) => part.isNotEmpty)
      .lastOrNull;
  if (fileName != null) {
    final cleaned = _cleanTitle(fileName);
    if (cleaned.isNotEmpty) return cleaned;
  }

  for (final rawLine in inputText.replaceAll('\r', '\n').split('\n')) {
    var line = rawLine.replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '').trim();
    if (line.isEmpty) continue;

    final markdown = RegExp(r'^#{1,6}\s+(.+)$').firstMatch(line);
    final explicitlyMarked = markdown != null;
    if (markdown != null) line = markdown.group(1)!.trim();
    line = line.replaceFirst(
      RegExp(r'^(?:title|標題|标题)\s*[:：]\s*', caseSensitive: false),
      '',
    );
    line = _cleanTitle(line);
    if (line.isEmpty || _isHistoryBoilerplate(line)) continue;
    if (explicitlyMarked && line.length <= 180) return line;
    if (_looksLikePlainDocumentTitle(line)) return line;

    // 第一個有內容的實體行已是正文，就不要再往後挑一句看似標題的文字。
    return '';
  }
  return '';
}

String _cleanTitle(String value) => value
    .replaceAll(RegExp(r'[\r\n\t]+'), ' ')
    .replaceAll(RegExp(r'\s{2,}'), ' ')
    .trim();

bool _isHistoryBoilerplate(String line) => RegExp(
  r'^(?:please scroll|this article was downloaded|received\b|revised\b|'
  r'accepted\b|published\b|doi\s*:|copyright\b|您好[！!，,]?|以下(?:為|是))',
  caseSensitive: false,
).hasMatch(line);

bool _looksLikePlainDocumentTitle(String line) {
  if (line.length > 140 || RegExp(r'[。.!！?？]\s*.+').hasMatch(line)) {
    return false;
  }
  if (RegExp(
    r'^(?:in this (?:study|paper|article)|this (?:study|paper|article)|'
    r'we |i |本文|本研究|本論文|本论文)',
    caseSensitive: false,
  ).hasMatch(line)) {
    return false;
  }

  final words = RegExp(
    r'[\p{L}\p{M}\p{N}]+',
    unicode: true,
  ).allMatches(line).length;
  if (words == 0 || words > 14) return false;

  final cjk = RegExp(
    r'[\p{Script=Han}\p{Script=Hiragana}\p{Script=Katakana}\p{Script=Hangul}]',
    unicode: true,
  ).allMatches(line).length;
  if (cjk > 0) return cjk <= 48 && !RegExp(r'[。！？]').hasMatch(line);

  // 無大小寫文字（阿拉伯文、泰文、天城文等）以長度與句末標點保守判斷。
  final casedLetters = RegExp(
    r'[\p{Lu}\p{Ll}\p{Lt}]',
    unicode: true,
  ).hasMatch(line);
  if (!casedLetters) {
    return line.length <= 90 && !RegExp(r'[؟۔።፧।॥။]').hasMatch(line);
  }

  return !RegExp(r'[.!?]$').hasMatch(line);
}
