/// 模型登記表：對應 implementation_plan.md 第五節（分層下載）與第八節（更新機制）。
/// 每個檢測子模型 / LLM 都是一筆 [ModelSpec]，ModelManager 依此決定下載與安裝狀態。
library;

/// 模型分層（決定何時下載）
enum ModelTier {
  bundled, // 隨 App 安裝（風格分析器 C、OCR）
  core, // 首次啟動下載（分類器 A、統計 B、對抗 D）
  optional, // 選擇性下載（本地端 LLM）
  language, // 選擇性語言包
}

/// 推論後端（決定走哪條原生橋接）
enum InferenceBackend {
  none, // 純 Dart 啟發式（不需模型檔）
  transformer, // TFLite / Core ML / ONNX 分類器
  languageModel, // llama.cpp（LLM）
}

class ModelSpec {
  final String id; // 對應引擎 id 或 'llm'
  final String name;
  final ModelTier tier;
  final InferenceBackend backend;
  final String fileName; // 存於 app support/models 下的檔名
  final int sizeBytes; // 預期大小（用於進度與粗略校驗）
  final String version;
  final String? sha256; // 內容校驗（真模型發佈後填入）
  final String? downloadUrl; // GitHub Releases / CDN；訓練完成後填入

  const ModelSpec({
    required this.id,
    required this.name,
    required this.tier,
    required this.backend,
    required this.fileName,
    required this.sizeBytes,
    required this.version,
    this.sha256,
    this.downloadUrl,
  });

  /// 是否已有可下載來源（尚未訓練發佈者為 false）
  bool get isDownloadable => downloadUrl != null && downloadUrl!.isNotEmpty;
}

/// 目前登記的模型清單。URL/雜湊在對應模型訓練並發佈到 GitHub Releases 後填入；
/// 在那之前 [ModelSpec.isDownloadable] 為 false，UI 會顯示「即將推出」。
const kModelRegistry = <ModelSpec>[
  // 第一版由 training/ 以 HC3（英+中）微調多語言 Transformer 產出，INT8 量化 ONNX
  // （四平台通用 ONNX Runtime）。訓練流程見 training/README.md。
  ModelSpec(
    id: 'transformer',
    name: '多語言 AI 分類器',
    tier: ModelTier.core,
    backend: InferenceBackend.transformer,
    fileName: 'detector_int8.onnx',
    sizeBytes: 135 * 1024 * 1024,
    version: '0.0.0',
  ),
  ModelSpec(
    id: 'statistical',
    name: '統計分析語言模型（DistilGPT2）',
    tier: ModelTier.core,
    backend: InferenceBackend.transformer,
    fileName: 'distilgpt2_ppl_int8.tflite',
    sizeBytes: 80 * 1024 * 1024,
    version: '0.0.0',
  ),
  ModelSpec(
    id: 'adversarial',
    name: '對抗式改寫偵測分類器',
    tier: ModelTier.core,
    backend: InferenceBackend.transformer,
    fileName: 'paraphrase_detector_int8.tflite',
    sizeBytes: 50 * 1024 * 1024,
    version: '0.0.0',
  ),
  ModelSpec(
    id: 'llm',
    name: '報告生成 LLM（Gemma 2B, Q4）',
    tier: ModelTier.optional,
    backend: InferenceBackend.languageModel,
    fileName: 'gemma-2b-it-q4.gguf',
    sizeBytes: 1288 * 1024 * 1024,
    version: '0.0.0',
  ),
];

ModelSpec? modelSpecFor(String id) {
  for (final m in kModelRegistry) {
    if (m.id == id) return m;
  }
  return null;
}
