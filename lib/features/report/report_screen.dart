import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/report_llm_service.dart';
import '../../core/models/detection_result.dart';
import '../../core/services/bibliography_verifier.dart';
import '../../core/services/link_verifier.dart';
import '../../core/services/network_status.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/report_exporter.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/professional_report_header.dart';
import '../../shared/widgets/suspicious_sentences_list.dart';
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

  late final List<String> _detectedUrls = LinkVerifier.extractUrls(
    result.inputText,
  );
  bool _checkingLinks = false;
  List<LinkCheckResult>? _linkChecks;

  late final List<BibliographyEntry> _bibEntries =
      BibliographyVerifier.extractEntries(result.inputText);
  bool _checkingBib = false;
  List<BibliographyCheckResult>? _bibChecks;
  int _bibCompleted = 0;
  int _bibTotal = 0;
  BibliographyEntry? _bibCurrentEntry;

  /// App 執行時預設假定網路可用；`null` 代表本次報告尚未探測過，
  /// `false` 代表偵測到連線不佳／離線，需提示使用者。
  bool? _networkAvailable;

  DetectionResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    // _generate() / _runVerification() 需讀取 AppLocalizations.of(context)，
    // 不可在 initState 同步階段呼叫（否則拋 dependOnInheritedWidgetOfExactType，
    // 報告永遠停在「正在生成報告…」）。延到首個 frame 之後、widget 已掛載時執行。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _generate();
      final linkVerificationOn = context
          .read<PreferencesService>()
          .linkVerificationEnabled;
      if (linkVerificationOn &&
          (_detectedUrls.isNotEmpty || _bibEntries.isNotEmpty)) {
        _runVerification();
      }
    });
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
      setState(() {
        _checkingBib = true;
        _bibCompleted = 0;
        _bibTotal = _bibEntries.length;
        _bibCurrentEntry = _bibEntries.first;
        _bibChecks = const [];
      });
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

    final tasks = <Future<void>>[];
    if (_detectedUrls.isNotEmpty) {
      tasks.add(
        LinkVerifier.verifyAll(_detectedUrls).then((checks) {
          if (mounted) {
            setState(() {
              _linkChecks = checks;
              _checkingLinks = false;
            });
          }
        }),
      );
    }
    if (_bibEntries.isNotEmpty) {
      tasks.add(
        BibliographyVerifier.verifyAll(
          _bibEntries,
          onProgress: (progress) {
            if (!mounted) return;
            setState(() {
              _bibCompleted = progress.completed;
              _bibTotal = progress.total;
              _bibCurrentEntry = progress.currentEntry;
              final latest = progress.latestResult;
              if (latest != null) {
                final current = List<BibliographyCheckResult>.from(
                  _bibChecks ?? const [],
                );
                current.add(latest);
                _bibChecks = current;
              }
            });
          },
        ).then((checks) {
          if (mounted) {
            setState(() {
              _bibChecks = checks;
              _checkingBib = false;
              _bibCompleted = checks.length;
              _bibTotal = checks.length;
              _bibCurrentEntry = null;
            });
          }
        }),
      );
    }
    await Future.wait(tasks);
  }

  Future<void> _export(
    Future<String?> Function(
      DetectionResult,
      AppLocalizations, {
      ReportDocument? reportDocument,
    })
    exporter,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final path = await exporter(result, l10n, reportDocument: _doc);
      if (path != null) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.reportExported(path))),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.reportExportFailed(e.toString()))),
      );
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
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  children: [
                    // 專業報告頂部：判定摘要 + 三列指標 + 引擎貢獻度
                    ProfessionalReportHeader(
                      result: result,
                      onDownloadPdf: () => _export(ReportExporter.exportPdf),
                    ),

                    // 可疑句子清單
                    if (result.sentences.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SuspiciousSentencesList(
                          sentences: result.sentences,
                          l10n: l10n,
                        ),
                      ),
                    ],

                    // 超連結驗證卡（可選）
                    if (_detectedUrls.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _linkVerificationCard(l10n),
                      ),
                    ],

                    // 文獻參考驗證卡（可選）
                    if (_bibEntries.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _bibliographyCard(l10n),
                      ),
                    ],

                    // 網路狀態警告（若適用）
                    if (_networkAvailable == false &&
                        (_detectedUrls.isNotEmpty ||
                            _bibEntries.isNotEmpty)) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _networkWarningCard(l10n),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

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
                  Text(
                    l10n.reportNetworkWarningTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
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
                    Text(
                      l10n.reportLinkAuthenticityTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.link, color: scheme.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportLinkAuthenticityTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _checkingLinks
                          ? l10n.reportLinkCheckingProgress
                          : l10n.reportLinkDetectedPending(
                              _detectedUrls.length,
                            ),
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
            Text(
              l10n.reportLinkAuthenticityTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
                    LinkVerifier.maxLinksPerCheck,
                    _detectedUrls.length,
                  ),
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
        c.articleTitle != null ? '，${c.articleTitle}' : '',
      ),
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
                    Text(
                      l10n.reportBibAuthenticityTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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

    if (checks == null || _checkingBib) {
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.menu_book_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportBibAuthenticityTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _checkingBib
                          ? l10n.reportBibCheckingProgress
                          : l10n.reportBibDetectedPending(_bibEntries.length),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    if (_checkingBib) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _bibTotal > 0 ? _bibCompleted / _bibTotal : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _bibProgressText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      if ((checks ?? const []).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          '已完成 ${(checks ?? const []).length} 筆，結果會持續更新。',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        for (final c in (checks ?? const []).take(3))
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  switch (c.confidence) {
                                    CitationMatchConfidence.high =>
                                      Icons.check_circle,
                                    CitationMatchConfidence.notFound =>
                                      Icons.link_off,
                                    CitationMatchConfidence.uncertain =>
                                      Icons.report_problem_outlined,
                                  },
                                  size: 16,
                                  color: switch (c.confidence) {
                                    CitationMatchConfidence.high =>
                                      Colors.green,
                                    CitationMatchConfidence.notFound =>
                                      Colors.red,
                                    CitationMatchConfidence.uncertain =>
                                      Colors.orange,
                                  },
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _bibStatusLabel(c, l10n),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
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
            Text(
              l10n.reportBibAuthenticityTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
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
                        CitationMatchConfidence.uncertain =>
                          Icons.report_problem_outlined,
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
            : '',
      ),
      CitationMatchConfidence.notFound => l10n.reportBibNotFound,
      CitationMatchConfidence.uncertain => _bibUnreliableLabel(c, l10n),
    };
  }

  String _bibUnreliableLabel(BibliographyCheckResult c, AppLocalizations l10n) {
    final matched = c.matchedTitle;
    if (matched != null && matched.trim().isNotEmpty) {
      return '${l10n.reportBibUncertain}：找到相似候選「${_shortBibText(matched)}」，但作者、年份或篇名未達可靠匹配門檻。';
    }
    return '${l10n.reportBibUncertain}：查核來源無可靠回應或條目資訊不足，系統不將此文獻視為已核實存在。';
  }

  String _bibProgressText() {
    final total = _bibTotal > 0 ? _bibTotal : _bibEntries.length;
    final current = _bibCurrentEntry;
    final currentText = current == null
        ? '正在整理結果'
        : '目前：${_shortBibText(current.rawText)}';
    return '進度 $_bibCompleted/$total，$currentText';
  }

  String _shortBibText(String text) {
    final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 72) return compact;
    return '${compact.substring(0, 72)}...';
  }
}
