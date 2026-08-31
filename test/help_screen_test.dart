import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/features/help/help_screen.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('workflow chips follow the English locale', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: HelpScreen(),
      ),
    );

    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 8 && find.text('Paste text').evaluate().isEmpty; i++) {
      await tester.drag(scrollable, const Offset(0, -600));
      await tester.pumpAndSettle();
    }

    expect(find.text('Paste text'), findsOneWidget);
    expect(find.text('Four-engine ensemble'), findsOneWidget);
    expect(find.text('AI overview gauge'), findsOneWidget);
    expect(find.text('直接貼上'), findsNothing);
    expect(find.text('四引擎並列推論'), findsNothing);
    expect(find.text('AI 總覽儀表'), findsNothing);
  });
  testWidgets('設計理念章節涵蓋定位轉換、五支柱、整合判讀與風險', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: HelpScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('Design philosophy and known limits'),
      scrollable,
      const Offset(0, -400),
    );

    expect(find.text('Design philosophy and known limits'), findsOneWidget);

    // ListView 為惰性建構，逐一捲動確認四個小節都存在
    for (final title in [
      '1. The shift: not competing on score accuracy',
      '2. The five pillars',
      '3. Tiered analysis and integrated assessment',
      '4. Risks worth facing honestly',
    ]) {
      await tester.dragUntilVisible(
        find.text(title),
        scrollable,
        const Offset(0, -400),
      );
      expect(find.text(title), findsOneWidget, reason: '缺少小節：$title');
    }

    // 風險章節必須實際帶出「不可單獨作為指控依據」這條
    expect(
      find.textContaining('stand alone as grounds for an accusation'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('user guide explains workspace actions and iOS web limits', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: HelpScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final scrollable = find.byType(Scrollable).first;
    await tester.dragUntilVisible(
      find.text('Workspace actions and platform limits'),
      scrollable,
      const Offset(0, -400),
    );

    for (final text in [
      'Import document',
      'New analysis',
      'Engine status in reports',
      'iOS browser memory limits',
    ]) {
      await tester.dragUntilVisible(
        find.text(text),
        scrollable,
        const Offset(0, -400),
      );
      expect(find.text(text), findsOneWidget);
    }

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(l10n.helpWorkspaceNewAnalysisBody, contains('should not re-run'));
    expect(l10n.helpWorkspaceIosWebBody, contains('488 MB Qwen PPL'));
    expect(l10n.helpWorkspaceIosWebBody, contains('statistical engine active'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('說明手冊不得殘留 Web-only 之前的跨平台原生描述', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1000, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: HelpScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    // Phase 6 已改為 Web-only，手冊不得再宣稱原生跨平台或平台原生 OCR
    for (final text in [
      l10n.helpAboutBody,
      l10n.helpVsWinston1,
      l10n.helpVsGptZero1,
      l10n.helpWorkflowStep3Body,
    ]) {
      for (final stale in ['iOS', 'Android', 'Windows.Media', 'ML Kit']) {
        expect(
          text.contains(stale),
          isFalse,
          reason: '「$stale」是 Web-only 之前的過時描述',
        );
      }
    }
    expect(l10n.helpAboutBody, contains('inside your browser'));
    // 新增的兩項優勢：來源鑑識與方向／信心分離
    expect(l10n.helpAdvantage5, contains('origin forensics'));
    expect(l10n.helpAdvantage6, contains('most likely AI / not-AI direction'));
    expect(l10n.helpAdvantage6, contains('confidence'));
    expect(
      l10n.helpWorkflowStep4Body,
      isNot(contains('all four engines run in parallel')),
    );
    expect(l10n.helpWorkspaceNewAnalysisBody, contains('should not re-run'));
    expect(l10n.helpWorkspaceIosWebBody, contains('iOS Web'));
    expect(l10n.helpWorkspaceIosWebBody, contains('488 MB Qwen PPL'));
  });
}
