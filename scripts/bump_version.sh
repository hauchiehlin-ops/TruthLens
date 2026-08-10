#!/bin/bash
# 自動遞增版本號（patch + build number）並提交、推送

set -e

# 取得目前版本（格式：x.y.z+b）
current_version=$(grep "^version:" pubspec.yaml | sed 's/version: //')
echo "Current version: $current_version"

# 解析版本號
version_part=$(echo "$current_version" | cut -d'+' -f1)
build_number=$(echo "$current_version" | cut -d'+' -f2)

# 解析 semantic version
major=$(echo "$version_part" | cut -d'.' -f1)
minor=$(echo "$version_part" | cut -d'.' -f2)
patch=$(echo "$version_part" | cut -d'.' -f3)

# 遞增 patch 與 build number
new_patch=$((patch + 1))
new_build=$((build_number + 1))
new_version="${major}.${minor}.${new_patch}+${new_build}"

echo "New version: $new_version"

# 更新 pubspec.yaml
sed -i '' "s/^version: .*/version: $new_version/" pubspec.yaml

echo "✓ Updated pubspec.yaml to $new_version"
echo ""
echo "Usage: git commit -m '...' && ./scripts/bump_version.sh"
echo "Version will be bumped to $new_version after your commit"
