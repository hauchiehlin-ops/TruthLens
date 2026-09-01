import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/features/workspace/telemetry_summary.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

/// 產生指定句數的可分析句子（每句都夠長，確保通過 isAnalyzableSentence）
List<SentenceScore> _sentences(int count, {double score = 0.3}) => [
  for (var i = 0; i < count; i++)
    SentenceScore(
      index: i,
      text:
          'This is a complete and sufficiently long analysable sentence '
          'numbered $i for the purposes of this test.',
      aiProbability: score,
    ),
];

String _text(int words) => List.filled(words, 'alpha').join(' ');

DetectionResult _result({
  int words = 400,
  int sentenceCount = 10,
  List<double> engineProbabilities = const [0.30, 0.35, 0.32, 0.28],
  int availableCount = 4,
}) {
  final scores = <EngineScore>[];
  const ids = ['transformer', 'statistical', 'stylometry', 'adversarial'];
  for (var i = 0; i < engineProbabilities.length; i++) {
    scores.add(
      EngineScore(
        engineId: ids[i % ids.length],
        engineName: ids[i % ids.length],
        aiProbability: engineProbabilities[i],
        weight: 0.25,
        available: i < availableCount,
      ),
    );
  }
  return DetectionResult(
    id: 'a',
    analyzedAt: DateTime(2026, 8, 17),
    inputText: _text(words),
    aiProbability: 0.32,
    verdict: Verdict.fromProbability(0.32),
    engineScores: scores,
    sentences: _sentences(sentenceCount),
    availableEngineCount: availableCount,
    totalEngineCount: 4,
  );
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  group('棄權判斷', () {
    test('證據充足時不棄權', () {
      final r = _result();
      expect(r.abstention, AbstentionReason.none);
      expect(r.shouldAbstain, isFalse);
    });

    test('字數不足時棄權', () {
      final r = _result(words: 40);
      expect(r.abstention, AbstentionReason.tooFewWords);
    });

    test('可分析句數不足時棄權', () {
      final r = _result(sentenceCount: 3);
      expect(r.abstention, AbstentionReason.tooFewSentences);
    });

    test('參與引擎少於 2 個時棄權，且優先於其他理由回報', () {
      // 同時字數也不足，但引擎不足才是該先解決的根本問題
      final r = _result(words: 40, availableCount: 1);
      expect(r.abstention, AbstentionReason.tooFewEngines);
    });

    test('引擎分歧超過門檻時棄權', () {
      final r = _result(engineProbabilities: const [0.95, 0.05, 0.5, 0.4]);
      expect(r.abstention, AbstentionReason.enginesConflict);
    });

    test('分歧恰在門檻上不棄權（邊界不過度觸發）', () {
      // 全距 0.60，未超過 maxEngineSpread
      final r = _result(engineProbabilities: const [0.80, 0.20, 0.5, 0.4]);
      expect(r.abstention, AbstentionReason.none);
    });
  });

  group('遙測總結與報告一致', () {
    test('證據限制時仍給最可能方向，並明確降低信心', () {
      final r = _result(sentenceCount: 2);
      final lines = buildTelemetrySummary(r, l10n);
      final text = lines.join(' ');

      expect(text, contains('Currently leans human, near the boundary'));
      expect(text, contains('AI evidence index 49/100'));
      expect(text, contains('Low confidence'));
      expect(text, contains('analysable sentence'));
      expect(text, contains('screening result, not proof'));
      expect(text, isNot(contains('Not enough evidence to judge')));
    });

    test('未棄權時維持原本的完整總結', () {
      final lines = buildTelemetrySummary(_result(), l10n);
      final text = lines.join(' ');

      expect(text, contains('After weighting the available evidence'));
      expect(text, isNot(contains('Not enough evidence')));
    });
  });

  group('字數計算', () {
    test('CJK 逐字計、拉丁語系以詞計', () {
      final r = DetectionResult(
        id: 'w',
        analyzedAt: DateTime(2026, 8, 17),
        inputText: '這是一份報告 hello world',
        aiProbability: 0.1,
        verdict: Verdict.human,
        engineScores: const [],
        sentences: const [],
      );
      expect(r.wordCount, 8); // 6 個中文字 + 2 個英文詞
    });
  });
}
