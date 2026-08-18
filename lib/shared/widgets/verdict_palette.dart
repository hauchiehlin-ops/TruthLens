/// 五級判定的配色。
///
/// 目的是讓判定「一眼可辨」，因此五級各有專屬色相而非只有深淺差異。
///
/// 刻意**不用紅綠燈配色**：綠燈紅燈帶有「合格／不合格」的價值判斷，而這個
/// 量表量的是「人類←→AI」的位置，不是好壞。改用單向漸變的序列色階，
/// 從深青綠經藏青、古銅金、赭橙到深絳紅，中段沿用專案的金色調
/// （深青紫金），讓色階本身就表達「在量表上的位置」。
///
/// 所有底色與其提亮後的作用態都經 WCAG 計算驗證，白字對比全數達 AA（≥4.5:1）
/// 且留有餘裕——`Color.lerp` 的浮點插值與離線試算會有千分位差異，
/// 貼著門檻取色會讓測試在不同 Flutter 版本上飄。
/// 色階同時保有明度差，色盲使用者仍可由深淺分辨順序。
library;

import 'package:flutter/material.dart';

import '../../core/models/detection_result.dart';

/// 各級的基準底色
const Map<Verdict, Color> verdictBaseColors = {
  Verdict.human: Color(0xFF12503F), // 深青綠
  Verdict.likelyHuman: Color(0xFF1E3A5F), // 藏青（沿用報告原本的主色）
  Verdict.mixed: Color(0xFF5E400A), // 古銅金
  Verdict.likelyAi: Color(0xFF7E3813), // 赭橙
  Verdict.ai: Color(0xFF7A1B33), // 深絳紅
};

/// 判定的基準色
Color verdictColor(Verdict verdict) => verdictBaseColors[verdict]!;

/// 判定摘要卡的背景漸層。與基準色同色相，只做明度變化，
/// 避免漸層本身變成第二個訊息來源。
LinearGradient verdictGradient(Verdict verdict) {
  final base = verdictColor(verdict);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color.lerp(base, Colors.white, 0.12)!, base],
  );
}

/// 作用中的級距在卡片上的底色。
///
/// 卡片背景已經是該級的色相，若作用中的籌碼用同一個色值就會消失在背景裡，
/// 因此往白色插值 22% 提亮——這個比例是取「明顯浮出背景」與
/// 「白字仍達 WCAG AA」兩者的交集。
Color verdictActiveChipColor(Verdict verdict) =>
    Color.lerp(verdictColor(verdict), Colors.white, 0.22)!;

/// 非作用中的級距底色。壓到低不透明度以退居背景，但保留自身色相，
/// 讓整條色階讀得出來——這才是五級並列的意義。
Color verdictIdleChipColor(Verdict verdict) =>
    verdictColor(verdict).withValues(alpha: 0.45);
