"""階段一輔助：以 API 批次生成「AI 對照組」語料。

為什麼不能隨便生
------------------
評測的目的是量「Binoculars 能不能認出 AI 產出」，而不是量「能不能認出流暢的
英文」。若不小心，會有兩個混淆因子讓結果**假性樂觀**：

1. **題材混淆**：AI 樣本若寫的是完全不同的主題，模型只要認出主題就能分開兩組。
   → 本腳本預設從 human 語料**反推題目**（`--from-human`），確保題材對齊。

2. **流暢度混淆**（最容易被忽略）：human 是非母語學生原稿，AI 若一律產出
   母語級的漂亮散文，兩組差的其實是「流暢度」而不是「來源」。這樣測出來的
   高分無法外推，而且上線後會把英文好的學生通通誤判。
   → 本腳本預設同時生成多種**語域**（`--styles`），包含刻意模仿非母語學生的版本。

3. **生成器單一**：真實情境裡學生用的是各種工具。建議至少跑兩個不同供應商，
   把輸出混在同一個資料夾裡。

用法
----
    export ANTHROPIC_API_KEY=sk-ant-...
    .venv/bin/python binoculars/generate_ai_corpus.py \\
        --from-human binoculars/data/corpus.jsonl \\
        --provider anthropic --model claude-sonnet-5 \\
        --out-dir binoculars/data/ai_generated

先看會送出什麼、不花錢：加 `--dry-run`。

產出為一份一檔的 .txt，可直接餵給 prepare_corpus.py 的 `--ai-dir`。
另外寫出 manifest.jsonl 記錄每份的供應商／模型／語域／題目來源，方便追溯。
"""

from __future__ import annotations

import argparse
import json
import os
import random
import re
import sys
import time
from pathlib import Path

import requests

# ── 語域設定 ──────────────────────────────────────────────────────────
# 刻意涵蓋從「母語級」到「非母語學生」的光譜，避免流暢度混淆。
STYLES: dict[str, str] = {
    "standard": (
        "Write it as a competent university student would: clear, well organised, "
        "and reasonably polished."
    ),
    "polished": (
        "Write it as a strong native-speaker student would: fluent, varied sentence "
        "structure, confident academic register."
    ),
    "nonnative": (
        "Write it as a non-native English speaker at intermediate level would: simpler "
        "vocabulary, somewhat repetitive sentence patterns, occasional slightly "
        "awkward phrasing and article or preposition slips. Do not caricature it — "
        "it should read as genuine student work, not as a parody."
    ),
    "casual": (
        "Write it in a plainer, less formal register, as a student who is writing "
        "quickly and not worrying much about polish."
    ),
}

PROMPT_TEMPLATE = """Write an original piece of academic writing on the following topic.

Topic: {topic}

Requirements:
- About {words} words.
- {style}
- Write the essay itself only. No title, no preamble, no meta-commentary, no bullet
  summary at the end.
- Treat the topic as a starting point and write your own piece. Do not paraphrase or
  continue any text you may have been shown; do not reuse its phrasing."""


# ── 供應商 ────────────────────────────────────────────────────────────
def call_anthropic(model: str, prompt: str, max_tokens: int, timeout: int) -> str:
    key = os.environ.get("ANTHROPIC_API_KEY")
    if not key:
        sys.exit("請設定環境變數 ANTHROPIC_API_KEY")
    resp = requests.post(
        "https://api.anthropic.com/v1/messages",
        headers={
            "x-api-key": key,
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
        },
        json={
            "model": model,
            "max_tokens": max_tokens,
            "messages": [{"role": "user", "content": prompt}],
        },
        timeout=timeout,
    )
    resp.raise_for_status()
    blocks = resp.json().get("content", [])
    return "".join(b.get("text", "") for b in blocks if b.get("type") == "text")


