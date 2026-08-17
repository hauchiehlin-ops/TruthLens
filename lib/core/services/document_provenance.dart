/// 文件來源鑑識：從 DOCX／ODT 容器中讀出編輯紀錄類的中繼資料。
///
/// 這是**來源證據**，不是文字風格推論，因此刻意與 AI 機率分開呈現：
/// 它回答「這份檔案是怎麼產生的」，而非「這段文字看起來像不像 AI 寫的」。
///
/// 重要限制（必須隨結果一起呈現給使用者）：
/// - 這些紀錄可被清除或重置——另存新檔、線上轉檔、從 Google 文件匯出、
///   複製貼上到新檔案，都會讓紀錄歸零或消失。
/// - 因此「有訊號」是佐證，「沒訊號」**不代表**文件必然由人撰寫。
library;

import 'dart:convert';

import 'package:archive/archive.dart';

/// 單一來源訊號的種類
enum ProvenanceSignalKind {
  /// 正文的編輯批次（RSID）過度集中 → 內容可能是單次一起寫入
  singleEditingSession,

  /// 字數 ÷ 編輯時長換算出的速度遠高於常人打字速度
  implausibleTypingSpeed,

  /// 有實質內容，但宣稱的編輯總時長接近 0
  negligibleEditingTime,

  /// 整份文件只存檔過極少次數
  fewRevisions,
}

/// 訊號強度。刻意不叫「有罪程度」——這只描述證據本身有多不尋常。
enum ProvenanceSeverity { info, notable, strong }

/// 為什麼沒有編輯紀錄可用。兩種情況的處置方式**完全不同**：
/// 格式本身就不帶紀錄時，叫使用者「注意紀錄可能被清除」是誤導；
/// 正確的建議是「改收 .docx／.odt 原檔」。
enum ProvenanceAvailability {
  /// 有可用的編輯紀錄
  available,

  /// 此格式本質上不攜帶編輯歷程（PDF／舊版 doc／純文字／OCR／貼上）
  unsupportedFormat,

  /// 格式支援，但這份檔案裡沒有紀錄——多半是另存、轉檔或匯出時被重置
  stripped,
}

/// 綜合的來源可疑度，與 AI 機率完全獨立
enum ProvenanceRisk {
  /// 沒有任何可用的中繼資料（純文字、PDF、或已被清除）
  unknown,
  low,
  medium,
  high,
}

class ProvenanceSignal {
  final ProvenanceSignalKind kind;
  final ProvenanceSeverity severity;

  /// 供介面格式化訊息用的數值，鍵名對應各 l10n 佔位符
  final Map<String, int> values;

  const ProvenanceSignal({
    required this.kind,
    required this.severity,
    this.values = const {},
  });
}

/// 一份文件的來源中繼資料與衍生訊號
class DocumentProvenance {
  /// 檔案宣稱的編輯總時長（DOCX `<TotalTime>`／ODT `editing-duration`）
  final Duration? editingDuration;

  /// 存檔／修訂次數（DOCX `<cp:revision>`／ODT `editing-cycles`）
  final int? revisionCount;

  final DateTime? createdAt;
  final DateTime? modifiedAt;

  /// 產生軟體（DOCX `<Application>`／ODT `<meta:generator>`）
  final String? application;

  /// 中繼資料自己宣稱的字數（DOCX `<Words>`）
  final int? declaredWordCount;

  /// 正文中出現的相異 RSID 數量（僅 DOCX）。RSID 是 Word 為每個編輯批次
  /// 產生的識別碼：正常寫作會散布在數十組，整篇只有一兩組通常代表
  /// 內容是一次寫入的。
  final int? distinctBodyRsids;

  /// 實際用來計算的正文字數（由呼叫端傳入的解析結果算出）
  final int bodyWordCount;

  final List<ProvenanceSignal> signals;

  /// 來源副檔名（小寫）。用來區分「格式不支援」與「紀錄被清除」，
  /// 空字串代表貼上的文字或圖片 OCR，兩者都沒有檔案容器。
  final String sourceFormat;

  const DocumentProvenance({
    this.editingDuration,
    this.revisionCount,
    this.createdAt,
    this.modifiedAt,
    this.application,
    this.declaredWordCount,
    this.distinctBodyRsids,
    this.bodyWordCount = 0,
    this.signals = const [],
    this.sourceFormat = '',
  });

  /// 完全沒有中繼資料可用（例如貼上的純文字、PDF、或紀錄已被清除）
  static const DocumentProvenance none = DocumentProvenance();

  /// 帶有編輯歷程的容器格式。其餘格式不是「被清除」，而是**從來就沒有**。
  static const Set<String> formatsWithEditingRecord = {'docx', 'odt'};

  ProvenanceAvailability get availability {
    if (hasMetadata) return ProvenanceAvailability.available;
    return formatsWithEditingRecord.contains(sourceFormat)
        ? ProvenanceAvailability.stripped
        : ProvenanceAvailability.unsupportedFormat;
  }

