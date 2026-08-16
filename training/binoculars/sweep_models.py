"""階段二：縮模型，量測「效果 vs 體積」的衰減曲線。

要回答的問題
------------
階段一證明了 Binoculars 在全尺寸模型上有效之後，真正的未知數是：
**縮到瀏覽器跑得動的尺寸，效果會掉多少？**

原論文用 7B 級模型。0.5B 甚至 135M 的配對能不能維持鑑別力，只能實測。
本腳本依序跑多組配對，輸出一張對照表，讓「最小可用配對」一眼可見。

用法
----
    .venv/bin/python binoculars/sweep_models.py \\
        --corpus binoculars/data/corpus.jsonl \\
        --out-dir binoculars/data/sweep

預設會跑 PRESET_PAIRS 由大到小的配對。想只跑其中幾組：

    --pairs "Qwen/Qwen2.5-0.5B|Qwen/Qwen2.5-0.5B-Instruct"

每組跑完會立刻寫檔，中途中斷不會白跑；已存在的結果預設略過（--force 可覆寫）。
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
import time
from pathlib import Path

# 由大到小。base / instruct 必須同系列，否則 tokenizer 對不齊。
# 估算體積為 INT8 量化後的**雙模型合計**，用來對照下載預算（已確認可接受 700MB–1GB）。
PRESET_PAIRS: list[tuple[str, str, str]] = [
    ("Qwen/Qwen2.5-1.5B", "Qwen/Qwen2.5-1.5B-Instruct", "約 3.0 GB"),
    ("Qwen/Qwen2.5-0.5B", "Qwen/Qwen2.5-0.5B-Instruct", "約 1.0 GB"),
    ("HuggingFaceTB/SmolLM2-360M", "HuggingFaceTB/SmolLM2-360M-Instruct", "約 0.7 GB"),
    ("HuggingFaceTB/SmolLM2-135M", "HuggingFaceTB/SmolLM2-135M-Instruct", "約 0.3 GB"),
]

# 下載預算上限（雙模型合計）。超過此值的配對即使效果好也不可行。
BUDGET_NOTE = "可接受上限：雙模型合計約 1 GB"


def slug(observer: str, performer: str) -> str:
    return f"{observer}__{performer}".replace("/", "-")


def run_pair(observer: str, performer: str, args, out_dir: Path) -> dict | None:
    name = slug(observer, performer)
    scores_path = out_dir / f"scores_{name}.jsonl"
    report_path = out_dir / f"report_{name}.md"

    if scores_path.exists() and not args.force:
        print(f"  略過（已存在）：{name}")
    else:
        cmd = [
            sys.executable,
            "binoculars/run_binoculars.py",
            "--corpus", str(args.corpus),
            "--out", str(scores_path),
            "--observer", observer,
            "--performer", performer,
            "--device", args.device,
            "--dtype", args.dtype,
            "--max-tokens", str(args.max_tokens),
        ]
        if args.limit:
            cmd += ["--limit", str(args.limit)]
        print(f"  計分中：{observer} / {performer}")
        started = time.time()
        proc = subprocess.run(cmd, capture_output=True, text=True)
        if proc.returncode != 0:
            print(f"  ✗ 失敗：{proc.stderr.strip().splitlines()[-1:] or proc.stdout[-300:]}")
            return None
        print(f"  ✓ 完成，耗時 {time.time() - started:.0f}s")

    # 評測（樣本量不足時 evaluate.py 會以 exit 1 拒絕出結論，這裡照實記錄）
    proc = subprocess.run(
        [
            sys.executable,
            "binoculars/evaluate.py",
            "--scores", str(scores_path),
            "--report", str(report_path),
            "--target-fpr", str(args.target_fpr),
        ],
        capture_output=True,
        text=True,
    )
    if proc.returncode != 0:
        print("  ⚠️  樣本量不足，此配對無法出具結論")
        return {"observer": observer, "performer": performer, "insufficient": True}

    return parse_report(report_path, observer, performer)


def parse_report(report_path: Path, observer: str, performer: str) -> dict | None:
    """從 evaluate.py 的 Markdown 表格取回關鍵數字。"""
    text = report_path.read_text(encoding="utf-8")
    row = next(
        (line for line in text.splitlines() if line.startswith("| **Binoculars**")),
        None,
    )
    baseline_row = next(
        (line for line in text.splitlines() if "裸 perplexity" in line), None
    )
    if not row:
        return None

    def cells(line: str) -> list[str]:
        return [c.strip() for c in line.strip().strip("|").split("|")]

    binoc = cells(row)
    base = cells(baseline_row) if baseline_row else ["", "", "", "", ""]
    return {
        "observer": observer,
        "performer": performer,
        "insufficient": False,
        "auc": float(binoc[1]),
        "recall": binoc[2],
        "threshold": float(binoc[4]),
        "baseline_auc": float(base[1]) if base[1] else None,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Binoculars 階段二：模型尺寸掃描")
    parser.add_argument("--corpus", type=Path, default=Path("binoculars/data/corpus.jsonl"))
    parser.add_argument("--out-dir", type=Path, default=Path("binoculars/data/sweep"))
    parser.add_argument(
        "--pairs",
        default="",
        help='自訂配對，格式 "observer|performer"，多組以逗號分隔',
    )
    parser.add_argument("--device", default="auto")
    parser.add_argument("--dtype", default="float16")
    parser.add_argument("--max-tokens", type=int, default=512)
    parser.add_argument("--target-fpr", type=float, default=0.05)
    parser.add_argument("--limit", type=int, default=0)
    parser.add_argument("--force", action="store_true", help="重跑已存在的結果")
    args = parser.parse_args()

    if not args.corpus.exists():
        sys.exit(f"找不到語料 {args.corpus}")

    if args.pairs:
        pairs = []
        for item in args.pairs.split(","):
            observer, _, performer = item.partition("|")
            if not performer:
                sys.exit(f'配對格式錯誤：{item}（應為 "observer|performer"）')
            pairs.append((observer.strip(), performer.strip(), "自訂"))
    else:
        pairs = PRESET_PAIRS

    args.out_dir.mkdir(parents=True, exist_ok=True)
    print(f"共 {len(pairs)} 組配對　|　{BUDGET_NOTE}\n")

    results = []
    for i, (observer, performer, size) in enumerate(pairs, 1):
        print(f"[{i}/{len(pairs)}] {observer} / {performer}（{size}）")
        result = run_pair(observer, performer, args, args.out_dir)
        if result:
            result["size"] = size
            results.append(result)
        print()

    # ── 匯總表 ────────────────────────────────────────────────────────
    lines = [
        "# Binoculars 階段二：模型尺寸衰減曲線",
        "",
        f"- 目標偽陽性率：{args.target_fpr:.0%}",
        f"- {BUDGET_NOTE}",
        "",
        "| 配對 | 估算體積 | Binoculars AUC | 召回率 | 對照組 AUC | 門檻 |",
        "|---|---|---|---|---|---|",
    ]
    for r in results:
        if r.get("insufficient"):
            lines.append(
                f"| {r['observer']} / {r['performer']} | {r.get('size', '')} "
                "| 樣本量不足 | — | — | — |"
            )
            continue
        baseline = f"{r['baseline_auc']:.4f}" if r["baseline_auc"] is not None else "—"
        lines.append(
            f"| {r['observer']} / {r['performer']} | {r['size']} "
            f"| **{r['auc']:.4f}** | {r['recall']} | {baseline} | {r['threshold']:.4f} |"
        )

    usable = [r for r in results if not r.get("insufficient")]
    lines += ["", "## 怎麼讀這張表", ""]
    if usable:
        best = max(usable, key=lambda r: r["auc"])
        lines += [
            f"- 最佳配對：**{best['observer']} / {best['performer']}**（AUC {best['auc']:.4f}）",
            "- 往下找**體積符合預算、且 AUC 尚未明顯崩掉**的最小配對，那就是要上線的組合。",
            "- 每個配對的門檻值都不同，**不可沿用**——階段三會重新校準。",
            "",
            "若最小可用配對超出下載預算，就只能降級為選擇性下載，",
            "或維持現有引擎 B 不做這項升級。",
        ]
    else:
        lines.append("- 沒有任何配對產出有效結果，請先確認語料量是否足夠。")

    summary = args.out_dir / "sweep_summary.md"
    summary.write_text("\n".join(lines), encoding="utf-8")
    print("\n".join(lines))
    print(f"\n匯總已寫入 {summary}")


if __name__ == "__main__":
    main()
