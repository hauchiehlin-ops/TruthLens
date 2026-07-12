import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

// ── TruthLens llama 橋接 dylib 的 C ABI（見 native/llama_bridge/truthlens_llama.h）──
// 只綁 primitive + 指標，所有 by-value 結構/取樣器細節都封在 C++ 橋接層，
// 避免在 Dart 端手刻 llama.cpp 結構佈局造成 ABI 崩潰。

typedef _TlInitNative = ffi.Int32 Function();
typedef _TlInit = int Function();

typedef _TlLoadNative = ffi.Pointer<ffi.Void> Function(
    ffi.Pointer<Utf8> path, ffi.Int32 nCtx, ffi.Int32 nGpuLayers);
typedef _TlLoad = ffi.Pointer<ffi.Void> Function(
    ffi.Pointer<Utf8> path, int nCtx, int nGpuLayers);

typedef _TlGenerateNative = ffi.Int32 Function(
    ffi.Pointer<ffi.Void> handle,
    ffi.Pointer<Utf8> prompt,
    ffi.Int32 maxTokens,
    ffi.Float temperature,
    ffi.Float topP,
    ffi.Uint32 seed,
    ffi.Pointer<Utf8> outBuf,
    ffi.Int32 outBufSize);
typedef _TlGenerate = int Function(
    ffi.Pointer<ffi.Void> handle,
    ffi.Pointer<Utf8> prompt,
    int maxTokens,
    double temperature,
    double topP,
    int seed,
    ffi.Pointer<Utf8> outBuf,
    int outBufSize);

typedef _TlFreeNative = ffi.Void Function(ffi.Pointer<ffi.Void> handle);
typedef _TlFree = void Function(ffi.Pointer<ffi.Void> handle);

typedef _TlBackendFreeNative = ffi.Void Function();
typedef _TlBackendFree = void Function();

/// llama.cpp 橋接 FFI 封裝。原生庫缺失時全數優雅降級（isAvailable=false）。
class LlamaFfi {
  static ffi.DynamicLibrary? _lib;
  static bool _initialized = false;
  static bool _available = false;

  static bool get isAvailable {
    if (!_initialized) _init();
    return _available;
  }

  static void _init() {
    _initialized = true;
    try {
      _lib = _loadLibrary();
      if (_lib != null) {
        // 綁定期即驗證符號存在；缺任何一個都視為不可用。
        _lib!.lookupFunction<_TlInitNative, _TlInit>('tl_llama_init')();
        _available = true;
        debugPrint('TruthLens llama bridge loaded.');
      }
    } catch (e) {
      debugPrint('Failed to load llama bridge: $e');
      _available = false;
    }
  }

  /// 橋接 dylib/so 的檔名（各平台）。
  static String get _libFileName {
    if (Platform.isWindows) return 'truthlens_llama.dll';
    if (Platform.isMacOS || Platform.isIOS) return 'libtruthlens_llama.dylib';
    return 'libtruthlens_llama.so'; // Android / Linux
  }

  static ffi.DynamicLibrary? _loadLibrary() {
    try {
      if (Platform.isMacOS) {
        // 已打包版：相對於執行檔的 Contents/Frameworks/。橋接 dylib 內含
        // @loader_path rpath，會在同目錄找到 libllama / libggml*。
        final exeDir = File(Platform.resolvedExecutable).parent.path;
        final bundled = p.normalize(
            p.join(exeDir, '..', 'Frameworks', _libFileName));
        if (File(bundled).existsSync()) {
          return ffi.DynamicLibrary.open(bundled);
        }
        // 開發後備：專案內 macos/Libs/。
        final devPath =
            p.join(Directory.current.path, 'macos', 'Libs', _libFileName);
        if (File(devPath).existsSync()) {
          return ffi.DynamicLibrary.open(devPath);
        }
        return ffi.DynamicLibrary.open(_libFileName);
      } else if (Platform.isWindows) {
        final exeDir = File(Platform.resolvedExecutable).parent.path;
        final bundled = p.join(exeDir, _libFileName);
        if (File(bundled).existsSync()) {
          return ffi.DynamicLibrary.open(bundled);
        }
        return ffi.DynamicLibrary.open(_libFileName);
      } else if (Platform.isAndroid) {
        return ffi.DynamicLibrary.open(_libFileName);
      } else if (Platform.isIOS) {
        // iOS：橋接靜態連進 app 或以 framework 提供 → 主映像中查找。
        return ffi.DynamicLibrary.process();
      }
    } catch (e) {
      debugPrint('Error loading llama bridge: $e');
    }
    return null;
  }

