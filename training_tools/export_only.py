import os
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from optimum.onnxruntime import ORTQuantizer
from optimum.onnxruntime.configuration import AutoQuantizationConfig
from pathlib import Path

def main():
    output_model_dir = "./fine_tuned_model"
    model = AutoModelForSequenceClassification.from_pretrained(output_model_dir)
    tokenizer = AutoTokenizer.from_pretrained(output_model_dir)

    print("=== 步驟 2-7: 將 PyTorch 模型導出為 ONNX 格式 ===")
    onnx_path = "./model.onnx"
    dummy_input = (
        torch.zeros(1, 128, dtype=torch.long), # input_ids
        torch.zeros(1, 128, dtype=torch.long)  # attention_mask
    )
    
    model.eval()
    torch.onnx.export(
        model,
        dummy_input,
        onnx_path,
        input_names=["input_ids", "attention_mask"],
        output_names=["logits"],
        dynamic_axes={
            "input_ids": {0: "batch_size", 1: "sequence_length"},
            "attention_mask": {0: "batch_size", 1: "sequence_length"},
            "logits": {0: "batch_size"}
        },
        opset_version=14
    )
    print(f"ONNX 模型導出成功: {onnx_path}")

    print("=== 步驟 2-8: 進行 ONNX 靜態 INT8 量化 (降低體積與加速) ===")
    quantizer = ORTQuantizer(Path("./model.onnx"))
    qconfig = AutoQuantizationConfig.arm64(is_static=False)
    
    quantizer.quantize(
        save_dir="./quantized_model",
        quantization_config=qconfig
    )
    
    if os.path.exists("./quantized_model/model_quantized.onnx"):
        os.rename("./quantized_model/model_quantized.onnx", "./adversarial_paraphrase_quantized.onnx")
    else:
        os.rename("./quantized_model/model.onnx", "./adversarial_paraphrase_quantized.onnx")
    print("量化模型已產生: adversarial_paraphrase_quantized.onnx")

if __name__ == "__main__":
    main()
