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


/// 某個變體在建議套組中的處置。被排除時要說得出理由——
/// 只列「建議下載這些」而不說為什麼漏掉某項，使用者無從判斷該不該手動補。
enum BundleDecision {
  /// 建議下載
  include,

  /// 裝置 RAM 不足以載入
  skipRam,

  /// 瀏覽器可用儲存空間放不下
  skipStorage,

  /// 放得下但非必要（報告用 LLM 不影響判讀結果）
  skipOptional,
}

class BundleEntry {
  final String role;
  final String roleName;
  final ModelVariant variant;
  final BundleDecision decision;

  const BundleEntry({
    required this.role,
    required this.roleName,
    required this.variant,
    required this.decision,
  });

  bool get included => decision == BundleDecision.include;
}

/// 依裝置 RAM 與瀏覽器實際可用配額算出的建議下載套組。
///
/// 為什麼需要總量而不只是逐 role 推薦：模型放在 OPFS，配額是可用磁碟的一個
/// 比例而非固定值。逐項看每顆都「放得下」，全部加起來卻可能爆掉——完整 catalog
/// 約 2.6 GB，在配額 4 GB 的機器上就佔掉六成以上。
class RecommendedBundle {
  final List<BundleEntry> entries;
  final int deviceRamMb;

  /// 瀏覽器回報的可用空間；未知時為 null（原生端恆為 null）。
  final int? storageAvailableBytes;

  /// 已下載的模型是否免於瀏覽器自動回收。
  final bool storagePersisted;

  const RecommendedBundle({
    required this.entries,
    required this.deviceRamMb,
    required this.storageAvailableBytes,
    required this.storagePersisted,
  });

  List<BundleEntry> get included =>
      [for (final e in entries) if (e.included) e];

  List<BundleEntry> get excluded =>
      [for (final e in entries) if (!e.included) e];

  /// 建議下載的顆數
  int get count => included.length;

  /// 建議下載的合計位元組
  int get totalBytes =>
      included.fold(0, (sum, e) => sum + e.variant.sizeBytes);

  /// 下載完之後預估仍剩多少空間；配額未知時為 null。
  int? get remainingBytes {
    final available = storageAvailableBytes;
    return available == null ? null : available - totalBytes;
  }
}

/// 模型佈建協調器：結合 catalog + 裝置能力，產生各 role 的選型計畫。
class ModelProvisioner {
  final ModelCatalogService catalogService;
  final ModelManager modelManager;

  ModelProvisioner({required this.catalogService, required this.modelManager});

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


  /// 依優先序排出建議套組。
  ///
  /// 優先序按「每 MB 換到多少判讀能力」排：transformer 是核心（權重 40%），
  /// statistical 的輕量變體只要 78 MB 就換到 25% 權重，是全 catalog 最划算的一顆，
  /// adversarial 次之；報告用 LLM 要 1.6 GB 且完全不影響判讀結論，永遠排最後。
  ///
  /// [languageCode] 指定時會為該語言補上專用變體——中文文件若只裝多語模型，
  /// 分析當下才會被提示缺模型，不如在這裡就一起建議。
  Future<RecommendedBundle> recommendBundle(
    DeviceCapabilities device, {
    String? languageCode,
  }) async {
    final catalog = await catalogService.load();
    const priority = ['transformer', 'statistical', 'adversarial', 'llm'];
    // 只用掉七成可用空間：歷史紀錄與其他 origin 資料也共用同一份配額，
    // 而且用滿反而提高被瀏覽器回收的機率。
    final available = device.storageAvailableBytes;
    var budget = available == null ? null : (available * 0.7).round();

    final entries = <BundleEntry>[];
    for (final role in priority) {
      final model = catalog.forRole(role);
      if (model == null) continue;

      final candidates = <ModelVariant>[];
      final best = model.bestFor(device.tier, device.totalRamMb);
      if (best != null) candidates.add(best);
      if (role == 'transformer' && languageCode != null) {
        for (final v in model.variants) {
          if (v.id != best?.id && v.languages.contains(languageCode)) {
            candidates.add(v);
          }
        }
      }

      for (final variant in candidates) {
        if (variant.minRamMb > device.totalRamMb) {
          entries.add(_entry(role, model.name, variant, BundleDecision.skipRam));
          continue;
        }
        if (role == 'llm') {
          entries.add(
            _entry(role, model.name, variant, BundleDecision.skipOptional),
          );
          continue;
        }
        if (budget != null && variant.sizeBytes > budget) {
          entries.add(
            _entry(role, model.name, variant, BundleDecision.skipStorage),
          );
          continue;
        }
        if (budget != null) budget -= variant.sizeBytes;
        entries.add(_entry(role, model.name, variant, BundleDecision.include));
      }
    }

    return RecommendedBundle(
      entries: entries,
      deviceRamMb: device.totalRamMb,
      storageAvailableBytes: available,
      storagePersisted: device.storagePersisted,
    );
  }

  BundleEntry _entry(
    String role,
    String roleName,
    ModelVariant variant,
    BundleDecision decision,
  ) => BundleEntry(
    role: role,
    roleName: roleName,
    variant: variant,
    decision: decision,
  );

  /// 核心偵測 role 是否已安裝——決定是否需引導 / 再次提示。
  Future<bool> get isCoreDetectorInstalled async {
    await modelManager.refreshInstallStates();
    return modelManager.isInstalled('transformer');
  }

  Future<bool> downloadVariant(String role, ModelVariant variant) =>
      modelManager.downloadVariant(role, variant);
}
