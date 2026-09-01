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
        sourceName: 'omnitrace-import-${DateTime.now().microsecondsSinceEpoch}',
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
      .replaceAll('&apos;', "'")
      .replaceAllMapped(RegExp(r'&#(\d+);'), (match) {
        final codePoint = int.tryParse(match.group(1) ?? '');
        if (codePoint == null) return match.group(0) ?? '';
        return String.fromCharCode(codePoint);
      })
      .replaceAllMapped(RegExp(r'&#x([0-9A-Fa-f]+);'), (match) {
        final codePoint = int.tryParse(match.group(1) ?? '', radix: 16);
        if (codePoint == null) return match.group(0) ?? '';
        return String.fromCharCode(codePoint);
      });

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
    final cfb = _CompoundBinaryFile.tryParse(bytes);
    final sources = <List<int>>[];
    if (cfb != null) {
      final pieceTableText = _parseWordBinaryPieceTable(cfb);
      if (_isUsableText(pieceTableText)) return pieceTableText;

      for (final name in const ['WordDocument', '0Table', '1Table']) {
        final stream = cfb.readStream(name);
        if (stream != null && stream.isNotEmpty) sources.add(stream);
      }
    }
    if (sources.isEmpty) sources.add(bytes);

    final candidates = <String>[];
    for (final source in sources) {
      candidates
        ..addAll(_scanUtf16LeTextRuns(source, alignment: 0))
        ..addAll(_scanUtf16LeTextRuns(source, alignment: 1))
        ..addAll(_scanUtf8TextRuns(source))
        ..addAll(_scanAsciiTextRuns(source));
    }

    var best = '';
    var bestScore = 0.0;
    for (final candidate in candidates) {
      final cleaned = _cleanExtractedLegacyText(candidate);
      final score = pdfTextQuality(cleaned);
      if (score > bestScore ||
          (score == bestScore && cleaned.length > best.length)) {
        best = cleaned;
        bestScore = score;
      }
    }
    return bestScore >= _minimumPdfTextQuality ? best : '';
  }

  /// Word 97-2003 `.doc` 的正文通常不是連續純文字，而是由 WordDocument
  /// FIB 指向 0Table/1Table 的 CLX piece table，再由 piece descriptors 指回
  /// WordDocument 的實際字元區段。只掃二進位 stream 會漏掉主文或抓到尾端雜訊；
  /// 這裡先走真正的 piece table，失敗時才回退到舊 heuristic。
  static String _parseWordBinaryPieceTable(_CompoundBinaryFile cfb) {
    final wordDocument = cfb.readStream('WordDocument');
    if (wordDocument == null || wordDocument.length < 0x1aa) return '';
    final wordData = ByteData.sublistView(wordDocument);
    if (wordData.getUint16(0, Endian.little) != 0xa5ec) return '';

    final flags = wordData.getUint16(0x0a, Endian.little);
    final tableName = (flags & 0x0200) != 0 ? '1Table' : '0Table';
    final table = cfb.readStream(tableName);
    if (table == null || table.isEmpty) return '';

    final fcClx = wordData.getUint32(0x01a2, Endian.little);
    final lcbClx = wordData.getUint32(0x01a6, Endian.little);
    if (lcbClx == 0 || fcClx + lcbClx > table.length) return '';

    final clx = table.sublist(fcClx, fcClx + lcbClx);
    final pieces = _readWordBinaryPieces(clx);
    if (pieces.isEmpty) return '';

    final buffer = StringBuffer();
    for (final piece in pieces) {
      final charCount = piece.endCp - piece.startCp;
      if (charCount <= 0) continue;
      final text = piece.compressed
          ? _decodeWordBinaryCompressedPiece(
              wordDocument,
              piece.fileOffset,
              charCount,
            )
          : _decodeWordBinaryUnicodePiece(
              wordDocument,
              piece.fileOffset,
              charCount,
            );
      if (text.isEmpty) continue;
      if (buffer.isNotEmpty && !_endsWithWhitespace(buffer.toString())) {
        buffer.write('\n');
      }
      buffer.write(text);
    }
    return _cleanExtractedLegacyText(buffer.toString());
  }

  static List<_WordBinaryPiece> _readWordBinaryPieces(Uint8List clx) {
    final data = ByteData.sublistView(clx);
    var offset = 0;
    while (offset < clx.length) {
      final marker = clx[offset];
      offset += 1;
      if (marker == 0x01) {
        if (offset + 2 > clx.length) return const [];
        final skip = data.getUint16(offset, Endian.little);
        offset += 2 + skip;
        continue;
      }
      if (marker != 0x02 || offset + 4 > clx.length) return const [];

      final tableLength = data.getUint32(offset, Endian.little);
      offset += 4;
      if (tableLength < 12 || offset + tableLength > clx.length) {
        return const [];
      }
      final pieceCount = ((tableLength - 4) / 12).floor();
      if (pieceCount <= 0 || pieceCount > 100000) return const [];

      final cpOffset = offset;
      final pcdOffset = cpOffset + (pieceCount + 1) * 4;
      if (pcdOffset + pieceCount * 8 > offset + tableLength) return const [];

      final pieces = <_WordBinaryPiece>[];
      for (var i = 0; i < pieceCount; i++) {
        final startCp = data.getUint32(cpOffset + i * 4, Endian.little);
        final endCp = data.getUint32(cpOffset + (i + 1) * 4, Endian.little);
        final rawFc = data.getUint32(pcdOffset + i * 8 + 2, Endian.little);
        final compressed = (rawFc & 0x40000000) != 0;
        final fileOffset = compressed ? (rawFc & 0x3fffffff) ~/ 2 : rawFc;
        pieces.add(
          _WordBinaryPiece(
            startCp: startCp,
            endCp: endCp,
            fileOffset: fileOffset,
            compressed: compressed,
          ),
        );
      }
      return pieces;
    }
    return const [];
  }

  static String _decodeWordBinaryUnicodePiece(
    Uint8List bytes,
    int offset,
    int charCount,
  ) {
    final byteLength = charCount * 2;
    if (offset < 0 || byteLength <= 0 || offset + byteLength > bytes.length) {
      return '';
    }
    final codes = <int>[];
    final data = ByteData.sublistView(bytes);
    for (var i = 0; i < byteLength; i += 2) {
      final codePoint = data.getUint16(offset + i, Endian.little);
      codes.add(_normalizeWordBinaryControlChar(codePoint));
    }
    return String.fromCharCodes(codes);
  }

  static String _decodeWordBinaryCompressedPiece(
    Uint8List bytes,
    int offset,
    int charCount,
  ) {
    if (offset < 0 || charCount <= 0 || offset + charCount > bytes.length) {
      return '';
    }
    final codes = <int>[];
    for (var i = 0; i < charCount; i++) {
      codes.add(_normalizeWordBinaryControlChar(bytes[offset + i]));
    }
    return String.fromCharCodes(codes);
  }

  static int _normalizeWordBinaryControlChar(int codePoint) {
    return switch (codePoint) {
      0x0007 || 0x000d || 0x000b => 0x000a,
      0x0009 => 0x0009,
      _ => codePoint,
    };
  }

  static bool _endsWithWhitespace(String text) =>
      text.isNotEmpty && RegExp(r'\s$').hasMatch(text);

  static Iterable<String> _scanUtf16LeTextRuns(
    List<int> bytes, {
    required int alignment,
  }) sync* {
    final buffer = StringBuffer();
    for (var i = alignment; i + 1 < bytes.length; i += 2) {
      final codePoint = bytes[i] | (bytes[i + 1] << 8);
      if (_isLegacyTextCodePoint(codePoint)) {
        buffer.writeCharCode(codePoint);
      } else {
        final value = _takeReadableRun(buffer, minimumVisible: 12);
        if (value != null) yield value;
      }
    }
    final value = _takeReadableRun(buffer, minimumVisible: 12);
    if (value != null) yield value;
  }

  static Iterable<String> _scanUtf8TextRuns(List<int> bytes) sync* {
    final run = <int>[];
    for (var i = 0; i < bytes.length; i++) {
      final b = bytes[i];
      final isTextByte =
          b == 0x09 || b == 0x0a || b == 0x0d || (b >= 0x20 && b <= 0xf4);
      if (isTextByte) {
        run.add(b);
      } else {
        final value = _decodeByteRun(run, minimumBytes: 24);
        if (value != null) yield value;
      }
    }
    final value = _decodeByteRun(run, minimumBytes: 24);
    if (value != null) yield value;
  }

  static Iterable<String> _scanAsciiTextRuns(List<int> bytes) sync* {
    final run = <int>[];
    for (final b in bytes) {
      final isPrintable =
          b == 0x09 || b == 0x0a || b == 0x0d || b >= 32 && b <= 126;
      if (isPrintable) {
        run.add(b);
      } else {
        final value = _decodeByteRun(run, minimumBytes: 24);
        if (value != null) yield value;
      }
    }
    final value = _decodeByteRun(run, minimumBytes: 24);
    if (value != null) yield value;
  }

  static bool _isLegacyTextCodePoint(int codePoint) {
    return codePoint == 0x09 ||
        codePoint == 0x0a ||
        codePoint == 0x0d ||
        codePoint >= 0x20 && codePoint <= 0x7e ||
        codePoint >= 0xa0 && codePoint <= 0x2fff ||
        codePoint >= 0x3400 && codePoint <= 0x9fff ||
        codePoint >= 0xac00 && codePoint <= 0xd7af ||
        codePoint >= 0xf900 && codePoint <= 0xfaff ||
        codePoint >= 0xff00 && codePoint <= 0xffef;
  }

  static String? _takeReadableRun(
    StringBuffer buffer, {
    required int minimumVisible,
  }) {
    if (buffer.isEmpty) return null;
    final value = buffer.toString();
    buffer.clear();
    final visible = value.runes
        .where((rune) => !RegExp(r'\s').hasMatch(String.fromCharCode(rune)))
        .length;
    return visible >= minimumVisible ? value : null;
  }

  static String? _decodeByteRun(List<int> run, {required int minimumBytes}) {
    if (run.length < minimumBytes) {
      run.clear();
      return null;
    }
    final value = utf8.decode(run, allowMalformed: true);
    run.clear();
    return value;
  }

  static String _cleanExtractedLegacyText(String text) {
    return text
        .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }
}

