import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';
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

    switch (choice.result) {
      case ModelPromptResult.download:
        // 先進模型頁再開始下載：那一頁已經有逐顆的進度條與錯誤呈現，
        // 在對話框裡另做一套進度 UI 只會多一份要維護的東西。
        final provisioner = context.read<ModelProvisioner>();
        final l10n = AppLocalizations.of(context);
        context.push('/onboarding');
        for (final item in choice.selected) {
          // 逐顆依序下載。並行會讓數百 MB 的請求互相搶頻寬，
          // 進度也變得無從解讀。單顆失敗不影響其餘（模型頁會顯示該顆的錯誤）。
          await provisioner.downloadVariant(
            item.role,
            item.variant,
            l10n: l10n,
          );
        }

      case ModelPromptResult.skip:
        // 使用者選擇不下載——這時才是說明「之後去哪裡自己下載」的時機。
        await showManualModelDownloadHint(context);

      case ModelPromptResult.dismissed:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = context.watch<PreferencesService>().workspaceMode;
    return switch (mode) {
      WorkspaceMode.original => const InputScreen(),
      WorkspaceMode.commandGrid ||
      WorkspaceMode.missionTimeline ||
      WorkspaceMode.evidenceCanvas => const WorkspaceScreen(),
    };
  }
}
