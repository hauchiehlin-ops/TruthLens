/// 詞彙多樣性指標的逐語言校準。
///
/// 為什麼不用原始 TTR：它**強烈受文件長度影響**。同一篇英文論文，
/// 取前 15% 時 TTR 為 0.584、全文時只有 0.405——比值下降與內容無關，
/// 純粹是長文件重複用詞的機會較多。拿固定門檻套用，判定會隨長度漂移。
///
/// 改用 MATTR（固定窗口內的 TTR 平均）後，同一篇論文在四種長度下為
/// 0.683／0.710／0.697／0.686，實質不變。可分性也略升
/// （中文 0.673→0.704、英文 0.839→0.837 持平）。
///
/// 門檻仍需逐語言：中文逐字計詞，英文以空白斷詞，兩者的基準值不同。
/// 原本 `ttr < 0.40` 這條規則對中文真人的誤觸率高達 42.5%，對英文則是 0%
/// ——同一個數字在兩種語言裡意義完全不同。
library;

/// 單一語言的 MATTR 門檻與其實測依據
class LexicalThresholds {
  /// 低於此值視為偏 AI（用詞重複、多樣性不足）
  final double aiCut;

  /// 實測可分性（AUC）
  final double auc;

  /// 校準樣本數（真人 + AI 合計）
  final int sampleCount;

  final String provenance;

  const LexicalThresholds({
    required this.aiCut,
    required this.auc,
    required this.sampleCount,
    required this.provenance,
  });

  /// 低於此可分性不採用
  static const double minimumUsableAuc = 0.65;

  bool get isUsable => auc >= minimumUsableAuc;
}

/// 逐語言的 MATTR 校準表。
///
/// **刻意只有 AI 側，沒有人類側。** 高詞彙多樣性不作為人類撰寫的證據：
/// 實測 2026 世代 LLM 的中文輸出 MATTR 為 0.783–0.802，遠高於真人中位數
/// 0.669——若把高多樣性當成人類證據，等於主動把現代 AI 文本推向人類。
/// 這與困惑度的人類側停用是同一個理由。
const Map<String, LexicalThresholds> _table = {
  'zh': LexicalThresholds(
    aiCut: 0.607,
    auc: 0.704,
    sampleCount: 240,
    provenance:
        'HC3 中文語料 240 筆（≥300 字元），以 production 的斷詞程式碼量測：'
        '真人 MATTR 中位 0.669、AI 0.642、AUC 0.704。'
        '切點取偽陽性 10% 預算下的 0.607。'
        '現代 LLM 中文輸出 MATTR 0.783–0.802，此切點抓不到（0/3），'
        '但誤傷率低，作為單向證據仍有價值。',
  ),
  'en': LexicalThresholds(
    aiCut: 0.632,
    auc: 0.837,
    sampleCount: 240,
    provenance:
        'HC3 英文語料 240 筆（≥300 字元），以 production 的斷詞程式碼量測：'
        '真人 MATTR 中位 0.708、AI 0.625、AUC 0.837。'
        '切點取偽陽性 10% 預算下的 0.632。'
        '尚未以現代英文語料重測。',
  ),
};

/// 詞彙多樣性校準表的查詢入口
abstract final class LexicalCalibration {
  /// 取得 [languageCode] 的可用門檻；未校準或可分性不足時回傳 null。
  /// 查不到就不採計此指標——套用別的語言的門檻正是本模組要杜絕的錯誤。
  static LexicalThresholds? of(String languageCode) {
    final entry = _table[languageCode];
    if (entry == null || !entry.isUsable) return null;
    return entry;
  }

  static bool hasRecord(String languageCode) =>
      _table.containsKey(languageCode);

  static Iterable<String> get calibratedLanguages => _table.keys;
}
