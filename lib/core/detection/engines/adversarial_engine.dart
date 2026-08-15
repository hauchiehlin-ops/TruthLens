import 'package:flutter/foundation.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_file_exists.dart';
import '../model_manager.dart';
import '../onnx_detector.dart';

/// 子模型 D：對抗式防禦模組（改寫偵測），ONNX Runtime 端上推論。
/// 以「原生 AI + 改寫後 AI」皆標為 AI 訓練的分類器（見 training/prepare_adversarial.py），
/// 對 QuillBot / Undetectable.ai 等改寫規避具韌性；推論使用保留段落上下文的
/// 受控區塊，再映射回逐句分數供報告使用。
/// 使用中模型與 tokenizer 檔皆需存在才可用；否則回報 unavailable（優雅降級）。
class AdversarialEngine implements DetectionEngine {
  final ModelManager modelManager;
  final String? variantId;

  static const _supportedTokenizers = {'bert-wordpiece', 'roberta-bpe'};

  OnnxDetector? _detector;
  String? _loadedModelPath;
  String? _loadError;
  String? _repairMessage;

  AdversarialEngine({required this.modelManager, this.variantId});

  @override
  String get id => variantId != null ? 'adversarial_$variantId' : 'adversarial';

  @override
  String name(AppLocalizations l10n) => l10n.engineNameAdversarialFull;

  @override
  double get defaultWeight => 0.15;

  InstalledModel? _resolveVariant() {
    if (variantId != null) {
      final installed = modelManager.installedVariants('adversarial');
      for (final m in installed) {
        if (m.variantId == variantId) return m;
      }
      return null;
    }
    return modelManager.activeVariant('adversarial');
  }

  Future<(String, String)?> _resolvePaths() async {
    final active = _resolveVariant();
    if (active == null) return null;
    final modelPath = await modelManager.variantModelPath(
      'adversarial',
      active.variantId,
    );
    final tokPath = await modelManager.variantTokenizerPath(
      'adversarial',
      active.variantId,
    );
    if (modelPath == null || tokPath == null) return null;
    if (!await modelFileExists(modelPath) || !await modelFileExists(tokPath)) {
      return null;
    }
    return (modelPath, tokPath);
  }

  @override
  Future<bool> isAvailable() async => (await _resolvePaths()) != null;

  Future<OnnxDetector?> _ensureLoaded(AppLocalizations l10n) async {
    final paths = await _resolvePaths();
    if (paths == null) {
      final active = _resolveVariant();
      _loadError = active == null
          ? l10n.engineAdversarialNoActiveVariant
          : l10n.engineAdversarialMissingFiles;
      return null;
    }
    final (modelPath, tokPath) = paths;
    final active = _resolveVariant()!;
    if (_detector != null && _loadedModelPath == modelPath) return _detector;
    Object? lastError;

    for (final tokenizerType in [
      active.tokenizer,
      if (active.tokenizer != 'bert-wordpiece') 'bert-wordpiece',
      if (active.tokenizer != 'roberta-bpe') 'roberta-bpe',
    ].where(_supportedTokenizers.contains)) {
      try {
        _detector?.dispose();
        _detector = await OnnxDetector.load(
          modelPath: modelPath,
          tokenizerJsonPath: tokPath,
          tokenizerType: tokenizerType,
          aiLabelIndex: active.aiLabelIndex,
        );
        _loadedModelPath = modelPath;
        _loadError = null;
        return _detector;
      } catch (e) {
        _detector = null;
        _loadedModelPath = null;
        lastError = e;
        debugPrint('[AdversarialEngine] tokenizer=$tokenizerType 載入失敗: $e');
      }
    }

    debugPrint('[AdversarialEngine] 所有 tokenizer 備援皆失敗，啟動自動修復: $lastError');
    _repairMessage = await _repairActiveVariant(l10n);
    _loadError = _repairMessage;
    return null;
  }

  EngineScore _unavailable(AppLocalizations l10n) => EngineScore(
    engineId: id,
    engineName: name(l10n),
    aiProbability: 0.5,
    weight: defaultWeight,
    available: false,
    reasons: [
      _loadError == null
          ? l10n.engineReasonAdversarialNotInstalled
          : l10n.engineReasonNotParticipatedWithError(_loadError!),
    ],
  );

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n,
  ) async {
    OnnxDetector? detector;
    try {
      detector = await _ensureLoaded(l10n);
    } catch (_) {
      detector = null;
    }
    if (detector == null || text.analysisChunks.isEmpty) {
      return _unavailable(l10n);
    }

    List<double> perChunk;
    try {
      perChunk = await detector.classifySentences(text.analysisChunks);
    } catch (e) {
      debugPrint('[AdversarialEngine] 模型推論失敗，啟動自動修復: $e');
      detector.dispose();
      _detector = null;
      _loadedModelPath = null;
      _repairMessage = await _repairActiveVariant(l10n);
      _loadError = _repairMessage;
      return _unavailable(l10n);
    }
    final perSentence = text.expandChunkScoresToSentences(perChunk);
    final avg = perChunk.reduce((a, b) => a + b) / perChunk.length;
    final strongChunks = perChunk.where((score) => score >= 0.6).toList();
    final strongChunkCount = strongChunks.length;
    final strongChunkRatio = strongChunkCount / perChunk.length;
    final strongSentenceCount = perSentence
        .where((score) => score >= 0.6)
        .length;
    final strongSentenceRatio = strongSentenceCount / perSentence.length;
    double calibratedProbability;
    if (strongChunkCount == 0) {
      final peak = perChunk.reduce((a, b) => a > b ? a : b);
      final averageMargin = (avg - 0.5).clamp(0.0, 0.1) / 0.1;
      final peakMargin = (peak - 0.5).clamp(0.0, 0.1) / 0.1;
      calibratedProbability = (averageMargin * 0.07) + (peakMargin * 0.03);
    } else {
      final strongAverage =
          strongChunks.reduce((a, b) => a + b) / strongChunkCount;
      calibratedProbability = (strongChunkRatio * 0.7) + (strongAverage * 0.3);
    }
    calibratedProbability = calibratedProbability.clamp(0.0, 1.0);
    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: calibratedProbability,
      weight: defaultWeight,
      sentenceScores: perSentence,
      features: {
        'strong_sentence_ratio': strongSentenceRatio,
        'strong_analysis_chunk_ratio': strongChunkRatio,
        'analysis_chunk_count': perChunk.length.toDouble(),
        'raw_avg_prob': avg,
        'calibrated_prob': calibratedProbability,
      },
      reasons: [
        if (strongChunkCount == 0)
          l10n.engineReasonAdversarialNoStrongSentence(
            perSentence.length,
            (calibratedProbability * 100).round(),
          )
        else
          l10n.engineReasonAdversarialStrongSentences(
            strongSentenceCount,
            perSentence.length,
            (calibratedProbability * 100).round(),
          ),
      ],
    );
  }

  Future<String> _repairActiveVariant(AppLocalizations l10n) async {
    try {
      return await modelManager.repairActiveVariant('adversarial', l10n);
    } catch (_) {
      return l10n.engineAdversarialRepairFailed;
    }
  }
}
