import 'package:flutter/foundation.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_file_exists.dart';
import '../model_manager.dart';
import '../model_display_names.dart';
import '../variant_router.dart';
import '../onnx_detector.dart';

/// 子模型 D：對抗式防禦模組（改寫偵測），ONNX Runtime 端上推論。
/// 以「原生 AI + 改寫後 AI」皆標為 AI 訓練的分類器（見 training/prepare_adversarial.py），
/// 對 QuillBot / Undetectable.ai 等改寫規避具韌性；推論使用保留段落上下文的
/// 受控區塊，再映射回逐句分數供報告使用。
/// 使用中模型與 tokenizer 檔皆需存在才可用；否則回報 unavailable（優雅降級）。
class AdversarialEngine implements DetectionEngine, ReleasableDetectionEngine {
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

  /// 本次分析選用的變體。呼叫端先以 [routeFor] 依文件語言決定，
  /// 結果暫存於此供 [analyze] 期間的各步驟一致引用。
  VariantChoice _choice = VariantChoice.none;

  VariantChoice get choice => _choice;

  /// 依文件語言在已安裝變體之間路由。
  ///
  /// [variantId] 明確指定時直接鎖定該變體（測試與特定流程用），
  /// 不參與路由——呼叫端已經表達了確切意圖。
  VariantChoice routeFor(String? language, {bool mixedScripts = false}) {
    final installed = modelManager.installedVariants('adversarial');
    if (variantId != null) {
      for (final m in installed) {
        if (m.variantId == variantId) {
          return VariantChoice(
            variant: m,
            fit: language == null ? LanguageFit.unknown : fitFor(m, language),
          );
        }
      }
      return VariantChoice.none;
    }
    return chooseVariant(
      installed: installed,
      language: language,
      mixedScripts: mixedScripts,
      userActiveVariantId: modelManager.activeVariant('adversarial')?.variantId,
    );
  }

  /// 本次選用的變體。[isAvailable] 會在 [analyze] 之前被呼叫，那時還沒有
  /// 文件可供路由，因此退回語言無關的預設選擇（使用者的手動選擇）——
  /// 「有沒有可用模型」與「哪一顆最適合這份文件」是兩個問題。
  InstalledModel? _resolveVariant() =>
      _choice.variant ?? routeFor(null).variant;

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

