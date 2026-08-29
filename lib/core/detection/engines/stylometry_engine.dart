import 'dart:math' as math;

import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detectrl_zh_char_scorer.dart';
import '../detection_engine.dart';
import '../pan25_tfidf_scorer.dart';

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
    // 以下四條由實測樣式挑選：在一份 Gemini 回覆上分別命中 1–2 次，而在三份
    // 人類撰寫的專案文件（implementation_plan.md、README.md、DEVLOG.md）上
    // 全部為 0。刻意不收「冒號引導接條列」——那條在 DEVLOG 命中 247 次，
    // 是技術寫作的常態而非助理特徵。
    RegExp(r'建議(?:您|你)|(?:您|你)可以(?:先|從|考慮|切入)|供(?:您|你)參考'),
    RegExp(
      r'(?:如果|若)(?:您|你).{0,30}(?:可以|我們可以|歡迎).{0,20}'
      r'(?:討論|說明|調整|深入)',
    ),
    RegExp(r'希望(?:這些|以上|本文).{0,30}(?:能|有(?:所)?)(?:幫助|助於|啟發)'),
    RegExp(
      r"(?:hope|feel free to).{0,60}(?:helps?|let me know|reach out)",
      caseSensitive: false,
    ),
  ];

  /// 版面慣例層的助理特徵：證據力明顯弱於語句招呼，單獨出現不足以支撐高信心。
  ///
  /// 「**術語：** 說明」這種粗體定義式條列在受測的 AI 回覆中出現 12 次、在三份
  /// 人類文件中皆為 0，但控制組只有三份文件，不足以當作已驗證的判準。因此它
  /// 另計一組、給較低的分數，也不參與「命中兩個獨立框架」的高信心條件。
  static final assistantLayoutPatterns = <RegExp>[
    RegExp(r'\*\*[^*\n]{2,40}[：:]\*\*'),
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
    double? lexicalProbability;
    var lexicalSupportsAiOnly = false;
    var lexicalModel = '';
    if (text.language.code == 'en' && text.allTokens.length >= 100) {
      try {
        final lexicalScore = await Pan25TfidfScorer.load().then(
          (scorer) => scorer.score(text.analysisText),
        );
        lexicalProbability = lexicalScore;
        lexicalModel = 'pan25';
        features['pan25_tfidf_probability'] = lexicalScore;
        features['bidirectional_probability'] = 1;
      } catch (_) {
        lexicalProbability = null;
      }
    } else if (text.language.code == 'zh') {
      try {
        final lexicalScore = await DetectRlZhCharScorer.load().then(
          (scorer) => scorer.score(text.analysisText),
        );
        if (lexicalScore != null) {
          lexicalProbability = lexicalScore.probability;
          lexicalSupportsAiOnly = lexicalScore.supportsAi;
          lexicalModel = 'detectrl_zh';
          features['detectrl_zh_probability'] = lexicalScore.probability;
          features['detectrl_zh_decision'] = lexicalScore.decision;
          features['detectrl_zh_ai_cut'] = lexicalScore.aiDecisionCut;
          features['detectrl_zh_supports_ai'] = lexicalScore.supportsAi ? 1 : 0;
          features['bidirectional_probability'] = 1;
        }
      } catch (_) {
        lexicalProbability = null;
      }
    }

    // 特徵 0：聊天助理回覆框架殘留。單一片語可能只是正文引用，僅給 75%；
    // 命中兩個獨立對話框架時才提高至近乎完整的規則分數。
    //
    // 比對 [PreprocessedText.raw] 而非 analysisText：這是直接痕跡，不是統計量。
    // analysisText 會刻意剝掉標題、條列與以冒號結尾的引導句，好讓統計特徵不被
    // 版面結構污染——但助理回覆的招呼語正好就長在那些位置。實測一份助理回覆
    // 文件：「以下為您整理…提供靈感：」整行被剝除，原文命中 1 次、analysisText
    // 命中 0 次，全 App 特異性最高的訊號就此消失在引擎看到它之前。
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

    // 版面慣例只在已經有語句招呼時才加分。單看版面密度無法分辨——實測人類
    // 撰寫的技術文件在標題比例（18.6% 對 8.3%）、粗體數（142 對 27）與 emoji
    // 數（41 對 5）上都高於受測的 AI 回覆，密度特徵只會製造誤報。
    final layoutHits = assistantLayoutPatterns
        .where((pattern) => pattern.hasMatch(text.raw))
        .length;
    features['assistant_layout_conventions'] = layoutHits.toDouble();
    if (layoutHits > 0 && assistantArtifactHits > 0) {
      score += 0.10;
    }

    // 特徵 1：通用過渡詞密度
    final lower = text.analysisText.toLowerCase();
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
    final lexicalDirectional =
        lexicalProbability != null &&
        (lexicalModel == 'detectrl_zh'
            ? lexicalSupportsAiOnly
            : (lexicalProbability - 0.5).abs() >= 0.08);
    if (lexicalProbability != null) {
      final percent = (lexicalProbability * 100).round();
      if (lexicalModel == 'detectrl_zh') {
        reasons.add(
          lexicalSupportsAiOnly
              ? l10n.engineReasonDetectRlZhAi(percent)
              : l10n.engineReasonDetectRlZhNoAiSignal(percent),
        );
      } else {
        reasons.add(
          lexicalProbability >= 0.58
              ? l10n.engineReasonPan25LexicalAi(percent)
              : lexicalProbability <= 0.42
              ? l10n.engineReasonPan25LexicalHuman(percent)
              : l10n.engineReasonPan25LexicalNeutral(percent),
        );
      }
    } else if (!foundMarkers) {
      reasons.add(l10n.engineReasonNoStyleMarkers);
    }

    final probability = lexicalProbability == null
        ? score.clamp(0.0, 1.0)
        : assistantArtifactHits >= 2
        ? 0.99
        : math.max(lexicalProbability, 0.5 + score.clamp(0.0, 1.0) * 0.35);

    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: probability,
      weight: defaultWeight,
      features: features,
      reasons: reasons,
      hasEvidence: foundMarkers || lexicalDirectional,
      evidenceFamily: lexicalProbability != null
          ? EvidenceFamily.lexicalFingerprint
          : EvidenceFamily.stylometric,
      applicability: assistantArtifactHits >= 2 || lexicalModel == 'detectrl_zh'
          ? EngineApplicability.validated
          : EngineApplicability.plausible,
      // 規則式風格只作弱佐證；兩個完整聊天助理框架屬高特異性直接痕跡。
      calibrationReliability: assistantArtifactHits >= 2
          ? 0.95
          : lexicalModel == 'detectrl_zh'
          ? 0.82
          : lexicalProbability != null
          ? 0.76
          : 0.42,
    );
  }
}
