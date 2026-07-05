import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/features/report/summary_card.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l10n = lookupAppLocalizations(const Locale('en'));

  DetectionResult sample() => DetectionResult(
        id: 'x',
        analyzedAt: DateTime(2026, 7, 4),
        inputText: 'a',
        aiProbability: 0.72,
        verdict: Verdict.likelyAi,
        engineScores: const [],
        sentences: const [
          SentenceScore(index: 0, text: '句一。', aiProbability: 0.8),
          SentenceScore(index: 1, text: '句二。', aiProbability: 0.3),
        ],
      );

  test('renderPng 產出有效 PNG 位元組', () async {
    final bytes = await SummaryCard.renderPng(sample(), l10n);
    expect(bytes.length, greaterThan(1000));
    // PNG 簽章 89 50 4E 47
    expect(bytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
  });
}
