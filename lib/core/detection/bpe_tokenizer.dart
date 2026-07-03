import 'dart:convert';

import 'text_tokenizer.dart';

/// Byte-level BPE tokenizer（GPT-2 / RoBERTa 風格）。
/// 從 HuggingFace `tokenizer.json`（model.vocab + model.merges）建構，
/// 與原生 tokenizer 行為一致：ByteLevel 前處理 → BPE 合併 → <s> ... </s>。
class BpeTokenizer implements TextTokenizer {
  final Map<String, int> vocab;
  final Map<String, int> _bpeRanks; // "a b" -> rank
  final Map<int, String> _byteToChar;
  final int bosId;
  final int eosId;
  final int unkId;
  final Map<String, List<String>> _cache = {};

  // GPT-2 前處理正則
  static final _pat = RegExp(
    r"'s|'t|'re|'ve|'m|'ll|'d| ?\p{L}+| ?\p{N}+| ?[^\s\p{L}\p{N}]+|\s+(?!\S)|\s+",
    unicode: true,
  );

  BpeTokenizer({
    required this.vocab,
    required List<String> merges,
    this.bosId = 0,
    this.eosId = 2,
    this.unkId = 3,
  })  : _bpeRanks = {for (var i = 0; i < merges.length; i++) merges[i]: i},
        _byteToChar = _bytesToUnicode();

  factory BpeTokenizer.fromTokenizerJson(String jsonStr) {
    final model = tokenizerModel(jsonStr);
    final rawVocab = model['vocab'] as Map;
    final vocab = <String, int>{
      for (final e in rawVocab.entries) e.key as String: (e.value as num).toInt()
    };
    // merges 可能是 List<String>（"a b"）或 List<List<String>>（新格式）
    final rawMerges = model['merges'] as List;
    final merges = <String>[
      for (final m in rawMerges)
        m is String ? m : (m as List).join(' '),
    ];
    return BpeTokenizer(
      vocab: vocab,
      merges: merges,
      bosId: vocab['<s>'] ?? 0,
      eosId: vocab['</s>'] ?? 2,
      unkId: vocab['<unk>'] ?? 3,
    );
  }

  @override
  Encoded encode(String text, {int maxLen = 192}) {
    final ids = <int>[];
    for (final match in _pat.allMatches(text)) {
      final piece = match.group(0)!;
      // 將 pre-token 的 UTF-8 位元組映射為 byte-level 字元
      final mapped = StringBuffer();
      for (final b in utf8.encode(piece)) {
        mapped.write(_byteToChar[b]);
      }
      for (final tok in _bpe(mapped.toString())) {
        ids.add(vocab[tok] ?? unkId);
      }
    }
    final limit = maxLen - 2; // 保留 <s> / </s>
    final content = ids.length > limit ? ids.sublist(0, limit) : ids;
    final out = <int>[bosId, ...content, eosId];
    return Encoded(out, List.filled(out.length, 1));
  }

  // BPE：對一個 byte-level 字串反覆合併排名最前的相鄰對
  List<String> _bpe(String token) {
    final cached = _cache[token];
    if (cached != null) return cached;

    var word = token.split('');
    if (word.length < 2) {
      _cache[token] = word;
      return word;
    }

    while (true) {
      int bestRank = 1 << 30;
      int bestIdx = -1;
      for (var i = 0; i < word.length - 1; i++) {
        final rank = _bpeRanks['${word[i]} ${word[i + 1]}'];
        if (rank != null && rank < bestRank) {
          bestRank = rank;
          bestIdx = i;
        }
      }
      if (bestIdx < 0) break;
      word = [
        ...word.sublist(0, bestIdx),
        word[bestIdx] + word[bestIdx + 1],
        ...word.sublist(bestIdx + 2),
      ];
      if (word.length == 1) break;
    }
    _cache[token] = word;
    return word;
  }

  /// GPT-2 bytes_to_unicode：把 0-255 位元組映射為可逆的可列印 unicode 字元。
  static Map<int, String> _bytesToUnicode() {
    final bs = <int>[];
    for (var i = 0x21; i <= 0x7e; i++) {
      bs.add(i);
    }
    for (var i = 0xa1; i <= 0xac; i++) {
      bs.add(i);
    }
    for (var i = 0xae; i <= 0xff; i++) {
      bs.add(i);
    }
    final cs = List<int>.from(bs);
    var n = 0;
    for (var b = 0; b < 256; b++) {
      if (!bs.contains(b)) {
        bs.add(b);
        cs.add(256 + n);
        n++;
      }
    }
    return {for (var i = 0; i < bs.length; i++) bs[i]: String.fromCharCode(cs[i])};
  }
}
