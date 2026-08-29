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
  ///
  /// **null 代表「高困惑度不構成人類撰寫的證據」**，此時只有低於 [aiCut]
  /// 的那一側會發言。這不是保守起見，是實測結論：2026 世代 LLM 的中文輸出
  /// 困惑度中位數 72.3，遠高於 HC3 校準出的 18.67，若照舊給 −0.25，
  /// 等於主動把 AI 文章往人類推——這與「沉默不等於人類證據」是同一個錯誤。
  final double? humanCut;

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
  /// DistilGPT2 對中文就是這種情況：門檻 60 之下真人與 AI 各佔 100%，區別力 0。
  ///
  /// 這個判準只擋「會製造偽陽性」的情況。低召回率但高精確度的指標仍然有用：
  /// 它很少誤指，發言時就有意義。真正危險的是**反向**證據，
  /// 那由 [humanCut] 是否為 null 控制，與本判準是兩回事。
  bool get isUsable => auc >= minimumUsableAuc;

  /// 高困惑度是否可作為人類撰寫的證據
  bool get hasHumanSideEvidence => humanCut != null;

  /// 低於此可分性的指標不採計。0.65 大致對應「最佳操作點下，
  /// 每命中一個 AI 就要誤傷一個真人」的量級，再低就沒有採用價值。
  static const double minimumUsableAuc = 0.65;
}

/// 沒有指定模型時採用的預設鍵，對應 catalog 中最早的困惑度模型。
///
/// 表的鍵**刻意直接使用 catalog 的 variant id**：兩邊各取一套命名，
/// 遲早會出現「換了模型卻仍套用舊門檻」而沒人發現的情況。
const String defaultPerplexityModelId = 'distilgpt2-ppl-int8';

/// 校準表：模型 → 語言 → 門檻。
///
/// 兩層結構不是為了整齊，是因為門檻綁定的是「模型 × 語言」這個組合。
/// 同一個語言換了模型，門檻完全不同——DistilGPT2 對中文的 AUC 是 0.50，
/// Qwen2.5-0.5B 是 0.965；尺度也從真人中位數 21 變成 56。
///
/// 未列出的語言不是「不支援」，是「尚未取得該語言的標註語料」。
/// 模型本身照跑，只是我們沒有資格用它的數字下結論。
const Map<String, Map<String, PerplexityThresholds>> _table = {
  'distilgpt2-ppl-int8': {
    'en': PerplexityThresholds(
      aiCut: 60,
      // 人類側停用，理由同 qwen05b-ppl-int8：HC3 的 AI 樣本是 2022 年的罐頭
      // 回覆，據此得出的「高困惑度＝人類」在現代 LLM 輸出上不成立。
      humanCut: null,
      auc: 0.996,
      sampleCount: 600,
      provenance:
          'HC3 英文語料 600 筆（fp32 distilgpt2）測得 AUC 0.996；門檻 60 沿用自'
          ' production INT8 管線的既有值。原本的 humanCut 150 已停用——'
          '它曾讓一篇真人學術論文得到正確的 15%，但同一條規則也會把困惑度同樣'
          '偏高的現代 AI 文本推向人類。低召回率可以接受，反向誤判不行。',
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
  // 註：Web 側的支援已完成——ort_bridge.js 會依模型宣告自動補上 position_ids
  // 與 24 層 × key/value 共 48 個空 KV cache 張量，靜態維度由 catalog 的
  // runtime.kv_cache 帶入。實測 INT8 產物可正常推論並算出困惑度。
  'qwen05b-ppl-int8': {
    'zh': PerplexityThresholds(
      aiCut: 11.19,
      // 刻意為 null：高困惑度不作為人類撰寫的證據
      humanCut: null,
      auc: 0.965,
      sampleCount: 160,
      provenance:
          'HC3 中文語料 160 筆，以 production 的 INT8 ONNX 量測：'
          '偽陽性預算 5% 下切點 11.19 命中 75.0%、實際誤傷 5.0%、AUC 0.965。'
          '但 HC3 的 AI 樣本是 2022 年問答式的罐頭回覆。'
          '以 18 篇 2026 世代 LLM 輸出（題材對齊、語域分散）重測：'
          '困惑度中位數 72.3、AUC 僅 0.603、依此門檻無一被判為偏 AI。'
          '因此低於 aiCut 仍是有效的 AI 證據（誤傷真人僅 2%），'
          '但高於任何門檻都不再構成人類證據——現代 AI 文本正落在那個區間。'
          '重測：training/binoculars/evaluate_modern_ai.py',
    ),
    'en': PerplexityThresholds(
      aiCut: 11.45,
      humanCut: null,
      auc: 0.988,
      sampleCount: 160,
      provenance:
          'HC3 英文語料 160 筆，以 production 的 INT8 ONNX 量測：'
          '偽陽性預算 5% 下切點 11.45 命中 100%、實際誤傷 2.5%。'
          '人類側同樣停用：中文以現代語料重測後 AUC 由 0.965 掉到 0.603，'
          '英文尚未以現代語料重測，但成因（HC3 的 AI 樣本是 2022 年罐頭回覆）'
          '與語言無關，沒有理由假設英文不受影響。在取得英文現代語料量測前，'
          '不讓高困惑度充當人類證據。',
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
    String modelId = defaultPerplexityModelId,
  }) {
    final entry = _table[modelId]?[languageCode];
    if (entry == null || !entry.isUsable) return null;
    return entry;
  }

  /// [candidateModelIds] 之中，第一個對 [languageCode] 有**可用**門檻的模型。
  ///
  /// 存在的理由：困惑度的可分性綁定「模型 × 語言」，差距可以很極端——
  /// DistilGPT2 對中文的 AUC 是 0.50（等於亂猜），Qwen2.5-0.5B 是 0.965。
  /// 若沿用使用者手動設定的「使用中」變體，一份中文文件配上 DistilGPT2 就會
  /// 讓整個統計角色空轉，而介面上看不出原因。候選依傳入順序（catalog 的品質
  /// 排序）評估，全部都查不到可用門檻時回傳 null，由呼叫端誠實棄權。
  static String? bestModelFor(
    String languageCode,
    Iterable<String> candidateModelIds,
  ) {
    for (final id in candidateModelIds) {
      if (of(languageCode, modelId: id) != null) return id;
    }
    return null;
  }

  /// 表中是否有這個語言的紀錄（含判定為不可用者）。
  /// 用於區分「量過但沒用」與「根本還沒量」，兩者要對使用者說不同的話。
  static bool hasRecord(
    String languageCode, {
    String modelId = defaultPerplexityModelId,
  }) => _table[modelId]?.containsKey(languageCode) ?? false;

  /// 已量測過的語言代碼，供設定頁或說明手冊呈現涵蓋範圍
  static Iterable<String> measuredLanguages({
    String modelId = defaultPerplexityModelId,
  }) => _table[modelId]?.keys ?? const [];

  /// 目前實際採用的語言代碼
  static Iterable<String> usableLanguages({
    String modelId = defaultPerplexityModelId,
  }) => (_table[modelId] ?? const {}).entries
      .where((e) => e.value.isUsable)
      .map((e) => e.key);

  /// 表中已有校準資料的模型，供評估「換上這顆模型能覆蓋哪些語言」
  static Iterable<String> get calibratedModels => _table.keys;
}
