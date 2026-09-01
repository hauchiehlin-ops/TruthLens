import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/bibliography_verifier.dart';
import 'package:omnitrace/features/report/report_screen.dart';

void main() {
  test('deduplicates repeated bibliography progress preview labels', () {
    final duplicateUncertain = BibliographyCheckResult(
      entry: BibliographyEntry(rawText: 'Coles, D. Example'),
      confidence: CitationMatchConfidence.uncertain,
    );
    final anotherDuplicateUncertain = BibliographyCheckResult(
      entry: BibliographyEntry(rawText: 'Hall, P. Example'),
      confidence: CitationMatchConfidence.uncertain,
    );
    final highConfidence = BibliographyCheckResult(
      entry: BibliographyEntry(rawText: 'Donnelly, R. Example'),
      confidence: CitationMatchConfidence.high,
      matchedJournal: 'Proceedings of the Royal Society of London A',
    );

    final preview = deduplicateBibliographyPreviewResults(
      [duplicateUncertain, anotherDuplicateUncertain, highConfidence],
      (check) => switch (check.confidence) {
        CitationMatchConfidence.high => 'High confidence',
        CitationMatchConfidence.notFound => 'Not found',
        CitationMatchConfidence.uncertain => 'Same uncertain reason',
      },
    );

    expect(preview, [duplicateUncertain, highConfidence]);
  });

  test('keeps at most three distinct bibliography progress preview labels', () {
    final checks = [
      BibliographyCheckResult(
        entry: BibliographyEntry(rawText: 'A'),
        confidence: CitationMatchConfidence.uncertain,
      ),
      BibliographyCheckResult(
        entry: BibliographyEntry(rawText: 'B'),
        confidence: CitationMatchConfidence.notFound,
      ),
      BibliographyCheckResult(
        entry: BibliographyEntry(rawText: 'C'),
        confidence: CitationMatchConfidence.high,
      ),
      BibliographyCheckResult(
        entry: BibliographyEntry(rawText: 'D'),
        confidence: CitationMatchConfidence.high,
      ),
    ];

    final preview = deduplicateBibliographyPreviewResults(
      checks,
      (check) => '${check.confidence.name}:${check.entry.rawText}',
    );

    expect(preview.length, 3);
    expect(preview.map((c) => c.entry.rawText), ['A', 'B', 'C']);
  });
}
