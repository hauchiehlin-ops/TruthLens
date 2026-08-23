// 自訂 Flutter web 啟動腳本：強制使用本地端 CanvasKit（build/web/canvaskit/，
// 由 `flutter build web` 自動產生），不透過 Google CDN（gstatic.com）下載，
// 符合本地優先原則——除了推論本身，連引擎執行期資源都不依賴外部連線。
{{flutter_js}}
{{flutter_build_config}}

const truthLensWorkerCleanupKey = "truthlens-worker-cleanup-v1";

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

  const registrations = await navigator.serviceWorker.getRegistrations();
  const hadLegacyWorker =
    registrations.length > 0 || navigator.serviceWorker.controller != null;
  await Promise.all(registrations.map((registration) => registration.unregister()));

  if ("caches" in window) {
    const cacheNames = await window.caches.keys();
    await Promise.all(
      cacheNames
        .filter(
          (name) =>
            name === "flutter-app-cache" || name.startsWith("flutter-"),
        )
        .map((name) => window.caches.delete(name)),
    );
  }
  return hadLegacyWorker;
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
    window.sessionStorage.getItem(truthLensWorkerCleanupKey) !== "reloaded"
  ) {
    // An unregistered worker can continue controlling the current document
    // until the next navigation. Reload exactly once so main.dart.js is fetched
    // without the stale worker; the session marker prevents a reload loop.
    window.sessionStorage.setItem(truthLensWorkerCleanupKey, "reloaded");
    window.location.reload();
    return;
  }
  window.sessionStorage.removeItem(truthLensWorkerCleanupKey);

  let appStarted = false;
  const startupWatchdog = window.setTimeout(() => {
    if (!appStarted) {
      showTruthLensStartupFailure(new Error("Flutter startup timed out"));
    }
  }, 30000);

  try {
    await _flutter.loader.load({
      // Do not pass serviceWorkerSettings. Flutter's generated worker now
      // unregisters itself and navigates clients; registering it on every load
      // creates a refresh loop in Android Chrome.
      config: {
        canvasKitBaseUrl: "canvaskit/",
        useLocalCanvasKit: true,
      },
      onEntrypointLoaded: async function(engineInitializer) {
        try {
          const appRunner = await engineInitializer.initializeEngine();
          await appRunner.runApp();
          appStarted = true;
          window.clearTimeout(startupWatchdog);
          document.getElementById("seo-shell")?.remove();
        } catch (error) {
          window.clearTimeout(startupWatchdog);
          showTruthLensStartupFailure(error);
        }
      },
    });
  } catch (error) {
    window.clearTimeout(startupWatchdog);
    showTruthLensStartupFailure(error);
  }
}

bootTruthLens();
