import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/local_ocr_response_parser.dart';

void main() {
  test('parses current companion server top-level block list', () {
    final result = parseLocalOcrResponse([
      {'text': 'First line', 'confidence': 0.9},
      {'text': '第二行', 'confidence': 0.8},
    ]);

    expect(result.supportedFormat, isTrue);
    expect(result.text, 'First line\n第二行');
  });

  test('parses wrapped results and plain text compatibility formats', () {
    final wrapped = parseLocalOcrResponse({
      'results': [
        {'text': 'Wrapped line'},
      ],
    });
    final plain = parseLocalOcrResponse({'text': 'Plain text'});

    expect(wrapped.text, 'Wrapped line');
    expect(plain.text, 'Plain text');
  });

  test('accepts an empty block list as a valid OCR response', () {
    final result = parseLocalOcrResponse([]);

    expect(result.supportedFormat, isTrue);
    expect(result.hasText, isFalse);
  });

  test('preserves server errors and rejects unknown response formats', () {
    final serverError = parseLocalOcrResponse({'error': 'decode failed'});
    final unknown = parseLocalOcrResponse({'items': []});

    expect(serverError.error, 'decode failed');
    expect(unknown.supportedFormat, isFalse);
  });
}
