import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/detection/analysis_profile.dart';
import 'package:omnitrace/core/detection/domain_evidence.dart';
import 'package:omnitrace/core/detection/model_catalog.dart';
import 'package:omnitrace/core/detection/model_display_names.dart';
import 'package:omnitrace/core/detection/model_manager.dart';
import 'package:omnitrace/core/detection/variant_router.dart';
import 'package:omnitrace/core/services/analysis_plan.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';

DomainEvidence _general(
  double recall, {
  double upper = 0.002,
  int n = 2000,
  String corpus = 'c',
}) => DomainEvidence(
  domain: 'general',
  language: 'zh',
  corpus: corpus,
  recall: recall,
  aiDocuments: n,
  humanDocuments: n,
  fprUpper95: upper,
);

const _probe = DomainEvidence(
  domain: 'academic',
  language: 'zh',
  corpus: 'probe',
  recall: 0,
  aiDocuments: 1,
);

InstalledModel _m(
  String id,
  List<String> languages, [
  List<DomainEvidence> domains = const [],
]) => InstalledModel(
  role: 'transformer',
  variantId: id,
  fileName: '$id.onnx',
  version: '1',
  sizeBytes: 1,
  languages: languages,
  domains: domains,
);

final _strong = _m(
  'zh-strong',
  ['zh'],
  [_general(0.73), _general(0.90), _general(0.54), _probe],
);
final _weak = _m(
  'zh-weak',
  ['zh'],
  [
    // 召回最高但誤報上界超出 1% 預算：不得當排序依據
    _general(0.77, upper: 0.0109),
    _general(0.31),
    _general(0.27),
    _probe,
  ],
);

const _academicZh =
    '本研究採用方法目的鏈與結構方程模式，並以資料探勘補足消費者異質性（Wedel & Kannan, 2016）。'
    '研究方法分為三階段，研究結果將以預先註冊的程序驗證（Athey & Imbens, 2016）。'
    '參考文獻依 APA 格式列出（Simmons et al., 2011）。';

