"""驗證對抗模組 D 的核心能力：改寫後的 AI 文本仍被判為 AI（不被規避）。

取一段 AI 文本、其 T5 改寫版、以及一段人類文本，跑訓練好的對抗 ONNX 模型，
期望：native AI 與改寫 AI 皆為高 AI 機率，人類為低。
"""
from __future__ import annotations

import numpy as np
import onnxruntime as ort
import torch
from transformers import (
    AutoModelForSeq2SeqLM,
    AutoTokenizer,
)

from config import adversarial

PARAPHRASER = "humarin/chatgpt_paraphraser_on_T5_base"

AI_TEXT = (
    "It is important to note that artificial intelligence is transforming "
    "numerous industries. Furthermore, these systems provide significant "
    "efficiency gains and must be carefully evaluated before deployment."
)
HUMAN_TEXT = (
    "honestly the meeting ran way over again and i barely had time for lunch, "
    "then the printer jammed twice, what a day lol"
)


def _softmax(x):
    e = np.exp(x - x.max())
    return e / e.sum()


def _paraphrase(text: str) -> str:
    dev = "mps" if torch.backends.mps.is_available() else "cpu"
    tok = AutoTokenizer.from_pretrained(PARAPHRASER)
    m = AutoModelForSeq2SeqLM.from_pretrained(PARAPHRASER).to(dev).eval()
    inp = tok([f"paraphrase: {text}"], return_tensors="pt",
              truncation=True, max_length=256).to(dev)
    out = m.generate(**inp, max_length=256, num_beams=4, num_return_sequences=1)
    return tok.batch_decode(out, skip_special_tokens=True)[0]


def main() -> None:
    cfg = adversarial()
    sess = ort.InferenceSession(cfg.onnx_int8_out,
                                providers=["CPUExecutionProvider"])
    tok = AutoTokenizer.from_pretrained(cfg.model_out)

    def ai_prob(text: str) -> float:
        enc = tok(text, return_tensors="np", truncation=True, max_length=192)
        logits = sess.run(None, {
            "input_ids": enc["input_ids"].astype(np.int64),
            "attention_mask": enc["attention_mask"].astype(np.int64),
        })[0][0]
        return float(_softmax(logits)[1])  # 1 = AI

    para = _paraphrase(AI_TEXT)
    print("改寫版：", para, "\n")
    print(f"原生 AI    → AI 機率 {ai_prob(AI_TEXT):.3f}（期望高）")
    print(f"改寫後 AI  → AI 機率 {ai_prob(para):.3f}（期望高＝未被規避）")
    print(f"人類文本   → AI 機率 {ai_prob(HUMAN_TEXT):.3f}（期望低）")


if __name__ == "__main__":
    main()
