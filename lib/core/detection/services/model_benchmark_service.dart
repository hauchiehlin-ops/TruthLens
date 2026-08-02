import 'package:flutter/widgets.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';

class BenchmarkSample {
  final String text;
  final bool isAi;
  const BenchmarkSample(this.text, this.isAi);
}

class BenchmarkReport {
  final String engineId;
  final double accuracy;
  final double avgLatencyMs;
  final double recommendedWeight;

  const BenchmarkReport({
    required this.engineId,
    required this.accuracy,
    required this.avgLatencyMs,
    required this.recommendedWeight,
  });

  Map<String, dynamic> toJson() => {
        'engine_id': engineId,
        'accuracy': accuracy,
        'avg_latency_ms': avgLatencyMs,
        'recommended_weight': recommendedWeight,
      };
}

/// 自動校準與基準評測服務 (Option C)
class ModelBenchmarkService {
  static const kDefaultBenchmarkDataset = <BenchmarkSample>[
    // AI 樣本
    BenchmarkSample(
      'Furthermore, artificial intelligence is transforming modern society. '
      'It is important to note that machine learning algorithms play a critical role. '
      'In conclusion, adopting these technologies will yield significant benefits.',
      true,
    ),
    BenchmarkSample(
      '此外，人工智慧正在改變現代社會。值得注意的是，機器學習演算法扮演著關鍵角色。'
      '綜上所述，導入此類技術將帶來顯著益處。',
      true,
    ),
    BenchmarkSample(
      'Moreover, solar energy offers a clean, sustainable alternative to fossil fuels. '
      'It is worth noting that installation costs have declined rapidly.',
      true,
    ),
    BenchmarkSample(
      '首先，我們需要了解其原理。其次，我們必須評估其影響。綜上所述，未來的可能性無窮。',
      true,
    ),
    BenchmarkSample(
      'In summary, quantum computing promises unprecedented processing capabilities across cryptography.',
      true,
    ),
    // 人類自然寫作樣本
    BenchmarkSample(
      'I woke up late this morning and quickly grabbed a cup of lukewarm coffee. '
      'The rain was pouring hard against my bedroom window as I looked for my keys.',
      false,
    ),
    BenchmarkSample(
      '今天早上我起床晚了，隨手拿了一杯溫咖啡就準備出門。雨打在窗戶上啪嗒作響，我找鑰匙找了好久。',
      false,
    ),
    BenchmarkSample(
      'My grandmother used to make the best apple pie with a secret touch of cinnamon. '
      'We spent whole afternoons sitting on her porch talking about old family photos.',
      false,
    ),
    BenchmarkSample(
      '小時候阿嬤總是煮最香濃的牛肉麵，湯頭熬了一整天。我們坐在小木椅上聊著小時候的故事。',
      false,
    ),
    BenchmarkSample(
      'Honestly, I never expected the movie to end like that. The plot twist caught me completely off guard!',
      false,
    ),
  ];

  /// 對指定引擎執行基準測量並產出校準報告
  Future<BenchmarkReport> benchmarkEngine(
    DetectionEngine engine, {
    List<BenchmarkSample> dataset = kDefaultBenchmarkDataset,
    AppLocalizations? l10n,
  }) async {
    final loc = l10n ?? lookupAppLocalizations(const Locale('en'));
    if (!await engine.isAvailable()) {
      return BenchmarkReport(
        engineId: engine.id,
        accuracy: 0.0,
        avgLatencyMs: 0.0,
        recommendedWeight: 0.0,
      );
    }

    var correctCount = 0;
    var totalLatencyMs = 0.0;

    for (final sample in dataset) {
      final text = PreprocessedText.from(sample.text);
      final stopwatch = Stopwatch()..start();
      final score = await engine.analyze(text, loc);
      stopwatch.stop();

      totalLatencyMs += stopwatch.elapsedMicroseconds / 1000.0;

      final predictedAi = score.aiProbability >= 0.5;
      if (predictedAi == sample.isAi) {
        correctCount++;
      }
    }

    final accuracy = correctCount / dataset.length;
    final avgLatencyMs = totalLatencyMs / dataset.length;
    final baseWeight = engine.defaultWeight;
    final recommendedWeight = (baseWeight * accuracy).clamp(0.05, 0.50);

    return BenchmarkReport(
      engineId: engine.id,
      accuracy: accuracy,
      avgLatencyMs: avgLatencyMs,
      recommendedWeight: recommendedWeight,
    );
  }
}
