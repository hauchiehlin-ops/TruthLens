// TruthLens Web 推論橋接：包裝 onnxruntime-web，供 Dart (dart:js_interop) 呼叫。
// 所有檔案皆自我托管於 assets/ort/（不使用 CDN），符合本地優先原則——
// 推論運算全程在瀏覽器（WASM / WebGPU）內完成，不上傳模型或文本。
//
// EP 選擇：偵測到 navigator.gpu 時優先載入 WebGPU 版 bundle，失敗（不支援的算子等）
// 時於執行期自動退回 WASM SIMD 版；沒有 navigator.gpu 的瀏覽器則直接載入較小的 WASM 版。
(function () {
  const ORT_BASE = 'assets/ort/';

  const state = {
    ortPromise: null,
    epKind: null, // 'webgpu' | 'wasm'
    sessions: new Map(),
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
      const hasGpu = typeof navigator !== 'undefined' && !!navigator.gpu;
      state.epKind = hasGpu ? 'webgpu' : 'wasm';
      const script = hasGpu ? ORT_BASE + 'ort.webgpu.min.js' : ORT_BASE + 'ort.wasm.min.js';
      await loadScript(script);
      if (!window.ort) throw new Error('onnxruntime-web 載入後未初始化');
      // 自我托管 wasm 檔案（不打 CDN），關閉多執行緒以免要求 COOP/COEP 標頭
      // （開發伺服器預設未設定跨來源隔離；正式部署可加上標頭後改回多執行緒）。
      window.ort.env.wasm.wasmPaths = ORT_BASE;
      window.ort.env.wasm.numThreads = 1;
      return window.ort;
    })();
    return state.ortPromise;
  }

  async function loadModel(modelId, modelBytes) {
    const ort = await ensureOrt();
    const bytes = modelBytes instanceof Uint8Array ? modelBytes : new Uint8Array(modelBytes);
    const tryEps = state.epKind === 'webgpu' ? ['webgpu', 'wasm'] : ['wasm'];
    let session;
    let usedEp = state.epKind;
    try {
      session = await ort.InferenceSession.create(bytes, { executionProviders: tryEps });
    } catch (e) {
      console.warn('[truthlensOrt] ' + tryEps.join('/') + ' 建立 session 失敗，改用 wasm：', e);
      session = await ort.InferenceSession.create(bytes, { executionProviders: ['wasm'] });
      usedEp = 'wasm';
    }
    state.sessions.set(modelId, session);
    return usedEp;
  }

  async function run(modelId, inputIds, attentionMask, seqLen) {
    const ort = window.ort;
    const session = state.sessions.get(modelId);
    if (!session || !ort) throw new Error('模型尚未載入：' + modelId);
    const shape = [1, seqLen];
    const ids = BigInt64Array.from(inputIds.map((v) => BigInt(v)));
    const mask = BigInt64Array.from(attentionMask.map((v) => BigInt(v)));
    const feeds = {
      input_ids: new ort.Tensor('int64', ids, shape),
      attention_mask: new ort.Tensor('int64', mask, shape),
    };
    const results = await session.run(feeds);
    const outputName = Object.keys(results)[0];
    const output = results[outputName];
    return { data: Array.from(output.data), dims: Array.from(output.dims) };
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
