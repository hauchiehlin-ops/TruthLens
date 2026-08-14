import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:image/image.dart' as image_lib;
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:syncfusion_flutter_pdf/pdf.dart';

typedef PdfOcrRecognizer =
    Future<String?> Function(
      Uint8List imageBytes,
      int pageNumber,
      int pageCount,
    );

enum PdfImportIssue { none, needsOcr, tooManyPages, unreadable }

/// 文件匯入：支援 txt, md, pdf, docx, doc；PDF 文字層失效時可選擇 OCR。
class DocumentImporter {
  static const int maxPdfOcrPages = 100;
  static const double _minimumPdfTextQuality = 0.62;

  static const supportedExtensions = [
    'txt',
    'md',
    'markdown',
    'pdf',
    'docx',
    'doc',
  ];

  /// 開啟選檔對話框並讀取內容；使用者取消時回傳 null
  static Future<ImportedDocument?> pick({
    PdfOcrRecognizer? pdfOcr,
    void Function(int pageNumber, int pageCount)? onPdfOcrProgress,
  }) async {
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
    final parsed = extension == 'pdf'
        ? await _parsePdf(
            Uint8List.fromList(bytes),
            pdfOcr: pdfOcr,
            onPdfOcrProgress: onPdfOcrProgress,
          )
        : _PdfParseResult(text: parseBytes(bytes, extension: extension));

    return ImportedDocument(
      fileName: file.name,
      text: _stripFormatting(parsed.text.trim()),
      usedPdfOcr: parsed.usedOcr,
      pdfImportIssue: parsed.issue,
    );
  }

