import Cocoa
import FlutterMacOS
import Vision

/// macOS 端 OCR 實作，使用 Apple Vision 框架（on-device，無需下載模型）。
/// 註冊於 MainFlutterWindow。契約見 lib/core/services/ocr_service.dart。
enum OcrPlugin {
  static func register(with registrar: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "com.truthlens/ocr",
      binaryMessenger: registrar.engine.binaryMessenger)

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "ping":
        result(true)
      case "recognize":
        guard let args = call.arguments as? [String: Any],
          let path = args["path"] as? String
        else {
          result(FlutterError(code: "bad_args", message: "缺少 path", details: nil))
          return
        }
        let languages = args["languages"] as? [String]
        recognize(path: path, languages: languages, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func recognize(
    path: String, languages: [String]?, result: @escaping FlutterResult
  ) {
    guard let image = NSImage(contentsOfFile: path),
      let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)
    else {
      result(FlutterError(code: "load_failed", message: "無法載入圖片", details: path))
      return
    }

    let request = VNRecognizeTextRequest { req, err in
      if let err = err {
        result(FlutterError(code: "ocr_failed", message: err.localizedDescription, details: nil))
        return
      }
      let observations = req.results as? [VNRecognizedTextObservation] ?? []
      let text = observations
        .compactMap { $0.topCandidates(1).first?.string }
        .joined(separator: "\n")
      result(text)
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    if let languages = languages {
      request.recognitionLanguages = languages
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try handler.perform([request])
      } catch {
        result(FlutterError(code: "ocr_failed", message: error.localizedDescription, details: nil))
      }
    }
  }
}
