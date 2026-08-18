/// 模型 catalog：可下載的開源模型清單（含硬體需求），供首次啟動依裝置能力自動選型。
/// 對應 implementation_plan.md 第五節（分層下載）與第八節（無後端的更新機制）。
///
/// 資料來源：優先抓遠端 catalog（GitHub raw / CDN）取得「目前最新」，
/// 失敗時回退至隨 App 打包的 assets/model_catalog.json。
library;

/// 裝置效能分層
enum PerformanceTier { low, mid, high }

/// 模型在推論時額外需要的輸入。
///
/// 分類器只要 input_ids / attention_mask，但 transformers.js 匯出的 causal LM
/// 會另外宣告 position_ids 與逐層攤平的 KV cache。單次前向不需要 cache 內容，
/// 但 kv_heads 與 head_dim 是**靜態維度**，必須與模型相符才能建出合法張量。
///
/// onnxruntime-web 1.19.2 的 inputMetadata 不保證提供形狀，所以這兩個數字
/// 由 catalog 明確宣告，不在執行期猜測——猜錯會直接推論失敗。
class KvCacheSpec {
  final int layers;
  final int heads;
  final int headDim;

  const KvCacheSpec({
    required this.layers,
    required this.heads,
    required this.headDim,
  });

  static KvCacheSpec? fromJson(Map<String, dynamic>? j) {
    if (j == null) return null;
    final layers = (j['layers'] as num?)?.toInt();
    final heads = (j['heads'] as num?)?.toInt();
    final headDim = (j['head_dim'] as num?)?.toInt();
    if (layers == null || heads == null || headDim == null) return null;
    if (layers <= 0 || heads <= 0 || headDim <= 0) return null;
    return KvCacheSpec(layers: layers, heads: heads, headDim: headDim);
  }

  /// 傳給 JS 橋接的表示法。JS 端依模型自己宣告的輸入名稱決定要不要用，
  /// 這裡只負責提供它猜不到的維度。
  Map<String, dynamic> toJson() => {
    'layers': layers,
    'heads': heads,
    'headDim': headDim,
  };
}

class ModelVariant {
  final String id;
  final String name;
  final String backend; // transformer / languageModel
  final List<String> languages; // e.g. ['en'], ['en','zh','multi']
  final String quant; // int8 / fp16 / q4 ...
  final int sizeBytes;
  final int minRamMb; // 執行所需最低 RAM
  final PerformanceTier tier;
  final String? url; // 直接下載連結；null = 尚未提供（顯示「即將推出」）
  final String? tokenizerUrl; // 部分模型的 tokenizer 另檔
  final String? sha256;
  final String version;
  final String source; // 出處（HF repo 等）
  final String license;
  final String note;
  final String? pageUrl; // 模型頁面（HF model page），供「查看/取得最新」
  final String tokenizer; // bert-wordpiece / roberta-bpe / none
  final int aiLabelIndex; // 輸出兩類中代表 AI 的索引（依模型 id2label）

  /// 此模型需要的 KV cache 輸入規格；null 表示模型不宣告 KV cache
  final KvCacheSpec? kvCache;

  const ModelVariant({
    required this.id,
    required this.name,
    required this.backend,
    required this.languages,
    required this.quant,
    required this.sizeBytes,
    required this.minRamMb,
    required this.tier,
    required this.version,
    required this.source,
    required this.license,
    this.note = '',
    this.url,
    this.tokenizerUrl,
    this.sha256,
    this.pageUrl,
    this.tokenizer = 'none',
    this.aiLabelIndex = 1,
    this.kvCache,
  });

  /// 傳給推論橋接的 runtime 規格；不需要額外輸入時為 null
  String? get runtimeJson =>
      kvCache == null ? null : '{"kvCache":${_encode(kvCache!.toJson())}}';

  static String _encode(Map<String, dynamic> map) =>
      '{${map.entries.map((e) => '"${e.key}":${e.value}').join(',')}}';

  bool get isDownloadable => url != null && url!.isNotEmpty;

