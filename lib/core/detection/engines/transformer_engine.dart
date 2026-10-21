import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../models/detection_result.dart';
import '../../utils/text_stats.dart';
import '../detection_engine.dart';
import '../model_file_exists.dart';
import '../model_manager.dart';
import '../model_display_names.dart';
import '../analysis_profile.dart';
import '../variant_router.dart';
import '../onnx_detector.dart';

/// 子模型 A：多語言 Transformer 分類器（ONNX Runtime 端上推論）。
/// 使用 [ModelManager] 目前「使用中」的已安裝模型；載入後以保留段落上下文的
/// 受控區塊推論，並將區塊分數映射回逐句報告。
/// 支援 WordPiece（BERT 系）與 byte-level BPE（RoBERTa 系）tokenizer。
/// 分類器一定需要 tokenizer；若使用中模型缺 tokenizer 或檔案不存在，回報 unavailable。
class TransformerEngine implements DetectionEngine, ReleasableDetectionEngine {
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

  /// 本次分析選用的變體。呼叫端先以 [routeFor] 依文件語言決定，
  /// 結果暫存於此供 [analyze] 期間的各步驟一致引用。
  VariantChoice _choice = VariantChoice.none;

  VariantChoice get choice => _choice;

  /// 依文件語言與文體在已安裝變體之間路由。
  ///
  /// 自動模式（預設）不把「使用中」當成偏好，只在語言不明時作為預設；
  /// 使用者在模型管理鎖定變體後，才優先採用它。
  ///
  /// [variantId] 明確指定時直接鎖定該變體（測試與特定流程用），
  /// 不參與路由——呼叫端已經表達了確切意圖。
  VariantChoice routeFor(
    String? language, {
    bool mixedScripts = false,
    String domain = 'general',
  }) {
    final installed = modelManager.installedVariants('transformer');
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
    final active = modelManager.activeVariant('transformer')?.variantId;
    return chooseVariant(
      installed: installed,
      language: language,
      domain: domain,
      mixedScripts: mixedScripts,
      userActiveVariantId: modelManager.isManualSelection('transformer')
          ? active
          : null,
      defaultVariantId: active,
    );
  }

  /// 本次選用的變體。[isAvailable] 會在 [analyze] 之前被呼叫，那時還沒有
  /// 文件可供路由，因此退回語言無關的預設選擇（使用者的手動選擇）——
  /// 「有沒有可用模型」與「哪一顆最適合這份文件」是兩個問題。
  InstalledModel? _resolveVariant() =>
      _choice.variant ?? routeFor(null).variant;

  /// 依變體檔解析模型與 tokenizer 檔案路徑；[l10n] 提供時才會在失敗原因寫入
  /// 本地化錯誤訊息（[isAvailable] 只需布林結果，不必也不應觸發翻譯查找）。
  Future<(String, String)?> _resolvePaths([AppLocalizations? l10n]) async {
    final active = _resolveVariant();
    if (active == null) {
      _loadError = l10n?.engineTransformerNoActiveVariant;
      return null;
    }
    if (!_supported(active.tokenizer)) {
      _loadError = l10n?.engineTransformerUnsupportedTokenizer(
        active.tokenizer,
      );
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
      _loadError = l10n?.engineTransformerMissingPaths;
      return null;
    }
    if (!await modelFileExists(modelPath) || !await modelFileExists(tokPath)) {
      _loadError = l10n?.engineTransformerMissingFiles;
      return null;
    }
    return (modelPath, tokPath);
  }

  @override
  Future<bool> isAvailable() async => (await _resolvePaths()) != null;

