"""以 ONNX Runtime 載入量化模型，對數個範例做推論，驗證匯出正確可用。

這也示範原生端（各平台 ONNX Runtime）需複製的前處理 / 後處理邏輯：
  1. tokenizer 編碼（input_ids, attention_mask）
  2. onnxruntime.run → logits
  3. softmax → label 1 (ai) 的機率
"""
from __future__ import annotations

import argparse

import numpy as np
import onnxruntime as ort
from transformers import AutoTokenizer

from config import TrainConfig, quick_smoke

SAMPLES = [
    ("As an AI language model, I must emphasize that it is important to note "
     "that there are several key factors to consider. Furthermore, in "
     "conclusion, these aspects are crucial for a comprehensive understanding.",
     "ai"),
    ("honestly i have no idea why the bus was late again today, third time "
     "this week lol. gonna just bike tomorrow if it rains i'll deal with it",
     "human"),
]


def _softmax(x):
    e = np.exp(x - np.max(x))
    return e / e.sum()


def verify(cfg: TrainConfig) -> None:
    tokenizer = AutoTokenizer.from_pretrained(cfg.model_out)
    sess = ort.InferenceSession(cfg.onnx_int8_out, providers=["CPUExecutionProvider"])

    print(f"驗證模型：{cfg.onnx_int8_out}\n")
    for text, expected in SAMPLES:
        enc = tokenizer(
            text,
            return_tensors="np",
            truncation=True,
            max_length=cfg.max_length,
            padding="max_length",
        )
        logits = sess.run(
            ["logits"],
            {
                "input_ids": enc["input_ids"].astype(np.int64),
                "attention_mask": enc["attention_mask"].astype(np.int64),
            },
        )[0][0]
        ai_prob = float(_softmax(logits)[1])
        pred = "ai" if ai_prob >= 0.5 else "human"
        mark = "✓" if pred == expected else "✗"
        print(f"{mark} 預期 {expected:5s} | 預測 {pred:5s} | AI 機率 {ai_prob:.3f}")
        print(f"    {text[:70]}...\n")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true")
    args = ap.parse_args()
    verify(quick_smoke() if args.quick else TrainConfig())
