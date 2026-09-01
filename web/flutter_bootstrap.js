// 自訂 Flutter web 啟動腳本：強制使用本地端 CanvasKit（build/web/canvaskit/，
// 由 `flutter build web` 自動產生），不透過 Google CDN（gstatic.com）下載，
// 符合本地優先原則——除了推論本身，連引擎執行期資源都不依賴外部連線。
{{flutter_js}}
{{flutter_build_config}}

const truthLensWorkerCleanupKey = "omnitrace-worker-cleanup-v2";
const truthLensWorkerMigrationKey = "omnitrace-worker-migration-v2";
const truthLensWorkerScript = "omnitrace_sw.js";
const truthLensShellCache = "omnitrace-shell-v1";
const truthLensPublicLanguageKey = "omnitrace-public-lang";
const truthLensFlutterLocaleKey = "flutter.app_locale";

function normalizeOmniTraceLocale(value) {
  if (value == null || value === "") return "en";
  const lower = String(value).replace("_", "-").toLowerCase();
  if (lower === "zh-hant" || lower === "zh-tw" || lower === "zh-hk" || lower === "zh-mo") {
    return "zh-Hant";
  }
  if (lower === "zh-hans" || lower === "zh-cn" || lower === "zh-sg") {
    return "zh-Hans";
  }
  const base = lower.split("-")[0];
  return [
    "en",
    "ja",
    "ko",
    "th",
    "ms",
    "es",
    "id",
    "ru",
    "de",
    "fr",
    "pt",
  ].includes(base)
    ? base
    : "en";
}

function currentOmniTracePublicLocale() {
  const params = new URLSearchParams(window.location.search || "");
  return normalizeOmniTraceLocale(
    params.get("lang") ||
      readOmniTraceStorage(window.localStorage, truthLensPublicLanguageKey) ||
      navigator.language ||
      document.documentElement.lang,
  );
}

function encodeOmniTraceFlutterLocale(lang) {
  const normalized = normalizeOmniTraceLocale(lang);
  if (normalized === "zh-Hant") return "zh_Hant";
  if (normalized === "zh-Hans") return "zh_Hans";
  return normalized;
}

function persistOmniTraceLocale(lang) {
  const normalized = normalizeOmniTraceLocale(lang);
  writeOmniTraceStorage(window.localStorage, truthLensPublicLanguageKey, normalized);
  writeOmniTraceStorage(
    window.localStorage,
    truthLensFlutterLocaleKey,
    JSON.stringify(encodeOmniTraceFlutterLocale(normalized)),
  );
  return normalized;
}

function truthLensWorkspaceUrl(lang) {
  const url = new URL(window.location.href);
  url.pathname = "/";
  url.search = "";
  url.searchParams.set("workspace", "1");
  url.searchParams.set("lang", normalizeOmniTraceLocale(lang));
  return url.pathname + url.search;
}

