#!/bin/bash
set -e
echo "=== 開始訓練對抗模組 D ===" 
.venv/bin/python -u train_classifier.py --adversarial 2>&1 | tee artifacts/adv_train_full.log | grep -E "驗證指標|模型已存|Error|Traceback"
echo "=== 訓練完成，匯出 ONNX ===" 
.venv/bin/python -u export_onnx.py --adversarial 2>&1 | grep -E "匯出|量化|完成|Error|Traceback"
echo "=== 匯出完成，驗證推論 ===" 
.venv/bin/python -u verify_onnx.py --adversarial 2>&1 | grep -vE "Warning|warn" | tail -10
echo "=== ADV PIPELINE DONE ==="
