/// 檢測結果資料模型 — 對應 docs/implementation_plan.md 模組 1 的輸出結構。
library;

import '../../l10n/generated/app_localizations.dart';
import '../services/document_provenance.dart';
import '../utils/text_stats.dart';

/// 五級分類（依整體 AI 機率與使用者可調的 AI 標記門檻閾值劃分）
enum Verdict {
  human, // 🟢 人類撰寫
  likelyHuman, // 🟡 可能人類
  mixed, // 🟠 混合內容
  likelyAi, // 🔴 可能 AI
  ai; // ⛔ AI 生成

  /// 五級分類的固定切點。刻意不做成可調參數：門檻一旦可調，同一份文件在
  /// 不同人手上會得到不同結論，跨使用者、跨時間的紀錄也不再可比。
  /// 固定值讓「可能 AI」這個詞永遠指同一件事。
  static const List<double> cutPoints = [0.20, 0.40, 0.60, 0.80];

  static Verdict fromProbability(double p) {
    if (p < cutPoints[0]) return Verdict.human;
    if (p < cutPoints[1]) return Verdict.likelyHuman;
    if (p < cutPoints[2]) return Verdict.mixed;
    if (p < cutPoints[3]) return Verdict.likelyAi;
    return Verdict.ai;
  }

  /// 判定結果的顯示文字，依 [l10n] 語系呈現。
  String label(AppLocalizations l10n) => switch (this) {
    Verdict.human => l10n.verdictHuman,
    Verdict.likelyHuman => l10n.verdictLikelyHuman,
    Verdict.mixed => l10n.verdictMixed,
    Verdict.likelyAi => l10n.verdictLikelyAi,
    Verdict.ai => l10n.verdictAi,
  };
}

/// 為什麼這次分析不給判定。棄權不是失敗，而是拒絕在證據不足時假裝有結論——
/// 多數誤指控都來自對太短或訊號太弱的輸入給出自信的數字。
enum AbstentionReason {
  /// 證據充足，正常出判定
  none,

  /// 可分析的句子太少，句級與統計訊號都不具代表性
  tooFewSentences,

  /// 內容字數太少
  tooFewWords,

  /// 參與投票的引擎不足，無法多角度驗證
  tooFewEngines,

  /// 引擎之間分歧過大，加權平均已不具意義
  enginesConflict,
}

/// 單一子模型（引擎）的評分結果
class EngineScore {
  final String engineId; // transformer / statistical / stylometry / adversarial
  final String engineName;
  final double aiProbability; // 0.0 (人類) - 1.0 (AI)
  final double weight; // 集成投票權重
  final bool available; // 模型是否已安裝可用
  final Map<String, double> features; // 可解釋特徵值（供報告呈現）
  final List<String> reasons; // 人類可讀的判定理由
  final List<double>? sentenceScores; // 句子級 AI 機率（有神經模型時提供）

  /// 這個分數是否代表引擎「真的找到了東西」。
  ///
  /// 四個引擎的中性點並不相同：統計引擎從 0.5 出發、可正可負，
  /// 風格／Transformer／對抗三個引擎則從 0 出發、只在命中特徵時加分。
  /// 對後三者而言 0 的意思是「我沒有話說」，不是「我確定這是人寫的」。
  /// 若不區分這兩件事，三個沉默的引擎會以 75% 的權重否決唯一有證據的引擎——
  /// 一篇通篇 AI 的短文因此得到 20% 並被判為「引擎分歧、不做判定」。
  ///
  /// 為 false 時該引擎不參與加權投票，也不列入分歧計算：沒有發言的證人
  /// 不能算成反對票，更不能算成證人之間的矛盾。
  final bool hasEvidence;

  const EngineScore({
    required this.engineId,
    required this.engineName,
    required this.aiProbability,
    required this.weight,
    this.available = true,
    this.features = const {},
    this.reasons = const [],
    this.sentenceScores,
    this.hasEvidence = true,
  });

