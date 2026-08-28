import 'dart:js_interop';

import 'model_catalog.dart';

@JS('navigator.hardwareConcurrency')
external JSNumber? get _hardwareConcurrency;

/// 部分瀏覽器（Firefox/Safari）未實作 Device Memory API，讀不到時為 undefined/null。
@JS('navigator.deviceMemory')
external JSNumber? get _deviceMemory;

@JS('navigator.gpu')
external JSAny? get _navigatorGpu;

@JS('navigator.storage')
external _StorageManager? get _storage;

extension type _StorageManager._(JSObject _) implements JSObject {
  external JSPromise<_StorageEstimate> estimate();
  external JSPromise<JSBoolean> persisted();
  external JSPromise<JSBoolean> persist();
}

extension type _StorageEstimate._(JSObject _) implements JSObject {
  external JSNumber? get quota;
  external JSNumber? get usage;
}

/// 偵測瀏覽器裝置能力，供方案③的能力分級（快速層／精修層）與 catalog 選型使用。
/// RAM 僅 Chromium 系瀏覽器可透過 `navigator.deviceMemory` 取得概略值（單位 GB，且會
/// 被瀏覽器四捨五入/降級以保護隱私）；讀不到時以核心數保守估算。
///
/// 儲存空間同樣重要：模型放在 OPFS，而 origin 配額是可用磁碟的一個比例，並非固定值。
/// 沒有取得持久化授權時，瀏覽器在磁碟壓力下可以直接清掉已下載的模型，使用者就得重載。
class DeviceCapabilities {
  final int totalRamMb;
  final int processors;
  final String platform;
  final bool ramMeasured;
  final bool webGpuAvailable;

  /// 此 origin 的儲存配額與已用量（位元組）。瀏覽器不提供時為 null。
  final int? storageQuotaBytes;
  final int? storageUsageBytes;

  /// 是否已取得持久化授權。false 代表已下載的模型可能被瀏覽器回收。
  final bool storagePersisted;

  const DeviceCapabilities({
    required this.totalRamMb,
    required this.processors,
    required this.platform,
    required this.ramMeasured,
    this.webGpuAvailable = false,
    this.storageQuotaBytes,
    this.storageUsageBytes,
    this.storagePersisted = false,
  });

  static Future<DeviceCapabilities> detect() async {
    final processors = _hardwareConcurrency?.toDartInt ?? 4;
    final memGb = _deviceMemory?.toDartDouble;
    final hasGpu = _navigatorGpu != null;

    int? quota;
    int? usage;
    var persisted = false;
    final storage = _storage;
    if (storage != null) {
      try {
        final estimate = await storage.estimate().toDart;
        quota = estimate.quota?.toDartInt;
        usage = estimate.usage?.toDartInt;
      } catch (_) {
        // Storage API 不可用（舊瀏覽器 / 隱私模式）→ 當作未知，不阻擋流程。
      }
      try {
        persisted = (await storage.persisted().toDart).toDart;
      } catch (_) {
        persisted = false;
      }
    }

    return DeviceCapabilities(
      totalRamMb: memGb != null
          ? (memGb * 1024).round()
          : _estimateRamMb(processors),
      processors: processors,
      platform: 'web',
      ramMeasured: memGb != null,
      webGpuAvailable: hasGpu,
      storageQuotaBytes: quota,
      storageUsageBytes: usage,
      storagePersisted: persisted,
    );
  }

  /// 向瀏覽器申請持久化儲存，讓已下載的模型不被自動回收。
  ///
  /// Chromium 依使用者互動程度自行決定是否給予，不會跳出提示；Safari 只在網站被
  /// 加入主畫面時給予。回傳 false 不是錯誤，只代表模型仍可能在磁碟壓力下被清掉。
  static Future<bool> requestPersistentStorage() async {
    final storage = _storage;
    if (storage == null) return false;
    try {
      return (await storage.persist().toDart).toDart;
    } catch (_) {
      return false;
    }
  }

  static int _estimateRamMb(int processors) => processors >= 8 ? 8192 : 4096;

  PerformanceTier get tier {
    if (totalRamMb >= 8192 && processors >= 8) return PerformanceTier.high;
    if (totalRamMb >= 4096) return PerformanceTier.mid;
    return PerformanceTier.low;
  }

  /// 還能再放多少位元組。配額未知時回傳 null——未知不等於零，呼叫端不該因此擋下載。
  int? get storageAvailableBytes {
    final quota = storageQuotaBytes;
    if (quota == null) return null;
    final used = storageUsageBytes ?? 0;
    final free = quota - used;
    return free > 0 ? free : 0;
  }

  String get summary =>
      'web · $processors 核 · '
      '${(totalRamMb / 1024).toStringAsFixed(totalRamMb % 1024 == 0 ? 0 : 1)}GB RAM'
      '${ramMeasured ? '' : '（估算）'} · ${tier.name} tier'
      '${webGpuAvailable ? ' · WebGPU' : ''}';
}
