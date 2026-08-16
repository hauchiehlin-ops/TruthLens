"""階段三：校準判定門檻，並產出可直接貼進 Dart 的常數。

為什麼不能沿用階段一的門檻
--------------------------
`BinocularsScorer.placeholderThreshold = 0.9` 只是佔位值。真正的門檻取決於
**模型配對**與**語言**：換模型會整體平移，換語言會改變分布形狀。沿用別人的
門檻等於把偽陽性率交給運氣。

本腳本以「在目標偽陽性率下反解門檻」的方式求值——與 App 的共形校準同一個
單位（偽陽性率），兩邊講的是同一件事。

**必須用獨立的校準集**（不是拿評測集求門檻再回頭報告該集的效果，那會樂觀偏誤）。
預設以 doc_id 分層切分，確保同一份文件不會同時出現在兩邊。

用法
----
    .venv/bin/python binoculars/calibrate_threshold.py \\
        --scores binoculars/data/scores.jsonl \\
        --target-fpr 0.05
"""

from __future__ import annotations

import argparse
import json
import random
import re
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np


def detect_language(text_sample: str) -> str:
    """粗略語言分群：只分 CJK 與非 CJK。

    分布形狀在中英文之間差異很大（斷詞粒度不同），因此門檻必須分開求。
    更細的語言判別留待有實際多語語料時再處理。
    """
    cjk = len(re.findall(r"[㐀-䶿一-鿿぀-ヿ가-힯]", text_sample))
    return "cjk" if cjk > len(text_sample) * 0.15 else "latin"


def split_by_doc(rows: list[dict], calib_ratio: float, seed: int):
    """以 doc_id 分層切分，同一份文件的所有切塊只會落在同一邊。"""
    by_doc = defaultdict(list)
    for row in rows:
        by_doc[row["doc_id"]].append(row)

    docs = sorted(by_doc)
    random.Random(seed).shuffle(docs)
    cut = max(1, int(len(docs) * calib_ratio))
    calib_docs = set(docs[:cut])

    calib = [r for d in calib_docs for r in by_doc[d]]
    test = [r for d in docs[cut:] for r in by_doc[d]]
    return calib, test


def threshold_at_fpr(human_scores: np.ndarray, target_fpr: float) -> float:
    """Binoculars 越低越像 AI，因此門檻取 human 分布的下尾分位數。

    以 human 樣本的第 (target_fpr) 分位數為門檻：低於此值才判為 AI，
    如此在 human 上的誤判率即約為 target_fpr。
    """
    return float(np.quantile(human_scores, target_fpr))


def evaluate_at(threshold: float, human: np.ndarray, ai: np.ndarray) -> dict:
    fpr = float((human < threshold).mean()) if len(human) else float("nan")
    recall = float((ai < threshold).mean()) if len(ai) else float("nan")
    return {"threshold": threshold, "fpr": fpr, "recall": recall}


