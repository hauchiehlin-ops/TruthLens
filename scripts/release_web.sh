#!/bin/bash
# Web release helper: bump pubspec version, rebuild build/web, commit, and push.
# Usage: ./scripts/release_web.sh "commit message"

set -euo pipefail

if [ $# -eq 0 ]; then
  echo "Usage: ./scripts/release_web.sh \"commit message\""
  echo "Example: ./scripts/release_web.sh \"Release web version 4.11.8\""
  exit 1
fi

if [ ! -f pubspec.yaml ]; then
  echo "Error: pubspec.yaml not found. Run this script from the project root."
  exit 1
fi

commit_msg="$*"
remote="${RELEASE_REMOTE:-origin}"
branch="${RELEASE_BRANCH:-$(git rev-parse --abbrev-ref HEAD)}"

current_version=$(awk '/^version:/ { print $2; exit }' pubspec.yaml)

if [[ ! "$current_version" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)$ ]]; then
  echo "Error: unsupported version format: $current_version"
  echo "Expected format: major.minor.patch+build, for example 4.11.7+1457"
  exit 1
fi

major="${BASH_REMATCH[1]}"
minor="${BASH_REMATCH[2]}"
patch="${BASH_REMATCH[3]}"
build_number="${BASH_REMATCH[4]}"

new_patch=$((patch + 1))
new_build=$((build_number + 1))
new_version="${major}.${minor}.${new_patch}+${new_build}"

echo "Current version: $current_version"
echo "New version:     $new_version"
echo ""

perl -0pi -e "s/^version: .*/version: $new_version/m" pubspec.yaml

echo "Syncing SEO changelog..."
if [ -f "scripts/sync_seo_changelog.py" ]; then
  python3 scripts/sync_seo_changelog.py "$new_version" "$commit_msg"
  dart tool/generate_seo_pages.dart
fi

echo "Building web bundle..."
flutter build web

echo "Staging version, SEO pages, and web build artifacts..."
git add pubspec.yaml build/web web/seo/home_i18n.js web/index.html web/use-cases/ web/sitemap.xml web/sitemap_directory.html

if git diff --cached --quiet; then
  echo "No staged changes to commit."
  exit 0
fi

echo "Creating release commit..."
git commit -m "$commit_msg"

echo "Pushing to $remote/$branch..."
git push "$remote" "$branch"

echo ""
echo "Done."
echo "Version: $current_version -> $new_version"
