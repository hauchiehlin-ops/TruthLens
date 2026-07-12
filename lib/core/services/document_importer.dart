import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

/// 文件匯入：支援 txt, md, pdf, docx, doc 等格式的離線解析。
class DocumentImporter {
  static const supportedExtensions = [
    'txt',
    'md',
    'markdown',
    'pdf',
    'docx',
    'doc',
  ];

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

    // withData: true 已確保各平台（含 web，僅提供 bytes、無 path）都會填入 bytes。
    final bytes = file.bytes;
    if (bytes == null) return null;

    final extension = file.extension?.toLowerCase() ?? '';
    String text = '';

    try {
      if (extension == 'pdf') {
        // PDF 離線文字抽取
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        text = PdfTextExtractor(document).extractText();
        document.dispose();
      } else if (extension == 'docx') {
        // DOCX 離線解壓與 <w:t> 文字提取
        text = _parseDocx(bytes);
      } else if (extension == 'doc') {
        // 舊版 OLE Binary DOC 格式寬字元與可讀區段提取 Heuristics
        text = _parseLegacyDoc(bytes);
      } else {
        // 預設為純文字（txt, md 等）
        text = utf8.decode(bytes, allowMalformed: true);
      }
    } catch (e) {
      // 發生錯誤時以純文字作為防退方案
      text = utf8.decode(bytes, allowMalformed: true);
    }

    return ImportedDocument(
      fileName: file.name,
      text: _stripFormatting(text.trim()),
    );
  }

  /// 移除常見的 Markdown 格式符號與 HTML 標籤，純化文字供 AI 分析
  static String _stripFormatting(String text) {
    var result = text;
    // 1. 移除程式碼區塊與行內程式碼
    result = result.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    result = result.replaceAll(RegExp(r'`[^`]+`'), '');
    // 2. 移除 HTML 標籤
    result = result.replaceAll(RegExp(r'<[^>]*>', multiLine: true), '');
    // 3. 提取 Markdown 連結與圖片文字 (![text](url) 或 [text](url))
    result = result.replaceAllMapped(RegExp(r'!?\[([^\]]*)\]\([^)]+\)'), (match) => match.group(1) ?? '');
    // 4. 移除 Markdown 標題
    result = result.replaceAll(RegExp(r'^#+\s+', multiLine: true), '');
    // 5. 移除 Markdown 引用
    result = result.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    // 6. 移除無序與有序列表前綴
    result = result.replaceAll(RegExp(r'^(\s*[-*+]|\s*\d+\.)\s+', multiLine: true), '');
    // 7. 移除粗體與斜體符號 (** / __)
    result = result.replaceAll(RegExp(r'\*\*|__'), '');
    // 8. 縮減過多的換行
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return result.trim();
  }

  static String _parseDocx(List<int> bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final file = archive.findFile('word/document.xml');
      if (file == null) return '';
      final xmlContent = utf8.decode(file.content as List<int>, allowMalformed: true);
      
      final regex = RegExp(r'<w:t[^>]*>(.*?)</w:t>');
      final matches = regex.allMatches(xmlContent);
      final textBuffer = StringBuffer();
      
      for (final match in matches) {
        var t = match.group(1) ?? '';
        t = t
            .replaceAll('&amp;', '&')
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&apos;', "'");
        textBuffer.write(t);
      }
      return textBuffer.toString();
    } catch (_) {
      return '';
    }
  }

  static String _parseLegacyDoc(List<int> bytes) {
    final buffer = StringBuffer();
    
    // Heuristic 1: 掃描 UTF-16LE 寬字元段落（Word 常用）
    for (int i = 0; i < bytes.length - 1; i += 2) {
      final charCode = bytes[i] | (bytes[i + 1] << 8);
      if ((charCode >= 32 && charCode <= 126) || 
          (charCode >= 0x4E00 && charCode <= 0x9FFF)) {
        buffer.writeCharCode(charCode);
      } else if (charCode == 10 || charCode == 13) {
        buffer.write('\n');
      }
    }
    
    // Heuristic 2: 若提取字元過少，回退至 ASCII printable 字元提取
    if (buffer.length < 50) {
      buffer.clear();
      final currentRun = <int>[];
      for (final b in bytes) {
        final isPrintable = (b >= 32 && b <= 126) || b == 10 || b == 13 || b == 9;
        if (isPrintable) {
          currentRun.add(b);
        } else {
          if (currentRun.length >= 4) {
            buffer.write(utf8.decode(currentRun, allowMalformed: true));
            buffer.write(' ');
          }
          currentRun.clear();
        }
      }
    }

    return buffer.toString()
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '')
        .replaceAll(RegExp(r' {2,}'), ' ')
        .trim();
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
