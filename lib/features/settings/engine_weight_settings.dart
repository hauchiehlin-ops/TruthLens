import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/services/preferences_service.dart';
import '../../l10n/generated/app_localizations.dart';

class EngineWeightSettingsCard extends StatefulWidget {
  final bool compact;

  const EngineWeightSettingsCard({super.key, this.compact = false});

  @override
  State<EngineWeightSettingsCard> createState() =>
      _EngineWeightSettingsCardState();
}

class _EngineWeightSettingsCardState extends State<EngineWeightSettingsCard> {
  Map<String, int>? _draft;
  bool _dirty = false;

  Map<String, int> _savedPercentages(PreferencesService prefs) => {
    for (final role in PreferencesService.engineRoles)
      role: (prefs.engineWeight(role) * 100).round(),
  };

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesService>();
    final l10n = AppLocalizations.of(context);
    if (!_dirty) _draft = _savedPercentages(prefs);
    final draft = _draft!;
    final total = draft.values.fold<int>(0, (sum, value) => sum + value);
    final valid = total == 100;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? 0 : 16,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.settingsEngineWeightsTitle,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.settingsEngineWeightsSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          for (final role in PreferencesService.engineRoles)
            _WeightRow(
              label: _label(role, l10n),
              help: _help(role, l10n),
              value: draft[role]!,
              helpTooltip: l10n.settingsEngineInfoTooltip,
              onChanged: (value) {
                setState(() {
                  draft[role] = value;
                  _dirty = true;
                });
              },
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                valid ? Icons.check_circle_outline : Icons.error_outline,
                size: 18,
                color: valid ? scheme.primary : scheme.error,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  valid
                      ? l10n.settingsEngineWeightsTotalValid(total)
                      : l10n.settingsEngineWeightsTotalInvalid(total),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: valid ? scheme.onSurfaceVariant : scheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: valid && _dirty
                    ? () async {
                        await prefs.setEngineWeights({
                          for (final entry in draft.entries)
                            entry.key: entry.value / 100,
                        });
                        if (!context.mounted) return;
                        setState(() => _dirty = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.settingsEngineWeightsSaved),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.save_outlined, size: 18),
                label: Text(l10n.settingsEngineWeightsSave),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _draft = {
                      for (final entry
                          in PreferencesService.defaultEngineWeights.entries)
                        entry.key: (entry.value * 100).round(),
                    };
                    _dirty = true;
                  });
                },
                icon: const Icon(Icons.restart_alt, size: 18),
                label: Text(l10n.settingsEngineWeightsRestoreDefaults),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _label(String role, AppLocalizations l10n) => switch (role) {
    'transformer' => l10n.settingsEngineTransformerTitle,
    'statistical' => l10n.settingsEngineStatisticalTitle,
    'stylometry' => l10n.settingsEngineStylometryTitle,
    'adversarial' => l10n.settingsEngineAdversarialTitle,
    _ => role,
  };

  String _help(String role, AppLocalizations l10n) => switch (role) {
    'transformer' => l10n.settingsEngineTransformerHelp,
    'statistical' => l10n.settingsEngineStatisticalHelp,
    'stylometry' => l10n.settingsEngineStylometryHelp,
    'adversarial' => l10n.settingsEngineAdversarialHelp,
    _ => '',
  };
}

class _WeightRow extends StatefulWidget {
  final String label;
  final String help;
  final String helpTooltip;
  final int value;
  final ValueChanged<int> onChanged;

  const _WeightRow({
    required this.label,
    required this.help,
    required this.helpTooltip,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_WeightRow> createState() => _WeightRowState();
}

class _WeightRowState extends State<_WeightRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _WeightRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value &&
        _controller.text != widget.value.toString()) {
      _controller.value = TextEditingValue(
        text: widget.value.toString(),
        selection: TextSelection.collapsed(
          offset: widget.value.toString().length,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              widget.label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            tooltip: widget.helpTooltip,
            onPressed: () => showDialog<void>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: Text(widget.label),
                content: Text(widget.help),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(AppLocalizations.of(context).commonClose),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.info_outline),
          ),
          SizedBox(
            width: 88,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.end,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  final value = int.tryParse(newValue.text);
                  return value != null && value <= 100 ? newValue : oldValue;
                }),
              ],
              decoration: const InputDecoration(
                suffixText: '%',
                isDense: true,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
              ),
              onChanged: (text) {
                final parsed = int.tryParse(text) ?? 0;
                widget.onChanged(parsed.clamp(0, 100));
              },
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
    ],
  );
}
