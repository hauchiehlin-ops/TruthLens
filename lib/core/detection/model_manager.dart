import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'model_catalog.dart';
import 'model_catalog_service.dart';
import 'model_registry.dart';
import 'onnx_detector.dart';

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

/// 模型檔案管理：支援每個 role 並存多個變體、切換使用中變體、下載 / 刪除 / 更新。
/// 狀態持久化於 models/installed.json。目錄與 http client 可注入以供測試。
class ModelManager extends ChangeNotifier {
  final http.Client _client;
  final Directory? _dirOverride;

  final Map<String, RoleState> _roles = {
    for (final m in kModelRegistry) m.id: RoleState(role: m.id),
  };

  ModelManager({http.Client? client, Directory? modelsDir})
      : _client = client ?? http.Client(),
        _dirOverride = modelsDir;

  RoleState? roleState(String role) => _roles[role];

  Set<String> _rolesWithUpdate = {};

  /// 是否有任一角色偵測到可用更新（供設定頁／首頁顯示提示徽章）。
  bool get hasAnyUpdate => _rolesWithUpdate.isNotEmpty;
  bool roleHasUpdate(String role) => _rolesWithUpdate.contains(role);

  /// 主動連線抓取最新 catalog，比對所有已安裝角色的使用中版本是否落後。
  /// 應用程式啟動時呼叫一次即可；離線或抓取失敗時靜默略過，不視為錯誤
  /// （catalog 服務本身已有「遠端優先、失敗回退本地資產」的機制）。
  Future<void> checkForUpdates(ModelCatalogService catalogService) async {
    try {
      final catalog = await catalogService.load();
      final updated = <String>{};
      for (final role in _roles.keys) {
        final active = activeVariant(role);
        if (active == null) continue;
        final variants = catalog.forRole(role)?.variants ?? const [];
        ModelVariant? variant;
        for (final v in variants) {
          if (v.id == active.variantId) {
            variant = v;
            break;
          }
        }
        if (variant != null && hasUpdate(role, variant)) {
          updated.add(role);
        }
      }
      if (updated.length != _rolesWithUpdate.length ||
          !updated.containsAll(_rolesWithUpdate)) {
        _rolesWithUpdate = updated;
        notifyListeners();
      }
    } catch (_) {
      // 離線／連線失敗：保留目前已知狀態，不中斷使用者流程。
    }
  }
  Iterable<RoleState> get roles => _roles.values;

  Future<Directory> _modelsDir() async {
    final override = _dirOverride;
    if (override != null) return override;
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'models'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<File> _manifestFile() async =>
      File(p.join((await _modelsDir()).path, 'installed.json'));

  // 持久化格式：{ role: { active: variantId, installed: { variantId: InstalledModel } } }
  Future<void> _persist() async {
    final f = await _manifestFile();
    final map = <String, dynamic>{};
    for (final r in _roles.values) {
      if (r.installed.isEmpty) continue;
      map[r.role] = {
        'active': r.activeVariantId,
        'installed':
            r.installed.map((k, v) => MapEntry(k, v.toJson())),
      };
    }
    f.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(map));
  }

