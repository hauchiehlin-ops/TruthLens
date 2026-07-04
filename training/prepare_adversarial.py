"""為對抗式防禦模組 D（改寫偵測）產生訓練資料。

概念（plan 模組 D）：改寫工具（QuillBot / Undetectable.ai 等）會把 AI 文本「洗」得
更像人類以規避偵測。我們用一個 T5 改寫模型模擬這個過程，把 HC3 的 ChatGPT 答案改寫，
連同原生 ChatGPT 答案一起標為 AI(1)，人類答案標為 human(0)。分類器在「原生 + 改寫」
兩種 AI 上訓練後，對改寫規避更有韌性。

輸出 data/adv_train.jsonl 與 data/adv_val.jsonl。
"""
from __future__ import annotations

import argparse
import json
import os
import random

import torch
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer

from config import DATA_DIR, adversarial
from prepare_data import _load_jsonl

PARAPHRASER = "humarin/chatgpt_paraphraser_on_T5_base"


def _device() -> str:
    # 注意：beam search 的 seq2seq generate() 在 MPS 上重複呼叫會有記憶體
    # 不釋放的已知問題（迴圈跑數百批後可膨脹到 20GB+ 造成系統換頁、看似當機）。
    # 實測 CPU 與 MPS 單批耗時相近（distilgpt2/T5-base 量級），故改寫步驟固定用 CPU，
    # 避開這個記憶體風險；其餘訓練步驟仍可用 MPS（train_classifier.py 走 Trainer，行為不同）。
    if torch.cuda.is_available():
        return "cuda"
    return "cpu"


def _paraphrase_batch(model, tok, texts: list[str], device: str) -> list[str]:
    inputs = tok(
        [f"paraphrase: {t}" for t in texts],
        return_tensors="pt",
        padding=True,
        truncation=True,
        max_length=256,
    ).to(device)
    with torch.no_grad():
        out = model.generate(
            **inputs,
            max_length=256,
            num_beams=4,
            num_return_sequences=1,
            temperature=1.0,
            do_sample=False,
        )
    result = tok.batch_decode(out, skip_special_tokens=True)
    # 第二道防線：即使日後改回 MPS/CUDA，每批強制釋放快取避免記憶體累積。
    del inputs, out
    if device == "mps" and torch.backends.mps.is_available():
        torch.mps.empty_cache()
    elif device == "cuda":
        torch.cuda.empty_cache()
    return result


def build(n_paraphrase: int, batch_size: int) -> None:
    os.makedirs(DATA_DIR, exist_ok=True)
    cfg = adversarial()
    random.seed(cfg.seed)

    print("下載 HC3 (all.jsonl) ...", flush=True)
    rows = _load_jsonl(cfg.hc3_english)
    human, ai = [], []
    for row in rows:
        for a in row.get("human_answers") or []:
            if a and len(a.strip()) >= 40:
                human.append(a.strip())
        for a in row.get("chatgpt_answers") or []:
            if a and len(a.strip()) >= 40:
                ai.append(a.strip())
    random.shuffle(human)
    random.shuffle(ai)
    cap = cfg.max_per_class
    human = human[:cap]
    ai_native = ai[:cap]
    print(f"human={len(human)} ai_native={len(ai_native)}", flush=True)

    # 改寫一部分 AI 文本（模擬規避）
    to_para = ai[:n_paraphrase]
    print(f"載入改寫模型 {PARAPHRASER} ...", flush=True)
    device = _device()
    tok = AutoTokenizer.from_pretrained(PARAPHRASER)
    model = AutoModelForSeq2SeqLM.from_pretrained(PARAPHRASER).to(device).eval()

    paraphrased = []
    import os as _os
    import time

    def _rss_mb() -> float | None:
        try:
            import psutil as _ps
            return _ps.Process(_os.getpid()).memory_info().rss / 1e6
        except Exception:
            return None

    t_start = time.time()
    for i in range(0, len(to_para), batch_size):
        batch = to_para[i:i + batch_size]
        t0 = time.time()
        paraphrased.extend(_paraphrase_batch(model, tok, batch, device))
        n_batch = i // batch_size

        # 記憶體安全防護：單批耗時異常久（>2 分鐘）或 RSS 超過 8GB 時中止，
        # 避免重演先前 MPS 記憶體膨脹到 20GB+ 拖垮系統的狀況。
        batch_secs = time.time() - t0
        rss = _rss_mb()
        if batch_secs > 120 or (rss is not None and rss > 8000):
            print(
                f"  警告：本批耗時 {batch_secs:.0f}s、RSS≈{rss}MB，"
                "疑似記憶體異常膨脹，提前中止改寫並保存已完成部分。",
                flush=True,
            )
            break

        if n_batch % 5 == 0:
            elapsed = time.time() - t_start
            done = i + len(batch)
            rate = done / elapsed if elapsed > 0 else 0
            eta = (len(to_para) - done) / rate if rate > 0 else float("nan")
            print(
                f"  改寫進度 {done}/{len(to_para)}"
                f"（本批 {time.time()-t0:.1f}s，已耗時 {elapsed/60:.1f} 分，"
                f"預估剩餘 {eta/60:.1f} 分）",
                flush=True,
            )
    print(f"改寫完成：{len(paraphrased)} 筆", flush=True)

    # 組資料：human=0；native AI + 改寫 AI = 1
    samples = []
    samples += [{"text": t, "label": 0} for t in human]
    samples += [{"text": t, "label": 1} for t in ai_native]
    samples += [{"text": t, "label": 1, "paraphrased": True} for t in paraphrased]
    random.shuffle(samples)

    n_val = max(1, int(len(samples) * cfg.val_ratio))
    val, train = samples[:n_val], samples[n_val:]
    _write(os.path.join(DATA_DIR, cfg.train_file), train)
    _write(os.path.join(DATA_DIR, cfg.val_file), val)
    print(f"完成：train={len(train)} val={len(val)}（含改寫 AI {len(paraphrased)}）", flush=True)


def _write(path: str, rows: list[dict]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--n-paraphrase", type=int, default=4000,
                    help="要改寫的 AI 文本數（越多越慢）")
    ap.add_argument("--batch-size", type=int, default=16)
    ap.add_argument("--quick", action="store_true", help="小量煙霧測試")
    args = ap.parse_args()
    build(50 if args.quick else args.n_paraphrase,
          8 if args.quick else args.batch_size)
