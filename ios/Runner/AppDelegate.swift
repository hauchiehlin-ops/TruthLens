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
