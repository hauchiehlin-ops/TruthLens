import 'device_capabilities.dart';
import 'model_catalog.dart';
import 'model_catalog_service.dart';
import 'model_manager.dart';

/// 針對某 role 的佈建建議
class ProvisionPlan {
  final String role;
  final String roleName;
  final ModelVariant? recommended; // 依硬體選出的最適變體
  final bool alreadyInstalled;
  final InstalledModel? installed;

  const ProvisionPlan({
    required this.role,
    required this.roleName,
    required this.recommended,
    required this.alreadyInstalled,
    this.installed,
  });

  /// 需要下載（未安裝且有可下載的推薦變體）
  bool get needsDownload =>
      !alreadyInstalled && recommended != null && recommended!.isDownloadable;
}

/// 模型佈建協調器：結合 catalog + 裝置能力 + 安裝狀態，
/// 於首次啟動決定「該裝哪個模型」並執行下載。
class ModelProvisioner {
  final ModelCatalogService catalogService;
  final ModelManager modelManager;

  ModelProvisioner({
    required this.catalogService,
    required this.modelManager,
  });

  /// 產生各 role 的佈建計畫（依裝置能力挑最適變體，並標示是否已安裝）。
  Future<List<ProvisionPlan>> plan(DeviceCapabilities device) async {
    final catalog = await catalogService.load();
    await modelManager.refreshInstallStates();

    final plans = <ProvisionPlan>[];
    for (final model in catalog.models) {
      final best = model.bestFor(device.tier, device.totalRamMb);
      plans.add(ProvisionPlan(
        role: model.role,
        roleName: model.name,
        recommended: best,
        alreadyInstalled: modelManager.isInstalled(model.role),
        installed: modelManager.installedInfo(model.role),
      ));
    }
    return plans;
  }

  /// 核心偵測 role（transformer）是否已安裝——首次啟動用來決定是否進入引導。
  Future<bool> get isCoreDetectorInstalled async {
    await modelManager.refreshInstallStates();
    return modelManager.isInstalled('transformer');
  }

  /// 下載某計畫的推薦變體
  Future<bool> download(ProvisionPlan plan) async {
    final v = plan.recommended;
    if (v == null) return false;
    return modelManager.downloadVariant(plan.role, v);
  }
}
