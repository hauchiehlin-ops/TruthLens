import '../../l10n/generated/app_localizations.dart';
import 'device_capabilities.dart';
import 'variant_router.dart';

/// 依變體 id 取得在地化的模型名稱。
///
/// catalog 的 `name` 欄位是寫死的單一語言字串，介面切到其他語系時仍會顯示原文
/// ——實測英文介面下模型清單整排是中文。但 catalog 是可遠端更新的，未來新增的
/// 變體不會有對應的 l10n 鍵，因此這裡採「已知 id 走翻譯、未知 id 回退 catalog
/// 名稱」的策略：既修好現有模型的語系，也不擋住新模型上架。
String localizedModelName(
  String variantId,
  String? catalogName,
  AppLocalizations l10n,
) => switch (variantId) {
  'omnitrace-mbert-multilingual-int8' => l10n.modelNameMbertMultilingual,
  'omnitrace-zh-detector-int8' => l10n.modelNameTruthlensZh,
  'aigc-detector-zhv3-int8' => l10n.modelNameAigcZhv3,
  'chatgpt-detector-roberta-onnx-int8' => l10n.modelNameRobertaEn,
  'qwen05b-ppl-int8' => l10n.modelNameQwenPpl,
  'distilgpt2-ppl-int8' => l10n.modelNameDistilgpt2Ppl,
  'omnitrace-adversarial-distil-int8' => l10n.modelNameAdversarial,
  'gemma-2-2b-it-q4km' => l10n.modelNameGemma2Llm,
  _ => catalogName ?? variantId,
};

/// 在地化的裝置摘要。
///
/// 原本有兩條各自寫死語言的路徑：`DeviceCapabilities.summary` 是中文
/// （「web · 10 核 · 16GB RAM」），模型管理頁另外自組一份英文
/// （「WEB · 10 CPU · 16 GB RAM · HIGH」）。兩者都不隨介面語系走。
String localizedDeviceSummary(
  DeviceCapabilities device,
  AppLocalizations l10n,
) {
  final ram = device.totalRamMb / 1024;
  return l10n.deviceCapabilitySummary(
    device.platform.toUpperCase(),
    device.processors,
    ram.toStringAsFixed(device.totalRamMb % 1024 == 0 ? 0 : 1),
    device.ramMeasured ? '' : l10n.deviceCapabilityEstimated,
    device.tier.name.toUpperCase(),
  );
}

/// 文體名稱（`AnalysisDomain.name`）的在地化標籤
String localizedDomainName(String domain, AppLocalizations l10n) =>
    switch (domain) {
      'academic' => l10n.analysisDomainAcademic,
      'news' => l10n.analysisDomainNews,
      'creative' => l10n.analysisDomainCreative,
      'codeHeavy' => l10n.analysisDomainCode,
      _ => l10n.analysisDomainGeneral,
    };

/// 語言代碼的在地化標籤；未建表的語言直接顯示代碼
String localizedLanguageName(String? code, AppLocalizations l10n) =>
    switch (code) {
      null || '' || 'und' => l10n.analysisPlanLanguageUnknown,
      'zh' => l10n.languageNameZh,
      'en' => l10n.languageNameEn,
      _ => code.toUpperCase(),
    };

/// 路由原因的白話說明，報告與分析前預覽共用同一份措辭
String routingBasisText(VariantChoice choice, AppLocalizations l10n) {
  final domain = localizedDomainName(choice.domain, l10n);
  final recall = (choice.domainFit.meanRecall * 100).round();
  return switch (choice.basis) {
    RoutingBasis.userPinned => l10n.routingBasisPinned,
    RoutingBasis.measuredDomain => l10n.routingBasisMeasuredDomain(
      domain,
      recall,
    ),
    RoutingBasis.measuredGeneral => l10n.routingBasisMeasuredGeneral(
      domain,
      recall,
    ),
    RoutingBasis.languageOnly => l10n.routingBasisLanguageOnly,
    RoutingBasis.languageUnknown => l10n.routingBasisLanguageUnknown,
    RoutingBasis.mixedScripts => l10n.routingBasisMixedScripts,
  };
}

/// 該文體上樣本不足的探針紀錄，供說明「漏過但不足以比較」
List<String> routingProbeNotes(VariantChoice choice, AppLocalizations l10n) => [
  for (final e in choice.domainFit.observed)
    if (!e.hasEnoughSamples)
      l10n.routingDomainProbe(
        localizedDomainName(e.domain, l10n),
        e.aiDocuments + e.humanDocuments,
        (e.recall * 100).round(),
      ),
];
