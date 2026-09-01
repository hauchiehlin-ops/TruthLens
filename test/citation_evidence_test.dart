import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/bibliography_verifier.dart';
import 'package:omnitrace/core/services/citation_evidence.dart';

/// 捏造引用是 LLM 的行為特徵，而且是**可查證的事實**——
/// 一篇文獻存不存在，模型再強也不會改變。這是它不隨世代衰減的原因。
///
/// 但門檻必須保守：公開資料庫對中文、專書、法律文獻的收錄本就不完整，
/// 把「查不到」直接當成「捏造」會製造偽陽性。
BibliographyCheckResult _check(
  CitationMatchConfidence confidence, {
  bool journalMismatch = false,
}) => BibliographyCheckResult(
  entry: const BibliographyEntry(rawText: 'x'),
  confidence: confidence,
  journalNameMismatch: journalMismatch,
);

List<BibliographyCheckResult> _mix({
  int verified = 0,
  int uncertain = 0,
  int notFound = 0,
}) => [
  for (var i = 0; i < verified; i++) _check(CitationMatchConfidence.high),
  for (var i = 0; i < uncertain; i++) _check(CitationMatchConfidence.uncertain),
  for (var i = 0; i < notFound; i++) _check(CitationMatchConfidence.notFound),
];

void main() {
  group('彙總', () {
    test('三種結果分別計數', () {
      final e = CitationEvidence.fromChecks(
        _mix(verified: 6, uncertain: 2, notFound: 3),
      );
      expect(e.total, 11);
      expect(e.verified, 6);
      expect(e.uncertain, 2);
      expect(e.notFound, 3);
    });

    test('命中但期刊名對不上算 uncertain，不算乾淨命中', () {
      // 條目被拼湊過的可能性仍在，不該計為已核實
      final e = CitationEvidence.fromChecks([
        _check(CitationMatchConfidence.high, journalMismatch: true),
      ]);
      expect(e.verified, 0);
      expect(e.uncertain, 1);
    });
  });

  group('風險判定刻意保守', () {
    test('文獻數太少時不下結論', () {
      // 一兩筆查無此文可能只是資料庫收錄不全
      final e = CitationEvidence.fromChecks(_mix(notFound: 2, verified: 1));
      expect(e.total, lessThan(CitationEvidence.minimumEntriesForRisk));
      expect(e.risk, CitationRisk.unknown);
      expect(e.contradictsHumanAuthorship, isFalse);
    });

    test('全部可核實時為低風險', () {
      final e = CitationEvidence.fromChecks(_mix(verified: 12));
      expect(e.risk, CitationRisk.low);
    });

    test('少量查無此文不足以示警（收錄不全是常態）', () {
      // 1/20 = 5%，低於 15% 門檻且未達 3 筆
      final e = CitationEvidence.fromChecks(_mix(verified: 19, notFound: 1));
      expect(e.risk, CitationRisk.low);
      expect(e.contradictsHumanAuthorship, isFalse);
    });

    test('查無此文達三筆即進入中風險', () {
      final e = CitationEvidence.fromChecks(_mix(verified: 22, notFound: 3));
      expect(e.risk, CitationRisk.medium);
      expect(e.contradictsHumanAuthorship, isTrue);
    });

    test('比例達三成為高風險——難以用收錄不全解釋', () {
      final e = CitationEvidence.fromChecks(_mix(verified: 7, notFound: 5));
      expect(e.notFoundRatio, greaterThanOrEqualTo(0.30));
      expect(e.risk, CitationRisk.high);
    });

    test('沒有文獻時不產生任何主張', () {
      expect(CitationEvidence.none.hasData, isFalse);
      expect(CitationEvidence.none.risk, CitationRisk.unknown);
      expect(CitationEvidence.none.contradictsHumanAuthorship, isFalse);
      expect(CitationEvidence.none.notFoundRatio, 0);
    });
  });
}
