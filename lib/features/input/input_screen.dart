import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_catalog_service.dart';
import '../../core/detection/model_manager.dart';
import '../../core/services/document_importer.dart';
import '../../core/services/ocr_service.dart';
import '../../core/services/preferences_service.dart';
import '../onboarding/model_prompt.dart';

/// 首頁：極簡輸入區 + 三個快捷入口（貼上 / 拍照 OCR / 匯入文件）
class InputScreen extends StatefulWidget {
  const InputScreen({super.key});

  @override
  State<InputScreen> createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 主動、靜默地檢查模型是否有更新；離線或失敗時不影響任何功能。
    context
        .read<ModelManager>()
        .checkForUpdates(context.read<ModelCatalogService>());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startAnalysis() async {
    final text = _controller.text.trim();
    if (text.length < 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入至少 40 個字元的文本以獲得可靠分析')),
      );
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
    context.push('/analysis', extra: text);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _controller.text = data.text!;
      setState(() {});
    }
  }

  Future<void> _scanImage() async {
    final ocr = context.read<OcrService>();
    if (!await ocr.isSupported) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('此平台尚未支援 OCR 文字辨識')),
      );
      return;
    }
    final path = await ImagePicker.pick();
    if (path == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('辨識中…')),
    );
    final text = await ocr.recognize(path);
    if (!mounted) return;
    if (text == null || text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('未從圖片中辨識到文字')),
      );
      return;
    }
    _controller.text = text.trim();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已辨識 ${text.trim().length} 個字元')),
    );
  }

  void _clearInput() {
    _controller.clear();
    setState(() {});
  }

  Future<void> _importDocument() async {
    final doc = await DocumentImporter.pick();
    if (doc == null || !mounted) return;
    if (doc.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('「${doc.fileName}」沒有可讀取的文字內容')),
      );
      return;
    }
    _controller.text = doc.text;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已匯入「${doc.fileName}」（${doc.text.length} 字元）')),
    );
  }

  /// 顯示目前使用中的偵測模型，或提示未安裝（僅統計/風格分析）
  Widget _activeModelChip(BuildContext context) {
    final active = context.watch<ModelManager>().activeVariant('transformer');
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(active != null ? Icons.memory : Icons.info_outline,
            size: 14, color: scheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          active != null ? '模型：${active.variantId}' : '未安裝模型（僅統計/風格分析）',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('TruthLens'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '歷史紀錄',
            onPressed: () => context.push('/history'),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: '操作說明',
            onPressed: () => context.push('/help'),
          ),
          IconButton(
            icon: const Icon(Icons.privacy_tip_outlined),
            tooltip: '隱私權政策',
            onPressed: () => context.push('/privacy'),
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: context.watch<ModelManager>().hasAnyUpdate,
              child: const Icon(Icons.settings_outlined),
            ),
            tooltip: '設定',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '貼上或輸入文本，離線檢測 AI 生成內容',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Stack(
                    children: [
                      TextField(
                        controller: _controller,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: '在此輸入或貼上要檢測的文字…',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      if (_controller.text.isNotEmpty)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: '清除內容',
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
                      _activeModelChip(context),
                      const Spacer(),
                      Text(
                        '${_controller.text.trim().length} 字元',
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
                      icon: const Icon(Icons.content_paste),
                      label: const Text('貼上'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _scanImage,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('圖片辨識'),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: _importDocument,
                      icon: const Icon(Icons.folder_open_outlined),
                      label: const Text('匯入文件'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _controller.text.trim().isEmpty
                      ? null
                      : _startAnalysis,
                  icon: const Icon(Icons.search),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('開始檢測', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
