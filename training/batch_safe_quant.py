"""可批次推論的 ONNX 量化：靜態 QDQ INT8 與批次一致性檢查。

動態量化（quantize_dynamic）在推論時依「整個輸入張量」計算 activation scale，
同一批次的其他句子會改變某一句的分數，因此 App 只能逐句送進模型（每次
ONNX 呼叫只有一句），長文件分析因此很慢。

靜態量化在匯出時就以校準語料固定 scale，推論時不再依輸入變動：同一句話
不論和哪些句子同批，分數都一樣。App 偵測到模型圖中沒有動態量化 op 後，
會自動改為每批 8 句（見 web/ort_core.js、lib/core/detection/onnx_detector_web.dart）。

**分數會變**：換量化方式後，同一句話的分數與舊的動態量化模型不同，catalog 的
ai_evidence_threshold 必須用 evaluate_operating_point.py 重新選定，不能沿用。
"""
from __future__ import annotations

import json
from pathlib import Path
from typing import Iterable

import numpy as np
import onnxruntime as ort
from onnxruntime.quantization import (
    CalibrationDataReader,
    CalibrationMethod,
    QuantFormat,
    QuantType,
    quantize_static,
)
from onnxruntime.quantization.shape_inference import quant_pre_process

QUANT_CHOICES = ("dynamic", "static", "fp32")


def load_texts(jsonl: Path, limit: int) -> list[str]:
    """讀取 {"text": ...} JSONL，人類與 AI 樣本交錯取，校準範圍才涵蓋兩類。"""
    by_label: dict[object, list[str]] = {}
    with jsonl.open(encoding="utf-8") as source:
        for line in source:
            row = json.loads(line)
            text = row.get("text")
            if isinstance(text, str) and text.strip():
                by_label.setdefault(row.get("label"), []).append(text)
    pools = list(by_label.values())
    texts: list[str] = []
    index = 0
    while len(texts) < limit and any(index < len(pool) for pool in pools):
        for pool in pools:
            if index < len(pool) and len(texts) < limit:
                texts.append(pool[index])
        index += 1
    return texts


class _TokenizedReader(CalibrationDataReader):
    """逐句提供校準輸入，與 App 推論時的輸入形狀一致（不 padding 到固定長度）。"""

    def __init__(self, tokenizer, texts: Iterable[str], max_length: int) -> None:
        self._items = iter(
            [
                {
                    "input_ids": enc["input_ids"].astype(np.int64),
                    "attention_mask": enc["attention_mask"].astype(np.int64),
                }
                for enc in (
                    tokenizer(
                        text,
                        return_tensors="np",
                        truncation=True,
                        max_length=max_length,
                    )
                    for text in texts
                )
            ]
        )

    def get_next(self):
        return next(self._items, None)


def quantize_static_qdq(
    fp32_path: Path,
    out_path: Path,
    tokenizer,
    calibration_texts: list[str],
    max_length: int,
) -> None:
    """以校準語料固定 activation scale 的 QDQ INT8 量化。"""
    if not calibration_texts:
        raise ValueError("靜態量化需要校準語料（--calibration-jsonl）")
    prepared = out_path.with_name(f"{out_path.stem}_prep.onnx")
    quant_pre_process(str(fp32_path), str(prepared))
    quantize_static(
        str(prepared),
        str(out_path),
        _TokenizedReader(tokenizer, calibration_texts, max_length),
        quant_format=QuantFormat.QDQ,
        activation_type=QuantType.QUInt8,
        weight_type=QuantType.QInt8,
        per_channel=True,
        # MinMax 接受長短不一的校準句；Percentile／Entropy 需固定形狀，
        # 補齊到 max_length 會讓 padding 位置主導直方圖。
        calibrate_method=CalibrationMethod.MinMax,
        # Softmax／LayerNorm 前後的 activation 動態範圍大，留在浮點較能保住準確度
        op_types_to_quantize=["MatMul", "Gemm"],
    )
    prepared.unlink(missing_ok=True)


def max_batch_drift(
    onnx_path: Path, tokenizer, texts: list[str], max_length: int, ai_label: int = 1
) -> float:
    """單句推論與 8 句一批推論的 AI 機率最大差異。

    App 以 1e-4 為容許值（kBatchInvarianceTolerance）；FP32 約 1e-7，
    動態 INT8 約 1e-3。
    """
    session = ort.InferenceSession(str(onnx_path), providers=["CPUExecutionProvider"])

    def probs(batch: list[str]) -> np.ndarray:
        enc = tokenizer(
            batch,
            return_tensors="np",
            truncation=True,
            max_length=max_length,
            padding=True,
        )
        logits = session.run(
            ["logits"],
            {
                "input_ids": enc["input_ids"].astype(np.int64),
                "attention_mask": enc["attention_mask"].astype(np.int64),
            },
        )[0]
        shifted = np.exp(logits - logits.max(axis=1, keepdims=True))
        return (shifted / shifted.sum(axis=1, keepdims=True))[:, ai_label]

    worst = 0.0
    for start in range(0, len(texts), 8):
        batch = texts[start : start + 8]
        batched = probs(batch)
        for index, text in enumerate(batch):
            worst = max(worst, abs(float(probs([text])[0]) - float(batched[index])))
    return worst
