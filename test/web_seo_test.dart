import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web entry exposes indexable metadata and structured content', () {
    final html = File('web/index.html').readAsStringSync();

    expect(html, contains('<html lang="zh-Hant">'));
    expect(html, contains('name="viewport"'));
    expect(html, contains('viewport-fit=cover'));
    expect(html, contains('name="description"'));
    expect(html, contains('name="robots" content="index, follow'));
    expect(
      html,
      contains(
        '<link rel="canonical" href="https://truth-lens-roan-three.vercel.app/">',
      ),
    );
    expect(html, contains('property="og:title"'));
    expect(html, contains('<main id="seo-shell">'));
    expect(html, contains('<h1 id="seo-title"'));

    final match = RegExp(
      r'<script type="application/ld\+json">\s*([\s\S]*?)\s*</script>',
    ).firstMatch(html);
    expect(match, isNotNull);
    final structuredData = jsonDecode(match!.group(1)!) as Map<String, dynamic>;
    expect(structuredData['@type'], 'WebApplication');
    expect(structuredData['name'], 'TruthLens');
    expect(structuredData['featureList'], isNotEmpty);
  });

  test('robots and sitemap expose only the canonical application URL', () {
    final robots = File('web/robots.txt').readAsStringSync();
    final sitemap = File('web/sitemap.xml').readAsStringSync();

    expect(robots, contains('Allow: /'));
    expect(
      robots,
      contains('Sitemap: https://truth-lens-roan-three.vercel.app/sitemap.xml'),
    );
    expect(
      sitemap,
      contains('<loc>https://truth-lens-roan-three.vercel.app/</loc>'),
    );
  });

  test('Vercel serves static SEO files before the Flutter fallback', () {
    for (final path in ['vercel.json', 'web/vercel.json']) {
      final config =
          jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
      final routes = config['routes'] as List<dynamic>;
      final filesystemIndex = routes.indexWhere(
        (route) => (route as Map<String, dynamic>)['handle'] == 'filesystem',
      );
      final fallbackIndex = routes.indexWhere(
        (route) => (route as Map<String, dynamic>)['dest'] == '/index.html',
      );
      expect(filesystemIndex, greaterThanOrEqualTo(0));
      expect(filesystemIndex, lessThan(fallbackIndex));
    }
  });

  test(
    'web bootstrap removes legacy workers without registering a new one',
    () {
      final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();

      expect(bootstrap, isNot(contains('flutter_service_worker_version')));
      expect(bootstrap, isNot(contains('serviceWorkerSettings:')));
      expect(bootstrap, contains('navigator.serviceWorker.getRegistrations()'));
      expect(bootstrap, contains('registration.unregister()'));
      expect(bootstrap, contains('truthlens-worker-cleanup-v1'));
      expect(bootstrap, contains('window.sessionStorage'));
      expect(bootstrap, contains('window.caches.delete(name)'));
      expect(bootstrap, isNot(contains('navigator.serviceWorker.register(')));
    },
  );

  test('web startup shell exposes an accessible retry state', () {
    final html = File('web/index.html').readAsStringSync();
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();

    expect(html, contains('class="seo-shell__status" role="status"'));
    expect(html, contains('#seo-shell-retry'));
    expect(bootstrap, contains('showTruthLensStartupFailure'));
    expect(bootstrap, contains('retry.type = "button"'));
    expect(bootstrap, contains('window.location.reload()'));
  });
}
