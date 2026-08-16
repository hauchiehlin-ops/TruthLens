"""階段一步驟 3：評測與報表。

回答的核心問題
--------------
Binoculars 在**你自己的語料**上，是否真的優於現有引擎 B 所用的裸 perplexity？
特別是在非母語英文寫作上，偽陽性有沒有下降？

輸出的關鍵指標
--------------
* ROC-AUC：整體排序能力
* **固定偽陽性率下的召回率**（預設 5%）：比 AUC 更貼近實際使用——
  App 的共形校準就是以偽陽性率為設定單位。
* 在該操作點上的門檻值：可直接填回 `BinocularsScorer.placeholderThreshold`

樣本量把關
----------
與 App 的棄權設計同一精神：**獨立文件數**不足時直接拒絕出具結論。
把同一份文件切成很多塊並不會增加獨立資訊量，卻會讓 AUC 看起來很漂亮。

用法
----
    .venv/bin/python binoculars/evaluate.py \
        --scores binoculars/data/scores.jsonl \
        --report binoculars/data/report.md
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np
from sklearn.metrics import roc_auc_score, roc_curve

# 出具結論所需的最少**獨立文件**數（每類）
MIN_DOCS_PER_CLASS = 30


def load(path: Path) -> list[dict]:
    if not path.exists():
        sys.exit(f"找不到 {path}，請先跑 run_binoculars.py")
    return [json.loads(line) for line in path.read_text().splitlines() if line]


def metrics_at_fpr(y_true: np.ndarray, scores: np.ndarray, target_fpr: float) -> dict:
    """scores 越高越像 AI。回傳在目標偽陽性率下的召回率與門檻。"""
    fpr, tpr, thresholds = roc_curve(y_true, scores)
    ok = np.where(fpr <= target_fpr)[0]
    idx = ok[-1] if len(ok) else 0
    return {
        "auc": float(roc_auc_score(y_true, scores)),
        "fpr": float(fpr[idx]),
        "recall": float(tpr[idx]),
        "threshold": float(thresholds[idx]),
    }


def evaluate_metric(rows: list[dict], key: str, higher_is_ai: bool, target_fpr: float):
    y_true = np.array([1 if r["label"] == "ai" else 0 for r in rows])
    raw = np.array([r[key] for r in rows], dtype=float)
    # 統一成「越高越像 AI」再算 ROC
    scores = raw if higher_is_ai else -raw
    out = metrics_at_fpr(y_true, scores, target_fpr)
    # 門檻換算回原始尺度，方便直接填進程式
    out["threshold_raw"] = out["threshold"] if higher_is_ai else -out["threshold"]
    out["direction"] = "越高越像 AI" if higher_is_ai else "越低越像 AI"
    return out


def describe(rows: list[dict], key: str) -> str:
    human = np.array([r[key] for r in rows if r["label"] == "human"], dtype=float)
    ai = np.array([r[key] for r in rows if r["label"] == "ai"], dtype=float)
    return (
        f"human 平均 {human.mean():.4f}（標準差 {human.std(ddof=1):.4f}）／"
        f"ai 平均 {ai.mean():.4f}（標準差 {ai.std(ddof=1):.4f}）"
    )


def main() -> None:
    parser = argparse.ArgumentParser(description="Binoculars 階段一：評測")
    parser.add_argument("--scores", type=Path, default=Path("binoculars/data/scores.jsonl"))
    parser.add_argument("--report", type=Path, default=Path("binoculars/data/report.md"))
    parser.add_argument("--target-fpr", type=float, default=0.05)
    args = parser.parse_args()

    rows = load(args.scores)
    human_docs = len({r["doc_id"] for r in rows if r["label"] == "human"})
    ai_docs = len({r["doc_id"] for r in rows if r["label"] == "ai"})
    human_chunks = sum(1 for r in rows if r["label"] == "human")
    ai_chunks = sum(1 for r in rows if r["label"] == "ai")

    lines: list[str] = ["# Binoculars 階段一評測報告", ""]
    lines.append(
        f"- human：**{human_docs}** 份獨立文件 / {human_chunks} 個樣本\n"
        f"- ai　：**{ai_docs}** 份獨立文件 / {ai_chunks} 個樣本\n"
        f"- 目標偽陽性率：{args.target_fpr:.0%}"
    )
    lines.append("")

    # ── 樣本量把關（與 App 的棄權同一精神）────────────────────────────
    if human_docs < MIN_DOCS_PER_CLASS or ai_docs < MIN_DOCS_PER_CLASS:
        lines += [
            "## ⛔ 樣本量不足，不出具結論",
            "",
            f"每一類至少需要 **{MIN_DOCS_PER_CLASS} 份獨立文件**，目前 "
            f"human {human_docs} 份、ai {ai_docs} 份。",
            "",
            "把同一份文件切成很多塊**不會**增加獨立資訊量，卻會讓 AUC 看起來",
            "漂亮得多——同一位作者、同一個主題的切塊彼此高度相關，模型只要",
            "認出「這是誰寫的」就能拿到高分，而不是真的認出「這是不是 AI 寫的」。",
            "",
            f"另外，在 {args.target_fpr:.0%} 的偽陽性率下，human 樣本數至少要有 "
            f"{int(1 / args.target_fpr)} 份，這個操作點才存在。",
            "",
            "### 需要補齊的語料",
            "",
            "- **human**：非母語英文的**學生作業原稿**（未經期刊編輯潤稿）。",
            "  已出版的論文經過審稿與編輯，正好把我們要檢驗的非母語特徵磨掉了，",
            "  因此不是合適的代理樣本。",
            "- **ai**：用 ChatGPT／Claude／Gemini 就同樣題目產生的文章，",
            "  題材與長度盡量與 human 對齊，否則模型會學到「主題」而非「來源」。",
            "",
        ]
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text("\n".join(lines), encoding="utf-8")
        print("\n".join(lines))
        print(f"\n報告已寫入 {args.report}")
        sys.exit(1)

    # ── 正式評測 ─────────────────────────────────────────────────────
    binoculars = evaluate_metric(rows, "binoculars", higher_is_ai=False, target_fpr=args.target_fpr)
    baseline = evaluate_metric(
        rows, "log_perplexity", higher_is_ai=False, target_fpr=args.target_fpr
    )

    lines += [
        "## 結果",
        "",
        "| 指標 | AUC | 召回率 @ 目標 FPR | 實際 FPR | 門檻 |",
        "|---|---|---|---|---|",
        f"| **Binoculars** | {binoculars['auc']:.4f} | {binoculars['recall']:.1%} "
        f"| {binoculars['fpr']:.1%} | {binoculars['threshold_raw']:.4f} |",
        f"| 裸 perplexity（現有引擎 B） | {baseline['auc']:.4f} | {baseline['recall']:.1%} "
        f"| {baseline['fpr']:.1%} | {baseline['threshold_raw']:.4f} |",
        "",
        f"- Binoculars 方向：{binoculars['direction']}",
        f"- Binoculars 分布：{describe(rows, 'binoculars')}",
        f"- perplexity 分布：{describe(rows, 'log_perplexity')}",
        "",
    ]

    auc_gain = binoculars["auc"] - baseline["auc"]
    recall_gain = binoculars["recall"] - baseline["recall"]
    lines += [
        "## 決策點",
        "",
        f"AUC 差異 **{auc_gain:+.4f}**、"
        f"{args.target_fpr:.0%} FPR 下召回率差異 **{recall_gain:+.1%}**。",
        "",
    ]
    if recall_gain > 0.05:
        lines += [
            "✅ **建議進入階段二**（縮模型量衰減曲線）。",
            "",
            f"可先把 `BinocularsScorer.placeholderThreshold` 暫定為 "
            f"`{binoculars['threshold_raw']:.4f}`，但這是**全尺寸模型**的門檻，",
            "換小模型後必須重新校準。",
        ]
    else:
        lines += [
            "⛔ **建議停止**，把資源投回本地基準校準（支柱 2）。",
            "",
            "在你自己的語料上，Binoculars 相對於現有裸 perplexity 沒有帶來足夠",
            "的改善。全尺寸模型都贏不了的話，縮到瀏覽器可跑的尺寸只會更差。",
        ]
    lines.append("")

    args.report.parent.mkdir(parents=True, exist_ok=True)
    args.report.write_text("\n".join(lines), encoding="utf-8")
    print("\n".join(lines))
    print(f"\n報告已寫入 {args.report}")


if __name__ == "__main__":
    main()