  /// 開機掃描 installed.json 與檔案，重建每個 role 的安裝狀態（含清理遺失檔案）。
  Future<void> refreshInstallStates() async {
    final f = await _manifestFile();
    final dir = await _modelsDir();
    Map<String, dynamic> raw = {};
    if (f.existsSync()) {
      try {
        raw = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      } catch (_) {}
    }

    for (final role in _roles.keys.toList()) {
      final entry = raw[role] as Map<String, dynamic>?;
      final installed = <String, InstalledModel>{};
      if (entry != null) {
        final inst = (entry['installed'] as Map<String, dynamic>?) ?? {};
        inst.forEach((variantId, v) {
          final model = InstalledModel.fromJson(v as Map<String, dynamic>);
          if (File(p.join(dir.path, model.fileName)).existsSync()) {
            installed[variantId] = model;
          }
        });
      }
      // Auto-scan: list all files in directory and register them if they match known variant filenames
      try {
        if (dir.existsSync()) {
          for (final entity in dir.listSync()) {
            if (entity is File) {
              final name = p.basename(entity.path);
              if (name == 'gemma-2b-it-q4.gguf' || name == 'llm__gemma-2b-it-q4.gguf') {
                if (role == 'llm' && !installed.containsKey('gemma-2b-it-q4')) {
                  installed['gemma-2b-it-q4'] = InstalledModel(
                    role: 'llm',
                    variantId: 'gemma-2b-it-q4',
                    fileName: name,
                    version: '1.0',
                    sizeBytes: entity.lengthSync(),
                  );
                }
              } else if (name == 'detector_int8.onnx' || name == 'transformer__truthlens-multilingual-distil-int8.onnx') {
                // 分類器需要 tokenizer；只有在同目錄真的有 tokenizer.json 時才登記，
                // 否則登記了也無法推論（避免掃到缺 tokenizer 的孤兒模型）。
                final tokName = File(p.join(dir.path, 'tokenizer.json')).existsSync()
                    ? 'tokenizer.json'
                    : null;
                if (role == 'transformer' &&
                    tokName != null &&
                    !installed.containsKey('truthlens-multilingual-distil-int8')) {
                  installed['truthlens-multilingual-distil-int8'] = InstalledModel(
                    role: 'transformer',
                    variantId: 'truthlens-multilingual-distil-int8',
                    fileName: name,
                    tokenizerFileName: tokName,
                    tokenizer: 'bert-wordpiece',
                    aiLabelIndex: 1,
                    version: '1.0.0',
                    sizeBytes: entity.lengthSync(),
                  );
                }
              }
            }
          }
        }
      } catch (_) {}
      var active = entry?['active'] as String?;
      if (active == null || !installed.containsKey(active)) {
        active = installed.keys.isNotEmpty ? installed.keys.first : null;
      }
      _roles[role] = RoleState(
        role: role,
        installed: installed,
        activeVariantId: active,
        transientState: installed.isNotEmpty
            ? InstallState.installed
            : InstallState.notInstalled,
        progress: installed.isNotEmpty ? 1 : 0,
      );
    }
    await _backfillMissingHashes(dir);
    await _persist();
    notifyListeners();
  }

  /// 為舊資料（本功能上線前已匯入、尚無 sha256）的自訂匯入模型補算雜湊，
  /// 讓「匯入前偵測重複檔案」對這些既有項目也能生效，不必要求使用者重新匯入。
  Future<void> _backfillMissingHashes(Directory dir) async {
    for (final role in _roles.keys.toList()) {
      final r = _roles[role]!;
      if (r.installed.isEmpty) continue;
      var changed = false;
      final updated = <String, InstalledModel>{};
      for (final entry in r.installed.entries) {
        final m = entry.value;
        if (m.imported && m.sha256 == null) {
          final file = File(p.join(dir.path, m.fileName));
          if (file.existsSync()) {
            try {
              final hash = await _sha256Of(file);
              updated[entry.key] = InstalledModel(
                role: m.role,
                variantId: m.variantId,
                fileName: m.fileName,
                tokenizerFileName: m.tokenizerFileName,
                tokenizer: m.tokenizer,
                aiLabelIndex: m.aiLabelIndex,
                version: m.version,
                sizeBytes: m.sizeBytes,
                name: m.name,
                imported: m.imported,
                sha256: hash,
              );
              changed = true;
              continue;
            } catch (_) {
              // 讀取失敗則略過，保留原項目（不含 sha256）
            }
          }
        }
        updated[entry.key] = m;
      }
      if (changed) {
        _roles[role] = r.copyWith(installed: updated);
      }
    }
  }

  bool isInstalled(String role) => _roles[role]?.hasInstalled ?? false;
  bool isVariantInstalled(String role, String variantId) =>
      _roles[role]?.installed.containsKey(variantId) ?? false;
  InstalledModel? activeVariant(String role) => _roles[role]?.active;
  List<InstalledModel> installedVariants(String role) =>
      _roles[role]?.installed.values.toList() ?? const [];

  /// 可實際執行推論的引擎（有使用中的已安裝變體 + 原生後端）
  bool canRunEngine(String role) {
    final spec = modelSpecFor(role);
    if (spec == null || spec.backend == InferenceBackend.none) return false;
    return activeVariant(role) != null;
  }

  /// 使用中變體的模型檔絕對路徑（供推論引擎載入）
  Future<String?> activeModelPath(String role) async {
    final active = activeVariant(role);
    if (active == null) return null;
    return p.join((await _modelsDir()).path, active.fileName);
  }

  Future<String?> activeTokenizerPath(String role) async {
    final active = activeVariant(role);
    if (active?.tokenizerFileName == null) return null;
    return p.join((await _modelsDir()).path, active!.tokenizerFileName!);
  }

