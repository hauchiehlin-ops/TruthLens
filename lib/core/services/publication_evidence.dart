import 'link_verifier.dart';

enum PublicationEvidenceStatus {
  unavailable,
  verified,
  identityMismatch,
  notFound,
  unreachable,
}

/// 來源論文本身的 DOI／篇名／年代證據。
///
/// 這和參考文獻核實不同：它確認的是「目前匯入的文件是否就是一篇已在特定
/// 年代登記的出版品」。只有 DOI 位於文件開頭、Crossref 篇名與文件吻合，且
/// 出版年代早於現代生成式 AI 時，才提供人類作者方向的來源證據。
class PublicationEvidence {
  static const int preGenerativeCutoffYear = 2020;

  final PublicationEvidenceStatus status;
  final String? doi;
  final String? articleTitle;
  final String? journalName;
  final int? publicationYear;
  final double titleSimilarity;

  const PublicationEvidence({
    required this.status,
    this.doi,
    this.articleTitle,
    this.journalName,
    this.publicationYear,
    this.titleSimilarity = 0,
  });

  static const none = PublicationEvidence(
    status: PublicationEvidenceStatus.unavailable,
  );

  bool get identityVerified => status == PublicationEvidenceStatus.verified;

  bool get supportsHumanAuthorship =>
      identityVerified &&
      publicationYear != null &&
      publicationYear! < preGenerativeCutoffYear;

  static String? extractSourceDoi(String text) {
    if (text.trim().isEmpty) return null;
    final prefix = text.substring(0, text.length.clamp(0, 6000));
    final references = RegExp(
      r'(^|\n)\s*(references|bibliography|參考文獻)\s*[:：]?\s*(\n|$)',
      caseSensitive: false,
      multiLine: true,
    ).firstMatch(prefix);
    final sourceRegion = references == null
        ? prefix
        : prefix.substring(0, references.start);
    final dois = LinkVerifier.extractDois(sourceRegion);
    return dois.isEmpty ? null : dois.first;
  }

  static Future<PublicationEvidence> verify({
    required String inputText,
    required String sourceFileName,
  }) async {
    final doi = extractSourceDoi(inputText);
    if (doi == null) return none;
    final check = await LinkVerifier.verifyDoi(doi);
    return fromCheck(
      check,
      inputText: inputText,
      sourceFileName: sourceFileName,
    );
  }

  static PublicationEvidence fromCheck(
    LinkCheckResult check, {
    required String inputText,
    required String sourceFileName,
  }) {
    final similarity = _titleSimilarity(
      check.articleTitle ?? '',
      '${inputText.substring(0, inputText.length.clamp(0, 4000))} '
      '$sourceFileName',
    );
    final status = switch (check.status) {
      LinkStatus.notFound => PublicationEvidenceStatus.notFound,
      LinkStatus.unreachable => PublicationEvidenceStatus.unreachable,
      LinkStatus.reachable when similarity >= 0.72 =>
        PublicationEvidenceStatus.verified,
      LinkStatus.reachable => PublicationEvidenceStatus.identityMismatch,
    };
    return PublicationEvidence(
      status: status,
      doi: check.doi ?? extractSourceDoi(inputText),
      articleTitle: check.articleTitle,
      journalName: check.journalName,
      publicationYear: check.publicationYear,
      titleSimilarity: similarity,
    );
  }

  static double _titleSimilarity(String title, String documentIdentity) {
    final titleTokens = _tokens(title);
    if (titleTokens.length < 3) return 0;
    final documentTokens = _tokens(documentIdentity);
    final matched = titleTokens.where(documentTokens.contains).length;
    return matched / titleTokens.length;
  }

  static Set<String> _tokens(String value) => RegExp(r'[a-z0-9]+')
      .allMatches(value.toLowerCase())
      .map((match) => match.group(0)!)
      .where((token) => token.length > 2)
      .toSet();
}
