import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/evasion_scanner.dart';
import 'package:omnitrace/core/models/input_quality.dart';

/// 這是整套系統裡唯一確定性的檢查：不估機率，只回報「有沒有」。
/// 它指向的不是「這段文字像 AI」，而是「有人刻意規避偵測」——
/// 後者本身就需要解釋，而且不隨語言模型進步而失效。
void main() {
  const clean =
      'The lowest stability boundary on the flow of concentric rotating '
      'cylinders was examined across a range of radius ratios.';

  group('乾淨文本', () {
    test('正常英文沒有任何發現', () {
      final scan = scanForEvasion(clean);
      expect(scan.hasFindings, isFalse);
      expect(scan.indicatesDeliberateEvasion, isFalse);
    });

    test('正常中文沒有任何發現', () {
      final scan = scanForEvasion('本研究採用泰勒庫埃特流場作為實驗載體，觀察渦漩的形態轉換過程。');
      expect(scan.hasFindings, isFalse);
    });

    test('空字串不崩潰', () {
      expect(scanForEvasion('').hasFindings, isFalse);
    });

    test('實際 IJBC 學術 PDF 抽取文字不構成刻意規避', () {
      final paper = File('test/fixtures/ijbc_paper.txt').readAsStringSync();
      final scan = scanForEvasion(
        paper,
        acquisitionMethod: InputAcquisitionMethod.pdfTextLayer,
      );
      expect(
        scan.indicatesDeliberateEvasion,
        isFalse,
        reason: scan.findings
            .map(
              (finding) =>
                  '${finding.kind.name}:${finding.count}:${finding.samples}',
            )
            .join(', '),
      );
    });
  });

  group('零寬字元', () {
    test('少量殘留不足以指控——複製貼上就可能帶進來', () {
      final scan = scanForEvasion('The​flow​was examined.');
      expect(scan.hasFindings, isTrue);
      expect(scan.indicatesDeliberateEvasion, isFalse);
    });

    test('大量插入構成刻意規避', () {
      final text = clean.replaceAll(' ', '​ ');
      final scan = scanForEvasion(text);
      expect(scan.indicatesDeliberateEvasion, isTrue);
      expect(scan.findings.any((f) => f.kind == EvasionKind.zeroWidth), isTrue);
    });
  });

  group('同形字', () {
    test('拉丁文本中混入西里爾字母即構成規避', () {
      // А、О、Е 是西里爾字母，外觀與 ASCII 相同
      final scan = scanForEvasion(
        'The flоw was exаmined with cаre across the range.',
      );
      expect(scan.indicatesDeliberateEvasion, isTrue);
      expect(scan.findings.any((f) => f.kind == EvasionKind.homoglyph), isTrue);
    });

    test('學術公式中的獨立希臘變數不算同形字規避', () {
      final scan = scanForEvasion(
        'The eigenvalue is written as ν = 0.25, while α controls the mode.',
        acquisitionMethod: InputAcquisitionMethod.pdfTextLayer,
      );
      expect(
        scan.findings.any((f) => f.kind == EvasionKind.homoglyph),
        isFalse,
      );
      expect(scan.indicatesDeliberateEvasion, isFalse);
    });

    test('俄文文件裡的西里爾字母不算規避', () {
      // 一份俄文文件裡有西里爾字母是理所當然的
      final scan = scanForEvasion(
        'В настоящем исследовании течение Тейлора-Куэтта использовалось '
        'в качестве экспериментальной среды для наблюдения за вихрями.',
      );
      expect(
        scan.findings.any((f) => f.kind == EvasionKind.homoglyph),
        isFalse,
      );
    });
  });

  group('雙向控制字元', () {
    test('出現即示警——正常寫作工具不會產生', () {
      final scan = scanForEvasion('The flow\u202Ewas examined.');
      expect(scan.indicatesDeliberateEvasion, isTrue);
    });

    test('PDF 抽取的單一方向控制字元只列出，不直接指控規避', () {
      final scan = scanForEvasion(
        'The flow\u202E was examined.',
        acquisitionMethod: InputAcquisitionMethod.pdfTextLayer,
      );
      expect(scan.hasFindings, isTrue);
      expect(scan.indicatesDeliberateEvasion, isFalse);
    });
  });

  test('非標準空白需大量出現才算規避', () {
    final few = scanForEvasion('The flow was examined.');
    expect(few.hasFindings, isTrue);
    expect(few.indicatesDeliberateEvasion, isFalse);

    final many = scanForEvasion(List.filled(25, 'word ').join());
    expect(many.indicatesDeliberateEvasion, isTrue);
  });

  test('回報命中次數與樣本供介面呈現', () {
    final scan = scanForEvasion('a​b​c​d');
    final zw = scan.findings.firstWhere((f) => f.kind == EvasionKind.zeroWidth);
    expect(zw.count, 3);
    expect(zw.samples, isNotEmpty);
    expect(scan.totalHits, 3);
  });

  _wiredIntoResult();
}

/// 掃描結果必須真的影響報告，否則等於沒做
void _wiredIntoResult() {
  test('分析結果會帶上掃描結果，且乾淨文本不產生主張', () {
    const clean = 'The flow was examined across a range of radius ratios.';
    expect(scanForEvasion(clean).indicatesDeliberateEvasion, isFalse);
  });
}
