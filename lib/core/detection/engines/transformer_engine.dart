import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_file_exists.dart';
import '../model_manager.dart';
import '../onnx_detector.dart';

/// 子模型 A：多語言 Transformer 分類器（ONNX Runtime 端上推論）。
/// 使用 [ModelManager] 目前「使用中」的已安裝模型；載入後以保留段落上下文的
/// 受控區塊推論，並將區塊分數映射回逐句報告。
/// 支援 WordPiece（BERT 系）與 byte-level BPE（RoBERTa 系）tokenizer。
/// 分類器一定需要 tokenizer；若使用中模型缺 tokenizer 或檔案不存在，回報 unavailable。
class TransformerEngine implements DetectionEngine {
  final ModelManager modelManager;
  final String? variantId;

  static const _supportedTokenizers = {'bert-wordpiece', 'roberta-bpe'};

  OnnxDetector? _detector;
  String? _loadedModelPath;
  String? _repairMessage;

  TransformerEngine({required this.modelManager, this.variantId});

  @override
  String get id => variantId != null ? 'transformer_$variantId' : 'transformer';

  @override
  String name(AppLocalizations l10n) => l10n.analysisEngineTransformer;

  @override
  double get defaultWeight => 0.40;

  bool _supported(String tokenizer) => _supportedTokenizers.contains(tokenizer);

  InstalledModel? _resolveVariant() {
    if (variantId != null) {
      final installed = modelManager.installedVariants('transformer');
      for (final m in installed) {
        if (m.variantId == variantId) return m;
      }
      return null;
    }
    return modelManager.activeVariant('transformer');
  }

  /// 依變體檔解析模型與 tokenizer 檔案路徑
  Future<(String, String)?> _resolvePaths() async {
    final active = _resolveVariant();
    if (active == null) {
      _loadError = '未找到使用中的 Transformer 模型；請到模型管理下載或設為使用中';
      return null;
    }
    if (!_supported(active.tokenizer)) {
      _loadError =
          '使用中模型的 tokenizer 類型不支援（${active.tokenizer}）；請切換到支援 bert-wordpiece 或 roberta-bpe 的模型';
      return null;
    }
    final modelPath = await modelManager.variantModelPath(
      'transformer',
      active.variantId,
    );
    final tokPath = await modelManager.variantTokenizerPath(
      'transformer',
      active.variantId,
    );
    if (modelPath == null || tokPath == null) {
      _loadError = 'Transformer 模型或 tokenizer 路徑缺失；請在模型管理重新下載';
      return null;
    }
    if (!await modelFileExists(modelPath) || !await modelFileExists(tokPath)) {
      _loadError = 'Transformer 模型或 tokenizer 檔案不存在；請在模型管理重新下載';
      return null;
    }
    return (modelPath, tokPath);
  }

  @override
  Future<bool> isAvailable() async => (await _resolvePaths()) != null;

  String? _loadError;

