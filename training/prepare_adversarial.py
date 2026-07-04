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
    if torch.backends.mps.is_available():
        return "mps"
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
    return tok.batch_decode(out, skip_special_tokens=True)


def build(n_paraphrase: int, batch_size: int) -> None:
    os.makedirs(DATA_DIR, exist_ok=True)
    cfg = adversarial()
    random.seed(cfg.seed)

    print("下載 HC3 (all.jsonl) ...")
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
    print(f"human={len(human)} ai_native={len(ai_native)}")

    # 改寫一部分 AI 文本（模擬規避）
    to_para = ai[:n_paraphrase]
    print(f"載入改寫模型 {PARAPHRASER} ...")
    device = _device()
    tok = AutoTokenizer.from_pretrained(PARAPHRASER)
    model = AutoModelForSeq2SeqLM.from_pretrained(PARAPHRASER).to(device).eval()

    paraphrased = []
    for i in range(0, len(to_para), batch_size):
        batch = to_para[i:i + batch_size]
        paraphrased.extend(_paraphrase_batch(model, tok, batch, device))
        if (i // batch_size) % 10 == 0:
            print(f"  改寫進度 {i + len(batch)}/{len(to_para)}")
    print(f"改寫完成：{len(paraphrased)} 筆")

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
    print(f"完成：train={len(train)} val={len(val)}（含改寫 AI {len(paraphrased)}）")


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
