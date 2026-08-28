import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;

import '../../l10n/generated/app_localizations.dart';
import '../models/calibration_evidence.dart';
import '../models/detection_result.dart';
import '../models/input_quality.dart';
import '../services/calibration_service.dart';
import '../services/document_provenance.dart';
import '../services/writing_session.dart';
import '../services/preferences_service.dart';
import '../utils/text_stats.dart';
import 'detection_engine.dart';
import 'analysis_profile.dart';
import 'evasion_scanner.dart';
import 'evidence_fusion.dart';
import 'lexical_calibration.dart';
import 'engines/adversarial_engine.dart';
import 'engines/statistical_engine.dart';
import 'engines/stylometry_engine.dart';
import 'engines/transformer_engine.dart';
import 'model_manager.dart';

/// 分析協調器：驅動四個子模型，先依獨立證據家族去除重複訊號，再融合判讀。
///
/// 設定權重（A 40% / B 25% / C 20% / D 15%）只是家族上限；實際話語權還會
/// 受語言、領域、模型校準可靠度、文件覆蓋率與 ESL 偏差修正限制。引擎分數高低
/// 不會反過來提高自己的權重。
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
    // 一次分析仍只跑一顆 Transformer，但不在 Orchestrator 建構時鎖死
    // activeVariantId。文件語言要等預處理後才知道，TransformerEngine
    // 會在每次分析時從所有已安裝變體挑選經該語言驗證的最佳模型。
    discovered.add(TransformerEngine(modelManager: mm));

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
  /// 五級判定使用 [Verdict.cutPoints] 的固定切點，不再接受可調門檻。
  Future<DetectionResult> analyze(
    String input, {
    String sourceFileName = '',
    DocumentProvenance provenance = DocumentProvenance.none,
    WritingSession writingSession = WritingSession.empty,
    InputQualityEvidence inputQuality = InputQualityEvidence.directText,
    CalibrationService? calibration,
    bool eslCorrectionEnabled = true,
    PreferencesService? prefs,
    AppLocalizations? l10n,
    void Function(String engineId)? onEngineStarted,
    void Function(String engineId)? onEngineDone,
    void Function(EngineScore score)? onEngineScore,
  }) async {
    final loc = l10n ?? lookupAppLocalizations(const Locale('en'));
    final started = DateTime.now();
    final text = PreprocessedText.from(input);
    final profile = AnalysisProfile.fromText(input);

    final futures = engines.map((engine) async {
      final role = _roleOf(engine.id);
      onEngineStarted?.call(role);
      await Future<void>.delayed(Duration.zero);
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
              applicability: EngineApplicability.unsupported,
              calibrationReliability: 0,
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
    final fusion = TextEvidenceFusion.evaluate(
      scores: scores,
      inputText: input,
      profile: profile,
      extractionQuality: inputQuality.extractionQuality,
      eslAdjusted: eslAdjusted,
    );
    final overall = fusion.probability;
    final sentences = _scoreSentences(text, overall, scores, loc);
    final analysisSignature = CalibrationService.analysisSignatureFor(scores);
    final calibrationEvidence =
        calibration?.evaluateFor(
          score: overall,
          language: profile.language,
          analysisSignature: analysisSignature,
          domain: profile.domain.name,
          lengthBucket: CalibrationService.lengthBucketFor(profile.wordCount),
        ) ??
        CalibrationEvidence.unavailable;

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
      sourceFileName: sourceFileName,
      provenance: provenance,
      // 規避痕跡掃描是純本地的確定性檢查，成本近乎零，直接在分析當下完成
      evasion: scanForEvasion(input, acquisitionMethod: inputQuality.method),
      writingSession: writingSession,
      aiProbability: overall,
      verdict: Verdict.fromProbability(overall),
      engineScores: scores,
      sentences: sentences,
      dominantPatterns: _dominantPatterns(scores),
      eslAdjusted: eslAdjusted,
      elapsed: DateTime.now().difference(started),
      availableEngineCount: availableCount,
      totalEngineCount: totalCount,
      inputQuality: inputQuality,
      calibration: calibrationEvidence,
    );
  }

  static String _roleOf(String engineId) {
    for (final role in PreferencesService.engineRoles) {
      if (engineId == role || engineId.startsWith('${role}_')) return role;
    }
    return engineId;
  }

  /// ESL 風格偵測（簡化版）：詞彙多樣性低但句長變化大，
  /// 傾向為語言能力限制而非 AI 生成。正式版將以專用分類器實作。
  ///
  /// **只適用於已校準的語言。** 兩個理由：
  /// 1. 這個修正處理的是「以英文為第二語言」的寫作偏差，對一篇中文文件
  ///    談 ESL 本身就沒有意義
  /// 2. 門檻 0.38 是英文詞級 TTR 的值。中文逐字計詞，TTR 隨長度崩塌
  ///    （2000 字時降到 0.283），套用會讓長中文文件無差別觸發，
  ///    使統計引擎的權重被砍半
  ///
  /// 改用長度不變的 MATTR，並以 [LexicalCalibration] 是否涵蓋該語言把關。
  bool _detectEslStyle(PreprocessedText text) {
    if (text.allTokens.length < 80) return false;
    if (text.language.isUndetermined) return false;
    if (LexicalCalibration.of(text.language.code) == null) return false;
    return text.movingAverageTypeTokenRatio < 0.60 && text.burstiness > 0.45;
  }

  /// 句子級評分：依使用者設定權重合併神經模型，再依風格模式微調。
  List<SentenceScore> _scoreSentences(
    PreprocessedText text,
    double overall,
    List<EngineScore> scores,
    AppLocalizations l10n,
  ) {
    // 收集所有可用神經模型及其本次有效權重；句子級結果必須與文件級
    // Ensemble 使用同一權重定義，不能再以簡單平均產生不同結論。
    final neuralScores = scores
        .where(
          (s) =>
              s.votes &&
              s.sentenceScores != null &&
              s.sentenceScores!.isNotEmpty,
        )
        .map(
          (s) => (
            values: s.sentenceScores!,
            weight: s.weight * s.evidenceWeightMultiplier,
          ),
        )
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
          ..add(l10n.patternNotAnalyzable);
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
