import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/evasion_scanner.dart';
import 'package:truthlens/core/detection/orchestrator.dart';

/// 掃描器若沒接進管線就等於沒做。這裡確認 analyze() 的結果真的帶著它。
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const body =
      'The lowest stability boundary on the flow of concentric rotating '
      'cylinders was examined across a range of radius ratios. The results '
      'are compared with predictions from the linear theory of the problem.';

  test('乾淨文本的分析結果不帶任何規避痕跡', () async {
    final result = await EnsembleOrchestrator().analyze(body);
    expect(result.evasion.hasFindings, isFalse);
    expect(result.evasion.indicatesDeliberateEvasion, isFalse);
  });

  test('插入零寬字元後，分析結果會帶出規避痕跡', () async {
    final result = await EnsembleOrchestrator().analyze(
      body.replaceAll(' ', '​ '),
    );
    expect(result.evasion.indicatesDeliberateEvasion, isTrue);
    expect(
      result.evasion.findings.any((f) => f.kind == EvasionKind.zeroWidth),
      isTrue,
    );
  });

  test('規避痕跡不影響 AI 機率——它是另一類證據，不是分數的一部分', () async {
    final plain = await EnsembleOrchestrator().analyze(body);
    final tampered = await EnsembleOrchestrator().analyze(
      body.replaceAll(' ', '​ '),
    );
    // 零寬字元會改變斷詞，因此分數不必完全相同；但掃描結果本身
    // 不得被加進分數——確認它只出現在 evasion 欄位
    expect(plain.evasion.indicatesDeliberateEvasion, isFalse);
    expect(tampered.evasion.indicatesDeliberateEvasion, isTrue);
  });
}
