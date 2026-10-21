/// 依文件語言與文體在**已安裝的**模型變體之間選出最適用的一個。
///
/// 為什麼需要這層：同一個角色可以同時裝多個變體，而它們的語言適用性差很多。
/// 純英文的 `chatgpt-detector-roberta` 對中文輸入從未跨過強訊號閾值——
/// 40% 的權重長期空轉，而介面完全沒有告訴使用者這件事。
///
/// 兩個刻意的設計界線：
///
/// 1. **只在已安裝的變體之間選。** 語言要解析完文件才知道，那時候不可能
///    臨時去下載幾百 MB。缺適用模型時要誠實回報，不是假裝有。
/// 2. **不修改使用者的手動選擇。** 路由只決定「這次分析用哪顆」，
///    不會去動儲存的 activeVariantId。使用者鎖定的變體若適用就優先使用；
///    不適用而另有適用者時改用後者，並在理由中說明——設定不該被靜默改寫。
///
/// 排序依序為：語言適用度 → 目標文體的實測召回（必須守住 1% 誤報預算且樣本
/// 足夠）→ 一般語料的實測召回 → 安裝順序。沒有實測的文體不會被猜成「適用」，
/// 而是明說「此文體未驗證，依一般語料選用」。
library;

import 'domain_evidence.dart';
import 'model_manager_types.dart';

/// 變體對某語言的適用程度。順序即優先序。
enum LanguageFit {
  /// 已在該語言上實測驗證
  validated,

  /// 架構為多語言，但未在該語言上驗證
  plausible,

  /// 語言涵蓋範圍未知（舊版安裝紀錄沒有 languages 欄位）
  unknown,

  /// 明確不涵蓋該語言
  unsupported,
}

/// 這次為什麼選這顆，供報告與分析前預覽說明
enum RoutingBasis {
  /// 使用者鎖定且適用
  userPinned,

  /// 依目標文體的實測選出
  measuredDomain,

  /// 目標文體沒有可用實測，依一般語料的實測選出
  measuredGeneral,

  /// 沒有任何可用實測，只依語言涵蓋選出
  languageOnly,

  /// 文件語言無法判定，使用預設
  languageUnknown,

  /// 中英混合，改用多語變體
  mixedScripts,
}

/// 路由結果
class VariantChoice {
  /// 本次分析實際要用的變體；沒有任何已安裝變體時為 null
  final InstalledModel? variant;

  /// [variant] 對本文件語言的適用程度
  final LanguageFit fit;

  /// 是否偏離了使用者的手動選擇。為 true 時介面必須說明原因，
  /// 否則使用者會看到「使用中」的模型與報告所用的不一致。
  final bool overrodeUserChoice;

  final RoutingBasis basis;

  /// 路由時採用的文體名稱（`AnalysisDomain.name`）
  final String domain;

  /// [variant] 在此文體 × 語言上的實測摘要
  final DomainFit domainFit;

  const VariantChoice({
    required this.variant,
    required this.fit,
    this.overrodeUserChoice = false,
    this.basis = RoutingBasis.languageOnly,
    this.domain = 'general',
    this.domainFit = const DomainFit(),
  });

  static const none = VariantChoice(
    variant: null,
    fit: LanguageFit.unsupported,
  );

  /// 寫入引擎結果的路由紀錄。報告可能在之後從歷史紀錄打開，那時已安裝的
  /// 模型可能不同，因此判別力評估必須依賴分析當下記下的值。
  Map<String, double> get routingFeatures {
    final probes = [
      for (final e in domainFit.observed)
        if (!e.hasEnoughSamples) e,
    ];
    return {
      'routing_basis': basis.index.toDouble(),
      'routing_domain_matches': domainFit.matchesDomain ? 1 : 0,
      'routing_ranked_recall': domainFit.meanRecall,
      'routing_probe_documents': probes
          .fold<int>(0, (sum, e) => sum + e.aiDocuments)
          .toDouble(),
      'routing_probe_detected': probes.fold<double>(
        0,
        (sum, e) => sum + e.recall * e.aiDocuments,
      ),
    };
  }

  /// 這次的判定是否建立在已驗證的語言涵蓋之上。
  /// 為 false 時分數仍可呈現，但不該被當成同等強度的證據。
  bool get isValidated => fit == LanguageFit.validated;
}