  Future<OnnxDetector?> _ensureLoaded() async {
    final paths = await _resolvePaths();
    if (paths == null) return null;
    final (modelPath, tokPath) = paths;
    final active = _resolveVariant()!;
    if (_detector != null && _loadedModelPath == modelPath) return _detector;
    try {
      _detector?.dispose();
      _detector = await OnnxDetector.load(
        modelPath: modelPath,
        tokenizerJsonPath: tokPath,
        tokenizerType: active.tokenizer,
        aiLabelIndex: active.aiLabelIndex,
      );
      _loadedModelPath = modelPath;
      _loadError = null;
      return _detector;
    } catch (e) {
      _detector = null;
      _loadedModelPath = null;
      final errorMsg = e.toString();

      // 區分 opset 版本不支援 vs 其他錯誤，設定對應的錯誤消息
      if (errorMsg.contains('opset') ||
          errorMsg.contains('Opset') ||
          errorMsg.contains('ValidateOpsetForDomain')) {
        _loadError = 'ONNX opset 版本不支援（該模型版本太新，需更新應用）: ${active.variantId}';
      } else if (e is FormatException) {
        _loadError = 'Tokenizer 格式損毀: ${e.message}';
        // 嘗試刪除損毀的 tokenizer，下次會提示用戶重新下載
        try {
          final tokFile = File(tokPath);
          if (tokFile.existsSync()) await tokFile.delete();
          await modelManager.refreshInstallStates();
        } catch (_) {}
      } else {
        debugPrint('[TransformerEngine] 模型載入失敗，啟動自動修復: $errorMsg');
        _repairMessage = await _repairActiveVariant(
          reason: 'Transformer 模型載入失敗',
        );
        _loadError = _repairMessage;
      }
      return null;
    }
  }

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n,
  ) async {
    OnnxDetector? detector;
    try {
      detector = await _ensureLoaded();
      if (detector == null || text.analysisChunks.isEmpty) {
        return _unavailable(l10n);
      }
    } catch (e) {
      debugPrint('[TransformerEngine] 模型載入例外，啟動自動修復: $e');
      _repairMessage = await _repairActiveVariant(reason: 'Transformer 模型載入失敗');
      _loadError = _repairMessage;
      return _unavailable(l10n);
    }

    List<double> perChunk;
    try {
      perChunk = await detector.classifySentences(text.analysisChunks);
    } catch (e) {
      debugPrint('[TransformerEngine] 模型推論失敗，啟動自動修復: $e');
      detector.dispose();
      _detector = null;
      _loadedModelPath = null;
      _repairMessage = await _repairActiveVariant(reason: 'Transformer 模型推論失敗');
      _loadError = _repairMessage;
      return _unavailable(l10n);
    }
    final perSentence = text.expandChunkScoresToSentences(perChunk);
    final avg = perChunk.reduce((a, b) => a + b) / perChunk.length;
    final strongChunks = perChunk.where((score) => score >= 0.6).toList();
    final strongChunkCount = strongChunks.length;
    final strongChunkRatio = strongChunkCount / perChunk.length;
    final maxChunk = perChunk.reduce(math.max);
    final strongSentenceCount = perSentence
        .where((score) => score >= 0.6)
        .length;
    final strongSentenceRatio = strongSentenceCount / perSentence.length;

    // 置信度校準：避免隨機 Softmax 浮動（~0.50）在 0 個強 AI 區塊時
    // 輸出 52% 的矛盾結果。
    double calibratedProbability;
    if (strongChunkCount == 0) {
      final averageMargin = (avg - 0.5).clamp(0.0, 0.1) / 0.1;
      final peakMargin = (maxChunk - 0.5).clamp(0.0, 0.1) / 0.1;
      // 沒有任何區塊跨過強 AI 閾值時，只保留最多 10% 的弱訊號，
      // 避免 Softmax 在 0.5 附近的浮動被誤解成肯定的 AI 證據。
      calibratedProbability = (averageMargin * 0.07) + (peakMargin * 0.03);
    } else {
      final strongAverage =
          strongChunks.reduce((a, b) => a + b) / strongChunkCount;
      calibratedProbability = (strongChunkRatio * 0.7) + (strongAverage * 0.3);
    }
    calibratedProbability = calibratedProbability.clamp(0.0, 1.0);

    final variant = _resolveVariant();
    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: calibratedProbability,
      weight: defaultWeight,
      features: {
        'ai_sentence_ratio': strongSentenceRatio,
        'ai_analysis_chunk_ratio': strongChunkRatio,
        'analysis_chunk_count': perChunk.length.toDouble(),
        'raw_avg_prob': avg,
        'calibrated_prob': calibratedProbability,
      },
      reasons: [
        if (strongChunkCount == 0)
          l10n.engineReasonTransformerNoStrongSentence(
            variant?.variantId ?? name(l10n),
            perSentence.length,
            (calibratedProbability * 100).round(),
          )
        else
          l10n.engineReasonTransformerResult(
            variant?.variantId ?? name(l10n),
            strongSentenceCount,
            perSentence.length,
          ),
      ],
      sentenceScores: perSentence,
    );
  }

  EngineScore _unavailable(AppLocalizations l10n) => EngineScore(
    engineId: id,
    engineName: name(l10n),
    aiProbability: 0.5,
    weight: defaultWeight,
    available: false,
    reasons: [
      _loadError == null
          ? l10n.engineReasonTransformerNotInstalled
          : '模型未參與本次投票。$_loadError',
    ],
  );

  Future<String> _repairActiveVariant({required String reason}) async {
    try {
      return await modelManager.repairActiveVariant(
        'transformer',
        reason: reason,
      );
    } catch (_) {
      return '模型載入或推論失敗，且自動修復未完成；請到模型管理重新下載使用中的 Transformer 模型與 tokenizer。';
    }
  }
}