def call_openai_compatible(
    model: str, prompt: str, max_tokens: int, timeout: int, base_url: str, env_key: str
) -> str:
    key = os.environ.get(env_key)
    if not key:
        sys.exit(f"請設定環境變數 {env_key}")
    resp = requests.post(
        f"{base_url}/chat/completions",
        headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
        json={
            "model": model,
            "max_tokens": max_tokens,
            "messages": [{"role": "user", "content": prompt}],
        },
        timeout=timeout,
    )
    resp.raise_for_status()
    return resp.json()["choices"][0]["message"]["content"]


def call_gemini(model: str, prompt: str, max_tokens: int, timeout: int) -> str:
    key = os.environ.get("GOOGLE_API_KEY")
    if not key:
        sys.exit("請設定環境變數 GOOGLE_API_KEY")
    resp = requests.post(
        f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent",
        headers={"x-goog-api-key": key, "Content-Type": "application/json"},
        json={
            "contents": [{"parts": [{"text": prompt}]}],
            "generationConfig": {"maxOutputTokens": max_tokens},
        },
        timeout=timeout,
    )
    resp.raise_for_status()
    parts = resp.json()["candidates"][0]["content"]["parts"]
    return "".join(p.get("text", "") for p in parts)


PROVIDERS = {
    "anthropic": lambda m, p, t, to: call_anthropic(m, p, t, to),
    "openai": lambda m, p, t, to: call_openai_compatible(
        m, p, t, to, "https://api.openai.com/v1", "OPENAI_API_KEY"
    ),
    "groq": lambda m, p, t, to: call_openai_compatible(
        m, p, t, to, "https://api.groq.com/openai/v1", "GROQ_API_KEY"
    ),
    "together": lambda m, p, t, to: call_openai_compatible(
        m, p, t, to, "https://api.together.xyz/v1", "TOGETHER_API_KEY"
    ),
    "gemini": lambda m, p, t, to: call_gemini(m, p, t, to),
}


# ── 題目來源 ──────────────────────────────────────────────────────────
# PDF 常見的連字（ligature），不處理會一路髒到提示詞裡
LIGATURES = {"\ufb01": "fi", "\ufb02": "fl", "\ufb00": "ff", "\ufb03": "ffi", "\ufb04": "ffl"}


def looks_like_header(sentence: str) -> bool:
    """判斷是否為頁首／標題／作者列這類非正文片段。

    這些片段常混在 PDF 第一塊裡，若當成題目送進 API，不但題材對不準，
    還會把**作者姓名**一起送出去。
    """
    words = sentence.split()
    if len(words) < 6:
        return True
    # 大寫字佔比過高 → 多半是全大寫標題
    alpha = [w for w in words if any(c.isalpha() for c in w)]
    if alpha and sum(w.isupper() for w in alpha) / len(alpha) > 0.4:
        return True
    # 作者列樣式：by X.Y. Zzz / 一堆首字母縮寫
    if re.search(r"\bby\s+[A-Z]\.", sentence):
        return True
    if len(re.findall(r"\b[A-Z]\.[A-Z]?\.", sentence)) >= 2:
        return True
    return False


def topic_from_text(text: str, max_words: int = 45) -> str:
    """從 human 樣本取開頭數句當題目線索。

    刻意只取很短一段：取太多會讓模型傾向改寫原文，那測到的就變成
    「改寫偵測」而不是「AI 生成偵測」。同時濾掉頁首／標題／作者列，
    避免題材對不準，也避免把姓名送進第三方 API。
    """
    for src, dst in LIGATURES.items():
        text = text.replace(src, dst)
    text = re.sub(r"\s+", " ", text).strip()
    # PDF 首字放大（drop cap）常被抽成「C ircular」這種斷字
    text = re.sub(r"\b([A-Z]) ([a-z]{2,})", r"\1\2", text)
    sentences = [s for s in re.split(r"(?<=[.!?])\s+", text) if s.strip()]
    body = [s for s in sentences if not looks_like_header(s)]
    if not body:
        body = sentences  # 全被濾掉時退回原始，至少還有東西可用

    hint = ""
    for sentence in body:
        if hint and len((hint + " " + sentence).split()) > max_words:
            break
        hint = (hint + " " + sentence).strip()
        if len(hint.split()) >= max_words:
            break

    # 標題與正文之間常沒有句號，會被併成同一「句」而躲過上面的頁首過濾；
    # 這裡再剝掉開頭連續的全大寫詞（標題殘留）。
    # 連續 3 個以上的全大寫詞視為標題，連同它前面的殘字一起剝掉
    hint = re.sub(r"^.*?(?:[A-Z][A-Z\-']{1,}\s+){3,}", "", hint).strip()
    return " ".join(hint.split()[:max_words])


