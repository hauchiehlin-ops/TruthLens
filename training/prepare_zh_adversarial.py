"""為中文改寫偵測模型（對抗模組 D 的中文變體）產生訓練／驗證／測試資料。

英文版（prepare_adversarial.py）的作法是把 AI 文本用 T5 改寫，與原生 AI 一起標為 AI。
中文沒有同等的公開改寫模型，而且使用者實際遇到的是「AI 痕跡洗滌」工具，因此這裡
改用三種來源的「洗過的 AI 文本」：

1. 規則式洗滌（zh_laundering.py）：去八股、拆排比、拉高句長變異、換口語、改標點
2. 大型語言模型人類化（--llm-humanized）：binoculars/generate_ai_corpus.py 的
   humanized 語域，最接近真實洗滌工具，強烈建議提供
3. 原生 AI 文本本身

三個防捷徑設計，缺一不可：
- **對稱增強**：真人文本以相同次數套用同樣的規則式洗滌（仍標為人類），並在每個家族
  內各自平衡兩類。只洗 AI、或 AI 洗得比較多，模型都會學到「被洗過＝AI」，真人文章
  經過同樣處理就會被誤判。
- **按群組切分**：同一題的真人答案、AI 答案與其所有洗滌版本一定落在同一側，切分
  先做、增強後做，避免同一篇文章的不同版本同時出現在訓練與測試集。
- **繁簡轉換對稱**：轉繁體（--traditional-share）兩類以相同比例套用，字形不洩漏標籤。

輸出（--out-dir，預設 data/zh_adversarial）：
- train.json、dev.json：train_zh_detector.py 讀取的格式（JSON 陣列，text/label）
- test.jsonl：每列含 doc_id、group_id、label、family（original／rule_laundered／
  llm_humanized），供 evaluate_zh_adversarial.py 分家族量測
- manifest.json：參數與各分割、各家族的筆數

範例（在已下載 HC3-Chinese 的機器上）：
  .venv/bin/python prepare_zh_adversarial.py \\
      --hc3 data/hc3_zh/all.jsonl \\
      --llm-humanized binoculars/data/ai_generated/manifest.jsonl
"""

from __future__ import annotations

import argparse
import hashlib
import json
import random
from collections import Counter
from pathlib import Path

from zh_laundering import launder

ROOT = Path(__file__).resolve().parent

FAMILIES = ("original", "rule_laundered", "llm_humanized")


def load_hc3(path: Path, min_chars: int) -> list[dict]:
    """HC3-Chinese 原始格式：每列一題，含 human_answers 與 chatgpt_answers。"""
    rows: list[dict] = []
    for index, line in enumerate(path.read_text(encoding="utf-8").splitlines()):
        if not line.strip():
            continue
        record = json.loads(line)
        group = "hc3-" + hashlib.sha1(
            (record.get("question") or str(index)).encode("utf-8")
        ).hexdigest()[:16]
        for field, label in (("human_answers", 0), ("chatgpt_answers", 1)):
            for answer in record.get(field) or []:
                text = (answer or "").strip()
                if len(text) >= min_chars:
                    rows.append(
                        {"text": text, "label": label, "group_id": group, "family": "original"}
                    )
    return rows


def _label(value) -> int:
    if value in {0, "0", "human"}:
        return 0
    if value in {1, "1", "ai", "ai_generated", "ai_assisted"}:
        return 1
    raise ValueError(f"未知標籤 {value!r}")


def load_corpus(path: Path, min_chars: int) -> list[dict]:
    """通用 JSONL：text、label、group_id（或 doc_id／id）。"""
    rows: list[dict] = []
    for line in path.read_text(encoding="utf-8").splitlines():
        if not line.strip():
            continue
        record = json.loads(line)
        text = (record.get("text") or "").strip()
        if len(text) < min_chars:
            continue
        group = record.get("group_id") or record.get("doc_id") or record.get("id")
        if group is None:
            raise ValueError(f"{path} 有一列缺 group_id／doc_id／id，無法防止切分洩漏")
        rows.append(
            {
                "text": text,
                "label": _label(record.get("label")),
                "group_id": f"{path.stem}-{group}",
                "family": "original",
            }
        )
    return rows


