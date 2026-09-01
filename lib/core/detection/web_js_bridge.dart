import 'dart:js_interop';
import 'dart:typed_data';

/// dart:js_interop 對 web/fs_bridge.js（OPFS 儲存）與 web/ort_bridge.js
/// （onnxruntime-web 推論）的薄封裝。刻意只用基本型別（String / bool / num /
/// Uint8Array）跨越 JS 邊界，複雜的瀏覽器 API（FileSystemHandle、InferenceSession…）
/// 一律留在 JS 端處理，降低 interop 型別對應出錯的風險。

@JS('omnitraceFs.readBytes')
external JSPromise<JSUint8Array?> _fsReadBytes(JSString fileName);

@JS('omnitraceFs.writeBytes')
external JSPromise<JSAny?> _fsWriteBytes(JSString fileName, JSUint8Array bytes);

@JS('omnitraceFs.exists')
external JSPromise<JSBoolean> _fsExists(JSString fileName);

@JS('omnitraceFs.size')
external JSPromise<JSNumber> _fsSize(JSString fileName);

@JS('omnitraceFs.deleteFile')
external JSPromise<JSAny?> _fsDeleteFile(JSString fileName);

@JS('omnitraceFs.readText')
external JSPromise<JSString?> _fsReadText(JSString fileName);

@JS('omnitraceFs.writeText')
external JSPromise<JSAny?> _fsWriteText(JSString fileName, JSString text);

@JS('omnitraceFs.openWritable')
external JSPromise<JSObject> _fsOpenWritable(JSString fileName);

@JS('omnitraceFs.writeChunk')
external JSPromise<JSAny?> _fsWriteChunk(JSObject writable, JSUint8Array bytes);

@JS('omnitraceFs.closeWritable')
external JSPromise<JSAny?> _fsCloseWritable(JSObject writable);

@JS('omnitraceFs.abortWritable')
external JSPromise<JSAny?> _fsAbortWritable(JSObject writable);

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

  static Future<int> size(String fileName) async =>
      (await _fsSize(fileName.toJS).toDart).toDartDouble.toInt();

  static Future<void> deleteFile(String fileName) =>
      _fsDeleteFile(fileName.toJS).toDart;

  static Future<String?> readText(String fileName) async =>
      (await _fsReadText(fileName.toJS).toDart)?.toDart;

  static Future<void> writeText(String fileName, String text) =>
      _fsWriteText(fileName.toJS, text.toJS).toDart;

  /// 開啟一個可逐塊寫入的 OPFS 串流（供大型模型檔案下載時邊收邊寫，
  /// 不必先把整份檔案累積在記憶體）。用畢務必呼叫 [closeWritable] 或
  /// [abortWritable] 之一，否則底層檔案鎖不會釋放。
  static Future<WebFsWritable> openWritable(String fileName) async {
    final handle = await _fsOpenWritable(fileName.toJS).toDart;
    return WebFsWritable._(handle);
  }
}

/// 對應瀏覽器 `FileSystemWritableFileStream` 的薄封裝。
class WebFsWritable {
  final JSObject _handle;

  WebFsWritable._(this._handle);

  Future<void> writeChunk(Uint8List bytes) =>
      _fsWriteChunk(_handle, bytes.toJS).toDart;

  Future<void> close() => _fsCloseWritable(_handle).toDart;

  Future<void> abort() => _fsAbortWritable(_handle).toDart;
}

extension type _OrtRunResult._(JSObject _) implements JSObject {
  external JSArray<JSNumber> get data;
  external JSArray<JSNumber> get dims;
}

@JS('omnitraceOrt.loadModel')
external JSPromise<JSString> _ortLoadModel(
  JSString modelId,
  JSUint8Array bytes,
);

@JS('omnitraceOrt.runBatch')
external JSPromise<_OrtRunResult> _ortRunBatch(
  JSString modelId,
  JSInt32Array inputIds,
  JSInt32Array attentionMask,
  JSNumber batchSize,
  JSNumber seqLen,
  JSString? runtimeJson,
);

@JS('omnitraceOrt.releaseModel')
external void _ortReleaseModel(JSString modelId);

@JS('omnitraceOrt.epKind')
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
    List<int> inputIds,
    List<int> attentionMask, {
    String? runtimeJson,
  }) => runBatch(
    inputIds,
    attentionMask,
    1,
    inputIds.length,
    runtimeJson: runtimeJson,
  );

  /// [runtimeJson] 提供 JS 端猜不到的靜態維度（KV cache 的 heads/head_dim）。
  /// JS 端依模型自己宣告的輸入名稱決定要不要用；不需要時傳 null。
  Future<(List<double>, List<int>)> runBatch(
    List<int> inputIds,
    List<int> attentionMask,
    int batchSize,
    int sequenceLength, {
    String? runtimeJson,
  }) async {
    final ids = Int32List.fromList(inputIds).toJS;
    final mask = Int32List.fromList(attentionMask).toJS;
    final result = await _ortRunBatch(
      modelId.toJS,
      ids,
      mask,
      batchSize.toJS,
      sequenceLength.toJS,
      runtimeJson?.toJS,
    ).toDart;
    final data = result.data.toDart.map((n) => n.toDartDouble).toList();
    final dims = result.dims.toDart.map((n) => n.toDartDouble.toInt()).toList();
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

@JS('omnitraceDb.put')
external JSPromise<JSAny?> _dbPut(JSString entryJson);

@JS('omnitraceDb.getAllJson')
external JSPromise<JSString> _dbGetAllJson();

@JS('omnitraceDb.deleteEntry')
external JSPromise<JSAny?> _dbDeleteEntry(JSString id);

@JS('omnitraceDb.clear')
external JSPromise<JSAny?> _dbClear();

/// IndexedDB 存取，供 web 版 HistoryRepository 持久化歷史紀錄。單筆紀錄以 JSON
/// 字串跨越 JS 邊界，過濾/排序留在 Dart 端做（見 history_repository_web.dart）。
class WebDb {
  static Future<void> put(String entryJson) => _dbPut(entryJson.toJS).toDart;

  static Future<String> getAllJson() async =>
      (await _dbGetAllJson().toDart).toDart;

  static Future<void> deleteEntry(String id) => _dbDeleteEntry(id.toJS).toDart;

  static Future<void> clear() => _dbClear().toDart;
}
