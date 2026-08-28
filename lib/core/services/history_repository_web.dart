import 'dart:convert';

import '../detection/web_js_bridge.dart';
import '../models/detection_result.dart';
import 'claim_audit.dart';
import 'history_metadata.dart';
import 'integrated_assessment.dart';

/// 歷史檢測紀錄（web 版）：持久化於瀏覽器 IndexedDB（見 [WebDb]），介面與原生版
/// （SQLite）一致。內容全部留在瀏覽器本機儲存內，不經任何伺服器。
class HistoryRepository {
  Future<void> save(DetectionResult result) {
    final integrated = IntegratedAssessment.assess(
      result,
      claims: ClaimAudit.analyze(result.inputText),
    );
    return WebDb.put(
      jsonEncode({
        'id': result.id,
        'analyzed_at': result.analyzedAt.millisecondsSinceEpoch,
        'input_text': result.inputText,
        'source_file_name': result.sourceFileName,
        'document_title': resolveHistoryDocumentTitle(
          sourceFileName: result.sourceFileName,
          inputText: result.inputText,
        ),
        'ai_probability': result.aiProbability,
        'verdict': result.verdict.name,
        'integrated_likelihood': integrated.aiLikelihood,
        'integrated_direction': integrated.direction.name,
        'integrated_confidence': integrated.confidence.name,
      }),
    );
  }

  Future<List<HistoryEntry>> list({String? query}) async {
    final raw = jsonDecode(await WebDb.getAllJson()) as List;
    var entries =
        raw.cast<Map<String, dynamic>>().map(HistoryEntry.fromJson).toList()
          ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    if (query != null && query.isNotEmpty) {
      final normalizedQuery = query.trim().toLowerCase();
      entries = entries
          .where((entry) => entry.matchesMetadata(normalizedQuery))
          .toList();
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
  final String sourceFileName;
  final String documentTitle;
  final double aiProbability;
  final Verdict verdict;
  final double integratedAiLikelihood;
  final IntegratedDirection integratedDirection;
  final IntegratedConfidence integratedConfidence;

  const HistoryEntry({
    required this.id,
    required this.analyzedAt,
    required this.inputText,
    this.sourceFileName = '',
    this.documentTitle = '',
    required this.aiProbability,
    required this.verdict,
    required this.integratedAiLikelihood,
    required this.integratedDirection,
    required this.integratedConfidence,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> j) {
    return HistoryEntry.fromMap(j);
  }

  factory HistoryEntry.fromMap(Map<String, Object?> j) {
    final textProbability = (j['ai_probability'] as num).toDouble();
    final integratedProbability =
        (j['integrated_likelihood'] as num?)?.toDouble() ?? textProbability;
    return HistoryEntry(
      id: j['id'] as String,
      analyzedAt: DateTime.fromMillisecondsSinceEpoch(j['analyzed_at'] as int),
      inputText: j['input_text'] as String,
      sourceFileName: j['source_file_name'] as String? ?? '',
      documentTitle: resolveHistoryDocumentTitle(
        storedTitle: j['document_title'] as String? ?? '',
        sourceFileName: j['source_file_name'] as String? ?? '',
        inputText: j['input_text'] as String,
      ),
      aiProbability: textProbability,
      verdict: Verdict.values.byName(j['verdict'] as String),
      integratedAiLikelihood: integratedProbability,
      integratedDirection:
          IntegratedDirection.values
              .where((value) => value.name == j['integrated_direction'])
              .firstOrNull ??
          (integratedProbability > 0.5
              ? IntegratedDirection.likelyAi
              : IntegratedDirection.likelyHuman),
      integratedConfidence:
          IntegratedConfidence.values
              .where((value) => value.name == j['integrated_confidence'])
              .firstOrNull ??
          IntegratedConfidence.low,
    );
  }

  bool matchesMetadata(String normalizedQuery) {
    return documentTitle.toLowerCase().contains(normalizedQuery) ||
        sourceFileName.toLowerCase().contains(normalizedQuery) ||
        integratedDirection.name.toLowerCase().contains(normalizedQuery) ||
        integratedConfidence.name.toLowerCase().contains(normalizedQuery);
  }
}
