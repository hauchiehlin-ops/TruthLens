// TruthLens Web 推論橋接：包裝 onnxruntime-web，供 Dart (dart:js_interop) 呼叫。
// 所有檔案自我托管於 assets/ort/，並在必要時提供彈性降級與 CDN 備援，符合本地優先原則——
// 推論運算全程在瀏覽器（WASM / WebGPU）內完成，不上傳模型或文本。
(function () {
  const getOrtBase = () => {
    if (typeof window !== 'undefined' && window.location) {
      return window.location.origin + '/assets/ort/';
    }
    return 'assets/ort/';
  };

  const state = {
    ortPromise: null,
    epKind: null, // 'webgpu' | 'wasm'
    sessions: new Map(),
    runQueue: Promise.resolve(),
  };

  function loadScript(src) {
    return new Promise((resolve, reject) => {
      const el = document.createElement('script');
      el.src = src;
      el.onload = () => resolve();
      el.onerror = () => reject(new Error('無法載入 ' + src));
      document.head.appendChild(el);
    });
  }

  async function ensureOrt() {
    if (state.ortPromise) return state.ortPromise;
    state.ortPromise = (async () => {
      const ortBase = getOrtBase();
      const hasGpu = typeof navigator !== 'undefined' && !!navigator.gpu;
      state.epKind = hasGpu ? 'webgpu' : 'wasm';
      const script = hasGpu ? ortBase + 'ort.webgpu.min.js' : ortBase + 'ort.wasm.min.js';

      try {
        await loadScript(script);
      } catch (e) {
        console.warn('[truthlensOrt] 本地 script 載入失敗，嘗試 fallback：', e);
        const cdnScript = hasGpu
          ? 'https://cdn.jsdelivr.net/npm/onnxruntime-web@1.19.2/dist/ort.webgpu.min.js'
          : 'https://cdn.jsdelivr.net/npm/onnxruntime-web@1.19.2/dist/ort.wasm.min.js';
        await loadScript(cdnScript);
      }

      if (!window.ort) throw new Error('onnxruntime-web 載入後未初始化');

      // 檢查環境是否支援 SharedArrayBuffer / 跨來源隔離
      const isIsolated =
        typeof crossOriginIsolated !== 'undefined' &&
        crossOriginIsolated &&
        typeof SharedArrayBuffer !== 'undefined';

      window.ort.env.wasm.wasmPaths = ortBase;
      window.ort.env.wasm.numThreads = isIsolated
        ? Math.min(navigator.hardwareConcurrency || 4, 4)
        : 1;

      return window.ort;
    })();
    return state.ortPromise;
  }

  async function loadModel(modelId, modelBytes) {
    return enqueueOrtWork(async () => {
      const ort = await ensureOrt();
      const bytes = modelBytes instanceof Uint8Array ? modelBytes : new Uint8Array(modelBytes);

      releaseModel(modelId);

      const tryProviders = [];
      if (state.epKind === 'webgpu') {
        tryProviders.push(['webgpu', 'wasm']);
      }
      tryProviders.push(['wasm']);

      let session;
      let usedEp = 'wasm';
      let lastError;

      for (const eps of tryProviders) {
        try {
          session = await ort.InferenceSession.create(bytes, { executionProviders: eps });
          usedEp = eps[0];
          break;
        } catch (e) {
          lastError = e;
          console.warn('[truthlensOrt] ' + eps.join('/') + ' 建立 session 失敗，嘗試後續 provider：', e);
        }
      }

      if (!session) {
        // 若因 wasm 尋徑或執行緒設定導致建立失敗，嘗試以 CDN wasmPaths 與單執行緒作為最後防線
        try {
          window.ort.env.wasm.wasmPaths = 'https://cdn.jsdelivr.net/npm/onnxruntime-web@1.19.2/dist/';
          window.ort.env.wasm.numThreads = 1;
          session = await ort.InferenceSession.create(bytes, { executionProviders: ['wasm'] });
          usedEp = 'wasm';
        } catch (fallbackError) {
          console.error('[truthlensOrt] 所有 ONNX Runtime session 建立方式皆失敗：', fallbackError);
          throw lastError || fallbackError;
        }
      }

      state.sessions.set(modelId, session);
      return usedEp;
    });
  }

  async function run(modelId, inputIds, attentionMask, seqLen) {
    return enqueueOrtWork(async () => {
      const ort = window.ort;
      const session = state.sessions.get(modelId);
      if (!session || !ort) throw new Error('模型尚未載入：' + modelId);
      const shape = [1, seqLen];
      let results;
      try {
        const ids = BigInt64Array.from(inputIds.map((v) => BigInt(v)));
        const mask = BigInt64Array.from(attentionMask.map((v) => BigInt(v)));
        results = await session.run({
          input_ids: new ort.Tensor('int64', ids, shape),
          attention_mask: new ort.Tensor('int64', mask, shape),
        });
      } catch (e) {
        console.warn('[truthlensOrt] int64 輸入推論失敗，改用 int32 重試：', e);
        const ids = Int32Array.from(inputIds);
        const mask = Int32Array.from(attentionMask);
        results = await session.run({
          input_ids: new ort.Tensor('int32', ids, shape),
          attention_mask: new ort.Tensor('int32', mask, shape),
        });
      }
      const outputName = Object.keys(results)[0];
      const output = results[outputName];
      return {
        data: Array.from(output.data, numberFromTensorValue),
        dims: Array.from(output.dims, numberFromTensorValue),
      };
    });
  }

  function numberFromTensorValue(value) {
    if (typeof value === 'bigint') return Number(value);
    return Number(value);
  }

  function enqueueOrtWork(task) {
    // onnxruntime-web 的部分 execution provider 不允許同一執行環境重入
    // session.run；全域佇列能徹底避免 Session already started / Session mismatch。
    const next = state.runQueue.then(task, task);
    state.runQueue = next.catch(() => {});
    return next;
  }

  function releaseModel(modelId) {
    const session = state.sessions.get(modelId);
    if (session) {
      try {
        session.release();
      } catch (_) {
        /* ignore */
      }
      state.sessions.delete(modelId);
    }
  }

  function epKind() {
    return state.epKind;
  }

  window.truthlensOrt = { loadModel, run, releaseModel, epKind, ensureOrt };
})();
