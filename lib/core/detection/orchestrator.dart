import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;

import '../../l10n/generated/app_localizations.dart';
import '../models/detection_result.dart';
import '../services/preferences_service.dart';
import '../utils/text_stats.dart';
import 'detection_engine.dart';
import 'engines/adversarial_engine.dart';
import 'engines/statistical_engine.dart';
import 'engines/stylometry_engine.dart';
import 'engines/transformer_engine.dart';
import 'model_manager.dart';

/// 分析協調器：驅動四個子模型並執行加權投票。
/// 權重（A 40% / B 25% / C 20% / D 15%）會在兩種情況下重新分配：
/// 1. 引擎不可用（模型未下載或使用者關閉）→ 權重按比例分給可用引擎
/// 2. ESL 偏差修正 → 降低統計模型 (B) 權重，避免誤判非母語者
class EnsembleOrchestrator extends ChangeNotifier {
  final List<DetectionEngine> engines;

  EnsembleOrchestrator({
    List<DetectionEngine>? engines,
    ModelManager? modelManager,
  }) : engines = engines ?? _defaultEngines(modelManager ?? ModelManager());

  /// 重新掃描後續分析所使用的引擎狀態。
  ///
  /// 引擎會在每次 [analyze] 時讀取 ModelManager 的最新使用中變體，
  /// 這裡同時發出通知，讓監聽器可即時更新模型啟用狀態。
  Future<void> refreshEngines() async {
    debugPrint(
      '[Orchestrator] Engines refreshed - new models will be used in next analysis',
    );
    notifyListeners();
  }

  static List<DetectionEngine> _defaultEngines(ModelManager mm) {
    final discovered = <DetectionEngine>[];

    // 1. Transformer AI 分類器。
    // 同一 role 可安裝多個候選變體，但一次分析只跑「使用中」變體。
    // 這能避免 Web ONNX Runtime 同時啟動多個同類 session 而產生
    // Session already started / Session mismatch，權重也保持固定 40%。
    final activeTransformer = mm.activeVariant('transformer');
    discovered.add(
      TransformerEngine(
        modelManager: mm,
        variantId: activeTransformer?.variantId,
      ),
    );

    // 2. 統計特徵模型 (Perplexity)
    discovered.add(StatisticalEngine(modelManager: mm));

    // 3. 風格特徵模型 (Stylometry)
    discovered.add(StylometryEngine());

    // 4. 對抗防禦同樣只跑使用中變體，避免同 role 多 session 競爭。
    final activeAdversarial = mm.activeVariant('adversarial');
    discovered.add(
      AdversarialEngine(
        modelManager: mm,
        variantId: activeAdversarial?.variantId,
      ),
    );

    return discovered;
  }