  bool get hasMetadata =>
      editingDuration != null ||
      revisionCount != null ||
      createdAt != null ||
      application != null ||
      distinctBodyRsids != null;

  /// 是否構成「由人撰寫」的**獨立**證據，可據以自動納入基準集。
  ///
  /// 關鍵在於**獨立性**：這個判斷完全來自檔案的編輯紀錄，與文字分類器算出的
  /// AI 機率無關。若改用分類器自己的判定來自動標註，虛無分布就會變成「分類器
  /// 已經認為是人類的文章」——循環論證，而且被誤判的真人文章永遠進不了基準集，
  /// 會讓分布在低分端被人為壓緊、門檻偏低，反而標記更多真人作業。
  ///
  /// 條件刻意訂得保守：寧可少收，也不要把來歷不明的樣本放進虛無分布。
  bool get indicatesHumanAuthorship {
    if (!hasMetadata || signals.isNotEmpty) return false;
    if ((editingDuration?.inMinutes ?? 0) < minAutoAdmitMinutes) return false;
    if ((revisionCount ?? 0) < minAutoAdmitRevisions) return false;
    // ODT 沒有 RSID 欄位，該欄為 null 時不作為否決條件
    final rsids = distinctBodyRsids;
    if (rsids != null && rsids < minAutoAdmitRsids) return false;
    return true;
  }

  /// 自動納入基準集的門檻：需有實質的編輯歷程，而非一次寫入
  static const int minAutoAdmitMinutes = 20;
  static const int minAutoAdmitRevisions = 3;
  static const int minAutoAdmitRsids = 5;

  ProvenanceRisk get risk {
    if (!hasMetadata) return ProvenanceRisk.unknown;
    if (signals.isEmpty) return ProvenanceRisk.low;
    final strong = signals
        .where((s) => s.severity == ProvenanceSeverity.strong)
        .length;
    final notable = signals
        .where((s) => s.severity == ProvenanceSeverity.notable)
        .length;
    if (strong >= 2 || (strong >= 1 && notable >= 1)) return ProvenanceRisk.high;
    if (strong >= 1 || notable >= 2) return ProvenanceRisk.medium;
    return ProvenanceRisk.low;
  }