  EngineScore copyWith({double? weight}) => EngineScore(
    engineId: engineId,
    engineName: engineName,
    aiProbability: aiProbability,
    weight: weight ?? this.weight,
    available: available,
    features: features,
    reasons: reasons,
    sentenceScores: sentenceScores,
    hasEvidence: hasEvidence,
  );

  /// 實際參與投票：可用、且確實握有證據
  bool get votes => available && hasEvidence;
}

/// 句子級分析結果
class SentenceScore {
  final int index;
  final String text;
  final double aiProbability;
  final List<String> patterns; // 命中的 AI 寫作模式

  const SentenceScore({
    required this.index,
    required this.text,
    required this.aiProbability,
    this.patterns = const [],
  });
}

/// 完整檢測結果
class DetectionResult {
  final String id;
  final DateTime analyzedAt;
  final String inputText;
  final String sourceFileName;
  final double aiProbability; // 加權投票後的整體 AI 機率
  final Verdict verdict;
  final List<EngineScore> engineScores;
  final List<SentenceScore> sentences;
  final List<String> dominantPatterns;
  final bool eslAdjusted; // 是否套用了 ESL 偏差修正
  final Duration elapsed;
  final int availableEngineCount; // 本次參與投票的引擎數
  final int totalEngineCount; // 註冊的引擎總數

  /// 來源檔案自身攜帶的編輯紀錄證據。刻意不併入 [aiProbability]：
  /// 這是「檔案怎麼產生的」的來源證據，與「文字像不像 AI」的統計推論
  /// 性質不同，合併會讓使用者誤以為分數已把編輯紀錄計入。
  final DocumentProvenance provenance;

  const DetectionResult({
    required this.id,
    required this.analyzedAt,
    required this.inputText,
    this.sourceFileName = '',
    required this.aiProbability,
    required this.verdict,
    required this.engineScores,
    required this.sentences,
    this.dominantPatterns = const [],
    this.eslAdjusted = false,
    this.elapsed = Duration.zero,
    this.availableEngineCount = 0,
    this.totalEngineCount = 0,
    this.provenance = DocumentProvenance.none,
  });

  /// 計算可用引擎數（available=true 的引擎）
  int get _computeAvailableCount =>
      engineScores.where((e) => e.available).length;

  /// 計算使用中的總權重（只計算 available 引擎的權重）
  double get _computeUsedWeight => engineScores
      .where((e) => e.available)
      .fold<double>(0, (sum, e) => sum + e.weight);

  /// 計算理想的總權重（所有引擎）
  double get _computeTotalWeight =>
      engineScores.fold<double>(0, (sum, e) => sum + e.weight);

  /// 檢查是否為低信心分析：
  /// 只有在引擎投票數極度不足時才認為信心度低
  /// - 可用引擎 < 2 個（無法多角度驗證）
  bool get isLowConfidence {
    final availableCount = _computeAvailableCount;

    // 只有在引擎數量不足時才判為低信心度
    // （權重不平衡屬於正常情況，不應降低信心度）
    if (availableCount < 2) return true;

    return false;
  }

  /// 棄權門檻：低於這些量體時，任何統計訊號都不具代表性
  static const int minAnalyzableSentences = 5;
  static const int minWords = 100;

  /// 可用引擎之間的分數全距超過此值即視為分歧過大（0-1 尺度）
  static const double maxEngineSpread = 0.60;

  /// 實際參與投票的引擎數。優先由 [engineScores] 推導，而不是信任呼叫端
  /// 另外傳入的計數欄位——兩者不一致時（例如未填計數的建構）會讓棄權判斷
  /// 誤以為沒有引擎參與。
  int get effectiveAvailableEngineCount =>
      engineScores.isEmpty ? availableEngineCount : _computeAvailableCount;

  /// 同上，註冊的引擎總數
  int get effectiveTotalEngineCount =>
      engineScores.isEmpty ? totalEngineCount : engineScores.length;