  @visibleForTesting
  static String parseBytes(List<int> bytes, {required String extension}) {
    final normalizedExtension = extension.toLowerCase();

    try {
      if (normalizedExtension == 'pdf') {
        final text = _extractSyncfusionPdfText(bytes);
        return _isUsablePdfText(text) ? text : '';
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

  static String _extractSyncfusionPdfText(List<int> bytes) {
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    try {
      return PdfTextExtractor(document).extractText();
    } finally {
      document.dispose();
    }
  }

  static Future<_PdfParseResult> _parsePdf(
    Uint8List bytes, {
    PdfOcrRecognizer? pdfOcr,
    void Function(int pageNumber, int pageCount)? onPdfOcrProgress,
  }) async {
    String syncfusionText = '';
    try {
      syncfusionText = _extractSyncfusionPdfText(bytes);
    } catch (_) {}

    pdfrx.PdfDocument? document;
    String pdfiumText = '';
    try {
      document = await pdfrx.PdfDocument.openData(
        bytes,
        sourceName: 'truthlens-import-${DateTime.now().microsecondsSinceEpoch}',
      );
      final buffer = StringBuffer();
      for (final page in document.pages) {
        try {
          final pageText = await page.loadStructuredText();
          if (pageText.fullText.trim().isNotEmpty) {
            if (buffer.isNotEmpty) buffer.writeln();
            buffer.write(pageText.fullText.trim());
          }
        } catch (_) {}
      }
      pdfiumText = buffer.toString();

      final bestText = _bestPdfTextCandidate([pdfiumText, syncfusionText]);
      if (bestText.isNotEmpty) {
        return _PdfParseResult(text: bestText);
      }

      if (pdfOcr == null) {
        return const _PdfParseResult(issue: PdfImportIssue.needsOcr);
      }
      if (document.pages.length > maxPdfOcrPages) {
        return const _PdfParseResult(issue: PdfImportIssue.tooManyPages);
      }

      final ocrText = StringBuffer();
      for (final page in document.pages) {
        final pageNumber = page.pageNumber;
        onPdfOcrProgress?.call(pageNumber, document.pages.length);
        final longestSide = math.max(page.width, page.height);
        final scale = math.min(2.0, 2200 / longestSide);
        final rendered = await page.render(
          fullWidth: page.width * scale,
          fullHeight: page.height * scale,
          backgroundColor: 0xffffffff,
        );
        if (rendered == null) continue;
        try {
          final raster = image_lib.Image.fromBytes(
            width: rendered.width,
            height: rendered.height,
            bytes: rendered.pixels.buffer,
            bytesOffset: rendered.pixels.offsetInBytes,
            numChannels: 4,
            order: image_lib.ChannelOrder.bgra,
          );
          final png = Uint8List.fromList(image_lib.encodePng(raster, level: 6));
          final pageText = await pdfOcr(png, pageNumber, document.pages.length);
          if (pageText != null && pageText.trim().isNotEmpty) {
            if (ocrText.isNotEmpty) ocrText.writeln();
            ocrText.write(pageText.trim());
          }
        } finally {
          rendered.dispose();
        }
      }
      final recognized = ocrText.toString().trim();
      return recognized.isEmpty
          ? const _PdfParseResult(issue: PdfImportIssue.unreadable)
          : _PdfParseResult(text: recognized, usedOcr: true);
    } catch (_) {
      final fallback = _bestPdfTextCandidate([syncfusionText]);
      return fallback.isEmpty
          ? const _PdfParseResult(issue: PdfImportIssue.unreadable)
          : _PdfParseResult(text: fallback);
    } finally {
      await document?.dispose();
    }
  }

  static String _bestPdfTextCandidate(Iterable<String> candidates) {
    var best = '';
    var bestScore = 0.0;
    for (final candidate in candidates) {
      final score = pdfTextQuality(candidate);
      if (score > bestScore) {
        best = candidate;
        bestScore = score;
      }
    }
    return bestScore >= _minimumPdfTextQuality ? best : '';
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
    return pdfTextQuality(text) >= _minimumPdfTextQuality;
  }

  @visibleForTesting
  static double pdfTextQuality(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _looksLikeRawPdfStructure(trimmed)) return 0;

    final runes = trimmed.runes.toList(growable: false);
    final visible = runes
        .where((rune) => !RegExp(r'\s').hasMatch(String.fromCharCode(rune)))
        .length;
    if (visible < 20) return 0;

    final lettersAndDigits = RegExp(
      r'[\p{L}\p{N}]',
      unicode: true,
    ).allMatches(trimmed).length;
    final badCodePoints = runes.where((rune) {
      return rune == 0xfffd ||
          (rune >= 0xe000 && rune <= 0xf8ff) ||
          (rune >= 0xf0000 && rune <= 0xffffd) ||
          (rune >= 0x100000 && rune <= 0x10fffd) ||
          (rune < 0x20 && rune != 0x09 && rune != 0x0a && rune != 0x0d);
    }).length;
    final mojibakeHits = RegExp(
      r'(?:Ã.|Â.|â€|â€™|â€œ|â€|ï¿½|ðŸ|�)',
    ).allMatches(trimmed).length;
    final tokens = trimmed
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    final singleCharacterTokens = tokens
        .where((token) => token.runes.length == 1)
        .length;
    final wordRuns = RegExp(
      r'(?:[A-Za-zÀ-ÖØ-öø-ÿ]{2,}|[\u3400-\u9fff]{2,}|[\u3040-\u30ff]{2,}|[\uac00-\ud7af]{2,})',
      unicode: true,
    ).allMatches(trimmed).length;
    final languageAnchors = RegExp(
      r'\b(?:the|and|of|to|in|for|is|are|with|from|that|this|der|die|das|und|de|la|le|les|el|los|las|y|en|para|dan|yang|untuk)\b|[的一是在有和為與及研究資料分析內容文獻]',
      caseSensitive: false,
      unicode: true,
    ).allMatches(trimmed).length;

    var score = 0.0;
    final alnumRatio = lettersAndDigits / visible;
    score += (alnumRatio / 0.7).clamp(0.0, 1.0) * 0.35;
    score += (1 - (badCodePoints / runes.length * 12)).clamp(0.0, 1.0) * 0.25;
    score += (wordRuns / 8).clamp(0.0, 1.0) * 0.15;
    score += (languageAnchors / 4).clamp(0.0, 1.0) * 0.15;
    score += (trimmed.length / 300).clamp(0.0, 1.0) * 0.10;

    if (mojibakeHits > 0) score -= math.min(0.45, mojibakeHits * 0.08);
    if (tokens.length >= 12 && singleCharacterTokens / tokens.length > 0.55) {
      score -= 0.30;
    }
    if (trimmed.length >= 200 && languageAnchors == 0) score -= 0.18;
    return score.clamp(0.0, 1.0);
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
  final bool usedPdfOcr;
  final PdfImportIssue pdfImportIssue;

  const ImportedDocument({
    required this.fileName,
    required this.text,
    this.usedPdfOcr = false,
    this.pdfImportIssue = PdfImportIssue.none,
  });
}

class _PdfParseResult {
  final String text;
  final bool usedOcr;
  final PdfImportIssue issue;

  const _PdfParseResult({
    this.text = '',
    this.usedOcr = false,
    this.issue = PdfImportIssue.none,
  });
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
