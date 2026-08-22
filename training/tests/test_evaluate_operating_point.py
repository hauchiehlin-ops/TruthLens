import json
import tempfile
import unittest
from pathlib import Path

import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from evaluate_operating_point import evaluate, load_documents, select_threshold, wilson_upper


class OperatingPointTest(unittest.TestCase):
    def test_chunks_are_collapsed_to_independent_documents(self):
        rows = [
            {"doc_id": "h1", "label": "human", "split": "test", "score": 0.2},
            {"doc_id": "h1", "label": "human", "split": "test", "score": 0.4},
            {"doc_id": "a1", "label": "ai", "split": "test", "score": 0.9},
        ]
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "scores.jsonl"
            path.write_text("\n".join(json.dumps(row) for row in rows), encoding="utf-8")
            documents = load_documents(path)

        self.assertEqual(len(documents), 2)
        human = next(row for row in documents if row["doc_id"] == "h1")
        self.assertAlmostEqual(human["score"], 0.3)

    def test_threshold_respects_fixed_false_positive_budget(self):
        rows = [
            {"label": 0, "score": score / 100}
            for score in range(100)
        ]
        threshold = select_threshold(rows, 0.01)
        empirical_fpr = sum(row["score"] >= threshold for row in rows) / 100
        self.assertLessEqual(empirical_fpr, 0.01)

    def test_evaluation_reports_recall_and_false_positive_bound(self):
        rows = [
            *({"doc_id": f"h{i}", "label": 0, "score": 0.1} for i in range(300)),
            *({"doc_id": f"a{i}", "label": 1, "score": score} for i, score in enumerate([0.9, 0.8, 0.2])),
        ]
        result = evaluate(rows, 0.7)

        self.assertEqual(result["false_positives"], 0)
        self.assertAlmostEqual(result["recall"], 2 / 3)
        self.assertLess(wilson_upper(0, 300), 0.01)


if __name__ == "__main__":
    unittest.main()
