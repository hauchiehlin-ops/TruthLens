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

  const EvasionScan({this.findings = const [], this.characterCount = 0});

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
          // 混用外觀相同的異體字母極難自然發生
          if (f.count >= 3) return true;
        case EvasionKind.bidiControl:
          return true;
        case EvasionKind.zeroWidth:
          if (f.count >= 5) return true;
        case EvasionKind.unusualSpace:
          if (f.count >= 20) return true;
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
EvasionScan scanForEvasion(String raw) {
  if (raw.isEmpty) return EvasionScan.clean;

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
  add(EvasionKind.unusualSpace, _unusualSpace.allMatches(raw).map((m) => m[0]!));

  final latin = RegExp(r'[A-Za-z]').allMatches(raw).length;
  if (latin / raw.length > 0.30) {
    final hits = <String>[];
    for (final ch in raw.split('')) {
      if (_homoglyphs.containsKey(ch)) hits.add(ch);
    }
    add(EvasionKind.homoglyph, hits);
  }

  return EvasionScan(findings: findings, characterCount: raw.length);
}
