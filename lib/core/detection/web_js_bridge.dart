import 'dart:js_interop';
import 'dart:typed_data';

/// dart:js_interop 對 web/fs_bridge.js（OPFS 儲存）與 web/ort_bridge.js
/// （onnxruntime-web 推論）的薄封裝。刻意只用基本型別（String / bool / num /
/// Uint8Array）跨越 JS 邊界，複雜的瀏覽器 API（FileSystemHandle、InferenceSession…）
/// 一律留在 JS 端處理，降低 interop 型別對應出錯的風險。

@JS('truthlensFs.readBytes')
external JSPromise<JSUint8Array?> _fsReadBytes(JSString fileName);

@JS('truthlensFs.writeBytes')
external JSPromise<JSAny?> _fsWriteBytes(JSString fileName, JSUint8Array bytes);

@JS('truthlensFs.exists')
external JSPromise<JSBoolean> _fsExists(JSString fileName);

@JS('truthlensFs.deleteFile')
external JSPromise<JSAny?> _fsDeleteFile(JSString fileName);

@JS('truthlensFs.readText')
external JSPromise<JSString?> _fsReadText(JSString fileName);

@JS('truthlensFs.writeText')
external JSPromise<JSAny?> _fsWriteText(JSString fileName, JSString text);

/// OPFS（瀏覽器沙盒檔案系統）存取，供 web 版 ModelManager 快取已下載模型。
class WebFs {
  static Future<Uint8List?> readBytes(String fileName) async {
    final r = await _fsReadBytes(fileName.toJS).toDart;
    return r?.toDart;
  }

  static Future<void> writeBytes(String fileName, Uint8List bytes) =>
      _fsWriteBytes(fileName.toJS, bytes.toJS).toDart;

  static Future<bool> exists(String fileName) async =>
      (await _fsExists(fileName.toJS).toDart).toDart;

  static Future<void> deleteFile(String fileName) =>
      _fsDeleteFile(fileName.toJS).toDart;

  static Future<String?> readText(String fileName) async =>
      (await _fsReadText(fileName.toJS).toDart)?.toDart;

  static Future<void> writeText(String fileName, String text) =>
      _fsWriteText(fileName.toJS, text.toJS).toDart;
}

extension type _OrtRunResult._(JSObject _) implements JSObject {
  external JSArray<JSNumber> get data;
  external JSArray<JSNumber> get dims;
}

@JS('truthlensOrt.loadModel')
external JSPromise<JSString> _ortLoadModel(JSString modelId, JSUint8Array bytes);

@JS('truthlensOrt.run')
external JSPromise<_OrtRunResult> _ortRun(
    JSString modelId, JSInt32Array inputIds, JSInt32Array attentionMask, JSNumber seqLen);

@JS('truthlensOrt.releaseModel')
external void _ortReleaseModel(JSString modelId);

@JS('truthlensOrt.epKind')
external JSString? _ortEpKind();

/// 單一模型的 onnxruntime-web session 包裝。[modelId] 須跨呼叫維持一致
/// （通常用 role，例如 'transformer'/'statistical'/'adversarial'）。
class WebOrtSession {
  final String modelId;
  bool _loaded = false;

  WebOrtSession(this.modelId);

  bool get isLoaded => _loaded;

  /// 載入模型（bytes 來自 [WebFs.readBytes]）。回傳實際採用的 execution provider。
  Future<String> load(Uint8List modelBytes) async {
    final ep = await _ortLoadModel(modelId.toJS, modelBytes.toJS).toDart;
    _loaded = true;
    return ep.toDart;
  }

  /// 執行推論，回傳輸出張量的扁平資料與形狀；呼叫端依模型輸出形狀自行 reshape
  /// （分類器為 [1,2]，困惑度模型為 [1,seq,vocab]）。
  Future<(List<double>, List<int>)> run(
      List<int> inputIds, List<int> attentionMask) async {
    final ids = Int32List.fromList(inputIds).toJS;
    final mask = Int32List.fromList(attentionMask).toJS;
    final result =
        await _ortRun(modelId.toJS, ids, mask, inputIds.length.toJS).toDart;
    final data = result.data.toDart.map((n) => n.toDartDouble).toList();
    final dims = result.dims.toDart.map((n) => n.toDartInt).toList();
    return (data, dims);
  }

  void dispose() {
    if (_loaded) {
      _ortReleaseModel(modelId.toJS);
      _loaded = false;
    }
  }
}

/// 目前使用中的 execution provider('webgpu' / 'wasm'),尚未載入任何模型時為 null。
String? currentOrtExecutionProvider() => _ortEpKind()?.toDart;
