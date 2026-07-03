import 'dart:convert';

import 'bpe_tokenizer.dart';
import 'wordpiece_tokenizer.dart';

/// 編碼結果：input_ids 與 attention_mask（供 ONNX 模型輸入）
class Encoded {
  final List<int> inputIds;
  final List<int> attentionMask;
  const Encoded(this.inputIds, this.attentionMask);
}

/// 文字 tokenizer 介面。各實作負責自己的特殊 token（BERT: [CLS]/[SEP]，RoBERTa: <s>/</s>）。
abstract class TextTokenizer {
  Encoded encode(String text, {int maxLen = 192});
}

/// 依模型類型從 HuggingFace tokenizer.json 建構對應 tokenizer。
///   bert-wordpiece → [WordPieceTokenizer]
///   roberta-bpe    → [BpeTokenizer]（byte-level BPE）
TextTokenizer buildTokenizer(String type, String tokenizerJson) {
  switch (type) {
    case 'roberta-bpe':
      return BpeTokenizer.fromTokenizerJson(tokenizerJson);
    case 'bert-wordpiece':
    default:
      return WordPieceTokenizer.fromTokenizerJson(tokenizerJson);
  }
}

/// 從 tokenizer.json 讀出 model 節點（vocab / merges 等），共用工具。
Map<String, dynamic> tokenizerModel(String tokenizerJson) =>
    (jsonDecode(tokenizerJson) as Map<String, dynamic>)['model']
        as Map<String, dynamic>;
