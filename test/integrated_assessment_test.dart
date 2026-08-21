import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/core/services/citation_evidence.dart';
import 'package:truthlens/core/services/document_provenance.dart';
import 'package:truthlens/core/services/integrated_assessment.dart';
import 'package:truthlens/core/services/writing_session.dart';

DetectionResult _result({
  double textScore = 0.13,
  bool enginesHaveEvidence = false,
  WritingSession writing = WritingSession.empty,
  DocumentProvenance provenance = DocumentProvenance.none,
}) => DetectionResult(
  id: 'integrated',
  analyzedAt: DateTime(2026, 8, 21),
  inputText: List.filled(180, 'word').join(' '),
  aiProbability: textScore,
  verdict: Verdict.fromProbability(textScore),
  writingSession: writing,
  provenance: provenance,
  engineScores: [
    EngineScore(
      engineId: 'transformer',
      engineName: 'Transformer',
      aiProbability: textScore,
      weight: 0.4,
      hasEvidence: enginesHaveEvidence,
    ),
    EngineScore(
      engineId: 'statistical',
      engineName: 'Statistical',
      aiProbability: textScore,
      weight: 0.25,
      hasEvidence: enginesHaveEvidence,
    ),
  ],
  sentences: [
    for (var i = 0; i < 8; i++)
      SentenceScore(
        index: i,
        text: 'This is a complete and sufficiently long sentence number $i.',
        aiProbability: textScore,
      ),
  ],
);

void main() {
  test('全引擎沉默仍給最可能方向，但把 13% 拉回低信心中性附近', () {
    final assessment = IntegratedAssessment.assess(_result());

    expect(assessment.direction, IntegratedDirection.likelyHuman);
    expect(assessment.aiLikelihood, greaterThan(0.40));
    expect(assessment.aiLikelihood, lessThan(0.50));
    expect(assessment.confidence, IntegratedConfidence.low);
    expect(assessment.textReliability, 0.12);
  });

  test('整段貼上、可疑來源與查無引用可推翻偏低文字分數', () {
    const writing = WritingSession(
      events: [
        InputEvent(kind: InputEventKind.paste, characters: 1800, elapsedMs: 0),
      ],
    );
    const provenance = DocumentProvenance(
      sourceFormat: 'docx',
      editingDuration: Duration.zero,
      revisionCount: 1,
      signals: [
        ProvenanceSignal(
          kind: ProvenanceSignalKind.negligibleEditingTime,
          severity: ProvenanceSeverity.strong,
        ),
        ProvenanceSignal(
          kind: ProvenanceSignalKind.implausibleTypingSpeed,
          severity: ProvenanceSeverity.strong,
        ),
      ],
    );
    final assessment = IntegratedAssessment.assess(
      _result(writing: writing, provenance: provenance),
      citations: const CitationEvidence(total: 10, verified: 5, notFound: 5),
    );

    expect(assessment.direction, IntegratedDirection.likelyAi);
    expect(assessment.aiLikelihood, greaterThan(0.75));
    expect(assessment.confidence, isNot(IntegratedConfidence.low));
  });

  test('受控逐步寫作與完整編輯歷程可推翻偏 AI 的文字模型', () {
    const writing = WritingSession(
      events: [
        InputEvent(kind: InputEventKind.typing, characters: 1000, elapsedMs: 0),
        InputEvent(kind: InputEventKind.deletion, characters: 30, elapsedMs: 1),
      ],
    );
    const provenance = DocumentProvenance(
      sourceFormat: 'docx',
      editingDuration: Duration(minutes: 90),
      revisionCount: 8,
      distinctBodyRsids: 12,
      application: 'Microsoft Word',
    );
    final assessment = IntegratedAssessment.assess(
      _result(
        textScore: 0.70,
        enginesHaveEvidence: true,
        writing: writing,
        provenance: provenance,
      ),
    );

    expect(assessment.direction, IntegratedDirection.likelyHuman);
    expect(assessment.aiLikelihood, lessThan(0.50));
    // 文字模型仍與兩條來源證據相反，因此方向可翻轉，但信心維持中等。
    expect(assessment.confidence, IntegratedConfidence.moderate);
  });
}
