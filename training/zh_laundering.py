"""模擬中文「AI 痕跡洗滌」工具的改寫手法，供中文改寫偵測模型（對抗模組 D）產生訓練資料。

依據：市售洗滌工具（例如使用者截圖中的 NonAI 第一階段）宣稱的作法是
- 剔除「值得注意的是」「此外」「綜上所述」等 AI 八股過渡詞
- 打碎「首先…其次…最後」這類制式排比
- 拉高長短句的突發性（句長變異係數 > 0.65）
- 把書面用語換成口語

這裡逐項以規則實作，全部只用標準函式庫、以種子決定結果，可重現。

重要：這些變換**同時**套用在人類與 AI 文本上（見 prepare_zh_adversarial.py）。
若只洗 AI 文本，模型會學到「被洗過＝AI」這種捷徑，而不是在洗滌之後仍殘留的
AI 特徵；真人文章經過同樣的處理後必須仍判為人類。

已知限制：規則式改寫比不上以大型語言模型「人類化」的真實洗滌。真實樣本請用
binoculars/generate_ai_corpus.py 的 humanized 語域產生，再以 --llm-humanized 併入。
"""

from __future__ import annotations

import random
import re
import statistics
from typing import Callable

# 句末標點：切句與重組都以這組為準
_SENTENCE_END = "。！？!?"
_SENTENCE_SPLIT = re.compile(r"(?<=[。！？!?])")

# AI 八股過渡詞（繁簡並列）。只在子句開頭刪除，句中出現的同字詞保留。
STOCK_TRANSITIONS = [
    "值得注意的是", "需要注意的是", "需要指出的是", "值得一提的是",
    "綜上所述", "综上所述", "總而言之", "总而言之", "總的來說", "总的来说", "總之", "总之",
    "此外", "另外", "與此同時", "与此同时", "不僅如此", "不仅如此", "除此之外",
    "事實上", "事实上", "可以說", "可以说", "毋庸置疑", "顯而易見", "显而易见",
    "首先", "其次", "再次", "最後", "最后",
    "一方面", "另一方面", "因此", "然而", "換句話說", "换句话说",
]

# 制式排比的序數開頭（「一是…二是…三是」「其一…其二…」）
_ORDINAL_MARKERS = re.compile(r"(?:(?<=[。；;，,\n])|^)\s*(?:一是|二是|三是|四是|其一|其二|其三|其四)[，,：:]?")

# 書面 → 口語。只收語意幾乎不變的替換；繁簡各列一次。
SYNONYMS = {
    "進行": "做", "进行": "做",
    "提升": "提高", "顯著": "明顯", "显著": "明显",
    "旨在": "是想", "透過": "靠", "通过": "靠",
    "因而": "所以", "從而": "這樣就", "从而": "这样就",
    "具有": "有", "存在": "有", "然而": "不過", "但是": "不過",
    "非常": "很", "十分": "很", "極為": "很", "极为": "很",
    "能夠": "能", "能够": "能", "以及": "還有",
    "對於": "對", "对于": "对", "關於": "說到", "关于": "说到",
    "使用": "用", "利用": "用", "採用": "用", "采用": "用",
    "目前": "現在", "当前": "现在", "當前": "現在",
}


def split_sentences(text: str) -> list[str]:
    return [s for s in _SENTENCE_SPLIT.split(text) if s.strip()]


def burstiness_cv(text: str) -> float:
    """句長（字元數）的變異係數。洗滌工具宣稱要把它拉高到 0.65 以上。"""
    lengths = [len(s.strip()) for s in split_sentences(text)]
    if len(lengths) < 2:
        return 0.0
    mean = statistics.fmean(lengths)
    return statistics.pstdev(lengths) / mean if mean else 0.0


def strip_stock_transitions(text: str, rng: random.Random) -> str:
    """刪除子句開頭、後面緊接標點的八股過渡詞（連同該標點）。"""
    pattern = re.compile(
        r"(^|[。！？!?；;\n])(\s*)("
        + "|".join(sorted({re.escape(t) for t in STOCK_TRANSITIONS}, key=len, reverse=True))
        # 必須接著標點才算過渡詞：「此外，」要刪，「此外的部分」不能動
        + r")[，,、：:]"
    )

    def drop(match: re.Match) -> str:
        # 保留少數，避免整篇一致地「完全沒有連接詞」反而成為新特徵
        return match.group(0) if rng.random() < 0.15 else match.group(1) + match.group(2)

    return pattern.sub(drop, text)


