/// AI 訊號清單：本次分析擷取到的每一項 AI 相關訊號，逐條表列。
///
/// 與 [collectVerifiableFindings] 的差別：那份清單只收可獨立查證的事實，
/// 並刻意排除推論；這份清單則是**完整盤點**——檔案載體、規避字元、文字
/// 引擎、逐句寫作模式與來源完整性的訊號全部列出，每一條都標明類別、強度、
/// 在作者判讀中的作用與出處，讓讀者能逐條回到原檔或原文核對。
///
/// 畫面上的報告、PDF 與 JSON 匯出共用這一份清單，三者列出的項目一致。
library;

import '../../core/models/detection_result.dart';
import '../../core/services/artifact_trace.dart';
import '../../core/services/citation_evidence.dart';
import '../../core/services/claim_audit.dart';
import '../../core/services/document_provenance.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/provenance_card.dart';
import 'verifiable_findings.dart';

/// 訊號類別，依清單呈現順序排列
enum AiSignalCategory {
  /// 檔案裡原樣留下的 AI 服務產物
  fileNative,

  /// 抹除 AI 訊號、偽造編輯歷程留下的欄位矛盾
  concealment,

  /// 正文中的規避字元（零寬字元、同形字等）
  evasion,

  /// 判定為 AI 方向的文字引擎
  textEngine,

  /// 神經模型逐句判定達門檻的句子，以及逐句命中的制式寫作模式
  sentencePattern,

  /// 寫作歷程異常：說明內容不是在這份檔案裡打出來的
  writingProcess,

  /// 引用查無此文、主張缺少來源
  sourceIntegrity,

  /// 只供參考、不計入判讀（如圖片的 C2PA 憑證）
  informational,
}

enum AiSignalStrength { strong, notable, info }

/// 訊號在作者判讀中實際發揮的作用。逐條標明，避免讀者把「列出」誤讀成
/// 「已計入 AI 機率」。
enum AiSignalRole {
  /// 作者身分證據，可單獨形成 AI 方向
  identity,

  /// 加強既有的 AI 方向，不單獨形成結論
  strengthens,

  /// 加強 AI 方向，並使編輯紀錄不再作為「由人撰寫」的證據
  concealment,

  /// 使編輯紀錄不再作為「由人撰寫」的證據，但不推向 AI
  vetoesHuman,

  /// 文字引擎的統計推論，經證據融合計入
  textInference,

  /// 刻意規避；只在文字引擎已有 AI 訊號時作為弱佐證
  evasion,

  /// 來源品質問題，不計入作者判讀
  sourceQuality,

  /// 僅供參考，不計入
  informational,
}

class AiSignalEntry {
  final AiSignalCategory category;
  final AiSignalStrength strength;
  final AiSignalRole role;

  /// 白話陳述，含可核對的數量與值
  final String statement;

  /// 出處：檔案部件（如 `word/settings.xml`）或正文位置
  final String location;

  const AiSignalEntry({
    required this.category,
    required this.strength,
    required this.role,
    required this.statement,
    required this.location,
  });
}

/// 逐句清單最多列出的句號數，其餘以「…」表示，完整清單見逐句分析表
const int maxListedSentences = 40;