def load_llm_humanized(path: Path, min_chars: int) -> list[dict]:
    """LLM 產生的 AI 文本，一律標為 AI。接受兩種格式：

    - binoculars/generate_ai_corpus.py 的 manifest.jsonl（每列 file、style、topic_src；
      文字在同目錄的 file）：style 為 humanized 的是「洗過的 AI」，其餘語域是原生的
      現代 AI，兩者都收——後者補上 HC3 缺的 2026 世代生成器。
    - 一般 JSONL（每列 text，視為 humanized）。

    群組取 group_id／topic_src／topic_id／doc_id：同題的各語域一定落在切分的同一側。
    """
    rows: list[dict] = []
    for index, line in enumerate(path.read_text(encoding="utf-8").splitlines()):
        if not line.strip():
            continue
        record = json.loads(line)
        text = record.get("text")
        if text is None and record.get("file"):
            source = path.parent / record["file"]
            if not source.exists():
                continue
            text = source.read_text(encoding="utf-8")
        text = (text or "").strip()
        if len(text) < min_chars:
            continue
        style = record.get("style", "humanized")
        group = (
            record.get("group_id")
            or record.get("topic_src")
            or record.get("topic_id")
            or record.get("doc_id")
            or f"{path.stem}-{index}"
        )
        rows.append(
            {
                "text": text,
                "label": 1,
                "group_id": f"llm-{group}",
                "family": "llm_humanized" if style == "humanized" else "original",
            }
        )
    return rows


def split_groups(
    rows: list[dict], dev_ratio: float, test_ratio: float, seed: int
) -> dict[str, list[dict]]:
    """按 group_id 切成 train/dev/test。依「群組內有哪些標籤」分層，三側都有兩類。"""
    groups: dict[str, list[dict]] = {}
    for row in rows:
        groups.setdefault(row["group_id"], []).append(row)
    by_signature: dict[tuple, list[str]] = {}
    for key, members in groups.items():
        signature = tuple(sorted({m["label"] for m in members}))
        by_signature.setdefault(signature, []).append(key)

    rng = random.Random(seed)
    assignment: dict[str, str] = {}
    for keys in by_signature.values():
        keys.sort()
        rng.shuffle(keys)
        n_test = round(len(keys) * test_ratio) if len(keys) >= 3 else 0
        n_dev = round(len(keys) * dev_ratio) if len(keys) >= 3 else 0
        for i, key in enumerate(keys):
            assignment[key] = "test" if i < n_test else "dev" if i < n_test + n_dev else "train"

    out: dict[str, list[dict]] = {"train": [], "dev": [], "test": []}
    for key, members in groups.items():
        out[assignment[key]].extend(members)
    return out


def augment(rows: list[dict], rng: random.Random, variants: int) -> list[dict]:
    """在切分之後增強，同一篇的所有版本留在同一側。

    真人與 AI 原文產生**相同數量**的洗滌版本：若 AI 洗得比較多，「被洗過」本身就
    會帶有標籤資訊。
    """
    out: list[dict] = []
    for row in rows:
        out.append(dict(row, ops=[]))
        if row["family"] != "original":
            continue
        for _ in range(variants):
            text, ops = launder(row["text"], rng)
            if text and text != row["text"]:
                out.append(dict(row, text=text, family="rule_laundered", ops=ops))
    return out


def to_traditional_symmetric(rows: list[dict], share: float, rng: random.Random) -> int:
    """兩類以相同比例轉成繁體，回傳轉換筆數；沒有安裝 OpenCC 時不轉並回傳 -1。"""
    if share <= 0:
        return 0
    try:
        from opencc import OpenCC  # opencc-python-reimplemented
    except ImportError:
        return -1
    converter = OpenCC("s2t")
    converted = 0
    for row in rows:
        if rng.random() < share:
            row["text"] = converter.convert(row["text"])
            converted += 1
    return converted


