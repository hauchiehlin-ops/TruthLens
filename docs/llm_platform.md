# 本地 LLM（llama.cpp）平台支援

報告生成 LLM 透過 [llama_ffi.dart](../lib/core/detection/llama_ffi.dart) 以 FFI 呼叫原生
`llama.cpp` 動態庫。缺庫的平台會由 `LlamaFfi.isAvailable` 回報 false，
[report_llm_service.dart](../lib/core/detection/report_llm_service.dart) 自動退回
`ReportComposer` 的模板報告——**不會崩潰，只是報告不由 LLM 生成**。

## 目前庫涵蓋

| 平台 | 庫檔 | 狀態 |
| :--- | :--- | :--- |
| macOS | `macos/Libs/libllama.dylib` | ✅ 已放置（需確認已嵌入 .app bundle 的 Frameworks，見下） |
| Android | `android/app/src/main/jniLibs/arm64-v8a/libllama.so` | ✅ 僅 arm64-v8a（無 x86_64 模擬器 / armeabi-v7a） |
| iOS | `llama.framework/llama` | ❌ 未提供 |
| Windows | `windows/libs/llama.dll` | ❌ 未提供 |
| Linux | `libllama.so`（系統路徑） | ❌ 未提供 |

## 補上其他平台

各平台需以對應工具鏈編譯 llama.cpp，放到 `LlamaFfi._loadLibrary()` 尋找的位置：

```bash
# 通用（依平台加對應 flag / 交叉編譯工具鏈）
git clone https://github.com/ggerganov/llama.cpp && cd llama.cpp
cmake -B build -DBUILD_SHARED_LIBS=ON <平台/加速 flag>
cmake --build build --config Release
```

- **iOS**：編為 `llama.xcframework`，嵌入 Runner，`_loadLibrary` 用 `DynamicLibrary.process()` 或 framework 路徑
- **Windows**：`llama.dll` 放 `windows/libs/`，並在 CMake 複製到輸出目錄
- **Android x86_64 / armeabi-v7a**：加對應 ABI 的 `.so` 到 `jniLibs/<abi>/`
- **Linux**：`libllama.so` 放系統庫路徑或隨附

## macOS bundle 嵌入注意

`_loadLibrary` 在開發時走 `macos/Libs/libllama.dylib`（相對專案根，`flutter run`/test 可用）。
正式 .app 需將 dylib 加入 Xcode 的 Copy Files（Frameworks）並設好 `@rpath`，
否則回退路徑 `DynamicLibrary.open('libllama.dylib')` 會找不到 → 退回模板。
