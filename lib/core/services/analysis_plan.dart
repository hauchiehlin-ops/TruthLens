/// 分析前的「分析計畫」：偵測到的文件特徵，以及每個模型角色這次會用哪顆、
/// 為什麼、是否有更適合但尚未安裝的模型。
///
/// 使用者過去只能在模型管理頁按「設為使用中」，卻無從得知哪一顆適合手上的
/// 文件——而語言、文體、檔案格式各自會讓同一顆模型從有效變成空轉。這裡把
/// 路由在分析時才會做的決定提前算出來給使用者看，與引擎實際使用的是同一個
/// [chooseVariant]，不另寫一套規則，避免預覽與實際不一致。
///
/// 分析途中無法臨時下載數百 MB，因此「缺適用模型」只能在這裡事先提示。
library;

import '../detection/analysis_profile.dart';
import '../detection/model_catalog.dart';
import '../detection/model_manager.dart';
import '../detection/perplexity_calibration.dart';
import '../detection/variant_router.dart';
import '../models/input_quality.dart';
import '../utils/language_id.dart';
import '../utils/text_stats.dart';

class RolePlan {
  final String role;

  /// 本次會用的變體與原因；沒有任何已安裝變體時 `choice.variant` 為 null
  final VariantChoice choice;

  /// 使用者是否鎖定此角色的變體
  final bool manual;

  /// 比目前選擇更適合、但尚未安裝的 catalog 變體
  final ModelVariant? suggestion;

  const RolePlan({
    required this.role,
    required this.choice,
    required this.manual,
    this.suggestion,
  });

  bool get hasModel => choice.variant != null;
}

class AnalysisPlan {
  final DetectedLanguage language;
  final AnalysisDomain domain;

  /// 來源副檔名（小寫、無點）；貼上或直接輸入時為空字串
  final String sourceFormat;
  final int wordCount;
  final InputQualityEvidence inputQuality;
  final List<RolePlan> roles;

  const AnalysisPlan({
    required this.language,
    required this.domain,
    required this.sourceFormat,
    required this.wordCount,
    required this.inputQuality,
    required this.roles,
  });

  /// 有任何角色建議下載更適合的模型
  bool get hasSuggestions => roles.any((r) => r.suggestion != null);

  /// 需要使用者留意的角色：沒有模型、語言不適用，或有更適合的模型可下載
  bool get needsAttention => roles.any(
    (r) =>
        !r.hasModel ||
        r.choice.fit == LanguageFit.unsupported ||
        r.suggestion != null,
  );

  /// 走與引擎相同的路由，算出每個角色的選擇。[catalog] 為 null（離線且
  /// 讀不到打包 catalog）時仍可產生計畫，只是沒有下載建議。
  static AnalysisPlan build({
    required String text,
    required ModelManager modelManager,
    String sourceFormat = '',
    InputQualityEvidence inputQuality = InputQualityEvidence.directText,
    ModelCatalog? catalog,
    List<String> roles = const ['transformer', 'statistical', 'adversarial'],
  }) {
    final preprocessed = PreprocessedText.from(text);
    final language = preprocessed.language;
    final languageCode = language.isUndetermined ? null : language.code;
    final domain = AnalysisProfile.domainOf(text);
    return AnalysisPlan(
      language: language,
      domain: domain,
      sourceFormat: sourceFormat.toLowerCase(),
      wordCount: AnalysisProfile.fromText(text).wordCount,
      inputQuality: inputQuality,
      roles: [
        for (final role in roles)
          role == 'statistical'
              ? _statisticalPlan(modelManager, languageCode, domain, catalog)
              : _classifierPlan(
                  role,
                  modelManager,
                  languageCode,
                  domain,
                  language.mixedScripts,
                  catalog,
                ),
      ],
    );
  }

