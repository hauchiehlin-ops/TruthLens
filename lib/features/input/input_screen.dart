import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_catalog_service.dart';
import '../../core/detection/model_manager.dart';
import '../../core/models/analysis_request.dart';
import '../../core/services/document_importer.dart';
import '../../core/services/ocr_config_notifier.dart';
import '../../core/services/ocr_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/utils/app_version.dart';
import '../../core/utils/ocr_post_processor.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shared/widgets/app_copyright_footer.dart';
import '../../shared/widgets/workspace_navigation.dart';
import '../onboarding/model_prompt.dart';
import '../settings/model_import_screen.dart';
import '../settings/settings_screen.dart' show ModelManagerScreen;
import '../settings/engine_weight_settings.dart';
import '../settings/web_ocr_settings.dart';

/// 首頁：極簡輸入區 + 三個快捷入口（貼上 / 拍照 OCR / 匯入文件）
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

String workspaceModeLabel(WorkspaceMode mode, AppLocalizations l10n) =>
    switch (mode) {
      WorkspaceMode.original => l10n.workspaceModeOriginal,
      WorkspaceMode.automatic => l10n.workspaceModeAuto,
      WorkspaceMode.commandGrid => l10n.workspaceModeCommandGrid,
      WorkspaceMode.missionTimeline => l10n.workspaceModeTimeline,
      WorkspaceMode.evidenceCanvas => l10n.workspaceModeEvidence,
      WorkspaceMode.cosmicFuture => l10n.workspaceModeCosmicFuture,
      WorkspaceMode.softEducation => l10n.workspaceModeSoftEducation,
    };

