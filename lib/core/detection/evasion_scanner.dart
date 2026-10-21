/// 規避痕跡掃描：不可見字元與同形字。
///
/// 這是整套系統裡唯一**確定性**的檢查——不估機率，只回報「有沒有」。
///
/// 所謂「AI humanizer」工具的常見手法是在文字裡插入零寬字元，或把拉丁字母
/// 換成外觀相同的西里爾／希臘字母，藉此打亂偵測器的斷詞與統計。正常的寫作
/// 工具不會產生這些東西。
///
/// 這類痕跡的證據力與文本統計完全不同：它指向的不是「這段文字像 AI」，
/// 而是**「有人刻意規避偵測」**——後者本身就是一件需要解釋的事，
/// 而且不隨語言模型進步而失效。
library;

import '../models/input_quality.dart';
import 'cjk_lookalikes.dart';

/// 規避手法的種類
enum EvasionKind {
  /// 零寬字元（零寬空格／連接符／不連接符、BOM）
  zeroWidth,

  /// 外觀與 ASCII 字母相同的西里爾／希臘字母
  homoglyph,

  /// 非標準空白（不斷行空格、細空格、表意空格等）
  unusualSpace,

  /// 雙向控制字元，可讓顯示順序與實際字元順序不一致
  bidiControl,

  /// Unicode Tag 字元（U+E0000 區段）：完全不可見，常用來夾帶隱藏內容
  tagCharacter,

  /// 連續或接在字母後的變體選擇符：正常只會接在 emoji 或特定漢字之後
  variationSelector,

  /// 插在單字中間的軟連字號（U+00AD）：顯示不出來，卻會打斷斷詞
  softHyphen,

  /// 其他不可見的填充字元（不可見運算子、韓文填充字、蒙古文母音分隔符…）
  invisibleFiller,

  /// 夾在英文字中的全形拉丁字母（ｅ、ａ）
  fullwidthLatin,

  /// 夾在英文字中的數學字母符號（𝐚、𝑒）
  mathAlphanumeric,

  /// 外觀與常用漢字相同的康熙部首、部首補充與相容表意字（⼈、⾏）
  cjkRadical,

  /// 疊加三層以上的組合符號（「Zalgo」文字）
  combiningStack,
}

/// 單一種類的掃描結果
class EvasionFinding {
  final EvasionKind kind;

  /// 命中次數
  final int count;

  /// 實際出現的字元（去重，最多保留數個供介面呈現）
  final List<String> samples;

  const EvasionFinding({
    required this.kind,
    required this.count,
    this.samples = const [],
  });
}

/// 整份文件的掃描結果
class EvasionScan {
  final List<EvasionFinding> findings;

  /// 掃描時的總字元數，用來換算密度
  final int characterCount;

  /// 一般空格（U+0020）數量，用來判斷非標準空白佔多少比例
  final int regularSpaceCount;

  /// PDF 文字層與 OCR 可能由排版器帶入控制字元；這些發現仍會列出，但需要
  /// 更高密度才足以被解讀為刻意規避。
  final bool extractionDerived;

  const EvasionScan({
    this.findings = const [],
    this.characterCount = 0,
    this.regularSpaceCount = 0,
    this.extractionDerived = false,
  });

  static const EvasionScan clean = EvasionScan();

  bool get hasFindings => findings.isNotEmpty;

  int get totalHits => findings.fold(0, (sum, f) => sum + f.count);

  /// 是否構成刻意規避的證據。
  ///
  /// 單一個零寬字元可能來自複製貼上的殘留，不足以指控。要求達到一定數量，
  /// 或出現同形字／雙向控制字元這類**幾乎不會意外出現**的種類。
  bool get indicatesDeliberateEvasion {
    if (!hasFindings) return false;
    for (final f in findings) {
      switch (f.kind) {
        case EvasionKind.homoglyph:
          // 掃描器只保留嵌入 ASCII 單字的異體字母，三處以上才視為系統性替換。
          if (f.count >= 3) return true;
        case EvasionKind.bidiControl:
          if (f.count >= (extractionDerived ? 3 : 1)) return true;
        case EvasionKind.zeroWidth:
          if (f.count >= (extractionDerived ? 12 : 5)) return true;
        case EvasionKind.unusualSpace:
          // 出版社排版大量使用不斷行空格（實測單篇可達數百個），但只佔全部
          // 空白的一小部分；把空格整批換掉的工具會讓比例大幅升高
          final share = f.count / (f.count + regularSpaceCount);
          if (f.count >= (extractionDerived ? 40 : 20) &&
              share >= (extractionDerived ? 0.30 : 0.15)) {
            return true;
          }
        case EvasionKind.tagCharacter:
          // 旗幟 emoji 的合法 Tag 序列已在掃描時排除，剩下的沒有正當用途
          return true;
        case EvasionKind.variationSelector:
        case EvasionKind.fullwidthLatin:
        case EvasionKind.cjkRadical:
          if (f.count >= 3) return true;
        case EvasionKind.softHyphen:
          if (f.count >= (extractionDerived ? 40 : 5)) return true;
        case EvasionKind.invisibleFiller:
          if (f.count >= (extractionDerived ? 12 : 3)) return true;
        case EvasionKind.mathAlphanumeric:
          if (f.count >= (extractionDerived ? 12 : 3)) return true;
        case EvasionKind.combiningStack:
          if (f.count >= 2) return true;
      }
    }
    return false;
  }
}

