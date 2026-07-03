"""下載並整理 HC3 資料集為統一的 {text, label} 格式。

HC3（Human ChatGPT Comparison Corpus）每筆問題附「human_answers」與
「chatgpt_answers」兩組回答。我們拆成獨立樣本：
  human_answers  → label 0 (human)
  chatgpt_answers→ label 1 (ai)

datasets v4 起不再支援腳本式資料集，故直接以 hf_hub_download 抓 all.jsonl。
輸出 data/train.jsonl 與 data/val.jsonl。
"""
from __future__ import annotations

import argparse
import json
import os
import random

from huggingface_hub import hf_hub_download

from config import DATA_DIR, TrainConfig, quick_smoke


def _load_jsonl(repo_id: str) -> list[dict]:
    path = hf_hub_download(repo_id=repo_id, filename="all.jsonl", repo_type="dataset")
    rows = []
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                rows.append(json.loads(line))
    return rows


def _extract(rows: list[dict], samples: list[dict], max_per_class: int | None):
    human_count = ai_count = 0
    for row in rows:
        for ans in row.get("human_answers") or []:
            if max_per_class and human_count >= max_per_class:
                break
            text = (ans or "").strip()
            if len(text) >= 40:
                samples.append({"text": text, "label": 0})
                human_count += 1
        for ans in row.get("chatgpt_answers") or []:
            if max_per_class and ai_count >= max_per_class:
                break
            text = (ans or "").strip()
            if len(text) >= 40:
                samples.append({"text": text, "label": 1})
                ai_count += 1
    return human_count, ai_count


def build(cfg: TrainConfig) -> None:
    os.makedirs(DATA_DIR, exist_ok=True)
    random.seed(cfg.seed)
    samples: list[dict] = []

    print(f"下載 {cfg.hc3_english} (all.jsonl) ...")
    h, a = _extract(_load_jsonl(cfg.hc3_english), samples, cfg.max_per_class)
    print(f"  英文：human={h} ai={a}")

    if cfg.use_chinese:
        print(f"下載 {cfg.hc3_chinese} (all.jsonl) ...")
        h, a = _extract(_load_jsonl(cfg.hc3_chinese), samples, cfg.max_per_class)
        print(f"  中文：human={h} ai={a}")

    random.shuffle(samples)
    n_val = max(1, int(len(samples) * cfg.val_ratio))
    val, train = samples[:n_val], samples[n_val:]

    _write(os.path.join(DATA_DIR, "train.jsonl"), train)
    _write(os.path.join(DATA_DIR, "val.jsonl"), val)
    print(f"完成：train={len(train)} val={len(val)} → {DATA_DIR}")


def _write(path: str, rows: list[dict]) -> None:
    with open(path, "w", encoding="utf-8") as f:
        for r in rows:
            f.write(json.dumps(r, ensure_ascii=False) + "\n")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true", help="煙霧測試（小資料）")
    args = ap.parse_args()
    build(quick_smoke() if args.quick else TrainConfig())
