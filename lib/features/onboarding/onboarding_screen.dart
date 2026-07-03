import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';
import 'model_options_list.dart';
import 'model_prompt.dart';

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
    final device = _device;
    return Scaffold(
      appBar: AppBar(
        title: const Text('歡迎使用 TruthLens'),
        automaticallyImplyLeading: false,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text('離線 AI 內容檢測',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    // 必要性說明
                    Card(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.4),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb_outline, size: 20),
                            SizedBox(width: 12),
                            Expanded(child: Text(kModelNecessityText)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (device != null)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.memory),
                          title: const Text('偵測到的裝置'),
                          subtitle: Text(device.summary),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text('選擇要下載的模型',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('已依你的硬體標示「推薦」；也可自行選擇其他選項。',
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    ModelOptionsList(plans: _plans),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _finish,
                      child: const Text('稍後再說（先用免模型的統計/風格分析）'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '略過後仍可隨時到「設定 → AI 模型管理」下載；'
                      '使用需要模型的分析時也會再次提醒。',
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
