import Cocoa
import FlutterMacOS
import Vision

/// macOS 端 OCR 實作，使用 Apple Vision 框架（on-device，無需下載模型）。
/// 註冊於 MainFlutterWindow。契約見 lib/core/services/ocr_service.dart。
enum OcrPlugin {
  static func register(with registrar: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "com.omnitrace/ocr",
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
      guard let observations = req.results as? [VNRecognizedTextObservation], !observations.isEmpty else {
        result("")
        return
      }

      // 按 Y 軸由上至下、X 軸由左至右精準排序，同行片段以半形空格合成分離，杜絕 OCR 連字
      let sortedObs = observations.sorted { (obs1, obs2) -> Bool in
        let yDiff = abs(obs1.boundingBox.midY - obs2.boundingBox.midY)
        let avgHeight = (obs1.boundingBox.height + obs2.boundingBox.height) / 2.0
        if yDiff < avgHeight * 0.6 {
          return obs1.boundingBox.minX < obs2.boundingBox.minX
        }
        return obs1.boundingBox.midY > obs2.boundingBox.midY
      }

      var lines: [[String]] = []
      var prevObsList: [VNRecognizedTextObservation] = []

      for obs in sortedObs {
        guard let cand = obs.topCandidates(1).first?.string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
              !cand.isEmpty else { continue }

        if lines.isEmpty {
          lines.append([cand])
          prevObsList.append(obs)
        } else {
          let prevObs = prevObsList.last!
          let yDiff = abs(obs.boundingBox.midY - prevObs.boundingBox.midY)
          let avgHeight = (obs.boundingBox.height + prevObs.boundingBox.height) / 2.0
          if yDiff < avgHeight * 0.6 {
            lines[lines.count - 1].append(cand)
          } else {
            lines.append([cand])
          }
          prevObsList.append(obs)
        }
      }

      let formattedText = lines.map { $0.joined(separator: " ") }.joined(separator: "\n")
      result(formattedText)
    }
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = false
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
