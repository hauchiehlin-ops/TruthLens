import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/features/report/report_composer.dart';
import 'package:truthlens/features/report/report_document.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

DetectionResult _result({
  required double ai,
  bool esl = false,
  bool paraphrase = false,
  double threshold = 0.6,
}) =>
    DetectionResult(
      id: 'x',
      analyzedAt: DateTime(2026, 7, 3),
      inputText: 'a',
      aiProbability: ai,
      verdict: Verdict.fromProbability(ai),
      threshold: threshold,
      eslAdjusted: esl,
      engineScores: [
        const EngineScore(
          engineId: 'stylometry',
          engineName: '風格特徵分析',
          aiProbability: 0.7,
          weight: 0.2,
          reasons: ['高頻使用通用過渡詞'],
        ),
        EngineScore(
          engineId: 'adversarial',
          engineName: '對抗式防禦',
          aiProbability: paraphrase ? 0.8 : 0.3,
          weight: 0.15,
          available: paraphrase,
          reasons: const ['改寫偵測'],
        ),
      ],
      sentences: const [
        SentenceScore(index: 0, text: '句一。', aiProbability: 0.8),
        SentenceScore(index: 1, text: '句二。', aiProbability: 0.2),
        SentenceScore(index: 2, text: '句三。', aiProbability: 0.5),
      ],
      dominantPatterns: const ['高頻使用通用過渡詞'],
    );

void main() {
  final composer = ReportComposer();
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('回退報告來源標示為 template', () {
    final doc = composer.compose(_result(ai: 0.9), l10n);
    expect(doc.source, ReportSource.template);
  });

  test('AI 高分選 ai_alert 版面，headline 反映判定', () {
    final doc = composer.compose(_result(ai: 0.9), l10n);
    expect(doc.templateId, 'ai_alert');
    expect(doc.headline, contains('AI'));
    expect(doc.headline, contains('90%'));
  });

  test('人類文本選 human_clean 版面', () {
    final doc = composer.compose(_result(ai: 0.1), l10n);
    expect(doc.templateId, 'human_clean');
  });

  test('偵測到改寫時選 paraphrase_alert 並含警告元件', () {
    final doc = composer.compose(_result(ai: 0.65, paraphrase: true), l10n);
    expect(doc.templateId, 'paraphrase_alert');
    expect(
      doc.components.any(
          (c) => c.type == ReportComponentType.paraphraseWarning),
      isTrue,
    );
  });

  test('ESL 修正時加入說明元件', () {
    final doc = composer.compose(_result(ai: 0.5, esl: true), l10n);
    expect(
      doc.components.any((c) => c.type == ReportComponentType.eslNotice),
      isTrue,
    );
  });

  test('固定含儀表、閾值橫幅、解讀、引擎明細', () {
    final types = composer
        .compose(_result(ai: 0.5), l10n)
        .components
        .map((c) => c.type)
        .toSet();
    expect(types, containsAll([
      ReportComponentType.overallGauge,
      ReportComponentType.thresholdBanner,
      ReportComponentType.narrative,
      ReportComponentType.engineBreakdown,
    ]));
  });

  test('閾值橫幅文字反映 flaggedAsAi', () {
    final flagged = composer.compose(_result(ai: 0.9, threshold: 0.6), l10n);
    final notFlagged =
        composer.compose(_result(ai: 0.5, threshold: 0.95), l10n);
    final flaggedBanner = flagged.components
        .firstWhere((c) => c.type == ReportComponentType.thresholdBanner);
    final notBanner = notFlagged.components
        .firstWhere((c) => c.type == ReportComponentType.thresholdBanner);
    expect(flaggedBanner.body, contains('flagged as AI'));
    expect(notBanner.body, contains('below'));
  });
}
