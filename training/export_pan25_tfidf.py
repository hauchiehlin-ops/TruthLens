"""Export the official PAN 2025 TF-IDF/SVM baseline to a portable JSON asset."""

from __future__ import annotations

import argparse
import json
import pickle
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("model", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    with args.model.open("rb") as source:
        classifier, vectorizer = pickle.load(source)

    payload = {
        "format": "truthlens-pan25-tfidf-svm-v1",
        "source": "PAN 2025 Generative AI Authorship Verification baseline",
        "source_url": "https://github.com/pan-webis-de/pan-code/tree/master/clef25/generative-ai-authorship-verification",
        "license": "Apache-2.0",
        "ngram_range": [1, 4],
        "intercept": float(classifier.intercept_[0]),
        "vocabulary": {term: int(index) for term, index in vectorizer.vocabulary_.items()},
        "idf": vectorizer.idf_.tolist(),
        "coefficients": classifier.coef_[0].tolist(),
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(payload, ensure_ascii=True, separators=(",", ":")),
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()
