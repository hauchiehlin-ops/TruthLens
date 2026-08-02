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

    test('12 頁完整論文內文（包含內文引用與完整 References）可精準抽取全部 7 筆條目', () {
      const fullPaperContent = '''
Environment Protection Engineering
Vol. 42 2016 No. 1
DOI: 10.5277/epe160105
BENWEI LIAO1, SHUEIWAN H. JUANG1, HAUCHIEH LIN2
A NEW DESIGN OF WET SCRUBBER FOR REMOVAL OF FINE PARTICLES FROM EXHAUST GAS
1. INTRODUCTION
Common methods of cleaning bag filters include mechanical oscillation...
60 B. LIAO et al.
Filtration equipment do not generally produce particle bounce by cyclone [1] in use, and the dust collection efficiency curve of such equipment is similar to that of the traditional respirable sampling apparatus [2].
The literatures include extensive research on the separated efficiency and pressure drop characteristics of the Venturi scrubbers [3–5].
Therefore, Tsai et al. [6] and Huang et al. [7] proposed improving the dust collection efficiency...
4. CONCLUSIONS
The proposed wet scrubber described here combines the concepts...
REFERENCES
[1] COHEN B.S., HERING S.V., Air sampling instrumentsfor evaluation of atmospheric contaminants, 8th Ed.
American Conference of Governmental Industrial Hygienists, Inc., Cincinnati 1995.
[2] HINDS W.C., Aerosol Technology, Properties, Behavior, and Measurement of Airborne Particles,
2nd Ed., Wiley, 1999.
[3] CALVERT S., Venturi and other atomizing scrubbers efficiency and pressure drop, AICHE J., 1970, 16, 392.
[4] MAYINGER F., NEUMANN M., Dust collection in Venturi scrubbers, Ger. Chem. Eng., 1978, 1, 289.
[5] TIGGES K.D., MAYINGER F., Experiments with highly efficient Venturi scrubbers for aerosol separation
from gases under multi-plane water injection, Chem. Eng. Process, 1984, 18, 171.
70 B. LIAO et al.
[6] TSAI C.J., LIN C.H., WANG Y.M., An efficient Venturi scrubber system to remove submicron particles in
exhaust gas, J. Air Waste Manage. Assoc., 2005, 55, 319.
[7] HUANG C.H., TSAI C.J., WANG Y.M., Control of submicron particle collection efficiency in a Venturi
scrubber. Comparison of experiments with theory, Env. Sci. Tech., 2007, 20, 237.
''';
      final entries = BibliographyVerifier.extractEntries(fullPaperContent);
      expect(entries.length, 7);
      expect(entries.map((e) => e.firstAuthorSurname).toList(), [
        'COHEN',
        'HINDS',
        'CALVERT',
        'MAYINGER',
        'TIGGES',
        'TSAI',
        'HUANG',
      ]);
    });

    test('含有真實 OCR / PDF 瑕疵（連寫嵌合條目 [ 2 ]、[ 3 ] 與單一字母空白 H INDS, T SAI）仍可精準修復並抽取全部 7 筆條目', () {
      const ocrArtifactContent = '''
REFERENCES
[1] COHEN B.S., HERING S.V., Air sampling instruments for evaluation of atmospheric contaminants , 8t h Ed. American Conference of Governmental Industrial Hygienists , Inc., Cincinnati 1995. [ 2 ] H INDS W.C., Aerosol Technology, Properties, Behavior, and Measurement of Airborne Particle s , 2nd E d. , Wiley, 1999. [ 3 ] C ALVERT S., Venturi and other atomizing scrubbers efficiency and pressure drop , AICHE J. , 1970, 16, 392. [4 ] M AYINGER F., N EUMANN M., Dust collection in Venturi scrubbers , Ger. Chem. Eng. , 1978, 1, 289 . [5 ] T IGGES K.D., M AYINGER F., Experiments with highly efficient Venturi scrubbers for aerosol separation from gases under multi plane water injection , Chem. Eng. Process , 1984, 18, 171. 70 B. L IAO et al. [6 ] T SAI C.J., L IN C.H., W ANG Y.M., An efficient Venturi scrubber system to remove submicron particles in exhaust gas , J. Air Waste Manage. Assoc., 2005 , 55, [7 ] H UANG C.H., T SAI C.J., W ANG Y.M., Control of submicron particle collection efficiency in a Venturi scrubber . C omparison of experiments with theory , Env. Sci. Tech. , 2007 , 20 , 237.
''';
      final entries = BibliographyVerifier.extractEntries(ocrArtifactContent);
      expect(entries.length, 7);
      expect(entries[0].firstAuthorSurname, 'COHEN');
      expect(entries[0].year, 1995);
      expect(entries[1].firstAuthorSurname, 'HINDS');
      expect(entries[1].year, 1999);
      expect(entries[2].firstAuthorSurname, 'CALVERT');
      expect(entries[2].year, 1970);
      expect(entries[3].firstAuthorSurname, 'MAYINGER');
      expect(entries[3].year, 1978);
      expect(entries[4].firstAuthorSurname, 'TIGGES');
      expect(entries[4].year, 1984);
      expect(entries[5].firstAuthorSurname, 'TSAI');
      expect(entries[5].year, 2005);
      expect(entries[6].firstAuthorSurname, 'HUANG');
      expect(entries[6].year, 2007);
    });

    test('World Scientific / Author [Year] 格式論文內文與 References 可精準過濾內文引用與公式並抽取正確文獻', () {
      const worldScientificPaper = '''
International Journal of Bifurcation and Chaos, Vol. 20, No. 5 (2010) 1527-1532
LOWEST STABILITY BOUNDARY ON FLOW OF CONCENTRIC ROTATING CYLINDERS
1. Introduction
The curve differs from that obtained by Coles [1965], who assumed that the TVF was axisymmetric.
(2) where V = (Vr, Vθ, Vz) and j is the solution at time t...
(3) The flow velocity and pressure profile of the super-critical TVF are obtained...
(7) Here, M and N are the number of terms in the Fourier series expansion...
(8) The matrix equation represents a system of equations with (4 x M x N) unknown parameters.
References
Ahlers, G., Cannell, D. S. & Lerma, M. A. D. [1983] "Possible mechanism for transitions in wavy Taylor-vortex flow," Phys. Rev. A. At. Mol. Opt. Phys. 27, 1225-1227.
Andereck, C., Liu, S. S. & Swinney, H. L. [1986] "Flow regimes in a circular Couette system with independently rotating cylinders," J. Fluid Mech. 164, 155-183.
Antonijoan, J. & Sanchez, J. [2002] "On stable Taylor vortices above the transition to wavy vortices," Phys. Fluids 14, 1661-1665.
Burkhalter, J. E. & Koschmieder, E. L. [1973] "Steady supercritical Taylor vortex flow," J. Fluid Mech. 58, 547-560.
Burkhalter, J. E. & Koschmieder, E. L. [1974] "Steady supercritical Taylor vortices after sudden starts," Phys. Fluids 17, 1929-1935.
Coles, D. [1965] "Transition in circular Couette flow," J. Fluid Mech. 21, 385-425.
Hall, P. & Blennerhasset, P. J. [1979] "Centrifugal instability of circumferential flow in finite cylinders," Proc. R. Soc. London A 365, 191-207.
''';
      final entries = BibliographyVerifier.extractEntries(worldScientificPaper);
      expect(entries.length, 7);
      expect(entries.map((e) => e.firstAuthorSurname).toList(), [
        'Ahlers',
        'Andereck',
        'Antonijoan',
        'Burkhalter',
        'Burkhalter',
        'Coles',
        'Hall',
      ]);
      expect(entries[5].year, 1965);
      expect(entries[5].title, 'Transition in circular Couette flow');
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
