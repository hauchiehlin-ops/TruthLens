/// 文件語言辨識。
///
/// 存在的理由：每一項語言統計指標的尺度都是逐語言的。同一顆 DistilGPT2，
/// 英文真人文章的困惑度中位數是 65.6、中文是 21.2（fp32 實測）；production
/// 管線更懸殊，英文真人 304、中文 41。任何拿單一全域門檻套所有語言的做法，
/// 在數學上都不可能同時服務兩種語言——所以先得知道這份文件是什麼語言。
///
/// 粒度刻意只做到「需要分開校準的組」，不追求精確語種辨識：
/// 文字系統（Han／Kana／Hangul／Thai／Cyrillic／Arabic／Devanagari／Latin）
/// 幾乎零成本就能分出絕大多數的組，拉丁語系內部再以功能詞剖面細分。
library;

/// 辨識結果。[code] 對應 [PerplexityCalibration] 等校準表的查表鍵。
class DetectedLanguage {
  /// ISO 639-1 語言代碼；無法判定時為 [undetermined]
  final String code;

  /// 判定信心 0–1。文字系統判定接近 1，功能詞剖面判定較低。
  final double confidence;

  const DetectedLanguage(this.code, this.confidence);

  /// 無法判定。校準表查不到它，對應的指標一律棄權而非猜測。
  static const String undetermined = 'und';

  bool get isUndetermined => code == undetermined;

  @override
  String toString() => '$code(${(confidence * 100).round()}%)';
}

/// 各文字系統的字元範圍。以字元佔比而非絕對數量判定，避免長文件裡
/// 零星幾個外語字元就翻轉結果。
const _han = r'㐀-䶿一-鿿';
const _kana = r'぀-ヿ';
const _hangul = r'가-힯ᄀ-ᇿ';
const _thai = r'฀-๿';
const _cyrillic = r'Ѐ-ӿ';
const _arabic = r'؀-ۿ';
const _devanagari = r'ऀ-ॿ';
const _latin = r'A-Za-zÀ-ÿĀ-ſ';

final _hanRe = RegExp('[$_han]');
final _kanaRe = RegExp('[$_kana]');
final _hangulRe = RegExp('[$_hangul]');
final _thaiRe = RegExp('[$_thai]');
final _cyrillicRe = RegExp('[$_cyrillic]');
final _arabicRe = RegExp('[$_arabic]');
final _devanagariRe = RegExp('[$_devanagari]');
final _latinRe = RegExp('[$_latin]');
final _wordRe = RegExp('[$_latin]+');

/// 拉丁語系的功能詞剖面。功能詞在任何主題的文章裡都會高頻出現，
/// 用它們區分語言比用內容詞穩定得多，也不需要任何模型檔案。
const _latinProfiles = <String, Set<String>>{
  'en': {
    'the',
    'of',
    'and',
    'to',
    'in',
    'is',
    'that',
    'for',
    'it',
    'as',
    'with',
    'was',
    'this',
    'be',
    'are',
    'from',
    'which',
    'have',
    'not',
    'on',
  },
  'es': {
    'de',
    'la',
    'que',
    'el',
    'en',
    'los',
    'del',
    'las',
    'por',
    'con',
    'una',
    'su',
    'para',
    'es',
    'al',
    'lo',
    'como',
    'más',
    'pero',
    'sus',
  },
  'pt': {
    'de',
    'que',
    'não',
    'uma',
    'os',
    'no',
    'se',
    'na',
    'por',
    'com',
    'para',
    'as',
    'dos',
    'como',
    'mas',
    'ao',
    'das',
    'à',
    'seu',
    'ou',
  },
  'fr': {
    'de',
    'la',
    'le',
    'et',
    'les',
    'des',
    'en',
    'un',
    'du',
    'une',
    'que',
    'dans',
    'qui',
    'pour',
    'pas',
    'sur',
    'au',
    'par',
    'plus',
    'ce',
  },
  'de': {
    'der',
    'die',
    'und',
    'den',
    'von',
    'das',
    'mit',
    'des',
    'ist',
    'nicht',
    'ein',
    'auf',
    'für',
    'dem',
    'eine',
    'als',
    'auch',
    'sich',
    'im',
    'werden',
  },
  'id': {
    'yang',
    'dan',
    'di',
    'itu',
    'dengan',
    'untuk',
    'tidak',
    'ini',
    'dari',
    'dalam',
    'akan',
    'pada',
    'juga',
    'ke',
    'karena',
    'oleh',
    'saya',
    'kami',
    'sudah',
    'bisa',
  },
  'ms': {
    'yang',
    'dan',
    'di',
    'itu',
    'dengan',
    'untuk',
    'tidak',
    'ini',
    'dari',
    'dalam',
    'akan',
    'pada',
    'juga',
    'ke',
    'kerana',
    'oleh',
    'saya',
    'kami',
    'boleh',
    'adalah',
  },
};

/// 辨識 [raw] 的語言。
///
/// 先看文字系統佔比，再於拉丁語系內部用功能詞剖面細分。任何一步無法達到
/// 門檻就回傳 [DetectedLanguage.undetermined]——猜錯語言會套錯校準門檻，
/// 那正是這整套機制要杜絕的事，寧可棄權。
DetectedLanguage detectLanguage(String raw) {
  final text = raw.trim();
  if (text.length < 12) {
    return const DetectedLanguage(DetectedLanguage.undetermined, 0);
  }

  double ratio(RegExp re) => re.allMatches(text).length / text.length;

  final han = ratio(_hanRe);
  final kana = ratio(_kanaRe);
  final hangul = ratio(_hangulRe);
  final thai = ratio(_thaiRe);
  final cyrillic = ratio(_cyrillicRe);
  final arabic = ratio(_arabicRe);
  final devanagari = ratio(_devanagariRe);

  // 日文與中文都用漢字，靠假名區分：日文正常行文必然夾雜假名。
  if (kana >= 0.05) return DetectedLanguage('ja', (kana + han).clamp(0.0, 1.0));
  if (hangul >= 0.10) return DetectedLanguage('ko', hangul);
  if (han >= 0.10) return DetectedLanguage('zh', han);
  if (thai >= 0.10) return DetectedLanguage('th', thai);
  if (cyrillic >= 0.10) return DetectedLanguage('ru', cyrillic);
  if (arabic >= 0.10) return DetectedLanguage('ar', arabic);
  if (devanagari >= 0.10) return DetectedLanguage('hi', devanagari);

  if (ratio(_latinRe) < 0.25) {
    return const DetectedLanguage(DetectedLanguage.undetermined, 0);
  }

  final tokens = _wordRe
      .allMatches(text.toLowerCase())
      .map((m) => m[0]!)
      .toList();
  if (tokens.length < 20) {
    return const DetectedLanguage(DetectedLanguage.undetermined, 0);
  }

  final hits = <String, int>{};
  for (final entry in _latinProfiles.entries) {
    hits[entry.key] = tokens.where(entry.value.contains).length;
  }
  final ranked = hits.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final best = ranked.first;
  final runnerUp = ranked.length > 1 ? ranked[1].value : 0;
  final share = best.value / tokens.length;

  // 功能詞佔比太低（可能是程式碼、表格、書目清單），或第一二名咬得太緊
  // （印尼／馬來這類近親語言），都判為無法判定。
  if (share < 0.06) {
    return const DetectedLanguage(DetectedLanguage.undetermined, 0);
  }
  if (best.value <= runnerUp * 1.25) {
    return const DetectedLanguage(DetectedLanguage.undetermined, 0);
  }
  return DetectedLanguage(best.key, share.clamp(0.0, 1.0));
}
