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
    expect(html, contains('data-home-language'));
    expect(html, contains('data-home-lead'));
    expect(html, contains('data-home-feature'));
    expect(html, contains('data-home-card-link'));
    expect(html, contains('seo/home_i18n.js'));
    expect(html, contains('<h1 id="seo-title"'));
    expect(html, contains('aria-label="公開工具與指南"'));
    expect(html, contains('id="seo-shell-start"'));
    expect(html, contains('href="/?workspace=1"'));

    final match = RegExp(
      r'<script type="application/ld\+json">\s*([\s\S]*?)\s*</script>',
    ).firstMatch(html);
    expect(match, isNotNull);
    final structuredData = jsonDecode(match!.group(1)!) as Map<String, dynamic>;
    expect(structuredData['@type'], 'WebApplication');
    expect(structuredData['name'], 'TruthLens');
    expect(structuredData['featureList'], isNotEmpty);
  });

  test('robots and sitemap expose public SEO entry points', () {
    final robots = File('web/robots.txt').readAsStringSync();
    final sitemap = File('web/sitemap.xml').readAsStringSync();
    const publicRoutes = [
      'https://truth-lens-roan-three.vercel.app/',
      'https://truth-lens-roan-three.vercel.app/free-ai-detector',
      'https://truth-lens-roan-three.vercel.app/zh/ai-article-detector',
      'https://truth-lens-roan-three.vercel.app/privacy/local-ai-detector-vs-cloud-upload',
      'https://truth-lens-roan-three.vercel.app/formats/pdf-ai-detection-limitations',
      'https://truth-lens-roan-three.vercel.app/formats/docx-editing-history-ai-evidence',
      'https://truth-lens-roan-three.vercel.app/ai-writing-signs/low-burstiness',
      'https://truth-lens-roan-three.vercel.app/ai-writing-signs/fake-citations',
    ];

    expect(robots, contains('Allow: /'));
    expect(
      robots,
      contains('Sitemap: https://truth-lens-roan-three.vercel.app/sitemap.xml'),
    );
    for (final route in publicRoutes) {
      expect(sitemap, contains('<loc>$route</loc>'));
    }
    expect(sitemap, contains('<lastmod>2026-09-01</lastmod>'));
  });

  test('root SEO shell links to crawlable public landing pages', () {
    final html = File('web/index.html').readAsStringSync();

    expect(html, contains('href="/zh/ai-article-detector"'));
    expect(html, contains('href="/free-ai-detector"'));
    expect(html, contains('href="/privacy/local-ai-detector-vs-cloud-upload"'));
    expect(html, contains('href="/formats/pdf-ai-detection-limitations"'));
    expect(html, contains('href="/formats/docx-editing-history-ai-evidence"'));
    expect(html, contains('href="/ai-writing-signs/low-burstiness"'));
    expect(html, contains('href="/ai-writing-signs/fake-citations"'));
  });

  test('free detector pages are static, indexable, and privacy preserving', () {
    const pages = [
      'web/free-ai-detector.html',
      'web/zh/ai-article-detector.html',
    ];

    for (final page in pages) {
      final html = File(page).readAsStringSync();

      expect(html, contains('name="description"'));
      expect(html, contains('name="robots" content="index, follow'));
      expect(html, contains('<link rel="canonical"'));
      expect(html, contains('<script type="application/ld+json">'));
      expect(html, contains('<h1>'));
      expect(html, contains('data-detector-input'));
      expect(html, contains('data-detector-run'));
      expect(html, contains('data-word-count'));
      expect(html, contains('/seo/page_i18n.js'));
      expect(html, contains('/seo/free_detector.js'));
      expect(html, isNot(contains('flutter_bootstrap.js')));
    }

    final detectorScript = File('web/seo/free_detector.js').readAsStringSync();
    expect(detectorScript, isNot(contains('fetch(')));
    expect(detectorScript, isNot(contains('XMLHttpRequest')));
    expect(detectorScript, isNot(contains('sendBeacon')));
    expect(detectorScript, isNot(contains('WebSocket')));
  });

  test('programmatic SEO articles are useful static pages with app links', () {
    const pages = [
      'web/privacy/local-ai-detector-vs-cloud-upload.html',
      'web/formats/pdf-ai-detection-limitations.html',
      'web/formats/docx-editing-history-ai-evidence.html',
      'web/ai-writing-signs/low-burstiness.html',
      'web/ai-writing-signs/fake-citations.html',
    ];

    for (final page in pages) {
      final html = File(page).readAsStringSync();

      expect(html, contains('<meta name="description"'));
      expect(html, contains('<link rel="canonical"'));
      expect(html, contains('<script type="application/ld+json">'));
      expect(html, contains('"@type": "Article"'));
      expect(html, contains('/seo/page_i18n.js'));
      expect(html, contains('href="/free-ai-detector"'));
      expect(html, contains('href="/"'));
      expect(html, isNot(contains('flutter_bootstrap.js')));
    }
  });

  test('public static pages can render in the app-selected locale', () {
    final i18n = File('web/seo/page_i18n.js').readAsStringSync();
    final homeI18n = File('web/seo/home_i18n.js').readAsStringSync();

    for (final locale in [
      'zh-Hant',
      'zh-Hans',
      'en',
      'ja',
      'ko',
      'th',
      'ms',
      'es',
      'id',
      'ru',
      'de',
      'fr',
      'pt',
    ]) {
      expect(i18n, contains("lang: '$locale'"));
      expect(homeI18n, contains("'$locale'"));
    }
    expect(i18n, contains("new URLSearchParams(window.location.search"));
    expect(i18n, contains("params.get('lang')"));
    expect(
      i18n,
      contains("window.localStorage.getItem('truthlens-public-lang')"),
    );
    expect(
      i18n,
      contains("window.localStorage.setItem('truthlens-public-lang'"),
    );
    expect(i18n, contains("renderLanguagePicker(pack.lang)"));
    expect(i18n, contains("workspace=1&lang="));
    expect(i18n, contains('document.documentElement.lang = pack.lang'));
    expect(i18n, contains('document.title = page[0]'));
    expect(
      homeI18n,
      contains("window.localStorage.getItem('truthlens-public-lang')"),
    );
    expect(homeI18n, contains("data-home-language"));
    expect(homeI18n, contains("data-home-card-link"));
    expect(homeI18n, contains("workspace=1&lang="));
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

  test('web bootstrap removes legacy workers and registers only its own', () {
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();

    // Flutter 產生的 worker 會反註冊自己並導航所有 client，在 Android Chrome
    // 造成重整迴圈。它永遠不該被接回來。
    expect(bootstrap, isNot(contains('flutter_service_worker_version')));
    expect(bootstrap, isNot(contains('serviceWorkerSettings:')));
    expect(bootstrap, contains('navigator.serviceWorker.getRegistrations()'));
    expect(bootstrap, contains('registration.unregister()'));
    expect(bootstrap, contains('truthlens-worker-cleanup-v2'));
    expect(bootstrap, contains('truthlens-worker-migration-v2'));
    expect(bootstrap, contains('window.localStorage'));
    expect(bootstrap, contains('window.sessionStorage'));
    expect(bootstrap, contains('window.caches.delete(name)'));

    // 自有 worker 是「可安裝」的前提，Chromium 沒有它就不派送
    // beforeinstallprompt，安裝按鈕永遠不會出現。
    expect(
      bootstrap,
      contains('navigator.serviceWorker.register(truthLensWorkerScript)'),
    );
    expect(
      bootstrap,
      contains('const truthLensWorkerScript = "truthlens_sw.js"'),
    );
    // 清理邏輯必須放過自有 worker 與其快取，否則每次載入都會把它清掉。
    expect(bootstrap, contains('isOwnWorker'));
    expect(bootstrap, contains('name !== truthLensShellCache'));
  });

  test('自有 service worker 只做可安裝判準所需的事', () {
    // 只看程式碼：註解裡本來就會提到這些名詞，拿整份原始碼比對會誤判。
    final worker = File('web/truthlens_sw.js')
        .readAsLinesSync()
        .where((line) => !line.trimLeft().startsWith('//'))
        .join('\n');

    // Chromium 的可安裝判準要求有 fetch handler。
    expect(worker, contains("addEventListener('fetch'"));
    // 以下兩件正是先前 Flutter worker 造成 Android 重整迴圈的原因。
    expect(worker, isNot(contains('registration.unregister')));
    expect(worker, isNot(contains('client.navigate')));
    // 只接管導覽請求；main.dart.js／CanvasKit／模型一律不碰，避免陳舊資產。
    expect(worker, contains("request.mode !== 'navigate'"));
    // 網路優先：網路成功時一定回傳最新內容，快取只作離線後備。
    expect(worker, contains('await fetch(request)'));
  });

  test('PWA 橋接必須早於 flutter_bootstrap 載入', () {
    final html = File('web/index.html').readAsStringSync();

    // beforeinstallprompt 只派送一次，且通常早於 Flutter 啟動。
    // 比較實際的 script 標籤位置，HTML 註解提到檔名不算數。
    expect(
      html.indexOf('<script src="pwa_bridge.js">'),
      lessThan(html.indexOf('<script src="flutter_bootstrap.js"')),
    );
  });

  test('web startup shell exposes an accessible retry state', () {
    final html = File('web/index.html').readAsStringSync();
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();

    expect(html, contains('class="seo-shell__status" role="status"'));
    expect(html, contains('#seo-shell-retry'));
    expect(bootstrap, contains('showTruthLensStartupFailure'));
    expect(bootstrap, contains('retry.type = "button"'));
    expect(bootstrap, contains('window.location.reload()'));
    expect(bootstrap, contains('}, 120000)'));
    expect(bootstrap, contains('此裝置可能需要較長時間'));
  });

  test('root page waits for an explicit workspace launch action', () {
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();

    expect(bootstrap, contains('function shouldAutoBootTruthLens()'));
    expect(bootstrap, contains('params.get("workspace") === "1"'));
    expect(bootstrap, contains('window.location.hash === "#workspace"'));
    expect(bootstrap, contains('function wireTruthLensStartButton()'));
    expect(bootstrap, contains('event.preventDefault()'));
    expect(
      bootstrap,
      contains('window.startTruthLensWorkspace = bootTruthLens'),
    );
    expect(bootstrap, contains('if (shouldAutoBootTruthLens())'));

    final autoBootTail = RegExp(r'\nbootTruthLens\(\);\s*$');
    expect(autoBootTail.hasMatch(bootstrap), isFalse);
  });

  test('Android and macOS web bypass incompatible GPU rendering', () {
    final bootstrap = File('web/flutter_bootstrap.js').readAsStringSync();
    final workflow = File(
      '.github/workflows/deploy_vercel.yml',
    ).readAsStringSync();

    expect(bootstrap, contains('function getTruthLensCompatibilityPlatform()'));
    expect(bootstrap, contains('navigator.userAgentData?.platform'));
    expect(bootstrap, contains('navigator.maxTouchPoints'));
    expect(bootstrap, contains('return "Android"'));
    expect(bootstrap, contains('return isMacOS ? "macOS" : null'));
    expect(bootstrap, contains('config.canvasKitVariant = "full"'));
    expect(bootstrap, contains('config.canvasKitForceCpuOnly = true'));
    expect(bootstrap, contains('config: flutterConfig'));
    expect(
      bootstrap,
      contains(
        'engineInitializer.initializeEngine(\n            flutterConfig,',
      ),
    );
    expect(workflow, contains("flutter-version: '3.44.4'"));
  });

  test('web first frame does not wait for OPFS model inventory restore', () {
    final mainSource = File('lib/main.dart').readAsStringSync();

    expect(mainSource, contains('if (kIsWeb)'));
    expect(mainSource, contains('_webPreferenceStartupTimeout'));
    expect(mainSource, contains('prefs.load().timeout'));
    expect(mainSource, contains('runApp('));
    expect(mainSource, contains('unawaited('));
    expect(
      mainSource,
      contains(
        "_runStartupTask('model inventory', modelManager.refreshInstallStates)",
      ),
    );
  });
}
