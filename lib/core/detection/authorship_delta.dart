/// 作者身分驗證：Burrows' Delta。
///
/// **換一個問題。** 「這是不是 AI 寫的」會隨模型進步而愈來愈難答——今天已經
/// 量到現代 LLM 的中文輸出困惑度落在真人分布正中央。但「**這像不像這位作者
/// 平常的寫法**」錨定在人身上，不隨模型世代失效。
///
/// 而且這才是使用者真正的問題。老師不在乎全世界通用的 AI 判準，在乎的是
/// 「這份跟他上次交的差很多」。
///
/// 做法是 Burrows' Delta（1990 年代提出，作者歸屬領域的標準基線）：取最高頻的
/// 功能詞，把每個詞的頻率換算成相對於參考語料的 z 分數，再取各詞 z 分數差的
/// 平均絕對值。用功能詞而非內容詞是關鍵——內容詞反映主題，功能詞反映習慣。
///
/// **必須誠實面對的限制**
/// - Delta 值沒有絕對意義，只能在同一組參考語料內比較。因此本模組回報的是
///   待測文件在作者自身樣本中的**百分位**，不是「有多像」的絕對分數。
/// - 樣本太少時分母不穩定，此時一律不下結論。
/// - 它答的是「與這位作者的既有樣本相不相似」。不相似的原因可能是 AI 代筆，
///   也可能是換了文體、換了題材、或那批樣本本來就不是同一人寫的。
///   **它提供的是需要解釋的落差，不是結論。**
library;

import 'dart:math' as math;

/// 一份文件的詞頻剖面。
///
/// 只保存功能詞的相對頻率，不保存原文——這是不可還原的統計摘要，
/// 讓作者驗證能在不留存文件內容的前提下運作。
class StyleProfile {
  /// 詞 → 相對頻率（該詞出現次數 ÷ 總詞數）
  final Map<String, double> frequencies;

  /// 計算基礎的總詞數，用來判斷樣本是否夠長
  final int tokenCount;

  const StyleProfile({required this.frequencies, required this.tokenCount});

  /// 低於這個詞數的樣本頻率估計太不穩定，不納入比較
  static const int minimumTokens = 200;

  bool get isUsable => tokenCount >= minimumTokens;

  Map<String, dynamic> toJson() => {
    'tokens': tokenCount,
    'freq': frequencies.map((k, v) => MapEntry(k, v)),
  };

  static StyleProfile? fromJson(Map<String, dynamic> json) {
    final tokens = (json['tokens'] as num?)?.toInt();
    final raw = json['freq'];
    if (tokens == null || raw is! Map) return null;
    return StyleProfile(
      tokenCount: tokens,
      frequencies: {
        for (final e in raw.entries)
          if (e.value is num) e.key.toString(): (e.value as num).toDouble(),
      },
    );
  }
}

/// 比對結果
class AuthorshipComparison {
  /// 待測文件對參考語料的 Delta 值
  final double delta;

  /// 參考語料內部兩兩比對的 Delta 分布中，本文件所在的百分位（0–100）。
  /// **這才是可解讀的數字**——Delta 的絕對值只在同一組語料內有意義。
  final int percentile;

  /// 參考樣本數
  final int referenceCount;

  const AuthorshipComparison({
    required this.delta,
    required this.percentile,
    required this.referenceCount,
  });

  /// 要讓百分位有意義所需的最少參考樣本數。
  /// 少於這個數量時，「在分布中的位置」本身沒有分布可言。
  static const int minimumReferenceSamples = 5;

  /// 落差是否大到需要解釋。
  /// 取 90 而非更低：作者自己的文章之間本來就有變異，
  /// 只有明顯超出自身變異範圍才值得提出。
  bool get isOutlier => percentile >= 90;
}

/// 功能詞剖面所使用的詞。
///
/// 只取功能詞是 Burrows' Delta 的核心：內容詞反映**主題**，功能詞反映**習慣**。
/// 一個人換題材時內容詞全變，功能詞的使用比例卻相當穩定。
const _functionWords = <String>{
  // 英文
  'the', 'of', 'and', 'to', 'in', 'a', 'is', 'that', 'for', 'it',
  'as', 'with', 'was', 'this', 'be', 'are', 'from', 'which', 'not', 'on',
  'by', 'at', 'or', 'an', 'have', 'has', 'but', 'they', 'we', 'can',
  'their', 'these', 'there', 'been', 'more', 'when', 'if', 'would',
  // 中文功能詞與虛詞
  '的', '了', '在', '是', '和', '也', '就', '不', '有', '而', '其',
  '與', '為', '以', '對', '於', '會', '要', '被', '將', '從',
  '但', '或', '這', '那', '所', '因', '此', '並', '則', '之',
};

/// 由文字建立詞頻剖面。[tokens] 應由 production 的斷詞程式碼提供，
/// 確保與其他統計使用同一套規則。
StyleProfile buildStyleProfile(List<String> tokens) {
  if (tokens.isEmpty) {
    return const StyleProfile(frequencies: {}, tokenCount: 0);
  }
  final counts = <String, int>{};
  for (final token in tokens) {
    final t = token.toLowerCase();
    if (_functionWords.contains(t)) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
  }
  return StyleProfile(
    tokenCount: tokens.length,
    frequencies: {
      for (final word in _functionWords)
        word: (counts[word] ?? 0) / tokens.length,
    },
  );
}

/// Burrows' Delta：各功能詞 z 分數差的平均絕對值。
///
/// z 分數以 [reference] 這組樣本的平均與標準差計算——這正是 Delta 必須
/// 在同一組參考語料內解讀的原因。
double burrowsDelta(StyleProfile candidate, List<StyleProfile> reference) {
  if (reference.isEmpty) return double.nan;

  var sum = 0.0;
  var counted = 0;
  for (final word in _functionWords) {
    final values = reference.map((p) => p.frequencies[word] ?? 0.0).toList();
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
        values.length;
    final sd = math.sqrt(variance);
    // 標準差為 0 代表這個詞在參考語料裡毫無變異，無從判斷偏離程度
    if (sd == 0) continue;
    final z = ((candidate.frequencies[word] ?? 0.0) - mean) / sd;
    sum += z.abs();
    counted++;
  }
  return counted == 0 ? double.nan : sum / counted;
}

/// 比對 [candidate] 與作者既有樣本 [reference]。
///
/// 回傳 null 表示樣本不足以下任何結論——這是刻意的：
/// 少於門檻時給出一個看似精確的百分位，比不給更糟。
AuthorshipComparison? compareAuthorship(
  StyleProfile candidate,
  List<StyleProfile> reference,
) {
  final usable = reference.where((p) => p.isUsable).toList();
  if (!candidate.isUsable) return null;
  if (usable.length < AuthorshipComparison.minimumReferenceSamples) return null;

  final delta = burrowsDelta(candidate, usable);
  if (delta.isNaN) return null;

  // 參考語料的自身變異：把每一份樣本對其餘樣本做同樣的計算，
  // 得到「這位作者的文章之間通常差多少」的分布
  final baseline = <double>[];
  for (var i = 0; i < usable.length; i++) {
    final others = [
      for (var j = 0; j < usable.length; j++)
        if (j != i) usable[j],
    ];
    final d = burrowsDelta(usable[i], others);
    if (!d.isNaN) baseline.add(d);
  }
  if (baseline.isEmpty) return null;

  final below = baseline.where((d) => d < delta).length;
  return AuthorshipComparison(
    delta: delta,
    percentile: (below / baseline.length * 100).round(),
    referenceCount: usable.length,
  );
}
