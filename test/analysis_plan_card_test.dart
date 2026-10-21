import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:omnitrace/core/detection/model_manager.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';
import 'package:omnitrace/shared/widgets/analysis_plan_card.dart';

const _zh =
    '本研究採用方法目的鏈與結構方程模式，並以資料探勘補足消費者異質性（Wedel & Kannan, 2016）。'
    '研究分為三階段，發現將以預先註冊的程序驗證（Athey & Imbens, 2016）。'
    '多重檢定以偽發現率控制（Benjamini & Hochberg, 1995）。';

void main() {
  late Directory dir;
  late ModelManager manager;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('plan_card_');
    manager = ModelManager(modelsDir: dir);
    await manager.refreshInstallStates();
  });
  tearDown(() => dir.deleteSync(recursive: true));

  Widget host({required bool autoExpand}) =>
      ChangeNotifierProvider<ModelManager>.value(
        value: manager,
        child: MaterialApp(
          locale: const Locale('zh', 'TW'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: SingleChildScrollView(
              child: AnalysisPlanCard(
                text: _zh,
                sourceFormat: 'docx',
                autoExpand: autoExpand,
              ),
            ),
          ),
        ),
      );

  testWidgets('缺模型時標題提示留意；寬版自動展開並說明原因', (tester) async {
    await tester.pumpWidget(host(autoExpand: true));
    await tester.pumpAndSettle();

    expect(find.textContaining('有需要留意的項目'), findsOneWidget);
    expect(find.textContaining('學術'), findsWidgets);
    expect(find.textContaining('.DOCX'), findsOneWidget);
    expect(find.text('尚未安裝模型，這個引擎不會參與'), findsWidgets);
  });

  testWidgets('窄螢幕不自動展開，避免把開始按鈕擠出畫面', (tester) async {
    await tester.pumpWidget(host(autoExpand: false));
    await tester.pumpAndSettle();

    expect(find.textContaining('有需要留意的項目'), findsOneWidget);
    expect(find.text('尚未安裝模型，這個引擎不會參與'), findsNothing);
  });
}
