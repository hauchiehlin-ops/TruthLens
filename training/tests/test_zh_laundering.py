import random
import statistics
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

import zh_laundering as z

TEXT = (
    "首先，本研究以消費者異質性感知為核心，探討擴增實境在數位行銷中的應用效果，並進行跨類別的比較分析。"
    "值得注意的是，過去文獻多聚焦於單一產品類別。此外，沉浸式購物體驗對購買意圖的影響機制仍有待釐清；"
    "其影響非常顯著。最後，研究結果將有助於企業制定更精準的數位行銷策略、提升消費者滿意度以及品牌忠誠度。"
    "\n\n綜上所述，本計畫旨在透過混合研究方法，結合問卷調查與實驗設計。一是建立理論框架，二是驗證模型，"
    "三是提出實務建議。"
)


class _NeverKeep(random.Random):
    """random() 永遠回傳 0.99：所有「保留」機率都不觸發，結果可預期"""

    def random(self):
        return 0.99


class ZhLaunderingTest(unittest.TestCase):
    def test_stock_transitions_removed_only_when_followed_by_punctuation(self):
        out = z.strip_stock_transitions(
            "第一段結束。\n\n綜上所述，本計畫很好。此外，還有一點。因此我們出發。",
            _NeverKeep(),
        )
        self.assertEqual(out, "第一段結束。\n\n本計畫很好。還有一點。因此我們出發。")

    def test_parallel_ordinals_removed(self):
        out = z.break_parallelism("一是建立框架，二是驗證模型，三是提出建議。", random.Random(0))
        self.assertNotIn("一是", out)
        self.assertNotIn("三是", out)
        self.assertIn("建立框架", out)

    def test_rhythm_raises_sentence_length_variance(self):
        cvs = [
            z.burstiness_cv(z.vary_sentence_rhythm(TEXT, random.Random(seed)))
            for seed in range(40)
        ]
        self.assertGreater(statistics.fmean(cvs), z.burstiness_cv(TEXT) + 0.2)
        # 洗滌工具宣稱的目標
        self.assertGreater(statistics.fmean(cvs), 0.6)

    def test_rhythm_keeps_paragraphs_and_content(self):
        out = z.vary_sentence_rhythm(TEXT, random.Random(1))
        self.assertEqual(out.count("\n\n"), TEXT.count("\n\n"))
        # 只動標點：去掉標點與空白後的文字完全相同
        strip = lambda s: "".join(ch for ch in s if ch not in "，,。；;！？!? \n")
        self.assertEqual(strip(out), strip(TEXT))

    def test_launder_is_deterministic_and_changes_text(self):
        a = z.launder(TEXT, random.Random(42))
        b = z.launder(TEXT, random.Random(42))
        self.assertEqual(a, b)
        text, ops = a
        self.assertNotEqual(text, TEXT)
        self.assertEqual(ops[0], "strip_transitions")
        self.assertTrue(2 <= len(ops) <= 4)
        self.assertTrue(set(ops) <= set(z.TRANSFORMS))

    def test_launder_never_returns_empty_text(self):
        for seed in range(30):
            text, _ = z.launder(TEXT, random.Random(seed))
            self.assertGreater(len(text), len(TEXT) * 0.7)


if __name__ == "__main__":
    unittest.main()
