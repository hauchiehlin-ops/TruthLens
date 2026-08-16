import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:truthlens/core/services/calibration_service.dart';

void main() {
  group('共形 p 值', () {
    test('分數低於所有校準樣本時 p 值最大（最不可疑）', () {
      final r = CalibrationService.conformal(0.05, [0.3, 0.4, 0.5, 0.6], 0.05);
      // 4 筆都 ≥ 0.05 → p = (1+4)/5 = 1.0
      expect(r.pValue, 1.0);
      expect(r.percentile, 0);
      expect(r.isFlagged, isFalse);
    });

    test('分數高於所有校準樣本時 p 值最小 1/(n+1)', () {
      final calib = List.generate(19, (i) => i / 100);
      final r = CalibrationService.conformal(0.99, calib, 0.05);
      expect(r.pValue, closeTo(1 / 20, 1e-9));
      expect(r.percentile, 100);
      expect(r.hasEnoughSamples, isTrue);
      expect(r.isFlagged, isTrue);
    });

    test('校準集不足以支撐所選 α 時一律不標記', () {
      // α=0.05 需要 19 筆，只給 10 筆
      final r = CalibrationService.conformal(0.99, List.filled(10, 0.1), 0.05);
      expect(r.hasEnoughSamples, isFalse);
      expect(r.isFlagged, isFalse, reason: '沒有統計保證時不得給紅燈');
    });

    test('空校準集不崩潰且不標記', () {
      final r = CalibrationService.conformal(0.9, const [], 0.05);
      expect(r.pValue, 1);
      expect(r.calibrationSize, 0);
      expect(r.isFlagged, isFalse);
    });

    test('所需樣本數符合 n ≥ 1/α − 1', () {
      expect(CalibrationService.requiredSamplesFor(0.05), 19);
      expect(CalibrationService.requiredSamplesFor(0.01), 99);
      expect(CalibrationService.requiredSamplesFor(0.10), 9);
    });
  });

  group('偽陽性率保證（經驗驗證）', () {
    test('真人樣本被標記的比例不超過 α', () {
      // 校準樣本與待測樣本來自同一分布（可交換），此時共形保證應成立。
      // 刻意用偏態分布，證明保證不依賴常態假設。
      final rng = Random(42);
      double draw() => pow(rng.nextDouble(), 3).toDouble();

      const alpha = 0.05;
      const trials = 4000;
      const calibrationSize = 99;
      var flagged = 0;

      for (var t = 0; t < trials; t++) {
        final calib = List.generate(calibrationSize, (_) => draw());
        final r = CalibrationService.conformal(draw(), calib, alpha);
        if (r.isFlagged) flagged++;
      }

      final rate = flagged / trials;
      // 保證是 P(flag) ≤ α；留一點取樣誤差的餘裕
      expect(
        rate,
        lessThanOrEqualTo(alpha + 0.015),
        reason: '偽陽性率 $rate 超出 α=$alpha 的保證',
      );
    });

    test('AI 樣本（分數明顯偏高）確實會被標記', () {
      final rng = Random(7);
      final calib = List.generate(99, (_) => rng.nextDouble() * 0.3);
      final r = CalibrationService.conformal(0.95, calib, 0.05);
      expect(r.isFlagged, isTrue);
    });
  });

  group('儲存', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('新增、移除、清空與重新載入', () async {
      final service = CalibrationService();
      await service.load();
      expect(service.size, 0);
      expect(service.hasEnoughSamples, isFalse);

      await service.addSample(0.2, label: '三年二班');
      await service.addSample(0.3);
      expect(service.size, 2);
      expect(service.samples.first.label, '三年二班');

      final id = service.samples.first.id;
      await service.removeSample(id);
      expect(service.size, 1);

      // 重新載入應保留資料
      final reloaded = CalibrationService();
      await reloaded.load();
      expect(reloaded.size, 1);
      expect(reloaded.samples.single.score, closeTo(0.3, 1e-9));

      await reloaded.clear();
      expect(reloaded.size, 0);
    });

    test('α 設定會夾在合法範圍並持久化', () async {
      final service = CalibrationService();
      await service.load();
      expect(service.alpha, CalibrationService.defaultAlpha);

      await service.setAlpha(0.5); // 超過上限
      expect(service.alpha, CalibrationService.maxAlpha);

      await service.setAlpha(0.10);
      final reloaded = CalibrationService();
      await reloaded.load();
      expect(reloaded.alpha, closeTo(0.10, 1e-9));
      expect(reloaded.requiredSamples, 9);
    });

    test('損毀的儲存項目被略過而非整批失敗', () async {
      SharedPreferences.setMockInitialValues({
        'calibration_samples': <String>[
          '{"id":"a","score":0.4,"label":"","addedAt":"2026-08-17T00:00:00.000"}',
          'not json at all',
          '{"id":"b"}', // 缺欄位
        ],
      });
      final service = CalibrationService();
      await service.load();
      expect(service.size, 1);
      expect(service.samples.single.id, 'a');
    });
  });
}
