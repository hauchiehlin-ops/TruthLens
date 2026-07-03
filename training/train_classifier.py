"""微調多語言 Transformer 做 human/AI 二元分類。

自動選用 Apple Silicon MPS / CUDA / CPU。輸出 HuggingFace 模型到 artifacts/classifier。
"""
from __future__ import annotations

import argparse
import json

import numpy as np
import torch
from datasets import load_dataset
from sklearn.metrics import accuracy_score, f1_score, precision_recall_fscore_support
from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
    Trainer,
    TrainingArguments,
    set_seed,
)

from config import DATA_DIR, TrainConfig, quick_smoke


def _device() -> str:
    if torch.backends.mps.is_available():
        return "mps"
    if torch.cuda.is_available():
        return "cuda"
    return "cpu"


def _metrics(eval_pred):
    logits, labels = eval_pred
    preds = np.argmax(logits, axis=-1)
    precision, recall, f1, _ = precision_recall_fscore_support(
        labels, preds, average="binary", zero_division=0
    )
    return {
        "accuracy": accuracy_score(labels, preds),
        "precision": precision,
        "recall": recall,
        "f1": f1,
    }


def train(cfg: TrainConfig) -> None:
    set_seed(cfg.seed)
    device = _device()
    print(f"裝置：{device} | 基底模型：{cfg.base_model}")

    tokenizer = AutoTokenizer.from_pretrained(cfg.base_model)
    model = AutoModelForSequenceClassification.from_pretrained(
        cfg.base_model,
        num_labels=2,
        id2label={0: "human", 1: "ai"},
        label2id={"human": 0, "ai": 1},
    )

    data = load_dataset(
        "json",
        data_files={
            "train": f"{DATA_DIR}/train.jsonl",
            "val": f"{DATA_DIR}/val.jsonl",
        },
    )

    def tok(batch):
        return tokenizer(
            batch["text"],
            truncation=True,
            max_length=cfg.max_length,
            padding="max_length",
        )

    data = data.map(tok, batched=True, remove_columns=["text"])

    args = TrainingArguments(
        output_dir=f"{cfg.model_out}_ckpt",
        num_train_epochs=cfg.epochs,
        per_device_train_batch_size=cfg.batch_size,
        per_device_eval_batch_size=cfg.batch_size,
        learning_rate=cfg.learning_rate,
        warmup_ratio=cfg.warmup_ratio,
        weight_decay=cfg.weight_decay,
        eval_strategy="epoch",
        save_strategy="epoch",
        load_best_model_at_end=True,
        metric_for_best_model="f1",
        logging_steps=20,
        seed=cfg.seed,
        report_to=[],
    )

    trainer = Trainer(
        model=model,
        args=args,
        train_dataset=data["train"],
        eval_dataset=data["val"],
        compute_metrics=_metrics,
    )
    trainer.train()

    metrics = trainer.evaluate()
    print("驗證指標：", metrics)

    trainer.save_model(cfg.model_out)
    tokenizer.save_pretrained(cfg.model_out)
    with open(f"{cfg.model_out}/eval_metrics.json", "w", encoding="utf-8") as f:
        json.dump(metrics, f, ensure_ascii=False, indent=2)
    print(f"模型已存至 {cfg.model_out}")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--quick", action="store_true", help="煙霧測試（小模型/1 epoch）")
    args = ap.parse_args()
    train(quick_smoke() if args.quick else TrainConfig())
