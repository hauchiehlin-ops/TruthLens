import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/calibration_exporter.dart';
import 'package:omnitrace/core/services/calibration_service.dart';

CalibrationSample _s({
  required String id,
  bool isAi = false,
  String? text,
  String label = '',
}) => CalibrationSample(
  id: id,
  score: isAi ? 0.8 : 0.2,
  addedAt: DateTime(2026, 8, 17),
  isAi: isAi,
  text: text,
  label: label,
);

List<Map<String, dynamic>> _rows(ExportPayload payload) => utf8
    .decode(payload.bytes)
    .split('\n')
    .where((line) => line.isNotEmpty)
    .map((line) => jsonDecode(line) as Map<String, dynamic>)
    .toList();

void main() {
  test('輸出格式與 prepare_corpus.py 一致，欄位齊備', () {
    final payload = CalibrationExporter.buildJsonl([
      _s(
        id: 'a',
        text: 'The experiment measured torque values.',
        label: '三年二班',
      ),
      _s(id: 'b', isAi: true, text: 'An essay produced by a model.'),
    ]);

    final rows = _rows(payload);
    expect(rows, hasLength(2));
    for (final row in rows) {
      expect(row.keys.toSet(), {
        'id',
        'doc_id',
        'label',
        'source',
        'words',
        'text',
      }, reason: '欄位必須與離線端完全一致，否則要多做轉檔');
      // 一筆校準樣本即一份獨立文件
      expect(row['doc_id'], row['id']);
    }
    expect(rows[0]['label'], 'human');
    expect(rows[0]['source'], '三年二班');
    expect(rows[1]['label'], 'ai');
    expect(rows[1]['source'], 'in-app', reason: '未命名時給可辨識的預設來源');
  });

  test('沒有原文的樣本被略過並明確計數，不靜默吞掉', () {
    final payload = CalibrationExporter.buildJsonl([
      _s(id: 'a', text: 'Has text here for evaluation.'),
      _s(id: 'b'), // 未保留原文
      _s(id: 'c', text: '   '), // 只有空白
    ]);

    expect(payload.exported, 1);
    expect(payload.skippedMissingText, 2);
    expect(_rows(payload), hasLength(1));
  });

  test('字數計算與離線端同規則：CJK 逐字、拉丁以詞', () {
    final payload = CalibrationExporter.buildJsonl([
      _s(id: 'a', text: '這是一份報告 hello world'),
    ]);
    expect(_rows(payload).single['words'], 8); // 6 個中文字 + 2 個英文詞
  });

  test('兩類皆達 30 份才視為可進行離線評測', () {
    List<CalibrationSample> build(int human, int ai) => [
      for (var i = 0; i < human; i++) _s(id: 'h$i', text: 'human sample text'),
      for (var i = 0; i < ai; i++)
        _s(id: 'a$i', isAi: true, text: 'ai sample text'),
    ];

    expect(
      CalibrationExporter.buildJsonl(build(30, 30)).readyForEvaluation,
      isTrue,
    );
    expect(
      CalibrationExporter.buildJsonl(build(30, 29)).readyForEvaluation,
      isFalse,
    );
    expect(
      CalibrationExporter.buildJsonl(build(29, 30)).readyForEvaluation,
      isFalse,
    );

    final counted = CalibrationExporter.buildJsonl(build(31, 12));
    expect(counted.humanCount, 31);
    expect(counted.aiCount, 12);
  });

  test('全部沒有原文時回報 isEmpty，介面才能給出正確提示', () {
    final payload = CalibrationExporter.buildJsonl([_s(id: 'a'), _s(id: 'b')]);
    expect(payload.isEmpty, isTrue);
    expect(payload.readyForEvaluation, isFalse);
  });
}
