// 量測各證據家族在不同文件領域的實際誤報率與召回率，作為
// `AnalysisProfile.domainReliability` 固定折扣（學術 0.55／0.68／0.72）的替代依據。
//
// 刻意放在 tool/ 而不是 test/：預設的 `flutter test` 不會執行它，只在手上有
// 標註語料時才跑。只量不需 ONNX 模型的確定性引擎（風格規則層＋詞彙指紋、
// 統計啟發式），因為 Transformer 與困惑度已有各自的 Python 評測管線。
//
// 用法（語料格式同 binoculars/prepare_corpus.py、App 校準匯出、
// build_proposal_register.py 的 proposal_register_binoculars.jsonl）：
//
//   flutter test tool/measure_domain_reliability_test.dart \
//     --dart-define=CORPUS=/abs/path/corpus.jsonl \
//     --dart-define=REPORT=/abs/path/domain_reliability.json
//
// 語料必須是**完整文件**（含標題、摘要、參考文獻），領域判定才看得到這些標記。
// build_proposal_register.py 的切塊已剝掉標題，拿它來量會全部落在 general。
//
// 每個「領域 × 家族」至少要有 30 份 human 與 30 份 AI 文件才給建議值；
// 樣本不足時明確標記 insufficient，不補猜測值。
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/analysis_profile.dart';
import 'package:omnitrace/core/detection/engines/statistical_engine.dart';
import 'package:omnitrace/core/detection/engines/stylometry_engine.dart';
import 'package:omnitrace/core/detection/evidence_fusion.dart';
import 'package:omnitrace/core/utils/text_stats.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

const _corpusPath = String.fromEnvironment('CORPUS');
const _reportPath = String.fromEnvironment('REPORT');
const _minimumDocsPerClass = 30;

class _Tally {
  int human = 0;
  int ai = 0;
  int humanFlaggedAi = 0;
  int aiFlaggedAi = 0;
  int humanFlaggedHuman = 0;

  double get fpr => human == 0 ? 0 : humanFlaggedAi / human;
  double get recall => ai == 0 ? 0 : aiFlaggedAi / ai;
  double get youden => recall - fpr;
  bool get sufficient =>
      human >= _minimumDocsPerClass && ai >= _minimumDocsPerClass;

  Map<String, Object> toJson() => {
    'human_docs': human,
    'ai_docs': ai,
    'false_positive_rate': fpr,
    'recall': recall,
    'human_side_votes_on_human': humanFlaggedHuman,
    'youden_j': youden,
    'sufficient': sufficient,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('measure domain reliability', () async {
    if (_corpusPath.isEmpty) {
      markTestSkipped('未指定 --dart-define=CORPUS=…');
      return;
    }
    final lines = File(_corpusPath)
        .readAsLinesSync()
        .where((line) => line.trim().isNotEmpty);
    // 同一份文件的多個切塊合併回整份，量的是文件級判讀。
    final documents = <String, ({bool isAi, StringBuffer text})>{};
    for (final line in lines) {
      final row = jsonDecode(line) as Map<String, dynamic>;
      final id = (row['doc_id'] ?? row['id']).toString();
      final isAi = row['label'] == 'ai' || row['label'] == 1;
      documents
          .putIfAbsent(id, () => (isAi: isAi, text: StringBuffer()))
          .text
          .writeln(row['text']);
    }

    final engines = [StylometryEngine(), StatisticalEngine()];
    final tallies = <String, Map<String, _Tally>>{};
    // 結構特徵不投票，這裡只蒐集 human／AI 兩側的分布，供日後判斷是否值得啟用。
    final structure = <String, Map<String, List<double>>>{};
    for (final doc in documents.values) {
      final raw = doc.text.toString();
      final text = PreprocessedText.from(raw);
      final profile = AnalysisProfile.fromText(raw);
      final side = doc.isAi ? 'ai' : 'human';
      StylometryEngine.documentStructureFeatures(raw).forEach((key, value) {
        structure
            .putIfAbsent('${profile.domain.name}/$key', () => {})
            .putIfAbsent(side, () => [])
            .add(value);
      });
      for (final engine in engines) {
        final score = await engine.analyze(text, l10n);
        // 不帶領域折扣評估，量到的才是該領域的原始表現。
        final fusion = TextEvidenceFusion.evaluate(
          scores: [score],
          inputText: raw,
          profile: AnalysisProfile(
            language: profile.language,
            domain: AnalysisDomain.general,
            wordCount: profile.wordCount,
            sentenceCount: profile.sentenceCount,
            inputQuality: profile.inputQuality,
          ),
        );
        final family = score.resolvedEvidenceFamily.name;
        final tally = tallies
            .putIfAbsent(profile.domain.name, () => {})
            .putIfAbsent(family, _Tally.new);
        final votesAi = fusion.aiSupportingFamilies > 0;
        final votesHuman = fusion.humanSupportingFamilies > 0;
        if (doc.isAi) {
          tally.ai++;
          if (votesAi) tally.aiFlaggedAi++;
        } else {
          tally.human++;
          if (votesAi) tally.humanFlaggedAi++;
          if (votesHuman) tally.humanFlaggedHuman++;
        }
      }
    }

    // 建議值＝該領域 Youden J ÷ 一般領域 Youden J，夾在 0.25–1。
    // 一般領域樣本不足時沒有比較基準，只輸出原始指標。
    final report = <String, Object>{};
    for (final domain in tallies.entries) {
      final perFamily = <String, Object>{};
      for (final family in domain.value.entries) {
        final baseline = tallies['general']?[family.key];
        final canSuggest =
            family.value.sufficient &&
            baseline != null &&
            baseline.sufficient &&
            baseline.youden > 0;
        perFamily[family.key] = {
          ...family.value.toJson(),
          'suggested_reliability': canSuggest
              ? (family.value.youden / baseline.youden).clamp(0.25, 1.0)
              : 'insufficient',
        };
      }
      report[domain.key] = perFamily;
    }
    final encoded = const JsonEncoder.withIndent('  ').convert({
      'corpus': _corpusPath,
      'documents': documents.length,
      'minimum_docs_per_class': _minimumDocsPerClass,
      'domains': report,
      'structure_features': {
        for (final entry in structure.entries)
          entry.key: {
            for (final side in entry.value.entries)
              side.key: {
                'n': side.value.length,
                'mean':
                    side.value.reduce((a, b) => a + b) / side.value.length,
              },
          },
      },
    });
    if (_reportPath.isNotEmpty) File(_reportPath).writeAsStringSync(encoded);
    // ignore: avoid_print
    print(encoded);
  });
}