  /// 握有證據的引擎之間分數全距，換算為整數百分點（0 表示不足兩個引擎可比）。
  ///
  /// 刻意只看有證據的引擎。沉默的引擎輸出的是自己的中性點，把它和一個
  /// 78% 的正向訊號相減會得到 78 個百分點的「分歧」——但沒有任何引擎說過
  /// 反話，那不是矛盾，只是三個證人沒有發言。
  int get engineSpreadPoints {
    final active = votingEngines.where((e) => e.hasEvidence).toList();
    if (active.length < 2) return 0;
    final probabilities = active.map((e) => e.aiProbability);
    final high = probabilities.reduce((a, b) => a > b ? a : b);
    final low = probabilities.reduce((a, b) => a < b ? a : b);
    return ((high - low) * 100).round();
  }

  /// 本次分析應否棄權，以及棄權的原因。判斷順序由「最根本」到「最細緻」，
  /// 讓回報的理由是最該先解決的那一個。
  AbstentionReason get abstention {
    if (effectiveAvailableEngineCount < 2) {
      return AbstentionReason.tooFewEngines;
    }
    if (wordCount < minWords) return AbstentionReason.tooFewWords;
    if (analyzableSentenceCount < minAnalyzableSentences) {
      return AbstentionReason.tooFewSentences;
    }

    final evidential = votingEngines.where((e) => e.hasEvidence).toList();
    if (evidential.length >= 2) {
      // 以整數百分點比較：浮點相減會讓 0.80-0.20 變成 0.6000000000000001，
      // 使恰好落在門檻上的情形被誤判為超標。這裡也與畫面顯示的單位一致。
      if (engineSpreadPoints > (maxEngineSpread * 100).round()) {
        return AbstentionReason.enginesConflict;
      }
    }
    return AbstentionReason.none;
  }

  /// 只有單一引擎握有證據。證據來源單一，信心該打折，但仍是有證據——
  /// 這種情況要給判定並附註來源單一，不能拿「不做判定」搪塞：
  /// 單一證人不等於沒有證人。
  bool get singleEvidenceSource =>
      votingEngines.where((e) => e.hasEvidence).length == 1;

  /// 本次分析中真正找到東西的引擎數
  int get evidenceEngineCount =>
      engineScores.where((e) => e.available && e.hasEvidence).length;

  /// 證據不足以支撐任何判定時為 true。此時介面必須以棄權取代判定標題，
  /// 但仍保留底下的數字供人工參考——隱藏數字只會讓使用者更困惑。
  bool get shouldAbstain => abstention != AbstentionReason.none;

  /// 粗略字數：CJK 逐字計，其他語言以空白分詞
  int get wordCount {
    final trimmed = inputText.trim();
    if (trimmed.isEmpty) return 0;
    final cjk = RegExp(r'[㐀-䶿一-鿿぀-ヿ가-힯]').allMatches(trimmed).length;
    final latin = RegExp(r'[A-Za-zÀ-ɏЀ-ӿ]+').allMatches(trimmed).length;
    return cjk + latin;
  }

  /// 正式標記為 AI 的固定門檻，等於「混合內容 → 可能 AI」的分界。
  /// 與五級切點取同一個值，判定文字與標記狀態才不會互相矛盾。
  static const double aiFlagThreshold = 0.60;

  /// 是否越過標記門檻。這是固定值，不隨使用者設定變動。
  bool get flaggedAsAi => aiProbability >= aiFlagThreshold;

  double effectiveWeightFor(EngineScore score) {
    final statistical =
        score.engineId == 'statistical' ||
        score.engineId.startsWith('statistical_');
    return eslAdjusted && statistical ? score.weight * 0.5 : score.weight;
  }

  /// 實際參與投票的引擎，與 EnsembleOrchestrator._weightedVote 的取法一致：
  /// 可用且握有證據者投票；全體都沉默時退回全體可用引擎。
  /// 兩邊若不同步，報告的「各引擎貢獻」加總就會對不上整體百分比。
  List<EngineScore> get votingEngines {
    final available = engineScores.where((s) => s.available).toList();
    final evidential = available.where((s) => s.hasEvidence).toList();
    return evidential.isNotEmpty ? evidential : available;
  }