def break_parallelism(text: str, rng: random.Random) -> str:
    """拿掉「一是…二是…」這類制式序數開頭。"""
    return _ORDINAL_MARKERS.sub("", text)


def vary_sentence_rhythm(text: str, rng: random.Random) -> str:
    """拆長句、併短句，拉高句長變異。逐段處理，段落結構不變。

    長句在中段的逗號處斷成兩句；相鄰兩個短句以逗號接成一句。
    """
    return "\n\n".join(
        _vary_paragraph(p.strip(), rng) for p in re.split(r"\n\s*\n", text) if p.strip()
    )


def _vary_paragraph(paragraph: str, rng: random.Random) -> str:
    sentences = [s.strip() for s in split_sentences(paragraph)]
    if not sentences:
        return paragraph
    mean = statistics.fmean(len(s) for s in sentences)
    out: list[str] = []
    i = 0
    while i < len(sentences):
        body = sentences[i]
        commas = [m.start() for m in re.finditer(r"[，,]", body)]
        # 長句：在 1–2 個逗號處斷開，容許很短的片段——句長落差正是要製造的效果
        if len(body) >= mean and commas and rng.random() < 0.85:
            cuts = sorted(rng.sample(commas, min(len(commas), rng.choice((1, 2)))))
            start = 0
            for cut in cuts:
                out.append(body[start:cut] + "。")
                start = cut + 1
            out.append(body[start:])
            i += 1
            continue
        # 連續短句：以逗號接成一個長句
        run = [body]
        while (
            i + len(run) < len(sentences)
            and len(sentences[i + len(run)]) < mean
            and len(run) < 3
            and rng.random() < 0.7
        ):
            run.append(sentences[i + len(run)])
        if len(run) > 1:
            out.append("，".join(r[:-1] if r[-1:] in _SENTENCE_END else r for r in run[:-1]) + "，" + run[-1])
        else:
            out.append(body)
        i += len(run)
    return "".join(out)


def swap_synonyms(text: str, rng: random.Random) -> str:
    """把一部分書面用語換成口語。"""
    keys = sorted(SYNONYMS, key=len, reverse=True)
    pattern = re.compile("|".join(re.escape(k) for k in keys))

    def replace(match: re.Match) -> str:
        return SYNONYMS[match.group(0)] if rng.random() < 0.6 else match.group(0)

    return pattern.sub(replace, text)


def perturb_punctuation(text: str, rng: random.Random) -> str:
    """分號改逗號、少數頓號改逗號：真人寫作的標點較不規整。"""
    def semicolon(match: re.Match) -> str:
        return "，" if rng.random() < 0.7 else match.group(0)

    def enumeration(match: re.Match) -> str:
        return "，" if rng.random() < 0.3 else match.group(0)

    text = re.sub(r"[；;]", semicolon, text)
    return re.sub(r"、", enumeration, text)


TRANSFORMS: dict[str, Callable[[str, random.Random], str]] = {
    "strip_transitions": strip_stock_transitions,
    "break_parallelism": break_parallelism,
    "vary_rhythm": vary_sentence_rhythm,
    "synonyms": swap_synonyms,
    "punctuation": perturb_punctuation,
}


def launder(text: str, rng: random.Random, min_ops: int = 2, max_ops: int = 4) -> tuple[str, list[str]]:
    """隨機組合 2–4 種變換，回傳（改寫後文字、套用的變換名稱）。

    「去八股」永遠在最前面：它是洗滌工具的核心賣點，也是真實樣本中最常見的一步。
    """
    names = list(TRANSFORMS)
    count = rng.randint(min_ops, min(max_ops, len(names)))
    chosen = ["strip_transitions"] + rng.sample(names[1:], count - 1)
    for name in chosen:
        text = TRANSFORMS[name](text, rng)
    text = re.sub(r"\s*\n\s*\n\s*", "\n\n", text).strip()
    return text, chosen
