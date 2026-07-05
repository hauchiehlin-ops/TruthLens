import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/generated/app_localizations.dart';

/// 操作說明頁：產品定位與競品比較、完整操作流程、模型下載與調適教學。
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _officialLinkUrls = [
    'https://huggingface.co/onnx-community/chatgpt-detector-roberta-ONNX',
    'https://huggingface.co/Xenova/distilgpt2',
    'https://github.com/hauchiehlin-ops/TruthLens/releases/tag/models-v1',
    'https://huggingface.co/google/gemma-2-2b-it',
  ];
  static const _officialLinkNames = [
    'onnx-community/chatgpt-detector-roberta-ONNX',
    'Xenova/distilgpt2',
    'TruthLens GitHub Releases (models-v1)',
    'google/gemma-2-2b-it',
  ];

  Future<void> _openLink(String url) async {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final officialLinkRoles = [
      l10n.helpLinkRoleTransformer,
      l10n.helpLinkRoleStatistical,
      l10n.helpLinkRoleAdversarial,
      l10n.helpLinkRoleLlm,
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpAppBarTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.helpAboutTitle, style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    l10n.helpAboutBody,
                    style: const TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.helpComparisonTitle, style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            l10n.helpComparisonDisclaimer,
            style: textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          _compareCard(
            context,
            title: l10n.helpVsGptZeroTitle,
            points: [
              l10n.helpVsGptZero1,
              l10n.helpVsGptZero2,
              l10n.helpVsGptZero3,
            ],
          ),
          _compareCard(
            context,
            title: l10n.helpVsTurnitinTitle,
            points: [
              l10n.helpVsTurnitin1,
              l10n.helpVsTurnitin2,
              l10n.helpVsTurnitin3,
            ],
          ),
          _compareCard(
            context,
            title: l10n.helpVsOriginalityTitle,
            points: [
              l10n.helpVsOriginality1,
              l10n.helpVsOriginality2,
            ],
          ),
          _compareCard(
            context,
            title: l10n.helpVsCopyleaksTitle,
            points: [
              l10n.helpVsCopyleaks1,
              l10n.helpVsCopyleaks2,
            ],
          ),
          _compareCard(
            context,
            title: l10n.helpVsWinstonTitle,
            points: [
              l10n.helpVsWinston1,
              l10n.helpVsWinston2,
            ],
          ),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.helpAdvantagesTitle, style: textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _Bullet(l10n.helpAdvantage1),
                  _Bullet(l10n.helpAdvantage2),
                  _Bullet(l10n.helpAdvantage3),
                  _Bullet(l10n.helpAdvantage4),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.helpWorkflowTitle, style: textTheme.titleLarge),
          const SizedBox(height: 12),
          _stepCard(
            context,
            step: 1,
            title: l10n.helpWorkflowStep1Title,
            body: l10n.helpWorkflowStep1Body,
          ),
          _stepCard(
            context,
            step: 2,
            title: l10n.helpWorkflowStep2Title,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Bullet(l10n.helpWorkflowStep2Bullet1),
                _Bullet(l10n.helpWorkflowStep2Bullet2),
                _Bullet(l10n.helpWorkflowStep2Bullet3),
                _Bullet(l10n.helpWorkflowStep2Bullet4),
                _Bullet(l10n.helpWorkflowStep2Bullet5),
                _Bullet(l10n.helpWorkflowStep2Bullet6),
              ],
            ),
          ),
          _stepCard(
            context,
            step: 3,
            title: l10n.helpWorkflowStep3Title,
            body: l10n.helpWorkflowStep3Body,
          ),
          _stepCard(
            context,
            step: 4,
            title: l10n.helpWorkflowStep4Title,
            body: l10n.helpWorkflowStep4Body,
          ),
          _stepCard(
            context,
            step: 5,
            title: l10n.helpWorkflowStep5Title,
            body: l10n.helpWorkflowStep5Body,
          ),
          const SizedBox(height: 24),
          Text(l10n.helpTuningTitle, style: textTheme.titleLarge),
          const SizedBox(height: 12),
          _stepCard(
            context,
            step: 1,
            title: l10n.helpTuningStep1Title,
            body: l10n.helpTuningStep1Body,
          ),
          _stepCard(
            context,
            step: 2,
            title: l10n.helpTuningStep2Title,
            body: l10n.helpTuningStep2Body,
          ),
          _stepCard(
            context,
            step: 3,
            title: l10n.helpTuningStep3Title,
            body: l10n.helpTuningStep3Body,
          ),
          _stepCard(
            context,
            step: 4,
            title: l10n.helpTuningStep4Title,
            body: l10n.helpTuningStep4Body,
          ),
          _stepCard(
            context,
            step: 5,
            title: l10n.helpTuningStep5Title,
            body: l10n.helpTuningStep5Body,
          ),
          const SizedBox(height: 16),
          Text(l10n.helpOfficialLinksTitle, style: textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(l10n.helpOfficialLinksHint, style: textTheme.bodySmall),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (var i = 0; i < _officialLinkUrls.length; i++)
                  ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: Text(officialLinkRoles[i]),
                    subtitle: Text(_officialLinkNames[i]),
                    onTap: () => _openLink(_officialLinkUrls[i]),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _compareCard(BuildContext context,
      {required String title, required List<String> points}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final p in points) _Bullet(p),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepCard(
    BuildContext context, {
    required int step,
    required String title,
    String? body,
    Widget? child,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: Text('$step', style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    if (body != null) Text(body, style: const TextStyle(height: 1.5)),
                    ?child,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text, style: const TextStyle(height: 1.4))),
        ],
      ),
    );
  }
}
