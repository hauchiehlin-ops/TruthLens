/// 輸入文字的取得方式與可分析品質。
library;

enum InputAcquisitionMethod {
  directText,
  clipboard,
  structuredDocument,
  pdfTextLayer,
  ocr,
  legacyDocument,
  unknown,
}

class InputQualityEvidence {
  final InputAcquisitionMethod method;

  /// 文字抽取品質，0 代表不可用，1 代表未發現抽取失真。
  final double extractionQuality;

  /// 可供介面與匯出呈現的穩定代碼，不保存文件內容。
  final List<String> limitations;

  const InputQualityEvidence({
    required this.method,
    required this.extractionQuality,
    this.limitations = const [],
  });

  static const directText = InputQualityEvidence(
    method: InputAcquisitionMethod.directText,
    extractionQuality: 1,
  );

  static const clipboard = InputQualityEvidence(
    method: InputAcquisitionMethod.clipboard,
    extractionQuality: 1,
  );

  static const unknown = InputQualityEvidence(
    method: InputAcquisitionMethod.unknown,
    extractionQuality: 0.85,
    limitations: ['acquisition_method_unknown'],
  );

  double get confidenceCeiling => switch (extractionQuality) {
    >= 0.90 => 1.0,
    >= 0.75 => 0.85,
    >= 0.62 => 0.68,
    _ => 0.45,
  };
}
