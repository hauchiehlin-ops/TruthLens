import '../../l10n/generated/app_localizations.dart';

/// OCR 失敗的成因。
///
/// 原本 `OcrService` 直接把中文字串存進 `lastErrorMessage`，再原樣丟進 snackbar——
/// 服務層拿不到 `AppLocalizations`，所以當初只能寫死。結果是其餘 13 個語系的
/// 使用者在英文（或日文、德文）介面裡看到中文錯誤。
///
/// 改法：服務層只回報「發生了哪一種失敗」與可選的技術明細，顯示端才在地化。
enum OcrFailureKind {
  /// 本地 OCR 伺服器自己回報了錯誤內容。
  localServerReported,

  /// 本地 OCR 伺服器回應了 200，但結構不符合任何已知格式。
  localServerFormat,

  /// OCR 成功執行，但影像中沒有可用文字。三個實作共用。
  noTextDetected,

  /// 本地 OCR 伺服器回應非 200。
  localServerStatus,

  /// 本地 OCR 伺服器無法連線或逾時。
  localUnreachable,

  /// 既沒有本地伺服器網址，也沒有 Gemini 金鑰。
  notConfigured,

  /// Gemini 有回應，但回應裡找不到可解析的文字欄位。
  geminiNoParsableText,

  /// Gemini 回 429（速率或配額）。
  geminiRateLimited,

  /// Gemini 回 400。
  geminiBadRequest,

  /// Gemini 回 401。
  geminiUnauthorized,

  /// Gemini 回其他 HTTP 錯誤且重試次數用盡。
  geminiHttpFailed,

  /// 呼叫 Gemini 期間拋出例外且重試次數用盡。
  geminiException,

  /// 未能從選取的圖片取得 bytes。
  noImageData,

  /// 金鑰測試：伺服器回 400/401。
  geminiKeyInvalid,

  /// 金鑰測試：其他非 200 回應。
  geminiTestFailed,

  /// 金鑰測試：連線期間拋出例外。
  geminiTestException,

  /// 原生外掛沒有回應 ping。
  nativePluginNoPing,

  /// 此平台未註冊原生 OCR 外掛。
  nativePluginMissing,

  /// 檢查原生外掛時拋出例外。
  nativeCheckFailed,

  /// 原生 OCR 執行失敗。
  nativeFailed,
}

/// 一次 OCR 失敗：成因加上要嵌進訊息的技術明細。
///
/// [detail] 與 [statusCode] 是給使用者回報問題用的原始資料（HTTP body、例外文字），
/// 不翻譯——翻譯它們反而會讓錯誤無法對照伺服器日誌。
class OcrFailure {
  final OcrFailureKind kind;
  final String? detail;
  final int? statusCode;

  const OcrFailure(this.kind, {this.detail, this.statusCode});

  /// 依目前介面語系描述這次失敗。
  String localize(AppLocalizations l10n) {
    final detail = this.detail ?? '';
    final status = statusCode?.toString() ?? '';
    return switch (kind) {
      OcrFailureKind.localServerReported => l10n.ocrErrorLocalServerReported(
        detail,
      ),
      OcrFailureKind.localServerFormat => l10n.ocrErrorLocalServerFormat,
      OcrFailureKind.noTextDetected => l10n.ocrErrorNoTextDetected,
      OcrFailureKind.localServerStatus => l10n.ocrErrorLocalServerStatus(
        status,
        detail,
      ),
      OcrFailureKind.localUnreachable => l10n.ocrErrorLocalUnreachable(detail),
      OcrFailureKind.notConfigured => l10n.ocrErrorNotConfigured,
      OcrFailureKind.geminiNoParsableText => l10n.ocrErrorGeminiNoParsableText,
      OcrFailureKind.geminiRateLimited => l10n.ocrErrorGeminiRateLimited,
      OcrFailureKind.geminiBadRequest => l10n.ocrErrorGeminiBadRequest(detail),
      OcrFailureKind.geminiUnauthorized => l10n.ocrErrorGeminiUnauthorized,
      OcrFailureKind.geminiHttpFailed => l10n.ocrErrorGeminiHttpFailed(
        status,
        detail,
      ),
      OcrFailureKind.geminiException => l10n.ocrErrorGeminiException(detail),
      OcrFailureKind.noImageData => l10n.ocrErrorNoImageData,
      OcrFailureKind.geminiKeyInvalid => l10n.ocrErrorGeminiKeyInvalid(status),
      OcrFailureKind.geminiTestFailed => l10n.ocrErrorGeminiTestFailed(status),
      OcrFailureKind.geminiTestException => l10n.ocrErrorGeminiTestException(
        detail,
      ),
      OcrFailureKind.nativePluginNoPing => l10n.ocrErrorNativePluginNoPing,
      OcrFailureKind.nativePluginMissing => l10n.ocrErrorNativePluginMissing,
      OcrFailureKind.nativeCheckFailed => l10n.ocrErrorNativeCheckFailed(
        detail,
      ),
      OcrFailureKind.nativeFailed => l10n.ocrErrorNativeFailed(detail),
    };
  }
}
