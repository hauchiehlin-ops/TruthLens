import 'dart:io';
import 'dart:math' as math;

import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_file_exists.dart';
import '../model_manager.dart';
import '../onnx_detector.dart';

/// 子模型 A：多語言 Transformer 分類器（ONNX Runtime 端上推論）。
/// 使用 [ModelManager] 目前「使用中」的已安裝模型；載入後逐句推論、彙整為整體分數。
/// 支援 WordPiece（BERT 系）與 byte-level BPE（RoBERTa 系）tokenizer。
/// 分類器一定需要 tokenizer；若使用中模型缺 tokenizer 或檔案不存在，回報 unavailable。
class TransformerEngine implements DetectionEngine {
  final ModelManager modelManager;
  final String? variantId;

  static const _supportedTokenizers = {'bert-wordpiece', 'roberta-bpe'};

  OnnxDetector? _detector;
  String? _loadedModelPath;

  TransformerEngine({required this.modelManager, this.variantId});

  @override
  String get id => variantId != null ? 'transformer_$variantId' : 'transformer';

  @override
  String name(AppLocalizations l10n) {
    if (variantId != null) {
      final installed = modelManager.installedVariants('transformer');
      for (final m in installed) {
        if (m.variantId == variantId) return m.displayName;
      }
    }
    return l10n.analysisEngineTransformer;
  }

  @override
  double get defaultWeight => 0.40;

  bool _supported(String tokenizer) => _supportedTokenizers.contains(tokenizer);

  InstalledModel? _resolveVariant() {
    if (variantId != null) {
      final installed = modelManager.installedVariants('transformer');
      for (final m in installed) {
        if (m.variantId == variantId) return m;
      }
      return null;
    }
    return modelManager.activeVariant('transformer');
  }

  /// 依變體檔解析模型與 tokenizer 檔案路徑
  Future<(String, String)?> _resolvePaths() async {
    final active = _resolveVariant();
    if (active == null || !_supported(active.tokenizer)) return null;
    final modelPath = await modelManager.variantModelPath('transformer', active.variantId);
    final tokPath = await modelManager.variantTokenizerPath('transformer', active.variantId);
    if (modelPath == null || tokPath == null) return null;
    if (!await modelFileExists(modelPath) || !await modelFileExists(tokPath)) {
      return null;
    }
    return (modelPath, tokPath);
  }

  @override
  Future<bool> isAvailable() async => (await _resolvePaths()) != null;

  String? _loadError;

  Future<OnnxDetector?> _ensureLoaded() async {
    final paths = await _resolvePaths();
    if (paths == null) return null;
    final (modelPath, tokPath) = paths;
    final active = _resolveVariant()!;
    if (_detector != null && _loadedModelPath == modelPath) return _detector;
    try {
      _detector?.dispose();
      _detector = await OnnxDetector.load(
        modelPath: modelPath,
        tokenizerJsonPath: tokPath,
        tokenizerType: active.tokenizer,
        aiLabelIndex: active.aiLabelIndex,
      );
      _loadedModelPath = modelPath;
      _loadError = null;
      return _detector;
    } catch (e) {
      _detector = null;
      _loadedModelPath = null;
      _loadError = e.toString();
      if (e is FormatException) {
        try {
          final tokFile = File(tokPath);
          if (tokFile.existsSync()) await tokFile.delete();
          await modelManager.refreshInstallStates();
        } catch (_) {}
      }
      return null;
    }
  }

  @override
  Future<EngineScore> analyze(PreprocessedText text, AppLocalizations l10n) async {
    OnnxDetector? detector;
    try {
      detector = await _ensureLoaded();
      if (detector == null || text.sentences.isEmpty) return _unavailable(l10n);
    } catch (_) {
      return _unavailable(l10n);
    }

    List<double> perSentence;
    try {
      perSentence = await detector.classifySentences(text.sentences);
    } catch (e) {
      return _unavailable(l10n);
    }
    final avg = perSentence.reduce((a, b) => a + b) / perSentence.length;
    final aiCount = perSentence.where((s) => s >= 0.6).length;
    final aiRatio = aiCount / perSentence.length;
    final maxSentence = perSentence.reduce(math.max);

    // 置信度校準：避免隨機 Softmax 浮動（~0.50）在 0 句 AI 時輸出 52% 的矛盾
    double calibratedProbability;
    if (aiCount == 0) {
      final margin = (maxSentence - 0.5).clamp(0.0, 0.1) / 0.1;
      calibratedProbability = (avg * 0.10) + (margin * 0.10);
    } else {
      final aiAvg =
          perSentence.where((s) => s >= 0.6).reduce((a, b) => a + b) / aiCount;
      calibratedProbability = (aiRatio * 0.7) + (aiAvg * 0.3);
    }
    calibratedProbability = calibratedProbability.clamp(0.0, 1.0);

    final variant = _resolveVariant();
    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: calibratedProbability,
      weight: defaultWeight,
      features: {
        'ai_sentence_ratio': aiRatio,
        'raw_avg_prob': avg,
        'calibrated_prob': calibratedProbability,
      },
      reasons: [
        l10n.engineReasonTransformerResult(
            variant?.variantId ?? name(l10n), aiCount, perSentence.length),
      ],
      sentenceScores: perSentence,
    );
  }

  EngineScore _unavailable(AppLocalizations l10n) => EngineScore(
        engineId: id,
        engineName: name(l10n),
        aiProbability: 0.5,
        weight: defaultWeight,
        available: false,
        reasons: [
          _loadError != null
              ? l10n.engineReasonTransformerLoadFailed(_loadError!)
              : l10n.engineReasonTransformerNotInstalled,
        ],
      );
}
