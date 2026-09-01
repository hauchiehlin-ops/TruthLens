import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/core/services/citation_evidence.dart';
import 'package:omnitrace/core/services/claim_audit.dart';
import 'package:omnitrace/core/services/forensic_evidence.dart';
import 'package:omnitrace/core/services/writing_session.dart';

void main() {
  DetectionResult result({WritingSession writing = WritingSession.empty}) =>
      DetectionResult(
        id: 'matrix',
        analyzedAt: DateTime(2026, 8, 21),
        inputText: List.filled(140, 'word').join(' '),
        aiProbability: 0.13,
        verdict: Verdict.human,
        writingSession: writing,
        engineScores: const [
          EngineScore(
            engineId: 'transformer',
            engineName: 'Transformer',
            aiProbability: 0,
            weight: 0.4,
            hasEvidence: false,
          ),
          EngineScore(
            engineId: 'stylometry',
            engineName: 'Stylometry',
            aiProbability: 0,
            weight: 0.2,
            hasEvidence: false,
          ),
        ],
        sentences: [
          for (var i = 0; i < 6; i++)
            SentenceScore(
              index: i,
              text: 'This is a sufficiently complete sentence numbered $i.',
              aiProbability: 0,
            ),
        ],
      );

  test('全引擎沉默時文本軸為不確定，不是支持人類', () {
    final matrix = ForensicEvidenceMatrix.assess(result());
    final text = matrix.axes.first;
    expect(text.kind, EvidenceAxisKind.textTrace);
    expect(text.state, EvidenceAxisState.inconclusive);
    expect(matrix.totalAxisCount, 4);
    expect(matrix.textOnly, isTrue);
  });

  test('只有整段貼上的輸入方式不構成作者證據', () {
    final recorder = WritingSessionRecorder()..record(1800);
    final matrix = ForensicEvidenceMatrix.assess(
      result(writing: recorder.session),
    );
    final writing = matrix.axes.firstWhere(
      (axis) => axis.kind == EvidenceAxisKind.writingProcess,
    );
    expect(writing.state, EvidenceAxisState.unavailable);
    expect(writing.strength, EvidenceStrength.none);
  });

  test('查無大量引用可在低文本分數下形成另一條強證據', () {
    final matrix = ForensicEvidenceMatrix.assess(
      result(),
      citations: const CitationEvidence(total: 10, verified: 5, notFound: 5),
      claims: ClaimAudit.analyze(
        'A report found that output rose by 30 percent.',
      ),
    );
    final sources = matrix.axes.firstWhere(
      (axis) => axis.kind == EvidenceAxisKind.sourceIntegrity,
    );
    expect(sources.state, EvidenceAxisState.concern);
    expect(sources.strength, EvidenceStrength.strong);
    expect(matrix.hasStrongConcern, isTrue);
  });
}
