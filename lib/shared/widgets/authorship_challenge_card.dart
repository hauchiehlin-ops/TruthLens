import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/models/detection_result.dart';
import '../../core/services/authorship_challenge.dart';
import '../../core/services/writing_session.dart';
import '../../l10n/generated/app_localizations.dart';

class AuthorshipChallengeCard extends StatefulWidget {
  final DetectionResult result;

  const AuthorshipChallengeCard({super.key, required this.result});

  @override
  State<AuthorshipChallengeCard> createState() =>
      _AuthorshipChallengeCardState();
}

class _AuthorshipChallengeCardState extends State<AuthorshipChallengeCard> {
  late final AuthorshipChallenge _challenge;
  late final List<TextEditingController> _controllers;
  late final List<WritingSessionRecorder> _recorders;
  late final List<ChallengeAnswerState> _states;

  @override
  void initState() {
    super.initState();
    _challenge = AuthorshipChallenge.fromText(widget.result.inputText);
    _controllers = [
      for (final _ in _challenge.questions) TextEditingController(),
    ];
    _recorders = [
      for (final _ in _challenge.questions) WritingSessionRecorder(),
    ];
    _states = List.filled(
      _challenge.questions.length,
      ChallengeAnswerState.unanswered,
    );
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_challenge.questions.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        leading: Icon(LucideIcons.messageSquareText, color: scheme.primary),
        title: Text(l10n.challengeTitle),
        subtitle: Text(l10n.challengeSubtitle),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.challengeCaveat,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < _challenge.questions.length; i++) ...[
            _question(context, i),
            if (i + 1 < _challenge.questions.length) const Divider(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _question(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context);
    final question = _challenge.questions[index];
    final state = _states[index];
    final scheme = Theme.of(context).colorScheme;
    final prompt = switch (question.kind) {
      ChallengeQuestionKind.explain => l10n.challengeExplainQuestion(
        question.excerpt,
      ),
      ChallengeQuestionKind.justify => l10n.challengeJustifyQuestion(
        question.excerpt,
      ),
    };
    final stateColor = switch (state) {
      ChallengeAnswerState.unanswered => scheme.onSurfaceVariant,
      ChallengeAnswerState.insufficient => scheme.tertiary,
      ChallengeAnswerState.grounded => Colors.green.shade700,
      ChallengeAnswerState.pasted => scheme.error,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${index + 1}. $prompt',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controllers[index],
          minLines: 3,
          maxLines: 6,
          decoration: InputDecoration(hintText: l10n.challengeAnswerHint),
          onChanged: (value) {
            _recorders[index].record(value.length);
            if (_states[index] != ChallengeAnswerState.unanswered) {
              setState(() => _states[index] = ChallengeAnswerState.unanswered);
            }
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton.tonalIcon(
              onPressed: () {
                setState(() {
                  _states[index] = AuthorshipChallenge.evaluate(
                    question,
                    _controllers[index].text,
                    _recorders[index].session,
                  );
                });
              },
              icon: const Icon(LucideIcons.check, size: 16),
              label: Text(l10n.challengeEvaluate),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _stateLabel(state, l10n),
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: stateColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _stateLabel(ChallengeAnswerState state, AppLocalizations l10n) =>
      switch (state) {
        ChallengeAnswerState.unanswered => l10n.challengeStateUnanswered,
        ChallengeAnswerState.insufficient => l10n.challengeStateInsufficient,
        ChallengeAnswerState.grounded => l10n.challengeStateGrounded,
        ChallengeAnswerState.pasted => l10n.challengeStatePasted,
      };
}