def load_topics(args) -> list[dict]:
    if args.topics_file:
        lines = [
            line.strip()
            for line in args.topics_file.read_text(encoding="utf-8").splitlines()
            if line.strip()
        ]
        return [{"topic": t, "words": args.target_words, "src": "topics-file"} for t in lines]

    if not args.from_human:
        sys.exit("請指定 --from-human 或 --topics-file")
    if not args.from_human.exists():
        sys.exit(f"找不到 {args.from_human}，請先跑 prepare_corpus.py")

    rows = [
        json.loads(line)
        for line in args.from_human.read_text(encoding="utf-8").splitlines()
        if line
    ]
    human = [r for r in rows if r.get("label") == "human"]
    if not human:
        sys.exit("語料裡沒有 human 樣本，無法反推題目")

    # 一份原始文件只取一個題目，避免同一篇被重複生成多次而灌水
    seen: set[str] = set()
    topics = []
    for row in human:
        if row["doc_id"] in seen:
            continue
        seen.add(row["doc_id"])
        topics.append(
            {
                "topic": topic_from_text(row["text"]),
                "words": row.get("words", args.target_words),
                "src": row["doc_id"],
            }
        )
    return topics


def main() -> None:
    parser = argparse.ArgumentParser(description="批次生成 AI 對照組語料")
    parser.add_argument("--from-human", type=Path, help="由 human 語料反推題目（建議）")
    parser.add_argument("--topics-file", type=Path, help="自備題目清單，一行一題")
    parser.add_argument("--provider", default="anthropic", choices=sorted(PROVIDERS))
    parser.add_argument("--model", default="claude-sonnet-5")
    parser.add_argument("--out-dir", type=Path, default=Path("binoculars/data/ai_generated"))
    parser.add_argument(
        "--styles",
        default="standard,nonnative",
        help=f"逗號分隔，可選：{','.join(STYLES)}（預設同時含非母語語域以避免流暢度混淆）",
    )
    parser.add_argument("--per-topic", type=int, default=1, help="每個題目每種語域生成幾份")
    parser.add_argument("--target-words", type=int, default=400)
    parser.add_argument("--max-tokens", type=int, default=1500)
    parser.add_argument("--timeout", type=int, default=120)
    parser.add_argument("--sleep", type=float, default=1.0, help="每次請求間隔秒數")
    parser.add_argument("--retries", type=int, default=3)
    parser.add_argument("--limit", type=int, default=0, help="只做前 N 個任務")
    parser.add_argument("--dry-run", action="store_true", help="只印出提示詞，不呼叫 API")
    args = parser.parse_args()

    styles = [s.strip() for s in args.styles.split(",") if s.strip()]
    for style in styles:
        if style not in STYLES:
            sys.exit(f"未知語域 {style}；可選：{', '.join(STYLES)}")

    topics = load_topics(args)

    # 隱私提醒：--from-human 會把 human 語料的開頭片段送到第三方 API。
    # 本專案其餘部分都是本機推論，這裡是唯一會外送文字的環節，必須講清楚。
    if args.from_human and not args.dry_run:
        print(
            "\n⚠️  --from-human 會把每份 human 樣本的**開頭約 45 字**送到 "
            f"{args.provider} 以反推題目。\n"
            "   已自動濾除標題與作者列，但仍是學生原文片段。若不接受，請改用\n"
            "   --topics-file 自備題目清單（完全不外送學生文字）。\n"
            "   先用 --dry-run 可檢視實際會送出的每一段內容。"
        )
        if input("   繼續？(yes/N) ").strip().lower() not in {"yes", "y"}:
            sys.exit("已取消")

    tasks = [
        {"topic": t, "style": style, "index": i}
        for t in topics
        for style in styles
        for i in range(args.per_topic)
    ]
    random.Random(0).shuffle(tasks)  # 打散，避免同語域連續呼叫造成快取式相似
    if args.limit:
        tasks = tasks[: args.limit]

    print(f"題目 {len(topics)} 個 × 語域 {len(styles)} 種 × 每題 {args.per_topic} 份")
    print(f"→ 共 {len(tasks)} 個生成任務（{args.provider} / {args.model}）")

    args.out_dir.mkdir(parents=True, exist_ok=True)
    manifest_path = args.out_dir / "manifest.jsonl"
    done = set()
    if manifest_path.exists():
        for line in manifest_path.read_text(encoding="utf-8").splitlines():
            if line:
                done.add(json.loads(line)["file"])

    generated = failed = skipped = 0
    with manifest_path.open("a", encoding="utf-8") as manifest:
        for n, task in enumerate(tasks, 1):
            topic = task["topic"]
            name = (
                f"{args.provider}_{re.sub(r'[^a-zA-Z0-9]+', '-', args.model)[:24]}"
                f"_{task['style']}_{topic['src']}_{task['index']}.txt"
            )
            out_path = args.out_dir / name
            if name in done or out_path.exists():
                skipped += 1
                continue

            prompt = PROMPT_TEMPLATE.format(
                topic=topic["topic"], words=topic["words"], style=STYLES[task["style"]]
            )

            if args.dry_run:
                print(f"\n─── [{n}/{len(tasks)}] {name} ───\n{prompt}")
                continue

            text = ""
            for attempt in range(1, args.retries + 1):
                try:
                    text = PROVIDERS[args.provider](
                        args.model, prompt, args.max_tokens, args.timeout
                    ).strip()
                    break
                except Exception as exc:  # noqa: BLE001 - 單筆失敗不中斷整批
                    wait = 2**attempt
                    print(f"  [{n}] 第 {attempt} 次失敗（{exc}），{wait}s 後重試")
                    time.sleep(wait)

            if not text:
                failed += 1
                print(f"  [{n}] 放棄 {name}")
                continue

            out_path.write_text(text, encoding="utf-8")
            manifest.write(
                json.dumps(
                    {
                        "file": name,
                        "provider": args.provider,
                        "model": args.model,
                        "style": task["style"],
                        "topic_src": topic["src"],
                        "words": len(text.split()),
                    },
                    ensure_ascii=False,
                )
                + "\n"
            )
            manifest.flush()
            generated += 1
            if n % 5 == 0 or n == len(tasks):
                print(f"  {n}/{len(tasks)}　已生成 {generated}　略過 {skipped}　失敗 {failed}")
            time.sleep(args.sleep)

    if args.dry_run:
        print(f"\n（dry-run，未呼叫 API。共 {len(tasks)} 個任務）")
        return

    print(f"\n完成：生成 {generated}、略過 {skipped}（已存在）、失敗 {failed}")
    print(f"輸出目錄 {args.out_dir}")
    print("\n接著：")
    print(
        "  .venv/bin/python binoculars/prepare_corpus.py \\\n"
        f"      --human-dir <你的學生作業資料夾> \\\n"
        f"      --ai-dir {args.out_dir}"
    )
    if generated and len({t["style"] for t in tasks}) == 1:
        print(
            "\n⚠️  只用了單一語域。建議至少加上 nonnative，"
            "否則評測可能只是在量「流暢度」而不是「AI 生成」。"
        )


if __name__ == "__main__":
    main()
