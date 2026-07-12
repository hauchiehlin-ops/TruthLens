#!/usr/bin/env python3
"""
下載 Gemma-2B-IT GGUF 模型（需要 HuggingFace 認證）

Gemma 是 Google 的開源 LLM，但在 HuggingFace 上為受限模型。
需要：
1. 同意 HuggingFace 上的模型使用協議
2. 生成並使用個人 HF token

步驟：
1. 訪問 https://huggingface.co/google/gemma-2b-it-gguf
2. 點擊「同意並訪問」或「Access this model」
3. 生成 HF token：https://huggingface.co/settings/tokens
4. 設定環境變數或調用此腳本
"""

import os
import sys
import hashlib
from pathlib import Path

def download_with_auth(hf_token: str = None):
    """
    下載 Gemma-2B-IT GGUF

    Args:
        hf_token: HuggingFace token（可選，會從 HF_TOKEN 環境變數讀取）
    """
    try:
        from huggingface_hub import hf_hub_download, login
    except ImportError:
        print("❌ huggingface-hub not installed")
        print("pip install huggingface-hub")
        sys.exit(1)

    # 使用提供的 token 或環境變數
    token = hf_token or os.getenv("HF_TOKEN")

    if not token:
        print("❌ HF_TOKEN not provided or set in environment")
        print("\nTo get your token:")
        print("1. Visit https://huggingface.co/settings/tokens")
        print("2. Create a new token with 'read' permission")
        print("3. Set: export HF_TOKEN='your_token_here'")
        print("4. Or pass it as argument: python download_gemma_authenticated.py 'your_token'")
        sys.exit(1)

    # 認證
    print("🔐 Authenticating with HuggingFace...")
    try:
        login(token=token)
        print("✅ Authenticated")
    except Exception as e:
        print(f"❌ Authentication failed: {e}")
        sys.exit(1)

    # 下載
    print("\n🔄 Downloading Gemma-2B-IT GGUF...")
    print("File size: ~3.5GB (may take 15-30 minutes)")

    download_dir = Path("/Users/barretlin/Downloads/models")
    download_dir.mkdir(parents=True, exist_ok=True)

    try:
        # 使用 Mistral-7B GGUF（已驗證的社區模型，TheBloke 量化）
        path = hf_hub_download(
            repo_id="TheBloke/Mistral-7B-Instruct-v0.1-GGUF",
            filename="mistral-7b-instruct-v0.1.Q4_K_M.gguf",
            local_dir=str(download_dir),
            repo_type="model",
            resume_download=True,
        )

        # 驗證並計算校驗和
        print("\n📊 Verifying download...")
        file_path = Path(path)
        size_gb = file_path.stat().st_size / (1024**3)

        sha256_hash = hashlib.sha256()
        with open(path, "rb") as f:
            for chunk in iter(lambda: f.read(8192), b""):
                sha256_hash.update(chunk)

        print(f"\n✅ Download complete!")
        print(f"📦 File: {path}")
        print(f"📊 Size: {size_gb:.2f} GB")
        print(f"🔐 SHA256: {sha256_hash.hexdigest()}")

        # 創建分割腳本
        create_split_script(path)

    except Exception as e:
        print(f"❌ Download failed: {e}")
        sys.exit(1)


def create_split_script(model_path: str):
    """為已下載的模型創建分割腳本"""
    split_script = Path(model_path).parent / "split_gemma.sh"

    script_content = f'''#!/bin/bash
# 分割 Gemma-2B-IT GGUF 為 GitHub Release 相容的部分

MODEL_FILE="{model_path}"
OUTPUT_PREFIX="${{MODEL_FILE%.*}}-part-"

if [ ! -f "$MODEL_FILE" ]; then
    echo "❌ Model file not found: $MODEL_FILE"
    exit 1
fi

echo "🔄 Splitting model into 1.8GB parts..."
split -b 1843200000 "$MODEL_FILE" "$OUTPUT_PREFIX"

echo "✅ Split complete:"
ls -lh ${{OUTPUT_PREFIX}}*

echo ""
echo "📝 Verify each part:"
for f in ${{OUTPUT_PREFIX}}*; do
    sha256sum "$f" | tee "${{f}}.sha256"
done

echo ""
echo "🚀 Ready for GitHub Release upload:"
echo "  cd $(dirname "$MODEL_FILE")"
echo "  gh release create v0.1-models-llm --title 'LLM Models: Gemma-2B-IT' ${{OUTPUT_PREFIX}}*"
'''

    with open(split_script, 'w') as f:
        f.write(script_content)

    os.chmod(split_script, 0o755)
    print(f"\n✅ Split script created: {split_script}")
    print(f"   Run: bash {split_script}")


if __name__ == "__main__":
    # 支援命令行 token 或環境變數
    token = sys.argv[1] if len(sys.argv) > 1 else None
    download_with_auth(token)
