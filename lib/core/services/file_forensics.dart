/// 檔案層的確定性鑑識：PDF 產生器、DOCX 封裝指紋、網頁貼上殘留、C2PA 內容憑證。
///
/// 這些都是「檔案怎麼產生的」證據，而不是「文字像不像 AI」。它們的證據力
/// 差異很大，呼叫端（[DocumentProvenance]）依此分級：
/// - 產生器直接寫著 AI 產品 → 作者身分證據
/// - 程式庫產生、封裝與宣稱軟體不符、網頁貼上 → 只說明寫作過程，不推向 AI
/// - 內嵌圖片的 C2PA → 說明的是圖片來源，與內文作者無關
///
/// 全部以位元組／字串比對完成，不需要網路，也不需要額外套件。
library;

import 'dart:convert';

/// PDF 文件資訊字典與 XMP 中的產生器欄位
class PdfMetadata {
  final String? creator;
  final String? producer;
  final String? creatorTool;

  const PdfMetadata({this.creator, this.producer, this.creatorTool});

  static const PdfMetadata empty = PdfMetadata();

  bool get isEmpty =>
      creator == null && producer == null && creatorTool == null;

  /// 依可信度排列的產生器描述：XMP CreatorTool 與 Creator 是「哪個軟體做的」，
  /// Producer 是「哪個程式庫轉成 PDF」——前者較能代表來源。
  List<String> get values => [?creatorTool, ?creator, ?producer];

  /// 顯示用的單一名稱
  String? get primary => creatorTool ?? creator ?? producer;

  PdfMetadata mergedWith(PdfMetadata other) => PdfMetadata(
    creator: creator ?? other.creator,
    producer: producer ?? other.producer,
    creatorTool: creatorTool ?? other.creatorTool,
  );

  /// 從 PDF 原始位元組解析。只讀未壓縮的資訊字典與 XMP 封包；PDF 1.5 以後
  /// 放在壓縮物件串流中的資訊字典讀不到，呼叫端可用 PDF 函式庫補上
  /// （見 [mergedWith]）。
  static PdfMetadata parse(List<int> bytes) {
    final text = latin1.decode(bytes, allowInvalid: true);
    String? info(String key) {
      final match = RegExp(
        '/$key\\s*(\\((?:\\\\.|[^\\\\)])*\\)|<[0-9A-Fa-f\\s]*>)',
      ).firstMatch(text);
      final raw = match?.group(1);
      if (raw == null) return null;
      return _clean(raw.startsWith('(') ? _literal(raw) : _hex(raw));
    }

    String? xmp(String tag) {
      final element = RegExp('<$tag>([^<]*)</$tag>').firstMatch(text)?.group(1);
      final attribute = RegExp('$tag="([^"]*)"').firstMatch(text)?.group(1);
      final raw = element ?? attribute;
      return raw == null ? null : _clean(_utf8(raw));
    }

    return PdfMetadata(
      creator: info('Creator'),
      producer: info('Producer') ?? xmp('pdf:Producer'),
      creatorTool: xmp('xmp:CreatorTool'),
    );
  }

  static String? _clean(String value) {
    final trimmed = value.replaceAll(RegExp(r'[\x00-\x1F]'), '').trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// latin1 解出的字串若其實是 UTF-8 位元組，轉回正確文字
  static String _utf8(String latin) {
    try {
      return utf8.decode(latin1.encode(latin));
    } catch (_) {
      return latin;
    }
  }

  static String _literal(String raw) {
    final body = raw.substring(1, raw.length - 1);
    final out = <int>[];
    for (var i = 0; i < body.length; i++) {
      final ch = body.codeUnitAt(i);
      if (ch != 0x5C || i + 1 >= body.length) {
        out.add(ch);
        continue;
      }
      final next = body[++i];
      switch (next) {
        case 'n':
          out.add(0x0A);
        case 'r':
          out.add(0x0D);
        case 't':
          out.add(0x09);
        case '(' || ')' || r'\':
          out.add(next.codeUnitAt(0));
        default:
          final octal = RegExp(r'^[0-7]{1,3}').stringMatch(body.substring(i));
          if (octal != null) {
            out.add(int.parse(octal, radix: 8) & 0xFF);
            i += octal.length - 1;
          } else {
            out.add(next.codeUnitAt(0));
          }
      }
    }
    return _decodeTextString(out);
  }

  static String _hex(String raw) {
    final digits = raw.replaceAll(RegExp(r'[<>\s]'), '');
    final padded = digits.length.isOdd ? '${digits}0' : digits;
    return _decodeTextString([
      for (var i = 0; i < padded.length; i += 2)
        int.parse(padded.substring(i, i + 2), radix: 16),
    ]);
  }

  /// PDF 文字字串：以 FE FF 開頭為 UTF-16BE，否則視為 PDFDocEncoding／UTF-8
  static String _decodeTextString(List<int> bytes) {
    if (bytes.length >= 2 && bytes[0] == 0xFE && bytes[1] == 0xFF) {
      final units = <int>[
        for (var i = 2; i + 1 < bytes.length; i += 2)
          (bytes[i] << 8) | bytes[i + 1],
      ];
      return String.fromCharCodes(units);
    }
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes, allowInvalid: true);
    }
  }
}

