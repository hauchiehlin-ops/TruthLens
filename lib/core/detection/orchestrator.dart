import '../models/detection_result.dart';
import '../utils/text_stats.dart';
import 'detection_engine.dart';
import 'engines/adversarial_engine.dart';
import 'engines/statistical_engine.dart';
import 'engines/stylometry_engine.dart';
import 'engines/transformer_engine.dart';
import 'model_manager.dart';
import 'native_inference_service.dart';

/// 分析協調器：驅動四個子模型並執行加權投票。
/// 權重（A 40% / B 25% / C 20% / D 15%）會在兩種情況下重新分配：
/// 1. 引擎不可用（模型未下載）→ 權重按比例分給可用引擎
/// 2. ESL 偏差修正 → 降低統計模型 (B) 權重，避免誤判非母語者
class EnsembleOrchestrator {
  final List<DetectionEngine> engines;

  EnsembleOrchestrator({
    List<DetectionEngine>? engines,
    ModelManager? modelManager,
    NativeInferenceService? native,
  }) : engines = engines ??
            _defaultEngines(
              modelManager ?? ModelManager(),
              native ?? NativeInferenceService(),
            );

  static List<DetectionEngine> _defaultEngines(
    ModelManager mm,
    NativeInferenceService native,
  ) =>
      [
        TransformerEngine(modelManager: mm, native: native),
        StatisticalEngine(modelManager: mm, native: native),
        StylometryEngine(),
        AdversarialEngine(modelManager: mm, native: native),
      ];

  /// 逐引擎回報進度：engineId → 完成。
  /// [eslCorrectionEnabled] 對應設定頁開關，關閉時不套用偏差修正。
  /// [threshold] 為使用者設定的 AI 判定信心閾值（降低偽陽性）。
  Future<DetectionResult> analyze(
    String input, {
    bool eslCorrectionEnabled = true,
    double threshold = 0.6,
    void Function(String engineId)? onEngineDone,
  }) async {
    final started = DateTime.now();
    final text = PreprocessedText.from(input);

    final scores = <EngineScore>[];
    for (final engine in engines) {
      final available = await engine.isAvailable();
      final score = available
          ? await engine.analyze(text)
          : EngineScore(
              engineId: engine.id,
              engineName: engine.name,
              aiProbability: 0.5,
              weight: engine.defaultWeight,
              available: false,
              reasons: const ['模型尚未安裝，未參與本次投票'],
            );
      scores.add(score);
      onEngineDone?.call(engine.id);
    }

    final eslAdjusted = eslCorrectionEnabled && _detectEslStyle(text);
    final overall = _weightedVote(scores, eslAdjusted: eslAdjusted);
    final sentences = _scoreSentences(text, overall);

    return DetectionResult(
      id: started.microsecondsSinceEpoch.toString(),
      analyzedAt: started,
      inputText: input,
      aiProbability: overall,
      verdict: Verdict.fromProbability(overall),
      engineScores: scores,
      sentences: sentences,
      dominantPatterns: _dominantPatterns(scores),
      eslAdjusted: eslAdjusted,
      threshold: threshold,
      elapsed: DateTime.now().difference(started),
    );
  }

  double _weightedVote(List<EngineScore> scores, {required bool eslAdjusted}) {
    final active = scores.where((s) => s.available).toList();
    if (active.isEmpty) return 0.5;

    double weightOf(EngineScore s) {
      // ESL 修正：統計模型權重減半（低困惑度/低突發性可能是語言能力，非 AI 特徵）
      if (eslAdjusted && s.engineId == 'statistical') return s.weight * 0.5;
      return s.weight;
    }

    final totalWeight = active.fold(0.0, (sum, s) => sum + weightOf(s));
    if (totalWeight == 0) return 0.5;
    return active.fold(0.0, (sum, s) => sum + s.aiProbability * weightOf(s)) /
        totalWeight;
  }

  /// ESL 風格偵測（簡化版）：詞彙多樣性低但句長變化大，
  /// 傾向為語言能力限制而非 AI 生成。正式版將以專用分類器實作。
  bool _detectEslStyle(PreprocessedText text) {
    if (text.allTokens.length < 80) return false;
    return text.typeTokenRatio < 0.38 && text.burstiness > 0.45;
  }

  /// 句子級評分：以整體分數為基準，依單句命中的風格模式微調
  List<SentenceScore> _scoreSentences(PreprocessedText text, double overall) {
    final result = <SentenceScore>[];
    for (var i = 0; i < text.sentences.length; i++) {
      final s = text.sentences[i];
      final patterns = <String>[];
      var p = overall;

      for (final t in StylometryEngine.genericTransitions) {
        if (s.toLowerCase().contains(t.toLowerCase())) {
          patterns.add('通用過渡詞「$t」');
          p += 0.08;
        }
      }
      result.add(SentenceScore(
        index: i,
        text: s,
        aiProbability: p.clamp(0.0, 1.0),
        patterns: patterns,
      ));
    }
    return result;
  }

  List<String> _dominantPatterns(List<EngineScore> scores) {
    final patterns = <String>[];
    for (final s in scores.where((s) => s.available)) {
      if (s.aiProbability >= 0.6) {
        patterns.addAll(s.reasons.take(1));
      }
    }
    return patterns;
  }
}
