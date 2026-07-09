import '../models/detection_result.dart';

/// 歷史檢測紀錄（web 版）：僅存於記憶體，重新整理頁面即清空。
/// 網頁版第一階段刻意不做 IndexedDB 持久化（見開發計畫「不在這次範圍內」），
/// 介面與原生版（SQLite）一致，供 UI 無條件呼叫。
class HistoryRepository {
  final List<HistoryEntry> _entries = [];

  Future<void> save(DetectionResult result) async {
    _entries.removeWhere((e) => e.id == result.id);
    _entries.insert(
      0,
      HistoryEntry(
        id: result.id,
        analyzedAt: result.analyzedAt,
        inputText: result.inputText,
        aiProbability: result.aiProbability,
        verdict: result.verdict,
      ),
    );
    if (_entries.length > 200) _entries.removeLast();
  }

  Future<List<HistoryEntry>> list({String? query}) async {
    if (query == null || query.isEmpty) return List.of(_entries);
    return _entries.where((e) => e.inputText.contains(query)).toList();
  }

  Future<void> delete(String id) async {
    _entries.removeWhere((e) => e.id == id);
  }

  Future<void> clearAll() async {
    _entries.clear();
  }
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
}
