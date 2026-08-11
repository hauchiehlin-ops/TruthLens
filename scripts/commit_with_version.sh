#!/bin/bash
# 交互式 commit：提交代碼 + 選擇版本號遞增類型（patch/minor/major）
# 用法：./scripts/commit_with_version.sh "commit message"

set -e

if [ -z "$1" ]; then
  echo "❌ 用法：./scripts/commit_with_version.sh \"commit message\""
  echo "   範例：./scripts/commit_with_version.sh \"功能：新增雷達圖\""
  exit 1
fi

commit_msg="$1"

# 第 1 步：git add && git commit
echo "📝 提交更改..."
git add -A
git commit -m "$commit_msg"

# 第 2 步：詢問用戶版本號遞增類型
echo ""
echo "🔢 選擇版本號遞增類型："
echo "  [1] Patch (patch) - 錯誤修復、小改進 (推薦)"
echo "  [2] Minor (minor) - 新功能"
echo "  [3] Major (major) - 重大變更"
echo ""

read -p "請選擇 [1-3] (預設: 1): " choice
choice=${choice:-1}

case $choice in
  1) version_type="patch" ;;
  2) version_type="minor" ;;
  3) version_type="major" ;;
  *)
    echo "❌ 無效選擇"
    exit 1
    ;;
esac

# 第 3 步：遞增版本號
echo "⏳ 遞增 $version_type 版本號..."

current_version=$(grep "^version:" pubspec.yaml | sed 's/version: //')
version_part=$(echo "$current_version" | cut -d'+' -f1)
build_number=$(echo "$current_version" | cut -d'+' -f2)

major=$(echo "$version_part" | cut -d'.' -f1)
minor=$(echo "$version_part" | cut -d'.' -f2)
patch=$(echo "$version_part" | cut -d'.' -f3)

case $version_type in
  patch)
    new_patch=$((patch + 1))
    new_version="${major}.${minor}.${new_patch}"
    ;;
  minor)
    new_minor=$((minor + 1))
    new_version="${major}.${new_minor}.0"
    ;;
  major)
    new_major=$((major + 1))
    new_version="${new_major}.0.0"
    ;;
esac

new_build=$((build_number + 1))
new_version_with_build="${new_version}+${new_build}"

# 更新 pubspec.yaml
sed -i '' "s/^version: .*/version: $new_version_with_build/" pubspec.yaml

# 提交版本號更新
git add pubspec.yaml
git commit -m "版本號更新 ($version_type)：$current_version → $new_version_with_build" || true

# 第 4 步：git push
echo "🚀 推送至遠端..."
git push

echo ""
echo "✅ 完成！"
echo "   提交訊息：$commit_msg"
echo "   版本號遞增：$current_version → $new_version_with_build ($version_type)"
echo ""
