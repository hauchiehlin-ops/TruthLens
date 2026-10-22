"""Export an Apache-licensed Hugging Face sequence classifier to INT8 ONNX.

--quant static produces a batch-invariant model (the app then batches 8
sentences per call); it needs --calibration-jsonl and the catalog threshold
must be re-selected because scores change. See batch_safe_quant.py.

This helper is intentionally model-agnostic so a newer language-specific
detector can replace an obsolete checkpoint without changing application code.
"""

from __future__ import annotations

import argparse
import hashlib
import shutil
from pathlib import Path

import torch
from onnxruntime.quantization import QuantType, quantize_dynamic
from transformers import AutoModelForSequenceClassification, AutoTokenizer

from batch_safe_quant import QUANT_CHOICES, load_texts, max_batch_drift, quantize_static_qdq


class _TwoInputClassifier(torch.nn.Module):
    def __init__(self, model: torch.nn.Module) -> None:
        super().__init__()
        self.model = model

    def forward(
        self, input_ids: torch.Tensor, attention_mask: torch.Tensor
    ) -> torch.Tensor:
        return self.model(
            input_ids=input_ids, attention_mask=attention_mask
        ).logits


def _sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for block in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("model", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--max-length", type=int, default=192)
    parser.add_argument("--quant", choices=QUANT_CHOICES, default="dynamic")
    parser.add_argument("--calibration-jsonl", type=Path)
    parser.add_argument("--calibration-size", type=int, default=512)
    args = parser.parse_args()

    args.output.parent.mkdir(parents=True, exist_ok=True)
    fp32 = args.output.with_name(f"{args.output.stem}_fp32.onnx")
    tokenizer = AutoTokenizer.from_pretrained(args.model, use_fast=True)
    tokenizer.save_pretrained(args.output.parent)
    model = AutoModelForSequenceClassification.from_pretrained(args.model).eval()
    wrapped = _TwoInputClassifier(model).eval()
    sample = tokenizer(
        "這是一段用於匯出模型的完整中文測試文字。",
        return_tensors="pt",
        truncation=True,
        max_length=args.max_length,
        padding="max_length",
    )
    torch.onnx.export(
        wrapped,
        (sample["input_ids"], sample["attention_mask"]),
        fp32,
        input_names=["input_ids", "attention_mask"],
        output_names=["logits"],
        dynamic_axes={
            "input_ids": {0: "batch", 1: "sequence"},
            "attention_mask": {0: "batch", 1: "sequence"},
            "logits": {0: "batch"},
        },
        opset_version=17,
        dynamo=False,
    )
    texts = (
        load_texts(args.calibration_jsonl, args.calibration_size)
        if args.calibration_jsonl
        else []
    )
    if args.quant == "static":
        quantize_static_qdq(fp32, args.output, tokenizer, texts, args.max_length)
    elif args.quant == "fp32":
        shutil.copyfile(fp32, args.output)
    else:
        quantize_dynamic(fp32, args.output, weight_type=QuantType.QInt8)
    print(
        f"fp32={fp32.stat().st_size} {args.quant}={args.output.stat().st_size} "
        f"sha256={_sha256(args.output)}"
    )
    if texts:
        drift = max_batch_drift(args.output, tokenizer, texts[:64], args.max_length)
        print(f"max single-vs-batch drift {drift:.2e} (app batches when <= 1e-4)")


if __name__ == "__main__":
    main()
