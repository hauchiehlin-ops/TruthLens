import 'package:flutter/services.dart';

/// 原生平台 OCR 服務（macOS、iOS、Android、Windows）
///
/// 透過 MethodChannel 呼叫各平台的 on-device 文字辨識：
///   macOS  → Vision 框架（VNRecognizeTextRequest，已實作）
///   iOS    → Vision 框架
///   Android→ ML Kit Text Recognition
///   Windows→ Windows.Media.Ocr
///
/// 原生端未實作的平台會拋 [MissingPluginException]，此處捕捉後回傳 null，
/// UI 顯示「此平台尚未支援 OCR」。
class OcrService {
  static const _channel = MethodChannel('com.truthlens/ocr');

  /// 此平台是否已實作 OCR
  Future<bool> get isSupported async {
    try {
      final ok = await _channel.invokeMethod<bool>('ping');
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 辨識圖片檔中的文字。回傳 null 表示平台不支援或辨識失敗。
  /// [languages] 為 BCP-47 語言提示（如 ['zh-Hant','en-US']），部分平台會參考。
  Future<String?> recognize(String imagePath, {List<String>? languages}) async {
    try {
      return await _channel.invokeMethod<String>('recognize', {
        'path': imagePath,
        'languages': languages ?? const ['zh-Hant', 'zh-Hans', 'en-US'],
      });
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
