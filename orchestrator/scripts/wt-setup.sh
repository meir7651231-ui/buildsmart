#!/usr/bin/env bash
# Create a fresh detached worktree at a commit/branch for one pipeline run.
# usage: wt-setup.sh <repo-dir> <commit-or-branch> <worktree-path>
set -euo pipefail
REPO="${1:?repo dir}"; REF="${2:?commit/branch}"; WT="${3:?worktree path}"
git -C "$REPO" fetch --no-tags origin "$REF" 2>/dev/null || true
git -C "$REPO" worktree add --detach "$WT" "$REF"
echo "worktree at $(git -C "$WT" rev-parse --short HEAD) -> $WT"
echo "cleanup later with: git -C $REPO worktree remove $WT --force"
