import Flutter
import Foundation

/// iOS 原生推論橋接 — 支援 ONNX Runtime + Core ML
///
/// ⚠️ 重要：InferenceHelper.mm 需要被添加到 Xcode Build Phases > Compile Sources
///
/// 當前狀態：占位實作（返回中立值），待 Objective-C++ 整合完成
class InferencePlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.truthlens/inference",
      binaryMessenger: registrar.messenger()
    )
    let instance = InferencePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  // TODO: 當 InferenceHelper.mm 被正確編譯後，啟用下行
  // private let helper = InferenceHelper.sharedInstance()

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ping":
      // 檢查原生推論層是否可用
      result(true)

    case "loadModel":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String,
            let path = args["path"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少必要參數", details: nil))
        return
      }

      // 占位實作：模擬成功載入
      debugPrint("[InferencePlugin] 占位：loadModel \(modelId) from \(path)")
      result(true)

    case "classify":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String,
            let text = args["text"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少 modelId 或 text", details: nil))
        return
      }

      // 占位實作：返回中立值 0.5
      debugPrint("[InferencePlugin] 占位：classify \(modelId) on \(text.prefix(30))...")
      result(0.5)

    case "perplexity":
      // 困惑度計算暫不支援
      result(nil)

    case "unload":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少 modelId", details: nil))
        return
      }

      debugPrint("[InferencePlugin] 占位：unload \(modelId)")
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
