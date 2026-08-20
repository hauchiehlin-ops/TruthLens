/// 監督式作者追問的本機邏輯。
///
/// 問題從文件本身抽取，不呼叫外部 LLM。回答評估只檢查是否有足夠內容、是否
/// 大量貼上，以及是否具體回應被抽出的段落；即使通過也不是身分證明，必須在
/// 監督情境中搭配口頭說明使用。
library;

import '../utils/text_stats.dart';
import 'claim_audit.dart';
import 'writing_session.dart';

enum ChallengeQuestionKind { explain, justify }

enum ChallengeAnswerState { unanswered, insufficient, grounded, pasted }

class AuthorshipChallengeQuestion {
  final ChallengeQuestionKind kind;
  final String excerpt;

  const AuthorshipChallengeQuestion({
    required this.kind,
    required this.excerpt,
  });
}

class AuthorshipChallenge {
  final List<AuthorshipChallengeQuestion> questions;

  const AuthorshipChallenge({this.questions = const []});

  factory AuthorshipChallenge.fromText(String text) {
    final processed = PreprocessedText.from(text);
    if (processed.sentences.isEmpty) return const AuthorshipChallenge();
    final claims = ClaimAudit.analyze(text).claims;
    final questions = <AuthorshipChallengeQuestion>[];

    final first = processed.sentences.firstWhere(
      (sentence) => sentence.length >= 45,
      orElse: () => processed.sentences.first,
    );
    questions.add(
      AuthorshipChallengeQuestion(
        kind: ChallengeQuestionKind.explain,
        excerpt: _trim(first),
      ),
    );

    final claim = claims.where((item) => !item.hasSourceAnchor).firstOrNull;
    final second =
        claim?.text ?? processed.sentences[processed.sentences.length ~/ 2];
    if (second != first) {
      questions.add(
        AuthorshipChallengeQuestion(
          kind: ChallengeQuestionKind.justify,
          excerpt: _trim(second),
        ),
      );
    }
    return AuthorshipChallenge(questions: questions.take(2).toList());
  }

  static ChallengeAnswerState evaluate(
    AuthorshipChallengeQuestion question,
    String answer,
    WritingSession session,
  ) {
    if (answer.trim().isEmpty) return ChallengeAnswerState.unanswered;
    if (session.largestPaste >= 80 || session.pastedRatio > 0.60) {
      return ChallengeAnswerState.pasted;
    }
    final answerTerms = _terms(answer);
    if (answerTerms.length < 8) return ChallengeAnswerState.insufficient;
    final sourceTerms = _terms(question.excerpt);
    if (sourceTerms.isEmpty) return ChallengeAnswerState.insufficient;
    final overlap =
        answerTerms.intersection(sourceTerms).length / sourceTerms.length;
    return overlap >= 0.12
        ? ChallengeAnswerState.grounded
        : ChallengeAnswerState.insufficient;
  }

  static Set<String> _terms(String text) => RegExp(
    r'[A-Za-zÀ-ɏ]{3,}|[一-鿿]{2}',
    unicode: true,
  ).allMatches(text.toLowerCase()).map((match) => match.group(0)!).toSet();

  static String _trim(String text) {
    final compact = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return compact.length <= 180 ? compact : '${compact.substring(0, 177)}...';
  }
}
