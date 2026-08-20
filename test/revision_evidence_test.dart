import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/revision_evidence.dart';

void main() {
  test('小幅增修辨識為漸進演化', () {
    final before = List.generate(120, (i) => 'word$i').join(' ');
    final after = '$before ${List.generate(15, (i) => 'added$i').join(' ')}';
    final evidence = RevisionEvidence.compare(before, after);
    expect(evidence.pattern, RevisionPattern.incremental);
  });

  test('篇幅相近但內容整批替換會列為大面積替換', () {
    final before = List.generate(120, (i) => 'alpha$i').join(' ');
    final after = List.generate(120, (i) => 'omega$i').join(' ');
    final evidence = RevisionEvidence.compare(before, after);
    expect(evidence.pattern, RevisionPattern.largeReplacement);
  });

  test('草稿太短時拒絕製造版本結論', () {
    expect(
      RevisionEvidence.compare('short draft', 'another short draft').hasData,
      isFalse,
    );
  });
}
