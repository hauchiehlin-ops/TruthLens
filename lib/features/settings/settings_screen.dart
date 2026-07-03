import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_manager.dart';
import '../../core/detection/model_registry.dart';
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

/// 模型管理頁：列出登記模型的安裝狀態，提供下載 / 移除。
class ModelManagerScreen extends StatelessWidget {
  const ModelManagerScreen({super.key});

  String _size(int bytes) {
    if (bytes >= 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
    return '${(bytes / (1024 * 1024)).round()} MB';
  }

  @override
  Widget build(BuildContext context) {
    final manager = context.watch<ModelManager>();
    return Scaffold(
      appBar: AppBar(title: const Text('AI 模型管理')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '檢測模型與 LLM 皆在裝置端執行，下載後完全離線。'
                '未安裝的模型不參與檢測，系統會自動以其餘引擎加權投票。',
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final status in manager.statuses.values)
            Card(
              child: ListTile(
                title: Text(status.spec.name),
                subtitle: _subtitle(context, status),
                trailing: _trailing(context, manager, status),
              ),
            ),
        ],
      ),
    );
  }

  Widget _subtitle(BuildContext context, ModelStatus status) {
    final base = '${_size(status.spec.sizeBytes)} · ${_tierLabel(status.spec.tier)}';
    return switch (status.state) {
      InstallState.downloading => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: LinearProgressIndicator(value: status.progress),
        ),
      InstallState.failed => Text(
          '$base · 失敗：${status.error ?? '未知錯誤'}',
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      InstallState.installed => Text('$base · 已安裝'),
      InstallState.notInstalled => Text(base),
    };
  }

  Widget _trailing(
      BuildContext context, ModelManager manager, ModelStatus status) {
    switch (status.state) {
      case InstallState.installed:
        return IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: '移除',
          onPressed: () => manager.remove(status.spec.id),
        );
      case InstallState.downloading:
        return const SizedBox(
          width: 24, height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case InstallState.notInstalled:
      case InstallState.failed:
        // 尚未發佈的模型顯示「即將推出」（無下載來源）
        return status.spec.isDownloadable
            ? FilledButton.tonal(
                onPressed: () => manager.download(status.spec.id),
                child: const Text('下載'),
              )
            : const Chip(label: Text('即將推出'));
    }
  }

  String _tierLabel(ModelTier tier) => switch (tier) {
        ModelTier.bundled => '隨附',
        ModelTier.core => '核心',
        ModelTier.optional => '選配',
        ModelTier.language => '語言包',
      };
}
