"""以獨立文件校準高特異性的 AI 判定操作點。

輸入 JSONL 每列至少包含：doc_id、label（human/ai/ai_assisted/ai_generated）、score（越高越像 AI）、
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
import hashlib
import json
import math
from collections import defaultdict
from pathlib import Path


def _label(value: object) -> int:
    if value in {"ai", "ai_assisted", "ai_generated", 1, "1"}:
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
        label_classes = {str(row["label"]) for row in rows}
        splits = {str(row["split"]) for row in rows}
        if len(labels) != 1 or len(label_classes) != 1 or len(splits) != 1:
            raise ValueError(
                f"{doc_id}: chunks disagree on label class or split"
            )
        scores = [float(row["score"]) for row in rows]
        if any(not 0 <= score <= 1 for score in scores):
            raise ValueError(f"{doc_id}: scores must be between 0 and 1")
        documents.append(
            {
                "doc_id": doc_id,
                "label": labels.pop(),
                "label_class": next(iter(label_classes)),
                "split": splits.pop(),
                "score": sum(scores) / len(scores),
                "domain": str(rows[0].get("domain") or "unknown"),
                "language": str(rows[0].get("language") or "unknown"),
                "source": str(rows[0].get("source") or ""),
                "provider": str(rows[0].get("provider") or "unknown"),
                "style": str(rows[0].get("style") or "standard"),
                "attack": str(rows[0].get("attack") or "none"),
                "group_id": str(rows[0].get("group_id") or doc_id),
                "text": "\n".join(
                    str(row.get("text") or "") for row in rows if row.get("text")
                ),
            }
        )
    return documents


def assert_split_isolation(documents: list[dict]) -> None:
    """Reject source/prompt families shared by calibration and test."""
    by_group: dict[str, set[str]] = defaultdict(set)
    for row in documents:
        by_group[row["group_id"]].add(row["split"])
    overlap = sorted(
        group_id
        for group_id, splits in by_group.items()
        if "calibration" in splits and "test" in splits
    )
    if overlap:
        raise ValueError(
            "calibration/test group leakage: " + ", ".join(overlap[:5])
        )


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


def grouped_evaluations(
    rows: list[dict], threshold: float, min_group_docs: int
) -> dict[str, dict]:
    output: dict[str, dict] = {}
    for field in ("domain", "language"):
        values = sorted({row[field] for row in rows})
        for value in values:
            group = [row for row in rows if row[field] == value]
            if any(row["label"] == 0 for row in group) and any(
                row["label"] == 1 for row in group
            ):
                result = evaluate(group, threshold)
                result["eligible_for_release_gate"] = (
                    result["human_documents"] >= min_group_docs
                    and result["ai_documents"] >= min_group_docs
                )
                output[f"{field}:{value}"] = result
    return output


def robustness_evaluations(
    rows: list[dict], threshold: float, min_group_docs: int
) -> dict[str, dict]:
    """AI-only strata measure detector drift; FPR is governed by human strata."""
    output: dict[str, dict] = {}
    ai_rows = [row for row in rows if row["label"] == 1]
    for field in ("provider", "style", "attack", "label_class"):
        for value in sorted({row[field] for row in ai_rows}):
            group = [row for row in ai_rows if row[field] == value]
            detected = sum(float(row["score"]) >= threshold for row in group)
            output[f"{field}:{value}"] = {
                "ai_documents": len(group),
                "true_positives": detected,
                "recall": detected / len(group),
                "eligible_for_release_gate": len(group) >= min_group_docs,
            }
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description="校準並驗證 AI 判定操作點")
    parser.add_argument("--predictions", type=Path, required=True)
    parser.add_argument("--target-fpr", type=float, default=0.01)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument("--hard-negatives", type=Path)
    parser.add_argument(
        "--hard-positives",
        type=Path,
        help="輸出漏判的 AI 文件，供下一輪對抗訓練",
    )
    parser.add_argument("--min-group-docs", type=int, default=30)
    parser.add_argument("--min-recall", type=float, default=0.50)
    parser.add_argument("--required-language", action="append", default=[])
    parser.add_argument("--required-domain", action="append", default=[])
    parser.add_argument("--contract-id", default="truthlens-external-v1")
    parser.add_argument("--benchmark-id", action="append", default=[])
    parser.add_argument("--detector-signature", default="")
    parser.add_argument(
        "--independent-test",
        action="store_true",
        help="Assert that the reporting split is external to model training.",
    )
    args = parser.parse_args()
    if not 0 < args.target_fpr < 1:
        parser.error("--target-fpr must be between 0 and 1")
    if not 0 <= args.min_recall <= 1:
        parser.error("--min-recall must be between 0 and 1")

    documents = load_documents(args.predictions)
    assert_split_isolation(documents)
    calibration = [row for row in documents if row["split"] == "calibration"]
    test = [row for row in documents if row["split"] == "test"]
    calibration_humans = sum(row["label"] == 0 for row in calibration)
    minimum_calibration_humans = math.ceil(1 / args.target_fpr)
    if calibration_humans < minimum_calibration_humans:
        raise ValueError(
            f"target FPR {args.target_fpr:.2%} requires at least "
            f"{minimum_calibration_humans} independent calibration human documents; "
            f"got {calibration_humans}"
        )
    threshold = select_threshold(calibration, args.target_fpr)
    overall = evaluate(test, threshold)
    fairness_groups = grouped_evaluations(test, threshold, args.min_group_docs)
    robustness_groups = robustness_evaluations(
        test, threshold, args.min_group_docs
    )
    fairness_gate = all(
        (not result["eligible_for_release_gate"])
        or (
            result["fpr_upper_95"] <= args.target_fpr
            and result["recall"] >= args.min_recall
        )
        for result in fairness_groups.values()
    )
    robustness_gate = all(
        (not result["eligible_for_release_gate"])
        or result["recall"] >= args.min_recall
        for result in robustness_groups.values()
    )
    required_fairness_groups = {
        *(f"language:{value}" for value in args.required_language),
        *(f"domain:{value}" for value in args.required_domain),
    }
    missing_required_groups = sorted(
        key
        for key in required_fairness_groups
        if key not in fairness_groups
        or not fairness_groups[key]["eligible_for_release_gate"]
    )
    coverage_gate = not missing_required_groups
    evidence_identity_gate = bool(
        args.independent_test and args.benchmark_id and args.detector_signature
    )
    report = {
        "schema_version": 1,
        "contract_id": args.contract_id,
        "status": "validated" if evidence_identity_gate else "not_yet_externally_validated",
        "detector_signature": args.detector_signature or None,
        "benchmark_ids": args.benchmark_id,
        "predictions_sha256": hashlib.sha256(
            args.predictions.read_bytes()
        ).hexdigest(),
        "independent_test_asserted": args.independent_test,
        "threshold": threshold,
        "target_fpr": args.target_fpr,
        "test": overall,
        "minimum_recall": args.min_recall,
        "minimum_group_documents": args.min_group_docs,
        "fairness_groups": fairness_groups,
        "robustness_groups": robustness_groups,
        "required_fairness_groups": sorted(required_fairness_groups),
        "missing_required_groups": missing_required_groups,
        "release_gate_passed": (
            overall["fpr_upper_95"] <= args.target_fpr
            and overall["recall"] >= args.min_recall
            and fairness_gate
            and robustness_gate
            and coverage_gate
            and evidence_identity_gate
        ),
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

    if args.hard_positives:
        missed = [
            row
            for row in test
            if row["label"] == 1 and float(row["score"]) < threshold
        ]
        args.hard_positives.parent.mkdir(parents=True, exist_ok=True)
        with args.hard_positives.open("w", encoding="utf-8") as handle:
            for row in missed:
                handle.write(json.dumps(row, ensure_ascii=False) + "\n")

    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
