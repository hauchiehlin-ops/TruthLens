"""以獨立文件校準高特異性的 AI 判定操作點。

輸入 JSONL 每列至少包含：doc_id、label（human/ai）、score（越高越像 AI）、
split（calibration/test）。可選 domain、language。校準集只負責選門檻；所有發布
數字都由未參與選門檻的 test 文件計算，避免把調參資料當成成績。

範例：
    .venv/bin/python evaluate_operating_point.py \
      --predictions data/held_out_predictions.jsonl \
      --target-fpr 0.01 --report data/operating_point.json \
      --hard-negatives data/hard_negative_humans.jsonl
"""

from __future__ import annotations

import argparse
import json
import math
from collections import defaultdict
from pathlib import Path


def _label(value: object) -> int:
    if value in {"ai", 1, "1"}:
        return 1
    if value in {"human", 0, "0"}:
        return 0
    raise ValueError(f"unknown label: {value!r}")


def load_documents(path: Path) -> list[dict]:
    """Collapse chunks to document means so chunking cannot inflate sample size."""
    groups: dict[str, list[dict]] = defaultdict(list)
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.strip():
            row = json.loads(line)
            groups[str(row["doc_id"])].append(row)

    documents: list[dict] = []
    for doc_id, rows in groups.items():
        labels = {_label(row["label"]) for row in rows}
        splits = {str(row["split"]) for row in rows}
        if len(labels) != 1 or len(splits) != 1:
            raise ValueError(f"{doc_id}: chunks disagree on label or split")
        documents.append(
            {
                "doc_id": doc_id,
                "label": labels.pop(),
                "split": splits.pop(),
                "score": sum(float(row["score"]) for row in rows) / len(rows),
                "domain": str(rows[0].get("domain") or "unknown"),
                "language": str(rows[0].get("language") or "unknown"),
                "source": str(rows[0].get("source") or ""),
            }
        )
    return documents


def select_threshold(rows: list[dict], target_fpr: float) -> float:
    """Return the lowest threshold whose empirical calibration FPR is in budget."""
    human = [float(row["score"]) for row in rows if row["label"] == 0]
    if not human:
        raise ValueError("calibration split has no human documents")
    candidates = sorted(set(human))
    candidates.append(math.nextafter(max(human), math.inf))
    for threshold in candidates:
        fpr = sum(score >= threshold for score in human) / len(human)
        if fpr <= target_fpr:
            return threshold
    raise AssertionError("no threshold satisfies target FPR")


def wilson_upper(errors: int, total: int, z: float = 1.6448536269514722) -> float:
    """One-sided 95% Wilson upper bound for a binomial error rate."""
    if total == 0:
        return 1.0
    proportion = errors / total
    denominator = 1 + z * z / total
    center = proportion + z * z / (2 * total)
    spread = z * math.sqrt(
        proportion * (1 - proportion) / total + z * z / (4 * total * total)
    )
    return (center + spread) / denominator


def evaluate(rows: list[dict], threshold: float) -> dict:
    human = [row for row in rows if row["label"] == 0]
    ai = [row for row in rows if row["label"] == 1]
    if not human or not ai:
        raise ValueError("test split must contain both human and AI documents")
    false_positives = [row for row in human if row["score"] >= threshold]
    true_positives = [row for row in ai if row["score"] >= threshold]
    return {
        "human_documents": len(human),
        "ai_documents": len(ai),
        "false_positives": len(false_positives),
        "true_positives": len(true_positives),
        "fpr": len(false_positives) / len(human),
        "fpr_upper_95": wilson_upper(len(false_positives), len(human)),
        "recall": len(true_positives) / len(ai),
        "false_positive_doc_ids": [row["doc_id"] for row in false_positives],
    }


def grouped_evaluations(rows: list[dict], threshold: float) -> dict[str, dict]:
    output: dict[str, dict] = {}
    for field in ("domain", "language"):
        values = sorted({row[field] for row in rows})
        for value in values:
            group = [row for row in rows if row[field] == value]
            if any(row["label"] == 0 for row in group) and any(
                row["label"] == 1 for row in group
            ):
                output[f"{field}:{value}"] = evaluate(group, threshold)
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description="校準並驗證 AI 判定操作點")
    parser.add_argument("--predictions", type=Path, required=True)
    parser.add_argument("--target-fpr", type=float, default=0.01)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument("--hard-negatives", type=Path)
    args = parser.parse_args()
    if not 0 < args.target_fpr < 1:
        parser.error("--target-fpr must be between 0 and 1")

    documents = load_documents(args.predictions)
    calibration = [row for row in documents if row["split"] == "calibration"]
    test = [row for row in documents if row["split"] == "test"]
    threshold = select_threshold(calibration, args.target_fpr)
    overall = evaluate(test, threshold)
    report = {
        "threshold": threshold,
        "target_fpr": args.target_fpr,
        "test": overall,
        "groups": grouped_evaluations(test, threshold),
        "release_gate_passed": overall["fpr_upper_95"] <= args.target_fpr,
        "release_gate_note": (
            "Only an independent test set supports a confidence claim; accuracy alone does not."
        ),
    }
    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text(
        json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )

    if args.hard_negatives:
        ids = set(overall["false_positive_doc_ids"])
        hard_negatives = [row for row in test if row["doc_id"] in ids]
        args.hard_negatives.parent.mkdir(parents=True, exist_ok=True)
        with args.hard_negatives.open("w", encoding="utf-8") as handle:
            for row in hard_negatives:
                handle.write(json.dumps(row, ensure_ascii=False) + "\n")

    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
