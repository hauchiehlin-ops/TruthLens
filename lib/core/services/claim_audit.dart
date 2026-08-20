/// 文件內可查核主張的「來源覆蓋」稽核。
///
/// 這裡不宣稱能在離線狀態判斷一句話是真是假；它做的是更窄、也可驗證的事：
/// 找出帶有數字、日期、研究歸因或明確比較的主張，檢查附近是否提供引用、DOI
/// 或網址。沒有來源不等於內容錯誤，更不等於 AI 撰寫，但它能指出應優先查核之處。
library;

import '../utils/text_stats.dart';

enum ClaimSignal { quantitative, attribution, comparison }

enum ClaimSourceRisk { unknown, low, medium, high }

class CheckableClaim {
  final int sentenceIndex;
  final String text;
  final Set<ClaimSignal> signals;
  final bool hasSourceAnchor;

  const CheckableClaim({
    required this.sentenceIndex,
    required this.text,
    required this.signals,
    required this.hasSourceAnchor,
  });
}

class ClaimAudit {
  final List<CheckableClaim> claims;

  const ClaimAudit({this.claims = const []});

  static const ClaimAudit none = ClaimAudit();
  static const int minimumClaimsForRisk = 3;

  int get total => claims.length;
  int get sourced => claims.where((claim) => claim.hasSourceAnchor).length;
  int get unsupported => total - sourced;
  double get unsupportedRatio => total == 0 ? 0 : unsupported / total;
  bool get hasData => claims.isNotEmpty;

  ClaimSourceRisk get risk {
    if (total < minimumClaimsForRisk) return ClaimSourceRisk.unknown;
    if (unsupportedRatio >= 0.60 && unsupported >= 3) {
      return ClaimSourceRisk.high;
    }
    if (unsupportedRatio >= 0.30 || unsupported >= 4) {
      return ClaimSourceRisk.medium;
    }
    return ClaimSourceRisk.low;
  }

  factory ClaimAudit.analyze(String rawText) {
    final body = _bodyBeforeBibliography(rawText);
    final sentences = PreprocessedText.from(body).sentences;
    final claims = <CheckableClaim>[];
    for (var i = 0; i < sentences.length; i++) {
      final sentence = sentences[i];
      final signals = <ClaimSignal>{};
      if (_quantitative.hasMatch(sentence)) {
        signals.add(ClaimSignal.quantitative);
      }
      if (_attribution.hasMatch(sentence)) {
        signals.add(ClaimSignal.attribution);
      }
      if (_comparison.hasMatch(sentence)) {
        signals.add(ClaimSignal.comparison);
      }
      if (signals.isEmpty) continue;

      // 只承認同一句的來源錨點。若把相鄰句也算進來，一個段尾引用就可能
      // 自動替整段所有數字背書，反而漏掉真正需要人工查核的主張。
      final hasAnchor =
          _directSource.hasMatch(sentence) ||
          _citationAnchor.hasMatch(sentence);
      claims.add(
        CheckableClaim(
          sentenceIndex: i,
          text: sentence,
          signals: signals,
          hasSourceAnchor: hasAnchor,
        ),
      );
    }
    return ClaimAudit(claims: claims);
  }

  static String _bodyBeforeBibliography(String text) {
    final heading = RegExp(
      r'\n\s*(?:references|bibliography|works cited|參考文獻|參考資料|引用文獻)\s*[:：]?\s*\n',
      caseSensitive: false,
    ).firstMatch(text);
    return heading == null ? text : text.substring(0, heading.start);
  }

  static final RegExp _quantitative = RegExp(
    r'(?:\b\d{1,4}(?:[.,]\d+)?\s*(?:%|percent|percentage|million|billion|萬|億|％|倍|人|件|年|月|日)\b|'
    r'\b(?:19|20)\d{2}\b|百分之[零〇一二三四五六七八九十百\d]+)',
    caseSensitive: false,
  );

  static final RegExp _attribution = RegExp(
    r'(?:研究|調查|報告|數據|文獻|學者|專家).{0,8}(?:指出|顯示|發現|證實|認為|估計)|'
    r'根據|依據|據.{0,12}(?:指出|報導)|'
    r'\b(?:according to|research|stud(?:y|ies)|survey|report|data|evidence|researchers?)\b.{0,30}'
    r'\b(?:show|shows|showed|find|finds|found|suggest|suggests|indicate|indicates|estimate|estimates)\b',
    caseSensitive: false,
  );

  static final RegExp _comparison = RegExp(
    r'(?:增加|減少|上升|下降|高於|低於|超過|少於|多於|最(?:高|低|大|小|快|慢))|'
    r'\b(?:increase[ds]?|decrease[ds]?|rose|fell|higher than|lower than|more than|less than|'
    r'largest|smallest|highest|lowest|fastest|slowest)\b',
    caseSensitive: false,
  );

  static final RegExp _directSource = RegExp(
    r'(?:https?://|www\.|doi\s*[:：]?\s*10\.\d{4,9}/|doi\.org/10\.)',
    caseSensitive: false,
  );

  static final RegExp _citationAnchor = RegExp(
    r'(?:\[(?:\d{1,3}(?:\s*[-,–]\s*\d{1,3})*)\]|'
    r'[（(][^()（）\n]{1,50}(?:19|20)\d{2}[a-z]?[^()（）\n]{0,20}[)）]|'
    r'(?:[A-Z][A-Za-z\-]+|[\u4e00-\u9fff]{2,4})\s*(?:等|et al\.)?\s*[,，]?\s*(?:19|20)\d{2})',
    caseSensitive: false,
  );
}
