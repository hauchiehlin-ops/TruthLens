import 'package:flutter/foundation.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_file_exists.dart';
import '../model_manager.dart';
import '../onnx_detector.dart';

/// 子模型 D：對抗式防禦模組（改寫偵測），ONNX Runtime 端上推論。
/// 以「原生 AI + 改寫後 AI」皆標為 AI 訓練的分類器（見 training/prepare_adversarial.py），
/// 對 QuillBot / Undetectable.ai 等改寫規避具韌性。
/// 使用中模型與 tokenizer 檔皆需存在才可用；否則回報 unavailable（優雅降級）。
class AdversarialEngine implements DetectionEngine {
  final ModelManager modelManager;
  final String? variantId;

  static const _supportedTokenizers = {'bert-wordpiece', 'roberta-bpe'};

  OnnxDetector? _detector;
  String? _loadedModelPath;
  String? _loadError;
  String? _repairMessage;

  AdversarialEngine({required this.modelManager, this.variantId});

  @override
  String get id => variantId != null ? 'adversarial_$variantId' : 'adversarial';

  @override
  String name(AppLocalizations l10n) => l10n.engineNameAdversarialFull;

  @override
  double get defaultWeight => 0.15;

  InstalledModel? _resolveVariant() {
    if (variantId != null) {
      final installed = modelManager.installedVariants('adversarial');
      for (final m in installed) {
        if (m.variantId == variantId) return m;
      }
      return null;
    }
    return modelManager.activeVariant('adversarial');
  }

  Future<(String, String)?> _resolvePaths() async {
    final active = _resolveVariant();
    if (active == null) return null;
    final modelPath = await modelManager.variantModelPath(
      'adversarial',
      active.variantId,
    );
    final tokPath = await modelManager.variantTokenizerPath(
      'adversarial',
      active.variantId,
    );
    if (modelPath == null || tokPath == null) return null;
    if (!await modelFileExists(modelPath) || !await modelFileExists(tokPath)) {
      return null;
    }
    return (modelPath, tokPath);
  }

  @override
  Future<bool> isAvailable() async => (await _resolvePaths()) != null;

  Future<OnnxDetector?> _ensureLoaded() async {
    final paths = await _resolvePaths();
    if (paths == null) {
      final active = _resolveVariant();
      _loadError = active == null
          ? '未找到使用中的改寫偵測模型'
          : '模型或 tokenizer 檔案不存在，請在模型管理重新下載';
      return null;
    }
    final (modelPath, tokPath) = paths;
    final active = _resolveVariant()!;
    if (_detector != null && _loadedModelPath == modelPath) return _detector;
    Object? lastError;

    for (final tokenizerType in [
      active.tokenizer,
      if (active.tokenizer != 'bert-wordpiece') 'bert-wordpiece',
      if (active.tokenizer != 'roberta-bpe') 'roberta-bpe',
    ].where(_supportedTokenizers.contains)) {
      try {
        _detector?.dispose();
        _detector = await OnnxDetector.load(
          modelPath: modelPath,
          tokenizerJsonPath: tokPath,
          tokenizerType: tokenizerType,
          aiLabelIndex: active.aiLabelIndex,
        );
        _loadedModelPath = modelPath;
        _loadError = null;
        return _detector;
      } catch (e) {
        _detector = null;
        _loadedModelPath = null;
        lastError = e;
        debugPrint('[AdversarialEngine] tokenizer=$tokenizerType 載入失敗: $e');
      }
    }

    debugPrint('[AdversarialEngine] 所有 tokenizer 備援皆失敗，啟動自動修復: $lastError');
    _repairMessage = await _repairActiveVariant(reason: '改寫偵測模型載入失敗');
    _loadError = _repairMessage;
    return null;
  }

  EngineScore _unavailable(AppLocalizations l10n) => EngineScore(
    engineId: id,
    engineName: name(l10n),
    aiProbability: 0.5,
    weight: defaultWeight,
    available: false,
    reasons: [
      _loadError == null
          ? l10n.engineReasonAdversarialNotInstalled
          : '改寫偵測模型未參與本次投票。$_loadError',
    ],
  );

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n,
  ) async {
    OnnxDetector? detector;
    try {
      detector = await _ensureLoaded();
    } catch (_) {
      detector = null;
    }
    if (detector == null || text.sentences.isEmpty) {
      return _unavailable(l10n);
    }

    List<double> perSentence;
    try {
      perSentence = await detector.classifySentences(text.sentences);
    } catch (e) {
      debugPrint('[AdversarialEngine] 模型推論失敗，啟動自動修復: $e');
      detector.dispose();
      _detector = null;
      _loadedModelPath = null;
      _repairMessage = await _repairActiveVariant(reason: '改寫偵測模型推論失敗');
      _loadError = _repairMessage;
      return _unavailable(l10n);
    }
    final avg = perSentence.reduce((a, b) => a + b) / perSentence.length;
    final strongScores = perSentence.where((score) => score >= 0.6).toList();
    final strongCount = strongScores.length;
    final strongRatio = strongCount / perSentence.length;
    double calibratedProbability;
    if (strongCount == 0) {
      final peak = perSentence.reduce((a, b) => a > b ? a : b);
      final averageMargin = (avg - 0.5).clamp(0.0, 0.1) / 0.1;
      final peakMargin = (peak - 0.5).clamp(0.0, 0.1) / 0.1;
      calibratedProbability = (averageMargin * 0.07) + (peakMargin * 0.03);
    } else {
      final strongAverage = strongScores.reduce((a, b) => a + b) / strongCount;
      calibratedProbability = (strongRatio * 0.7) + (strongAverage * 0.3);
    }
    calibratedProbability = calibratedProbability.clamp(0.0, 1.0);
    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: calibratedProbability,
      weight: defaultWeight,
      sentenceScores: perSentence,
      features: {
        'strong_sentence_ratio': strongRatio,
        'raw_avg_prob': avg,
        'calibrated_prob': calibratedProbability,
      },
      reasons: [
        if (strongCount == 0)
          l10n.engineReasonAdversarialNoStrongSentence(
            perSentence.length,
            (calibratedProbability * 100).round(),
          )
        else
          l10n.engineReasonAdversarialStrongSentences(
            strongCount,
            perSentence.length,
            (calibratedProbability * 100).round(),
          ),
      ],
    );
  }

  Future<String> _repairActiveVariant({required String reason}) async {
    try {
      return await modelManager.repairActiveVariant(
        'adversarial',
        reason: reason,
      );
    } catch (_) {
      return '模型載入或推論失敗，且自動修復未完成；請到模型管理重新下載改寫偵測模型與 tokenizer。';
    }
  }
}
