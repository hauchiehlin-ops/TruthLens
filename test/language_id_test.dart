import 'dart:convert';
import 'dart:io';

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
        detectLanguage(
          '본 연구는 테일러 쿠에트 유동을 실험 대상으로 삼아 내외 원통의 회전비를 변화시켰습니다.',
        ).code,
        'ko',
      );
    });

    test('泰文', () {
      expect(
        detectLanguage(
          'การศึกษานี้ใช้การไหลแบบเทย์เลอร์-คูเอตต์เป็นตัวกลางในการทดลองและเปลี่ยนอัตราส่วนการหมุน',
        ).code,
        'th',
      );
    });

    test('俄文', () {
      expect(
        detectLanguage(
          'В настоящем исследовании течение Тейлора-Куэтта использовалось в качестве экспериментальной среды.',
        ).code,
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

    // 以下四項對應 M4GT 多語語料上量到的結構性錯誤：只看文字系統會把
    // 保加利亞文全判成俄文、烏爾都文全判成阿拉伯文，而義大利文與印尼文
    // 因為缺剖面／近親互鎖幾乎全數棄權。
    test('保加利亞文不會因共用西里爾字母而被判成俄文', () {
      final result = detectLanguage(
        'Настоящото изследване разглежда прехода към турбулентност в потока '
        'между два коаксиални цилиндъра и се съсредоточава върху ъгловата '
        'скорост като основен параметър, който определя формата на вихрите.',
      );
      expect(result.code, 'bg');
    });

    test('俄文仍判為俄文，不被保加利亞文的規則搶走', () {
      final result = detectLanguage(
        'Это исследование рассматривает переход к турбулентности в потоке '
        'между двумя коаксиальными цилиндрами и сосредоточено на угловой '
        'скорости, которая определяет форму вихрей в этой системе.',
      );
      expect(result.code, 'ru');
    });

    test('烏爾都文不會因共用阿拉伯字母而被判成阿拉伯文', () {
      final result = detectLanguage(
        'یہ تحقیق دو ہم محور سلنڈروں کے درمیان بہاؤ میں اضطراب کی طرف منتقلی '
        'کا جائزہ لیتی ہے اور زاویائی رفتار پر توجہ مرکوز کرتی ہے جو اس نظام '
        'میں بھنوروں کی شکل کا تعین کرتی ہے۔',
      );
      expect(result.code, 'ur');
    });

    test('阿拉伯文仍判為阿拉伯文', () {
      final result = detectLanguage(
        'يتناول هذا البحث الانتقال إلى الاضطراب في التدفق بين أسطوانتين '
        'متحدتي المحور، مع التركيز على السرعة الزاوية التي تحدد شكل '
        'الدوامات في هذا النظام على أن تكون النتائج قابلة للتكرار.',
      );
      expect(result.code, 'ar');
    });

    test('義大利文有自己的剖面，不再被誤判為西班牙文', () {
      final result = detectLanguage(
        'Questo studio esamina la transizione alla turbolenza nel flusso che '
        'si sviluppa tra due cilindri coassiali e si concentra sulla velocità '
        'angolare, che è il parametro più importante perché determina la '
        'forma dei vortici quando il sistema viene perturbato.',
      );
      expect(result.code, 'it');
    });

    test('印尼文可由正字法對照詞分出，不再一律棄權', () {
      final result = detectLanguage(
        'Penelitian ini bisa menjelaskan peralihan menuju turbulensi karena '
        'kecepatan sudut yang diukur pada setiap tahap, yaitu parameter utama '
        'yang menentukan bentuk pusaran dalam sistem tersebut saja.',
      );
      expect(result.code, 'id');
    });

    test('馬來文同樣可由正字法對照詞分出', () {
      final result = detectLanguage(
        'Kajian ini ialah usaha menjelaskan peralihan menuju gelora kerana '
        'halaju sudut yang diukur pada setiap peringkat, iaitu parameter utama '
        'yang menentukan bentuk pusaran dalam sistem itu sahaja.',
      );
      expect(result.code, 'ms');
    });
  });

  group('校準表', () {
    test('英文有可用門檻', () {
      final cal = PerplexityCalibration.of('en');
      expect(cal, isNotNull);
      expect(cal!.aiCut, 60);
      // humanCut 已停用：高困惑度不再作為人類證據
      expect(cal.humanCut, isNull);
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

    test('換模型後中文才有可用門檻，且與現行模型互不干擾', () {
      // 現行 DistilGPT2 對中文的區別力為 0，Qwen 量到 0.965。
      // 同一個語言、不同模型，門檻完全不同——這正是要用兩層表的原因。
      expect(PerplexityCalibration.of('zh'), isNull);

      final qwenZh = PerplexityCalibration.of(
        'zh',
        modelId: 'qwen05b-ppl-int8',
      );
      expect(qwenZh, isNotNull);
      expect(qwenZh!.auc, greaterThan(PerplexityThresholds.minimumUsableAuc));
      // 人類側已停用（見「高困惑度不得再充當人類證據」），
      // 因此這裡只確認 AI 側的門檻仍在
      expect(qwenZh.aiCut, greaterThan(0));
      expect(qwenZh.hasHumanSideEvidence, isFalse);

      expect(
        PerplexityCalibration.usableLanguages(modelId: 'qwen05b-ppl-int8'),
        containsAll(['zh', 'en']),
      );
    });

    test('有人類側門檻時，aiCut 不得高於 humanCut（區間會顛倒）', () {
      for (final model in PerplexityCalibration.calibratedModels) {
        for (final lang in PerplexityCalibration.measuredLanguages(
          modelId: model,
        )) {
          final t = PerplexityCalibration.of(lang, modelId: model);
          if (t?.humanCut == null) continue;
          expect(
            t!.aiCut,
            lessThanOrEqualTo(t.humanCut!),
            reason: '$model/$lang 的 aiCut 高於 humanCut，兩條規則會互相打架',
          );
        }
      }
    });

    test('高困惑度不得再充當人類證據——現代 AI 文本正落在那個區間', () {
      // 2026 世代 LLM 的中文輸出困惑度中位數 72.3，遠高於 HC3 校準的 18.67。
      // 若照舊給 −0.25，等於主動把 AI 文章往人類推。
      for (final model in PerplexityCalibration.calibratedModels) {
        for (final lang in PerplexityCalibration.measuredLanguages(
          modelId: model,
        )) {
          final t = PerplexityCalibration.of(lang, modelId: model);
          if (t == null) continue;
          expect(
            t.hasHumanSideEvidence,
            isFalse,
            reason: '$model/$lang 仍以高困惑度作為人類證據，尚未以現代語料驗證過',
          );
        }
      }
    });

    test('無法判定語言時同樣棄權', () {
      expect(PerplexityCalibration.of(DetectedLanguage.undetermined), isNull);
    });

    test('現行模型的可用語言只有英文', () {
      expect(PerplexityCalibration.usableLanguages(), ['en']);
    });

    test('門檻綁定模型：換模型後舊門檻一律失效，不得沿用', () {
      // 換模型後沿用舊門檻，就是「拿英文門檻量中文」的同一種錯誤換了個軸
      expect(PerplexityCalibration.of('en'), isNotNull);
      expect(
        PerplexityCalibration.of('en', modelId: 'some_multilingual_lm_int8'),
        isNull,
      );
    });

    test('校準表的鍵必須存在於 catalog，否則永遠查不到', () {
      // 兩邊各取一套命名，遲早會出現「換了模型卻仍套用舊門檻」而沒人發現
      final catalog =
          jsonDecode(File('assets/model_catalog.json').readAsStringSync())
              as Map<String, dynamic>;
      final ids = <String>{
        for (final model in catalog['models'] as List)
          for (final v in ((model as Map)['variants'] as List))
            (v as Map)['id'] as String,
      };
      for (final modelId in PerplexityCalibration.calibratedModels) {
        expect(
          ids,
          contains(modelId),
          reason: '校準表的「$modelId」在 catalog 中不存在，這組門檻永遠不會被套用',
        );
      }
    });
  });
}