  /// 檔名依 role + variant 決定，供本地儲存
  String fileName(String role) => '${role}__$id.${_ext()}';
  String _ext() => backend == 'languageModel' ? 'gguf' : 'onnx';

  factory ModelVariant.fromJson(Map<String, dynamic> j) => ModelVariant(
    id: j['id'] as String,
    name: j['name'] as String,
    backend: j['backend'] as String,
    languages: (j['languages'] as List).cast<String>(),
    quant: j['quant'] as String? ?? '',
    sizeBytes: (j['size_bytes'] as num).toInt(),
    minRamMb: (j['min_ram_mb'] as num).toInt(),
    tier: PerformanceTier.values.byName(j['tier'] as String),
    url: j['url'] as String?,
    tokenizerUrl: j['tokenizer_url'] as String?,
    sha256: j['sha256'] as String?,
    version: j['version'] as String? ?? '0',
    source: j['source'] as String? ?? '',
    license: j['license'] as String? ?? '',
    note: j['note'] as String? ?? '',
    pageUrl: j['page_url'] as String?,
    tokenizer: j['tokenizer'] as String? ?? 'none',
    aiLabelIndex: (j['ai_label_index'] as num?)?.toInt() ?? 1,
    kvCache: KvCacheSpec.fromJson(
      (j['runtime'] as Map<String, dynamic>?)?['kv_cache']
          as Map<String, dynamic>?,
    ),
  );
}

class CatalogModel {
  final String role; // transformer / statistical / adversarial / llm
  final String name;
  final List<ModelVariant> variants; // 依品質優先排序（最佳在前）

  const CatalogModel({
    required this.role,
    required this.name,
    required this.variants,
  });

  factory CatalogModel.fromJson(Map<String, dynamic> j) => CatalogModel(
    role: j['role'] as String,
    name: j['name'] as String,
    variants: (j['variants'] as List)
        .map((v) => ModelVariant.fromJson(v as Map<String, dynamic>))
        .toList(),
  );

  /// 依裝置能力挑選最適變體：在可下載且 RAM 足夠的前提下取品質最高者；
  /// 若無可下載者，回退為最小可執行變體（讓 UI 顯示「即將推出」）。
  ModelVariant? bestFor(PerformanceTier tier, int ramMb) {
    bool fits(ModelVariant v) => v.minRamMb <= ramMb;
    final downloadable = variants.where((v) => v.isDownloadable && fits(v));
    if (downloadable.isNotEmpty) return downloadable.first; // 已按品質排序
    final anyFits = variants.where(fits);
    if (anyFits.isNotEmpty) return anyFits.first;
    return variants.isNotEmpty ? variants.last : null; // 最小者
  }
}

class ModelCatalog {
  final String catalogVersion;
  final List<CatalogModel> models;

  const ModelCatalog({required this.catalogVersion, required this.models});

  CatalogModel? forRole(String role) {
    for (final m in models) {
      if (m.role == role) return m;
    }
    return null;
  }

  ModelCatalog withCommunityVariants(List<ModelVariant> extraVariants) {
    if (extraVariants.isEmpty) return this;
    final updatedModels = models.map((m) {
      if (m.role == 'transformer') {
        final existingIds = m.variants.map((v) => v.id).toSet();
        final newVariants = extraVariants
            .where((v) => !existingIds.contains(v.id))
            .toList();
        if (newVariants.isEmpty) return m;
        return CatalogModel(
          role: m.role,
          name: m.name,
          variants: [...m.variants, ...newVariants],
        );
      }
      return m;
    }).toList();
    return ModelCatalog(catalogVersion: catalogVersion, models: updatedModels);
  }

  factory ModelCatalog.fromJson(Map<String, dynamic> j) => ModelCatalog(
    catalogVersion: j['catalog_version'] as String? ?? 'unknown',
    models: (j['models'] as List)
        .map((m) => CatalogModel.fromJson(m as Map<String, dynamic>))
        .toList(),
  );
}
