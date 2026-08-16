/// 把實戰中累積的校準語料匯出，餵進 `training/binoculars` 的離線評測管線。
///
/// 這是「邊跑邊驗證」的關鍵一環：教師在日常使用中把確定由學生本人撰寫的
/// 作業標為 human、把 AI 產出標為 ai，語料就會自然累積；累積到足夠份數後
/// 匯出成 JSONL，即可直接跑階段一評測，不必另外辦一次資料蒐集。
///
/// 輸出格式**刻意與 `prepare_corpus.py` 的輸出完全一致**，因此可直接接
/// `run_binoculars.py`，中間不需要任何轉檔。
library;

import 'dart:convert';
import 'dart:typed_data';

import 'calibration_service.dart';

class CalibrationExporter {
  /// 匯出結果與過程中被略過的原因，供介面誠實回報
  static ExportPayload buildJsonl(List<CalibrationSample> samples) {
    final lines = <String>[];
    var missingText = 0;

    for (final sample in samples) {
      final text = sample.text;
      // 沒有原文的樣本無法用於離線評測（Binoculars 需要逐詞元機率），
      // 靜默略過會讓使用者以為匯出成功卻拿到半套資料，因此明確計數回報。
      if (text == null || text.trim().isEmpty) {
        missingText++;
        continue;
      }
      lines.add(
        jsonEncode({
          'id': sample.id,
          // 一筆校準樣本即一份獨立文件，doc_id 與 id 相同；
          // 離線端據此判定獨立文件數，這正是樣本量把關的依據。
          'doc_id': sample.id,
          'label': sample.isAi ? 'ai' : 'human',
          'source': sample.label.isEmpty ? 'in-app' : sample.label,
          'words': _countWords(text),
          'text': text,
        }),
      );
    }

    return ExportPayload(
      bytes: Uint8List.fromList(utf8.encode(lines.join('\n'))),
      exported: lines.length,
      skippedMissingText: missingText,
      humanCount: samples
          .where((s) => !s.isAi && (s.text?.trim().isNotEmpty ?? false))
          .length,
      aiCount: samples
          .where((s) => s.isAi && (s.text?.trim().isNotEmpty ?? false))
          .length,
    );
  }

  /// 與離線端 `DocumentProvenance.countWords` 同一套規則：
  /// CJK 逐字計，其他語言以詞計。兩端一致才不會出現字數對不上的困惑。
  static int _countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    final cjk = RegExp(r'[㐀-䶿一-鿿぀-ヿ가-힯]').allMatches(trimmed).length;
    final latin = RegExp(r'[A-Za-zÀ-ɏЀ-ӿ]+').allMatches(trimmed).length;
    return cjk + latin;
  }
}

class ExportPayload {
  final Uint8List bytes;
  final int exported;
  final int skippedMissingText;
  final int humanCount;
  final int aiCount;

  const ExportPayload({
    required this.bytes,
    required this.exported,
    required this.skippedMissingText,
    required this.humanCount,
    required this.aiCount,
  });

  bool get isEmpty => exported == 0;

  /// 離線評測每類需要的獨立文件數，與 `evaluate.py` 的 MIN_DOCS_PER_CLASS 一致
  static const int minDocsPerClass = 30;

  bool get readyForEvaluation =>
      humanCount >= minDocsPerClass && aiCount >= minDocsPerClass;
}
