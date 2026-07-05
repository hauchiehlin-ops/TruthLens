import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/detection/report_llm_service.dart';
import '../../core/models/detection_result.dart';
import '../../core/services/bibliography_verifier.dart';
import '../../core/services/link_verifier.dart';
import '../../core/services/network_status.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/report_exporter.dart';
import '../../l10n/generated/app_localizations.dart';
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

  late final List<String> _detectedUrls =
      LinkVerifier.extractUrls(result.inputText);
  bool _checkingLinks = false;
  List<LinkCheckResult>? _linkChecks;

  late final List<BibliographyEntry> _bibEntries =
      BibliographyVerifier.extractEntries(result.inputText);
  bool _checkingBib = false;
  List<BibliographyCheckResult>? _bibChecks;

  /// App 執行時預設假定網路可用；`null` 代表本次報告尚未探測過，
  /// `false` 代表偵測到連線不佳／離線，需提示使用者。
  bool? _networkAvailable;

  DetectionResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    _generate();
    final linkVerificationOn =
        context.read<PreferencesService>().linkVerificationEnabled;
    if (linkVerificationOn &&
        (_detectedUrls.isNotEmpty || _bibEntries.isNotEmpty)) {
      _runVerification();
    }
  }

  Future<void> _generate() async {
    final service = context.read<ReportLlmService>();
    final l10n = AppLocalizations.of(context);
    final doc = await service.generate(result, l10n);
    if (mounted) setState(() => _doc = doc);
  }

  /// 超連結／文獻參考真實性驗證的單一入口：先確認網路連線狀態（可重用先前
  /// 已探測過的結果，[forceRecheck] 為 true 時強制重新探測），連線不佳時
  /// 直接顯示提示、不逐筆嘗試逾時的網路請求。
  Future<void> _runVerification({bool forceRecheck = false}) async {
    if (forceRecheck) _networkAvailable = null;
    if (_detectedUrls.isNotEmpty && mounted) {
      setState(() => _checkingLinks = true);
    }
    if (_bibEntries.isNotEmpty && mounted) {
      setState(() => _checkingBib = true);
    }

    final online = _networkAvailable ?? await NetworkStatus.isOnline();
    if (mounted) setState(() => _networkAvailable = online);

    if (!online) {
      if (mounted) {
        setState(() {
          _checkingLinks = false;
          _checkingBib = false;
        });
      }
      return;
    }

    if (_detectedUrls.isNotEmpty) {
      final checks = await LinkVerifier.verifyAll(_detectedUrls);
      if (mounted) {
        setState(() {
          _linkChecks = checks;
          _checkingLinks = false;
        });
      }
    }
    if (_bibEntries.isNotEmpty) {
      final checks = await BibliographyVerifier.verifyAll(_bibEntries);
      if (mounted) {
        setState(() {
          _bibChecks = checks;
          _checkingBib = false;
        });
      }
    }
  }

  Future<void> _export(
    Future<String?> Function(DetectionResult, AppLocalizations) exporter,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final path = await exporter(result, l10n);
      if (path != null) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.reportExported(path))));
      }
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.reportExportFailed(e.toString()))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final doc = _doc;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportAppBarTitle),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.reportExportTooltip,
            onSelected: (v) => _export(switch (v) {
              'pdf' => ReportExporter.exportPdf,
              'json' => ReportExporter.exportJson,
              'png' => ReportExporter.exportPng,
              _ => ReportExporter.exportCsv,
            }),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pdf',
                child: ListTile(
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: Text(l10n.reportExportPdf),
                ),
              ),
              PopupMenuItem(
                value: 'csv',
                child: ListTile(
                  leading: const Icon(Icons.table_chart_outlined),
                  title: Text(l10n.reportExportCsv),
                ),
              ),
              PopupMenuItem(
                value: 'json',
                child: ListTile(
                  leading: const Icon(Icons.data_object),
                  title: Text(l10n.reportExportJson),
                ),
              ),
              PopupMenuItem(
                value: 'png',
                child: ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: Text(l10n.reportExportPng),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.home_outlined),
            tooltip: l10n.reportHomeTooltip,
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: doc == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.reportGeneratingTitle),
                ],
              ),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 840),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _headlineCard(doc, l10n),
                    const SizedBox(height: 16),
                    for (final c in doc.components) ...[
                      _component(c, l10n),
                      const SizedBox(height: 16),
                    ],
                    if (_networkAvailable == false &&
                        (_detectedUrls.isNotEmpty ||
                            _bibEntries.isNotEmpty)) ...[
                      _networkWarningCard(l10n),
                      const SizedBox(height: 16),
                    ],
                    _linkVerificationCard(l10n),
                    const SizedBox(height: 16),
                    _bibliographyCard(l10n),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _headlineCard(ReportDocument doc, AppLocalizations l10n) {
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
                  llm ? l10n.reportSourceLlm : l10n.reportSourceTemplate,
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

  Widget _component(ReportComponent c, AppLocalizations l10n) {
    return switch (c.type) {
      ReportComponentType.overallGauge => _gaugeCard(l10n),
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
      ReportComponentType.engineBreakdown => _engineCard(l10n),
      ReportComponentType.sentenceHeatmap => _heatmapCard(l10n),
    };
  }

  Widget _gaugeCard(AppLocalizations l10n) => Card(
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
                l10n.reportSentenceSummary(
                    result.sentences.length,
                    result.aiSentenceCount,
                    result.humanSentenceCount,
                    (result.elapsed.inMilliseconds / 1000).toStringAsFixed(1)),
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

  Widget _engineCard(AppLocalizations l10n) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.reportEngineBreakdownTitle,
              style: Theme.of(context).textTheme.titleMedium),
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
                    : Text(l10n.reportEngineNotInstalled),
              ),
            ),
        ],
      );

  Widget _heatmapCard(AppLocalizations l10n) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.reportSentenceAnalysisTitle,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                runSpacing: 6,
                children: [
                  for (final s in result.sentences)
                    Semantics(
                      label: l10n.reportSentenceTooltip(
                          s.text,
                          (s.aiProbability * 100).round(),
                          s.patterns.isEmpty
                              ? ''
                              : '，${s.patterns.join('、')}'),
                      excludeSemantics: true,
                      child: Tooltip(
                        message: s.patterns.isEmpty
                            ? '${l10n.reportAiProbabilityLabel} ${(s.aiProbability * 100).round()}%'
                            : '${l10n.reportAiProbabilityLabel} ${(s.aiProbability * 100).round()}%\n'
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

  Widget _networkWarningCard(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer.withValues(alpha: 0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.wifi_off, color: scheme.error),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.reportNetworkWarningTitle,
                      style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(l10n.reportNetworkWarningBody),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _runVerification(forceRecheck: true),
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.reportRetryConnectionButton),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _linkVerificationCard(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    final checks = _linkChecks;

    if (_detectedUrls.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.link, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reportLinkAuthenticityTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(l10n.reportLinkNoneDetected),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (checks == null) {
      // 尚未驗證：功能關閉時僅提示、不連線；正在驗證時顯示進度
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _checkingLinks
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.link, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reportLinkAuthenticityTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      _checkingLinks
                          ? l10n.reportLinkCheckingProgress
                          : l10n.reportLinkDetectedPending(_detectedUrls.length),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (!_checkingLinks) ...[
                      const SizedBox(height: 4),
                      Text(l10n.reportLinkDisabledHint),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _runVerification(forceRecheck: true),
                        icon: const Icon(Icons.wifi_outlined),
                        label: Text(l10n.reportVerifyNowButton),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reportLinkAuthenticityTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final c in checks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      switch (c.status) {
                        LinkStatus.reachable => Icons.check_circle,
                        LinkStatus.notFound => Icons.link_off,
                        LinkStatus.unreachable => Icons.help_outline,
                      },
                      size: 18,
                      color: switch (c.status) {
                        LinkStatus.reachable => Colors.green,
                        LinkStatus.notFound => Colors.red,
                        LinkStatus.unreachable => Colors.orange,
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${c.url}\n${_linkStatusLabel(c, l10n)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            if (_detectedUrls.length > LinkVerifier.maxLinksPerCheck)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.reportLinkTruncated(
                      LinkVerifier.maxLinksPerCheck, _detectedUrls.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 一般網址只做連線可達性描述；DOI 期刊文獻則說明是否經 Crossref 目錄核實。
  String _linkStatusLabel(LinkCheckResult c, AppLocalizations l10n) {
    if (!c.isCitationVerified) {
      return switch (c.status) {
        LinkStatus.reachable => l10n.reportLinkReachable,
        LinkStatus.notFound => l10n.reportLinkNotFound,
        LinkStatus.unreachable => l10n.reportLinkUnreachable,
      };
    }
    return switch (c.status) {
      LinkStatus.reachable => l10n.reportLinkCitationVerified(
          c.journalName ?? '',
          c.articleTitle != null ? '，${c.articleTitle}' : ''),
      LinkStatus.notFound => l10n.reportLinkCitationNotFound,
      LinkStatus.unreachable => l10n.reportLinkCitationUnreachable,
    };
  }

  Widget _bibliographyCard(AppLocalizations l10n) {
    final scheme = Theme.of(context).colorScheme;
    final checks = _bibChecks;

    if (_bibEntries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.menu_book_outlined, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reportBibAuthenticityTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(l10n.reportBibNoneDetected),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (checks == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _checkingBib
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.menu_book_outlined,
                      color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.reportBibAuthenticityTitle,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      _checkingBib
                          ? l10n.reportBibCheckingProgress
                          : l10n.reportBibDetectedPending(_bibEntries.length),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (!_checkingBib) ...[
                      const SizedBox(height: 4),
                      Text(l10n.reportBibDisabledHint),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _runVerification(forceRecheck: true),
                        icon: const Icon(Icons.wifi_outlined),
                        label: Text(l10n.reportVerifyNowBibButton),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reportBibAuthenticityTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              l10n.reportBibResultHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final c in checks)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      switch (c.confidence) {
                        CitationMatchConfidence.high => Icons.check_circle,
                        CitationMatchConfidence.notFound => Icons.link_off,
                        CitationMatchConfidence.uncertain => Icons.help_outline,
                      },
                      size: 18,
                      color: switch (c.confidence) {
                        CitationMatchConfidence.high => Colors.green,
                        CitationMatchConfidence.notFound => Colors.red,
                        CitationMatchConfidence.uncertain => Colors.orange,
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${c.entry.rawText}\n${_bibStatusLabel(c, l10n)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            if (_bibEntries.length > BibliographyVerifier.maxEntriesPerCheck)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.reportBibTruncated(
                      BibliographyVerifier.maxEntriesPerCheck,
                      _bibEntries.length),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _bibStatusLabel(BibliographyCheckResult c, AppLocalizations l10n) {
    return switch (c.confidence) {
      CitationMatchConfidence.high => l10n.reportBibHighConfidence(
          c.matchedJournal != null
              ? l10n.reportBibJournalSuffix(c.matchedJournal!)
              : ''),
      CitationMatchConfidence.notFound => l10n.reportBibNotFound,
      CitationMatchConfidence.uncertain => l10n.reportBibUncertain,
    };
  }
}
