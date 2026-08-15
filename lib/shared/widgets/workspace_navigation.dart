import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/preferences_service.dart';
import '../../core/utils/app_version.dart';
import '../../l10n/generated/app_localizations.dart';

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
            child: Text(
              AppVersion.displayVersion,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WorkspaceModeMenuButton extends StatelessWidget {
  final WorkspaceMode activeMode;
  final bool analysisActive;

  const WorkspaceModeMenuButton({
    super.key,
    required this.activeMode,
    this.analysisActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.read<PreferencesService>();
    return PopupMenuButton<WorkspaceMode>(
      icon: Icon(_modeIcon(activeMode)),
      tooltip: l10n.workspaceModeTooltip,
      onSelected: prefs.setWorkspaceMode,
      itemBuilder: (context) => [
        for (final mode in WorkspaceMode.values)
          PopupMenuItem(
            value: mode,
            enabled: !analysisActive || mode != WorkspaceMode.original,
            child: ListTile(
              dense: true,
              leading: Icon(_modeIcon(mode)),
              title: Text(_modeLabel(mode, l10n)),
            ),
          ),
      ],
    );
  }

  static IconData _modeIcon(WorkspaceMode mode) => switch (mode) {
    WorkspaceMode.original => Icons.view_agenda_outlined,
    WorkspaceMode.automatic => Icons.auto_awesome_mosaic_outlined,
    WorkspaceMode.commandGrid => Icons.grid_view_outlined,
    WorkspaceMode.missionTimeline => Icons.route_outlined,
    WorkspaceMode.evidenceCanvas => Icons.fact_check_outlined,
  };

  static String _modeLabel(WorkspaceMode mode, AppLocalizations l10n) =>
      switch (mode) {
        WorkspaceMode.original => l10n.workspaceModeOriginal,
        WorkspaceMode.automatic => l10n.workspaceModeAuto,
        WorkspaceMode.commandGrid => l10n.workspaceModeCommandGrid,
        WorkspaceMode.missionTimeline => l10n.workspaceModeTimeline,
        WorkspaceMode.evidenceCanvas => l10n.workspaceModeEvidence,
      };
}
