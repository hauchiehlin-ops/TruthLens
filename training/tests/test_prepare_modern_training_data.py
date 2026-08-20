import tempfile
import unittest
from pathlib import Path

import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from prepare_modern_training_data import assert_no_leakage, balance, grouped_split


class ModernTrainingDataTest(unittest.TestCase):
    def rows(self):
        rows = []
        for label in (0, 1):
            for group in range(8):
                for variant in range(3):
                    rows.append(
                        {
                            "text": f"sample {label}-{group}-{variant}",
                            "label": label,
                            "group_id": f"{label}-{group}",
                        }
                    )
        return rows

    def test_group_never_crosses_train_and_validation(self):
        train, val = grouped_split(self.rows(), 0.25, 42)
        assert_no_leakage(train, val)
        self.assertTrue(train)
        self.assertTrue(val)

    def test_balance_keeps_equal_classes(self):
        rows = self.rows() + [
            {"text": "extra", "label": 1, "group_id": "ai-extra"}
            for _ in range(10)
        ]
        balanced = balance(rows, 42, None)
        self.assertEqual(
            sum(row["label"] == 0 for row in balanced),
            sum(row["label"] == 1 for row in balanced),
        )


if __name__ == "__main__":
    unittest.main()
