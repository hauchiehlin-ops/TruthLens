import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/detection/model_manager.dart';
import '../../core/detection/model_registry.dart';

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
  File? _tokenizerFile;
  String _tokenizerType = 'bert-wordpiece';
  int _aiLabelIndex = 1;
  String _targetRole = 'transformer';

  bool _testing = false;
  double? _testResult;
  String? _testError;
  bool _importing = false;

  bool _hasLocalUpdate = false;
  DateTime? _localFileTime;

  @override
  void initState() {
    super.initState();
    _autoDetectLocalModel();
  }

  void _autoDetectLocalModel() {
    const projectOnnxPath = '/Users/barretlin/GitProjects/TruthLens/training_tools/adversarial_paraphrase_quantized.onnx';
    const projectTokenizerPath = '/Users/barretlin/GitProjects/TruthLens/training_tools/quantized_model/tokenizer.json';

    final onnxFile = File(projectOnnxPath);
    final tokenizerFile = File(projectTokenizerPath);

    if (onnxFile.existsSync()) {
      _modelFile = onnxFile;
      _nameController.text = '對抗式改寫偵測分類器';
      _targetRole = 'adversarial'; // 預設為對抗式引擎
      _tokenizerType = 'bert-wordpiece';
      _aiLabelIndex = 1;
      _localFileTime = onnxFile.lastModifiedSync();

      final manager = context.read<ModelManager>();
      final active = manager.activeModelFor('adversarial');
      
      // 如果未安裝任何 adversarial 模型，或者本地檔案存在，皆標示為有新模型可供一鍵安裝套用
      _hasLocalUpdate = true;

      if (tokenizerFile.existsSync()) {
        _tokenizerFile = tokenizerFile;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _testController.dispose();
    super.dispose();
  }

  Future<void> _pickModel() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['onnx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _modelFile = File(result.files.single.path!);
        // Pre-fill model name with file basename without extension
        final baseName = result.files.single.name;
        _nameController.text = baseName.replaceAll('.onnx', '');
        _testResult = null;
        _testError = null;
      });
    }
  }

  Future<void> _pickTokenizer() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _tokenizerFile = File(result.files.single.path!);
        _testResult = null;
        _testError = null;
      });
    }
  }

  Future<void> _runTest() async {
    if (_modelFile == null) return;
    if (_tokenizerType != 'none' && _tokenizerFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請先選擇 Tokenizer 檔案')),
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
    if (!_formKey.currentState!.validate() || _modelFile == null) return;
    if (_tokenizerType != 'none' && _tokenizerFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請選擇 Tokenizer 檔案')),
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
        const SnackBar(content: Text('模型匯入成功！已自動啟用為使用中模型。')),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('模型匯入失敗，請檢查權限或日誌')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('匯入自訂 ONNX 模型')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_hasLocalUpdate && _modelFile != null) ...[
              Card(
                color: cs.primaryContainer.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: cs.primary.withValues(alpha: 0.5), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.system_update_alt, color: cs.primary, size: 28),
                          const SizedBox(width: 8),
                          Text(
                            '偵測到本機微調目錄有新模型！',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '本機路徑: training_tools/adversarial_paraphrase_quantized.onnx\n'
                        '修改時間: ${_localFileTime?.toLocal().toString().split('.').first ?? '未知'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _import,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: cs.primary,
                            foregroundColor: cs.onPrimary,
                          ),
                          icon: const Icon(Icons.download_for_offline),
                          label: const Text('一鍵下載、安裝及套用此模型'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            // 1. Model File Picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. 選擇 ONNX 模型檔案',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _modelFile != null
                                ? '已選擇: ${_modelFile!.path.split(Platform.pathSeparator).last}'
                                : '未選擇模型檔案 (.onnx)',
                            style: TextStyle(
                              color: _modelFile != null ? cs.primary : cs.outline,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickModel,
                          icon: const Icon(Icons.file_open),
                          label: const Text('瀏覽'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. Configuration Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('2. 參數設定',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '模型顯示名稱',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? '名稱不能為空' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _targetRole,
                      decoration: const InputDecoration(
                        labelText: '目標引擎角色',
                        border: OutlineInputBorder(),
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
                      decoration: const InputDecoration(
                        labelText: 'Tokenizer 類型',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'bert-wordpiece', child: Text('BERT (WordPiece)')),
                        DropdownMenuItem(
                            value: 'roberta-bpe', child: Text('RoBERTa (BPE)')),
                        DropdownMenuItem(
                            value: 'none', child: Text('None (無 Tokenizer/逐字)')),
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
                                  ? '已選擇: ${_tokenizerFile!.path.split(Platform.pathSeparator).last}'
                                  : '未選擇 Tokenizer 檔案 (.json)',
                              style: TextStyle(
                                color: _tokenizerFile != null ? cs.primary : cs.outline,
                              ),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _pickTokenizer,
                            icon: const Icon(Icons.code),
                            label: const Text('瀏覽'),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      initialValue: _aiLabelIndex,
                      decoration: const InputDecoration(
                        labelText: 'AI 類別輸出索引 (AI Label Index)',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 0, child: Text('Index 0 (例如 RoBERTa)')),
                        DropdownMenuItem(value: 1, child: Text('Index 1 (例如 DistilBERT)')),
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
                    Text('3. 測試與驗證',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _testController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '測試輸入文本',
                        border: OutlineInputBorder(),
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
                            label: const Text('執行測試推論'),
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
                            const Text('推論結果 (AI 機率):',
                                style: TextStyle(fontWeight: FontWeight.bold)),
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
                          '測試失敗: $_testError',
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
              label: const Text('確認匯入並啟用模型', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
