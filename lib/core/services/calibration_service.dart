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
import 'package:shared_preferences/shared_preferences.dart';

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

  /// 使用者自訂的標示（例如「三年二班 期中作業」），可留空
  final String label;

  final DateTime addedAt;

  const CalibrationSample({
    required this.id,
    required this.score,
    required this.addedAt,
    this.label = '',
    this.isAi = false,
    this.engineScores = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'score': score,
    'label': label,
    'isAi': isAi,
    'engineScores': engineScores,
    'addedAt': addedAt.toIso8601String(),
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
      isAi: json['isAi'] as bool? ?? false,
      engineScores: rawEngines is Map
          ? {
              for (final e in rawEngines.entries)
                if (e.value is num)
                  e.key.toString(): (e.value as num).toDouble(),
            }
          : const {},
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

  /// 預設偽陽性率上限 5%
  static const double defaultAlpha = 0.05;
  static const double minAlpha = 0.01;
  static const double maxAlpha = 0.20;

  SharedPreferences? _prefs;
  List<CalibrationSample> _samples = const [];
  double _alpha = defaultAlpha;

  List<CalibrationSample> get samples => List.unmodifiable(_samples);

  /// 已知人類樣本，共形預測的虛無分布只用這些
  List<CalibrationSample> get humanSamples =>
      _samples.where((s) => !s.isAi).toList();

  /// 已知 AI 樣本，僅供權重學習
  List<CalibrationSample> get aiSamples =>
      _samples.where((s) => s.isAi).toList();

  /// 共形預測的樣本數＝人類樣本數（AI 樣本不屬於虛無分布）
  int get size => humanSamples.length;
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
    notifyListeners();
  }

  Future<void> _persist() async {
    await _prefs?.setStringList(
      _kSamples,
      _samples.map((s) => jsonEncode(s.toJson())).toList(),
    );
  }

  Future<void> addSample(
    double score, {
    String label = '',
    bool isAi = false,
    Map<String, double> engineScores = const {},
  }) async {
    _samples = [
      ..._samples,
      CalibrationSample(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        score: score.clamp(0.0, 1.0),
        label: label,
        isAi: isAi,
        engineScores: engineScores,
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

  /// 以目前校準集評估 [score]。只拿人類樣本當虛無分布——把 AI 樣本混進去
  /// 會把分布往高分推，反而讓真正的 AI 文章更不容易被標記。
  ConformalResult evaluate(double score) =>
      conformal(score, humanSamples.map((s) => s.score).toList(), _alpha);

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
