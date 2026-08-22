import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/services/forensic_evidence.dart';
import '../../l10n/generated/app_localizations.dart';

/// 六軸證據總覽。各軸保留自己的證據方向與強度；其中只有作者特異性證據
/// 進入作者判讀，其餘風險維持獨立的待核查事實。
/// 「整段貼上」或「引用查無此文」不會被誤包裝成 AI 作者證據。
class EvidenceMatrixCard extends StatelessWidget {
  final ForensicEvidenceMatrix matrix;

  const EvidenceMatrixCard({super.key, required this.matrix});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final callout = matrix.hasStrongConcern
        ? l10n.evidenceMatrixStrongConcern
        : matrix.textOnly
        ? l10n.evidenceMatrixTextOnlyWarning
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final lead = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.layoutGrid, size: 20, color: scheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.evidenceMatrixTitle,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.evidenceMatrixSubtitle,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final coverage = Text(
                l10n.evidenceMatrixCoverage(
                  matrix.availableAxisCount,
                  matrix.totalAxisCount,
                ),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              );
              if (constraints.maxWidth < 520) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    lead,
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 28),
                      child: coverage,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: lead),
                  const SizedBox(width: 12),
                  coverage,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < matrix.axes.length; i++) ...[
            _EvidenceAxisRow(axis: matrix.axes[i]),
            if (i + 1 < matrix.axes.length) const Divider(height: 16),
          ],
          if (callout != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: matrix.hasStrongConcern
                    ? scheme.errorContainer.withValues(alpha: 0.55)
                    : scheme.secondaryContainer.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                callout,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: matrix.hasStrongConcern
                      ? scheme.onErrorContainer
                      : scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EvidenceAxisRow extends StatelessWidget {
  final EvidenceAxisAssessment axis;

  const _EvidenceAxisRow({required this.axis});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (icon, title, note) = switch (axis.kind) {
      EvidenceAxisKind.textTrace => (
        LucideIcons.scanText,
        l10n.evidenceAxisText,
        l10n.evidenceAxisTextNote,
      ),
      EvidenceAxisKind.writingProcess => (
        LucideIcons.keyboard,
        l10n.evidenceAxisProcess,
        l10n.evidenceAxisProcessNote,
      ),
      EvidenceAxisKind.documentOrigin => (
        LucideIcons.fileClock,
        l10n.evidenceAxisOrigin,
        l10n.evidenceAxisOriginNote,
      ),
      EvidenceAxisKind.revisionHistory => (
        LucideIcons.gitCompare,
        l10n.evidenceAxisRevision,
        l10n.evidenceAxisRevisionNote,
      ),
      EvidenceAxisKind.taskAlignment => (
        LucideIcons.clipboardCheck,
        l10n.evidenceAxisTask,
        l10n.evidenceAxisTaskNote,
      ),
      EvidenceAxisKind.sourceIntegrity => (
        LucideIcons.bookOpenCheck,
        l10n.evidenceAxisSources,
        l10n.evidenceAxisSourcesNote,
      ),
    };
    final color = switch (axis.state) {
      EvidenceAxisState.unavailable => scheme.outline,
      EvidenceAxisState.inconclusive => scheme.tertiary,
      EvidenceAxisState.reassuring => Colors.green.shade700,
      EvidenceAxisState.concern => scheme.error,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                note,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 86),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _stateLabel(axis.state, l10n),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _strengthLabel(axis.strength, l10n),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _stateLabel(EvidenceAxisState state, AppLocalizations l10n) =>
      switch (state) {
        EvidenceAxisState.unavailable => l10n.evidenceStateUnavailable,
        EvidenceAxisState.inconclusive => l10n.evidenceStateInconclusive,
        EvidenceAxisState.reassuring => l10n.evidenceStateReassuring,
        EvidenceAxisState.concern => l10n.evidenceStateConcern,
      };

  String _strengthLabel(EvidenceStrength strength, AppLocalizations l10n) =>
      switch (strength) {
        EvidenceStrength.none => l10n.evidenceStrengthNone,
        EvidenceStrength.limited => l10n.evidenceStrengthLimited,
        EvidenceStrength.moderate => l10n.evidenceStrengthModerate,
        EvidenceStrength.strong => l10n.evidenceStrengthStrong,
      };
}
