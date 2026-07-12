// TruthLens ↔ llama.cpp 薄橋接層（C ABI）。
//
// 目的：把 llama.cpp 那些「by-value 結構參數 / 取樣器 / batch」等版本敏感的細節
// 全部封裝在 C++ 這一側（編譯期對齊），只對 Dart FFI 暴露 primitive + char* 的
// 極簡介面，避免在 Dart 端手刻結構佈局造成 ABI 崩潰。
//
// 生成流程遵循 llama.cpp examples/simple 的標準迴圈：
//   tokenize → llama_decode(prompt) → [sample → token_to_piece → decode(token)]* 。
#ifndef TRUTHLENS_LLAMA_H
#define TRUTHLENS_LLAMA_H

#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

// 初始化 llama.cpp 後端（整個行程呼叫一次即可）。回傳 1 表示成功。
int tl_llama_init(void);

// 載入 GGUF 模型並建立推論 context。
//   model_path : GGUF 檔絕對路徑
//   n_ctx      : context 長度（如 4096）
//   n_gpu_layers: 卸載到 GPU(Metal) 的層數（-1 = 全部；0 = 純 CPU）
// 回傳不透明 handle；失敗回傳 NULL。
void* tl_llama_load(const char* model_path, int n_ctx, int n_gpu_layers);

// 依 prompt 生成文字，寫入呼叫端提供的 UTF-8 緩衝區（null-terminated）。
// 內部套用 Gemma 對話模板。回傳寫入的位元組數(不含結尾\0)，錯誤回傳 -1。
int tl_llama_generate(void* handle, const char* prompt, int max_tokens,
                      float temperature, float top_p, unsigned int seed,
                      char* out_buf, int out_buf_size);

// 釋放模型與 context。
void tl_llama_free(void* handle);

// 釋放 llama.cpp 後端（行程結束前呼叫）。
void tl_llama_backend_free(void);

#ifdef __cplusplus
}
#endif

#endif  // TRUTHLENS_LLAMA_H
