import 'package:flutter/foundation.dart';

import 'ocr_service.dart';

/// 目前實際生效的 OCR 引擎（依優先順序：本地伺服器 → Gemini → 無）。
enum OcrEngineKind { none, local, gemini }

/// 集中管理 Web OCR 設定（本地伺服器 URL、Gemini 金鑰）與其驗證狀態，
/// 讓設定卡與首頁狀態指示可共用同一份即時狀態，不必各自讀取 localStorage。
class OcrConfigNotifier extends ChangeNotifier {
  String localServerUrl = '';
  String geminiApiKey = '';
  bool localVerified = false;
  bool geminiVerified = false;
  bool testingLocal = false;
  bool testingGemini = false;
  // 本次工作階段內「剛測試過」的結果（null＝這次還沒按過測試）；只用來讓
  // UI 立即分辨「尚未測試」與「測試失敗」，不會跨重整持久化。
  bool? localLastTestOk;
  bool? geminiLastTestOk;

  OcrConfigNotifier() {
    reload();
  }

  void reload() {
    localServerUrl = OcrService.getLocalServerUrl()?.trim() ?? '';
    geminiApiKey = OcrService.getGeminiApiKey()?.trim() ?? '';
    localVerified =
        localServerUrl.isNotEmpty &&
        OcrService.getVerifiedLocalServerUrl() == localServerUrl;
    geminiVerified =
        geminiApiKey.isNotEmpty &&
        OcrService.getVerifiedGeminiApiKey() == geminiApiKey;
    notifyListeners();
  }

  void setLocalServerUrl(String url) {
    OcrService.setLocalServerUrl(url);
    localLastTestOk = null;
    reload();
  }

  void setGeminiApiKey(String key) {
    OcrService.setGeminiApiKey(key);
    geminiLastTestOk = null;
    reload();
  }

  Future<bool> testLocal() async {
    testingLocal = true;
    notifyListeners();
    final ok = await OcrService.testLocalServer();
    testingLocal = false;
    localLastTestOk = ok;
    reload();
    return ok;
  }

  Future<bool> testGemini() async {
    testingGemini = true;
    notifyListeners();
    final ok = await OcrService.testGeminiKey();
    testingGemini = false;
    geminiLastTestOk = ok;
    reload();
    return ok;
  }

  /// 依優先順序決定目前實際生效的引擎：已設定本地伺服器 URL 時一律優先
  /// 嘗試本地（即使尚未測試過）；否則若設定了 Gemini 金鑰則使用 Gemini；
  /// 兩者皆未設定則無可用引擎。與 [OcrService.recognize] 的判斷邏輯一致。
  OcrEngineKind get activeEngine {
    if (localServerUrl.isNotEmpty) return OcrEngineKind.local;
    if (geminiApiKey.isNotEmpty) return OcrEngineKind.gemini;
    return OcrEngineKind.none;
  }

  /// 目前生效引擎是否已「實測連線成功」，而非只是填了值。
  bool get activeEngineVerified => switch (activeEngine) {
    OcrEngineKind.local => localVerified,
    OcrEngineKind.gemini => geminiVerified,
    OcrEngineKind.none => false,
  };
}
