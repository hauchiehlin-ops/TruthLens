from __future__ import annotations

import json
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from prepare_modern_training_data import (
    assert_no_leakage,
    grouped_split,
    load_rows,
)


class PrepareModernTrainingDataTest(unittest.TestCase):
    def test_three_authorship_classes_are_preserved(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "corpus.jsonl"
            rows = [
                {"id": "h", "label": "human", "text": "human"},
                {"id": "a", "label": "ai_generated", "text": "ai"},
                {"id": "m", "label": "ai_assisted", "text": "mixed"},
            ]
            path.write_text(
                "\n".join(json.dumps(row) for row in rows), encoding="utf-8"
            )

            loaded = load_rows([path])
            self.assertEqual(
                {row["authorship_class"] for row in loaded},
                {"human", "ai_generated", "ai_assisted"},
            )

    def test_prompt_group_never_crosses_train_and_validation(self) -> None:
        rows = []
        for group in range(10):
            for label in (0, 1):
                rows.append(
                    {
                        "label": label,
                        "group_id": f"topic-{group}",
                        "text": f"sample-{group}-{label}",
                    }
                )

        train, validation = grouped_split(rows, val_ratio=0.2, seed=7)
        assert_no_leakage(train, validation)
        self.assertTrue(train)
        self.assertTrue(validation)


if __name__ == "__main__":
    unittest.main()
