import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:omnitrace/core/detection/engines/statistical_engine.dart';
import 'package:omnitrace/core/detection/engines/stylometry_engine.dart';
import 'package:omnitrace/core/detection/pan25_tfidf_scorer.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/core/services/integrated_assessment.dart';
import 'package:omnitrace/core/utils/text_stats.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

const geminiExcerpt =
    '# Navigating the Crucible: The Shifting Sands of East Asian Geopolitics in the 21st Century '
    'East Asia, a region characterized by its rapid economic growth, dense populations, and complex historical narratives, '
    'has indisputably become the demographic, technological, and economic center of gravity of the modern world. '
    'However, beneath the surface of this economic miracle lies a fragile, volatile, and highly armed geopolitical landscape. '
    'As we progress deeper into the 21st century, the geopolitical dynamics of East Asia are undergoing a profound transformation, '
    'shifting from a post-Cold War era defined by unquestioned United States hegemony. '
    'At the heart of this structural transformation is the systemic rivalry between the United States and the People\'s Republic of China, '
    'a competition that permeates every facet of regional diplomacy, military planning, trade, and technological development.';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Dart scorer reproduces the official PAN 2025 baseline decision',
    () async {
      Pan25TfidfScorer.resetForTesting();
      final scorer = await Pan25TfidfScorer.load();

      expect(scorer.score(geminiExcerpt), closeTo(0.79900766, 1e-6));
    },
  );

  test('known human academic fixture stays on the human side', () async {
    final scorer = await Pan25TfidfScorer.load();
    final human = await File('test/fixtures/ijbc_paper.txt').readAsString();

    expect(scorer.score(human), lessThan(0.40));
  });

  test(
    'Gemini excerpt forms two independent AI directions end to end',
    () async {
      final l10n = lookupAppLocalizations(const Locale('en'));
      final text = PreprocessedText.from(geminiExcerpt);
      final scores = [
        await StatisticalEngine().analyze(text, l10n),
        await StylometryEngine().analyze(text, l10n),
      ];
      final result = DetectionResult(
        id: 'gemini-regression',
        analyzedAt: DateTime(2026, 8, 23),
        inputText: geminiExcerpt,
        aiProbability: 0.5,
        verdict: Verdict.mixed,
        engineScores: scores,
        sentences: const [],
      );
      final assessment = IntegratedAssessment.assess(result);

      expect(scores.where((score) => score.votes), hasLength(2));
      expect(assessment.independentEvidenceFamilies, 2);
      expect(assessment.passesAiEvidenceGate, isTrue);
      expect(assessment.direction, IntegratedDirection.likelyAi);
      expect(assessment.evidenceIndex, greaterThanOrEqualTo(70));
      expect(assessment.pointEstimateAvailable, isTrue);
      expect(assessment.confidence, IntegratedConfidence.moderate);
    },
  );
}
