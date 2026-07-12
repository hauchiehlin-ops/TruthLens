# iOS llama.cpp Framework 集成指南

本文檔說明如何為 iOS 編譯並集成 llama.cpp xcframework。

## 前置要求

- Xcode 14.0+
- iOS Deployment Target: 12.0+
- macOS 12.0+ 開發機器
- llama.cpp 倉庫：https://github.com/ggerganov/llama.cpp

## 編譯步驟

### 1. 克隆並準備 llama.cpp

```bash
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
```

### 2. 編譯 iOS 設備版本（arm64）

```bash
# 編譯實機版本
cmake -B build-ios \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES="arm64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build-ios --config Release

# 輸出：build-ios/src/libllama.dylib
```

### 3. 編譯 iOS 模擬器版本（x86_64 + arm64e）

```bash
# 編譯模擬器版本
cmake -B build-ios-sim \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64e" \
  -DCMAKE_OSX_SIMULATOR=ON \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build-ios-sim --config Release

# 輸出：build-ios-sim/src/libllama.dylib
```

### 4. 使用 lipo 創建通用二進制（可選）

```bash
# 若想要單一通用二進制，可用 lipo 合併（但 xcframework 方式更推薦）
lipo -create \
  build-ios/src/libllama.dylib \
  build-ios-sim/src/libllama.dylib \
  -output libllama.dylib
```

### 5. 創建 xcframework

方式 A：使用 xcodebuild（推薦）

```bash
xcodebuild -create-xcframework \
  -library build-ios/src/libllama.dylib -headers . \
  -library build-ios-sim/src/libllama.dylib -headers . \
  -output llama.xcframework
```

方式 B：手動創建（若 xcodebuild 不可用）

```bash
# 創建 xcframework 結構
mkdir -p llama.xcframework/ios-arm64
mkdir -p llama.xcframework/ios-arm64_x86_64-simulator

cp build-ios/src/libllama.dylib llama.xcframework/ios-arm64/libllama.dylib
cp build-ios-sim/src/libllama.dylib llama.xcframework/ios-arm64_x86_64-simulator/libllama.dylib

# 創建 Info.plist
cat > llama.xcframework/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>AvailableLibraries</key>
  <array>
    <dict>
      <key>Headers</key>
      <string></string>
      <key>LibraryIdentifier</key>
      <string>ios-arm64</string>
      <key>LibraryPath</key>
      <string>libllama.dylib</string>
      <key>SupportedArchitectures</key>
      <array>
        <string>arm64</string>
      </array>
      <key>SupportedPlatform</key>
      <string>ios</string>
    </dict>
    <dict>
      <key>Headers</key>
      <string></string>
      <key>LibraryIdentifier</key>
      <string>ios-arm64_x86_64-simulator</string>
      <key>LibraryPath</key>
      <string>libllama.dylib</string>
      <key>SupportedArchitectures</key>
      <array>
        <string>arm64</string>
        <string>x86_64</string>
      </array>
      <key>SupportedPlatform</key>
      <string>ios</string>
      <key>SupportedPlatformVariant</key>
      <string>simulator</string>
    </dict>
  </array>
  <key>CFBundlePackageType</key>
  <string>XFWK</string>
  <key>XCFrameworkFormatVersion</key>
  <string>1.0</string>
</dict>
</EOF
```

### 6. 集成到 TruthLens

```bash
# 複製 xcframework 到項目
mkdir -p /Users/barretlin/GitProjects/TruthLens/ios/Libs
cp -r llama.xcframework /Users/barretlin/GitProjects/TruthLens/ios/Libs/
```

### 7. 在 Xcode 中設定

1. 開啟 `ios/Runner.xcworkspace`
2. 選擇 **Runner** target → **Build Phases**
3. 在 **Copy Bundle Resources** 中確保 `llama.xcframework` 已列出
4. 選擇 **Runner** target → **Build Settings**
5. 搜尋 **Framework Search Paths**，添加：`$(PROJECT_DIR)/Libs`
6. 搜尋 **Other Linker Flags**，添加：`-framework llama`

### 8. 更新 LlamaFfi 支援（已完成）

`lib/core/detection/llama_ffi_io.dart` 的 `_loadLibrary()` 已支援：

```dart
} else if (Platform.isIOS) {
  return ffi.DynamicLibrary.open('llama.framework/llama');
}
```

當 xcframework 正確集成後，上述代碼會自動加載。

## 驗證

```bash
# 編譯檢查（不實際運行）
flutter build ios --no-codesign

# 或在實機上運行
flutter run -d ios
```

LlamaFfi.isAvailable 應返回 true（若庫成功加載）。

## 故障排除

### 「Cannot load libllama」

- 確認 xcframework 已複製到 `ios/Libs/`
- 確認 Xcode Build Settings 中 Framework Search Paths 包含 `$(PROJECT_DIR)/Libs`
- 檢查 llama.xcframework/Info.plist 是否完整

### 「Unsupported architecture」

- 確認編譯了 arm64（實機）和 arm64e/x86_64（模擬器）
- 若只需實機，可略去模擬器版本

### 構建失敗

- 確認 iOS Deployment Target ≥ 12.0
- 檢查 llama.dylib 不是 arm64e_arm64 架構不支援的版本
- 嘗試手動清理：`flutter clean && flutter pub get`

## 效能提示

iOS 上的 llama.cpp 性能：
- **實機（A15+）**：可接受（~50 token/s 用 7B 模型）
- **模擬器（x86_64）**：很慢（~5-10 token/s），建議開發時使用實機
- **內存**：7B 模型需 ~16GB RAM；iPhone 12+ 通常足夠

## 參考

- llama.cpp 官方 iOS 文檔：https://github.com/ggerganov/llama.cpp/tree/master/examples/llama.swiftui
- Xcode xcframework 文檔：https://developer.apple.com/documentation/xcode/creating-a-binary-framework-bundle
