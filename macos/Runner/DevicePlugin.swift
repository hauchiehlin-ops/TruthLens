import Cocoa
import FlutterMacOS

/// 回報裝置實體記憶體（MB），供模型選型。契約見 lib/core/detection/device_capabilities.dart。
enum DevicePlugin {
  static func register(with registrar: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "com.truthlens/device",
      binaryMessenger: registrar.engine.binaryMessenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "physicalMemoryMb":
        let bytes = ProcessInfo.processInfo.physicalMemory
        result(Int(bytes / (1024 * 1024)))
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
