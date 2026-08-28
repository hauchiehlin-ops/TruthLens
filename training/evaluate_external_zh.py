"""Score an external Chinese corpus with the SHIPPED detector asset.

Why this exists: `export_detectrl_zh_char_svm.py` reports numbers on the corpus
it was trained from.  Those numbers say nothing about an unseen corpus, an
unseen generator, or an unseen domain — and `benchmark_contract.json` requires
exactly that before any population-level claim may be made.  This script takes
the asset the app actually ships and replays it, unchanged, at its shipped
operating point.

The scoring here mirrors `lib/core/detection/detectrl_zh_char_scorer.dart`
line for line (same normalisation, n-gram range, sublinear tf-idf, L2 norm and
decision cut).  Agreement was cross-checked document by document against the
Dart implementation; do not "improve" one side without re-checking the other.

Example:
  .venv/bin/python evaluate_external_zh.py \
    --corpus data/semeval2024/semeval_zh.json \
    --corpus-id semeval-2024-task8-zh
"""

from __future__ import annotations

import argparse
import json
import math
import re
from collections import defaultdict
from pathlib import Path

ASSET = Path(__file__).resolve().parent.parent / "assets/models/detectrl_zh_char_svm.json"


class ShippedScorer:
    def __init__(self, asset: Path):
        payload = json.loads(asset.read_text(encoding="utf-8"))
        self.terms = {term: i for i, term in enumerate(payload["terms"])}
        self.idf = payload["idf"]
        self.coefficients = payload["coefficients"]
        self.minimum_characters = payload["minimum_characters"]
        self.intercept = payload["intercept"]
        self.cut = payload["ai_decision_cut"]

    def decision(self, raw: str) -> float | None:
        """None means the scorer stays silent — too short, or no known n-gram."""
        normalised = re.sub(r"\s+", " ", raw.lower()).strip()
        characters = list(normalised)
        if len(characters) < self.minimum_characters:
            return None
        counts: dict[int, float] = defaultdict(float)
        for n in range(2, 6):
            for start in range(len(characters) - n + 1):
                index = self.terms.get("".join(characters[start : start + n]))
                if index is not None:
                    counts[index] += 1
        if not counts:
            return None
        squared_norm = 0.0
        for index, count in list(counts.items()):
            value = (1 + math.log(count)) * self.idf[index]
            counts[index] = value
            squared_norm += value * value
        if squared_norm <= 0:
            return None
        norm = math.sqrt(squared_norm)
        return self.intercept + sum(
            value / norm * self.coefficients[index] for index, value in counts.items()
        )


def wilson_upper(successes: int, total: int, z: float = 1.6449) -> float:
    """One-sided 95% upper bound, as the contract's fpr_confidence_bound requires."""
    if total == 0:
        return 1.0
    p = successes / total
    denominator = 1 + z * z / total
    centre = p + z * z / (2 * total)
    half = z * math.sqrt(p * (1 - p) / total + z * z / (4 * total * total))
    return (centre + half) / denominator


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--corpus", type=Path, required=True)
    parser.add_argument("--corpus-id", required=True)
    parser.add_argument("--asset", type=Path, default=ASSET)
    parser.add_argument("--json-out", type=Path)
    args = parser.parse_args()

    scorer = ShippedScorer(args.asset)
    rows = json.loads(args.corpus.read_text(encoding="utf-8"))

    scored = []
    silent = 0
    for row in rows:
        decision = scorer.decision(row["text"])
        if decision is None:
            silent += 1
            continue
        scored.append((decision, int(row["label"]), row.get("model")))

    human = [d for d, label, _ in scored if label == 0]
    machine = [d for d, label, _ in scored if label == 1]
    false_positives = sum(1 for d in human if d >= scorer.cut)
    true_positives = sum(1 for d in machine if d >= scorer.cut)
    fpr = false_positives / len(human) if human else 0.0
    fpr_upper = wilson_upper(false_positives, len(human))
    recall = true_positives / len(machine) if machine else 0.0

    per_generator = {}
    for name in sorted({m for _, _, m in scored if m}):
        subset = [(d, label) for d, label, m in scored if m == name]
        per_generator[name] = {
            "n": len(subset),
            "label": subset[0][1],
            "above_cut_rate": sum(1 for d, _ in subset if d >= scorer.cut) / len(subset),
        }

    report = {
        "corpus_id": args.corpus_id,
        "documents_scored": len(scored),
        "documents_below_length_floor": silent,
        "operating_point": scorer.cut,
        "human_documents": len(human),
        "machine_documents": len(machine),
        "fpr": fpr,
        "fpr_upper_95": fpr_upper,
        "recall": recall,
        "per_generator": per_generator,
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if args.json_out:
        args.json_out.write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )


if __name__ == "__main__":
    main()
