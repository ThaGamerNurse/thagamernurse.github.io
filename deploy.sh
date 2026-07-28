#!/bin/bash
# Commit, push, and make sure the site actually redeploys.
#
# GitHub Pages does not reliably rebuild on every push, and never on a
# force-push, so the site can sit serving an old commit with nothing to tell you.
# This asks for a build explicitly and waits until the deployed commit matches
# what you just pushed.
set -euo pipefail
cd "$(dirname "$0")"

REPO="ThaGamerNurse/thagamernurse.github.io"
MSG="${1:-Update site}"
NAME="ThaGamerNurse"
EMAIL="ThaGamerNurse@users.noreply.github.com"   # public in commit metadata; keep it noreply

if [ -z "$(git status --porcelain)" ]; then
  echo "Nothing to commit."
else
  git add -A
  git -c user.name="$NAME" -c user.email="$EMAIL" commit -q -m "$MSG"
  echo "committed: $MSG"
fi

git push -q origin main
HEAD_SHA=$(git rev-parse HEAD)
echo "pushed $HEAD_SHA"

gh api -X POST "repos/$REPO/pages/builds" >/dev/null 2>&1 || true

echo -n "waiting for Pages"
for _ in $(seq 1 40); do
  STATUS=$(gh api "repos/$REPO/pages/builds/latest" --jq .status 2>/dev/null || echo "")
  SHA=$(gh api "repos/$REPO/pages/builds/latest" --jq .commit 2>/dev/null || echo "")
  if [ "$STATUS" = "built" ] && [ "$SHA" = "$HEAD_SHA" ]; then
    echo; echo "LIVE: https://thagamernurse.github.io  (commit ${HEAD_SHA:0:7})"
    exit 0
  fi
  echo -n "."
  sleep 8
done

echo
echo "Pages did not report your commit as built within ~5 minutes."
echo "  deployed: ${SHA:-unknown}"
echo "  expected: $HEAD_SHA"
echo "Check https://github.com/$REPO/deployments"
exit 1
