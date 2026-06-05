#!/usr/bin/env bash
# Fast-forward push ONLY. Refuses if origin advanced past your base (no silent overwrite).
# Retries on network errors with exponential backoff. Never targets the default branch implicitly.
# usage: ff-push.sh <worktree> <repo-dir> <branch> <expected-origin-base-sha>
set -uo pipefail
WT="${1:?worktree}"; REPO="${2:?repo dir}"; BRANCH="${3:?branch}"; BASE="${4:?expected origin base sha}"
git -C "$REPO" fetch --no-tags origin "$BRANCH:refs/remotes/origin/$BRANCH" 2>&1 | tail -1
OT=$(git -C "$REPO" rev-parse "origin/$BRANCH" 2>/dev/null || echo none)
if [ "${OT:0:7}" != "${BASE:0:7}" ]; then
  echo "REFUSE: origin/$BRANCH is ${OT:0:7}, expected base ${BASE:0:7} — it advanced; rebase/merge first."
  exit 1
fi
for d in 0 2 4 8 16; do
  [ "$d" -gt 0 ] && { echo "retry in ${d}s..."; sleep "$d"; }
  if git -C "$WT" push origin "HEAD:$BRANCH" 2>&1; then echo "PUSHED $(git -C "$WT" rev-parse --short HEAD) -> $BRANCH"; exit 0; fi
done
echo "PUSH FAILED after retries"; exit 1
