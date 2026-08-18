/// 本地校準集與共形預測（conformal prediction）。
///
/// 商用偵測器只能拿全球通用的門檻套在所有人身上，因此對非母語寫作有系統性
/// 偽陽性。本地執行的優勢在於：可以用**這個班級自己的已知人類寫作**當虛無
/// 分布，把「這份文章有多異常」變成相對於同儕的統計問題。
///
/// 共形預測給的是**分布無關**的保證：若校準樣本與待測樣本可交換
/// （exchangeable），則對真正由人撰寫的文章，p 值 ≤ α 的機率不超過 α。
/// 換句話說，α 就是偽陽性率上限，而且不必假設分數服從任何特定分布。
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../utils/language_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 樣本標籤的來源。決定它能不能進入共形預測的虛無分布。
enum SampleOrigin {
  /// 使用者手動標註
  manual,

  /// 由文件編輯紀錄（RSID／編輯時長／存檔次數）自動判定為人類撰寫。
  /// 這個判斷**獨立於文字分類器**，因此不會造成循環論證，可安全納入虛無分布。
  provenance,

  /// 自動蒐集，但沒有任何獨立的標籤依據（例如貼上的純文字）。
  /// **只用於描述性百分位，絕不進入共形預測**——把偵測器自己的判定拿來當
  /// 虛無分布會讓它永遠無法發現自己錯了。
  observed,
}

/// 一筆已知標籤的基準樣本
@immutable
class CalibrationSample {
  final String id;

  /// 該樣本經同一套引擎算出的整體 AI 機率
  final double score;

  /// 是否為已知的 AI 產出。共形預測只用人類樣本（虛無分布），
  /// AI 樣本則供第 4 項的權重學習衡量鑑別力。
  final bool isAi;

  /// 各引擎當時的個別分數（engineId → 機率），供權重學習使用。
  /// 舊版樣本沒有此欄位，會是空 Map。
  final Map<String, double> engineScores;

  /// 標籤來源，決定是否納入共形預測
  final SampleOrigin origin;

  /// 樣本原文。**預設不保存**——只有使用者在設定中明確開啟「保留原文以供
  /// 離線驗證」時才會填入。共形預測本身只需要分數，原文純粹是為了能把
  /// 實戰中累積的語料匯出、餵進 training/binoculars 的離線評測管線。
  final String? text;

  /// 使用者自訂的標示（例如「三年二班 期中作業」），可留空
  final String label;

  /// 樣本的語言代碼（見 detectLanguage）。共形預測的可交換性假設要求
  /// 校準集與待測樣本來自同一分布——不同語言的分數分布並不相同，
  /// 拿中文文件去跟一個多半由英文文件構成的基準集比對，p 值不具意義。
  /// 舊版樣本沒有此欄位，會是 [DetectedLanguage.undetermined]，
  /// 不歸入任何語言的基準集。
  final String language;

  final DateTime addedAt;

  const CalibrationSample({
    required this.id,
    required this.score,
    required this.addedAt,
    this.label = '',
    this.language = DetectedLanguage.undetermined,
    this.isAi = false,
    this.engineScores = const {},
    this.text,
    this.origin = SampleOrigin.manual,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'score': score,
    'label': label,
    'language': language,
    'isAi': isAi,
    'engineScores': engineScores,
    'addedAt': addedAt.toIso8601String(),
    'origin': origin.name,
    if (text != null) 'text': text,
  };

  static CalibrationSample? fromJson(Map<String, dynamic> json) {
    final score = (json['score'] as num?)?.toDouble();
    final id = json['id'] as String?;
    final addedAt = DateTime.tryParse(json['addedAt'] as String? ?? '');
    if (score == null || id == null || addedAt == null) return null;
    final rawEngines = json['engineScores'];
    return CalibrationSample(
      id: id,
      score: score.clamp(0.0, 1.0),
      label: json['label'] as String? ?? '',
      // 舊版樣本沒有語言欄位；標為未定而不是猜一個，猜錯會污染基準集
      language: json['language'] as String? ?? DetectedLanguage.undetermined,
      isAi: json['isAi'] as bool? ?? false,
      engineScores: rawEngines is Map
          ? {
              for (final e in rawEngines.entries)
                if (e.value is num)
                  e.key.toString(): (e.value as num).toDouble(),
            }
          : const {},
      text: json['text'] as String?,
      // 舊版樣本沒有 origin 欄位，一律視為手動標註（當時只有這條路徑）
      origin: SampleOrigin.values.firstWhere(
        (o) => o.name == json['origin'],
        orElse: () => SampleOrigin.manual,
      ),
      addedAt: addedAt,
    );
  }
}

/// 共形預測的輸出
@immutable
class ConformalResult {
  /// 保守 p 值：(1 + 校準集中分數 ≥ 待測分數的筆數) / (n + 1)
  final double pValue;

