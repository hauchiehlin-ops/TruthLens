import json
import random
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))

import evaluate_zh_adversarial as ev
import prepare_zh_adversarial as prep

ANSWER = (
    "首先，{q}是一個值得探討的問題，涉及多個面向，需要從不同角度進行分析。"
    "值得注意的是，相關研究顯示其影響非常顯著；此外，實務上也有許多案例可以參考。"
    "最後，綜合以上觀點，我們可以得出較為全面的理解，並提出具體建議。"
)
HUMAN = (
    "{q}這個我有經驗，之前遇過一次，後來問了朋友才知道要先處理根本原因，不然很快又會再發生。"
    "另外，我那時候花了不少時間，跑了三家店才找到零件；老闆說這種情況其實很常見。"
    "總之先別急著換新的。"
)


def _hc3_file(directory: Path, questions: int = 40) -> Path:
    path = directory / "all.jsonl"
    with path.open("w", encoding="utf-8") as handle:
        for i in range(questions):
            q = f"問題{i}"
            handle.write(
                json.dumps(
                    {
                        "question": q,
                        "human_answers": [HUMAN.format(q=q)],
                        "chatgpt_answers": [ANSWER.format(q=q)],
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
    return path


class PrepareZhAdversarialTest(unittest.TestCase):
    def test_question_groups_never_cross_splits(self):
        with tempfile.TemporaryDirectory() as tmp:
            rows = prep.load_hc3(_hc3_file(Path(tmp)), min_chars=20)
        splits = prep.split_groups(rows, 0.1, 0.2, seed=1)
        sides = {name: {r["group_id"] for r in side} for name, side in splits.items()}
        self.assertFalse(sides["train"] & sides["dev"])
        self.assertFalse(sides["train"] & sides["test"])
        self.assertFalse(sides["dev"] & sides["test"])
        for side in splits.values():
            self.assertEqual({r["label"] for r in side}, {0, 1})

    def test_laundering_is_applied_equally_to_both_classes(self):
        with tempfile.TemporaryDirectory() as tmp:
            rows = prep.load_hc3(_hc3_file(Path(tmp)), min_chars=20)
        out = prep.augment(rows, random.Random(3), variants=2)
        laundered = [r for r in out if r["family"] == "rule_laundered"]
        ai = sum(1 for r in laundered if r["label"] == 1)
        human = sum(1 for r in laundered if r["label"] == 0)
        # 真人也必須有同樣多的洗滌版本，否則「被洗過」本身就成了 AI 的標記
        self.assertEqual(ai, 80)
        # 洗滌沒改到任何字的版本會被略過，真人文本的可洗目標較少，略少於 AI 屬正常
        self.assertGreaterEqual(human, 60)
        originals = {r["group_id"] for r in rows}
        self.assertTrue({r["group_id"] for r in laundered} <= originals)

    def test_balance_makes_each_family_label_neutral(self):
        rows = (
            [{"label": 0, "family": "original"}] * 30
            + [{"label": 1, "family": "original"}] * 10
            + [{"label": 0, "family": "rule_laundered"}] * 8
            + [{"label": 1, "family": "rule_laundered"}] * 20
            + [{"label": 1, "family": "llm_humanized"}] * 5
        )
        out = prep.balance(rows, random.Random(0), max_per_class=None)
        for family in ("original", "rule_laundered"):
            labels = [r["label"] for r in out if r["family"] == family]
            self.assertEqual(labels.count(0), labels.count(1))
        self.assertEqual(sum(1 for r in out if r["family"] == "llm_humanized"), 5)

    def test_llm_humanized_rows_are_ai_and_keep_group(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "humanized.jsonl"
            path.write_text(
                json.dumps({"text": ANSWER.format(q="x"), "topic_id": "t-1"}, ensure_ascii=False)
                + "\n",
                encoding="utf-8",
            )
            rows = prep.load_llm_humanized(path, min_chars=20)
        self.assertEqual(rows, [
            {"text": ANSWER.format(q="x"), "label": 1, "group_id": "llm-t-1", "family": "llm_humanized"}
        ])

    def test_generator_manifest_reads_files_and_separates_styles(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            (tmp / "a.txt").write_text(ANSWER.format(q="a"), encoding="utf-8")
            (tmp / "b.txt").write_text(ANSWER.format(q="b"), encoding="utf-8")
            manifest = tmp / "manifest.jsonl"
            manifest.write_text(
                "\n".join(
                    json.dumps(r, ensure_ascii=False)
                    for r in [
                        {"file": "a.txt", "style": "humanized", "topic_src": "topic-1"},
                        {"file": "b.txt", "style": "standard", "topic_src": "topic-1"},
                        {"file": "missing.txt", "style": "humanized", "topic_src": "topic-2"},
                    ]
                ),
                encoding="utf-8",
            )
            rows = prep.load_llm_humanized(manifest, min_chars=20)
        self.assertEqual([r["family"] for r in rows], ["llm_humanized", "original"])
        self.assertEqual({r["group_id"] for r in rows}, {"llm-topic-1"})
        self.assertTrue(all(r["label"] == 1 for r in rows))

    def test_corpus_rows_require_group(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "c.jsonl"
            path.write_text(json.dumps({"text": HUMAN.format(q="x"), "label": "human"}, ensure_ascii=False) + "\n", encoding="utf-8")
            with self.assertRaises(ValueError):
                prep.load_corpus(path, min_chars=20)

    def test_cli_writes_balanced_trainer_files(self):
        with tempfile.TemporaryDirectory() as tmp:
            tmp = Path(tmp)
            source = _hc3_file(tmp, questions=60)
            out = tmp / "out"
            extra = tmp / "extra.jsonl"
            extra.write_text(
                json.dumps({"text": HUMAN.format(q="extra"), "label": "human", "group_id": "e1"}, ensure_ascii=False) + "\n",
                encoding="utf-8",
            )
            subprocess.run(
                [sys.executable, "prepare_zh_adversarial.py", "--hc3", str(source),
                 "--corpus", str(extra),
                 "--out-dir", str(out), "--min-chars", "20", "--traditional-share", "0"],
                cwd=ROOT, check=True, capture_output=True,
            )
            train = json.loads((out / "train.json").read_text(encoding="utf-8"))
            for family in ("original", "rule_laundered"):
                labels = [r["label"] for r in train if r["family"] == family]
                self.assertEqual(labels.count(0), labels.count(1))
            test_rows = [json.loads(l) for l in (out / "test.jsonl").read_text(encoding="utf-8").splitlines()]
            self.assertTrue({"doc_id", "group_id", "label", "family", "text"} <= set(test_rows[0]))
            manifest = json.loads((out / "manifest.json").read_text(encoding="utf-8"))
            self.assertIn("ai/rule_laundered", manifest["splits"]["test"])


class EvaluateZhAdversarialTest(unittest.TestCase):
    def test_auroc(self):
        self.assertEqual(ev.auroc([0, 0, 1, 1], [0.1, 0.2, 0.8, 0.9]), 1.0)
        self.assertEqual(ev.auroc([0, 0, 1, 1], [0.9, 0.8, 0.2, 0.1]), 0.0)
        self.assertEqual(ev.auroc([0, 1], [0.5, 0.5]), 0.5)
        self.assertIsNone(ev.auroc([1, 1], [0.2, 0.3]))

    def test_threshold_respects_target_fpr(self):
        humans = [i / 100 for i in range(100)]
        threshold = ev.threshold_at_fpr(humans, 0.05)
        self.assertLessEqual(sum(1 for s in humans if s >= threshold), 5)
        self.assertEqual(sum(1 for s in humans if s >= threshold), 5)

    def test_summary_reports_laundering_gap_and_human_shift(self):
        rows = []
        for i in range(200):
            split = "calibration" if i % 2 == 0 else "test"
            rows += [
                {"label": 0, "family": "original", "score": 0.1, "split": split},
                {"label": 0, "family": "rule_laundered", "score": 0.1, "split": split},
                {"label": 1, "family": "original", "score": 0.9, "split": split},
                # 一半的洗過 AI 被漏掉
                {"label": 1, "family": "rule_laundered", "score": 0.9 if i % 4 < 2 else 0.05, "split": split},
            ]
        summary = ev.summarize(rows, target_fpr=0.01)
        self.assertAlmostEqual(summary["laundering_recall_gap"], 0.5)
        self.assertAlmostEqual(summary["human_laundering_fpr_shift"], 0.0)
        self.assertEqual(summary["families"]["ai/original"]["rate"], 1.0)

    def test_split_is_stable_per_group(self):
        self.assertEqual(ev.split_of("hc3-abc"), ev.split_of("hc3-abc"))
        sides = {ev.split_of(f"g{i}") for i in range(50)}
        self.assertEqual(sides, {"calibration", "test"})


if __name__ == "__main__":
    unittest.main()
