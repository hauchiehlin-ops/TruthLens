import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/models/detection_result.dart';
import '../../core/services/citation_evidence.dart';
import '../../core/services/claim_audit.dart';
import '../../core/services/forensic_evidence.dart';
import '../../core/services/integrated_assessment.dart';
import '../../features/report/verifiable_findings.dart';
import '../../core/services/document_provenance.dart';
import '../../l10n/generated/app_localizations.dart';
import 'provenance_card.dart';
import 'evidence_matrix_card.dart';
import 'verdict_palette.dart';

/// 報告區塊標題色。深色工作台主題（宇宙未來風／教育文柔風）的面板會以
/// [DefaultTextStyle] 指定白色文字，此時再套原本的深青色會變成深色疊深色而
/// 幾乎看不見；因此改由繼承下來的文字色推測背景明暗再決定。
Color headingColorFor(BuildContext context) {
  final inherited = DefaultTextStyle.of(context).style.color;
  final onDarkSurface = inherited != null && inherited.computeLuminance() > 0.5;
  return onDarkSurface ? Colors.white : const Color(0xFF1E3A5F);
}

/// 把棄權原因轉成該語系的白話說明
String describeAbstention(DetectionResult result, AppLocalizations l10n) {
  return switch (result.abstention) {
    AbstentionReason.none => '',
    AbstentionReason.tooFewSentences => l10n.abstentionTooFewSentences(
      result.analyzableSentenceCount,
      DetectionResult.minAnalyzableSentences,
    ),
    AbstentionReason.tooFewWords => l10n.abstentionTooFewWords(
      result.wordCount,
      DetectionResult.minWords,
    ),
    AbstentionReason.tooFewEngines => l10n.abstentionTooFewEngines(
      result.effectiveAvailableEngineCount,
      result.effectiveTotalEngineCount,
    ),
    AbstentionReason.enginesConflict => l10n.abstentionEnginesConflict(
      result.engineSpreadPoints,
    ),
    AbstentionReason.noEvidenceFound => l10n.abstentionNoEvidenceFound,
    AbstentionReason.singleWeakEvidenceSource =>
      l10n.abstentionSingleWeakEvidenceSource(result.evidenceEngineCount),
  };
}

/// 專業級報告頁頭：判定摘要 + 詳細指標
class ProfessionalReportHeader extends StatelessWidget {
  final DetectionResult result;
  final VoidCallback onDownloadPdf;

  /// 引用核實的摘要。核實需要網路且在分析後才完成，因此不放進
  /// [DetectionResult]，而由報告頁在結果到齊後傳入。
  final CitationEvidence citations;
  final ClaimAudit claims;

  const ProfessionalReportHeader({
    super.key,
    required this.result,
    required this.onDownloadPdf,
    this.citations = CitationEvidence.none,
    this.claims = ClaimAudit.none,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final assessment = IntegratedAssessment.assess(
      result,
      citations: citations,
      claims: claims,
    );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // 1. 頂部工具欄
          Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final details = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 主題與檔名分行：檔名可能很長，接在主題後面會把兩者
                    // 擠成一團而無法辨識何者為何。檔名再縮 30% 拉開層級。
                    Text(
                      l10n.reportAiContentReportTitle,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: headingColorFor(context),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (result.sourceFileName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Builder(
                        builder: (context) {
                          final base = Theme.of(
                            context,
                          ).textTheme.headlineSmall;
                          return Text(
                            result.sourceFileName,
                            style: base?.copyWith(
                              // 主題字級的 70%
                              fontSize: (base.fontSize ?? 24) * 0.7,
                              fontWeight: FontWeight.w600,
                              color: headingColorFor(
                                context,
                              ).withValues(alpha: 0.85),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      l10n.reportAnalysisTimeLabel(
                        DateTime.now().toString().split('.')[0],
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: headingColorFor(context).withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                );
                final download = FilledButton.icon(
                  onPressed: onDownloadPdf,
                  icon: Icon(LucideIcons.download),
                  label: Text(l10n.reportDownloadPdfButton),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6B5B95), // 紫
                  ),
                );
                if (constraints.maxWidth < 520) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      details,
                      const SizedBox(height: 12),
                      Align(alignment: Alignment.centerLeft, child: download),
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: details),
                    const SizedBox(width: 16),
                    download,
                  ],
                );
              },
            ),
          ),
          const Divider(thickness: 2),

