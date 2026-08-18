"""評測已匯出的 ONNX 偵測器，逐語言給出可分性與操作點。

存在的理由：production 現行的 transformer 引擎是 `chatgpt-detector-roberta`
（roberta-base，純英文），對中文輸入從未跨越強訊號閾值，40% 的權重長期空轉。
本腳本用來驗證替代模型在**每個語言上**是否真的有鑑別力，而不是只看總體準確率——
總體數字會被樣本較多的語言蓋過去，正是這個專案先前踩到的坑。

同時報告分布內（HC3 驗證集）與分布外（手寫樣本）的表現。分布內數字一定漂亮，
真正決定能不能上線的是兩者的落差。

用法：
    .venv/bin/python evaluate_detector.py
    .venv/bin/python evaluate_detector.py --model artifacts/detector_int8.onnx \\
                                          --tokenizer artifacts/classifier
"""

from __future__ import annotations

import argparse
import json
import random
import re
from pathlib import Path

import numpy as np
import onnxruntime as ort
from transformers import AutoTokenizer

BASE = Path(__file__).parent
CJK = re.compile(r"[一-鿿]")

# 應用程式判定「強 AI 訊號」的閾值，與 transformer_engine.dart 一致
STRONG_SIGNAL = 0.6

# 分布外樣本：刻意不取自 HC3，用來看模型是否只學到資料集的表面特徵
OOD_SAMPLES = [
    ("中文 · 真人回憶散文", 0,
     "記得那年夏天特別熱，我們一群人擠在沒有冷氣的教室裡準備期末考。窗外的蟬叫得人心浮氣躁，"
     "黑板上還留著前一堂課沒擦乾淨的公式。阿明總是坐在最後一排，說那裡風比較大，"
     "其實大家都知道他是想睡覺方便。有一次被老師抓到，他還理直氣壯地說自己在「閉目思考」，"
     "結果全班笑了整整一節課。後來大家各奔東西，有人出國，有人留在原地。前陣子同學會，"
     "阿明居然變成了一間補習班的班主任，每天九點就到班盯學生自習。"),
    ("中文 · AI 制式文", 1,
     "隨著人工智慧技術的快速發展，其應用領域正不斷擴展。首先，在醫療產業方面，"
     "人工智慧能夠協助醫師進行影像判讀，大幅提升診斷的準確率與效率。其次，在製造業領域，"
     "透過導入智慧化生產線，企業得以有效降低營運成本並提高產品良率。此外，在教育產業中，"
     "個人化學習系統能夠依據學習狀況提供適性化的教材內容。值得注意的是，"
     "人工智慧的發展同時也帶來了諸多挑戰。綜上所述，其未來發展前景十分廣闊。"),
    ("英文 · 真人口語隨筆", 0,
     "Okay so this is going to sound stupid but I genuinely did not know that you were "
     "supposed to descale a kettle. Like, ever. I've had mine for about six years and last "
     "week my flatmate poured herself a cup of tea and just stared at it for a bit and then "
     "very carefully put it down and asked me when I'd last cleaned it. She showed me the "
     "inside with her phone torch and honestly it looked like a cave system."),
    ("英文 · AI 制式文", 1,
     "Artificial intelligence has fundamentally transformed numerous sectors in recent years. "
     "Firstly, within the healthcare industry, AI-powered diagnostic tools enable clinicians "
     "to interpret medical imaging with significantly greater accuracy and efficiency. "
     "Secondly, in the manufacturing sector, the implementation of intelligent production "
     "systems allows organizations to substantially reduce operational costs. Furthermore, "
     "personalized learning platforms can adapt instructional content to each student."),
]


def language_of(text: str) -> str:
    return "zh" if len(CJK.findall(text)) / max(len(text), 1) > 0.15 else "en"


def build_scorer(model_path: str, tokenizer_path: str):
    tok = AutoTokenizer.from_pretrained(tokenizer_path)
    sess = ort.InferenceSession(model_path, providers=["CPUExecutionProvider"])
    names = {i.name for i in sess.get_inputs()}

    def score(text: str) -> float:
        enc = tok(text, truncation=True, max_length=192, return_tensors="np")
        feed = {k: v.astype(np.int64) for k, v in enc.items() if k in names}
        logits = sess.run(None, feed)[0][0]
        exp = np.exp(logits - logits.max())
        return float((exp / exp.sum())[1])  # id2label: 1 = ai

    return score


def auc(human: list[float], ai: list[float]) -> float:
    wins = sum(1 for a in ai for h in human if a > h)
    ties = sum(1 for a in ai for h in human if a == h)
    return (wins + 0.5 * ties) / (len(ai) * len(human))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--model", default=str(BASE / "artifacts" / "detector_int8.onnx"))
    ap.add_argument("--tokenizer", default=str(BASE / "artifacts" / "classifier"))
    ap.add_argument("--n", type=int, default=120, help="每語言每類別的驗證樣本數")
    args = ap.parse_args()

    score = build_scorer(args.model, args.tokenizer)
    print(f"模型：{Path(args.model).name}\n")

    # ── 分布內：HC3 驗證集 ──────────────────────────────────────────
    rows = [json.loads(l) for l in (BASE / "data" / "val.jsonl").open(encoding="utf-8")]
    random.Random(7).shuffle(rows)
    cells: dict[tuple[str, int], list[str]] = {
        (lang, label): [] for lang in ("zh", "en") for label in (0, 1)
    }
    for row in rows:
        text = " ".join(row["text"].split())
        if len(text) < 200:
            continue
        key = (language_of(text), row["label"])
        if len(cells[key]) < args.n:
            cells[key].append(text)
        if all(len(v) >= args.n for v in cells.values()):
            break

    print("【分布內】HC3 驗證集")
    print(f"{'語言':<6}{'真人均值':>10}{'AI 均值':>10}{'AUC':>8}"
          f"{'命中率':>9}{'誤傷率':>9}")
    print("-" * 54)
    for lang, title in (("zh", "中文"), ("en", "英文")):
        h = [score(t) for t in cells[(lang, 0)]]
        a = [score(t) for t in cells[(lang, 1)]]
        tpr = sum(1 for v in a if v >= STRONG_SIGNAL) / len(a)
        fpr = sum(1 for v in h if v >= STRONG_SIGNAL) / len(h)
        print(f"{title:<6}{np.mean(h):>10.3f}{np.mean(a):>10.3f}"
              f"{auc(h, a):>8.3f}{tpr:>9.1%}{fpr:>9.1%}")

    # ── 分布外：手寫樣本 ────────────────────────────────────────────
    print("\n【分布外】非 HC3 來源的手寫樣本")
    print(f"{'樣本':<22}{'標籤':>6}{'AI 機率':>10}   判讀")
    print("-" * 56)
    correct = 0
    for name, label, text in OOD_SAMPLES:
        value = score(text)
        predicted = 1 if value >= STRONG_SIGNAL else 0
        correct += int(predicted == label)
        mark = "✓" if predicted == label else "✗"
        print(f"{name:<22}{'AI' if label else '真人':>6}{value:>10.3f}   "
              f"{'強 AI 訊號' if predicted else '未跨閾值':<10}{mark}")
    print(f"\n分布外正確 {correct}/{len(OOD_SAMPLES)}")
    print("分布內數字一定漂亮，真正決定能不能上線的是與分布外的落差。")


if __name__ == "__main__":
    main()
