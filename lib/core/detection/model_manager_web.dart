import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../l10n/generated/app_localizations.dart';
import 'model_catalog.dart';
import 'model_catalog_service.dart';
import 'model_manager_types.dart';
import 'model_registry.dart';
import 'web_js_bridge.dart';

export 'model_manager_types.dart';

const _manifestFileName = 'installed.json';

/// 供 [Hash.startChunkedConversion] 取回最終 [Digest] 用的最小 Sink 實作
/// （`package:crypto` 內建的 `DigestSink`未對外匯出）。
class _DigestCapture implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}

/// 模型檔案管理（web 版）：與原生版相同的公開介面與 [RoleState]／[InstalledModel]
/// 語意，差別只在儲存後端——原生版寫入 App Support 目錄，web 版寫入瀏覽器
/// OPFS（見 [WebFs]），全程留在瀏覽器沙盒內，不經任何伺服器。
///
/// 「匯入本機模型／測試模型」（[importLocalModel]／[testModel]）是仰賴 dart:io
/// File 的進階設定頁功能，web 版尚未支援（見 model_import_screen_web.dart），
/// 呼叫會拋出 [UnsupportedError]。
class ModelManager extends ChangeNotifier {
  final http.Client _client;

  final Map<String, RoleState> _roles = {
    for (final m in kModelRegistry) m.id: RoleState(role: m.id),
  };

  ModelManager({http.Client? client, Object? modelsDir})
    : _client = client ?? http.Client();

  RoleState? roleState(String role) => _roles[role];

  Set<String> _rolesWithUpdate = {};

  bool get hasAnyUpdate => _rolesWithUpdate.isNotEmpty;
  bool roleHasUpdate(String role) => _rolesWithUpdate.contains(role);

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

  Future<void> _persist() async {
    final map = <String, dynamic>{};
    for (final r in _roles.values) {
      if (r.installed.isEmpty) continue;
      map[r.role] = {
        'active': r.activeVariantId,
        'installed': r.installed.map((k, v) => MapEntry(k, v.toJson())),
      };
    }
    await WebFs.writeText(_manifestFileName, jsonEncode(map));
  }

