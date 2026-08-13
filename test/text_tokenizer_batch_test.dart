import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/text_tokenizer.dart';

void main() {
  test('pads a sentence batch and masks padding tokens', () {
    const tokenizer = NoneTokenizer();

    final batch = encodeTextBatch(tokenizer, const ['ab', 'c']);

    expect(batch.batchSize, 2);
    expect(batch.sequenceLength, 2);
    expect(batch.inputIds, [
      [97, 98],
      [99, 0],
    ]);
    expect(batch.attentionMasks, [
      [1, 1],
      [1, 0],
    ]);
    expect(batch.flatInputIds, [97, 98, 99, 0]);
  });
}
