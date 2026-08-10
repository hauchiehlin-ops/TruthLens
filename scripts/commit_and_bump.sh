#!/bin/bash
# 便捷指令：git commit + 自動版本號遞增 + git push
# 用法：./scripts/commit_and_bump.sh "commit message"

set -e

if [ -z "$1" ]; then
  echo "❌ 用法：./scripts/commit_and_bump.sh \"commit message\""
  echo "   範例：./scripts/commit_and_bump.sh \"新功能：雷達圖報告\""
  exit 1
fi

commit_msg="$1"

# 第 1 步：git add && git commit
echo "📝 提交更改..."
git add -A
git commit -m "$commit_msg"

# 第 2 步：遞增版本號
echo "🔢 遞增版本號..."

current_version=$(grep "^version:" pubspec.yaml | sed 's/version: //')
version_part=$(echo "$current_version" | cut -d'+' -f1)
build_number=$(echo "$current_version" | cut -d'+' -f2)

major=$(echo "$version_part" | cut -d'.' -f1)
minor=$(echo "$version_part" | cut -d'.' -f2)
patch=$(echo "$version_part" | cut -d'.' -f3)

new_patch=$((patch + 1))
new_build=$((build_number + 1))
new_version="${major}.${minor}.${new_patch}+${new_build}"

sed -i '' "s/^version: .*/version: $new_version/" pubspec.yaml

git add pubspec.yaml
git commit -m "版本號更新：$current_version → $new_version" || true

# 第 3 步：git push
echo "🚀 推送至遠端..."
git push

echo ""
echo "✅ 完成！"
echo "   提交訊息：$commit_msg"
echo "   版本號遞增：$current_version → $new_version"
echo ""
