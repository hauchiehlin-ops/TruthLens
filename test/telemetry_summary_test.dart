import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/services/publication_evidence.dart';
import 'package:truthlens/features/workspace/telemetry_summary.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

/// 足以通過棄權字數門檻的正文
final _longText = List.filled(200, 'alpha').join(' ');

/// 依指定的各引擎分數組出檢測結果；[threshold] 預設 0.5，切點即 20/40/60/80
DetectionResult _result({
  required Map<String, double> engineScores,
  Set<String> unavailable = const {},
  bool hasEvidence = true,
  List<double> sentenceScores = const [0.1, 0.1, 0.1, 0.15, 0.12, 0.08],
}) {
  final scores = [
    for (final entry in engineScores.entries)
      EngineScore(
        engineId: entry.key,
        engineName: entry.key,
        aiProbability: entry.value,
        weight: 0.25,
        available: !unavailable.contains(entry.key),
        hasEvidence: hasEvidence,
        sentenceScores: hasEvidence ? sentenceScores : null,
      ),
  ];
  final activeWeight = scores
      .where((s) => !unavailable.contains(s.engineId))
      .fold<double>(0, (sum, s) => sum + s.weight);
  final overall = activeWeight <= 0
      ? 0.0
      : scores
                .where((s) => !unavailable.contains(s.engineId))
                .fold<double>(0, (sum, s) => sum + s.aiProbability * s.weight) /
            activeWeight;

  return DetectionResult(
    id: 't',
    analyzedAt: DateTime(2026, 8, 16),
    // 需超過棄權門檻（100 字），這些案例測的是有結論時的總結內容
    inputText: _longText,
    aiProbability: overall,
    verdict: Verdict.fromProbability(overall),
    engineScores: scores,
    sentences: [
      for (var i = 0; i < sentenceScores.length; i++)
        SentenceScore(
          index: i,
          text: 'This is a complete analysable sentence number $i.',
          aiProbability: sentenceScores[i],
        ),
    ],
  );
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('結果為 null 或無可用引擎時不產生總結', () {
    expect(buildTelemetrySummary(null, l10n), isEmpty);
    expect(
      buildTelemetrySummary(
        _result(
          engineScores: {'transformer': 0.5, 'statistical': 0.5},
          unavailable: {'transformer', 'statistical'},
        ),
        l10n,
      ),
      isEmpty,
    );
  });

  test('引擎分數接近時走「一致」那句，並給出人類撰寫的結論', () {
    final lines = buildTelemetrySummary(
      _result(
        engineScores: {
          'transformer': 0.05,
          'statistical': 0.10,
          'stylometry': 0.05,
          'adversarial': 0.05,
        },
      ),
      l10n,
    );
    final text = lines.join(' ');

    expect(text, contains('After weighting the available evidence'));
    expect(text, contains('More likely not AI-generated'));
    expect(text, contains('broadly agree'));
    expect(text, isNot(contains('engines disagree')));
    expect(text, contains('not one crossed the strong-AI line'));
    expect(text, contains('like something a person actually wrote'));
    expect(text, isNot(contains('sat this one out')));
  });

  test('引擎分數差距超過 30 個百分點時走「不合」那句，且不給「沒什麼好查」的結論', () {
    final lines = buildTelemetrySummary(
      _result(
        engineScores: {
          // 全距 55 個百分點：足以觸發「引擎不合」，但未達棄權門檻（60）
          'transformer': 0.60,
          'statistical': 0.05,
          'stylometry': 0.10,
          'adversarial': 0.08,
        },
      ),
      l10n,
    );
    final text = lines.join(' ');

    expect(text, contains('The engines disagree'));
    expect(text, isNot(contains('broadly agree')));
    // 判定仍偏人類，但因引擎不合，結論必須改成需要人工判讀，避免自相矛盾
    expect(text, isNot(contains('nothing that needs chasing')));
    expect(text, contains('grey zone'));
  });

  test('有句子越過強 AI 訊號線時逐句那行改為提示逐一檢視', () {
    final lines = buildTelemetrySummary(
      _result(
        engineScores: {
          'transformer': 0.9,
          'statistical': 0.85,
          'stylometry': 0.9,
          'adversarial': 0.88,
        },
        sentenceScores: const [0.95, 0.9, 0.1, 0.92, 0.88, 0.91],
      ),
      l10n,
    );
    final text = lines.join(' ');

    expect(text, contains('Of 6 sentences, 5 crossed the strong-AI line'));
    expect(text, contains('AI generation or rewriting'));
  });

  test('有引擎缺席時回報缺席數量並提醒把握度打折', () {
    final lines = buildTelemetrySummary(
      _result(
        engineScores: {
          'transformer': 0.5,
          'statistical': 0.1,
          'stylometry': 0.1,
          'adversarial': 0.1,
        },
        unavailable: {'transformer', 'adversarial'},
      ),
      l10n,
    );
    final text = lines.join(' ');

    expect(text, contains('After weighting the available evidence'));
    expect(text, contains('2 engine(s) sat this one out'));
  });

  test('已核實的生成式 AI 前出版來源會同步更新遙測總結', () {
    final lines = buildTelemetrySummary(
      _result(
        engineScores: {
          'transformer': 0.5,
          'statistical': 0.5,
          'stylometry': 0.5,
          'adversarial': 0.5,
        },
        hasEvidence: false,
      ),
      l10n,
      publication: const PublicationEvidence(
        status: PublicationEvidenceStatus.verified,
        doi: '10.1142/S0218127410026678',
        articleTitle:
            'Lowest Stability Boundary on Flow of Concentric Rotating Cylinders',
        publicationYear: 2010,
        titleSimilarity: 1,
      ),
    );
    final text = lines.join(' ');

    expect(text, contains('More likely not AI-generated'));
    expect(text, contains('AI likelihood index 10%'));
    expect(text, isNot(contains('AI and human signals are balanced')));
    expect(text, isNot(contains('engines disagree')));
    expect(text, isNot(contains('broadly agree')));
    expect(text, isNot(contains('crossed the strong-AI line')));
  });
}
