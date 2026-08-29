"""Extract one language from DetectRL-X into the char-SVM training format.

Why this exists: DetectRL-X is the first public corpus covering the generators
this app actually faces — DeepSeek-V3, Gemini-2.5-Flash, GPT-4o and Qwen-Max —
and it pairs every human passage with an LLM one, so the human side needs no
separate sourcing.

Two things the extraction must not get wrong:

* **Leakage.** Each record holds a human text and the LLM text derived from the
  same source document. Splitting them across train and test would let the model
  memorise the source rather than the authorship signal, so a record's two halves
  always land on the same side.
* **The reporting split.** The corpus already ships `split: test`. That split is
  never used for training or for threshold selection — it exists to be touched
  once, at the end.

Example:
  .venv/bin/python prepare_detectrl_x_language.py --lang chinese --code zh
"""

from __future__ import annotations

import argparse
import collections
import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parent
DEFAULT_SOURCE = ROOT / "data/detectrl_x/binary_general_open.json"


def stream_records(path: Path):
    """Yield records from a multi-hundred-MB JSON array without loading it whole."""
    decoder = json.JSONDecoder()
    with path.open(encoding="utf-8") as handle:
        buffer = handle.read(1 << 20)
        start = buffer.find("[")
        if start < 0:
            raise SystemExit(f"{path} does not look like a JSON array")
        buffer = buffer[start + 1 :]
        while True:
            buffer = buffer.lstrip()
            while buffer[:1] == ",":
                buffer = buffer[1:].lstrip()
            if buffer[:1] == "]" or (not buffer and not (chunk := handle.read(1 << 20))):
                return
            try:
                record, offset = decoder.raw_decode(buffer)
            except ValueError:
                chunk = handle.read(1 << 20)
                if not chunk:
                    return
                buffer += chunk
                continue
            buffer = buffer[offset:]
            yield record


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", type=Path, default=DEFAULT_SOURCE)
    parser.add_argument("--lang", required=True, help="the corpus 'lang' value")
    parser.add_argument("--code", required=True, help="ISO 639-1 code for output paths")
    parser.add_argument("--out-dir", type=Path)
    parser.add_argument("--min-chars", type=int, default=64)
    parser.add_argument("--dev-fraction", type=float, default=0.15)
    parser.add_argument("--seed", type=int, default=20260829)
    args = parser.parse_args()

    train_records: list[dict] = []
    test_records: list[dict] = []
    stats = collections.Counter()
    for record in stream_records(args.source):
        if record.get("lang") != args.lang:
            continue
        stats[record.get("model", "?")] += 1
        (test_records if record.get("split") == "test" else train_records).append(record)

    if not train_records and not test_records:
        raise SystemExit(f"no records for lang={args.lang!r}")

    def expand(records: list[dict]) -> list[dict]:
        rows = []
        for record in records:
            for field, label in (
                ("human_written_text", 0),
                ("llm_generated_text", 1),
            ):
                text = (record.get(field) or "").strip()
                if len(text) >= args.min_chars:
                    # 人類那半不是任何模型生成的；沿用記錄的 model 欄位會讓
                    # 分生成器統計把真人樣本算進該生成器名下。
                    rows.append(
                        {
                            "text": text,
                            "label": label,
                            "model": record.get("model") if label == 1 else "human",
                        }
                    )
        return rows

    # 依「記錄」而非「樣本」切分，人機成對的兩半永遠留在同一側。
    rng = random.Random(args.seed)
    rng.shuffle(train_records)
    dev_count = int(len(train_records) * args.dev_fraction)
    splits = {
        "dev": expand(train_records[:dev_count]),
        "train": expand(train_records[dev_count:]),
        "test_with_label": expand(test_records),
    }

    out_dir = args.out_dir or (ROOT / f"data/detectrl_x/{args.code}")
    out_dir.mkdir(parents=True, exist_ok=True)
    print(f"生成器分布: {dict(stats)}")
    for name in ("train", "dev", "test_with_label"):
        rows = splits[name]
        path = out_dir / f"{name}.json"
        path.write_text(json.dumps(rows, ensure_ascii=False), encoding="utf-8")
        machine = sum(1 for r in rows if r["label"] == 1)
        print(
            f"{path}  n={len(rows):>6}  human={len(rows) - machine:>6}  machine={machine:>6}"
        )


if __name__ == "__main__":
    main()
