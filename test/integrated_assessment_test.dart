import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/analysis_profile.dart';
import 'package:omnitrace/core/detection/evidence_fusion.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/core/models/calibration_evidence.dart';
import 'package:omnitrace/core/models/input_quality.dart';
import 'package:omnitrace/core/services/citation_evidence.dart';
import 'package:omnitrace/core/services/claim_audit.dart';
import 'package:omnitrace/core/services/document_provenance.dart';
import 'package:omnitrace/core/services/forensic_evidence.dart';
import 'package:omnitrace/core/services/integrated_assessment.dart';
import 'package:omnitrace/core/services/publication_evidence.dart';
import 'package:omnitrace/core/services/writing_session.dart';

DetectionResult _result({
  double textScore = 0.13,
  bool enginesHaveEvidence = false,
  bool assistantArtifact = false,
  WritingSession writing = WritingSession.empty,
  DocumentProvenance provenance = DocumentProvenance.none,
  CalibrationEvidence calibration = CalibrationEvidence.unavailable,
  InputQualityEvidence inputQuality = InputQualityEvidence.directText,
}) => DetectionResult(
  id: 'integrated',
  analyzedAt: DateTime(2026, 8, 21),
  inputText: List.filled(180, 'word').join(' '),
  aiProbability: textScore,
  verdict: Verdict.fromProbability(textScore),
  writingSession: writing,
  provenance: provenance,
  calibration: calibration,
  inputQuality: inputQuality,
  engineScores: [
    EngineScore(
      engineId: 'transformer',
      engineName: 'Transformer',
      aiProbability: assistantArtifact ? 0.95 : textScore,
      weight: 0.4,
      hasEvidence: enginesHaveEvidence || assistantArtifact,
      features: {if (assistantArtifact) 'assistant_response_artifacts': 2},
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
  test('沒有作者證據時不把 49 包裝成可用點估計', () {
    const assessment = IntegratedAssessment(
      aiLikelihood: 0.49,
      direction: IntegratedDirection.likelyHuman,
      confidence: IntegratedConfidence.low,
      confidenceScore: 0.24,
      textReliability: 0.18,
      textAuthorshipClass: TextAuthorshipClass.likelyHuman,
      analysisDomain: AnalysisDomain.general,
      independentEvidenceFamilies: 0,
      applicabilityCoverage: 0.25,
      evidenceCoverage: 0,
      passesAiEvidenceGate: false,
      hasAuthorshipEvidence: false,
      stabilityScore: 0,
      lowerBound: 0,
      upperBound: 1,
      confidenceCeiling: 0.45,
      stabilityAvailable: false,
      contributions: [],
    );

    expect(assessment.conclusion, IntegratedConclusion.insufficientEvidence);
    expect(assessment.pointEstimateAvailable, isFalse);
    expect(assessment.evidenceIndex, 49);
    expect(assessment.evidenceSufficiency, 24);
    expect(assessment.aiEscalationGap, 11);
  });

  test('證據全在 AI 側但不足時，不得反向報成「較可能不是 AI」', () {
    // 實測案例：一篇 100% ChatGPT 的英文文章，Transformer、風格、對抗三個引擎
    // 全部給出正向 AI 證據（11 句 AI 特徵、21 句改寫痕跡），加總 44/100 低於
    // 中點，舊邏輯直接判成「較可能不是 AI 生成」——把證據不足說成反向結論。
    //
    // 這三個引擎的中性點是 0，只在命中特徵時加分；沒有任何家族往人類側傾斜，
    // 也沒有寫作過程或來源證據，方向就只能是「沒有明確方向」。
    final assessment = IntegratedAssessment.assess(
      _result(textScore: 0.44, enginesHaveEvidence: true),
    );

    expect(assessment.aiLikelihood, lessThan(0.5));
    expect(
      assessment.direction,
      isNot(IntegratedDirection.likelyHuman),
      reason: '沒有人類側證據就不能給人類方向',
    );
    expect(assessment.conclusion, isNot(IntegratedConclusion.likelyHuman));
  });

  test('真的有人類側證據時，仍可給出人類方向', () {
    // 寫作過程紀錄是獨立於文字統計的人類側證據：一份在編輯器內逐步寫成的
    // 文件，其打字與修改節奏是任何語言模型都偽造不了的。
    final assessment = IntegratedAssessment.assess(
      _result(
        textScore: 0.30,
        enginesHaveEvidence: true,
        writing: const WritingSession(
          events: [
            InputEvent(
              kind: InputEventKind.typing,
              characters: 1200,
              elapsedMs: 900000,
            ),
            InputEvent(
              kind: InputEventKind.deletion,
              characters: 180,
              elapsedMs: 960000,
            ),
            InputEvent(
              kind: InputEventKind.typing,
              characters: 800,
              elapsedMs: 1500000,
            ),
          ],
        ),
      ),
    );

    expect(assessment.hasAuthorshipEvidence, isTrue);
  });

  test('全引擎沉默時不沿用 fallback 原始分數', () {
    final assessment = IntegratedAssessment.assess(_result());

    expect(assessment.direction, IntegratedDirection.balanced);
    expect(assessment.aiLikelihood, 0.50);
    expect(assessment.confidence, IntegratedConfidence.low);
    expect(assessment.textReliability, 0.18);
    expect(assessment.passesAiEvidenceGate, isFalse);
    expect(assessment.pointEstimateAvailable, isFalse);
  });

  test('真正沒有方向時保留中性狀態，不冒充真人結論', () {
    final assessment = IntegratedAssessment.assess(_result(textScore: 0.50));

    expect(assessment.aiLikelihood, 0.50);
    expect(assessment.direction, IntegratedDirection.balanced);
    expect(assessment.confidence, IntegratedConfidence.low);
    expect(assessment.passesAiEvidenceGate, isFalse);
    expect(assessment.hasAuthorshipEvidence, isFalse);
    expect(assessment.stabilityAvailable, isFalse);
  });

  test('未投票分類器原始值不再偽造第二個真人方向家族', () {
    final result = DetectionResult(
      id: 'directional-consensus',
      analyzedAt: DateTime(2026, 8, 23),
      inputText:
          '摘要。本文採用研究方法比較不同條件，並依據實驗結果討論限制。'
          '${List.filled(180, '研究資料顯示各組條件仍有明顯差異。').join()}',
      aiProbability: 0.50,
      verdict: Verdict.mixed,
      engineScores: const [
        EngineScore(
          engineId: 'transformer',
          engineName: 'Transformer',
          aiProbability: 0.03,
          weight: 0.40,
          hasEvidence: false,
          calibrationReliability: 0.82,
          features: {'raw_avg_prob': 0.23, 'analysis_chunk_count': 20},
        ),
        EngineScore(
          engineId: 'statistical',
          engineName: 'Statistical',
          aiProbability: 0.30,
          weight: 0.25,
          applicability: EngineApplicability.plausible,
          calibrationReliability: 0.52,
        ),
        EngineScore(
          engineId: 'stylometry',
          engineName: 'Stylometry',
          aiProbability: 0,
          weight: 0.20,
          hasEvidence: false,
        ),
        EngineScore(
          engineId: 'adversarial',
          engineName: 'Adversarial',
          aiProbability: 0,
          weight: 0.15,
          hasEvidence: false,
        ),
      ],
      sentences: const [],
    );

    final assessment = IntegratedAssessment.assess(result);
    expect(assessment.direction, IntegratedDirection.likelyHuman);
    expect(assessment.aiLikelihood, lessThan(0.50));
    expect(assessment.aiLikelihood, lessThan(0.45));
    expect(assessment.independentEvidenceFamilies, 1);
    expect(assessment.passesAiEvidenceGate, isFalse);
    expect(assessment.confidence, IntegratedConfidence.low);
  });

  test('已核實的生成式 AI 前出版品可提供真人作者方向', () {
    const publication = PublicationEvidence(
      status: PublicationEvidenceStatus.verified,
      doi: '10.1142/s0218127410026678',
      articleTitle:
          'Lowest stability boundary on flow of concentric rotating cylinders',
      publicationYear: 2010,
      titleSimilarity: 1,
    );
    final assessment = IntegratedAssessment.assess(
      _result(textScore: 0.50),
      publication: publication,
    );

    expect(assessment.direction, IntegratedDirection.likelyHuman);
    expect(assessment.aiLikelihood, lessThan(0.15));
    expect(assessment.confidence, IntegratedConfidence.moderate);
    expect(assessment.hasAuthorshipEvidence, isTrue);
  });

  test('整段貼上、可疑來源與查無引用不能把偏低文字訊號翻成 AI', () {
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

    expect(assessment.direction, IntegratedDirection.balanced);
    expect(assessment.aiLikelihood, 0.50);
    expect(assessment.pointEstimateAvailable, isFalse);
    expect(assessment.confidence, IntegratedConfidence.low);
  });

  test('學術文獻缺同句引註只進品質稽核，不得重現 13% 被推成 51%', () {
    final claims = ClaimAudit(
      claims: [
        for (var i = 0; i < 17; i++)
          CheckableClaim(
            sentenceIndex: i,
            text: 'Checkable academic claim $i.',
            signals: const {ClaimSignal.quantitative},
            hasSourceAnchor: i >= 15,
          ),
      ],
    );
    const citations = CitationEvidence(total: 18, verified: 18);

    final baseline = IntegratedAssessment.assess(_result());
    final assessment = IntegratedAssessment.assess(
      _result(),
      citations: citations,
      claims: claims,
    );

    expect(claims.risk, ClaimSourceRisk.high);
    expect(assessment.direction, IntegratedDirection.balanced);
    expect(assessment.pointEstimateAvailable, isFalse);
    expect(assessment.aiLikelihood, closeTo(baseline.aiLikelihood, 1e-9));
    expect(assessment.confidence, IntegratedConfidence.low);
    expect(
      assessment.contributions.any(
        (item) => item.kind == EvidenceAxisKind.sourceIntegrity,
      ),
      isFalse,
    );
  });

  test('兩個文字引擎一致跨越強訊號門檻時可判為 AI', () {
    final assessment = IntegratedAssessment.assess(
      _result(textScore: 0.85, enginesHaveEvidence: true),
    );

    expect(assessment.direction, IntegratedDirection.likelyAi);
    expect(assessment.aiLikelihood, greaterThan(0.80));
    expect(assessment.confidence, isNot(IntegratedConfidence.low));
    expect(assessment.passesAiEvidenceGate, isTrue);
  });

  test('單一引擎找到兩處聊天助理回覆殘留時可越過 AI 證據門檻', () {
    final assessment = IntegratedAssessment.assess(
      _result(textScore: 0.95, assistantArtifact: true),
    );

    expect(assessment.direction, IntegratedDirection.likelyAi);
    expect(assessment.aiLikelihood, greaterThan(0.85));
    expect(assessment.textReliability, 0.95);
    expect(assessment.passesAiEvidenceGate, isTrue);
  });

  test('單一助理慣用語只呈現弱 AI 偏向，不會偽造 49% 或通過證據門檻', () {
    final result = DetectionResult(
      id: 'single-assistant-quote',
      analyzedAt: DateTime(2026, 8, 22),
      inputText: List.filled(180, 'word').join(' '),
      aiProbability: 0.75,
      verdict: Verdict.likelyAi,
      engineScores: const [
        EngineScore(
          engineId: 'stylometry',
          engineName: 'Stylometry',
          aiProbability: 0.75,
          weight: 0.2,
          features: {'assistant_response_artifacts': 1},
        ),
      ],
      sentences: [
        for (var i = 0; i < 8; i++)
          SentenceScore(
            index: i,
            text: 'A complete sentence numbered $i for a quoted phrase test.',
            aiProbability: 0.75,
          ),
      ],
    );

    final assessment = IntegratedAssessment.assess(result);
    expect(assessment.direction, IntegratedDirection.likelyAi);
    expect(assessment.aiLikelihood, greaterThan(0.50));
    expect(assessment.aiLikelihood, isNot(0.49));
    expect(assessment.confidence, IntegratedConfidence.low);
    expect(assessment.passesAiEvidenceGate, isFalse);
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

  test('同條件且足量的共形異常可通過 AI 證據閘門但不重複加分', () {
    const calibration = CalibrationEvidence(
      pValue: 0.05,
      percentile: 100,
      calibrationSize: 19,
      alpha: 0.05,
      hasEnoughSamples: true,
      contextMatched: true,
      analysisSignature: 'fusion-v3|model-a',
      language: 'en',
      domain: 'general',
      lengthBucket: 'medium',
    );
    final withoutCalibration = IntegratedAssessment.assess(
      _result(textScore: 0.78, enginesHaveEvidence: false),
    );
    final calibrated = IntegratedAssessment.assess(
      _result(
        textScore: 0.78,
        enginesHaveEvidence: false,
        calibration: calibration,
      ),
    );

    expect(withoutCalibration.passesAiEvidenceGate, isFalse);
    expect(calibrated.passesAiEvidenceGate, isTrue);
    expect(calibrated.contributions, hasLength(1));
    expect(calibrated.aiLikelihood, lessThan(0.78));
    expect(
      calibrated.aiLikelihood,
      greaterThan(withoutCalibration.aiLikelihood),
      reason: '校準可確認原分數在本地真人基準中異常，但不得新增第二條勝算貢獻',
    );
  });

  test('低抽取品質限制判讀信心上限', () {
    final assessment = IntegratedAssessment.assess(
      _result(
        textScore: 0.90,
        enginesHaveEvidence: true,
        inputQuality: const InputQualityEvidence(
          method: InputAcquisitionMethod.ocr,
          extractionQuality: 0.60,
        ),
      ),
    );

    expect(assessment.confidenceCeiling, 0.45);
    expect(assessment.confidence, IntegratedConfidence.moderate);
  });
}