  /// 切換使用中變體（應用程式運行前可自由更換模型）
  Future<void> setActive(String role, String variantId) async {
    final r = _roles[role];
    if (r == null || !r.installed.containsKey(variantId)) return;
    _roles[role] = r.copyWith(activeVariantId: variantId);
    await _persist();
    notifyListeners();
  }

  /// 需要更新：已安裝的使用中變體版本落後於 catalog 提供的版本
  bool hasUpdate(String role, ModelVariant catalogVariant) {
    final installed = _roles[role]?.installed[catalogVariant.id];
    if (installed == null) return false;
    // 正規化版本號（將 1.0.0 與 1.0 視為相同）
    final v1 = installed.version.replaceAll('.0', '');
    final v2 = catalogVariant.version.replaceAll('.0', '');
    return v1 != v2;
  }

  /// 下載並安裝變體。首個安裝的變體自動設為使用中。回傳 true 表示成功。
  Future<bool> downloadVariant(String role, ModelVariant variant) async {
    if (!variant.isDownloadable) {
      _mark(role, InstallState.failed, error: '此變體尚未提供下載來源');
      return false;
    }
    _mark(role, InstallState.downloading,
        downloadingVariantId: variant.id, progress: 0);
    final dir = await _modelsDir();
    final fileName = variant.fileName(role);
    final target = File(p.join(dir.path, fileName));
    final tmp = File('${target.path}.part');
    String? tokenizerFileName;

    try {
      await _streamDownload(variant.url!, tmp, expected: variant.sizeBytes,
          onProgress: (r) {
        _mark(role, InstallState.downloading,
            downloadingVariantId: variant.id, progress: r);
      });

      if (variant.sha256 != null) {
        final digest = await _sha256Of(tmp);
        if (digest != variant.sha256) {
          await tmp.delete();
          throw const FormatException('校驗和不符，檔案可能損毀');
        }
      }

      if (variant.tokenizerUrl != null) {
        tokenizerFileName = '${role}__${variant.id}.tokenizer.json';
        await _streamDownload(
            variant.tokenizerUrl!, File(p.join(dir.path, tokenizerFileName)));
      }

      if (target.existsSync()) await target.delete();
      await tmp.rename(target.path); // 原子替換（熱替換 / 更新）

      final r = _roles[role]!;
      final installed = Map<String, InstalledModel>.from(r.installed);
      installed[variant.id] = InstalledModel(
        role: role,
        variantId: variant.id,
        fileName: fileName,
        tokenizerFileName: tokenizerFileName,
        tokenizer: variant.tokenizer,
        aiLabelIndex: variant.aiLabelIndex,
        version: variant.version,
        sizeBytes: variant.sizeBytes,
      );
      _roles[role] = r.copyWith(
        installed: installed,
        activeVariantId: r.activeVariantId ?? variant.id, // 首個自動設為使用中
        transientState: InstallState.installed,
        progress: 1,
      );
      await _persist();
      notifyListeners();
      return true;
    } catch (e) {
      if (tmp.existsSync()) await tmp.delete();
      _mark(role, InstallState.failed,
          downloadingVariantId: variant.id, error: e.toString());
      return false;
    }
  }

