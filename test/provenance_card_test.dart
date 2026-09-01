import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omnitrace/core/services/document_provenance.dart';
import 'package:omnitrace/l10n/generated/app_localizations.dart';
import 'package:omnitrace/shared/widgets/provenance_card.dart';

Widget _app(DocumentProvenance provenance) => MaterialApp(
  locale: const Locale('en'),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: Scaffold(
    body: SingleChildScrollView(child: ProvenanceCard(provenance: provenance)),
  ),
);

void main() {
  testWidgets('沒有中繼資料時明確說明無從由來源判斷，而非默默留白', (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_app(DocumentProvenance.none));
    await tester.pumpAndSettle();

    expect(find.text('Document origin evidence'), findsOneWidget);
    expect(find.text('No editing history available'), findsOneWidget);
    expect(find.textContaining('carries no editing history'), findsOneWidget);
    // 免責說明任何情況都必須出現
    expect(find.textContaining('can be wiped or reset'), findsOneWidget);
  });

  testWidgets('有強訊號時逐條列出白話說明與事實欄位', (tester) async {
    await tester.binding.setSurfaceSize(const Size(600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const provenance = DocumentProvenance(
      editingDuration: Duration(minutes: 3),
      revisionCount: 1,
      application: 'Microsoft Office Word',
      distinctBodyRsids: 1,
      bodyWordCount: 1500,
      signals: [
        ProvenanceSignal(
          kind: ProvenanceSignalKind.implausibleTypingSpeed,
          severity: ProvenanceSeverity.strong,
          values: {'words': 1500, 'minutes': 3, 'wpm': 500},
        ),
        ProvenanceSignal(
          kind: ProvenanceSignalKind.singleEditingSession,
          severity: ProvenanceSeverity.strong,
          values: {'count': 1, 'words': 1500},
        ),
      ],
    );

    await tester.pumpWidget(_app(provenance));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Editing history is clearly unusual'), findsOneWidget);
    // 事實欄位
    expect(
      find.textContaining('Editing time recorded in the file: 3'),
      findsOneWidget,
    );
    expect(find.textContaining('Times saved: 1'), findsOneWidget);
    expect(find.textContaining('Microsoft Office Word'), findsOneWidget);
    // 兩條訊號的白話說明
    expect(find.textContaining('500 words per minute'), findsOneWidget);
    expect(find.textContaining('editing-batch marker'), findsOneWidget);
    expect(find.textContaining('can be wiped or reset'), findsOneWidget);
  });
}
