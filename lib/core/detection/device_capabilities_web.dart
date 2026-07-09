import 'dart:js_interop';

import 'model_catalog.dart';

@JS('navigator.hardwareConcurrency')
external JSNumber? get _hardwareConcurrency;

/// 部分瀏覽器（Firefox/Safari）未實作 Device Memory API，讀不到時為 undefined/null。
@JS('navigator.deviceMemory')
external JSNumber? get _deviceMemory;

@JS('navigator.gpu')
external JSAny? get _navigatorGpu;

/// 偵測瀏覽器裝置能力，供方案③的能力分級（快速層／精修層）與 catalog 選型使用。
/// RAM 僅 Chromium 系瀏覽器可透過 `navigator.deviceMemory` 取得概略值（單位 GB，且會
/// 被瀏覽器四捨五入/降級以保護隱私）；讀不到時以核心數保守估算。
class DeviceCapabilities {
  final int totalRamMb;
  final int processors;
  final String platform;
  final bool ramMeasured;
  final bool webGpuAvailable;

  const DeviceCapabilities({
    required this.totalRamMb,
    required this.processors,
    required this.platform,
    required this.ramMeasured,
    this.webGpuAvailable = false,
  });

  static Future<DeviceCapabilities> detect() async {
    final processors = _hardwareConcurrency?.toDartInt ?? 4;
    final memGb = _deviceMemory?.toDartDouble;
    final hasGpu = _navigatorGpu != null;

    return DeviceCapabilities(
      totalRamMb:
          memGb != null ? (memGb * 1024).round() : _estimateRamMb(processors),
      processors: processors,
      platform: 'web',
      ramMeasured: memGb != null,
      webGpuAvailable: hasGpu,
    );
  }

  static int _estimateRamMb(int processors) => processors >= 8 ? 8192 : 4096;

  PerformanceTier get tier {
    if (totalRamMb >= 8192 && processors >= 8) return PerformanceTier.high;
    if (totalRamMb >= 4096) return PerformanceTier.mid;
    return PerformanceTier.low;
  }

  String get summary =>
      'web · $processors 核 · '
      '${(totalRamMb / 1024).toStringAsFixed(totalRamMb % 1024 == 0 ? 0 : 1)}GB RAM'
      '${ramMeasured ? '' : '（估算）'} · ${tier.name} tier'
      '${webGpuAvailable ? ' · WebGPU' : ''}';
}
