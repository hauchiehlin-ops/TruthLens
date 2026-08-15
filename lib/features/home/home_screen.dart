import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/services/preferences_service.dart';
import '../input/input_screen.dart';
import '../workspace/workspace_screen.dart';

/// Keeps the classic input page and the situation-center layouts on one route.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<PreferencesService>().workspaceMode;
    return switch (mode) {
      WorkspaceMode.original => const InputScreen(),
      WorkspaceMode.automatic ||
      WorkspaceMode.commandGrid ||
      WorkspaceMode.missionTimeline ||
      WorkspaceMode.evidenceCanvas => const WorkspaceScreen(),
    };
  }
}
