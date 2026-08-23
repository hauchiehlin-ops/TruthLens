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

  /// PDF 文字層與 OCR 可能由排版器帶入控制字元；這些發現仍會列出，但需要
  /// 更高密度才足以被解讀為刻意規避。
  final bool extractionDerived;

  const EvasionScan({
    this.findings = const [],
    this.characterCount = 0,
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
          if (f.count >= (extractionDerived ? 40 : 20)) return true;
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

  add(EvasionKind.zeroWidth, _zeroWidth.allMatches(raw).map((m) => m[0]!));
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

  return EvasionScan(
    findings: findings,
    characterCount: raw.length,
    extractionDerived: extractionDerived,
  );
}

bool _isGreekHomoglyph(String ch) {
  final code = ch.runes.single;
  return (code >= 0x0370 && code <= 0x03FF) ||
      (code >= 0x1F00 && code <= 0x1FFF);
}
