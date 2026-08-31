import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/services/preferences_service.dart';
import '../../core/utils/app_version.dart';
import '../../l10n/generated/app_localizations.dart';

const List<(Locale?, String)> kSupportedLanguageOptions = [
  (null, 'System default'),
  (Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), '繁體中文'),
  (Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'), '简体中文'),
  (Locale('en'), 'English'),
  (Locale('ja'), '日本語'),
  (Locale('ko'), '한국어'),
  (Locale('th'), 'ไทย'),
  (Locale('ms'), 'Bahasa Melayu'),
  (Locale('es'), 'Español'),
  (Locale('id'), 'Bahasa Indonesia'),
  (Locale('ru'), 'Русский'),
  (Locale('de'), 'Deutsch'),
  (Locale('fr'), 'Français'),
  (Locale('pt'), 'Português'),
];

class AppIdentityTitle extends StatelessWidget {
  const AppIdentityTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Flexible(
          child: Text(
            'TruthLens',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            child: ValueListenableBuilder<AppVersionInfo>(
              valueListenable: AppVersion.listenable,
              builder: (context, info, _) => Text(
                info.displayVersion,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 應用程式右上角的單一收納選單：整合工作台模式、語言、歷史紀錄、設定、
/// 說明（與選填的隱私權政策）。取代先前一整排各自獨立、圖示難以辨識用途
/// 的按鈕群——收合成一個入口，內層以文字標籤清楚說明每個功能。
class AppOverflowMenu extends StatelessWidget {
  final WorkspaceMode activeMode;
  final bool analysisActive;
  final VoidCallback onSettings;
  final VoidCallback onHistory;
  final VoidCallback onHelp;
  final VoidCallback? onPrivacy;

  const AppOverflowMenu({
    super.key,
    required this.activeMode,
    required this.onSettings,
    required this.onHistory,
    required this.onHelp,
    this.analysisActive = false,
    this.onPrivacy,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesService>();
    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        icon: Icon(LucideIcons.moreVertical),
        tooltip: l10n.workspaceMoreMenuTooltip,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
      menuChildren: [
        SubmenuButton(
          leadingIcon: Icon(_modeIcon(activeMode)),
          menuChildren: [
            for (final mode in WorkspaceMode.values)
              MenuItemButton(
                leadingIcon: Icon(_modeIcon(mode)),
                trailingIcon: mode == activeMode
                    ? Icon(LucideIcons.check)
                    : null,
                onPressed: (!analysisActive || mode != WorkspaceMode.original)
                    ? () => prefs.setWorkspaceMode(mode)
                    : null,
                child: Text(_modeLabel(mode, l10n)),
              ),
          ],
          child: Text(l10n.workspaceModeTooltip),
        ),
        SubmenuButton(
          leadingIcon: Icon(LucideIcons.languages),
          menuChildren: [
            for (final option in kSupportedLanguageOptions)
              MenuItemButton(
                trailingIcon: option.$1 == prefs.locale
                    ? Icon(LucideIcons.check)
                    : null,
                onPressed: () => prefs.setLocale(option.$1),
                child: Text(option.$2),
              ),
          ],
          child: Text(l10n.workspaceLanguageMenuTitle),
        ),
        MenuItemButton(
          leadingIcon: Icon(LucideIcons.history),
          onPressed: onHistory,
          child: Text(l10n.inputHistoryTooltip),
        ),
        MenuItemButton(
          leadingIcon: Icon(LucideIcons.settings),
          onPressed: onSettings,
          child: Text(l10n.inputSettingsTooltip),
        ),
        MenuItemButton(
          leadingIcon: Icon(LucideIcons.helpCircle),
          onPressed: onHelp,
          child: Text(l10n.inputHelpTooltip),
        ),
        if (onPrivacy != null)
          MenuItemButton(
            leadingIcon: Icon(LucideIcons.shieldCheck),
            onPressed: onPrivacy,
            child: Text(l10n.inputPrivacyTooltip),
          ),
      ],
    );
  }

  static IconData _modeIcon(WorkspaceMode mode) => switch (mode) {
    WorkspaceMode.original => LucideIcons.rows3,
    WorkspaceMode.commandGrid => LucideIcons.grid3x3,
    WorkspaceMode.missionTimeline => LucideIcons.map,
    WorkspaceMode.evidenceCanvas => LucideIcons.checkSquare,
  };

  static String _modeLabel(WorkspaceMode mode, AppLocalizations l10n) =>
      switch (mode) {
        WorkspaceMode.original => l10n.workspaceModeOriginal,
        WorkspaceMode.commandGrid => l10n.workspaceModeCommandGrid,
        WorkspaceMode.missionTimeline => l10n.workspaceModeTimeline,
        WorkspaceMode.evidenceCanvas => l10n.workspaceModeEvidence,
      };
}