  /// 由逐區塊分數換算文件級分數。
  ///
  /// 本引擎沒有人類側通道（見 [analyze] 的 hasEvidence 說明），因此：
  /// - 沒有區塊跨過 [threshold]：只保留最多 10% 的弱訊號並由呼叫端標記為沉默，
  ///   避免 Softmax 在 0.5 附近的浮動被誤解成 AI 證據。
  /// - 有區塊跨過：分數一律落在 AI 側（> 0.5）。舊公式
  ///   `比例 × 0.7 + 強區塊均值 × 0.3` 在長文件會低於 0.38——一份 2.2 萬字
  ///   中文研究計畫有 21 句跨門檻，文件分數卻約 0.30，融合層把它讀成
  ///   「監督式分類器支持人類」，報告因而翻成「較可能不是 AI 生成」。
  ///   「AI 只出現在一部分區塊」是範圍問題，不是反向證據。
  /// - 只有單一強區塊、且比例不到一成時，視為可能的偶發誤觸：保留方向但封頂
  ///   於 0.60，不跨過融合層 0.62 的支持門檻。長文件逐塊比對本來就會累積
  ///   零星誤觸的機會，兩個以上獨立區塊才算超出偶然。
  @visibleForTesting
  static double documentProbability(List<double> perChunk, double threshold) {
    if (perChunk.isEmpty) return 0;
    final avg = perChunk.reduce((a, b) => a + b) / perChunk.length;
    final maxChunk = perChunk.reduce(math.max);
    final strongChunks = perChunk.where((score) => score >= threshold).toList();
    if (strongChunks.isEmpty) {
      final averageMargin = (avg - 0.5).clamp(0.0, 0.1) / 0.1;
      final peakMargin = (maxChunk - 0.5).clamp(0.0, 0.1) / 0.1;
      return ((averageMargin * 0.07) + (peakMargin * 0.03)).clamp(0.0, 1.0);
    }
    final strongRatio = strongChunks.length / perChunk.length;
    final strongAverage =
        strongChunks.reduce((a, b) => a + b) / strongChunks.length;
    final extent = ((strongRatio * 0.7) + (strongAverage * 0.3)).clamp(
      0.0,
      1.0,
    );
    final probability = 0.5 + extent * 0.5;
    final isolatedHit = strongChunks.length == 1 && strongRatio < 0.10;
    return isolatedHit ? math.min(probability, 0.60) : probability;
  }

  String? _loadError;

