import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
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
    final text = parseBytes(bytes, extension: extension);

    return ImportedDocument(
      fileName: file.name,
      text: _stripFormatting(text.trim()),
    );
  }

  @visibleForTesting
  static String parseBytes(List<int> bytes, {required String extension}) {
    final normalizedExtension = extension.toLowerCase();

    try {
      if (normalizedExtension == 'pdf') {
        // PDF 離線文字抽取
        final PdfDocument document = PdfDocument(inputBytes: bytes);
        try {
          final text = PdfTextExtractor(document).extractText();
          return _isUsablePdfText(text) ? text : '';
        } finally {
          document.dispose();
        }
      } else if (normalizedExtension == 'docx') {
        // DOCX 離線解壓與 <w:t> 文字提取
        return _parseDocx(bytes);
      } else if (normalizedExtension == 'doc') {
        // 舊版 OLE Binary DOC 格式寬字元與可讀區段提取 Heuristics
        return _parseLegacyDoc(bytes);
      }
    } catch (e) {
      // PDF 是二進位容器，不能以純文字 fallback，否則會把 xref / obj /
      // trailer 等內部結構誤當正文匯入。其他純文字類型仍可容錯解碼。
      if (normalizedExtension == 'pdf') return '';
    }

    // 預設為純文字（txt, md 等）
    return utf8.decode(bytes, allowMalformed: true);
  }

  /// 移除常見的 Markdown 格式符號、HTML 標籤、LaTeX 數學公式、頁首頁尾與頁碼噪音，純化文字供 AI 分析
  static String _stripFormatting(String text) {
    var result = text;
    // 1. 移除程式碼區塊與行內程式碼（MVP 1 Code Shield）
    result = result.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    result = result.replaceAll(RegExp(r'`[^`]+`'), '');

    // 2. 移除 LaTeX 數學公式與方程式環境（MVP 1 Formula Shield）
    result = result.replaceAll(RegExp(r'\$\$[\s\S]*?\$\$'), ''); // $$...$$
    result = result.replaceAll(RegExp(r'\\\[[\s\S]*?\\\]'), ''); // \[...\]
    result = result.replaceAll(
      RegExp(r'\\begin\{equation\}[\s\S]*?\\end\{equation\}'),
      '',
    );
    result = result.replaceAll(RegExp(r'\\\([\s\S]*?\\\)'), ''); // \(...\)
    result = result.replaceAll(RegExp(r'\$[^$\n]+\$'), ''); // $...$

    // 3. 移除頁首頁尾與頁碼噪音 (MVP 2 Structural Noise Stripping)
    result = result.replaceAll(
      RegExp(
        r'^\s*(?:Page\s*\|?\s*\d+(?:\s*of\s*\d+)?|第\s*\d+\s*頁(?:\s*，?\s*共\s*\d+\s*頁)?)\s*$',
        caseSensitive: false,
        multiLine: true,
      ),
      '',
    );
    result = result.replaceAll(
      RegExp(
        r'^\s*(?:Line|L)\s*\d+[\s:]*$',
        caseSensitive: false,
        multiLine: true,
      ),
      '',
    );

    // 4. 移除 HTML 標籤
    result = result.replaceAll(RegExp(r'<[^>]*>', multiLine: true), '');
    // 5. 提取 Markdown 連結與圖片文字 (![text](url) 或 [text](url))
    result = result.replaceAllMapped(
      RegExp(r'!?\[([^\]]*)\]\([^)]+\)'),
      (match) => match.group(1) ?? '',
    );
    // 6. 移除 Markdown 標題
    result = result.replaceAll(RegExp(r'^#+\s+', multiLine: true), '');
    // 7. 移除 Markdown 引用
    result = result.replaceAll(RegExp(r'^>\s+', multiLine: true), '');
    // 8. 移除無序列表前綴（保留數字列表與參考文獻編號 1., 2., 3. 等供結構化解析）
    result = result.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
    // 9. 移除粗體與斜體符號 (** / __)
    result = result.replaceAll(RegExp(r'\*\*|__'), '');
    // 10. 縮減過多的換行
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return result.trim();
  }

  static String _parseDocx(List<int> bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final file = archive.findFile('word/document.xml');
      if (file == null) return '';
      final xmlContent = utf8.decode(
        file.content as List<int>,
        allowMalformed: true,
      );

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

  static bool _isUsablePdfText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    if (_looksLikeRawPdfStructure(trimmed)) return false;

    final lettersAndDigits = RegExp(
      r'[\p{L}\p{N}]',
      unicode: true,
    ).allMatches(trimmed).length;
    final visible = RegExp(r'\S').allMatches(trimmed).length;
    if (visible == 0) return false;

    // 正常文章應有足夠可讀字元；若抽取結果主要是符號、控制字元或 PDF
    // 物件編號，寧可提示無可讀文字，避免後續 AI 分析被垃圾內容污染。
    return lettersAndDigits >= 20 && lettersAndDigits / visible >= 0.35;
  }

  static bool _looksLikeRawPdfStructure(String text) {
    final lower = text.toLowerCase();
    final structuralHits = <String>[
      '%pdf',
      'xref',
      'startxref',
      'trailer',
      'endobj',
      ' obj',
      '/calrgb',
      '/flatedecode',
      '%%eof',
    ].where(lower.contains).length;

    if (structuralHits >= 3) return true;

    final lines = text.split(RegExp(r'\r?\n'));
    if (lines.length < 6) return false;
    final xrefLikeLines = lines.where((line) {
      final value = line.trim();
      return RegExp(r'^\d{10}\s+\d{5}\s+[nf]\b').hasMatch(value) ||
          RegExp(r'^\d+\s+\d+\s+obj\b', caseSensitive: false).hasMatch(value);
    }).length;
    return xrefLikeLines >= 4;
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
        final isPrintable =
            (b >= 32 && b <= 126) || b == 10 || b == 13 || b == 9;
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

    return buffer
        .toString()
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
  static const supportedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'heic',
    'tiff',
    'bmp',
  ];

  /// 開啟選檔對話框選一張圖片，回傳本地路徑；取消回傳 null
  static Future<String?> pick() async {
    final result = await FilePicker.pickFiles(
      dialogTitle: '選擇要辨識的圖片',
      type: FileType.custom,
      allowedExtensions: supportedExtensions,
      withData: kIsWeb,
    );
    final file = result?.files.firstOrNull;
    if (file == null) return null;
    if (kIsWeb) {
      final bytes = file.bytes;
      if (bytes == null) return null;
      final mimeType = _mimeTypeFor(file.extension);
      return 'data:$mimeType;base64,${base64Encode(bytes)}';
    }
    return file.path;
  }

  static String _mimeTypeFor(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'tif':
      case 'tiff':
        return 'image/tiff';
      case 'bmp':
        return 'image/bmp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