// 零寬與格式控制字元
// 一律用轉義序列而非字面字元：把這些字元直接寫進原始碼，會讓程式碼的
// 顯示內容與編譯器讀到的不一致——那正是本掃描器要抓的手法本身。
final _zeroWidth = RegExp('[\\u200B\\u200C\\u200D\\u2060\\uFEFF]');

// 雙向控制字元（可讓顯示順序與實際順序不同）
final _bidiControl = RegExp('[\\u202A-\\u202E\\u2066-\\u2069]');

// 非標準空白
final _unusualSpace = RegExp('[\\u00A0\\u2000-\\u200A\\u202F\\u205F\\u3000]');

/// 與 ASCII 字母外觀相同的西里爾／希臘字母。
///
/// 只列**視覺上幾乎無法分辨**的那些。像西里爾 п、ж 這種一眼可辨的不列入——
/// 它們出現在拉丁文本裡是編碼問題，不是規避手法。
const _homoglyphs = <String, String>{
  // 西里爾字母（外觀與 ASCII 幾乎無法分辨的那些）
  'А': 'A', 'В': 'B', 'Е': 'E', 'К': 'K', 'М': 'M',
  'Н': 'H', 'О': 'O', 'Р': 'P', 'С': 'C', 'Т': 'T',
  'У': 'Y', 'Х': 'X',
  'а': 'a', 'е': 'e', 'о': 'o', 'р': 'p', 'с': 'c',
  'у': 'y', 'х': 'x',
  // 希臘字母
  'Α': 'A', 'Β': 'B', 'Ε': 'E', 'Ζ': 'Z', 'Η': 'H',
  'Ι': 'I', 'Κ': 'K', 'Μ': 'M', 'Ν': 'N', 'Ο': 'O',
  'Ρ': 'P', 'Τ': 'T', 'Υ': 'Y', 'Χ': 'X',
  'ο': 'o', 'ν': 'v',
};

/// 掃描 [raw] 的規避痕跡。
///
/// 同形字只在**拉丁文本**中判定：一份俄文或希臘文文件裡出現西里爾／希臘字母
/// 是理所當然的，那不是規避。判斷依據是文本中拉丁字母的佔比。
EvasionScan scanForEvasion(
  String raw, {
  InputAcquisitionMethod acquisitionMethod = InputAcquisitionMethod.directText,
}) {
  if (raw.isEmpty) return EvasionScan.clean;

  final extractionDerived = switch (acquisitionMethod) {
    InputAcquisitionMethod.pdfTextLayer ||
    InputAcquisitionMethod.ocr ||
    InputAcquisitionMethod.legacyDocument => true,
    _ => false,
  };

  final findings = <EvasionFinding>[];

  void add(EvasionKind kind, Iterable<String> hits) {
    final list = hits.toList();
    if (list.isEmpty) return;
    findings.add(
      EvasionFinding(
        kind: kind,
        count: list.length,
        samples: list.toSet().take(6).toList(),
      ),
    );
  }

  // 只數緊鄰文字的零寬字元。實測 498 份已出版論文的抽取文字：U+200B 共出現
  // 一萬四千多次，全部在表格空白格之間或 DOI／網址的「/」「.」之後（出版社的
  // 斷行提示），沒有一次落在兩個字母之間；人性化工具則把它塞進單字或字間。
  add(
    EvasionKind.zeroWidth,
    _zeroWidth
        .allMatches(raw)
        .where((m) => _zeroWidthTouchesText(raw, m.start, m.end))
        .map((m) => m[0]!),
  );
  add(EvasionKind.bidiControl, _bidiControl.allMatches(raw).map((m) => m[0]!));
  add(
    EvasionKind.unusualSpace,
    _unusualSpace.allMatches(raw).map((m) => m[0]!),
  );

  final latin = RegExp(r'[A-Za-z]').allMatches(raw).length;
  if (latin / raw.length > 0.30) {
    final hits = <String>[];
    final chars = raw.split('');
    final asciiLetter = RegExp(r'[A-Za-z]');
    for (var i = 0; i < chars.length; i++) {
      final ch = chars[i];
      if (!_homoglyphs.containsKey(ch)) continue;
      // PDF/OCR 的數學式經常把 ν 等希臘變數與後方英文說明黏在一起；這是
      // 抽取失真，不是把拉丁字母替換成同形字。西里爾字母仍照常檢查。
      if (extractionDerived && _isGreekHomoglyph(ch)) continue;
      // 科學論文常合法使用獨立的 α、ν、ο 等希臘變數；只有字元被塞進
      // ASCII 單字／識別字中時，才符合 humanizer 的同形字替換模式。
      final leftAscii = i > 0 && asciiLetter.hasMatch(chars[i - 1]);
      final rightAscii =
          i + 1 < chars.length && asciiLetter.hasMatch(chars[i + 1]);
      if (leftAscii || rightAscii) hits.add(ch);
    }
    add(EvasionKind.homoglyph, hits);
  }

  _scanCodePoints(raw, extractionDerived, add);

  return EvasionScan(
    findings: findings,
    characterCount: raw.length,
    regularSpaceCount: ' '.allMatches(raw).length,
    extractionDerived: extractionDerived,
  );
}

