import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omnitrace/core/services/calibration_service.dart';
import 'package:omnitrace/core/utils/language_id.dart';

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

    test('AI 樣本不進入共形虛無分布，只有人類樣本算數', () async {
      final service = CalibrationService();
      await service.load();

      // 25 份人類樣本（低分）
      for (var i = 0; i < 25; i++) {
        await service.addSample(0.1 + i * 0.001, language: 'en');
      }
      // 10 份 AI 樣本（高分）
      for (var i = 0; i < 10; i++) {
        await service.addSample(0.95, isAi: true, language: 'en');
      }

      expect(service.size, 25, reason: 'size 應只計人類樣本');
      expect(service.aiSamples.length, 10);

      // 若把 AI 樣本混進虛無分布，0.9 的 p 值會被推高而不再被標記
      final r = service.evaluate(0.9, 'en');
      expect(r.calibrationSize, 25);
      expect(r.isFlagged, isTrue);
    });

    test('逐引擎分數會一併持久化，供權重學習使用', () async {
      final service = CalibrationService();
      await service.load();
      await service.addSample(
        0.4,
        language: 'en',
        engineScores: const {'transformer': 0.5, 'statistical': 0.3},
      );

      final reloaded = CalibrationService();
      await reloaded.load();
      expect(reloaded.samples.single.engineScores['transformer'], 0.5);
      expect(reloaded.samples.single.engineScores['statistical'], 0.3);
    });

    test('清除保存原文時保留語言與共形基準資格', () async {
      final service = CalibrationService();
      await service.load();
      await service.setStoreText(true);
      await service.addSample(
        0.2,
        language: 'zh',
        text: '這是一份已知由真人撰寫並保留作為本地校準用途的中文樣本。',
      );

      expect(service.samples.single.text, isNotNull);
      expect(service.sizeFor('zh'), 1);

      await service.clearStoredText();

      expect(service.samples.single.text, isNull);
      expect(service.samples.single.language, 'zh');
      expect(service.sizeFor('zh'), 1);
    });

    test('observed 樣本不得進入共形虛無分布（防循環論證）', () async {
      final service = CalibrationService();
      await service.load();

      // 25 份由編輯紀錄自動認定的人類樣本（獨立證據，可用）
      for (var i = 0; i < 25; i++) {
        await service.autoCollect(
          score: 0.1 + i * 0.001,
          provenanceIndicatesHuman: true,
          language: 'en',
        );
      }
      // 50 份沒有獨立依據、僅靠偵測器判定收進來的樣本
      for (var i = 0; i < 50; i++) {
        await service.autoCollect(
          score: 0.05,
          provenanceIndicatesHuman: false,
          language: 'en',
        );
      }

      expect(service.autoAdmittedCount, 25);
      expect(service.observedSamples.length, 50);
      // 虛無分布只認 25 份，不是 75 份
      expect(service.size, 25);
      expect(service.evaluate(0.9, 'en').calibrationSize, 25);
    });

    test('autoCollect 依獨立證據決定來源，並回報實際採用的分類', () async {
      final service = CalibrationService();
      await service.load();

      expect(
        await service.autoCollect(
          score: 0.2,
          provenanceIndicatesHuman: true,
          language: 'en',
        ),
        SampleOrigin.provenance,
      );
      expect(
        await service.autoCollect(
          score: 0.2,
          provenanceIndicatesHuman: false,
          language: 'en',
        ),
        SampleOrigin.observed,
      );
      // 自動蒐集一律標為人類候選，不會憑判定結果自行標成 AI
      expect(service.aiSamples, isEmpty);
    });

    test('描述性百分位涵蓋全部樣本，且樣本過少時不給數字', () async {
      final service = CalibrationService();
      await service.load();
      expect(
        service.observedPercentile(0.5, 'en'),
        isNull,
        reason: '不足 5 筆不應給百分位',
      );

      for (var i = 0; i < 10; i++) {
        await service.autoCollect(
          score: i / 10,
          provenanceIndicatesHuman: false,
          language: 'en',
        );
      }
      // 0.55 高於 0.0–0.5 這 6 筆
      expect(service.observedPercentile(0.55, 'en'), 60);
    });

    test('舊版樣本沒有 origin 欄位時視為手動標註，仍計入虛無分布', () async {
      SharedPreferences.setMockInitialValues({
        'calibration_samples': <String>[
          '{"id":"old","score":0.3,"label":"","addedAt":"2026-08-17T00:00:00.000"}',
        ],
      });
      final service = CalibrationService();
      await service.load();
      expect(service.samples.single.origin, SampleOrigin.manual);
      expect(service.size, 1);
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

    test('基準集逐語言分開：中文文件不得拿英文樣本當虛無分布', () async {
      final service = CalibrationService();
      await service.load();

      // 30 份英文人類樣本，分數集中在低分區
      for (var i = 0; i < 30; i++) {
        await service.addSample(0.10 + i * 0.001, language: 'en');
      }

      expect(service.sizeFor('en'), 30);
      expect(service.sizeFor('zh'), 0);

      // 同一個分數，在英文基準下會被標記；中文沒有基準，不得沿用英文的結論
      expect(service.evaluate(0.9, 'en').isFlagged, isTrue);
      final zh = service.evaluate(0.9, 'zh');
      expect(zh.calibrationSize, 0);
      expect(zh.hasEnoughSamples, isFalse);
    });

    test('各語言樣本數分開統計', () async {
      final service = CalibrationService();
      await service.load();
      for (var i = 0; i < 3; i++) {
        await service.addSample(0.2, language: 'zh');
      }
      for (var i = 0; i < 5; i++) {
        await service.addSample(0.2, language: 'en');
      }

      expect(service.humanSampleCountByLanguage, {'zh': 3, 'en': 5});
      expect(service.size, 8, reason: '總數仍為跨語言合計');
    });

    test('語言未定的樣本不歸入任何語言，且可被清點出來', () async {
      final service = CalibrationService();
      await service.load();
      await service.addSample(0.2); // 無原文亦無語言
      await service.addSample(0.2, language: 'en');

      expect(service.unlabelledLanguageCount, 1);
      expect(service.sizeFor('en'), 1);
      expect(service.humanSamplesFor(DetectedLanguage.undetermined), isEmpty);
    });

    test('有原文時自動辨識語言，不必呼叫端指定', () async {
      final service = CalibrationService();
      await service.load();
      await service.addSample(
        0.2,
        text:
            '本研究採用泰勒庫埃特流場作為實驗載體，透過改變內外圓筒的轉速比，'
            '觀察環狀渦漩在臨界雷諾數附近的形態轉換過程與穩定性邊界的變化。',
      );
      expect(service.humanSampleCountByLanguage, {'zh': 1});
    });

    test('舊版樣本沒有語言欄位時標為未定，不污染任何語言的基準集', () async {
      SharedPreferences.setMockInitialValues({
        'calibration_samples': <String>[
          '{"id":"old","score":0.3,"label":"","addedAt":"2026-08-17T00:00:00.000"}',
        ],
      });
      final service = CalibrationService();
      await service.load();

      expect(service.size, 1);
      expect(service.sizeFor('en'), 0);
      expect(service.unlabelledLanguageCount, 1);
    });

    test('正式共形結果只採用同管線、領域與長度級距的樣本', () async {
      final service = CalibrationService();
      await service.load();
      for (var i = 0; i < 19; i++) {
        await service.addSample(
          0.10 + i * 0.001,
          language: 'en',
          analysisSignature: 'fusion-v3|model-a',
          domain: 'academic',
          lengthBucket: 'long',
        );
      }
      await service.addSample(
        0.99,
        language: 'en',
        analysisSignature: 'fusion-v3|model-b',
        domain: 'academic',
        lengthBucket: 'long',
      );

      final matched = service.evaluateFor(
        score: 0.95,
        language: 'en',
        analysisSignature: 'fusion-v3|model-a',
        domain: 'academic',
        lengthBucket: 'long',
      );
      final mismatched = service.evaluateFor(
        score: 0.95,
        language: 'en',
        analysisSignature: 'fusion-v3|model-a',
        domain: 'general',
        lengthBucket: 'long',
      );

      expect(matched.calibrationSize, 19);
      expect(matched.isFlagged, isTrue);
      expect(mismatched.isApplicable, isFalse);
      expect(mismatched.calibrationSize, 0);
    });
  });
}
