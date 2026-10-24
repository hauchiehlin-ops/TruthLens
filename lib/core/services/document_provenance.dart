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

import 'rsid_map.dart';

import 'dart:convert';

import 'package:archive/archive.dart';

import 'file_forensics.dart';
import 'ole_summary_information.dart';

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

  /// 文件有多個編輯批次，但字數高度集中於其中一批
  /// → 該批對應的段落可能是一次貼上的
  concentratedEditingBatch,

  /// 產生軟體或文件描述直接宣告為 AI 寫作工具（如 Claude Docs、ChatGPT 匯出）。
  /// 這是**作者特異性**的來源證據：一般文書軟體不會把自己寫成 AI 產品。
  aiGeneratorDeclared,

  /// DOCX 正文完全沒有 RSID，也沒有編輯時長，且不是 Word 存的檔
  /// → 檔案由程式一次產生（匯出、轉檔或生成工具），不是在文書軟體裡逐步打字。
  /// 這不是 AI 特異性證據（pandoc、Google 文件匯出也會如此），只能佐證。
  programmaticallyGenerated,

  /// 產生器欄位是程式庫（python-docx、reportlab、pdf-lib…）
  /// → 檔案由自動化流程寫出；AI 服務的匯出多半如此，但報表系統也是，只能佐證。
  programmaticLibrary,

  /// 宣稱由 Word 產生，卻缺少 Word 存檔必定寫入的設定與字型表
  /// → 中繼資料被改寫，或其他工具冒用了名稱
  generatorMismatch,

  /// 「Normal (Web)」樣式、HTML 區塊或網頁字型堆疊
  /// → 內容是從網頁或對話介面直接貼上，沒有選「只保留文字」
  webPasteResidue,

  /// 內文帶有 AI 對話介面專用的網頁字型（如 ChatGPT 的 Söhne）
  chatInterfaceFont,

  /// 檔案或內嵌圖片帶有 C2PA 內容憑證。說明的是媒體來源，
  /// 不是內文作者，因此只列出、不計入風險。
  embeddedC2pa,

  // ── 原生 AI 痕跡：未經洗滌時留在檔案裡的對話服務產物 ──

  /// 正文帶有 AI 對話服務的引用標記（`【4†source】`、`citeturn0search3`、
  /// `[oaicite:2]`）。這些標記只由對話服務的引用系統產生，屬作者特異性證據。
  chatCitationArtifact,

  /// 連結帶有 AI 搜尋導流參數（`utm_source=chatgpt.com`）
  /// → 參考資料經 AI 搜尋取得；不直接說明正文作者，只作佐證。
  aiReferralLink,

  // ── 洗滌痕跡：抹除 AI 訊號、偽造編輯歷程時留下的欄位矛盾 ──

  /// 正文引用的 RSID 大量未登記在 settings.xml 的 `<w:rsids>`
  /// → 編輯批次是事後注入正文，沒有同步登記表
  unregisteredRsids,

  /// 宣稱的編輯總時長超過「最後修改 − 建立」的檔案存在時間
  /// → 編輯時長被改寫（邏輯上不可能）
  editingTimeExceedsLifetime,

  /// 編輯批次數遠多於存檔次數。Word 每次存檔開新的 RSID，
  /// 批次數應與存檔次數同量級 → 批次或存檔次數其中之一被偽造
  sessionsExceedRevisions,

  /// PDF Producer 宣稱是 macOS／iOS 系統輸出，格式卻與系統實際寫入的不符
  /// （缺組建號，或組建號與版本對不上）→ 產生器欄位被改寫
  forgedPdfProducer,

  /// 宣稱 Word 存檔，settings.xml 與 fontTable.xml 卻只是空殼
  /// （沒有相容性設定、沒有任何字型）→ 部件是補上去應付檢查的
  hollowWordComponents,

  /// app.xml 宣告的字數與正文實際字數差距數倍
  /// → 正文在 Word 之外被改寫（例如自動改寫工具），統計欄位沒跟上
  declaredStatsMismatch,

  /// 大量相鄰且完全相同的文字執行區，或每段都硬寫與段落預設相同的 RSID
  /// → 文字被程式切碎，偽裝成逐字修訂
  syntheticRunFragmentation,

  /// PDF 較早的修訂版本寫著另一個產生器，最後生效的卻是只會整份寫出
  /// 的工具（系統列印、Word 另存）→ 產生器是事後以增量更新改寫的
  pdfProducerRewritten,

  /// PDF 資訊字典自稱系統或 Word 輸出，XMP 卻記著另一個產生器
  pdfInfoXmpConflict,

  /// 自稱 macOS／iOS 系統輸出，卻用了系統從不寫入的壓縮物件結構
  pdfStructureMismatch,

  /// styles.xml 定義了網頁貼上樣式，正文卻一處都沒用到
  /// → 內容曾從網頁貼上，事後被改成一般格式
  webStyleResidue,
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

  /// 需要原文呈現的字串值（例如宣告的產生軟體名稱）
  final String? label;

  const ProvenanceSignal({
    required this.kind,
    required this.severity,
    this.values = const {},
    this.label,
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

  /// 由檔案結構直接判定的訊號（封裝、貼上殘留、C2PA、程式庫），
  /// 不依賴字數門檻，由 [_withSignals] 併入 [signals]
  final List<ProvenanceSignal> fileSignals;

  /// DOCX 只有最少必要部件（沒有設定與字型表）：程式一次性封裝
  final bool minimalPackage;

  /// 其餘可能帶有產生工具名稱的欄位（DOCX `dc:creator`、
  /// `cp:lastModifiedBy`、`dc:description`）。只用來比對 AI 產生器，不呈現。
  final List<String> generatorHints;

  /// 段落級的編輯批次分佈（僅 DOCX）。比 [distinctBodyRsids] 的單一數字
  /// 更能指認**哪幾段**屬於同一批——一份逐步寫成的文件會有許多小批次散在
  /// 各段，一次貼上的內容則讓大量文字集中在單一批次。
  final RsidMap rsidMap;

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
    this.generatorHints = const [],
    this.fileSignals = const [],
    this.minimalPackage = false,
    this.distinctBodyRsids,
    this.rsidMap = RsidMap.empty,
    this.bodyWordCount = 0,
    this.signals = const [],
    this.sourceFormat = '',
  });

  /// 完全沒有中繼資料可用（例如貼上的純文字、PDF、或紀錄已被清除）
  static const DocumentProvenance none = DocumentProvenance();

  /// 帶有編輯歷程的容器格式。其餘格式不是「被清除」，而是**從來就沒有**。
  ///
  /// `.doc` 走的是完全不同的路徑：它是 OLE2／CFB 二進位容器而非 zip，
  /// 編輯紀錄放在 SummaryInformation 串流中（欄位與 docx 相同）。
  static const Set<String> formatsWithEditingRecord = {'docx', 'odt', 'doc'};

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
  /// 產生軟體自己宣告為 AI 寫作工具時回傳該名稱。
  ///
  /// 這與編輯時長、RSID 等「寫作過程異常」不同：那些只說明內容不是當場
  /// 打出來的，這裡則是檔案直接說明誰產生了它。紀錄可被清除，但很少被
  /// 偽造成 AI 產品名稱，因此可作為 AI 方向的來源證據。
  String? get declaredAiGenerator {
    for (final signal in signals) {
      if (signal.kind == ProvenanceSignalKind.aiGeneratorDeclared) {
        return signal.label;
      }
    }
    return null;
  }

  bool get declaresAiGenerator => declaredAiGenerator != null;

  /// 已知 AI 寫作工具在中繼資料留下的名稱。刻意不收單獨的「Claude」或
  /// Jasper、Kimi 這類同時是人名的字樣，避免把作者名字誤判成產生器。
  static const String _aiGeneratorNames =
      r'(?:claude\s*(?:docs|code|\.ai|ai|desktop)\b|anthropic\b|'
      r'chat\s*gpt\b|openai\b|gpt-[0-9o]|gemini\b|copilot\b|'
      r'notion\s+ai\b|perplexity\b|deepseek\b|qwen\b|通義|豆包|doubao\b|'
      r'grok\b|文心一言|ernie\s*bot\b)';

  /// 產生軟體欄位（DOCX `Application`、ODT `generator`）本身就是軟體名稱，
  /// 名稱出現在任何位置都算。不用 `\b`：它對中文字元不成立，會漏掉「通義」。
  static final RegExp aiGeneratorPattern = RegExp(
    '(?<![A-Za-z0-9])$_aiGeneratorNames',
    caseSensitive: false,
  );

  /// 作者、描述等自由文字欄位只認開頭的工具簽章（例如
  /// `Claude Docs node/…`）；描述裡「研究 ChatGPT 的使用」不能算數。
  static final RegExp aiGeneratorSignaturePattern = RegExp(
    '^\\s*$_aiGeneratorNames',
    caseSensitive: false,
  );

  /// 從產生軟體與其他欄位找出 AI 產生器名稱，找不到回傳 null
  static String? matchAiGenerator(String? application, List<String> hints) {
    if (application != null && aiGeneratorPattern.hasMatch(application)) {
      return application.trim();
    }
    for (final hint in hints) {
      final match = aiGeneratorSignaturePattern.firstMatch(hint);
      if (match != null) return match.group(0)!.trim();
    }
    return null;
  }

  bool get indicatesHumanAuthorship {
    if (!hasMetadata ||
        signals.any((s) => s.severity != ProvenanceSeverity.info)) {
      return false;
    }
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
    // 沒有中繼資料但封裝結構本身就有訊號時（例如完全不寫屬性的程式產生檔），
    // 不能因為缺欄位就把訊號藏成「未知」
    if (!hasMetadata && signals.isEmpty) return ProvenanceRisk.unknown;
    if (signals.isEmpty) return ProvenanceRisk.low;
    final strong = signals
        .where((s) => s.severity == ProvenanceSeverity.strong)
        .length;
    final notable = signals
        .where((s) => s.severity == ProvenanceSeverity.notable)
        .length;
    if (strong >= 2 || (strong >= 1 && notable >= 1)) {
      return ProvenanceRisk.high;
    }
    if (strong >= 1 || notable >= 2) return ProvenanceRisk.medium;
    return ProvenanceRisk.low;
  }

  /// 由檔案位元組解析來源證據。[bodyText] 是已解析出的正文，用來換算字數；
  /// 無法解析或非 zip 容器格式時回傳 [none]，絕不丟例外。
  static DocumentProvenance fromBytes(
    List<int> bytes, {
    required String extension,
    required String bodyText,
    PdfMetadata pdfMetadata = PdfMetadata.empty,
  }) {
    final ext = extension.toLowerCase();
    if (ext == 'pdf') return _fromPdf(bytes, bodyText, ext, pdfMetadata);
    if (!formatsWithEditingRecord.contains(ext)) {
      // 非容器格式：直接標明來源，讓介面能說出「此格式不帶編輯紀錄」
      return DocumentProvenance(sourceFormat: ext);
    }
    // 舊版 .doc 是 OLE2 二進位，不是 zip，需另一條解析路徑
    if (ext == 'doc') return _fromLegacyDoc(bytes, bodyText, ext);
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

  /// 舊版 `.doc`：從 OLE2 的 SummaryInformation 串流取出與 docx 相同的欄位。
  /// 沒有 RSID 這種逐批次標記，因此 [distinctBodyRsids] 維持 null——
  /// 自動納入基準集的判斷已設計為 null 時不否決。
  static DocumentProvenance _fromLegacyDoc(
    List<int> bytes,
    String bodyText,
    String ext,
  ) {
    final info = OleSummaryInformation.parse(bytes);
    if (info == null) return DocumentProvenance(sourceFormat: ext);
    return _withSignals(
      DocumentProvenance(
        editingDuration: info.totalEditTime,
        revisionCount: info.revisionNumber,
        createdAt: info.createdAt,
        modifiedAt: info.modifiedAt,
        application: info.application,
        declaredWordCount: info.wordCount,
        fileSignals: _textArtifacts(bodyText, const []),
        bodyWordCount: countWords(bodyText),
        sourceFormat: ext,
      ),
    );
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
    final hints = [
      for (final tag in const [
        'dc:creator',
        'cp:lastModifiedBy',
        'dc:description',
      ])
        ?_tag(core, tag),
    ].where((value) => value.isNotEmpty).toList();

    // 正文裡所有 w:rsid* 屬性值的相異數量
    final rsids = <String>{};
    for (final m in RegExp(
      r'w:rsid(?:R|RDefault|P|RPr|Tr|Del)?="([0-9A-Fa-f]+)"',
    ).allMatches(document)) {
      final value = m.group(1);
      if (value != null && value.isNotEmpty) rsids.add(value.toUpperCase());
    }

    final registry = RsidRegistry.parse(
      _read(archive, 'word/settings.xml') ?? '',
    );
    final unregistered = registry.unregistered(rsids);

    final package = DocxPackage({for (final f in archive.files) f.name});
    final claimsWord = (application ?? '').toLowerCase().contains('microsoft');
    final styles = _read(archive, 'word/styles.xml') ?? '';
    final paste = WebPasteResidue.scan(document: document, styles: styles);
    final parts = WordPartFingerprint.scan(
      settings: _read(archive, 'word/settings.xml') ?? '',
      fontTable: _read(archive, 'word/fontTable.xml') ?? '',
    );
    // Google 文件、LibreOffice 的寫法本來就不同，只對宣稱 Word 的檔案比對
    final fragmentation = claimsWord
        ? RunFragmentation.scan(document)
        : const RunFragmentation();
    final unusedWeb = paste.webStyledRuns == 0
        ? unusedWebStyles(styles: styles, document: document)
        : 0;
    final fileSignals = <ProvenanceSignal>[
      ..._libraryAndC2pa(
        [?application, ...hints],
        [
          for (final f in archive.files)
            if (f.isFile && f.name.startsWith('word/media/'))
              f.content as List<int>,
        ],
      ),
      // Word 一定寫入設定與字型表；宣稱 Word 卻沒有，代表名稱被冒用或改寫
      if (claimsWord && !package.hasWordCoreParts)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.generatorMismatch,
          severity: ProvenanceSeverity.notable,
          label: application,
        ),
      if (paste.indicatesWebPaste)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.webPasteResidue,
          severity: ProvenanceSeverity.notable,
          values: {'count': paste.affectedBlocks},
          label: paste.webFontStack,
        ),
      if (paste.chatInterfaceFont != null)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.chatInterfaceFont,
          severity: ProvenanceSeverity.notable,
          label: paste.chatInterfaceFont,
        ),
      ..._textArtifacts(bodyText, [
        document,
        _read(archive, 'word/_rels/document.xml.rels') ?? '',
      ]),
      if (claimsWord && package.hasWordCoreParts && parts.isHollow)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.hollowWordComponents,
          severity: ProvenanceSeverity.notable,
          label: application,
        ),
      if (fragmentation.indicatesSyntheticSplitting)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.syntheticRunFragmentation,
          severity: ProvenanceSeverity.notable,
          values: {
            'count': fragmentation.affectedRuns,
            'runs': fragmentation.runs,
          },
        ),
      if (unusedWeb > 0)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.webStyleResidue,
          severity: ProvenanceSeverity.notable,
          values: {'count': unusedWeb},
        ),
      // 少量未登記可能來自從別份文件複製的段落；過半且達一定數量才算
      if (unregistered.length >= minUnregisteredRsids &&
          unregistered.length * 2 >= rsids.length)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.unregisteredRsids,
          severity: ProvenanceSeverity.notable,
          values: {'count': unregistered.length, 'total': rsids.length},
        ),
    ];

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
        generatorHints: hints,
        fileSignals: fileSignals,
        minimalPackage: package.isMinimal,
        distinctBodyRsids: rsids.isEmpty ? null : rsids.length,
        rsidMap: buildRsidMap(document, countWords),
        bodyWordCount: countWords(bodyText),
        sourceFormat: ext,
      ),
    );
  }

  /// PDF 沒有編輯歷程，但產生器欄位（資訊字典的 Creator／Producer、XMP 的
  /// CreatorTool）會說明是哪個軟體或程式庫做出這份檔案。[supplied] 是 PDF
  /// 函式庫讀到的值（可讀壓縮物件串流），優先於原始位元組解析。
  static DocumentProvenance _fromPdf(
    List<int> bytes,
    String bodyText,
    String ext,
    PdfMetadata supplied,
  ) {
    final metadata = supplied.mergedWith(PdfMetadata.parse(bytes));
    final values = metadata.values;
    String? aiValue;
    for (final value in values) {
      if (aiGeneratorPattern.hasMatch(value)) {
        aiValue = value;
        break;
      }
    }
    final application = aiValue ?? metadata.primary;
    return _withSignals(
      DocumentProvenance(
        application: application,
        generatorHints: [
          for (final value in values)
            if (value != application) value,
        ],
        fileSignals: [
          ..._libraryAndC2pa(values, [bytes]),
          ..._textArtifacts(bodyText, [
            latin1.decode(bytes, allowInvalid: true),
          ]),
          ?_quartzSignal(metadata.producer),
          ..._pdfStructureSignals(PdfStructure.analyze(bytes)),
        ],
        bodyWordCount: countWords(bodyText),
        sourceFormat: ext,
      ),
    );
  }

  /// 原生 AI 痕跡：正文裡的對話引用標記，以及正文或 [rawSources]
  /// （超連結目標、PDF 原始位元組）中的 AI 搜尋導流連結。各格式共用。
  static List<ProvenanceSignal> _textArtifacts(
    String bodyText,
    List<String> rawSources,
  ) {
    final citations = ChatCitationArtifacts.count(bodyText);
    // 正文與原始來源會重複出現同一個連結，取兩者較大者而非相加
    final referrals = [
      AiReferralLinks.count([bodyText]),
      AiReferralLinks.count(rawSources),
    ].reduce((a, b) => a > b ? a : b);
    return [
      if (citations > 0)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.chatCitationArtifact,
          severity: ProvenanceSeverity.strong,
          values: {'count': citations},
        ),
      if (referrals > 0)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.aiReferralLink,
          severity: ProvenanceSeverity.notable,
          values: {'count': referrals},
        ),
    ];
  }

  static ProvenanceSignal? _quartzSignal(String? producer) =>
      switch (QuartzProducer.check(producer)) {
        QuartzProducerCheck.missingBuild => ProvenanceSignal(
          kind: ProvenanceSignalKind.forgedPdfProducer,
          severity: ProvenanceSeverity.notable,
          label: producer,
        ),
        // 組建號與版本對不上：不是格式差異，是兩個欄位各自被填寫
        QuartzProducerCheck.buildMismatch => ProvenanceSignal(
          kind: ProvenanceSignalKind.forgedPdfProducer,
          severity: ProvenanceSeverity.strong,
          label: producer,
        ),
        _ => null,
      };

  /// PDF 修訂歷程與結構的洗滌痕跡
  static List<ProvenanceSignal> _pdfStructureSignals(PdfStructure structure) {
    final earlier = structure.rewrittenFrom;
    return [
      // 舊版本原封不動留在檔案裡，改寫前的值直接可讀：邏輯上的確證
      if (earlier != null)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.pdfProducerRewritten,
          severity: ProvenanceSeverity.strong,
          label: '$earlier → ${structure.infoProducer}',
        ),
      if (structure.infoContradictsXmp)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.pdfInfoXmpConflict,
          severity: ProvenanceSeverity.notable,
          label: structure.xmpProducer,
        ),
      if (structure.quartzStructureMismatch)
        const ProvenanceSignal(
          kind: ProvenanceSignalKind.pdfStructureMismatch,
          severity: ProvenanceSeverity.notable,
        ),
    ];
  }

  /// 程式庫產生與 C2PA 內容憑證，DOCX 與 PDF 共用
  static List<ProvenanceSignal> _libraryAndC2pa(
    List<String> generatorValues,
    List<List<int>> media,
  ) {
    final library = matchProgrammaticLibrary(generatorValues);
    String? c2pa;
    var c2paFound = false;
    for (final bytes in media) {
      final finding = C2paFinding.scan(bytes);
      if (finding == null) continue;
      c2paFound = true;
      c2pa ??= finding.generator;
    }
    return [
      if (library != null)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.programmaticLibrary,
          severity: ProvenanceSeverity.notable,
          label: library,
        ),
      if (c2paFound)
        ProvenanceSignal(
          kind: ProvenanceSignalKind.embeddedC2pa,
          severity: ProvenanceSeverity.info,
          label: c2pa,
        ),
    ];
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
        fileSignals: _textArtifacts(bodyText, const []),
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
    final cjk = RegExp(r'[㐀-䶿一-鿿぀-ヿ가-힯]').allMatches(trimmed).length;
    final latin = RegExp(r'[A-Za-zÀ-ɏЀ-ӿ]+').allMatches(trimmed).length;
    return cjk + latin;
  }

  /// 一般人持續打字的上限概估（字/分）。超過此值代表內容多半不是當場敲出來的。
  /// 取值偏寬鬆（世界級打字員短衝可達 150+，但無法在整份長文維持），
  /// 寧可漏報也不要誤報。
  static const int implausibleWordsPerMinute = 120;

  /// 編輯時長超過檔案存在時間的容許量。時鐘誤差、跨時區存檔都遠小於此值；
  /// 另要求超過存在時間的兩倍，長壽檔案不會因幾十分鐘的差距被標記。
  static const int lifetimeToleranceMinutes = 60;

  /// 未登記 RSID 至少要有這麼多個才判定為注入
  static const int minUnregisteredRsids = 5;

  /// 批次數少於此值時不比對存檔次數（[ProvenanceSignalKind.fewRevisions] 已涵蓋）
  static const int minSessionsForRevisionCheck = 10;

  /// 宣告字數比對：正文至少這麼長，且差距達此倍數才判定
  static const int minWordsForStatsCheck = 300;
  static const int statsMismatchFactor = 3;

  /// 依已填入的中繼資料推導訊號
  static DocumentProvenance _withSignals(DocumentProvenance base) {
    final signals = <ProvenanceSignal>[...base.fileSignals];
    final words = base.bodyWordCount;
    final minutes = base.editingDuration?.inMinutes;

    // 產生器宣告與字數無關：再短的檔案，寫著 Claude Docs 就是 Claude Docs
    final aiGenerator = matchAiGenerator(base.application, base.generatorHints);
    if (aiGenerator != null) {
      signals.add(
        ProvenanceSignal(
          kind: ProvenanceSignalKind.aiGeneratorDeclared,
          severity: ProvenanceSeverity.strong,
          label: aiGenerator,
        ),
      );
    }

    // 欄位一致性檢查與字數無關：洗滌工具一欄一欄獨立偽造，欄位之間的
    // 因果關係對不上，這在短文件上同樣成立。
    // 缺任一個日期就無從得知存在時間，不能當成 0
    final created = base.createdAt;
    final lifetime = created == null
        ? null
        : base.modifiedAt?.difference(created);
    if (minutes != null &&
        lifetime != null &&
        !lifetime.isNegative &&
        minutes > lifetime.inMinutes + lifetimeToleranceMinutes &&
        minutes > lifetime.inMinutes * 2) {
      signals.add(
        ProvenanceSignal(
          kind: ProvenanceSignalKind.editingTimeExceedsLifetime,
          severity: ProvenanceSeverity.strong,
          values: {'minutes': minutes, 'lifetime': lifetime.inMinutes},
        ),
      );
    }
    final sessions = base.distinctBodyRsids;
    final saves = base.revisionCount;
    if (sessions != null &&
        saves != null &&
        saves >= 1 &&
        sessions >= minSessionsForRevisionCheck &&
        sessions > saves * 3 + 5) {
      signals.add(
        ProvenanceSignal(
          kind: ProvenanceSignalKind.sessionsExceedRevisions,
          severity: ProvenanceSeverity.notable,
          values: {'sessions': sessions, 'revisions': saves},
        ),
      );
    }

    // 宣告字數與正文差距數倍：Word 存檔時重算統計，差距這麼大代表正文
    // 在 Word 之外被改寫。計字規則差異（中日韓逐字、標點）遠小於三倍。
    final declared = base.declaredWordCount;
    if (base.sourceFormat == 'docx' &&
        (base.application ?? '').toLowerCase().contains('microsoft') &&
        declared != null &&
        words >= minWordsForStatsCheck &&
        (declared * statsMismatchFactor < words ||
            declared > words * statsMismatchFactor)) {
      signals.add(
        ProvenanceSignal(
          kind: ProvenanceSignalKind.declaredStatsMismatch,
          severity: ProvenanceSeverity.notable,
          values: {'declared': declared, 'actual': words},
        ),
      );
    }

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
      } else if (base.rsidMap.isHighlyConcentrated) {
        // 相異批次數不算少，但字數高度集中在其中一批——這是「文件本身
        // 有正常的編輯歷程，但某一大段內容是一次貼進來的」的形態。
        // 只數相異 RSID 的舊做法完全看不到這種情況。
        final map = base.rsidMap;
        signals.add(
          ProvenanceSignal(
            kind: ProvenanceSignalKind.concentratedEditingBatch,
            severity: ProvenanceSeverity.notable,
            values: {
              'paragraphs': map.batches.first.paragraphIndices.length,
              'total': map.paragraphCount,
              'percent': (map.largestBatchShare * 100).round(),
            },
          ),
        );
      }

      // Word 每次存檔都寫 RSID 與 TotalTime；兩者皆無代表檔案不是在文書軟體
      // 裡編出來的。宣稱是 Word 卻沒有紀錄的情況屬於「被清除」，不在此列。
      final application = base.application?.toLowerCase() ?? '';
      // 只有最少必要部件的封裝（沒有設定與字型表）也是同一回事，
      // 而且比 RSID 更難被「另存新檔」抹掉
      if (base.sourceFormat == 'docx' &&
          !application.contains('microsoft') &&
          (base.minimalPackage ||
              (rsids == null && base.editingDuration == null))) {
        signals.add(
          ProvenanceSignal(
            kind: ProvenanceSignalKind.programmaticallyGenerated,
            severity: ProvenanceSeverity.notable,
            values: {'words': words},
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
      generatorHints: base.generatorHints,
      fileSignals: base.fileSignals,
      minimalPackage: base.minimalPackage,
      distinctBodyRsids: base.distinctBodyRsids,
      bodyWordCount: base.bodyWordCount,
      sourceFormat: base.sourceFormat,
      rsidMap: base.rsidMap,
      signals: signals,
    );
  }
}
