import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/detection/model_catalog.dart';
import '../../core/detection/model_manager.dart';
import '../../core/detection/model_provisioner.dart';

/// 共用的模型選項清單：每個 role 列出所有變體，標示硬體推薦、安裝與使用中狀態，
/// 提供下載 / 刪除 / 更新 / 設為使用中 / 查看模型頁面。
/// 供首次啟動引導與設定的模型管理頁共用。
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
    final manager = context.watch<ModelManager>();
    final customModels = manager.installedVariants(plan.role).where((m) => m.imported).toList();

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
            if (customModels.isNotEmpty) ...[
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text('自訂匯入的模型：', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              for (final custom in customModels)
                _CustomModelTile(role: plan.role, model: custom),
            ],
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

  Future<void> _openPage() async {
    final url = variant.pageUrl;
    if (url != null) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelManager>(
      builder: (context, manager, _) {
        final rs = manager.roleState(plan.role);
        final installed = manager.isVariantInstalled(plan.role, variant.id);
        final isActive = rs?.activeVariantId == variant.id;
        final downloadingThis = rs?.transientState == InstallState.downloading &&
            rs?.downloadingVariantId == variant.id;
        final failedThis = rs?.transientState == InstallState.failed &&
            rs?.downloadingVariantId == variant.id;
        final hasUpdate = installed && manager.hasUpdate(plan.role, variant);
        final recommended = plan.isRecommended(variant);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : recommended
                      ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                      : Theme.of(context).dividerColor,
              width: isActive ? 2 : 1,
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
                  if (isActive)
                    const Chip(
                      avatar: Icon(Icons.check_circle, size: 16),
                      label: Text('使用中'),
                      visualDensity: VisualDensity.compact,
                    )
                  else if (recommended)
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
                '需 ${(variant.minRamMb / 1024).round()}GB RAM · v${variant.version}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (variant.note.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(variant.note,
                      style: Theme.of(context).textTheme.bodySmall),
                ),
              const SizedBox(height: 8),
              if (downloadingThis)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: rs?.progress),
                    const SizedBox(height: 4),
                    Text(
                      '下載中… ${((rs?.progress ?? 0) * 100).round()}%'
                      '（${ModelOptionsList.sizeLabel(((rs?.progress ?? 0) * variant.sizeBytes).round())}'
                      ' / ${ModelOptionsList.sizeLabel(variant.sizeBytes)}）',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                )
              else
                _actions(context, manager,
                    installed: installed,
                    isActive: isActive,
                    hasUpdate: hasUpdate,
                    failed: failedThis,
                    error: rs?.error),
            ],
          ),
        );
      },
    );
  }

  Widget _actions(
    BuildContext context,
    ModelManager manager, {
    required bool installed,
    required bool isActive,
    required bool hasUpdate,
    required bool failed,
    String? error,
  }) {
    final provisioner = context.read<ModelProvisioner>();
    final fits = plan.fitsDevice(variant);

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!installed && variant.isDownloadable)
          FilledButton.tonalIcon(
            onPressed: () => provisioner.downloadVariant(plan.role, variant),
            icon: const Icon(Icons.download, size: 18),
            label: Text('下載（${ModelOptionsList.sizeLabel(variant.sizeBytes)}）'),
          ),
        if (!installed && !variant.isDownloadable)
          const Chip(label: Text('即將推出')),
        if (installed && !isActive)
          OutlinedButton.icon(
            onPressed: () => manager.setActive(plan.role, variant.id),
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('設為使用中'),
          ),
        if (hasUpdate)
          FilledButton.tonalIcon(
            onPressed: () => provisioner.downloadVariant(plan.role, variant),
            icon: const Icon(Icons.system_update_alt, size: 18),
            label: const Text('更新'),
          ),
        if (installed)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: '刪除',
            onPressed: () => _confirmDelete(context, manager),
          ),
        if (variant.pageUrl != null)
          TextButton.icon(
            onPressed: _openPage,
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('模型頁面'),
          ),
        if (!fits && !installed)
          Text('可能超出裝置記憶體',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 12)),
        if (failed)
          Text('失敗：${error ?? ''}',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error, fontSize: 12)),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, ModelManager manager) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除模型？'),
        content: Text(
          '將刪除「${variant.name}」（${ModelOptionsList.sizeLabel(variant.sizeBytes)}）。'
          '刪除後需重新下載才能再次使用。',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await manager.removeVariant(plan.role, variant.id);
    }
  }
}

class _CustomModelTile extends StatelessWidget {
  final String role;
  final InstalledModel model;
  const _CustomModelTile({required this.role, required this.model});

  @override
  Widget build(BuildContext context) {
    return Consumer<ModelManager>(
      builder: (context, manager, _) {
        final rs = manager.roleState(role);
        final isActive = rs?.activeVariantId == model.variantId;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerColor,
              width: isActive ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Chip(
                    avatar: Icon(Icons.star, size: 16),
                    label: Text('自訂'),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(model.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  if (isActive)
                    const Chip(
                      avatar: Icon(Icons.check_circle, size: 16),
                      label: Text('使用中'),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '大小: ${ModelOptionsList.sizeLabel(model.sizeBytes)} · '
                'Tokenizer: ${model.tokenizer} · '
                'AI Label Index: ${model.aiLabelIndex}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (!isActive)
                    OutlinedButton.icon(
                      onPressed: () => manager.setActive(role, model.variantId),
                      icon: const Icon(Icons.swap_horiz, size: 18),
                      label: const Text('設為使用中'),
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '刪除',
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('刪除模型？'),
                          content: Text(
                            '將刪除自訂匯入的「${model.displayName}」'
                            '（${ModelOptionsList.sizeLabel(model.sizeBytes)}）。'
                            '刪除後需重新匯入才能再次使用。',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('取消'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text('刪除'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await manager.removeVariant(role, model.variantId);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
