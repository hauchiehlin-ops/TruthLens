import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/pwa_install.dart';
import '../../l10n/generated/app_localizations.dart';
import 'model_options_list.dart';

/// 模型挑選頁：偵測裝置能力 → 依硬體推薦並列出多個開源模型選項 → 下載或略過。
///
/// 不再是啟動時的攔截頁。首次啟動改為先進首頁，由首頁的一次性提示
/// （`showFirstRunModelPrompt`）詢問後才 push 進來，因此本頁必須可返回。
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DeviceCapabilities? _device;
  List<ProvisionPlan> _plans = [];
  RecommendedBundle? _bundle;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final provisioner = context.read<ModelProvisioner>();
    final languageCode = Localizations.localeOf(context).languageCode;
    final device = await DeviceCapabilities.detect();
    final plans = await provisioner.plan(device);
    final bundle = await provisioner.recommendBundle(
      device,
      languageCode: languageCode,
    );
    if (mounted) {
      setState(() {
        _device = device;
        _plans = plans;
        _bundle = bundle;
        _loading = false;
      });
    }
  }

  static String _mb(int bytes) => (bytes / 1048576).round().toString();

  /// 安裝成應用程式後再問一次持久化——這正是 Chromium 最可能改判的時機，
  /// 接著重新整理套組，讓警告在真的獲准時自己消失。
  Future<void> _installApp() async {
    final outcome = await PwaInstall.prompt();
    if (!mounted || outcome != PwaInstallOutcome.accepted) return;
    await DeviceCapabilities.requestPersistentStorage();
    if (!mounted) return;
    await _prepare();
  }

  Future<void> _finish() async {
    await context.read<PreferencesService>().setFirstRunHandled();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final device = _device;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onboardingWelcomeTitle),
        // 這頁現在是從首頁的提示 push 進來的，不再是起始路由——
        // 必須留下返回鍵，否則使用者進來後沒有退路。
        actions: [
          IconButton(
            icon: Icon(LucideIcons.settings),
            tooltip: l10n.inputSettingsTooltip,
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text(
                      l10n.onboardingHeadline,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    // 必要性說明
                    Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(LucideIcons.lightbulb, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(l10n.modelNecessityText)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (device != null)
                      Card(
                        child: ListTile(
                          leading: Icon(LucideIcons.tabletSmartphone),
                          title: Text(l10n.onboardingDetectedDevice),
                          subtitle: Text(device.summary),
                        ),
                      ),
                    // 逐 role 的「推薦」標記回答不了「總共要下載幾顆、多大」。
                    // 模型放在瀏覽器配額裡，逐項都放得下不代表加起來放得下。
                    if (_bundle case final bundle?) ...[
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(LucideIcons.packageCheck, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      l10n.onboardingBundleTitle,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.onboardingBundleSummary(
                                  bundle.count,
                                  _mb(bundle.totalBytes),
                                ),
                              ),
                              if (bundle.storageAvailableBytes
                                  case final available?)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    l10n.onboardingBundleStorage(
                                      _mb(available),
                                      _mb(bundle.remainingBytes ?? 0),
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              if (!bundle.storagePersisted) ...[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        LucideIcons.triangleAlert,
                                        size: 16,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          l10n.onboardingStorageNotPersisted,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // 只有 Chromium 會給這個事件。Safari 必須手動
                                // 「加入主畫面」，那時沒有按鈕可按，上面那段
                                // 說明就是使用者僅有的指引，因此不能省略。
                                if (PwaInstall.canInstall)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: FilledButton.tonalIcon(
                                        onPressed: _installApp,
                                        icon: Icon(
                                          LucideIcons.download,
                                          size: 18,
                                        ),
                                        label: Text(
                                          l10n.onboardingInstallAppButton,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingChooseModel,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.onboardingRecommendHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    ModelOptionsList(plans: _plans),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _finish,
                      child: Text(l10n.onboardingSkipButton),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.onboardingSkipHint,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
