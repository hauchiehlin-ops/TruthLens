// OmniTrace Web 推論橋接：包裝 onnxruntime-web，供 Dart (dart:js_interop) 呼叫。
// 所有檔案自我托管於 assets/ort/，並在必要時提供彈性降級與 CDN 備援，符合本地優先原則——
// 推論運算全程在瀏覽器（WASM / WebGPU）內完成，不上傳模型或文本。
//
// 每個模型預設在自己的 Web Worker 執行（見 ort_worker.js），不同模型因此能平行
// 推論、UI 執行緒也不會被卡住。Worker 無法使用時（iOS、或建立失敗）退回主執行緒
// 的單一全域佇列，行為與舊版相同。
(function () {
  const core = window.omnitraceOrtCore;

  const getOrtBase = () => {
    if (typeof window !== 'undefined' && window.location) {
      return window.location.origin + '/assets/ort/';
    }
    return 'assets/ort/';
  };

  const state = {
    ortPromise: null,
    epKind: null, // 'webgpu' | 'wasm'
    sessions: new Map(), // 主執行緒退回路徑的 session
    workers: new Map(), // modelId → Worker 包裝
    batchInvariant: new Map(), // modelId → 是否可安全批次推論
    runQueue: Promise.resolve(),
  };

  // iOS（含偽裝成桌面 UA 的 iPadOS 13+）：WebGPU 目前不夠穩定，一旦底層在
  // WebKit render process 內直接崩潰，不會拋出可被 catch 的 JS 例外，
  // 現有的 webgpu→wasm 復原機制完全接不到，等於直接讓分頁當機。因此在
  // iOS 上一律強制走 wasm，即使 navigator.gpu 存在也不使用。
  //
  // 這裡是以「裝置是否為 iOS」而非「瀏覽器品牌是否為 Safari」判斷——Apple
  // App Store 政策強制所有 iOS 上的瀏覽器（Chrome/Firefox/Edge 等）底層都
  // 必須使用 WebKit（WKWebView），實際上跑的是同一套 WebGPU 實作、有一樣
  // 的崩潰風險。isIOS() 用 UA 內的裝置字串（iPad/iPhone/iPod）判斷，
  // iOS 版 Chrome 的 UA 仍會帶 "iPhone"（如 CriOS/... Mobile/... 前綴），
  // 因此本判斷本來就會涵蓋 iOS 上的 Chrome，不只 Safari。
  function isIOS() {
    if (typeof navigator === 'undefined') return false;
    const ua = navigator.userAgent || '';
    const isAppleMobileUa = /iPad|iPhone|iPod/.test(ua);
    // iPadOS 13+ 預設把 UA 偽裝成 Mac，只能用觸控點數判斷
    const isIPadOSDesktopUa =
      navigator.platform === 'MacIntel' && (navigator.maxTouchPoints || 0) > 1;
    return isAppleMobileUa || isIPadOSDesktopUa;
  }

  // 只有 navigator.gpu 不夠：沒有可用 adapter（無 GPU、驅動黑名單）時 ORT 會
  // 靜默移除 webgpu，報告卻仍寫著 webgpu。先確認拿得到 adapter 再選用。
  let gpuPromise = null;
  function preferGpu() {
    if (gpuPromise) return gpuPromise;
    gpuPromise = (async () => {
      if (typeof navigator === 'undefined' || !navigator.gpu || isIOS()) return false;
      try {
        return !!(await navigator.gpu.requestAdapter());
      } catch (_) {
        return false;
      }
    })();
    return gpuPromise;
  }

  // 每個 Worker 各自載入一份 ORT 執行環境與模型；iOS 分頁記憶體上限低，
  // 多份執行環境容易讓分頁被系統回收，因此 iOS 維持主執行緒單一佇列。
  function workersSupported() {
    return typeof Worker !== 'undefined' && !isIOS();
  }

  function hardwareThreads() {
    return (typeof navigator !== 'undefined' && navigator.hardwareConcurrency) || 4;
  }

  async function ensureOrt() {
    if (state.ortPromise) return state.ortPromise;
    state.ortPromise = (async () => {
      state.epKind = (await preferGpu()) ? 'webgpu' : 'wasm';
      const numThreads = core.isCrossOriginIsolated() ? Math.min(hardwareThreads(), 4) : 1;
      return core.loadOrt(getOrtBase(), state.epKind === 'webgpu', numThreads);
    })();
    return state.ortPromise;
  }

  // ---------- Worker 路徑 ----------

  function createWorkerClient() {
    const worker = new Worker(window.location.origin + '/ort_worker.js');
    const pending = new Map();
    let nextId = 0;
    let broken = null;

    worker.onmessage = (event) => {
      const { id, ok, result, error } = event.data;
      const entry = pending.get(id);
      if (!entry) return;
      pending.delete(id);
      if (ok) entry.resolve(result);
      else entry.reject(new Error(error));
    };
    worker.onerror = (event) => {
      broken = new Error('ORT Worker 發生錯誤：' + (event.message || 'unknown'));
      for (const entry of pending.values()) entry.reject(broken);
      pending.clear();
    };

    function call(type, payload, transfer) {
      if (broken) return Promise.reject(broken);
      return new Promise((resolve, reject) => {
        const id = nextId++;
        pending.set(id, { resolve, reject });
        worker.postMessage({ id, type, payload }, transfer || []);
      });
    }

    return {
      call,
      terminate() {
        worker.terminate();
        const error = new Error('ORT Worker 已終止');
        for (const entry of pending.values()) entry.reject(error);
        pending.clear();
      },
    };
  }

  // 多個模型 Worker 同時執行時平分 CPU 執行緒，避免彼此超額訂閱。
  function workerThreads() {
    if (!core.isCrossOriginIsolated()) return 1;
    return Math.max(1, Math.min(4, Math.floor(hardwareThreads() / 2)));
  }

  async function loadModelInWorker(modelId, bytes) {
    const client = createWorkerClient();
    try {
      const useGpu = await preferGpu();
      state.epKind = useGpu ? 'webgpu' : 'wasm';
      await client.call('init', {
        ortBase: getOrtBase(),
        useGpu,
        numThreads: workerThreads(),
      });
      // 複製一份獨立的 buffer 再轉移：Dart 傳來的 Uint8Array 可能只是較大
      // buffer 的視圖，直接轉移會讓呼叫端手上的資料失效。
      const copy = bytes.slice();
      const ep = await client.call('load', { modelId, bytes: copy.buffer }, [copy.buffer]);
      state.workers.set(modelId, client);
      return ep;
    } catch (e) {
      client.terminate();
      throw e;
    }
  }

  // ---------- 主執行緒退回路徑 ----------

  async function loadModelOnMainThread(modelId, bytes) {
    return enqueueOrtWork(async () => {
      const ort = await ensureOrt();
      releaseMainSession(modelId);
      const { session, ep } = await core.createSession(ort, bytes, state.epKind === 'webgpu');
      state.sessions.set(modelId, { session, inputTypes: core.resolveInputTypes(session) });
      return ep;
    });
  }

  function enqueueOrtWork(task) {
    // onnxruntime-web 的部分 execution provider 不允許同一執行環境重入
    // session.run；全域佇列能徹底避免 Session already started / Session mismatch。
    const next = state.runQueue.then(task, task);
    state.runQueue = next.catch(() => {});
    return next;
  }

  function releaseMainSession(modelId) {
    const entry = state.sessions.get(modelId);
    if (!entry) return;
    try {
      entry.session.release();
    } catch (_) {
      /* ignore */
    }
    state.sessions.delete(modelId);
  }

  // ---------- 對 Dart 公開的 API ----------

  async function loadModel(modelId, modelBytes) {
    const bytes = modelBytes instanceof Uint8Array ? modelBytes : new Uint8Array(modelBytes);
    releaseModel(modelId);
    state.batchInvariant.set(modelId, !core.usesDynamicQuantization(bytes));
    if (workersSupported()) {
      try {
        return await loadModelInWorker(modelId, bytes);
      } catch (e) {
        console.warn('[omnitraceOrt] Worker 載入失敗，改在主執行緒執行：', e);
      }
    }
    return loadModelOnMainThread(modelId, bytes);
  }

  async function run(modelId, inputIds, attentionMask, seqLen, runtimeJson) {
    return runBatch(modelId, inputIds, attentionMask, 1, seqLen, runtimeJson);
  }

  async function runBatch(modelId, inputIds, attentionMask, batchSize, seqLen, runtimeJson) {
    const client = state.workers.get(modelId);
    let out;
    if (client) {
      out = await client.call('run', {
        modelId,
        inputIds,
        attentionMask,
        batchSize,
        seqLen,
        runtimeJson,
      });
    } else {
      out = await enqueueOrtWork(async () => {
        const ort = window.ort;
        const entry = state.sessions.get(modelId);
        if (!entry || !ort) throw new Error('模型尚未載入：' + modelId);
        return core.runSession(ort, entry, inputIds, attentionMask, batchSize, seqLen, runtimeJson);
      });
    }
    return { data: Array.from(out.data), dims: out.dims };
  }

  function releaseModel(modelId) {
    const client = state.workers.get(modelId);
    if (client) {
      client.terminate();
      state.workers.delete(modelId);
    }
    releaseMainSession(modelId);
    state.batchInvariant.delete(modelId);
  }

  function isBatchInvariant(modelId) {
    return state.batchInvariant.get(modelId) === true;
  }

  function epKind() {
    return state.epKind;
  }

  window.omnitraceOrt = {
    loadModel,
    run,
    runBatch,
    releaseModel,
    epKind,
    ensureOrt,
    isBatchInvariant,
  };
})();
