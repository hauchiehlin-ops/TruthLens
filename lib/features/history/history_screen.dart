import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/services/history_repository.dart';

/// 歷史紀錄頁：列表 + 搜尋 + 重新分析
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('歷史紀錄')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: '搜尋歷史紀錄…',
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
                    ? const Center(child: Text('尚無檢測紀錄'))
                    : ListView.builder(
                        itemCount: _entries.length,
                        itemBuilder: (context, i) {
                          final e = _entries[i];
                          final color =
                              AppTheme.verdictColor(e.aiProbability);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.2),
                              child: Text(
                                '${(e.aiProbability * 100).round()}',
                                style: TextStyle(
                                    color: color, fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(
                              e.inputText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              '${e.verdict.labelZh} · '
                              '${e.analyzedAt.toLocal().toString().substring(0, 16)}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.refresh),
                              tooltip: '重新分析',
                              onPressed: () =>
                                  context.push('/analysis', extra: e.inputText),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
