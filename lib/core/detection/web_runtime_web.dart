import 'dart:js_interop';

@JS('navigator.userAgent')
external JSString? get _userAgent;

@JS('navigator.platform')
external JSString? get _platform;

@JS('navigator.maxTouchPoints')
external JSNumber? get _maxTouchPoints;

/// iOS 上的所有瀏覽器都由 WebKit 驅動；ONNX/WASM 長時間推論時，比桌面更容易
/// 因同時載入多個模型而被系統終止分頁。這個旗標只調整排程，不改變啟用引擎。
bool get isConstrainedMobileWebRuntime {
  final userAgent = _userAgent?.toDart ?? '';
  final platform = _platform?.toDart ?? '';
  final touchPoints = _maxTouchPoints?.toDartInt ?? 0;

  return RegExp(r'iPad|iPhone|iPod').hasMatch(userAgent) ||
      (platform == 'MacIntel' && touchPoints > 1);
}
