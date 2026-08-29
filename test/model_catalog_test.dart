import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// 隨 App 打包的 catalog 是模型接線的唯一真相來源，
/// 而接線錯誤會**靜默失效**——模型照樣下載、照樣推論，只是輸出全是垃圾。
///
/// 實際發生過：多語偵測器（distilbert，WordPiece，詞表 119547）被配上
/// RoBERTa 的 byte-level BPE tokenizer，token ID 全對不上，
/// 輸出全擠在 0.5 附近。沒有任何錯誤訊息，只是引擎再也不出聲。
void main() {
  late Map<String, dynamic> catalog;

  setUpAll(() {
    catalog =
        jsonDecode(File('assets/model_catalog.json').readAsStringSync())
            as Map<String, dynamic>;
  });

  List<Map<String, dynamic>> variantsOf(String role) {
    final model = (catalog['models'] as List).firstWhere(
      (m) => (m as Map)['role'] == role,
    );
    return ((model as Map)['variants'] as List).cast<Map<String, dynamic>>();
  }

  test('分類器變體的 tokenizer 型別必須是 buildTokenizer 支援的', () {
    // 只檢查走 buildTokenizer 的分類器角色。statistical 角色由
    // PerplexityScorer 直接使用 BpeTokenizer，不經過該工廠函式，
    // 其 'gpt2-bpe' 標籤是描述性的。
    const classifierRoles = {'transformer', 'adversarial'};
    const supported = {'bert-wordpiece', 'roberta-bpe', 'none'};
    for (final role in classifierRoles) {
      for (final variant in variantsOf(role)) {
        expect(
          supported,
          contains(variant['tokenizer']),
          reason:
              '${variant['id']} 的 tokenizer「${variant['tokenizer']}」不受支援。'
              'buildTokenizer 對未知型別會靜默退回 WordPiece，'
              '詞表對不上也不會報錯。SentencePiece Unigram（XLM-RoBERTa）'
              '需先在 Dart 實作才能使用。',
        );
      }
    }
  });

  test('tokenizer 型別必須與模型底座相符', () {
    // 判斷依據取自變體自身的 source/id 描述，避免模型與 tokenizer 各說各話
    for (final variant in variantsOf('transformer')) {
      final source = '${variant['source']} ${variant['id']}'.toLowerCase();
      final tokenizer = variant['tokenizer'] as String;
      if (source.contains('bert') && !source.contains('roberta')) {
        expect(
          tokenizer,
          'bert-wordpiece',
          reason: '${variant['id']} 是 BERT 系底座，必須用 WordPiece',
        );
      }
      if (source.contains('roberta')) {
        expect(
          tokenizer,
          'roberta-bpe',
          reason: '${variant['id']} 是 RoBERTa 系底座，必須用 byte-level BPE',
        );
      }
    }
  });

  test('模型與其 tokenizer 必須來自同一來源，不得跨模型借用', () {
    // 借用別的模型的 tokenizer＝詞表不同＝token ID 全錯，而且不會報錯
    for (final variant in variantsOf('transformer')) {
      final url = variant['url'] as String?;
      final tokenizerUrl = variant['tokenizer_url'] as String?;
      if (url == null || tokenizerUrl == null) continue;
      expect(
        _repositoryOf(tokenizerUrl),
        _repositoryOf(url),
        reason:
            '${variant['id']} 的模型與 tokenizer 來自不同 repo。'
            '詞表不同會讓 token ID 全部對不上，且不會有任何錯誤訊息。',
      );
    }
  });

  test('可下載的變體都必須標明語言、量化方式與 AI 類別索引', () {
    for (final variant in variantsOf('transformer')) {
      if ((variant['url'] as String?)?.isEmpty ?? true) continue;
      expect(
        variant['languages'],
        isNotEmpty,
        reason: '${variant['id']} 未標明語言',
      );
      expect(variant['quant'], isNotEmpty, reason: '${variant['id']} 未標明量化');
      expect(
        variant['ai_label_index'],
        anyOf(0, 1),
        reason: '${variant['id']} 的 AI 類別索引無效——取錯會讓判定完全顛倒',
      );
      final evidenceThreshold =
          (variant['ai_evidence_threshold'] as num?)?.toDouble() ?? 0.60;
      expect(
        evidenceThreshold,
        inInclusiveRange(0.50, 1.0),
        reason: '${variant['id']} 的 AI 證據門檻必須是可解釋的機率值',
      );
    }
  });

  test('現代中文變體使用獨立校準門檻，舊 HC3 變體不得宣稱中文已驗證', () {
    final variants = variantsOf('transformer');
    final modern = variants.firstWhere(
      (v) => v['id'] == 'aigc-detector-zhv3-int8',
    );
    final legacy = variants.firstWhere(
      (v) => v['id'] == 'truthlens-mbert-multilingual-int8',
    );

    expect(modern['languages'], contains('zh'));
    // 0.97 由 NLPCC-2025 dev 校準、在 SemEval 中文上報告：誤報上界 0.22%、
    // 召回 27.4%。前一版的 0.99 是語料內數字，外部召回只有 9.0%。
    expect(modern['ai_evidence_threshold'], 0.97);
    expect(legacy['languages'], isNot(contains('zh')));
  });

  test('多語言變體排在英文專用變體之前（品質優先）', () {
    final variants = variantsOf('transformer');
    final firstMultilingual = variants.indexWhere(
      (v) => (v['languages'] as List).contains('multi'),
    );
    final firstEnglishOnly = variants.indexWhere(
      (v) =>
          (v['languages'] as List).length == 1 &&
          (v['languages'] as List).first == 'en',
    );
    if (firstMultilingual >= 0 && firstEnglishOnly >= 0) {
      expect(
        firstMultilingual,
        lessThan(firstEnglishOnly),
        reason: '純英文模型對中日韓文結構上無效，不該排在多語模型之前',
      );
    }
  });

  test('模型來源必須支援瀏覽器 CORS，不得使用 GitHub Releases', () {
    // GitHub Releases 的資產最終由 Azure Blob 經 Fastly 提供，
    // 完全不回 access-control-allow-origin，瀏覽器 fetch() 一律被阻擋。
    // App 雖有 Edge 代理備援，但本機開發環境（flutter run -d web-server）
    // 沒有 /api/proxy，等於完全下載不了——實測 2026-08-19 確認。
    for (final model in catalog['models'] as List) {
      for (final v in ((model as Map)['variants'] as List)) {
        final variant = v as Map<String, dynamic>;
        for (final key in ['url', 'tokenizer_url']) {
          final url = variant[key] as String?;
          if (url == null || url.isEmpty) continue;
          expect(
            Uri.parse(url).host,
            isNot(anyOf('github.com', 'objects.githubusercontent.com')),
            reason:
                '${variant['id']} 的 $key 指向 GitHub Releases，'
                '該來源無 CORS 標頭。請改用 HuggingFace 等支援 CORS 的主機，'
                'GitHub Releases 只作封存鏡像。',
          );
        }
      }
    }
  });
}

/// 取出下載網址所屬的 repo 識別（HuggingFace repo 或 GitHub owner/repo）
String _repositoryOf(String url) {
  final uri = Uri.parse(url);
  final segments = uri.pathSegments;
  if (segments.length < 2) return uri.host;
  return '${uri.host}/${segments[0]}/${segments[1]}';
}
