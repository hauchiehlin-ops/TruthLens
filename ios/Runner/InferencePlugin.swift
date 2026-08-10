import Flutter
import Foundation

/// iOS 原生推論橋接 — 支援 ONNX Runtime + Core ML
/// 呼叫 InferenceHelper (Objective-C++) 進行模型管理與推論
class InferencePlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.truthlens/inference",
      binaryMessenger: registrar.messenger()
    )
    let instance = InferencePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  private let helper = InferenceHelper.sharedInstance()

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ping":
      // 檢查原生推論層是否可用
      result(true)

    case "loadModel":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String,
            let path = args["path"] as? String,
            let backend = args["backend"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少必要參數", details: nil))
        return
      }
      loadModel(modelId: modelId, modelPath: path, backend: backend, result: result)

    case "classify":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String,
            let text = args["text"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少 modelId 或 text", details: nil))
        return
      }
      classify(modelId: modelId, text: text, result: result)

    case "perplexity":
      // 困惑度計算暫不支援
      result(nil)

    case "unload":
      guard let args = call.arguments as? [String: Any],
            let modelId = args["modelId"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少 modelId", details: nil))
        return
      }
      helper?.unload(modelId)
      result(nil)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func loadModel(
    modelId: String,
    modelPath: String,
    backend: String,
    result: @escaping FlutterResult
  ) {
    guard helper != nil else {
      result(FlutterError(code: "no_helper", message: "推論幫助器不可用", details: nil))
      return
    }

    // 檢查是否已載入
    if helper!.isLoaded(modelId) {
      result(true)
      return
    }

    // 查找對應的 tokenizer 檔案
    let appSupport = try? FileManager.default.url(
      for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false
    )
    guard let supportDir = appSupport else {
      result(FlutterError(code: "no_support_dir", message: "無法找到應用支援目錄", details: nil))
      return
    }

    let modelsDir = supportDir.appendingPathComponent("models")
    let tokenizerPath = modelsDir.appendingPathComponent(
      "\(modelId.split(separator: "__").first ?? "unknown")")
      .appendingPathComponent("\(modelId).tokenizer.json"
    ).path

    // 推測 tokenizer 類型（暫簡化，假設 bert-wordpiece）
    let tokenizerType = modelId.contains("roberta") ? "roberta-bpe" : "bert-wordpiece"

    DispatchQueue.global(qos: .userInitiated).async {
      let success = self.helper!.loadModel(
        modelId,
        modelPath: modelPath,
        tokenizerPath: tokenizerPath,
        tokenizerType: tokenizerType
      )
      DispatchQueue.main.async {
        result(success)
      }
    }
  }

  private func classify(
    modelId: String,
    text: String,
    result: @escaping FlutterResult
  ) {
    guard helper != nil else {
      result(FlutterError(code: "no_helper", message: "推論幫助器不可用", details: nil))
      return
    }

    guard helper!.isLoaded(modelId) else {
      result(FlutterError(code: "not_loaded", message: "模型未載入", details: modelId))
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      let prob = self.helper!.classify(modelId, text: text)
      DispatchQueue.main.async {
        result(prob)
      }
    }
  }
}
