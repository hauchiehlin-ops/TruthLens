import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/services/history_repository.dart';
import '../../l10n/generated/app_localizations.dart';

/// 歷史紀錄頁：列表 + 搜尋 + 重新分析 + 個別刪除（滑動）+ 清空全部
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<HistoryEntry> _entries = [];
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = context.read<HistoryRepository>();
    final entries = await repo.list(query: _query);
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  Future<void> _deleteEntry(HistoryEntry e) async {
    final repo = context.read<HistoryRepository>();
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    await repo.delete(e.id);
    if (!mounted) return;
    setState(() => _entries.removeWhere((x) => x.id == e.id));
    messenger.showSnackBar(SnackBar(content: Text(l10n.historyDeletedSnackbar)));
  }

  Future<void> _confirmClearAll() async {
    if (_entries.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.historyClearAllTitle),
        content: Text(l10n.historyClearAllBody(_entries.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.historyClearButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<HistoryRepository>().clearAll();
    if (mounted) setState(() => _entries = []);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyAppBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: l10n.historyClearAllTooltip,
            onPressed: _entries.isEmpty ? null : _confirmClearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.historySearchHint,
              ),
              onChanged: (v) {
                _query = v;
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? _emptyState(l10n)
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, i) {
                          final e = _entries[i];
                          final color =
                              AppTheme.verdictColor(e.aiProbability);
                          final time = e.analyzedAt
                              .toLocal()
                              .toString()
                              .substring(0, 16);
                          final verdictLabel = e.verdict.label(l10n);
                          return Dismissible(
                            key: ValueKey(e.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              color:
                                  Theme.of(context).colorScheme.errorContainer,
                              child: Icon(Icons.delete_outline,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onErrorContainer),
                            ),
                            confirmDismiss: (_) async {
                              return showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(l10n.historyDeleteEntryTitle),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(l10n.commonCancel),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(l10n.commonDelete),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) => _deleteEntry(e),
                            child: Semantics(
                              label: l10n.historyEntrySemantics(
                                  verdictLabel,
                                  (e.aiProbability * 100).round(),
                                  time,
                                  e.inputText),
                              child: ListTile(
                                leading: ExcludeSemantics(
                                  child: CircleAvatar(
                                    backgroundColor:
                                        color.withValues(alpha: 0.2),
                                    child: Text(
                                      '${(e.aiProbability * 100).round()}',
                                      style: TextStyle(
                                          color: color,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  e.inputText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text('$verdictLabel · $time'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.refresh),
                                  tooltip: l10n.historyReanalyzeTooltip,
                                  onPressed: () => context.push('/analysis',
                                      extra: e.inputText),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(AppLocalizations l10n) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history,
                size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              _query.isEmpty
                  ? l10n.historyEmptyDefault
                  : l10n.historyEmptySearch(_query),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
}
