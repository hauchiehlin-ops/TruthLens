// 單一模型專屬的 ONNX Runtime Worker。
//
// 每個模型（transformer / adversarial / statistical）各自擁有一個 Worker 與
// 一份 onnxruntime-web 執行環境，因此不同模型可以真正平行推論，也不會佔用
// UI 執行緒。同一 Worker 內的請求依序執行——onnxruntime-web 不允許同一
// session 重入 run。
importScripts('ort_core.js');

const core = self.omnitraceOrtCore;
let ortPromise = null;
let config = null;
const sessions = new Map();
let queue = Promise.resolve();

async function handle(type, payload) {
  switch (type) {
    case 'init': {
      config = payload;
      ortPromise = core.loadOrt(payload.ortBase, payload.useGpu, payload.numThreads);
      await ortPromise;
      return null;
    }
    case 'load': {
      const ort = await ortPromise;
      release(payload.modelId);
      const { session, ep } = await core.createSession(
        ort,
        new Uint8Array(payload.bytes),
        config.useGpu,
      );
      sessions.set(payload.modelId, { session, inputTypes: core.resolveInputTypes(session) });
      return { result: ep };
    }
    case 'run': {
      const ort = await ortPromise;
      const entry = sessions.get(payload.modelId);
      if (!entry) throw new Error('模型尚未載入：' + payload.modelId);
      const out = await core.runSession(
        ort,
        entry,
        payload.inputIds,
        payload.attentionMask,
        payload.batchSize,
        payload.seqLen,
        payload.runtimeJson,
      );
      return { result: out, transfer: [out.data.buffer] };
    }
    case 'release': {
      release(payload.modelId);
      return null;
    }
    default:
      throw new Error('未知的 Worker 指令：' + type);
  }
}

function release(modelId) {
  const entry = sessions.get(modelId);
  if (!entry) return;
  try {
    entry.session.release();
  } catch (_) {
    /* ignore */
  }
  sessions.delete(modelId);
}

self.onmessage = (event) => {
  const { id, type, payload } = event.data;
  const task = () => handle(type, payload);
  const next = queue.then(task, task);
  queue = next.catch(() => {});
  next.then(
    (out) => {
      const result = out ? out.result : null;
      self.postMessage({ id, ok: true, result }, (out && out.transfer) || []);
    },
    (error) => {
      self.postMessage({
        id,
        ok: false,
        error: String((error && (error.message || error)) || error),
      });
    },
  );
};