  /// 讀取 OPFS 內的 installed.json，重建每個 role 的安裝狀態（含清理遺失檔案）。
  /// web 上的檔案只會由本 App 自己寫入（沒有「使用者手動丟檔案進目錄」的情境），
  /// 故不需要原生版那樣的目錄掃描補登記。
  Future<void> refreshInstallStates() async {
    Map<String, dynamic> raw = {};
    final manifestText = await WebFs.readText(_manifestFileName);
    if (manifestText != null) {
      try {
        raw = jsonDecode(manifestText) as Map<String, dynamic>;
      } catch (_) {}
    }

    for (final role in _roles.keys.toList()) {
      final entry = raw[role] as Map<String, dynamic>?;
      final installed = <String, InstalledModel>{};
      if (entry != null) {
        final inst = (entry['installed'] as Map<String, dynamic>?) ?? {};
        for (final e in inst.entries) {
          final model = InstalledModel.fromJson(
            e.value as Map<String, dynamic>,
          );
          if (await _isHealthyInstall(model)) {
            installed[e.key] = model;
          } else {
            await _deleteModelFiles(model);
          }
        }
      }
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
    await _persist();
    notifyListeners();
  }

  bool isInstalled(String role) => _roles[role]?.hasInstalled ?? false;
  bool isVariantInstalled(String role, String variantId) =>
      _roles[role]?.installed.containsKey(variantId) ?? false;
  InstalledModel? activeVariant(String role) => _roles[role]?.active;
  List<InstalledModel> installedVariants(String role) =>
      _roles[role]?.installed.values.toList() ?? const [];

  bool canRunEngine(String role) {
    final spec = modelSpecFor(role);
    if (spec == null || spec.backend == InferenceBackend.none) return false;
    return activeVariant(role) != null;
  }

  /// web 上「路徑」即 OPFS 儲存鍵（等同檔名），供 [OnnxDetector]/[PerplexityScorer]
  /// 的 web 版透過 [WebFs] 讀取。
  Future<String?> activeModelPath(String role) async =>
      activeVariant(role)?.fileName;

  Future<String?> activeTokenizerPath(String role) async =>
      activeVariant(role)?.tokenizerFileName;

  Future<void> setActive(String role, String variantId) async {
    final r = _roles[role];
    if (r == null || !r.installed.containsKey(variantId)) return;
    _roles[role] = r.copyWith(activeVariantId: variantId);
    await _persist();
    notifyListeners();
  }

  Future<String> repairActiveVariant(String role, AppLocalizations l10n) async {
    final active = activeVariant(role);
    if (active == null) {
      return l10n.modelRepairNoActiveVariant;
    }
    if (active.imported) {
      await removeVariant(role, active.variantId);
      return l10n.modelRepairCustomRemoved;
    }

    ModelVariant? catalogVariant;
    try {
      final catalog = await ModelCatalogService(client: _client).load();
      final variants =
          catalog.forRole(role)?.variants ?? const <ModelVariant>[];
      for (final v in variants) {
        if (v.id == active.variantId) {
          catalogVariant = v;
          break;
        }
      }
    } catch (_) {
      // Catalog 讀取失敗時仍先清掉壞檔，避免後續一直誤判為已安裝。
    }

    await removeVariant(role, active.variantId);

    if (catalogVariant == null || !catalogVariant.isDownloadable) {
      return l10n.modelRepairNoSource;
    }

    final ok = await downloadVariant(role, catalogVariant);
    return ok
        ? l10n.modelRepairRedownloaded(catalogVariant.name)
        : l10n.modelRepairRedownloadFailed(catalogVariant.name);
  }

  bool hasUpdate(String role, ModelVariant catalogVariant) {
    final installed = _roles[role]?.installed[catalogVariant.id];
    if (installed == null) return false;
    final v1 = installed.version.replaceAll('.0', '');
    final v2 = catalogVariant.version.replaceAll('.0', '');
    return v1 != v2;
  }

  /// 下載並安裝變體：模型主檔逐塊直接串流寫入 OPFS（見 [_streamDownloadToFile]），
  /// 不再整份先堆積在記憶體；Tokenizer 檔通常僅數十 KB～數 MB，仍以整包記憶體
  /// 讀取（需要完整字串做 JSON 解析）。首個安裝的變體自動設為使用中。
  Future<bool> downloadVariant(String role, ModelVariant variant) async {
    if (!variant.isDownloadable) {
      _mark(role, InstallState.failed, error: '此變體尚未提供下載來源');
      return false;
    }
    _mark(
      role,
      InstallState.downloading,
      downloadingVariantId: variant.id,
      progress: 0,
    );
    final fileName = variant.fileName(role);
    String? tokenizerFileName;

    try {
      final downloaded = await _streamDownloadToFile(
        variant.url!,
        fileName,
        expected: variant.sizeBytes,
        onProgress: (r) {
          _mark(
            role,
            InstallState.downloading,
            downloadingVariantId: variant.id,
            progress: r,
          );
        },
      );

      try {
        _validateDownloadedSize(downloaded.sizeBytes, variant.sizeBytes);
        if (variant.sha256 != null && downloaded.sha256Hex != variant.sha256) {
          throw const FormatException('校驗和不符，檔案可能損毀');
        }
      } catch (_) {
        await WebFs.deleteFile(fileName); // 驗證失敗，清除半成品，避免殘留壞檔
        rethrow;
      }

      if (variant.tokenizerUrl != null) {
        tokenizerFileName = '${role}__${variant.id}.tokenizer.json';
        final tokBytes = await _streamDownload(variant.tokenizerUrl!);
        try {
          jsonDecode(utf8.decode(tokBytes));
        } catch (e) {
          throw FormatException('下載之 Tokenizer JSON 格式不完整或網路斷傳: $e');
        }
        await WebFs.writeBytes(tokenizerFileName, tokBytes);
      }

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
        // 安裝當下記下推論所需的額外輸入規格與語言涵蓋，
        // 執行期不必再抓 catalog——離線也要能正確路由
        runtimeJson: variant.runtimeJson,
        languages: variant.languages,
      );
      _roles[role] = r.copyWith(
        installed: installed,
        activeVariantId: r.activeVariantId ?? variant.id,
        transientState: InstallState.installed,
        progress: 1,
      );
      await _persist();
      notifyListeners();
      return true;
    } catch (e) {
      _mark(
        role,
        InstallState.failed,
        downloadingVariantId: variant.id,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> removeVariant(String role, String variantId) async {
    final r = _roles[role];
    if (r == null) return;
    final entry = r.installed[variantId];
    if (entry == null) return;
    await WebFs.deleteFile(entry.fileName);
    if (entry.tokenizerFileName != null) {
      await WebFs.deleteFile(entry.tokenizerFileName!);
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

  Future<bool> _isHealthyInstall(InstalledModel model) async {
    final modelSize = await WebFs.size(model.fileName);
    if (modelSize <= 0) return false;
    if (!_isPlausibleSize(modelSize, model.sizeBytes)) return false;

    if ((model.role == 'transformer' || model.role == 'adversarial') &&
        model.tokenizer != 'none') {
      final tokenizer = model.tokenizerFileName;
      if (tokenizer == null || !await WebFs.exists(tokenizer)) return false;
      final tokenizerText = await WebFs.readText(tokenizer);
      if (tokenizerText == null || tokenizerText.trim().isEmpty) return false;
      try {
        jsonDecode(tokenizerText);
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  Future<void> _deleteModelFiles(InstalledModel model) async {
    await WebFs.deleteFile(model.fileName);
    final tokenizer = model.tokenizerFileName;
    if (tokenizer != null) await WebFs.deleteFile(tokenizer);
  }

  bool _isPlausibleSize(int actual, int expected) {
    if (expected <= 0) return actual > 100 * 1024;
    final minExpected = (expected * 0.80).round();
    return actual >= minExpected;
  }

  void _validateDownloadedSize(int actual, int expected) {
    if (!_isPlausibleSize(actual, expected)) {
      throw FormatException(
        '模型下載不完整：收到 ${(actual / (1024 * 1024)).toStringAsFixed(1)} MB，'
        '預期約 ${(expected / (1024 * 1024)).toStringAsFixed(1)} MB',
      );
    }
  }

  List<String> _candidateUrls(String originalUrl) {
    final urlsToTry = <String>[];

    final proxyPath = '/api/proxy?url=${Uri.encodeComponent(originalUrl)}';
    final sameOriginProxy = Uri.base.resolve(proxyPath).toString();
    final prodVercelProxy =
        'https://truth-lens-roan-three.vercel.app/api/proxy?url=${Uri.encodeComponent(originalUrl)}';

    if (originalUrl.contains('huggingface.co')) {
      urlsToTry.add(originalUrl);
      urlsToTry.add(originalUrl.replaceAll('huggingface.co', 'hf-mirror.com'));
      urlsToTry.add(sameOriginProxy);
      urlsToTry.add(prodVercelProxy);
    } else if (originalUrl.contains('github.com')) {
      // GitHub Releases downloads lack browser CORS headers, prioritize same-origin Edge proxy
      urlsToTry.add(sameOriginProxy);
      urlsToTry.add(prodVercelProxy);
      urlsToTry.add(originalUrl);
    } else {
      urlsToTry.add(sameOriginProxy);
      urlsToTry.add(prodVercelProxy);
      urlsToTry.add(originalUrl);
    }
    return urlsToTry;
  }

  /// 串流下載並直接寫入 OPFS，全程不把整份檔案留在記憶體中——逐塊
  /// （Range 分塊或連貫串流）邊收邊寫入 [WebFsWritable]，同步以增量方式
  /// 計算 SHA-256，供下載完成後核對校驗和。
  Future<({int sizeBytes, String sha256Hex})> _streamDownloadToFile(
    String originalUrl,
    String fileName, {
    int? expected,
    void Function(double)? onProgress,
  }) async {
    Object? lastError;
    for (final url in _candidateUrls(originalUrl)) {
      try {
        final result = await _tryChunkedDownloadToFile(
          url,
          fileName,
          expected: expected,
          onProgress: onProgress,
        );
        if (result.sizeBytes > 0) {
          return result;
        }
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? http.ClientException('無可用的下載連線，請檢查網路狀態');
  }

  Future<Uint8List> _streamDownload(
    String originalUrl, {
    int? expected,
    void Function(double)? onProgress,
  }) async {
    Object? lastError;
    for (final url in _candidateUrls(originalUrl)) {
      try {
        final result = await _tryChunkedDownload(
          url,
          expected: expected,
          onProgress: onProgress,
        );
        if (result != null && result.isNotEmpty) {
          return result;
        }
      } catch (e) {
        lastError = e;
      }
    }
    throw lastError ?? http.ClientException('無可用的下載連線，請檢查網路狀態');
  }

  /// 以 2MB 分塊 (Range: bytes=start-end) 執行斷點續傳下載
  /// 與 [_tryChunkedDownload] 邏輯相同（Range 分塊探測／連貫串流回退），
  /// 差別是每收到一塊資料就立刻寫入 [WebFsWritable]、同步累積 SHA-256，
  /// 不在記憶體中保留已下載內容。任一環節失敗時會中止（abort）寫入串流，
  /// 讓外層改試下一個候選網址時能重新開檔（OPFS 同一檔案僅允許單一寫入串流）。
  Future<({int sizeBytes, String sha256Hex})> _tryChunkedDownloadToFile(
    String url,
    String fileName, {
    int? expected,
    void Function(double)? onProgress,
  }) async {
    int totalSize = expected ?? 0;
    bool supportsRange = false;

    try {
      final headReq = http.Request('GET', Uri.parse(url));
      headReq.headers['Range'] = 'bytes=0-1023';
      final headRes = await _client
          .send(headReq)
          .timeout(const Duration(seconds: 15));

      if (headRes.statusCode == 206) {
        supportsRange = true;
        final contentRange = headRes.headers['content-range'];
        if (contentRange != null && contentRange.contains('/')) {
          final totalStr = contentRange.split('/').last;
          totalSize = int.tryParse(totalStr) ?? totalSize;
        }
      } else if (headRes.statusCode == 200) {
        totalSize = headRes.contentLength ?? totalSize;
      }
      headRes.stream.drain().ignore();
    } catch (_) {
      // 探測失敗 → 後續嘗試完整流式下載
    }

    final writable = await WebFs.openWritable(fileName);
    final digestCapture = _DigestCapture();
    final hashSink = sha256.startChunkedConversion(digestCapture);
    var written = 0;

    try {
      if (!supportsRange || totalSize <= 0) {
        final req = http.Request('GET', Uri.parse(url));
        final res = await _client
            .send(req)
            .timeout(const Duration(seconds: 45));
        if (res.statusCode != 200 && res.statusCode != 206) {
          throw http.ClientException('HTTP ${res.statusCode}');
        }
        final size = res.contentLength ?? expected ?? 0;
        await for (final chunk in res.stream) {
          final bytes = Uint8List.fromList(chunk);
          await writable.writeChunk(bytes);
          hashSink.add(bytes);
          written += bytes.length;
          if (onProgress != null && size > 0) {
            onProgress((written / size).clamp(0.0, 1.0));
          }
        }
      } else {
        // 支援 Range：以 2MB 分塊分段流式下載並帶重試機制
        const chunkSize = 2 * 1024 * 1024; // 2MB 塊
        var downloaded = 0;

        while (downloaded < totalSize) {
          final end = (downloaded + chunkSize - 1).clamp(0, totalSize - 1);
          Uint8List? chunkData;
          int retry = 0;

          while (retry < 5 && chunkData == null) {
            try {
              final chunkReq = http.Request('GET', Uri.parse(url));
              chunkReq.headers['Range'] = 'bytes=$downloaded-$end';

              final chunkRes = await _client
                  .send(chunkReq)
                  .timeout(const Duration(seconds: 30));
              if (chunkRes.statusCode == 206 || chunkRes.statusCode == 200) {
                final chunkBytes = await chunkRes.stream.toBytes();
                if (chunkBytes.isNotEmpty) {
                  chunkData = chunkBytes;
                }
              }
            } catch (_) {
              // 單一 Chunk 失敗時僅重試該 Chunk，不從 0 MB 重來
            }

            if (chunkData == null) {
              retry++;
              await Future.delayed(Duration(milliseconds: 500 * (1 << retry)));
            }
          }

          if (chunkData == null) {
            throw http.ClientException('下載在中途分塊 ($downloaded-$end) 斷線，重試多次失敗');
          }

          await writable.writeChunk(chunkData);
          hashSink.add(chunkData);
          downloaded += chunkData.length;
          written += chunkData.length;

          if (onProgress != null && totalSize > 0) {
            onProgress((downloaded / totalSize).clamp(0.0, 1.0));
          }
        }
      }

      hashSink.close();
      await writable.close();
      return (sizeBytes: written, sha256Hex: digestCapture.value!.toString());
    } catch (e) {
      await writable.abort();
      rethrow;
    }
  }

  Future<Uint8List?> _tryChunkedDownload(
    String url, {
    int? expected,
    void Function(double)? onProgress,
  }) async {
    int totalSize = expected ?? 0;
    bool supportsRange = false;

    // 先測試 HEAD / 部分 Range 探測 Total Content-Length 與 Range 支援度
    try {
      final headReq = http.Request('GET', Uri.parse(url));
      headReq.headers['Range'] = 'bytes=0-1023';
      final headRes = await _client
          .send(headReq)
          .timeout(const Duration(seconds: 15));

      if (headRes.statusCode == 206) {
        supportsRange = true;
        final contentRange = headRes.headers['content-range'];
        if (contentRange != null && contentRange.contains('/')) {
          final totalStr = contentRange.split('/').last;
          totalSize = int.tryParse(totalStr) ?? totalSize;
        }
      } else if (headRes.statusCode == 200) {
        totalSize = headRes.contentLength ?? totalSize;
      }
      headRes.stream.drain().ignore();
    } catch (_) {
      // 探測失敗 → 後續嘗試完整流下載
    }

    // 若伺服器不支援 Range 或未取到總大小 → 退回傳統連貫流式下載
    if (!supportsRange || totalSize <= 0) {
      final req = http.Request('GET', Uri.parse(url));
      final res = await _client.send(req).timeout(const Duration(seconds: 45));
      if (res.statusCode != 200 && res.statusCode != 206) {
        throw http.ClientException('HTTP ${res.statusCode}');
      }
      final size = res.contentLength ?? expected ?? 0;
      final builder = BytesBuilder(copy: false);
      var received = 0;
      await for (final chunk in res.stream) {
        builder.add(chunk);
        received += chunk.length;
        if (onProgress != null && size > 0) {
          onProgress((received / size).clamp(0.0, 1.0));
        }
      }
      return builder.takeBytes();
    }

    // 支援 Range：以 2MB 分塊分段流式下載並帶重試機制
    const chunkSize = 2 * 1024 * 1024; // 2MB 塊
    final builder = BytesBuilder(copy: false);
    var downloaded = 0;

    while (downloaded < totalSize) {
      final end = (downloaded + chunkSize - 1).clamp(0, totalSize - 1);
      Uint8List? chunkData;
      int retry = 0;

      while (retry < 5 && chunkData == null) {
        try {
          final chunkReq = http.Request('GET', Uri.parse(url));
          chunkReq.headers['Range'] = 'bytes=$downloaded-$end';

          final chunkRes = await _client
              .send(chunkReq)
              .timeout(const Duration(seconds: 30));
          if (chunkRes.statusCode == 206 || chunkRes.statusCode == 200) {
            final chunkBytes = await chunkRes.stream.toBytes();
            if (chunkBytes.isNotEmpty) {
              chunkData = chunkBytes;
            }
          }
        } catch (_) {
          // 單一 Chunk 失敗時僅重試該 Chunk，不從 0 MB 重來
        }

        if (chunkData == null) {
          retry++;
          await Future.delayed(
            Duration(milliseconds: 500 * (1 << retry)),
          ); // 指數退避 1s, 2s, 4s...
        }
      }

      if (chunkData == null) {
        throw http.ClientException('下載在中途分塊 ($downloaded-$end) 斷線，重試多次失敗');
      }

      builder.add(chunkData);
      downloaded += chunkData.length;

      if (onProgress != null && totalSize > 0) {
        onProgress((downloaded / totalSize).clamp(0.0, 1.0));
      }
    }

    return builder.takeBytes();
  }

  /// 尚未支援於網頁版（見 model_import_screen_web.dart）。
  Future<bool> importLocalModel({
    required String role,
    required String name,
    required Object modelFile,
    Object? tokenizerFile,
    String tokenizerType = 'bert-wordpiece',
    int aiLabelIndex = 1,
  }) async => throw UnsupportedError('自訂模型匯入尚未支援於網頁版');

  Future<String> hashOf(Object file) async =>
      throw UnsupportedError('自訂模型匯入尚未支援於網頁版');

  InstalledModel? findByHash(String sha256) {
    for (final r in _roles.values) {
      for (final m in r.installed.values) {
        if (m.sha256 == sha256) return m;
      }
    }
    return null;
  }

  Future<String?> variantModelPath(String role, String variantId) async {
    final installed = _roles[role]?.installed[variantId];
    if (installed == null) return null;
    return installed.fileName;
  }

  Future<String?> variantTokenizerPath(String role, String variantId) async {
    final installed = _roles[role]?.installed[variantId];
    return installed?.tokenizerFileName;
  }

  Future<double> testModel({
    required Object modelFile,
    Object? tokenizerFile,
    String tokenizerType = 'bert-wordpiece',
    int aiLabelIndex = 1,
    required String text,
  }) async => throw UnsupportedError('自訂模型測試尚未支援於網頁版');

  void _mark(
    String role,
    InstallState state, {
    String? downloadingVariantId,
    double? progress,
    String? error,
  }) {
    final r = _roles[role]!;
    _roles[role] = r.copyWith(
      transientState: state,
      downloadingVariantId: downloadingVariantId,
      progress:
          progress ?? (state == InstallState.downloading ? 0 : r.progress),
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
