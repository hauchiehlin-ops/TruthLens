import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/model_catalog.dart';

/// 對隨 App 打包的 assets/model_catalog.json 做健全性檢查。
/// 曾發生過的問題（regression guard）：把「多語言 AI 偵測器」的下載網址誤填成
/// 情感分析模型（Xenova/*-sentiments-student，3 類 positive/neutral/negative），
/// 而非 AI-vs-人類的二元偵測器。該模型下載後會被當作 AI 偵測器使用，
/// 但實際輸出的是情感傾向，結果無意義。
void main() {
  final raw = File('assets/model_catalog.json').readAsStringSync();
  final catalog = ModelCatalog.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  test('catalog 可正確解析', () {
    expect(catalog.models, isNotEmpty);
    expect(catalog.forRole('transformer'), isNotNull);
  });

  test('regression: 不得指向已知的錯誤模型（情感分析而非 AI 偵測器）', () {
    const knownBad = ['sentiments-student', 'sentiment-analysis'];
    for (final model in catalog.models) {
      for (final v in model.variants) {
        for (final bad in knownBad) {
          expect(v.url ?? '', isNot(contains(bad)),
              reason: '${v.id} 的 url 疑似指向情感分析模型而非 AI 偵測器');
          expect(v.source, isNot(contains(bad)),
              reason: '${v.id} 的 source 疑似為情感分析模型');
        }
      }
    }
  });

  test('可下載且需要 tokenizer 的變體必須同時提供 tokenizer_url', () {
    for (final model in catalog.models) {
      for (final v in model.variants) {
        if (v.isDownloadable && v.tokenizer != 'none') {
          expect(v.tokenizerUrl, isNotNull,
              reason: '${v.id} 可下載但缺少 tokenizer_url，端上將無法推論');
        }
      }
    }
  });

  test('transformer 角色的可下載變體 tokenizer 類型須為目前支援的種類', () {
    const supported = {'bert-wordpiece', 'roberta-bpe'};
    final transformer = catalog.forRole('transformer')!;
    for (final v in transformer.variants) {
      if (v.isDownloadable) {
        expect(supported, contains(v.tokenizer),
            reason: '${v.id} 使用尚未支援的 tokenizer 類型 ${v.tokenizer}');
      }
    }
  });

  test('regression: url/tokenizer_url 不得指向開發機本地位址', () {
    // 曾發生：對抗模組 D 的 url 指向 127.0.0.1:8000（開發者本機測試伺服器），
    // 對任何真實使用者的裝置都是 Connection refused，永遠無法下載成功。
    // 尚未上架 host 時應設為 null（顯示「即將推出」），而非指向本機位址。
    const localHostMarkers = ['127.0.0.1', 'localhost', '0.0.0.0', '::1'];
    for (final model in catalog.models) {
      for (final v in model.variants) {
        for (final marker in localHostMarkers) {
          expect(v.url ?? '', isNot(contains(marker)),
              reason: '${v.id} 的 url 指向本機位址，真實使用者永遠無法下載');
          expect(v.tokenizerUrl ?? '', isNot(contains(marker)),
              reason: '${v.id} 的 tokenizer_url 指向本機位址，真實使用者永遠無法下載');
        }
      }
    }
  });
}
