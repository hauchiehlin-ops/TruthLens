import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/detection/report_llm_service.dart';
import '../../core/models/detection_result.dart';
import '../../core/services/report_exporter.dart';
import '../../shared/widgets/score_gauge.dart';
import 'report_document.dart';

/// 報告頁：版面由 [ReportDocument] 動態決定（LLM 或確定性模板生成）。
/// 依 document 的元件順序渲染，並標示生成來源。
class ReportScreen extends StatefulWidget {
  final DetectionResult result;
  const ReportScreen({super.key, required this.result});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  ReportDocument? _doc;

  DetectionResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  Future<void> _generate() async {
    final service = context.read<ReportLlmService>();
    final doc = await service.generate(result);
    if (mounted) setState(() => _doc = doc);
  }

  Future<void> _export(
    Future<String?> Function(DetectionResult) exporter,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await exporter(result);
      if (path != null) {
        messenger.showSnackBar(SnackBar(content: Text('已匯出：$path')));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('匯出失敗：$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final doc = _doc;
    return Scaffold(
      appBar: AppBar(
        title: const Text('檢測報告'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share),
            tooltip: '匯出報告',
            onSelected: (v) => _export(switch (v) {
              'pdf' => ReportExporter.exportPdf,
              'json' => ReportExporter.exportJson,
              'png' => ReportExporter.exportPng,
              _ => ReportExporter.exportCsv,
            }),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'pdf',
                child: ListTile(
                  leading: Icon(Icons.picture_as_pdf_outlined),
                  title: Text('匯出 PDF 報告'),
                ),
              ),
              PopupMenuItem(
                value: 'csv',
                child: ListTile(
                  leading: Icon(Icons.table_chart_outlined),
                  title: Text('匯出 CSV 數據'),
                ),
              ),
              PopupMenuItem(
                value: 'json',
                child: ListTile(
                  leading: Icon(Icons.data_object),
                  title: Text('匯出 JSON（系統整合）'),
                ),
              ),
              PopupMenuItem(
                value: 'png',
                child: ListTile(
                  leading: Icon(Icons.image_outlined),
                  title: Text('匯出摘要卡（PNG）'),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: '回首頁',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: doc == null
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('正在生成報告…'),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _headlineCard(doc),
                    const SizedBox(height: 16),
                    for (final c in doc.components) ...[
                      _component(c),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _headlineCard(ReportDocument doc) {
    final llm = doc.source == ReportSource.llm;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(llm ? Icons.auto_awesome : Icons.description_outlined,
                    size: 16),
                const SizedBox(width: 6),
                Text(
                  llm ? 'AI 智慧生成報告' : '模板生成報告',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(doc.headline,
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _component(ReportComponent c) {
    return switch (c.type) {
      ReportComponentType.overallGauge => _gaugeCard(),
      ReportComponentType.thresholdBanner => _bannerCard(
          c.body ?? '',
          icon: result.flaggedAsAi ? Icons.flag : Icons.check_circle_outline,
        ),
      ReportComponentType.narrative => _narrativeCard(c),
      ReportComponentType.paraphraseWarning => _bannerCard(
          c.body ?? '',
          title: c.title,
          icon: Icons.warning_amber,
          tone: AppTheme.verdictColor(0.9),
        ),
      ReportComponentType.eslNotice => _bannerCard(
          c.body ?? '',
          title: c.title,
          icon: Icons.translate,
        ),
      ReportComponentType.patternList => _narrativeCard(c),
      ReportComponentType.engineBreakdown => _engineCard(),
      ReportComponentType.sentenceHeatmap => _heatmapCard(),
    };
  }

  Widget _gaugeCard() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              ScoreGauge(
                aiProbability: result.aiProbability,
                verdict: result.verdict,
              ),
              const SizedBox(height: 12),
              Text(
                '共 ${result.sentences.length} 句 · '
                '疑似 AI ${result.aiSentenceCount} 句 · '
                '人類 ${result.humanSentenceCount} 句 · '
                '耗時 ${(result.elapsed.inMilliseconds / 1000).toStringAsFixed(1)} 秒',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );

  Widget _bannerCard(String body,
      {String? title, IconData? icon, Color? tone}) {
    final color = tone ?? Theme.of(context).colorScheme.primary;
    return Card(
      color: color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon ?? Icons.info_outline, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: color)),
                  Text(body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _narrativeCard(ReportComponent c) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (c.title != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(c.title!,
                      style: Theme.of(context).textTheme.titleMedium),
                ),
              Text(c.body ?? '', style: const TextStyle(height: 1.5)),
            ],
          ),
        ),
      );

  Widget _engineCard() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('引擎明細', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final e in result.engineScores)
            Card(
              child: ListTile(
                leading: Icon(
                  e.available ? Icons.memory : Icons.download_outlined,
                  color: e.available
                      ? AppTheme.verdictColor(e.aiProbability)
                      : Theme.of(context).disabledColor,
                ),
                title: Text(e.engineName),
                subtitle: Text(e.reasons.join('\n')),
                trailing: e.available
                    ? Text('${(e.aiProbability * 100).round()}%',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.verdictColor(e.aiProbability)))
                    : const Text('未安裝'),
              ),
            ),
        ],
      );

  Widget _heatmapCard() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('逐句分析', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                runSpacing: 6,
                children: [
                  for (final s in result.sentences)
                    Semantics(
                      label: '${s.text}。AI 機率 ${(s.aiProbability * 100).round()}%'
                          '${s.patterns.isEmpty ? '' : '，${s.patterns.join('、')}'}',
                      excludeSemantics: true,
                      child: Tooltip(
                        message: s.patterns.isEmpty
                            ? 'AI 機率 ${(s.aiProbability * 100).round()}%'
                            : 'AI 機率 ${(s.aiProbability * 100).round()}%\n'
                                '${s.patterns.join('、')}',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.verdictColor(s.aiProbability)
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('${s.text} '),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      );
}
