# 本地 LLM（llama.cpp）平台支援

報告生成 LLM 透過 [llama_ffi.dart](../lib/core/detection/llama_ffi.dart) 以 FFI 呼叫原生
`llama.cpp` 動態庫。缺庫的平台會由 `LlamaFfi.isAvailable` 回報 false，
[report_llm_service.dart](../lib/core/detection/report_llm_service.dart) 自動退回
`ReportComposer` 的模板報告——**不會崩潰，只是報告不由 LLM 生成**。

## 目前庫涵蓋

| 平台 | 庫檔 | 狀態 |
| :--- | :--- | :--- |
| macOS | `macos/Libs/libtruthlens_llama.dylib` + `libllama.0.dylib`/`libggml*.dylib` | ✅ 已嵌入 .app bundle 的 Frameworks |
| Android | `android/app/src/main/jniLibs/{arm64-v8a,x86_64}/libtruthlens_llama.so` + `libllama.so`/`libggml*.so` | ✅ 已打包 arm64-v8a 與 x86_64；不宣稱支援 armeabi-v7a LLM |
| iOS | `TruthLensLlamaBridge.framework` + `llama.framework` | ✅ CocoaPods 本地 pod 打包，`tl_llama_*` 符號已在 iOS build 產物確認 |
| Windows | `windows/libs/truthlens_llama.dll` + `llama.dll`/`ggml*.dll` | 🟡 已提供 `native/llama_bridge/build_windows.ps1` 與 CMake 複製邏輯；需 Windows host 編譯驗證 |
| Linux | `libllama.so`（系統路徑） | ❌ 未提供 |

## 補上其他平台

各平台需以對應工具鏈編譯 llama.cpp，放到 `LlamaFfi._loadLibrary()` 尋找的位置：

```bash
# 通用（依平台加對應 flag / 交叉編譯工具鏈）
git clone https://github.com/ggerganov/llama.cpp && cd llama.cpp
cmake -B build -DBUILD_SHARED_LIBS=ON <平台/加速 flag>
cmake --build build --config Release
```

- **Android**：執行 `native/llama_bridge/build_android.sh`，產物放 `android/app/src/main/jniLibs/<abi>/`
- **iOS**：`ios/TruthLensLlamaBridge.podspec` 會編譯共用 bridge wrapper，並 vendored link `ios/Libs/llama.xcframework`
- **Windows**：在 Windows host 執行 `native/llama_bridge/build_windows.ps1`，產物放 `windows/libs/`，CMake 會複製到輸出目錄
- **Linux**：`libllama.so` 放系統庫路徑或隨附

## macOS bundle 嵌入注意

`_loadLibrary` 在開發時走 `macos/Libs/libllama.dylib`（相對專案根，`flutter run`/test 可用）。
正式 .app 需將 dylib 加入 Xcode 的 Copy Files（Frameworks）並設好 `@rpath`，
否則回退路徑 `DynamicLibrary.open('libllama.dylib')` 會找不到 → 退回模板。
