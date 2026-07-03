import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/services/report_exporter.dart';

DetectionResult _sampleResult() => DetectionResult(
      id: 'test-1',
      analyzedAt: DateTime(2026, 7, 3, 21, 30),
      inputText: '這是第一句。這是「含引號, 與逗號」的第二句。',
      aiProbability: 0.55,
      verdict: Verdict.mixed,
      engineScores: const [
        EngineScore(
          engineId: 'statistical',
          engineName: '統計特徵分析',
          aiProbability: 0.6,
          weight: 0.25,
          reasons: ['句子長度高度一致'],
        ),
        EngineScore(
          engineId: 'transformer',
          engineName: 'Transformer 分類器',
          aiProbability: 0.5,
          weight: 0.40,
          available: false,
          reasons: ['模型尚未安裝'],
        ),
      ],
      sentences: const [
        SentenceScore(index: 0, text: '這是第一句。', aiProbability: 0.3),
        SentenceScore(
          index: 1,
          text: '這是「含引號, 與逗號」的第二句。',
          aiProbability: 0.7,
          patterns: ['通用過渡詞「此外」'],
        ),
      ],
      elapsed: const Duration(milliseconds: 1234),
    );

void main() {
  group('ReportExporter.buildCsv', () {
    test('含摘要註解與逐句資料列', () {
      final csv = ReportExporter.buildCsv(_sampleResult());
      final lines = csv.trim().split('\n');
      expect(lines.where((l) => l.startsWith('#')).length, 5);
      expect(lines, contains('index,sentence,ai_probability,patterns'));
      expect(lines.last, startsWith('1,'));
      expect(csv, contains('overall_ai_probability,0.5500'));
    });

    test('逗號與引號正確跳脫', () {
      final csv = ReportExporter.buildCsv(_sampleResult());
      expect(csv, contains('"這是「含引號, 與逗號」的第二句。"'));
      // 跳脫後的欄位數不變
      final dataLine =
          csv.trim().split('\n').firstWhere((l) => l.startsWith('1,'));
      // 引號欄位內的逗號不應被視為分隔符（簡單驗證：以 " 包裹）
      expect(RegExp(r'^1,".*",0\.7000,').hasMatch(dataLine), isTrue);
    });
  });

  group('ReportExporter.buildJson', () {
    test('產生合法 JSON 且含關鍵欄位', () {
      final json = ReportExporter.buildJson(_sampleResult());
      final map = jsonDecode(json) as Map<String, dynamic>;
      expect(map['version'], 1);
      expect(map['overall']['verdict'], 'mixed');
      expect(map['overall']['ai_probability'], 0.55);
      expect((map['engines'] as List).length, 2);
      expect((map['sentences'] as List).length, 2);
      expect(map['headline'], isA<String>());
    });

    test('逐句 patterns 保留為陣列', () {
      final map = jsonDecode(ReportExporter.buildJson(_sampleResult()))
          as Map<String, dynamic>;
      final second = (map['sentences'] as List)[1] as Map<String, dynamic>;
      expect(second['patterns'], ['通用過渡詞「此外」']);
    });
  });

  group('ReportExporter.buildPdf', () {
    test('產生有效的 PDF 位元組（內嵌 CJK 字型）', () async {
      final regular =
          File('assets/fonts/NotoSansTC-Regular.ttf').readAsBytesSync();
      final bold = File('assets/fonts/NotoSansTC-Bold.ttf').readAsBytesSync();
      final bytes = await ReportExporter.buildPdf(
        _sampleResult(),
        regularFont: regular.buffer.asByteData(),
        boldFont: bold.buffer.asByteData(),
      );
      expect(bytes.length, greaterThan(1000));
      // PDF 魔術數字 %PDF
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });
  });
}
