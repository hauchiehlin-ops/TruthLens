import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from build_proposal_register import chunk_sentences, prose_sentences, split_groups


class ProposalRegisterTest(unittest.TestCase):
    def test_prose_sentences_drop_headings_tables_and_bibliography(self):
        text = (
            "# 第一章 研究背景\n"
            "關鍵詞：數位行銷、生成式人工智慧\n"
            "當前數位行銷領域正處於技術驅動的關鍵交匯點。本研究以兩年為期提出方案。\n"
            "| 階段 | 期間 | 工作 |\n"
            "第一年上半 1–6 月 文獻回顧\n"
            "參考文獻\n"
            "Kumar, V. (2016). Creating enduring customer value. Journal of Marketing.\n"
        )
        self.assertEqual(
            prose_sentences(text),
            ["當前數位行銷領域正處於技術驅動的關鍵交匯點。", "本研究以兩年為期提出方案。"],
        )

    def test_chunks_respect_size_and_minimum(self):
        sentences = ["甲" * 60 + "。", "乙" * 60 + "。", "丙" * 60 + "。", "短。"]
        chunks = chunk_sentences(sentences, chunk_chars=130, min_chars=10)
        self.assertTrue(all(len(c) <= 130 for c in chunks))
        self.assertTrue(chunks[0].startswith("甲"))

    def test_split_keeps_groups_isolated_and_both_labels_in_test(self):
        rows = [
            {"label": label, "group_id": f"{label}:{g}", "text": f"{g}-{i}"}
            for label in (0, 1)
            for g in range(10)
            for i in range(3)
        ]
        splits = split_groups(rows, test_ratio=0.3, dev_ratio=0.1, seed=1)
        seen = {}
        for name, data in splits.items():
            for row in data:
                self.assertEqual(seen.setdefault(row["group_id"], name), name)
        self.assertEqual({r["label"] for r in splits["test"]}, {0, 1})


if __name__ == "__main__":
    unittest.main()
