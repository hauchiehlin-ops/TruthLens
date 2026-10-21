import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_catalog.dart';
import '../../core/detection/model_display_names.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/model_provisioner.dart';
import '../../core/detection/variant_router.dart';
import '../../core/models/input_quality.dart';
import '../../core/services/analysis_plan.dart';
import '../../features/onboarding/model_options_list.dart';
import '../../l10n/generated/app_localizations.dart';

/// 分析前的「分析計畫」卡：偵測到的語言、文體、格式，以及每個引擎這次會
/// 用哪顆模型、為什麼，缺適用模型時直接提供下載。
///
/// 預設收合，只在有需要留意的項目（沒有模型、語言不支援、有更適合的模型）
/// 時自動展開——大多數情況下使用者不需要做任何事。
class AnalysisPlanCard extends StatefulWidget {
  final String text;
  final String sourceFormat;
  final InputQualityEvidence inputQuality;

  /// 有需要留意的項目時是否自動展開。窄螢幕傳 false：展開的卡片會把
  /// 「開始檢測」擠出畫面，標題的顏色與字樣已足以提示。
  final bool autoExpand;

  const AnalysisPlanCard({
    super.key,
    required this.text,
    this.sourceFormat = '',
    this.inputQuality = InputQualityEvidence.directText,
    this.autoExpand = true,
  });

  @override
  State<AnalysisPlanCard> createState() => _AnalysisPlanCardState();
}

class _AnalysisPlanCardState extends State<AnalysisPlanCard> {
  Future<ModelCatalog?>? _catalog;

  // 長文件的前處理不便宜，輸入或模型狀態沒變時沿用上一次的計畫
  String? _planText;
  String? _planFormat;
  Object? _planModels;
  ModelCatalog? _planCatalog;
  AnalysisPlan? _plan;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _catalog ??= _loadCatalog();
  }

  Future<ModelCatalog?> _loadCatalog() async {
    try {
      return await context.read<ModelProvisioner>().catalogService.load();
    } catch (_) {
      return null; // 讀不到 catalog 仍可顯示計畫，只是沒有下載建議
    }
  }

  AnalysisPlan _planFor(ModelManager manager, ModelCatalog? catalog) {
    final modelsKey = Object.hashAll([
      for (final role in const ['transformer', 'statistical', 'adversarial'])
        Object.hash(
          manager.isManualSelection(role),
          manager.activeVariant(role)?.variantId,
          Object.hashAll(
            manager.installedVariants(role).map((m) => m.variantId),
          ),
        ),
    ]);
    if (_plan != null &&
        _planText == widget.text &&
        _planFormat == widget.sourceFormat &&
        _planModels == modelsKey &&
        identical(_planCatalog, catalog)) {
      return _plan!;
    }
    _planText = widget.text;
    _planFormat = widget.sourceFormat;
    _planModels = modelsKey;
    _planCatalog = catalog;
    return _plan = AnalysisPlan.build(
      text: widget.text,
      modelManager: manager,
      sourceFormat: widget.sourceFormat,
      inputQuality: widget.inputQuality,
      catalog: catalog,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final manager = context.watch<ModelManager>();
    return FutureBuilder<ModelCatalog?>(
      future: _catalog,
      builder: (context, snapshot) {
        final plan = _planFor(manager, snapshot.data);
        final attention = plan.needsAttention;
        final accent = attention
            ? theme.colorScheme.tertiary
            : theme.colorScheme.primary;
        return Card(
          margin: EdgeInsets.zero,
          child: Theme(
            data: theme.copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: ValueKey(attention),
              initiallyExpanded: attention && widget.autoExpand,
              tilePadding: const EdgeInsets.symmetric(horizontal: 12),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              leading: Icon(LucideIcons.route, size: 18, color: accent),
              title: Text(
                attention
                    ? '${l10n.analysisPlanTitle} · ${l10n.analysisPlanAttention}'
                    : l10n.analysisPlanTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: attention ? accent : null,
                ),
              ),
              subtitle: Text(
                _summary(plan, l10n),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.analysisPlanSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final role in plan.roles) _RoleRow(plan: role),
              ],
            ),
          ),
        );
      },
    );
  }

  String _summary(AnalysisPlan plan, AppLocalizations l10n) {
    final format = plan.sourceFormat.isEmpty
        ? l10n.analysisPlanFormatPasted
        : '.${plan.sourceFormat.toUpperCase()}';
    return [
      l10n.analysisPlanLanguageLabel(
        localizedLanguageName(
          plan.language.isUndetermined ? null : plan.language.code,
          l10n,
        ),
      ),
      if (plan.language.mixedScripts) l10n.analysisPlanMixedScripts,
      l10n.analysisPlanDomainLabel(localizedDomainName(plan.domain.name, l10n)),
      l10n.analysisPlanFormatLabel(format),
      l10n.analysisPlanWords(plan.wordCount),
      if (plan.inputQuality.extractionQuality < 1)
        l10n.analysisPlanExtraction(
          (plan.inputQuality.extractionQuality * 100).round(),
        ),
    ].join(' · ');
  }
}

class _RoleRow extends StatelessWidget {
  final RolePlan plan;
  const _RoleRow({required this.plan});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final choice = plan.choice;
    final variant = choice.variant;
    final problem = variant == null || choice.fit == LanguageFit.unsupported;
    final notes = <String>[
      if (variant == null)
        l10n.routingNoModel
      else ...[
        routingBasisText(choice, l10n),
        ...routingProbeNotes(choice, l10n),
        if (choice.fit == LanguageFit.plausible) l10n.routingFitPlausible,
        if (choice.fit == LanguageFit.unsupported) l10n.routingFitUnsupported,
      ],
    ];
    final suggestion = plan.suggestion;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: Icon(
              problem ? LucideIcons.alertTriangle : LucideIcons.checkCircle2,
              size: 16,
              color: problem
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: ModelOptionsList.roleLabel(
                          plan.role,
                          plan.role,
                          l10n,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (variant != null)
                        TextSpan(
                          text:
                              ' · ${localizedModelName(variant.variantId, variant.name, l10n)}'
                              '${plan.manual ? ' · ${l10n.modelListPinnedChip}' : ''}',
                        ),
                    ],
                  ),
                  style: theme.textTheme.bodySmall,
                ),
                for (final note in notes)
                  Text(
                    note,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (suggestion != null)
                  _Suggestion(role: plan.role, variant: suggestion),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Suggestion extends StatelessWidget {
  final String role;
  final ModelVariant variant;
  const _Suggestion({required this.role, required this.variant});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final size = ModelOptionsList.sizeLabel(variant.sizeBytes);
    final state = context.watch<ModelManager>().roleState(role);
    final downloading =
        state?.transientState == InstallState.downloading &&
        state?.downloadingVariantId == variant.id;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.routingSuggestion(
              ModelOptionsList.variantLabel(variant, l10n),
              size,
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          if (downloading)
            LinearProgressIndicator(value: state?.progress)
          else
            FilledButton.tonalIcon(
              onPressed: () => context.read<ModelProvisioner>().downloadVariant(
                role,
                variant,
                l10n: l10n,
              ),
              icon: Icon(LucideIcons.download, size: 16),
              label: Text(l10n.modelListDownloadButton(size)),
            ),
        ],
      ),
    );
  }
}
