import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
                  Text(l10n.helpAboutBody, style: const TextStyle(height: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(l10n.helpComparisonTitle, style: textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(l10n.helpComparisonDisclaimer, style: textTheme.bodySmall),
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
            points: [l10n.helpVsOriginality1, l10n.helpVsOriginality2],
          ),
          _compareCard(
            context,
            title: l10n.helpVsCopyleaksTitle,
            points: [l10n.helpVsCopyleaks1, l10n.helpVsCopyleaks2],
          ),
          _compareCard(
            context,
            title: l10n.helpVsWinstonTitle,
            points: [l10n.helpVsWinston1, l10n.helpVsWinston2],
          ),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.4),
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
          _WorkflowInfographicWidget(l10n: l10n),
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
                    leading: Icon(LucideIcons.externalLink),
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

  Widget _compareCard(
    BuildContext context, {
    required String title,
    required List<String> points,
  }) {
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
                    if (body != null)
                      Text(body, style: const TextStyle(height: 1.5)),
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

class _WorkflowStepData {
  final int step;
  final String title;
  final IconData icon;
  final Color accentColor;
  final List<String> chips;
  final String? body;
  final List<String>? bullets;

  const _WorkflowStepData({
    required this.step,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.chips,
    this.body,
    this.bullets,
  });
}

class _WorkflowInfographicWidget extends StatefulWidget {
  final AppLocalizations l10n;
  const _WorkflowInfographicWidget({required this.l10n});

  @override
  State<_WorkflowInfographicWidget> createState() =>
      _WorkflowInfographicWidgetState();
}

class _WorkflowInfographicWidgetState
    extends State<_WorkflowInfographicWidget> {
  int _selectedStep = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final steps = [
      _WorkflowStepData(
        step: 1,
        title: widget.l10n.helpWorkflowStep1Title,
        icon: LucideIcons.cloudDownload,
        accentColor: Colors.blue,
        chips: [
          widget.l10n.helpWorkflowStep1ChipOnboarding,
          widget.l10n.helpWorkflowStep1ChipModelManager,
          widget.l10n.helpWorkflowStep1ChipUpdateCheck,
        ],
        body: widget.l10n.helpWorkflowStep1Body,
      ),
      _WorkflowStepData(
        step: 2,
        title: widget.l10n.helpWorkflowStep2Title,
        icon: LucideIcons.sliders,
        accentColor: Colors.purple,
        chips: [
          widget.l10n.helpWorkflowStep2ChipTransformer,
          widget.l10n.helpWorkflowStep2ChipStatistics,
          widget.l10n.helpWorkflowStep2ChipStylometry,
          widget.l10n.helpWorkflowStep2ChipAdversarial,
          widget.l10n.helpWorkflowStep2ChipReportLlm,
        ],
        bullets: [
          widget.l10n.helpWorkflowStep2Bullet1,
          widget.l10n.helpWorkflowStep2Bullet2,
          widget.l10n.helpWorkflowStep2Bullet3,
          widget.l10n.helpWorkflowStep2Bullet4,
          widget.l10n.helpWorkflowStep2Bullet5,
          widget.l10n.helpWorkflowStep2Bullet6,
        ],
      ),
      _WorkflowStepData(
        step: 3,
        title: widget.l10n.helpWorkflowStep3Title,
        icon: LucideIcons.upload,
        accentColor: Colors.teal,
        chips: [
          widget.l10n.helpWorkflowStep3ChipPaste,
          widget.l10n.helpWorkflowStep3ChipImageOcr,
          widget.l10n.helpWorkflowStep3ChipImportFormats,
          widget.l10n.helpWorkflowStep3ChipCodeFormulaIsolation,
        ],
        body: widget.l10n.helpWorkflowStep3Body,
      ),
      _WorkflowStepData(
        step: 4,
        title: widget.l10n.helpWorkflowStep4Title,
        icon: LucideIcons.trendingUp,
        accentColor: Colors.amber,
        chips: [
          widget.l10n.helpWorkflowStep4ChipEnsemble,
          widget.l10n.helpWorkflowStep4ChipLiveProgress,
          widget.l10n.helpWorkflowStep4ChipEslCorrection,
          widget.l10n.helpWorkflowStep4ChipStoppable,
        ],
        body: widget.l10n.helpWorkflowStep4Body,
      ),
      _WorkflowStepData(
        step: 5,
        title: widget.l10n.helpWorkflowStep5Title,
        icon: LucideIcons.barChart,
        accentColor: Colors.green,
        chips: [
          widget.l10n.helpWorkflowStep5ChipOverviewGauge,
          widget.l10n.helpWorkflowStep5ChipSentenceHeatmap,
          widget.l10n.helpWorkflowStep5ChipCitationVerification,
          widget.l10n.helpWorkflowStep5ChipExportFormats,
        ],
        body: widget.l10n.helpWorkflowStep5Body,
      ),
    ];

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 頂部圖解橫向步驟條 (Header Flow Banner)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (int i = 0; i < steps.length; i++) ...[
                    _buildStepHeaderChip(context, steps[i]),
                    if (i < steps.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Icon(
                          LucideIcons.arrowRight,
                          size: 16,
                          color: scheme.outline.withAlpha(140),
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            // 縱向流程圖解卡片 Timeline
            Column(
              children: [
                for (int i = 0; i < steps.length; i++)
                  _buildTimelineNode(
                    context,
                    steps[i],
                    isLast: i == steps.length - 1,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeaderChip(BuildContext context, _WorkflowStepData step) {
    final isSelected = _selectedStep == step.step;
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedStep = step.step;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? step.accentColor.withAlpha(40)
                : scheme.surfaceContainerHighest.withAlpha(100),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? step.accentColor
                  : scheme.outline.withAlpha(60),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: step.accentColor,
                child: Text(
                  '${step.step}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                step.icon,
                size: 16,
                color: isSelected ? step.accentColor : scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                step.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? scheme.onSurface
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineNode(
    BuildContext context,
    _WorkflowStepData step, {
    required bool isLast,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _selectedStep == step.step;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左側資訊圖表 Timeline 軸
          Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedStep = step.step),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: step.accentColor.withAlpha(isSelected ? 255 : 40),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: step.accentColor,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: step.accentColor.withAlpha(100),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      step.icon,
                      size: 18,
                      color: isSelected ? Colors.white : step.accentColor,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isSelected
                        ? step.accentColor.withAlpha(180)
                        : scheme.outline.withAlpha(60),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // 右側內容卡片
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: GestureDetector(
                onTap: () => setState(() => _selectedStep = step.step),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? step.accentColor.withAlpha(20)
                        : scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? step.accentColor.withAlpha(180)
                          : scheme.outline.withAlpha(40),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: step.accentColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.l10n.helpWorkflowStepLabel(step.step),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              step.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 資訊圖表關鍵字 Chip 標籤
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final chip in step.chips)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: step.accentColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: step.accentColor.withAlpha(100),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                chip,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (step.body != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          step.body!,
                          style: const TextStyle(height: 1.45, fontSize: 13),
                        ),
                      ],
                      if (step.bullets != null) ...[
                        const SizedBox(height: 8),
                        for (final b in step.bullets!) _Bullet(b),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
