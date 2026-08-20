import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/claim_audit.dart';

void main() {
  test('找出中英文可查核主張，並辨識附近引用', () {
    final audit = ClaimAudit.analyze('''
根據 2025 年的研究，採用率增加了 37%（Lin, 2025）。
另一份調查顯示，有 62% 的受訪者支持這項政策。
The report found that costs fell by 18 percent [12].
This paragraph only explains the background without a checkable claim.
''');
    expect(audit.total, 3);
    expect(audit.sourced, 2);
    expect(audit.unsupported, 1);
  });

  test('參考文獻清單本身不會被當成正文主張', () {
    final audit = ClaimAudit.analyze('''
The survey found that adoption increased by 44 percent.

References
Lin, A. (2025). A study of adoption rates. Journal 12(3), 44-51.
Wang, B. (2024). Evidence and policy. https://example.org/paper
''');
    expect(audit.total, 1);
  });

  test('大量無來源主張標為高來源覆蓋風險，但不宣稱內容為假', () {
    final audit = ClaimAudit.analyze('''
The first survey found that adoption increased by 44 percent.
The second report showed that costs fell by 18 percent.
Researchers found that output rose by 25 percent.
Data indicates that failures decreased by 31 percent.
The largest group represented 62 percent of respondents.
''');
    expect(audit.unsupported, 5);
    expect(audit.risk, ClaimSourceRisk.high);
  });
}
