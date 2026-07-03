/// 模型 catalog：可下載的開源模型清單（含硬體需求），供首次啟動依裝置能力自動選型。
/// 對應 implementation_plan.md 第五節（分層下載）與第八節（無後端的更新機制）。
///
/// 資料來源：優先抓遠端 catalog（GitHub raw / CDN）取得「目前最新」，
/// 失敗時回退至隨 App 打包的 assets/model_catalog.json。
library;

/// 裝置效能分層
enum PerformanceTier { low, mid, high }

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
  });

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

  factory ModelCatalog.fromJson(Map<String, dynamic> j) => ModelCatalog(
        catalogVersion: j['catalog_version'] as String? ?? 'unknown',
        models: (j['models'] as List)
            .map((m) => CatalogModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}
