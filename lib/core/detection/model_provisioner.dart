import 'device_capabilities.dart';
import 'model_catalog.dart';
import 'model_catalog_service.dart';
import 'model_manager.dart';

/// 針對某 role 的佈建計畫（含所有可選變體與硬體推薦）。
/// 安裝 / 使用中狀態由 UI 即時向 [ModelManager] 查詢，不快取於此。
class ProvisionPlan {
  final String role;
  final String roleName;
  final List<ModelVariant> variants; // 該 role 的所有變體（供使用者選擇）
  final ModelVariant? recommended; // 依硬體選出的最適變體（標示為推薦）
  final int deviceRamMb;

  const ProvisionPlan({
    required this.role,
    required this.roleName,
    required this.variants,
    required this.recommended,
    required this.deviceRamMb,
  });

  bool isRecommended(ModelVariant v) => recommended?.id == v.id;

  /// 該變體的硬體是否吃得下（RAM 足夠）
  bool fitsDevice(ModelVariant v) => v.minRamMb <= deviceRamMb;
}

/// 模型佈建協調器：結合 catalog + 裝置能力，產生各 role 的選型計畫。
class ModelProvisioner {
  final ModelCatalogService catalogService;
  final ModelManager modelManager;

  ModelProvisioner({
    required this.catalogService,
    required this.modelManager,
  });

  Future<List<ProvisionPlan>> plan(DeviceCapabilities device) async {
    final catalog = await catalogService.load();
    await modelManager.refreshInstallStates();
    return [
      for (final model in catalog.models)
        ProvisionPlan(
          role: model.role,
          roleName: model.name,
          variants: model.variants,
          recommended: model.bestFor(device.tier, device.totalRamMb),
          deviceRamMb: device.totalRamMb,
        ),
    ];
  }

  /// 核心偵測 role 是否已安裝——決定是否需引導 / 再次提示。
  Future<bool> get isCoreDetectorInstalled async {
    await modelManager.refreshInstallStates();
    return modelManager.isInstalled('transformer');
  }

  Future<bool> downloadVariant(String role, ModelVariant variant) =>
      modelManager.downloadVariant(role, variant);
}