  /// 由檔案位元組解析來源證據。[bodyText] 是已解析出的正文，用來換算字數；
  /// 無法解析或非 zip 容器格式時回傳 [none]，絕不丟例外。
  static DocumentProvenance fromBytes(
    List<int> bytes, {
    required String extension,
    required String bodyText,
  }) {
    final ext = extension.toLowerCase();
    if (!formatsWithEditingRecord.contains(ext)) {
      // 非 zip 容器格式：直接標明來源，讓介面能說出「此格式不帶編輯紀錄」
      return DocumentProvenance(sourceFormat: ext);
    }
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      return switch (ext) {
        'docx' => _fromDocx(archive, bodyText, ext),
        'odt' => _fromOdt(archive, bodyText, ext),
        _ => DocumentProvenance(sourceFormat: ext),
      };
    } catch (_) {
      return DocumentProvenance(sourceFormat: ext);
    }
  }

  static String? _read(Archive archive, String path) {
    final file = archive.findFile(path);
    if (file == null) return null;
    try {
      return utf8.decode(file.content as List<int>, allowMalformed: true);
    } catch (_) {
      return null;
    }
  }

  static DocumentProvenance _fromDocx(
    Archive archive,
    String bodyText,
    String ext,
  ) {
    final app = _read(archive, 'docProps/app.xml') ?? '';
    final core = _read(archive, 'docProps/core.xml') ?? '';
    final document = _read(archive, 'word/document.xml') ?? '';

    final totalMinutes = int.tryParse(_tag(app, 'TotalTime') ?? '');
    final declaredWords = int.tryParse(_tag(app, 'Words') ?? '');
    final application = _tag(app, 'Application');
    final revision = int.tryParse(_tag(core, 'cp:revision') ?? '');
    final created = DateTime.tryParse(_tag(core, 'dcterms:created') ?? '');
    final modified = DateTime.tryParse(_tag(core, 'dcterms:modified') ?? '');

    // 正文裡所有 w:rsid* 屬性值的相異數量
    final rsids = <String>{};
    for (final m in RegExp(
      r'w:rsid(?:R|RDefault|P|RPr|Tr|Del)?="([0-9A-Fa-f]+)"',
    ).allMatches(document)) {
      final value = m.group(1);
      if (value != null && value.isNotEmpty) rsids.add(value.toUpperCase());
    }

    return _withSignals(
      DocumentProvenance(
        editingDuration: totalMinutes == null
            ? null
            : Duration(minutes: totalMinutes),
        revisionCount: revision,
        createdAt: created,
        modifiedAt: modified,
        application: (application == null || application.isEmpty)
            ? null
            : application,
        declaredWordCount: declaredWords,
        distinctBodyRsids: rsids.isEmpty ? null : rsids.length,
        bodyWordCount: countWords(bodyText),
        sourceFormat: ext,
      ),
    );
  }

  static DocumentProvenance _fromOdt(
    Archive archive,
    String bodyText,
    String ext,
  ) {
    final meta = _read(archive, 'meta.xml') ?? '';

    final duration = parseIso8601Duration(
      _tag(meta, 'meta:editing-duration') ?? '',
    );
    final cycles = int.tryParse(_tag(meta, 'meta:editing-cycles') ?? '');
    final created = DateTime.tryParse(_tag(meta, 'meta:creation-date') ?? '');
    final modified = DateTime.tryParse(_tag(meta, 'dc:date') ?? '');
    final generator = _tag(meta, 'meta:generator');

    return _withSignals(
      DocumentProvenance(
        editingDuration: duration,
        revisionCount: cycles,
        createdAt: created,
        modifiedAt: modified,
        application: (generator == null || generator.isEmpty)
            ? null
            : generator,
        // ODT 沒有 RSID 這種逐批次標記，維持 null
        bodyWordCount: countWords(bodyText),
        sourceFormat: ext,
      ),
    );
  }

  /// 取出 `<tag ...>value</tag>` 的內容；找不到回傳 null
  static String? _tag(String xml, String tag) {
    final match = RegExp(
      '<${RegExp.escape(tag)}[^>]*>(.*?)</${RegExp.escape(tag)}>',
      dotAll: true,
    ).firstMatch(xml);
    return match?.group(1)?.trim();
  }

  /// 解析 ISO 8601 期間（如 `PT4M30S`、`P0D`）。ODT 只會用到日以下的欄位。
  static Duration? parseIso8601Duration(String raw) {
    if (raw.isEmpty) return null;
    final match = RegExp(
      r'^P(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(?:\.\d+)?)S)?)?$',
    ).firstMatch(raw.trim().toUpperCase());
    if (match == null) return null;
    final days = int.tryParse(match.group(1) ?? '') ?? 0;
    final hours = int.tryParse(match.group(2) ?? '') ?? 0;
    final minutes = int.tryParse(match.group(3) ?? '') ?? 0;
    final seconds = double.tryParse(match.group(4) ?? '')?.round() ?? 0;
    return Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  /// 粗略字數：CJK 逐字計，其他語言以空白分詞。
  static int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    final cjk = RegExp(
      r'[㐀-䶿一-鿿぀-ヿ가-힯]',
    ).allMatches(trimmed).length;
    final latin = RegExp(
      r'[A-Za-zÀ-ɏЀ-ӿ]+',
    ).allMatches(trimmed).length;
    return cjk + latin;
  }

  /// 一般人持續打字的上限概估（字/分）。超過此值代表內容多半不是當場敲出來的。
  /// 取值偏寬鬆（世界級打字員短衝可達 150+，但無法在整份長文維持），
  /// 寧可漏報也不要誤報。
  static const int implausibleWordsPerMinute = 120;

  /// 依已填入的中繼資料推導訊號
  static DocumentProvenance _withSignals(DocumentProvenance base) {
    final signals = <ProvenanceSignal>[];
    final words = base.bodyWordCount;
    final minutes = base.editingDuration?.inMinutes;

    // 內容量太少時所有推論都不可靠，直接不產生訊號
    const minimumWordsForInference = 150;

    if (words >= minimumWordsForInference) {
      if (minutes != null) {
        if (minutes <= 1) {
          signals.add(
            ProvenanceSignal(
              kind: ProvenanceSignalKind.negligibleEditingTime,
              severity: ProvenanceSeverity.strong,
              values: {'words': words, 'minutes': minutes},
            ),
          );
        } else {
          final wpm = words ~/ minutes;
          if (wpm >= implausibleWordsPerMinute) {
            signals.add(
              ProvenanceSignal(
                kind: ProvenanceSignalKind.implausibleTypingSpeed,
                severity: ProvenanceSeverity.strong,
                values: {'words': words, 'minutes': minutes, 'wpm': wpm},
              ),
            );
          }
        }
      }

      final rsids = base.distinctBodyRsids;
      if (rsids != null && rsids <= 2) {
        signals.add(
          ProvenanceSignal(
            kind: ProvenanceSignalKind.singleEditingSession,
            severity: ProvenanceSeverity.strong,
            values: {'count': rsids, 'words': words},
          ),
        );
      }

      final revisions = base.revisionCount;
      if (revisions != null && revisions <= 1) {
        signals.add(
          ProvenanceSignal(
            kind: ProvenanceSignalKind.fewRevisions,
            severity: ProvenanceSeverity.notable,
            values: {'count': revisions, 'words': words},
          ),
        );
      }
    }

    return DocumentProvenance(
      editingDuration: base.editingDuration,
      revisionCount: base.revisionCount,
      createdAt: base.createdAt,
      modifiedAt: base.modifiedAt,
      application: base.application,
      declaredWordCount: base.declaredWordCount,
      distinctBodyRsids: base.distinctBodyRsids,
      bodyWordCount: base.bodyWordCount,
      sourceFormat: base.sourceFormat,
      signals: signals,
    );
  }
}
