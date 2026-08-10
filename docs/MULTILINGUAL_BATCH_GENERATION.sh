#!/bin/bash
# 多語言快速開始指南批量生成腳本
# 使用方式：bash MULTILINGUAL_BATCH_GENERATION.sh

set -e

# 定義語言列表（代碼 : 語言名稱 : 英文名稱）
declare -A LANGUAGES=(
  ["de"]="Deutsch"
  ["es"]="Español"
  ["fr"]="Français"
  ["pt"]="Português"
  ["ru"]="Русский"
  ["id"]="Bahasa Indonesia"
  ["ms"]="Bahasa Melayu"
  ["th"]="ไทย"
  ["zh"]="中文（通用）"
)

echo "🌍 TruthLens 多語言翻譯批量生成"
echo "================================"

# 檢查英文原始文件
if [ ! -f "docs/quick-start-en.md" ]; then
    echo "❌ 錯誤：docs/quick-start-en.md 不存在"
    exit 1
fi

echo "✅ 已找到英文原始文件"
echo ""

# 為每種語言創建快速開始指南
for lang_code in "${!LANGUAGES[@]}"; do
    lang_name="${LANGUAGES[$lang_code]}"
    output_file="docs/quick-start-${lang_code}.md"

    echo "📝 生成：$lang_name ($lang_code) → $output_file"

    # 使用 sed 進行基本的語言代碼替換
    # 實際翻譯需要人工或 API 調用
    cat docs/quick-start-en.md | \
        sed "s/Quick Start Guide (English)/快速開始指南（$lang_name）/g" | \
        sed "s/5 minutes to complete your first document analysis/5 分鐘內完成第一份文件分析/g" > "$output_file"

    echo "   ✓ 已建立 $output_file"
done

echo ""
echo "✅ 已生成 9 個語言版本的框架"
echo ""
echo "📋 待辦事項："
echo "  1. 使用 Google Translate / DeepL API 或人工翻譯者翻譯每個檔案"
echo "  2. 驗證技術術語的一致性（參考 TRANSLATION-PLAN.md）"
echo "  3. 文化適配（如適用）"
echo "  4. 執行 git add docs/quick-start-*.md && git commit"
echo ""
echo "🎯 翻譯優先級："
echo "  1️⃣  Deutsch, Español, Français（第 2 優先級）"
echo "  2️⃣  Português, Русский（第 3 優先級）"
echo "  3️⃣  Bahasa Indonesia, Bahasa Melayu, ไทย（第 3 優先級）"