def balance(rows: list[dict], rng: random.Random, max_per_class: int | None) -> list[dict]:
    """在每個家族內各自平衡兩類，讓 P(AI | 家族) = 0.5。

    只做整體平衡時，若某家族的 AI 比例偏高，模型就能靠「屬於哪個家族」猜標籤。
    只有單一標籤的家族（llm_humanized 只有 AI）照收，不參與配對。
    """
    families = sorted({r["family"] for r in rows})
    paired = [f for f in families if {r["label"] for r in rows if r["family"] == f} == {0, 1}]
    single = [f for f in families if f not in paired]
    per_family_cap = None
    if max_per_class and paired:
        per_family_cap = max(1, max_per_class // len(paired))
    out: list[dict] = []
    for family in paired:
        by_label = {
            label: [r for r in rows if r["family"] == family and r["label"] == label]
            for label in (0, 1)
        }
        cap = min(len(by_label[0]), len(by_label[1]))
        if per_family_cap:
            cap = min(cap, per_family_cap)
        for label in (0, 1):
            members = by_label[label][:]
            rng.shuffle(members)
            out.extend(members[:cap])
    for family in single:
        members = [r for r in rows if r["family"] == family]
        rng.shuffle(members)
        out.extend(members[:max_per_class] if max_per_class else members)
    rng.shuffle(out)
    return out


def summarize(rows: list[dict]) -> dict:
    return {
        f"{'ai' if label else 'human'}/{family}": count
        for (label, family), count in sorted(
            Counter((r["label"], r["family"]) for r in rows).items()
        )
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--hc3", type=Path, help="HC3-Chinese all.jsonl")
    parser.add_argument("--corpus", type=Path, action="append", default=[])
    parser.add_argument("--llm-humanized", type=Path, action="append", default=[])
    parser.add_argument("--out-dir", type=Path, default=ROOT / "data/zh_adversarial")
    parser.add_argument("--min-chars", type=int, default=64)
    parser.add_argument(
        "--variants", type=int, default=2, help="每篇原文（真人與 AI 相同）產生幾個洗滌版本"
    )
    parser.add_argument("--traditional-share", type=float, default=0.5)
    parser.add_argument("--dev-ratio", type=float, default=0.10)
    parser.add_argument("--test-ratio", type=float, default=0.15)
    parser.add_argument("--max-per-class", type=int, default=30000)
    parser.add_argument("--seed", type=int, default=20261024)
    args = parser.parse_args()

    rows: list[dict] = []
    if args.hc3:
        rows += load_hc3(args.hc3, args.min_chars)
    for path in args.corpus:
        rows += load_corpus(path, args.min_chars)
    for path in args.llm_humanized:
        rows += load_llm_humanized(path, args.min_chars)
    if not rows:
        raise SystemExit("沒有任何資料：請提供 --hc3、--corpus 或 --llm-humanized")
    if not args.llm_humanized:
        print("⚠️  未提供 --llm-humanized：洗過的 AI 只有規則式版本，對真實洗滌工具的代表性有限")

    rng = random.Random(args.seed)
    splits = split_groups(rows, args.dev_ratio, args.test_ratio, args.seed)
    for side in splits.values():
        for row in side:
            row["text"] = row["text"].strip()
    for name in ("train", "dev", "test"):
        splits[name] = augment(splits[name], rng, args.variants)
        converted = to_traditional_symmetric(splits[name], args.traditional_share, rng)
        if converted < 0 and name == "train":
            print("⚠️  未安裝 opencc-python-reimplemented：不做繁體轉換，模型可能偏向簡體")
    splits["train"] = balance(splits["train"], rng, args.max_per_class)
    splits["dev"] = balance(splits["dev"], rng, None)

    args.out_dir.mkdir(parents=True, exist_ok=True)
    for name in ("train", "dev"):
        (args.out_dir / f"{name}.json").write_text(
            json.dumps(
                [{"text": r["text"], "label": r["label"], "family": r["family"]} for r in splits[name]],
                ensure_ascii=False,
            ),
            encoding="utf-8",
        )
    with (args.out_dir / "test.jsonl").open("w", encoding="utf-8") as handle:
        for index, row in enumerate(splits["test"]):
            handle.write(
                json.dumps(
                    {
                        "doc_id": f"{row['group_id']}-{index}",
                        "group_id": row["group_id"],
                        "label": row["label"],
                        "family": row["family"],
                        "ops": row.get("ops", []),
                        "text": row["text"],
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )

    manifest = {
        # 路徑（含 --corpus 這種路徑清單）一律轉成字串
        "args": json.loads(json.dumps(vars(args), default=str)),
        "splits": {name: summarize(side) for name, side in splits.items()},
    }
    (args.out_dir / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    for name, counts in manifest["splits"].items():
        print(f"{name:5s} {counts}")


if __name__ == "__main__":
    main()
