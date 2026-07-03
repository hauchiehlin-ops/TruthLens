import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_manager.dart';
import '../native_inference_service.dart';

/// 子模型 D：對抗式防禦模組（改寫偵測）。
/// 以「改寫後 AI 文本」訓練的專用分類器，經 [NativeInferenceService] 推論。
/// 模型未安裝或原生端未就緒時回報 unavailable。
class AdversarialEngine implements DetectionEngine {
  final ModelManager modelManager;
  final NativeInferenceService native;

  AdversarialEngine({required this.modelManager, required this.native});

  @override
  String get id => 'adversarial';
  @override
  String get name => '對抗式防禦（改寫偵測）';
  @override
  double get defaultWeight => 0.15;

  @override
  Future<bool> isAvailable() async {
    if (!modelManager.canRunEngine(id)) return false;
    return native.isSupported;
  }

  @override
  Future<EngineScore> analyze(PreprocessedText text) async {
    final score = await native.classify(id, text.raw);
    if (score == null) {
      return EngineScore(
        engineId: id,
        engineName: name,
        aiProbability: 0.5,
        weight: defaultWeight,
        available: false,
        reasons: const ['模型尚未安裝，未參與本次投票'],
      );
    }
    return EngineScore(
      engineId: id,
      engineName: name,
      aiProbability: score,
      weight: defaultWeight,
      reasons: [
        score >= 0.6
            ? '偵測到疑似經改寫工具（如 QuillBot / Undetectable.ai）處理的痕跡'
            : '未偵測到明顯的改寫規避特徵',
      ],
    );
  }
}
