# LLM 跨平台支援補全指南

TruthLens 使用 `native/llama_bridge/truthlens_llama.cpp` 包住 `llama.cpp`，Dart 端只呼叫
`tl_llama_*` C ABI。各平台必須同時打包 TruthLens bridge 與 llama.cpp/ggml 依賴；
只放 `libllama` / `llama.dll` 不足以讓 App 生成 Gemma 報告。

詳細狀態以 [llm_platform.md](llm_platform.md) 為準。

## 平台支援矩陣

| 平台 | 狀態 | 打包內容 | 備註 |
|------|------|----------|------|
| macOS | ✅ 已完成 | `libtruthlens_llama.dylib` + `libllama.0.dylib`/`libggml*.dylib` | App bundle `Frameworks/` 已驗證 |
| iOS | ✅ 已打包 | `TruthLensLlamaBridge.framework` + `llama.framework` | `flutter build ios --no-codesign` 已驗證符號；實機需簽章 smoke test |
| Android arm64-v8a | ✅ 已打包 | `libtruthlens_llama.so` + `libllama.so`/`libggml*.so` | debug APK 已驗證包含所有依賴 |
| Android x86_64 | ✅ 已打包 | `libtruthlens_llama.so` + `libllama.so`/`libggml*.so` | 模擬器 ABI |
| Android armeabi-v7a | ⬜ 不宣稱支援 | 無 | llama/Gemma 記憶體需求高，先不支援舊 ABI |
| Windows x64 | 🟡 腳本就緒 | `truthlens_llama.dll` + `llama.dll`/`ggml*.dll` | 需 Windows host 執行編譯與 smoke test |
| Linux | ⬜ 未規劃 | 無 | 桌面環境非優先 |

## Android

```bash
cd native/llama_bridge
ABI_LIST="arm64-v8a x86_64" ./build_android.sh
```

腳本會：

- 需要時 clone `llama.cpp`
- 以 Android NDK/CMake 編譯 `truthlens_llama`
- 複製 `libtruthlens_llama.so`、`libllama.so`、`libggml.so`、`libggml-base.so`、`libggml-cpu.so`
  到 `android/app/src/main/jniLibs/<abi>/`

驗證 APK：

```bash
flutter build apk --debug
unzip -l build/app/outputs/flutter-apk/app-debug.apk | rg "libtruthlens_llama|libllama|libggml"
```

## iOS

iOS 透過本地 CocoaPods pod 編譯 bridge：

- `ios/TruthLensLlamaBridge.podspec`
- `ios/TruthLensLlamaBridge/truthlens_llama_bridge.cpp`
- `ios/Libs/llama.xcframework`

驗證：

```bash
cd ios
pod install
cd ..
flutter build ios --no-codesign
nm -gU build/ios/iphoneos/Runner.app/Frameworks/TruthLensLlamaBridge.framework/TruthLensLlamaBridge | rg "tl_llama"
```

## Windows

在 Windows x64 開發機上執行：

```powershell
powershell -ExecutionPolicy Bypass -File native\llama_bridge\build_windows.ps1
flutter build windows
```

腳本會把 `truthlens_llama.dll`、`llama.dll`、`ggml.dll`、`ggml-base.dll`、`ggml-cpu.dll`
放進 `windows/libs/`。`windows/CMakeLists.txt` 會在 build/install 階段複製這些 DLL 到
Flutter 輸出目錄。

## 優雅降級

若平台缺少 bridge、依賴 DLL/SO/dylib、或使用者尚未安裝 Gemma GGUF，
`LlmManager.loadIfAvailable()` 會回傳 false，報告仍會由 `ReportComposer` 生成模板報告。
這是可用性保護，不代表該平台已完成 Gemma narrative smoke test。
