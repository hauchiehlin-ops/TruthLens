import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/detection_result.dart';

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
      version: 2,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE history (
          id TEXT PRIMARY KEY,
          analyzed_at INTEGER NOT NULL,
          input_text TEXT NOT NULL,
          source_file_name TEXT NOT NULL DEFAULT '',
          ai_probability REAL NOT NULL,
          verdict TEXT NOT NULL,
          esl_adjusted INTEGER NOT NULL DEFAULT 0
        )
      '''),
      onUpgrade: (db, oldVersion, _) async {
        if (oldVersion < 2) {
          await db.execute(
            "ALTER TABLE history ADD COLUMN source_file_name TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
    return _db!;
  }

  Future<void> save(DetectionResult result) async {
    final db = await _open();
    await db.insert('history', {
      'id': result.id,
      'analyzed_at': result.analyzedAt.millisecondsSinceEpoch,
      'input_text': result.inputText,
      'source_file_name': result.sourceFileName,
      'ai_probability': result.aiProbability,
      'verdict': result.verdict.name,
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

  const HistoryEntry({
    required this.id,
    required this.analyzedAt,
    required this.inputText,
    this.sourceFileName = '',
    required this.aiProbability,
    required this.verdict,
  });

  factory HistoryEntry.fromRow(Map<String, Object?> row) => HistoryEntry(
    id: row['id'] as String,
    analyzedAt: DateTime.fromMillisecondsSinceEpoch(row['analyzed_at'] as int),
    inputText: row['input_text'] as String,
    sourceFileName: (row['source_file_name'] as String?) ?? '',
    aiProbability: row['ai_probability'] as double,
    verdict: Verdict.values.byName(row['verdict'] as String),
  );
}
