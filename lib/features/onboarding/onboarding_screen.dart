import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'model_options_list.dart';

/// 首次啟動引導：偵測裝置能力 → 依硬體推薦並列出多個開源模型選項 → 下載或略過。
/// 已安裝核心偵測模型時不會進到這裡（由 router 判斷）。
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  DeviceCapabilities? _device;
  List<ProvisionPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final provisioner = context.read<ModelProvisioner>();
    final device = await DeviceCapabilities.detect();
    final plans = await provisioner.plan(device);
    if (mounted) {
      setState(() {
        _device = device;
        _plans = plans;
        _loading = false;
      });
    }
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
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
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
                    Text(l10n.onboardingHeadline,
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    // 必要性說明
                    Card(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.lightbulb_outline, size: 20),
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
                          leading: const Icon(Icons.memory),
                          title: Text(l10n.onboardingDetectedDevice),
                          subtitle: Text(device.summary),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(l10n.onboardingChooseModel,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(l10n.onboardingRecommendHint,
                        style: Theme.of(context).textTheme.bodySmall),
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
