import '../../core/models/detection_result.dart';
import 'report_document.dart';

/// 確定性報告生成器（模組 2 的「確定性回退」）。
/// 依檢測結果以規則選擇版面、產生中文自然語言解讀。
/// 完全離線、無需 LLM，任何裝置都能產出報告。
class ReportComposer {
  ReportDocument compose(DetectionResult r) {
    final templateId = _selectTemplate(r);
    return ReportDocument(
      templateId: templateId,
      headline: _headline(r),
      components: _components(r, templateId),
      source: ReportSource.template,
    );
  }

  String _selectTemplate(DetectionResult r) {
    final paraphrase = _paraphraseDetected(r);
    if (paraphrase) return 'paraphrase_alert';
    return switch (r.verdict) {
      Verdict.ai || Verdict.likelyAi => 'ai_alert',
      Verdict.mixed => 'mixed_detailed',
      Verdict.likelyHuman || Verdict.human => 'human_clean',
    };
  }

  bool _paraphraseDetected(DetectionResult r) {
    final adv = r.engineScores
        .where((e) => e.engineId == 'adversarial' && e.available)
        .toList();
    return adv.isNotEmpty && adv.first.aiProbability >= 0.6;
  }

  String _headline(DetectionResult r) {
    final pct = (r.aiProbability * 100).round();
    return switch (r.verdict) {
      Verdict.ai => '這段文字極可能由 AI 生成（AI 機率 $pct%）',
      Verdict.likelyAi => '這段文字傾向 AI 生成，建議進一步檢視（AI 機率 $pct%）',
      Verdict.mixed => '這段文字呈現人類與 AI 混合的特徵（AI 機率 $pct%）',
      Verdict.likelyHuman => '這段文字傾向人類撰寫（AI 機率 $pct%）',
      Verdict.human => '這段文字極可能為人類撰寫（AI 機率 $pct%）',
    };
  }

  List<ReportComponent> _components(DetectionResult r, String templateId) {
    final list = <ReportComponent>[
      const ReportComponent(type: ReportComponentType.overallGauge),
      ReportComponent(
        type: ReportComponentType.thresholdBanner,
        body: r.flaggedAsAi
            ? '整體 AI 機率越過你設定的 ${(r.threshold * 100).round()}% 閾值，被標記為 AI。'
            : '整體 AI 機率未達 ${(r.threshold * 100).round()}% 標記閾值。',
      ),
      ReportComponent(
        type: ReportComponentType.narrative,
        title: '分析解讀',
        body: _narrative(r),
      ),
    ];

    // 改寫警告優先呈現
    if (_paraphraseDetected(r)) {
      list.add(const ReportComponent(
        type: ReportComponentType.paraphraseWarning,
        title: '偵測到改寫痕跡',
        body: '本文可能經過改寫工具（如 QuillBot、Undetectable.ai）處理以規避偵測。'
            '此類文本即使逐句讀來自然，其整體統計特徵仍與原生人類寫作不同，請特別留意。',
      ));
    }

    if (r.dominantPatterns.isNotEmpty) {
      list.add(ReportComponent(
        type: ReportComponentType.patternList,
        title: '主要 AI 寫作特徵',
        body: r.dominantPatterns.join('\n'),
      ));
    }

    // 混合內容最適合逐句熱力圖（plan 範例）
    if (templateId == 'mixed_detailed' || r.sentences.length >= 3) {
      list.add(const ReportComponent(type: ReportComponentType.sentenceHeatmap));
    }

    list.add(const ReportComponent(type: ReportComponentType.engineBreakdown));

    if (r.eslAdjusted) {
      list.add(const ReportComponent(
        type: ReportComponentType.eslNotice,
        title: 'ESL 非母語者偏差修正',
        body: '偵測到本文可能出自非母語寫作者。非母語者常見的低困惑度與規律句式'
            '並非 AI 特徵，因此系統已降低統計模型的權重，以避免誤判。',
      ));
    }

    return list;
  }

  /// 規則式自然語言解讀：綜合分佈、主要特徵與可解釋引擎的理由
  String _narrative(DetectionResult r) {
    final parts = <String>[];
    final total = r.sentences.length;

    if (total > 0) {
      parts.add('全文共 $total 句，其中 ${r.aiSentenceCount} 句呈現較強的 AI 特徵、'
          '${r.humanSentenceCount} 句偏向人類撰寫。');
    }

    switch (r.verdict) {
      case Verdict.ai:
      case Verdict.likelyAi:
        parts.add('多數句子在句長節奏、用詞與過渡詞使用上高度規律，'
            '這是 AI 生成文本的常見指紋。');
      case Verdict.mixed:
        parts.add('文中同時存在規律化與自然起伏的段落，'
            '顯示可能為人類初稿再經 AI 潤飾，或人機協作而成。');
      case Verdict.likelyHuman:
      case Verdict.human:
        parts.add('句長與用詞展現自然的變化與個人風格，未見明顯的 AI 規律化痕跡。');
    }

    // 取可解釋引擎（統計/風格）最具代表性的理由各一
    for (final id in ['stylometry', 'statistical']) {
      final e = r.engineScores
          .where((s) => s.engineId == id && s.available && s.reasons.isNotEmpty)
          .toList();
      if (e.isNotEmpty) parts.add('${e.first.reasons.first}。');
    }

    return parts.join('');
  }
}
