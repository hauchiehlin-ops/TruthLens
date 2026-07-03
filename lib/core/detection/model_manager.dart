import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'model_registry.dart';

enum InstallState { notInstalled, downloading, installed, failed }

class ModelStatus {
  final ModelSpec spec;
  final InstallState state;
  final double progress; // 0..1（下載中）
  final String? error;

  const ModelStatus({
    required this.spec,
    required this.state,
    this.progress = 0,
    this.error,
  });

  ModelStatus copyWith({InstallState? state, double? progress, String? error}) =>
      ModelStatus(
        spec: spec,
        state: state ?? this.state,
        progress: progress ?? this.progress,
        error: error,
      );
}

/// 模型檔案管理：安裝狀態偵測、下載（含進度）、內容校驗、移除。
/// 檔案系統目錄與 http client 皆可注入，方便單元測試。
class ModelManager extends ChangeNotifier {
  final http.Client _client;
  final Directory? _dirOverride;

  final Map<String, ModelStatus> _statuses = {
    for (final m in kModelRegistry)
      m.id: ModelStatus(spec: m, state: InstallState.notInstalled),
  };

  ModelManager({http.Client? client, Directory? modelsDir})
      : _client = client ?? http.Client(),
        _dirOverride = modelsDir;

  Map<String, ModelStatus> get statuses => Map.unmodifiable(_statuses);
  ModelStatus? statusFor(String id) => _statuses[id];

  Future<Directory> _modelsDir() async {
    final override = _dirOverride;
    if (override != null) return override;
    final support = await getApplicationSupportDirectory();
    final dir = Directory(p.join(support.path, 'models'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<File> fileFor(ModelSpec spec) async =>
      File(p.join((await _modelsDir()).path, spec.fileName));

  /// 開機時掃描本地檔案，更新每個模型的安裝狀態。
  Future<void> refreshInstallStates() async {
    for (final spec in kModelRegistry) {
      final file = await fileFor(spec);
      final installed = file.existsSync() && file.lengthSync() > 0;
      _statuses[spec.id] = _statuses[spec.id]!.copyWith(
        state: installed ? InstallState.installed : InstallState.notInstalled,
        progress: installed ? 1 : 0,
      );
    }
    notifyListeners();
  }

  bool isInstalled(String id) =>
      _statuses[id]?.state == InstallState.installed;

  /// 可實際執行推論的引擎（已安裝且有原生後端）。純 Dart 引擎不在此列。
  bool canRunEngine(String id) {
    final spec = modelSpecFor(id);
    if (spec == null || spec.backend == InferenceBackend.none) return false;
    return isInstalled(id);
  }

  /// 下載並安裝模型。回傳 true 表示成功。
  /// 尚未發佈（無 downloadUrl）的模型會標記 failed 並回傳 false。
  Future<bool> download(String id) async {
    final spec = modelSpecFor(id);
    if (spec == null) return false;
    if (!spec.isDownloadable) {
      _update(id, state: InstallState.failed, error: '模型尚未發佈');
      return false;
    }

    _update(id, state: InstallState.downloading, progress: 0);
    final target = await fileFor(spec);
    final tmp = File('${target.path}.part');

    try {
      final request = http.Request('GET', Uri.parse(spec.downloadUrl!));
      final response = await _client.send(request);
      if (response.statusCode != 200) {
        throw HttpException('HTTP ${response.statusCode}');
      }
      final total = response.contentLength ?? spec.sizeBytes;
      final sink = tmp.openWrite();
      var received = 0;
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        _update(id,
            state: InstallState.downloading,
            progress: total > 0 ? (received / total).clamp(0, 1) : 0);
      }
      await sink.close();

      if (spec.sha256 != null) {
        final digest = await _sha256Of(tmp);
        if (digest != spec.sha256) {
          await tmp.delete();
          throw const FormatException('校驗和不符，檔案可能損毀');
        }
      }

      if (target.existsSync()) await target.delete();
      await tmp.rename(target.path); // 原子替換（熱替換）
      _update(id, state: InstallState.installed, progress: 1);
      return true;
    } catch (e) {
      if (tmp.existsSync()) await tmp.delete();
      _update(id, state: InstallState.failed, error: e.toString());
      return false;
    }
  }

  Future<void> remove(String id) async {
    final spec = modelSpecFor(id);
    if (spec == null) return;
    final file = await fileFor(spec);
    if (file.existsSync()) await file.delete();
    _update(id, state: InstallState.notInstalled, progress: 0);
  }

  Future<String> _sha256Of(File file) async {
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString();
  }

  void _update(String id,
      {required InstallState state, double? progress, String? error}) {
    _statuses[id] = _statuses[id]!
        .copyWith(state: state, progress: progress, error: error);
    notifyListeners();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }
}
