import Flutter
import CoreML
import Foundation

/// iOS 原生推論橋接 — 支援 ONNX 和 Core ML 推論
/// 契約：loadModel, classify, perplexity, unload
class InferencePlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.truthlens/inference",
      binaryMessenger: registrar.messenger()
    )
    let instance = InferencePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private let onnxHelper = OnnxInferenceHelper()
  private var loadedModels: [String: MLModel] = [:]

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ping":
      result(true)

    case "loadModel":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String,
            let path = args["path"] as? String,
            let backend = args["backend"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少必要參數", details: nil))
        return
      }
      loadModel(modelId: modelId, path: path, backend: backend, result: result)

    case "classify":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String,
            let text = args["text"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少 modelId 或 text", details: nil))
        return
      }
      classify(modelId: modelId, text: text, result: result)

    case "perplexity":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String,
            let text = args["text"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少 modelId 或 text", details: nil))
        return
      }
      perplexity(modelId: modelId, text: text, result: result)

    case "unload":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少 modelId", details: nil))
        return
      }
      unload(modelId: modelId)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func loadModel(
    modelId: String,
    path: String,
    backend: String,
    result: @escaping FlutterResult
  ) {
    let fileURL = URL(fileURLWithPath: path)

    // 檢查是否已載入
    if loadedModels[modelId] != nil || onnxHelper.isLoaded(modelId) {
      result(true)
      return
    }

    do {
      // 嘗試載入 Core ML 模型
      if path.hasSuffix(".mlmodel") {
        let model = try MLModel(contentsOf: fileURL)
        loadedModels[modelId] = model
        result(true)
      } else if path.hasSuffix(".onnx") {
        // 使用 ONNX Runtime 推論幫助類
        let success = onnxHelper.loadModel(modelPath: path, modelId: modelId)
        result(success)
      } else {
        result(false)
      }
    } catch {
      print("[Inference] 載入模型失敗: \(error.localizedDescription)")
      result(false)
    }
  }

  private func classify(
    modelId: String,
    text: String,
    result: @escaping FlutterResult
  ) {
    // 優先檢查 ONNX 模型
    if let prob = onnxHelper.classify(modelId: modelId, text: text) {
      result(prob)
      return
    }

    // 再檢查 Core ML 模型
    guard let model = loadedModels[modelId] else {
      result(FlutterError(code: "not_loaded", message: "模型未載入", details: modelId))
      return
    }

    do {
      // 簡化實作：暫時回傳 0.5（待實現具體推論邏輯）
      result(0.5)
    } catch {
      result(FlutterError(code: "inference_failed", message: error.localizedDescription, details: nil))
    }
  }

  private func perplexity(
    modelId: String,
    text: String,
    result: @escaping FlutterResult
  ) {
    // 困惑度計算：暫不支援
    if let prob = onnxHelper.perplexity(modelId: modelId, text: text) {
      result(prob)
    } else {
      result(nil)
    }
  }

  private func unload(modelId: String) {
    loadedModels.removeValue(forKey: modelId)
    onnxHelper.unload(modelId: modelId)
  }
}
