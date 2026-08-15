import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// 使用者透過原生 `<input type=file>` 選取的檔案結果
class PickedWebFile {
  final String name;
  final Uint8List bytes;

  const PickedWebFile({required this.name, required this.bytes});

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

const Map<String, String> _mimeByExtension = {
  'txt': 'text/plain',
  'md': 'text/markdown',
  'markdown': 'text/markdown',
  'pdf': 'application/pdf',
  'docx':
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'doc': 'application/msword',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'heic': 'image/heic',
  'heif': 'image/heic',
  'tiff': 'image/tiff',
  'tif': 'image/tiff',
  'bmp': 'image/bmp',
};

/// 開啟原生檔案選擇對話框，取代 `file_picker` 套件的 web 實作。
///
/// `file_picker` 11.x 在 web 平台有兩個已知問題，會直接導致行動裝置匯入失敗：
/// 1. `accept` 屬性只帶副檔名、不帶 MIME type；Android 原生選擇器是以
///    MIME 分類檔案的，純副檔名常導致清單為空、或篩不出 doc/docx。
/// 2. 視窗重新取得焦點後 1 秒內沒收到 `change` 事件就強制視為使用者取消；
///    手機上的選擇流程（尤其雲端硬碟選擇器、較慢裝置）常常晚於 1 秒才觸發
///    `change`，因而被誤判為取消。
///
/// 這裡改用瀏覽器原生 `<input type=file>`：`accept` 同時帶副檔名與 MIME，
/// 且不設任何強制取消計時器——只在瀏覽器支援時（Chrome 113+ 等）監聽原生
/// `cancel` 事件，避免對還在選擇中的使用者做出錯誤的取消判斷。
Future<PickedWebFile?> pickWebFile({required List<String> extensions}) async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = _buildAccept(extensions);
  input.style
    ..setProperty('position', 'fixed')
    ..setProperty('top', '-1000px')
    ..setProperty('opacity', '0');
  web.document.body?.append(input);

  final completer = Completer<PickedWebFile?>();
  var settled = false;

  void finish(PickedWebFile? value) {
    if (settled) return;
    settled = true;
    input.remove();
    if (!completer.isCompleted) completer.complete(value);
  }

  Future<void> handleChange() async {
    final files = input.files;
    final file = (files != null && files.length > 0) ? files.item(0) : null;
    if (file == null) {
      finish(null);
      return;
    }
    try {
      final buffer = await file.arrayBuffer().toDart;
      finish(PickedWebFile(name: file.name, bytes: buffer.toDart.asUint8List()));
    } catch (_) {
      finish(null);
    }
  }

  void onChange(web.Event _) {
    unawaited(handleChange());
  }

  input.addEventListener('change', onChange.toJS);
  input.addEventListener('cancel', ((web.Event _) => finish(null)).toJS);

  input.click();
  return completer.future;
}

String _buildAccept(List<String> extensions) {
  final exts = extensions.map((e) => '.${e.toLowerCase()}');
  final mimes = extensions
      .map((e) => _mimeByExtension[e.toLowerCase()])
      .whereType<String>()
      .toSet();
  return {...exts, ...mimes}.join(',');
}
