import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:truthlens/core/services/network_status.dart';

void main() {
  group('NetworkStatus.isOnline', () {
    test('任何非 5xx 回應（含 4xx）皆視為已連線', () async {
      final client = MockClient((_) async => http.Response('', 405));
      expect(await NetworkStatus.isOnline(client: client), isTrue);
    });

    test('200 回應視為已連線', () async {
      final client = MockClient((_) async => http.Response('', 200));
      expect(await NetworkStatus.isOnline(client: client), isTrue);
    });

    test('5xx 伺服器錯誤視為未連線', () async {
      final client = MockClient((_) async => http.Response('', 503));
      expect(await NetworkStatus.isOnline(client: client), isFalse);
    });

    test('連線例外（逾時／DNS 失敗）視為未連線', () async {
      final client = MockClient((_) async => throw Exception('offline'));
      expect(await NetworkStatus.isOnline(client: client), isFalse);
    });
  });
}
