/// 文件適用性路由：先判斷這份輸入屬於哪種分析情境，再決定各證據家族
/// 能有多少話語權。領域判斷只用來降低未驗證方法的可靠度，不會自行產生
/// AI 或人類結論。
library;

import '../models/detection_result.dart';
import '../utils/text_stats.dart';

enum AnalysisDomain { academic, news, creative, general, codeHeavy }

class AnalysisProfile {
  final String language;
  final AnalysisDomain domain;
  final int wordCount;
  final int sentenceCount;
  final double inputQuality;

  const AnalysisProfile({
    required this.language,
    required this.domain,
    required this.wordCount,
    required this.sentenceCount,
    required this.inputQuality,
  });

  factory AnalysisProfile.fromText(String raw) {
    final text = PreprocessedText.from(raw);
    final wordCount = text.allTokens.length;
    final sentenceCount = text.sentences
        .where(PreprocessedText.isAnalyzableSentence)
        .length;
    final lengthQuality = switch (wordCount) {
      >= 500 => 1.0,
      >= 250 => 0.90,
      >= 100 => 0.72,
      >= 50 => 0.42,
      _ => 0.18,
    };
    final sentenceQuality = switch (sentenceCount) {
      >= 10 => 1.0,
      >= 5 => 0.78,
      >= 3 => 0.48,
      _ => 0.22,
    };
    return AnalysisProfile(
      language: text.language.code,
      domain: _detectDomain(raw),
      wordCount: wordCount,
      sentenceCount: sentenceCount,
      inputQuality: (lengthQuality * sentenceQuality).clamp(0.0, 1.0),
    );
  }

  /// 領域敏感度只會下修可靠度。學術文章的規律句式與過渡詞、新聞的固定
  /// 倒金字塔結構，以及創作文本的高變異，都不能套用同一組啟發式門檻。
  double domainReliability(EvidenceFamily family) => switch ((domain, family)) {
    (AnalysisDomain.academic, EvidenceFamily.lexicalFingerprint) => 0.72,
    (AnalysisDomain.academic, EvidenceFamily.distributional) => 0.68,
    (AnalysisDomain.academic, EvidenceFamily.stylometric) => 0.55,
    (AnalysisDomain.news, EvidenceFamily.stylometric) => 0.72,
    (AnalysisDomain.news, EvidenceFamily.lexicalFingerprint) => 0.90,
    (AnalysisDomain.creative, EvidenceFamily.distributional) => 0.72,
    (AnalysisDomain.creative, EvidenceFamily.lexicalFingerprint) => 0.82,
    (AnalysisDomain.creative, EvidenceFamily.stylometric) => 0.70,
    (AnalysisDomain.codeHeavy, _) => 0.25,
    _ => 1.0,
  };

  static AnalysisDomain _detectDomain(String raw) {
    if (raw.trim().isEmpty) return AnalysisDomain.general;
    final lower = raw.toLowerCase();
    final codeMarks = RegExp(
      r'(?:\b(?:class|function|const|var|return|import)\b|[{};]{2,}|```)',
    ).allMatches(raw).length;
    if (codeMarks >= 5) return AnalysisDomain.codeHeavy;

    final academicMarks = RegExp(
      r'(?:\bdoi\b|\bet al\.?\b|\breferences\b|\bbibliography\b|'
      r'\bmethod(?:ology|s)?\b|\bresults?\b|\bdiscussion\b|'
      r'參考文獻|文獻探討|研究方法|研究結果|摘要|關鍵詞|圖\s*\d+|表\s*\d+)',
      caseSensitive: false,
    ).allMatches(lower).length;
    final citationMarks = RegExp(
      r'(?:\([A-Z][A-Za-z-]+(?: et al\.)?,?\s*\d{4}\)|\[\d+(?:\s*[-,]\s*\d+)*\])',
    ).allMatches(raw).length;
    if (academicMarks >= 3 || citationMarks >= 3) {
      return AnalysisDomain.academic;
    }

    final newsMarks = RegExp(
      r'(?:\breuters\b|\bassociated press\b|\baccording to officials\b|'
      r'據.*?(?:表示|指出)|記者.{0,12}報導|本報訊)',
      caseSensitive: false,
    ).allMatches(lower).length;
    if (newsMarks >= 2) return AnalysisDomain.news;

    final dialogueLines = RegExp(
      r'^(?:[「『“\"]|[-—]\s*[A-Za-z一-鿿])',
      multiLine: true,
    ).allMatches(raw).length;
    if (dialogueLines >= 4) return AnalysisDomain.creative;
    return AnalysisDomain.general;
  }
}
