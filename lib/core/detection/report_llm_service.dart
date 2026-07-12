import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../l10n/generated/app_localizations.dart';
import '../models/detection_result.dart';
import '../../features/report/report_composer.dart';
import '../../features/report/report_document.dart';
import 'llm_manager.dart';

/// 報告生成服務（模組 2）。若本地端 LLM（Gemma 2B / llama.cpp）已載入且就緒，
/// 由 LLM 決定版面並生成解讀；否則回退至 [ReportComposer] 的確定性模板生成。
/// 兩種路徑皆依傳入的 [AppLocalizations] 語系呈現文字。
///
/// 低階裝置保護：LLM 逾時（>30 秒）亦回退，確保任何裝置都能產出報告。
class ReportLlmService {
  static const _timeout = Duration(seconds: 30);

  final LlmManager llmManager;
  final ReportComposer _fallback;

  ReportLlmService({required this.llmManager, ReportComposer? fallback})
    : _fallback = fallback ?? ReportComposer();

  /// 產生報告。永遠回傳有效文件（LLM 失敗或未載入時透明回退至模板）。
  Future<ReportDocument> generate(
    DetectionResult result,
    AppLocalizations l10n,
  ) async {
    final ready = await llmManager.loadIfAvailable();
    if (ready && llmManager.isLoaded) {
      try {
        final doc = await _generateWithLlm(result, l10n).timeout(_timeout);
        if (doc != null) return doc;
      } catch (e) {
        debugPrint('LLM report generation error: $e');
        // 逾時或出錯 → 回退
      }
    }
    return _fallback.compose(result, l10n);
  }

  Future<ReportDocument?> _generateWithLlm(
    DetectionResult r,
    AppLocalizations l10n,
  ) async {
    final payload = {
      'overall_score': r.aiProbability,
      'classification': r.verdict.name,
      'sentence_count': r.sentences.length,
      'ai_sentences': r.aiSentenceCount,
      'human_sentences': r.humanSentenceCount,
      'dominant_patterns': r.dominantPatterns,
      'esl_adjusted': r.eslAdjusted,
      'threshold': r.threshold,
      'engine_findings': r.engineScores
          .where((e) => e.available)
          .map(
            (e) => {
              'id': e.engineId,
              'name': e.engineName,
              'ai_probability': e.aiProbability,
              'weight': e.weight,
              'reasons': e.reasons,
            },
          )
          .toList(),
    };

    final prompt = _buildPrompt(payload, l10n.localeName);

    String raw;
    if (llmManager.isRemote && llmManager.remoteProvider != null) {
      // 遠程 API
      raw = await llmManager.remoteProvider!.generate(prompt, maxTokens: 700);
    } else {
      // 本地 llama.cpp
      raw = await llmManager.inference.generate(prompt, maxTokens: 700);
    }

    if (raw.isEmpty) return null;

    final base = _fallback.compose(r, l10n);
    final llmSections = _parseLlmSections(raw);
    final headline = _cleanHeadline(llmSections['HEADLINE'] ?? raw);
    if (headline.isEmpty) return null;

    final components = _componentsFromLlm(
      base: base,
      sections: llmSections,
      result: r,
      l10n: l10n,
    );
    if (components == null) return null;

    return ReportDocument(
      templateId: base.templateId,
      headline: headline,
      components: components,
      source: ReportSource.llm,
    );
  }

