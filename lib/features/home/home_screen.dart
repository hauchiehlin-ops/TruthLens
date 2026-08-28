import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/services/preferences_service.dart';
import '../input/input_screen.dart';
import '../onboarding/model_prompt.dart';
import '../workspace/workspace_screen.dart';

/// Keeps the classic input page and the situation-center layouts on one route.
class HomeScreen extends StatefulWidget {
  /// 首次啟動且尚未安裝偵測模型：進到首頁後詢問一次是否前往模型頁。
  /// 提示只出現一次——不論使用者前往或婉拒，都會記下已處理。
  final bool promptModelOnFirstRun;

  const HomeScreen({super.key, this.promptModelOnFirstRun = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.promptModelOnFirstRun) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _askAboutModels());
    }
  }

  Future<void> _askAboutModels() async {
    if (!mounted) return;
    // 先記下已處理再顯示：無論使用者怎麼回應（含直接關掉），下次啟動都不再打擾。
    await context.read<PreferencesService>().setFirstRunHandled();
    if (!mounted) return;
    final choice = await showFirstRunModelPrompt(context);
    if (!mounted) return;
    if (choice == ModelPromptResult.download) context.push('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<PreferencesService>().workspaceMode;
    return switch (mode) {
      WorkspaceMode.original => const InputScreen(),
      WorkspaceMode.automatic ||
      WorkspaceMode.commandGrid ||
      WorkspaceMode.missionTimeline ||
      WorkspaceMode.evidenceCanvas ||
      WorkspaceMode.cosmicFuture ||
      WorkspaceMode.softEducation => const WorkspaceScreen(),
    };
  }
}