  Future<OnnxDetector?> _ensureLoaded(AppLocalizations l10n) async {
    final paths = await _resolvePaths(l10n);
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
        _loadError = l10n.engineTransformerOpsetUnsupported(active.variantId);
      } else if (e is FormatException) {
        _loadError = l10n.engineTransformerTokenizerCorrupt(e.message);
        // 嘗試刪除損毀的 tokenizer，下次會提示用戶重新下載
        try {
          final tokFile = File(tokPath);
          if (tokFile.existsSync()) await tokFile.delete();
          await modelManager.refreshInstallStates();
        } catch (_) {}
      } else {
        debugPrint('[TransformerEngine] 模型載入失敗，啟動自動修復: $errorMsg');
        _repairMessage = await _repairActiveVariant(l10n);
        _loadError = _repairMessage;
      }
      return null;
    }
  }

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
      domain: AnalysisProfile.domainOf(text.raw).name,
    );

    OnnxDetector? detector;
    try {
      detector = await _ensureLoaded(l10n);
      onProgress?.call(0.12);
      if (detector == null || text.analysisChunks.isEmpty) {
        return _unavailable(l10n);
      }
    } catch (e) {
      debugPrint('[TransformerEngine] 模型載入例外，啟動自動修復: $e');
      _repairMessage = await _repairActiveVariant(l10n);
      _loadError = _repairMessage;
      return _unavailable(l10n);
    }

    List<double> perChunk;
    try {
      debugPrint('[TransformerEngine] 推論 ${text.analysisChunks.length} 個分析區塊');
      perChunk = await detector.classifySentences(
        text.analysisChunks,
        onProgress: (progress) =>
            onProgress?.call(0.12 + progress.clamp(0.0, 1.0) * 0.86),
      );
      onProgress?.call(0.98);
    } catch (e) {
      debugPrint('[TransformerEngine] 模型推論失敗，啟動自動修復: $e');
      detector.dispose();
      _detector = null;
      _loadedModelPath = null;
      _repairMessage = await _repairActiveVariant(l10n);
      _loadError = _repairMessage;
      return _unavailable(l10n);
    }
    final perSentence = text.expandChunkScoresToSentences(perChunk);
    final avg = perChunk.reduce((a, b) => a + b) / perChunk.length;
    final variant = _resolveVariant();
    final aiEvidenceThreshold = variant?.aiEvidenceThreshold ?? 0.60;
    final strongChunks = perChunk
        .where((score) => score >= aiEvidenceThreshold)
        .toList();
    final strongChunkCount = strongChunks.length;
    final strongChunkRatio = strongChunkCount / perChunk.length;
    final strongSentenceCount = perSentence
        .where((score) => score >= aiEvidenceThreshold)
        .length;
    final strongSentenceRatio = strongSentenceCount / perSentence.length;

    final calibratedProbability = documentProbability(
      perChunk,
      aiEvidenceThreshold,
    );

    // 沒有任何區塊跨過強 AI 閾值時，上面的校準把輸出壓進 [0, 0.10]，
    // 目的是抑制 Softmax 在 0.5 附近的浮動——那是消噪，不是機率估計。
    // 更關鍵的是：低於 0.5 的原始分數會被 clamp 成 0，所以「模型很確定是人寫的」
    // 和「模型根本沒意見」在輸出上完全無法區分。既然分不出來，就不能拿它
    // 當作支持人類撰寫的證據，只能誠實標記為「本次沒有證據」。
    // TODO: 未來替這個引擎補一條負向證據通道，讓確信的人類判斷也能發聲。
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
      // 現行分類器已做語言驗證，但仍主要來自 HC3；保留跨領域折扣，
      // 待 RAID／現代模型固定 FPR 報告通過後才能提高到 1。
      calibrationReliability: _choice.isValidated ? 0.82 : 0.62,
      features: {
        'ai_sentence_ratio': strongSentenceRatio,
        'ai_analysis_chunk_ratio': strongChunkRatio,
        'analysis_chunk_count': perChunk.length.toDouble(),
        'raw_avg_prob': avg,
        'calibrated_prob': calibratedProbability,
        'ai_evidence_threshold': aiEvidenceThreshold,
        ..._choice.routingFeatures,
      },
      // 路由每次分析都可能換變體，使用者只看「Transformer 分類器」無從得知
      // 這次是哪一顆在發言。
      modules: [
        if (variant != null)
          localizedModelName(variant.variantId, variant.name, l10n)
        else
          name(l10n),
      ],
      reasons: [
        // 先講清楚這次用了哪顆模型、對這個語言驗證過沒有。
        // 一份中文文件被純英文模型判為 0%，使用者有權知道原因出在模型選用。
        ..._routingNotes(l10n, text),
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

  /// 模型選用的說明：這次用哪顆、依據什麼選的、語言是否驗證過。
  /// 預設改為自動選擇後，使用者沒有親手選模型，報告必須交代選擇的理由。
  List<String> _routingNotes(AppLocalizations l10n, PreprocessedText text) {
    final variant = _choice.variant;
    if (variant == null) return const [];
    final notes = <String>[
      routingBasisText(_choice, l10n),
      ...routingProbeNotes(_choice, l10n),
    ];
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
    if (_choice.fit == LanguageFit.plausible ||
        _choice.fit == LanguageFit.unsupported ||
        _choice.basis == RoutingBasis.languageOnly) {
      notes.add(l10n.routingSeeModelManager);
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
          ? l10n.engineReasonTransformerNotInstalled
          : l10n.engineReasonNotParticipatedWithError(_loadError!),
    ],
  );

  Future<String> _repairActiveVariant(AppLocalizations l10n) async {
    try {
      return await modelManager.repairActiveVariant('transformer', l10n);
    } catch (_) {
      return l10n.engineTransformerRepairFailed;
    }
  }

  @override
  void releaseResources() {
    _detector?.dispose();
    _detector = null;
    _loadedModelPath = null;
  }
}
