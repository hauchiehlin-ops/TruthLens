import 'dart:io';

import 'package:flutter/services.dart';

import 'model_catalog.dart';

/// 偵測裝置硬體能力，供 catalog 選出最適模型變體。
/// RAM 由原生端提供（macOS 已實作 DevicePlugin）；取不到時以 CPU 核心數與平台估算。
class DeviceCapabilities {
  static const _channel = MethodChannel('com.truthlens/device');

  final int totalRamMb;
  final int processors;
  final String platform;
  final bool ramMeasured; // false = 估算值

  const DeviceCapabilities({
    required this.totalRamMb,
    required this.processors,
    required this.platform,
    required this.ramMeasured,
  });

  static Future<DeviceCapabilities> detect() async {
    final processors = Platform.numberOfProcessors;
    final platform = Platform.operatingSystem;

    int? ram;
    try {
      ram = await _channel.invokeMethod<int>('physicalMemoryMb');
    } on MissingPluginException {
      ram = null;
    } catch (_) {
      ram = null;
    }

    return DeviceCapabilities(
      totalRamMb: ram ?? _estimateRamMb(processors, platform),
      processors: processors,
      platform: platform,
      ramMeasured: ram != null,
    );
  }

  /// 無原生 RAM 讀數時的保守估算（寧可低估以避免推薦過重的模型）
  static int _estimateRamMb(int processors, String platform) {
    if (platform == 'ios' || platform == 'android') {
      return processors >= 8 ? 6144 : 3072; // 行動裝置保守估
    }
    return processors >= 8 ? 16384 : 8192; // 桌面
  }

  PerformanceTier get tier {
    if (totalRamMb >= 8192 && processors >= 8) return PerformanceTier.high;
    if (totalRamMb >= 4096) return PerformanceTier.mid;
    return PerformanceTier.low;
  }

  String get summary =>
      '$platform · $processors 核 · '
      '${(totalRamMb / 1024).toStringAsFixed(totalRamMb % 1024 == 0 ? 0 : 1)}GB RAM'
      '${ramMeasured ? '' : '（估算）'} · ${tier.name} tier';
}
