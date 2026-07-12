import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/orchestrator.dart';
import '../../core/models/detection_result.dart';
import '../../core/services/history_repository.dart';
import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/analysis_wave.dart';

/// 分析進度頁：顯示四個子模型的即時進度，完成後導向報告頁。
/// 方案③（能力分級＋漸進式結果）：風格特徵引擎（純 Dart、無需下載模型）通常最先
/// 完成，一出結果就顯示「初步結果」；Transformer/統計/對抗引擎陸續完成時即時
/// 更新加權分數，全部完成後才轉場到完整報告頁——體感延遲低，但最終判定仍是
/// 完整 Ensemble，準確度不打折。
class AnalysisScreen extends StatefulWidget {
  final String text;
  const AnalysisScreen({super.key, required this.text});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final _done = <String>{};
  final _scores = <String, EngineScore>{};

  Map<String, String> _engineLabels(AppLocalizations l10n) => {
        'transformer': l10n.analysisEngineTransformer,
        'statistical': l10n.analysisEngineStatistical,
        'stylometry': l10n.analysisEngineStylometry,
        'adversarial': l10n.analysisEngineAdversarial,
      };

  @override
  void initState() {
    super.initState();
    // _run() 需讀取 AppLocalizations.of(context)（依賴 InheritedWidget），
    // 不可在 initState 同步階段呼叫，否則拋 dependOnInheritedWidgetOfExactType
    // 例外導致分析永遠不啟動。延到首個 frame 之後、widget 已掛載時再執行。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _run();
    });
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
      onEngineScore: (score) {
        if (mounted) setState(() => _scores[score.engineId] = score);
      },
    );
    await history.save(result);
    if (mounted) context.pushReplacement('/report', extra: result);
  }

  /// 目前已完成引擎的即時加權分數（僅計入 available 的引擎）。
  /// 與 [EnsembleOrchestrator._weightedVote] 邏輯一致，但只用「目前已知」的分數，
  /// 隨每個引擎完成而重新計算、逐步逼近最終結果。
  double? get _runningProbability {
    final available = _scores.values.where((s) => s.available);
    if (available.isEmpty) return null;
    final totalWeight = available.fold(0.0, (sum, s) => sum + s.weight);
    if (totalWeight <= 0) return null;
    return available.fold(0.0, (sum, s) => sum + s.aiProbability * s.weight) /
        totalWeight;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final engineLabels = _engineLabels(l10n);
    final running = _runningProbability;
    final refining = _done.length < engineLabels.length;
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
              if (running != null) ...[
                const SizedBox(height: 20),
                _PreliminaryResultCard(probability: running, refining: refining),
              ],
              const SizedBox(height: 24),
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
                  trailing: _scores[entry.key] != null
                      ? Text(
                          '${(_scores[entry.key]!.aiProbability * 100).round()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      : null,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 初步／精修中結果卡片。第一個引擎（通常是風格特徵，無需下載模型、
/// 最快出結果）完成後即顯示，隨其餘引擎完成而即時更新數值；不影響最終
/// 導向報告頁的完整 Ensemble 判定。
class _PreliminaryResultCard extends StatelessWidget {
  final double probability;
  final bool refining;
  const _PreliminaryResultCard({required this.probability, required this.refining});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final percent = (probability * 100).round();
    return Card(
      color: cs.secondaryContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (refining)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(Icons.check_circle_outline, size: 18, color: cs.primary),
            const SizedBox(width: 10),
            Text(
              refining ? '初步結果：AI 機率 $percent%（精修中…）' : '初步結果：AI 機率 $percent%',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
