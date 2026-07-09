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

  static const _supportedTokenizers = {'bert-wordpiece', 'roberta-bpe'};

  OnnxDetector? _detector;
  String? _loadedModelPath;

  TransformerEngine({required this.modelManager});

  @override
  String get id => 'transformer';
  @override
  String name(AppLocalizations l10n) => l10n.analysisEngineTransformer;
  @override
  double get defaultWeight => 0.40;

  bool _supported(String tokenizer) => _supportedTokenizers.contains(tokenizer);

  /// 使用中模型與其 tokenizer 的檔案是否都真的存在於磁碟（避免自動掃描登記到缺檔的模型）。
  Future<(String, String)?> _resolvePaths() async {
    final active = modelManager.activeVariant(id);
    if (active == null || !_supported(active.tokenizer)) return null;
    final modelPath = await modelManager.activeModelPath(id);
    final tokPath = await modelManager.activeTokenizerPath(id);
    if (modelPath == null || tokPath == null) return null;
    if (!await modelFileExists(modelPath) || !await modelFileExists(tokPath)) {
      return null;
    }
    return (modelPath, tokPath);
  }

  @override
  Future<bool> isAvailable() async => (await _resolvePaths()) != null;

  String? _loadError;

  /// 依「使用中」模型延遲載入 / 快取 detector；模型切換時重新載入。
  /// 載入失敗（如模型 opset 不相容、檔案損毀）回傳 null 並記錄原因，不拋出。
  Future<OnnxDetector?> _ensureLoaded() async {
    final paths = await _resolvePaths();
    if (paths == null) return null;
    final (modelPath, tokPath) = paths;
    final active = modelManager.activeVariant(id)!;
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

    final perSentence = await detector.classifySentences(text.sentences);
    final avg = perSentence.reduce((a, b) => a + b) / perSentence.length;
    final aiCount = perSentence.where((s) => s >= 0.6).length;
    final variant = modelManager.activeVariant(id);
    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: avg,
      weight: defaultWeight,
      features: {'ai_sentence_ratio': aiCount / perSentence.length},
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
