import 'dart:async';
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
      DetectionResult result, AppLocalizations l10n) async {
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
      DetectionResult r, AppLocalizations l10n) async {
    final payload = {
      'overall_score': r.aiProbability,
      'classification': r.verdict.name,
      'sentence_count': r.sentences.length,
      'ai_sentences': r.aiSentenceCount,
      'human_sentences': r.humanSentenceCount,
      'dominant_patterns': r.dominantPatterns,
      'esl_adjusted': r.eslAdjusted,
      'threshold': r.threshold,
    };

    final prompt = _buildPrompt(payload, l10n.localeName);

    final raw = await llmManager.inference.generate(prompt);
    if (raw.isEmpty) return null;

    final base = _fallback.compose(r, l10n);
    return ReportDocument(
      templateId: base.templateId,
      headline: raw.split('\n').first.trim(),
      components: base.components,
      source: ReportSource.llm,
    );
  }

  /// 提示詞本身以英文撰寫（LLM 對英文指令的服從度最穩定），但明確要求輸出
  /// 語言須為使用者目前選擇的 App 語系（BCP-47 語言代碼），確保 LLM 生成的
  /// 報告文字與其餘介面語言一致，而非固定輸出中文。
  String _buildPrompt(Map<String, dynamic> payload, String targetLocale) {
    return '''You are the TruthLens AI content detection report writer.
Below is the structured result (JSON) from the detection engines. Write a concise analysis report.

$payload

Requirements:
1. The first line is a headline (one sentence summarizing the verdict and confidence).
2. Explain each engine's key findings in separate paragraphs (no more than three paragraphs).
3. If paraphrase evasion is suspected, warn about it clearly.
4. Keep an objective, professional tone.
5. Write the entire report in the language identified by BCP-47 tag "$targetLocale", not any other language.
''';
  }
}
