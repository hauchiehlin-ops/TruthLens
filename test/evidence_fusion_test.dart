import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/analysis_profile.dart';
import 'package:omnitrace/core/detection/evidence_fusion.dart';
import 'package:omnitrace/core/models/detection_result.dart';

EngineScore _score(
  String id,
  double probability, {
  EvidenceFamily? family,
  bool evidence = true,
  EngineApplicability applicability = EngineApplicability.validated,
  List<double>? sentences,
  Map<String, double> features = const {},
}) => EngineScore(
  engineId: id,
  engineName: id,
  aiProbability: probability,
  weight: 0.4,
  hasEvidence: evidence,
  evidenceFamily: family ?? EvidenceFamily.unknown,
  applicability: applicability,
  sentenceScores: sentences,
  features: features,
);

const longGeneralText =
    'People revise a difficult argument in several stages before presenting it. '
    'The opening claim may change after evidence is checked and examples are compared. '
    'Some sentences remain short. Others grow longer because the writer needs to qualify an idea. '
    'A later paragraph may return to the first question from a different angle. '
    'This ordinary variation gives the document enough length for a stable local analysis. '
    'The conclusion then records what was learned without pretending that every uncertainty disappeared.';

void main() {
  test('同一家族的兩個高分分類器只算一份證據', () {
    final fusion = TextEvidenceFusion.evaluate(
      scores: [_score('transformer_a', 0.86), _score('transformer_b', 0.91)],
      inputText: longGeneralText,
    );

    expect(fusion.families, hasLength(1));
    expect(fusion.aiSupportingFamilies, 1);
    expect(fusion.passesAiEvidenceGate, isFalse);
    expect(fusion.probability, closeTo(0.885, 0.001));
    expect(fusion.probability, isNot(0.59));
    expect(fusion.authorshipClass, TextAuthorshipClass.likelyAiGenerated);
  });

  test('分類器與分布鑑識同向才形成跨家族 AI 共識', () {
    final fusion = TextEvidenceFusion.evaluate(
      scores: [_score('transformer', 0.84), _score('statistical', 0.79)],
      inputText: longGeneralText,
    );

    expect(fusion.aiSupportingFamilies, 2);
    expect(fusion.passesAiEvidenceGate, isTrue);
    expect(fusion.probability, greaterThan(0.75));
    expect(fusion.authorshipClass, TextAuthorshipClass.likelyAiGenerated);
  });

  test('跨家族分數以有效權重線性累積且可由家族分量重算', () {
    final fusion = TextEvidenceFusion.evaluate(
      scores: [_score('transformer', 0.82), _score('statistical', 0.28)],
      inputText: longGeneralText,
    );
    final expectedMass = fusion.families.fold<double>(
      0,
      (sum, family) => sum + family.probability * family.effectiveWeight,
    );
    final expectedWeight = fusion.families.fold<double>(
      0,
      (sum, family) => sum + family.effectiveWeight,
    );

    expect(fusion.families, hasLength(2));
    expect(fusion.weightedAiMass, closeTo(expectedMass, 1e-9));
    expect(fusion.activeFamilyWeight, closeTo(expectedWeight, 1e-9));
    expect(fusion.probability, closeTo(expectedMass / expectedWeight, 1e-9));
  });

  test('風格命中強度 35% 是弱 AI 佐證，不是 35% 的人類票', () {
    final fusion = TextEvidenceFusion.evaluate(
      scores: [_score('stylometry', 0.35)],
      inputText: longGeneralText,
    );

    expect(fusion.families.single.probability, greaterThan(0.5));
    expect(fusion.humanSupportingFamilies, 0);
  });

  test('不支援本次語言的模型完全退出融合', () {
    final fusion = TextEvidenceFusion.evaluate(
      scores: [
        _score(
          'transformer',
          0.99,
          applicability: EngineApplicability.unsupported,
        ),
      ],
      inputText: longGeneralText,
    );

    expect(fusion.families, isEmpty);
    expect(fusion.probability, 0.5);
    expect(fusion.passesAiEvidenceGate, isFalse);
    expect(fusion.stabilityAvailable, isFalse);
  });

  test('全引擎沉默時不以 fallback 句分數偽造穩定區間', () {
    final fusion = TextEvidenceFusion.evaluate(
      scores: [_score('transformer', 0, evidence: false)],
      inputText: longGeneralText,
      sentences: [
        for (var i = 0; i < 8; i++)
          SentenceScore(index: i, text: 'Sentence $i.', aiProbability: 0),
      ],
    );

    expect(fusion.stabilityAvailable, isFalse);
    expect(fusion.stabilitySegmentCount, 0);
    expect(fusion.lowerBound, 0);
    expect(fusion.upperBound, 1);
  });

  test('未投票分類器原始值不參與方向，只保留真正投票的統計訊號', () {
    final fusion = TextEvidenceFusion.evaluate(
      scores: [
        _score(
          'transformer',
          0.03,
          evidence: false,
          features: const {'raw_avg_prob': 0.23, 'analysis_chunk_count': 12},
        ),
        _score('statistical', 0.30),
        _score('stylometry', 0, evidence: false),
        _score('adversarial', 0, evidence: false),
      ],
      inputText: longGeneralText,
    );

    expect(fusion.families, hasLength(1));
    expect(fusion.probability, closeTo(0.30, 1e-9));
    expect(fusion.probability, isNot(0.5));
    expect(fusion.passesAiEvidenceGate, isFalse);
  });

  test('分類器真正中性且其他單向引擎沉默時仍維持中性', () {
    final fusion = TextEvidenceFusion.evaluate(
      scores: [
        _score(
          'transformer',
          0,
          evidence: false,
          features: const {'raw_avg_prob': 0.50},
        ),
        _score('stylometry', 0, evidence: false),
      ],
      inputText: longGeneralText,
    );

    expect(fusion.families, isEmpty);
    expect(fusion.probability, 0.5);
    expect(fusion.humanSupportingFamilies, 0);
  });

  test('AI 訊號集中於部分句子時標示人機混合', () {
    final windows = <double>[0.92, 0.88, 0.81, 0.12, 0.18, 0.20, 0.25, 0.30];
    final fusion = TextEvidenceFusion.evaluate(
      scores: [
        _score('transformer', 0.86, sentences: windows),
        _score('statistical', 0.78),
      ],
      inputText: longGeneralText,
    );

    expect(fusion.passesAiEvidenceGate, isTrue);
    expect(fusion.mixedAuthorship, isTrue);
    expect(fusion.authorshipClass, TextAuthorshipClass.likelyAiAssisted);
  });

  test('學術領域只降低脆弱家族可靠度，不自行改變方向', () {
    const academic =
        'Abstract. This study evaluates a calibrated method. Methodology and results are reported below. '
        'Prior work [1] established the baseline, while later research [2] examined the same question. '
        'Discussion. The measured result is compared with three published estimates. References. '
        'The evidence remains limited and the conclusion therefore requires additional testing.';
    final profile = AnalysisProfile.fromText(academic);
    final general = AnalysisProfile.fromText(longGeneralText);

    expect(profile.domain, AnalysisDomain.academic);
    expect(
      profile.domainReliability(EvidenceFamily.stylometric),
      lessThan(general.domainReliability(EvidenceFamily.stylometric)),
    );
  });

  test('分段結果一致時 bootstrap 區間較窄、穩定性較高', () {
    final stable = TextEvidenceFusion.evaluate(
      scores: [_score('transformer', 0.82, sentences: List.filled(12, 0.82))],
      inputText: longGeneralText,
    );
    final variable = TextEvidenceFusion.evaluate(
      scores: [
        _score(
          'transformer',
          0.55,
          sentences: [0.05, 0.95, 0.10, 0.90, 0.15, 0.85, 0.20, 0.80],
        ),
      ],
      inputText: longGeneralText,
    );

    expect(stable.upperBound - stable.lowerBound, lessThan(0.02));
    expect(stable.stabilityScore, greaterThan(variable.stabilityScore));
  });

  test('低品質文字抽取只降低可靠度，不竄改方向分數', () {
    final clean = TextEvidenceFusion.evaluate(
      scores: [_score('transformer', 0.84), _score('statistical', 0.79)],
      inputText: longGeneralText,
    );
    final noisy = TextEvidenceFusion.evaluate(
      scores: [_score('transformer', 0.84), _score('statistical', 0.79)],
      inputText: longGeneralText,
      extractionQuality: 0.62,
    );

    expect(noisy.probability, closeTo(clean.probability, 1e-9));
    expect(noisy.reliability, lessThan(clean.reliability));
  });
}
