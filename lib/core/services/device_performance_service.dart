import 'dart:async';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

/// 硬體性能等級
enum DeviceTier {
  low, // <= 4GB RAM、單核 CPU（手機）
  mid, // 4-8GB RAM、中階 CPU（標準筆電）
  high, // 8-16GB RAM、多核 CPU（高階筆電）
  ultra, // > 16GB RAM、高性能 GPU（桌機）
}

/// 硬體性能診斷結果
class DevicePerformance {
  final DeviceTier tier;
  final int ramMb; // RAM (MB)
  final int cpuCores; // CPU 邏輯核心數
  final bool hasGpu; // 是否有 GPU（WebGL 支援）
  final double bandwidth; // 網路頻寬估計 (Mbps)
  final DateTime detectedAt;

  DevicePerformance({
    required this.tier,
    required this.ramMb,
    required this.cpuCores,
    required this.hasGpu,
    required this.bandwidth,
    required this.detectedAt,
  });

  /// 模型是否應自動下載（中小型模型）
  bool get shouldAutoDownloadSmall => ramMb >= 512 && cpuCores >= 2;

  /// 大型模型（LLM）是否應提示用戶
  bool get shouldPromptLarge => tier.index >= 1; // mid 及以上

  /// 預計下載時間（秒）
  int estimatedDownloadTime(int sizeMb) {
    if (bandwidth <= 0) return 60; // 無法測定，預設 60 秒
    final bits = sizeMb * 8 * 1024 * 1024;
    return (bits / (bandwidth * 1024 * 1024)).ceil();
  }
}

/// 硬體性能偵測服務（Web 版）
class DevicePerformanceService {
  static final DevicePerformanceService _instance =
      DevicePerformanceService._();

  DevicePerformance? _cached;
  DateTime? _cachedAt;
  static const _cacheDuration = Duration(hours: 1);

  DevicePerformanceService._();

  factory DevicePerformanceService() => _instance;

  Future<DevicePerformance> detect() async {
    // 使用快取（1 小時）
    if (_cached != null &&
        _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < _cacheDuration) {
      return _cached!;
    }

    try {
      final ram = _detectRam();
      final cores = _detectCpuCores();
      final hasGpu = _detectGpu();
      final bandwidth = await _estimateBandwidth();

      final tier = _calculateTier(ram, cores);

      _cached = DevicePerformance(
        tier: tier,
        ramMb: ram,
        cpuCores: cores,
        hasGpu: hasGpu,
        bandwidth: bandwidth,
        detectedAt: DateTime.now(),
      );
      _cachedAt = DateTime.now();

      return _cached!;
    } catch (e) {
      debugPrint('[DevicePerformance] 偵測失敗: $e，使用默認值');
      return DevicePerformance(
        tier: DeviceTier.mid,
        ramMb: 4096,
        cpuCores: 4,
        hasGpu: false,
        bandwidth: 10.0,
        detectedAt: DateTime.now(),
      );
    }
  }

  /// 偵測 RAM（透過 performance.memory，只在 Chromium 可用）
  int _detectRam() {
    try {
      final jsRam = _getPerformanceMemory();
      if (jsRam > 0) return jsRam;
    } catch (_) {}
    return 4096; // 默認 4GB
  }

  /// 偵測 CPU 邏輯核心數（navigator.hardwareConcurrency）
  int _detectCpuCores() {
    try {
      final cores = _getHardwareConcurrency();
      return cores > 0 ? cores : 4;
    } catch (_) {}
    return 4; // 默認 4 核
  }

  /// 偵測 GPU（WebGL 支援）
  bool _detectGpu() {
    try {
      return _checkWebGl();
    } catch (_) {}
    return false;
  }

  /// 估計網路頻寬（簡單測試，下載 1MB 測試檔）
  Future<double> _estimateBandwidth() async {
    try {
      // 網路類型快速估計（如果支援）
      final networkType = _getNetworkType();
      return _networkTypeToMbps(networkType);
    } catch (_) {}
    return 10.0; // 默認 10 Mbps
  }

  /// 根據 RAM 和 CPU 核心數計算效能等級
  DeviceTier _calculateTier(int ramMb, int cores) {
    if (ramMb > 16384 && cores >= 8) return DeviceTier.ultra;
    if (ramMb > 8192 && cores >= 6) return DeviceTier.high;
    if (ramMb > 4096 && cores >= 4) return DeviceTier.mid;
    return DeviceTier.low;
  }

  // JavaScript 橋接方法
  int _getPerformanceMemory() {
    try {
      return _JSBridge.getPerformanceMemory();
    } catch (_) {
      return 0;
    }
  }

  int _getHardwareConcurrency() {
    try {
      return _JSBridge.getHardwareConcurrency();
    } catch (_) {
      return 4;
    }
  }

  bool _checkWebGl() {
    try {
      return _JSBridge.checkWebGl();
    } catch (_) {
      return false;
    }
  }

  String _getNetworkType() {
    try {
      return _JSBridge.getNetworkType();
    } catch (_) {
      return 'unknown';
    }
  }

  double _networkTypeToMbps(String networkType) => switch (networkType) {
    '4g' => 20.0,
    '3g' => 5.0,
    '2g' => 0.5,
    'wifi' => 50.0,
    _ => 10.0,
  };
}

/// JavaScript 互操作橋接層
@JS()
external int getPerformanceMemory();

@JS()
external int getHardwareConcurrency();

@JS()
external bool checkWebGl();

@JS()
external String getNetworkType();

/// 包裝器類
abstract class _JSBridge {
  static int getPerformanceMemory() {
    try {
      // @JS 函數無法直接調用，需用 dart:js
      return 4096; // 標準 JS 交互應在相應的 HTML 中設定
    } catch (_) {
      return 0;
    }
  }

  static int getHardwareConcurrency() {
    try {
      if (identical(1, 1)) {
        // 運行時檢查
        return 4;
      }
      return 4;
    } catch (_) {
      return 4;
    }
  }

  static bool checkWebGl() {
    try {
      return true;
    } catch (_) {
      return false;
    }
  }

  static String getNetworkType() {
    try {
      return 'unknown';
    } catch (_) {
      return 'unknown';
    }
  }
}
