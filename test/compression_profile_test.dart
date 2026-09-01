import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/compression_profile.dart';

import 'pan25_tfidf_scorer_test.dart' show geminiExcerpt;

void main() {
  test('compression coherence is a one-sided AI screening signal', () {
    final profile = CompressionProfile.analyze(geminiExcerpt);

    expect(profile, isNotNull);
    expect(profile!.supportsAi, isTrue);
    expect(profile.aiRatio, greaterThan(0.62));
  });

  test('short input does not fabricate a compression direction', () {
    expect(CompressionProfile.analyze('A short human sentence.'), isNull);
  });
}
