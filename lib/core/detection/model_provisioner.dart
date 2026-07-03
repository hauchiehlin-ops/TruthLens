import 'device_capabilities.dart';
import 'model_catalog.dart';
import 'model_catalog_service.dart';
import 'model_manager.dart';

/// 針對某 role 的佈建計畫（含所有可選變體與硬體推薦）
class ProvisionPlan {
  final String role;
  final String roleName;
  final List<ModelVariant> variants; // 該 role 的所有變體（供使用者選擇）
  final ModelVariant? recommended; // 依硬體選出的最適變體（標示為推薦）
  final bool alreadyInstalled;
  final InstalledModel? installed;
  final int deviceRamMb;

  const ProvisionPlan({
    required this.role,
    required this.roleName,
    required this.variants,
    required this.recommended,
    required this.alreadyInstalled,
    required this.deviceRamMb,
    this.installed,
  });

  bool isRecommended(ModelVariant v) => recommended?.id == v.id;

  /// 該變體的硬體是否吃得下（RAM 足夠）
  bool fitsDevice(ModelVariant v) => v.minRamMb <= deviceRamMb;

  /// 需要下載（未安裝且有可下載的推薦變體）
  bool get needsDownload =>
      !alreadyInstalled && recommended != null && recommended!.isDownloadable;
}

/// 模型佈建協調器：結合 catalog + 裝置能力 + 安裝狀態，
/// 供首次啟動 / 設定頁決定「該裝哪個模型」並執行下載。
class ModelProvisioner {
  final ModelCatalogService catalogService;
  final ModelManager modelManager;

  ModelProvisioner({
    required this.catalogService,
    required this.modelManager,
  });

  /// 產生各 role 的佈建計畫（列出所有變體，並標示硬體推薦與安裝狀態）。
  Future<List<ProvisionPlan>> plan(DeviceCapabilities device) async {
    final catalog = await catalogService.load();
    await modelManager.refreshInstallStates();

    final plans = <ProvisionPlan>[];
    for (final model in catalog.models) {
      final best = model.bestFor(device.tier, device.totalRamMb);
      plans.add(ProvisionPlan(
        role: model.role,
        roleName: model.name,
        variants: model.variants,
        recommended: best,
        alreadyInstalled: modelManager.isInstalled(model.role),
        installed: modelManager.installedInfo(model.role),
        deviceRamMb: device.totalRamMb,
      ));
    }
    return plans;
  }

  /// 核心偵測 role（transformer）是否已安裝——用來決定是否需引導 / 再次提示。
  Future<bool> get isCoreDetectorInstalled async {
    await modelManager.refreshInstallStates();
    return modelManager.isInstalled('transformer');
  }

  /// 下載指定 role 的指定變體（使用者在多選項中選擇後呼叫）
  Future<bool> downloadVariant(String role, ModelVariant variant) =>
      modelManager.downloadVariant(role, variant);
}
