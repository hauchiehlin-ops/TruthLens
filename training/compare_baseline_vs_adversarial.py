"""比較「一般偵測器（無對抗訓練，第一版 transformer）」vs「對抗模組 D」
對同一句改寫後 AI 文本的判定差異，證明對抗訓練的實際效果。
"""
from __future__ import annotations

import numpy as np
import onnxruntime as ort
from transformers import AutoTokenizer


def softmax(x: np.ndarray) -> np.ndarray:
    e = np.exp(x - x.max())
    return e / e.sum()


def ai_prob(onnx_path: str, tok_path: str, text: str) -> float:
    sess = ort.InferenceSession(onnx_path, providers=["CPUExecutionProvider"])
    tok = AutoTokenizer.from_pretrained(tok_path)
    enc = tok(text, return_tensors="np", truncation=True, max_length=192)
    logits = sess.run(None, {
        "input_ids": enc["input_ids"].astype(np.int64),
        "attention_mask": enc["attention_mask"].astype(np.int64),
    })[0][0]
    return float(softmax(logits)[1])


NATIVE_AI = (
    "It is important to note that artificial intelligence is transforming "
    "numerous industries. Furthermore, these systems provide significant "
    "efficiency gains and must be carefully evaluated before deployment."
)
# 由 verify_adversarial.py 對上句實際產生的改寫版本（T5 paraphraser）
PARAPHRASED = (
    "It is worth mentioning that artificial intelligence is altering the "
    "workings of many industries. Furthermore, these systems offer "
    "substantial productivity benefits and necessitate careful evaluation "
    "before deployment."
)

if __name__ == "__main__":
    baseline = ("artifacts/detector_int8.onnx", "artifacts/classifier")
    adversarial = ("artifacts/adversarial_int8.onnx", "artifacts/adv_classifier")

    print(f"{'模型':<14}{'原生 AI':>10}{'改寫後 AI':>12}{'規避成功度':>12}")
    for name, (onnx_path, tok_path) in [
        ("一般偵測器(A)", baseline),
        ("對抗模組(D)", adversarial),
    ]:
        native = ai_prob(onnx_path, tok_path, NATIVE_AI)
        para = ai_prob(onnx_path, tok_path, PARAPHRASED)
        drop = native - para  # 掉得越多，代表改寫越容易規避這個模型
        print(f"{name:<14}{native:>10.3f}{para:>12.3f}{drop:>12.3f}")
