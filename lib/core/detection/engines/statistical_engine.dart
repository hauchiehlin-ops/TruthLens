import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_manager.dart';
import '../native_inference_service.dart';

/// 子模型 B：統計特徵分析器。
/// 若 DistilGPT2 困惑度模型已安裝且原生端就緒，納入真 Perplexity；
/// 否則以 Burstiness / Entropy / TTR 的啟發式組合運作。此引擎恆可用（有回退）。
class StatisticalEngine implements DetectionEngine {
  final ModelManager? modelManager;
  final NativeInferenceService? native;

  StatisticalEngine({this.modelManager, this.native});

  @override
  String get id => 'statistical';
  @override
  String get name => '統計特徵分析';
  @override
  double get defaultWeight => 0.25;

  @override
  Future<bool> isAvailable() async => true; // 啟發式回退，恆可用

  @override
  Future<EngineScore> analyze(PreprocessedText text) async {
    final burstiness = text.burstiness;
    final ttr = text.typeTokenRatio;
    final entropy = text.entropy;

    final reasons = <String>[];
    final features = <String, double>{
      'burstiness': burstiness,
      'type_token_ratio': ttr,
      'entropy': entropy,
    };
    var score = 0.5;

    // 若真困惑度模型可用，優先納入（低困惑度 → 偏 AI）
    final ppl = await _tryPerplexity(text.raw);
    if (ppl != null) {
      features['perplexity'] = ppl;
      // 經驗映射：ppl < 20 高度可疑、> 80 偏人類（實際閾值待模型校準）
      if (ppl < 20) {
        score += 0.28;
        reasons.add('語言模型困惑度極低（${ppl.toStringAsFixed(1)}），'
            '文本高度可預測，是 AI 生成的強指標');
      } else if (ppl > 80) {
        score -= 0.25;
        reasons.add('語言模型困惑度偏高（${ppl.toStringAsFixed(1)}），符合人類寫作的不可預測性');
      } else {
        reasons.add('語言模型困惑度中等（${ppl.toStringAsFixed(1)}）');
      }
    }

    // Burstiness：人類句長起伏大；AI 節奏均勻
    if (text.sentences.length >= 4) {
      if (burstiness < 0.30) {
        score += 0.20;
        reasons.add('句子長度高度一致（burstiness ${burstiness.toStringAsFixed(2)}），'
            '節奏均勻是 AI 生成文本的典型統計特徵');
      } else if (burstiness > 0.55) {
        score -= 0.20;
        reasons.add('句長起伏明顯（burstiness ${burstiness.toStringAsFixed(2)}），'
            '符合人類自然寫作的節奏變化');
      }
    }

    // 詞彙多樣性：AI 文本 TTR 常偏低
    if (text.allTokens.length >= 50) {
      if (ttr < 0.40) {
        score += 0.10;
        reasons.add('詞彙多樣性偏低（TTR ${ttr.toStringAsFixed(2)}），用詞重複度高');
      } else if (ttr > 0.65) {
        score -= 0.10;
        reasons.add('詞彙多樣性高（TTR ${ttr.toStringAsFixed(2)}）');
      }
    }

    if (reasons.isEmpty) {
      reasons.add('統計指標未呈現顯著傾向，維持中性判定');
    }

    return EngineScore(
      engineId: id,
      engineName: name,
      aiProbability: score.clamp(0.0, 1.0),
      weight: defaultWeight,
      features: features,
      reasons: reasons,
    );
  }

  Future<double?> _tryPerplexity(String text) async {
    if (modelManager == null || native == null) return null;
    if (!modelManager!.canRunEngine('statistical')) return null;
    if (!await native!.isSupported) return null;
    return native!.perplexity('statistical', text);
  }
}
