/// 文件載體 AI 訊號核實引擎。
///
/// 與四個文字子模型（Transformer、統計、風格、對抗）完全獨立：它不讀文風，
/// 只讀**檔案本身**（DOCX／PDF／ODT／DOC 的結構與中繼資料）留下的 AI 訊號，
/// 並把結果整理成作者判讀可用的一項檢查因子。
///
/// 核心設計是「洗不洗都留痕」的雙向夾擊：
/// - **未洗滌**：對話服務的產物會原樣留在檔案裡（AI 產生器宣告、對話引用標記、
///   對話介面字型、AI 搜尋導流連結）→ [ArtifactTraceFamily.aiNative]
/// - **已洗滌**：抹除這些產物、偽造編輯歷程的工具是一欄一欄獨立改寫，欄位之間
///   的因果關係對不上（RSID 未登記、編輯時長超過檔案存在時間、Producer 格式錯誤）
///   → [ArtifactTraceFamily.concealment]
///
/// 證據力分級（與 [IntegratedAssessment] 的不對稱規則一致）：
/// - 作者特異性的原生痕跡（[ArtifactTraceReport.hasIdentityTrace]）足以單獨形成
///   AI 方向，與產生器宣告同級。
/// - 其餘原生痕跡與洗滌痕跡只**加強**既有方向，不單獨形成結論：洗滌證明的是
///   有人刻意隱匿，不證明作者是 AI。
/// - 洗滌痕跡另有否決權：編輯歷程一旦被偽造，就不能再當作「由人撰寫」的證據
///   （由 [DocumentProvenance.indicatesHumanAuthorship] 的「任何非 info 訊號即否決」
///   規則實現）。
/// - 寫作歷程異常（整段貼上、編輯時長過短）不具作者特異性，維持不推向 AI。
///
/// 限制：沒有任何痕跡不代表檔案未經處理——列印成 PDF、重新打字都能避開。
library;

import 'document_provenance.dart';

enum ArtifactTraceFamily {
  /// 未經洗滌、原樣留在檔案裡的 AI 對話服務產物
  aiNative,

  /// 抹除 AI 訊號或偽造編輯歷程留下的欄位矛盾
  concealment,

  /// 寫作歷程異常：說明內容不是在這份檔案裡打出來的，不說明作者是誰
  processAnomaly,

  /// 只供呈現、不計入判讀（如圖片的 C2PA 憑證）
  informational,
}

class ArtifactTrace {
  final ProvenanceSignal signal;
  final ArtifactTraceFamily family;

  /// 是否為作者特異性證據：只有 AI 服務會產生，可單獨形成 AI 方向
  final bool identity;

  const ArtifactTrace({
    required this.signal,
    required this.family,
    this.identity = false,
  });
}

class ArtifactTraceReport {
  final List<ArtifactTrace> traces;

  const ArtifactTraceReport(this.traces);

  static const ArtifactTraceReport none = ArtifactTraceReport([]);

  /// 作者特異性原生痕跡的對數勝算，與出版紀錄同級但方向相反
  static const double identityLogOdds = 2.20;

  /// 非作者特異性的原生痕跡（對話介面字型、AI 搜尋連結）
  static const double supportingNativeLogOdds = 0.60;

  /// 洗滌痕跡：強（邏輯上不可能）／顯著（統計上不尋常），合計有上限，
  /// 避免同一次洗滌的多個破綻被重複計算成壓倒性證據
  static const double strongConcealmentLogOdds = 0.90;
  static const double notableConcealmentLogOdds = 0.45;
  static const double concealmentCap = 1.20;

  /// 依訊號種類歸族。新增 [ProvenanceSignalKind] 時編譯器會強制在此表態。
  static ArtifactTraceFamily familyOf(
    ProvenanceSignalKind kind,
  ) => switch (kind) {
    ProvenanceSignalKind.aiGeneratorDeclared ||
    ProvenanceSignalKind.chatCitationArtifact ||
    ProvenanceSignalKind.chatInterfaceFont ||
    ProvenanceSignalKind.aiReferralLink => ArtifactTraceFamily.aiNative,
    ProvenanceSignalKind.generatorMismatch ||
    ProvenanceSignalKind.unregisteredRsids ||
    ProvenanceSignalKind.editingTimeExceedsLifetime ||
    ProvenanceSignalKind.sessionsExceedRevisions ||
    ProvenanceSignalKind.forgedPdfProducer => ArtifactTraceFamily.concealment,
    ProvenanceSignalKind.singleEditingSession ||
    ProvenanceSignalKind.implausibleTypingSpeed ||
    ProvenanceSignalKind.negligibleEditingTime ||
    ProvenanceSignalKind.fewRevisions ||
    ProvenanceSignalKind.concentratedEditingBatch ||
    ProvenanceSignalKind.programmaticallyGenerated ||
    ProvenanceSignalKind.programmaticLibrary ||
    ProvenanceSignalKind.webPasteResidue => ArtifactTraceFamily.processAnomaly,
    ProvenanceSignalKind.embeddedC2pa => ArtifactTraceFamily.informational,
  };

  /// 只有 AI 服務會產生的痕跡：檔案自己宣告 AI 產生器，或帶有對話引用標記
  static bool isIdentity(ProvenanceSignalKind kind) =>
      kind == ProvenanceSignalKind.aiGeneratorDeclared ||
      kind == ProvenanceSignalKind.chatCitationArtifact;

  factory ArtifactTraceReport.evaluate(DocumentProvenance provenance) =>
      ArtifactTraceReport([
        for (final signal in provenance.signals)
          ArtifactTrace(
            signal: signal,
            family: familyOf(signal.kind),
            identity: isIdentity(signal.kind),
          ),
      ]);

  Iterable<ArtifactTrace> ofFamily(ArtifactTraceFamily family) =>
      traces.where((trace) => trace.family == family);

  bool get hasIdentityTrace => traces.any((trace) => trace.identity);

  bool get hasNativeTrace => ofFamily(ArtifactTraceFamily.aiNative).isNotEmpty;

  /// 偵測到洗滌或偽造痕跡
  bool get concealmentDetected =>
      ofFamily(ArtifactTraceFamily.concealment).isNotEmpty;

  /// 對 AI 對數勝算的修正（≥ 0）。這是「AI 主導」判讀的檢查因子，
  /// 由呼叫端併入文件來源軸。
  double get aiLogOdds {
    var total = hasIdentityTrace ? identityLogOdds : 0.0;
    if (ofFamily(
      ArtifactTraceFamily.aiNative,
    ).any((trace) => !trace.identity)) {
      total += supportingNativeLogOdds;
    }
    var concealment = 0.0;
    for (final trace in ofFamily(ArtifactTraceFamily.concealment)) {
      concealment += trace.signal.severity == ProvenanceSeverity.strong
          ? strongConcealmentLogOdds
          : notableConcealmentLogOdds;
    }
    return total +
        (concealment > concealmentCap ? concealmentCap : concealment);
  }

  /// 這項因子的資訊量：身分證據與出版紀錄同級，其餘為輔助
  double get information => hasIdentityTrace
      ? 2.0
      : aiLogOdds > 0
      ? 0.6
      : 0.0;
}
