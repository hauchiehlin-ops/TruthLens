/// 分析遙測面板的白話總結：把四個引擎的結果講成人話。
library;

import '../../core/models/detection_result.dart';
import '../../core/services/claim_audit.dart';
import '../../core/services/integrated_assessment.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/professional_report_header.dart'
    show EngineGroup, describeAbstention;

/// 以白話文總結各引擎的分析結果：先講結論，再講引擎之間合不合、
/// 分數主要被誰拉動、逐句掃出什麼，最後給一句「所以該怎麼辦」。
/// 每一句都由本次實際數據組出，不是固定罐頭句；結果為 null 或無可用引擎時回傳空清單。
List<String> buildTelemetrySummary(
  DetectionResult? result,
  AppLocalizations l10n,
) {
  if (result == null) return const [];

  final groups = EngineGroup.fromScores(
    result.engineScores,
    l10n,
    eslAdjusted: result.eslAdjusted,
    contributionPointsByEngineId: result.roundedEngineContributionPoints,
  );
  final available = groups.where((g) => g.available).toList();
  if (available.isEmpty) return const [];
  // 真正有話說的引擎。沉默的引擎不列入「引擎之間合不合」的比較——
  // 它們沒有主張，拿它們的中性點去和正向訊號相減只會製造假分歧。
  final speaking = available.where((g) => g.hasEvidence).toList();
  final assessment = IntegratedAssessment.assess(
    result,
    claims: ClaimAudit.analyze(result.inputText),
  );
  final direction = switch (assessment.direction) {
    IntegratedDirection.likelyAi => l10n.integratedLikelyAi,
    IntegratedDirection.likelyMixed => l10n.integratedLikelyMixed,
    IntegratedDirection.likelyHuman => l10n.integratedLikelyHuman,
  };
  final confidence = switch (assessment.confidence) {
    IntegratedConfidence.low => l10n.integratedConfidenceLow,
    IntegratedConfidence.moderate => l10n.integratedConfidenceModerate,
    IntegratedConfidence.high => l10n.integratedConfidenceHigh,
  };

  final lines = <String>[
    l10n.telemetryIntegratedVerdict(
      direction,
      (assessment.aiLikelihood * 100).round(),
      confidence,
    ),
    if (result.hasEvidenceLimitations)
      l10n.integratedQualifiedWarning(describeAbstention(result, l10n)),
  ];

  // 引擎之間看法合不合：分數全距 30 個百分點以內視為一致
  final compared = speaking.isNotEmpty ? speaking : available;
  final highest = compared.reduce(
    (a, b) => a.probability >= b.probability ? a : b,
  );
  final lowest = compared.reduce(
    (a, b) => a.probability <= b.probability ? a : b,
  );
  final highPercent = (highest.probability * 100).round();
  final lowPercent = (lowest.probability * 100).round();
  final enginesDisagree = compared.length >= 2 && highPercent - lowPercent > 30;
  if (speaking.length == 1) {
    // 單一證人：要講清楚結論的支撐面很窄，但不能因此改口說「沒有證據」
    lines.add(l10n.telemetrySummarySingleSource(speaking.single.label));
  } else if (compared.length >= 2) {
    lines.add(
      enginesDisagree
          ? l10n.telemetrySummaryDisagreement(
              highest.label,
              highPercent,
              lowest.label,
              lowPercent,
            )
          : l10n.telemetrySummaryAgreement(highPercent, lowPercent),
    );
  }

  // 分數主要被誰拉動（全都 0 分時提了沒意義）
  final driver = available.reduce(
    (a, b) => a.contributionPoints >= b.contributionPoints ? a : b,
  );
  if (driver.contributionPoints > 0) {
    lines.add(
      l10n.telemetrySummaryDriver(driver.label, driver.contributionPoints),
    );
  }

  // 逐句掃描結果
  final analyzable = result.analyzableSentenceCount;
  if (analyzable > 0) {
    final flagged = result.aiSentenceCount;
    lines.add(
      flagged == 0
          ? l10n.telemetrySummarySentencesNone(analyzable)
          : l10n.telemetrySummarySentencesSome(flagged, analyzable),
    );
  }

  // 所以該怎麼辦。引擎彼此不合時不給「沒什麼好查的」這種話，
  // 否則會和上面那句「別只看總分」自相矛盾，一律改用需要人工判讀的說法。
  lines.add(switch (assessment.direction) {
    IntegratedDirection.likelyHuman when !enginesDisagree =>
      l10n.telemetrySummaryAdviceHuman,
    IntegratedDirection.likelyHuman => l10n.telemetrySummaryAdviceMixed,
    IntegratedDirection.likelyMixed => l10n.telemetrySummaryAdviceMixed,
    IntegratedDirection.likelyAi => l10n.telemetrySummaryAdviceAi,
  });

  // 可用但本次沒找到東西的引擎：說明它們為何不影響分數，
  // 免得使用者看到「0%」以為它們投了「人類」一票。
  final silent = available.length - speaking.length;
  if (speaking.isNotEmpty && silent > 0) {
    lines.add(l10n.telemetrySummarySilentEngines(silent));
  }

  final missing = groups.length - available.length;
  if (missing > 0) {
    lines.add(l10n.telemetrySummaryModelGap(missing));
  }
  return lines;
}
