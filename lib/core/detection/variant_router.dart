/// 依文件語言在**已安裝的**模型變體之間選出最適用的一個。
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
///    不會去動儲存的 activeVariantId。使用者選的變體若適用就優先使用；
///    不適用而另有適用者時改用後者，並在理由中說明——設定不該被靜默改寫。
library;

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

/// 路由結果
class VariantChoice {
  /// 本次分析實際要用的變體；沒有任何已安裝變體時為 null
  final InstalledModel? variant;

  /// [variant] 對本文件語言的適用程度
  final LanguageFit fit;

  /// 是否偏離了使用者的手動選擇。為 true 時介面必須說明原因，
  /// 否則使用者會看到「使用中」的模型與報告所用的不一致。
  final bool overrodeUserChoice;

  const VariantChoice({
    required this.variant,
    required this.fit,
    this.overrodeUserChoice = false,
  });

  static const none = VariantChoice(
    variant: null,
    fit: LanguageFit.unsupported,
  );

  /// 這次的判定是否建立在已驗證的語言涵蓋之上。
  /// 為 false 時分數仍可呈現，但不該被當成同等強度的證據。
  bool get isValidated => fit == LanguageFit.validated;
}

/// 判斷單一變體對 [language] 的適用程度
LanguageFit fitFor(InstalledModel model, String language) {
  if (model.languages.isEmpty) return LanguageFit.unknown;
  if (model.validatesLanguage(language)) return LanguageFit.validated;
  if (model.plausiblySupports(language)) return LanguageFit.plausible;
  return LanguageFit.unsupported;
}

/// 在 [installed] 之中挑出最適合 [language] 的變體。
///
/// [userActiveVariantId] 為使用者手動指定的變體；適用程度相同時優先採用它，
/// 尊重使用者的選擇而不是每次分析都可能換一顆模型。
///
/// 語言為 null 或無法判定時直接回傳使用者的選擇——語言不明就沒有路由的依據，
/// 硬挑一顆等於用猜測取代使用者的決定。
VariantChoice chooseVariant({
  required List<InstalledModel> installed,
  required String? language,
  String? userActiveVariantId,
}) {
  if (installed.isEmpty) return VariantChoice.none;

  InstalledModel? userChoice;
  for (final m in installed) {
    if (m.variantId == userActiveVariantId) userChoice = m;
  }
  final fallback = userChoice ?? installed.first;

  if (language == null || language.isEmpty) {
    return VariantChoice(variant: fallback, fit: LanguageFit.unknown);
  }

  final userFit = userChoice == null
      ? LanguageFit.unsupported
      : fitFor(userChoice, language);

  // 使用者選的已經是最好的等級，不必換
  if (userChoice != null && userFit == LanguageFit.validated) {
    return VariantChoice(variant: userChoice, fit: userFit);
  }

  InstalledModel? best;
  var bestFit = LanguageFit.unsupported;
  for (final m in installed) {
    final fit = fitFor(m, language);
    if (best == null || fit.index < bestFit.index) {
      best = m;
      bestFit = fit;
    }
  }

  // 找不到比使用者選擇更好的，就維持使用者的選擇
  if (userChoice != null && bestFit.index >= userFit.index) {
    return VariantChoice(variant: userChoice, fit: userFit);
  }

  return VariantChoice(
    variant: best,
    fit: bestFit,
    overrodeUserChoice: userChoice != null && best != userChoice,
  );
}
