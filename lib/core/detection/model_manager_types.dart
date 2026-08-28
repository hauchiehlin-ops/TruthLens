/// [ModelManager] 共用的資料型別（原生 io 版與 web 版皆用同一套，
/// 避免在兩個平台實作間重複定義）。純資料，不含任何平台相關程式碼。
library;

import 'package:flutter/foundation.dart';

enum InstallState { notInstalled, downloading, installed, failed }

/// 已安裝變體紀錄（多個變體可同時安裝於同一 role）
class InstalledModel {
  final String role;
  final String variantId;
  final String fileName;
  final String? tokenizerFileName;
  final String tokenizer; // bert-wordpiece / roberta-bpe / none
  final int aiLabelIndex;
  final double aiEvidenceThreshold;
  final String version;
  final int sizeBytes;
  final String? name; // 友善名稱（匯入的模型用）
  final bool imported;
  final String? sha256; // 模型檔內容雜湊，供匯入前偵測重複檔案用

  /// 此模型**經驗證**涵蓋的語言代碼（取自 catalog 的 languages）。
  ///
  /// 'multi' 代表「架構為多語言，但未逐語言驗證」——刻意與明確列出的語言碼
  /// 分開對待：mBERT 架構支援 104 語言，我們只實測過英文與中文，
  /// 拿它對泰文下結論是在宣稱沒有的證據。
  ///
  /// 安裝當下記下；舊版紀錄為空清單，視為涵蓋範圍未知。
  final List<String> languages;

  /// 推論時需要的額外輸入規格（KV cache 的靜態維度），格式見
  /// [ModelVariant.runtimeJson]。安裝當下就記下來，執行期不必再抓 catalog——
  /// 離線也要能正確推論。不需要額外輸入的模型為 null。
  final String? runtimeJson;

  const InstalledModel({
    required this.role,
    required this.variantId,
    required this.fileName,
    required this.version,
    required this.sizeBytes,
    this.tokenizerFileName,
    this.tokenizer = 'none',
    this.aiLabelIndex = 1,
    this.aiEvidenceThreshold = 0.60,
    this.name,
    this.imported = false,
    this.sha256,
    this.runtimeJson,
    this.languages = const [],
  });

  /// 是否**經驗證**涵蓋此語言
  bool validatesLanguage(String language) => languages.contains(language);

  /// 架構上可能支援但未逐語言驗證
  bool plausiblySupports(String language) =>
      !validatesLanguage(language) && languages.contains('multi');

  String get displayName => name ?? variantId;

  Map<String, dynamic> toJson() => {
    'role': role,
    'variant_id': variantId,
    'file_name': fileName,
    'tokenizer_file_name': tokenizerFileName,
    'tokenizer': tokenizer,
    'ai_label_index': aiLabelIndex,
    'ai_evidence_threshold': aiEvidenceThreshold,
    'version': version,
    'size_bytes': sizeBytes,
    'name': name,
    'imported': imported,
    'sha256': sha256,
    'runtime_json': runtimeJson,
    'languages': languages,
  };

  factory InstalledModel.fromJson(Map<String, dynamic> j) {
    try {
      // 詳細類型檢查，防止 null 轉換錯誤
      final role = j['role'] as String?;
      if (role == null || role.isEmpty) {
        throw FormatException('role 欄位缺失或為空');
      }

      final variantId = j['variant_id'] as String?;
      if (variantId == null || variantId.isEmpty) {
        throw FormatException('variant_id 欄位缺失或為空');
      }

      final fileName = j['file_name'] as String?;
      if (fileName == null || fileName.isEmpty) {
        throw FormatException('file_name 欄位缺失或為空');
      }

      // 可選欄位
      final tokenizerFileName = j['tokenizer_file_name'] as String?;
      final tokenizer = j['tokenizer'] as String? ?? 'none';
      final aiLabelIndex = (j['ai_label_index'] as num?)?.toInt() ?? 1;
      final aiEvidenceThreshold =
          (j['ai_evidence_threshold'] as num?)?.toDouble() ?? 0.60;
      final version = j['version'] as String? ?? '0';
      final sizeBytes = (j['size_bytes'] as num?)?.toInt() ?? 0;
      final name = j['name'] as String?;
      final imported = j['imported'] as bool? ?? false;
      final sha256 = j['sha256'] as String?;
      // 舊版紀錄沒有此欄位；null 代表模型不需要額外輸入，正是既有模型的情況
      final runtimeJson = j['runtime_json'] as String?;
      final languages = (j['languages'] as List?)?.whereType<String>().toList();

      return InstalledModel(
        role: role,
        variantId: variantId,
        fileName: fileName,
        tokenizerFileName: tokenizerFileName,
        tokenizer: tokenizer,
        aiLabelIndex: aiLabelIndex,
        aiEvidenceThreshold: aiEvidenceThreshold,
        version: version,
        sizeBytes: sizeBytes,
        name: name,
        imported: imported,
        sha256: sha256,
        runtimeJson: runtimeJson,
        languages: languages ?? const [],
      );
    } catch (e) {
      debugPrint('[InstalledModel] ❌ 解析失敗: $e');
      debugPrint('[InstalledModel]    原始數據: $j');
      rethrow;
    }
  }
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
  }) => RoleState(
    role: role,
    installed: installed ?? this.installed,
    activeVariantId: activeVariantId ?? this.activeVariantId,
    transientState: transientState ?? this.transientState,
    downloadingVariantId: downloadingVariantId,
    progress: progress ?? this.progress,
    error: error,
  );
}
