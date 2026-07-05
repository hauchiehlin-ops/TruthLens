import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/orchestrator.dart';
import '../../core/services/history_repository.dart';
import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/analysis_wave.dart';

/// 分析進度頁：顯示四個子模型的即時進度，完成後導向報告頁
class AnalysisScreen extends StatefulWidget {
  final String text;
  const AnalysisScreen({super.key, required this.text});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _done = <String>{};

  Map<String, String> _engineLabels(AppLocalizations l10n) => {
        'transformer': l10n.analysisEngineTransformer,
        'statistical': l10n.analysisEngineStatistical,
        'stylometry': l10n.analysisEngineStylometry,
        'adversarial': l10n.analysisEngineAdversarial,
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
    final l10n = AppLocalizations.of(context);
    final result = await orchestrator.analyze(
      widget.text,
      eslCorrectionEnabled: prefs.eslCorrectionEnabled,
      threshold: prefs.confidenceThreshold,
      prefs: prefs,
      l10n: l10n,
      onEngineDone: (id) {
        if (mounted) setState(() => _done.add(id));
      },
    );
    await history.save(result);
    if (mounted) context.pushReplacement('/report', extra: result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final engineLabels = _engineLabels(l10n);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.analysisAppBarTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: l10n.analysisProgressSemantics(
                    _done.length, engineLabels.length),
                child: const AnalysisWave(),
              ),
              const SizedBox(height: 32),
              for (final entry in engineLabels.entries)
                ListTile(
                  leading: _done.contains(entry.key)
                      ? Icon(Icons.check_circle,
                          color: Colors.green,
                          semanticLabel: l10n.analysisDoneSemantics)
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
