"""階段一步驟 1：把資料夾裡的文件轉成評測用的 JSONL 語料。

用途
----
Binoculars 離線驗證需要兩類樣本：
  * human — 確定由人撰寫的文章（本專案的重點是**非母語英文寫作**）
  * ai    — 確定由 AI 產出的文章

本腳本只負責「抽文字 + 打標籤 + 切塊」，不做任何評分。

用法
----
    .venv/bin/python binoculars/prepare_corpus.py \
        --human-dir "/path/to/student_essays" \
        --ai-dir    "/path/to/ai_generated" \
        --out       binoculars/data/corpus.jsonl

只有其中一類也可以先跑（另一類之後再補）：

    .venv/bin/python binoculars/prepare_corpus.py \
        --human-dir "/path/to/student_essays" --out binoculars/data/corpus.jsonl

支援 .pdf / .txt / .md / .docx。長文會依 --chunk-words 切成多個樣本，
但**同一份原始文件的所有切塊會共用同一個 doc_id**，評測時才能避免把
同一份文件同時放進校準集與測試集而高估效果。
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import sys
import zipfile
from pathlib import Path

SUPPORTED = {".pdf", ".txt", ".md", ".docx"}


def extract_pdf(path: Path) -> str:
    try:
        from pypdf import PdfReader
    except ImportError:  # pragma: no cover - 缺套件時給明確指示
        sys.exit("需要 pypdf：.venv/bin/pip install pypdf")
    reader = PdfReader(str(path))
    return "\n".join((page.extract_text() or "") for page in reader.pages)


def extract_docx(path: Path) -> str:
    with zipfile.ZipFile(path) as zf:
        xml = zf.read("word/document.xml").decode("utf-8", errors="replace")
    parts = re.findall(r"<w:t[^>]*>(.*?)</w:t>", xml, flags=re.S)
    text = "".join(parts)
    for a, b in [("&amp;", "&"), ("&lt;", "<"), ("&gt;", ">"), ("&quot;", '"')]:
        text = text.replace(a, b)
    return text


def extract(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix == ".pdf":
        return extract_pdf(path)
    if suffix == ".docx":
        return extract_docx(path)
    return path.read_text(encoding="utf-8", errors="replace")


def clean(text: str) -> str:
    """移除 PDF 抽取常見的雜訊：連字換行、頁碼行、過多空白。"""
    text = text.replace("\r", "\n")
    # 跨行連字：analy-\nsis -> analysis
    text = re.sub(r"(\w)-\n(\w)", r"\1\2", text)
    # 單獨成行的頁碼
    text = re.sub(r"\n\s*\d{1,4}\s*\n", "\n", text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def chunk_words(text: str, size: int, min_size: int) -> list[str]:
    """依詞數切塊。太短的尾段直接丟棄，避免混入不具代表性的殘片。"""
    words = text.split()
    out = []
    for i in range(0, len(words), size):
        piece = words[i : i + size]
        if len(piece) >= min_size:
            out.append(" ".join(piece))
    return out


def collect(directory: Path, label: str, args) -> list[dict]:
    if not directory.exists():
        sys.exit(f"找不到目錄：{directory}")

    files = sorted(
        p for p in directory.rglob("*") if p.suffix.lower() in SUPPORTED and p.is_file()
    )
    if not files:
        sys.exit(f"{directory} 底下沒有支援的檔案（{'/'.join(sorted(SUPPORTED))}）")

    samples: list[dict] = []
    skipped: list[str] = []
    for path in files:
        try:
            text = clean(extract(path))
        except Exception as exc:  # noqa: BLE001 - 單檔失敗不該中斷整批
            skipped.append(f"{path.name}（讀取失敗：{exc}）")
            continue

        chunks = chunk_words(text, args.chunk_words, args.min_words)
        if not chunks:
            skipped.append(f"{path.name}（可用內容不足 {args.min_words} 詞）")
            continue

        doc_id = hashlib.sha1(str(path).encode()).hexdigest()[:12]
        for index, chunk in enumerate(chunks):
            samples.append(
                {
                    "id": f"{doc_id}_{index}",
                    "doc_id": doc_id,
                    "label": label,
                    "source": path.name,
                    "words": len(chunk.split()),
                    "text": chunk,
                }
            )

    print(f"[{label}] 檔案 {len(files)} 份 → 樣本 {len(samples)} 塊")
    for note in skipped:
        print(f"  略過 {note}")
    return samples


def main() -> None:
    parser = argparse.ArgumentParser(description="Binoculars 階段一：語料準備")
    parser.add_argument("--human-dir", type=Path, help="已知由人撰寫的文件資料夾")
    parser.add_argument("--ai-dir", type=Path, help="已知由 AI 產出的文件資料夾")
    parser.add_argument(
        "--out", type=Path, default=Path("binoculars/data/corpus.jsonl")
    )
    parser.add_argument(
        "--chunk-words",
        type=int,
        default=400,
        help="每個樣本的目標詞數（預設 400，貼近實際使用的文件長度）",
    )
    parser.add_argument(
        "--min-words",
        type=int,
        default=200,
        help="低於此詞數的切塊直接丟棄（預設 200）",
    )
    args = parser.parse_args()

    if not args.human_dir and not args.ai_dir:
        sys.exit("至少要指定 --human-dir 或 --ai-dir 其中一個")

    samples: list[dict] = []
    if args.human_dir:
        samples += collect(args.human_dir, "human", args)
    if args.ai_dir:
        samples += collect(args.ai_dir, "ai", args)

    args.out.parent.mkdir(parents=True, exist_ok=True)
    with args.out.open("w", encoding="utf-8") as f:
        for sample in samples:
            f.write(json.dumps(sample, ensure_ascii=False) + "\n")

    human_docs = len({s["doc_id"] for s in samples if s["label"] == "human"})
    ai_docs = len({s["doc_id"] for s in samples if s["label"] == "ai"})
    human_chunks = sum(1 for s in samples if s["label"] == "human")
    ai_chunks = sum(1 for s in samples if s["label"] == "ai")

    print(f"\n已寫入 {args.out}")
    print(f"  human：{human_docs} 份文件 / {human_chunks} 個樣本")
    print(f"  ai   ：{ai_docs} 份文件 / {ai_chunks} 個樣本")

    # 樣本量把關：與 App 的棄權設計同一個精神——量不足時就明說，
    # 不要讓使用者拿一份沒有統計意義的報表去做決策。
    warnings = []
    if human_docs < 30:
        warnings.append(
            f"human 只有 {human_docs} 份**獨立文件**（建議 ≥30）。"
            "同一份文件切成多塊並不會增加獨立資訊量。"
        )
    if ai_docs < 30:
        warnings.append(f"ai 只有 {ai_docs} 份獨立文件（建議 ≥30）。")
    if warnings:
        print("\n⚠️  樣本量不足，評測結果不具統計意義：")
        for w in warnings:
            print(f"   - {w}")
        print("   仍可先跑通流程，但別把數字當結論。")


if __name__ == "__main__":
    main()