/// 彙整本次分析擷取到的全部 AI 訊號，依類別、再依強度排序
List<AiSignalEntry> collectAiSignals(
  DetectionResult result,
  AppLocalizations l10n, {
  CitationEvidence citations = CitationEvidence.none,
  ClaimAudit claims = ClaimAudit.none,
}) {
  final entries = <AiSignalEntry>[];
  final format = result.provenance.sourceFormat.toLowerCase();

  // 1. 檔案載體：引擎歸族後的每一條訊號
  for (final trace in ArtifactTraceReport.evaluate(result.provenance).traces) {
    final signal = trace.signal;
    final (category, role) = switch (trace.family) {
      ArtifactTraceFamily.aiNative => (
        AiSignalCategory.fileNative,
        trace.identity ? AiSignalRole.identity : AiSignalRole.strengthens,
      ),
      ArtifactTraceFamily.concealment => (
        AiSignalCategory.concealment,
        AiSignalRole.concealment,
      ),
      ArtifactTraceFamily.processAnomaly => (
        AiSignalCategory.writingProcess,
        AiSignalRole.vetoesHuman,
      ),
      ArtifactTraceFamily.informational => (
        AiSignalCategory.informational,
        AiSignalRole.informational,
      ),
    };
    entries.add(
      AiSignalEntry(
        category: category,
        strength: switch (signal.severity) {
          ProvenanceSeverity.strong => AiSignalStrength.strong,
          ProvenanceSeverity.notable => AiSignalStrength.notable,
          ProvenanceSeverity.info => AiSignalStrength.info,
        },
        role: role,
        statement: ProvenanceCard.describeSignal(signal, l10n),
        location: signalLocation(signal.kind, format, l10n),
      ),
    );
  }

  // 2. 規避字元：每一種手法一條，附次數
  final evasion = result.evasion;
  final deliberate = evasion.indicatesDeliberateEvasion;
  for (final finding in evasion.findings) {
    entries.add(
      AiSignalEntry(
        category: AiSignalCategory.evasion,
        strength: deliberate ? AiSignalStrength.notable : AiSignalStrength.info,
        role: deliberate ? AiSignalRole.evasion : AiSignalRole.informational,
        statement: l10n.evasionTechniqueCount(
          evasionKindLabel(finding.kind, l10n),
          finding.count,
        ),
        location: l10n.aiSignalLocationBody,
      ),
    );
  }

  // 3. 判定為 AI 方向的文字引擎：引擎分數與它列出的全部理由
  for (final engine in result.engineScores) {
    if (!engine.votes ||
        engine.aiProbability < DetectionResult.aiFlagThreshold) {
      continue;
    }
    entries.add(
      AiSignalEntry(
        category: AiSignalCategory.textEngine,
        strength: engine.aiProbability >= 0.8
            ? AiSignalStrength.strong
            : AiSignalStrength.notable,
        role: AiSignalRole.textInference,
        statement: l10n.aiSignalEngineStatement(
          engine.engineName,
          (engine.aiProbability * 100).round(),
          engine.reasons.isEmpty
              ? '—'
              : engine.reasons.join(l10n.listSeparator),
        ),
        location: l10n.aiSignalLocationBody,
      ),
    );
  }

  // 4. 逐句：模型判定達門檻的句子，以及每一種制式寫作模式出現在哪幾句
  final flagged = [
    for (final s in result.sentences)
      if (s.modelBacked &&
          !s.aiProbability.isNaN &&
          s.aiProbability >= DetectionResult.aiFlagThreshold)
        s.index + 1,
  ];
  if (flagged.isNotEmpty) {
    entries.add(
      AiSignalEntry(
        category: AiSignalCategory.sentencePattern,
        strength: AiSignalStrength.notable,
        role: AiSignalRole.textInference,
        statement: l10n.aiSignalSentencesFlagged(
          flagged.length,
          (DetectionResult.aiFlagThreshold * 100).round(),
          _sentenceList(flagged, l10n),
        ),
        location: l10n.aiSignalLocationSentences,
      ),
    );
  }
  final byPattern = <String, List<int>>{};
  for (final s in result.sentences) {
    for (final pattern in s.patterns) {
      if (pattern == l10n.patternNotAnalyzable) continue;
      byPattern.putIfAbsent(pattern, () => []).add(s.index + 1);
    }
  }
  final patterns = byPattern.entries.toList()
    ..sort((a, b) => b.value.length.compareTo(a.value.length));
  for (final pattern in patterns) {
    entries.add(
      AiSignalEntry(
        category: AiSignalCategory.sentencePattern,
        strength: AiSignalStrength.info,
        role: AiSignalRole.textInference,
        statement: l10n.aiSignalPatternStatement(
          pattern.key,
          pattern.value.length,
          _sentenceList(pattern.value, l10n),
        ),
        location: l10n.aiSignalLocationSentences,
      ),
    );
  }

  // 5. 來源完整性
  if (citations.hasData && citations.notFound > 0) {
    entries.add(
      AiSignalEntry(
        category: AiSignalCategory.sourceIntegrity,
        strength: citations.risk == CitationRisk.high
            ? AiSignalStrength.strong
            : AiSignalStrength.notable,
        role: AiSignalRole.sourceQuality,
        statement: l10n.findingCitationsNotFound(
          citations.notFound,
          citations.total,
        ),
        location: l10n.aiSignalLocationReferences,
      ),
    );
  }
  if (claims.risk == ClaimSourceRisk.medium ||
      claims.risk == ClaimSourceRisk.high) {
    entries.add(
      AiSignalEntry(
        category: AiSignalCategory.sourceIntegrity,
        strength: claims.risk == ClaimSourceRisk.high
            ? AiSignalStrength.notable
            : AiSignalStrength.info,
        role: AiSignalRole.sourceQuality,
        statement: l10n.findingUnsupportedClaims(
          claims.unsupported,
          claims.total,
        ),
        location: l10n.aiSignalLocationBody,
      ),
    );
  }

  // 類別順序優先，同類別內強者在前；sort 是穩定的，同強度保留原順序
  entries.sort((a, b) {
    final byCategory = a.category.index.compareTo(b.category.index);
    return byCategory != 0
        ? byCategory
        : a.strength.index.compareTo(b.strength.index);
  });
  return entries;
}

String _sentenceList(List<int> numbers, AppLocalizations l10n) {
  final shown = numbers.take(maxListedSentences).join(l10n.listSeparator);
  return numbers.length > maxListedSentences ? '$shown…' : shown;
}

