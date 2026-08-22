from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from evaluate_operating_point import (
    assert_split_isolation,
    grouped_evaluations,
    load_documents,
    robustness_evaluations,
    select_threshold,
    wilson_upper,
)


class OperatingPointTest(unittest.TestCase):
    def test_chunks_collapse_and_preserve_training_text(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "predictions.jsonl"
            rows = [
                {
                    "doc_id": "h1",
                    "label": "human",
                    "score": 0.1,
                    "split": "test",
                    "text": "first",
                },
                {
                    "doc_id": "h1",
                    "label": "human",
                    "score": 0.3,
                    "split": "test",
                    "text": "second",
                },
            ]
            path.write_text(
                "\n".join(json.dumps(row) for row in rows), encoding="utf-8"
            )

            documents = load_documents(path)
            self.assertEqual(len(documents), 1)
            self.assertAlmostEqual(documents[0]["score"], 0.2)
            self.assertEqual(documents[0]["text"], "first\nsecond")

    def test_ai_subclasses_are_in_robustness_report(self) -> None:
        rows = [
            {
                "label": 1,
                "label_class": "ai_assisted",
                "provider": "modern-model",
                "style": "humanized",
                "attack": "paraphrase",
                "score": 0.8,
            },
            {
                "label": 1,
                "label_class": "ai_generated",
                "provider": "modern-model",
                "style": "standard",
                "attack": "none",
                "score": 0.2,
            },
        ]

        groups = robustness_evaluations(rows, 0.6, min_group_docs=1)
        self.assertEqual(groups["label_class:ai_assisted"]["recall"], 1.0)
        self.assertEqual(groups["label_class:ai_generated"]["recall"], 0.0)

    def test_prompt_group_cannot_cross_calibration_and_test(self) -> None:
        rows = [
            {"group_id": "same-topic", "split": "calibration"},
            {"group_id": "same-topic", "split": "test"},
        ]

        with self.assertRaisesRegex(ValueError, "group leakage"):
            assert_split_isolation(rows)

    def test_chunk_authorship_classes_must_agree(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "predictions.jsonl"
            rows = [
                {
                    "doc_id": "a1",
                    "label": "ai_assisted",
                    "score": 0.8,
                    "split": "test",
                },
                {
                    "doc_id": "a1",
                    "label": "ai_generated",
                    "score": 0.9,
                    "split": "test",
                },
            ]
            path.write_text(
                "\n".join(json.dumps(row) for row in rows), encoding="utf-8"
            )

            with self.assertRaisesRegex(ValueError, "label class"):
                load_documents(path)

    def test_fairness_groups_are_gated_only_with_enough_documents(self) -> None:
        rows = [
            {
                "label": label,
                "score": score,
                "domain": "academic",
                "language": "en",
            }
            for label, score in [(0, 0.1), (0, 0.2), (1, 0.8), (1, 0.9)]
        ]
        groups = grouped_evaluations(rows, 0.6, min_group_docs=3)
        self.assertFalse(groups["domain:academic"]["eligible_for_release_gate"])

    def test_threshold_respects_calibration_false_positive_budget(self) -> None:
        rows = [
            {"label": 0, "score": i / 100} for i in range(100)
        ]
        threshold = select_threshold(rows, 0.01)
        fpr = sum(row["score"] >= threshold for row in rows) / len(rows)
        self.assertLessEqual(fpr, 0.01)

    def test_wilson_upper_is_conservative(self) -> None:
        self.assertGreater(wilson_upper(0, 100), 0)
        self.assertGreater(wilson_upper(1, 100), 0.01)


if __name__ == "__main__":
    unittest.main()
