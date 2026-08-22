import '../../core/models/detection_result.dart';
import '../../core/services/claim_audit.dart';
import '../../core/services/integrated_assessment.dart';
import '../../l10n/generated/app_localizations.dart';
import 'report_document.dart';

/// 確定性報告生成器（模組 2 的「確定性回退」）。
/// 依檢測結果以規則選擇版面、產生依 [l10n] 語系呈現的自然語言解讀。
/// 完全離線、無需 LLM，任何裝置都能產出報告。
class ReportComposer {
  ReportDocument compose(DetectionResult r, AppLocalizations l10n) {
    final assessment = IntegratedAssessment.assess(
      r,
      claims: ClaimAudit.analyze(r.inputText),
    );
    final templateId = _selectTemplate(r, assessment);
    return ReportDocument(
      templateId: templateId,
      headline: _headline(assessment, l10n),
      components: _components(r, assessment, templateId, l10n),
      source: ReportSource.template,
    );
  }

  String _selectTemplate(DetectionResult r, IntegratedAssessment assessment) {
    final paraphrase = _paraphraseDetected(r);
    if (paraphrase) return 'paraphrase_alert';
    return switch (assessment.direction) {
      IntegratedDirection.likelyAi => 'ai_alert',
      IntegratedDirection.likelyHuman => 'human_clean',
    };
  }

  bool _paraphraseDetected(DetectionResult r) {
    final adv = r.engineScores
        .where((e) => e.engineId == 'adversarial' && e.available)
        .toList();
    return adv.isNotEmpty && adv.first.aiProbability >= 0.6;
  }

  String _headline(IntegratedAssessment assessment, AppLocalizations l10n) {
    final pct = (assessment.aiLikelihood * 100).round();
    return switch (assessment.direction) {
      IntegratedDirection.likelyAi => l10n.composerHeadlineLikelyAi(pct),
      IntegratedDirection.likelyHuman => l10n.composerHeadlineLikelyHuman(pct),
    };
  }

  List<ReportComponent> _components(
    DetectionResult r,
    IntegratedAssessment assessment,
    String templateId,
    AppLocalizations l10n,
  ) {
    final list = <ReportComponent>[
      const ReportComponent(type: ReportComponentType.overallGauge),
      ReportComponent(
        type: ReportComponentType.thresholdBanner,
        body: r.flaggedAsAi
            ? l10n.composerTextScoreThresholdReached(
                (r.aiProbability * 100).round(),
                (DetectionResult.aiFlagThreshold * 100).round(),
              )
            : l10n.composerTextScoreThresholdNotReached(
                (r.aiProbability * 100).round(),
                (DetectionResult.aiFlagThreshold * 100).round(),
              ),
      ),
      ReportComponent(
        type: ReportComponentType.narrative,
        title: l10n.composerNarrativeTitle,
        body: _narrative(r, assessment, l10n),
      ),
    ];

    // 改寫警告優先呈現
    if (_paraphraseDetected(r)) {
      list.add(
        ReportComponent(
          type: ReportComponentType.paraphraseWarning,
          title: l10n.composerParaphraseTitle,
          body: l10n.composerParaphraseBody,
        ),
      );
    }

    if (r.dominantPatterns.isNotEmpty) {
      list.add(
        ReportComponent(
          type: ReportComponentType.patternList,
          title: l10n.composerPatternListTitle,
          body: r.dominantPatterns.join('\n'),
        ),
      );
    }

    // 混合內容最適合逐句熱力圖（plan 範例）
    if (templateId == 'mixed_detailed' || r.analyzableSentenceCount >= 3) {
      list.add(
        const ReportComponent(type: ReportComponentType.sentenceHeatmap),
      );
    }

    list.add(const ReportComponent(type: ReportComponentType.engineBreakdown));

    if (r.eslAdjusted) {
      list.add(
        ReportComponent(
          type: ReportComponentType.eslNotice,
          title: l10n.composerEslTitle,
          body: l10n.composerEslBody,
        ),
      );
    }

    return list;
  }

  /// 規則式自然語言解讀：綜合分佈、主要特徵與可解釋引擎的理由
  String _narrative(
    DetectionResult r,
    IntegratedAssessment assessment,
    AppLocalizations l10n,
  ) {
    final parts = <String>[];
    final total = r.analyzableSentenceCount;

    if (total > 0) {
      parts.add(
        l10n.composerNarrativeIntro(
          total,
          r.aiSentenceCount,
          r.humanSentenceCount,
        ),
      );
    }

    switch (assessment.direction) {
      case IntegratedDirection.likelyAi:
        parts.add(l10n.composerNarrativeAiPattern);
      case IntegratedDirection.likelyHuman:
        parts.add(l10n.composerNarrativeHumanPattern);
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
