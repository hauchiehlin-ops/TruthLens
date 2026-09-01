import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/detectrl_zh_char_scorer.dart';

/// 說明式／條列式的機器中文——訓練集 GPT-4o、GLM-4-flash、Qwen-turbo 的典型語域。
const _machineTraditional =
    '人工智慧的發展對現代社會產生了深遠的影響。首先，它顯著提升了生產效率，'
    '使企業能夠以更低的成本完成更多的工作。其次，人工智慧在醫療、教育與交通等領域'
    '展現出巨大的應用潛力，為人們的生活帶來了便利。然而，我們也必須正視其帶來的挑戰，'
    '例如就業結構的變化以及資料隱私的風險。綜上所述，我們應當在推動技術進步的同時，'
    '建立完善的監管機制，以確保人工智慧能夠真正造福人類社會。';

/// 與 [_machineTraditional] 逐字對應的簡體版本：只換字形，不換用詞，
/// 這樣分數差異才只能來自字形本身。
const _machineSimplified =
    '人工智慧的发展对现代社会产生了深远的影响。首先，它显著提升了生产效率，'
    '使企业能够以更低的成本完成更多的工作。其次，人工智慧在医疗、教育与交通等领域'
    '展现出巨大的应用潜力，为人们的生活带来了便利。然而，我们也必须正视其带来的挑战，'
    '例如就业结构的变化以及资料隐私的风险。综上所述，我们应当在推动技术进步的同时，'
    '建立完善的监管机制，以确保人工智慧能够真正造福人类社会。';

const _humanTraditional =
    '那天下午雨下得很大，我沒帶傘，就在便利商店門口站了快一個鐘頭。'
    '老闆娘後來拿了張塑膠椅出來，說坐吧，站著也是站著。我說謝謝，然後就真的坐下了，'
    '看著外面的車一輛一輛開過去，水花濺得老高。';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(DetectRlZhCharScorer.resetForTesting);

  test('短中文片段不產生不可靠的作者方向', () async {
    final scorer = await DetectRlZhCharScorer.load();
    expect(scorer.score('這是一句太短、無法穩定判讀的文字。'), isNull);
  });

  test('機器語域的中文可跨過保守 AI 證據門檻', () async {
    final scorer = await DetectRlZhCharScorer.load();

    final result = scorer.score(_machineTraditional);
    expect(result, isNotNull);
    expect(result!.supportsAi, isTrue);
    expect(result.decision, greaterThanOrEqualTo(result.aiDecisionCut));
  });

  test('人類敘事不跨門檻，且低分不反向投人類票', () async {
    final scorer = await DetectRlZhCharScorer.load();

    final result = scorer.score(_humanTraditional);
    expect(result, isNotNull);
    expect(result!.supportsAi, isFalse);
    expect(result.decision, lessThan(result.aiDecisionCut));
  });

  test('繁簡同一文本走同一證據流程並得到一致結論', () async {
    // 匯出腳本以 OpenCC s2t/t2s 雙向增強訓練，因此字形不該改變判定。
    // 這條守的是那個保證：只換字形時結論與分數都必須貼齊。
    final scorer = await DetectRlZhCharScorer.load();

    final traditional = scorer.score(_machineTraditional);
    final simplified = scorer.score(_machineSimplified);

    expect(traditional, isNotNull);
    expect(simplified, isNotNull);
    expect(simplified!.supportsAi, traditional!.supportsAi);
    expect(
      (simplified.decision - traditional.decision).abs(),
      lessThan(0.05),
      reason: '繁簡只差字形，判定邊界不該因此漂移',
    );
  });
}
