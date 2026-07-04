import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:truthlens/core/services/link_verifier.dart';

void main() {
  group('LinkVerifier.isDoiUrl', () {
    test('doi.org 網址判定為 DOI', () {
      expect(LinkVerifier.isDoiUrl('https://doi.org/10.1038/nphys1170'), isTrue);
      expect(LinkVerifier.isDoiUrl('https://dx.doi.org/10.1000/xyz123'), isTrue);
    });

    test('一般網址不判定為 DOI', () {
      expect(LinkVerifier.isDoiUrl('https://example.com/10.1038/nphys1170'),
          isFalse);
      expect(LinkVerifier.isDoiUrl('https://doi.org/not-a-doi'), isFalse);
    });
  });

  group('LinkVerifier.verifyAll — 期刊文獻目錄核實（DOI → Crossref）', () {
    test('Crossref 查得到 DOI → 標記為期刊目錄已核實，並帶回期刊/篇名', () async {
      final client = MockClient((req) async {
        expect(req.url.host, 'api.crossref.org');
        expect(req.url.path, '/works/10.1038/nphys1170');
        return http.Response(
          jsonEncode({
            'message': {
              'title': ['Some Article Title'],
              'container-title': ['Nature Physics'],
            }
          }),
          200,
        );
      });
      final results = await LinkVerifier.verifyAll(
        ['https://doi.org/10.1038/nphys1170'],
        client: client,
      );
      final r = results.single;
      expect(r.isCitationVerified, isTrue);
      expect(r.status, LinkStatus.reachable);
      expect(r.journalName, 'Nature Physics');
      expect(r.articleTitle, 'Some Article Title');
    });

    test('Crossref 404 → 查無此 DOI 登記，判定為 notFound', () async {
      final client = MockClient((_) async => http.Response('', 404));
      final results = await LinkVerifier.verifyAll(
        ['https://doi.org/10.9999/does-not-exist'],
        client: client,
      );
      final r = results.single;
      expect(r.isCitationVerified, isTrue);
      expect(r.status, LinkStatus.notFound);
    });

    test('非 DOI 網址仍走一般連線可達性檢查（isCitationVerified 為 false）', () async {
      final client = MockClient((_) async => http.Response('', 200));
      final results = await LinkVerifier.verifyAll(
        ['https://example.com/page'],
        client: client,
      );
      expect(results.single.isCitationVerified, isFalse);
    });
  });

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
