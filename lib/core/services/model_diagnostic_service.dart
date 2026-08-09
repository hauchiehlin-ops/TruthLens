import '../detection/model_manager.dart';

/// 模型診斷報告 — 幫助用戶了解模型狀態並自助修復
class ModelDiagnosticReport {
  final String role;
  final int totalModels;
  final int installableModels; // 可下載/已安裝的模型
  final int failedModels; // 無法使用的模型
  final List<ModelStatus> statuses;
  final List<String> recommendations; // 用戶友好的建議

  const ModelDiagnosticReport({
    required this.role,
    required this.totalModels,
    required this.installableModels,
    required this.failedModels,
    required this.statuses,
    required this.recommendations,
  });

  bool get hasIssues => failedModels > 0;
}

/// 單個模型的診斷狀態
class ModelStatus {
  final String variantId;
  final String displayName;
  final String statusLabel; // "已安裝", "未安裝", "載入失敗", "Tokenizer 損毀"
  final String? errorDetails; // 詳細錯誤消息
  final bool canRepair; // 是否可以一鍵修復
  final String? repairAction; // 修復操作（重新下載、刪除等）

  const ModelStatus({
    required this.variantId,
    required this.displayName,
    required this.statusLabel,
    this.errorDetails,
    this.canRepair = false,
    this.repairAction,
  });
}

/// 模型診斷服務 — 為用戶提供清晰的模型狀態診斷和修復建議
class ModelDiagnosticService {
  final ModelManager modelManager;

  ModelDiagnosticService({required this.modelManager});

  /// 生成完整診斷報告（所有 role）
  Future<List<ModelDiagnosticReport>> generateFullReport() async {
    final reports = <ModelDiagnosticReport>[];
    for (final role in ['transformer', 'statistical', 'adversarial', 'llm']) {
      final report = await generateRoleReport(role);
      reports.add(report);
    }
    return reports;
  }

  /// 為特定 role 生成診斷報告
  Future<ModelDiagnosticReport> generateRoleReport(String role) async {
    final statuses = <ModelStatus>[];
    final recommendations = <String>[];

    final installedVariants = modelManager.installedVariants(role);
    final active = modelManager.activeVariant(role);

    // 已安裝的模型狀態
    for (final variant in installedVariants) {
      final isActive = variant.variantId == active?.variantId;
      final statusLabel = isActive ? '✓ 已安裝（使用中）' : '✓ 已安裝';

      statuses.add(ModelStatus(
        variantId: variant.variantId,
        displayName: variant.displayName,
        statusLabel: statusLabel,
        canRepair: false,
      ));
    }

    // 統計信息
    final totalCount = installedVariants.length;
    final failedCount = 0; // 實際失敗情況由 EngineScore.available 判斷

    // 生成建議
    if (installedVariants.isEmpty) {
      recommendations.add('🔴 此角色無已安裝的模型，分析時會跳過此模型');
      recommendations.add('💡 建議：前往「模型下載」頁面安裝至少一個 $role 模型');
    } else if (installedVariants.length == 1) {
      recommendations.add('⚠️ 只有 1 個模型可用，建議安裝多個變體以提高分析準確性');
    } else {
      recommendations.add('✓ 多個模型可用，分析穩定性良好');
    }

    return ModelDiagnosticReport(
      role: role,
      totalModels: totalCount,
      installableModels: totalCount,
      failedModels: failedCount,
      statuses: statuses,
      recommendations: recommendations,
    );
  }

  /// 生成簡潔的健康檢查摘要
  Future<String> generateHealthCheckSummary() async {
    final reports = await generateFullReport();
    final totalInstalled = reports.fold<int>(
      0,
      (sum, r) => sum + r.installableModels,
    );

    if (totalInstalled == 0) {
      return '❌ 未安裝任何模型，應用無法進行分析';
    } else if (totalInstalled < 3) {
      return '⚠️ 已安裝 $totalInstalled 個模型，建議安裝更多以提高分析可信度';
    } else {
      return '✓ 已安裝 $totalInstalled 個模型，分析準備就緒';
    }
  }
}
