import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/detection_result.dart';
import 'claim_audit.dart';
import 'integrated_assessment.dart';

/// 歷史檢測紀錄（SQLite）。桌面端（macOS/Windows）走 sqflite FFI。
class HistoryRepository {
  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getApplicationSupportDirectory();
    _db = await openDatabase(
      p.join(dir.path, 'truthlens_history.db'),
      version: 3,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE history (
          id TEXT PRIMARY KEY,
          analyzed_at INTEGER NOT NULL,
          input_text TEXT NOT NULL,
          source_file_name TEXT NOT NULL DEFAULT '',
          ai_probability REAL NOT NULL,
          verdict TEXT NOT NULL,
          integrated_likelihood REAL NOT NULL,
          integrated_direction TEXT NOT NULL,
          integrated_confidence TEXT NOT NULL,
          esl_adjusted INTEGER NOT NULL DEFAULT 0
        )
      '''),
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE history ADD COLUMN source_file_name TEXT NOT NULL DEFAULT ''",
          );
        }
        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE history ADD COLUMN integrated_likelihood REAL',
          );
          await db.execute(
            'ALTER TABLE history ADD COLUMN integrated_direction TEXT',
          );
          await db.execute(
            'ALTER TABLE history ADD COLUMN integrated_confidence TEXT',
          );
          await db.execute('''
            UPDATE history
            SET integrated_likelihood = ai_probability,
                integrated_direction = CASE
                  WHEN ai_probability > 0.5 THEN 'likelyAi'
                  ELSE 'likelyHuman'
                END,
                integrated_confidence = 'low'
          ''');
        }
      },
    );
    return _db!;
  }

  Future<void> save(DetectionResult result) async {
    final db = await _open();
    final integrated = IntegratedAssessment.assess(
      result,
      claims: ClaimAudit.analyze(result.inputText),
    );
    await db.insert('history', {
      'id': result.id,
      'analyzed_at': result.analyzedAt.millisecondsSinceEpoch,
      'input_text': result.inputText,
      'source_file_name': result.sourceFileName,
      'ai_probability': result.aiProbability,
      'verdict': result.verdict.name,
      'integrated_likelihood': integrated.aiLikelihood,
      'integrated_direction': integrated.direction.name,
      'integrated_confidence': integrated.confidence.name,
      'esl_adjusted': result.eslAdjusted ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<HistoryEntry>> list({String? query}) async {
    final db = await _open();
    final rows = await db.query(
      'history',
      where: query != null && query.isNotEmpty ? 'input_text LIKE ?' : null,
      whereArgs: query != null && query.isNotEmpty ? ['%$query%'] : null,
      orderBy: 'analyzed_at DESC',
      limit: 200,
    );
    return rows.map(HistoryEntry.fromRow).toList();
  }

  Future<void> delete(String id) async {
    final db = await _open();
    await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await _open();
    await db.delete('history');
  }
}

/// 歷史列表項（不含完整逐句結果，重新分析可還原）
class HistoryEntry {
  final String id;
  final DateTime analyzedAt;
  final String inputText;
  final String sourceFileName;
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
    required this.aiProbability,
    required this.verdict,
    required this.integratedAiLikelihood,
    required this.integratedDirection,
    required this.integratedConfidence,
  });

  factory HistoryEntry.fromRow(Map<String, Object?> row) {
    final textProbability = (row['ai_probability'] as num).toDouble();
    final integratedProbability =
        (row['integrated_likelihood'] as num?)?.toDouble() ?? textProbability;
    return HistoryEntry(
      id: row['id'] as String,
      analyzedAt: DateTime.fromMillisecondsSinceEpoch(
        row['analyzed_at'] as int,
      ),
      inputText: row['input_text'] as String,
      sourceFileName: (row['source_file_name'] as String?) ?? '',
      aiProbability: textProbability,
      verdict: Verdict.values.byName(row['verdict'] as String),
      integratedAiLikelihood: integratedProbability,
      integratedDirection:
          IntegratedDirection.values
              .where((value) => value.name == row['integrated_direction'])
              .firstOrNull ??
          (integratedProbability > 0.5
              ? IntegratedDirection.likelyAi
              : IntegratedDirection.likelyHuman),
      integratedConfidence:
          IntegratedConfidence.values
              .where((value) => value.name == row['integrated_confidence'])
              .firstOrNull ??
          IntegratedConfidence.low,
    );
  }
}
