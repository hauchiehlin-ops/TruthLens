import '../../core/services/bibliography_verifier.dart';
import '../../l10n/generated/app_localizations.dart';

enum BibliographyDisplayTone { success, warning, mismatch, error }

class BibliographyPresentation {
  final String status;
  final String? warning;
  final String? source;
  final BibliographyDisplayTone tone;
  final BibliographyDisplayTone? warningTone;

  const BibliographyPresentation({
    required this.status,
    required this.tone,
    this.warning,
    this.source,
    this.warningTone,
  });
}

List<BibliographyCheckResult> orderBibliographyChecks(
  Iterable<BibliographyCheckResult> checks,
) {
  final indexed = checks.indexed.toList();
  indexed.sort((a, b) {
    final aOffset = a.$2.entry.sourceOffset;
    final bOffset = b.$2.entry.sourceOffset;
    if (aOffset < 0 || bOffset < 0) return a.$1.compareTo(b.$1);
    final bySource = aOffset.compareTo(bOffset);
    return bySource != 0 ? bySource : a.$1.compareTo(b.$1);
  });
  return indexed.map((item) => item.$2).toList(growable: false);
}

BibliographyPresentation presentBibliographyCheck(
  BibliographyCheckResult check,
  AppLocalizations l10n,
) {
  if (check.confidence == CitationMatchConfidence.high) {
    final journal = check.matchedJournal;
    return BibliographyPresentation(
      status: l10n.reportBibHighConfidence(
        journal == null ? '' : l10n.reportBibJournalSuffix(journal),
      ),
      warning: check.journalNameMismatch
          ? l10n.reportBibJournalMismatch(
              check.entry.venueTitle ?? '',
              journal ?? '',
            )
          : null,
      source: check.verificationSource == null
          ? null
          : l10n.reportBibVerificationSource(check.verificationSource!),
      tone: BibliographyDisplayTone.success,
      warningTone: check.journalNameMismatch
          ? BibliographyDisplayTone.mismatch
          : null,
    );
  }

  if (check.confidence == CitationMatchConfidence.notFound) {
    return BibliographyPresentation(
      status: l10n.reportBibNotFound,
      tone: BibliographyDisplayTone.error,
    );
  }

  final candidate = check.matchedTitle;
  return BibliographyPresentation(
    status: candidate != null && candidate.trim().isNotEmpty
        ? l10n.reportBibUncertainWithCandidate(
            l10n.reportBibUncertain,
            candidate,
          )
        : l10n.reportBibUncertainNoReliableResponse(l10n.reportBibUncertain),
    tone: BibliographyDisplayTone.warning,
  );
}
