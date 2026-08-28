"""Extract one language from M4GT-Bench / SemEval into the DetectRL export format.

Why the consistency check exists: `SubtaskA_multilingual.jsonl` is not uniformly
trustworthy.  Its German subset carries 3000 records labelled human whose
`model` field says chatGPT, and Arabic and Italian have the same defect.  Training
on that teaches the detector that machine text is human — silently, with a
healthy-looking AUC on the equally-corrupt validation split.  So the label is
cross-checked against the generator field, and a corrupt language is refused
rather than repaired by guessing which of the two fields is right.

Example:
  .venv/bin/python prepare_m4gt_language.py --language indonesian --code id
"""

from __future__ import annotations

import argparse
import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_SOURCE = ROOT / "data/m4gt/M4GT-Bench/SubtaskA_multilingual.jsonl"


def load_language(source: Path, language: str) -> list[dict]:
    rows = []
    with source.open(encoding="utf-8") as handle:
        for line in handle:
            row = json.loads(line)
            if row.get("source") == language:
                rows.append(row)
    return rows


def contradictions(rows: list[dict]) -> int:
    """Records whose binary label disagrees with the named generator."""
    return sum(
        1
        for row in rows
        if (row["label"] == 0 and row.get("model") != "human")
        or (row["label"] == 1 and row.get("model") == "human")
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--language", required=True, help="the corpus 'source' value")
    parser.add_argument("--code", required=True, help="ISO 639-1 code for output paths")
    parser.add_argument("--out-dir", type=Path)
    parser.add_argument("--min-chars", type=int, default=64)
    parser.add_argument("--seed", type=int, default=20260828)
    args = parser.parse_args()

    rows = load_language(args.source, args.language)
    if not rows:
        raise SystemExit(f"no rows for source={args.language!r} in {args.source}")

    bad = contradictions(rows)
    if bad:
        raise SystemExit(
            f"refusing {args.language}: {bad}/{len(rows)} records have a label that "
            f"contradicts their generator field. Fix the corpus before training."
        )

    usable = [
        {"text": r["text"], "label": int(r["label"])}
        for r in rows
        if len(r["text"].strip()) >= args.min_chars
    ]
    random.Random(args.seed).shuffle(usable)

    # 70/10/20. The dev split is reserved for the decision threshold, exactly as
    # the shared-task rules require, so it must not be folded back into training.
    n = len(usable)
    train_end = int(n * 0.7)
    dev_end = int(n * 0.8)
    splits = {
        "train": usable[:train_end],
        "dev": usable[train_end:dev_end],
        "test_with_label": usable[dev_end:],
    }

    out_dir = args.out_dir or (ROOT / f"data/m4gt/{args.code}")
    out_dir.mkdir(parents=True, exist_ok=True)
    for name, split in splits.items():
        path = out_dir / f"{name}.json"
        path.write_text(
            json.dumps(split, ensure_ascii=False), encoding="utf-8"
        )
        machine = sum(1 for r in split if r["label"] == 1)
        print(f"{path}  n={len(split):>6}  human={len(split)-machine:>6}  machine={machine:>6}")


if __name__ == "__main__":
    main()
