// OmniTrace ONNX Runtime 共用核心：同時供主執行緒（ort_bridge.js）與模型專屬
// Web Worker（ort_worker.js）使用，確保兩條路徑的 session 建立、輸入組裝與
// 輸出解讀完全一致。本檔不持有任何狀態。
(function (scope) {
  const ORT_VERSION = '1.30.0';
  const ORT_CDN = 'https://cdn.jsdelivr.net/npm/onnxruntime-web@' + ORT_VERSION + '/dist/';

  function loadScriptInPage(src) {
    return new Promise((resolve, reject) => {
      const el = document.createElement('script');
      el.src = src;
      el.onload = () => resolve();
      el.onerror = () => reject(new Error('無法載入 ' + src));
      document.head.appendChild(el);
    });
  }

  async function loadScript(src) {
    if (typeof importScripts === 'function') {
      importScripts(src);
      return;
    }
    await loadScriptInPage(src);
  }

  // 載入 onnxruntime-web 並設定 wasm 路徑與執行緒數。本地自我托管優先，
  // 失敗才退回 CDN（同版本）。
  async function loadOrt(ortBase, useGpu, numThreads) {
    const file = useGpu ? 'ort.webgpu.min.js' : 'ort.wasm.min.js';
    try {
      await loadScript(ortBase + file);
    } catch (e) {
      console.warn('[omnitraceOrt] 本地 script 載入失敗，嘗試 CDN：', e);
      await loadScript(ORT_CDN + file);
    }
    if (!scope.ort) throw new Error('onnxruntime-web 載入後未初始化');
    scope.ort.env.wasm.wasmPaths = ortBase;
    scope.ort.env.wasm.numThreads = numThreads;
    return scope.ort;
  }

  function isCrossOriginIsolated() {
    return (
      typeof crossOriginIsolated !== 'undefined' &&
      crossOriginIsolated &&
      typeof SharedArrayBuffer !== 'undefined'
    );
  }

  async function createSession(ort, bytes, useGpu) {
    const tryProviders = [];
    if (useGpu) tryProviders.push(['webgpu', 'wasm']);
    tryProviders.push(['wasm']);

    let lastError;
    for (const eps of tryProviders) {
      try {
        const session = await ort.InferenceSession.create(bytes, { executionProviders: eps });
        return { session, ep: eps[0] };
      } catch (e) {
        lastError = e;
        console.warn('[omnitraceOrt] ' + eps.join('/') + ' 建立 session 失敗，嘗試後續 provider：', e);
      }
    }

    // 若因 wasm 尋徑或執行緒設定導致建立失敗，以 CDN wasmPaths 與單執行緒作為最後防線
    try {
      ort.env.wasm.wasmPaths = ORT_CDN;
      ort.env.wasm.numThreads = 1;
      const session = await ort.InferenceSession.create(bytes, { executionProviders: ['wasm'] });
      return { session, ep: 'wasm' };
    } catch (fallbackError) {
      console.error('[omnitraceOrt] 所有 ONNX Runtime session 建立方式皆失敗：', fallbackError);
      throw lastError || fallbackError;
    }
  }

  function resolveInputTypes(session) {
    const out = {};
    try {
      const metadata = session.inputMetadata;
      if (Array.isArray(metadata)) {
        // 1.20+ 以陣列提供 { name, type, ... }
        for (const meta of metadata) {
          if (meta && typeof meta.name === 'string' && typeof meta.type === 'string') {
            out[meta.name] = meta.type;
          }
        }
      } else if (metadata) {
        for (const name of Object.keys(metadata)) {
          const meta = metadata[name];
          if (meta && typeof meta.type === 'string') out[name] = meta.type;
        }
      }
    } catch (_) {
      /* metadata is best effort */
    }
    return out;
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
  // 必須與模型相符——inputMetadata 不保證提供形狀，
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

  function parseRuntime(runtimeJson) {
    if (!runtimeJson) return null;
    try {
      return JSON.parse(runtimeJson);
    } catch (e) {
      console.warn('[omnitraceOrt] runtime 規格解析失敗，忽略：', e);
      return null;
    }
  }

  // 執行一次推論，回傳 { data: Float32Array | Float64Array, dims: number[] }。
  // 型別化陣列可直接以 transfer 方式跨越 Worker 邊界，不必逐元素複製。
  async function runSession(ort, entry, inputIds, attentionMask, batchSize, seqLen, runtimeJson) {
    const session = entry.session;
    const shape = [batchSize, seqLen];
    const runtime = parseRuntime(runtimeJson);
    const inputTypes = entry.inputTypes || {};
    const firstType = inputTypes.input_ids || inputTypes.input || 'int64';
    const typeOrder = firstType === 'int32' ? ['int32', 'int64'] : ['int64', 'int32'];
    let results;
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
    const raw = output.data;
    let data;
    if (raw instanceof Float32Array) {
      data = raw.slice();
    } else {
      data = Float64Array.from(raw, (v) => Number(v));
    }
    const dims = Array.from(output.dims, (v) => Number(v));
    for (const name of Object.keys(results)) {
      const tensor = results[name];
      if (tensor && typeof tensor.dispose === 'function') {
        try {
          tensor.dispose();
        } catch (_) {
          /* ignore */
        }
      }
    }
    return { data, dims };
  }

  // 動態量化（quantize_dynamic）的 activation scale 依整個輸入張量計算，
  // 同批其他句子會改變某句的分數，因此這類模型只能逐句推論。這些 op 名稱
  // 以明文存在 ONNX protobuf 的 node.op_type 中，掃描位元組即可判斷，不必解析。
  const DYNAMIC_QUANT_OPS = [
    'DynamicQuantizeLinear',
    'DynamicQuantizeMatMul',
    'DynamicQuantizeLSTM',
    'QAttention',
  ];

  function containsAscii(bytes, text) {
    const first = text.charCodeAt(0);
    const last = bytes.length - text.length;
    let i = bytes.indexOf(first);
    while (i !== -1 && i <= last) {
      let match = true;
      for (let j = 1; j < text.length; j++) {
        if (bytes[i + j] !== text.charCodeAt(j)) {
          match = false;
          break;
        }
      }
      if (match) return true;
      i = bytes.indexOf(first, i + 1);
    }
    return false;
  }

  function usesDynamicQuantization(bytes) {
    return DYNAMIC_QUANT_OPS.some((op) => containsAscii(bytes, op));
  }

  scope.omnitraceOrtCore = {
    usesDynamicQuantization,
    ORT_VERSION,
    loadOrt,
    isCrossOriginIsolated,
    createSession,
    resolveInputTypes,
    runSession,
  };
})(typeof self !== 'undefined' ? self : window);