void main() {
  group('依文體與實測排序', () {
    test('自動模式不看安裝順序，選守住誤報預算且召回較高者', () {
      final choice = chooseVariant(
        installed: [_weak, _strong],
        language: 'zh',
        domain: 'academic',
      );
      expect(choice.variant, _strong);
      expect(choice.basis, RoutingBasis.measuredGeneral);
      expect(choice.domainFit.matchesDomain, isFalse);
      // 三份一般語料皆在預算內
      expect(
        choice.domainFit.meanRecall,
        closeTo((0.73 + 0.90 + 0.54) / 3, 1e-9),
      );
    });

    test('超出 1% 誤報預算的紀錄不參與平均', () {
      final fit = DomainFit.of(_weak.domains, 'general', 'zh');
      expect(fit.ranked, hasLength(2));
      expect(fit.meanRecall, closeTo((0.31 + 0.27) / 2, 1e-9));
    });

    test('單篇探針只呈現、不排序，並產生說明文字', () {
      final fit = DomainFit.of(_strong.domains, 'academic', 'zh');
      expect(fit.observed, contains(_probe));
      expect(fit.ranked.contains(_probe), isFalse);
      final l10n = lookupAppLocalizations(const Locale('zh'));
      final notes = routingProbeNotes(
        chooseVariant(installed: [_strong], language: 'zh', domain: 'academic'),
        l10n,
      );
      expect(notes.single, contains('1'));
    });

    test('目標文體有足量實測時優先於一般語料', () {
      final academicExpert = _m(
        'zh-academic',
        ['zh'],
        [
          const DomainEvidence(
            domain: 'academic',
            language: 'zh',
            corpus: 'proposals',
            recall: 0.60,
            aiDocuments: 300,
            humanDocuments: 300,
            fprUpper95: 0.008,
          ),
        ],
      );
      final choice = chooseVariant(
        installed: [_strong, academicExpert],
        language: 'zh',
        domain: 'academic',
      );
      expect(choice.variant, academicExpert);
      expect(choice.basis, RoutingBasis.measuredDomain);
    });

    test('鎖定的模型語言適用時保留，即使實測較差', () {
      final choice = chooseVariant(
        installed: [_strong, _weak],
        language: 'zh',
        userActiveVariantId: 'zh-weak',
      );
      expect(choice.variant, _weak);
      expect(choice.basis, RoutingBasis.userPinned);
      expect(choice.overrodeUserChoice, isFalse);
    });

    test('鎖定的模型不支援此語言時改選並標記', () {
      final en = _m('en-only', ['en']);
      final choice = chooseVariant(
        installed: [en, _strong],
        language: 'zh',
        userActiveVariantId: 'en-only',
      );
      expect(choice.variant, _strong);
      expect(choice.overrodeUserChoice, isTrue);
    });

    test('語言不明時用預設模型，不靠猜', () {
      final choice = chooseVariant(
        installed: [_strong, _weak],
        language: null,
        defaultVariantId: 'zh-weak',
      );
      expect(choice.variant, _weak);
      expect(choice.basis, RoutingBasis.languageUnknown);
    });

    test('學術計畫書被判為 academic 文體', () {
      expect(AnalysisProfile.domainOf(_academicZh), AnalysisDomain.academic);
    });

    test('只有全形括號引文、沒有「研究方法」等字眼的中文論文段落也判為學術', () {
      const citationsOnly =
          '心流在虛擬實境中提升購買意願（Fang & Chung, 2024）。'
          '短影音的研究也有相同發現（Zhao & Wagner, 2022；Luarn et al., 2024）。'
          '但效果在不同族群間並不一致（Wager & Athey, 2018）。';
      expect(AnalysisProfile.domainOf(citationsOnly), AnalysisDomain.academic);
    });

    test('一般敘述不因單一括號年份被誤判為學術', () {
      const prose = '我們在（2024）年搬家，之後每週末都去市場買菜，生活步調慢了許多。';
      expect(AnalysisProfile.domainOf(prose), AnalysisDomain.general);
    });
  });

  group('打包 catalog 的 domains 欄位', () {
    late ModelCatalog catalog;
    setUpAll(() {
      catalog = ModelCatalog.fromJson(
        jsonDecode(File('assets/model_catalog.json').readAsStringSync())
            as Map<String, dynamic>,
      );
    });

    ModelVariant variant(String id) =>
        catalog.forRole('transformer')!.variants.firstWhere((v) => v.id == id);

    test('中文偵測器的實測紀錄可解析且數字對得上 validation 檔', () {
      final zh = variant('omnitrace-zh-detector-int8');
      final general = zh.domains.where((d) => d.domain == 'general').toList();
      expect(general, hasLength(3));
      expect(general.every((d) => d.usableForRanking), isTrue);
      expect(zh.domains.where((d) => d.domain == 'academic').single.recall, 0);
    });

    test('zhv3 的 DetectRL-X 紀錄超出誤報預算，不得用於排序', () {
      final zhv3 = variant('aigc-detector-zhv3-int8');
      final detectrl = zhv3.domains.firstWhere(
        (d) => d.corpus.contains('DetectRL'),
      );
      expect(detectrl.withinFprBudget, isFalse);
    });

    test('每筆紀錄都指回 training/validation 的實測檔', () {
      for (final model in catalog.models) {
        for (final v in model.variants) {
          for (final d in v.domains) {
            expect(
              File(d.source).existsSync(),
              isTrue,
              reason: '${v.id} 的 ${d.corpus} 指向不存在的 ${d.source}',
            );
          }
        }
      }
    });
  });

  group('手動／自動模式與分析計畫', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('routing_'));
    tearDown(() => dir.deleteSync(recursive: true));

    Future<ModelManager> manager(
      Map<String, InstalledModel> installed, {
      required String active,
      bool? manual,
    }) async {
      for (final m in installed.values) {
        File('${dir.path}/${m.fileName}').writeAsBytesSync([1, 2, 3]);
      }
      File('${dir.path}/installed.json').writeAsStringSync(
        jsonEncode({
          'transformer': {
            'active': active,
            'manual': ?manual,
            'installed': {
              for (final e in installed.entries) e.key: e.value.toJson(),
            },
          },
        }),
      );
      final mm = ModelManager(modelsDir: dir);
      await mm.refreshInstallStates();
      return mm;
    }

    test('舊版紀錄沒有 manual 欄位時預設為自動', () async {
      final mm = await manager({'zh-strong': _strong}, active: 'zh-strong');
      expect(mm.isManualSelection('transformer'), isFalse);
    });

    test('鎖定後重啟仍為手動，切回自動後解除', () async {
      final mm = await manager({
        'zh-strong': _strong,
        'zh-weak': _weak,
      }, active: 'zh-strong');
      await mm.setActive('transformer', 'zh-weak');
      expect(mm.isManualSelection('transformer'), isTrue);

      final restarted = ModelManager(modelsDir: dir);
      await restarted.refreshInstallStates();
      expect(restarted.isManualSelection('transformer'), isTrue);
      expect(restarted.activeVariant('transformer')?.variantId, 'zh-weak');

      await restarted.setAutoSelect('transformer');
      expect(restarted.isManualSelection('transformer'), isFalse);
    });

    test('刪除鎖定中的模型會回到自動', () async {
      final mm = await manager(
        {'zh-strong': _strong, 'zh-weak': _weak},
        active: 'zh-weak',
        manual: true,
      );
      await mm.removeVariant('transformer', 'zh-weak');
      expect(mm.isManualSelection('transformer'), isFalse);
    });

    test('分析計畫與引擎走同一路由：自動模式選實測較佳者', () async {
      final mm = await manager({
        'zh-weak': _weak,
        'zh-strong': _strong,
      }, active: 'zh-weak');
      final plan = AnalysisPlan.build(
        text: _academicZh,
        modelManager: mm,
        sourceFormat: 'DOCX',
        roles: const ['transformer'],
      );
      expect(plan.domain, AnalysisDomain.academic);
      expect(plan.sourceFormat, 'docx');
      expect(plan.roles.single.choice.variant?.variantId, 'zh-strong');
      expect(plan.roles.single.manual, isFalse);
    });

    test('有更適合但未安裝的模型時提出下載建議', () async {
      final mm = await manager({
        'multi': _m('multi', ['en', 'multi']),
      }, active: 'multi');
      final catalog = ModelCatalog.fromJson({
        'models': [
          {
            'role': 'transformer',
            'name': 't',
            'variants': [
              {
                'id': 'zh-strong',
                'name': 'zh',
                'backend': 'transformer',
                'languages': ['zh'],
                'size_bytes': 100,
                'min_ram_mb': 1,
                'tier': 'low',
                'url': 'https://example.invalid/zh.onnx',
              },
            ],
          },
        ],
      });
      final plan = AnalysisPlan.build(
        text: _academicZh,
        modelManager: mm,
        catalog: catalog,
        roles: const ['transformer'],
      );
      expect(plan.roles.single.choice.fit, LanguageFit.plausible);
      expect(plan.roles.single.suggestion?.id, 'zh-strong');
      expect(plan.needsAttention, isTrue);
    });

    test('不建議下載不支援此語言的模型', () async {
      final mm = ModelManager(modelsDir: dir);
      await mm.refreshInstallStates();
      final catalog = ModelCatalog.fromJson({
        'models': [
          {
            'role': 'adversarial',
            'name': 'a',
            'variants': [
              {
                'id': 'adv-en',
                'name': 'en',
                'backend': 'transformer',
                'languages': ['en'],
                'size_bytes': 100,
                'min_ram_mb': 1,
                'tier': 'low',
                'url': 'https://example.invalid/adv.onnx',
              },
            ],
          },
        ],
      });
      final plan = AnalysisPlan.build(
        text: _academicZh,
        modelManager: mm,
        catalog: catalog,
        roles: const ['adversarial'],
      );
      expect(plan.roles.single.suggestion, isNull);
    });

    test('沒有安裝任何模型時計畫標示需要留意', () async {
      final mm = ModelManager(modelsDir: dir);
      await mm.refreshInstallStates();
      final plan = AnalysisPlan.build(
        text: _academicZh,
        modelManager: mm,
        roles: const ['transformer'],
      );
      expect(plan.roles.single.hasModel, isFalse);
      expect(plan.needsAttention, isTrue);
    });
  });
}
