import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_catalog.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';

/// 設定頁：信心閾值、ESL 修正、主題；模型管理（P2）與語言包（P4）後續加入
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            title: const Text('AI 判定信心閾值'),
            subtitle: Text(
              '目前：${(prefs.confidenceThreshold * 100).round()}% — '
              '調高可降低偽陽性（誤判人類文章為 AI）',
            ),
          ),
          Slider(
            value: prefs.confidenceThreshold,
            min: 0.4,
            max: 0.9,
            divisions: 10,
            label: '${(prefs.confidenceThreshold * 100).round()}%',
            onChanged: (v) => prefs.setThreshold(v),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('ESL 非母語者偏差修正'),
            subtitle: const Text('偵測到非母語寫作風格時，自動降低統計模型權重'),
            value: prefs.eslCorrectionEnabled,
            onChanged: (v) => prefs.setEslCorrection(v),
          ),
          const Divider(),
          ListTile(
            title: const Text('外觀主題'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode_outlined)),
                ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode_outlined)),
                ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto_outlined)),
              ],
              selected: {prefs.themeMode},
              onSelectionChanged: (s) => prefs.setThemeMode(s.first),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('AI 模型管理'),
            subtitle: const Text('下載檢測模型與報告 LLM，啟用完整推論能力'),
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModelManagerScreen()),
              ),
              child: const Text('開啟'),
            ),
          ),
          const ListTile(
            enabled: false,
            leading: Icon(Icons.language),
            title: Text('語言包'),
            subtitle: Text('額外語言微調模型（第四階段開放）'),
          ),
        ],
      ),
    );
  }
}

/// 模型管理頁：依裝置能力列出各 role 的推薦開源模型與安裝狀態，提供下載 / 移除。
class ModelManagerScreen extends StatefulWidget {
  const ModelManagerScreen({super.key});

  @override
  State<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

class _ModelManagerScreenState extends State<ModelManagerScreen> {
  DeviceCapabilities? _device;
  List<ProvisionPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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

  String _size(int bytes) => bytes >= 1024 * 1024 * 1024
      ? '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB'
      : '${(bytes / (1024 * 1024)).round()} MB';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI 模型管理')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '模型皆在裝置端執行，下載後完全離線。'
                          '未安裝的模型不參與檢測，系統以其餘引擎加權投票。',
                        ),
                        if (_device != null) ...[
                          const SizedBox(height: 8),
                          Text('裝置：${_device!.summary}',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final plan in _plans) _planCard(plan),
              ],
            ),
    );
  }

  Widget _planCard(ProvisionPlan plan) {
    final v = plan.recommended;
    return Consumer<ModelManager>(
      builder: (context, manager, _) {
        final status = manager.statusFor(plan.role);
        final state = status?.state ?? InstallState.notInstalled;
        return Card(
          child: ListTile(
            title: Text(plan.roleName),
            subtitle: _subtitle(context, plan, v, status),
            trailing: _trailing(context, plan, v, state, status?.progress ?? 0),
          ),
        );
      },
    );
  }

  Widget _subtitle(BuildContext context, ProvisionPlan plan, ModelVariant? v,
      ModelStatus? status) {
    if (status?.state == InstallState.downloading) {
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: LinearProgressIndicator(value: status?.progress),
      );
    }
    if (v == null) return const Text('無適用此裝置的變體');
    final base = '${v.name} · ${_size(v.sizeBytes)} · ${v.languages.join('/')}';
    return switch (status?.state) {
      InstallState.installed => Text('$base · 已安裝'),
      InstallState.failed => Text('$base · 失敗：${status?.error ?? ''}',
          style: TextStyle(color: Theme.of(context).colorScheme.error)),
      _ => Text(base),
    };
  }

  Widget _trailing(BuildContext context, ProvisionPlan plan, ModelVariant? v,
      InstallState state, double progress) {
    switch (state) {
      case InstallState.installed:
        return IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: '移除',
          onPressed: () => context.read<ModelManager>().remove(plan.role),
        );
      case InstallState.downloading:
        return const SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(strokeWidth: 2));
      case InstallState.notInstalled:
      case InstallState.failed:
        if (v != null && v.isDownloadable) {
          return FilledButton.tonal(
            onPressed: () => context.read<ModelProvisioner>().download(plan),
            child: const Text('下載'),
          );
        }
        return const Chip(label: Text('即將推出'));
    }
  }
}