  /// 逐引擎回報進度：engineId → 完成。
  /// [eslCorrectionEnabled] 對應設定頁開關，關閉時不套用偏差修正。
  /// [threshold] 為使用者設定的 AI 判定信心閾值（降低偽陽性）。
  Future<DetectionResult> analyze(
    String input, {
    bool eslCorrectionEnabled = true,
    double threshold = 0.6,
    PreferencesService? prefs,
    AppLocalizations? l10n,
    void Function(String engineId)? onEngineDone,
    void Function(EngineScore score)? onEngineScore,
  }) async {
    final loc = l10n ?? lookupAppLocalizations(const Locale('en'));
    final started = DateTime.now();
    final text = PreprocessedText.from(input);

    final futures = engines.map((engine) async {
      final role = _roleOf(engine.id);
      final enabled = prefs?.isEngineEnabled(role) ?? true;
      final configuredWeight =
          prefs?.engineWeight(role) ?? engine.defaultWeight;
      final available = enabled && await engine.isAvailable();
      final rawScore = available
          ? await engine.analyze(text, loc)
          : EngineScore(
              engineId: engine.id,
              engineName: engine.name(loc),
              aiProbability: 0.5,
              weight: configuredWeight,
              available: false,
              reasons: [
                enabled
                    ? loc.engineReasonGenericNotInstalled
                    : loc.engineReasonDisabledByUser,
              ],
            );
      final score = rawScore.copyWith(weight: configuredWeight);
      onEngineDone?.call(role);
      onEngineScore?.call(score);
      return score;
    });

    final scores = await Future.wait(futures);

    final eslAdjusted = eslCorrectionEnabled && _detectEslStyle(text);
    final overall = _weightedVote(scores, eslAdjusted: eslAdjusted);
    final sentences = _scoreSentences(text, overall, scores, loc);

    // 統計引擎參與情況
    final availableCount = scores.where((s) => s.available).length;
    final totalCount = scores.length;
    final availableWeight = scores
        .where((s) => s.available)
        .fold<double>(0, (sum, s) => sum + s.weight);
    final totalWeight = scores.fold<double>(0, (sum, s) => sum + s.weight);
    final confidenceRatio = totalWeight > 0
        ? (availableWeight / totalWeight)
        : 0.0;

    debugPrint(
      '[Ensemble] 分析完成: $availableCount/$totalCount 引擎可用，'
      '權重覆蓋 ${(confidenceRatio * 100).toStringAsFixed(0)}% '
      '(${availableWeight.toStringAsFixed(2)}/${totalWeight.toStringAsFixed(2)})',
    );
    if (confidenceRatio < 0.60) {
      debugPrint('[Ensemble] ⚠️ 低信心分析：權重覆蓋不足 60%');
    }
    if (availableCount < 2) {
      debugPrint('[Ensemble] ⚠️ 低信心分析：可用引擎少於 2 個');
    }

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
      availableEngineCount: availableCount,
      totalEngineCount: totalCount,
    );
  }

  static String _roleOf(String engineId) {
    for (final role in PreferencesService.engineRoles) {
      if (engineId == role || engineId.startsWith('${role}_')) return role;
    }
    return engineId;
  }

  double _weightedVote(List<EngineScore> scores, {required bool eslAdjusted}) {
    final active = scores.where((s) => s.available).toList();
    if (active.isEmpty) return 0.5;

    double weightOf(EngineScore s) {
      // ESL 修正：統計模型權重減半（低困惑度/低突發性可能是語言能力，非 AI 特徵）
      if (eslAdjusted && _roleOf(s.engineId) == 'statistical') {
        return s.weight * 0.5;
      }
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

  /// 句子級評分：依使用者設定權重合併神經模型，再依風格模式微調。
  List<SentenceScore> _scoreSentences(
    PreprocessedText text,
    double overall,
    List<EngineScore> scores,
    AppLocalizations l10n,
  ) {
    // 收集所有可用神經模型及其實際設定權重；句子級結果必須與文件級
    // Ensemble 使用同一權重定義，不能再以簡單平均產生不同結論。
    final neuralScores = scores
        .where(
          (s) =>
              s.available &&
              s.sentenceScores != null &&
              s.sentenceScores!.isNotEmpty,
        )
        .map((s) => (values: s.sentenceScores!, weight: s.weight))
        .toList();

    final result = <SentenceScore>[];
    for (var i = 0; i < text.sentences.length; i++) {
      final s = text.sentences[i];
      final patterns = <String>[];
      final analyzable = PreprocessedText.isAnalyzableSentence(s);

      // 基準：有神經模型時依設定權重合併逐句結果，否則以整體分數為基準，
      // 並結合單句長度變化度（如與平均句長之偏差）產生自然的句級差異。
      var p = overall;
      if (neuralScores.isNotEmpty) {
        var sum = 0.0;
        var totalWeight = 0.0;
        for (final neural in neuralScores) {
          if (i < neural.values.length && neural.weight > 0) {
            sum += neural.values[i] * neural.weight;
            totalWeight += neural.weight;
          }
        }
        if (totalWeight > 0) p = sum / totalWeight;
      } else if (text.sentenceTokens.isNotEmpty) {
        final avgLen = text.allTokens.length / text.sentenceTokens.length;
        final curLen = text.sentenceTokens[i].length;
        // 句長起伏與平均值的差距：人類寫作起伏較大（偏差顯著時扣分/偏人類），AI 節奏平穩（貼近平均時加分/偏 AI）
        final dev = (curLen - avgLen).abs();
        if (dev > avgLen * 0.5) {
          p -= 0.04;
        } else if (dev < avgLen * 0.15) {
          p += 0.03;
        }
      }

      for (final t in StylometryEngine.genericTransitions) {
        if (s.toLowerCase().contains(t.toLowerCase())) {
          patterns.add(l10n.patternGenericTransition(t));
          p += 0.05;
        }
      }
      if (!analyzable) {
        p = 0.5;
        patterns
          ..clear()
          ..add('片段過短或疑似 PDF/OCR 噪音，未作 AI 句級判讀');
      }
      result.add(
        SentenceScore(
          index: i,
          text: s,
          aiProbability: p.clamp(0.0, 1.0),
          patterns: patterns,
        ),
      );
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