/// 訊號在原檔中的出處。檔案部件名稱是技術識別碼，各語系一致不翻譯。
String signalLocation(
  ProvenanceSignalKind kind,
  String format,
  AppLocalizations l10n,
) {
  final metadata = switch (format) {
    'docx' => 'docProps/app.xml · docProps/core.xml',
    'odt' => 'meta.xml',
    'doc' => 'SummaryInformation',
    'pdf' => 'PDF Info · XMP',
    _ => format,
  };
  return switch (kind) {
    ProvenanceSignalKind.aiGeneratorDeclared ||
    ProvenanceSignalKind.programmaticLibrary ||
    ProvenanceSignalKind.implausibleTypingSpeed ||
    ProvenanceSignalKind.negligibleEditingTime ||
    ProvenanceSignalKind.editingTimeExceedsLifetime => metadata,
    ProvenanceSignalKind.fewRevisions => switch (format) {
      'docx' => 'docProps/core.xml',
      _ => metadata,
    },
    ProvenanceSignalKind.chatCitationArtifact => l10n.aiSignalLocationBody,
    ProvenanceSignalKind.aiReferralLink => switch (format) {
      'docx' => 'word/_rels/document.xml.rels',
      'pdf' => 'PDF /URI',
      _ => l10n.aiSignalLocationBody,
    },
    ProvenanceSignalKind.chatInterfaceFont =>
      'word/styles.xml · word/document.xml',
    ProvenanceSignalKind.webPasteResidue ||
    ProvenanceSignalKind.syntheticRunFragmentation => 'word/document.xml',
    ProvenanceSignalKind.webStyleResidue => 'word/styles.xml',
    ProvenanceSignalKind.singleEditingSession ||
    ProvenanceSignalKind.concentratedEditingBatch =>
      'word/document.xml (w:rsid*)',
    ProvenanceSignalKind.unregisteredRsids =>
      'word/document.xml · word/settings.xml (w:rsids)',
    ProvenanceSignalKind.sessionsExceedRevisions =>
      'word/document.xml · docProps/core.xml',
    ProvenanceSignalKind.declaredStatsMismatch => 'docProps/app.xml (Words)',
    ProvenanceSignalKind.generatorMismatch =>
      'docProps/app.xml · word/settings.xml · word/fontTable.xml',
    ProvenanceSignalKind.hollowWordComponents =>
      'word/settings.xml · word/fontTable.xml',
    ProvenanceSignalKind.programmaticallyGenerated => 'DOCX package',
    ProvenanceSignalKind.forgedPdfProducer => 'PDF Info /Producer',
    ProvenanceSignalKind.pdfProducerRewritten => 'PDF %%EOF revisions',
    ProvenanceSignalKind.pdfInfoXmpConflict => 'PDF Info · XMP pdf:Producer',
    ProvenanceSignalKind.pdfStructureMismatch => 'PDF /ObjStm · /XRef',
    ProvenanceSignalKind.embeddedC2pa => switch (format) {
      'docx' => 'word/media/*',
      _ => 'C2PA',
    },
  };
}

String aiSignalCategoryLabel(AiSignalCategory c, AppLocalizations l10n) =>
    switch (c) {
      AiSignalCategory.fileNative => l10n.aiSignalCategoryFileNative,
      AiSignalCategory.concealment => l10n.aiSignalCategoryConcealment,
      AiSignalCategory.evasion => l10n.aiSignalCategoryEvasion,
      AiSignalCategory.textEngine => l10n.aiSignalCategoryTextEngine,
      AiSignalCategory.sentencePattern => l10n.aiSignalCategorySentence,
      AiSignalCategory.writingProcess => l10n.aiSignalCategoryProcess,
      AiSignalCategory.sourceIntegrity => l10n.aiSignalCategorySource,
      AiSignalCategory.informational => l10n.aiSignalCategoryInformational,
    };

String aiSignalStrengthLabel(AiSignalStrength s, AppLocalizations l10n) =>
    switch (s) {
      AiSignalStrength.strong => l10n.aiSignalStrengthStrong,
      AiSignalStrength.notable => l10n.aiSignalStrengthNotable,
      AiSignalStrength.info => l10n.aiSignalStrengthInfo,
    };

String aiSignalRoleLabel(AiSignalRole r, AppLocalizations l10n) => switch (r) {
  AiSignalRole.identity => l10n.aiSignalRoleIdentity,
  AiSignalRole.strengthens => l10n.aiSignalRoleStrengthens,
  AiSignalRole.concealment => l10n.aiSignalRoleConcealment,
  AiSignalRole.vetoesHuman => l10n.aiSignalRoleVetoesHuman,
  AiSignalRole.textInference => l10n.aiSignalRoleTextInference,
  AiSignalRole.evasion => l10n.aiSignalRoleEvasion,
  AiSignalRole.sourceQuality => l10n.aiSignalRoleSourceQuality,
  AiSignalRole.informational => l10n.aiSignalRoleInformational,
};
