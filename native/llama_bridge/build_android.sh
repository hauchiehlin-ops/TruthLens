#!/bin/bash
# 建置 TruthLens Android llama.cpp 橋接層與完整原生庫，並複製到
# android/app/src/main/jniLibs/<abi>/。
#
# 產出：
#   libtruthlens_llama.so
#   libllama.so + libggml{,-base,-cpu}.so
#
# 用法：
#   bash native/llama_bridge/build_android.sh
#
# 可用 ABI_LIST 覆寫目標 ABI，例如：
#   ABI_LIST="arm64-v8a x86_64" bash native/llama_bridge/build_android.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
JNI_DIR="$REPO_ROOT/android/app/src/main/jniLibs"
NDK_ROOT="${ANDROID_NDK_HOME:-${ANDROID_NDK:-$HOME/Library/Android/sdk/ndk/28.2.13676358}}"
TOOLCHAIN="$NDK_ROOT/build/cmake/android.toolchain.cmake"
ABI_LIST="${ABI_LIST:-arm64-v8a x86_64 armeabi-v7a}"

if [ ! -f "$TOOLCHAIN" ]; then
  echo "Android NDK toolchain not found: $TOOLCHAIN" >&2
  exit 1
fi

if [ ! -d "$SCRIPT_DIR/llama.cpp" ]; then
  echo "→ clone llama.cpp ..."
  git clone --depth 1 ${LLAMA_CPP_REF:+--branch "$LLAMA_CPP_REF"} \
    https://github.com/ggml-org/llama.cpp.git "$SCRIPT_DIR/llama.cpp"
fi

for ABI in $ABI_LIST; do
  BUILD_DIR="$SCRIPT_DIR/build-android-$ABI"
  OUT_DIR="$JNI_DIR/$ABI"
  echo "→ configure Android $ABI ..."
  cmake -S "$SCRIPT_DIR" -B "$BUILD_DIR" -G "Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN" \
    -DANDROID_ABI="$ABI" \
    -DANDROID_PLATFORM=android-23

  echo "→ build Android $ABI ..."
  cmake --build "$BUILD_DIR" --target truthlens_llama -j"$(sysctl -n hw.ncpu)"

  echo "→ copy Android $ABI libraries to $OUT_DIR ..."
  mkdir -p "$OUT_DIR"
  cp -L "$BUILD_DIR/libtruthlens_llama.so" "$OUT_DIR/libtruthlens_llama.so"
  cp -L "$BUILD_DIR/bin/libllama.so" "$OUT_DIR/libllama.so"
  cp -L "$BUILD_DIR/bin/libggml.so" "$OUT_DIR/libggml.so"
  cp -L "$BUILD_DIR/bin/libggml-base.so" "$OUT_DIR/libggml-base.so"
  cp -L "$BUILD_DIR/bin/libggml-cpu.so" "$OUT_DIR/libggml-cpu.so"
done

echo "✅ Android llama bridge libraries ready:"
find "$JNI_DIR" -maxdepth 2 -type f \( -name 'libtruthlens_llama.so' -o -name 'libllama.so' -o -name 'libggml*.so' \) | sort
