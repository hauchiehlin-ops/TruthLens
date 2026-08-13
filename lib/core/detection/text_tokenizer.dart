import 'dart:convert';

import 'bpe_tokenizer.dart';
import 'wordpiece_tokenizer.dart';

/// 編碼結果：input_ids 與 attention_mask（供 ONNX 模型輸入）
class Encoded {
  final List<int> inputIds;
  final List<int> attentionMask;
  const Encoded(this.inputIds, this.attentionMask);
}

/// A padded rectangular input suitable for one ONNX batch invocation.
class EncodedBatch {
  final List<List<int>> inputIds;
  final List<List<int>> attentionMasks;
  final int sequenceLength;

  const EncodedBatch(this.inputIds, this.attentionMasks, this.sequenceLength);

  int get batchSize => inputIds.length;
  List<int> get flatInputIds => inputIds.expand((row) => row).toList();
  List<int> get flatAttentionMasks =>
      attentionMasks.expand((row) => row).toList();
}

/// 文字 tokenizer 介面。各實作負責自己的特殊 token（BERT: [CLS]/[SEP]，RoBERTa: <s>/</s>）。
abstract class TextTokenizer {
  int get padId;

  Encoded encode(String text, {int maxLen = 192});
}

EncodedBatch encodeTextBatch(
  TextTokenizer tokenizer,
  List<String> texts, {
  int maxLen = 192,
}) {
  if (texts.isEmpty) {
    throw ArgumentError.value(texts, 'texts', 'Batch cannot be empty.');
  }
  final encoded = [
    for (final text in texts) tokenizer.encode(text, maxLen: maxLen),
  ];
  final sequenceLength = encoded
      .map((item) => item.inputIds.length)
      .reduce((a, b) => a > b ? a : b);
  final inputIds = <List<int>>[];
  final attentionMasks = <List<int>>[];
  for (final item in encoded) {
    inputIds.add([
      ...item.inputIds,
      ...List<int>.filled(
        sequenceLength - item.inputIds.length,
        tokenizer.padId,
      ),
    ]);
    attentionMasks.add([
      ...item.attentionMask,
      ...List<int>.filled(sequenceLength - item.attentionMask.length, 0),
    ]);
  }
  return EncodedBatch(inputIds, attentionMasks, sequenceLength);
}

/// 依模型類型從 HuggingFace tokenizer.json 建構對應 tokenizer。
///   bert-wordpiece → [WordPieceTokenizer]
///   roberta-bpe    → [BpeTokenizer]（byte-level BPE）
TextTokenizer buildTokenizer(String type, String tokenizerJson) {
  switch (type) {
    case 'none':
      return const NoneTokenizer();
    case 'roberta-bpe':
      return BpeTokenizer.fromTokenizerJson(tokenizerJson);
    case 'bert-wordpiece':
    default:
      return WordPieceTokenizer.fromTokenizerJson(tokenizerJson);
  }
}

class NoneTokenizer implements TextTokenizer {
  const NoneTokenizer();

  @override
  int get padId => 0;

  @override
  Encoded encode(String text, {int maxLen = 192}) {
    final codes = text.codeUnits.take(maxLen).toList();
    if (codes.isEmpty) {
      return const Encoded([0], [1]);
    }
    final mask = List<int>.filled(codes.length, 1);
    return Encoded(codes, mask);
  }
}

/// 從 tokenizer.json 讀出 model 節點（vocab / merges 等），共用工具。
Map<String, dynamic> tokenizerModel(String tokenizerJson) =>
    (jsonDecode(tokenizerJson) as Map<String, dynamic>)['model']
        as Map<String, dynamic>;
