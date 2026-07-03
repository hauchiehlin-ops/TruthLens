import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/orchestrator.dart';
import '../../core/services/history_repository.dart';
import '../../core/services/preferences_service.dart';

/// 分析進度頁：顯示四個子模型的即時進度，完成後導向報告頁
class AnalysisScreen extends StatefulWidget {
  final String text;
  const AnalysisScreen({super.key, required this.text});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _done = <String>{};

  static const _engineLabels = {
    'transformer': 'Transformer 分類器',
    'statistical': '統計特徵分析',
    'stylometry': '風格特徵分析',
    'adversarial': '對抗式防禦',
  };

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final orchestrator = context.read<EnsembleOrchestrator>();
    final history = context.read<HistoryRepository>();
    final prefs = context.read<PreferencesService>();
    final result = await orchestrator.analyze(
      widget.text,
      eslCorrectionEnabled: prefs.eslCorrectionEnabled,
      threshold: prefs.confidenceThreshold,
      onEngineDone: (id) {
        if (mounted) setState(() => _done.add(id));
      },
    );
    await history.save(result);
    if (mounted) context.pushReplacement('/report', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分析中')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 32),
              for (final entry in _engineLabels.entries)
                ListTile(
                  leading: _done.contains(entry.key)
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                  title: Text(entry.value),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
