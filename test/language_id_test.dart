import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/perplexity_calibration.dart';
import 'package:truthlens/core/utils/language_id.dart';

void main() {
  group('文字系統判定', () {
    test('中文', () {
      expect(
        detectLanguage(
          '本研究採用泰勒庫埃特流場作為實驗載體，透過改變內外圓筒的轉速比，'
          '觀察環狀渦漩在臨界雷諾數附近的形態轉換過程與穩定性邊界的變化。',
        ).code,
        'zh',
      );
    });

    test('日文靠假名與中文區分（同樣使用漢字）', () {
      expect(
        detectLanguage('本研究では、テイラー・クエット流れを実験対象として、内外円筒の回転比を変化させました。').code,
        'ja',
      );
    });

    test('韓文', () {
      expect(
        detectLanguage('본 연구는 테일러 쿠에트 유동을 실험 대상으로 삼아 내외 원통의 회전비를 변화시켰습니다.').code,
        'ko',
      );
    });

    test('泰文', () {
      expect(
        detectLanguage('การศึกษานี้ใช้การไหลแบบเทย์เลอร์-คูเอตต์เป็นตัวกลางในการทดลองและเปลี่ยนอัตราส่วนการหมุน').code,
        'th',
      );
    });

    test('俄文', () {
      expect(
        detectLanguage('В настоящем исследовании течение Тейлора-Куэтта использовалось в качестве экспериментальной среды.').code,
        'ru',
      );
    });
  });

  group('拉丁語系以功能詞剖面細分', () {
    test('英文', () {
      expect(
        detectLanguage(
          'The lowest stability boundary on the flow of concentric rotating '
          'cylinders was examined across a range of radius ratios, and the '
          'results are compared with the predictions that follow from the '
          'linear theory of the problem as it is usually stated.',
        ).code,
        'en',
      );
    });

    test('法文不會被誤判為英文', () {
      expect(
        detectLanguage(
          "La limite de stabilité la plus basse de l'écoulement entre des "
          'cylindres concentriques en rotation a été examinée pour une gamme '
          'de rapports de rayons, et les résultats sont comparés avec les '
          'prédictions de la théorie linéaire du problème.',
        ).code,
        'fr',
      );
    });

    test('德文不會被誤判為英文', () {
      expect(
        detectLanguage(
          'Die niedrigste Stabilitätsgrenze der Strömung zwischen konzentrisch '
          'rotierenden Zylindern wurde für einen Bereich von Radienverhältnissen '
          'untersucht, und die Ergebnisse werden mit den Vorhersagen der '
          'linearen Theorie des Problems verglichen.',
        ).code,
        'de',
      );
    });
  });

  group('判不出來就明說，不猜', () {
    test('太短的輸入', () {
      expect(detectLanguage('Hello').isUndetermined, isTrue);
      expect(detectLanguage('   ').isUndetermined, isTrue);
    });

    test('書目清單／表格這類功能詞稀薄的內容', () {
      expect(
        detectLanguage(
          'Taylor G I 1923 Phil Trans R Soc A 223 289 '
          'Donnelly R J 1991 Phys Today 44 32 '
          'Andereck C D Liu S S Swinney H L 1986 J Fluid Mech 164 155 '
          'Coles D 1965 J Fluid Mech 21 385 Chandrasekhar S 1961 Oxford',
        ).isUndetermined,
        isTrue,
      );
    });

    test('印馬近親語言咬得太緊時不強行分邊', () {
      final result = detectLanguage(
        'Kajian ini menggunakan aliran Taylor-Couette sebagai medium eksperimen '
        'dan mengubah nisbah putaran silinder dalam dan luar untuk melihat '
        'peralihan bentuk pusaran di dalam sistem yang dikaji ini dengan teliti.',
      );
      expect(['ms', 'id', 'und'], contains(result.code));
    });
  });

  group('校準表', () {
    test('英文有可用門檻', () {
      final cal = PerplexityCalibration.of('en');
      expect(cal, isNotNull);
      expect(cal!.aiCut, 60);
      expect(cal.humanCut, 150);
    });

    test('中文量測過但可分性不足，不得採用', () {
      expect(PerplexityCalibration.hasRecord('zh'), isTrue);
      expect(PerplexityCalibration.of('zh'), isNull);
    });

    test('尚未量測的語言查不到，呼叫端必須棄權', () {
      for (final code in ['ja', 'ko', 'th', 'ru', 'ar', 'hi', 'fr', 'de']) {
        expect(PerplexityCalibration.of(code), isNull, reason: code);
        expect(PerplexityCalibration.hasRecord(code), isFalse, reason: code);
      }
    });

    test('無法判定語言時同樣棄權', () {
      expect(PerplexityCalibration.of(DetectedLanguage.undetermined), isNull);
    });

    test('可用語言清單目前只有英文', () {
      expect(PerplexityCalibration.usableLanguages, ['en']);
    });
  });
}
