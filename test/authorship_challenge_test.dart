import 'package:flutter_test/flutter_test.dart';
import 'package:truthlens/core/services/authorship_challenge.dart';
import 'package:truthlens/core/services/writing_session.dart';

void main() {
  final text = List.filled(
    8,
    'The report found that renewable storage reduced peak demand by 24 percent, which requires careful interpretation.',
  ).join(' ');

  test('從文件產生具體追問', () {
    final challenge = AuthorshipChallenge.fromText(text);
    expect(challenge.questions, isNotEmpty);
    expect(challenge.questions.first.excerpt, contains('renewable storage'));
  });

  test('大量貼上的回答會被標記，不當成現場作答', () {
    final question = AuthorshipChallenge.fromText(text).questions.first;
    final recorder = WritingSessionRecorder()..record(220);
    expect(
      AuthorshipChallenge.evaluate(
        question,
        'renewable storage '.padRight(220, 'x'),
        recorder.session,
      ),
      ChallengeAnswerState.pasted,
    );
  });

  test('逐步輸入且具體回應原文可標為有根據', () {
    final question = AuthorshipChallenge.fromText(text).questions.first;
    final answer =
        'The report links renewable storage to lower peak demand, but the 24 percent figure still needs context and careful interpretation.';
    final recorder = WritingSessionRecorder();
    for (var i = 1; i <= answer.length; i++) {
      recorder.record(i);
    }
    expect(
      AuthorshipChallenge.evaluate(question, answer, recorder.session),
      ChallengeAnswerState.grounded,
    );
  });
}
