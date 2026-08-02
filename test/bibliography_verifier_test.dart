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

    test('沒有標題但條目數達門檻時仍主動偵測（文件未必會明確標示「這是文獻」）', () {
      // 取樣本文獻但移除「References」標題這一行
      final withoutHeading =
          _sampleReferences.replaceFirst('References\n', '');
      final entries = BibliographyVerifier.extractEntries(withoutHeading);
      expect(entries.length, 6);
      expect(entries[0].firstAuthorSurname, 'Ahlers');
    });

    test('沒有標題且條目數低於門檻時不判定為文獻目錄，避免內文巧合誤判', () {
      final onlyTwo = '''
Ahlers, G., Cannell, D.S., and Lerma, M.A.D., 1983. Possible mechanism for transitions in wavy Taylor-vortex flow. Physical Review A, 27, 1225–1227.
Coles, D., 1965. Transition in circular Couette flow. Journal of Fluid Mechanics, 21, 385–425.
''';
      expect(BibliographyVerifier.extractEntries(onlyTwo), isEmpty);
    });

    test('無 References 標題但包含條目編號/期刊/卷期關鍵字之條列文獻可精準擷取', () {
      const bulletedInput = '''
[1] Smith, J. and Doe, A. (2021). "Deep Learning Analysis." Journal of AI Research, vol. 15, pp. 100-110.
[2] Johnson, M. (2019). "Neural Network Models." IEEE Transactions on Pattern Analysis, 41(2): 300-312.
[3] Brown, K. et al. (2023). "Transformer Networks." Proceedings of ACM Computing, pp. 50-65.
''';
      final entries = BibliographyVerifier.extractEntries(bulletedInput);
      expect(entries.length, 3);
      expect(entries[0].year, 2021);
      expect(entries[0].title, 'Deep Learning Analysis.');
      expect(entries[1].year, 2019);
      expect(entries[2].year, 2023);
    });

    test('中文條列式期刊文獻包含學報與卷期格式可自動識別與抽取', () {
      const chineseInput = '''
1. 王小明、李大華（2020）。〈機器學習在內容檢測之應用〉。《資訊學報》，第 12 卷第 3 期，頁 45-60。
2. 張三、陳某某等（2022）。〈深度生成模型辨識技術〉。《電子工程學刊》，第 8 卷第 1 期，頁 12-25。
3. 林志明（2018）。〈對抗式防禦演算法解析〉。《計算機論文集》，頁 80-95。
''';
      final entries = BibliographyVerifier.extractEntries(chineseInput);
      expect(entries.length, 3);
      expect(entries[0].firstAuthorSurname, '王小明');
      expect(entries[0].year, 2020);
      expect(entries[0].title, '機器學習在內容檢測之應用');
      expect(entries[1].year, 2022);
      expect(entries[2].year, 2018);
    });

    test('跨行與含有頁首/頁尾雜訊之 Vancouver/IEEE 格式參考文獻可精準擷取', () {
      const vancouverInput = '''
REFERENCES

[1] COHEN B.S., HERING S.V., Air sampling instrumentsfor evaluation of atmospheric contaminants, 8th Ed.
American Conference of Governmental Industrial Hygienists, Inc., Cincinnati 1995.
[2] HINDS W.C., Aerosol Technology, Properties, Behavior, and Measurement of Airborne Particles,
2nd Ed., Wiley, 1999.
[3] CALVERT S., Venturi and other atomizing scrubbers efficiency and pressure drop, AICHE J., 1970,
16, 392.
[4] MAYINGER F., NEUMANN M., Dust collection in Venturi scrubbers, Ger. Chem. Eng., 1978, 1, 289.
[5] TIGGES K.D., MAYINGER F., Experiments with highly efficient Venturi scrubbers for aerosol separation
from gases under multi-plane water injection, Chem. Eng. Process, 1984, 18, 171.

70                                B. LIAO et al.
--------------------------------------------------

[6] TSAI C.J., LIN C.H., WANG Y.M., An efficient Venturi scrubber system to remove submicron particles in
exhaust gas, J. Air Waste Manage. Assoc., 2005, 55, 319.
[7] HUANG C.H., TSAI C.J., WANG Y.M., Control of submicron particle collection efficiency in a Venturi
scrubber. Comparison of experiments with theory, Env. Sci. Tech., 2007, 20, 237.
''';
      final entries = BibliographyVerifier.extractEntries(vancouverInput);
      expect(entries.length, 7);
      expect(entries[0].firstAuthorSurname, 'COHEN');
      expect(entries[0].year, 1995);
      expect(entries[5].firstAuthorSurname, 'TSAI');
      expect(entries[5].year, 2005);
      expect(entries[6].firstAuthorSurname, 'HUANG');
      expect(entries[6].year, 2007);
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
