import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/perplexity_calibration.dart';
import 'package:omnitrace/core/utils/language_id.dart';
import 'package:omnitrace/core/utils/text_stats.dart';

/// 迴歸測試：一篇真實的英文學術 PDF 論文，困惑度指標必須被採計。
///
/// 實際發生過的回退：同一份文件先前得 15%「人類撰寫」，後來變成 40%「混合內容」。
/// 成因是困惑度那份**支持人類**的證據被丟掉了——
/// 先前 0.5 − 0.25（困惑度 304 > 150 偏人類）− 0.10（詞彙多樣性高）= 0.15，
/// 之後只剩 0.5 − 0.10 = 0.40。困惑度一旦因語言判定失敗而棄用，
/// 分數會**往 AI 方向漂**，因為被丟掉的是反向證據。
void main() {
  late String paper;

  setUpAll(() {
    paper = File('test/fixtures/ijbc_paper.txt').readAsStringSync();
  });

  test('真實英文學術 PDF 會被判為英文', () {
    final detected = detectLanguage(paper);
    expect(
      detected.code,
      'en',
      reason:
          'PDF 抽出的文字帶有字距損傷（BOUNDAR Y、ROTA TING、a n dW .M .Y A N G），'
          '功能詞剖面仍須撐得住',
    );
  });

  test('PreprocessedText 帶出的語言與直接辨識一致', () {
    final text = PreprocessedText.from(paper);
    expect(text.language.code, 'en');
  });

  test('真實 PDF 的版面換行不會成為即時卡片的句子碎片', () {
    final text = PreprocessedText.from(paper);

    expect(
      text.sentences,
      contains(
        'In this study, we numerically investigate the lowest instability '
        'boundary of nonaxisymmetric Taylor vortex ﬂow (TVF) for diﬀerent '
        'axial wavenumbers.',
      ),
    );
    expect(
      text.sentences.where((sentence) => sentence == 'is' || sentence == 'and'),
      isEmpty,
    );
  });

  test('英文在現行困惑度模型下有可用門檻，指標不得被跳過', () {
    final text = PreprocessedText.from(paper);
    final calibration = PerplexityCalibration.of(
      text.language.code,
      modelId: defaultPerplexityModelId,
    );
    expect(calibration, isNotNull, reason: '查不到門檻就會跳過困惑度，而困惑度在這份文件上是支持人類的證據');
    expect(calibration!.aiCut, 60);
    expect(calibration.humanCut, isNull);
  });

  test('換上多語模型後英文同樣有門檻，不因切換模型而失去指標', () {
    final text = PreprocessedText.from(paper);
    expect(
      PerplexityCalibration.of(text.language.code, modelId: 'qwen05b-ppl-int8'),
      isNotNull,
    );
  });

  test('學術論文的參考文獻段落單獨拿出來仍不至於誤判語言', () {
    // 書目段落功能詞稀薄，是最容易掉進 und 的區段
    final tail = paper.substring((paper.length * 0.85).round());
    final detected = detectLanguage(tail);
    expect(
      [tail.isEmpty ? 'und' : 'en', 'und'],
      contains(detected.code),
      reason: '書目段落判為 en 或 und 都可接受，但不得判成其他語言',
    );
  });

  _uncalibratedMessages();
}

/// 三種「困惑度不採計」的原因必須講不同的話。
/// 先前一律套用中日韓文那段說明，導致一篇英文論文被告知「對中日韓文而言……」。
void _uncalibratedMessages() {
  group('不採計困惑度的三種原因分開陳述', () {
    test('量測過但鑑別力不足（DistilGPT2 對中文）', () {
      expect(PerplexityCalibration.hasRecord('zh'), isTrue);
      expect(PerplexityCalibration.of('zh'), isNull);
    });

    test('該「模型 × 語言」組合從未量測（DistilGPT2 對日文）', () {
      expect(PerplexityCalibration.hasRecord('ja'), isFalse);
      expect(PerplexityCalibration.of('ja'), isNull);
    });

    test('語言無法判定', () {
      expect(
        PerplexityCalibration.hasRecord(DetectedLanguage.undetermined),
        isFalse,
      );
    });

    test('換模型後同一語言的紀錄狀態可能完全不同', () {
      // 中文在 DistilGPT2 下是「量過但沒用」，在 Qwen 下是「可用」
      expect(PerplexityCalibration.of('zh'), isNull);
      expect(
        PerplexityCalibration.of('zh', modelId: 'qwen05b-ppl-int8'),
        isNotNull,
      );
    });
  });
}