  Future<OnnxDetector?> _ensureLoaded(AppLocalizations l10n) async {
    final paths = await _resolvePaths();
    if (paths == null) {
      final active = _resolveVariant();
      _loadError = active == null
          ? l10n.engineAdversarialNoActiveVariant
          : l10n.engineAdversarialMissingFiles;
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
    _repairMessage = await _repairActiveVariant(l10n);
    _loadError = _repairMessage;
    return null;
  }

  /// 模型選用的說明。只在有話說的時候才產生：使用者選的變體已驗證且沒被
  /// 覆寫時不必贅述，介面已經顯示「使用中」。
  List<String> _routingNotes(AppLocalizations l10n, PreprocessedText text) {
    final variant = _choice.variant;
    if (variant == null) return const [];
    final notes = <String>[];
    if (_choice.overrodeUserChoice) {
      notes.add(
        l10n.engineRoutedToBetterVariant(
          localizedModelName(variant.variantId, variant.name, l10n),
          text.language.code,
        ),
      );
    }
    switch (_choice.fit) {
      case LanguageFit.plausible:
        notes.add(
          l10n.engineLanguageNotValidated(
            localizedModelName(variant.variantId, variant.name, l10n),
            text.language.code,
          ),
        );
      case LanguageFit.unsupported:
        notes.add(
          l10n.engineLanguageUnsupported(
            localizedModelName(variant.variantId, variant.name, l10n),
            text.language.code,
          ),
        );
      case LanguageFit.validated:
      case LanguageFit.unknown:
        break;
    }
    return notes;
  }

  EngineScore _unavailable(AppLocalizations l10n) => EngineScore(
    engineId: id,
    engineName: name(l10n),
    aiProbability: 0.5,
    weight: defaultWeight,
    available: false,
    applicability: EngineApplicability.unsupported,
    calibrationReliability: 0,
    reasons: [
      _loadError == null
          ? l10n.engineReasonAdversarialNotInstalled
          : l10n.engineReasonNotParticipatedWithError(_loadError!),
    ],
  );

  @override
  Future<EngineScore> analyze(
    PreprocessedText text,
    AppLocalizations l10n, {
    EngineProgressCallback? onProgress,
  }) async {
    onProgress?.call(0.02);
    // 逐文件路由：語言不同，最適用的變體也不同。純英文模型對中文輸入
    // 從未跨過強訊號閾值，等於權重空轉，而使用者看不出這件事。
    _choice = routeFor(
      text.language.isUndetermined ? null : text.language.code,
      mixedScripts: text.language.mixedScripts,
    );

    OnnxDetector? detector;
    try {
      detector = await _ensureLoaded(l10n);
      onProgress?.call(0.12);
    } catch (_) {
      detector = null;
    }
    if (detector == null || text.analysisChunks.isEmpty) {
      return _unavailable(l10n);
    }

    List<double> perChunk;
    try {
      debugPrint('[AdversarialEngine] 推論 ${text.analysisChunks.length} 個分析區塊');
      perChunk = await detector.classifySentences(
        text.analysisChunks,
        onProgress: (progress) =>
            onProgress?.call(0.12 + progress.clamp(0.0, 1.0) * 0.86),
      );
      onProgress?.call(0.98);
    } catch (e) {
      debugPrint('[AdversarialEngine] 模型推論失敗，啟動自動修復: $e');
      detector.dispose();
      _detector = null;
      _loadedModelPath = null;
      _repairMessage = await _repairActiveVariant(l10n);
      _loadError = _repairMessage;
      return _unavailable(l10n);
    }
    final perSentence = text.expandChunkScoresToSentences(perChunk);
    final avg = perChunk.reduce((a, b) => a + b) / perChunk.length;
    final strongChunks = perChunk.where((score) => score >= 0.6).toList();
    final strongChunkCount = strongChunks.length;
    final strongChunkRatio = strongChunkCount / perChunk.length;
    final strongSentenceCount = perSentence
        .where((score) => score >= 0.6)
        .length;
    final strongSentenceRatio = strongSentenceCount / perSentence.length;
    double calibratedProbability;
    if (strongChunkCount == 0) {
      final peak = perChunk.reduce((a, b) => a > b ? a : b);
      final averageMargin = (avg - 0.5).clamp(0.0, 0.1) / 0.1;
      final peakMargin = (peak - 0.5).clamp(0.0, 0.1) / 0.1;
      calibratedProbability = (averageMargin * 0.07) + (peakMargin * 0.03);
    } else {
      final strongAverage =
          strongChunks.reduce((a, b) => a + b) / strongChunkCount;
      calibratedProbability = (strongChunkRatio * 0.7) + (strongAverage * 0.3);
    }
    calibratedProbability = calibratedProbability.clamp(0.0, 1.0);

    // 本引擎問的是「這段文字有沒有被改寫工具動過」，不是「這段文字是不是 AI 寫的」。
    // 一篇原生 AI 短文從未被改寫，得到 0% 是正確答案——但那是另一道題的正確答案，
    // 不能當成「這是人寫的」的證據拿去投票。沒偵測到改寫時一律視為沉默。
    final hasEvidence = strongChunkCount > 0;
    onProgress?.call(1);
    return EngineScore(
      engineId: id,
      engineName: name(l10n),
      aiProbability: calibratedProbability,
      weight: defaultWeight,
      hasEvidence: hasEvidence,
      applicability: switch (_choice.fit) {
        LanguageFit.validated => EngineApplicability.validated,
        LanguageFit.plausible => EngineApplicability.plausible,
        LanguageFit.unknown => EngineApplicability.unknown,
        LanguageFit.unsupported => EngineApplicability.unsupported,
      },
      modules: [
        if (_choice.variant != null)
          localizedModelName(
            _choice.variant!.variantId,
            _choice.variant!.name,
            l10n,
          )
        else
          name(l10n),
      ],
      calibrationReliability: _choice.isValidated ? 0.78 : 0.55,
      sentenceScores: perSentence,
      features: {
        'strong_sentence_ratio': strongSentenceRatio,
        'strong_analysis_chunk_ratio': strongChunkRatio,
        'analysis_chunk_count': perChunk.length.toDouble(),
        'raw_avg_prob': avg,
        'calibrated_prob': calibratedProbability,
      },
      reasons: [
        // 先講清楚這次用了哪顆模型、對這個語言驗證過沒有。
        // 一份中文文件被純英文模型判為 0%，使用者有權知道原因出在模型選用。
        ..._routingNotes(l10n, text),
        if (strongChunkCount == 0)
          l10n.engineReasonAdversarialNoStrongSentence(
            perSentence.length,
            (calibratedProbability * 100).round(),
          )
        else
          l10n.engineReasonAdversarialStrongSentences(
            strongSentenceCount,
            perSentence.length,
            (calibratedProbability * 100).round(),
          ),
      ],
    );
  }

  Future<String> _repairActiveVariant(AppLocalizations l10n) async {
    try {
      return await modelManager.repairActiveVariant('adversarial', l10n);
    } catch (_) {
      return l10n.engineAdversarialRepairFailed;
    }
  }

  @override
  void releaseResources() {
    _detector?.dispose();
    _detector = null;
    _loadedModelPath = null;
  }
}
