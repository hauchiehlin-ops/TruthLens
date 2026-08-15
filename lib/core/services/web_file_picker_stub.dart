import 'dart:typed_data';

/// `web_file_picker.dart` 的非 web（VM/io）替身，僅供編譯期解析使用
/// （例如 `flutter test` 預設在 VM 上執行）。本 App 僅部署於 Web，
/// 此分支在執行期不會真的被呼叫到。
class PickedWebFile {
  final String name;
  final Uint8List bytes;

  const PickedWebFile({required this.name, required this.bytes});

  String get extension {
    final dot = name.lastIndexOf('.');
    return dot == -1 ? '' : name.substring(dot + 1).toLowerCase();
  }
}

Future<PickedWebFile?> pickWebFile({required List<String> extensions}) {
  throw UnsupportedError('pickWebFile is only available on the web target.');
}