class _CompoundBinaryFile {
  static const List<int> _signature = [
    0xD0,
    0xCF,
    0x11,
    0xE0,
    0xA1,
    0xB1,
    0x1A,
    0xE1,
  ];
  static const int _endOfChain = 0xFFFFFFFE;
  static const int _defaultMiniCutoff = 4096;
  static const int _maxSectors = 1 << 20;

  final Uint8List _bytes;
  final int _sectorSize;
  final int _miniSectorSize;
  final int _miniCutoff;
  final List<int> _fat;
  final Uint8List _miniStream;
  final List<int> _miniFat;
  final Map<String, _CompoundBinaryStream> _streams;

  const _CompoundBinaryFile._(
    this._bytes,
    this._sectorSize,
    this._miniSectorSize,
    this._miniCutoff,
    this._fat,
    this._miniStream,
    this._miniFat,
    this._streams,
  );

  static _CompoundBinaryFile? tryParse(List<int> input) {
    try {
      final bytes = Uint8List.fromList(input);
      if (bytes.length < 512) return null;
      for (var i = 0; i < _signature.length; i++) {
        if (bytes[i] != _signature[i]) return null;
      }

      final data = ByteData.sublistView(bytes);
      final sectorSize = 1 << data.getUint16(30, Endian.little);
      final miniSectorSize = 1 << data.getUint16(32, Endian.little);
      if (sectorSize < 128 || sectorSize > 1 << 16) return null;
      if (miniSectorSize < 16 || miniSectorSize > sectorSize) return null;

      int offsetOf(int sector) => (sector + 1) * sectorSize;
      bool inRange(int sector) =>
          sector >= 0 &&
          sector < _maxSectors &&
          offsetOf(sector) + sectorSize <= bytes.length;

      final fatSectorCount = data.getUint32(44, Endian.little);
      final firstDirSector = data.getUint32(48, Endian.little);
      final miniCutoff = data.getUint32(56, Endian.little);
      final firstMiniFatSector = data.getUint32(60, Endian.little);
      final firstDifatSector = data.getUint32(68, Endian.little);

      final difat = <int>[];
      for (var i = 0; i < 109 && i < fatSectorCount; i++) {
        difat.add(data.getUint32(76 + i * 4, Endian.little));
      }

      var difatSector = firstDifatSector;
      var difatGuard = 0;
      while (difat.length < fatSectorCount &&
          inRange(difatSector) &&
          difatGuard++ < _maxSectors) {
        final base = offsetOf(difatSector);
        final entries = sectorSize ~/ 4 - 1;
        for (var i = 0; i < entries && difat.length < fatSectorCount; i++) {
          difat.add(data.getUint32(base + i * 4, Endian.little));
        }
        difatSector = data.getUint32(base + entries * 4, Endian.little);
      }

      final fat = <int>[];
      for (final sector in difat) {
        if (!inRange(sector)) return null;
        final base = offsetOf(sector);
        for (var i = 0; i < sectorSize ~/ 4; i++) {
          fat.add(data.getUint32(base + i * 4, Endian.little));
        }
      }
      if (fat.isEmpty) return null;

      List<int> chain(int start, List<int> table) {
        final out = <int>[];
        final seen = <int>{};
        var sector = start;
        while (sector < table.length && sector != _endOfChain) {
          if (!seen.add(sector)) break;
          if (out.length >= _maxSectors) break;
          out.add(sector);
          sector = table[sector];
        }
        return out;
      }

      Uint8List readRegularChain(int start, int size) {
        final out = BytesBuilder();
        for (final sector in chain(start, fat)) {
          if (!inRange(sector)) break;
          out.add(
            bytes.sublist(offsetOf(sector), offsetOf(sector) + sectorSize),
          );
        }
        final all = out.toBytes();
        return size > 0 && size <= all.length ? all.sublist(0, size) : all;
      }

      final dirSectors = chain(firstDirSector, fat);
      var rootStart = 0;
      var rootSize = 0;
      final streams = <String, _CompoundBinaryStream>{};

      for (final sector in dirSectors) {
        if (!inRange(sector)) return null;
        final base = offsetOf(sector);
        for (var e = 0; e + 128 <= sectorSize; e += 128) {
          final entry = base + e;
          final nameLength = data.getUint16(entry + 64, Endian.little);
          final type = bytes[entry + 66];
          if (type != 2 && type != 5) continue;

          final chars = <int>[];
          for (var i = 0; i + 1 < nameLength - 2 && i < 64; i += 2) {
            chars.add(data.getUint16(entry + i, Endian.little));
          }
          final name = String.fromCharCodes(chars);
          final start = data.getUint32(entry + 116, Endian.little);
          final size = data.getUint32(entry + 120, Endian.little);

          if (type == 5) {
            rootStart = start;
            rootSize = size;
          } else if (name.isNotEmpty && size > 0) {
            streams[name] = _CompoundBinaryStream(start, size);
          }
        }
      }

      final miniStream = readRegularChain(rootStart, rootSize);
      final miniFatRaw = readRegularChain(firstMiniFatSector, 0);
      final miniFat = <int>[];
      final miniFatData = ByteData.sublistView(miniFatRaw);
      for (var i = 0; i + 4 <= miniFatRaw.length; i += 4) {
        miniFat.add(miniFatData.getUint32(i, Endian.little));
      }

      return _CompoundBinaryFile._(
        bytes,
        sectorSize,
        miniSectorSize,
        miniCutoff == 0 ? _defaultMiniCutoff : miniCutoff,
        fat,
        miniStream,
        miniFat,
        streams,
      );
    } catch (_) {
      return null;
    }
  }