  static ffi.Pointer<ffi.Void> load(String modelPath,
      {int nCtx = 4096, int nGpuLayers = -1}) {
    if (!isAvailable) return ffi.Pointer.fromAddress(0);
    final fn = _lib!.lookupFunction<_TlLoadNative, _TlLoad>('tl_llama_load');
    final pathPtr = modelPath.toNativeUtf8();
    try {
      return fn(pathPtr, nCtx, nGpuLayers);
    } finally {
      malloc.free(pathPtr);
    }
  }

  static String generate(ffi.Pointer<ffi.Void> handle, String prompt,
      {int maxTokens = 256,
      double temperature = 0.7,
      double topP = 0.9,
      int seed = 0xFFFFFFFF,
      int outBufSize = 16384}) {
    if (!isAvailable || handle.address == 0) return '';
    final fn =
        _lib!.lookupFunction<_TlGenerateNative, _TlGenerate>('tl_llama_generate');
    final promptPtr = prompt.toNativeUtf8();
    final outBuf = malloc<ffi.Uint8>(outBufSize).cast<Utf8>();
    try {
      final n = fn(handle, promptPtr, maxTokens, temperature, topP, seed,
          outBuf, outBufSize);
      if (n <= 0) return '';
      return outBuf.toDartString(length: n);
    } finally {
      malloc.free(promptPtr);
      malloc.free(outBuf);
    }
  }

  static void free(ffi.Pointer<ffi.Void> handle) {
    if (!isAvailable || handle.address == 0) return;
    _lib!.lookupFunction<_TlFreeNative, _TlFree>('tl_llama_free')(handle);
  }

  static void backendFree() {
    if (!isAvailable) return;
    _lib!.lookupFunction<_TlBackendFreeNative, _TlBackendFree>(
        'tl_llama_backend_free')();
  }
}

/// 使用 [LlamaFfi] 的高階文字生成封裝。介面（isLoaded/loadModel/generate/
/// unload/dispose）維持不變，供 [LlmManager] 沿用。
class LlamaInference {
  ffi.Pointer<ffi.Void> _handle = ffi.Pointer.fromAddress(0);
  bool _loaded = false;

  bool get isLoaded => _loaded;

  LlamaInference() {
    if (LlamaFfi.isAvailable) {
      // tl_llama_init 已在 _init() 呼叫；此處保留掛勾點。
    }
  }

  Future<bool> loadModel(String modelPath) async {
    if (!LlamaFfi.isAvailable) return false;
    unload();
    try {
      _handle = LlamaFfi.load(modelPath);
      if (_handle.address == 0) {
        debugPrint('llama bridge: model load returned null for $modelPath');
        return false;
      }
      _loaded = true;
      return true;
    } catch (e) {
      debugPrint('llama bridge loadModel error: $e');
      unload();
      return false;
    }
  }

  /// 以已載入的模型實際生成文字（裝置端 llama.cpp 推論）。
  Future<String> generate(String prompt, {int maxTokens = 256}) async {
    if (!_loaded) return '';
    try {
      return LlamaFfi.generate(_handle, prompt, maxTokens: maxTokens);
    } catch (e) {
      debugPrint('llama bridge generate error: $e');
      return '';
    }
  }

  void unload() {
    _loaded = false;
    if (_handle.address != 0) {
      LlamaFfi.free(_handle);
      _handle = ffi.Pointer.fromAddress(0);
    }
  }

  void dispose() {
    unload();
  }
}
