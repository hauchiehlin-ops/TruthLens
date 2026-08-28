// TruthLens 自有 service worker。
//
// 唯一目的：滿足 Chromium 判定「可安裝」所需的 fetch handler，讓
// beforeinstallprompt 得以派送。裝成應用程式後 navigator.storage.persist()
// 才有機會獲准，已下載的數百 MB 模型才不會被瀏覽器回收。
//
// 刻意不做的事——這些正是先前 Flutter 產生的 worker 造成 Android Chrome
// 重整迴圈與陳舊資產的原因（見 flutter_bootstrap.js 的清理邏輯）：
//   * 不在 activate 反註冊自己
//   * 不呼叫 client.navigate()
//   * 不預先快取任何應用程式資產（main.dart.js、CanvasKit、模型一律不碰）
//
// 只做一件事：導覽請求走「網路優先」，成功就順手更新一份 index.html 當離線
// 後備。網路正常時永遠拿到最新內容，不可能陳舊；網路斷線時至少開得起來。
'use strict';

const SHELL_CACHE = 'truthlens-shell-v1';
const SHELL_URL = 'index.html';

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches
      .open(SHELL_CACHE)
      .then((cache) => cache.add(SHELL_URL))
      .catch(() => {
        // 取不到就算了：離線後備是加分項，不該讓安裝失敗。
      }),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      // 清掉舊版 Flutter worker 留下的快取，避免它們繼續佔用配額。
      const names = await caches.keys();
      await Promise.all(
        names.filter((name) => name !== SHELL_CACHE).map((name) => caches.delete(name)),
      );
      await self.clients.claim();
    })(),
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  // 只接管導覽請求。其餘（main.dart.js、CanvasKit、OPFS、模型下載的 range
  // 請求…）完全不呼叫 respondWith，交回瀏覽器預設行為。
  if (request.method !== 'GET' || request.mode !== 'navigate') return;

  event.respondWith(
    (async () => {
      try {
        const response = await fetch(request);
        if (response && response.ok) {
          const cache = await caches.open(SHELL_CACHE);
          await cache.put(SHELL_URL, response.clone());
        }
        return response;
      } catch (error) {
        const cached = await caches.match(SHELL_URL);
        return cached || Response.error();
      }
    })(),
  );
});
