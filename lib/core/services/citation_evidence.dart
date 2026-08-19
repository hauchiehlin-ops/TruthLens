/// 引用核實的證據摘要。
///
/// 為什麼獨立成一級證據，而不併入 AI 機率：
///
/// **這不是推論，是事實。** 一篇文獻存不存在，是可以查證的二元問題，
/// 不是「有多像 AI」的機率估計。捏造引用是 LLM 的**行為特徵**——
/// 不需要偵測文風就能抓到，而且模型再強也不會讓不存在的論文變成存在。
/// 這正是它不隨模型世代衰減的原因。
///
/// 併入機率會毀掉這個性質：一個 0.85 的分數無法告訴使用者「有三篇文獻查無此文」，
/// 而後者的證據力遠高於前者。與 [DocumentProvenance] 的處理方式一致。
library;

import 'bibliography_verifier.dart';

/// 引用證據的風險等級
enum CitationRisk {
  /// 沒有偵測到參考文獻，或數量太少不足以判斷
  unknown,

  /// 絕大多數引用可核實
  low,

  /// 有少量查無此文，或比例達到需要人工確認的程度
  medium,

  /// 查無此文的比例高到難以用「資料庫收錄不全」解釋
  high,
}

/// 一次分析的引用核實摘要
class CitationEvidence {
  /// 實際送出查核的文獻數
  final int total;

  /// 高可信度命中
  final int verified;

  /// 查到相近候選但欄位對不上，需人工確認
  final int uncertain;

  /// 各資料庫皆查無此文
  final int notFound;

  const CitationEvidence({
    this.total = 0,
    this.verified = 0,
    this.uncertain = 0,
    this.notFound = 0,
  });

  static const CitationEvidence none = CitationEvidence();

  /// 少於這個數量不下結論：一兩筆查無此文可能只是資料庫收錄不全，
  /// 而參考文獻極少的文件本來就沒有足夠的樣本可談比例。
  static const int minimumEntriesForRisk = 5;

  /// 查無此文的比例
  double get notFoundRatio => total == 0 ? 0 : notFound / total;

  bool get hasData => total > 0;

  /// 風險等級。
  ///
  /// 門檻刻意保守：公開資料庫對中文、專書、法律文獻的收錄本來就不完整，
  /// 把「查不到」直接等同於「捏造」會製造偽陽性。因此要求**比例**達標，
  /// 而不是看到一筆就示警。
  CitationRisk get risk {
    if (total < minimumEntriesForRisk) return CitationRisk.unknown;
    if (notFound == 0) return CitationRisk.low;
    if (notFoundRatio >= 0.30) return CitationRisk.high;
    if (notFoundRatio >= 0.15 || notFound >= 3) return CitationRisk.medium;
    return CitationRisk.low;
  }

  /// 是否構成「與低分判定矛盾」的反證。
  /// 捏造引用不隨模型世代衰減，因此它與文本分數衝突時，該被質疑的是分數。
  bool get contradictsHumanAuthorship =>
      risk == CitationRisk.medium || risk == CitationRisk.high;

  /// 由核實結果彙總
  factory CitationEvidence.fromChecks(List<BibliographyCheckResult> checks) {
    var verified = 0;
    var uncertain = 0;
    var notFound = 0;
    for (final check in checks) {
      switch (check.confidence) {
        case CitationMatchConfidence.high:
          // 期刊名對不上時不算乾淨命中——條目被拼湊過的可能性仍在
          if (check.journalNameMismatch) {
            uncertain++;
          } else {
            verified++;
          }
        case CitationMatchConfidence.uncertain:
          uncertain++;
        case CitationMatchConfidence.notFound:
          notFound++;
      }
    }
    return CitationEvidence(
      total: checks.length,
      verified: verified,
      uncertain: uncertain,
      notFound: notFound,
    );
  }
}
