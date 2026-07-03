import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_manager.dart';
import '../native_inference_service.dart';

/// 子模型 A：XLM-RoBERTa 多語言分類器。
/// 需下載量化模型檔（~120MB），經 [NativeInferenceService] 呼叫原生推論。
/// 模型未安裝或原生端未就緒時回報 unavailable，協調器會重新分配權重。
class TransformerEngine implements DetectionEngine {
  final ModelManager modelManager;
  final NativeInferenceService native;

  TransformerEngine({required this.modelManager, required this.native});

  @override
  String get id => 'transformer';
  @override
  String get name => 'Transformer 分類器';
  @override
  double get defaultWeight => 0.40;

  @override
  Future<bool> isAvailable() async {
    if (!modelManager.canRunEngine(id)) return false;
    return native.isSupported;
  }

  @override
  Future<EngineScore> analyze(PreprocessedText text) async {
    // 句子級推論後彙整為整體分數（每句獨立呼叫原生分類器）
    final perSentence = <double>[];
    for (final sentence in text.sentences) {
      final score = await native.classify(id, sentence);
      if (score != null) perSentence.add(score);
    }
    if (perSentence.isEmpty) {
      return _unavailable();
    }
    final avg = perSentence.reduce((a, b) => a + b) / perSentence.length;
    final aiCount = perSentence.where((s) => s >= 0.6).length;
    return EngineScore(
      engineId: id,
      engineName: name,
      aiProbability: avg,
      weight: defaultWeight,
      features: {'ai_sentence_ratio': aiCount / perSentence.length},
      reasons: [
        '多語言分類器判定 ${perSentence.length} 句中有 $aiCount 句呈現 AI 特徵',
      ],
    );
  }

  EngineScore _unavailable() => EngineScore(
        engineId: id,
        engineName: name,
        aiProbability: 0.5,
        weight: defaultWeight,
        available: false,
        reasons: const ['模型尚未安裝，未參與本次投票'],
      );
}
