import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/detection/llm_manager.dart';
import 'package:truthlens/core/detection/model_manager.dart';
import 'package:truthlens/core/detection/remote_llm_provider.dart';
import 'package:truthlens/core/detection/report_llm_service.dart';
import 'package:truthlens/core/models/detection_result.dart';
import 'package:truthlens/features/report/report_document.dart';
import 'package:truthlens/l10n/generated/app_localizations.dart';

class _FakeRemoteLlmProvider implements RemoteLlmProvider {
  final String response;
  int? lastMaxTokens;

  _FakeRemoteLlmProvider(this.response);

  @override
  Future<String> generate(String prompt, {int maxTokens = 256}) async {
    lastMaxTokens = maxTokens;
    return response;
  }

  @override
  Future<bool> healthCheck() async => true;
}

DetectionResult _result({bool paraphrase = false}) => DetectionResult(
  id: 'llm',
  analyzedAt: DateTime(2026, 7, 12),
  inputText: 'This paragraph looks formulaic. This sentence feels human.',
  aiProbability: 0.64,
  verdict: Verdict.likelyAi,
  threshold: 0.6,
  engineScores: [
    const EngineScore(
      engineId: 'stylometry',
      engineName: 'Stylometry',
      aiProbability: 0.7,
      weight: 0.2,
      reasons: ['Repeated transitional phrasing'],
    ),
    EngineScore(
      engineId: 'adversarial',
      engineName: 'Adversarial Defense',
      aiProbability: paraphrase ? 0.8 : 0.2,
      weight: 0.15,
      available: paraphrase,
      reasons: const ['Paraphrase signature detected'],
    ),
  ],
  sentences: const [
    SentenceScore(
      index: 0,
      text: 'This paragraph looks formulaic.',
      aiProbability: 0.78,
    ),
    SentenceScore(
      index: 1,
      text: 'This sentence feels human.',
      aiProbability: 0.31,
    ),
  ],
  dominantPatterns: const ['Repeated transitional phrasing'],
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  test('LLM response populates report body, not only headline', () async {
    final provider = _FakeRemoteLlmProvider('''
HEADLINE: Likely AI-assisted text at 64% confidence.
NARRATIVE: The document crosses the configured threshold and shows uneven sentence-level evidence.

Stylometry highlights repeated transitional phrasing, while the sentence split still leaves some human-like material.
PATTERNS: Repeated transitional phrasing
''');
    final manager = LlmManager(
      modelManager: ModelManager(),
      remoteProvider: provider,
    );
    final service = ReportLlmService(llmManager: manager);

    final doc = await service.generate(_result(), l10n);
    final narrative = doc.components.firstWhere(
      (c) => c.type == ReportComponentType.narrative,
    );

    expect(doc.source, ReportSource.llm);
    expect(doc.headline, 'Likely AI-assisted text at 64% confidence.');
    expect(narrative.body, contains('uneven sentence-level evidence'));
    expect(narrative.body, contains('Stylometry highlights'));
    expect(narrative.body, isNot(contains('2 sentences')));
    expect(provider.lastMaxTokens, greaterThan(256));
  });

  test('LLM paraphrase section overrides template warning body', () async {
    final provider = _FakeRemoteLlmProvider('''
HEADLINE: Possible paraphrase evasion is present.
NARRATIVE: The overall score is elevated, and adversarial checks found a rewrite-like signature.
PARAPHRASE_WARNING: Treat the rewrite signal as a risk marker, not a standalone proof of authorship.
''');
    final manager = LlmManager(
      modelManager: ModelManager(),
      remoteProvider: provider,
    );
    final service = ReportLlmService(llmManager: manager);

    final doc = await service.generate(_result(paraphrase: true), l10n);
    final warning = doc.components.firstWhere(
      (c) => c.type == ReportComponentType.paraphraseWarning,
    );

    expect(doc.source, ReportSource.llm);
    expect(warning.body, contains('risk marker'));
  });

  test(
    'unstructured multi-line LLM output is accepted as headline and body',
    () async {
      final provider = _FakeRemoteLlmProvider('''
## Likely mixed authorship.
The first line becomes the headline after Markdown cleanup.
The remaining lines become the generated report narrative.
''');
      final manager = LlmManager(
        modelManager: ModelManager(),
        remoteProvider: provider,
      );
      final service = ReportLlmService(llmManager: manager);

      final doc = await service.generate(_result(), l10n);
      final narrative = doc.components.firstWhere(
        (c) => c.type == ReportComponentType.narrative,
      );

      expect(doc.source, ReportSource.llm);
      expect(doc.headline, 'Likely mixed authorship.');
      expect(narrative.body, contains('remaining lines'));
    },
  );
}
