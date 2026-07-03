import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_manager.dart';
import '../perplexity_scorer.dart';

/// 子模型 B：統計特徵分析器。
/// 若 DistilGPT2 困惑度模型（statistical role）已安裝，納入真 Perplexity（ONNX 端上）；
/// 否則以 Burstiness / Entropy / TTR 的啟發式組合運作。此引擎恆可用（有回退）。
class StatisticalEngine implements DetectionEngine {
  final ModelManager? modelManager;

  PerplexityScorer? _scorer;
  String? _loadedPath;

  StatisticalEngine({this.modelManager});

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
      // 經 distilgpt2 校準：AI 風格文本 ~50、人類口語 ~500+。
      if (ppl < 60) {
        score += 0.28;
        reasons.add('語言模型困惑度偏低（${ppl.toStringAsFixed(0)}），'
            '文本高度可預測，是 AI 生成的指標');
      } else if (ppl > 150) {
        score -= 0.25;
        reasons.add('語言模型困惑度偏高（${ppl.toStringAsFixed(0)}），符合人類寫作的不可預測性');
      } else {
        reasons.add('語言模型困惑度中等（${ppl.toStringAsFixed(0)}）');
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
    final mm = modelManager;
    if (mm == null) return null;
    final active = mm.activeVariant('statistical');
    if (active == null) return null;
    final modelPath = await mm.activeModelPath('statistical');
    final tokPath = await mm.activeTokenizerPath('statistical');
    if (modelPath == null || tokPath == null) return null;
    try {
      if (_scorer == null || _loadedPath != modelPath) {
        _scorer?.dispose();
        _scorer = await PerplexityScorer.load(
          modelPath: modelPath,
          tokenizerJsonPath: tokPath,
        );
        _loadedPath = modelPath;
      }
      return await _scorer!.perplexity(text);
    } catch (_) {
      return null; // 載入/推論失敗 → 回退啟發式
    }
  }
}