  /// 待測分數在校準集中的百分位（0-100），供直觀理解
  final int percentile;

  /// 本次採用的校準樣本數
  final int calibrationSize;

  /// 偽陽性率上限設定
  final double alpha;

  /// 校準集是否足以支撐所選的 α（需 n ≥ 1/α − 1）
  final bool hasEnoughSamples;

  const ConformalResult({
    required this.pValue,
    required this.percentile,
    required this.calibrationSize,
    required this.alpha,
    required this.hasEnoughSamples,
  });

  /// 在此 α 下是否應標記。校準集不足時一律不標記——寧可不判，
  /// 也不要給一個沒有統計保證的紅燈。
  bool get isFlagged => hasEnoughSamples && pValue <= alpha;
}

/// 校準集的儲存與共形計算
class CalibrationService extends ChangeNotifier {
  static const _kSamples = 'calibration_samples';
  static const _kAlpha = 'calibration_alpha';
  static const _kStoreText = 'calibration_store_text';
  static const _kAutoCollect = 'calibration_auto_collect';

  /// 預設偽陽性率上限 5%
  static const double defaultAlpha = 0.05;
  static const double minAlpha = 0.01;
  static const double maxAlpha = 0.20;

  SharedPreferences? _prefs;
  List<CalibrationSample> _samples = const [];
  double _alpha = defaultAlpha;
  bool _storeText = false;
  bool _autoCollect = true;

  /// 分析完成後是否自動蒐集校準樣本。預設開啟——這是讓基準集能靠日常使用
  /// 自然累積的關鍵，且自動蒐集本身不會影響統計保證（標籤來源仍受把關）。
  bool get autoCollectEnabled => _autoCollect;

  /// 是否連同原文一起保存。預設關閉：原文是敏感資料（多為學生作業），
  /// 只有在使用者明確要蒐集離線驗證語料時才該開啟。
  bool get storeText => _storeText;

  /// 已保有原文的樣本數，供設定頁顯示
  int get samplesWithText => _samples.where((s) => s.text != null).length;

  List<CalibrationSample> get samples => List.unmodifiable(_samples);

  /// 進入共形虛無分布的人類樣本：**只收標籤來源獨立於文字分類器者**
  /// （手動標註，或由文件編輯紀錄判定）。
  ///
  /// 刻意排除 [SampleOrigin.observed]：那些是靠偵測器自己的判定收進來的，
  /// 拿來當虛無分布等於循環論證——被誤判為 AI 的真人文章永遠進不了基準集，
  /// 分布會在低分端被人為壓緊、門檻偏低，反而標記更多真人作業。
  List<CalibrationSample> get humanSamples => _samples
      .where((s) => !s.isAi && s.origin != SampleOrigin.observed)
      .toList();

  /// 指定語言的人類樣本，也就是該語言真正的虛無分布。
  ///
  /// 共形預測的保證建立在可交換性上：校準樣本與待測樣本必須來自同一分布。
  /// 不同語言的分數分布並不相同（引擎本身對各語言的靈敏度就不一樣），
  /// 把它們混成一鍋，p 值就不再對應任何偽陽性率上限。語言未定的樣本
  /// 不歸入任何語言——不知道它屬於哪個分布，就不能拿它當虛無分布。
  List<CalibrationSample> humanSamplesFor(String language) {
    if (language == DetectedLanguage.undetermined) return const [];
    return humanSamples.where((s) => s.language == language).toList();
  }

