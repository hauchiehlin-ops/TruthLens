"""階段一步驟 2：對語料計算 Binoculars 分數（以及對照用的裸 perplexity）。

原理
----
    B = log-perplexity(觀察者模型 M1 對實際詞元的困惑度)
        ───────────────────────────────────────────────
        cross-perplexity(M1 與 M2 對下一個詞分布的交叉熵)

分子單獨使用就是「裸 perplexity」，正是現有引擎 B 的作法，也是對非母語寫作
產生系統性偽陽性的原因。分母提供了一個「這段文字本來就有多難預測」的基準。

**分數越低越像機器產出**（與直覺相反），評測時務必留意方向。

用法
----
    .venv/bin/python binoculars/run_binoculars.py \
        --corpus binoculars/data/corpus.jsonl \
        --observer tiiuae/falcon-7b \
        --performer tiiuae/falcon-7b-instruct \
        --out binoculars/data/scores.jsonl

階段一建議先用全尺寸模型確認「值不值得做」；階段二再換小模型量衰減。
小模型配對範例（階段二）：
    --observer HuggingFaceTB/SmolLM2-360M --performer HuggingFaceTB/SmolLM2-360M-Instruct
"""

from __future__ import annotations

import argparse
import json
import sys
import time
from pathlib import Path

import torch
import torch.nn.functional as F
from transformers import AutoModelForCausalLM, AutoTokenizer


def pick_device(requested: str) -> str:
    if requested != "auto":
        return requested
    if torch.cuda.is_available():
        return "cuda"
    # MPS 對部分 LLM 運算支援仍不完整，但小模型多半可行；失敗時可 --device cpu
    if torch.backends.mps.is_available():
        return "mps"
    return "cpu"


def load_pair(observer_id: str, performer_id: str, device: str, dtype: torch.dtype):
    print(f"載入觀察者模型 {observer_id} …")
    tok = AutoTokenizer.from_pretrained(observer_id)
    if tok.pad_token is None:
        tok.pad_token = tok.eos_token
    observer = AutoModelForCausalLM.from_pretrained(observer_id, dtype=dtype).to(device)
    observer.eval()

    print(f"載入表現者模型 {performer_id} …")
    performer_tok = AutoTokenizer.from_pretrained(performer_id)
    performer = AutoModelForCausalLM.from_pretrained(performer_id, dtype=dtype).to(
        device
    )
    performer.eval()

    # 兩個模型必須共用同一套 tokenizer，否則詞彙表對不齊，
    # 交叉熵就是在比較兩個不同座標系的分布——數字算得出來但沒有意義。
    if performer_tok.get_vocab() != tok.get_vocab():
        sys.exit(
            "兩個模型的 tokenizer 詞彙表不一致，無法計算交叉困惑度。\n"
            "請選用同系列的 base / instruct 配對（例如 Falcon-7B 與 Falcon-7B-Instruct）。"
        )
    return tok, observer, performer


@torch.no_grad()
def score_text(
    text: str,
    tok,
    observer,
    performer,
    device: str,
    max_tokens: int,
) -> dict | None:
    enc = tok(
        text, return_tensors="pt", truncation=True, max_length=max_tokens
    ).to(device)
    input_ids = enc["input_ids"]
    if input_ids.shape[1] < 32:
        return None  # 太短，任何困惑度統計都不穩定

    obs_logits = observer(**enc).logits
    perf_logits = performer(**enc).logits

    # 預測第 t+1 個詞用的是第 t 個位置的輸出，因此兩邊各錯開一位
    shift_logits_obs = obs_logits[:, :-1, :]
    shift_logits_perf = perf_logits[:, :-1, :]
    targets = input_ids[:, 1:]

    # 分子：觀察者對「實際出現的詞元」的平均負對數機率
    log_probs = F.log_softmax(shift_logits_obs.float(), dim=-1)
    token_logprobs = log_probs.gather(-1, targets.unsqueeze(-1)).squeeze(-1)
    log_ppl = float(-token_logprobs.mean())

    # 分母：兩個模型下一詞分布之間的交叉熵平均
    p_obs = F.softmax(shift_logits_obs.float(), dim=-1)
    log_q_perf = F.log_softmax(shift_logits_perf.float(), dim=-1)
    cross_ppl = float(-(p_obs * log_q_perf).sum(dim=-1).mean())

    if not (cross_ppl == cross_ppl) or abs(cross_ppl) < 1e-9:  # NaN 或近似 0
        return None

    return {
        "log_perplexity": log_ppl,
        "cross_perplexity": cross_ppl,
        "binoculars": log_ppl / cross_ppl,
        "tokens": int(input_ids.shape[1]),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Binoculars 階段一：計分")
    parser.add_argument("--corpus", type=Path, default=Path("binoculars/data/corpus.jsonl"))
    parser.add_argument("--out", type=Path, default=Path("binoculars/data/scores.jsonl"))
    parser.add_argument("--observer", default="tiiuae/falcon-7b")
    parser.add_argument("--performer", default="tiiuae/falcon-7b-instruct")
    parser.add_argument("--device", default="auto", choices=["auto", "cpu", "cuda", "mps"])
    parser.add_argument("--max-tokens", type=int, default=512)
    parser.add_argument(
        "--dtype",
        default="float16",
        choices=["float16", "bfloat16", "float32"],
        help="CPU 上請用 float32",
    )
    parser.add_argument("--limit", type=int, default=0, help="只跑前 N 筆（煙霧測試用）")
    args = parser.parse_args()

    if not args.corpus.exists():
        sys.exit(f"找不到語料 {args.corpus}，請先跑 prepare_corpus.py")

    samples = [json.loads(line) for line in args.corpus.read_text().splitlines() if line]
    if args.limit:
        samples = samples[: args.limit]

    device = pick_device(args.device)
    dtype = {"float16": torch.float16, "bfloat16": torch.bfloat16, "float32": torch.float32}[
        args.dtype
    ]
    if device == "cpu" and dtype is not torch.float32:
        print("⚠️  CPU 上半精度會極慢且可能不準，自動改用 float32")
        dtype = torch.float32

    print(f"裝置 {device} / dtype {dtype} / 樣本 {len(samples)} 筆")
    tok, observer, performer = load_pair(args.observer, args.performer, device, dtype)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    started = time.time()
    written = skipped = 0
    with args.out.open("w", encoding="utf-8") as f:
        for i, sample in enumerate(samples, 1):
            result = score_text(
                sample["text"], tok, observer, performer, device, args.max_tokens
            )
            if result is None:
                skipped += 1
                continue
            row = {k: sample[k] for k in ("id", "doc_id", "label", "source", "words")}
            row.update(result)
            f.write(json.dumps(row, ensure_ascii=False) + "\n")
            written += 1
            if i % 10 == 0 or i == len(samples):
                elapsed = time.time() - started
                print(
                    f"  {i}/{len(samples)}　已寫 {written}　略過 {skipped}　"
                    f"平均 {elapsed / i:.2f}s/筆",
                    flush=True,
                )

    print(f"\n已寫入 {args.out}（{written} 筆，略過 {skipped} 筆）")
    print("接著執行：.venv/bin/python binoculars/evaluate.py")


if __name__ == "__main__":
    main()
