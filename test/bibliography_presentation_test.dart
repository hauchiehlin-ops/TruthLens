import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/bibliography_verifier.dart';
import 'package:omnitrace/features/report/bibliography_presentation.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('orders bibliography checks by imported source position', () {
    BibliographyCheckResult check(String citation, int sourceOffset) =>
        BibliographyCheckResult(
          entry: BibliographyEntry(
            rawText: citation,
            sourceOffset: sourceOffset,
          ),
          confidence: CitationMatchConfidence.high,
        );

    final ordered = orderBibliographyChecks([
      check('Third', 30),
      check('First', 10),
      check('Second', 20),
    ]);

    expect(ordered.map((item) => item.entry.rawText), [
      'First',
      'Second',
      'Third',
    ]);
  });

  test(
    'uses the same success, warning, and error tones for web and exports',
    () {
      final success = presentBibliographyCheck(
        const BibliographyCheckResult(
          entry: BibliographyEntry(rawText: 'Verified citation'),
          confidence: CitationMatchConfidence.high,
          matchedJournal: 'Journal of Verification',
          verificationSource: 'Crossref',
        ),
        l10n,
      );
      final mismatch = presentBibliographyCheck(
        const BibliographyCheckResult(
          entry: BibliographyEntry(
            rawText: 'Mismatch citation',
            venueTitle: 'Incorrect Journal',
          ),
          confidence: CitationMatchConfidence.high,
          matchedJournal: 'Correct Journal',
          journalNameMismatch: true,
        ),
        l10n,
      );
      final notFound = presentBibliographyCheck(
        const BibliographyCheckResult(
          entry: BibliographyEntry(rawText: 'Missing citation'),
          confidence: CitationMatchConfidence.notFound,
        ),
        l10n,
      );

      expect(success.tone, BibliographyDisplayTone.success);
      expect(success.warning, isNull);
      expect(success.source, contains('Crossref'));
      expect(mismatch.tone, BibliographyDisplayTone.success);
      expect(mismatch.warningTone, BibliographyDisplayTone.mismatch);
      expect(mismatch.warning, contains('Incorrect Journal'));
      expect(notFound.tone, BibliographyDisplayTone.error);
    },
  );
}
