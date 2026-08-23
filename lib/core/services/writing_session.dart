/// 寫作過程擷取。
///
/// 前面五項證據都是**事後**檢查已完成的檔案。本模組不同：它記錄文字**產生
/// 的過程**——擊鍵節奏、貼上事件、以及兩者之間的時間分佈。
///
/// 這是唯一不會被下一代模型追上的方法。一次貼上 2000 字與打了三小時，
/// 這個差別任何語言模型都偽造不了，因為它記錄的不是文字本身，
/// 而是文字如何出現在編輯器裡。
///
/// **代價要說清楚**：這需要寫作發生在應用程式內，是工作流改變而非演算法改進。
/// 它不適用於匯入既有檔案——那條路上能用的是文件來源證據（支柱 1）。
///
/// **隱私設計**：只記錄事件的**大小與時間**，不記錄輸入的內容。
/// 「在 14:03:22 貼上了 1,842 字」不需要知道那 1,842 字是什麼。
library;

/// 一次輸入事件的種類
enum InputEventKind {
  /// 逐字輸入
  typing,

  /// 一次貼上
  paste,

  /// 刪除
  deletion,
}

/// 單一輸入事件。刻意不含任何文字內容。
class InputEvent {
  final InputEventKind kind;

  /// 這次事件影響的字元數
  final int characters;

  /// 距離工作階段開始的毫秒數
  final int elapsedMs;

  const InputEvent({
    required this.kind,
    required this.characters,
    required this.elapsedMs,
  });

  Map<String, dynamic> toJson() => {
    'k': kind.name,
    'c': characters,
    't': elapsedMs,
  };

  static InputEvent? fromJson(Map<String, dynamic> j) {
    final kind = InputEventKind.values
        .where((k) => k.name == j['k'])
        .firstOrNull;
    final characters = (j['c'] as num?)?.toInt();
    final elapsed = (j['t'] as num?)?.toInt();
    if (kind == null || characters == null || elapsed == null) return null;
    return InputEvent(kind: kind, characters: characters, elapsedMs: elapsed);
  }
}

/// 一次寫作工作階段的摘要
class WritingSession {
  final List<InputEvent> events;

  const WritingSession({this.events = const []});

  static const WritingSession empty = WritingSession();

  bool get hasData => events.isNotEmpty;

  /// 工作階段總長度
  Duration get duration => events.isEmpty
      ? Duration.zero
      : Duration(milliseconds: events.last.elapsedMs);

  int get typedCharacters => events
      .where((e) => e.kind == InputEventKind.typing)
      .fold(0, (sum, e) => sum + e.characters);

  int get pastedCharacters => events
      .where((e) => e.kind == InputEventKind.paste)
      .fold(0, (sum, e) => sum + e.characters);

  /// 貼上內容佔最終文字的比例
  double get pastedRatio {
    final total = typedCharacters + pastedCharacters;
    return total == 0 ? 0 : pastedCharacters / total;
  }

  /// 單次貼上的最大字元數。這比總比例更有指示性——
  /// 分十次貼入引用與一次貼入整篇，是完全不同的行為。
  int get largestPaste => events
      .where((e) => e.kind == InputEventKind.paste)
      .fold(0, (max, e) => e.characters > max ? e.characters : max);

  /// 刪除量。近乎為零的修改是「寫好才貼進來」的特徵——
  /// 真正的寫作過程幾乎必然包含反覆修改。
  int get deletedCharacters => events
      .where((e) => e.kind == InputEventKind.deletion)
      .fold(0, (sum, e) => sum + e.characters);

  /// 單次貼上超過這個字元數即視為整段匯入
  static const int bulkPasteThreshold = 400;

  /// 是否存在整段貼上的行為
  bool get hasBulkPaste => largestPaste >= bulkPasteThreshold;

  /// 文字只是透過貼上移入工作區，沒有觀察到任何實際撰寫或修改過程。
  ///
  /// 這只能說明取得方式，不能說明作者身分。外部文件不論由人或 AI 撰寫，
  /// 貼進編輯器時都會留下完全相同的事件，因此不得列為 AI 證據。
  bool get isTransferOnly =>
      hasBulkPaste && typedCharacters == 0 && deletedCharacters == 0;

  /// 是否真的觀察到可用於作者判讀的逐步撰寫活動。
  bool get hasObservedComposition =>
      typedCharacters > 0 || deletedCharacters > 0;

  /// 過程是否與「在此逐步寫成」相符。
  ///
  /// 三個條件同時成立才算：沒有整段貼上、貼上佔比低、有實質的刪改。
  /// 缺任何一項都不宣稱——這個證據的價值來自它的嚴格。
  bool get consistentWithLiveWriting {
    if (!hasData) return false;
    if (!hasObservedComposition) return false;
    if (hasBulkPaste) return false;
    if (pastedRatio > 0.20) return false;
    // 真正的寫作幾乎必然包含反覆修改；完全沒有刪除很可疑
    final total = typedCharacters + pastedCharacters;
    return total > 0 && deletedCharacters >= total * 0.02;
  }
}

/// 累積輸入事件的記錄器。
///
/// 由編輯器在每次文字變動時呼叫 [record]，它以**長度差**推斷事件種類，
/// 因此不需要接觸輸入的內容。
class WritingSessionRecorder {
  final List<InputEvent> _events = [];
  DateTime? _startedAt;
  int _lastLength = 0;

  /// 一次輸入超過這個字元數即判定為貼上而非打字。
  /// 取 8 是因為輸入法（注音、拼音、日文 IME）一次上屏可能有數個字元，
  /// 但不會到八個。
  static const int pasteHeuristicThreshold = 8;

  WritingSession get session => WritingSession(events: List.of(_events));

  /// 清空紀錄，並把目前編輯器長度設為新的起點。
  ///
  /// 匯入文件或 OCR 結果時必須用 [initialLength] 建立起點，否則使用者下一次
  /// 只輸入一個字，會被誤判成「一次貼上整份文件」。
  void reset({int initialLength = 0}) {
    _events.clear();
    _startedAt = null;
    _lastLength = initialLength;
  }

  /// 從既有工作階段繼續記錄。用於從原始輸入頁切到整合工作台後，保留先前
  /// 已蒐集的事件，同時讓後續編修繼續接在同一條時間軸上。
  void resume({required int currentLength, required WritingSession session}) {
    _events
      ..clear()
      ..addAll(session.events);
    _lastLength = currentLength;
    _startedAt = session.hasData
        ? DateTime.now().subtract(session.duration)
        : null;
  }

  /// 記錄一次文字變動。[length] 為變動後的總字元數。
  void record(int length, {DateTime? at}) {
    final now = at ?? DateTime.now();
    _startedAt ??= now;
    final elapsed = now.difference(_startedAt!).inMilliseconds;
    final delta = length - _lastLength;
    _lastLength = length;

    if (delta == 0) return;
    if (delta < 0) {
      _events.add(
        InputEvent(
          kind: InputEventKind.deletion,
          characters: -delta,
          elapsedMs: elapsed,
        ),
      );
      return;
    }
    _events.add(
      InputEvent(
        kind: delta >= pasteHeuristicThreshold
            ? InputEventKind.paste
            : InputEventKind.typing,
        characters: delta,
        elapsedMs: elapsed,
      ),
    );
  }
}
