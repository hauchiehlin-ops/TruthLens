/// 困惑度指標的逐語言校準表。
///
/// 為什麼是資料而不是程式碼裡的常數：困惑度的尺度隨語言與模型而變，
/// 且只能靠實測取得。把門檻放在查表結構裡，新增一個語言就等於
/// 「跑一次 training/calibrate_perplexity.py、加一列資料」，
/// 不必改判定邏輯、不必重新推導公式。
///
/// 查不到的語言一律回傳 null，呼叫端必須棄權而不是套用別的語言的門檻——
/// 拿英文門檻去量中文，正是 2026-08-18 修掉的那個偽陽性來源。
library;

/// 單一語言的困惑度門檻與其實測依據。
class PerplexityThresholds {
  /// 低於此值視為偏 AI（文本過度可預測）
  final double aiCut;

  /// 高於此值視為偏人類（文本不可預測）。介於兩者之間＝無證據。
  final double humanCut;

  /// 實測可分性（AUC）。0.5 代表毫無鑑別力。
  final double auc;

  /// 校準樣本數（真人 + AI 合計）
  final int sampleCount;

  /// 校準來源與已知限制，寫給日後要重跑校準的人看
  final String provenance;

  const PerplexityThresholds({
    required this.aiCut,
    required this.humanCut,
    required this.auc,
    required this.sampleCount,
    required this.provenance,
  });

  /// 這組門檻是否值得採用。可分性太低時，採用只會製造偽陽性——
  /// 中文就是這種情況：門檻 60 之下真人與 AI 各佔 100%，區別力 0。
  bool get isUsable => auc >= minimumUsableAuc;

  /// 低於此可分性的指標不採計。0.65 大致對應「最佳操作點下，
  /// 每命中一個 AI 就要誤傷一個真人」的量級，再低就沒有採用價值。
  static const double minimumUsableAuc = 0.65;
}

/// 目前使用的困惑度模型識別字串。換模型時整張表都必須重測——
/// 門檻綁定的是「模型 × 語言」，不是語言本身。
const String perplexityModelId = 'distilgpt2_ppl_int8';

/// 校準表：模型 → 語言 → 門檻。
///
/// 兩層結構不是為了整齊，是因為門檻綁定的是「模型 × 語言」這個組合。
/// 同一個語言換了模型，門檻完全不同——DistilGPT2 對中文的 AUC 是 0.50，
/// Qwen2.5-0.5B 是 0.965；尺度也從真人中位數 21 變成 56。
///
/// 未列出的語言不是「不支援」，是「尚未取得該語言的標註語料」。
/// 模型本身照跑，只是我們沒有資格用它的數字下結論。
const Map<String, Map<String, PerplexityThresholds>> _table = {
  'distilgpt2_ppl_int8': {
    'en': PerplexityThresholds(
      aiCut: 60,
      humanCut: 150,
      auc: 0.996,
      sampleCount: 600,
      provenance:
          'HC3 英文語料 600 筆（fp32 distilgpt2）測得 AUC 0.996；門檻 60/150 沿用自'
          ' production INT8 管線的既有值，於真人學術論文（困惑度 304 → 人類撰寫）'
          '上行為正確。門檻本身未在 INT8 尺度上重新最佳化。',
    ),
    'zh': PerplexityThresholds(
      // 保留量測值供追溯，但 AUC 未達採用標準，會被 isUsable 擋下
      aiCut: 14.0,
      humanCut: 22.8,
      auc: 0.50,
      sampleCount: 600,
      provenance:
          'DistilGPT2 未見過中文，量到的是 UTF-8 位元組的可預測性。HC3 中文語料'
          ' 600 筆實測：門檻 60 之下真人與 AI 各佔 100%，區別力 0.0 個百分點。'
          'production 管線亦然（真人 41、AI 46，順序相反）。',
    ),
  },

  // 多語替代品。門檻已用 production 會實際執行的 INT8 產物量過
  // （onnx-community/Qwen2.5-0.5B 的 model_int8.onnx，非 fp32），
  // 因此切換模型時可直接生效，不需重測。
  //
  // 尚未啟用的原因與門檻無關：Dart→JS 橋接目前只餵 input_ids 與
  // attention_mask，而 Qwen 的 web 建置另需 position_ids 與 48 個
  // KV cache 張量，需先擴充 web_js_bridge.dart 與 web/ 的 JS 側。
  'qwen05b_ppl_int8': {
    'zh': PerplexityThresholds(
      aiCut: 11.19,
      humanCut: 18.67,
      auc: 0.965,
      sampleCount: 160,
      provenance:
          'HC3 中文語料 160 筆，以 production 的 INT8 ONNX 量測。'
          '偽陽性預算 5% 下切點 11.19 命中 75.0%、實際誤傷 5.0%。'
          'humanCut 取 AI 樣本的 p95（僅 5% 的 AI 高於此值）。',
    ),
    'en': PerplexityThresholds(
      aiCut: 11.45,
      humanCut: 11.45,
      auc: 0.988,
      sampleCount: 160,
      provenance:
          'HC3 英文語料 160 筆，以 production 的 INT8 ONNX 量測。'
          '偽陽性預算 5% 下切點 11.45 命中 100%、實際誤傷 2.5%。'
          '兩類分離近乎完全（AI p95 為 8.07，低於切點），因此沒有灰帶。',
    ),
  },
};

/// 困惑度校準表的查詢入口
abstract final class PerplexityCalibration {
  /// 取得 [languageCode] 在目前使用中模型下的可用門檻。
  ///
  /// 未校準、可分性不足、或門檻是用別顆模型量的，一律回傳 null。
  /// 最後這一項尤其重要：換模型之後沿用舊門檻，就是這個專案先前
  /// 拿英文門檻量中文的同一種錯誤，只是換了個軸。
  static PerplexityThresholds? of(
    String languageCode, {
    String modelId = perplexityModelId,
  }) {
    final entry = _table[modelId]?[languageCode];
    if (entry == null || !entry.isUsable) return null;
    return entry;
  }

  /// 表中是否有這個語言的紀錄（含判定為不可用者）。
  /// 用於區分「量過但沒用」與「根本還沒量」，兩者要對使用者說不同的話。
  static bool hasRecord(
    String languageCode, {
    String modelId = perplexityModelId,
  }) => _table[modelId]?.containsKey(languageCode) ?? false;

  /// 已量測過的語言代碼，供設定頁或說明手冊呈現涵蓋範圍
  static Iterable<String> measuredLanguages({
    String modelId = perplexityModelId,
  }) => _table[modelId]?.keys ?? const [];

  /// 目前實際採用的語言代碼
  static Iterable<String> usableLanguages({
    String modelId = perplexityModelId,
  }) =>
      (_table[modelId] ?? const {}).entries
          .where((e) => e.value.isUsable)
          .map((e) => e.key);

  /// 表中已有校準資料的模型，供評估「換上這顆模型能覆蓋哪些語言」
  static Iterable<String> get calibratedModels => _table.keys;
}
