import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// 文件匯入：目前支援純文字格式（txt / md）。
/// PDF 文字抽取與 docx 解析為後續 P1/P3 擴充項目。
class DocumentImporter {
  static const supportedExtensions = ['txt', 'md', 'markdown'];

  /// 開啟選檔對話框並讀取內容；使用者取消時回傳 null
  static Future<ImportedDocument?> pick() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: '匯入文件',
      type: FileType.custom,
      allowedExtensions: supportedExtensions,
      withData: true, // 行動平台以 bytes 提供內容
    );
    final file = result?.files.firstOrNull;
    if (file == null) return null;

    final bytes = file.bytes ??
        (file.path != null ? await File(file.path!).readAsBytes() : null);
    if (bytes == null) return null;

    return ImportedDocument(
      fileName: file.name,
      text: utf8.decode(bytes, allowMalformed: true).trim(),
    );
  }
}

class ImportedDocument {
  final String fileName;
  final String text;
  const ImportedDocument({required this.fileName, required this.text});
}

/// 圖片選取（供 OCR 使用）
class ImagePicker {
  static const supportedExtensions = ['jpg', 'jpeg', 'png', 'heic', 'tiff', 'bmp'];

  /// 開啟選檔對話框選一張圖片，回傳本地路徑；取消回傳 null
  static Future<String?> pick() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: '選擇要辨識的圖片',
      type: FileType.custom,
      allowedExtensions: supportedExtensions,
    );
    return result?.files.firstOrNull?.path;
  }
}