def main() -> None:
    parser = argparse.ArgumentParser(description="Binoculars 階段三：門檻校準")
    parser.add_argument("--scores", type=Path, default=Path("binoculars/data/scores.jsonl"))
    parser.add_argument("--corpus", type=Path, default=Path("binoculars/data/corpus.jsonl"),
                        help="用於語言判別（需要原文）")
    parser.add_argument("--out", type=Path, default=Path("binoculars/data/threshold.md"))
    parser.add_argument("--target-fpr", type=float, default=0.05)
    parser.add_argument("--calib-ratio", type=float, default=0.5)
    parser.add_argument("--seed", type=int, default=0)
    args = parser.parse_args()

    if not args.scores.exists():
        sys.exit(f"找不到 {args.scores}，請先跑 run_binoculars.py")

    rows = [json.loads(l) for l in args.scores.read_text().splitlines() if l]

    # 補上語言標記（scores.jsonl 不含原文，需回查語料）
    lang_by_id: dict[str, str] = {}
    if args.corpus.exists():
        for line in args.corpus.read_text().splitlines():
            if not line:
                continue
            item = json.loads(line)
            lang_by_id[item["id"]] = detect_language(item.get("text", ""))
    for row in rows:
        row["lang"] = lang_by_id.get(row["id"], "latin")

    lines = [
        "# Binoculars 階段三：門檻校準",
        "",
        f"- 目標偽陽性率：{args.target_fpr:.0%}",
        f"- 校準／測試切分比例：{args.calib_ratio:.0%} / {1 - args.calib_ratio:.0%}（依 doc_id 分層）",
        "",
    ]

    groups: dict[str, list[dict]] = defaultdict(list)
    for row in rows:
        groups[row["lang"]].append(row)
    groups["all"] = rows

    results: dict[str, dict] = {}
    for lang, subset in sorted(groups.items()):
        human_docs = len({r["doc_id"] for r in subset if r["label"] == "human"})
        ai_docs = len({r["doc_id"] for r in subset if r["label"] == "ai"})
        if human_docs < 10 or ai_docs < 10:
            lines.append(
                f"## {lang}\n\n樣本量不足（human {human_docs} 份、ai {ai_docs} 份，"
                "每類至少 10 份獨立文件才校準），略過。\n"
            )
            continue

        calib, test = split_by_doc(subset, args.calib_ratio, args.seed)
        calib_human = np.array(
            [r["binoculars"] for r in calib if r["label"] == "human"], dtype=float
        )
        if len(calib_human) < int(1 / args.target_fpr):
            lines.append(
                f"## {lang}\n\n校準集 human 只有 {len(calib_human)} 筆，"
                f"不足以支撐 {args.target_fpr:.0%} 這個操作點（需 ≥{int(1 / args.target_fpr)}），略過。\n"
            )
            continue

        threshold = threshold_at_fpr(calib_human, args.target_fpr)
        test_human = np.array(
            [r["binoculars"] for r in test if r["label"] == "human"], dtype=float
        )
        test_ai = np.array(
            [r["binoculars"] for r in test if r["label"] == "ai"], dtype=float
        )
        on_test = evaluate_at(threshold, test_human, test_ai)
        results[lang] = on_test

        lines += [
            f"## {lang}",
            "",
            f"- 校準集：{len(calib_human)} 筆 human",
            f"- **門檻 = {threshold:.4f}**（分數低於此值判為 AI）",
            "",
            "在**獨立測試集**上的表現：",
            "",
            f"- 實際偽陽性率：{on_test['fpr']:.1%}（目標 {args.target_fpr:.0%}）",
            f"- 召回率：{on_test['recall']:.1%}",
            "",
        ]

        # 樣本外偽陽性率明顯超標，代表分位數估計太不穩——這是校準集太小的
        # 典型徵狀，必須明說，否則使用者會拿一個名目 5% 實則更高的門檻上線。
        overshoot = on_test["fpr"] - args.target_fpr
        if overshoot > args.target_fpr:
            lines += [
                f"> ⚠️ 樣本外偽陽性率為目標的 {on_test['fpr'] / args.target_fpr:.1f} 倍。",
                f"> 以 {len(calib_human)} 筆 human 估計 {args.target_fpr:.0%} 分位數本來就很不穩，",
                "> 這個門檻上線後實際誤判會高於名目值。請累積更多 human 樣本後重跑；",
                f"> 經驗上校準集至少要 {int(5 / args.target_fpr)} 筆才會穩定。",
                "",
            ]

    if results:
        lines += ["## 貼回 Dart", "", "```dart", "// lib/core/detection/binoculars_scorer.dart"]
        if "cjk" in results and "latin" in results:
            lines += [
                "// 中英文分布形狀不同，門檻必須分開",
                f"static const double thresholdLatin = {results['latin']['threshold']:.4f};",
                f"static const double thresholdCjk = {results['cjk']['threshold']:.4f};",
            ]
        else:
            only = results.get("all") or next(iter(results.values()))
            lines.append(f"static const double placeholderThreshold = {only['threshold']:.4f};")
        lines += ["```", ""]
        lines += [
            "⚠️ 這組門檻**只對本次使用的模型配對有效**。換配對必須重跑本腳本。",
            "",
        ]
    else:
        lines += ["## 無法校準", "", "所有分組樣本量都不足，請先累積更多語料。", ""]

    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text("\n".join(lines), encoding="utf-8")
    print("\n".join(lines))
    print(f"\n報告已寫入 {args.out}")


if __name__ == "__main__":
    main()
