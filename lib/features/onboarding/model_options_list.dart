import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_catalog.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/model_provisioner.dart';

/// 共用的模型選項清單：每個 role 列出所有變體，標示硬體推薦與安裝狀態，
/// 提供下載 / 移除。供首次啟動引導與設定的模型管理頁共用。
class ModelOptionsList extends StatelessWidget {
  final List<ProvisionPlan> plans;
  const ModelOptionsList({super.key, required this.plans});

  static String sizeLabel(int bytes) => bytes >= 1024 * 1024 * 1024
      ? '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB'
      : '${(bytes / (1024 * 1024)).round()} MB';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [for (final plan in plans) _roleSection(context, plan)],
    );
  }

  Widget _roleSection(BuildContext context, ProvisionPlan plan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plan.roleName,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            for (final v in plan.variants)
              _VariantTile(plan: plan, variant: v),
          ],
        ),
      ),
    );
  }
}

class _VariantTile extends StatelessWidget {
  final ProvisionPlan plan;
  final ModelVariant variant;
  const _VariantTile({required this.plan, required this.variant});

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelManager>(
      builder: (context, manager, _) {
        final status = manager.statusFor(plan.role);
        final isThisInstalled = status?.installed?.variantId == variant.id;
        final downloading = status?.state == InstallState.downloading;
        final fits = plan.fitsDevice(variant);
        final recommended = plan.isRecommended(variant);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: recommended
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(variant.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  if (recommended)
                    Chip(
                      label: const Text('推薦'),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${ModelOptionsList.sizeLabel(variant.sizeBytes)} · '
                '${variant.languages.join('/')} · '
                '需 ${(variant.minRamMb / 1024).round()}GB RAM · 來源 ${variant.source}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (variant.note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(variant.note,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              const SizedBox(height: 8),
              _action(context, status, isThisInstalled, downloading, fits),
            ],
          ),
        );
      },
    );
  }

  Widget _action(BuildContext context, ModelStatus? status,
      bool isThisInstalled, bool downloading, bool fits) {
    if (isThisInstalled) {
      return Row(
        children: [
          const Chip(
            avatar: Icon(Icons.check_circle, size: 16),
            label: Text('已安裝'),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '移除',
            onPressed: () => context.read<ModelManager>().remove(plan.role),
          ),
        ],
      );
    }
    if (downloading) {
      return LinearProgressIndicator(value: status?.progress);
    }
    if (!variant.isDownloadable) return const Chip(label: Text('即將推出'));

    return Row(
      children: [
        FilledButton.tonalIcon(
          onPressed: () =>
              context.read<ModelProvisioner>().downloadVariant(plan.role, variant),
          icon: const Icon(Icons.download, size: 18),
          label: Text('下載（${ModelOptionsList.sizeLabel(variant.sizeBytes)}）'),
        ),
        if (!fits)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('可能超出裝置記憶體',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
        if (status?.state == InstallState.failed)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text('失敗：${status?.error ?? ''}',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}
