import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';
import '../onboarding/model_options_list.dart';
import '../onboarding/model_prompt.dart';

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

/// 模型管理頁：依裝置能力列出各 role 的多個開源模型選項與安裝狀態，提供下載 / 移除。
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
                        const Text(kModelNecessityText),
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
                ModelOptionsList(plans: _plans),
              ],
            ),
    );
  }
}
