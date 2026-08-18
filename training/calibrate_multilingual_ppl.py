"""評估多語言語言模型能否取代 DistilGPT2 作為困惑度指標。

背景：現行的 DistilGPT2 只在英文語料上訓練，對中文量到的是 UTF-8 位元組的
可預測性而非語言的可預測性。HC3 實測 AUC 僅 0.50（見 calibrate_perplexity.py），
因此中文已停用此指標。本腳本用同一套語料與同一套方法評估候選的多語模型，
判斷「換模型」是否真能換回中文的鑑別力——換之前先量，不要先下載 1GB 再說。

判準：AUC ≥ 0.65（PerplexityCalibration.minimumUsableAuc）才值得採用。

**門檻必須用 production 實際會跑的產物量**：量化會位移困惑度尺度。
production 的 DistilGPT2 對英文真人量到 304，fp32 只有 65.6，就是同一個現象。
因此本腳本同時支援 HuggingFace（fp32，快速篩選候選）與 ONNX（production 產物，定案）。

用法：
    # fp32 快速篩選候選模型
    .venv/bin/python calibrate_multilingual_ppl.py --model Qwen/Qwen2.5-0.5B

    # 以 production 的 INT8 ONNX 定案門檻
    .venv/bin/python calibrate_multilingual_ppl.py \\
        --onnx artifacts/qwen05b_web/model_int8.onnx \\
        --tokenizer artifacts/qwen05b_web
"""

from __future__ import annotations

import argparse
import json
import math
import random
import re
import statistics
from pathlib import Path

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

BASE = Path(__file__).parent
CJK = re.compile(r"[一-鿿]")
MIN_USABLE_AUC = 0.65


def language_of(text: str) -> str:
    return "zh" if len(CJK.findall(text)) / max(len(text), 1) > 0.15 else "en"


def load_cells(n: int, seed: int = 20260818):
    cells = {(lang, label): [] for lang in ("zh", "en") for label in (0, 1)}
    rows = [json.loads(l) for l in (BASE / "data" / "train.jsonl").open(encoding="utf-8")]
    random.Random(seed).shuffle(rows)
    for row in rows:
        text = " ".join(row["text"].split())
        if len(text) < 200:
            continue
        key = (language_of(text), row["label"])
        if len(cells[key]) < n:
            cells[key].append(text)
        if all(len(v) >= n for v in cells.values()):
            break
    return cells


def auc_lower_is_ai(human: list[float], ai: list[float]) -> float:
    """AI 困惑度低於真人的機率。0.5 = 毫無鑑別力。"""
    wins = sum(1 for a in ai for h in human if a < h)
    ties = sum(1 for a in ai for h in human if a == h)
    return (wins + 0.5 * ties) / (len(ai) * len(human))


def operating_point(human: list[float], ai: list[float], budget: float):
    """偽陽性率不超過 budget 的前提下，能換到的最高命中率。

    對會拿去指控他人的工具，操作點應由偽陽性預算決定，
    而不是用 Youden 最大化 TPR−FPR。
    """
    best = (float("nan"), 0.0, 0.0)
    for cut in sorted({round(v, 2) for v in human + ai}):
        fpr = sum(1 for v in human if v < cut) / len(human)
        if fpr > budget:
            break
        tpr = sum(1 for v in ai if v < cut) / len(ai)
        if tpr > best[1]:
            best = (cut, tpr, fpr)
    return best


