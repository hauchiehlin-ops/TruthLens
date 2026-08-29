"""Train and export the compact DetectRL-ZH character TF-IDF detector.

The production scorer is deliberately one-sided: a score above the development
human 99th percentile can support AI authorship, while a low score is not
treated as proof of human authorship.  This keeps an out-of-domain or heavily
rewritten generation from becoming a false human vote.

Example:
  .venv/bin/python export_detectrl_zh_char_svm.py \
    --train /path/to/NLPCC-2025-Task1/data/train.json \
    --dev /path/to/NLPCC-2025-Task1/data/dev.json \
    --test /path/to/NLPCC-2025-Task1/data/test_with_label.json \
    --output ../assets/models/detectrl_zh_char_svm.json
"""

from __future__ import annotations

import argparse
import json
import math
import re
from pathlib import Path

import numpy as np
from opencc import OpenCC
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import confusion_matrix, f1_score, roc_auc_score
from sklearn.svm import LinearSVC


_TO_SIMPLIFIED = OpenCC("t2s")
_TO_TRADITIONAL = OpenCC("s2t")


def _normalise(text: str) -> str:
    return re.sub(r"\s+", " ", text.lower()).strip()


def _load(path: Path) -> tuple[list[str], np.ndarray]:
    rows = json.loads(path.read_text(encoding="utf-8"))
    return [row["text"] for row in rows], np.asarray(
        [int(row["label"]) for row in rows], dtype=np.int8
    )


def _augment_scripts(
    texts: list[str], labels: np.ndarray
) -> tuple[list[str], np.ndarray]:
    """Present every sample in both Chinese scripts to the char model."""
    simplified = [_TO_SIMPLIFIED.convert(text) for text in texts]
    traditional = [_TO_TRADITIONAL.convert(text) for text in texts]
    return simplified + traditional, np.concatenate([labels, labels])


def _metrics(labels: np.ndarray, decisions: np.ndarray, cut: float) -> dict:
    predictions = decisions >= cut
    matrix = confusion_matrix(labels, predictions, labels=[0, 1])
    tn, fp, fn, tp = matrix.ravel()
    return {
        "auc": float(roc_auc_score(labels, decisions)),
        "macro_f1": float(f1_score(labels, predictions, average="macro")),
        "false_positive_rate": float(fp / max(1, fp + tn)),
        "machine_recall": float(tp / max(1, tp + fn)),
        "confusion_matrix": matrix.tolist(),
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--train", type=Path, required=True)
    parser.add_argument("--dev", type=Path, required=True)
    parser.add_argument("--test", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--max-features", type=int, default=50_000)
    parser.add_argument("--language", default="zh", help="recorded in the asset")
    # 開發集真人分數的分位數。0.99 對應約 1% 的開發集誤報率，但那是「在這份
    # 開發集上」——換一份人類寫作分布就可能超出預算。調高分位數是買安全邊際，
    # 代價是召回。預設維持 0.99 以保住既有資產的可重現性。
    parser.add_argument("--human-quantile", type=float, default=0.99)
    # 來源與生成器清單必須跟著實際訓練資料走。寫死會讓資產宣稱一份它沒讀過的
    # 語料——這種 provenance 不實比數字錯更難發現。
    parser.add_argument("--source", default="NLPCC 2025 Shared Task 1 / DetectRL-ZH")
    parser.add_argument(
        "--source-url", default="https://github.com/NLP2CT/NLPCC-2025-Task1"
    )
    parser.add_argument(
        "--training-generators",
        default="GPT-4o,GLM-4-flash,Qwen-turbo",
        help="comma separated",
    )
    parser.add_argument("--independent-test-generator", default="DeepSeek-V3")
    # 繁簡雙向增強只對中文有意義。套到拉丁／西里爾語料上，OpenCC 原樣回傳，
    # 等於把每一筆樣本複製一份——會膨脹開發集分位數並浪費模型容量。
    parser.add_argument(
        "--no-script-augment",
        dest="script_augment",
        action="store_false",
        help="disable the s2t/t2s augmentation (use for non-Chinese corpora)",
    )
    parser.set_defaults(script_augment=True)
    args = parser.parse_args()

    augment = _augment_scripts if args.script_augment else (lambda t, l: (t, l))
    train_text, train_labels = augment(*_load(args.train))
    dev_text, dev_labels = augment(*_load(args.dev))
    vectorizer = TfidfVectorizer(
        analyzer="char",
        ngram_range=(2, 5),
        min_df=4,
        max_features=args.max_features,
        sublinear_tf=True,
        preprocessor=_normalise,
        lowercase=False,
        dtype=np.float32,
    )
    train_matrix = vectorizer.fit_transform(train_text)
    classifier = LinearSVC(C=0.25, class_weight="balanced")
    classifier.fit(train_matrix, train_labels)

    dev_decisions = classifier.decision_function(vectorizer.transform(dev_text))
    # The shared-task rules explicitly reserve dev for threshold/calibration tuning.
    human_cut = float(np.quantile(dev_decisions[dev_labels == 0], args.human_quantile))
    calibrator = LogisticRegression(C=1000).fit(
        dev_decisions.reshape(-1, 1), dev_labels
    )
    platt_scale = float(calibrator.coef_[0][0])
    platt_intercept = float(calibrator.intercept_[0])

    validation = {"dev": _metrics(dev_labels, dev_decisions, human_cut)}
    if args.test:
        test_text, test_labels = _load(args.test)
        test_decisions = classifier.decision_function(vectorizer.transform(test_text))
        validation["independent_test"] = _metrics(
            test_labels, test_decisions, human_cut
        )
        if args.script_augment:
            traditional_test = [_TO_TRADITIONAL.convert(text) for text in test_text]
            traditional_decisions = classifier.decision_function(
                vectorizer.transform(traditional_test)
            )
            validation["independent_test_traditional"] = _metrics(
                test_labels, traditional_decisions, human_cut
            )

    size = len(vectorizer.vocabulary_)
    terms = [""] * size
    for term, index in vectorizer.vocabulary_.items():
        terms[index] = term
    payload = {
        "format": "truthlens-detectrl-zh-char-svm-v1",
        "source": args.source,
        "source_url": args.source_url,
        "training_generators": [
            g.strip() for g in args.training_generators.split(",") if g.strip()
        ],
        "independent_test_generator": args.independent_test_generator,
        "language": args.language,
        "normalization": "lowercase-collapse-whitespace"
        + ("; trained with s2t/t2s augmentation" if args.script_augment else ""),
        "ngram_range": [2, 5],
        "minimum_characters": 64,
        "ai_decision_cut": human_cut,
        "human_quantile": args.human_quantile,
        "platt_scale": platt_scale,
        "platt_intercept": platt_intercept,
        "intercept": float(classifier.intercept_[0]),
        "terms": terms,
        "idf": vectorizer.idf_.tolist(),
        "coefficients": classifier.coef_[0].tolist(),
        "validation": validation,
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(payload, ensure_ascii=False, separators=(",", ":")),
        encoding="utf-8",
    )

    print(json.dumps(validation, ensure_ascii=False, indent=2))
    print(
        f"features={size} cut={human_cut:.6f} "
        f"platt={platt_scale:.6f}*decision+{platt_intercept:.6f} "
        f"asset={args.output} ({args.output.stat().st_size / 1024 / 1024:.2f} MiB)"
    )


if __name__ == "__main__":
    main()
