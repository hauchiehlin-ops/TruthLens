import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'document_provenance.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:image/image.dart' as image_lib;
import 'package:pdfrx/pdfrx.dart' as pdfrx;
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../detection/device_capabilities.dart';
import '../detection/model_catalog.dart' show PerformanceTier;
import '../models/input_quality.dart';
import 'web_file_picker.dart' if (dart.library.io) 'web_file_picker_stub.dart';

typedef PdfOcrRecognizer =
    Future<String?> Function(
      Uint8List imageBytes,
      int pageNumber,
      int pageCount,
    );

enum PdfImportIssue {
  none,
  needsOcr,
  tooManyPages,
  unreadable,
  legacyDocUnreadable,
}

/// 文件匯入：支援 txt, md, pdf, docx, doc, odt；PDF 文字層失效時可選擇 OCR。
class DocumentImporter {
  static const int maxPdfOcrPages = 100;
  static const double _minimumPdfTextQuality = 0.62;

  /// 上一次 PDF OCR 依裝置分級套用的實際頁數上限，供「頁數過多」提示訊息使用
  /// （因為實際上限依裝置記憶體動態調整，不再固定等於 [maxPdfOcrPages]）。
  static int effectiveMaxPdfOcrPages = maxPdfOcrPages;

  /// 依裝置效能分級決定 PDF 掃描檔 OCR 的頁數上限與光柵化解析度上限：
  /// 低階（多為手機）裝置記憶體有限，同時光柵化多頁高解析度圖片很容易讓
  /// 分頁記憶體見底（尤其疊加 CanvasKit 與 ONNX WASM 堆），因此調低上限。
  static int _pdfOcrPageLimitFor(PerformanceTier tier) => switch (tier) {
    PerformanceTier.low => 20,
    PerformanceTier.mid => 50,
    PerformanceTier.high => maxPdfOcrPages,
  };

  static double _pdfOcrRenderLongestSideFor(PerformanceTier tier) =>
      switch (tier) {
        PerformanceTier.low => 1400,
        PerformanceTier.mid => 1800,
        PerformanceTier.high => 2200,
      };

  static const supportedExtensions = [
    'txt',
    'md',
    'markdown',
    'pdf',
    'docx',
    'doc',
    'odt',
  ];

  /// 開啟選檔對話框並讀取內容；使用者取消時回傳 null
  static Future<ImportedDocument?> pick({
    PdfOcrRecognizer? pdfOcr,
    void Function(int pageNumber, int pageCount)? onPdfOcrProgress,
  }) async {
    final file = await pickWebFile(extensions: supportedExtensions);
    if (file == null) return null;

    final bytes = file.bytes;
    final extension = file.extension;
    final parsed = extension == 'pdf'
        ? await _parsePdf(
            bytes,
            pdfOcr: pdfOcr,
            onPdfOcrProgress: onPdfOcrProgress,
          )
        : _parseNonPdf(bytes, extension);

    final text = _stripFormatting(parsed.text.trim());
    return ImportedDocument(
      fileName: file.name,
      text: text,
      usedPdfOcr: parsed.usedOcr,
      pdfImportIssue: parsed.issue,
      inputQuality: InputQualityEvidence(
        method: _acquisitionMethod(extension, parsed.usedOcr),
        extractionQuality: parsed.quality > 0
            ? parsed.quality
            : pdfTextQuality(text),
        limitations: [
          if (parsed.usedOcr) 'ocr_transcription',
          if ((parsed.quality > 0 ? parsed.quality : pdfTextQuality(text)) <
              0.75)
            'low_extraction_quality',
        ],
      ),
      // 來源證據只有 zip 容器格式（docx/odt）帶得出來；其餘格式回傳 none
      provenance: DocumentProvenance.fromBytes(
        bytes,
        extension: extension,
        bodyText: text,
      ),
    );
  }

  static InputAcquisitionMethod _acquisitionMethod(
    String extension,
    bool usedOcr,
  ) {
    if (usedOcr) return InputAcquisitionMethod.ocr;
    return switch (extension.toLowerCase()) {
      'pdf' => InputAcquisitionMethod.pdfTextLayer,
      'docx' || 'odt' => InputAcquisitionMethod.structuredDocument,
      'doc' => InputAcquisitionMethod.legacyDocument,
      _ => InputAcquisitionMethod.directText,
    };
  }

