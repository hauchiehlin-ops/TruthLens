"""把「中文研究計畫書」語域併入中文偵測器的訓練資料，並保留獨立測試集。

為什麼需要
----------
2026-10 一份 Antigravity 全自動生成的中文研究計畫被判為「較可能不是 AI」。
現行中文 Transformer 的三份訓練語料（DetectRL-X 改寫／續寫、NLPCC、HC3 問答）
都沒有這個語域。DEVLOG 2026-08-29 已記錄過同一類教訓：缺的是語域，不是生成器。

為什麼不用 binoculars/prepare_corpus.py
--------------------------------------
它以 `text.split()` 計詞。中文沒有空白，一份 3000 字計畫書只會算出幾十個「詞」，
低於 `--min-words` 而被整份丟棄。這裡改以字元與句末標點切塊。

切塊規則刻意對齊 App 的前處理（`PreprocessedText`）：
- 沒有句末標點的行（標題、關鍵詞、表格列）不進訓練文字，App 分析時同樣會剝掉
- 參考文獻標題之後的內容全部略過
- 以句為單位累積到約 `--chunk-chars` 字，對齊 App 逐句推論與 192 token 上限

切分以 group 為單位：AI 樣本依生成時的題目（manifest 的 topic_src），human 樣本
每份文件各自一組。同題的不同模型、語域版本不會同時出現在訓練與測試兩側。

用法
----
    cd training
    .venv/bin/python build_proposal_register.py \\
        --human-dir data/proposal_register/human \\
        --ai-dir    data/proposal_register/ai \\
        --base-data-dir data/zh_combined3 \\
        --out-dir   data/zh_combined4

產出：
    <out-dir>/train.json、dev.json        基礎語料 + 研究計畫語域（餵 train_zh_detector.py）
    <out-dir>/proposal_register_test.json 只含研究計畫語域、未參與訓練與校準
    <out-dir>/proposal_register_stats.json 各 split 的 human／AI 數量與生成器分布
    <out-dir>/proposal_register_binoculars.jsonl 同一語域，供 binoculars/run_binoculars.py 量可分性
"""

from __future__ import annotations

import argparse
import hashlib
import json
import random
import re
import sys
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "binoculars"))
from prepare_corpus import SUPPORTED, extract  # noqa: E402

SENTENCE_END = "。！？!?；;"
BIBLIOGRAPHY_HEADINGS = {
    "參考文獻",
    "参考文献",
    "參考資料",
    "参考资料",
    "引用文獻",
    "references",
    "bibliography",
}


def is_bibliography_heading(line: str) -> bool:
    normalized = re.sub(r"^[\d.、．\s第一二三四五六七八九十章節]+", "", line)
    normalized = re.sub(r"[\s　:：#*]+", "", normalized).lower()
    return normalized in BIBLIOGRAPHY_HEADINGS


def prose_sentences(text: str) -> list[str]:
    """抽出正文散文句：略過無句末標點的行與參考文獻之後的內容。"""
    sentences: list[str] = []
    for raw_line in text.replace("\r\n", "\n").split("\n"):
        line = raw_line.strip().strip("#*>-• ").strip()
        if not line:
            continue
        if is_bibliography_heading(line):
            break
        if line.count("|") >= 2 or line[-1] not in SENTENCE_END + "」』）)":
            continue
        for sentence in re.split(rf"(?<=[{SENTENCE_END}])", line):
            sentence = sentence.strip()
            if len(sentence) >= 8:
                sentences.append(sentence)
    return sentences


def chunk_sentences(sentences: list[str], chunk_chars: int, min_chars: int) -> list[str]:
    chunks: list[str] = []
    pending = ""
    for sentence in sentences:
        if pending and len(pending) + len(sentence) > chunk_chars:
            chunks.append(pending)
            pending = ""
        pending += sentence
    if pending:
        chunks.append(pending)
    return [chunk for chunk in chunks if len(chunk) >= min_chars]


def load_manifest(directory: Path) -> dict[str, dict]:
    path = directory / "manifest.jsonl"
    if not path.exists():
        return {}
    rows = {}
    for line in path.read_text(encoding="utf-8").splitlines():
        if line.strip():
            row = json.loads(line)
            rows[row.get("file", "")] = row
    return rows