  Uint8List? readStream(String name) {
    final stream = _streams[name];
    if (stream == null) return null;
    if (stream.size >= _miniCutoff) {
      return _readRegularChain(stream.start, stream.size);
    }
    return _readMiniChain(stream.start, stream.size);
  }

  Uint8List _readRegularChain(int start, int size) {
    final out = BytesBuilder();
    for (final sector in _chain(start, _fat)) {
      if (!_inRange(sector)) break;
      final offset = _offsetOf(sector);
      out.add(_bytes.sublist(offset, offset + _sectorSize));
    }
    final all = out.toBytes();
    return size > 0 && size <= all.length ? all.sublist(0, size) : all;
  }

  Uint8List _readMiniChain(int start, int size) {
    final out = BytesBuilder();
    for (final mini in _chain(start, _miniFat)) {
      final offset = mini * _miniSectorSize;
      if (offset + _miniSectorSize > _miniStream.length) break;
      out.add(_miniStream.sublist(offset, offset + _miniSectorSize));
    }
    final all = out.toBytes();
    return size > 0 && size <= all.length ? all.sublist(0, size) : all;
  }

  List<int> _chain(int start, List<int> table) {
    final out = <int>[];
    final seen = <int>{};
    var sector = start;
    while (sector < table.length && sector != _endOfChain) {
      if (!seen.add(sector)) break;
      if (out.length >= _maxSectors) break;
      out.add(sector);
      sector = table[sector];
    }
    return out;
  }

  int _offsetOf(int sector) => (sector + 1) * _sectorSize;

  bool _inRange(int sector) =>
      sector >= 0 &&
      sector < _maxSectors &&
      _offsetOf(sector) + _sectorSize <= _bytes.length;
}

class _CompoundBinaryStream {
  final int start;
  final int size;

  const _CompoundBinaryStream(this.start, this.size);
}

class _WordBinaryPiece {
  final int startCp;
  final int endCp;
  final int fileOffset;
  final bool compressed;

  const _WordBinaryPiece({
    required this.startCp,
    required this.endCp,
    required this.fileOffset,
    required this.compressed,
  });
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
