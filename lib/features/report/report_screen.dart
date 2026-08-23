import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/detection/report_llm_service.dart';
import '../../core/models/detection_result.dart';
import '../../core/services/bibliography_verifier.dart';
import '../../core/services/citation_evidence.dart';
import '../../core/services/claim_audit.dart';
import '../../core/services/link_verifier.dart';
import '../../core/services/network_status.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/publication_evidence.dart';
import '../../core/services/report_exporter.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/app_copyright_footer.dart';
import '../../shared/widgets/authorship_challenge_card.dart';
import '../../shared/widgets/professional_report_header.dart';
import '../../shared/widgets/suspicious_sentences_list.dart';
import 'bibliography_presentation.dart';
import 'report_document.dart';

@visibleForTesting
List<BibliographyCheckResult> deduplicateBibliographyPreviewResults(
  List<BibliographyCheckResult>? checks,
  String Function(BibliographyCheckResult check) labelFor,
) {
  if (checks == null || checks.isEmpty) return const [];
  final preview = <BibliographyCheckResult>[];
  final seenLabels = <String>{};
  for (final check in checks) {
    final label = labelFor(check);
    if (!seenLabels.add(label)) continue;
    preview.add(check);
    if (preview.length >= 3) break;
  }
  return preview;
}

/// 報告頁：版面由 [ReportDocument] 動態決定（LLM 或確定性模板生成）。
/// 依 document 的元件順序渲染，並標示生成來源。
class ReportScreen extends StatefulWidget {
  final DetectionResult result;
  final bool embedded;
  final ValueChanged<PublicationEvidence>? onPublicationEvidenceChanged;

