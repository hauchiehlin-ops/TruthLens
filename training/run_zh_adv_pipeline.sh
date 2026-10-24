#!/bin/bash
# 中文改寫偵測模型（對抗模組 D 的中文變體）一鍵流程：資料 → 微調 → INT8 ONNX → 量測。
#
# 需要：training/.venv（見 README）、HC3-Chinese all.jsonl，以及能下載基底模型
# （hfl/chinese-roberta-wwm-ext；已訓練過中文偵測器的機器通常已有快取）。
#
# 可調環境變數：
#   HC3=data/hc3_zh/all.jsonl          HC3-Chinese 原始檔
#   HUMANIZED=path.jsonl               LLM 人類化的 AI 文本（強烈建議；見 README）
#   BASE_MODEL=hfl/chinese-roberta-wwm-ext
#   MAX_TRAIN=40000  EPOCHS=1
set -euo pipefail
cd "$(dirname "$0")"

PY=.venv/bin/python
HC3=${HC3:-data/hc3_zh/all.jsonl}
BASE_MODEL=${BASE_MODEL:-hfl/chinese-roberta-wwm-ext}
DATA=data/zh_adversarial
MODEL=artifacts/zh_adversarial
ONNX=artifacts/zh_adversarial_onnx/model_int8.onnx

echo "=== 1/5 準備資料 ==="
$PY prepare_zh_adversarial.py --hc3 "$HC3" --out-dir "$DATA" \
  ${HUMANIZED:+--llm-humanized "$HUMANIZED"}

echo "=== 2/5 微調（$BASE_MODEL）==="
$PY -u train_zh_detector.py --base-model "$BASE_MODEL" --data-dir "$DATA" \
  --out-dir "$MODEL" --max-train "${MAX_TRAIN:-40000}" --epochs "${EPOCHS:-1}"

echo "=== 3/5 匯出 INT8 ONNX（與 App 相同的推論合約）==="
mkdir -p "$(dirname "$ONNX")"
$PY export_hf_sequence_classifier.py "$MODEL" "$ONNX"

echo "=== 4/5 依洗滌家族量測 ==="
$PY evaluate_zh_adversarial.py --onnx "$ONNX" --test "$DATA/test.jsonl" \
  --predictions "$DATA/predictions.jsonl" --report "$DATA/report.json"

echo "=== 5/5 發布前操作點報告 ==="
$PY evaluate_operating_point.py --predictions "$DATA/predictions.jsonl" \
  --target-fpr 0.01 --report "$DATA/operating_point.json" --required-language zh

echo "=== 完成：$ONNX ==="
echo "發布前請確認 $DATA/report.json 的 human_laundering_fpr_shift 接近 0，"
echo "再把 operating_point.json 的門檻填入 catalog 的 ai_evidence_threshold。"
