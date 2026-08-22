"""把現代、多模型與人類化語料整理成不洩漏的訓練／驗證集。

輸入由 binoculars/prepare_corpus.py 產生。切分單位是 group_id（原始 human 文件
或其衍生題目），不是單一文字塊；同題的 Claude、GPT、Gemini、人類化與輕編修版本
因此不可能分散到 train/val 兩側。
"""

from __future__ import annotations

import argparse
import json
import random
from collections import Counter, defaultdict
from pathlib import Path


def load_rows(paths: list[Path]) -> list[dict]:
    rows: list[dict] = []
    for path in paths:
        for line in path.read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            row = json.loads(line)
            label = row.get("label")
            if label in {"human", 0, "0"}:
                row["label"] = 0
                row["authorship_class"] = "human"
            elif label in {"ai", "ai_generated", 1, "1"}:
                row["label"] = 1
                row["authorship_class"] = "ai_generated"
            elif label == "ai_assisted":
                row["label"] = 1
                row["authorship_class"] = "ai_assisted"
            else:
                raise ValueError(f"未知標籤 {label!r}：{path}")
            row["group_id"] = str(row.get("group_id") or row.get("doc_id") or row.get("id"))
            rows.append(row)
    return rows


def grouped_split(rows: list[dict], val_ratio: float, seed: int) -> tuple[list[dict], list[dict]]:
    groups: dict[str, list[dict]] = defaultdict(list)
    for row in rows:
        groups[row["group_id"]].append(row)

    rng = random.Random(seed)
    val_keys: set[str] = set()
    by_signature: dict[tuple[int, ...], list[str]] = defaultdict(list)
    for group_id, samples in groups.items():
        signature = tuple(sorted({row["label"] for row in samples}))
        by_signature[signature].append(group_id)
    for keys in by_signature.values():
        rng.shuffle(keys)
        count = 0 if len(keys) < 2 else max(1, round(len(keys) * val_ratio))
        val_keys.update(keys[:count])

    train: list[dict] = []
    val: list[dict] = []
    for group_id, samples in groups.items():
        (val if group_id in val_keys else train).extend(samples)
    rng.shuffle(train)
    rng.shuffle(val)
    return train, val


def cap_groups(rows: list[dict], max_chunks_per_group: int, seed: int) -> list[dict]:
    grouped: dict[tuple[int, str], list[dict]] = defaultdict(list)
    for row in rows:
        grouped[(row["label"], row["group_id"])].append(row)
    rng = random.Random(seed)
    output: list[dict] = []
    for samples in grouped.values():
        rng.shuffle(samples)
        output.extend(samples[:max_chunks_per_group])
    rng.shuffle(output)
    return output


def balance(rows: list[dict], seed: int, max_per_class: int | None) -> list[dict]:
    by_label = {label: [row for row in rows if row["label"] == label] for label in (0, 1)}
    target = min(len(by_label[0]), len(by_label[1]))
    if max_per_class:
        target = min(target, max_per_class)
    if target == 0:
        raise ValueError("human/ai 兩類都必須至少有一筆")
    rng = random.Random(seed)
    output: list[dict] = []
    for samples in by_label.values():
        rng.shuffle(samples)
        output.extend(samples[:target])
    rng.shuffle(output)
    return output


def write(path: Path, rows: list[dict]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", encoding="utf-8") as handle:
        for row in rows:
            handle.write(json.dumps(row, ensure_ascii=False) + "\n")


def assert_no_leakage(train: list[dict], val: list[dict]) -> None:
    train_groups = {(row["label"], row["group_id"]) for row in train}
    val_groups = {(row["label"], row["group_id"]) for row in val}
    overlap = train_groups & val_groups
    if overlap:
        raise AssertionError(f"train/val group leakage: {sorted(overlap)[:5]}")

    train_topics = {row["group_id"] for row in train}
    val_topics = {row["group_id"] for row in val}
    topic_overlap = train_topics & val_topics
    if topic_overlap:
        raise AssertionError(f"train/val prompt leakage: {sorted(topic_overlap)[:5]}")


def summarize(name: str, rows: list[dict]) -> None:
    labels = Counter("human" if row["label"] == 0 else "ai" for row in rows)
    providers = Counter(row.get("provider", "unknown") for row in rows if row["label"] == 1)
    styles = Counter(row.get("style", "unknown") for row in rows if row["label"] == 1)
    classes = Counter(row.get("authorship_class", "unknown") for row in rows)
    print(
        f"{name}: {dict(labels)} | classes={dict(classes)} | "
        f"AI providers={dict(providers)} | styles={dict(styles)}"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="準備現代 AI 偵測訓練資料")
    parser.add_argument("--corpus", type=Path, action="append", required=True)
    parser.add_argument("--out-dir", type=Path, default=Path("data"))
    parser.add_argument("--val-ratio", type=float, default=0.15)
    parser.add_argument("--max-chunks-per-group", type=int, default=3)
    parser.add_argument("--max-per-class", type=int, default=30000)
    parser.add_argument("--seed", type=int, default=20260821)
    args = parser.parse_args()

    rows = cap_groups(load_rows(args.corpus), args.max_chunks_per_group, args.seed)
    train, val = grouped_split(rows, args.val_ratio, args.seed)
    train = balance(train, args.seed, args.max_per_class)
    val = balance(val, args.seed + 1, None)
    assert_no_leakage(train, val)
    write(args.out_dir / "modern_train.jsonl", train)
    write(args.out_dir / "modern_val.jsonl", val)
    summarize("train", train)
    summarize("val", val)


if __name__ == "__main__":
    main()
