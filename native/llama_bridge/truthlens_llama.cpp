// TruthLens ↔ llama.cpp 橋接實作。介面見 truthlens_llama.h。
// 對齊當前 llama.cpp C API（llama_model_load_from_file / llama_init_from_model /
// llama_sampler_* 等），生成迴圈遵循 examples/simple。
#include "truthlens_llama.h"

#include "llama.h"

#include <string>
#include <vector>
#include <cstring>
#include <cstdio>

namespace {

struct TlContext {
    llama_model*        model = nullptr;
    llama_context*      ctx   = nullptr;
    const llama_vocab*  vocab = nullptr;
};

// 套用 Gemma 對話模板（Gemma 2/3 皆用此格式）。
std::string apply_gemma_template(const char* prompt) {
    std::string p = prompt ? prompt : "";
    return "<start_of_turn>user\n" + p +
           "<end_of_turn>\n<start_of_turn>model\n";
}

}  // namespace

extern "C" {

int tl_llama_init(void) {
    llama_backend_init();
    return 1;
}

void* tl_llama_load(const char* model_path, int n_ctx, int n_gpu_layers) {
    if (!model_path) return nullptr;

    llama_model_params mparams = llama_model_default_params();
    mparams.n_gpu_layers = n_gpu_layers;  // -1 = 全部卸載到 Metal

    llama_model* model = llama_model_load_from_file(model_path, mparams);
    if (!model) return nullptr;

    llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx   = (n_ctx > 0) ? (uint32_t)n_ctx : 4096;
    cparams.n_batch = cparams.n_ctx;
    cparams.n_threads = 4;
    cparams.n_threads_batch = 4;

    llama_context* ctx = llama_init_from_model(model, cparams);
    if (!ctx) {
        llama_model_free(model);
        return nullptr;
    }

    TlContext* h = new TlContext();
    h->model = model;
    h->ctx   = ctx;
    h->vocab = llama_model_get_vocab(model);
    return h;
}

int tl_llama_generate(void* handle, const char* prompt, int max_tokens,
                      float temperature, float top_p, unsigned int seed,
                      char* out_buf, int out_buf_size) {
    if (!handle || !out_buf || out_buf_size <= 0) return -1;
    TlContext* h = static_cast<TlContext*>(handle);

    const std::string formatted = apply_gemma_template(prompt);

    // 1) Tokenize（add_special=true 讓模型加 BOS）。先量長度再配置。
    const int n_ctx = (int)llama_n_ctx(h->ctx);
    int n_needed = -llama_tokenize(h->vocab, formatted.c_str(),
                                   (int)formatted.size(), nullptr, 0,
                                   /*add_special=*/true, /*parse_special=*/true);
    if (n_needed <= 0) return -1;
    if (n_needed > n_ctx - 8) n_needed = n_ctx - 8;  // 保留生成空間

    std::vector<llama_token> tokens(n_needed);
    int n_prompt = llama_tokenize(h->vocab, formatted.c_str(),
                                  (int)formatted.size(), tokens.data(),
                                  (int)tokens.size(), true, true);
    if (n_prompt <= 0) return -1;
    tokens.resize(n_prompt);

    // 2) 取樣器鏈：top_k → top_p → temp → dist（溫度<=0 則貪婪）。
    llama_sampler* smpl =
        llama_sampler_chain_init(llama_sampler_chain_default_params());
    if (temperature <= 0.0f) {
        llama_sampler_chain_add(smpl, llama_sampler_init_greedy());
    } else {
        llama_sampler_chain_add(smpl, llama_sampler_init_top_k(40));
        llama_sampler_chain_add(smpl, llama_sampler_init_top_p(top_p, 1));
        llama_sampler_chain_add(smpl, llama_sampler_init_temp(temperature));
        llama_sampler_chain_add(smpl, llama_sampler_init_dist(seed));
    }

    // 3) 先 decode prompt。
    llama_batch batch = llama_batch_get_one(tokens.data(), (int)tokens.size());
    std::string result;
    int written = 0;
    bool ok = true;

    if (llama_decode(h->ctx, batch) != 0) {
        ok = false;
    }

    // 4) 生成迴圈：sample → 檢查 EOG → token_to_piece → 累積 → decode 下一顆。
    char piece[256];
    for (int i = 0; ok && i < max_tokens; ++i) {
        llama_token id = llama_sampler_sample(smpl, h->ctx, -1);
        if (llama_vocab_is_eog(h->vocab, id)) break;

        int n = llama_token_to_piece(h->vocab, id, piece, sizeof(piece), 0,
                                     /*special=*/false);
        if (n < 0) break;
        result.append(piece, n);

        // 緩衝區快滿就停（保留結尾 \0）。
        if ((int)result.size() >= out_buf_size - 1) {
            result.resize(out_buf_size - 1);
            break;
        }

        llama_token next = id;
        llama_batch nb = llama_batch_get_one(&next, 1);
        if (llama_decode(h->ctx, nb) != 0) break;
    }

    llama_sampler_free(smpl);

    if (!ok) return -1;

    written = (int)result.size();
    if (written > out_buf_size - 1) written = out_buf_size - 1;
    std::memcpy(out_buf, result.data(), written);
    out_buf[written] = '\0';
    return written;
}

void tl_llama_free(void* handle) {
    if (!handle) return;
    TlContext* h = static_cast<TlContext*>(handle);
    if (h->ctx)   llama_free(h->ctx);
    if (h->model) llama_model_free(h->model);
    delete h;
}

void tl_llama_backend_free(void) {
    llama_backend_free();
}

}  // extern "C"
