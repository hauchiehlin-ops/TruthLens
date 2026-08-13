import '../utils/ocr_post_processor.dart';

/// Normalizes the response formats supported by the companion OCR server.
///
/// Current servers return a top-level list of blocks, while older/custom
/// servers may wrap the same blocks in `results` or return a plain `text`
/// field. Keeping this parser platform-neutral makes the protocol testable.
class LocalOcrResponse {
  final bool supportedFormat;
  final String text;
  final String? error;

  const LocalOcrResponse({
    required this.supportedFormat,
    this.text = '',
    this.error,
  });

  bool get hasText => text.trim().isNotEmpty;
}

LocalOcrResponse parseLocalOcrResponse(Object? payload) {
  if (payload is List) {
    return LocalOcrResponse(supportedFormat: true, text: _joinBlocks(payload));
  }
  if (payload is Map) {
    final error = payload['error'];
    if (error != null && '$error'.trim().isNotEmpty) {
      return LocalOcrResponse(supportedFormat: true, error: '$error'.trim());
    }
    final results = payload['results'];
    if (results is List) {
      return LocalOcrResponse(
        supportedFormat: true,
        text: _joinBlocks(results),
      );
    }
    final text = payload['text'];
    if (text is String) {
      return LocalOcrResponse(
        supportedFormat: true,
        text: OcrPostProcessor.clean(text),
      );
    }
  }
  return const LocalOcrResponse(supportedFormat: false);
}

String _joinBlocks(List<dynamic> blocks) => OcrPostProcessor.clean(
  blocks
      .map((block) {
        if (block is String) return block;
        if (block is Map) return block['text']?.toString() ?? '';
        return '';
      })
      .where((text) => text.trim().isNotEmpty)
      .join('\n'),
);
