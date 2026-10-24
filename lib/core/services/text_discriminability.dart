/// 文字引擎在「這份文件」上是否有判別力。
///
/// 一排「已執行，無強訊號」很容易被讀成「文字看起來像人寫的」，但那常常只代表
/// 偵測模型沒見過這種文件：實測一份 Claude 撰寫的繁中研究計畫書，分類器逐句平均
/// 0.054、字元指紋 0.001、困惑度落在門檻外——四個引擎都不是在說「人寫的」，而是
/// 「我分辨不了」。這裡把「分辨不了」的已知原因明確列出，讓報告能說清楚：
/// 本次沒有文字訊號，是因為工具對這類文件判別力不足，不是因為文件像人寫的。
///
/// 只依據分析當下寫入結果的資料（引擎特徵、適用性），不讀目前安裝的模型；
/// 從歷史紀錄打開舊報告時，結論必須與當時一致。
library;

import '../detection/analysis_profile.dart';
import '../detection/variant_router.dart';
import '../models/detection_result.dart';
import '../utils/language_id.dart';

/// 判別力不足的已知原因
enum DiscriminabilityGap {
  /// 這種文體有實測探針，而模型漏判了
  domainKnownMiss,

  /// 這種文體沒有足量實測，模型的表現未知
  domainUnmeasured,

  /// 分類器對這個語言未經驗證
  languageUnvalidated,

  /// 困惑度門檻以早期語料校準，對現代模型輸出判別力明顯下降
  perplexityOutdated,

  /// 有文字引擎不適用此語言或未安裝
  enginesUnavailable,
}

class TextDiscriminability {
  /// 所有文字引擎都沒有形成證據
  final bool textEnginesSilent;
  final List<DiscriminabilityGap> gaps;

  /// `AnalysisDomain.name`
  final String domain;

  /// 已知漏判的探針：總數與被偵測到的數量
  final int probeDocuments;
  final int probeDetected;

  /// 不適用或未安裝的文字引擎數
  final int unavailableEngines;

  /// 模型不支援本文語言的引擎角色（如 `adversarial`）。重新下載救不了。
  final List<String> languageUnsupportedRoles;

  /// 未安裝或載入失敗的引擎角色。可在模型管理重新下載。
  final List<String> notInstalledRoles;

  /// 偵測到的文件語言代碼；未判定時為 null
  final String? language;

  const TextDiscriminability({
    required this.textEnginesSilent,
    required this.gaps,
    required this.domain,
    this.probeDocuments = 0,
    this.probeDetected = 0,
    this.unavailableEngines = 0,
    this.languageUnsupportedRoles = const [],
    this.notInstalledRoles = const [],
    this.language,
  });

  /// 需要在報告上警示：文字引擎全部沉默，而且有已知原因說明它們為何分辨不了
  bool get isLimited => textEnginesSilent && gaps.isNotEmpty;

  static const _textRoles = [
    'transformer',
    'statistical',
    'stylometry',
    'adversarial',
  ];

  static TextDiscriminability assess(DetectionResult result) {
    final domain = AnalysisProfile.domainOf(result.inputText).name;
    final scores = {
      for (final score in result.engineScores)
        if (_textRoles.contains(_roleOf(score.engineId)))
          _roleOf(score.engineId): score,
    };
    final silent = !scores.values.any((score) => score.votes);
    final gaps = <DiscriminabilityGap>[];

    final transformer = scores['transformer'];
    var probeDocuments = 0;
    var probeDetected = 0;
    if (transformer != null && transformer.available) {
      final f = transformer.features;
      probeDocuments = (f['routing_probe_documents'] ?? 0).round();
      probeDetected = (f['routing_probe_detected'] ?? 0).round();
      if (probeDocuments > 0 && probeDetected < probeDocuments) {
        gaps.add(DiscriminabilityGap.domainKnownMiss);
      }
      final basis = f['routing_basis']?.round();
      final measuredHere = (f['routing_domain_matches'] ?? 0) >= 1;
      // 舊紀錄沒有路由特徵時不猜，只在確知「這種文體沒有足量實測」時才列出
      if (basis != null && domain != 'general' && !measuredHere) {
        gaps.add(DiscriminabilityGap.domainUnmeasured);
      }
      if (transformer.applicability != EngineApplicability.validated) {
        gaps.add(DiscriminabilityGap.languageUnvalidated);
      }
    }

    final statistical = scores['statistical'];
    if (statistical != null &&
        statistical.available &&
        !statistical.votes &&
        (statistical.features['perplexity_calibrated'] ?? 0) >= 1) {
      gaps.add(DiscriminabilityGap.perplexityOutdated);
    }

    // 「語言不支援」與「沒裝好」的解法完全不同，分開記錄
    final languageUnsupported = [
      for (final entry in scores.entries)
        if (entry.value.available &&
            entry.value.applicability == EngineApplicability.unsupported)
          entry.key,
    ];
    final notInstalled = [
      for (final entry in scores.entries)
        if (!entry.value.available) entry.key,
    ];
    final unavailable = languageUnsupported.length + notInstalled.length;
    if (unavailable > 0) gaps.add(DiscriminabilityGap.enginesUnavailable);

    final detected = detectLanguage(result.inputText);
    return TextDiscriminability(
      textEnginesSilent: silent,
      gaps: gaps,
      domain: domain,
      probeDocuments: probeDocuments,
      probeDetected: probeDetected,
      unavailableEngines: unavailable,
      languageUnsupportedRoles: languageUnsupported,
      notInstalledRoles: notInstalled,
      language: detected.isUndetermined ? null : detected.code,
    );
  }

  static String _roleOf(String engineId) {
    for (final role in _textRoles) {
      if (engineId == role || engineId.startsWith('${role}_')) return role;
    }
    return engineId;
  }

  /// 路由依據（供測試與除錯；報告只需要 [gaps]）
  static RoutingBasis? basisOf(EngineScore score) {
    final index = score.features['routing_basis']?.round();
    if (index == null || index < 0 || index >= RoutingBasis.values.length) {
      return null;
    }
    return RoutingBasis.values[index];
  }
}
