import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/services/document_provenance.dart';
import '../../l10n/generated/app_localizations.dart';

/// 文件來源證據卡：與 AI 機率**分開**呈現。
///
/// 這裡講的是「這份檔案是怎麼產生的」，屬於來源證據；AI 機率講的是
/// 「這段文字看起來像不像 AI 寫的」，屬於統計推論。兩者證據性質不同，
/// 混在一起會讓使用者誤以為分數已經把編輯紀錄算進去了，因此刻意不合併。
class ProvenanceCard extends StatelessWidget {
  final DocumentProvenance provenance;

  const ProvenanceCard({super.key, required this.provenance});

  /// 把訊號轉成該語系的白話說明
  static String describeSignal(ProvenanceSignal signal, AppLocalizations l10n) {
    final v = signal.values;
    return switch (signal.kind) {
      ProvenanceSignalKind.singleEditingSession =>
        l10n.provenanceSignalSingleSession(v['count'] ?? 0, v['words'] ?? 0),
      ProvenanceSignalKind.implausibleTypingSpeed =>
        l10n.provenanceSignalTypingSpeed(
          v['words'] ?? 0,
          v['minutes'] ?? 0,
          v['wpm'] ?? 0,
        ),
      ProvenanceSignalKind.negligibleEditingTime =>
        l10n.provenanceSignalNoEditingTime(v['words'] ?? 0),
      ProvenanceSignalKind.fewRevisions =>
        l10n.provenanceSignalFewRevisions(v['count'] ?? 0, v['words'] ?? 0),
    };
  }

  static String describeRisk(ProvenanceRisk risk, AppLocalizations l10n) =>
      switch (risk) {
        ProvenanceRisk.high => l10n.provenanceRiskHigh,
        ProvenanceRisk.medium => l10n.provenanceRiskMedium,
        ProvenanceRisk.low => l10n.provenanceRiskLow,
        ProvenanceRisk.unknown => l10n.provenanceRiskUnknown,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final risk = provenance.risk;

    final (accent, icon) = switch (risk) {
      ProvenanceRisk.high => (const Color(0xFFC0392B), LucideIcons.alertTriangle),
      ProvenanceRisk.medium => (const Color(0xFFD4AF37), LucideIcons.alertCircle),
      ProvenanceRisk.low => (const Color(0xFF1E8449), LucideIcons.checkCircle),
      ProvenanceRisk.unknown => (Colors.grey.shade600, LucideIcons.helpCircle),
    };

    final facts = <String>[
      if (provenance.editingDuration != null)
        l10n.provenanceEditingDuration(provenance.editingDuration!.inMinutes),
      if (provenance.revisionCount != null)
        l10n.provenanceRevisionCount(provenance.revisionCount!),
      if (provenance.application != null)
        l10n.provenanceApplication(provenance.application!),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.fileSearch, size: 20, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.provenanceTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A5F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  describeRisk(risk, l10n),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),

          if (!provenance.hasMetadata) ...[
            const SizedBox(height: 8),
            Text(
              l10n.provenanceNoMetadata,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 6),
            // 「此格式本來就沒有」與「這份被清除了」的處置完全不同，
            // 對 PDF 說「紀錄可能被清除」是誤導，正確建議是改收原始檔。
            Text(
              provenance.availability ==
                      ProvenanceAvailability.unsupportedFormat
                  ? l10n.provenanceUnsupportedFormat(
                      provenance.sourceFormat.isEmpty
                          ? '—'
                          : '.${provenance.sourceFormat}',
                    )
                  : l10n.provenanceStripped,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.provenanceHowToGetRecord,
              style: theme.textTheme.bodySmall?.copyWith(
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            if (facts.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final fact in facts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    fact,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                ),
            ],
            if (provenance.signals.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final signal in provenance.signals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5, right: 8),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: signal.severity == ProvenanceSeverity.strong
                                ? accent
                                : accent.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          describeSignal(signal, l10n),
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              l10n.provenanceCaveat,
              style: theme.textTheme.labelSmall?.copyWith(
                height: 1.5,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
