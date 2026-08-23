/// 分析當下凍結的本地共形校準結果。
library;

class CalibrationEvidence {
  final double pValue;
  final int percentile;
  final int calibrationSize;
  final double alpha;
  final bool hasEnoughSamples;
  final bool contextMatched;
  final String analysisSignature;
  final String language;
  final String domain;
  final String lengthBucket;

  const CalibrationEvidence({
    required this.pValue,
    required this.percentile,
    required this.calibrationSize,
    required this.alpha,
    required this.hasEnoughSamples,
    required this.contextMatched,
    required this.analysisSignature,
    required this.language,
    required this.domain,
    required this.lengthBucket,
  });

  static const unavailable = CalibrationEvidence(
    pValue: 1,
    percentile: 0,
    calibrationSize: 0,
    alpha: 0.05,
    hasEnoughSamples: false,
    contextMatched: false,
    analysisSignature: '',
    language: 'und',
    domain: 'unknown',
    lengthBucket: 'unknown',
  );

  bool get isApplicable => contextMatched && hasEnoughSamples;
  bool get isFlagged => isApplicable && pValue <= alpha;
}
