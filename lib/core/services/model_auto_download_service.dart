import 'dart:async';

import 'package:flutter/foundation.dart';

import '../detection/model_catalog.dart';
import '../detection/model_catalog_service.dart';
import '../detection/model_manager.dart';
import '../detection/model_manager_types.dart';
import 'device_performance_service.dart';

/// 模型下載策略
enum ModelDownloadStrategy {
  manual,        // 用戶手動下載
  autoSmall,     // 自動下載小型模型（< 100MB）
  autoMedium,    // 自動下載中型模型（100-500MB）
  promptLarge,   // 提示用戶（大型模型）
}

/// 模型下載計畫
class ModelDownloadPlan {
  final String role;
  final ModelVariant variant;
  final ModelDownloadStrategy strategy;
  final String reason;
  final bool needsUserConfirmation;

  const ModelDownloadPlan({
    required this.role,
    required this.variant,
    required this.strategy,
    required this.reason,
    this.needsUserConfirmation = false,
  });

  /// 模型大小分類
  bool get isSmall => variant.sizeBytes < 100 * 1024 * 1024; // < 100 MB
  bool get isMedium => variant.sizeBytes < 500 * 1024 * 1024; // < 500 MB
  bool get isLarge => variant.sizeBytes >= 500 * 1024 * 1024; // >= 500 MB
}

/// 模型自動下載管理服務
class ModelAutoDownloadService extends ChangeNotifier {
  final ModelManager modelManager;
  final ModelCatalogService catalogService;
  final DevicePerformanceService deviceService;

  List<ModelDownloadPlan> _pendingPlans = [];
  Map<String, bool> _userApprovals = {}; // role -> 用戶決定
  bool _isProcessing = false;

  ModelAutoDownloadService({
    required this.modelManager,
    required this.catalogService,
    required this.deviceService,
  });

  List<ModelDownloadPlan> get pendingPlans => List.unmodifiable(_pendingPlans);
  bool get isProcessing => _isProcessing;

  /// 分析並生成下載計畫
  Future<List<ModelDownloadPlan>> analyzeDowloads() async {
    try {
      final performance = await deviceService.detect();
      final catalog = await catalogService.load();
      final plans = <ModelDownloadPlan>[];

      for (final modelDef in kModelRegistry) {
        final role = modelDef.id;
        if (modelManager.isInstalled(role)) continue; // 已安裝跳過

        final roleCatalog = catalog.forRole(role);
        if (roleCatalog == null || roleCatalog.variants.isEmpty) continue;

        // 推薦首個變體（默認下載版本）
        final recommended = roleCatalog.variants.first;

        // 根據硬體性能決定下載策略
        final strategy = _determineStrategy(recommended, performance, role);
        final plan = ModelDownloadPlan(
          role: role,
          variant: recommended,
          strategy: strategy,
          reason: _generateReason(recommended, strategy, performance),
          needsUserConfirmation: strategy == ModelDownloadStrategy.promptLarge,
        );

        plans.add(plan);
      }

      _pendingPlans = plans;
      notifyListeners();
      return plans;
    } catch (e) {
      debugPrint('[ModelAutoDownload] 分析失敗: $e');
      return [];
    }
  }

  /// 用戶同意/拒絕下載大型模型
  void setUserApproval(String role, bool approved) {
    _userApprovals[role] = approved;
    notifyListeners();
  }

  /// 執行下載計畫
  Future<int> executeDownloads() async {
    if (_isProcessing) return 0;

    _isProcessing = true;
    notifyListeners();

    int successCount = 0;
    try {
      for (final plan in _pendingPlans) {
        // 檢查用戶決定
        if (plan.needsUserConfirmation &&
            _userApprovals[plan.role] != true) {
          continue;
        }

        // 自動下載或跳過提示
        if (plan.strategy == ModelDownloadStrategy.manual) continue;

        try {
          final success =
              await modelManager.downloadVariant(plan.role, plan.variant);
          if (success) successCount++;
        } catch (e) {
          debugPrint('[ModelAutoDownload] 下載失敗 ${plan.role}: $e');
        }
      }

      _pendingPlans.clear();
    } finally {
      _isProcessing = false;
      notifyListeners();
    }

    return successCount;
  }

  // 私有方法

  ModelDownloadStrategy _determineStrategy(
    ModelVariant variant,
    DevicePerformance performance,
    String role,
  ) {
    // 核心引擎：Transformer、Statistical → 自動小型或提示大型
    if (role == 'transformer' || role == 'statistical') {
      if (variant.sizeBytes < 100 * 1024 * 1024 &&
          performance.shouldAutoDownloadSmall) {
        return ModelDownloadStrategy.autoSmall;
      }
      if (performance.shouldPromptLarge) {
        return ModelDownloadStrategy.promptLarge;
      }
      return ModelDownloadStrategy.manual;
    }

    // 可選引擎：Stylometry、Adversarial → 用戶決定
    if (role == 'stylometry' || role == 'adversarial') {
      return ModelDownloadStrategy.manual;
    }

    return ModelDownloadStrategy.manual;
  }

  String _generateReason(
    ModelVariant variant,
    ModelDownloadStrategy strategy,
    DevicePerformance performance,
  ) {
    final sizeMb = (variant.sizeBytes / 1024 / 1024).toStringAsFixed(1);
    final estimatedTime = performance.estimatedDownloadTime(
      (variant.sizeBytes / 1024 / 1024).toInt(),
    );

    return switch (strategy) {
      ModelDownloadStrategy.autoSmall =>
        '小型模型 ($sizeMb MB)，您的設備支援自動下載（預計 $estimatedTime 秒）',
      ModelDownloadStrategy.autoMedium =>
        '中型模型 ($sizeMb MB)，背景下載中...',
      ModelDownloadStrategy.promptLarge =>
        '大型模型 ($sizeMb MB)，需要 $estimatedTime 秒。是否下載？',
      ModelDownloadStrategy.manual =>
        '模型可選（$sizeMb MB），您可在設定中手動下載',
    };
  }
}
