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
    '此外',
    '值得注意的是',
    '綜上所述',
    '總而言之',
    '首先',
    '其次',
    '最後',
    '換句話說',
    '不僅如此',
    '需要指出的是',
    'furthermore',
    'moreover',
    'in conclusion',
    'additionally',
    'it is important to note',
    'in summary',
    'overall',
    'consequently',
    "it's worth noting",
    'in today\'s world',
    'delve into',
    'tapestry',
  ];

  /// 高特異性的聊天助理回覆殘留。這些不是「文風很像 AI」的弱線索，而是成品
  /// 夾帶了回應使用者、主動提供後續修改等對話框架。規則刻意要求完整片語，避免
  /// 將一般文章中的單一禮貌詞或第一人稱誤判為助理輸出。
  static final assistantResponsePatterns = <RegExp>[
    RegExp(r'以下(?:為|是)(?:您|你).{0,20}(?:撰寫|整理|提供|生成)'),
    RegExp(r'如果您(?:原本|的原意).{0,30}(?:請|告訴|調整)'),
    RegExp(r'若您(?:希望|需要).{0,30}(?:我可以|我會|告訴我)'),
    RegExp(
      r"(?:here(?:'s| is)|below is) (?:the|an?) .{0,40}(?:you requested|you asked for)",
      caseSensitive: false,
    ),
    RegExp(
      r"(?:if you(?:'d| would) like|let me know if you).{0,50}(?:i can|revise|adjust|expand)",
      caseSensitive: false,
    ),
    RegExp(r'as an ai (?:language )?model', caseSensitive: false),
  ];

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n,
  ) async {
    final reasons = <String>[];
    final features = <String, double>{};
    // 規則式引擎的分數代表實際命中特徵；沒有命中時應為 0，不能把
    // 先驗基線誤當成 AI 證據。
    var score = 0.0;

    // 特徵 0：聊天助理回覆框架殘留。單一片語可能只是正文引用，僅給 75%；
    // 命中兩個獨立對話框架時才提高至近乎完整的規則分數。
    final assistantArtifactHits = assistantResponsePatterns
        .where((pattern) => pattern.hasMatch(text.raw))
        .length;
    features['assistant_response_artifacts'] = assistantArtifactHits.toDouble();
    if (assistantArtifactHits > 0) {
      score += assistantArtifactHits >= 2 ? 0.95 : 0.75;
      reasons.add(
        l10n.engineReasonAssistantResponseArtifact(assistantArtifactHits),
      );
    }

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
      score += 0.35;
      reasons.add(
        l10n.engineReasonTransitionWords(
          hitWords.take(4).join('、'),
          density.toStringAsFixed(2),
        ),
      );
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
      score += 0.25;
      reasons.add(l10n.engineReasonRepeatedOpeners(repeatedOpeners));
    }

    // 特徵 3：清單化/條列傾向（過度結構化）
    final bulletLines = RegExp(
      r'^\s*([-*•]|\d+[.、)])',
      multiLine: true,
    ).allMatches(text.raw).length;
    features['bullet_lines'] = bulletLines.toDouble();
    if (text.sentences.length >= 5 &&
        bulletLines / text.sentences.length > 0.4) {
      score += 0.15;
    }

    // 本引擎只在命中 AI 風格特徵時加分，從不因「文筆像人」而扣分。
    // 因此沒命中任何特徵時它是沉默，不是在投「人類」一票。
    final foundMarkers = reasons.isNotEmpty;
    if (!foundMarkers) {
      reasons.add(l10n.engineReasonNoStyleMarkers);
    }

    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: score.clamp(0.0, 1.0),
      weight: defaultWeight,
      features: features,
      reasons: reasons,
      hasEvidence: foundMarkers,
    );
  }
}
