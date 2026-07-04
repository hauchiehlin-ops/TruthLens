import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/detection_result.dart';
import '../../features/report/report_composer.dart';
import '../../features/report/report_document.dart';
import 'llm_manager.dart';

/// 報告生成服務（模組 2）。若本地端 LLM（Gemma 2B / llama.cpp）已載入且就緒，
/// 由 LLM 決定版面並生成解讀；否則回退至 [ReportComposer] 的確定性模板生成。
///
/// 低階裝置保護：LLM 逾時（>30 秒）亦回退，確保任何裝置都能產出報告。
class ReportLlmService {
  static const _timeout = Duration(seconds: 30);

  final LlmManager llmManager;
  final ReportComposer _fallback;

  ReportLlmService({required this.llmManager, ReportComposer? fallback})
      : _fallback = fallback ?? ReportComposer();

  /// 產生報告。永遠回傳有效文件（LLM 失敗或未載入時透明回退至模板）。
  Future<ReportDocument> generate(DetectionResult result) async {
    final ready = await llmManager.loadIfAvailable();
    if (ready && llmManager.isLoaded) {
      try {
        final doc = await _generateWithLlm(result).timeout(_timeout);
        if (doc != null) return doc;
      } catch (e) {
        debugPrint('LLM report generation error: $e');
        // 逾時或出錯 → 回退
      }
    }
    return _fallback.compose(result);
  }

  Future<ReportDocument?> _generateWithLlm(DetectionResult r) async {
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

    final prompt = _buildPrompt(payload);
    
    final raw = await llmManager.inference.generate(prompt);
    if (raw.isEmpty) return null;

    final base = _fallback.compose(r);
    return ReportDocument(
      templateId: base.templateId,
      headline: raw.split('\n').first.trim(),
      components: base.components,
      source: ReportSource.llm,
    );
  }

  String _buildPrompt(Map<String, dynamic> payload) {
    return '''你是 TruthLens AI 內容檢測報告撰寫助手。
以下是檢測引擎的結構化結果（JSON），請產出簡潔的中文分析報告。

$payload

要求：
1. 第一行是大標題（一句話總結判定與信心程度）
2. 分段說明各引擎發現的重點（不超過三段）
3. 若有改寫嫌疑，明確警告
4. 語氣客觀專業
''';
  }
}
