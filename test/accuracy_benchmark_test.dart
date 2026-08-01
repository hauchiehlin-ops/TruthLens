import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/orchestrator.dart';
import 'package:truthlens/core/models/detection_result.dart';

void main() {
  group('AI Detection Accuracy Benchmark (>90% Accuracy Requirement)', () {
    late EnsembleOrchestrator orchestrator;

    setUp(() {
      orchestrator = EnsembleOrchestrator();
    });

    // 典型的 AI 生成文章 (GPT-4 / Claude / Gemma 生成風格，具備高過渡詞密度與均勻句長)
    final aiSamples = [
      '''
此外，人工智慧技術正在重塑現代社會的各個層面。值得注意的是，從醫療診斷到金融風險評估，
機器學習算法都展現出了前所未有的精準度。首先，數據驅動的模型能夠在毫秒內處理海量資訊。
其次，自動化流程顯著降低了人為失誤的風險。綜上所述，擁抱人工智慧轉型是企業保持競爭力的關鍵。
''',
      '''
In today's world, artificial intelligence plays a pivotal role in modern technology.
Furthermore, it is important to note that machine learning algorithms excel at recognizing complex patterns.
Additionally, automated tools enhance operational efficiency across various industries.
In conclusion, the integration of AI solutions offers unprecedented opportunities for future growth.
''',
      '''
需要指出的是，可持續發展已成為全球各界的共同目標。換句話說，減少碳排放與推動綠色能源轉型勢在必行。
首先，太陽能與風力發電技術的突破降低了清潔能源的成本。其次，各國政策的扶持為綠色產業提供了強大的動力。
總而言之，只有通過跨領域的合作，我們才能實現長期的生態平衡。
''',
    ];

    // 典型的人類自然寫作文章（句式起伏大、打字習慣靈活、缺乏 AI 式重複過渡詞）
    final humanSamples = [
      '''
昨晚跟朋友聊到這部電影，覺得結局真的轉得有點太硬。前面的鋪陳明明很細緻，
主角的心境變化也抓得很到位，結果最後五分鐘突然來個神展開，讓人一時反映不過來。
不過音樂倒是蠻加分的，配樂一響起氣氛立刻就拉滿了。
''',
      '''
I was looking at the old photo album from last summer's road trip.
We got lost near the mountains for three hours because the map app lost GPS signal completely!
Ended up finding this tiny bakery in the middle of nowhere that served the best apple pie I've ever had.
Honestly, best wrong turn ever.
''',
      '''
今天實驗室的儀器又在發脾氣，校正了三次數值還是偏高。
學長建議把感測器拆下來清一下試試看，結果發現裡面積了一層薄灰。
弄完重新跑一次數據終於正常了，下班時間又往後延了兩小時。
''',
    ];

    test('AI 生成文本判定正確率與信心度達標 (>90% 正確率與標記率)', () async {
      var correctCount = 0;
      for (final sample in aiSamples) {
        final result = await orchestrator.analyze(sample);
        // AI 樣本應獲得較高之 AI 機率且被判為 Likely AI 或 AI (或 Flagged)
        if (result.aiProbability >= 0.55 ||
            result.verdict == Verdict.ai ||
            result.verdict == Verdict.likelyAi ||
            result.verdict == Verdict.mixed) {
          correctCount++;
        }
      }
      final accuracy = correctCount / aiSamples.length;
      expect(accuracy, greaterThanOrEqualTo(0.90),
          reason: 'AI 檢測正確率應達到 90% 以上');
    });

    test('人類自然寫作判訂正確率與低偽陽性率達標 (>90% 正確率)', () async {
      var correctCount = 0;
      for (final sample in humanSamples) {
        final result = await orchestrator.analyze(sample);
        // 人類樣本 AI 機率應低於 0.5，且不應被判為 AI
        if (result.aiProbability < 0.50 &&
            (result.verdict == Verdict.human ||
                result.verdict == Verdict.likelyHuman ||
                result.verdict == Verdict.mixed)) {
          correctCount++;
        }
      }
      final accuracy = correctCount / humanSamples.length;
      expect(accuracy, greaterThanOrEqualTo(0.90),
          reason: '人類文章被誤判為 AI 的偽陽性率應小於 10%（即正確率 >= 90%）');
    });
  });
}
