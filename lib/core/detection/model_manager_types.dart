/// [ModelManager] 共用的資料型別（原生 io 版與 web 版皆用同一套，
/// 避免在兩個平台實作間重複定義）。純資料，不含任何平台相關程式碼。
library;

enum InstallState { notInstalled, downloading, installed, failed }

/// 已安裝變體紀錄（多個變體可同時安裝於同一 role）
class InstalledModel {
  final String role;
  final String variantId;
  final String fileName;
  final String? tokenizerFileName;
  final String tokenizer; // bert-wordpiece / roberta-bpe / none
  final int aiLabelIndex;
  final String version;
  final int sizeBytes;
  final String? name; // 友善名稱（匯入的模型用）
  final bool imported;
  final String? sha256; // 模型檔內容雜湊，供匯入前偵測重複檔案用

  const InstalledModel({
    required this.role,
    required this.variantId,
    required this.fileName,
    required this.version,
    required this.sizeBytes,
    this.tokenizerFileName,
    this.tokenizer = 'none',
    this.aiLabelIndex = 1,
    this.name,
    this.imported = false,
    this.sha256,
  });

  String get displayName => name ?? variantId;

  Map<String, dynamic> toJson() => {
        'role': role,
        'variant_id': variantId,
        'file_name': fileName,
        'tokenizer_file_name': tokenizerFileName,
        'tokenizer': tokenizer,
        'ai_label_index': aiLabelIndex,
        'version': version,
        'size_bytes': sizeBytes,
        'name': name,
        'imported': imported,
        'sha256': sha256,
      };

  factory InstalledModel.fromJson(Map<String, dynamic> j) => InstalledModel(
        role: j['role'] as String,
        variantId: j['variant_id'] as String,
        fileName: j['file_name'] as String,
        tokenizerFileName: j['tokenizer_file_name'] as String?,
        tokenizer: j['tokenizer'] as String? ?? 'none',
        aiLabelIndex: (j['ai_label_index'] as num?)?.toInt() ?? 1,
        version: j['version'] as String? ?? '0',
        sizeBytes: (j['size_bytes'] as num?)?.toInt() ?? 0,
        name: j['name'] as String?,
        imported: j['imported'] as bool? ?? false,
        sha256: j['sha256'] as String?,
      );
}

/// 單一 role 的安裝狀態（可含多個已安裝變體 + 使用中變體 + 下載進度）
class RoleState {
  final String role;
  final Map<String, InstalledModel> installed; // variantId -> 紀錄
  final String? activeVariantId;
  final InstallState transientState; // 目前下載活動（idle 以 installed/notInstalled 表示）
  final String? downloadingVariantId;
  final double progress;
  final String? error;

  const RoleState({
    required this.role,
    this.installed = const {},
    this.activeVariantId,
    this.transientState = InstallState.notInstalled,
    this.downloadingVariantId,
    this.progress = 0,
    this.error,
  });

  bool get hasInstalled => installed.isNotEmpty;
  InstalledModel? get active =>
      activeVariantId == null ? null : installed[activeVariantId];

  RoleState copyWith({
    Map<String, InstalledModel>? installed,
    String? activeVariantId,
    InstallState? transientState,
    String? downloadingVariantId,
    double? progress,
    String? error,
  }) =>
      RoleState(
        role: role,
        installed: installed ?? this.installed,
        activeVariantId: activeVariantId ?? this.activeVariantId,
        transientState: transientState ?? this.transientState,
        downloadingVariantId: downloadingVariantId,
        progress: progress ?? this.progress,
        error: error,
      );
}
