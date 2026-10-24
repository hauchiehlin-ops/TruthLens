"""量測中文改寫偵測模型：洗過的 AI 是否仍抓得到，洗過的真人是否仍判為人類。

只看整體 AUROC 會掩蓋這個模型存在的理由。這裡依家族分開報告：
- AI／original：未洗滌的 AI 文本召回率
- AI／rule_laundered、AI／llm_humanized：洗過之後的召回率（**主要指標**）
- human／original、human／rule_laundered：誤報率。後者若明顯高於前者，代表模型學到
  「被洗過＝AI」的捷徑，不能發布

門檻在 calibration 半邊（依 group_id 雜湊分半）以目標誤報率選定，所有發布數字只用
另一半 test 計算，與 evaluate_operating_point.py 相同的紀律。輸出的 predictions
JSONL 也可直接餵給 evaluate_operating_point.py 做發布前的正式操作點報告。

範例：
  .venv/bin/python evaluate_zh_adversarial.py \\
      --onnx artifacts/zh_adversarial_onnx/model_int8.onnx \\
      --test data/zh_adversarial/test.jsonl \\
      --predictions data/zh_adversarial/predictions.jsonl \\
      --report data/zh_adversarial/report.json
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from pathlib import Path


def split_of(group_id: str) -> str:
    """依群組雜湊決定 calibration／test，同一題的所有版本落在同一側。"""
    digest = hashlib.sha1(group_id.encode("utf-8")).digest()
    return "calibration" if digest[0] % 2 == 0 else "test"


def auroc(labels: list[int], scores: list[float]) -> float | None:
    """以秩和計算 AUROC，同分取平均秩。缺任一類時回傳 None。"""
    pos = sum(labels)
    neg = len(labels) - pos
    if pos == 0 or neg == 0:
        return None
    order = sorted(range(len(scores)), key=lambda i: scores[i])
    ranks = [0.0] * len(scores)
    i = 0
    while i < len(order):
        j = i
        while j + 1 < len(order) and scores[order[j + 1]] == scores[order[i]]:
            j += 1
        for k in range(i, j + 1):
            ranks[order[k]] = (i + j) / 2 + 1
        i = j + 1
    rank_sum = sum(r for r, label in zip(ranks, labels) if label == 1)
    return (rank_sum - pos * (pos + 1) / 2) / (pos * neg)


def threshold_at_fpr(human_scores: list[float], target_fpr: float) -> float:
    """使真人誤報率不超過目標的最低門檻（分數 ≥ 門檻判為 AI）。"""
    if not human_scores:
        raise ValueError("calibration 沒有真人樣本，無法選門檻")
    ordered = sorted(human_scores, reverse=True)
    allowed = math.floor(len(ordered) * target_fpr)
    # 門檻設在第 allowed 個最高分之上，最多 allowed 個真人被判為 AI
    if allowed >= len(ordered):
        return 0.0
    return math.nextafter(ordered[allowed], math.inf)


def wilson_upper(hits: int, n: int, z: float = 1.96) -> float:
    if n == 0:
        return 1.0
    p = hits / n
    denom = 1 + z * z / n
    centre = p + z * z / (2 * n)
    margin = z * math.sqrt(p * (1 - p) / n + z * z / (4 * n * n))
    return min(1.0, (centre + margin) / denom)


def family_report(rows: list[dict], threshold: float) -> dict:
    """依（標籤, 家族）彙整 test 半邊的判定率。AI 為召回率，真人為誤報率。"""
    report: dict[str, dict] = {}
    keys = sorted({(r["label"], r["family"]) for r in rows})
    for label, family in keys:
        members = [r for r in rows if r["label"] == label and r["family"] == family]
        hits = sum(1 for r in members if r["score"] >= threshold)
        entry = {"n": len(members), "rate": hits / len(members) if members else 0.0}
        if label == 0:
            entry["fpr_upper95"] = wilson_upper(hits, len(members))
        report[f"{'ai' if label else 'human'}/{family}"] = entry
    return report


def summarize(rows: list[dict], target_fpr: float) -> dict:
    calibration = [r for r in rows if r["split"] == "calibration"]
    test = [r for r in rows if r["split"] == "test"]
    threshold = threshold_at_fpr(
        [r["score"] for r in calibration if r["label"] == 0], target_fpr
    )
    families = family_report(test, threshold)
    original = families.get("ai/original", {}).get("rate")
    laundered = families.get("ai/rule_laundered", {}).get("rate")
    human_original = families.get("human/original", {}).get("rate")
    human_laundered = families.get("human/rule_laundered", {}).get("rate")
    return {
        "target_fpr": target_fpr,
        "threshold": threshold,
        "test_auroc": auroc([r["label"] for r in test], [r["score"] for r in test]),
        "families": families,
        # 洗滌讓召回掉多少：越接近 0 越好
        "laundering_recall_gap": (
            None if original is None or laundered is None else original - laundered
        ),
        # 真人被洗過後誤報上升多少：明顯大於 0 代表模型學了捷徑
        "human_laundering_fpr_shift": (
            None
            if human_original is None or human_laundered is None
            else human_laundered - human_original
        ),
    }


def _score_onnx(texts: list[str], onnx_path: Path, tokenizer_path: Path, max_length: int):
    import numpy as np
    import onnxruntime as ort
    from tokenizers import Tokenizer

    tokenizer = Tokenizer.from_file(str(tokenizer_path))
    tokenizer.enable_truncation(max_length)
    session = ort.InferenceSession(str(onnx_path), providers=["CPUExecutionProvider"])
    scores = []
    # 逐句推論：與 App 相同（動態量化模型批次推論分數會漂移）
    for text in texts:
        encoding = tokenizer.encode(text)
        feeds = {
            "input_ids": np.array([encoding.ids], dtype=np.int64),
            "attention_mask": np.array([encoding.attention_mask], dtype=np.int64),
        }
        logits = session.run(None, feeds)[0][0]
        exp = np.exp(logits - logits.max())
        scores.append(float(exp[1] / exp.sum()))
    return scores


def _score_hf(texts: list[str], model_dir: Path, max_length: int):
    import torch
    from transformers import AutoModelForSequenceClassification, AutoTokenizer

    tokenizer = AutoTokenizer.from_pretrained(model_dir)
    model = AutoModelForSequenceClassification.from_pretrained(model_dir).eval()
    scores = []
    with torch.no_grad():
        for start in range(0, len(texts), 32):
            batch = tokenizer(
                texts[start : start + 32],
                truncation=True,
                max_length=max_length,
                padding=True,
                return_tensors="pt",
            )
            probs = torch.softmax(model(**batch).logits, dim=-1)[:, 1]
            scores.extend(float(p) for p in probs)
    return scores


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--test", type=Path, required=True)
    parser.add_argument("--onnx", type=Path, help="匯出的 ONNX（App 實際執行的版本）")
    parser.add_argument("--tokenizer", type=Path, help="預設為 ONNX 同目錄的 tokenizer.json")
    parser.add_argument("--model-dir", type=Path, help="或直接量測 Hugging Face 檢查點")
    parser.add_argument("--max-length", type=int, default=192)
    parser.add_argument("--target-fpr", type=float, default=0.01)
    parser.add_argument("--predictions", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    args = parser.parse_args()

    rows = [
        json.loads(line)
        for line in args.test.read_text(encoding="utf-8").splitlines()
        if line.strip()
    ]
    texts = [r["text"] for r in rows]
    if args.onnx:
        tokenizer = args.tokenizer or args.onnx.parent / "tokenizer.json"
        scores = _score_onnx(texts, args.onnx, tokenizer, args.max_length)
    elif args.model_dir:
        scores = _score_hf(texts, args.model_dir, args.max_length)
    else:
        raise SystemExit("請提供 --onnx 或 --model-dir")

    with args.predictions.open("w", encoding="utf-8") as handle:
        for row, score in zip(rows, scores):
            row["score"] = score
            row["split"] = split_of(row["group_id"])
            handle.write(
                json.dumps(
                    {
                        "doc_id": row["doc_id"],
                        "label": "ai" if row["label"] else "human",
                        "score": score,
                        "split": row["split"],
                        # evaluate_operating_point.py 以 domain 分組；這裡的「文體」就是洗滌家族
                        "domain": row["family"],
                        "language": "zh",
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )

    report = summarize(rows, args.target_fpr)
    args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
