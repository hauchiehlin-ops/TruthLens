import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';

/// 首次啟動引導：偵測裝置能力 → 依硬體推薦最適開源模型 → 下載或略過。
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

  String _size(int bytes) => bytes >= 1024 * 1024 * 1024
      ? '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB'
      : '${(bytes / (1024 * 1024)).round()} MB';

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
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text('離線 AI 內容檢測',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    const Text('所有推論都在你的裝置上完成。首次啟動先下載一個'
                        '適合你硬體的開源偵測模型，之後即可完全離線使用。'),
                    const SizedBox(height: 16),
                    if (device != null)
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.memory),
                          title: const Text('偵測到的裝置'),
                          subtitle: Text(device.summary),
                        ),
                      ),
                    const SizedBox(height: 8),
                    for (final plan in _plans) _planCard(plan),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _finish,
                      child: const Text('稍後再說（先用免模型的統計/風格分析）'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _planCard(ProvisionPlan plan) {
    final v = plan.recommended;
    return Consumer<ModelManager>(
      builder: (context, manager, _) {
        final status = manager.statusFor(plan.role);
        final downloading = status?.state == InstallState.downloading;
        final installed = plan.alreadyInstalled ||
            status?.state == InstallState.installed;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.roleName,
                    style: Theme.of(context).textTheme.titleMedium),
                if (v == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('目前無適用此裝置的變體'),
                  )
                else ...[
                  const SizedBox(height: 4),
                  Text('推薦：${v.name}'),
                  Text(
                    '${_size(v.sizeBytes)} · ${v.languages.join('/')} · '
                    '來源 ${v.source}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (v.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(v.note,
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                  const SizedBox(height: 12),
                  if (installed)
                    const Chip(
                      avatar: Icon(Icons.check_circle, size: 16),
                      label: Text('已安裝'),
                    )
                  else if (downloading)
                    LinearProgressIndicator(value: status?.progress)
                  else if (v.isDownloadable)
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<ModelProvisioner>().download(plan),
                      icon: const Icon(Icons.download),
                      label: Text('下載（${_size(v.sizeBytes)}）'),
                    )
                  else
                    const Chip(label: Text('即將推出')),
                  if (status?.state == InstallState.failed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text('下載失敗：${status?.error ?? ''}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error)),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