/// 程式化產生文件的程式庫。出現在產生器欄位代表檔案由自動化流程寫出，
/// 不是在文書軟體裡編輯——AI 服務的匯出功能多半如此，但報表系統、
/// 轉檔服務也一樣，因此只作佐證。
///
/// 刻意不收：Chrome 列印的 `Skia/PDF`、macOS 的 `Quartz PDFContext`、
/// LaTeX（pdfTeX、XeTeX）、Microsoft／LibreOffice 轉存——這些都是真人日常使用的工具。
/// 也不收 iText／OpenPDF／pdftk 與 Acrobat PDFMaker：以 503 份已出版論文實測，
/// 出版社加下載浮水印時會留下 iText，Word 外掛 PDFMaker 會被誤認為 pdfmake，
/// 兩者合計誤標 40 篇真人論文。
final RegExp programmaticLibraryPattern = RegExp(
  r'(?:python-docx|docx4j|docxtemplater|officegen|phpword|apache poi|'
  r'aspose|spire\.(?:doc|pdf)|groupdocs|pandoc|reportlab|pdf-lib|'
  r'\bpypdf\d?\b|pdfsharp|migradoc|\bfpdf\d?\b|jspdf|\bpdfmake\b|'
  r'wkhtmltopdf|weasyprint|dompdf|\bmpdf\b|tcpdf|\bpdfkit\b|playwright|'
  r'puppeteer)',
  caseSensitive: false,
);

/// 回傳產生器欄位中的程式庫名稱，找不到為 null
String? matchProgrammaticLibrary(Iterable<String> values) {
  for (final value in values) {
    final match = programmaticLibraryPattern.firstMatch(value);
    if (match != null) return match.group(0);
  }
  return null;
}

/// DOCX 封裝結構的指紋
class DocxPackage {
  final Set<String> parts;

  const DocxPackage(this.parts);

  /// Word 每次存檔一定寫入的部件。缺了這些，檔案不是 Word 存的。
  static const wordCoreParts = {'word/settings.xml', 'word/fontTable.xml'};

  bool get hasWordCoreParts => wordCoreParts.every(parts.contains);

  /// 只有最少必要部件（沒有設定與字型表）：典型的程式一次性封裝
  bool get isMinimal =>
      !parts.contains('word/settings.xml') &&
      !parts.contains('word/fontTable.xml');
}

/// DOCX 中「從網頁或對話介面直接貼上」留下的格式
class WebPasteResidue {
  /// 套用「Normal (Web)」或 HTML 系列樣式的段落／文字段
  final int webStyledRuns;

  /// 以 altChunk 原樣嵌入的 HTML 區塊
  final int htmlChunks;

  /// 偵測到的 AI 對話介面網頁字型（例如 Söhne）
  final String? chatInterfaceFont;

  /// 偵測到的通用網頁字型堆疊（ui-sans-serif、system-ui…）
  final String? webFontStack;

  const WebPasteResidue({
    this.webStyledRuns = 0,
    this.htmlChunks = 0,
    this.chatInterfaceFont,
    this.webFontStack,
  });

  static const WebPasteResidue none = WebPasteResidue();

  /// 構成「從網頁貼上」的跡象。單一兩處 Normal (Web) 可能是使用者手動套用
  /// 的樣式，要求達到一定數量，或出現 altChunk／網頁字型這類不會手動產生的痕跡。
  bool get indicatesWebPaste =>
      webStyledRuns >= 3 || htmlChunks > 0 || webFontStack != null;