/// 判斷單一變體對 [language] 的適用程度
LanguageFit fitFor(InstalledModel model, String language) {
  // 這顆模型曾在舊 catalog 被標成中文已驗證，但實測只適合早期 HC3：
  // 2026 現代中文壓力集 18 篇皆未跨門檻。舊安裝紀錄會保留當時的
  // languages，故不能只修 catalog，還要在路由層撤銷過時聲明。
  if (model.variantId == 'omnitrace-mbert-multilingual-int8' &&
      language == 'zh') {
    return model.languages.contains('multi')
        ? LanguageFit.plausible
        : LanguageFit.unsupported;
  }
  if (model.languages.isEmpty) return LanguageFit.unknown;
  if (model.validatesLanguage(language)) return LanguageFit.validated;
  if (model.plausiblySupports(language)) return LanguageFit.plausible;
  return LanguageFit.unsupported;
}

/// [a] 是否比 [b] 更適合（語言 → 文體實測 → 一般實測）；相同時回傳 false
bool _ranksAbove(
  ({LanguageFit fit, DomainFit domain}) a,
  ({LanguageFit fit, DomainFit domain}) b,
) {
  if (a.fit.index != b.fit.index) return a.fit.index < b.fit.index;
  if (a.domain.matchesDomain != b.domain.matchesDomain) {
    return a.domain.matchesDomain;
  }
  return a.domain.meanRecall > b.domain.meanRecall;
}

RoutingBasis _basisFor(DomainFit fit) => fit.matchesDomain
    ? RoutingBasis.measuredDomain
    : fit.hasRankingEvidence
    ? RoutingBasis.measuredGeneral
    : RoutingBasis.languageOnly;

/// 在 [installed] 之中挑出最適合 [language] × [domain] 的變體。
///
/// [userActiveVariantId] 為使用者**鎖定**的變體（自動模式傳 null）；適用程度
/// 不低於最佳者時優先採用它，尊重使用者的選擇。
///
/// [defaultVariantId] 只在語言不明時使用：語言不明就沒有路由依據，
/// 硬挑一顆等於用猜測取代預設。
VariantChoice chooseVariant({
  required List<InstalledModel> installed,
  required String? language,
  String domain = 'general',
  String? userActiveVariantId,
  String? defaultVariantId,
  bool mixedScripts = false,
}) {
  if (installed.isEmpty) return VariantChoice.none;

  // 中英混合文件：語言專用模型只涵蓋其中一半，拿它評分另一半等於用中文偵測器
  // 讀英文段落。多語變體兩邊都涵蓋，即使對單一語言的強度略遜，整份文件的
  // 判讀仍然比較可信。找不到多語變體時才退回一般路由。
  if (mixedScripts) {
    for (final m in installed) {
      if (m.languages.contains('multi')) {
        return VariantChoice(
          variant: m,
          fit: fitFor(m, language ?? ''),
          overrodeUserChoice:
              userActiveVariantId != null && m.variantId != userActiveVariantId,
          basis: RoutingBasis.mixedScripts,
          domain: domain,
          domainFit: DomainFit.of(m.domains, domain, language ?? ''),
        );
      }
    }
  }

  InstalledModel? userChoice;
  InstalledModel? defaultChoice;
  for (final m in installed) {
    if (m.variantId == userActiveVariantId) userChoice = m;
    if (m.variantId == defaultVariantId) defaultChoice = m;
  }

  if (language == null || language.isEmpty) {
    return VariantChoice(
      variant: userChoice ?? defaultChoice ?? installed.first,
      fit: LanguageFit.unknown,
      basis: userChoice != null
          ? RoutingBasis.userPinned
          : RoutingBasis.languageUnknown,
      domain: domain,
    );
  }

  ({LanguageFit fit, DomainFit domain}) rate(InstalledModel m) => (
    fit: fitFor(m, language),
    domain: DomainFit.of(m.domains, domain, language),
  );

  InstalledModel? best;
  ({LanguageFit fit, DomainFit domain})? bestRating;
  for (final m in installed) {
    final rating = rate(m);
    if (bestRating == null || _ranksAbove(rating, bestRating)) {
      best = m;
      bestRating = rating;
    }
  }

  // 鎖定的變體只要語言適用度不輸最佳者就保留——實測差異屬於建議，
  // 不足以推翻使用者明確的選擇；語言不適用才改選並說明。
  if (userChoice != null) {
    final userRating = rate(userChoice);
    if (userRating.fit.index <= bestRating!.fit.index) {
      return VariantChoice(
        variant: userChoice,
        fit: userRating.fit,
        basis: RoutingBasis.userPinned,
        domain: domain,
        domainFit: userRating.domain,
      );
    }
  }

  return VariantChoice(
    variant: best,
    fit: bestRating!.fit,
    overrodeUserChoice: userChoice != null && best != userChoice,
    basis: _basisFor(bestRating.domain),
    domain: domain,
    domainFit: bestRating.domain,
  );
}
