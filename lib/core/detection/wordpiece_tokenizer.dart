import 'dart:convert';

import 'text_tokenizer.dart';

/// BERT WordPiece tokenizer（對應 bert-base-multilingual-cased）。
/// 實作標準 BERT 前處理：清理 → CJK 逐字分隔 → 空白切分 → 標點切分 → WordPiece。
/// 從 HuggingFace `tokenizer.json`（model.vocab）建構，行為與原生 tokenizer 一致。
class WordPieceTokenizer implements TextTokenizer {
  final Map<String, int> vocab;
  final bool lowercase;
  final int clsId;
  final int sepId;
  final int unkId;
  final int padId;
  static const int _maxCharsPerWord = 100;

  WordPieceTokenizer(
    this.vocab, {
    this.lowercase = false,
    this.clsId = 101,
    this.sepId = 102,
    this.unkId = 100,
    this.padId = 0,
  });

  factory WordPieceTokenizer.fromTokenizerJson(String jsonStr,
      {bool? lowercase}) {
    final d = jsonDecode(jsonStr) as Map<String, dynamic>;
    final rawVocab = (d['model'] as Map<String, dynamic>)['vocab'] as Map;
    final vocab = <String, int>{
      for (final e in rawVocab.entries) e.key as String: (e.value as num).toInt()
    };
    // 由 normalizer 推斷是否轉小寫（cased 模型為 false）
    final norm = d['normalizer'] as Map<String, dynamic>?;
    final lc = lowercase ?? (norm?['lowercase'] as bool? ?? false);
    return WordPieceTokenizer(
      vocab,
      lowercase: lc,
      clsId: vocab['[CLS]'] ?? 101,
      sepId: vocab['[SEP]'] ?? 102,
      unkId: vocab['[UNK]'] ?? 100,
      padId: vocab['[PAD]'] ?? 0,
    );
  }

  /// 編碼為 [CLS] ... [SEP]，超過 maxLen 截斷。
  @override
  Encoded encode(String text, {int maxLen = 192}) {
    final pieces = <int>[];
    for (final token in _basicTokenize(text)) {
      pieces.addAll(_wordpiece(token));
    }
    final limit = maxLen - 2; // 保留 CLS / SEP
    final content = pieces.length > limit ? pieces.sublist(0, limit) : pieces;
    final ids = <int>[clsId, ...content, sepId];
    return Encoded(ids, List.filled(ids.length, 1));
  }

  // ---- 基礎切分（BertNormalizer + BertPreTokenizer）----

  List<String> _basicTokenize(String text) {
    final cleaned = _cleanAndSpaceCjk(text);
    final tokens = <String>[];
    for (final chunk in cleaned.split(RegExp(r'\s+'))) {
      if (chunk.isEmpty) continue;
      final piece = lowercase ? chunk.toLowerCase() : chunk;
      tokens.addAll(_splitPunctuation(piece));
    }
    return tokens;
  }

  String _cleanAndSpaceCjk(String text) {
    final buf = StringBuffer();
    for (final rune in text.runes) {
      if (rune == 0 || rune == 0xFFFD || _isControl(rune)) continue;
      if (_isWhitespace(rune)) {
        buf.write(' ');
      } else if (_isCjk(rune)) {
        buf.write(' ');
        buf.writeCharCode(rune);
        buf.write(' ');
      } else {
        buf.writeCharCode(rune);
      }
    }
    return buf.toString();
  }

  List<String> _splitPunctuation(String token) {
    final out = <String>[];
    final sb = StringBuffer();
    for (final rune in token.runes) {
      if (_isPunct(rune)) {
        if (sb.isNotEmpty) {
          out.add(sb.toString());
          sb.clear();
        }
        out.add(String.fromCharCode(rune));
      } else {
        sb.writeCharCode(rune);
      }
    }
    if (sb.isNotEmpty) out.add(sb.toString());
    return out;
  }

  // ---- WordPiece（greedy longest-match）----

  List<int> _wordpiece(String token) {
    if (token.length > _maxCharsPerWord) return [unkId];
    final chars = token.runes.toList();
    final ids = <int>[];
    var start = 0;
    while (start < chars.length) {
      var end = chars.length;
      int? curId;
      while (start < end) {
        var sub = String.fromCharCodes(chars.sublist(start, end));
        if (start > 0) sub = '##$sub';
        final id = vocab[sub];
        if (id != null) {
          curId = id;
          break;
        }
        end--;
      }
      if (curId == null) return [unkId]; // 整個 token 無法切分 → UNK
      ids.add(curId);
      start = end;
    }
    return ids;
  }

  // ---- 字元判定 ----

  bool _isWhitespace(int cp) =>
      cp == 0x20 || cp == 0x09 || cp == 0x0A || cp == 0x0D || _wsRe.hasMatch(String.fromCharCode(cp));
  static final _wsRe = RegExp(r'\s', unicode: true);

  bool _isControl(int cp) {
    if (cp == 0x09 || cp == 0x0A || cp == 0x0D) return false;
    return _ctrlRe.hasMatch(String.fromCharCode(cp));
  }

  static final _ctrlRe = RegExp(r'[\p{Cc}\p{Cf}]', unicode: true);

  bool _isPunct(int cp) {
    if ((cp >= 33 && cp <= 47) ||
        (cp >= 58 && cp <= 64) ||
        (cp >= 91 && cp <= 96) ||
        (cp >= 123 && cp <= 126)) {
      return true;
    }
    return _punctRe.hasMatch(String.fromCharCode(cp));
  }

  static final _punctRe = RegExp(r'\p{P}', unicode: true);

  bool _isCjk(int cp) =>
      (cp >= 0x4E00 && cp <= 0x9FFF) ||
      (cp >= 0x3400 && cp <= 0x4DBF) ||
      (cp >= 0x20000 && cp <= 0x2A6DF) ||
      (cp >= 0x2A700 && cp <= 0x2B73F) ||
      (cp >= 0x2B740 && cp <= 0x2B81F) ||
      (cp >= 0x2B820 && cp <= 0x2CEAF) ||
      (cp >= 0xF900 && cp <= 0xFAFF) ||
      (cp >= 0x2F800 && cp <= 0x2FA1F);
}
