import '../models/detection_result.dart';
import '../utils/text_stats.dart';
import '../../l10n/generated/app_localizations.dart';

/// 檢測引擎共同介面。四個子模型（A/B/C/D）各自實作，
/// 由 [EnsembleOrchestrator] 加權投票整合。
abstract class DetectionEngine {
  String get id;

  /// 引擎顯示名稱（依 [l10n] 語系呈現）。
  String name(AppLocalizations l10n);

  /// 集成投票的預設權重（協調器可依 ESL 修正動態調整）
  double get defaultWeight;

  /// 模型是否已就緒（Transformer/對抗模組需下載模型檔後才可用）
  Future<bool> isAvailable();

  /// 對預處理後的文本評分；[l10n] 決定判定理由文字的顯示語系。
  Future<EngineScore> analyze(PreprocessedText text, AppLocalizations l10n);
}
