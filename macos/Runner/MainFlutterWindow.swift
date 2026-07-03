import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // TruthLens 原生外掛
    OcrPlugin.register(with: flutterViewController)
    DevicePlugin.register(with: flutterViewController)

    super.awakeFromNib()
  }
}
