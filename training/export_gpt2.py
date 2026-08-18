"""匯出 causal LM 為 ONNX，供端上計算困惑度（統計引擎 B）。

困惑度低 = 文本高度可預測 = 偏 AI；高 = 偏人類。

預設匯出 distilgpt2（現行 production 模型，純英文）。以 --model 指定其他模型
即可匯出多語替代品——DistilGPT2 對中文的 AUC 僅 0.50（毫無鑑別力），
Qwen2.5-0.5B 為 0.974，見 calibrate_multilingual_ppl.py。

用法：
    .venv/bin/python export_gpt2.py
    .venv/bin/python export_gpt2.py --model Qwen/Qwen2.5-0.5B --name qwen05b_ppl

匯出後**必須**用 INT8 產物重跑一次校準：量化會位移困惑度尺度，
fp32 量到的門檻不能直接沿用（門檻綁定的是「模型 × 語言」）。
"""
from __future__ import annotations

import math
import os

import numpy as np
import torch
from onnxruntime.quantization import QuantType, quantize_dynamic
from transformers import AutoModelForCausalLM, AutoTokenizer

from config import OUTPUT_DIR

MAXLEN = 192


def export(model_id: str, name: str) -> None:
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    tok = AutoTokenizer.from_pretrained(model_id)
    model = AutoModelForCausalLM.from_pretrained(model_id)
    model.config.use_cache = False  # 避免 transformers 5.x cache 追蹤問題
    model.eval()
    tok.save_pretrained(os.path.join(OUTPUT_DIR, f"{name}_tokenizer"))

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
    fp32 = os.path.join(OUTPUT_DIR, f"{name}.onnx")
    int8 = os.path.join(OUTPUT_DIR, f"{name}_int8.onnx")

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
        opset_version=18,
        # Qwen 等使用 rotary embedding 的模型會在舊版 TorchScript 匯出器
        # 觸發 "ScalarType ComplexDouble is an unexpected tensor scalar type"；
        # dynamo 匯出器（torch.export）能正確處理複數運算。
        # distilgpt2 兩者皆可，統一走 dynamo 以免維護兩條路徑。
        dynamo=True,
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
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument("--model", default="distilgpt2")
    parser.add_argument("--name", default="distilgpt2")
    args = parser.parse_args()
    export(args.model, args.name)