          // 2. 整合作者判讀置頂。使用者先取得本次最可能方向，再依序往下
          //    核對可查證事實、證據覆蓋與各引擎細節。
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _VerdictSummaryCard(
              result: result,
              l10n: l10n,
              assessment: assessment,
              citations: citations,
            ),
          ),

          // 3. 可查證的事實。它們緊接主結論呈現，供使用者立即核對，
          //    但不再搶在作者判讀之前。
          Builder(
            builder: (context) {
              final findings = collectVerifiableFindings(
                result,
                l10n,
                citations: citations,
                claims: claims,
              );
              if (findings.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: _VerifiableFindingsCard(findings: findings, l10n: l10n),
              );
            },
          ),

          // 4. 四軸證據矩陣。覆蓋與證據方向分開呈現；只有作者特異性
          //    訊號進入下方作者判讀，其餘維持待核查事實。
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: EvidenceMatrixCard(
              matrix: ForensicEvidenceMatrix.assess(
                result,
                citations: citations,
                claims: claims,
              ),
            ),
          ),

          // 5. 三列指標卡
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _MetricsRow(result: result, l10n: l10n),
          ),

          // 6. 文件來源證據卡（與 AI 機率分開的另一類證據；沒有可用紀錄時
          //    仍顯示，明確告訴使用者「這份無從由來源判斷」而非默默略過）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ProvenanceCard(provenance: result.provenance),
          ),

          // 7. 引擎貢獻度卡
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _EngineContributionCard(
              result: result,
              assessment: assessment,
              l10n: l10n,
            ),
          ),

          const Divider(thickness: 1, height: 24),

          // 8. 可疑句子清單標題
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.alertTriangle,
                  color: Color(0xFFD4AF37), // 金
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.reportSuspiciousLocationsTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: headingColorFor(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.reportSentenceCount(result.aiSentenceCount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: headingColorFor(context).withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 可查證事實的清單，放在判定卡**之前**。
///
/// 原本的順序是反的：機率當頭條、事實在下方。但「三篇文獻查無此文」與
/// 「編輯總時長 0 分鐘但正文 2462 字」都是可以獨立驗證的事實，而 AI 機率
/// 是推論——今天已證實它對現代模型的輸出分辨力有限。
///
/// 一份報告若能說「這三篇文獻查無此文」，它的說服力不需要任何機率來支撐。
class _VerifiableFindingsCard extends StatelessWidget {
  final List<VerifiableFinding> findings;
  final AppLocalizations l10n;

  const _VerifiableFindingsCard({required this.findings, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasConcern = findings.any((f) => f.isConcern);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasConcern ? scheme.error : scheme.outlineVariant,
          width: hasConcern ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                hasConcern ? LucideIcons.fileSearch : LucideIcons.checkCircle,
                size: 20,
                color: hasConcern ? scheme.error : scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.reportVerifiableFindingsTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.reportVerifiableFindingsSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          for (final finding in findings)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    finding.isConcern
                        ? LucideIcons.alertTriangle
                        : LucideIcons.check,
                    size: 16,
                    color: finding.isConcern
                        ? scheme.error
                        : scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      finding.statement,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// 偏人類的低分需要附上哪一種警語。
enum _LowScoreCaveat {
  /// 不需要：判定不偏人類、已棄權，或來源證據支持人類撰寫
  none,

  /// 沒有任何來源證據，低分只代表「文本統計沒找到痕跡」
  noProvenance,

  /// **可查證的證據顯示可疑，卻得到偏人類的低分。**
  /// 這是最該被放大的情況：兩類證據互相矛盾，而可查證的證據
  /// （檔案編輯紀錄、引用是否存在）不隨模型世代失效，可信度高於文本統計。
  /// 把它縮成一句「沒有來源證據」是錯的——有，而且在示警。
  provenanceContradicts,
}

_LowScoreCaveat _lowScoreCaveat(
  DetectionResult result, {
  CitationEvidence citations = CitationEvidence.none,
}) {
  if (result.verdict != Verdict.human &&
      result.verdict != Verdict.likelyHuman) {
    return _LowScoreCaveat.none;
  }

  // 刻意規避的痕跡是最直接的反證：它不談文風，而是有人動手腳。
  // 不受 indicatesHumanAuthorship 抵銷——編輯歷程正常的檔案照樣可以被
  // humanizer 工具處理過。
  if (result.evasion.indicatesDeliberateEvasion) {
    return _LowScoreCaveat.provenanceContradicts;
  }

  // 捏造引用與可疑編輯紀錄同屬「可查證的事實」，任一成立都構成矛盾。
  // 引用證據刻意不被 indicatesHumanAuthorship 抵銷：一份編輯歷程正常的文件
  // 仍可能引用了不存在的文獻，那是獨立的問題。
  if (citations.contradictsHumanAuthorship) {
    return _LowScoreCaveat.provenanceContradicts;
  }

  if (result.provenance.indicatesHumanAuthorship) return _LowScoreCaveat.none;

  final risk = result.provenance.risk;
  if (risk == ProvenanceRisk.medium || risk == ProvenanceRisk.high) {
    return _LowScoreCaveat.provenanceContradicts;
  }
  return _LowScoreCaveat.noProvenance;
}

/// 判定摘要卡片（大）
class _VerdictSummaryCard extends StatelessWidget {
  final DetectionResult result;
  final AppLocalizations l10n;
  final IntegratedAssessment assessment;
  final CitationEvidence citations;

  const _VerdictSummaryCard({
    required this.result,
    required this.l10n,
    required this.assessment,
    required this.citations,
  });

  @override
  Widget build(BuildContext context) {
    final verdict = switch (assessment.direction) {
      IntegratedDirection.likelyAi => Verdict.likelyAi,
      IntegratedDirection.likelyMixed => Verdict.mixed,
      IntegratedDirection.likelyHuman => Verdict.likelyHuman,
      IntegratedDirection.balanced => Verdict.mixed,
    };
    final base = verdictColor(verdict);
    final confidence = switch (assessment.confidence) {
      IntegratedConfidence.low => l10n.integratedConfidenceLow,
      IntegratedConfidence.moderate => l10n.integratedConfidenceModerate,
      IntegratedConfidence.high => l10n.integratedConfidenceHigh,
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: verdictGradient(verdict),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 480;
          final iconBadge = Container(
            width: compact ? 56 : 80,
            height: compact ? 56 : 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
            ),
            child: Center(
              // 圖示與底色同步分級：只靠顏色分辨對色盲使用者不友善，
              // 形狀是第二條獨立的辨識線索。
              child: Icon(
                switch (assessment.direction) {
                  IntegratedDirection.likelyAi => LucideIcons.cpu,
                  IntegratedDirection.likelyMixed => LucideIcons.layers,
                  IntegratedDirection.likelyHuman => LucideIcons.pencil,
                  IntegratedDirection.balanced => LucideIcons.scale,
                },
                size: compact ? 28 : 40,
                color: Colors.white,
              ),
            ),
          );
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.integratedAssessmentTitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                switch (assessment.direction) {
                  IntegratedDirection.likelyAi => l10n.integratedLikelyAi,
                  IntegratedDirection.likelyMixed => l10n.integratedLikelyMixed,
                  IntegratedDirection.likelyHuman => l10n.integratedLikelyHuman,
                  IntegratedDirection.balanced => l10n.integratedBalanced,
                },
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.integratedLikelihoodLabel(
                  (assessment.aiLikelihood * 100).round(),
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${l10n.integratedTextScoreLabel((result.aiProbability * 100).round())} · '
                '${l10n.integratedConfidenceLabel(confidence)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.integratedEvidenceCoverage(
                  assessment.independentEvidenceFamilies,
                  (assessment.applicabilityCoverage * 100).round(),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.integratedStabilityLabel(
                  (assessment.stabilityScore * 100).round(),
                  (assessment.lowerBound * 100).round(),
                  (assessment.upperBound * 100).round(),
                ),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
              if (result.inputQuality.extractionQuality < 0.95) ...[
                const SizedBox(height: 3),
                Text(
                  l10n.integratedInputQualityLabel(
                    (result.inputQuality.extractionQuality * 100).round(),
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
              if (result.calibration.isApplicable) ...[
                const SizedBox(height: 3),
                Text(
                  l10n.integratedCalibrationLabel(
                    result.calibration.pValue.toStringAsFixed(3),
                    result.calibration.calibrationSize,
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 3),
              Text(
                assessment.passesAiEvidenceGate
                    ? l10n.integratedEvidenceGatePassed
                    : l10n.integratedEvidenceGateNotPassed,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.integratedIndexCaveat,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white70,
                  height: 1.4,
                ),
              ),
              if (result.hasEvidenceLimitations) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    l10n.integratedQualifiedWarning(
                      describeAbstention(result, l10n),
                    ),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
              // 偏人類的低分，在沒有來源證據時**不構成人類撰寫的確認**。
              // 實測：2026 世代 LLM 的中文散文困惑度落在真人分布內，
              // 一篇 ChatGPT 中文因此被判為「可能人類」。文本統計只能指認
              // 罐頭式寫作，指認不了寫得好的 AI 文本——這句話必須放在判定
              // 旁邊，塞進下方的說明卡等於沒說。
              if (_lowScoreCaveat(result, citations: citations) !=
                  _LowScoreCaveat.none) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    // 證據互相矛盾時加重底色與框線：這不是補充說明，
                    // 是「別只看上面那個數字」的告誡
                    color: Colors.white.withValues(
                      alpha:
                          _lowScoreCaveat(result, citations: citations) ==
                              _LowScoreCaveat.provenanceContradicts
                          ? 0.22
                          : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha:
                            _lowScoreCaveat(result, citations: citations) ==
                                _LowScoreCaveat.provenanceContradicts
                            ? 0.70
                            : 0.28,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _lowScoreCaveat(result, citations: citations) ==
                                _LowScoreCaveat.provenanceContradicts
                            ? LucideIcons.alertTriangle
                            : LucideIcons.info,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _lowScoreCaveat(result, citations: citations) ==
                                  _LowScoreCaveat.provenanceContradicts
                              ? l10n.reportProvenanceContradictsLowScore
                              : l10n.reportLowScoreNotProofOfHuman,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.92),
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [iconBadge, const SizedBox(height: 14), content],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconBadge,
              const SizedBox(width: 20),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}

/// 三列指標卡
class _MetricsRow extends StatelessWidget {
  final DetectionResult result;
  final AppLocalizations l10n;

  const _MetricsRow({required this.result, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final analyzableSentenceCount = result.analyzableSentenceCount;
    final aiSentenceRatio = analyzableSentenceCount == 0
        ? 0.0
        : result.aiSentenceCount / analyzableSentenceCount;
    final cards = [
      _MetricCard(
        icon: LucideIcons.barChart,
        iconColor: const Color(0xFF6B5B95),
        title: l10n.reportMetricAiSentenceRatio,
        value: '${(aiSentenceRatio * 100).toStringAsFixed(1)}%',
        subtitle: l10n.reportStrongAiSentenceCount(
          result.aiSentenceCount,
          analyzableSentenceCount,
        ),
      ),
      _MetricCard(
        icon: LucideIcons.clock,
        iconColor: const Color(0xFF1E3A5F),
        title: l10n.reportMetricElapsed,
        value: '${(result.elapsed.inMilliseconds / 1000).toStringAsFixed(2)}s',
        subtitle: l10n.reportMetricElapsedNormal,
      ),
      _MetricCard(
        icon: LucideIcons.shieldCheck,
        iconColor: const Color(0xFFD4AF37),
        title: l10n.reportMetricReliability,
        value: result.isLowConfidence
            ? l10n.reportReliabilityLow
            : l10n.reportReliabilityHigh,
        subtitle: result.isLowConfidence
            ? l10n.reportReliabilityNeedsReview
            : l10n.reportReliabilityHighTrust,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: cards[i]),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }
}

/// 單個指標卡
class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

/// 引擎貢獻度卡
class _EngineContributionCard extends StatelessWidget {
  final DetectionResult result;
  final IntegratedAssessment assessment;
  final AppLocalizations l10n;

  const _EngineContributionCard({
    required this.result,
    required this.assessment,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final engineGroups = EngineGroup.fromScores(
      result.engineScores,
      l10n,
      eslAdjusted: result.eslAdjusted,
      contributionPointsByEngineId: result.roundedEngineContributionPoints,
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.layers, color: Color(0xFF6B5B95), size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.reportEngineAnalysisLevelTitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 雷達圖：顯示各引擎 AI 概率
          if (engineGroups.isNotEmpty) ...[
            _RadarWithVerdict(
              engineGroups: engineGroups,
              assessment: assessment,
              l10n: l10n,
            ),
            _EngineSynthesisSummary(
              groups: engineGroups,
              assessment: assessment,
              textModelProbability: result.aiProbability,
              l10n: l10n,
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // 引擎詳細列表
          Text(
            l10n.reportDetailAnalysisTitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            l10n.reportTextEngineSignalExplanation,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),

          // 引擎列表
          if (engineGroups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n.reportNoEngineData,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
              ),
            )
          else
            for (final group in engineGroups)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 可用狀態指示
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: group.available
                            ? const Color(0xFF6B5B95)
                            : Colors.grey[300],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 引擎名 + 評分
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      group.axisLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1E3A5F),
                                          ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      group.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                group.available
                                    ? l10n.reportEngineSignalLabel(
                                        (group.probability * 100).round(),
                                      )
                                    : l10n.reportEngineNotParticipated,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: group.available
                                          ? const Color(0xFF1E3A5F)
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: group.available ? group.probability : 0,
                              minHeight: 4,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                !group.available
                                    ? Colors.grey[300]!
                                    : group.probability > 0.7
                                    ? const Color(0xFF6B5B95)
                                    : const Color(0xFF1E3A5F),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _RadarWithVerdict extends StatelessWidget {
  final List<EngineGroup> engineGroups;
  final IntegratedAssessment assessment;
  final AppLocalizations l10n;

  const _RadarWithVerdict({
    required this.engineGroups,
    required this.assessment,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 560;
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _EngineRadarChart(engineGroups: engineGroups),
              ),
              const SizedBox(height: 8),
              _VerdictSignalBadge(assessment: assessment, l10n: l10n),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _EngineRadarChart(engineGroups: engineGroups),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: _VerdictSignalBadge(assessment: assessment, l10n: l10n),
            ),
          ],
        );
      },
    );
  }
}

class _VerdictSignalBadge extends StatelessWidget {
  final IntegratedAssessment assessment;
  final AppLocalizations l10n;

  const _VerdictSignalBadge({required this.assessment, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final verdict = switch (assessment.direction) {
      IntegratedDirection.likelyAi => Verdict.likelyAi,
      IntegratedDirection.likelyMixed => Verdict.mixed,
      IntegratedDirection.likelyHuman => Verdict.likelyHuman,
      IntegratedDirection.balanced => Verdict.mixed,
    };
    final meta = _meta(verdict);
    final probability = (assessment.aiLikelihood * 100).round();
    final confidence = switch (assessment.confidence) {
      IntegratedConfidence.low => l10n.integratedConfidenceLow,
      IntegratedConfidence.moderate => l10n.integratedConfidenceModerate,
      IntegratedConfidence.high => l10n.integratedConfidenceHigh,
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: meta.color.withValues(alpha: 0.25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: meta.color.withValues(alpha: 0.16),
                ),
                child: Icon(meta.icon, color: meta.color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.reportVerdictBadgeTitle,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      switch (assessment.direction) {
                        IntegratedDirection.likelyAi => l10n.integratedLikelyAi,
                        IntegratedDirection.likelyMixed =>
                          l10n.integratedLikelyMixed,
                        IntegratedDirection.likelyHuman =>
                          l10n.integratedLikelyHuman,
                        IntegratedDirection.balanced => l10n.integratedBalanced,
                      },
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: meta.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.integratedLikelihoodLabel(probability),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF1E3A5F),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.integratedConfidenceLabel(confidence),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  static _VerdictMeta _meta(Verdict verdict) => switch (verdict) {
    Verdict.human => _VerdictMeta(
      icon: LucideIcons.shieldCheck,
      color: Color(0xFF2E7D32),
    ),
    Verdict.likelyHuman => _VerdictMeta(
      icon: LucideIcons.checkCircle,
      color: Color(0xFF558B2F),
    ),
    Verdict.mixed => _VerdictMeta(
      icon: LucideIcons.scale,
      color: Color(0xFF6B5B95),
    ),
    Verdict.likelyAi => _VerdictMeta(
      icon: LucideIcons.alertTriangle,
      color: Color(0xFFC47F17),
    ),
    Verdict.ai => _VerdictMeta(
      icon: LucideIcons.alertTriangle,
      color: Color(0xFFC62828),
    ),
  };
}

class _VerdictMeta {
  final IconData icon;
  final Color color;

  _VerdictMeta({required this.icon, required this.color});
}

/// 引擎 AI 概率雷達圖
class _EngineRadarChart extends StatelessWidget {
  final List<EngineGroup> engineGroups;

  const _EngineRadarChart({required this.engineGroups});

  @override
  Widget build(BuildContext context) {
    if (engineGroups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            '無引擎數據',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
          ),
        ),
      );
    }

    final displayGroups = engineGroups.take(5).toList();
    final chartSize = math
        .min(MediaQuery.sizeOf(context).width - 96, 280.0)
        .clamp(220.0, 280.0);

    return Center(
      child: SizedBox(
        width: chartSize,
        height: chartSize,
        child: CustomPaint(painter: _ReportRadarPainter(groups: displayGroups)),
      ),
    );
  }
}

class _ReportRadarPainter extends CustomPainter {
  final List<EngineGroup> groups;

  const _ReportRadarPainter({required this.groups});

  @override
  void paint(Canvas canvas, Size size) {
    if (groups.length < 3) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 42;
    const axisColor = Color(0xFFE3E1EA);
    const valueColor = Color(0xFF6B5B95);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = axisColor;
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = axisColor.withValues(alpha: 0.75);
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = valueColor.withValues(alpha: 0.20);
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = valueColor;
    final disabledDotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFBDBDBD);
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = valueColor;

    for (var ring = 1; ring <= 4; ring++) {
      final ringPath = Path();
      for (var i = 0; i < groups.length; i++) {
        final p = _point(center, radius * ring / 4, i, groups.length);
        if (i == 0) {
          ringPath.moveTo(p.dx, p.dy);
        } else {
          ringPath.lineTo(p.dx, p.dy);
        }
      }
      ringPath.close();
      canvas.drawPath(ringPath, gridPaint);
    }

    for (var i = 0; i < groups.length; i++) {
      canvas.drawLine(
        center,
        _point(center, radius, i, groups.length),
        axisPaint,
      );
    }

    final valuePath = Path();
    for (var i = 0; i < groups.length; i++) {
      final value = groups[i].available
          ? groups[i].probability.clamp(0.0, 1.0)
          : 0.0;
      final p = _point(center, radius * value, i, groups.length);
      if (i == 0) {
        valuePath.moveTo(p.dx, p.dy);
      } else {
        valuePath.lineTo(p.dx, p.dy);
      }
    }
    valuePath.close();
    canvas.drawPath(valuePath, fillPaint);
    canvas.drawPath(valuePath, outlinePaint);

    for (var i = 0; i < groups.length; i++) {
      final value = groups[i].available
          ? groups[i].probability.clamp(0.0, 1.0)
          : 0.0;
      final p = _point(center, radius * value, i, groups.length);
      canvas.drawCircle(
        p,
        4,
        groups[i].available ? dotPaint : disabledDotPaint,
      );
    }

    for (var i = 0; i < groups.length; i++) {
      final p = _point(center, radius + 24, i, groups.length);
      final painter = TextPainter(
        text: TextSpan(
          text: groups[i].axisLabel,
          style: const TextStyle(
            color: Color(0xFF55515D),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 78);
      painter.paint(
        canvas,
        Offset(p.dx - painter.width / 2, p.dy - painter.height / 2),
      );
    }
  }

  Offset _point(Offset center, double radius, int index, int total) {
    final angle = (index / total) * 2 * math.pi - math.pi / 2;
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  @override
  bool shouldRepaint(covariant _ReportRadarPainter oldDelegate) {
    return oldDelegate.groups != groups;
  }
}

class _EngineSynthesisSummary extends StatelessWidget {
  final List<EngineGroup> groups;
  final IntegratedAssessment assessment;
  final double textModelProbability;
  final AppLocalizations l10n;

  const _EngineSynthesisSummary({
    required this.groups,
    required this.assessment,
    required this.textModelProbability,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final available = groups.where((g) => g.available).toList();
    final strongestSignal = available.isEmpty
        ? null
        : available.reduce((a, b) => a.probability >= b.probability ? a : b);
    final strongestContribution = available.isEmpty
        ? null
        : available.reduce(
            (a, b) => a.contributionPoints >= b.contributionPoints ? a : b,
          );
    EngineGroup? style;
    for (final group in groups) {
      if (group.role == 'stylometry') {
        style = group;
        break;
      }
    }
    final hasModelGap = groups.any((g) => !g.available);

    final direction = switch (assessment.direction) {
      IntegratedDirection.likelyAi => l10n.integratedLikelyAi,
      IntegratedDirection.likelyMixed => l10n.integratedLikelyMixed,
      IntegratedDirection.likelyHuman => l10n.integratedLikelyHuman,
      IntegratedDirection.balanced => l10n.integratedBalanced,
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
      l10n.reportSynthesisTextScoreContext(
        (textModelProbability * 100).round(),
      ),
    ];
    if (strongestSignal != null) {
      lines.add(
        l10n.reportSynthesisStrongestTextSignal(
          strongestSignal.label,
          (strongestSignal.probability * 100).round(),
        ),
      );
    }
    if (strongestContribution != null) {
      lines.add(
        l10n.reportSynthesisStrongestContribution(
          strongestContribution.label,
          strongestContribution.contributionPoints,
        ),
      );
    }
    if (style != null &&
        style.probability < 0.45 &&
        textModelProbability >= 0.45) {
      lines.add(l10n.reportSynthesisStyleCaveat);
    }
    if (hasModelGap) {
      lines.add(l10n.reportSynthesisModelGap);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE3E1EA)),
      ),
      child: Text(
        lines.join('\n'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: const Color(0xFF3F3A4A),
          height: 1.35,
        ),
      ),
    );
  }
}

class EngineGroup {
  final String role;
  final String label;
  final String axisLabel;
  final double probability;
  final double weight;
  final double contribution;
  final int contributionPoints;
  final bool available;

  /// 這個引擎本次是否真的找到證據。false 代表它可用但沒有發言——
  /// 不參與投票，也不算在引擎分歧裡。
  final bool hasEvidence;
  final int variantCount;
  final List<String> reasons;
  final AppLocalizations l10n;

  const EngineGroup({
    required this.role,
    required this.label,
    required this.axisLabel,
    required this.probability,
    required this.weight,
    required this.contribution,
    required this.contributionPoints,
    required this.available,
    required this.hasEvidence,
    required this.variantCount,
    required this.reasons,
    required this.l10n,
  });

  String get relationshipText {
    final weightPercent = (weight * 100).round();
    if (!available) {
      return l10n.reportEngineRelationshipUnavailable(
        label,
        _resolutionHint(role, l10n),
      );
    }
    if (!hasEvidence) {
      return l10n.reportEngineRelationshipNoEvidence(label, weightPercent);
    }
    final variantText = variantCount > 1
        ? l10n.reportEngineVariantMerged(variantCount)
        : '';
    return l10n.reportEngineRelationshipAvailable(
      weightPercent,
      contributionPoints,
      variantText,
    );
  }

  static List<EngineGroup> fromScores(
    List<EngineScore> scores,
    AppLocalizations l10n, {
    bool eslAdjusted = false,
    Map<String, int> contributionPointsByEngineId = const {},
  }) {
    const order = ['transformer', 'statistical', 'stylometry', 'adversarial'];
    final grouped = <String, List<EngineScore>>{
      for (final role in order) role: <EngineScore>[],
    };
    for (final score in scores) {
      grouped[_roleOf(score.engineId)]?.add(score);
    }

    double configuredWeight(String role) => grouped[role]!.isNotEmpty
        ? grouped[role]!.first.weight
        : _roleWeight(role);
    double effectiveWeight(String role) {
      final configured = configuredWeight(role);
      final reliability = grouped[role]!
          .where((score) => score.available)
          .map((score) => score.evidenceWeightMultiplier)
          .fold<double>(0, math.max);
      final eslFactor = eslAdjusted && role == 'statistical' ? 0.5 : 1.0;
      return configured * reliability * eslFactor;
    }

    // 與 DetectionResult.votingEngines 同步：有證據的角色才分配權重；
    // 全體沉默時退回全體可用角色，否則貢獻度會全部變成 0。
    bool roleVotes(String role) => grouped[role]!.any((s) => s.votes);
    final anyEvidence = order.any(roleVotes);
    bool counts(String role) => anyEvidence
        ? roleVotes(role)
        : grouped[role]!.any(
            (s) =>
                s.available &&
                s.applicability != EngineApplicability.unsupported,
          );
    final availableWeight = order.fold<double>(
      0,
      (sum, role) => counts(role) ? sum + effectiveWeight(role) : sum,
    );

    return [
      for (final role in order)
        _fromRole(
          role,
          grouped[role]!,
          availableWeight: availableWeight,
          effectiveWeight: effectiveWeight(role),
          counted: counts(role),
          contributionPoints: grouped[role]!.fold<int>(
            0,
            (sum, score) =>
                sum + (contributionPointsByEngineId[score.engineId] ?? 0),
          ),
          l10n: l10n,
        ),
    ];
  }

  static EngineGroup _fromRole(
    String role,
    List<EngineScore> scores, {
    required double availableWeight,
    required double effectiveWeight,
    required bool counted,
    required int contributionPoints,
    required AppLocalizations l10n,
  }) {
    final availableScores = scores
        .where(
          (s) =>
              s.available &&
              s.applicability != EngineApplicability.unsupported &&
              s.calibrationReliability > 0,
        )
        .toList();
    final available = availableScores.isNotEmpty;
    final probability = available
        ? availableScores.fold<double>(0, (sum, s) => sum + s.aiProbability) /
              availableScores.length
        : 0.0;
    final weight = scores.isNotEmpty ? scores.first.weight : _roleWeight(role);
    final contribution = counted && availableWeight > 0
        ? probability * effectiveWeight / availableWeight
        : 0.0;
    final reasons = <String>[
      for (final score in scores)
        ...score.reasons.where((reason) => reason.trim().isNotEmpty),
    ];
    final uniqueReasons = <String>[
      for (final reason in reasons.toSet()) _explainReason(role, reason, l10n),
    ];

    return EngineGroup(
      role: role,
      label: _roleLabel(role, l10n),
      axisLabel: _axisLabel(role, l10n),
      probability: probability,
      weight: weight,
      contribution: contribution,
      contributionPoints: contributionPoints,
      available: available,
      hasEvidence: availableScores.any((s) => s.hasEvidence),
      variantCount: math.max(scores.length, 1),
      reasons: uniqueReasons.isEmpty
          ? [_fallbackReason(role, available, l10n)]
          : uniqueReasons,
      l10n: l10n,
    );
  }

  static String _roleOf(String engineId) {
    if (engineId.startsWith('transformer')) return 'transformer';
    if (engineId.startsWith('statistical')) return 'statistical';
    if (engineId.startsWith('stylometry')) return 'stylometry';
    if (engineId.startsWith('adversarial')) return 'adversarial';
    return engineId;
  }

  static double _roleWeight(String role) => switch (role) {
    'transformer' => 0.40,
    'statistical' => 0.25,
    'stylometry' => 0.20,
    'adversarial' => 0.15,
    _ => 0.0,
  };

  static String _roleLabel(String role, AppLocalizations l10n) =>
      switch (role) {
        'transformer' => l10n.reportRadarRoleTransformer,
        'statistical' => l10n.reportRadarRoleStatistical,
        'stylometry' => l10n.reportRadarRoleStylometry,
        'adversarial' => l10n.reportRadarRoleAdversarial,
        _ => role,
      };

  static String _axisLabel(String role, AppLocalizations l10n) =>
      switch (role) {
        'transformer' => l10n.reportRadarAxisTransformer,
        'statistical' => l10n.reportRadarAxisStatistical,
        'stylometry' => l10n.reportRadarAxisStylometry,
        'adversarial' => l10n.reportRadarAxisAdversarial,
        _ => role,
      };

  static String _fallbackReason(
    String role,
    bool available,
    AppLocalizations l10n,
  ) {
    final label = _roleLabel(role, l10n);
    if (!available) return l10n.reportEngineFallbackUnavailable(label);
    return l10n.reportEngineFallbackAvailable(label);
  }

  static String _resolutionHint(String role, AppLocalizations l10n) =>
      switch (role) {
        'transformer' => l10n.reportEngineResolutionTransformer,
        'adversarial' => l10n.reportEngineResolutionAdversarial,
        _ => '',
      };

  static String _explainReason(
    String role,
    String reason,
    AppLocalizations l10n,
  ) {
    if (role == 'adversarial' &&
        reason.contains('Cannot convert a BigInt value to a number')) {
      return l10n.reportEngineReasonBigInt(reason);
    }
    if (role == 'transformer' && reason.contains('tokenizer')) {
      return l10n.reportEngineReasonTokenizer(reason);
    }
    if (role == 'transformer' && reason.contains('未找到使用中的')) {
      return l10n.reportEngineReasonNoActiveTransformer(reason);
    }
    return reason;
  }
}
