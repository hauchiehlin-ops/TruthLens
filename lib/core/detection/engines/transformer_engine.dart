import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_manager.dart';
import '../onnx_detector.dart';

/// 子模型 A：多語言 Transformer 分類器（ONNX Runtime 端上推論）。
/// 使用 [ModelManager] 目前「使用中」的已安裝模型；載入後逐句推論、彙整為整體分數。
/// 支援 WordPiece（BERT 系）與 byte-level BPE（RoBERTa 系）tokenizer。
class TransformerEngine implements DetectionEngine {
  final ModelManager modelManager;

  static const _supportedTokenizers = {'bert-wordpiece', 'roberta-bpe', 'none'};

  OnnxDetector? _detector;
  String? _loadedModelPath;

  TransformerEngine({required this.modelManager});

  @override
  String get id => 'transformer';
  @override
  String get name => 'Transformer 分類器';
  @override
  double get defaultWeight => 0.40;

  bool _supported(String tokenizer) => _supportedTokenizers.contains(tokenizer);

  @override
  Future<bool> isAvailable() async {
    final active = modelManager.activeVariant(id);
    if (active == null || !_supported(active.tokenizer)) return false;
    final hasModel = (await modelManager.activeModelPath(id)) != null;
    final hasTokenizer = active.tokenizer == 'none' || (await modelManager.activeTokenizerPath(id)) != null;
    return hasModel && hasTokenizer;
  }

  String? _loadError;

  /// 依「使用中」模型延遲載入 / 快取 detector；模型切換時重新載入。
  /// 載入失敗（如模型 opset 不相容、檔案損毀）回傳 null 並記錄原因，不拋出。
  Future<OnnxDetector?> _ensureLoaded() async {
    final active = modelManager.activeVariant(id);
    if (active == null || !_supported(active.tokenizer)) return null;
    final modelPath = await modelManager.activeModelPath(id);
    final String tokPath = active.tokenizer == 'none' ? '' : (await modelManager.activeTokenizerPath(id) ?? '');
    if (modelPath == null || (active.tokenizer != 'none' && tokPath.isEmpty)) return null;
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
  Future<EngineScore> analyze(PreprocessedText text) async {
    OnnxDetector? detector;
    try {
      detector = await _ensureLoaded();
      if (detector == null || text.sentences.isEmpty) return _unavailable();
    } catch (_) {
      return _unavailable();
    }

    final perSentence = await detector.classifySentences(text.sentences);
    final avg = perSentence.reduce((a, b) => a + b) / perSentence.length;
    final aiCount = perSentence.where((s) => s >= 0.6).length;
    final variant = modelManager.activeVariant(id);
    return EngineScore(
      engineId: id,
      engineName: name,
      aiProbability: avg,
      weight: defaultWeight,
      features: {'ai_sentence_ratio': aiCount / perSentence.length},
      reasons: [
        '${variant?.variantId ?? '模型'} 判定 ${perSentence.length} 句中有 '
            '$aiCount 句呈現 AI 特徵',
      ],
      sentenceScores: perSentence,
    );
  }

  EngineScore _unavailable() => EngineScore(
        engineId: id,
        engineName: name,
        aiProbability: 0.5,
        weight: defaultWeight,
        available: false,
        reasons: [
          _loadError != null
              ? '模型載入失敗，未參與本次投票（${_loadError!}）'
              : '模型尚未安裝或使用中模型未支援，未參與本次投票',
        ],
      );
}
