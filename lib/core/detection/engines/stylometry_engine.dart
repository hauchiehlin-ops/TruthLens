import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';

/// 子模型 C：風格特徵分析器（Stylometry）。
/// 以特徵工程偵測 AI 寫作模式；正式版將疊加 XGBoost 分類器，
/// 目前為規則式特徵庫（可解釋性最高，特徵直接對應報告解釋）。
class StylometryEngine implements DetectionEngine {
  @override
  String get id => 'stylometry';
  @override
  String name(AppLocalizations l10n) => l10n.analysisEngineStylometry;
  @override
  double get defaultWeight => 0.20;

  @override
  Future<bool> isAvailable() async => true;

  /// 通用過渡詞特徵庫（中英，可透過更新包擴充）；句級分析亦引用
  static const genericTransitions = [
    '此外', '值得注意的是', '綜上所述', '總而言之', '首先', '其次', '最後',
    '換句話說', '不僅如此', '需要指出的是',
    'furthermore', 'moreover', 'in conclusion', 'additionally',
    'it is important to note', 'in summary', 'overall', 'consequently',
    "it's worth noting", 'in today\'s world', 'delve into', 'tapestry',
  ];

  @override
  Future<EngineScore> analyze(PreprocessedText text, AppLocalizations l10n) async {
    final reasons = <String>[];
    final features = <String, double>{};
    var score = 0.5;

    // 特徵 1：通用過渡詞密度
    final lower = text.raw.toLowerCase();
    var transitionHits = 0;
    final hitWords = <String>{};
    for (final t in genericTransitions) {
      final matches = t.toLowerCase().allMatches(lower).length;
      if (matches > 0) {
        transitionHits += matches;
        hitWords.add(t);
      }
    }
    final density = text.sentences.isEmpty
        ? 0.0
        : transitionHits / text.sentences.length;
    features['transition_density'] = density;
    if (density > 0.25 && transitionHits >= 3) {
      score += 0.22;
      reasons.add(l10n.engineReasonTransitionWords(
          hitWords.take(4).join('、'), density.toStringAsFixed(2)));
    }

    // 特徵 2：句式開頭重複（連續句子以相同詞開頭）
    var repeatedOpeners = 0;
    for (var i = 1; i < text.sentenceTokens.length; i++) {
      final prev = text.sentenceTokens[i - 1];
      final cur = text.sentenceTokens[i];
      if (prev.isNotEmpty && cur.isNotEmpty && prev.first == cur.first) {
        repeatedOpeners++;
      }
    }
    features['repeated_openers'] = repeatedOpeners.toDouble();
    if (text.sentences.length >= 5 &&
        repeatedOpeners / text.sentences.length > 0.3) {
      score += 0.15;
      reasons.add(l10n.engineReasonRepeatedOpeners(repeatedOpeners));
    }

    // 特徵 3：清單化/條列傾向（過度結構化）
    final bulletLines = RegExp(r'^\s*([-*•]|\d+[.、)])', multiLine: true)
        .allMatches(text.raw)
        .length;
    features['bullet_lines'] = bulletLines.toDouble();

    if (reasons.isEmpty) {
      reasons.add(l10n.engineReasonNoStyleMarkers);
      score -= 0.05;
    }

    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: score.clamp(0.0, 1.0),
      weight: defaultWeight,
      features: features,
      reasons: reasons,
    );
  }
}
