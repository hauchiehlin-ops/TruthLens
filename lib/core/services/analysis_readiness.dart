/// 分析前可達信心評估，只檢查輸入與工具覆蓋，不預測作者方向。
library;

import '../detection/analysis_profile.dart';
import '../models/input_quality.dart';

enum ReadinessLevel { low, moderate, high }

enum ReadinessLimitation {
  shortText,
  fewSentences,
  coreModelMissing,
  tooFewEngines,
  lowExtractionQuality,
  localBaselineMissing,
}

class AnalysisReadiness {
  final ReadinessLevel ceiling;
  final List<ReadinessLimitation> limitations;
  final AnalysisProfile profile;

  const AnalysisReadiness({
    required this.ceiling,
    required this.limitations,
    required this.profile,
  });

  factory AnalysisReadiness.assess({
    required String text,
    required InputQualityEvidence inputQuality,
    required bool coreModelInstalled,
    required int enabledEngineCount,
    required int matchingBaselineSamples,
    required int requiredBaselineSamples,
  }) {
    final profile = AnalysisProfile.fromText(text);
    final limitations = <ReadinessLimitation>[];
    if (profile.wordCount < 100) {
      limitations.add(ReadinessLimitation.shortText);
    }
    if (profile.sentenceCount < 5) {
      limitations.add(ReadinessLimitation.fewSentences);
    }
    if (!coreModelInstalled) {
      limitations.add(ReadinessLimitation.coreModelMissing);
    }
    if (enabledEngineCount < 2) {
      limitations.add(ReadinessLimitation.tooFewEngines);
    }
    if (inputQuality.extractionQuality < 0.75) {
      limitations.add(ReadinessLimitation.lowExtractionQuality);
    }
    if (matchingBaselineSamples < requiredBaselineSamples) {
      limitations.add(ReadinessLimitation.localBaselineMissing);
    }

    final hardLimit = limitations.any(
      (item) =>
          item == ReadinessLimitation.shortText ||
          item == ReadinessLimitation.fewSentences ||
          item == ReadinessLimitation.coreModelMissing ||
          item == ReadinessLimitation.tooFewEngines ||
          item == ReadinessLimitation.lowExtractionQuality,
    );
    return AnalysisReadiness(
      ceiling: hardLimit
          ? ReadinessLevel.low
          : limitations.contains(ReadinessLimitation.localBaselineMissing)
          ? ReadinessLevel.moderate
          : ReadinessLevel.high,
      limitations: limitations,
      profile: profile,
    );
  }
}
