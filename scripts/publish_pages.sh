#!/usr/bin/env bash
# Publish docs/ to GitHub Pages using git subtree
# Requirements: remote 'origin' points to your GitHub repo and you have push access.

set -e

if [ ! -d docs ]; then
  echo "docs/ directory not found; nothing to publish"
  exit 1
fi

# Commit any local changes first
git add docs
git commit -m "Update docs for GitHub Pages" || echo "No changes to commit in docs/"

# Push docs/ to gh-pages branch using subtree
git subtree push --prefix docs origin gh-pages || {
  echo "git subtree push failed. You may need to create gh-pages branch first or use an alternative workflow.";
  exit 1;
}

echo "Published docs/ to gh-pages branch on origin. Visit your repo settings to enable Pages if needed."