/// 以碼位逐一檢查的手法。多數字元在特定上下文中有正當用途，因此判定都看
/// 前後字元：同一個全形 Ａ 在日文標題裡正常，夾在 intelｌigence 裡就是替換。
void _scanCodePoints(
  String raw,
  bool extractionDerived,
  void Function(EvasionKind kind, Iterable<String> hits) add,
) {
  final runes = raw.runes.toList();
  final present = runes.toSet();
  final hits = <EvasionKind, List<String>>{};
  void hit(EvasionKind kind, int rune) =>
      hits.putIfAbsent(kind, () => []).add(String.fromCharCode(rune));

  int at(int i) => i >= 0 && i < runes.length ? runes[i] : -1;

  var inFlagTagRun = false;
  final combiningRun = <int>{};
  var combiningLength = 0;
  for (var i = 0; i < runes.length; i++) {
    final r = runes[i];
    final prev = at(i - 1);
    final next = at(i + 1);

    // 組合符號：越南文分解形會正常疊兩層；PDF 數學式會重複同一個上劃線
    // （U+0305）。Zalgo 產生器疊的是多種不同符號，因此要求三種以上
    if (_isCombining(r)) {
      combiningLength++;
      combiningRun.add(r);
      if (combiningLength >= 3 && combiningRun.length == 3) {
        hit(EvasionKind.combiningStack, r);
      }
    } else {
      combiningRun.clear();
      combiningLength = 0;
    }

    if (r >= 0xE0000 && r <= 0xE007F) {
      // 🏴 + Tag 序列 + U+E007F 是蘇格蘭、威爾斯等地區旗幟的標準寫法
      if (prev == 0x1F3F4) inFlagTagRun = true;
      if (!inFlagTagRun) hit(EvasionKind.tagCharacter, r);
      if (r == 0xE007F) inFlagTagRun = false;
      continue;
    }
    inFlagTagRun = false;

    if (_isVariationSelector(r)) {
      // emoji 後的 FE0F、漢字後的異體選擇符都正常；連續出現或接在英數字後，
      // 就是用選擇符夾帶資料的手法
      if (_isVariationSelector(prev) || _isAsciiAlnum(prev)) {
        hit(EvasionKind.variationSelector, r);
      }
      continue;
    }

    if (r == 0x00AD) {
      if (_isLetter(prev) && _isLetter(next)) hit(EvasionKind.softHyphen, r);
      continue;
    }

    if (_invisibleFillers.contains(r)) {
      hit(EvasionKind.invisibleFiller, r);
      continue;
    }

    // 全形與數學字母都要求被英文字母夾在中間：替換工具改的是單字內的字母；
    // 數學式的下標（𝑋i）、日文的「Ａ型」只會貼著一側
    if ((r >= 0xFF21 && r <= 0xFF3A) || (r >= 0xFF41 && r <= 0xFF5A)) {
      if (_isAsciiLetter(prev) && _isAsciiLetter(next)) {
        hit(EvasionKind.fullwidthLatin, r);
      }
      continue;
    }

    if (r >= 0x1D400 && r <= 0x1D7FF) {
      // PDF 抽取常把空格吃掉，讓數學變數黏在單字旁（in𝑐Css、of𝑈r）。
      // 替換工具改的是小寫單字裡的字母（fl𝐨w），因此要求小寫數學字母且
      // 前後都是小寫英文
      if (_isMathLowercase(r) && _isAsciiLower(prev) && _isAsciiLower(next)) {
        hit(EvasionKind.mathAlphanumeric, r);
      }
      continue;
    }

    // PDF 常因字型的 ToUnicode 對照錯誤把漢字抽成康熙部首或相容字（⾏、⼈、來），
    // 從 PDF 複製貼上也會帶進來。對照錯誤是「整份一致」的——同一個字每次都被
    // 換掉；替換工具只換一部分。因此只有同一個字的正常寫法也出現在文中時才計入。
    // PDF 抽取的文字一律不判定。
    final base = cjkLookalikeBase[r];
    if (!extractionDerived && base != null && present.contains(base)) {
      if (_isCjkIdeograph(prev) || _isCjkIdeograph(next)) {
        hit(EvasionKind.cjkRadical, r);
      }
    }
  }

  for (final kind in const [
    EvasionKind.tagCharacter,
    EvasionKind.variationSelector,
    EvasionKind.softHyphen,
    EvasionKind.invisibleFiller,
    EvasionKind.fullwidthLatin,
    EvasionKind.mathAlphanumeric,
    EvasionKind.cjkRadical,
    EvasionKind.combiningStack,
  ]) {
    final list = hits[kind];
    if (list != null) add(kind, list);
  }
}