  /// 各語言目前累積的人類樣本數，供設定頁誠實呈現「哪個語言已經夠了」
  Map<String, int> get humanSampleCountByLanguage {
    final counts = <String, int>{};
    for (final sample in humanSamples) {
      if (sample.language == DetectedLanguage.undetermined) continue;
      counts[sample.language] = (counts[sample.language] ?? 0) + 1;
    }
    return counts;
  }

  /// 尚未帶語言標記的舊樣本數。這些樣本無法歸入任何語言的基準集，
  /// 介面需要能說明它們為何不算數。
  int get unlabelledLanguageCount => humanSamples
      .where((s) => s.language == DetectedLanguage.undetermined)
      .length;

  /// 自動蒐集但無獨立標籤依據的樣本，只用於描述性百分位
  List<CalibrationSample> get observedSamples =>
      _samples.where((s) => s.origin == SampleOrigin.observed).toList();

  /// 由文件編輯紀錄自動納入的份數，供介面說明「背景已收了多少」
  int get autoAdmittedCount =>
      _samples.where((s) => s.origin == SampleOrigin.provenance).length;

  /// 已知 AI 樣本，僅供權重學習
  List<CalibrationSample> get aiSamples =>
      _samples.where((s) => s.isAi).toList();

  /// 共形預測的樣本數＝人類樣本數（AI 樣本不屬於虛無分布）。
  /// 這是跨語言的總數，僅供概覽；實際做共形預測時一律用
  /// [humanSamplesFor] 取該語言自己的樣本。
  int get size => humanSamples.length;

  /// 指定語言的共形樣本數
  int sizeFor(String language) => humanSamplesFor(language).length;
  double get alpha => _alpha;

  /// 要讓 α 真的可達，最小 p 值 1/(n+1) 必須 ≤ α，因此 n ≥ 1/α − 1。
  /// 例如 α=0.05 需要至少 19 筆；α=0.01 需要 99 筆。
  static int requiredSamplesFor(double alpha) {
    if (alpha <= 0) return 1 << 30;
    return (1 / alpha - 1).ceil();
  }

