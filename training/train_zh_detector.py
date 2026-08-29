"""Fine-tune a Chinese AI-text detector on the local combined corpus.

Why a new script rather than train_classifier.py: that one pulls HC3 straight
from the Hub and knows nothing about DetectRL-X or the record-level splits we
built. The corpus that matters here is already on disk, already split without
leakage, and already covers both the contemporary generators and the
assistant-reply register — the two gaps the shipped detector misses.

The output has to satisfy the app's inference contract (see
`lib/core/detection/onnx_detector_io.dart`): WordPiece tokenizer, `input_ids`
plus `attention_mask` only, two logits, AI at index 1, sequences truncated to
192 tokens. Anything else will load but score nonsense.

Example:
  .venv/bin/python train_zh_detector.py --max-train 40000
"""

from __future__ import annotations

import argparse
import json
import random
from pathlib import Path

import numpy as np
import torch
from sklearn.metrics import roc_auc_score
from torch.utils.data import Dataset
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
    Trainer,
    TrainingArguments,
    set_seed,
)

ROOT = Path(__file__).resolve().parent


class JsonlDataset(Dataset):
    def __init__(self, rows, tokenizer, max_length):
        self.rows = rows
        self.tokenizer = tokenizer
        self.max_length = max_length

    def __len__(self):
        return len(self.rows)

    def __getitem__(self, index):
        row = self.rows[index]
        encoded = self.tokenizer(
            row["text"],
            truncation=True,
            max_length=self.max_length,
            padding="max_length",
        )
        encoded = {k: torch.tensor(v) for k, v in encoded.items()
                   if k in {"input_ids", "attention_mask"}}
        encoded["labels"] = torch.tensor(int(row["label"]))
        return encoded


def _device() -> str:
    if torch.backends.mps.is_available():
        return "mps"
    if torch.cuda.is_available():
        return "cuda"
    return "cpu"


def _metrics(eval_pred):
    logits, labels = eval_pred
    probs = torch.softmax(torch.tensor(logits), dim=-1)[:, 1].numpy()
    preds = (probs >= 0.5).astype(int)
    human = labels == 0
    machine = labels == 1
    return {
        "auc": float(roc_auc_score(labels, probs)),
        "accuracy": float((preds == labels).mean()),
        "fpr": float(preds[human].mean()) if human.any() else 0.0,
        "recall": float(preds[machine].mean()) if machine.any() else 0.0,
    }


def load(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base-model", default="hfl/chinese-roberta-wwm-ext")
    parser.add_argument("--data-dir", type=Path, default=ROOT / "data/zh_combined3")
    parser.add_argument("--out-dir", type=Path, default=ROOT / "artifacts/zh_detector")
    parser.add_argument("--max-length", type=int, default=192)
    parser.add_argument("--batch-size", type=int, default=16)
    parser.add_argument("--epochs", type=float, default=1.0)
    parser.add_argument("--learning-rate", type=float, default=2e-5)
    parser.add_argument("--max-train", type=int, default=40000)
    parser.add_argument("--max-eval", type=int, default=4000)
    parser.add_argument("--seed", type=int, default=20260829)
    args = parser.parse_args()

    set_seed(args.seed)
    rng = random.Random(args.seed)

    train_rows = load(args.data_dir / "train.json")
    dev_rows = load(args.data_dir / "dev.json")
    rng.shuffle(train_rows)
    rng.shuffle(dev_rows)
    train_rows = train_rows[: args.max_train]
    dev_rows = dev_rows[: args.max_eval]
    print(
        f"train={len(train_rows)} dev={len(dev_rows)} device={_device()} "
        f"base={args.base_model}",
        flush=True,
    )

    tokenizer = AutoTokenizer.from_pretrained(args.base_model)
    model = AutoModelForSequenceClassification.from_pretrained(
        args.base_model,
        num_labels=2,
        id2label={0: "human", 1: "ai"},
        label2id={"human": 0, "ai": 1},
    )

    args.out_dir.mkdir(parents=True, exist_ok=True)
    trainer = Trainer(
        model=model,
        args=TrainingArguments(
            output_dir=str(args.out_dir / "checkpoints"),
            num_train_epochs=args.epochs,
            per_device_train_batch_size=args.batch_size,
            per_device_eval_batch_size=args.batch_size * 2,
            learning_rate=args.learning_rate,
            warmup_ratio=0.1,
            weight_decay=0.01,
            logging_steps=100,
            eval_strategy="no",
            save_strategy="no",
            seed=args.seed,
            report_to=[],
        ),
        train_dataset=JsonlDataset(train_rows, tokenizer, args.max_length),
        compute_metrics=_metrics,
    )
    trainer.train()

    metrics = trainer.evaluate(
        eval_dataset=JsonlDataset(dev_rows, tokenizer, args.max_length)
    )
    print(json.dumps(metrics, ensure_ascii=False, indent=2), flush=True)

    model.save_pretrained(args.out_dir)
    tokenizer.save_pretrained(args.out_dir)
    (args.out_dir / "train_metrics.json").write_text(
        json.dumps(metrics, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"saved to {args.out_dir}", flush=True)


if __name__ == "__main__":
    main()