  const ReportScreen({
    super.key,
    required this.result,
    this.embedded = false,
    this.onPublicationEvidenceChanged,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late final ClaimAudit _claimAudit;
  ReportDocument? _doc;

  late final List<String> _detectedUrls = LinkVerifier.extractUrls(
    result.inputText,
  );
  bool _checkingLinks = false;
  List<LinkCheckResult>? _linkChecks;
  late final String? _sourceDoi = PublicationEvidence.extractSourceDoi(
    result.inputText,
  );
  PublicationEvidence _publicationEvidence = PublicationEvidence.none;

  late final List<BibliographyEntry> _bibEntries =
      BibliographyVerifier.extractEntries(result.inputText);
  bool _checkingBib = false;
  List<BibliographyCheckResult>? _bibChecks;
  int _bibCompleted = 0;
  int _bibTotal = 0;
  BibliographyEntry? _bibCurrentEntry;
  // 針對已顯示清單中特定幾筆文獻重新查核時使用；與 [_checkingBib]（整批初次
  // 驗證）分開追蹤，讓畫面能停留在完整清單、只在受影響列顯示查核中狀態，
  // 不會因暫時切換成精簡進度卡而讓捲動位置跳回頁首。
  Set<int> _bibRecheckingIndexes = {};

  /// App 執行時預設假定網路可用；`null` 代表本次報告尚未探測過，
  /// `false` 代表偵測到連線不佳／離線，需提示使用者。
  bool? _networkAvailable;

  DetectionResult get result => widget.result;

  @override
  void initState() {
    super.initState();
    _claimAudit = ClaimAudit.analyze(result.inputText);
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
          (_detectedUrls.isNotEmpty ||
              _bibEntries.isNotEmpty ||
              _sourceDoi != null)) {
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
    if (_sourceDoi != null) {
      tasks.add(
        PublicationEvidence.verify(
          inputText: result.inputText,
          sourceFileName: result.sourceFileName,
        ).then((evidence) {
          if (mounted) {
            setState(() {
              _publicationEvidence = evidence;
            });
            widget.onPublicationEvidenceChanged?.call(evidence);
          }
        }),
      );
    }
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
              _bibChecks = orderBibliographyChecks(checks);
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

  Future<void> _recheckBibliographyEntries(List<int> indexes) async {
    if (_bibRecheckingIndexes.isNotEmpty || indexes.isEmpty) return;

    final existingChecks = _bibChecks;
    if (existingChecks == null || existingChecks.isEmpty) {
      await _runVerification(forceRecheck: true);
      return;
    }

    final targetIndexes =
        indexes
            .where((i) => i >= 0 && i < existingChecks.length)
            .toSet()
            .toList()
          ..sort();
    if (targetIndexes.isEmpty) return;

    setState(() {
      _bibRecheckingIndexes = targetIndexes.toSet();
      _bibCompleted = 0;
      _bibTotal = targetIndexes.length;
      _bibCurrentEntry = existingChecks[targetIndexes.first].entry;
      _networkAvailable = null;
    });

    final online = await NetworkStatus.isOnline();
    if (mounted) setState(() => _networkAvailable = online);

    if (!online) {
      if (mounted) {
        setState(() {
          _bibRecheckingIndexes = {};
          _bibCurrentEntry = null;
        });
      }
      return;
    }

    final workingChecks = List<BibliographyCheckResult>.from(existingChecks);
    final targetEntries = [
      for (final i in targetIndexes) existingChecks[i].entry,
    ];

    final updatedChecks = await BibliographyVerifier.verifyAll(
      targetEntries,
      onProgress: (progress) {
        if (!mounted) return;
        setState(() {
          _bibCompleted = progress.completed;
          _bibTotal = progress.total;
          _bibCurrentEntry = progress.currentEntry;
          final latest = progress.latestResult;
          if (latest != null) {
            final replaceAt = targetIndexes[progress.completed - 1];
            workingChecks[replaceAt] = latest;
            _bibChecks = List<BibliographyCheckResult>.from(workingChecks);
          }
        });
      },
    );

    if (!mounted) return;
    setState(() {
      for (var i = 0; i < updatedChecks.length; i += 1) {
        workingChecks[targetIndexes[i]] = updatedChecks[i];
      }
      _bibChecks = orderBibliographyChecks(workingChecks);
      _bibRecheckingIndexes = {};
      _bibCompleted = updatedChecks.length;
      _bibTotal = updatedChecks.length;
      _bibCurrentEntry = null;
    });
  }

  Future<void> _export(
    Future<String?> Function(
      DetectionResult,
      AppLocalizations, {
      ReportDocument? reportDocument,
      List<BibliographyCheckResult>? bibliographyChecks,
      PublicationEvidence? publicationEvidence,
    })
    exporter,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    try {
      final path = await exporter(
        result,
        l10n,
        reportDocument: _doc,
        bibliographyChecks: _bibChecks,
        publicationEvidence: _publicationEvidence,
      );
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
    final content = doc == null
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
        : SelectionArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  children: [
                    // 專業報告頂部：判定摘要 + 三列指標 + 引擎貢獻度
                    ProfessionalReportHeader(
                      result: result,
                      onDownloadPdf: () => _export(ReportExporter.exportPdf),
                      // 引用核實是可查證的事實，不是機率推論，
                      // 因此獨立傳入而非併進 aiProbability
                      citations: CitationEvidence.fromChecks(
                        _bibChecks ?? const [],
                      ),
                      claims: _claimAudit,
                      publication: _publicationEvidence,
                    ),

                    if (result.wordCount >= DetectionResult.minWords) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: AuthorshipChallengeCard(result: result),
                      ),
                    ],

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
                            _bibEntries.isNotEmpty ||
                            _sourceDoi != null)) ...[
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _networkWarningCard(l10n),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const AppCopyrightFooter(),
                  ],
                ),
              ),
            ),
          );
    if (widget.embedded) return content;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.reportAppBarTitle),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.share2),
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
                  leading: Icon(LucideIcons.fileType2),
                  title: Text(l10n.reportExportPdf),
                ),
              ),
              PopupMenuItem(
                value: 'csv',
                child: ListTile(
                  leading: Icon(LucideIcons.table),
                  title: Text(l10n.reportExportCsv),
                ),
              ),
              PopupMenuItem(
                value: 'json',
                child: ListTile(
                  leading: Icon(LucideIcons.braces),
                  title: Text(l10n.reportExportJson),
                ),
              ),
              PopupMenuItem(
                value: 'png',
                child: ListTile(
                  leading: Icon(LucideIcons.image),
                  title: Text(l10n.reportExportPng),
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(LucideIcons.house),
            tooltip: l10n.reportHomeTooltip,
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: content,
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
            Icon(LucideIcons.wifiOff, color: scheme.error),
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
                    icon: Icon(LucideIcons.refreshCw),
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
              Icon(LucideIcons.link, color: scheme.onSurfaceVariant),
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
                  : Icon(LucideIcons.link, color: scheme.onSurfaceVariant),
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
                        icon: Icon(LucideIcons.wifi),
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
                        LinkStatus.reachable => LucideIcons.checkCircle,
                        LinkStatus.notFound => LucideIcons.unlink,
                        LinkStatus.unreachable => LucideIcons.helpCircle,
                      },
                      size: 18,
                      color: switch (c.status) {
                        LinkStatus.reachable =>
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.greenAccent.shade200
                              : Colors.green.shade800,
                        LinkStatus.notFound =>
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.red.shade200
                              : Colors.red.shade800,
                        LinkStatus.unreachable =>
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.amber.shade300
                              : Colors.orange.shade900,
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
    final previewChecks = _deduplicatedBibliographyPreview(checks, l10n);

    if (_bibEntries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(LucideIcons.bookOpen, color: scheme.onSurfaceVariant),
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
                  : Icon(LucideIcons.bookOpen, color: scheme.onSurfaceVariant),
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
                          l10n.reportBibCompletedPreview(
                            (checks ?? const []).length,
                          ),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        for (final c in previewChecks)
                          Builder(
                            builder: (context) {
                              final presentation = presentBibliographyCheck(
                                c,
                                l10n,
                              );
                              final statusColor = _bibStatusColor(
                                presentation.tone,
                                Theme.of(context).brightness,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      _bibStatusIcon(c),
                                      size: 16,
                                      color: statusColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        _bibStatusLabel(c, l10n),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: statusColor),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ],
                    if (!_checkingBib) ...[
                      const SizedBox(height: 4),
                      Text(l10n.reportBibDisabledHint),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _runVerification(forceRecheck: true),
                        icon: Icon(LucideIcons.wifi),
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
            if (_unreliableBibIndexes(checks).isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _bibRecheckingIndexes.isNotEmpty
                      ? null
                      : () => _recheckBibliographyEntries(
                          _unreliableBibIndexes(checks),
                        ),
                  icon: Icon(LucideIcons.refreshCw),
                  label: Text(l10n.reportBibRecheckAllUnreliableButton),
                ),
              ),
            ],
            const SizedBox(height: 8),
            for (var i = 0; i < checks.length; i += 1)
              Builder(
                builder: (context) {
                  final presentation = presentBibliographyCheck(
                    checks[i],
                    l10n,
                  );
                  final statusColor = _bibStatusColor(
                    presentation.tone,
                    Theme.of(context).brightness,
                  );
                  final warningColor = _bibStatusColor(
                    presentation.warningTone ?? presentation.tone,
                    Theme.of(context).brightness,
                  );
                  final rechecking = _bibRecheckingIndexes.contains(i);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        rechecking
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _bibStatusIcon(checks[i]),
                                size: 18,
                                color: presentation.warning == null
                                    ? statusColor
                                    : warningColor,
                              ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${i + 1}. ${checks[i].entry.rawText}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                presentation.status,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: statusColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              if (presentation.source != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  presentation.source!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                              if (presentation.warning != null) ...[
                                const SizedBox(height: 3),
                                Text(
                                  presentation.warning!,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: warningColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                              const SizedBox(height: 2),
                              TextButton.icon(
                                onPressed: () => _openGoogleScholar(checks[i]),
                                icon: Icon(LucideIcons.externalLink, size: 16),
                                label: Text(
                                  l10n.reportBibGoogleScholarManualLookup,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_isUnreliableBibliographyResult(checks[i])) ...[
                          const SizedBox(width: 6),
                          IconButton(
                            tooltip: l10n.reportBibRecheckOneTooltip,
                            onPressed: _bibRecheckingIndexes.isNotEmpty
                                ? null
                                : () => _recheckBibliographyEntries([i]),
                            icon: Icon(LucideIcons.refreshCw),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  String _bibStatusLabel(BibliographyCheckResult c, AppLocalizations l10n) {
    final presentation = presentBibliographyCheck(c, l10n);
    return presentation.warning == null
        ? presentation.status
        : '${presentation.status}\n${presentation.warning}';
  }

  Future<void> _openGoogleScholar(BibliographyCheckResult check) async {
    final entry = check.entry;
    final query = [
      entry.title,
      entry.firstAuthorSurname,
      if (entry.year != null) entry.year.toString(),
    ].whereType<String>().where((part) => part.trim().isNotEmpty).join(' ');
    final uri = Uri.https('scholar.google.com', '/scholar', {
      'q': query.isEmpty ? entry.rawText : query,
    });
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Color _bibStatusColor(
    BibliographyDisplayTone tone,
    Brightness brightness,
  ) => switch ((tone, brightness)) {
    (BibliographyDisplayTone.success, Brightness.dark) =>
      Colors.greenAccent.shade200,
    (BibliographyDisplayTone.success, Brightness.light) =>
      Colors.green.shade800,
    (BibliographyDisplayTone.warning, Brightness.dark) => Colors.amber.shade300,
    (BibliographyDisplayTone.warning, Brightness.light) =>
      Colors.orange.shade900,
    (BibliographyDisplayTone.mismatch, Brightness.dark) =>
      Colors.lightBlue.shade200,
    (BibliographyDisplayTone.mismatch, Brightness.light) =>
      Colors.blue.shade800,
    (BibliographyDisplayTone.error, Brightness.dark) => Colors.red.shade200,
    (BibliographyDisplayTone.error, Brightness.light) => Colors.red.shade800,
  };

  IconData _bibStatusIcon(BibliographyCheckResult check) =>
      switch (check.confidence) {
        CitationMatchConfidence.high when !check.journalNameMismatch =>
          LucideIcons.checkCircle,
        CitationMatchConfidence.notFound => LucideIcons.unlink,
        CitationMatchConfidence.high ||
        CitationMatchConfidence.uncertain => LucideIcons.alertTriangle,
      };

  bool _isUnreliableBibliographyResult(BibliographyCheckResult c) =>
      c.confidence != CitationMatchConfidence.high;

  List<int> _unreliableBibIndexes(List<BibliographyCheckResult> checks) => [
    for (var i = 0; i < checks.length; i += 1)
      if (_isUnreliableBibliographyResult(checks[i])) i,
  ];

  List<BibliographyCheckResult> _deduplicatedBibliographyPreview(
    List<BibliographyCheckResult>? checks,
    AppLocalizations l10n,
  ) => deduplicateBibliographyPreviewResults(
    checks,
    (check) => _bibStatusLabel(check, l10n),
  );

  String _bibProgressText() {
    final total = _bibTotal > 0 ? _bibTotal : _bibEntries.length;
    final current = _bibCurrentEntry;
    final currentText = current == null
        ? AppLocalizations.of(context).reportBibProgressFinalizing
        : AppLocalizations.of(
            context,
          ).reportBibProgressCurrent(_shortBibText(current.rawText));
    return AppLocalizations.of(
      context,
    ).reportBibProgress(_bibCompleted, total, currentText);
  }

  String _shortBibText(String text) {
    final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 72) return compact;
    return '${compact.substring(0, 72)}...';
  }
}