  double get _activeEffectiveWeight => votingEngines.fold<double>(
    0,
    (sum, score) => sum + effectiveWeightFor(score),
  );

  double contributionFor(EngineScore score) {
    final total = _activeEffectiveWeight;
    if (!votingEngines.contains(score) || total <= 0) return 0;
    return score.aiProbability * effectiveWeightFor(score) / total;
  }

  /// 將各引擎的完整精度貢獻換算為整數百分點，同時保證加總恰好等於
  /// 畫面顯示的整體 AI 百分比，避免逐列四捨五入造成 20% 對 23% 的矛盾。
  Map<String, int> get roundedEngineContributionPoints {
    final active = votingEngines;
    if (active.isEmpty || _activeEffectiveWeight <= 0) return const {};

    final exact = <String, double>{
      for (final score in active) score.engineId: contributionFor(score) * 100,
    };
    final points = <String, int>{
      for (final entry in exact.entries) entry.key: entry.value.floor(),
    };
    var remaining =
        (aiProbability * 100).round() -
        points.values.fold<int>(0, (sum, value) => sum + value);
    final order = exact.keys.toList()
      ..sort((a, b) {
        final aFraction = exact[a]! - exact[a]!.floor();
        final bFraction = exact[b]! - exact[b]!.floor();
        return bFraction.compareTo(aFraction);
      });

    for (var i = 0; remaining > 0 && order.isNotEmpty; i++, remaining--) {
      final id = order[i % order.length];
      points[id] = points[id]! + 1;
    }
    for (var i = 0; remaining < 0 && order.isNotEmpty; i++) {
      final id = order.reversed.elementAt(i % order.length);
      if (points[id]! <= 0) {
        if (points.values.every((value) => value <= 0)) break;
        continue;
      }
      points[id] = points[id]! - 1;
      remaining++;
    }
    return points;
  }

  /// 生成低信心分析的警告消息（用戶友好）
  String lowConfidenceWarning() {
    final reasons = <String>[];

    final availableCount = _computeAvailableCount;
    final usedWeight = _computeUsedWeight;
    final totalWeight = _computeTotalWeight;
    final confidenceRatio = totalWeight > 0 ? (usedWeight / totalWeight) : 0.0;

    if (availableCount < 2) {
      reasons.add('只有 $availableCount 個模型參與分析（建議至少 2 個）');
    }

    if (totalWeight > 0 && confidenceRatio < 0.60) {
      reasons.add(
        '引擎權重覆蓋不足：${(confidenceRatio * 100).toStringAsFixed(0)}% '
        '（建議 ≥60%）',
      );
    }

    if (reasons.isEmpty) {
      return '';
    }

    return '⚠️ 此分析信心度較低，原因：${reasons.join('；')}。'
        '建議查看「設定」中的模型狀態，下載或修復缺失的模型。';
  }

  int get aiSentenceCount => sentences
      .where(
        (s) =>
            PreprocessedText.isAnalyzableSentence(s.text) &&
            s.aiProbability >= 0.6,
      )
      .length;
  int get analyzableSentenceCount => sentences
      .where((s) => PreprocessedText.isAnalyzableSentence(s.text))
      .length;
  int get humanSentenceCount => sentences
      .where(
        (s) =>
            PreprocessedText.isAnalyzableSentence(s.text) &&
            s.aiProbability < 0.6,
      )
      .length;
  int get strictAiSentenceCount => sentences
      .where(
        (s) =>
            PreprocessedText.isAnalyzableSentence(s.text) &&
            s.aiProbability >= 0.6,
      )
      .length;
  int get strictHumanSentenceCount => sentences
      .where(
        (s) =>
            PreprocessedText.isAnalyzableSentence(s.text) &&
            s.aiProbability < 0.4,
      )
      .length;
}
