/// 檢測結果資料模型 — 對應 docs/implementation_plan.md 模組 1 的輸出結構。
library;

import '../../l10n/generated/app_localizations.dart';
import '../detection/evasion_scanner.dart';
import '../services/document_provenance.dart';
import '../services/writing_session.dart';
import '../utils/text_stats.dart';
import 'calibration_evidence.dart';
import 'input_quality.dart';

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

/// 為什麼本次判讀必須降低信心。系統仍會輸出最可能方向，但不能把方向
/// 包裝成高確定性結論。
enum AbstentionReason {
  /// 證據充足，可正常呈現判讀
  none,

  /// 可分析的句子太少，句級與統計訊號都不具代表性
  tooFewSentences,

  /// 內容字數太少
  tooFewWords,

  /// 參與投票的引擎不足，無法多角度驗證
  tooFewEngines,

  /// 引擎之間分歧過大，加權平均已不具意義
  enginesConflict,

  /// 引擎都有執行，但沒有任何一個找到可用證據；低分只是沉默後的 fallback，
  /// 不是人類撰寫的證據
  noEvidenceFound,

  /// 只有單一引擎握有證據，且整體分數落在人類側；此時低分更像是
  /// 覆蓋不足造成的沉默，而不是人類撰寫的證據
  singleWeakEvidenceSource,
}

/// 引擎所屬的獨立證據家族。
///
/// 同一家族的兩個模型通常共享訓練資料、機率特徵或架構假設，不能被當成兩份
/// 獨立證據。整合層會先在家族內合併，再計算跨家族共識。
enum EvidenceFamily {
  supervisedClassifier,
  lexicalFingerprint,
  distributional,
  stylometric,
  rewriteTrace,
  unknown,
}

/// 模型對本次語言／文體的適用程度。它回答「這顆模型能不能在這裡發言」，
/// 與模型輸出的 AI 分數是兩個不同問題。
enum EngineApplicability { validated, plausible, unknown, unsupported }

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

  /// 本次分析**實際載入並使用**的模組名稱。
  ///
  /// 同一個角色底下可能有多個模組（例如統計角色會同時跑困惑度模型與詞彙指紋），
  /// 而路由又會依文件語言換掉 Transformer 的變體。使用者只看角色名稱無從得知
  /// 這次到底是誰在發言，遙測面板因此需要逐次列出。
  ///
  /// 只列真的用到的：載入失敗或未安裝的模組不得出現在這裡。
  final List<String> modules;

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

  /// 本引擎屬於哪一個統計上相關的證據家族。
  final EvidenceFamily evidenceFamily;

  /// 本引擎對本次輸入語言／領域的適用程度。
  final EngineApplicability applicability;

  /// 由獨立驗證資料得到的可靠度；不能由本次分數高低反推。
  /// 1 代表已有對應語言／用途驗證，0 代表不得參與作者判讀。
  final double calibrationReliability;

  const EngineScore({
    required this.engineId,
    required this.engineName,
    required this.aiProbability,
    required this.weight,
    this.available = true,
    this.features = const {},
    this.reasons = const [],
    this.sentenceScores,
    this.modules = const [],
    this.hasEvidence = true,
    this.evidenceFamily = EvidenceFamily.unknown,
    this.applicability = EngineApplicability.validated,
    this.calibrationReliability = 1.0,
  });

  EngineScore copyWith({
    double? weight,
    EngineApplicability? applicability,
    double? calibrationReliability,
  }) => EngineScore(
    engineId: engineId,
    engineName: engineName,
    aiProbability: aiProbability,
    weight: weight ?? this.weight,
    available: available,
    features: features,
    reasons: reasons,
    sentenceScores: sentenceScores,
    modules: modules,
    hasEvidence: hasEvidence,
    evidenceFamily: evidenceFamily,
    applicability: applicability ?? this.applicability,
    calibrationReliability:
        calibrationReliability ?? this.calibrationReliability,
  );

  /// 實際參與投票：可用、且確實握有證據
  bool get votes =>
      available &&
      hasEvidence &&
      applicability != EngineApplicability.unsupported &&
      calibrationReliability > 0;

  EvidenceFamily get resolvedEvidenceFamily =>
      evidenceFamily == EvidenceFamily.unknown
      ? _familyOf(engineId)
      : evidenceFamily;

  /// 依本次文件的證據品質調整有效權重。
  ///
  /// 權重只由適用性、獨立校準可靠度與可分析覆蓋率決定。不得再用
  /// [aiProbability] 高低提高自己的權重，否則會形成「分數愈高，話語權愈大」
  /// 的自我放大迴圈。
  double get evidenceWeightMultiplier {
    if (!available || !hasEvidence) return 1.0;
    final applicabilityFactor = switch (applicability) {
      EngineApplicability.validated => 1.0,
      EngineApplicability.plausible => 0.72,
      EngineApplicability.unknown => 0.45,
      EngineApplicability.unsupported => 0.0,
    };
    final chunks = features['analysis_chunk_count'];
    final coverageFactor = chunks == null
        ? 1.0
        : chunks >= 4
        ? 1.0
        : chunks >= 2
        ? 0.82
        : chunks > 0
        ? 0.65
        : 0.75;
    return (applicabilityFactor *
            calibrationReliability.clamp(0.0, 1.0) *
            coverageFactor)
        .clamp(0.0, 1.0);
  }

  static String _roleOf(String engineId) {
    const roles = ['transformer', 'statistical', 'stylometry', 'adversarial'];
    for (final role in roles) {
      if (engineId == role || engineId.startsWith('${role}_')) return role;
    }
    return engineId;
  }

  static EvidenceFamily _familyOf(String engineId) {
    final role = _roleOf(engineId);
    return switch (role) {
      'transformer' => EvidenceFamily.supervisedClassifier,
      'statistical' => EvidenceFamily.distributional,
      'stylometry' => EvidenceFamily.stylometric,
      'adversarial' => EvidenceFamily.rewriteTrace,
      _ => EvidenceFamily.unknown,
    };
  }
}

