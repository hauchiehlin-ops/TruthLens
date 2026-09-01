// 自訂 Flutter web 啟動腳本：強制使用本地端 CanvasKit（build/web/canvaskit/，
// 由 `flutter build web` 自動產生），不透過 Google CDN（gstatic.com）下載，
// 符合本地優先原則——除了推論本身，連引擎執行期資源都不依賴外部連線。
{{flutter_js}}
{{flutter_build_config}}

const truthLensWorkerCleanupKey = "truthlens-worker-cleanup-v2";
const truthLensWorkerMigrationKey = "truthlens-worker-migration-v2";
const truthLensWorkerScript = "truthlens_sw.js";
const truthLensShellCache = "truthlens-shell-v1";

function getTruthLensCompatibilityPlatform() {
  const userAgent = navigator.userAgent || "";
  const userAgentPlatform = navigator.userAgentData?.platform || "";
  const legacyPlatform = navigator.platform || "";

  if (/Android/i.test(userAgent) || /Android/i.test(userAgentPlatform)) {
    return "Android";
  }

  // iPadOS can advertise itself as MacIntel. Keep the already-working iOS
  // renderer path by requiring a non-touch Mac before applying this fallback.
  const isIPadOS =
    legacyPlatform === "MacIntel" && (navigator.maxTouchPoints || 0) > 1;
  const isMacOS =
    !isIPadOS &&
    (/Macintosh|Mac OS X/i.test(userAgent) ||
      /macOS/i.test(userAgentPlatform) ||
      /^Mac/i.test(legacyPlatform));
  return isMacOS ? "macOS" : null;
}

function createTruthLensFlutterConfig(compatibilityPlatform) {
  const config = {
    canvasKitBaseUrl: "canvaskit/",
    useLocalCanvasKit: true,
  };

  if (compatibilityPlatform != null) {
    // Some Android and macOS GPU/driver combinations expose WebGL successfully
    // but stall while CanvasKit creates its first accelerated surface. Use the
    // universally compatible CanvasKit build and software rasterization there.
    config.canvasKitVariant = "full";
    config.canvasKitForceCpuOnly = true;
  }

  return config;
}

function updateTruthLensStartupStatus(message) {
  const status = document
    .getElementById("seo-shell")
    ?.querySelector(".seo-shell__status");
  if (status) status.textContent = message;
}

function readTruthLensStorage(storage, key) {
  try {
    return storage.getItem(key);
  } catch (_) {
    return null;
  }
}

function writeTruthLensStorage(storage, key, value) {
  try {
    if (value == null) {
      storage.removeItem(key);
    } else {
      storage.setItem(key, value);
    }
  } catch (_) {
    // Storage can be unavailable in strict privacy modes. Startup still works.
  }
}

function showTruthLensStartupFailure(error) {
  console.error("TruthLens Web startup failed:", error);
  const shell = document.getElementById("seo-shell");
  const status = shell?.querySelector(".seo-shell__status");
  if (!shell || !status) return;

  status.textContent = "啟動未完成，請重新載入工作台。";
  if (document.getElementById("seo-shell-retry")) return;

  const retry = document.createElement("button");
  retry.id = "seo-shell-retry";
  retry.type = "button";
  retry.textContent = "重新載入";
  retry.addEventListener("click", () => window.location.reload());
  status.insertAdjacentElement("afterend", retry);
}

async function removeLegacyFlutterWorker() {
  if (!("serviceWorker" in navigator)) return false;

  if (
    navigator.serviceWorker.controller == null &&
    readTruthLensStorage(
      window.localStorage,
      truthLensWorkerMigrationKey,
    ) === "complete"
  ) {
    return false;
  }

  const registrations = await navigator.serviceWorker.getRegistrations();
  // TruthLens 自有的 worker 不算「舊」——它是安裝為應用程式的前提。
  // 少了這個判斷，每次載入都會把它反註冊掉，安裝提示永遠不會出現。
  const isOwnWorker = (registration) => {
    const worker =
      registration.active || registration.waiting || registration.installing;
    return worker != null && worker.scriptURL.endsWith(truthLensWorkerScript);
  };
  const legacy = registrations.filter((registration) => !isOwnWorker(registration));
  const hadLegacyWorker =
    legacy.length > 0 ||
    (navigator.serviceWorker.controller != null &&
      !navigator.serviceWorker.controller.scriptURL.endsWith(
        truthLensWorkerScript,
      ));
  await Promise.all(legacy.map((registration) => registration.unregister()));

  if ("caches" in window) {
    const cacheNames = await window.caches.keys();
    await Promise.all(
      cacheNames
        .filter(
          (name) =>
            name !== truthLensShellCache &&
            (name === "flutter-app-cache" || name.startsWith("flutter-")),
        )
        .map((name) => window.caches.delete(name)),
    );
  }
  if (!hadLegacyWorker) {
    writeTruthLensStorage(
      window.localStorage,
      truthLensWorkerMigrationKey,
      "complete",
    );
  }
  return hadLegacyWorker;
}

