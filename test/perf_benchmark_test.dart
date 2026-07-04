import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/utils/text_stats.dart';
import 'package:truthlens/features/report/report_composer.dart';

/// 純 Dart 熱路徑效能基準（不含原生模型推論）。
/// 對照 implementation_plan.md 第十節；此處量測前處理 + 啟發式引擎 + 報告生成。
/// 真實 ONNX 推論的量測見 integration_test/perf_benchmark_test.dart。
String _text(int chars) {
  const pool = [
    'Artificial intelligence is transforming how we work and communicate. ',
    '人工智慧正在改變我們的工作與溝通方式。',
    'It is important to note that these advancements bring both benefits and risks. ',
    '值得注意的是，這些進展同時帶來機會與風險。',
    'Furthermore, careful evaluation is required before deployment. ',
  ];
  final buf = StringBuffer();
  var i = 0;
  while (buf.length < chars) {
    buf.write(pool[i % pool.length]);
    i++;
  }
  return buf.toString().substring(0, chars);
}

Future<Duration> _time(Future<void> Function() body, {int runs = 5}) async {
  await body(); // 暖身
  final sw = Stopwatch()..start();
  for (var i = 0; i < runs; i++) {
    await body();
  }
  sw.stop();
  return Duration(microseconds: sw.elapsedMicroseconds ~/ runs);
}

void main() {
  final composer = ReportComposer();

  test('前處理 + 啟發式分析（500 字）遠低於 5 秒目標', () async {
    final text = _text(500);
    final avg = await _time(() => EnsembleOrchestrator().analyze(text));
    // ignore: avoid_print
    print('500 字 啟發式分析：${avg.inMilliseconds} ms');
    expect(avg.inSeconds, lessThan(5));
  });

  test('前處理 + 啟發式分析（5000 字）遠低於 30 秒目標', () async {
    final text = _text(5000);
    final avg = await _time(() => EnsembleOrchestrator().analyze(text));
    // ignore: avoid_print
    print('5000 字 啟發式分析：${avg.inMilliseconds} ms');
    expect(avg.inSeconds, lessThan(30));
  });

  test('斷句與統計（5000 字）在毫秒級', () async {
    final text = _text(5000);
    final avg = await _time(() async {
      final t = PreprocessedText.from(text);
      t.burstiness;
      t.typeTokenRatio;
      t.entropy;
    });
    // ignore: avoid_print
    print('5000 字 前處理+統計：${avg.inMilliseconds} ms');
    expect(avg.inMilliseconds, lessThan(500));
  });

  test('報告生成（模板）在毫秒級', () async {
    final result = await EnsembleOrchestrator().analyze(_text(2000));
    final avg = await _time(() async => composer.compose(result));
    // ignore: avoid_print
    print('模板報告生成：${avg.inMicroseconds} µs');
    expect(avg.inMilliseconds, lessThan(50));
  });
}
