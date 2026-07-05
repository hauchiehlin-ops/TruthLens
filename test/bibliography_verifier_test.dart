import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:truthlens/core/services/bibliography_verifier.dart';

// 逐字轉錄自使用者提供的截圖（Couette 流動研究論文的參考文獻頁）。
const _sampleReferences = '''
References
Ahlers, G., Cannell, D.S., and Lerma, M.A.D., 1983. Possible mechanism for transitions in wavy Taylor-vortex flow. Physical Review A, 27, 1225–1227.
Andereck, C., Liu, S.S., and Swinney, H.L., 1986. Flow regimes in a circular Couette system with independently rotating cylinders. Journal of Fluid Mechanics, 164, 155–183.
Antonijoan, J. and Sanchez, J., 2002. On stable Taylor vortices above the transition to wavy vortices. Physical Fluids, 14, 1661–1665.
Coles, D., 1965. Transition in circular Couette flow. Journal of Fluid Mechanics, 21, 385–425.
Nissan, A.H., Nardacci, J.L., and Ho, C.Y., 1963. The onset of different modes of instability for flow between rotating cylinders. AIChE J, 9, 620–624.
Schultz-Grunow, F. and Hein, H., 1956. Beitrag zur Couettestromung. Z. Flugwiss, 4, 28–30.
''';

void main() {
  group('BibliographyVerifier.extractEntries', () {
    test('偵測到 References 標題後依條目切分（含多作者、and 連接）', () {
      final entries = BibliographyVerifier.extractEntries(_sampleReferences);
      expect(entries.length, 6);
      expect(entries[0].firstAuthorSurname, 'Ahlers');
      expect(entries[0].year, 1983);
      expect(entries[0].title,
          'Possible mechanism for transitions in wavy Taylor-vortex flow');
    });

    test('單一作者條目也能正確解析（姓氏、年份、篇名）', () {
      final entries = BibliographyVerifier.extractEntries(_sampleReferences);
      final coles = entries.firstWhere((e) => e.firstAuthorSurname == 'Coles');
      expect(coles.year, 1965);
      expect(coles.title, 'Transition in circular Couette flow');
    });

    test('三位作者（and 連接）也能正確解析', () {
      final entries = BibliographyVerifier.extractEntries(_sampleReferences);
      final nissan =
          entries.firstWhere((e) => e.firstAuthorSurname == 'Nissan');
      expect(nissan.year, 1963);
    });

    test('沒有「References」標題時回傳空陣列，不誤判一般段落', () {
      expect(
        BibliographyVerifier.extractEntries('這只是一段普通的文件內容，沒有參考文獻。'),
        isEmpty,
      );
    });

    test('中文「參考文獻」標題也能觸發偵測', () {
      final entries = BibliographyVerifier.extractEntries(
        '前言略過。\n參考文獻\nColes, D., 1965. Transition in circular Couette flow. '
        'Journal of Fluid Mechanics, 21, 385–425.\n',
      );
      expect(entries, isNotEmpty);
    });
  });

  group('BibliographyVerifier.verifyAll', () {
    test('Crossref 回傳高度相似篇名＋年份吻合 → 高可信度', () async {
      final client = MockClient((req) async {
        expect(req.url.host, 'api.crossref.org');
        expect(req.url.queryParameters['query.bibliographic'], isNotNull);
        return http.Response(
          jsonEncode({
            'message': {
              'items': [
                {
                  'title': ['Transition in circular Couette flow'],
                  'container-title': ['Journal of Fluid Mechanics'],
                  'published': {
                    'date-parts': [
                      [1965]
                    ]
                  },
                  'author': [
                    {'family': 'Coles', 'given': 'D'}
                  ],
                }
              ],
            }
          }),
          200,
        );
      });
      final entries = BibliographyVerifier.extractEntries(_sampleReferences);
      final coles = entries.firstWhere((e) => e.firstAuthorSurname == 'Coles');
      final results =
          await BibliographyVerifier.verifyAll([coles], client: client);
      expect(results.single.confidence, CitationMatchConfidence.high);
      expect(results.single.matchedJournal, 'Journal of Fluid Mechanics');
    });

    test('Crossref 查無相近結果 → notFound（可能為虛構文獻）', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({
              'message': {'items': []}
            }),
            200,
          ));
      final entries = BibliographyVerifier.extractEntries(_sampleReferences);
      final results = await BibliographyVerifier.verifyAll(
          [entries.first],
          client: client);
      expect(results.single.confidence, CitationMatchConfidence.notFound);
    });

    test('篇名完全不同、年份與作者皆不吻合 → notFound', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({
              'message': {
                'items': [
                  {
                    'title': ['A completely unrelated topic in biology'],
                    'container-title': ['Some Other Journal'],
                    'published': {
                      'date-parts': [
                        [2020]
                      ]
                    },
                    'author': [
                      {'family': 'Smith', 'given': 'J'}
                    ],
                  }
                ],
              }
            }),
            200,
          ));
      final entries = BibliographyVerifier.extractEntries(_sampleReferences);
      final coles = entries.firstWhere((e) => e.firstAuthorSurname == 'Coles');
      final results =
          await BibliographyVerifier.verifyAll([coles], client: client);
      expect(results.single.confidence, CitationMatchConfidence.notFound);
    });

    test('連線例外時判定為 uncertain，不拋出例外', () async {
      final client = MockClient((_) async => throw Exception('offline'));
      final entries = BibliographyVerifier.extractEntries(_sampleReferences);
      final results = await BibliographyVerifier.verifyAll(
          [entries.first],
          client: client);
      expect(results.single.confidence, CitationMatchConfidence.uncertain);
    });
  });
}
