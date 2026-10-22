"""將微調後的分類器匯出為 ONNX 並量化。

--quant dynamic（預設，與既有發布模型相同）／static（可批次推論，App 推論快數倍，
需重新校準門檻）／fp32（不量化）。量化方式說明見 batch_safe_quant.py。

ONNX Runtime 可在 iOS/Android/macOS/Windows 四平台執行，是第一版最可攜的部署格式。
（TFLite / Core ML 轉換另行處理，見 README。）
"""
from __future__ import annotations

import argparse
import os
import shutil
from pathlib import Path

import torch
from onnxruntime.quantization import QuantType, quantize_dynamic
from transformers import AutoModelForSequenceClassification, AutoTokenizer

from batch_safe_quant import QUANT_CHOICES, load_texts, max_batch_drift, quantize_static_qdq
from config import DATA_DIR, TrainConfig, adversarial, quick_smoke


def export(cfg: TrainConfig, quant: str = "dynamic", calibration_size: int = 512) -> None:
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

    val_texts = load_texts(Path(DATA_DIR) / cfg.val_file, calibration_size)
    if quant == "static":
        print(f"INT8 靜態量化（{len(val_texts)} 句校準）→ {cfg.onnx_int8_out}")
        quantize_static_qdq(
            Path(cfg.onnx_out), Path(cfg.onnx_int8_out), tokenizer, val_texts, cfg.max_length
        )
    elif quant == "fp32":
        print(f"不量化，複製 fp32 → {cfg.onnx_int8_out}")
        shutil.copyfile(cfg.onnx_out, cfg.onnx_int8_out)
    else:
        print(f"INT8 動態量化 → {cfg.onnx_int8_out}")
        quantize_dynamic(
            cfg.onnx_out,
            cfg.onnx_int8_out,
            weight_type=QuantType.QInt8,
        )

    fp32 = os.path.getsize(cfg.onnx_out) / 1e6
    int8 = os.path.getsize(cfg.onnx_int8_out) / 1e6
    print(f"完成：fp32 {fp32:.1f}MB → {quant} {int8:.1f}MB")
    drift = max_batch_drift(Path(cfg.onnx_int8_out), tokenizer, val_texts[:64], cfg.max_length)
    verdict = "App 會自動批次推論" if quant != "dynamic" and drift <= 1e-4 else "App 會逐句推論"
    print(f"單句 vs 批次最大差異 {drift:.2e}（{verdict}）")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true")
    ap.add_argument("--adversarial", action="store_true")
    ap.add_argument("--quant", choices=QUANT_CHOICES, default="dynamic")
    ap.add_argument("--calibration-size", type=int, default=512)
    args = ap.parse_args()
    cfg = quick_smoke() if args.quick else (
        adversarial() if args.adversarial else TrainConfig())
    export(cfg, args.quant, args.calibration_size)
