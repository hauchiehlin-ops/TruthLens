import tempfile
import unittest
import zipfile
from pathlib import Path

import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from evaluate_known_documents import (
    docx_paragraphs,
    iter_documents,
    split_sentences,
    summarize_document,
)


class KnownDocumentsTest(unittest.TestCase):
    def test_docx_paragraphs_unescape_and_skip_empty(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "a.docx"
            with zipfile.ZipFile(path, "w") as archive:
                archive.writestr(
                    "word/document.xml",
                    "<w:document><w:body>"
                    "<w:p><w:r><w:t>Wedel &amp; Kannan</w:t></w:r></w:p>"
                    "<w:p></w:p>"
                    '<w:p w:rsidR="00A1"><w:t>第二段</w:t></w:p>'
                    "</w:body></w:document>",
                )
            self.assertEqual(docx_paragraphs(path), ["Wedel & Kannan", "第二段"])

    def test_split_sentences_drops_short_fragments(self):
        text = "本計畫為期兩年，發展一套研究方法論。表 1\n研究不預設要比較哪些消費者族群！"
        self.assertEqual(
            split_sentences(text),
            ["本計畫為期兩年，發展一套研究方法論。", "研究不預設要比較哪些消費者族群！"],
        )

    def test_evidence_requires_one_sentence_over_threshold(self):
        silent = summarize_document([0.05, 0.15, 0.04], threshold=0.98)
        self.assertFalse(silent["has_evidence"])
        self.assertEqual(silent["max"], 0.15)
        flagged = summarize_document([0.05, 0.99], threshold=0.98)
        self.assertTrue(flagged["has_evidence"])
        self.assertEqual(flagged["strong_ratio"], 0.5)

    def test_iter_documents_skips_appledouble(self):
        with tempfile.TemporaryDirectory() as tmp:
            folder = Path(tmp)
            (folder / "a.txt").write_text("x", encoding="utf-8")
            (folder / "._a.txt").write_text("x", encoding="utf-8")
            (folder / "b.pdf").write_text("x", encoding="utf-8")
            self.assertEqual(
                [p.name for p, _ in iter_documents(folder, "ai")], ["a.txt"]
            )


if __name__ == "__main__":
    unittest.main()