  static RolePlan _classifierPlan(
    String role,
    ModelManager manager,
    String? language,
    AnalysisDomain domain,
    bool mixedScripts,
    ModelCatalog? catalog,
  ) {
    final installed = manager.installedVariants(role);
    final manual = manager.isManualSelection(role);
    final active = manager.activeVariant(role)?.variantId;
    final choice = chooseVariant(
      installed: installed,
      language: language,
      domain: domain.name,
      mixedScripts: mixedScripts,
      userActiveVariantId: manual ? active : null,
      defaultVariantId: active,
    );

    ModelVariant? suggestion;
    if (catalog != null && language != null) {
      final installedIds = {for (final m in installed) m.variantId};
      final candidates = <String, ModelVariant>{
        for (final v
            in catalog.forRole(role)?.variants ?? const <ModelVariant>[])
          if (v.isDownloadable && !installedIds.contains(v.id)) v.id: v,
      };
      if (candidates.isNotEmpty) {
        // 把未安裝的候選放進同一個路由比一次：路由選中候選，代表它在語言或
        // 實測上確實勝過目前任何已安裝的模型。
        final ideal = chooseVariant(
          installed: [
            ...installed,
            for (final v in candidates.values) _asInstalled(role, v),
          ],
          language: language,
          domain: domain.name,
          mixedScripts: mixedScripts,
        );
        final idealId = ideal.variant?.variantId;
        // 不支援此語言的模型下載了也只會空轉，不建議
        final better =
            idealId != null &&
            candidates.containsKey(idealId) &&
            ideal.fit != LanguageFit.unsupported &&
            (choice.variant == null ||
                ideal.fit.index < choice.fit.index ||
                (ideal.fit == choice.fit &&
                    ideal.domainFit.meanRecall > choice.domainFit.meanRecall));
        if (better) suggestion = candidates[idealId];
      }
    }
    return RolePlan(
      role: role,
      choice: choice,
      manual: manual,
      suggestion: suggestion,
    );
  }

  /// 統計引擎的模型與語言綁定在困惑度校準表上，沿用引擎相同的挑選規則：
  /// 鎖定者優先，其次是第一個對此語言有可用門檻的已安裝變體。
  static RolePlan _statisticalPlan(
    ModelManager manager,
    String? language,
    AnalysisDomain domain,
    ModelCatalog? catalog,
  ) {
    const role = 'statistical';
    final installed = manager.installedVariants(role);
    final manual = manager.isManualSelection(role);
    final active = manager.activeVariant(role);
    InstalledModel? picked;
    var basis = RoutingBasis.languageOnly;
    var fit = LanguageFit.unknown;
    if (language == null) {
      picked = active;
      basis = RoutingBasis.languageUnknown;
    } else {
      final ordered = [
        if (manual && active != null) active,
        ...installed.where((m) => !(manual && m == active)),
      ];
      for (final m in ordered) {
        if (PerplexityCalibration.of(language, modelId: m.variantId) != null) {
          picked = m;
          fit = LanguageFit.validated;
          basis = manual && m == active
              ? RoutingBasis.userPinned
              : RoutingBasis.languageOnly;
          break;
        }
      }
      if (picked == null && installed.isNotEmpty) {
        picked = manual ? active : installed.first;
        fit = LanguageFit.unsupported;
      }
    }

    ModelVariant? suggestion;
    if (catalog != null && language != null && fit != LanguageFit.validated) {
      final installedIds = {for (final m in installed) m.variantId};
      for (final v
          in catalog.forRole(role)?.variants ?? const <ModelVariant>[]) {
        if (v.isDownloadable &&
            !installedIds.contains(v.id) &&
            PerplexityCalibration.of(language, modelId: v.id) != null) {
          suggestion = v;
          break;
        }
      }
    }
    return RolePlan(
      role: role,
      choice: VariantChoice(
        variant: picked,
        fit: picked == null ? LanguageFit.unsupported : fit,
        basis: basis,
        domain: domain.name,
      ),
      manual: manual,
      suggestion: suggestion,
    );
  }

  static InstalledModel _asInstalled(String role, ModelVariant v) =>
      InstalledModel(
        role: role,
        variantId: v.id,
        fileName: v.fileName(role),
        version: v.version,
        sizeBytes: v.sizeBytes,
        tokenizer: v.tokenizer,
        name: v.name,
        languages: v.languages,
        domains: v.domains,
      );
}