  @visibleForTesting
  static String parseBytes(List<int> bytes, {required String extension}) {
    final normalizedExtension = extension.toLowerCase();

    try {
      if (normalizedExtension == 'pdf') {
        final text = _extractSyncfusionPdfText(bytes);
        return _isUsableText(text) ? text : '';
      } else if (normalizedExtension == 'docx') {
        // DOCX 離線解壓與 <w:t> 文字提取
        return _parseDocx(bytes);
      } else if (normalizedExtension == 'odt') {
        // ODT（OpenDocument Text，Google 文件「下載→OpenDocument」的匯出
        // 格式）離線解壓與 content.xml 文字提取
        return _parseOdt(bytes);
      } else if (normalizedExtension == 'doc') {
        // 舊版 OLE Binary DOC 並非純文字容器（FAT 磁區表、目錄項、屬性集、
        // 壓縮/分段文字流等二進位結構），下方僅為位元組層級的 Heuristics，
        // 不是真正的 OLE2/CFB 解析器；把結構性位元組誤判為寬字元時，會產生
        // 貌似合理但其實是雜訊的文字（隨機命中 CJK 區段的亂碼＋替代字元）。
        // 因此以與 PDF 相同的文字品質檢查把關，品質不足就視為無法讀取，
        // 不讓亂碼進入分析流程。
        final text = _parseLegacyDoc(bytes);
        return _isUsableText(text) ? text : '';
      }
    } catch (e) {
      // PDF 是二進位容器，不能以純文字 fallback，否則會把 xref / obj /
      // trailer 等內部結構誤當正文匯入。其他純文字類型仍可容錯解碼。
      if (normalizedExtension == 'pdf') return '';
    }

    // 預設為純文字（txt, md 等）
    return utf8.decode(bytes, allowMalformed: true);
  }

  /// 非 PDF 副檔名的匯入結果組裝；.doc 因僅有 Heuristics 可用，品質不足時
  /// 需標示專屬的 [PdfImportIssue.legacyDocUnreadable]，與一般「找不到文字」
  /// 區分開來，才能提示使用者改用 .docx 或 PDF 匯入。
  static _PdfParseResult _parseNonPdf(List<int> bytes, String extension) {
    final text = parseBytes(bytes, extension: extension);
    if (extension.toLowerCase() == 'doc' && text.isEmpty) {
      return const _PdfParseResult(issue: PdfImportIssue.legacyDocUnreadable);
    }
    return _PdfParseResult(text: text, quality: pdfTextQuality(text));
  }

  static String _extractSyncfusionPdfText(List<int> bytes) {
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    try {
      // layoutText: true 是必要的，不是美化選項。預設模式會把單字之間的空白
      // 全部吃掉——同一篇論文抽出來是 InternationalJournalofBifurcationandChaos，
      // 平均「詞長」12.4 字元、英文功能詞佔比 1.42%。後果是全面性的：
      // 語言辨識判為未定（連帶讓困惑度整項被棄用）、詞彙多樣性因每個黏字串
      // 都是唯一詞而虛高、突發性與 Transformer 斷詞同樣失真。
      // 開啟後：詞元 1060 → 2950、平均詞長 → 4.5、功能詞 → 24.68%、語言 → en。
      return PdfTextExtractor(document).extractText(layoutText: true);
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
        return _PdfParseResult(
          text: bestText,
          quality: pdfTextQuality(bestText),
        );
      }

      if (pdfOcr == null) {
        return const _PdfParseResult(issue: PdfImportIssue.needsOcr);
      }

      final tier = (await DeviceCapabilities.detect()).tier;
      final pageLimit = _pdfOcrPageLimitFor(tier);
      final renderLongestSide = _pdfOcrRenderLongestSideFor(tier);
      effectiveMaxPdfOcrPages = pageLimit;
      if (document.pages.length > pageLimit) {
        return const _PdfParseResult(issue: PdfImportIssue.tooManyPages);
      }

      final ocrText = StringBuffer();
      for (final page in document.pages) {
        final pageNumber = page.pageNumber;
        onPdfOcrProgress?.call(pageNumber, document.pages.length);
        final longestSide = math.max(page.width, page.height);
        final scale = math.min(2.0, renderLongestSide / longestSide);
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
          : _PdfParseResult(
              text: recognized,
              usedOcr: true,
              quality: pdfTextQuality(recognized) * 0.85,
            );
    } catch (_) {
      final fallback = _bestPdfTextCandidate([syncfusionText]);
      return fallback.isEmpty
          ? const _PdfParseResult(issue: PdfImportIssue.unreadable)
          : _PdfParseResult(text: fallback, quality: pdfTextQuality(fallback));
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

      final textBuffer = StringBuffer();

      final paragraphs = RegExp(
        r'<w:p(?:\s[^>]*)?>[\s\S]*?</w:p>',
      ).allMatches(xmlContent);
      for (final paragraph in paragraphs) {
        final paragraphXml = paragraph.group(0) ?? '';
        final paragraphBuffer = StringBuffer();
        final nodes = RegExp(
          r'<w:t(?:\s[^>]*)?>([\s\S]*?)</w:t>|<w:tab\s*/>|<w:br(?:\s[^>]*)?\s*/>',
        ).allMatches(paragraphXml);
        for (final node in nodes) {
          final rawText = node.group(1);
          if (rawText != null) {
            paragraphBuffer.write(_decodeXmlEntities(rawText));
          } else if ((node.group(0) ?? '').startsWith('<w:tab')) {
            paragraphBuffer.write('\t');
          } else {
            paragraphBuffer.write('\n');
          }
        }
        final paragraphText = paragraphBuffer.toString().trim();
        if (paragraphText.isEmpty) continue;
        if (textBuffer.isNotEmpty) textBuffer.write('\n\n');
        textBuffer.write(paragraphText);
      }
      return textBuffer.toString();
    } catch (_) {
      return '';
    }
  }

