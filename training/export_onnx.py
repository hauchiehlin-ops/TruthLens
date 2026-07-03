"""將微調後的分類器匯出為 ONNX 並做 INT8 動態量化。

ONNX Runtime 可在 iOS/Android/macOS/Windows 四平台執行，是第一版最可攜的部署格式。
（TFLite / Core ML 轉換另行處理，見 README。）
"""
from __future__ import annotations

import argparse
import os

import torch
from onnxruntime.quantization import QuantType, quantize_dynamic
from transformers import AutoModelForSequenceClassification, AutoTokenizer

from config import TrainConfig, quick_smoke


def export(cfg: TrainConfig) -> None:
    os.makedirs(os.path.dirname(cfg.onnx_out), exist_ok=True)
    tokenizer = AutoTokenizer.from_pretrained(cfg.model_out)
    model = AutoModelForSequenceClassification.from_pretrained(cfg.model_out)
    model.eval()

    dummy = tokenizer(
        "範例文字 sample text for tracing",
        return_tensors="pt",
        truncation=True,
        max_length=cfg.max_length,
        padding="max_length",
    )

    print(f"匯出 ONNX → {cfg.onnx_out}")
    torch.onnx.export(
        model,
        (dummy["input_ids"], dummy["attention_mask"]),
        cfg.onnx_out,
        input_names=["input_ids", "attention_mask"],
        output_names=["logits"],
        dynamic_axes={
            "input_ids": {0: "batch", 1: "seq"},
            "attention_mask": {0: "batch", 1: "seq"},
            "logits": {0: "batch"},
        },
        opset_version=17,
        dynamo=False,  # 傳統 TorchScript 匯出器：graph 較單純，INT8 量化相容性佳
    )

    print(f"INT8 動態量化 → {cfg.onnx_int8_out}")
    quantize_dynamic(
        cfg.onnx_out,
        cfg.onnx_int8_out,
        weight_type=QuantType.QInt8,
    )

    fp32 = os.path.getsize(cfg.onnx_out) / 1e6
    int8 = os.path.getsize(cfg.onnx_int8_out) / 1e6
    print(f"完成：fp32 {fp32:.1f}MB → int8 {int8:.1f}MB")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true")
    args = ap.parse_args()
    export(quick_smoke() if args.quick else TrainConfig())
