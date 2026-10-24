#!/bin/bash
# 中文改寫偵測模型（對抗模組 D 的中文變體）一鍵流程：資料 → 微調 → INT8 ONNX → 量測 → 外部驗證。
#
# 只想補跑外部驗證（模型已訓練好）：ONLY_EXTERNAL=1 ./run_zh_adv_pipeline.sh
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

echo "=== 0/6 環境檢查 ==="
if [ ! -x "${PY}" ]; then
  echo "找不到 ${PY}：請先依 README「環境」一節建立 training/.venv" >&2
  exit 1
fi
${PY} - <<'CHECK'
import importlib.util, sys
# accelerate：transformers 的 Trainer 必須有它，缺了會到微調那一步才報錯
missing = [m for m in ("torch", "transformers", "accelerate", "onnx", "onnxruntime", "tokenizers", "sklearn", "huggingface_hub")
           if importlib.util.find_spec(m) is None]
if missing:
    sys.exit("缺少套件：" + " ".join(missing) + "\n請執行：.venv/bin/python -m pip install " + " ".join(
        "scikit-learn" if m == "sklearn" else m for m in missing))
import torch
print("PyTorch", torch.__version__, "· MPS 可用" if torch.backends.mps.is_available() else "· 未偵測到 MPS，將以 CPU 訓練（會很慢）")
if importlib.util.find_spec("opencc") is None:
    print("提示：未安裝 opencc-python-reimplemented，不會做繁體轉換（建議安裝）")
CHECK
if [ ! -s "${HC3}" ]; then
  echo "找不到 ${HC3}，從 Hugging Face 下載 HC3-Chinese ..."
  mkdir -p "$(dirname "${HC3}")"
  ${PY} - "${HC3}" <<'FETCH'
import shutil, sys
from huggingface_hub import hf_hub_download
path = hf_hub_download(repo_id="Hello-SimpleAI/HC3-Chinese", filename="all.jsonl", repo_type="dataset")
shutil.copyfile(path, sys.argv[1])
print("已存到", sys.argv[1])
FETCH
fi

if [ -z "${ONLY_EXTERNAL:-}" ]; then
echo "=== 1/6 準備資料 ==="
${PY} prepare_zh_adversarial.py --hc3 "${HC3}" --out-dir "${DATA}" \
  ${HUMANIZED:+--llm-humanized "${HUMANIZED}"}

echo "=== 2/6 微調（${BASE_MODEL}）==="
${PY} -u train_zh_detector.py --base-model "${BASE_MODEL}" --data-dir "${DATA}" \
  --out-dir "${MODEL}" --max-train "${MAX_TRAIN:-40000}" --epochs "${EPOCHS:-1}"

echo "=== 3/6 匯出 INT8 ONNX（與 App 相同的推論合約）==="
mkdir -p "$(dirname "${ONNX}")"
${PY} export_hf_sequence_classifier.py "${MODEL}" "${ONNX}"

echo "=== 4/6 依洗滌家族量測 ==="
${PY} evaluate_zh_adversarial.py --onnx "${ONNX}" --test "${DATA}/test.jsonl" \
  --predictions "${DATA}/predictions.jsonl" --report "${DATA}/report.json"

echo "=== 5/6 發布前操作點報告 ==="
${PY} evaluate_operating_point.py --predictions "${DATA}/predictions.jsonl" \
  --target-fpr 0.01 --report "${DATA}/operating_point.json" --required-language zh

fi

echo "=== 6/6 外部驗證（NLPCC-2025：dev 選門檻、test 報告；未參與訓練）==="
NLPCC=data/nlpcc2025
mkdir -p "${NLPCC}"
for f in dev.json test_with_label.json; do
  if [ ! -s "${NLPCC}/${f}" ]; then
    curl -sSL -o "${NLPCC}/${f}" "https://raw.githubusercontent.com/NLP2CT/NLPCC-2025-Task1/main/data/${f}"
  fi
done
SIGNATURE="sha256:$(shasum -a 256 "${ONNX}" | cut -d' ' -f1)"
${PY} evaluate_zh_adversarial.py --onnx "${ONNX}" \
  --calibration-corpus "${NLPCC}/dev.json" --external-corpus "${NLPCC}/test_with_label.json" \
  --predictions "${DATA}/external_predictions.jsonl" --report "${DATA}/external_report.json"
${PY} evaluate_operating_point.py --predictions "${DATA}/external_predictions.jsonl" \
  --target-fpr 0.01 --report "${DATA}/external_operating_point.json" --required-language zh \
  --independent-test --benchmark-id nlpcc-2025-task1 --detector-signature "${SIGNATURE}"

echo "=== 完成：${ONNX}（${SIGNATURE}）==="
echo "發布依據是外部驗證：${DATA}/external_operating_point.json 的 release_gate_passed，"
echo "以及 ${DATA}/external_report.json 的 human_laundering_fpr_shift 接近 0。"
echo "只有外部驗證通過，才把 external_operating_point.json 的門檻填入 catalog 的 ai_evidence_threshold。"
