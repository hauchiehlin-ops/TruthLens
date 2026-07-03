"""移除 ONNX 模型中「宣告但未被任何節點使用」的 opset import。

某些匯出（如 joaopn/roberta-large-openai-detector-onnx-fp16）會宣告 ai.onnx.ml、
training 等 domain 的 opset，但圖中並無對應節點。舊版 ONNX Runtime（含 onnxruntime
Flutter 套件內建版）會因不支援這些 domain 的高 opset 而拒絕載入。

清掉未使用的 opset 宣告後即可在端上載入，且不改變推論結果。

用法：
    .venv/bin/python fix_onnx_opset.py <input.onnx> <output.onnx>
"""
import sys

import onnx


def fix(src: str, dst: str) -> None:
    model = onnx.load(src)
    used = {node.domain for node in model.graph.node}
    used.add("")  # ai.onnx 預設 domain
    kept = [op for op in model.opset_import if (op.domain or "") in used]
    before = [(op.domain or "ai.onnx", op.version) for op in model.opset_import]
    del model.opset_import[:]
    model.opset_import.extend(kept)
    onnx.save(model, dst)
    print(f"opset imports: {before}")
    print(f"           -> {[(op.domain or 'ai.onnx', op.version) for op in kept]}")
    print(f"saved {dst}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(__doc__)
        sys.exit(1)
    fix(sys.argv[1], sys.argv[2])
