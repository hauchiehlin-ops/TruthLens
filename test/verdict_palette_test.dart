import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/models/detection_result.dart';
import 'package:omnitrace/shared/widgets/verdict_palette.dart';

/// WCAG 相對亮度
double _luminance(Color c) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(c.r) + 0.7152 * channel(c.g) + 0.0722 * channel(c.b);
}

/// 白色文字在 [background] 上的對比度
double _contrastWithWhite(Color background) =>
    1.05 / (_luminance(background) + 0.05);

void main() {
  test('五級都有專屬底色，沒有任何兩級共用', () {
    final values = Verdict.values.map(verdictColor).toSet();
    expect(values.length, Verdict.values.length);
  });

  test('白字在所有底色與作用態上都達 WCAG AA（4.5:1）', () {
    // 調色時最容易悄悄破壞的就是對比度——提亮作用態尤其危險
    for (final verdict in Verdict.values) {
      for (final entry in {
        '底色': verdictColor(verdict),
        '作用態': verdictActiveChipColor(verdict),
      }.entries) {
        expect(
          _contrastWithWhite(entry.value),
          greaterThanOrEqualTo(4.5),
          reason: '${verdict.name} 的${entry.key}白字對比不足',
        );
      }
    }
  });

  test('作用態必須明顯亮於底色，否則會消失在同色相的卡片背景裡', () {
    for (final verdict in Verdict.values) {
      expect(
        _luminance(verdictActiveChipColor(verdict)),
        greaterThan(_luminance(verdictColor(verdict)) * 1.5),
        reason: '${verdict.name} 的作用態與底色亮度太接近',
      );
    }
  });

  test('色階保有明度差，色盲使用者可由深淺分辨順序', () {
    // 只靠色相區分對紅綠色盲無效；相鄰級距的亮度必須有可辨差異
    final luminances = Verdict.values
        .map((v) => _luminance(verdictColor(v)))
        .toList();
    for (var i = 1; i < luminances.length; i++) {
      expect(
        (luminances[i] - luminances[i - 1]).abs(),
        greaterThan(0.004),
        reason:
            '${Verdict.values[i - 1].name} 與 ${Verdict.values[i].name} 明度太接近',
      );
    }
  });

  test('漸層與底色同色相，不引入第二個訊息來源', () {
    for (final verdict in Verdict.values) {
      final gradient = verdictGradient(verdict);
      expect(gradient.colors.length, 2);
      // 終點即基準色，起點只做提亮
      expect(gradient.colors.last, verdictColor(verdict));
      expect(
        _luminance(gradient.colors.first),
        greaterThan(_luminance(gradient.colors.last)),
      );
    }
  });

  test('非作用態保留自身色相，讓整條色階讀得出來', () {
    for (final verdict in Verdict.values) {
      final idle = verdictIdleChipColor(verdict);
      final base = verdictColor(verdict);
      expect(idle.a, lessThan(1.0), reason: '非作用態應退居背景');
      // 色相不變：RGB 分量比例與基準色一致
      expect(idle.r, closeTo(base.r, 0.001));
      expect(idle.g, closeTo(base.g, 0.001));
      expect(idle.b, closeTo(base.b, 0.001));
    }
  });

  test('切點與判定共用同一個來源，PDF 與畫面不會分岔', () {
    // report_exporter 以 Verdict.fromProbability 取級距後查同一張表
    expect(
      verdictColor(Verdict.fromProbability(0.10)),
      verdictColor(Verdict.human),
    );
    expect(
      verdictColor(Verdict.fromProbability(0.30)),
      verdictColor(Verdict.likelyHuman),
    );
    expect(
      verdictColor(Verdict.fromProbability(0.50)),
      verdictColor(Verdict.mixed),
    );
    expect(
      verdictColor(Verdict.fromProbability(0.70)),
      verdictColor(Verdict.likelyAi),
    );
    expect(
      verdictColor(Verdict.fromProbability(0.90)),
      verdictColor(Verdict.ai),
    );
  });
}