def onnx_scorer(onnx_path: str, tokenizer_path: str, max_length: int):
    """ONNX causal LM 的困惑度計算。

    transformers.js／onnxruntime-web 的建置會把 KV cache 攤成獨立輸入
    （0.5B 模型為 24 層 × key/value，共 48 個）。單次前向不需要 cache，
    餵入 past_sequence_length=0 的空張量即可。
    """
    import json as _json

    import numpy as np
    import onnxruntime as ort

    sess = ort.InferenceSession(onnx_path, providers=["CPUExecutionProvider"])
    tok = AutoTokenizer.from_pretrained(tokenizer_path)
    cfg = _json.loads((Path(tokenizer_path) / "config.json").read_text())
    layers = cfg["num_hidden_layers"]
    kv_heads = cfg["num_key_value_heads"]
    head_dim = cfg["hidden_size"] // cfg["num_attention_heads"]
    names = {i.name for i in sess.get_inputs()}

    def ppl(text: str) -> float:
        ids = tok(
            text, truncation=True, max_length=max_length, return_tensors="np"
        ).input_ids.astype(np.int64)
        n = ids.shape[1]
        if n < 8:
            return float("nan")
        feed = {
            "input_ids": ids,
            "attention_mask": np.ones((1, n), dtype=np.int64),
        }
        if "position_ids" in names:
            feed["position_ids"] = np.arange(n, dtype=np.int64)[None, :]
        empty = np.zeros((1, kv_heads, 0, head_dim), dtype=np.float32)
        for i in range(layers):
            if f"past_key_values.{i}.key" in names:
                feed[f"past_key_values.{i}.key"] = empty
                feed[f"past_key_values.{i}.value"] = empty
        logits = sess.run(["logits"], feed)[0][0]
        shifted = logits[:-1]
        shifted = shifted - shifted.max(-1, keepdims=True)
        log_probs = shifted - np.log(np.exp(shifted).sum(-1, keepdims=True))
        nll = -log_probs[np.arange(n - 1), ids[0, 1:]].mean()
        return math.exp(float(nll))

    return ppl


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default="distilgpt2", help="HuggingFace 模型 ID（fp32）")
    ap.add_argument("--onnx", help="改用 ONNX 產物（production 尺度，定案用）")
    ap.add_argument("--tokenizer", help="ONNX 模式的 tokenizer／config 目錄")
    ap.add_argument("--n", type=int, default=150)
    ap.add_argument("--max-length", type=int, default=384)
    args = ap.parse_args()

    if args.onnx:
        if not args.tokenizer:
            ap.error("--onnx 需同時指定 --tokenizer")
        ppl = onnx_scorer(args.onnx, args.tokenizer, args.max_length)
        print(f"模型：{Path(args.onnx).name}（ONNX・production 尺度）")
    else:
        device = "mps" if torch.backends.mps.is_available() else "cpu"
        tok = AutoTokenizer.from_pretrained(args.model)
        model = AutoModelForCausalLM.from_pretrained(args.model).to(device).eval()
        params = sum(p.numel() for p in model.parameters())
        print(f"模型：{args.model}　參數 {params/1e6:.0f}M　{device}（fp32・僅供篩選）")

        def ppl(text: str) -> float:
            ids = tok(
                text, return_tensors="pt", truncation=True, max_length=args.max_length
            ).input_ids.to(device)
            if ids.shape[1] < 8:
                return float("nan")
            with torch.no_grad():
                loss = model(ids, labels=ids).loss
            return math.exp(loss.item())

    cells = load_cells(args.n)
    print()
    print(f"{'語言':<6}{'真人中位數':>12}{'AI 中位數':>12}{'AUC':>8}   採用判定")
    print("-" * 60)
    results = {}
    for lang, title in (("zh", "中文"), ("en", "英文")):
        human = [v for v in (ppl(t) for t in cells[(lang, 0)]) if not math.isnan(v)]
        ai = [v for v in (ppl(t) for t in cells[(lang, 1)]) if not math.isnan(v)]
        a = auc_lower_is_ai(human, ai)
        verdict = "✅ 可採用" if a >= MIN_USABLE_AUC else f"❌ 未達 {MIN_USABLE_AUC}"
        print(
            f"{title:<6}{statistics.median(human):>12.1f}"
            f"{statistics.median(ai):>12.1f}{a:>8.3f}   {verdict}"
        )
        results[lang] = (human, ai, a)

    print("\n可採用語言的建議門檻（依偽陽性預算）")
    print("-" * 60)
    for lang, title in (("zh", "中文"), ("en", "英文")):
        human, ai, a = results[lang]
        if a < MIN_USABLE_AUC:
            print(f"{title}：鑑別力不足，不列門檻")
            continue
        for budget in (0.05, 0.10):
            cut, tpr, fpr = operating_point(human, ai, budget)
            print(
                f"{title}　偽陽性預算 {budget:>4.0%} → aiCut {cut:>7.2f}"
                f"　命中 {tpr:>5.1%}　實際誤傷 {fpr:>5.1%}"
            )
        ai_sorted = sorted(ai)
        human_cut = ai_sorted[int(len(ai_sorted) * 0.95)]
        print(f"{title}　humanCut {human_cut:.2f}（僅 5% 的 AI 樣本高於此值）")


if __name__ == "__main__":
    main()
