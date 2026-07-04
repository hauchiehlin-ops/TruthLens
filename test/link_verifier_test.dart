import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:truthlens/core/services/link_verifier.dart';

void main() {
  group('LinkVerifier.extractUrls', () {
    test('從文字中抽取網址並依出現順序去重', () {
      final urls = LinkVerifier.extractUrls(
        '參考來源：https://example.com/a 與 https://example.com/b。'
        '另見 https://example.com/a（重複）。',
      );
      expect(urls, ['https://example.com/a', 'https://example.com/b']);
    });

    test('去除網址尾隨的標點符號', () {
      final urls = LinkVerifier.extractUrls(
        '詳見 https://example.com/page。或參考 (https://example.com/other)。',
      );
      expect(urls, ['https://example.com/page', 'https://example.com/other']);
    });

    test('沒有網址時回傳空陣列，不誤判一般文字', () {
      expect(LinkVerifier.extractUrls('這是一段完全沒有連結的文字。'), isEmpty);
    });
  });

  group('LinkVerifier.verifyAll', () {
    test('200 回應判定為 reachable', () async {
      final client = MockClient((_) async => http.Response('', 200));
      final results = await LinkVerifier.verifyAll(
        ['https://example.com/ok'],
        client: client,
      );
      expect(results.single.status, LinkStatus.reachable);
    });

    test('404 回應判定為 notFound', () async {
      final client = MockClient((_) async => http.Response('', 404));
      final results = await LinkVerifier.verifyAll(
        ['https://example.com/missing'],
        client: client,
      );
      expect(results.single.status, LinkStatus.notFound);
    });

    test('連線例外判定為 unreachable', () async {
      final client = MockClient((_) async => throw Exception('network down'));
      final results = await LinkVerifier.verifyAll(
        ['https://example.com/down'],
        client: client,
      );
      expect(results.single.status, LinkStatus.unreachable);
    });

    test('超過上限僅驗證前 maxLinksPerCheck 個連結', () async {
      var callCount = 0;
      final client = MockClient((_) async {
        callCount++;
        return http.Response('', 200);
      });
      final urls = List.generate(30, (i) => 'https://example.com/$i');
      final results = await LinkVerifier.verifyAll(urls, client: client);
      expect(results.length, LinkVerifier.maxLinksPerCheck);
      expect(callCount, LinkVerifier.maxLinksPerCheck);
    });
  });
}
