import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/link_verifier.dart';
import 'package:omnitrace/core/services/publication_evidence.dart';

void main() {
  test('只從文件開頭抽取來源 DOI，不抓參考文獻 DOI', () {
    const text = '''
DOI:10.1142/S0218127410026678
LOWEST STABILITY BOUNDARY ON FLOW OF CONCENTRIC ROTATING CYLINDERS

References
Smith, A. https://doi.org/10.9999/reference-only
''';
    expect(
      PublicationEvidence.extractSourceDoi(text),
      '10.1142/s0218127410026678',
    );
  });

  test('可從實際 IJBC PDF 抽取文字取得來源 DOI', () {
    final paper = File('test/fixtures/ijbc_paper.txt').readAsStringSync();
    expect(
      PublicationEvidence.extractSourceDoi(paper),
      '10.1142/s0218127410026678',
    );
  });

  test('Crossref 篇名吻合且 2010 年出版可形成來源證據', () {
    const text = '''
DOI:10.1142/S0218127410026678
LOWEST STABILITY BOUNDARY ON FLOW OF CONCENTRIC ROTATING CYLINDERS
Received June 5, 2009
''';
    const check = LinkCheckResult(
      url: 'https://doi.org/10.1142/s0218127410026678',
      status: LinkStatus.reachable,
      isCitationVerified: true,
      doi: '10.1142/s0218127410026678',
      articleTitle:
          'Lowest stability boundary on flow of concentric rotating cylinders',
      journalName: 'International Journal of Bifurcation and Chaos',
      publicationYear: 2010,
    );
    final evidence = PublicationEvidence.fromCheck(
      check,
      inputText: text,
      sourceFileName: '2010-Lowest stability boundary.pdf',
    );

    expect(evidence.status, PublicationEvidenceStatus.verified);
    expect(evidence.titleSimilarity, greaterThanOrEqualTo(0.9));
    expect(evidence.supportsHumanAuthorship, isTrue);
  });

  test('舊 DOI 但篇名不符時不能支持真人作者', () {
    const check = LinkCheckResult(
      url: 'https://doi.org/10.1142/s0218127410026678',
      status: LinkStatus.reachable,
      articleTitle: 'A completely unrelated article',
      publicationYear: 2010,
    );
    final evidence = PublicationEvidence.fromCheck(
      check,
      inputText: 'Another document about urban planning.',
      sourceFileName: 'planning.pdf',
    );

    expect(evidence.status, PublicationEvidenceStatus.identityMismatch);
    expect(evidence.supportsHumanAuthorship, isFalse);
  });
}
