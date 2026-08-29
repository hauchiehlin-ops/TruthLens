"""Score an external Chinese corpus with the SHIPPED Transformer detector.

Mirrors the app's inference contract exactly (see
`lib/core/detection/onnx_detector_io.dart` and `onnx_detector_web.dart`):
WordPiece encode truncated to 192 tokens, `input_ids` + `attention_mask` only
(no token_type_ids), softmax over the two logits, take `ai_label_index`.

The operating point is the catalog's `ai_evidence_threshold`, not the model's
own 0.5: below that threshold the engine stays silent rather than voting human.

Example:
  .venv/bin/python evaluate_external_zh_transformer.py \
    --corpus data/semeval2024/semeval_zh.json \
    --corpus-id semeval-2024-task8-zh
"""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path

import numpy as np
import onnxruntime as ort
from tokenizers import Tokenizer

ROOT = Path(__file__).resolve().parent
DEFAULT_MODEL = ROOT / "artifacts/zhv3/aigc_detector_zhv3_int8.onnx"
DEFAULT_TOKENIZER = ROOT / "artifacts/zhv3/aigc_detector_zhv3_tokenizer.json"


def wilson_upper(successes: int, total: int, z: float = 1.6449) -> float:
    if total == 0:
        return 1.0
    p = successes / total
    denominator = 1 + z * z / total
    centre = p + z * z / (2 * total)
    half = z * math.sqrt(p * (1 - p) / total + z * z / (4 * total * total))
    return (centre + half) / denominator


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--corpus", type=Path, required=True)
    parser.add_argument("--corpus-id", required=True)
    parser.add_argument("--model", type=Path, default=DEFAULT_MODEL)
    parser.add_argument("--tokenizer", type=Path, default=DEFAULT_TOKENIZER)
    parser.add_argument("--max-len", type=int, default=192)
    parser.add_argument("--ai-label-index", type=int, default=1)
    parser.add_argument("--threshold", type=float, default=0.99)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--json-out", type=Path)
    parser.add_argument(
        "--calibration-corpus",
        type=Path,
        help="pick the threshold on THIS corpus, then report on --corpus. "
        "The two must be different corpora, or the reported number is just "
        "the selection restated.",
    )
    parser.add_argument("--target-fpr", type=float, default=0.01)
    args = parser.parse_args()

    tokenizer = Tokenizer.from_file(str(args.tokenizer))
    tokenizer.enable_truncation(max_length=args.max_len)
    tokenizer.enable_padding(length=None)
    session = ort.InferenceSession(str(args.model), providers=["CPUExecutionProvider"])
    input_names = {i.name for i in session.get_inputs()}
    print(f"model inputs: {sorted(input_names)}", flush=True)

    def score_corpus(path: Path):
        rows = json.loads(path.read_text(encoding="utf-8"))
        probabilities = np.empty(len(rows), dtype=np.float64)
        for start in range(0, len(rows), args.batch_size):
            chunk = rows[start : start + args.batch_size]
            encodings = tokenizer.encode_batch([r["text"] for r in chunk])
            feed = {
                "input_ids": np.array([e.ids for e in encodings], dtype=np.int64),
                "attention_mask": np.array(
                    [e.attention_mask for e in encodings], dtype=np.int64
                ),
            }
            feed = {k: v for k, v in feed.items() if k in input_names}
            logits = np.asarray(session.run(None, feed)[0], dtype=np.float64)
            shifted = logits - logits.max(axis=1, keepdims=True)
            exp = np.exp(shifted)
            probabilities[start : start + len(chunk)] = (
                exp[:, args.ai_label_index] / exp.sum(axis=1)
            )
            if start % (args.batch_size * 50) == 0:
                print(f"  {path.name} {start}/{len(rows)}", flush=True)
        return rows, probabilities

    calibration = None
    if args.calibration_corpus:
        if args.calibration_corpus.resolve() == args.corpus.resolve():
            raise SystemExit(
                "calibration and reporting corpora must differ — otherwise the "
                "reported figure is the selection restated, which the contract "
                "lists under prohibited_shortcuts."
            )
        cal_rows, cal_probs = score_corpus(args.calibration_corpus)
        cal_labels = np.array([int(r["label"]) for r in cal_rows])
        cal_human = cal_labels == 0
        # 取「在誤報預算內、最低」的門檻：門檻愈低召回愈高，因此在符合
        # 上界要求的候選中選最小者。用 Wilson 上界而非點估計，與合約的
        # fpr_confidence_bound 一致。
        chosen = 1.0
        for candidate in np.round(np.arange(0.50, 0.9991, 0.001), 3):
            fp = int(((cal_probs >= candidate) & cal_human).sum())
            if wilson_upper(fp, int(cal_human.sum())) <= args.target_fpr:
                chosen = float(candidate)
                break
        fp_at = int(((cal_probs >= chosen) & cal_human).sum())
        calibration = {
            "corpus": str(args.calibration_corpus),
            "documents": len(cal_rows),
            "human_documents": int(cal_human.sum()),
            "target_fpr": args.target_fpr,
            "chosen_threshold": chosen,
            "calibration_fpr": fp_at / int(cal_human.sum()),
            "calibration_fpr_upper_95": wilson_upper(fp_at, int(cal_human.sum())),
            "calibration_recall": float(
                (cal_probs[cal_labels == 1] >= chosen).mean()
            ),
        }
        print(json.dumps({"calibration": calibration}, ensure_ascii=False, indent=2), flush=True)
        args.threshold = chosen

    rows, probabilities = score_corpus(args.corpus)
    labels = np.array([int(r["label"]) for r in rows])
    models = [r.get("model") for r in rows]
    flagged = probabilities >= args.threshold

    human = labels == 0
    machine = labels == 1
    false_positives = int((flagged & human).sum())
    true_positives = int((flagged & machine).sum())

    # What would a less conservative gate buy?  The shipped 0.99 threshold was
    # calibrated in-corpus; on unseen generators the cost of that caution is
    # visible only by sweeping.  Selection still belongs to the calibration
    # split — this is reported for diagnosis, not as a new operating point.
    sweep = []
    for candidate in (0.5, 0.7, 0.8, 0.9, 0.95, 0.99, 0.999):
        hit = probabilities >= candidate
        fp = int((hit & human).sum())
        sweep.append({
            "threshold": candidate,
            "fpr": fp / int(human.sum()),
            "fpr_upper_95": wilson_upper(fp, int(human.sum())),
            "recall": int((hit & machine).sum()) / int(machine.sum()),
        })

    report = {
        "corpus_id": args.corpus_id,
        "component": "aigc-detector-zhv3-int8",
        "documents_scored": len(rows),
        "operating_point": args.threshold,
        "max_len": args.max_len,
        "human_documents": int(human.sum()),
        "machine_documents": int(machine.sum()),
        "fpr": false_positives / int(human.sum()),
        "fpr_upper_95": wilson_upper(false_positives, int(human.sum())),
        "recall": true_positives / int(machine.sum()),
        "calibration": calibration,
        "threshold_sweep": sweep,
        "per_generator": {
            name: {
                "n": int(sum(1 for m in models if m == name)),
                "above_threshold_rate": float(
                    flagged[[i for i, m in enumerate(models) if m == name]].mean()
                ),
            }
            for name in sorted({m for m in models if m})
        },
    }
    print(json.dumps(report, ensure_ascii=False, indent=2))
    if args.json_out:
        args.json_out.write_text(
            json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
        )


if __name__ == "__main__":
    main()