class _InputScreenState extends State<InputScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = TextEditingController();
  double _rightPanelWidth = 400; // 右側面板預設寬度
  String _sourceFileName = '';

  @override
  void initState() {
    super.initState();
    // 主動、靜默地檢查模型是否有更新；離線或失敗時不影響任何功能。
    context.read<ModelManager>().checkForUpdates(
      context.read<ModelCatalogService>(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showFloatingSnackBar(String text) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1800),
        margin: const EdgeInsets.only(bottom: 84, left: 16, right: 16),
      ),
    );
  }

  Future<void> _startAnalysis() async {
    final l10n = AppLocalizations.of(context);
    final text = _controller.text.trim();
    if (text.length < 40) {
      _showFloatingSnackBar(l10n.inputTooShortSnackbar);
      return;
    }

    // 需模型分析：核心偵測模型未安裝且使用者未關閉提醒時，再次說明必要性
    final prefs = context.read<PreferencesService>();
    final manager = context.read<ModelManager>();
    await manager.refreshInstallStates();
    if (!manager.isInstalled('transformer') && !prefs.modelPromptSuppressed) {
      if (!mounted) return;
      final choice = await showModelDownloadPrompt(context);
      if (!mounted) return;
      if (choice == ModelPromptResult.download) {
        context.push('/models'); // 前往下載，不繼續本次分析
        return;
      }
      // skip / dismissed → 以現有引擎（統計/風格）繼續分析
    }
    if (!mounted) return;
    context.push(
      '/analysis',
      extra: AnalysisRequest(text: text, sourceFileName: _sourceFileName),
    );
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!;
      _sourceFileName = '';
      setState(() {});
    }
  }

  Future<void> _scanImage() async {
    final l10n = AppLocalizations.of(context);
    final ocr = context.read<OcrService>();
    if (!await ocr.isSupported) {
      if (!mounted) return;
      _showFloatingSnackBar(l10n.inputOcrUnsupported);
      return;
    }
    final path = await ImagePicker.pick();
    if (path == null || !mounted) return;

    _showFloatingSnackBar(l10n.inputOcrRecognizing);
    final rawText = await ocr.recognize(path);
    if (!mounted) return;
    if (rawText == null || rawText.trim().isEmpty) {
      _showFloatingSnackBar(OcrService.lastErrorMessage ?? l10n.inputOcrNoText);
      return;
    }
    final text = OcrPostProcessor.clean(rawText);
    _controller.text = text;
    _sourceFileName = '';
    setState(() {});
    _showFloatingSnackBar(l10n.inputOcrRecognized(text.length));
  }

  void _clearInput() {
    _controller.clear();
    _sourceFileName = '';
    setState(() {});
  }

  Future<void> _importDocument() async {
    final l10n = AppLocalizations.of(context);
    final ocr = context.read<OcrService>();
    final canUsePdfOcr = await ocr.isReadyForPdfOcr;
    final doc = await DocumentImporter.pick(
      pdfOcr: canUsePdfOcr
          ? (imageBytes, pageNumber, pageCount) async {
              if (mounted) {
                _showFloatingSnackBar(
                  l10n.inputPdfOcrProgress(pageNumber, pageCount),
                );
              }
              return ocr.recognizeBytes(imageBytes);
            }
          : null,
    );
    if (doc == null || !mounted) return;
    if (doc.text.isEmpty) {
      final message = switch (doc.pdfImportIssue) {
        PdfImportIssue.needsOcr => l10n.inputPdfNeedsOcr(doc.fileName),
        PdfImportIssue.tooManyPages => l10n.inputPdfTooManyPages(
          doc.fileName,
          DocumentImporter.effectiveMaxPdfOcrPages,
        ),
        PdfImportIssue.unreadable => l10n.inputPdfUnreadable(doc.fileName),
        PdfImportIssue.legacyDocUnreadable => l10n.inputDocLegacyUnreadable(
          doc.fileName,
        ),
        PdfImportIssue.none => l10n.inputImportNoText(doc.fileName),
      };
      _showFloatingSnackBar(message);
      return;
    }
    _controller.text = doc.text;
    _sourceFileName = doc.fileName;
    setState(() {});
    _showFloatingSnackBar(
      doc.usedPdfOcr
          ? l10n.inputPdfOcrSuccess(doc.fileName, doc.text.length)
          : l10n.inputImportSuccess(doc.fileName, doc.text.length),
    );
  }

  /// 顯示目前使用中的偵測模型，或提示未安裝（僅統計/風格分析）
  Widget _activeModelChip(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = context.watch<ModelManager>().activeVariant('transformer');
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          active != null ? LucideIcons.checkCircle : LucideIcons.info,
          size: 14,
          color: scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            active != null
                ? l10n.inputActiveModel(active.variantId)
                : l10n.inputNoModel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  /// 顯示目前實際生效的 OCR 引擎（本地伺服器／Gemini／尚未設定），並標示是否
  /// 已實測連線成功，讓使用者不必打開設定就能確認辨識來源。
  Widget _ocrEngineChip(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final zh = l10n.localeName.toLowerCase().startsWith('zh');
    final notifier = context.watch<OcrConfigNotifier>();
    final scheme = Theme.of(context).colorScheme;

    final (icon, label, color) = switch (notifier.activeEngine) {
      OcrEngineKind.local => (
        LucideIcons.server,
        zh
            ? (notifier.localVerified ? '本地 OCR（已測試）' : '本地 OCR（未測試）')
            : (notifier.localVerified ? 'Local OCR (verified)' : 'Local OCR (untested)'),
        notifier.localVerified ? Colors.green.shade700 : Colors.amber.shade700,
      ),
      OcrEngineKind.gemini => (
        LucideIcons.sparkles,
        zh
            ? (notifier.geminiVerified ? 'Gemini（已測試）' : 'Gemini（未測試）')
            : (notifier.geminiVerified ? 'Gemini (verified)' : 'Gemini (untested)'),
        notifier.geminiVerified ? Colors.green.shade700 : Colors.amber.shade700,
      ),
      OcrEngineKind.none => (
        LucideIcons.info,
        zh ? 'OCR 引擎：尚未設定' : 'OCR engine: not configured',
        scheme.onSurfaceVariant,
      ),
    };

    final isWideScreen = MediaQuery.of(context).size.width >= 1200;
    return InkWell(
      onTap: isWideScreen
          ? () => context.push('/settings')
          : () => _scaffoldKey.currentState?.openEndDrawer(),
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth >= 1200;
    final workspaceMode = context.watch<PreferencesService>().workspaceMode;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: isWideScreen ? null : const InputSettingsDrawer(),
      appBar: AppBar(
        title: const AppIdentityTitle(),
        actions: [
          AppOverflowMenu(
            activeMode: workspaceMode,
            onSettings: isWideScreen
                ? () => context.push('/settings')
                : () => _scaffoldKey.currentState?.openEndDrawer(),
            onHistory: () => context.push('/history'),
            onHelp: () => context.push('/help'),
            onPrivacy: () => context.push('/privacy'),
          ),
        ],
      ),
      body: isWideScreen
          ? Row(
              children: [
                // 左側：輸入區域
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.inputSubtitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: scheme.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                            if (_sourceFileName.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                _sourceFileName,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 16),
                            Expanded(
                              child: Stack(
                                children: [
                                  TextField(
                                    controller: _controller,
                                    maxLines: null,
                                    expands: true,
                                    textAlignVertical: TextAlignVertical.top,
                                    decoration: InputDecoration(
                                      hintText: l10n.inputHint,
                                    ),
                                    onChanged: (value) {
                                      if (value.trim().isEmpty) {
                                        _sourceFileName = '';
                                      }
                                      setState(() {});
                                    },
                                  ),
                                  if (_controller.text.isNotEmpty)
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: IconButton(
                                        icon: Icon(LucideIcons.x),
                                        tooltip: l10n.inputClearTooltip,
                                        onPressed: _clearInput,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            MergeSemantics(
                              child: Row(
                                children: [
                                  Expanded(child: _activeModelChip(context)),
                                  const SizedBox(width: 8),
                                  _ocrEngineChip(context),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.inputCharCount(
                                      _controller.text.trim().length,
                                    ),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: _pasteFromClipboard,
                                  icon: Icon(LucideIcons.clipboard),
                                  label: Text(l10n.inputPasteButton),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: _scanImage,
                                  icon: Icon(LucideIcons.camera),
                                  label: Text(l10n.inputOcrButton),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: _importDocument,
                                  icon: Icon(LucideIcons.folderOpen),
                                  label: Text(l10n.inputImportButton),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _controller.text.trim().isEmpty
                                  ? null
                                  : _startAnalysis,
                              icon: Icon(LucideIcons.search),
                              label: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                child: Text(
                                  l10n.inputStartButton,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const AppCopyrightFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // 可拖動分割條
                MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        _rightPanelWidth = (_rightPanelWidth - details.delta.dx)
                            .clamp(300, 600);
                      });
                    },
                    child: Container(
                      width: 8,
                      color: scheme.outlineVariant.withValues(alpha: 0.3),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeColumn,
                        child: Center(
                          child: Container(
                            width: 3,
                            height: 40,
                            decoration: BoxDecoration(
                              color: scheme.outlineVariant.withValues(
                                alpha: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 右側：設定面板
                SizedBox(
                  width: _rightPanelWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: scheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                    ),
                    child: _SettingsPanelInline(),
                  ),
                ),
              ],
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.inputSubtitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                      if (_sourceFileName.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          _sourceFileName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),
                      Expanded(
                        child: Stack(
                          children: [
                            TextField(
                              controller: _controller,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: l10n.inputHint,
                              ),
                              onChanged: (value) {
                                if (value.trim().isEmpty) {
                                  _sourceFileName = '';
                                }
                                setState(() {});
                              },
                            ),
                            if (_controller.text.isNotEmpty)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: IconButton(
                                  icon: Icon(LucideIcons.x),
                                  tooltip: l10n.inputClearTooltip,
                                  onPressed: _clearInput,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      MergeSemantics(
                        child: Row(
                          children: [
                            Expanded(child: _activeModelChip(context)),
                            const SizedBox(width: 8),
                            _ocrEngineChip(context),
                            const SizedBox(width: 8),
                            Text(
                              l10n.inputCharCount(
                                _controller.text.trim().length,
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _pasteFromClipboard,
                            icon: Icon(LucideIcons.clipboard),
                            label: Text(l10n.inputPasteButton),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _scanImage,
                            icon: Icon(LucideIcons.camera),
                            label: Text(l10n.inputOcrButton),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: _importDocument,
                            icon: Icon(LucideIcons.folderOpen),
                            label: Text(l10n.inputImportButton),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _controller.text.trim().isEmpty
                            ? null
                            : _startAnalysis,
                        icon: Icon(LucideIcons.search),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            l10n.inputStartButton,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const AppCopyrightFooter(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// 右側設定面板（內聯版本，用於寬屏直接顯示）
class _SettingsPanelInline extends StatefulWidget {
  const _SettingsPanelInline();

  @override
  State<_SettingsPanelInline> createState() => _SettingsPanelInlineState();
}

class _SettingsPanelInlineState extends State<_SettingsPanelInline> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesService>();
    final modelManager = context.watch<ModelManager>();
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 標題
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.settingsAppBarTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: scheme.primary,
              ),
            ),
          ),
          const Divider(),

          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.layoutGrid),
            title: Text(l10n.workspaceModeSectionTitle),
            subtitle: Text(l10n.workspaceModeSectionSubtitle),
            trailing: DropdownButton<WorkspaceMode>(
              value: prefs.workspaceMode,
              items: [
                for (final mode in WorkspaceMode.values)
                  DropdownMenuItem(
                    value: mode,
                    child: Text(workspaceModeLabel(mode, l10n)),
                  ),
              ],
              onChanged: (value) {
                if (value != null) prefs.setWorkspaceMode(value);
              },
            ),
          ),
          const Divider(),


          // ESL 糾正
          SwitchListTile(
            dense: true,
            title: Text(
              l10n.settingsEslTitle,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            subtitle: Text(
              l10n.settingsEslSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: prefs.eslCorrectionEnabled,
            onChanged: (v) => prefs.setEslCorrection(v),
          ),
          const Divider(),

          // 檢測引擎（說明：自動啟用所有引擎以提高準確性）
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              l10n.settingsEngineSectionTitle,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            dense: true,
            title: Text(
              l10n.settingsEngineTransformerTitle,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            subtitle: Text(
              l10n.settingsEngineTransformerSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: prefs.isEngineEnabled('transformer'),
            onChanged: (v) => prefs.setEngineEnabled('transformer', v),
          ),
          SwitchListTile(
            dense: true,
            title: Text(
              l10n.settingsEngineStatisticalTitle,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            subtitle: Text(
              l10n.settingsEngineStatisticalSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: prefs.isEngineEnabled('statistical'),
            onChanged: (v) => prefs.setEngineEnabled('statistical', v),
          ),
          SwitchListTile(
            dense: true,
            title: Text(
              l10n.settingsEngineStylometryTitle,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            subtitle: Text(
              l10n.settingsEngineStylometrySubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: prefs.isEngineEnabled('stylometry'),
            onChanged: (v) => prefs.setEngineEnabled('stylometry', v),
          ),
          SwitchListTile(
            dense: true,
            title: Text(
              l10n.settingsEngineAdversarialTitle,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            subtitle: Text(
              l10n.settingsEngineAdversarialSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: prefs.isEngineEnabled('adversarial'),
            onChanged: (v) => prefs.setEngineEnabled('adversarial', v),
          ),
          const EngineWeightSettingsCard(compact: true),
          const Divider(),

          // 鏈接驗證
          SwitchListTile(
            dense: true,
            title: Text(
              l10n.settingsLinkVerificationTitle,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            subtitle: Text(
              l10n.settingsLinkVerificationSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            value: prefs.linkVerificationEnabled,
            onChanged: (v) => prefs.setLinkVerificationEnabled(v),
          ),
          const Divider(),

          // 主題
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsThemeTitle,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(LucideIcons.sunMoon),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(LucideIcons.sun),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(LucideIcons.moon),
                    ),
                  ],
                  selected: {prefs.themeMode},
                  onSelectionChanged: (s) => prefs.setThemeMode(s.first),
                ),
              ],
            ),
          ),
          const Divider(),

          // 語言選擇
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsLanguageTitle,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                l10n.settingsLanguageSubtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              DropdownButton<Locale?>(
                isExpanded: true,
                value: prefs.locale,
                items: [
                  for (final option in kSupportedLanguageOptions)
                    DropdownMenuItem(value: option.$1, child: Text(option.$2)),
                ],
                onChanged: (value) => prefs.setLocale(value),
              ),
            ],
          ),
          const Divider(),

          // 模型管理
          ListTile(
            dense: true,
            leading: Badge(
              isLabelVisible: modelManager.hasAnyUpdate,
              child: Icon(LucideIcons.download),
            ),
            title: Text(
              l10n.settingsModelManagementTitle,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            subtitle: Text(
              modelManager.hasAnyUpdate
                  ? l10n.settingsModelManagementUpdateSubtitle
                  : l10n.settingsModelManagementSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModelManagerScreen()),
              );
            },
          ),
          const Divider(),

          // 自訂模型匯入
          ListTile(
            dense: true,
            leading: Icon(LucideIcons.upload),
            title: Text(
              l10n.settingsCustomImportTitle,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            subtitle: Text(
              l10n.settingsCustomImportSubtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ModelImportScreen()),
              );
            },
          ),
          const Divider(),

          // Web OCR 設定
          if (kIsWeb) ...[
            const WebOcrSettingsCard(compact: true),
            const Divider(),
          ],

          // 關於應用
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(LucideIcons.info, size: 18),
                  const SizedBox(width: 8),
                  const Text('TruthLens'),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.settingsVersionSubtitle(
                  AppVersion.displayVersion,
                  AppVersion.buildNumber,
                ),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class InputSettingsDrawer extends StatefulWidget {
  const InputSettingsDrawer({super.key});

  @override
  State<InputSettingsDrawer> createState() => _InputSettingsDrawerState();
}

class _InputSettingsDrawerState extends State<InputSettingsDrawer> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prefs = context.watch<PreferencesService>();
    final modelManager = context.watch<ModelManager>();
    final scheme = Theme.of(context).colorScheme;

    // 響應式寬度：平板 320px，桌機最多 420px
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth < 600
        ? 320.0
        : (screenWidth < 900 ? 380.0 : 420.0);

    return Drawer(
      width: drawerWidth,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.settingsAppBarTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x),
                    tooltip: l10n.commonClose,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(LucideIcons.layoutGrid),
              title: Text(l10n.workspaceModeSectionTitle),
              subtitle: Text(l10n.workspaceModeSectionSubtitle),
              trailing: DropdownButton<WorkspaceMode>(
                value: prefs.workspaceMode,
                items: [
                  for (final mode in WorkspaceMode.values)
                    DropdownMenuItem(
                      value: mode,
                      child: Text(workspaceModeLabel(mode, l10n)),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) prefs.setWorkspaceMode(value);
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(LucideIcons.languages),
              title: Text(l10n.settingsLanguageTitle),
              subtitle: Text(l10n.settingsLanguageSubtitle),
              trailing: DropdownButton<Locale?>(
                value: prefs.locale,
                items: [
                  for (final option in kSupportedLanguageOptions)
                    DropdownMenuItem(value: option.$1, child: Text(option.$2)),
                ],
                onChanged: (value) => prefs.setLocale(value),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Badge(
                isLabelVisible: modelManager.hasAnyUpdate,
                child: Icon(LucideIcons.download),
              ),
              title: Text(l10n.settingsModelManagementTitle),
              subtitle: Text(
                modelManager.hasAnyUpdate
                    ? l10n.settingsModelManagementUpdateSubtitle
                    : l10n.settingsModelManagementSubtitle,
              ),
              trailing: Icon(LucideIcons.chevronRight, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ModelManagerScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(LucideIcons.upload),
              title: Text(l10n.settingsCustomImportTitle),
              subtitle: Text(l10n.settingsCustomImportSubtitle),
              trailing: Icon(LucideIcons.chevronRight, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ModelImportScreen()),
                );
              },
            ),
            const Divider(),
            if (kIsWeb) ...[
              const WebOcrSettingsCard(compact: true),
              const Divider(),
            ],
            SwitchListTile(
              title: Text(l10n.settingsEslTitle),
              subtitle: Text(l10n.settingsEslSubtitle),
              value: prefs.eslCorrectionEnabled,
              onChanged: (v) => prefs.setEslCorrection(v),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l10n.settingsEngineSectionTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            SwitchListTile(
              title: Text(l10n.settingsEngineTransformerTitle),
              subtitle: Text(l10n.settingsEngineTransformerSubtitle),
              value: prefs.isEngineEnabled('transformer'),
              onChanged: (v) => prefs.setEngineEnabled('transformer', v),
            ),
            SwitchListTile(
              title: Text(l10n.settingsEngineStatisticalTitle),
              subtitle: Text(l10n.settingsEngineStatisticalSubtitle),
              value: prefs.isEngineEnabled('statistical'),
              onChanged: (v) => prefs.setEngineEnabled('statistical', v),
            ),
            SwitchListTile(
              title: Text(l10n.settingsEngineStylometryTitle),
              subtitle: Text(l10n.settingsEngineStylometrySubtitle),
              value: prefs.isEngineEnabled('stylometry'),
              onChanged: (v) => prefs.setEngineEnabled('stylometry', v),
            ),
            SwitchListTile(
              title: Text(l10n.settingsEngineAdversarialTitle),
              subtitle: Text(l10n.settingsEngineAdversarialSubtitle),
              value: prefs.isEngineEnabled('adversarial'),
              onChanged: (v) => prefs.setEngineEnabled('adversarial', v),
            ),
            const EngineWeightSettingsCard(),
            const Divider(),
            SwitchListTile(
              title: Text(l10n.settingsLinkVerificationTitle),
              subtitle: Text(l10n.settingsLinkVerificationSubtitle),
              value: prefs.linkVerificationEnabled,
              onChanged: (v) => prefs.setLinkVerificationEnabled(v),
            ),
            const Divider(),
            ListTile(
              title: Text(l10n.settingsThemeTitle),
              trailing: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(LucideIcons.sunMoon),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(LucideIcons.sun),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(LucideIcons.moon),
                  ),
                ],
                selected: {prefs.themeMode},
                onSelectionChanged: (s) => prefs.setThemeMode(s.first),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(LucideIcons.info),
              title: const Text('TruthLens'),
              subtitle: Text(
                l10n.settingsVersionSubtitle(
                  AppVersion.displayVersion,
                  AppVersion.buildNumber,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
