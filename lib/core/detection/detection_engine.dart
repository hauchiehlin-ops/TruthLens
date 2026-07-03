import '../models/detection_result.dart';
import '../utils/text_stats.dart';

/// 檢測引擎共同介面。四個子模型（A/B/C/D）各自實作，
/// 由 [EnsembleOrchestrator] 加權投票整合。
abstract class DetectionEngine {
  String get id;
  String get name;

  /// 集成投票的預設權重（協調器可依 ESL 修正動態調整）
  double get defaultWeight;

  /// 模型是否已就緒（Transformer/對抗模組需下載模型檔後才可用）
  Future<bool> isAvailable();

  /// 對預處理後的文本評分
  Future<EngineScore> analyze(PreprocessedText text);
}