  List<ReportComponent>? _componentsFromLlm({
    required ReportDocument base,
    required Map<String, String> sections,
    required DetectionResult result,
    required AppLocalizations l10n,
  }) {
    final narrative = sections['NARRATIVE']?.trim();
    if (narrative == null || narrative.isEmpty) {
      return null;
    }

    final components = <ReportComponent>[];
    var narrativeInserted = false;
    var paraphraseInserted = false;
    var patternInserted = false;
    var eslInserted = false;

    for (final component in base.components) {
      switch (component.type) {
        case ReportComponentType.narrative:
          components.add(
            ReportComponent(
              type: ReportComponentType.narrative,
              title: component.title,
              body: narrative,
            ),
          );
          narrativeInserted = true;
        case ReportComponentType.paraphraseWarning:
          final warning = sections['PARAPHRASE_WARNING']?.trim();
          components.add(
            ReportComponent(
              type: ReportComponentType.paraphraseWarning,
              title: component.title,
              body: warning != null && warning.isNotEmpty
                  ? warning
                  : component.body,
            ),
          );
          paraphraseInserted = true;
        case ReportComponentType.patternList:
          final patterns = sections['PATTERNS']?.trim();
          components.add(
            ReportComponent(
              type: ReportComponentType.patternList,
              title: component.title,
              body: patterns != null && patterns.isNotEmpty
                  ? patterns
                  : component.body,
            ),
          );
          patternInserted = true;
        case ReportComponentType.eslNotice:
          final esl = sections['ESL_NOTICE']?.trim();
          components.add(
            ReportComponent(
              type: ReportComponentType.eslNotice,
              title: component.title,
              body: esl != null && esl.isNotEmpty ? esl : component.body,
            ),
          );
          eslInserted = true;
        default:
          components.add(component);
      }
    }

    final warning = sections['PARAPHRASE_WARNING']?.trim();
    if (!paraphraseInserted && warning != null && warning.isNotEmpty) {
      components.add(
        ReportComponent(
          type: ReportComponentType.paraphraseWarning,
          title: l10n.composerParaphraseTitle,
          body: warning,
        ),
      );
    }

    final patterns = sections['PATTERNS']?.trim();
    if (!patternInserted && patterns != null && patterns.isNotEmpty) {
      components.add(
        ReportComponent(
          type: ReportComponentType.patternList,
          title: l10n.composerPatternListTitle,
          body: patterns,
        ),
      );
    }

    final esl = sections['ESL_NOTICE']?.trim();
    if (!eslInserted && result.eslAdjusted && esl != null && esl.isNotEmpty) {
      components.add(
        ReportComponent(
          type: ReportComponentType.eslNotice,
          title: l10n.composerEslTitle,
          body: esl,
        ),
      );
    }

    if (!narrativeInserted) {
      final index = components.indexWhere(
        (c) => c.type == ReportComponentType.thresholdBanner,
      );
      components.insert(
        index == -1 ? 0 : index + 1,
        ReportComponent(
          type: ReportComponentType.narrative,
          title: l10n.composerNarrativeTitle,
          body: narrative,
        ),
      );
    }

    return components;
  }

  Map<String, String> _parseLlmSections(String raw) {
    final sections = <String, String>{};
    String? current;
    final buffer = StringBuffer();

    void flush() {
      final key = current;
      if (key != null) {
        final value = buffer.toString().trim();
        if (value.isNotEmpty) sections[key] = value;
      }
      buffer.clear();
    }

    for (final line in const LineSplitter().convert(raw)) {
      final match = RegExp(
        r'^\s*(HEADLINE|NARRATIVE|PARAPHRASE_WARNING|PATTERNS|ESL_NOTICE)\s*:\s*(.*)$',
        caseSensitive: false,
      ).firstMatch(line);
      if (match != null) {
        flush();
        current = match.group(1)!.toUpperCase();
        final rest = match.group(2)!.trim();
        if (rest.isNotEmpty) buffer.writeln(rest);
      } else if (current != null) {
        buffer.writeln(line);
      }
    }
    flush();

    if (sections.isEmpty) {
      final lines = raw
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      if (lines.length >= 2) {
        sections['HEADLINE'] = lines.first;
        sections['NARRATIVE'] = lines.skip(1).join('\n\n');
      }
    }

    return sections;
  }

  String _cleanHeadline(String raw) {
    return raw
        .split('\n')
        .first
        .replaceFirst(RegExp(r'^\s*#{1,6}\s*'), '')
        .replaceFirst(RegExp(r'^\s*HEADLINE\s*:\s*', caseSensitive: false), '')
        .trim();
  }

  /// 提示詞本身以英文撰寫（LLM 對英文指令的服從度最穩定），但明確要求輸出
  /// 語言須為使用者目前選擇的 App 語系（BCP-47 語言代碼），確保 LLM 生成的
  /// 報告文字與其餘介面語言一致，而非固定輸出中文。
  String _buildPrompt(Map<String, dynamic> payload, String targetLocale) {
    return '''You are the TruthLens AI content detection report writer.
Below is the structured result (JSON) from the detection engines. Write a concise analysis report.

${const JsonEncoder.withIndent('  ').convert(payload)}

Requirements:
1. Return only the labeled sections below. Do not use Markdown bullets unless they are inside PATTERNS.
2. HEADLINE is one sentence summarizing the verdict and confidence.
3. NARRATIVE is two to four short paragraphs explaining the overall result, engine findings, and sentence distribution.
4. PARAPHRASE_WARNING is required only when paraphrase evasion is suspected; otherwise omit it.
5. PATTERNS is required only when dominant patterns exist; otherwise omit it.
6. ESL_NOTICE is required only when esl_adjusted is true; otherwise omit it.
7. Keep an objective, professional tone.
8. Write the entire report in the language identified by BCP-47 tag "$targetLocale", not any other language.

Format:
HEADLINE: ...
NARRATIVE: ...
PARAPHRASE_WARNING: ...
PATTERNS: ...
ESL_NOTICE: ...
''';
  }
}