  /// ODT（OpenDocument Text）與 DOCX 同為 zip+XML 容器，但文字節點直接夾在
  /// 段落／標題／清單項標籤內（無 DOCX 那種獨立 `<w:t>` run 標籤包住每段
  /// 文字），因此改用「先把段落／換行標籤轉為實際換行，再剝除所有標籤只
  /// 留文字節點」的做法，而非逐一比對特定標籤。
  static String _parseOdt(List<int> bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final file = archive.findFile('content.xml');
      if (file == null) return '';
      var xmlContent = utf8.decode(
        file.content as List<int>,
        allowMalformed: true,
      );

      xmlContent = xmlContent
          .replaceAll(RegExp(r'<text:tab\s*/>'), '\t')
          .replaceAll(RegExp(r'<text:line-break\s*/>'), '\n')
          .replaceAll(RegExp(r'</text:p>'), '\n\n')
          .replaceAll(RegExp(r'</text:h>'), '\n\n')
          .replaceAll(RegExp(r'</text:list-item>'), '\n\n');

      final textBuffer = StringBuffer();
      var insideTag = false;
      for (final rune in xmlContent.runes) {
        if (rune == 0x3C) {
          insideTag = true;
        } else if (rune == 0x3E) {
          insideTag = false;
        } else if (!insideTag) {
          textBuffer.writeCharCode(rune);
        }
      }

      final text = textBuffer
          .toString()
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&apos;', "'");

      return text.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    } catch (_) {
      return '';
    }
  }

  static String _decodeXmlEntities(String text) => text
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'");

  static bool _isUsableText(String text) {
    return pdfTextQuality(text) >= _minimumPdfTextQuality;
  }

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
  final InputQualityEvidence inputQuality;

  /// 檔案自身攜帶的編輯紀錄證據（僅 docx/odt 有；其餘為
  /// [DocumentProvenance.none]）
  final DocumentProvenance provenance;

  const ImportedDocument({
    required this.fileName,
    required this.text,
    this.usedPdfOcr = false,
    this.pdfImportIssue = PdfImportIssue.none,
    this.inputQuality = InputQualityEvidence.unknown,
    this.provenance = DocumentProvenance.none,
  });
}

class _PdfParseResult {
  final String text;
  final bool usedOcr;
  final PdfImportIssue issue;
  final double quality;

  const _PdfParseResult({
    this.text = '',
    this.usedOcr = false,
    this.issue = PdfImportIssue.none,
    this.quality = 0,
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

  /// 開啟選檔對話框選一張圖片，回傳 data URL；取消回傳 null
  static Future<String?> pick() async {
    final file = await pickWebFile(extensions: supportedExtensions);
    if (file == null) return null;
    final mimeType = _mimeTypeFor(file.extension);
    return 'data:$mimeType;base64,${base64Encode(file.bytes)}';
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
