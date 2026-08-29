"""Extract HC3-Chinese into the char-SVM training format.

Why this corpus, when its generator is a 2022-era ChatGPT: the gap it fills is
**register**, not generator. DetectRL-X supplies contemporary models
(DeepSeek-V3, Gemini-2.5-Flash, GPT-4o, Qwen-Max) but every one of its domains
is a document rewrite or continuation. HC3-Chinese is the assistant-response
shape — a model answering a user's question with a colon-led preamble, numbered
advice and second-person address — which is precisely the register the shipped
detector scored 0/100 on.

Splitting is by question, never by answer: a question's human and machine
answers discuss the same subject, so separating them across train and test would
let the model score topic overlap instead of authorship.

Example:
  .venv/bin/python prepare_hc3_zh.py
"""

from __future__ import annotations

import argparse
import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_SOURCE = ROOT / "data/hc3_zh/all.jsonl"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--out-dir", type=Path, default=ROOT / "data/hc3_zh/zh")
    parser.add_argument("--min-chars", type=int, default=64)
    parser.add_argument("--seed", type=int, default=20260829)
    args = parser.parse_args()

    questions: list[dict] = []
    with args.source.open(encoding="utf-8") as handle:
        for line in handle:
            line = line.strip()
            if line:
                questions.append(json.loads(line))
    if not questions:
        raise SystemExit(f"no records in {args.source}")

    random.Random(args.seed).shuffle(questions)
    train_end = int(len(questions) * 0.70)
    dev_end = int(len(questions) * 0.85)
    grouped = {
        "train": questions[:train_end],
        "dev": questions[train_end:dev_end],
        "test_with_label": questions[dev_end:],
    }

    def expand(records: list[dict]) -> list[dict]:
        rows = []
        for record in records:
            for field, label, model in (
                ("human_answers", 0, "human"),
                ("chatgpt_answers", 1, "chatgpt"),
            ):
                for answer in record.get(field) or []:
                    text = (answer or "").strip()
                    if len(text) >= args.min_chars:
                        rows.append({"text": text, "label": label, "model": model})
        return rows

    args.out_dir.mkdir(parents=True, exist_ok=True)
    print(f"問題數 = {len(questions)}")
    for name, records in grouped.items():
        rows = expand(records)
        path = args.out_dir / f"{name}.json"
        path.write_text(json.dumps(rows, ensure_ascii=False), encoding="utf-8")
        machine = sum(1 for r in rows if r["label"] == 1)
        print(
            f"{path}  n={len(rows):>6}  human={len(rows) - machine:>6}  machine={machine:>6}"
        )


if __name__ == "__main__":
    main()
