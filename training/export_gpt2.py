"""匯出 distilgpt2 為 ONNX（causal LM），供端上計算困惑度（統計引擎 B）。

困惑度低 = 文本高度可預測 = 偏 AI；高 = 偏人類。
輸出 artifacts/distilgpt2.onnx（+ INT8）與 tokenizer.json，並印出參考困惑度。
"""
from __future__ import annotations

import math
import os

import numpy as np
import torch
from onnxruntime.quantization import QuantType, quantize_dynamic
from transformers import AutoModelForCausalLM, AutoTokenizer

from config import OUTPUT_DIR

MODEL = "distilgpt2"
MAXLEN = 192


def export() -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    tok = AutoTokenizer.from_pretrained(MODEL)
    model = AutoModelForCausalLM.from_pretrained(MODEL)
    model.config.use_cache = False  # 避免 transformers 5.x cache 追蹤問題
    model.eval()
    tok.save_pretrained(os.path.join(OUTPUT_DIR, "gpt2_tokenizer"))

    # 包一層，強制 use_cache=False 且只回傳 logits（避開 transformers 5.x cache 追蹤問題）
    class LogitsOnly(torch.nn.Module):
        def __init__(self, m):
            super().__init__()
            self.m = m

        def forward(self, input_ids, attention_mask):
            return self.m(
                input_ids=input_ids,
                attention_mask=attention_mask,
                use_cache=False,
            ).logits

    wrapped = LogitsOnly(model)

    dummy = tok("hello world", return_tensors="pt")
    fp32 = os.path.join(OUTPUT_DIR, "distilgpt2.onnx")
    int8 = os.path.join(OUTPUT_DIR, "distilgpt2_int8.onnx")

    print(f"匯出 ONNX → {fp32}")
    torch.onnx.export(
        wrapped,
        (dummy["input_ids"], dummy["attention_mask"]),
        fp32,
        input_names=["input_ids", "attention_mask"],
        output_names=["logits"],
        dynamic_axes={
            "input_ids": {0: "batch", 1: "seq"},
            "attention_mask": {0: "batch", 1: "seq"},
            "logits": {0: "batch", 1: "seq"},
        },
        opset_version=14,
        dynamo=False,
    )
    print(f"INT8 量化 → {int8}")
    quantize_dynamic(fp32, int8, weight_type=QuantType.QInt8)
    print(f"完成：fp32 {os.path.getsize(fp32)/1e6:.0f}MB → int8 {os.path.getsize(int8)/1e6:.0f}MB")

    _reference(int8, tok)


def _reference(model_path: str, tok) -> None:
    import onnxruntime as ort

    sess = ort.InferenceSession(model_path, providers=["CPUExecutionProvider"])
    samples = {
        "AI 風格": "It is important to note that artificial intelligence is "
        "transforming industries. Furthermore, these advancements offer "
        "significant benefits and must be considered carefully.",
        "人類口語": "ugh my train was late again lol, ended up walking half way "
        "and my coffee spilled everywhere, what a morning honestly",
    }
    print("\n參考困惑度（越低越偏 AI）：")
    for label, text in samples.items():
        ppl = _perplexity(sess, tok, text)
        print(f"  {label}: {ppl:.1f}")


def _perplexity(sess, tok, text: str) -> float:
    ids = tok(text, truncation=True, max_length=MAXLEN)["input_ids"]
    arr = np.array([ids], dtype=np.int64)
    mask = np.ones_like(arr)
    logits = sess.run(["logits"], {"input_ids": arr, "attention_mask": mask})[0][0]
    # 對每個位置預測下一個 token，累加負對數似然
    nll = 0.0
    n = 0
    for i in range(len(ids) - 1):
        row = logits[i]
        m = row.max()
        logsumexp = m + math.log(np.exp(row - m).sum())
        nll += logsumexp - row[ids[i + 1]]
        n += 1
    return math.exp(nll / n) if n else float("nan")


if __name__ == "__main__":
    export()
