/// web 版 [ModelManager.refreshInstallStates] 已在讀取 manifest 時用
/// `WebFs.exists` 過濾遺失檔案，這裡回傳的路徑（OPFS 鍵）已保證存在，
/// 故無需再次檢查。
Future<bool> modelFileExists(String path) async => true;
