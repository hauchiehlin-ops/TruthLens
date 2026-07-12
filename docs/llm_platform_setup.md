# LLM 跨平台支援補全指南

TruthLens 使用 `llama.cpp` 提供本地 LLM 推論能力。本文檔說明如何為各平台補充 libllama 動態庫。

## 📊 平台支援矩陣

| 平台 | 狀態 | 庫文件 | 備註 |
|------|------|--------|------|
| **macOS** | ✅ 完成 | `macos/Libs/libllama.dylib` (2.6MB) | Intel + Apple Silicon (universal binary) |
| **iOS** | 🟡 需補充 | `ios/Libs/llama.xcframework` | 需編譯為 xcframework |
| **Android arm64** | ✅ 完成 | `android/app/src/main/jniLibs/arm64-v8a/libllama.so` (34MB) | 常用架構 |
| **Android x86_64** | 🟡 需補充 | `android/app/src/main/jniLibs/x86_64/libllama.so` | 模擬器/特定設備 |
| **Android armv7** | 🟡 可選 | `android/app/src/main/jniLibs/armeabi-v7a/libllama.so` | 舊設備支援 |
| **Windows** | 🟡 需補充 | `windows/libs/llama.dll` | x64 預期 |
| **Linux** | ❌ 未規劃 | 系統庫 | 桌面環境非優先 |

## 🔧 為各平台編譯 llama.cpp

### 前置要求

```bash
# 克隆 llama.cpp
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp

# 安裝依賴（依平台）
# macOS: 已包含
# Windows: 需 Visual Studio Build Tools 或 MinGW
# Android: 需 NDK
# iOS: 需 Xcode
```

### 1. macOS 通用二進制（已完成）✅

```bash
# 編譯 Intel + Apple Silicon 通用二進制
cmake -B build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_OSX_ARCHITECTURES="arm64;x86_64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0
cmake --build build --config Release

# 複製到項目
cp build/src/libllama.dylib ../TruthLens/macos/Libs/
```

### 2. iOS xcframework（需補充）🟡

```bash
# 編譯 iOS 設備版本
cmake -B build-ios \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES="arm64" \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
  -DBUILD_SHARED_LIBS=ON
cmake --build build-ios --config Release

# 編譯 iOS 模擬器版本（可選）
cmake -B build-ios-sim \
  -DCMAKE_SYSTEM_NAME=iOS \
  -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64" \
  -DCMAKE_OSX_SIMULATOR=ON \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=12.0 \
  -DBUILD_SHARED_LIBS=ON
cmake --build build-ios-sim --config Release

# 創建 xcframework（需要 xcodebuild 工具或手動打包）
# 可選：使用工具生成，或參考 llama.cpp 官方 iOS 指南
```

### 3. Android（部分完成）✅⚠️

#### arm64-v8a（已完成）✅

```bash
export ANDROID_NDK=/path/to/android-ndk

# 編譯 arm64
cmake -B build-arm64 \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21 \
  -DBUILD_SHARED_LIBS=ON
cmake --build build-arm64 --config Release

cp build-arm64/src/libllama.so ../TruthLens/android/app/src/main/jniLibs/arm64-v8a/
```

#### x86_64（需補充）🟡

```bash
# 編譯 x86_64（用於模擬器和特定設備）
cmake -B build-x86_64 \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=x86_64 \
  -DANDROID_PLATFORM=android-21 \
  -DBUILD_SHARED_LIBS=ON
cmake --build build-x86_64 --config Release

cp build-x86_64/src/libllama.so ../TruthLens/android/app/src/main/jniLibs/x86_64/
```

#### armeabi-v7a（可選）

```bash
# 編譯 ARMv7（舊設備支援，可選）
cmake -B build-armv7 \
  -DCMAKE_TOOLCHAIN_FILE=$ANDROID_NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=armeabi-v7a \
  -DANDROID_PLATFORM=android-21 \
  -DBUILD_SHARED_LIBS=ON
cmake --build build-armv7 --config Release

cp build-armv7/src/libllama.so ../TruthLens/android/app/src/main/jniLibs/armeabi-v7a/
```

### 4. Windows（需補充）🟡

```bash
# 編譯 Windows x64
# 使用 Visual Studio 2022 或 MinGW-w64

# 若使用 Visual Studio
cmake -B build -G "Visual Studio 17 2022" \
  -A x64 \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release

# 複製到項目
copy build\src\Release\llama.dll ..\TruthLens\windows\libs\

# 若使用 MinGW（跨編譯或在 Windows 上）
cmake -B build -G "MinGW Makefiles" \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build

cp build/src/libllama.dll ../TruthLens/windows/libs/
```

## 🚀 快速設置腳本

### macOS（已完成）

```bash
# 驗證 macOS 庫
file /Users/barretlin/GitProjects/TruthLens/macos/Libs/libllama.dylib
# 應輸出：Mach-O 64-bit dynamically linked shared library arm64
```

### Android（部分完成）

```bash
# 驗證已安裝的庫
find /Users/barretlin/GitProjects/TruthLens/android/app/src/main/jniLibs -name "*.so"

# 期望輸出：
# /Users/barretlin/GitProjects/TruthLens/android/app/src/main/jniLibs/arm64-v8a/libllama.so
# /Users/barretlin/GitProjects/TruthLens/android/app/src/main/jniLibs/x86_64/libllama.so（待補）
```

## 📝 平台特定注意事項

### iOS
- llama.xcframework 必須是通用二進制，支援實機（arm64）和模擬器（x86_64/arm64e）
- 建議使用 Xcode Build Phases 自動複製 framework 到 App Bundle
- LlamaFfi._loadLibrary() 會嘗試 `DynamicLibrary.open('llama.framework/llama')`

### Windows
- llama.dll 必須與 TruthLens.exe 在同一目錄或在 PATH 中
- 建議在 CMakeLists.txt 的 Copy Files 階段將 dll 複製到構建輸出
- 支援 x64；x86 (Win32) 暫不規劃

### Android
- 為各 ABI 都補充 .so，Android Runtime 會自動選擇最適合的
- arm64-v8a：最常用（現代 Google Play 要求）
- x86_64：模擬器和特定設備
- armeabi-v7a：可選（舊設備，今已罕見）

## ⚙️ LlamaFfi 優雅降級

若平台缺少 libllama，LlamaFfi.isAvailable 回傳 false，報告生成會自動改用模板（ReportComposer）。無需用戶干預。

```dart
// llama_ffi.dart - 當前實現
static bool get isAvailable {
  if (!_initialized) _init();
  return _available; // false 若庫載入失敗
}

// report_llm_service.dart 會檢查並自動降級
if (!LlamaFfi.isAvailable) {
  return ReportComposer.buildTemplateReport(...); // 使用模板
}
```

## 🔗 參考資源

- llama.cpp 官方倉庫：https://github.com/ggerganov/llama.cpp
- iOS 編譯指南：https://github.com/ggerganov/llama.cpp/tree/master/examples/llama.swiftui
- Android NDK 文檔：https://developer.android.com/ndk
- Windows 構建指南：https://github.com/ggerganov/llama.cpp/blob/master/docs/build.md

## 待辦清單

- [ ] 編譯 iOS xcframework
- [ ] 編譯 Android x86_64
- [ ] 編譯 Android armeabi-v7a（可選）
- [ ] 編譯 Windows llama.dll
- [ ] 驗證各平台的庫載入與推論
- [ ] 更新 CI/CD 以自動構建這些庫