function truthLensStartupCopy(key) {
  const copy = {
    slow: {
      en: "Restoring local analysis components and data. This device may need more time...",
      "zh-Hant": "正在恢復本機分析元件與資料，此裝置可能需要較長時間...",
      "zh-Hans": "正在恢复本机分析组件与数据，此设备可能需要较长时间...",
      ja: "ローカル分析コンポーネントとデータを復元しています。この端末では少し時間がかかる場合があります...",
      ko: "로컬 분석 구성 요소와 데이터를 복원하는 중입니다. 이 기기에서는 시간이 더 걸릴 수 있습니다...",
      th: "กำลังกู้คืนส่วนประกอบและข้อมูลการวิเคราะห์ในเครื่อง อุปกรณ์นี้อาจต้องใช้เวลามากขึ้น...",
      ms: "Sedang memulihkan komponen dan data analisis setempat. Peranti ini mungkin memerlukan lebih masa...",
      es: "Restaurando componentes y datos de análisis local. Este dispositivo puede necesitar más tiempo...",
      id: "Memulihkan komponen dan data analisis lokal. Perangkat ini mungkin memerlukan waktu lebih lama...",
      ru: "Восстанавливаются локальные компоненты анализа и данные. Этому устройству может понадобиться больше времени...",
      de: "Lokale Analysekomponenten und Daten werden wiederhergestellt. Dieses Gerät benötigt möglicherweise etwas mehr Zeit...",
      fr: "Restauration des composants et données d’analyse locale. Cet appareil peut demander plus de temps...",
      pt: "Restaurando componentes e dados de análise local. Este dispositivo pode precisar de mais tempo...",
    },
    failed: {
      en: "Startup did not finish. Please reload the workspace.",
      "zh-Hant": "啟動未完成，請重新載入工作台。",
      "zh-Hans": "启动未完成，请重新载入工作台。",
      ja: "起動が完了しませんでした。ワークスペースを再読み込みしてください。",
      ko: "시작이 완료되지 않았습니다. 작업 공간을 다시 로드하세요.",
      th: "การเริ่มต้นยังไม่เสร็จ โปรดโหลดพื้นที่ทำงานใหม่",
      ms: "Permulaan belum selesai. Sila muat semula ruang kerja.",
      es: "El inicio no terminó. Vuelve a cargar el área de trabajo.",
      id: "Startup belum selesai. Muat ulang ruang kerja.",
      ru: "Запуск не завершен. Перезагрузите рабочую область.",
      de: "Der Start wurde nicht abgeschlossen. Bitte laden Sie den Arbeitsbereich neu.",
      fr: "Le démarrage n’est pas terminé. Rechargez l’espace de travail.",
      pt: "A inicialização não terminou. Recarregue o workspace.",
    },
    retry: {
      en: "Reload",
      "zh-Hant": "重新載入",
      "zh-Hans": "重新载入",
      ja: "再読み込み",
      ko: "다시 로드",
      th: "โหลดใหม่",
      ms: "Muat semula",
      es: "Recargar",
      id: "Muat ulang",
      ru: "Перезагрузить",
      de: "Neu laden",
      fr: "Recharger",
      pt: "Recarregar",
    },
    loading: {
      en: "Loading the local analysis workspace...",
      "zh-Hant": "正在載入本地檢測工作台…",
      "zh-Hans": "正在载入本地检测工作台…",
      ja: "ローカル検出ワークスペースを読み込んでいます…",
      ko: "로컬 감지 작업 공간을 불러오는 중입니다…",
      th: "กำลังโหลดพื้นที่ทำงานตรวจจับในเครื่อง…",
      ms: "Memuatkan ruang kerja pengesanan setempat...",
      es: "Cargando el área de detección local...",
      id: "Memuat ruang kerja deteksi lokal...",
      ru: "Загрузка локальной рабочей области проверки...",
      de: "Lokaler Erkennungsbereich wird geladen...",
      fr: "Chargement de l’espace de détection local...",
      pt: "Carregando o workspace de detecção local...",
    },
    loadingCompat: {
      en: "Loading the local analysis workspace in {platform} compatibility mode...",
      "zh-Hant": "正在以 {platform} 相容模式載入本地檢測工作台…",
      "zh-Hans": "正在以 {platform} 兼容模式载入本地检测工作台…",
      ja: "{platform} 互換モードでローカル検出ワークスペースを読み込んでいます…",
      ko: "{platform} 호환 모드로 로컬 감지 작업 공간을 불러오는 중입니다…",
      th: "กำลังโหลดพื้นที่ทำงานตรวจจับในเครื่องด้วยโหมดเข้ากันได้กับ {platform}…",
      ms: "Memuatkan ruang kerja pengesanan setempat dalam mod keserasian {platform}...",
      es: "Cargando el área de detección local en modo compatible con {platform}...",
      id: "Memuat ruang kerja deteksi lokal dalam mode kompatibilitas {platform}...",
      ru: "Загрузка локальной рабочей области проверки в режиме совместимости {platform}...",
      de: "Lokaler Erkennungsbereich wird im {platform}-Kompatibilitätsmodus geladen...",
      fr: "Chargement de l’espace de détection local en mode de compatibilité {platform}...",
      pt: "Carregando o workspace de detecção local no modo de compatibilidade {platform}...",
    },
    initializing: {
      en: "Initializing the workspace interface...",
      "zh-Hant": "正在初始化工作台介面…",
      "zh-Hans": "正在初始化工作台界面…",
      ja: "ワークスペース画面を初期化しています…",
      ko: "작업 공간 인터페이스를 초기화하는 중입니다…",
      th: "กำลังเริ่มต้นส่วนติดต่อพื้นที่ทำงาน…",
      ms: "Memulakan antara muka ruang kerja...",
      es: "Inicializando la interfaz del área de trabajo...",
      id: "Menginisialisasi antarmuka ruang kerja...",
      ru: "Инициализация интерфейса рабочей области...",
      de: "Arbeitsbereich-Oberfläche wird initialisiert...",
      fr: "Initialisation de l’interface de l’espace de travail...",
      pt: "Inicializando a interface do workspace...",
    },
    opening: {
      en: "Opening detection workspace...",
      "zh-Hant": "正在開啟檢測工作台…",
      "zh-Hans": "正在打开检测工作台…",
      ja: "検出ワークスペースを開いています…",
      ko: "감지 작업 공간을 여는 중입니다…",
      th: "กำลังเปิดพื้นที่ทำงานตรวจจับ…",
      ms: "Membuka ruang kerja pengesanan...",
      es: "Abriendo el área de detección...",
      id: "Membuka ruang kerja deteksi...",
      ru: "Открытие рабочей области проверки...",
      de: "Erkennungsbereich wird geöffnet...",
      fr: "Ouverture de l’espace de détection...",
      pt: "Abrindo o workspace de detecção...",
    },
  };
  const lang = currentOmniTracePublicLocale();
  return copy[key]?.[lang] || copy[key]?.en || "";
}

