import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_manager.dart';
import '../../core/detection/model_registry.dart';
import '../../l10n/generated/app_localizations.dart';

/// 匯入自訂 ONNX 模型。所有檔案存取一律經 [FilePicker]（見 [_pickModel] /
/// [_pickTokenizer]），這是 macOS App Sandbox 下唯一能取得讀取權限的方式；
/// 不要改成直接用硬編碼路徑建立 File（例如指向開發機的專案目錄），沙盒化的
/// App 對未經選檔對話框授權的路徑沒有讀取權限，會在 copy/讀取時失敗。
class ModelImportScreen extends StatefulWidget {
  const ModelImportScreen({super.key});

  @override
  State<ModelImportScreen> createState() => _ModelImportScreenState();
}

class _ModelImportScreenState extends State<ModelImportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _testController = TextEditingController(
    text: 'This is a sample text to test the imported model classification accuracy.',
  );

  File? _modelFile;
  String? _modelFileDisplayName;
  File? _tokenizerFile;
  String? _tokenizerFileDisplayName;
  String _tokenizerType = 'bert-wordpiece';
  int _aiLabelIndex = 1;
  String _targetRole = 'transformer';

  bool _testing = false;
  double? _testResult;
  String? _testError;
  bool _importing = false;

  /// 與剛選取的模型檔內容相同（sha256 一致）的既有已安裝模型；非 null 時顯示
  /// 重複提醒。不會阻擋匯入，只是提醒使用者可能不需要再匯入一次。
  InstalledModel? _duplicate;
  bool _checkingDuplicate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _testController.dispose();
    super.dispose();
  }

  /// macOS App Sandbox 下，NSOpenPanel 授予的檔案存取權只在選檔當下短暫有效；
  /// 若只保留 `path` 字串、之後才用 dart:io 讀取/複製，會因授權已過期而
  /// 擲出 `Operation not permitted`（errno=1）。因此必須帶 `withData: true`
  /// 讓 plugin 在選檔當下、授權仍有效時把 bytes 讀出，並立刻寫進 App 自己
  /// 沙盒內可寫的暫存目錄，之後一律對著這個副本操作。回傳的 name 供預填欄位用。
  Future<(File, String)?> _pickIntoSandbox(
      {required List<String> extensions}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: extensions,
      withData: true,
    );
    final picked = result?.files.single;
    if (picked?.bytes == null) return null;

    final tmpDir = await getTemporaryDirectory();
    final dest = File(p.join(
      tmpDir.path,
      '${DateTime.now().microsecondsSinceEpoch}_${picked!.name}',
    ));
    await dest.writeAsBytes(picked.bytes!);
    return (dest, picked.name);
  }

  Future<void> _pickModel() async {
    final picked = await _pickIntoSandbox(extensions: ['onnx']);
    if (picked == null) return;
    final (file, name) = picked;
    setState(() {
      _modelFile = file;
      _modelFileDisplayName = name;
      // Pre-fill model name with file basename without extension
      _nameController.text = name.replaceAll('.onnx', '');
      _testResult = null;
      _testError = null;
      _duplicate = null;
      _checkingDuplicate = true;
    });
    await _checkDuplicate(file);
  }

  /// 匯入前偵測：這個模型檔的內容是否與某個已安裝的模型相同（sha256 一致）。
  Future<void> _checkDuplicate(File file) async {
    final manager = context.read<ModelManager>();
    try {
      final hash = await manager.hashOf(file);
      final match = manager.findByHash(hash);
      if (!mounted) return;
      setState(() {
        _duplicate = match;
        _checkingDuplicate = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _checkingDuplicate = false);
    }
  }

  Future<void> _pickTokenizer() async {
    final picked = await _pickIntoSandbox(extensions: ['json']);
    if (picked == null) return;
    setState(() {
      _tokenizerFile = picked.$1;
      _tokenizerFileDisplayName = picked.$2;
      _testResult = null;
      _testError = null;
    });
  }

  Future<void> _runTest() async {
    final l10n = AppLocalizations.of(context);
    if (_modelFile == null) return;
    if (_tokenizerType != 'none' && _tokenizerFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.modelImportSelectTokenizerFirst)),
      );
      return;
    }

    setState(() {
      _testing = true;
      _testResult = null;
      _testError = null;
    });

    final manager = context.read<ModelManager>();
    try {
      final score = await manager.testModel(
        modelFile: _modelFile!,
        tokenizerFile: _tokenizerFile,
        tokenizerType: _tokenizerType,
        aiLabelIndex: _aiLabelIndex,
        text: _testController.text.trim(),
      );
      setState(() {
        _testResult = score;
      });
    } catch (e) {
      setState(() {
        _testError = e.toString();
      });
    } finally {
      setState(() {
        _testing = false;
      });
    }
  }

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate() || _modelFile == null) return;
    if (_tokenizerType != 'none' && _tokenizerFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.modelImportSelectTokenizer)),
      );
      return;
    }

    setState(() => _importing = true);
    final manager = context.read<ModelManager>();
    final success = await manager.importLocalModel(
      role: _targetRole,
      name: _nameController.text.trim(),
      modelFile: _modelFile!,
      tokenizerFile: _tokenizerFile,
      tokenizerType: _tokenizerType,
      aiLabelIndex: _aiLabelIndex,
    );

    setState(() => _importing = false);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.modelImportSuccessSnackbar)),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.modelImportFailedSnackbar)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.modelImportAppBarTitle)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 1. Model File Picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.modelImportStep1Title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _modelFile != null
                                ? l10n.modelImportSelectedFile(
                                    _modelFileDisplayName ??
                                        _modelFile!.path
                                            .split(Platform.pathSeparator)
                                            .last)
                                : l10n.modelImportNoFileSelected,
                            style: TextStyle(
                              color: _modelFile != null ? cs.primary : cs.outline,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickModel,
                          icon: const Icon(Icons.file_open),
                          label: Text(l10n.modelImportBrowseButton),
                        ),
                      ],
                    ),
                    if (_checkingDuplicate) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(l10n.modelImportCheckingDuplicate,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_duplicate != null) ...[
              const SizedBox(height: 12),
              Card(
                color: cs.tertiaryContainer.withValues(alpha: 0.4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: cs.tertiary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.modelImportDuplicateTitle,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              l10n.modelImportDuplicateBody(
                                  _duplicate!.displayName, _duplicate!.role),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // 2. Configuration Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.modelImportStep2Title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.modelImportNameLabel,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? l10n.modelImportNameRequired
                          : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _targetRole,
                      decoration: InputDecoration(
                        labelText: l10n.modelImportRoleLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: kModelRegistry
                          .where((m) => m.backend == InferenceBackend.transformer)
                          .map((m) => DropdownMenuItem(
                                value: m.id,
                                child: Text(m.name),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _targetRole = v);
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _tokenizerType,
                      decoration: InputDecoration(
                        labelText: l10n.modelImportTokenizerTypeLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: 'bert-wordpiece',
                            child: Text(l10n.modelImportTokenizerBert)),
                        DropdownMenuItem(
                            value: 'roberta-bpe',
                            child: Text(l10n.modelImportTokenizerRoberta)),
                        DropdownMenuItem(
                            value: 'none',
                            child: Text(l10n.modelImportTokenizerNone)),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _tokenizerType = v;
                            _testResult = null;
                            _testError = null;
                            if (v == 'none') _tokenizerFile = null;
                          });
                        }
                      },
                    ),
                    if (_tokenizerType != 'none') ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _tokenizerFile != null
                                  ? l10n.modelImportTokenizerSelected(
                                      _tokenizerFileDisplayName ??
                                          _tokenizerFile!.path
                                              .split(Platform.pathSeparator)
                                              .last)
                                  : l10n.modelImportNoTokenizerSelected,
                              style: TextStyle(
                                color: _tokenizerFile != null
                                    ? cs.primary
                                    : cs.outline,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickTokenizer,
                            icon: const Icon(Icons.code),
                            label: Text(l10n.modelImportBrowseButton),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _aiLabelIndex,
                      decoration: InputDecoration(
                        labelText: l10n.modelImportAiLabelIndexLabel,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: 0, child: Text(l10n.modelImportIndex0)),
                        DropdownMenuItem(
                            value: 1, child: Text(l10n.modelImportIndex1)),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setState(() {
                            _aiLabelIndex = v;
                            _testResult = null;
                            _testError = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Test & Verification Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.modelImportStep3Title,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _testController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: l10n.modelImportTestInputLabel,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _modelFile == null || _testing ? null : _runTest,
                            icon: _testing
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.play_arrow),
                            label: Text(l10n.modelImportRunTestButton),
                          ),
                        ),
                      ],
                    ),
                    if (_testResult != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(l10n.modelImportResultLabel,
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              '${(_testResult! * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _testResult! > 0.6 ? cs.error : cs.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_testError != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.modelImportTestFailed(_testError!),
                          style: TextStyle(color: cs.onErrorContainer),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Import Button
            FilledButton.icon(
              onPressed: _modelFile == null || _importing ? null : _import,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: _importing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download_done),
              label: Text(l10n.modelImportConfirmButton,
                  style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
