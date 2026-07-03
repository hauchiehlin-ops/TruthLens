import 'package:flutter/services.dart';

import '../models/detection_result.dart';
import '../../features/report/report_composer.dart';
import '../../features/report/report_document.dart';
import 'model_manager.dart';

/// 報告生成服務（模組 2）。若本地端 LLM（Gemma 2B / llama.cpp）已安裝且原生就緒，
/// 由 LLM 決定版面並生成解讀；否則回退至 [ReportComposer] 的確定性模板生成。
///
/// 低階裝置保護：LLM 逾時（>30 秒）亦回退，確保任何裝置都能產出報告。
class ReportLlmService {
  static const _channel = MethodChannel('com.truthlens/report_llm');
  static const _timeout = Duration(seconds: 30);

  final ModelManager modelManager;
  final ReportComposer _fallback;

  ReportLlmService({required this.modelManager, ReportComposer? fallback})
      : _fallback = fallback ?? ReportComposer();

  Future<bool> get _llmReady async {
    if (!modelManager.isInstalled('llm')) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('ping');
      return ok ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// 產生報告。永遠回傳有效文件（LLM 失敗時透明回退至模板）。
  Future<ReportDocument> generate(DetectionResult result) async {
    if (await _llmReady) {
      try {
        final doc = await _generateWithLlm(result).timeout(_timeout);
        if (doc != null) return doc;
      } catch (_) {
        // 逾時或原生錯誤 → 回退
      }
    }
    return _fallback.compose(result);
  }

  Future<ReportDocument?> _generateWithLlm(DetectionResult r) async {
    // 傳結構化 JSON 給 LLM（plan 模組 2 的輸入格式）
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
    final raw = await _channel.invokeMethod<String>('generateReport', payload);
    if (raw == null) return null;
    // 原生端回傳 headline + narrative；版面與元件仍由確定性器決定骨架，
    // 只以 LLM 文字替換 headline 與 narrative（第一版整合策略）。
    final base = _fallback.compose(r);
    return ReportDocument(
      templateId: base.templateId,
      headline: raw.split('\n').first.trim(),
      components: base.components,
      source: ReportSource.llm,
    );
  }
}
