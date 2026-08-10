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
import 'model_manager_types.dart';
import 'model_registry.dart';
import 'onnx_detector.dart';

export 'model_manager_types.dart';

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
  /// 詳細日誌記錄於 debugPrint，用於診斷模型安裝失敗原因。
  Future<void> refreshInstallStates() async {
    final f = await _manifestFile();
    final dir = await _modelsDir();
    Map<String, dynamic> raw = {};
    debugPrint('[ModelManager] === refreshInstallStates() 開始 ===');
    debugPrint('[ModelManager] 模型目錄: ${dir.path}');
    if (f.existsSync()) {
      try {
        raw = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
        debugPrint('[ModelManager] 讀入 installed.json，包含 ${raw.keys.length} 個 role');
      } catch (e) {
        debugPrint('[ModelManager] ❌ installed.json 解析失敗: $e');
      }
    } else {
      debugPrint('[ModelManager] 無 installed.json，首次掃描');
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
      // 動態掃描：偵測所有 ${role}__*.onnx / *.tflite / *.gguf 檔案並動態註冊
      try {
        if (dir.existsSync()) {
          for (final entity in dir.listSync()) {
            if (entity is File) {
              final name = p.basename(entity.path);

              // 配對 ${role}__${variantId}.onnx / .tflite / .gguf 的通用格式
              final rolePrefix = '${role}__';
              if (name.startsWith(rolePrefix)) {
                final withoutPrefix = name.substring(rolePrefix.length);
                final extension = p.extension(name);
                if (['.onnx', '.tflite', '.gguf'].contains(extension)) {
                  // 從檔名提取 variantId（去掉副檔名）
                  final variantId = withoutPrefix.substring(0, withoutPrefix.length - extension.length);

                  if (!installed.containsKey(variantId)) {
                    // Transformer / Adversarial 分類器強制需要 tokenizer；
                    // Statistical 有啟發式回退（無模型可用），LLM 不需 tokenizer
                    bool shouldRegister = true;
                    String? tokName;

                    if ((role == 'transformer' || role == 'adversarial') &&
                        ['.onnx', '.tflite'].contains(extension)) {
                      // 強制檢查 tokenizer 是否存在且格式完整
                      final tokFile = File(p.join(dir.path, '${role}__$variantId.tokenizer.json'));
                      debugPrint('[ModelManager] 檢查 $role/$variantId 的 tokenizer...');
                      if (!tokFile.existsSync()) {
                        debugPrint('[ModelManager]   ❌ Tokenizer 不存在: ${tokFile.path}');
                        shouldRegister = false; // 缺 tokenizer，不註冊
                      } else {
                        try {
                          final content = tokFile.readAsStringSync();
                          final sizeKb = content.length / 1024;
                          debugPrint('[ModelManager]   ✓ Tokenizer 檔案存在 (${sizeKb.toStringAsFixed(1)} KB)');
                          jsonDecode(content);
                          debugPrint('[ModelManager]   ✓ JSON 格式有效');
                          tokName = '${role}__$variantId.tokenizer.json';
                        } catch (e) {
                          // 格式損毀，刪除並不註冊該模型
                          debugPrint('[ModelManager]   ❌ Tokenizer JSON 解析失敗: $e');
                          try { tokFile.deleteSync(); } catch (_) {}
                          shouldRegister = false;
                        }
                      }
                    }

                    if (shouldRegister) {
                      final modelSizeMb = entity.lengthSync() / (1024 * 1024);
                      debugPrint('[ModelManager]   ✓ 註冊模型: $role/$variantId (${modelSizeMb.toStringAsFixed(1)} MB)${tokName != null ? ' + tokenizer' : ''}');
                      installed[variantId] = InstalledModel(
                        role: role,
                        variantId: variantId,
                        fileName: name,
                        tokenizerFileName: tokName,
                        tokenizer: tokName != null ? 'roberta-bpe' : 'none',
                        aiLabelIndex: 1,
                        version: '1.0.0',
                        sizeBytes: entity.lengthSync().toInt(),
                      );
                    } else {
                      debugPrint('[ModelManager]   ❌ 未註冊: $role/$variantId (缺少必要檔案或格式無效)');
                    }
                  }
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

  /// 指定變體的模型檔絕對路徑
  Future<String?> variantModelPath(String role, String variantId) async {
    final installed = _roles[role]?.installed[variantId];
    if (installed == null) return null;
    return p.join((await _modelsDir()).path, installed.fileName);
  }

  Future<String?> variantTokenizerPath(String role, String variantId) async {
    final installed = _roles[role]?.installed[variantId];
    if (installed?.tokenizerFileName == null) return null;
    return p.join((await _modelsDir()).path, installed!.tokenizerFileName!);
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
        final tokFile = File(p.join(dir.path, tokenizerFileName));
        if (tokFile.existsSync()) await tokFile.delete();
        await _streamDownload(variant.tokenizerUrl!, tokFile);

        // 驗證 Tokenizer JSON 檔格式完整性
        try {
          final content = await tokFile.readAsString();
          jsonDecode(content);
        } catch (e) {
          if (tokFile.existsSync()) await tokFile.delete();
          if (tmp.existsSync()) await tmp.delete();
          throw FormatException('下載之 Tokenizer JSON 格式不完整或網路斷傳: $e');
        }
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

  Future<void> _streamDownload(String originalUrl, File dest,
      {int? expected, void Function(double)? onProgress}) async {
    final urlsToTry = <String>[originalUrl];

    // 如果是 GitHub Releases 連結，加入備用鏡像代理（如 ghproxy, ghfast）作為 fallback
    if (originalUrl.contains('github.com') &&
        originalUrl.contains('/releases/download/')) {
      urlsToTry.add('https://ghfast.top/$originalUrl');
      urlsToTry.add('https://ghproxy.net/$originalUrl');
      urlsToTry.add('https://gh-proxy.com/$originalUrl');
    }

    Object? lastError;
    for (final tryUrl in urlsToTry) {
      try {
        await _streamDownloadSingle(tryUrl, dest,
            expected: expected, onProgress: onProgress);
        return;
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? HttpException('下載失敗');
  }

  Future<void> _streamDownloadSingle(String url, File dest,
      {int? expected, void Function(double)? onProgress}) async {
    final existingLen = dest.existsSync() ? dest.lengthSync() : 0;
    var currentUrl = url;
    http.StreamedResponse? response;
    int redirectCount = 0;
    bool isResuming = false;

    while (redirectCount < 5) {
      final request = http.Request('GET', Uri.parse(currentUrl));
      request.followRedirects = false; // 手動處理重定向，避免標頭洩漏至 AWS S3 引發 403
      request.headers['User-Agent'] =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36 TruthLens/1.0';

      if (existingLen > 0 && redirectCount == 0) {
        request.headers['Range'] = 'bytes=$existingLen-';
        isResuming = true;
        debugPrint('[下載] 偵測到部分檔案 (${(existingLen / (1024 * 1024)).toStringAsFixed(1)} MB)，嘗試續傳...');
      }

      final res = await _client.send(request);

      if (res.statusCode == 301 ||
          res.statusCode == 302 ||
          res.statusCode == 303 ||
          res.statusCode == 307 ||
          res.statusCode == 308) {
        final location = res.headers['location'];
        if (location != null && location.isNotEmpty) {
          currentUrl = Uri.parse(currentUrl).resolve(location).toString();
          redirectCount++;
          continue;
        }
      }

      response = res;
      break;
    }

    if (response == null) {
      throw HttpException('重定向次數過多');
    }

    if (response.statusCode == 206) {
      // 伺服器支援斷點續傳 (HTTP 206 Partial Content)
      final partialSize = response.contentLength ?? 0;
      final total = partialSize + existingLen;
      debugPrint('[下載] ✓ 伺服器支援續傳 (HTTP 206)，續傳 ${(partialSize / (1024 * 1024)).toStringAsFixed(1)} MB');
      final sink = dest.openWrite(mode: FileMode.append);
      var received = existingLen;
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (onProgress != null && total > 0) {
          onProgress((received / total).clamp(0, 1));
        }
      }
      await sink.close();
      debugPrint('[下載] ✓ 續傳完成，總大小 ${(total / (1024 * 1024)).toStringAsFixed(1)} MB');
      return;
    }
    if (response.statusCode == 200) {
      // 伺服器不支援 Range 或要求重新開始，清除並重新下載
      if (isResuming) {
        debugPrint('[下載] ⚠️ 伺服器不支援續傳，清除部分檔案並重新開始...');
        if (dest.existsSync()) await dest.delete();
      }
      final total = response.contentLength ?? expected ?? 0;
      final sink = dest.openWrite(mode: FileMode.write);
      var received = 0;
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (onProgress != null && total > 0) {
          onProgress((received / total).clamp(0, 1));
        }
      }
      await sink.close();
      debugPrint('[下載] ✓ 完成，總大小 ${(total / (1024 * 1024)).toStringAsFixed(1)} MB');
      return;
    }
    if (response.statusCode == 416) {
      // 416 Range Not Satisfiable — 請求的範圍無效（可能檔案已完成或損毀）
      debugPrint('[下載] ⚠️ 伺服器無法滿足 Range 要求 (HTTP 416)，清除部分檔案並重新開始...');
      if (dest.existsSync()) await dest.delete();
      throw HttpException('需要重新開始下載 (HTTP 416)');
    }
    throw HttpException('HTTP ${response.statusCode}：${response.reasonPhrase}');
  }

  /// 匯入本機 ONNX 模型檔。強化驗證與錯誤恢復。
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
      // 驗證角色
      if (!_roles.containsKey(role)) {
        throw ArgumentError('無效的 role: $role');
      }

      // 驗證模型檔
      if (!modelFile.existsSync()) {
        throw FileSystemException('模型檔不存在', modelFile.path);
      }
      final modelSize = modelFile.lengthSync();
      if (modelSize < 1024 * 100) {
        throw Exception('模型檔過小 (<100KB)，可能是空檔或格式錯誤: $modelSize bytes');
      }
      debugPrint('[ImportModel] 驗證模型檔: $name (${(modelSize / (1024 * 1024)).toStringAsFixed(1)} MB)');

      // 複製模型檔
      await modelFile.copy(target.path);
      final hash = await _sha256Of(target);
      debugPrint('[ImportModel] ✓ 模型檔複製完成，SHA256: ${hash.substring(0, 8)}...');

      // 複製並驗證 tokenizer 檔（若需要）
      if (tokenizerFile != null && tokenizerType != 'none') {
        if (!tokenizerFile.existsSync()) {
          throw FileSystemException('Tokenizer 檔不存在', tokenizerFile.path);
        }

        tokenizerFileName = '${role}__$variantId.tokenizer.json';
        final tokTarget = File(p.join(dir.path, tokenizerFileName));

        // 先複製，再驗證格式
        await tokenizerFile.copy(tokTarget.path);

        try {
          final content = tokTarget.readAsStringSync();
          jsonDecode(content);
          debugPrint('[ImportModel] ✓ Tokenizer JSON 驗證通過');
        } catch (e) {
          // Tokenizer 格式無效，刪除並拋出錯誤
          await tokTarget.delete();
          throw FormatException('Tokenizer JSON 格式無效: $e');
        }
      }

      // 構建並註冊模型
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
        sizeBytes: modelSize,
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
      debugPrint('[ImportModel] ✓ 模型匯入成功: $name ($variantId)');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[ImportModel] ❌ 匯入失敗: $e');
      // 清理已複製的檔案
      try {
        if (target.existsSync()) await target.delete();
      } catch (_) {}
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
