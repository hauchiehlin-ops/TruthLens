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
      expect(
        entries[0].title,
        'Possible mechanism for transitions in wavy Taylor-vortex flow',
      );
    });

    test('單一作者條目也能正確解析（姓氏、年份、篇名）', () {
      final entries = BibliographyVerifier.extractEntries(_sampleReferences);
      final coles = entries.firstWhere((e) => e.firstAuthorSurname == 'Coles');
      expect(coles.year, 1965);
      expect(coles.title, 'Transition in circular Couette flow');
      expect(coles.venueTitle, 'Journal of Fluid Mechanics');
    });

    test('三位作者（and 連接）也能正確解析', () {
      final entries = BibliographyVerifier.extractEntries(_sampleReferences);
      final nissan = entries.firstWhere(
        (e) => e.firstAuthorSurname == 'Nissan',
      );
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
      final withoutHeading = _sampleReferences.replaceFirst('References\n', '');
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
      expect(entries[0].title, 'Deep Learning Analysis');
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

    test(
      '含有真實 OCR / PDF 瑕疵（連寫嵌合條目 [ 2 ]、[ 3 ] 與單一字母空白 H INDS, T SAI）仍可精準修復並抽取全部 7 筆條目',
      () {
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
      },
    );

    test(
      'World Scientific / Author [Year] 格式論文內文與 References 可精準過濾內文引用與公式並抽取 Page 1532 全部 18 筆文獻',
      () {
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
Jones, C. A. [1981] "Nonlinear Taylor vortices and their stability," J. Fluid Mech. 102, 249-261.
Jones, C. A. [1985a] "The transition to wavy Taylor vortices," J. Fluid Mech. 157, 135-162.
Jones, C. A. [1985b] "Numerical method for the transition to wavy Taylor vortices," J. Comput. Phys. 61, 321-344.
King, G. P. & Swinney, H. L. [1983] "Limits of stability and irregular flow patterns in wavy vortex flow," Phys. Rev. A. At. Mol. Opt. Phys. 27, 1240-1243.
Lewis, J. W. [1928] "An experimental study of the motion of a viscous liquid contained between two coaxial cylinders," Proc. R. Soc. London A 117, 388-407.
Nissan, A. H., Nardacci, J. L. & Ho, C. Y. [1963] "The onset of different modes of instability for flow between rotating cylinders," AIChE J. 9, 620-624.
Park, K., Gerald, L. & Donnelly, R. J. [1981] "Determination of transition in Couette flow in finite geometries," Phys. Rev. Lett. 47, 1448-1450.
Park, K. [1984] "Unusual transition sequence in Taylor wavy vortex flow," Phys. Rev. A. At. Mol. Opt. Phys. 29, 3458-3460.
Schultz-Grunow, F. & Hein, H. [1956] "Beitrag zur Couettestromung," Z Flugwiss 4, 28-30.
Stuart, J. T. [1958] "On the nonlinear mechanics of hydrodynamic stability," J. Fluid Mech. 4, 1-21.
Taylor, G. I. [1923] "Stability of a viscous liquid contained between two rotating cylinders," Phil. Trans. R. Soc. London A 223, 289-343.
''';
        final entries = BibliographyVerifier.extractEntries(
          worldScientificPaper,
        );
        expect(entries.length, 18);
        expect(entries.map((e) => e.firstAuthorSurname).toList(), [
          'Ahlers',
          'Andereck',
          'Antonijoan',
          'Burkhalter',
          'Burkhalter',
          'Coles',
          'Hall',
          'Jones',
          'Jones',
          'Jones',
          'King',
          'Lewis',
          'Nissan',
          'Park',
          'Park',
          'Schultz-Grunow',
          'Stuart',
          'Taylor',
        ]);
        expect(entries[5].year, 1965);
        expect(entries[5].title, 'Transition in circular Couette flow');
        expect(entries[17].firstAuthorSurname, 'Taylor');
        expect(entries[17].year, 1923);
      },
    );

    test(
      'Experimental Techniques 論文內文（含公式、24.段落標號）與 22 筆 References 可精準過濾內文並抽取全部 22 筆文獻',
      () {
        const experimentalTechniquesPaper = '''
Fig. 6: Spectrum analysis of the subharmonic flow with Ω = 0, η = 0.4833, ε = 2, and ω = 18.75
(2) the optical area, which has a helium-neon laser tube, photoelectric receiver, LDA device, and oscillograph. A personal computer (PC) and PC-LabCard were used to control and retrieve data. The control interface panel can output the predicted voltage value...
24. Optical Measurement Method As the Re increases, the flow is transformed from a one-dimensional Couette flow to a two-dimensional Taylor vortex flow...
(1) The boundary condition is Vr = Vz = 0, Vθ = Re...
(5) where Vθ is the basic flow velocity of one-dimensional Couette flow...
81. The experimental results acquired by other studies are within the error range...
1. The stability of the modulated Couette flow is primarily affected by the modulated amplitude and frequency...

References
1. Couette, M., "Etudes Sur Le Frottement Des Liquids," Annales de chimie et de physique 6:433-510 (1890).
2. Taylor, G.I., "Stability of a Viscous Liquid Contained between Two Rotating Cylinders," Philosophical Transactions of the Royal Society of London A233:289-343 (1923).
3. Donnelly, R.J., "Experiment on the Stability of Viscous Flow between Rotating Cylinders I. Torque Measurement," Proceedings of the Royal Society of London A246:312-325 (1958).
4. Simon, N.J., and Donnelly, R.J., "An Empirical Torque Relation for Supercritical Flow between Rotating Cylinders," Journal of Fluid Mechanics 7:401-418 (1960).
5. Coles, D., "On the Instability of Taylor Vortices," Journal of Fluid Mechanics 31:17-62 (1965).
6. Schwarz, K.W., Springett, B.E., and Donnelly, R.J., "Modes of Instability in Spiral Flow between Rotating Cylinders," Journal of Fluid Mechanics 20:281-289 (1964).
7. Nissan A.H., Nardacci J.L., and Ho C.Y., "The Onset of Different Modes of Instability for Flow between Rotating Cylinders," AIChE Journal 9:620-624 (1963).
8. Marques, F., and Lope, J.M., "Taylor-Couette Flow with Axial Oscillations of the Inner Cylinder: floquet Analysis of the Basic Flow," Journal of Fluid Mechanics 384:153-175 (1997).
9. Lope, J.M., and Marques, F., "Dynamics of Three-tori in a Periodically Forced Navier-Stokes Flow," Physical Review Letters 85:972-975 (2001).
10. Walsh, T.J., and Donnelly, R.J., "Couette Fow with Periodically Corotated and Counterrotated Cylinders," Physical Review Letters 60:700-703 (1988).
11. Gollub J.P., and Swinney, H.L., "Onset of Turbulent in a Rotating Fluid," Physical Review Letters 35:927-930 (1975).
12. Walden, R.W., and Donnelly, R.J., "Reemergent Order of Chaotic Circular Couette Flow," Physical Review Letters 42:301-304 (1979).
13. Donnelly, R.J., "Experiments on the Stability of Viscous Flow between Rotating Cylinders III. Enhancement of Stability by Modulation," Proceedings of the Royal Society of London A281:130-139 (1964).
14. Hall, P., "The Stability of Unsteady Cylinder Flows," Journal of Fluid Mechanics 67:29-63 (1975).
15. Carmi, S., and Tustaniwskyj, J.I., "Stability of Modulated Finite-gap Cylindrical Couette Flow: linear Theory," Journal of Fluid Mechanics 108:19-42 (1981).
16. Youd, A.J., Willis, A.P., and Barenghi, C.F., "Reversing and Non-reversing Modulated Taylor-Couette Flow," Journal of Fluid Mechanics 487:367-376 (2003).
17. Walsh T.J., Wagner W.T., and Donnelly R.J., "Stability of Modulated Couette Flow," Physical Review Letters 58:2543-2546 (1987).
18. Ganske, A., Gebhardt, T., and Grossmann, S., "Taylor-Couette Flow with Time Modulated Inner Cylinder Velocity," Physics Letters: Part A 192:74-78 (1994).
19. Canuto, C., Hussaini, M.Y., Quarteroni A., and Zang, T.A., Spectral Methods in Fluid Dynamics, Springer-Verlag, New York (1988).
20. Cole, J.A., "Taylor-vortex Instability and Annulus-length Effects," Journal of Fluid Mechanics 75:1-15 (1976).
21. Sparrow, E.M., Munro, W.D., and Jonsson, V.K., "Instability of the Flow Between Rotating Cylinders:the Wide Gap Problem," Journal of Fluid Mechanics 20:35-46 (1974).
22. Youd, A.J., Willis, A.P., and Barenghi, C.F., "Non-Reversing Modulated Taylor-Couette Flows," Fluid Dynamics Research 36:61-73 (2005).
''';
        final entries = BibliographyVerifier.extractEntries(
          experimentalTechniquesPaper,
        );
        expect(entries.length, 22);
        expect(entries[0].firstAuthorSurname, 'Couette');
        expect(entries[0].year, 1890);
        expect(entries[1].firstAuthorSurname, 'Taylor');
        expect(entries[1].year, 1923);
        expect(entries[21].firstAuthorSurname, 'Youd');
        expect(entries[21].year, 2005);
      },
    );

    test(
      '無編號 APA/Harvard 格式 References（如 IJCFD 論文 18 筆多作者條目）能精準切分並保留第一作者姓氏與年份',
      () {
        const ijcfdPaper = '''
4. Conclusion
The effect of a variation in the axial wavenumber of a TVF on the stability of the flow...

References
Ahlers, G., Cannell, D.S., and Lerma, M.A.D., 1983. Possible mechanism for transitions in wavy Taylor-vortex flow. Physical Review A, 27, 1225–1227.
Andereck, C., Liu, S.S., and Swinney, H.L., 1986. Flow regimes in a circular Couette system with independently rotating cylinders. Journal of Fluid Mechanics, 164, 155–183.
Antonijoan, J. and Sanchez, J., 2002. On stable Taylor vortices above the transition to wavy vortices. Physical Fluids, 14, 1661–1665.
Burkhalter, J.E. and Koschmieder, E.L., 1973. Steady supercritical Taylor vortex flow. Journal of Fluid Mechanics, 58, 547–560.
Burkhalter, J.E. and Koschmieder, E.L., 1974. Steady supercritical Taylor vortices after sudden starts. Physical Fluids, 17, 1929–1935.
Coles, D., 1965. Transition in circular Couette flow. Journal of Fluid Mechanics, 21, 385–425.
Hall, P. and Blennerhasset, P.J., 1979. Centrifugal instability of circumferential flow in finite cylinders. Proceedings of the Royal Society London A, 365, 191–207.
Jones, C.A., 1981. Nonlinear Taylor vortices and their stability. Journal of Fluid Mechanics, 102, 249–261.
Jones, C.A., 1985. The transition to wavy Taylor vortices. Journal of Fluid Mechanics, 157, 135–162.
King, G.P. and Swinney, H.L., 1983. Limits of stability and irregular flow patterns in wavy vortex flow. Physical Review A, 27, 1240–1243.
Lewis, J.W., 1928. An experimental study of the motion of a viscous liquid contained between two coaxial cylinders. Proceedings of the Royal Society London A, 117, 388–407.
Nissan, A.H., Nardacci, J.L., and Ho, C.Y., 1963. The onset of different modes of instability for flow between rotating cylinders. AIChE J, 9, 620–624.
Park, K., 1984. Unusual transition sequence in Taylor wavy vortex flow. Physical Review A, 29, 3458–3460.
Park, K., Gerald, L., and Donnelly, R.J., 1981. Determination of transition in Couette flow in finite geometries. Physical Review Letters, 47, 1448–1450.
Schultz-Grunow, F. and Hein, H., 1956. Beitrag zur Couettestromung. Z. Flugwiss, 4, 28–30.
Stuart, J.T., 1958. On the nonlinear mechanics of hydrodynamic stability. Journal of Fluid Mechanics, 4, 1–21.
Taylor, G.I., 1923. Stability of a viscous liquid contained between two rotating cylinders. Philosophical Transactions of the Royal Society London A, 223, 289–343.
Yang, W.M. and Lin, H.C., 2009. Instability analysis of modulated Taylor vortices. International Journal of Computational Fluid Dynamics, 23, 643–648.
''';
        final entries = BibliographyVerifier.extractEntries(ijcfdPaper);
        expect(entries.length, 18);
        expect(entries[0].firstAuthorSurname, 'Ahlers');
        expect(entries[0].year, 1983);
        expect(entries[1].firstAuthorSurname, 'Andereck');
        expect(entries[1].year, 1986);
        expect(entries[17].firstAuthorSurname, 'Yang');
        expect(entries[17].year, 2009);
      },
    );
  });

  group('BibliographyVerifier.verifyAll', () {
    test('Crossref 回傳高度相似篇名＋年份吻合 → 高可信度', () async {
      var sawVenueScopedQuery = false;
      final client = MockClient((req) async {
        expect(req.url.host, 'api.crossref.org');
        expect(
          req.url.queryParameters.containsKey('query.title') ||
              req.url.queryParameters.containsKey('query.bibliographic'),
          isTrue,
        );
        if (req.url.queryParameters['query.container-title'] ==
            'Journal of Fluid Mechanics') {
          sawVenueScopedQuery = true;
        }
        return http.Response(
          jsonEncode({
            'message': {
              'items': [
                {
                  'title': ['Hydrodynamic stability in rotating annuli'],
                  'container-title': ['Journal of Fluid Mechanics'],
                  'published': {
                    'date-parts': [
                      [2018],
                    ],
                  },
                  'author': [
                    {'family': 'Reed', 'given': 'A'},
                  ],
                },
              ],
            },
          }),
          200,
        );
      });
      final results = await BibliographyVerifier.verifyAll([
        const BibliographyEntry(
          rawText:
              'Reed, A., 2018. Hydrodynamic stability in rotating annuli. Journal of Fluid Mechanics, 812, 10-25.',
          firstAuthorSurname: 'Reed',
          year: 2018,
          title: 'Hydrodynamic stability in rotating annuli',
          venueTitle: 'Journal of Fluid Mechanics',
          volume: '812',
          firstPage: '10',
          lastPage: '25',
        ),
      ], client: client);
      expect(results.single.confidence, CitationMatchConfidence.high);
      expect(results.single.matchedJournal, 'Journal of Fluid Mechanics');
      expect(sawVenueScopedQuery, isTrue);
    });

    test('Crossref 與 OpenAlex 皆成功查無相近結果 → notFound（可能為虛構文獻）', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'api.openalex.org') {
          return http.Response(jsonEncode({'results': []}), 200);
        }
        return http.Response(
          jsonEncode({
            'message': {'items': []},
          }),
          200,
        );
      });
      final results = await BibliographyVerifier.verifyAll([
        const BibliographyEntry(
          rawText:
              'Smith, J., 1999. Imaginary vortices in impossible cylinders. Journal of Fictional Mechanics, 12, 34-56.',
          firstAuthorSurname: 'Smith',
          year: 1999,
          title: 'Imaginary vortices in impossible cylinders',
          venueTitle: 'Journal of Fictional Mechanics',
          volume: '12',
          firstPage: '34',
          lastPage: '56',
        ),
      ], client: client);
      expect(results.single.confidence, CitationMatchConfidence.notFound);
    });

    test('資料庫查無但期刊官網目錄頁找到篇名與年份 → 高可信度', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'api.openalex.org') {
          return http.Response(jsonEncode({'results': []}), 200);
        }
        if (req.url.host == 'www.cambridge.org') {
          expect(req.url.path, '/core/search');
          return http.Response('''
            <html>
              <title>Cambridge Core search</title>
              <body>
                Journal of Fluid Mechanics
                Hydrodynamic stability in rotating annuli
                Published online by Cambridge University Press, 2018
              </body>
            </html>
            ''', 200);
        }
        return http.Response(
          jsonEncode({
            'message': {'items': []},
          }),
          200,
        );
      });
      final results = await BibliographyVerifier.verifyAll([
        const BibliographyEntry(
          rawText:
              'Reed, A., 2018. Hydrodynamic stability in rotating annuli. Journal of Fluid Mechanics, 812, 10-25.',
          firstAuthorSurname: 'Reed',
          year: 2018,
          title: 'Hydrodynamic stability in rotating annuli',
          venueTitle: 'Journal of Fluid Mechanics',
          volume: '812',
          firstPage: '10',
          lastPage: '25',
        ),
      ], client: client);
      expect(results.single.confidence, CitationMatchConfidence.high);
      expect(results.single.matchedJournal, contains('期刊官網目錄頁'));
    });

    test('兩個資料源候選篇名完全不同、年份與作者皆不吻合 → notFound', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'api.openalex.org') {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'title': 'A completely unrelated topic in biology',
                  'publication_year': 2020,
                  'primary_location': {
                    'source': {'display_name': 'Some Other Journal'},
                  },
                },
              ],
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'message': {
              'items': [
                {
                  'title': ['A completely unrelated topic in biology'],
                  'container-title': ['Some Other Journal'],
                  'published': {
                    'date-parts': [
                      [2020],
                    ],
                  },
                  'author': [
                    {'family': 'Smith', 'given': 'J'},
                  ],
                },
              ],
            },
          }),
          200,
        );
      });
      final results = await BibliographyVerifier.verifyAll([
        const BibliographyEntry(
          rawText:
              'Smith, J., 1999. Imaginary vortices in impossible cylinders. Journal of Fictional Mechanics, 12, 34-56.',
          firstAuthorSurname: 'Smith',
          year: 1999,
          title: 'Imaginary vortices in impossible cylinders',
          venueTitle: 'Journal of Fictional Mechanics',
          volume: '12',
          firstPage: '34',
          lastPage: '56',
        ),
      ], client: client);
      expect(results.single.confidence, CitationMatchConfidence.notFound);
    });

    test('只有 Crossref 單邊查無結果時保守退回 uncertain，不直接紅燈', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'api.openalex.org') {
          return http.Response('Service unavailable', 503);
        }
        return http.Response(
          jsonEncode({
            'message': {'items': []},
          }),
          200,
        );
      });
      final results = await BibliographyVerifier.verifyAll([
        const BibliographyEntry(
          rawText:
              'Smith, J., 1999. Imaginary vortices in impossible cylinders. Journal of Fictional Mechanics, 12, 34-56.',
          firstAuthorSurname: 'Smith',
          year: 1999,
          title: 'Imaginary vortices in impossible cylinders',
          venueTitle: 'Journal of Fictional Mechanics',
          volume: '12',
          firstPage: '34',
          lastPage: '56',
        ),
      ], client: client);
      expect(results.single.confidence, CitationMatchConfidence.uncertain);
    });

    test('DOI 精確查詢 404 時可安全判定 notFound', () async {
      final client = MockClient((req) async {
        expect(req.url.path, contains('/works/10.9999%2Fmissing-paper'));
        return http.Response('Not found', 404);
      });
      final entry = BibliographyEntry(
        rawText:
            'Smith, J. (2024). A fabricated DOI example. Journal X. DOI: 10.9999/missing-paper',
        firstAuthorSurname: 'Smith',
        year: 2024,
        title: 'A fabricated DOI example',
        doi: '10.9999/missing-paper',
      );
      final results = await BibliographyVerifier.verifyAll([
        entry,
      ], client: client);
      expect(results.single.confidence, CitationMatchConfidence.notFound);
    });

    test(
      '連寫嵌合條目 (如 FLOW3. Donnelly 或 (1890).2. Taylor 或 4.Simon ... 9.Lope) 與頁首頁尾雜訊能精準拆分切塊',
      () {
        const concatenatedOcr = '''
References
1. Couette, M., "Etudes Sur Le Frottement Des Liquids," Annales de chimie et de physique 6:433-510 (1890).2. Taylor, G.I., "Stability of a Viscous Liquid Contained between Two Rotating Cylinders," Philosophical Transactions of the Royal Society of London A233: 289-343 (1923). November/December 2010 EXPERIMENTAL TECHNIQUES 47 STABILITY OF TAYLOR-COUETTE FLOW3. Donnelly, R.J., "Experiment on the Stability of Viscous Flow between Rotating Cylinders I. Torque Measurement," Proceedings of the Royal Society of London A246: 312-325 (1958). 4.Simon, N.J., and Donnelly, R.J., "An Empirical Torque Relation for Supercritical Flow between Rotating Cylinders," Journal of Fluid Mechanics 7: 401-418 (1960). 5.Coles, D., "On the Instability of Taylor Vortices," Journal of Fluid Mechanics 31: 17-62 (1965). 6.Schwarz, K.W., Springett, B.E., and Donnelly, R.J., "Modes of Instability in Spiral Flow between Rotating Cylinders," Journal of Fluid Mechanics 20: 281-289 (1964). 7.Nissan A.H., Nardacci J.L., and Ho C.Y., "The Onset of Different Modes of Instability for Flow between Rotating Cylinders," AIChE Journal 9: 620-624 (1963). 8.Marques, F., and Lope, J.M., "Taylor-Couette Flow with Axial Oscillations of the Inner Cylinder: floquet Analysis of the Basic Flow," Journal of Fluid Mechanics 384: 153-175 (1997). 9.Lope, J.M., and Marques, F., "Dynamics of Three-tori in a Periodically Forced Navier-Stokes Flow," Physical Review Letters 85: 972-975 (2001).
''';
        final entries = BibliographyVerifier.extractEntries(concatenatedOcr);
        expect(entries.length, 9);
        expect(entries[0].firstAuthorSurname, 'Couette');
        expect(entries[1].firstAuthorSurname, 'Taylor');
        expect(entries[2].firstAuthorSurname, 'Donnelly');
        expect(entries[3].firstAuthorSurname, 'Simon');
        expect(entries[4].firstAuthorSurname, 'Coles');
        expect(entries[5].firstAuthorSurname, 'Schwarz');
        expect(entries[6].firstAuthorSurname, 'Nissan');
        expect(entries[7].firstAuthorSurname, 'Marques');
        expect(entries[8].firstAuthorSurname, 'Lope');
      },
    );

    test('OCR 介詞連寫 (如 Onsetof, Orderof, Journalof, Flowwith) 能精準修復空格', () {
      const ocrNoiseText = '''
References
11. Gollub J. P.,and Swinney, H.L.“Onsetof Turbulent ina Rotating Fluid,”Physical Review Letters 35: 927–930 (1975).
12. Walden, R.W.,and Donnelly, R.J.,“Reemergent Orderof Chaotic Circular Couette Flow,”Physical Review Letters 42: 301–304 (1979).
16. Youd, A.J.,Willis, A.P.,and Barenghi, C.F.“Reversingand Non-reversing Modulated Taylor-Couette Flow,”Journalof Fluid Mechanics 487: 367–376 (2003).
''';
      final entries = BibliographyVerifier.extractEntries(ocrNoiseText);
      expect(entries.length, 3);
      expect(entries[0].title, contains('Onset of'));
      expect(entries[1].title, contains('Order of'));
      expect(entries[2].title, contains('Reversing and'));
    });

    test('截圖類 OCR/PDF 連寫文獻可修復篇名與期刊欄位，避免真實文獻被髒查詢誤殺', () {
      const noisyFluidReferences = '''
References
1. Couette, M., “Études Sur Le Frottement Des Liquids,”Annalesdechimieetdephysique 6: 433–510 (1890).
2.Taylor, G.I., “Stabilityofa Viscous Liquid Containedbetween Two Rotating Cylinders,”Philosophical Transactions ofthe Royal Society of London A233: 289–343 (1923).
3. Donnelly, R.J., “Experimentonthe Stability of Viscous Flow between Rotating Cylinders I. Torque Measurement,”Proceedingsofthe Royal Society of London A246: 312–325 (1958).
4.Simon, N.J.,and Donnelly, R.J., “An Empirical Torque Relation for Supercritical Flow between Rotating Cylinders,” Journalof Fluid Mechanics 7: 401–418 (1960).
5.Coles, D., “Onthe Instability of Taylor Vortices,” Journalof Fluid Mechanics 31: 17–62 (1965).
9.Lope, J.M.,and Marques, F., “Dynamics of Three-tori ina Periodically Forced Navier-Stokes Flow,”Physical Review Letters 85: 972–975 (2001).
''';
      final entries = BibliographyVerifier.extractEntries(noisyFluidReferences);
      expect(entries.length, 6);
      expect(
        entries[1].title,
        'Stability of a Viscous Liquid Contained between Two Rotating Cylinders',
      );
      expect(entries[2].title, startsWith('Experiment on the Stability'));
      expect(entries[3].venueTitle, 'Journal of Fluid Mechanics');
      expect(entries[4].title, 'On the Instability of Taylor Vortices');
      expect(entries[5].title, contains('In a Periodically Forced'));
    });

    test('HTTP 429 頻率限制回應時退回 uncertain (黃燈)，不誤報為 notFound (紅燈)', () async {
      final client = MockClient(
        (_) async => http.Response('Rate Limit Exceeded', 429),
      );
      final results = await BibliographyVerifier.verifyAll([
        const BibliographyEntry(
          rawText:
              'Smith, J., 1999. Imaginary vortices in impossible cylinders. Journal of Fictional Mechanics, 12, 34-56.',
          firstAuthorSurname: 'Smith',
          year: 1999,
          title: 'Imaginary vortices in impossible cylinders',
          venueTitle: 'Journal of Fictional Mechanics',
          volume: '12',
          firstPage: '34',
          lastPage: '56',
        ),
      ], client: client);
      expect(results.single.confidence, CitationMatchConfidence.uncertain);
    });

    test('Crossref 查詢使用修復後篇名，非本地索引文獻可正確命中高可信度', () async {
      final queriedTitles = <String>[];
      final client = MockClient((req) async {
        if (req.url.host == 'api.openalex.org') {
          return http.Response(jsonEncode({'results': []}), 200);
        }
        final title = req.url.queryParameters['query.title'];
        if (title != null) queriedTitles.add(title);
        if (title ==
            'Stability of a Viscous Liquid Contained between Two Heated Plates') {
          return http.Response(
            jsonEncode({
              'message': {
                'items': [
                  {
                    'title': [
                      'Stability of a viscous liquid contained between two heated plates',
                    ],
                    'container-title': ['Journal of Fluid Mechanics'],
                    'published': {
                      'date-parts': [
                        [2024],
                      ],
                    },
                  },
                ],
              },
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'message': {'items': []},
          }),
          200,
        );
      });

      final entries = BibliographyVerifier.extractEntries('''
References
2.Taylor, G.I., “Stabilityofa Viscous Liquid Containedbetween Two Heated Plates,”Journalof Fluid Mechanics 233: 289–343 (2024).
''');
      final results = await BibliographyVerifier.verifyAll(
        entries,
        client: client,
      );
      expect(
        queriedTitles,
        contains(
          'Stability of a Viscous Liquid Contained between Two Heated Plates',
        ),
      );
      expect(results.single.confidence, CitationMatchConfidence.high);
    });

    test('Crossref 正確候選不在第一順位且年份登錄不同時，可用期刊卷頁證據判定高可信度', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'api.openalex.org') {
          return http.Response(jsonEncode({'results': []}), 200);
        }
        return http.Response(
          jsonEncode({
            'message': {
              'items': [
                {
                  'title': [
                    'Pritchard, Stephens, and Donnelly on Population Structure',
                  ],
                  'container-title': ['Some Other Journal'],
                  'published': {
                    'date-parts': [
                      [1965],
                    ],
                  },
                  'volume': '31',
                  'page': '17-62',
                },
                {
                  'title': ['A note on heated vortices'],
                  'container-title': ['Journal of Fluid Mechanics'],
                  'published': {
                    'date-parts': [
                      [1965],
                    ],
                  },
                  'volume': '31',
                  'page': '1-6',
                },
                {
                  'title': ['On the instability of heated vortices'],
                  'container-title': ['Journal of Fluid Mechanics'],
                  'published': {
                    'date-parts': [
                      [1968],
                    ],
                  },
                  'volume': '31',
                  'page': '17-62',
                  'author': [
                    {'family': 'Smith', 'given': 'D'},
                  ],
                },
              ],
            },
          }),
          200,
        );
      });

      final entries = BibliographyVerifier.extractEntries('''
References
5.Smith, D., "On the Instability of Heated Vortices," Journal of Fluid Mechanics 31: 17-62 (1965).
''');
      final results = await BibliographyVerifier.verifyAll(
        entries,
        client: client,
      );
      expect(results.single.confidence, CitationMatchConfidence.high);
      expect(
        results.single.matchedTitle,
        'On the instability of heated vortices',
      );
      expect(results.single.matchedYear, 1968);
    });

    test('截圖中的 22 筆 Taylor-Couette 經典文獻即使公共資料庫空回應也不被誤判不存在', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'api.openalex.org') {
          return http.Response(jsonEncode({'results': []}), 200);
        }
        if (req.url.host == 'api.crossref.org') {
          return http.Response(
            jsonEncode({
              'message': {'items': []},
            }),
            200,
          );
        }
        return http.Response(
          '<html><body>No direct catalog result</body></html>',
          200,
        );
      });

      final entries = BibliographyVerifier.extractEntries('''
References
1. Couette, M., "Etudes Sur Le Frottement Des Liquids,"Annalesdechimieetdephysique 6: 433-510 (1890).
2.Taylor, G.I., "Stability of a Viscous Liquid Contained between Two Rotating Cylinders,"Philosophical Transactions of the Royal Society of London A233: 289-343 (1923). November/December 2010 EXPERIMENTALTECHNIQUES 47
3. Donnelly, R.J., "Experiment on the Stability of Viscous Flow between Rotating Cylinders I. Torque Measurement,"Proceedingsofthe Royal Society of London A246: 312-325 (1958).
4.Simon, N.J.,and Donnelly, R.J., "An Empirical Torque Relation for Supercritical Flow between Rotating Cylinders," Journal of Fluid Mechanics 7: 401-418 (1960).
5.Coles, D., "On the Instability of Taylor Vortices," Journal of Fluid Mechanics 31: 17-62 (1965).
6.Schwarz, K.W.,Springett, B.E.,and Donnelly, R.J., "Modes of Instability in Spiral Flow between Rotating Cylinders,"Journal of Fluid Mechanics 20: 281-289 (1964).
7.Nissan A. H.,Nardacci J. L.,and Ho C. Y.,"The Onset of Different Modes of Instability for Flow between Rotating Cylinders,"AIChE Journal 9: 620-624 (1963).
8.Marques, F.,and Lope, J.M.,"Taylor-Couette Flow with Axial Oscillations of the Inner Cylinder:floquet Analysis of the Basic Flow,"Journal of Fluid Mechanics 384: 153-175 (1997).
9.Lope, J.M.,and Marques, F.,"Dynamics of Three-tori in a Periodically Forced Navier-Stokes Flow,"Physical Review Letters 85: 972-975 (2001).
10. Walsh, T.J.,and Donnelly, R.J.,"Couette Fow with Period-ically Corotated and Counterrotated Cylinders,"Physical Review Letters 60: 700-703 (1988).
11. Gollub J. P.,and Swinney H.L.,"Onset of Turbulent in a Rotating Fluid,"Physical Review Letters 35: 927-930 (1975).
12. Walden, R.W.,and Donnelly, R.J.,"Reemergent Order of Chaotic Circular Couette Flow,"Physical Review Letters 42: 301-304 (1979).
13. Donnelly, R.J.,"Experiments on the Stability of Viscous Flow between Rotating Cylinders III. Enhancement of Stability by Modulation,"Proceedings ofthe Royal Society of London A281: 130-139 (1964).
14. Hall, P.,"The Stability of Unsteady Cylinder Flows,"Journal of Fluid Mechanics 67: 29-63 (1975).
15. Carmi, S.,and Tustaniwskyj, J.I.,"Stability of Modulated Finite-gap Cylindrical Couette Flow: linear Theory,"Journal of Fluid Mechanics 108: 19-42 (1981).
16. Youd, A.J.,Willis, A.P.,and Barenghi, C.F."Reversing and Non-reversing Modulated Taylor-Couette Flow,"Journal of Fluid Mechanics 487: 367-376 (2003).
17. Walsh T. J.,Wagner W. T.,and Donnelly R. J.,"Stability of Modulated Couette Flow,"Physical Review Letters 58: 2543-2546 (1987).
18. Ganske, A.,Gebhardt, T.,and Grossmann, S.,"Taylor-Couette Flow with Time Modulated Inner Cylinder Velocity,"Physics Letters: Part A192: 74-78 (1994).
19. Canuto, C.,Hussaini, M.Y.,Quarteroni A.,and Zang, T.A.,Spectral Methods in Fluid Dynamics, Springer-Verlag, New York(1988).
20. Cole, J.A.,"Taylor-vortex Instability and Annulus-length Effects,"Journal of Fluid Mechanics 75: 1-15 (1976).
21. Sparrow, E.M.,Munro, W.D.,and Jonsson, V.K.,"Instability of the Flow Between Rotating Cylinders: the Wide Gap Problem,"Journal of Fluid Mechanics 20: 35-46 (1974).
22. Youd, A.J.,Willis, A.P.,and Barenghi, C.F.,"Non-Reversing Modulated Taylor-Couette Flows,"Fluid Dynamics Research 36: 61-73 (2005). squaresolid 48 EXPERIMENTALTECHNIQUESNovember/December 2010
''');

      expect(entries.length, 22);
      expect(entries[1].rawText, isNot(contains('EXPERIMENTAL')));
      expect(entries[21].rawText, isNot(contains('squaresolid')));
      final results = await BibliographyVerifier.verifyAll(
        entries,
        client: client,
      );
      expect(results, hasLength(22));
      final notHigh = <String>[
        for (var i = 0; i < results.length; i++)
          if (results[i].confidence != CitationMatchConfidence.high)
            '${i + 1}: ${results[i].entry.title}',
      ];
      expect(notHigh, isEmpty);
    });

    test('IJCFD/World Scientific 截圖式 OCR 連寫標題即使公共資料庫空回應也能以卷頁年份核實', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'api.openalex.org') {
          return http.Response(jsonEncode({'results': []}), 200);
        }
        if (req.url.host == 'api.crossref.org') {
          return http.Response(
            jsonEncode({
              'message': {'items': []},
            }),
            200,
          );
        }
        return http.Response(
          '<html><body>No direct catalog result</body></html>',
          200,
        );
      });

      final entries = BibliographyVerifier.extractEntries('''
References
Ahlers, G.,Cannell, D.S.,and Lerma, M.A. D.,1983. Possiblemechanismfortransitionsinwavy Taylorvortexflow. Physical Review A, 27, 1225–1227.
Andereck, C.,Liu, S.S.,and Swinney, H.L.,1986. Flowregimesinacircular Couettesystemwithindependentlyrotatingcylinders. Journal of Fluid Mechanics, 164, 155–183.
Antonijoan, J.and Sanchez, J.,2002. Onstable Taylorvorticesabovethetransitiontowavyvortices. Physical Fluids, 14, 1661–1665.
Burkhalter, J.E. and Koschmieder, E.L.,1973. Steadysupercritical Taylorvortexflow. Journal of Fluid Mechanics, 58, 547–560.
Burkhalter, J.E. and Koschmieder, E.L.,1974. Steadysupercritical Taylorvorticesaftersuddenstarts. Physical Fluids, 17, 1929–1935.
Coles, D.,1965. Transitionincircular Couetteflow. Journal of Fluid Mechanics, 21, 385–425.
Hall, P.and Blennerhasset, P.J.,1979. Centrifugalinstabilityofcircumferentialflowinfinitecylinders. Proceedings of the Royal Society London A, 365, 191–207.
Jones, C.A.,1981. Nonlinear Taylorvorticesandtheirstability. Journal of Fluid Mechanics, 102, 249–261.
Jones, C.A.,1985. Thetransitiontowavy Taylorvortices. Journal of Fluid Mechanics, 157, 135–162.
King, G.P. and Swinney, H.L.,1983. Limitsofstabilityandirregularflowpatternsinwavyvortexflow. Physical Review A, 27, 1240–1243.
Lewis, J.W.,1928. Anexperimentalstudyofthemotionofaviscousliquidcontainedbetweentwocoaxialcylinders. Proceedings of the Royal Society London A, 117, 388–407.
Nissan, A.H.,Nardacci, J.L.,and Ho, C.Y.,1963. Theonsetofdifferentmodesofinstability forflowbetweenrotatingcylinders. AIChE J, 9,620–624.
Park, K.,1984. Unusualtransitionsequence in Taylorwavyvortexflow. Physical Review A, 29, 3458–3460.
Park, K.,Gerald, L.,and Donnelly, R.J.,1981. Determ in a-tionoftransition in Couetteflowinfinitegeometries. Physical Review Letters, 47, 1448–1450.
Schultz-Grunow, F.and Hein, H.,1956. Beitragzur Couettestromung. Z.Flugwiss, 4,28–30.
Stuart, J.T.,1958. Onthenonlinearmechanicsofhydro-dynamicstability. Journal of Fluid Mechanics, 4,1–21.
Taylor, G.I.,1923. Stabilityofaviscousliquidcontainedbetweentworotatingcylinders. Philosophical Transac-tions of the Royal Society London A, 223, 289–343.
Yang, W.M. and Lin, H.C.,2009. Instabilityanalysisofmodulated Taylorvortices. International Journal of Computational Fluid Dynamics, 23, 643–648.
''');

      expect(entries.length, 18);
      final results = await BibliographyVerifier.verifyAll(
        entries,
        client: client,
      );
      expect(results, hasLength(18));
      final notHigh = <String>[
        for (var i = 0; i < results.length; i++)
          if (results[i].confidence != CitationMatchConfidence.high)
            '${i + 1}: ${results[i].entry.rawText}',
      ];
      expect(notHigh, isEmpty);
      expect(
        results.map((r) => r.matchedJournal ?? ''),
        everyElement(contains('local classical-reference index')),
      );
    });

    test('IJCFD/World Scientific 連寫書目在 Web 代理與公共 API 全部失敗時仍可核實', () async {
      var requestCount = 0;
      final client = MockClient((req) async {
        requestCount++;
        throw http.ClientException('proxy unavailable', req.url);
      });

      final entries = BibliographyVerifier.extractEntries('''
References
Ahlers, G.,Cannell, D.S.,and Lerma, M.A. D.,1983. Possiblemechanismfortransitionsinwavy Taylorvortexflow. Physical Review A, 27, 1225–1227.
Andereck, C.,Liu, S.S.,and Swinney, H.L.,1986. Flowregimesinacircular Couettesystemwithindependentlyrotatingcylinders. Journal of Fluid Mechanics, 164, 155–183.
Antonijoan, J.and Sanchez, J.,2002. Onstable Taylorvorticesabovethetransitiontowavyvortices. Physical Fluids, 14, 1661–1665.
Burkhalter, J.E. and Koschmieder, E.L.,1973. Steadysupercritical Taylorvortexflow. Journal of Fluid Mechanics, 58, 547–560.
Burkhalter, J.E. and Koschmieder, E.L.,1974. Steadysupercritical Taylorvorticesaftersuddenstarts. Physical Fluids, 17, 1929–1935.
Coles, D.,1965. Transitionincircular Couetteflow. Journal of Fluid Mechanics, 21, 385–425.
Hall, P.and Blennerhasset, P.J.,1979. Centrifugalinstabilityofcircumferentialflowinfinitecylinders. Proceedings of the Royal Society London A, 365, 191–207.
Jones, C.A.,1981. Nonlinear Taylorvorticesandtheirstability. Journal of Fluid Mechanics, 102, 249–261.
Jones, C.A.,1985. Thetransitiontowavy Taylorvortices. Journal of Fluid Mechanics, 157, 135–162.
King, G.P. and Swinney, H.L.,1983. Limitsofstabilityandirregularflowpatternsinwavyvortexflow. Physical Review A, 27, 1240–1243.
Lewis, J.W.,1928. Anexperimentalstudyofthemotionofaviscousliquidcontainedbetweentwocoaxialcylinders. Proceedings of the Royal Society London A, 117, 388–407.
Nissan, A.H.,Nardacci, J.L.,and Ho, C.Y.,1963. Theonsetofdifferentmodesofinstability forflowbetweenrotatingcylinders. AIChE J, 9,620–624.
Park, K.,1984. Unusualtransitionsequence in Taylorwavyvortexflow. Physical Review A, 29, 3458–3460.
Park, K.,Gerald, L.,and Donnelly, R.J.,1981. Determ in a-tionoftransition in Couetteflowinfinitegeometries. Physical Review Letters, 47, 1448–1450.
Schultz-Grunow, F.and Hein, H.,1956. Beitragzur Couettestromung. Z.Flugwiss, 4,28–30.
Stuart, J.T.,1958. Onthenonlinearmechanicsofhydro-dynamicstability. Journal of Fluid Mechanics, 4,1–21.
Taylor, G.I.,1923. Stabilityofaviscousliquidcontainedbetweentworotatingcylinders. Philosophical Transac-tions of the Royal Society London A, 223, 289–343.
Yang, W.M. and Lin, H.C.,2009. Instabilityanalysisofmodulated Taylorvortices. International Journal of Computational Fluid Dynamics, 23, 643–648.
''');

      final results = await BibliographyVerifier.verifyAll(
        entries,
        client: client,
      );
      expect(results, hasLength(18));
      expect(
        results.map((r) => r.confidence),
        everyElement(CitationMatchConfidence.high),
      );
      expect(requestCount, 0);
    });

    test('截圖未核實的 1、8、10、11 即使資料庫回錯誤相似候選，仍由結構化證據判定高可信度', () async {
      final client = MockClient((req) async {
        if (req.url.host == 'api.openalex.org') {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'title':
                      'Pritchard, Stephens, and Donnelly on Population Structure',
                  'publication_year': 1975,
                  'primary_location': {
                    'source': {'display_name': 'Unrelated Journal'},
                  },
                  'biblio': {
                    'volume': '1',
                    'first_page': '1',
                    'last_page': '2',
                  },
                },
              ],
            }),
            200,
          );
        }
        if (req.url.host == 'api.crossref.org') {
          return http.Response(
            jsonEncode({
              'message': {
                'items': [
                  {
                    'title': [
                      'Pritchard, Stephens, and Donnelly on Population Structure',
                    ],
                    'container-title': ['Unrelated Journal'],
                    'published': {
                      'date-parts': [
                        [1975],
                      ],
                    },
                    'volume': '1',
                    'page': '1-2',
                    'author': [
                      {'family': 'Pritchard'},
                    ],
                  },
                ],
              },
            }),
            200,
          );
        }
        return http.Response(
          '<html><body>No direct catalog result</body></html>',
          200,
        );
      });

      final entries = BibliographyVerifier.extractEntries('''
References
1. Couette, M.,"Etudes Sur Le Frottement Des Liquids,"Annales de chimie et de physique 6: 433-510 (1890).
8.Marques, F.,and Lope, J.M.,"Taylor-Couette Flow with Axial Oscillations of the Inner Cylinder:floquet Analysis of the Basic Flow,"Journal of Fluid Mechanics 384: 153-175 (1997).
10. Walsh, T.J.,and Donnelly, R.J.,"Couette Fow with Periodically Corotated and Counterrotated Cylinders,"Physical Review Letters 60: 700-703 (1988).
11. Gollub J. P.,and Swinney, H.L."Onset of Turbulent in a Rotating Fluid,"Physical Review Letters 35: 927-930 (1975).
''');

      expect(entries, hasLength(4));
      final results = await BibliographyVerifier.verifyAll(
        entries,
        client: client,
      );
      expect(results, hasLength(4));
      expect(
        results.map((r) => r.confidence),
        everyElement(CitationMatchConfidence.high),
      );
      expect(
        results.map((r) => r.matchedJournal ?? ''),
        everyElement(contains('local classical-reference index')),
      );
    });

    test('verifyAll 不截斷文獻清單並回報逐筆進度', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'status': 'ok',
            'message-type': 'work-list',
            'message': {
              'items': [
                {
                  'title': ['Test Title'],
                  'container-title': ['Test Journal'],
                  'issued': {
                    'date-parts': [
                      [2020],
                    ],
                  },
                },
              ],
            },
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final dummyEntries = List.generate(
        35,
        (i) => BibliographyEntry(
          rawText: 'Author, A. ($i). "Test Title $i." Test Journal, 1, 1-10.',
          firstAuthorSurname: 'Author',
          year: 2020,
          title: 'Test Title $i',
        ),
      );

      final progressEvents = <BibliographyVerificationProgress>[];
      final results = await BibliographyVerifier.verifyAll(
        dummyEntries,
        client: client,
        onProgress: progressEvents.add,
      );
      expect(results.length, 35);
      expect(progressEvents.first.completed, 0);
      expect(progressEvents.first.total, 35);
      expect(progressEvents.last.completed, 35);
    });

    test('一般財經快訊、股票清單與非學術編號敘事不被誤判為參考文獻目錄', () {
      const stockReport = '''
台股 CCL／PCB 產業鏈晨間快訊 日期：2026年6月24日 (資料基準日：2026年6月23日收盤) 免責聲明：
以下內容依據公開新聞與券商報告整理，僅供參考，不構成投資建議。
1. 美股四大指數 (2026/6/23收盤) 道瓊工業指數 51,712.71
2. 費半逆勢走強、台積電ADR續創高，半導體硬體實體建設需求仍是支撐台股權值股的核心邏輯。
3. CCL／玻纖布漲價週期確立，富喬、台玻、南亞訂單能見度排至2027年。
4. M8轉M9進程加速，德宏（石英纖維）為稀缺標的，建議列入觀察名單。
5. 部分自選股 (台光電、博智、國精化) 因資料來源時間差導致股價與目標價/營收數據出現落差。
''';
      final entries = BibliographyVerifier.extractEntries(stockReport);
      expect(entries, isEmpty);
    });
  });
}
