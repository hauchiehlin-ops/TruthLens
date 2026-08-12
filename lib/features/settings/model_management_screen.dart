import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_catalog.dart'
    show ModelCatalog, CatalogModel, ModelVariant, PerformanceTier;
import '../../core/detection/model_catalog_service.dart';
import '../../core/detection/model_manager.dart';
import '../../l10n/generated/app_localizations.dart';

/// 模型管理頁面：展示下載進度、已安裝模型、引擎狀態
class ModelManagementScreen extends StatefulWidget {
  const ModelManagementScreen({super.key});

  @override
  State<ModelManagementScreen> createState() => _ModelManagementScreenState();
}

class _ModelManagementScreenState extends State<ModelManagementScreen> {
  late Future<ModelCatalog> _catalogFuture;
  bool _downloadingRecommended = false;

  @override
  void initState() {
    super.initState();
    _catalogFuture = context.read<ModelCatalogService>().load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final modelManager = context.watch<ModelManager>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsModelManagementTitle),
        elevation: 0,
      ),
      body: FutureBuilder<ModelCatalog>(
        future: _catalogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(l10n.modelCatalogLoadFailed),
                ],
              ),
            );
          }

          final catalog = snapshot.data;
          if (catalog == null || catalog.models.isEmpty) {
            return Center(child: Text(l10n.modelCatalogEmpty));
          }

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // 儲存空間概覽
              _buildStorageOverview(modelManager, catalog),
              SizedBox(height: 24),

              // 按引擎分組的模型列表
              ...catalog.models.map((catalogModel) {
                final roleState = modelManager.roleState(catalogModel.role);
                if (roleState == null) return SizedBox.shrink();
                return _buildRoleSection(
                  context,
                  modelManager,
                  roleState,
                  catalogModel,
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStorageOverview(
    ModelManager modelManager,
    ModelCatalog catalog,
  ) {
    final roles = modelManager.roles;
    int totalBytes = 0;
    int installedCount = 0;
    final recommendedActions = _recommendedAnalysisModelActions(
      modelManager,
      catalog,
    );

    for (final role in roles) {
      for (final model in role.installed.values) {
        totalBytes += model.sizeBytes;
        installedCount++;
      }
    }

    final totalMb = (totalBytes / 1024 / 1024).toStringAsFixed(1);
    final totalGb = totalBytes > 1024 * 1024 * 1024
        ? ' ≈ ${(totalBytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB'
        : '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color(0xFF6B5B95).withValues(alpha: 0.1),
        border: Border.all(color: Color(0xFF6B5B95).withValues(alpha: 0.3)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.storage, color: Color(0xFF6B5B95), size: 24),
              SizedBox(width: 12),
              Text(
                '儲存空間使用',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B5B95),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '已安裝 $installedCount 個模型',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(height: 4),
          Text(
            '$totalMb MB$totalGb',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B5B95),
            ),
          ),
          SizedBox(height: 12),
          Text(
            '同一引擎可能提供多個候選模型；只要有一個標示「使用中」的模型，就代表該引擎已有預設分析模型，不需要把所有變體都下載。',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
          SizedBox(height: 12),
          FilledButton.icon(
            onPressed: recommendedActions.isEmpty || _downloadingRecommended
                ? null
                : () => _applyRecommendedAnalysisModels(
                    modelManager,
                    recommendedActions,
                  ),
            icon: _downloadingRecommended
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.download_for_offline_outlined),
            label: Text(
              recommendedActions.isEmpty
                  ? '補齊推薦分析模型（已就緒）'
                  : '補齊推薦分析模型（${recommendedActions.length}）',
            ),
          ),
        ],
      ),
    );
  }

  List<(String role, ModelVariant variant)> _recommendedAnalysisModelActions(
    ModelManager modelManager,
    ModelCatalog catalog,
  ) {
    const analysisRoles = {'transformer', 'statistical', 'adversarial'};
    return [
      for (final model in catalog.models)
        if (analysisRoles.contains(model.role))
          if (_defaultVariantFor(model) case final recommended?)
            if (recommended.isDownloadable &&
                modelManager.roleState(model.role)?.activeVariantId !=
                    recommended.id)
              (model.role, recommended),
    ];
  }

  ModelVariant? _defaultVariantFor(CatalogModel model) {
    bool multilingual(ModelVariant variant) =>
        variant.languages.contains('zh') || variant.languages.contains('multi');
    if (model.role == 'transformer') {
      for (final variant in model.variants) {
        if (variant.isDownloadable && multilingual(variant)) return variant;
      }
    }
    return model.bestFor(PerformanceTier.high, 8192);
  }

  Future<void> _applyRecommendedAnalysisModels(
    ModelManager modelManager,
    List<(String role, ModelVariant variant)> actions,
  ) async {
    setState(() => _downloadingRecommended = true);
    var failed = 0;
    for (final item in actions) {
      final installed = modelManager.isVariantInstalled(item.$1, item.$2.id);
      if (installed) {
        await modelManager.setActive(item.$1, item.$2.id);
      } else {
        final ok = await modelManager.downloadVariant(item.$1, item.$2);
        if (ok) {
          await modelManager.setActive(item.$1, item.$2.id);
        } else {
          failed++;
        }
      }
    }
    if (!mounted) return;
    setState(() => _downloadingRecommended = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          failed == 0 ? '推薦分析模型已套用為預設' : '部分模型下載失敗，請檢查網路後重試（失敗 $failed 個）',
        ),
      ),
    );
  }

  Widget _buildRoleSection(
    BuildContext context,
    ModelManager modelManager,
    RoleState role,
    CatalogModel catalogModel,
  ) {
    final l10n = AppLocalizations.of(context);

    // 獲取引擎友善名稱
    final engineName = _getEngineDisplayName(role.role, l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 引擎標題
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Color(0xFF6B5B95),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      engineName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${role.installed.length}/${catalogModel.variants.length} 個變體已安裝',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    if (role.installed.isNotEmpty)
                      Text(
                        '已可分析；未下載項目只是可選備用模型',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    if (role.role == 'adversarial')
                      Text(
                        '也就是對抗性防禦模型，用來偵測改寫或去 AI 痕跡處理。',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
              // 狀態指示
              _buildStatusIndicator(role),
            ],
          ),
        ),

        // 下載進度條（如果正在下載）
        if (role.transientState == InstallState.downloading)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '下載中...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${(role.progress * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: role.progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF6B5B95),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // 已安裝變體列表
        if (role.installed.isNotEmpty)
          ...role.installed.entries.map(
            (entry) => _buildInstalledModelTile(
              context,
              modelManager,
              role.role,
              entry.value,
              _variantById(catalogModel, entry.value.variantId),
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              '尚未安裝任何模型',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
            ),
          ),

        // 可下載的變體
        ...catalogModel.variants
            .where((v) => !role.installed.containsKey(v.id))
            .map(
              (variant) => _buildDownloadableTile(
                context,
                modelManager,
                role.role,
                variant,
                role,
              ),
            ),

        SizedBox(height: 16),
      ],
    );
  }

  ModelVariant? _variantById(CatalogModel model, String variantId) {
    for (final variant in model.variants) {
      if (variant.id == variantId) return variant;
    }
    return null;
  }

  Widget _buildStatusIndicator(RoleState role) {
    final color = switch (role.transientState) {
      InstallState.installed => Colors.green,
      InstallState.downloading => Colors.blue,
      InstallState.failed => Colors.red,
      InstallState.notInstalled => Colors.grey,
    };

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildInstalledModelTile(
    BuildContext context,
    ModelManager modelManager,
    String role,
    InstalledModel model,
    ModelVariant? catalogVariant,
  ) {
    final l10n = AppLocalizations.of(context);
    final sizeMb = (model.sizeBytes / 1024 / 1024).toStringAsFixed(1);
    final isActive =
        modelManager.roleState(role)?.activeVariantId == model.variantId;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.check_circle, color: Colors.green, size: 20),
        title: Text(
          catalogVariant?.name ?? model.displayName,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'v${model.version} • $sizeMb MB${isActive ? ' • 使用中' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (catalogVariant != null)
              _DownloadPathSummary(variant: catalogVariant),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            if (!isActive)
              PopupMenuItem(
                child: Text(l10n.modelListSetActiveButton),
                onTap: () => modelManager.setActive(role, model.variantId),
              ),
            PopupMenuItem(
              child: Text(
                l10n.commonDelete,
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => modelManager.removeVariant(role, model.variantId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadableTile(
    BuildContext context,
    ModelManager modelManager,
    String role,
    ModelVariant variant,
    RoleState roleState,
  ) {
    final l10n = AppLocalizations.of(context);
    final sizeMb = (variant.sizeBytes / 1024 / 1024).toStringAsFixed(1);
    final isDownloading =
        roleState.transientState == InstallState.downloading &&
        roleState.downloadingVariantId == variant.id;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        dense: true,
        leading: Icon(
          Icons.cloud_download_outlined,
          color: Colors.grey,
          size: 20,
        ),
        title: Text(variant.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('v${variant.version} • $sizeMb MB'),
            _DownloadPathSummary(variant: variant),
          ],
        ),
        trailing: isDownloading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FilledButton.tonal(
                onPressed: () => modelManager.downloadVariant(role, variant),
                child: Text(l10n.modelListDownloadButton('$sizeMb MB')),
              ),
      ),
    );
  }

  String _getEngineDisplayName(String roleId, AppLocalizations l10n) {
    return switch (roleId) {
      'transformer' => '🧠 ${l10n.analysisEngineTransformer}',
      'statistical' => '📊 ${l10n.analysisEngineStatistical}',
      'stylometry' => '✒️ ${l10n.analysisEngineStylometry}',
      'adversarial' => '🛡️ ${l10n.engineNameAdversarialFull}',
      _ => roleId,
    };
  }
}

class _DownloadPathSummary extends StatelessWidget {
  final ModelVariant variant;

  const _DownloadPathSummary({required this.variant});

  @override
  Widget build(BuildContext context) {
    final urls = [
      if (variant.url != null && variant.url!.isNotEmpty)
        (AppLocalizations.of(context).modelDownloadPathModelFile, variant.url!),
      if (variant.tokenizerUrl != null && variant.tokenizerUrl!.isNotEmpty)
        ('Tokenizer', variant.tokenizerUrl!),
    ];
    if (urls.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final item in urls)
            ActionChip(
              avatar: const Icon(Icons.link, size: 14),
              label: Text(
                AppLocalizations.of(context).modelDownloadPathChip(item.$1),
              ),
              visualDensity: VisualDensity.compact,
              onPressed: () => _copyUrl(context, item.$2),
            ),
        ],
      ),
    );
  }

  static Future<void> _copyUrl(BuildContext context, String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).modelDownloadPathCopied),
      ),
    );
  }
}
