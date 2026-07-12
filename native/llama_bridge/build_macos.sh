#!/bin/bash
# 建置 TruthLens 的 macOS llama.cpp 橋接層與完整原生庫，並複製到 macos/Libs/。
#
# 產出（arm64, shared, Metal）：
#   libtruthlens_llama.dylib  ← Dart FFI 綁定的橋接層
#   libllama.0.dylib + libggml{,-base,-cpu,-blas,-metal}.0.dylib  ← llama.cpp 執行期
#
# 用法： bash native/llama_bridge/build_macos.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIBS_DIR="$REPO_ROOT/macos/Libs"

# 1) 取得 llama.cpp 原始碼（可用環境變數 LLAMA_CPP_REF 指定版本/tag）。
if [ ! -d "$SCRIPT_DIR/llama.cpp" ]; then
  echo "→ clone llama.cpp ..."
  git clone --depth 1 ${LLAMA_CPP_REF:+--branch "$LLAMA_CPP_REF"} \
    https://github.com/ggml-org/llama.cpp.git "$SCRIPT_DIR/llama.cpp"
fi

# 2) 建置。
echo "→ cmake configure ..."
cmake -S "$SCRIPT_DIR" -B "$SCRIPT_DIR/build" -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release
echo "→ cmake build ..."
cmake --build "$SCRIPT_DIR/build" --target truthlens_llama -j"$(sysctl -n hw.ncpu)"

# 3) 以 loader 參照的名稱（.0.dylib）複製到 macos/Libs/。
echo "→ 複製 dylib 到 $LIBS_DIR ..."
mkdir -p "$LIBS_DIR"
B="$SCRIPT_DIR/build"
cp -L "$B/libtruthlens_llama.dylib"  "$LIBS_DIR/libtruthlens_llama.dylib"
cp -L "$B/bin/libllama.0.dylib"      "$LIBS_DIR/libllama.0.dylib"
cp -L "$B/bin/libggml.0.dylib"       "$LIBS_DIR/libggml.0.dylib"
cp -L "$B/bin/libggml-base.0.dylib"  "$LIBS_DIR/libggml-base.0.dylib"
cp -L "$B/bin/libggml-cpu.0.dylib"   "$LIBS_DIR/libggml-cpu.0.dylib"
cp -L "$B/bin/libggml-blas.0.dylib"  "$LIBS_DIR/libggml-blas.0.dylib"
cp -L "$B/bin/libggml-metal.0.dylib" "$LIBS_DIR/libggml-metal.0.dylib"

echo "✅ 完成。macos/Libs/ 內容："
ls -1 "$LIBS_DIR"
echo ""
echo "注意：這些 dylib 已透過 Runner.xcodeproj 的『Embed llama Libraries』"
echo "Copy Files 階段嵌入 app 的 Contents/Frameworks/（含 Code Sign On Copy）。"
