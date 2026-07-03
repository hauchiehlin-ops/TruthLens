import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/ocr_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('com.truthlens/ocr');
  final service = OcrService();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('無原生實作時 isSupported 為 false', () async {
    // 預設無 handler → MissingPluginException → 優雅回退
    expect(await service.isSupported, isFalse);
  });

  test('無原生實作時 recognize 回傳 null', () async {
    expect(await service.recognize('/tmp/x.png'), isNull);
  });

  test('原生就緒時透傳辨識結果', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'ping') return true;
      if (call.method == 'recognize') return '辨識文字 recognized';
      return null;
    });
    expect(await service.isSupported, isTrue);
    expect(await service.recognize('/tmp/x.png'), '辨識文字 recognized');
  });

  test('原生拋 PlatformException 時回傳 null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'ocr_failed');
    });
    expect(await service.recognize('/tmp/x.png'), isNull);
  });
}
