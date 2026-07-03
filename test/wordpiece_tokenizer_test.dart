import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/wordpiece_tokenizer.dart';

/// 以最小詞表驗證 WordPiece 演算法（CJK 逐字、標點切分、## 續接、貪婪最長匹配）。
/// 期望值取自真實 bert-base-multilingual-cased tokenizer 的輸出。
void main() {
  final vocab = <String, int>{
    '[PAD]': 0, '[UNK]': 100, '[CLS]': 101, '[SEP]': 102,
    // case: "Hello world, this is a test."
    'Hello': 31178, 'world': 11356, ',': 117, 'this': 10531,
    'is': 10124, 'a': 169, 'test': 15839, '.': 119,
    // case: 人工智慧正在改變世界
    '人': 2179, '工': 3584, '智': 4413, '慧': 3930, '正': 4791,
    '在': 3031, '改': 4282, '變': 7292, '世': 2087, '界': 5621,
    // case: "Undetectable paraphrasing"
    'Und': 41523, '##ete': 14766, '##cta': 24290, '##ble': 11203,
    'para': 10220, '##ph': 28088, '##rasi': 47393, '##ng': 10376,
    // case: "tokenization"
    'tok': 18436, '##eni': 18687, '##zation': 27048,
  };
  final tok = WordPieceTokenizer(vocab);

  test('英文含標點：與原生 tokenizer 一致', () {
    expect(tok.encode('Hello world, this is a test.').inputIds,
        [101, 31178, 11356, 117, 10531, 10124, 169, 15839, 119, 102]);
  });

  test('中文逐字切分：與原生 tokenizer 一致', () {
    expect(tok.encode('人工智慧正在改變世界').inputIds,
        [101, 2179, 3584, 4413, 3930, 4791, 3031, 4282, 7292, 2087, 5621, 102]);
  });

  test('WordPiece 續接（##）：與原生 tokenizer 一致', () {
    expect(tok.encode('Undetectable paraphrasing').inputIds,
        [101, 41523, 14766, 24290, 11203, 10220, 28088, 47393, 10376, 102]);
    expect(tok.encode('tokenization').inputIds,
        [101, 18436, 18687, 27048, 102]);
  });

  test('未知詞 → UNK', () {
    expect(tok.encode('zzqqxx').inputIds, [101, 100, 102]);
  });

  test('attention_mask 全為 1 且長度相符', () {
    final e = tok.encode('Hello world.');
    expect(e.attentionMask.length, e.inputIds.length);
    expect(e.attentionMask.every((m) => m == 1), isTrue);
  });

  test('截斷至 maxLen', () {
    final e = tok.encode('Hello ' * 300, maxLen: 16);
    expect(e.inputIds.length, 16);
    expect(e.inputIds.first, 101);
    expect(e.inputIds.last, 102);
  });
}
