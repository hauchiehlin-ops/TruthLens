/// 分析遙測面板的白話總結：把四個引擎的結果講成人話。
library;

import '../../core/models/detection_result.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/professional_report_header.dart'
    show EngineGroup, describeAbstention;

/// 以白話文總結各引擎的分析結果：先講結論，再講引擎之間合不合、
/// 分數主要被誰拉動、逐句掃出什麼，最後給一句「所以該怎麼辦」。
/// 每一句都由本次實際數據組出，不是固定罐頭句；結果為 null 或無可用引擎時回傳空清單。
List<String> buildTelemetrySummary(DetectionResult? result, AppLocalizations l10n) {
  if (result == null) return const [];

  final groups = EngineGroup.fromScores(
    result.engineScores,
    l10n,
    eslAdjusted: result.eslAdjusted,
    contributionPointsByEngineId: result.roundedEngineContributionPoints,
  );
  final available = groups.where((g) => g.available).toList();
  if (available.isEmpty) return const [];

  // 報告已棄權時，總結不能反過來給一個自信的判定，否則兩處自相矛盾
  if (result.shouldAbstain) {
    return [
      l10n.abstentionHeadline,
      describeAbstention(result, l10n),
      l10n.abstentionScoreStillShown,
    ];
  }

  final lines = <String>[
    l10n.telemetrySummaryVerdict(
      available.length,
      groups.length,
      (result.aiProbability * 100).round(),
      result.verdict.label(l10n),
    ),
  ];

  // 引擎之間看法合不合：分數全距 30 個百分點以內視為一致
  final highest = available.reduce(
    (a, b) => a.probability >= b.probability ? a : b,
  );
  final lowest = available.reduce(
    (a, b) => a.probability <= b.probability ? a : b,
  );
  final highPercent = (highest.probability * 100).round();
  final lowPercent = (lowest.probability * 100).round();
  final enginesDisagree = available.length >= 2 && highPercent - lowPercent > 30;
  if (available.length >= 2) {
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
  lines.add(switch (result.verdict) {
    Verdict.human || Verdict.likelyHuman when !enginesDisagree =>
      l10n.telemetrySummaryAdviceHuman,
    Verdict.human || Verdict.likelyHuman || Verdict.mixed =>
      l10n.telemetrySummaryAdviceMixed,
    Verdict.likelyAi || Verdict.ai => l10n.telemetrySummaryAdviceAi,
  });

  final missing = groups.length - available.length;
  if (missing > 0) {
    lines.add(l10n.telemetrySummaryModelGap(missing));
  }
  return lines;
}
