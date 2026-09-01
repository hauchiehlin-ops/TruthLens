// OmniTrace Web 推論橋接：包裝 onnxruntime-web，供 Dart (dart:js_interop) 呼叫。
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
      const useGpu = hasGpu && !isIOS();
      state.epKind = useGpu ? 'webgpu' : 'wasm';
      const script = useGpu ? ortBase + 'ort.webgpu.min.js' : ortBase + 'ort.wasm.min.js';

      try {
        await loadScript(script);
      } catch (e) {
        console.warn('[omnitraceOrt] 本地 script 載入失敗，嘗試 fallback：', e);
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
          console.warn('[omnitraceOrt] ' + eps.join('/') + ' 建立 session 失敗，嘗試後續 provider：', e);
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
          console.error('[omnitraceOrt] 所有 ONNX Runtime session 建立方式皆失敗：', fallbackError);
          throw lastError || fallbackError;
        }
      }

      const inputTypes = resolveInputTypes(session);
      state.sessions.set(modelId, { session, inputTypes });
      return usedEp;
    });
  }

  async function run(modelId, inputIds, attentionMask, seqLen, runtimeJson) {
    return runBatch(modelId, inputIds, attentionMask, 1, seqLen, runtimeJson);
  }

  async function runBatch(modelId, inputIds, attentionMask, batchSize, seqLen, runtimeJson) {
    return enqueueOrtWork(async () => {
      const ort = window.ort;
      const entry = state.sessions.get(modelId);
      const session = entry && entry.session ? entry.session : entry;
      if (!session || !ort) throw new Error('模型尚未載入：' + modelId);
      const shape = [batchSize, seqLen];
      const runtime = parseRuntime(runtimeJson);
      let results;

      const inputTypes = (entry && entry.inputTypes) || {};
      const firstType = inputTypes.input_ids || inputTypes.input || 'int64';
      const typeOrder = firstType === 'int32' ? ['int32', 'int64'] : ['int64', 'int32'];
      let lastError;

      for (const tensorType of typeOrder) {
        try {
          results = await session.run(
            buildFeeds(ort, tensorType, inputIds, attentionMask, shape, session, runtime),
          );
          break;
        } catch (e) {
          lastError = e;
          if (isDefinitiveTypeError(e, tensorType)) {
            continue;
          }
          if (mentionsExpectedType(e, tensorType)) {
            break;
          }
          console.warn('[omnitraceOrt] ' + tensorType + ' 輸入推論失敗，嘗試其他型別：', e);
        }
      }

      if (!results) {
        throw lastError || new Error('ONNX 推論失敗');
      }
      // 帶 KV cache 的模型會同時輸出 present.N.key/value；logits 未必排在第一個，
      // 依名稱取才不會誤把某一層的 cache 當成結果。
      const outputName = results.logits ? 'logits' : Object.keys(results)[0];
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

  function parseRuntime(runtimeJson) {
    if (!runtimeJson) return null;
    try {
      return JSON.parse(runtimeJson);
    } catch (e) {
      console.warn('[omnitraceOrt] runtime 規格解析失敗，忽略：', e);
      return null;
    }
  }

  function makeIntTensor(ort, tensorType, values, shape) {
    if (tensorType === 'int32') {
      return new ort.Tensor('int32', Int32Array.from(values), shape);
    }
    return new ort.Tensor(
      'int64',
      BigInt64Array.from(Array.from(values, (v) => BigInt(v))),
      shape,
    );
  }

  // 依模型實際宣告的輸入組裝 feeds。
  //
  // 分類器只要 input_ids / attention_mask，但 transformers.js 匯出的 causal LM
  // （如 Qwen2.5-0.5B）另外宣告 position_ids 與逐層攤平的 KV cache
  // （24 層 × key/value 共 48 個輸入）。單次前向不需要 cache，餵入
  // past_sequence_length = 0 的空張量即可，但 kv_heads 與 head_dim 是靜態維度，
  // 必須與模型相符——onnxruntime-web 1.19.2 的 inputMetadata 不保證提供形狀，
  // 因此這兩個數字由 Dart 依 catalog 的 runtime 規格帶入，不在此猜測。
  function buildFeeds(ort, tensorType, inputIds, attentionMask, shape, session, runtime) {
    const feeds = {
      input_ids: makeIntTensor(ort, tensorType, inputIds, shape),
      attention_mask: makeIntTensor(ort, tensorType, attentionMask, shape),
    };

    const names = (session && session.inputNames) || [];
    if (names.length === 0) return feeds;

    const [batchSize, seqLen] = shape;

    if (names.indexOf('position_ids') >= 0) {
      const positions = new Array(batchSize * seqLen);
      for (let b = 0; b < batchSize; b++) {
        for (let i = 0; i < seqLen; i++) positions[b * seqLen + i] = i;
      }
      feeds.position_ids = makeIntTensor(ort, tensorType, positions, shape);
    }

    const cacheNames = names.filter((n) => n.indexOf('past_key_values.') === 0);
    if (cacheNames.length > 0) {
      const kv = runtime && runtime.kvCache;
      if (!kv || !kv.heads || !kv.headDim) {
        throw new Error(
          '模型宣告了 ' + cacheNames.length + ' 個 KV cache 輸入，' +
            '但 catalog 未提供 runtime.kv_cache 的 heads/head_dim。' +
            '這兩個是靜態維度，猜錯會直接推論失敗。',
        );
      }
      // past_sequence_length = 0：空張量，但 rank 與靜態維度仍須正確
      const dims = [batchSize, kv.heads, 0, kv.headDim];
      for (const name of cacheNames) {
        feeds[name] = new ort.Tensor('float32', new Float32Array(0), dims);
      }
    }

    return feeds;
  }

  function resolveInputTypes(session) {
    const out = {};
    try {
      const metadata = session.inputMetadata || {};
      for (const name of Object.keys(metadata)) {
        const meta = metadata[name];
        if (meta && typeof meta.type === 'string') out[name] = meta.type;
      }
    } catch (_) {
      /* metadata is best effort */
    }
    return out;
  }

  function errorText(e) {
    return String((e && (e.message || e.toString && e.toString())) || e || '');
  }

  function isDefinitiveTypeError(e, tensorType) {
    const text = errorText(e);
    return (
      text.includes('Unexpected input data type') &&
      text.includes('Actual: (tensor(' + tensorType + '))')
    );
  }

  function mentionsExpectedType(e, tensorType) {
    const text = errorText(e);
    return (
      text.includes('Unexpected input data type') &&
      text.includes('expected: (tensor(' + tensorType + '))')
    );
  }

  function enqueueOrtWork(task) {
    // onnxruntime-web 的部分 execution provider 不允許同一執行環境重入
    // session.run；全域佇列能徹底避免 Session already started / Session mismatch。
    const next = state.runQueue.then(task, task);
    state.runQueue = next.catch(() => {});
    return next;
  }

  function releaseModel(modelId) {
    const entry = state.sessions.get(modelId);
    const session = entry && entry.session ? entry.session : entry;
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

  window.omnitraceOrt = { loadModel, run, runBatch, releaseModel, epKind, ensureOrt };
})();
