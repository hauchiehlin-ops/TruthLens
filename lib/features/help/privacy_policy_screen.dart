import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// 隱私權政策頁：依實際執行的作業系統顯示對應平台的政策內容。
/// 各平台內容描述的是同一套實際行為（見程式碼中列出的四項連線行為），
/// 只是依各平台商店／發行慣例調整措辭與揭露格式，並非分別實作不同的隱私作法。
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _lastUpdated = '2026-07-05';

  _PlatformPolicy _policyFor(TargetPlatform platform, AppLocalizations l10n) {
    switch (platform) {
      case TargetPlatform.iOS:
        return _iosPolicy(l10n);
      case TargetPlatform.android:
        return _androidPolicy(l10n);
      case TargetPlatform.macOS:
        return _macosPolicy(l10n);
      case TargetPlatform.windows:
        return _windowsPolicy(l10n);
      default:
        return _genericPolicy(l10n);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final policy = _policyFor(defaultTargetPlatform, l10n);
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
                  Icon(policy.icon,
                      color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.privacyPlatformTitle(policy.platformName),
                            style: textTheme.titleMedium),
                        Text(l10n.privacyLastUpdated(_lastUpdated),
                            style: textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final section in policy.sections) ...[
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
              style: textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.outline),
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

class _PlatformPolicy {
  final String platformName;
  final IconData icon;
  final List<_PolicySection> sections;
  const _PlatformPolicy({
    required this.platformName,
    required this.icon,
    required this.sections,
  });
}

_PolicySection _dataSection(AppLocalizations l10n) =>
    _PolicySection(l10n.privacySectionDataHandling, [
      l10n.privacyDataHandling1,
      l10n.privacyDataHandling2,
      l10n.privacyDataHandling3,
    ]);

_PolicySection _networkSection(AppLocalizations l10n) =>
    _PolicySection(l10n.privacySectionNetwork, [
      l10n.privacyNetworkIntro,
      l10n.privacyNetwork1,
      l10n.privacyNetwork2,
      l10n.privacyNetwork3,
    ]);

_PolicySection _rightsSection(AppLocalizations l10n, String removeAction) =>
    _PolicySection(l10n.privacySectionRights, [
      '${l10n.privacyRightsIntro} $removeAction。',
    ]);

_PlatformPolicy _iosPolicy(AppLocalizations l10n) => _PlatformPolicy(
      platformName: 'iOS',
      icon: Icons.phone_iphone,
      sections: [
        _PolicySection(l10n.privacySectionOverviewIos, [
          l10n.privacyIosOverview1,
          l10n.privacyIosOverview2,
        ]),
        _dataSection(l10n),
        _networkSection(l10n),
        _rightsSection(l10n, l10n.privacyRemoveIos),
      ],
    );

_PlatformPolicy _androidPolicy(AppLocalizations l10n) => _PlatformPolicy(
      platformName: 'Android',
      icon: Icons.android,
      sections: [
        _PolicySection(l10n.privacySectionOverviewAndroid, [
          l10n.privacyAndroidOverview1,
          l10n.privacyAndroidOverview2,
        ]),
        _dataSection(l10n),
        _networkSection(l10n),
        _rightsSection(l10n, l10n.privacyRemoveAndroid),
      ],
    );

_PlatformPolicy _macosPolicy(AppLocalizations l10n) => _PlatformPolicy(
      platformName: 'macOS',
      icon: Icons.laptop_mac,
      sections: [
        _PolicySection(l10n.privacySectionOverviewMacos, [
          l10n.privacyMacosOverview1,
          l10n.privacyMacosOverview2,
        ]),
        _dataSection(l10n),
        _networkSection(l10n),
        _rightsSection(l10n, l10n.privacyRemoveMacos),
      ],
    );

_PlatformPolicy _windowsPolicy(AppLocalizations l10n) => _PlatformPolicy(
      platformName: 'Windows',
      icon: Icons.desktop_windows,
      sections: [
        _PolicySection(l10n.privacySectionOverviewWindows, [
          l10n.privacyWindowsOverview1,
          l10n.privacyWindowsOverview2,
        ]),
        _dataSection(l10n),
        _networkSection(l10n),
        _rightsSection(l10n, l10n.privacyRemoveWindows),
      ],
    );

_PlatformPolicy _genericPolicy(AppLocalizations l10n) => _PlatformPolicy(
      platformName: l10n.privacyGenericPlatformName,
      icon: Icons.devices_other,
      sections: [_dataSection(l10n), _networkSection(l10n)],
    );
