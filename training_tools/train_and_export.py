import os
import torch
from datasets import load_dataset
from transformers import AutoTokenizer, AutoModelForSequenceClassification, Trainer, TrainingArguments
from optimum.onnxruntime import ORTQuantizer
from optimum.onnxruntime.configuration import AutoQuantizationConfig

def main():
    print("=== 步驟 2-1: 載入機器改寫對照資料集 ===")
    # 載入學術研究用的機器改寫與人類文章對照資料集
    train_dataset = load_dataset("jpwahle/machine-paraphrase-dataset", split="train").select(range(2000))
    val_dataset = load_dataset("jpwahle/machine-paraphrase-dataset", split="test").select(range(500))

    model_id = "distilbert-base-uncased"
    print(f"=== 步驟 2-2: 載入基礎模型與 Tokenizer: {model_id} ===")
    tokenizer = AutoTokenizer.from_pretrained(model_id)
    model = AutoModelForSequenceClassification.from_pretrained(model_id, num_labels=2)

    # 前處理：將輸入的改寫或原文字進行 Tokenization，截斷/填充為固定長度
    def preprocess_function(examples):
        return tokenizer(
            examples["text"],
            truncation=True,
            max_length=256,
            padding="max_length"
        )

    print("=== 步驟 2-3: 資料前處理與 Tokenization ===")
    tokenized_train = train_dataset.map(preprocess_function, batched=True)
    tokenized_val = val_dataset.map(preprocess_function, batched=True)

    print("=== 步驟 2-4: 配置訓練參數 ===")
    training_args = TrainingArguments(
        output_dir="./results",
        learning_rate=2e-5,
        per_device_train_batch_size=16,
        per_device_eval_batch_size=16,
        num_train_epochs=3,
        weight_decay=0.01,
        eval_strategy="epoch",
        save_strategy="epoch",
        logging_steps=50,
        use_cpu=False # 設為 False 以自動啟用 M4 Apple Silicon GPU (MPS) 進行加速訓練
    )

    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_train,
        eval_dataset=tokenized_val,
        tokenizer=tokenizer,
    )

    print("=== 步驟 2-5: 開始微調訓練 (這可能需要數分鐘) ===")
    trainer.train()

    print("=== 步驟 2-6: 保存微調後的模型與 Tokenizer ===")
    output_model_dir = "./fine_tuned_model"
    model.save_pretrained(output_model_dir)
    tokenizer.save_pretrained(output_model_dir)
    
    # 將 vocab.txt 與 tokenizer.json 保留供 Flutter 使用
    print("保存 Tokenizer 配置文件...")

    print("=== 步驟 2-7: 將 PyTorch 模型導出為 ONNX 格式 ===")
    onnx_path = "./model.onnx"
    dummy_input = (
        torch.zeros(1, 256, dtype=torch.long), # input_ids
        torch.zeros(1, 256, dtype=torch.long)  # attention_mask
    )
    
    # 將 PyTorch 模型轉為 ONNX 格式
    model.eval()
    model.to("cpu")
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
    quantizer = ORTQuantizer.from_pretrained(output_model_dir, feature="sequence-classification")
    qconfig = AutoQuantizationConfig.arm64(is_static=False, activated_ops=[]) # 動態量化適合 CPU 端上推論
    
    # 執行量化
    quantized_model_path = "./model_quantized.onnx"
    quantizer.quantize(
        save_dir="./quantized_model",
        quantization_config=qconfig
    )
    
    # 重新命名與清理
    if os.path.exists("./quantized_model/model_quantized.onnx"):
        os.rename("./quantized_model/model_quantized.onnx", "./adversarial_paraphrase_quantized.onnx")
        print("量化模型已產生: adversarial_paraphrase_quantized.onnx")
    else:
        # 相容舊 Optimum API 命名
        os.rename("./quantized_model/model.onnx", "./adversarial_paraphrase_quantized.onnx")
        print("量化模型已產生: adversarial_paraphrase_quantized.onnx")

    print("\n恭喜！訓練與導出程序全部完成。")
    print("您獲得了兩個關鍵檔案：")
    print("1. 模型檔：./adversarial_paraphrase_quantized.onnx")
    print("2. 詞表檔：./fine_tuned_model/tokenizer.json")

if __name__ == "__main__":
    main()
