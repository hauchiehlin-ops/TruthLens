import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/evasion_scanner.dart';
import 'package:omnitrace/core/models/input_quality.dart';
import 'package:omnitrace/features/report/verifiable_findings.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

// 一律以碼位建構測試字串：把不可見字元直接寫進原始碼，會讓審閱者看不到
// 測試真正在測什麼——那正是掃描器要抓的手法本身。
String _c(int codePoint) => String.fromCharCode(codePoint);

int _count(EvasionScan scan, EvasionKind kind) => scan.findings
    .where((f) => f.kind == kind)
    .fold(0, (sum, f) => sum + f.count);

const _english =
    'The lowest stability boundary on the flow of concentric rotating '
    'cylinders was examined across a range of radius ratios.';

void main() {
  group('Tag 字元', () {
    test('夾帶在英文中的 Tag 字元一律視為規避', () {
      final hidden = [0x49, 0x67, 0x6E].map((c) => _c(0xE0000 + c)).join();
      final scan = scanForEvasion('The flow$hidden was examined.');
      expect(_count(scan, EvasionKind.tagCharacter), 3);
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });

    test('蘇格蘭旗幟 emoji 的標準 Tag 序列不算', () {
      final scotland =
          _c(0x1F3F4) +
          [0x67, 0x62, 0x73, 0x63, 0x74].map((c) => _c(0xE0000 + c)).join() +
          _c(0xE007F);
      final scan = scanForEvasion('Edinburgh $scotland is lovely.');
      expect(_count(scan, EvasionKind.tagCharacter), 0);
    });
  });

  group('變體選擇符', () {
    test('連續的選擇符（夾帶資料）構成規避', () {
      final payload = List.generate(6, (i) => _c(0xE0100 + i)).join();
      final scan = scanForEvasion('a$payload flow');
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });

    test('emoji 後的 FE0F 與漢字後的單一異體選擇符正常', () {
      final scan = scanForEvasion(
        'Great job ${_c(0x2764)}${_c(0xFE0F)} 葛${_c(0xE0100)}城的研究。',
      );
      expect(_count(scan, EvasionKind.variationSelector), 0);
    });
  });

  group('軟連字號', () {
    test('大量插在單字中間構成規避', () {
      final text = _english.replaceAllMapped(
        RegExp(r'(\w{3})(\w{3,})'),
        (m) => '${m[1]}${_c(0x00AD)}${m[2]}',
      );
      final scan = scanForEvasion(text);
      expect(_count(scan, EvasionKind.softHyphen), greaterThanOrEqualTo(5));
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });

    test('PDF 排版斷字的軟連字號需要更高密度', () {
      final text =
          'stabil${_c(0x00AD)}ity and rota${_c(0x00AD)}ting flow, '
          'radi${_c(0x00AD)}us ratios, exam${_c(0x00AD)}ined, conc${_c(0x00AD)}entric';
      final scan = scanForEvasion(
        text,
        acquisitionMethod: InputAcquisitionMethod.pdfTextLayer,
      );
      expect(scan.indicatesDeliberateEvasion, isFalse);
    });
  });

  group('不可見填充字元', () {
    test('不可見運算子與韓文填充字構成規避', () {
      final text =
          'The${_c(0x2062)} flow${_c(0x3164)} was${_c(0x2063)} examined.';
      final scan = scanForEvasion(text);
      expect(_count(scan, EvasionKind.invisibleFiller), 3);
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });
  });

  group('全形與數學字母', () {
    test('夾在英文字中的全形字母構成規避', () {
      // intelｌigence、mａchine、leａrning
      final text =
          'intel${_c(0xFF4C)}igence and m${_c(0xFF41)}chine '
          'le${_c(0xFF41)}rning models';
      final scan = scanForEvasion(text);
      expect(_count(scan, EvasionKind.fullwidthLatin), 3);
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });

    test('中日文中獨立的全形英數字（ＡＩ、Ａ型）正常', () {
      final scan = scanForEvasion(
        '本研究以${_c(0xFF21)}${_c(0xFF29)}輔助分析，受試者為${_c(0xFF21)}型血。',
      );
      expect(_count(scan, EvasionKind.fullwidthLatin), 0);
    });

    test('夾在英文字中的數學字母構成規避', () {
      // 𝐚 = U+1D41A
      final text =
          'the fl${_c(0x1D428)}w w${_c(0x1D41A)}s ex${_c(0x1D41A)}mined';
      final scan = scanForEvasion(text);
      expect(_count(scan, EvasionKind.mathAlphanumeric), 3);
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });

    test('PDF 抽取時黏在單字旁的數學變數不算（實測已出版論文）', () {
      final scan = scanForEvasion(
        'an epidemic in${_c(0x1D450)}Css and of${_c(0x1D448)}r ef, '
        'spanned on${_c(0x1D441)} nodes of${_c(0x1D449)}G across contacts',
      );
      expect(_count(scan, EvasionKind.mathAlphanumeric), 0);
    });

    test('數學式中的獨立變數正常', () {
      final scan = scanForEvasion(
        'where ${_c(0x1D465)} = 2 and ${_c(0x1D706)} > 0 holds for all cases.',
      );
      expect(_count(scan, EvasionKind.mathAlphanumeric), 0);
    });
  });

  group('中文部首同形字', () {
    // ⼈ U+2F08（人）、⾏ U+2F8F（行）、⽣ U+2F63（生）、⼯ U+2F2F（工）
    // 替換工具只換一部分：同一個字的正常寫法仍會出現在文中
    final partial =
        '人們的行為與學生的工作表現。本研究以${_c(0x2F08)}工智慧為核心，'
        '分析消費者${_c(0x2F8F)}為與學${_c(0x2F63)}的${_c(0x2F2F)}作表現。';

    test('與正常寫法混用的康熙部首構成規避', () {
      final scan = scanForEvasion(partial);
      expect(_count(scan, EvasionKind.cjkRadical), 4);
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });

    test('相容表意字（豈 U+F900）與正常「豈」混用時列入', () {
      final scan = scanForEvasion('豈有此理。研究${_c(0xF900)}能忽略此一問題。');
      expect(_count(scan, EvasionKind.cjkRadical), 1);
    });

    test('整份一致的替換是 PDF 字型對照錯誤，不算規避', () {
      // 「行」「人」從頭到尾都以部首形式出現，文中沒有正常寫法
      final consistent =
          '本研究以${_c(0x2F08)}工智慧為核心，分析${_c(0x2F08)}們的'
          '${_c(0x2F8F)}為模式與${_c(0x2F8F)}銷策略。';
      final scan = scanForEvasion(consistent);
      expect(_count(scan, EvasionKind.cjkRadical), 0);
    });

    test('相容區中本身就是正規漢字的碼位（﨎）不算', () {
      final scan = scanForEvasion('研究${_c(0xFA0E)}能忽略此一問題。');
      expect(_count(scan, EvasionKind.cjkRadical), 0);
    });

    test('PDF 抽取的文字一律不判定', () {
      final scan = scanForEvasion(
        partial,
        acquisitionMethod: InputAcquisitionMethod.pdfTextLayer,
      );
      expect(_count(scan, EvasionKind.cjkRadical), 0);
    });

    test('部首單獨出現（字典解說）不算', () {
      final scan = scanForEvasion('人字旁的部首寫作 ${_c(0x2F08)} ，表示與人有關。');
      expect(_count(scan, EvasionKind.cjkRadical), 0);
    });
  });

  group('非標準空白比例', () {
    test('排版常見的少量不斷行空格不算（實測出版論文單篇可達數百個）', () {
      final words = List.generate(600, (i) => 'word$i');
      final text = [
        for (var i = 0; i < words.length; i++)
          i % 20 == 0 ? '${words[i]}${_c(0x00A0)}' : '${words[i]} ',
      ].join();
      final scan = scanForEvasion(text);
      expect(_count(scan, EvasionKind.unusualSpace), 30);
      expect(scan.indicatesDeliberateEvasion, isFalse);
    });

    test('把大部分空格換成不斷行空格構成規避', () {
      final scan = scanForEvasion(
        '$_english $_english'.replaceAll(' ', _c(0x00A0)),
      );
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });
  });

  group('疊加組合符號', () {
    test('三層以上的 Zalgo 疊加構成規避', () {
      final zalgo =
          'f${_c(0x0336)}${_c(0x0335)}${_c(0x0334)}low '
          'w${_c(0x0337)}${_c(0x0338)}${_c(0x0336)}as';
      final scan = scanForEvasion(zalgo);
      expect(_count(scan, EvasionKind.combiningStack), 2);
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });

    test('越南文分解形（兩層）正常', () {
      // ệ = e + U+0323 + U+0302
      final scan = scanForEvasion(
        'Vi${_c(0x0065)}${_c(0x0323)}${_c(0x0302)}t Nam là một quốc gia.',
      );
      expect(_count(scan, EvasionKind.combiningStack), 0);
    });
  });

  test('報告逐一列出手法與次數，且依語系使用正確的分隔符', () async {
    final text =
        'intel${_c(0xFF4C)}igence m${_c(0xFF41)}chine le${_c(0xFF41)}rning'
        '${_c(0xE0049)}${_c(0xE0067)}';
    final scan = scanForEvasion(text);
    final zh = await AppLocalizations.delegate.load(const Locale('zh', 'TW'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(evasionTechniquesText(scan, zh), contains('全形英文字母 3 處'));
    expect(evasionTechniquesText(scan, zh), contains('、'));
    expect(
      evasionTechniquesText(scan, en),
      contains('full-width Latin letters: 3'),
    );
    expect(evasionTechniquesText(scan, en), contains(', '));
  });
}
