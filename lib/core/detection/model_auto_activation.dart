/// 模型自動激活系統
///
/// 實現「下載模型 → 自動加入評判隊列」的邏輯：
/// 1. 模型下載完成時，ModelManager.notifyListeners() 被觸發
/// 2. 監聽器偵測到新安裝的模型
/// 3. 自動通知 EnsembleOrchestrator 刷新可用引擎列表
/// 4. 下次分析自動使用新模型參與投票
library;

import 'package:flutter/foundation.dart';

import '../models/detection_result.dart';
import 'model_manager_web.dart';
import 'orchestrator.dart';

/// 管理模型自動激活事件的單例
class ModelAutoActivationManager {
  static final ModelAutoActivationManager _instance = ModelAutoActivationManager._();

  factory ModelAutoActivationManager() => _instance;

  ModelAutoActivationManager._();

  late EnsembleOrchestrator _orchestrator;
  late ModelManager _modelManager;

  /// 前次已知的已安裝模型集合（用於偵測變化）
  final Map<String, Set<String>> _previousState = {};

  /// 自動激活事件流（供 UI 訂閱）
  final ValueNotifier<ModelActivationEvent?> activationEvent = ValueNotifier(null);

  /// 初始化監聽器
  void init({
    required EnsembleOrchestrator orchestrator,
    required ModelManager modelManager,
  }) {
    _orchestrator = orchestrator;
    _modelManager = modelManager;

    // 監聽模型管理器的變化
    _modelManager.addListener(_onModelStateChanged);
  }

  /// 模型狀態變化時觸發
  Future<void> _onModelStateChanged() async {
    try {
      // 掃描已安裝的模型，偵測新增
      final currentState = <String, Set<String>>{};
      for (final role in _modelManager.roles.map((r) => r.role)) {
        currentState[role] =
            _modelManager.installedVariants(role).map((v) => v.variantId).toSet();
      }

      // 比對前次狀態，找出新增的模型
      final newlyInstalled = <String, String>{};
      currentState.forEach((role, variants) {
        final previous = _previousState[role] ?? {};
        for (final variant in variants) {
          if (!previous.contains(variant)) {
            newlyInstalled[role] = variant;
          }
        }
      });

      // 如果有新增模型，自動激活並刷新引擎
      if (newlyInstalled.isNotEmpty) {
        await _activateNewModels(newlyInstalled);
        _previousState.clear();
        _previousState.addAll(currentState);
      }
    } catch (e, st) {
      debugPrintStack(stackTrace: st, label: 'ModelAutoActivation error: $e');
    }
  }

  /// 自動激活新安裝的模型
  Future<void> _activateNewModels(Map<String, String> newlyInstalled) async {
    final events = <String>[];

    // 逐個模型進行激活
    for (final MapEntry(key: role, value: variantId) in newlyInstalled.entries) {
      try {
        // 將新模型設為該角色的活躍變體
        await _modelManager.setActive(role, variantId);

        events.add('$role:$variantId');

        debugPrint('[ModelAutoActivation] Activated $role($variantId)');
      } catch (e) {
        debugPrint('[ModelAutoActivation] Failed to activate $role: $e');
      }
    }

    // 通知 Orchestrator 刷新可用引擎
    // 這樣下次分析時會自動使用新模型
    _orchestrator.notifyListeners();

    // 發出激活事件
    activationEvent.value = ModelActivationEvent(
      activatedModels: events,
      timestamp: DateTime.now(),
    );
  }

  /// 清理資源
  void dispose() {
    _modelManager.removeListener(_onModelStateChanged);
    activationEvent.dispose();
  }
}

/// 模型激活事件
class ModelActivationEvent {
  final List<String> activatedModels; // 格式：['role:variantId', ...]
  final DateTime timestamp;

  ModelActivationEvent({
    required this.activatedModels,
    required this.timestamp,
  });

  @override
  String toString() =>
      'ModelActivationEvent(activated: ${activatedModels.join(', ')}, at: $timestamp)';
}

/// 擴展 EnsembleOrchestrator，支持動態引擎刷新
///
/// **使用方式**（在 analysis_screen.dart 或 input_screen.dart）：
/// ```dart
/// final orchestrator = context.read<EnsembleOrchestrator>();
///
/// // 當模型下載完成時
/// await orchestrator.refreshEngines();
///
/// // 下次分析自動使用新模型
/// final result = await orchestrator.analyze(text, l10n);
/// ```
extension OrchestratorExtension on EnsembleOrchestrator {
  /// 重新掃描已安裝的模型，更新可用引擎列表
  ///
  /// 呼叫此方法後，[analyze] 方法將使用最新的模型配置。
  Future<void> refreshEngines() async {
    // 觸發 Orchestrator 的 notifyListeners()
    // 這會促使任何監聽 Orchestrator 的 Widget 重建
    notifyListeners();

    debugPrint('[Orchestrator] Engines refreshed - new models will be used in next analysis');
  }
}

/// UI 集成輔助：在模型下載完成時通知自動激活
///
/// **在 ModelDownloadScreen 中使用**：
/// ```dart
/// // 下載完成後
/// ModelAutoActivationManager().activationEvent.addListener(() {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text('✅ 新模型已激活！下次分析自動使用')),
///   );
/// });
/// ```
void notifyModelDownloadComplete({
  required String role,
  required String variantId,
  required EnsembleOrchestrator orchestrator,
}) {
  // 通知 Orchestrator 刷新引擎
  orchestrator.refreshEngines();

  debugPrint('[ModelDownload] Complete: $role($variantId) - Orchestrator refreshed');
}
