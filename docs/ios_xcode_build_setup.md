# iOS Xcode 編譯設置指南

## 🔴 當前問題

構建失敗：`Cannot find 'InferencePlugin' in scope`

根本原因：`InferenceHelper.mm` (Objective-C++ 實裝) 沒有被添加到 Xcode Build Phases

## ✅ 解決步驟

### **第 1 步：打開 Xcode**

```bash
open ios/Runner.xcworkspace
# ⚠️ 注意：打開 .xcworkspace，不是 .xcodeproj
```

### **第 2 步：添加 InferenceHelper.mm 到 Compile Sources**

1. **在 Xcode 中**：
   - 左側面板 → 選擇 `Runner` project
   - 選擇 `Runner` target
   - 切換到 **Build Phases** tab

2. **展開 "Compile Sources"** 區段

3. **點擊 "+" 按鈕**，添加文件：
   ```
   ios/Runner/InferenceHelper.mm
   ```

### **第 3 步：檢查 Build Settings**

確保以下設置正確：

| 設定項 | 值 |
|--------|-----|
| `SWIFT_OBJC_BRIDGING_HEADER` | `Runner/Runner-Bridging-Header.h` |
| `ENABLE_BITCODE` | `NO` (ONNX Runtime 要求) |
| `OTHER_CPLUSPLUSFLAGS` | `-fPIC` (如需要) |

**檢查步驟**：
1. Build Settings tab → 搜尋 "Swift"
2. 驗證 `SWIFT_OBJC_BRIDGING_HEADER` 設置

### **第 4 步：清潔並重建**

```bash
# 在 Xcode 中
Cmd + Shift + K  # 清潔構建資料夾

# 或用 CLI
flutter clean
flutter pub get
flutter build ios
```

## 📋 文件清單

需要在 Xcode 中設置的文件：

| 文件 | 類型 | 添加位置 |
|------|------|----------|
| `ios/Runner/InferencePlugin.swift` | Swift | 自動添加 ✅ |
| `ios/Runner/InferenceHelper.h` | Objective-C Header | Compile Sources |
| `ios/Runner/InferenceHelper.mm` | Objective-C++ | **Compile Sources** ⚠️ |
| `ios/Runner/Runner-Bridging-Header.h` | 配置 | 自動 ✅ |

## 🔧 Objective-C++ 編譯設置

### 文件類型識別

Xcode 需要將 `.mm` 文件識別為 Objective-C++：

1. 在 Xcode 中選擇 `InferenceHelper.mm`
2. 右側 File Inspector → Target Membership
3. 確保 `Runner` 被勾選

### 編譯標誌（可選）

如果遇到編譯警告，可在 Build Settings 中調整：

```
OTHER_CPLUSPLUSFLAGS = -fPIC -std=c++17
CLANG_CXX_LANGUAGE_DIALECT = c++17
```

## 🚨 常見問題排查

### 問題 1：找不到 "Runner-Bridging-Header.h"

**解決**：
```bash
# 確認文件存在
ls ios/Runner/Runner-Bridging-Header.h

# 確認 Build Settings 中的路徑正確
# Build Settings → Search "Bridging" → 檢查路徑
```

### 問題 2：ONNX Runtime 符號未找到

**解決**：
- 檢查 `ios/Podfile` 中是否有 `pod 'onnxruntime-objc'`
- 執行 `pod install --repo-update`
- 確保使用 `.xcworkspace` 而不是 `.xcodeproj`

### 問題 3："Cannot find 'InferenceHelper' in scope"

**解決**：
- 檢查 Bridging Header 是否正確包含 `#import "InferenceHelper.h"`
- 確保 `InferenceHelper.mm` 已被添加到 Compile Sources
- 檢查 File Inspector 中 InferenceHelper.mm 的 Target Membership

## 📱 測試構建

### 編譯檢查

```bash
# 預檢查（無需真機）
flutter build ios --dry-run

# 完整構建
flutter build ios

# 打包 Archive（需真機）
flutter build ios --release
```

### 真機測試

```bash
# 連接 iOS 設備後
flutter run -d <device_id>

# 或在 Xcode 中：
# 1. 選擇目標設備
# 2. Product → Run (Cmd+R)
```

## 📚 參考資源

- [Flutter Plugins: iOS Setup](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#ios)
- [Objective-C++ Interoperability](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjectiveC/Chapters/ocLanguageOverview.html)
- [CocoaPods Documentation](https://guides.cocoapods.org/)

## 🔄 當前狀態

### ✅ 已完成
- ✅ Dart 層：InferencePlugin.swift (占位實作)
- ✅ Swift 層：完整實裝
- ✅ Objective-C 層：InferenceHelper.h + .mm 實裝
- ✅ Bridging Header：正確配置

### ⏳ 待完成
- ⏳ Xcode Build Phases：添加 InferenceHelper.mm 到 Compile Sources
- ⏳ 編譯測試：確認 Objective-C++ 代碼能正常編譯
- ⏳ 真機測試：驗證推論執行

## 🎯 下一步

1. **立即執行**：按上述步驟在 Xcode 中添加 InferenceHelper.mm
2. **測試編譯**：`flutter build ios`
3. **驗證推論**：真機測試推論功能

---

**注意**：若 Xcode 版本過舊或 CocoaPods 配置問題，可能需要：
```bash
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install --repo-update && cd ..
flutter build ios
```
