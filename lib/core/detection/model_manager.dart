import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'model_catalog.dart';
import 'model_registry.dart';

enum InstallState { notInstalled, downloading, installed, failed }

/// 已安裝紀錄（寫入 models/installed.json，用於「判斷是否已安裝過模型」）
class InstalledModel {
  final String role;
  final String variantId;
  final String fileName;
  final String version;
  final int sizeBytes;

  const InstalledModel({
    required this.role,
    required this.variantId,
    required this.fileName,
    required this.version,
    required this.sizeBytes,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'variant_id': variantId,
        'file_name': fileName,
        'version': version,
        'size_bytes': sizeBytes,
      };

  factory InstalledModel.fromJson(Map<String, dynamic> j) => InstalledModel(
        role: j['role'] as String,
        variantId: j['variant_id'] as String,
        fileName: j['file_name'] as String,
        version: j['version'] as String? ?? '0',
        sizeBytes: (j['size_bytes'] as num?)?.toInt() ?? 0,
      );
}

class ModelStatus {
  final String role;
  final InstallState state;
  final double progress; // 0..1（下載中）
  final InstalledModel? installed;
  final String? error;

  const ModelStatus({
    required this.role,
    required this.state,
    this.progress = 0,
    this.installed,
    this.error,
  });

  ModelStatus copyWith({
    InstallState? state,
    double? progress,
    InstalledModel? installed,
    String? error,
    bool clearInstalled = false,
  }) =>
      ModelStatus(
        role: role,
        state: state ?? this.state,
        progress: progress ?? this.progress,
        installed: clearInstalled ? null : (installed ?? this.installed),
        error: error,
      );
}

/// 模型檔案管理：安裝狀態偵測（installed.json）、變體下載（含進度）、
/// sha256 校驗、原子熱替換、移除。目錄與 http client 可注入以供測試。
class ModelManager extends ChangeNotifier {
  final http.Client _client;
  final Directory? _dirOverride;

  final Map<String, ModelStatus> _statuses = {
    for (final m in kModelRegistry)
      m.id: ModelStatus(role: m.id, state: InstallState.notInstalled),
  };

  ModelManager({http.Client? client, Directory? modelsDir})
      : _client = client ?? http.Client(),
        _dirOverride = modelsDir;

  Map<String, ModelStatus> get statuses => Map.unmodifiable(_statuses);
  ModelStatus? statusFor(String role) => _statuses[role];

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

  Future<Map<String, InstalledModel>> _readManifest() async {
    final f = await _manifestFile();
    if (!f.existsSync()) return {};
    try {
      final raw = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      return raw.map((role, v) =>
          MapEntry(role, InstalledModel.fromJson(v as Map<String, dynamic>)));
    } catch (_) {
      return {};
    }
  }

  Future<void> _writeManifest(Map<String, InstalledModel> manifest) async {
    final f = await _manifestFile();
    f.writeAsStringSync(
      const JsonEncoder.withIndent('  ')
          .convert(manifest.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  /// 開機時掃描 installed.json 與檔案，更新每個 role 的安裝狀態。
  Future<void> refreshInstallStates() async {
    final manifest = await _readManifest();
    final dir = await _modelsDir();
    for (final role in _statuses.keys.toList()) {
      final entry = manifest[role];
      final ok = entry != null &&
          File(p.join(dir.path, entry.fileName)).existsSync();
      _statuses[role] = _statuses[role]!.copyWith(
        state: ok ? InstallState.installed : InstallState.notInstalled,
        progress: ok ? 1 : 0,
        installed: ok ? entry : null,
        clearInstalled: !ok,
      );
    }
    notifyListeners();
  }

  bool isInstalled(String role) =>
      _statuses[role]?.state == InstallState.installed;

  InstalledModel? installedInfo(String role) => _statuses[role]?.installed;

  /// 可實際執行推論的引擎（已安裝且有原生後端）。純 Dart 引擎不在此列。
  bool canRunEngine(String role) {
    final spec = modelSpecFor(role);
    if (spec == null || spec.backend == InferenceBackend.none) return false;
    return isInstalled(role);
  }

  /// 下載並安裝某 role 的指定變體。回傳 true 表示成功。
  /// 未提供下載來源（url 為 null）的變體會標記 failed。
  Future<bool> downloadVariant(String role, ModelVariant variant) async {
    if (!variant.isDownloadable) {
      _update(role, state: InstallState.failed, error: '此變體尚未提供下載來源');
      return false;
    }
    _update(role, state: InstallState.downloading, progress: 0);
    final dir = await _modelsDir();
    final fileName = variant.fileName(role);
    final target = File(p.join(dir.path, fileName));
    final tmp = File('${target.path}.part');

    try {
      await _streamDownload(variant.url!, tmp, expected: variant.sizeBytes,
          onProgress: (r) {
        _update(role, state: InstallState.downloading, progress: r);
      });

      if (variant.sha256 != null) {
        final digest = await _sha256Of(tmp);
        if (digest != variant.sha256) {
          await tmp.delete();
          throw const FormatException('校驗和不符，檔案可能損毀');
        }
      }

      // tokenizer 另檔（如 RoBERTa 的 tokenizer.json）
      if (variant.tokenizerUrl != null) {
        final tokFile =
            File(p.join(dir.path, '${role}__${variant.id}.tokenizer.json'));
        await _streamDownload(variant.tokenizerUrl!, tokFile);
      }

      if (target.existsSync()) await target.delete();
      await tmp.rename(target.path); // 原子替換（熱替換）

      final manifest = await _readManifest();
      manifest[role] = InstalledModel(
        role: role,
        variantId: variant.id,
        fileName: fileName,
        version: variant.version,
        sizeBytes: variant.sizeBytes,
      );
      await _writeManifest(manifest);

      _update(role,
          state: InstallState.installed,
          progress: 1,
          installed: manifest[role]);
      return true;
    } catch (e) {
      if (tmp.existsSync()) await tmp.delete();
      _update(role, state: InstallState.failed, error: e.toString());
      return false;
    }
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

  Future<void> remove(String role) async {
    final dir = await _modelsDir();
    final manifest = await _readManifest();
    final entry = manifest.remove(role);
    if (entry != null) {
      final f = File(p.join(dir.path, entry.fileName));
      if (f.existsSync()) await f.delete();
      final tok =
          File(p.join(dir.path, '${role}__${entry.variantId}.tokenizer.json'));
      if (tok.existsSync()) await tok.delete();
      await _writeManifest(manifest);
    }
    _update(role,
        state: InstallState.notInstalled, progress: 0, clearInstalled: true);
  }

  Future<String> _sha256Of(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  void _update(String role,
      {required InstallState state,
      double? progress,
      InstalledModel? installed,
      String? error,
      bool clearInstalled = false}) {
    _statuses[role] = _statuses[role]!.copyWith(
      state: state,
      progress: progress,
      installed: installed,
      error: error,
      clearInstalled: clearInstalled,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
