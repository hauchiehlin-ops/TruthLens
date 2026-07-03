"""TruthLens 檢測模型訓練設定。

第一版使用公開資料集（HC3 英文 + 中文）微調多語言 Transformer，
做人類(0)/AI(1) 二元分類。所有路徑相對於 training/ 目錄。
"""
from __future__ import annotations

import os
from dataclasses import dataclass, field

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(BASE_DIR, "data")
OUTPUT_DIR = os.path.join(BASE_DIR, "artifacts")


@dataclass
class TrainConfig:
    # 第一版 baseline 用 distilbert-base-multilingual-cased（多語言、輕量、MPS 上約 0.5s/step）。
    # production 目標為 plan 指定的 "xlm-roberta-base"（104 語，品質較高，但 MPS 上 ~2s/step
    # 需數小時，建議在有 CUDA 或過夜跑）。切換只需改此行。
    base_model: str = "distilbert-base-multilingual-cased"

    # 資料集來源（HuggingFace datasets）
    hc3_english: str = "Hello-SimpleAI/HC3"
    hc3_chinese: str = "Hello-SimpleAI/HC3-Chinese"
    use_chinese: bool = True

    max_length: int = 192
    # 第一版 1 epoch（8 萬+ 樣本二元分類單輪已足）；production 可加到 2-3 epoch 微幅提升
    epochs: int = 1
    batch_size: int = 32
    learning_rate: float = 2e-5
    warmup_ratio: float = 0.1
    weight_decay: float = 0.01
    seed: int = 42

    # 每類別取樣上限（None = 全部）。設上限同時平衡類別：
    # HC3 原始 human 7.7 萬 / ai 4.4 萬，capping 至 3 萬使兩類均衡並縮短訓練。
    max_per_class: int | None = 30000

    # 驗證集比例
    val_ratio: float = 0.1

    labels: list[str] = field(default_factory=lambda: ["human", "ai"])

    @property
    def model_out(self) -> str:
        return os.path.join(OUTPUT_DIR, "classifier")

    @property
    def onnx_out(self) -> str:
        return os.path.join(OUTPUT_DIR, "detector.onnx")

    @property
    def onnx_int8_out(self) -> str:
        return os.path.join(OUTPUT_DIR, "detector_int8.onnx")


def quick_smoke() -> "TrainConfig":
    """煙霧測試：小模型、小資料、1 epoch，驗證流程可端到端跑通。"""
    return TrainConfig(
        base_model="distilbert-base-multilingual-cased",
        epochs=1,
        max_per_class=200,
        use_chinese=False,
    )
