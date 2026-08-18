"""檢驗：以 HC3（2022 ChatGPT）校準出的困惑度門檻，對現代 LLM 輸出是否仍成立。

背景：使用者的 ChatGPT 中文文件實測困惑度 58，而 HC3 中文 AI 的中位數只有 9.2，
真人中位數 56.3——那篇 AI 文章落在真人分布的正中央。本腳本量化這個現象。

方法上的兩個要求（沿用 generate_ai_corpus.py 的警告）：

1. **題材對齊**：AI 樣本寫的是與 HC3 真人同類的日常問答題材，
   不是學術散文。否則量到的是題材差異而非來源差異。
2. **語域分散**：涵蓋自然口語、解釋說明、建議指引、敘事、評論分析，
   以及刻意保留條列結構的「半罐頭」。真實使用者拿到的輸出橫跨這個範圍，
   只測其中一端會得到假性樂觀或假性悲觀的結論。

**已知限制**：AI 樣本由單一模型撰寫。generate_ai_corpus.py 建議至少兩個
不同供應商，但本次無 API 金鑰。因此結論只能說明「現代 LLM 輸出中有很大一部分
落在真人分布內」，不能宣稱涵蓋所有生成器的行為。

用法：
    .venv/bin/python binoculars/evaluate_modern_ai.py
"""

from __future__ import annotations

import json
import math
import re
import random
import statistics
from pathlib import Path

import numpy as np
import onnxruntime as ort
from transformers import AutoTokenizer

BASE = Path(__file__).parent.parent
MODEL_DIR = BASE / "artifacts" / "qwen05b_web"
CJK = re.compile(r"[一-鿿]")

# lib/core/detection/perplexity_calibration.dart 的 qwen05b-ppl-int8 中文條目
HC3_AI_CUT = 11.19
HC3_HUMAN_CUT = 18.67


def build_scorer():
    sess = ort.InferenceSession(
        str(MODEL_DIR / "model_int8.onnx"), providers=["CPUExecutionProvider"]
    )
    tok = AutoTokenizer.from_pretrained(str(MODEL_DIR))
    cfg = json.loads((MODEL_DIR / "config.json").read_text())
    layers = cfg["num_hidden_layers"]
    kv_heads = cfg["num_key_value_heads"]
    head_dim = cfg["hidden_size"] // cfg["num_attention_heads"]

    def ppl(text: str) -> float:
        ids = tok(
            text, truncation=True, max_length=384, return_tensors="np"
        ).input_ids.astype(np.int64)
        n = ids.shape[1]
        if n < 8:
            return float("nan")
        feed = {
            "input_ids": ids,
            "attention_mask": np.ones((1, n), dtype=np.int64),
            "position_ids": np.arange(n, dtype=np.int64)[None, :],
        }
        empty = np.zeros((1, kv_heads, 0, head_dim), dtype=np.float32)
        for i in range(layers):
            feed[f"past_key_values.{i}.key"] = empty
            feed[f"past_key_values.{i}.value"] = empty
        logits = sess.run(["logits"], feed)[0][0]
        shifted = logits[:-1]
        shifted = shifted - shifted.max(-1, keepdims=True)
        log_probs = shifted - np.log(np.exp(shifted).sum(-1, keepdims=True))
        return math.exp(float(-log_probs[np.arange(n - 1), ids[0, 1:]].mean()))

    return ppl


def load_hc3_human(n: int, seed: int = 20260819) -> list[str]:
    rows = [
        json.loads(l)
        for l in (BASE / "data" / "train.jsonl").open(encoding="utf-8")
    ]
    random.Random(seed).shuffle(rows)
    out = []
    for row in rows:
        text = " ".join(row["text"].split())
        if row["label"] != 0 or len(text) < 150:
            continue
        if len(CJK.findall(text)) / len(text) <= 0.15:
            continue
        out.append(text)
        if len(out) >= n:
            break
    return out


def load_hc3_ai(n: int, seed: int = 20260819) -> list[str]:
    rows = [
        json.loads(l)
        for l in (BASE / "data" / "train.jsonl").open(encoding="utf-8")
    ]
    random.Random(seed).shuffle(rows)
    out = []
    for row in rows:
        text = " ".join(row["text"].split())
        if row["label"] != 1 or len(text) < 150:
            continue
        if len(CJK.findall(text)) / len(text) <= 0.15:
            continue
        out.append(text)
        if len(out) >= n:
            break
    return out


def auc_lower_is_ai(human: list[float], ai: list[float]) -> float:
    wins = sum(1 for a in ai for h in human if a < h)
    ties = sum(1 for a in ai for h in human if a == h)
    return (wins + 0.5 * ties) / (len(ai) * len(human))


def main() -> None:
    ppl = build_scorer()
    modern = [
        json.loads(l)
        for l in (Path(__file__).parent / "modern_ai_zh.jsonl").open(
            encoding="utf-8"
        )
    ]

    human = [ppl(t) for t in load_hc3_human(100)]
    hc3_ai = [ppl(t) for t in load_hc3_ai(100)]
    modern_scores = [(m["style"], ppl(m["text"])) for m in modern]
    modern_values = [v for _, v in modern_scores]

    def line(name: str, values: list[float]) -> None:
        below = sum(1 for v in values if v < HC3_AI_CUT) / len(values)
        print(
            f"  {name:<26} n={len(values):<4} 中位數 {statistics.median(values):>6.1f}"
            f"   落在「偏 AI」側 {below:>6.1%}"
        )

    print(f"門檻（HC3 校準）：aiCut {HC3_AI_CUT} ／ humanCut {HC3_HUMAN_CUT}\n")
    print("【困惑度分布】")
    line("HC3 真人（2022）", human)
    line("HC3 AI（2022 ChatGPT）", hc3_ai)
    line("現代 LLM（2026）", modern_values)

    print("\n【可分性 AUC】（0.5 = 毫無鑑別力）")
    print(f"  HC3 AI    vs 真人：{auc_lower_is_ai(human, hc3_ai):.3f}")
    print(f"  現代 LLM  vs 真人：{auc_lower_is_ai(human, modern_values):.3f}")

    print("\n【逐語域】")
    by_style: dict[str, list[float]] = {}
    for style, value in modern_scores:
        by_style.setdefault(style, []).append(value)
    for style, values in by_style.items():
        flagged = sum(1 for v in values if v < HC3_AI_CUT)
        print(
            f"  {style:<8} n={len(values)}  中位數 {statistics.median(values):>6.1f}"
            f"   被判偏 AI {flagged}/{len(values)}"
        )

    print(
        "\n註：AI 樣本由單一模型撰寫，題材對齊 HC3 的日常問答，語域刻意分散。"
        "\n    結論可說明「現代輸出有很大一部分落在真人分布內」，"
        "不宣稱涵蓋所有生成器。"
    )


if __name__ == "__main__":
    main()
