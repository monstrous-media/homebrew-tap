#!/usr/bin/env bash
# Copyright 2025-2026 Monstrous Media
# SPDX-License-Identifier: MIT
#
# Compare the formula against the latest monstrous-media/conductor release;
# on a newer tag, rewrite the url/sha256 pairs from the published .sha256
# assets and open a PR. Idempotent: exits quietly when up to date or when a
# bump PR for that version is already open.
set -euo pipefail

FORMULA="Formula/conductor-daemon.rb"
UPSTREAM="monstrous-media/conductor"
TARGETS=(aarch64-apple-darwin x86_64-apple-darwin x86_64-unknown-linux-gnu)

latest_tag=$(gh release view --repo "$UPSTREAM" --json tagName -q .tagName)
latest="${latest_tag#v}"
current=$(grep -oE 'download/v[0-9]+\.[0-9]+\.[0-9]+' "$FORMULA" | head -1 | sed 's|download/v||')

echo "formula: $current, latest release: $latest"
if [ "$latest" = "$current" ]; then
  echo "up to date"
  exit 0
fi

branch="bump-conductor-daemon-$latest"
if gh pr list --state open --head "$branch" --json number -q '.[0].number' | grep -q .; then
  echo "bump PR already open on $branch"
  exit 0
fi

for t in "${TARGETS[@]}"; do
  sha=$(gh release download "$latest_tag" --repo "$UPSTREAM" \
    --pattern "conductor-daemon-$t.tar.gz.sha256" --output - | awk '{print $1}')
  if ! printf '%s' "$sha" | grep -qE '^[0-9a-f]{64}$'; then
    echo "bad sha256 for $t: '$sha'" >&2
    exit 1
  fi
  export BUMP_TARGET="$t" BUMP_SHA="$sha"
  python3 - "$FORMULA" <<'PY'
import os, re, sys
path = sys.argv[1]
target, sha = os.environ["BUMP_TARGET"], os.environ["BUMP_SHA"]
src = open(path).read()
pattern = rf'(conductor-daemon-{re.escape(target)}\.tar\.gz"\n\s*sha256 ")[0-9a-f]{{64}}'
out, n = re.subn(pattern, rf'\g<1>{sha}', src)
if n != 1:
    sys.exit(f"expected exactly one sha256 for {target}, matched {n}")
open(path, "w").write(out)
PY
done

sed -i -E "s|download/v$current/|download/v$latest/|g" "$FORMULA"

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git checkout -b "$branch"
git add "$FORMULA"
git commit -s -m "bump: conductor-daemon $current -> $latest"
git push -u origin "$branch"

gh pr create \
  --title "bump: conductor-daemon $current -> $latest" \
  --body "Automated bump from the $latest_tag release of $UPSTREAM.

url/sha256 pairs taken from the release's published .sha256 assets.

NOTE: this PR was opened by GITHUB_TOKEN, so tap CI did not auto-trigger —
close and reopen it (or push to the branch) to run CI before merging."