  int get requiredSamples => requiredSamplesFor(_alpha);
  bool get hasEnoughSamples => size >= requiredSamples;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getStringList(_kSamples) ?? const [];
    _samples = raw
        .map((entry) {
          try {
            return CalibrationSample.fromJson(
              jsonDecode(entry) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<CalibrationSample>()
        .toList();
    _alpha = (_prefs!.getDouble(_kAlpha) ?? defaultAlpha).clamp(
      minAlpha,
      maxAlpha,
    );
    _storeText = _prefs!.getBool(_kStoreText) ?? false;
    _autoCollect = _prefs!.getBool(_kAutoCollect) ?? true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs?.setStringList(
      _kSamples,
      _samples.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<void> setAutoCollect(bool value) async {
    _autoCollect = value;
    await _prefs?.setBool(_kAutoCollect, value);
    notifyListeners();
  }

  Future<void> setStoreText(bool value) async {
    _storeText = value;
    await _prefs?.setBool(_kStoreText, value);
    notifyListeners();
  }

  /// 把已保存的原文全部清掉，但保留分數（共形預測不受影響）。
  /// 讓使用者能在匯出完語料後立刻移除敏感內容。
  Future<void> clearStoredText() async {
    _samples = [
      for (final s in _samples)
        CalibrationSample(
          id: s.id,
          score: s.score,
          label: s.label,
          isAi: s.isAi,
          engineScores: s.engineScores,
          origin: s.origin,
          addedAt: s.addedAt,
        ),
    ];
    await _persist();
    notifyListeners();
  }

  /// 使用者手動標註
  /// [language] 未指定時，若有原文則就地辨識，否則留為未定。
  /// 未定的樣本不會進入任何語言的虛無分布——這是刻意的，見 [humanSamplesFor]。
  Future<void> addSample(
    double score, {
    String label = '',
    bool isAi = false,
    Map<String, double> engineScores = const {},
    String? text,
    String? language,
  }) => _add(
    score: score,
    isAi: isAi,
    engineScores: engineScores,
    text: text,
    label: label,
    language: language ?? (text == null ? null : detectLanguage(text).code),
    origin: SampleOrigin.manual,
  );

  Future<void> _add({
    required double score,
    required bool isAi,
    required Map<String, double> engineScores,
    required String? text,
    required String label,
    required SampleOrigin origin,
    String? language,
  }) async {
    _samples = [
      ..._samples,
      CalibrationSample(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        score: score.clamp(0.0, 1.0),
        label: label,
        isAi: isAi,
        engineScores: engineScores,
        // 原文可能不保存（預設不存），但語言必須在收樣當下就記下來，
        // 事後無從補算——這正是舊樣本沒有語言標記的原因。
        language: language ?? DetectedLanguage.undetermined,
        text: _storeText ? text : null,
        origin: origin,
        addedAt: DateTime.now(),
      ),
    ];
    await _persist();
    notifyListeners();
  }

  Future<void> removeSample(String id) async {
    _samples = _samples.where((s) => s.id != id).toList();
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _samples = const [];
    await _persist();
    notifyListeners();
  }

  Future<void> setAlpha(double value) async {
    _alpha = value.clamp(minAlpha, maxAlpha);
    await _prefs?.setDouble(_kAlpha, _alpha);
    notifyListeners();
  }

  /// 以 [language] 的校準集評估 [score]。
  ///
  /// 只拿人類樣本當虛無分布——把 AI 樣本混進去會把分布往高分推，
  /// 反而讓真正的 AI 文章更不容易被標記。也只拿**同語言**的樣本：
  /// 跨語言混用會破壞可交換性，讓 α 不再是偽陽性率上限。
  ConformalResult evaluate(double score, String language) => conformal(
    score,
    humanSamplesFor(language).map((s) => s.score).toList(),
    _alpha,
  );

  /// [score] 在**所有已分析文件**中的百分位。這是純描述性的參考值，
  /// 不帶任何統計保證，因此與共形結果分開回傳、分開呈現。
  int? observedPercentile(double score, String language) {
    if (language == DetectedLanguage.undetermined) return null;
    final all = _samples
        .where((s) => s.language == language)
        .map((s) => s.score)
        .toList();
    if (all.length < 5) return null;
    final below = all.where((s) => s < score).length;
    return (below / all.length * 100).round();
  }

  /// 分析完成後由背景呼叫：依**獨立證據**決定要不要自動收進基準集。
  ///
  /// 回傳實際採用的來源，供介面誠實說明這一份是怎麼被分類的。
  Future<SampleOrigin> autoCollect({
    required double score,
    required bool provenanceIndicatesHuman,
    required String language,
    Map<String, double> engineScores = const {},
    String? text,
    String label = '',
  }) async {
    final origin = provenanceIndicatesHuman
        ? SampleOrigin.provenance
        : SampleOrigin.observed;
    await _add(
      score: score,
      isAi: false,
      engineScores: engineScores,
      text: text,
      label: label,
      language: language,
      origin: origin,
    );
    return origin;
  }

  /// 純函式版本，方便直接測試。
  ///
  /// 採用**保守**（conservative）的共形 p 值定義：
  ///   p = (1 + #{校準分數 ≥ 待測分數}) / (n + 1)
  /// 分子與分母都加 1，是為了把待測樣本自己算進去；這正是讓
  /// 「P(p ≤ α) ≤ α」對真正的人類樣本成立的關鍵，不能省略。
  static ConformalResult conformal(
    double score,
    List<double> calibrationScores,
    double alpha,
  ) {
    final n = calibrationScores.length;
    final required = requiredSamplesFor(alpha);
    if (n == 0) {
      return ConformalResult(
        pValue: 1,
        percentile: 0,
        calibrationSize: 0,
        alpha: alpha,
        hasEnoughSamples: false,
      );
    }

    final atLeastAsExtreme = calibrationScores.where((s) => s >= score).length;
    final pValue = (1 + atLeastAsExtreme) / (n + 1);
    final below = calibrationScores.where((s) => s < score).length;

    return ConformalResult(
      pValue: pValue,
      percentile: (below / n * 100).round(),
      calibrationSize: n,
      alpha: alpha,
      hasEnoughSamples: n >= required,
    );
  }
}
