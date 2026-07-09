import 'dart:convert';

import '../detection/web_js_bridge.dart';
import '../models/detection_result.dart';

/// 歷史檢測紀錄（web 版）：持久化於瀏覽器 IndexedDB（見 [WebDb]），介面與原生版
/// （SQLite）一致。內容全部留在瀏覽器本機儲存內，不經任何伺服器。
class HistoryRepository {
  Future<void> save(DetectionResult result) => WebDb.put(jsonEncode({
        'id': result.id,
        'analyzed_at': result.analyzedAt.millisecondsSinceEpoch,
        'input_text': result.inputText,
        'ai_probability': result.aiProbability,
        'verdict': result.verdict.name,
      }));

  Future<List<HistoryEntry>> list({String? query}) async {
    final raw = jsonDecode(await WebDb.getAllJson()) as List;
    var entries = raw
        .cast<Map<String, dynamic>>()
        .map(HistoryEntry.fromJson)
        .toList()
      ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    if (query != null && query.isNotEmpty) {
      entries = entries.where((e) => e.inputText.contains(query)).toList();
    }
    return entries.take(200).toList();
  }

  Future<void> delete(String id) => WebDb.deleteEntry(id);

  Future<void> clearAll() => WebDb.clear();
}

/// 歷史列表項（不含完整逐句結果，重新分析可還原）
class HistoryEntry {
  final String id;
  final DateTime analyzedAt;
  final String inputText;
  final double aiProbability;
  final Verdict verdict;

  const HistoryEntry({
    required this.id,
    required this.analyzedAt,
    required this.inputText,
    required this.aiProbability,
    required this.verdict,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
        id: j['id'] as String,
        analyzedAt:
            DateTime.fromMillisecondsSinceEpoch(j['analyzed_at'] as int),
        inputText: j['input_text'] as String,
        aiProbability: (j['ai_probability'] as num).toDouble(),
        verdict: Verdict.values.byName(j['verdict'] as String),
      );
}
