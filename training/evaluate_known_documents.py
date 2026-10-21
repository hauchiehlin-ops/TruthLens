"""以已知來源的整份文件（.docx／.txt／.md）回歸測試出貨的 Transformer 偵測器。

為什麼另寫一支
--------------
既有的 evaluate_external_zh_transformer.py 吃的是整理好的公開語料（短文、
單一語域）。實際漏判的卻是另一種東西：例如 Claude Docs 產生、2.5 萬字、夾雜
英文引文與表格的繁中研究計畫書——分類器在句、段、450 字窗口三種粒度都只給
約 4%，四個引擎全部沉默。這類文件必須能直接丟進資料夾、重跑、看召回有沒有
改善，否則下一版模型無從證明補上了這個缺口。

推論契約與 App 相同（見 `lib/core/detection/onnx_detector_io.dart` 與
`lib/core/utils/text_stats.dart`）：逐句輸入（maxAnalysisChunkSentences = 1）、
WordPiece 截斷 192 token、只送 input_ids + attention_mask、softmax 取
`ai_label_index`。引擎「有證據」＝至少一句跨過 catalog 的 `ai_evidence_threshold`；
低於門檻不反向投真人票。

輸出的逐句 JSONL 可直接餵給 evaluate_operating_point.py（doc_id、label、score、
split、domain、language）。只寫分數與檔名，不寫原文，避免把使用者文件帶進 repo。

用法
----
    .venv/bin/python evaluate_known_documents.py \\
        --ai-dir /path/to/known_ai_docs \\
        --human-dir /path/to/known_human_docs \\
        --model artifacts/zh/truthlens_zh_detector_int8.onnx \\
        --tokenizer artifacts/zh/truthlens_zh_detector_tokenizer.json \\
        --threshold 0.98 --domain academic_zh \\
        --predictions-out data/known_doc_predictions.jsonl \\
        --json-out validation/known_documents.json
"""

from __future__ import annotations

import argparse
import html
import json
import re
import zipfile
from pathlib import Path

SUPPORTED_SUFFIXES = {".docx", ".txt", ".md"}

# 與 App 的 isAnalyzableSentence 同向：太短的標題、頁碼、序號不送模型
MIN_SENTENCE_CHARS = 8

_SENTENCE_END = re.compile(r"(?<=[。！？；!?;])\s*|\n+")


def docx_paragraphs(path: Path) -> list[str]:
    """從 word/document.xml 取出段落文字；不依賴 python-docx。"""
    with zipfile.ZipFile(path) as archive:
        xml = archive.read("word/document.xml").decode("utf-8", errors="replace")
    paragraphs = []
    for block in re.findall(r"<w:p[ >].*?</w:p>", xml, flags=re.S):
        text = html.unescape(re.sub(r"<[^>]+>", "", block)).strip()
        if text:
            paragraphs.append(text)
    return paragraphs


def document_text(path: Path) -> str:
    if path.suffix.lower() == ".docx":
        return "\n".join(docx_paragraphs(path))
    return path.read_text(encoding="utf-8", errors="replace")


def split_sentences(text: str) -> list[str]:
    sentences = []
    for piece in _SENTENCE_END.split(text):
        piece = piece.strip()
        if len(piece) >= MIN_SENTENCE_CHARS:
            sentences.append(piece)
    return sentences


def iter_documents(folder: Path | None, label: str):
    if folder is None:
        return
    for path in sorted(folder.rglob("*")):
        if path.name.startswith("._") or path.suffix.lower() not in SUPPORTED_SUFFIXES:
            continue
        yield path, label


class Detector:
    def __init__(self, model: Path, tokenizer: Path, max_len: int, ai_index: int):
        import numpy as np
        import onnxruntime as ort
        from tokenizers import Tokenizer

        self._np = np
        self.session = ort.InferenceSession(str(model))
        self.tokenizer = Tokenizer.from_file(str(tokenizer))
        self.tokenizer.enable_truncation(max_len)
        self.ai_index = ai_index

    def score(self, text: str) -> float:
        np = self._np
        ids = np.array([self.tokenizer.encode(text).ids], dtype=np.int64)
        logits = self.session.run(
            None, {"input_ids": ids, "attention_mask": np.ones_like(ids)}
        )[0][0]
        probs = np.exp(logits - logits.max())
        probs /= probs.sum()
        return float(probs[self.ai_index])


def summarize_document(scores: list[float], threshold: float) -> dict:
    if not scores:
        return {"sentences": 0, "has_evidence": False}
    ordered = sorted(scores)
    strong = sum(score >= threshold for score in scores)
    return {
        "sentences": len(scores),
        "mean": round(sum(scores) / len(scores), 4),
        "median": round(ordered[len(ordered) // 2], 4),
        "max": round(ordered[-1], 4),
        "strong_ratio": round(strong / len(scores), 4),
        "has_evidence": strong > 0,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    parser.add_argument("--ai-dir", type=Path)
    parser.add_argument("--human-dir", type=Path)
    parser.add_argument("--model", type=Path, required=True)
    parser.add_argument("--tokenizer", type=Path, required=True)
    parser.add_argument("--threshold", type=float, default=0.98)
    parser.add_argument("--max-len", type=int, default=192)
    parser.add_argument("--ai-label-index", type=int, default=1)
    parser.add_argument("--split", default="test", choices=["calibration", "test"])
    parser.add_argument("--domain", default="unknown")
    parser.add_argument("--language", default="zh")
    parser.add_argument("--predictions-out", type=Path)
    parser.add_argument("--json-out", type=Path)
    args = parser.parse_args()
    if not args.ai_dir and not args.human_dir:
        parser.error("至少指定 --ai-dir 或 --human-dir")

    detector = Detector(args.model, args.tokenizer, args.max_len, args.ai_label_index)
    documents = []
    rows = []
    for path, label in [
        *iter_documents(args.ai_dir, "ai"),
        *iter_documents(args.human_dir, "human"),
    ]:
        sentences = split_sentences(document_text(path))
        scores = [detector.score(sentence) for sentence in sentences]
        summary = {"file": path.name, "label": label, **summarize_document(scores, args.threshold)}
        documents.append(summary)
        print(json.dumps(summary, ensure_ascii=False))
        rows.extend(
            {
                "doc_id": path.name,
                "label": label,
                "score": round(score, 6),
                "split": args.split,
                "domain": args.domain,
                "language": args.language,
            }
            for score in scores
        )

    ai_docs = [d for d in documents if d["label"] == "ai"]
    human_docs = [d for d in documents if d["label"] == "human"]
    report = {
        "model": args.model.name,
        "threshold": args.threshold,
        "contract": "per-sentence, max_len=192, evidence = any sentence >= threshold",
        "ai_documents": len(ai_docs),
        "human_documents": len(human_docs),
        "document_recall": (
            sum(d["has_evidence"] for d in ai_docs) / len(ai_docs) if ai_docs else None
        ),
        "document_fpr": (
            sum(d["has_evidence"] for d in human_docs) / len(human_docs)
            if human_docs
            else None
        ),
        "documents": documents,
    }
    print(json.dumps({k: v for k, v in report.items() if k != "documents"}, ensure_ascii=False))

    if args.predictions_out:
        args.predictions_out.parent.mkdir(parents=True, exist_ok=True)
        args.predictions_out.write_text(
            "".join(json.dumps(row, ensure_ascii=False) + "\n" for row in rows),
            encoding="utf-8",
        )
    if args.json_out:
        args.json_out.parent.mkdir(parents=True, exist_ok=True)
        args.json_out.write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )


if __name__ == "__main__":
    main()