bool _zeroWidthTouchesText(String raw, int start, int end) {
  final prev = start > 0 ? raw.codeUnitAt(start - 1) : -1;
  final next = end < raw.length ? raw.codeUnitAt(end) : -1;
  if (_isTextChar(prev)) return true;
  const urlBreaks = '/.:-_=?&#';
  final prevIsUrlBreak =
      prev >= 0 && urlBreaks.contains(String.fromCharCode(prev));
  return _isTextChar(next) && !prevIsUrlBreak;
}

bool _isTextChar(int unit) =>
    unit >= 0 &&
    (_isAsciiLetter(unit) ||
        (unit >= 0x00C0 && unit <= 0x024F) ||
        (unit >= 0x0370 && unit <= 0x04FF) ||
        (unit >= 0x3040 && unit <= 0x30FF) ||
        (unit >= 0x4E00 && unit <= 0x9FFF) ||
        (unit >= 0xAC00 && unit <= 0xD7AF));

bool _isAsciiLetter(int r) =>
    (r >= 0x41 && r <= 0x5A) || (r >= 0x61 && r <= 0x7A);

bool _isAsciiLower(int r) => r >= 0x61 && r <= 0x7A;

/// 數學字母符號區（U+1D400–1D6A3）以 52 個為一組：前 26 個大寫、後 26 個小寫
bool _isMathLowercase(int r) =>
    r >= 0x1D400 && r <= 0x1D6A3 && (r - 0x1D400) % 52 >= 26;

bool _isAsciiAlnum(int r) => _isAsciiLetter(r) || (r >= 0x30 && r <= 0x39);

final _letter = RegExp(r'\p{L}', unicode: true);
bool _isLetter(int r) => r >= 0 && _letter.hasMatch(String.fromCharCode(r));

bool _isVariationSelector(int r) =>
    (r >= 0xFE00 && r <= 0xFE0F) || (r >= 0xE0100 && r <= 0xE01EF);

bool _isCombining(int r) =>
    (r >= 0x0300 && r <= 0x036F) ||
    (r >= 0x1AB0 && r <= 0x1AFF) ||
    (r >= 0x1DC0 && r <= 0x1DFF) ||
    (r >= 0x20D0 && r <= 0x20FF) ||
    (r >= 0xFE20 && r <= 0xFE2F);

bool _isCjkIdeograph(int r) =>
    (r >= 0x4E00 && r <= 0x9FFF) ||
    (r >= 0x3400 && r <= 0x4DBF) ||
    (r >= 0x20000 && r <= 0x2EBEF);

/// 顯示為空白或完全不顯示、正常文字不會用到的填充字元
const _invisibleFillers = {
  0x034F, // 組合字形連接符
  0x115F, 0x1160, 0x3164, 0xFFA0, // 韓文填充字
  0x17B4, 0x17B5, // 高棉文不可見母音
  0x180E, // 蒙古文母音分隔符
  0x2061, 0x2062, 0x2063, 0x2064, // 不可見運算子
};

bool _isGreekHomoglyph(String ch) {
  final code = ch.runes.single;
  return (code >= 0x0370 && code <= 0x03FF) ||
      (code >= 0x1F00 && code <= 0x1FFF);
}
