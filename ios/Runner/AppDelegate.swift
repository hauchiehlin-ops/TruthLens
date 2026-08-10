import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let registrar = self.registrar(forPlugin: "OcrPlugin")
    if let reg = registrar {
      OcrPlugin.register(with: reg)
      DevicePlugin.register(with: reg)
      InferencePlugin.register(with: reg)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

class OcrPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.truthlens/ocr",
      binaryMessenger: registrar.messenger()
    )
    let instance = OcrPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "ping":
      result(true)
    case "recognize":
      guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String else {
        result(FlutterError(code: "bad_args", message: "缺少 path", details: nil))
        return
      }
      let languages = args["languages"] as? [String]
      recognize(path: path, languages: languages, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func recognize(path: String, languages: [String]?, result: @escaping FlutterResult) {
    guard let image = UIImage(contentsOfFile: path),
          let cgImage = image.cgImage else {
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

      // 按 Y 軸由上至下、X 軸由左至右精準排序，同行片段以空格合成分離
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

class DevicePlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "com.truthlens/device",
      binaryMessenger: registrar.messenger()
    )
    let instance = DevicePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "physicalMemoryMb":
      let bytes = ProcessInfo.processInfo.physicalMemory
      result(Int(bytes / (1024 * 1024)))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