  /// 移除指定變體。若移除的是使用中變體，改用其餘任一變體或清空。
  Future<void> removeVariant(String role, String variantId) async {
    final r = _roles[role];
    if (r == null) return;
    final entry = r.installed[variantId];
    if (entry == null) return;
    final dir = await _modelsDir();
    final f = File(p.join(dir.path, entry.fileName));
    if (f.existsSync()) await f.delete();
    if (entry.tokenizerFileName != null) {
      final tok = File(p.join(dir.path, entry.tokenizerFileName!));
      if (tok.existsSync()) await tok.delete();
    }
    final installed = Map<String, InstalledModel>.from(r.installed)
      ..remove(variantId);
    var active = r.activeVariantId;
    if (active == variantId) {
      active = installed.keys.isNotEmpty ? installed.keys.first : null;
    }
    _roles[role] = RoleState(
      role: role,
      installed: installed,
      activeVariantId: active,
      transientState: installed.isNotEmpty
          ? InstallState.installed
          : InstallState.notInstalled,
      progress: installed.isNotEmpty ? 1 : 0,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> _streamDownload(String url, File dest,
      {int? expected, void Function(double)? onProgress}) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await _client.send(request);
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}');
    }
    final total = response.contentLength ?? expected ?? 0;
    final sink = dest.openWrite();
    var received = 0;
    await for (final chunk in response.stream) {
      sink.add(chunk);
      received += chunk.length;
      if (onProgress != null && total > 0) {
        onProgress((received / total).clamp(0, 1));
      }
    }
    await sink.close();
  }

  /// 匯入本機 ONNX 模型檔。
  Future<bool> importLocalModel({
    required String role,
    required String name,
    required File modelFile,
    File? tokenizerFile,
    String tokenizerType = 'bert-wordpiece',
    int aiLabelIndex = 1,
  }) async {
    final dir = await _modelsDir();
    final variantId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final fileName = '${role}__$variantId.onnx';
    final target = File(p.join(dir.path, fileName));

    String? tokenizerFileName;

    try {
      // 複製模型檔
      await modelFile.copy(target.path);
      final hash = await _sha256Of(target);

      // 複製 tokenizer 檔
      if (tokenizerFile != null && tokenizerType != 'none') {
        tokenizerFileName = '${role}__$variantId.tokenizer.json';
        await tokenizerFile.copy(p.join(dir.path, tokenizerFileName));
      }

      final r = _roles[role]!;
      final installed = Map<String, InstalledModel>.from(r.installed);
      installed[variantId] = InstalledModel(
        role: role,
        variantId: variantId,
        fileName: fileName,
        tokenizerFileName: tokenizerFileName,
        tokenizer: tokenizerType,
        aiLabelIndex: aiLabelIndex,
        version: '1.0.0 (自訂匯入)',
        sizeBytes: modelFile.lengthSync(),
        name: name,
        imported: true,
        sha256: hash,
      );

      _roles[role] = r.copyWith(
        installed: installed,
        activeVariantId: variantId, // 自動設為使用中
        transientState: InstallState.installed,
        progress: 1,
      );

      await _persist();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Failed to import local model: $e');
      return false;
    }
  }

  /// 計算檔案的 sha256（公開方法，供 UI 在匯入前比對是否已存在相同內容的模型）。
  Future<String> hashOf(File file) => _sha256Of(file);

  /// 依內容雜湊尋找是否已有相同的已安裝模型（跨所有角色搜尋）。
  /// 用於匯入前提醒使用者「這個檔案可能已經匯入過了」，避免不小心重複匯入。
  InstalledModel? findByHash(String sha256) {
    for (final r in _roles.values) {
      for (final m in r.installed.values) {
        if (m.sha256 == sha256) return m;
      }
    }
    return null;
  }

  /// 測試單一 ONNX 模型，回傳 AI 機率（0..1）。用於匯入前預覽與驗證。
  /// 先把選取的檔案複製進 App 容器再載入：原生 ONNX Runtime 在沙盒下無法直接
  /// 開啟容器外的使用者選取檔（會出現 system error 1），複製後即可穩定載入，
  /// 也讓「測試」與「匯入」走同一條（容器內）路徑，行為一致。
  Future<double> testModel({
    required File modelFile,
    File? tokenizerFile,
    String tokenizerType = 'bert-wordpiece',
    int aiLabelIndex = 1,
    required String text,
  }) async {
    final dir = await _modelsDir();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final tmpModel = File(p.join(dir.path, '_test_$stamp.onnx'));
    final tmpTok = tokenizerFile == null
        ? null
        : File(p.join(dir.path, '_test_$stamp.tokenizer.json'));
    OnnxDetector? detector;
    try {
      await modelFile.copy(tmpModel.path);
      if (tokenizerFile != null && tmpTok != null) {
        await tokenizerFile.copy(tmpTok.path);
      }
      detector = await OnnxDetector.load(
        modelPath: tmpModel.path,
        tokenizerJsonPath: tmpTok?.path ?? '',
        tokenizerType: tokenizerType,
        aiLabelIndex: aiLabelIndex,
      );
      return await detector.classify(text);
    } finally {
      detector?.dispose();
      if (tmpModel.existsSync()) await tmpModel.delete();
      if (tmpTok != null && tmpTok.existsSync()) await tmpTok.delete();
    }
  }

  Future<String> _sha256Of(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  void _mark(String role, InstallState state,
      {String? downloadingVariantId, double? progress, String? error}) {
    final r = _roles[role]!;
    _roles[role] = r.copyWith(
      transientState: state,
      downloadingVariantId: downloadingVariantId,
      progress: progress ?? (state == InstallState.downloading ? 0 : r.progress),
      error: error,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
