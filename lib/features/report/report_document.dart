/// 動態報告文件模型（對應 implementation_plan.md 模組 2）。
/// 本地端 LLM 或確定性回退器都產出這個結構，報告頁依此渲染。
library;

/// 報告元件類型（版面決策的最小單位）
enum ReportComponentType {
  overallGauge, // 整體儀表盤
  thresholdBanner, // 信心閾值判定橫幅
  narrative, // 自然語言解讀段落
  engineBreakdown, // 引擎明細
  patternList, // 命中的 AI 寫作模式
  sentenceHeatmap, // 逐句熱力高亮
  paraphraseWarning, // 改寫偵測警告
  eslNotice, // ESL 偏差修正說明
}

/// 單一報告區塊
class ReportComponent {
  final ReportComponentType type;
  final String? title;
  final String? body; // 自然語言內容（narrative / warning / notice 用）

  const ReportComponent({required this.type, this.title, this.body});
}

/// 報告生成來源，讓 UI 標示「AI 智慧生成」或「模板生成」
enum ReportSource { llm, template }

/// 完整報告文件
class ReportDocument {
  final String templateId; // e.g. 'ai_alert' / 'mixed_detailed' / 'human_clean'
  final String headline; // 一句話總結
  final List<ReportComponent> components; // 依顯示順序排列
  final ReportSource source;

  const ReportDocument({
    required this.templateId,
    required this.headline,
    required this.components,
    required this.source,
  });
}
