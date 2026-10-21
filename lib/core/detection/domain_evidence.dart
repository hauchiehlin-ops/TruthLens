/// 模型在特定「文體 × 語言」上的實測紀錄（catalog 的 `domains` 欄位）。
///
/// 路由過去只看語言：同樣是中文，學術計畫書與網路問答會選到同一顆模型。
/// 這裡把 `training/validation/` 的實測結果帶進 App，讓路由能回答「哪一顆
/// 在這種文體上真的量過、量到多少」，而不是靠模型名稱猜。
///
/// 兩條刻意的界線：
/// 1. **誤報預算優先於召回**：真人誤報 Wilson 95% 上界超過 1% 的紀錄不得當作
///    排序依據——召回再高，也是用冤枉真人換來的。
/// 2. **樣本數不足只呈現、不排序**：單篇探針可以告訴使用者「這顆模型在這種
///    文體上漏過」，但一篇文件不能證明另一顆比較好。
library;

class DomainEvidence {
  /// 對應 `AnalysisDomain` 的名稱（academic／news／creative／general／codeHeavy）
  final String domain;
  final String language;
  final String corpus;

  /// 語料的語域細分（例如 assistant_qa、research_proposal），只供呈現
  final String register;
  final int aiDocuments;
  final int humanDocuments;
  final double recall;
  final double? fpr;
  final double? fprUpper95;

  /// 語料是否完全獨立於該模型的訓練與校準來源
  final bool independent;
  final String source;

  const DomainEvidence({
    required this.domain,
    required this.language,
    required this.corpus,
    required this.recall,
    this.register = '',
    this.aiDocuments = 0,
    this.humanDocuments = 0,
    this.fpr,
    this.fprUpper95,
    this.independent = false,
    this.source = '',
  });

  /// 誤報預算：與發布合約相同，真人誤報 Wilson 95% 上界 ≤ 1%
  static const double fprBudget = 0.01;

  /// 每類至少要這麼多份文件，才足以拿來比較模型
  static const int minDocumentsPerClass = 30;

  bool get withinFprBudget => fprUpper95 != null && fprUpper95! <= fprBudget;

  bool get hasEnoughSamples =>
      aiDocuments >= minDocumentsPerClass &&
      humanDocuments >= minDocumentsPerClass;

  /// 可作為路由排序依據：樣本足夠且守住誤報預算
  bool get usableForRanking => hasEnoughSamples && withinFprBudget;

  factory DomainEvidence.fromJson(Map<String, dynamic> j) => DomainEvidence(
    domain: j['domain'] as String,
    language: j['language'] as String,
    corpus: j['corpus'] as String? ?? '',
    register: j['register'] as String? ?? '',
    aiDocuments: (j['ai_documents'] as num?)?.toInt() ?? 0,
    humanDocuments: (j['human_documents'] as num?)?.toInt() ?? 0,
    recall: (j['recall'] as num).toDouble(),
    fpr: (j['fpr'] as num?)?.toDouble(),
    fprUpper95: (j['fpr_upper_95'] as num?)?.toDouble(),
    independent: j['independent'] as bool? ?? false,
    source: j['source'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'domain': domain,
    'language': language,
    'corpus': corpus,
    'register': register,
    'ai_documents': aiDocuments,
    'human_documents': humanDocuments,
    'recall': recall,
    'fpr': fpr,
    'fpr_upper_95': fprUpper95,
    'independent': independent,
    'source': source,
  };

  static List<DomainEvidence> listFromJson(Object? raw) => [
    for (final item in (raw as List?) ?? const [])
      if (item is Map<String, dynamic>) DomainEvidence.fromJson(item),
  ];

  @override
  bool operator ==(Object other) =>
      other is DomainEvidence &&
      other.domain == domain &&
      other.language == language &&
      other.corpus == corpus &&
      other.recall == recall &&
      other.fprUpper95 == fprUpper95 &&
      other.aiDocuments == aiDocuments &&
      other.humanDocuments == humanDocuments;

  @override
  int get hashCode => Object.hash(
    domain,
    language,
    corpus,
    recall,
    fprUpper95,
    aiDocuments,
    humanDocuments,
  );
}

/// 一顆模型在某「文體 × 語言」上的實測摘要，供路由排序與介面說明
class DomainFit {
  /// 排序所依據的實測紀錄；為空代表沒有可用實測
  final List<DomainEvidence> ranked;

  /// 該文體上的所有紀錄（含樣本不足或超出誤報預算者），供呈現
  final List<DomainEvidence> observed;

  /// [ranked] 是否來自目標文體本身；false 代表退回一般語料
  final bool matchesDomain;

  const DomainFit({
    this.ranked = const [],
    this.observed = const [],
    this.matchesDomain = false,
  });

  bool get hasRankingEvidence => ranked.isNotEmpty;

  /// 可排序紀錄的平均召回；沒有時為 -1，排在任何有實測的模型之後
  double get meanRecall => ranked.isEmpty
      ? -1
      : ranked.map((e) => e.recall).reduce((a, b) => a + b) / ranked.length;

  /// 從 [evidence] 取出 [domain] × [language] 的摘要：先找目標文體，
  /// 沒有可排序紀錄時退回 `general`。
  static DomainFit of(
    List<DomainEvidence> evidence,
    String domain,
    String language,
  ) {
    List<DomainEvidence> forDomain(String d) => [
      for (final e in evidence)
        if (e.domain == d && e.language == language) e,
    ];
    final observed = forDomain(domain);
    final rankedHere = observed.where((e) => e.usableForRanking).toList();
    if (rankedHere.isNotEmpty || domain == 'general') {
      return DomainFit(
        ranked: rankedHere,
        observed: observed,
        matchesDomain: rankedHere.isNotEmpty,
      );
    }
    final general = forDomain(
      'general',
    ).where((e) => e.usableForRanking).toList();
    return DomainFit(ranked: general, observed: observed);
  }
}