// Chromium 只有在網站具備帶 fetch handler 的 service worker 時才會派送
// beforeinstallprompt，而安裝是 storage.persist() 獲准的最有效途徑。
// 刻意等應用程式跑起來才註冊：註冊失敗或延遲都不該影響啟動。
function registerTruthLensWorker() {
  if (!("serviceWorker" in navigator)) return;
  navigator.serviceWorker.register(truthLensWorkerScript).catch((error) => {
    console.warn("TruthLens service worker registration failed:", error);
  });
}

async function bootTruthLens() {
  let hadLegacyWorker = false;
  try {
    hadLegacyWorker = await removeLegacyFlutterWorker();
  } catch (error) {
    // Worker cleanup is a migration aid. A browser that blocks this API should
    // still be allowed to launch the application normally.
    console.warn("Legacy Flutter worker cleanup failed:", error);
  }

  if (
    hadLegacyWorker &&
    readTruthLensStorage(window.sessionStorage, truthLensWorkerCleanupKey) !==
      "reloaded"
  ) {
    // An unregistered worker can continue controlling the current document
    // until the next navigation. Reload exactly once so main.dart.js is fetched
    // without the stale worker; the session marker prevents a reload loop.
    writeTruthLensStorage(
      window.sessionStorage,
      truthLensWorkerCleanupKey,
      "reloaded",
    );
    window.location.reload();
    return;
  }
  writeTruthLensStorage(window.sessionStorage, truthLensWorkerCleanupKey, null);

  let appStarted = false;
  const slowStartupNotice = window.setTimeout(() => {
    if (!appStarted) {
      updateTruthLensStartupStatus(
        "正在恢復本機分析元件與資料，此裝置可能需要較長時間…",
      );
    }
  }, 15000);
  const startupWatchdog = window.setTimeout(() => {
    if (!appStarted) {
      showTruthLensStartupFailure(new Error("Flutter startup timed out"));
    }
  }, 120000);
  const compatibilityPlatform = getTruthLensCompatibilityPlatform();
  const flutterConfig = createTruthLensFlutterConfig(compatibilityPlatform);

  try {
    updateTruthLensStartupStatus(
      compatibilityPlatform != null
        ? `正在以 ${compatibilityPlatform} 相容模式載入本機分析工作台…`
        : "正在載入本機分析工作台…",
    );
    await _flutter.loader.load({
      // Do not pass serviceWorkerSettings. Flutter's generated worker now
      // unregisters itself and navigates clients; registering it on every load
      // creates a refresh loop in Android Chrome.
      config: flutterConfig,
      onEntrypointLoaded: async function(engineInitializer) {
        try {
          updateTruthLensStartupStatus("正在初始化工作台介面…");
          // Loader settings choose the CanvasKit asset. Passing the same
          // settings into initializeEngine is required for engine options such
          // as canvasKitForceCpuOnly to take effect.
          const appRunner = await engineInitializer.initializeEngine(
            flutterConfig,
          );
          await appRunner.runApp();
          appStarted = true;
          window.clearTimeout(slowStartupNotice);
          window.clearTimeout(startupWatchdog);
          document.getElementById("seo-shell")?.remove();
          registerTruthLensWorker();
        } catch (error) {
          window.clearTimeout(slowStartupNotice);
          window.clearTimeout(startupWatchdog);
          showTruthLensStartupFailure(error);
        }
      },
    });
  } catch (error) {
    window.clearTimeout(slowStartupNotice);
    window.clearTimeout(startupWatchdog);
    showTruthLensStartupFailure(error);
  }
}

function shouldAutoBootTruthLens() {
  try {
    const params = new URLSearchParams(window.location.search || "");
    return (
      params.get("workspace") === "1" ||
      window.location.hash === "#workspace"
    );
  } catch (_) {
    return false;
  }
}

function wireTruthLensStartButton() {
  const start = document.getElementById("seo-shell-start");
  if (!start) return;
  start.addEventListener("click", (event) => {
    event.preventDefault();
    if (window.history && window.history.replaceState) {
      window.history.replaceState(null, "", "/?workspace=1");
    }
    start.setAttribute("aria-disabled", "true");
    start.textContent = "正在開啟檢測工作台…";
    bootTruthLens();
  });
}

window.startTruthLensWorkspace = bootTruthLens;

if (shouldAutoBootTruthLens()) {
  bootTruthLens();
} else {
  wireTruthLensStartButton();
}
