import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/detection/device_capabilities.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/services/preferences_service.dart';
import '../onboarding/model_options_list.dart';
import '../onboarding/model_prompt.dart';
import 'model_import_screen.dart';

/// 設定頁：信心閾值、ESL 修正、主題；模型管理（P2）與語言包（P4）後續加入
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    final modelManager = context.watch<ModelManager>();
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '子偵測引擎啟用設定 (Ensemble)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          SwitchListTile(
            title: const Text('多語言 AI 分類器 (Transformer)'),
            subtitle: const Text('使用 Transformer 神經網路模型進行端上 AI 機率預測'),
            value: prefs.isEngineEnabled('transformer'),
            onChanged: (v) => prefs.setEngineEnabled('transformer', v),
          ),
          SwitchListTile(
            title: const Text('統計分析引擎 (Statistical)'),
            subtitle: const Text('透過句長波動度、Burstiness 及 PPL 判定語言規律'),
            value: prefs.isEngineEnabled('statistical'),
            onChanged: (v) => prefs.setEngineEnabled('statistical', v),
          ),
          SwitchListTile(
            title: const Text('風格特徵分析 (Stylometry)'),
            subtitle: const Text('分析語意流暢度、重複句式與過渡詞等寫作特徵'),
            value: prefs.isEngineEnabled('stylometry'),
            onChanged: (v) => prefs.setEngineEnabled('stylometry', v),
          ),
          SwitchListTile(
            title: const Text('對抗式改寫偵測 (Adversarial)'),
            subtitle: const Text('辨識是否經過機器改寫或去 AI 痕跡處理'),
            value: prefs.isEngineEnabled('adversarial'),
            onChanged: (v) => prefs.setEngineEnabled('adversarial', v),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('超連結與參考文獻目錄驗證'),
            subtitle: const Text(
              '分析報告會對文件中偵測到的網址與參考文獻條目發出連線請求，確認是否'
              '真的存在（AI 生成內容常附上看似合理但實際不存在的引用連結或文獻）。'
              'DOI 格式的學術連結、以及沒有連結的「作者—年份」參考文獻，都會查詢'
              'Crossref 公開登記資料比對。核心 AI 偵測模型仍完全在裝置端執行，'
              '不會傳送文件內容，連線僅用於此驗證與模型更新偵測，可在此關閉。',
            ),
            value: prefs.linkVerificationEnabled,
            onChanged: (v) => prefs.setLinkVerificationEnabled(v),
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
            leading: Badge(
              isLabelVisible: modelManager.hasAnyUpdate,
              child: const Icon(Icons.download_outlined),
            ),
            title: const Text('AI 模型管理'),
            subtitle: Text(modelManager.hasAnyUpdate
                ? '偵測到模型更新，建議前往查看'
                : '下載檢測模型與報告 LLM，啟用完整推論能力'),
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModelManagerScreen()),
              ),
              child: const Text('開啟'),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_upload_outlined),
            title: const Text('自訂 ONNX 模型匯入與測試'),
            subtitle: const Text('匯入本機的自訂 ONNX 模型與 Tokenizer 設定並進行推論測試'),
            trailing: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModelImportScreen()),
              ),
              child: const Text('開啟'),
            ),
          ),
          const Divider(),
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
      appBar: AppBar(
        title: const Text('AI 模型管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            tooltip: '匯入本機 ONNX 模型',
            onPressed: () async {
              final imported = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => const ModelImportScreen()),
              );
              if (imported == true) {
                _load();
              }
            },
          ),
        ],
      ),
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