/// 句子級分析結果
class SentenceScore {
  final int index;
  final String text;
  final double aiProbability;
  final List<String> patterns; // 命中的 AI 寫作模式

  /// [aiProbability] 是否真的由神經模型的逐句輸出支撐。
  ///
  /// 沒有任何神經引擎投票時，逐句數值只是文件級分數再依句長偏差與轉折詞
  /// 微調出來的估計。把它當成「模型看過這句、判定 1% 像 AI」會完全誤導——
  /// 那是棄權，不是人類票。介面必須據此顯示棄權而非百分比。
  final bool modelBacked;

  const SentenceScore({
    required this.index,
    required this.text,
    required this.aiProbability,
    this.patterns = const [],
    this.modelBacked = true,
  });
}

/// 完整檢測結果
class DetectionResult {
  final String id;
  final DateTime analyzedAt;
  final String inputText;
  final String sourceFileName;
  final double aiProbability; // 證據家族融合後的文字 AI 訊號指數
  final Verdict verdict;
  final List<EngineScore> engineScores;
  final List<SentenceScore> sentences;
  final List<String> dominantPatterns;
  final bool eslAdjusted; // 是否套用了 ESL 偏差修正
  final Duration elapsed;
  final int availableEngineCount; // 本次參與投票的引擎數
  final int totalEngineCount; // 註冊的引擎總數
  final InputQualityEvidence inputQuality;
  final CalibrationEvidence calibration;

  /// 寫作過程紀錄。只有使用者直接在應用程式內輸入時才有內容；
  /// 匯入的檔案為空——那份文字不是在這裡寫的。
  /// 同樣不併入 [aiProbability]：這是關於「怎麼產生的」，不是「像不像 AI」。
  final WritingSession writingSession;

  /// 規避痕跡掃描結果（零寬字元、同形字等）。刻意不併入 [aiProbability]：
  /// 這是確定性的「有沒有」，不是機率。它指向的也不是「像不像 AI」，
  /// 而是「有人刻意規避偵測」——性質不同，混進分數會兩者都說不清楚。
  final EvasionScan evasion;

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
    this.inputQuality = InputQualityEvidence.directText,
    this.calibration = CalibrationEvidence.unavailable,
    this.provenance = DocumentProvenance.none,
    this.evasion = EvasionScan.clean,
    this.writingSession = WritingSession.empty,
  });

  /// 計算可用引擎數（available=true 的引擎）
  int get _computeAvailableCount => engineScores
      .where(
        (e) =>
            e.available &&
            e.applicability != EngineApplicability.unsupported &&
            e.calibrationReliability > 0,
      )
      .length;

  /// 計算使用中的總權重（只計算 available 引擎的權重）
  double get _computeUsedWeight => engineScores
      .where(
        (e) =>
            e.available &&
            e.applicability != EngineApplicability.unsupported &&
            e.calibrationReliability > 0,
      )
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
    if (evidential.isEmpty) {
      return AbstentionReason.noEvidenceFound;
    }
    final evidenceFamilies = evidential
        .map((engine) => engine.resolvedEvidenceFamily)
        .toSet();
    if (evidenceFamilies.length >= 2) {
      // 以整數百分點比較：浮點相減會讓 0.80-0.20 變成 0.6000000000000001，
      // 使恰好落在門檻上的情形被誤判為超標。這裡也與畫面顯示的單位一致。
      if (engineSpreadPoints > (maxEngineSpread * 100).round()) {
        return AbstentionReason.enginesConflict;
      }
    }
    if (evidenceFamilies.length == 1 && !flaggedAsAi) {
      return AbstentionReason.singleWeakEvidenceSource;
    }
    return AbstentionReason.none;
  }

  /// 只有單一引擎握有證據。證據來源單一，信心該打折，但仍是有證據——
  /// 這種情況要給判定並附註來源單一，不能拿「不做判定」搪塞：
  /// 單一證人不等於沒有證人。
  bool get singleEvidenceSource =>
      votingEngines
          .where((e) => e.hasEvidence)
          .map((e) => e.resolvedEvidenceFamily)
          .toSet()
          .length ==
      1;

  /// 本次分析中真正找到東西的引擎數
  int get evidenceEngineCount => engineScores.where((e) => e.votes).length;

  /// 本次證據有量體、覆蓋或一致性限制。介面仍提供最可能方向，但必須降低
  /// 信心並顯示原因。
  bool get hasEvidenceLimitations => abstention != AbstentionReason.none;

  /// 舊名稱保留給既有資料流；新介面應使用 [hasEvidenceLimitations]。
  @Deprecated('Use hasEvidenceLimitations; a direction is always provided.')
  bool get shouldAbstain => hasEvidenceLimitations;

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
    var weight = score.weight * score.evidenceWeightMultiplier;
    if (eslAdjusted && statistical) weight *= 0.5;
    return weight;
  }

  /// 實際提供診斷訊號的引擎。最終判讀會再按證據家族去除相關訊號；這份清單
  /// 只供引擎明細與原始貢獻視覺化使用。
  List<EngineScore> get votingEngines {
    return engineScores
        .where(
          (s) =>
              s.votes &&
              s.applicability != EngineApplicability.unsupported &&
              s.calibrationReliability > 0,
        )
        .toList();
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