function getOmniTraceCompatibilityPlatform() {
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

function createOmniTraceFlutterConfig(compatibilityPlatform) {
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

function updateOmniTraceStartupStatus(message) {
  const status = document
    .getElementById("seo-shell")
    ?.querySelector(".seo-shell__status");
  if (status) status.textContent = message;
}

function readOmniTraceStorage(storage, key) {
  try {
    return storage.getItem(key);
  } catch (_) {
    return null;
  }
}

function writeOmniTraceStorage(storage, key, value) {
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

function showOmniTraceStartupFailure(error) {
  console.error("OmniTrace Web startup failed:", error);
  const shell = document.getElementById("seo-shell");
  const status = shell?.querySelector(".seo-shell__status");
  if (!shell || !status) return;

  status.textContent = truthLensStartupCopy("failed");
  if (document.getElementById("seo-shell-retry")) return;

  const retry = document.createElement("button");
  retry.id = "seo-shell-retry";
  retry.type = "button";
  retry.textContent = truthLensStartupCopy("retry");
  retry.addEventListener("click", () => window.location.reload());
  status.insertAdjacentElement("afterend", retry);
}

async function removeLegacyFlutterWorker() {
  if (!("serviceWorker" in navigator)) return false;

  if (
    navigator.serviceWorker.controller == null &&
    readOmniTraceStorage(
      window.localStorage,
      truthLensWorkerMigrationKey,
    ) === "complete"
  ) {
    return false;
  }

  const registrations = await navigator.serviceWorker.getRegistrations();
  // OmniTrace 自有的 worker 不算「舊」——它是安裝為應用程式的前提。
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
    writeOmniTraceStorage(
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
function registerOmniTraceWorker() {
  if (!("serviceWorker" in navigator)) return;
  navigator.serviceWorker.register(truthLensWorkerScript).catch((error) => {
    console.warn("OmniTrace service worker registration failed:", error);
  });
}

async function bootOmniTrace() {
  persistOmniTraceLocale(currentOmniTracePublicLocale());
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
    readOmniTraceStorage(window.sessionStorage, truthLensWorkerCleanupKey) !==
      "reloaded"
  ) {
    // An unregistered worker can continue controlling the current document
    // until the next navigation. Reload exactly once so main.dart.js is fetched
    // without the stale worker; the session marker prevents a reload loop.
    writeOmniTraceStorage(
      window.sessionStorage,
      truthLensWorkerCleanupKey,
      "reloaded",
    );
    window.location.reload();
    return;
  }
  writeOmniTraceStorage(window.sessionStorage, truthLensWorkerCleanupKey, null);

  let appStarted = false;
  const slowStartupNotice = window.setTimeout(() => {
    if (!appStarted) {
      updateOmniTraceStartupStatus(
        truthLensStartupCopy("slow"),
      );
    }
  }, 15000);
  const startupWatchdog = window.setTimeout(() => {
    if (!appStarted) {
      showOmniTraceStartupFailure(new Error("Flutter startup timed out"));
    }
  }, 120000);
  const compatibilityPlatform = getOmniTraceCompatibilityPlatform();
  const flutterConfig = createOmniTraceFlutterConfig(compatibilityPlatform);

  try {
    updateOmniTraceStartupStatus(
      compatibilityPlatform != null
        ? truthLensStartupCopy("loadingCompat").replace("{platform}", compatibilityPlatform)
        : truthLensStartupCopy("loading"),
    );
    await _flutter.loader.load({
      // Do not pass serviceWorkerSettings. Flutter's generated worker now
      // unregisters itself and navigates clients; registering it on every load
      // creates a refresh loop in Android Chrome.
      config: flutterConfig,
      onEntrypointLoaded: async function(engineInitializer) {
        try {
          updateOmniTraceStartupStatus(truthLensStartupCopy("initializing"));
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
          registerOmniTraceWorker();
        } catch (error) {
          window.clearTimeout(slowStartupNotice);
          window.clearTimeout(startupWatchdog);
          showOmniTraceStartupFailure(error);
        }
      },
    });
  } catch (error) {
    window.clearTimeout(slowStartupNotice);
    window.clearTimeout(startupWatchdog);
    showOmniTraceStartupFailure(error);
  }
}

function shouldAutoBootOmniTrace() {
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

function wireOmniTraceStartButton() {
  const start = document.getElementById("seo-shell-start");
  if (!start) return;
  start.addEventListener("click", (event) => {
    event.preventDefault();
    const lang = persistOmniTraceLocale(currentOmniTracePublicLocale());
    if (window.history && window.history.replaceState) {
      window.history.replaceState(null, "", truthLensWorkspaceUrl(lang));
    }
    start.setAttribute("aria-disabled", "true");
    start.textContent = truthLensStartupCopy("opening");
    bootOmniTrace();
  });
}

window.startOmniTraceWorkspace = bootOmniTrace;

if (shouldAutoBootOmniTrace()) {
  bootOmniTrace();
} else {
  wireOmniTraceStartButton();
}
