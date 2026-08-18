"""用 HC3 標註語料校準統計引擎的困惑度門檻（distilgpt2）。

背景：statistical_engine.dart 目前寫死 `ppl < 60 → +0.28（偏 AI）`、
`ppl > 150 → -0.25（偏人類）`，註解宣稱「AI 風格文本 ~50、人類口語 ~500+」。
實測發現真人中文散文 31.6、真人英文口語 49.7 都低於 60，該規則等於恆為真，
使統計引擎對任何文本都輸出 0.5+0.28=0.78。本腳本用真實標註資料求出
實際的分布、可分性（AUC）與逐語言的最佳切點。

用法：
    .venv/bin/python calibrate_perplexity.py            # 每類每語言 300 筆
    .venv/bin/python calibrate_perplexity.py --n 800    # 加大樣本
"""

import argparse
import json
import math
import random
import re
import statistics
from pathlib import Path

import torch
from transformers import AutoModelForCausalLM, AutoTokenizer

DATA = Path(__file__).parent / "data" / "train.jsonl"
CJK = re.compile(r"[㐀-䶿一-鿿぀-ヿ가-힯]")


def language_of(text: str) -> str:
    """以 CJK 字元佔比粗分語言——只需區分兩種困惑度尺度，不需精確語種。"""
    if not text:
        return "en"
    return "zh" if len(CJK.findall(text)) / len(text) > 0.15 else "en"


def load_samples(n_per_cell: int, seed: int = 20260818):
    cells = {("zh", 0): [], ("zh", 1): [], ("en", 0): [], ("en", 1): []}
    rows = [json.loads(line) for line in DATA.open(encoding="utf-8")]
    random.Random(seed).shuffle(rows)
    for row in rows:
        text = " ".join(row["text"].split())
        # 太短的樣本困惑度不穩定，且低於應用程式自己的棄權門檻
        if len(text) < 200:
            continue
        key = (language_of(text), row["label"])
        if key in cells and len(cells[key]) < n_per_cell:
            cells[key].append(text)
        if all(len(v) >= n_per_cell for v in cells.values()):
            break
    return cells


def build_scorer():
    device = "mps" if torch.backends.mps.is_available() else "cpu"
    tok = AutoTokenizer.from_pretrained("distilgpt2")
    model = AutoModelForCausalLM.from_pretrained("distilgpt2").to(device).eval()

    def ppl(text: str) -> float:
        ids = tok(
            text, return_tensors="pt", truncation=True, max_length=384
        ).input_ids.to(device)
        if ids.shape[1] < 8:
            return float("nan")
        with torch.no_grad():
            loss = model(ids, labels=ids).loss
        return math.exp(loss.item())

    return ppl, device


def auc(human: list[float], ai: list[float]) -> float:
    """AI 分數低於真人的機率（困惑度越低越像 AI）。0.5 = 完全無鑑別力。"""
    wins = ties = 0
    for a in ai:
        for h in human:
            if a < h:
                wins += 1
            elif a == h:
                ties += 1
    total = len(ai) * len(human)
    return (wins + 0.5 * ties) / total if total else float("nan")


def best_cut(human: list[float], ai: list[float]) -> tuple[float, float, float]:
    """回傳 (切點, 該切點的真陽性率, 偽陽性率)，以 Youden's J 選取。"""
    best = (float("nan"), 0.0, 0.0, -1.0)
    for cut in sorted(set(round(v, 1) for v in human + ai)):
        tpr = sum(1 for v in ai if v < cut) / len(ai)
        fpr = sum(1 for v in human if v < cut) / len(human)
        j = tpr - fpr
        if j > best[3]:
            best = (cut, tpr, fpr, j)
    return best[0], best[1], best[2]


def describe(name: str, values: list[float]) -> str:
    q = statistics.quantiles(values, n=100)
    return (
        f"  {name:<10} n={len(values):<4} "
        f"中位數 {statistics.median(values):>7.1f}   "
        f"p10 {q[9]:>7.1f}   p90 {q[89]:>7.1f}"
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--n", type=int, default=300, help="每語言每類別的樣本數")
    args = parser.parse_args()

    cells = load_samples(args.n)
    ppl, device = build_scorer()
    print(f"裝置：{device}　樣本：" + "、".join(f"{k[0]}/{k[1]}={len(v)}" for k, v in cells.items()))
    print()

    cache = Path(__file__).parent / "data" / f"perplexity_scores_n{args.n}.json"
    if cache.exists():
        raw = json.loads(cache.read_text())
        scores = {(k.split("/")[0], int(k.split("/")[1])): v for k, v in raw.items()}
        print(f"（沿用既有分數快取 {cache.name}）")
    else:
        scores = {}
        for key, texts in cells.items():
            values = [p for p in (ppl(t) for t in texts) if not math.isnan(p)]
            scores[key] = values
        cache.write_text(
            json.dumps({f"{k[0]}/{k[1]}": v for k, v in scores.items()}),
            encoding="utf-8",
        )

    print("=" * 74)
    print("distilgpt2 困惑度分布（HC3 標註語料）")
    print("=" * 74)
    for lang, title in (("zh", "中文"), ("en", "英文")):
        human, ai = scores[(lang, 0)], scores[(lang, 1)]
        if not human or not ai:
            continue
        print(f"\n【{title}】")
        print(describe("真人", human))
        print(describe("AI", ai))
        a = auc(human, ai)
        cut, tpr, fpr = best_cut(human, ai)
        print(f"  AUC {a:.3f}（0.5 = 毫無鑑別力）")
        print(f"  最佳切點 ppl < {cut:.1f} → 命中 {tpr:.1%} 的 AI、誤傷 {fpr:.1%} 的真人")
        cur_tpr = sum(1 for v in ai if v < 60) / len(ai)
        cur_fpr = sum(1 for v in human if v < 60) / len(human)
        print(f"  現行切點 ppl < 60  → 命中 {cur_tpr:.1%} 的 AI、誤傷 {cur_fpr:.1%} 的真人")
        cur_hi = sum(1 for v in human if v > 150) / len(human)
        print(f"  現行的「偏人類」規則 ppl > 150 只涵蓋 {cur_hi:.1%} 的真人樣本")

        # 「偏人類」側：取只有 5% 的 AI 樣本會超過的值，超過它幾乎確定不是 AI
        ai_sorted = sorted(ai)
        human_cut = ai_sorted[int(len(ai_sorted) * 0.95)]
        cov = sum(1 for v in human if v > human_cut) / len(human)
        leak = sum(1 for v in ai if v > human_cut) / len(ai)
        print(
            f"  建議「偏人類」切點 ppl > {human_cut:.1f}"
            f" → 涵蓋 {cov:.1%} 的真人、僅 {leak:.1%} 的 AI 誤入"
        )
        print(f"  ▶ 建議規則：ppl < {cut:.1f} 偏 AI ／ ppl > {human_cut:.1f} 偏人類")


if __name__ == "__main__":
    main()
