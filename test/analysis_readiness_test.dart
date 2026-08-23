import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/models/input_quality.dart';
import 'package:truthlens/core/services/analysis_readiness.dart';

const _longText =
    'This first sentence establishes a concrete question for the analysis. '
    'The second sentence adds enough detail to make the document measurable. '
    'A third sentence varies the structure and presents another observation. '
    'The fourth sentence explains why evidence coverage matters for confidence. '
    'A fifth sentence records a limitation rather than hiding it from the reader. '
    'The sixth sentence closes the example with sufficient words and segments. '
    'Additional context is repeated carefully so that the input exceeds the minimum length. '
    'Each observation remains independently readable and contributes useful material. '
    'The resulting passage is long enough to test readiness without predicting authorship. '
    'No statement in this fixture should itself be interpreted as an AI signal.';

void main() {
  test('同條件基準與核心模型齊備時可預告高信心上限', () {
    final readiness = AnalysisReadiness.assess(
      text: _longText,
      inputQuality: InputQualityEvidence.directText,
      coreModelInstalled: true,
      enabledEngineCount: 4,
      matchingBaselineSamples: 19,
      requiredBaselineSamples: 19,
    );

    expect(readiness.ceiling, ReadinessLevel.high);
    expect(readiness.limitations, isEmpty);
  });

  test('OCR 品質不足時信心上限降為低且原因可稽核', () {
    final readiness = AnalysisReadiness.assess(
      text: _longText,
      inputQuality: const InputQualityEvidence(
        method: InputAcquisitionMethod.ocr,
        extractionQuality: 0.60,
      ),
      coreModelInstalled: true,
      enabledEngineCount: 4,
      matchingBaselineSamples: 19,
      requiredBaselineSamples: 19,
    );

    expect(readiness.ceiling, ReadinessLevel.low);
    expect(
      readiness.limitations,
      contains(ReadinessLimitation.lowExtractionQuality),
    );
  });

  test('只有本地基準不足時上限為中，不假裝已外部校準', () {
    final readiness = AnalysisReadiness.assess(
      text: _longText,
      inputQuality: InputQualityEvidence.directText,
      coreModelInstalled: true,
      enabledEngineCount: 4,
      matchingBaselineSamples: 0,
      requiredBaselineSamples: 19,
    );

    expect(readiness.ceiling, ReadinessLevel.moderate);
    expect(
      readiness.limitations,
      contains(ReadinessLimitation.localBaselineMissing),
    );
  });
}
