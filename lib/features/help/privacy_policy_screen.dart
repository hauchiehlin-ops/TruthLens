import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../l10n/generated/app_localizations.dart';

/// 隱私權政策頁：TruthLens 為 Web-only 應用程式（Phase 6 起原生平台已完全
/// 移除），因此政策內容不再依作業系統分支，統一描述瀏覽器端執行的實際行為。
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _lastUpdated = '2026-08-15';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final policy = _webPolicy(l10n);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyAppBarTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.globe,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.privacyAppBarTitle,
                          style: textTheme.titleMedium,
                        ),
                        Text(
                          l10n.privacyLastUpdated(_lastUpdated),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final section in policy) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(section.title, style: textTheme.titleSmall),
                    const SizedBox(height: 8),
                    for (final p in section.paragraphs)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(p, style: const TextStyle(height: 1.5)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.privacyDisclaimer,
              style: textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicySection {
  final String title;
  final List<String> paragraphs;
  const _PolicySection(this.title, this.paragraphs);
}

List<_PolicySection> _webPolicy(AppLocalizations l10n) => [
  _PolicySection(l10n.privacySectionOverviewWeb, [
    l10n.privacyWebOverview1,
    l10n.privacyWebOverview2,
  ]),
  _PolicySection(l10n.privacySectionDataHandling, [
    l10n.privacyDataHandling1,
    l10n.privacyDataHandling2,
    l10n.privacyDataHandling3,
  ]),
  _PolicySection(l10n.privacySectionNetwork, [
    l10n.privacyNetworkIntro,
    l10n.privacyNetwork1,
    l10n.privacyNetwork2,
    l10n.privacyNetwork3,
    l10n.privacyNetwork4,
  ]),
  _PolicySection(l10n.privacySectionRights, [
    '${l10n.privacyRightsIntro} ${l10n.privacyRemoveWeb}',
  ]),
];