def collect(directory: Path, label: int, args) -> list[dict]:
    manifest = load_manifest(directory)
    rows: list[dict] = []
    files = sorted(p for p in directory.rglob("*") if p.suffix.lower() in SUPPORTED)
    for path in files:
        try:
            text = extract(path)
        except Exception as exc:  # noqa: BLE001 - 單檔失敗不該中斷整批
            print(f"  略過 {path.name}（讀取失敗：{exc}）")
            continue
        chunks = chunk_sentences(prose_sentences(text), args.chunk_chars, args.min_chars)
        if not chunks:
            print(f"  略過 {path.name}（正文不足 {args.min_chars} 字）")
            continue
        doc_id = hashlib.sha1(str(path).encode()).hexdigest()[:12]
        meta = manifest.get(path.name, {})
        group = f"ai:{meta['topic_src']}" if label == 1 and meta.get("topic_src") else f"doc:{doc_id}"
        generator = f"{meta.get('provider', 'unknown')}/{meta.get('model', '')}" if label == 1 else "human"
        for index, chunk in enumerate(chunks):
            rows.append(
                {
                    "id": f"{doc_id}_{index}",
                    "doc_id": doc_id,
                    "text": chunk,
                    "label": label,
                    "source": "zh-proposal",
                    "group_id": group,
                    "generator": generator,
                    "style": meta.get("style", "human" if label == 0 else "unknown"),
                }
            )
    print(f"[{'AI' if label else 'human'}] 檔案 {len(files)} 份 → 切塊 {len(rows)} 個")
    return rows


def split_groups(rows: list[dict], test_ratio: float, dev_ratio: float, seed: int):
    """分別對 human 與 AI 的 group 抽樣，確保三個 split 都有兩類樣本。"""
    split_of: dict[str, str] = {}
    rng = random.Random(seed)
    for label in (0, 1):
        groups = sorted({r["group_id"] for r in rows if r["label"] == label})
        rng.shuffle(groups)
        n_test = max(1, round(len(groups) * test_ratio)) if len(groups) >= 3 else 0
        n_dev = max(1, round(len(groups) * dev_ratio)) if len(groups) >= 3 else 0
        for i, group in enumerate(groups):
            split_of[group] = "test" if i < n_test else "dev" if i < n_test + n_dev else "train"
    out = {"train": [], "dev": [], "test": []}
    for row in rows:
        out[split_of[row["group_id"]]].append(row)
    return out


def summarize(rows: list[dict]) -> dict:
    return {
        "human": sum(1 for r in rows if r["label"] == 0),
        "ai": sum(1 for r in rows if r["label"] == 1),
        "groups": len({r["group_id"] for r in rows}),
        "generators": dict(Counter(r["generator"] for r in rows if r["label"] == 1)),
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="併入中文研究計畫書語域")
    parser.add_argument("--human-dir", type=Path, required=True, help="真人撰寫的研究計畫書")
    parser.add_argument("--ai-dir", type=Path, required=True, help="generate_ai_corpus.py --register zh-proposal 的輸出")
    parser.add_argument("--base-data-dir", type=Path, help="既有 train.json／dev.json（例如 data/zh_combined3）")
    parser.add_argument("--out-dir", type=Path, required=True)
    parser.add_argument("--chunk-chars", type=int, default=160, help="對齊 192 token 上限")
    parser.add_argument("--min-chars", type=int, default=40)
    parser.add_argument("--test-ratio", type=float, default=0.30)
    parser.add_argument("--dev-ratio", type=float, default=0.10)
    parser.add_argument("--seed", type=int, default=20261017)
    args = parser.parse_args()

    rows = collect(args.human_dir, 0, args) + collect(args.ai_dir, 1, args)
    if not any(r["label"] == 0 for r in rows) or not any(r["label"] == 1 for r in rows):
        sys.exit("human 與 AI 兩類都至少需要一份可用文件")
    splits = split_groups(rows, args.test_ratio, args.dev_ratio, args.seed)
    if not splits["test"]:
        sys.exit("每類至少需要 3 份文件，才能保留獨立測試集")

    base_train: list[dict] = []
    base_dev: list[dict] = []
    if args.base_data_dir:
        base_train = json.loads((args.base_data_dir / "train.json").read_text(encoding="utf-8"))
        base_dev = json.loads((args.base_data_dir / "dev.json").read_text(encoding="utf-8"))

    args.out_dir.mkdir(parents=True, exist_ok=True)
    outputs = {
        "train.json": base_train + splits["train"],
        "dev.json": base_dev + splits["dev"],
        "proposal_register_test.json": splits["test"],
    }
    for name, data in outputs.items():
        (args.out_dir / name).write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
    # Binoculars 是零樣本方法，不經訓練，整個語域都可拿來量可分性；格式對齊
    # binoculars/run_binoculars.py 與 evaluate.py（label 為 human／ai，words 以字元計）。
    with (args.out_dir / "proposal_register_binoculars.jsonl").open("w", encoding="utf-8") as f:
        for row in rows:
            f.write(
                json.dumps(
                    {
                        "id": row["id"],
                        "doc_id": row["doc_id"],
                        "label": "ai" if row["label"] == 1 else "human",
                        "source": row["generator"],
                        "words": len(row["text"]),
                        "text": row["text"],
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
    stats = {split: summarize(data) for split, data in splits.items()}
    stats["base"] = {"train": len(base_train), "dev": len(base_dev)}
    (args.out_dir / "proposal_register_stats.json").write_text(
        json.dumps(stats, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(json.dumps(stats, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
