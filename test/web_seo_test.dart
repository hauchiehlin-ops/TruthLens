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
    'web bootstrap removes legacy workers and registers only its own',
    () {
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
      expect(bootstrap, contains('navigator.serviceWorker.register(truthLensWorkerScript)'));
      expect(bootstrap, contains('const truthLensWorkerScript = "truthlens_sw.js"'));
      // 清理邏輯必須放過自有 worker 與其快取，否則每次載入都會把它清掉。
      expect(bootstrap, contains('isOwnWorker'));
      expect(bootstrap, contains('name !== truthLensShellCache'));
    },
  );

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