  int get affectedBlocks => webStyledRuns + htmlChunks;

  /// AI 對話介面使用的網頁字型。只收辨識度高、桌面文書軟體不會內建的字型；
  /// 其他介面的字型需要實際貼上樣本確認後再加入。
  static final RegExp chatInterfaceFonts = RegExp(
    r'(?:S(?:ö|o|&#246;|&#xF6;)hne|Google Sans Text)',
    caseSensitive: false,
  );

  /// 網頁字型堆疊：只有從瀏覽器貼上才會把這些 CSS 字型名寫進 docx
  static final RegExp webFontStacks = RegExp(
    r'(?:ui-sans-serif|ui-monospace|system-ui|-apple-system|BlinkMacSystemFont)',
    caseSensitive: false,
  );

  static WebPasteResidue scan({required String document, String styles = ''}) {
    final webStyled = RegExp(
      r'<w:(?:pStyle|rStyle) w:val="(?:NormalWeb|HTML[A-Za-z]*)"',
    ).allMatches(document).length;
    final chunks = RegExp(r'<w:altChunk\b').allMatches(document).length;
    final fonts = [
      for (final m in RegExp(
        r'w:(?:ascii|hAnsi|eastAsia|cs)="([^"]+)"',
      ).allMatches('$document$styles'))
        m.group(1)!,
    ];
    String? first(RegExp pattern) {
      for (final font in fonts) {
        final match = pattern.firstMatch(font);
        if (match != null) return font;
      }
      return null;
    }

    return WebPasteResidue(
      webStyledRuns: webStyled,
      htmlChunks: chunks,
      chatInterfaceFont: first(chatInterfaceFonts),
      webFontStack: first(webFontStacks),
    );
  }
}

/// 內嵌的 C2PA 內容憑證（只讀出宣告，不驗證數位簽章）
class C2paFinding {
  /// 憑證宣告的產生工具（claim_generator），讀不到時為 null
  final String? generator;

  const C2paFinding({this.generator});

  /// 掃描媒體或整份檔案的位元組。C2PA 清單以 JUMBF 方塊保存，標籤為 `c2pa`；
  /// PNG 放在 `caBX` 區塊，JPEG 放在 APP11 區段，PDF 以內嵌檔案保存。
  /// 只要同時看到 JUMBF 方塊與 `c2pa` 標籤即視為帶有憑證。
  static C2paFinding? scan(List<int> bytes) {
    final text = latin1.decode(bytes, allowInvalid: true);
    if (!text.contains('jumb') || !text.contains('c2pa')) return null;
    return C2paFinding(generator: _generator(text));
  }

  static final _knownGenerators = RegExp(
    r'(?:Anthropic|Claude|OpenAI|ChatGPT|DALL.?E|Sora|Google|Gemini|'
    r'Imagen|Adobe Firefly|Firefly|Microsoft Designer|Bing Image Creator|'
    r'Midjourney|Stable Diffusion|Adobe Photoshop|Adobe Lightroom)',
  );

  /// 讀 CBOR 中 `claim_generator` 之後的文字字串；讀不到時退回辨識常見工具名
  static String? _generator(String text) {
    for (final key in const ['claim_generator', 'name']) {
      var index = text.indexOf(key);
      while (index >= 0) {
        final value = _cborText(text, index + key.length);
        if (value != null && value.length >= 3 && !value.contains('\u0000')) {
          if (key == 'claim_generator' || _knownGenerators.hasMatch(value)) {
            return value;
          }
        }
        index = text.indexOf(key, index + key.length);
      }
    }
    return _knownGenerators.firstMatch(text)?.group(0);
  }

  /// CBOR 文字字串（major type 3）：0x60+長度，或 0x78 後接 1 位元組長度
  static String? _cborText(String text, int at) {
    if (at >= text.length) return null;
    final head = text.codeUnitAt(at);
    int length;
    var start = at + 1;
    if (head >= 0x60 && head <= 0x77) {
      length = head - 0x60;
    } else if (head == 0x78 && start < text.length) {
      length = text.codeUnitAt(start);
      start++;
    } else {
      return null;
    }
    if (start + length > text.length) return null;
    final raw = text.substring(start, start + length);
    try {
      return utf8.decode(latin1.encode(raw)).trim();
    } catch (_) {
      return raw.trim();
    }
  }
}
