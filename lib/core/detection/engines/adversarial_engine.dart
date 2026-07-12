import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_file_exists.dart';
import '../model_manager.dart';
import '../onnx_detector.dart';

/// 子模型 D：對抗式防禦模組（改寫偵測），ONNX Runtime 端上推論。
/// 以「原生 AI + 改寫後 AI」皆標為 AI 訓練的分類器（見 training/prepare_adversarial.py），
/// 對 QuillBot / Undetectable.ai 等改寫規避具韌性。
/// 使用中模型與 tokenizer 檔皆需存在才可用；否則回報 unavailable（優雅降級）。
class AdversarialEngine implements DetectionEngine {
  final ModelManager modelManager;

  static const _supportedTokenizers = {'bert-wordpiece', 'roberta-bpe'};

  OnnxDetector? _detector;
  String? _loadedModelPath;

  AdversarialEngine({required this.modelManager});

  @override
  String get id => 'adversarial';
  @override
  String name(AppLocalizations l10n) => l10n.engineNameAdversarialFull;
  @override
  double get defaultWeight => 0.15;

  Future<(String, String)?> _resolvePaths() async {
    final active = modelManager.activeVariant(id);
    if (active == null || !_supportedTokenizers.contains(active.tokenizer)) {
      return null;
    }
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
      return _detector;
    } catch (_) {
      _detector = null;
      _loadedModelPath = null;
      return null;
    }
  }

  @override
  Future<EngineScore> analyze(PreprocessedText text, AppLocalizations l10n) async {
    OnnxDetector? detector;
    try {
      detector = await _ensureLoaded();
    } catch (_) {
      detector = null;
    }
    if (detector == null || text.sentences.isEmpty) {
      return EngineScore(
        engineId: id,
        engineName: name(l10n),
        aiProbability: 0.5,
        weight: defaultWeight,
        available: false,
        reasons: [l10n.engineReasonAdversarialNotInstalled],
      );
    }

    List<double> perSentence;
    try {
      perSentence = await detector.classifySentences(text.sentences);
    } catch (e) {
      return EngineScore(
        engineId: id,
        engineName: name(l10n),
        aiProbability: 0.5,
        weight: defaultWeight,
        available: false,
        reasons: [l10n.engineReasonAdversarialNotInstalled],
      );
    }
    final avg = perSentence.reduce((a, b) => a + b) / perSentence.length;
    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: avg,
      weight: defaultWeight,
      sentenceScores: perSentence,
      reasons: [
        avg >= 0.6
            ? l10n.engineReasonAdversarialDetected
            : l10n.engineReasonAdversarialClean,
      ],
    );
  }
}
