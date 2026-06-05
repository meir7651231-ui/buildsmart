#!/usr/bin/env bash
# Fast-forward push ONLY. Refuses the default/protected branch (red-team CRITICAL #1), refuses if origin
# advanced past your base, and aborts on a failed fetch (never push against an unconfirmed remote state).
# usage: ff-push.sh <worktree> <repo-dir> <branch> <expected-origin-base-sha>
#   ALLOW_PROTECTED=1 in the env overrides the default-branch guard — a HUMAN sets this; never bypass in code.
set -uo pipefail
WT="${1:?worktree}"; REPO="${2:?repo dir}"; BRANCH="${3:?branch}"; BASE="${4:?expected origin base sha}"

# --- SAFETY GUARD: never push the default/protected branch by accident (a mis-read/injected branch name) ---
DEFAULT=$(git -C "$REPO" symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null | sed 's|^refs/remotes/origin/||')
case "$BRANCH" in
  main|master|"$DEFAULT")
    if [ "${ALLOW_PROTECTED:-0}" != "1" ]; then
      echo "REFUSE: '$BRANCH' is the default/protected branch. This guard blocks accidental production pushes."
      echo "        A human must set ALLOW_PROTECTED=1 to override — never bypass it programmatically."
      exit 2
    fi
    echo "WARNING: pushing protected branch '$BRANCH' (ALLOW_PROTECTED=1 override active)." ;;
esac

# Fetch — do NOT swallow failure: a failed fetch must not let a stale remote-tracking ref pass the guard.
if ! git -C "$REPO" fetch --no-tags origin "$BRANCH:refs/remotes/origin/$BRANCH" 2>&1; then
  echo "REFUSE: fetch of origin/$BRANCH failed — cannot confirm the live remote state; aborting."
  exit 1
fi
OT=$(git -C "$REPO" rev-parse "origin/$BRANCH" 2>/dev/null || echo none)
# Compare FULL SHAs (canonicalize BASE via rev-parse so a short OR full sha both work).
BASE_FULL=$(git -C "$REPO" rev-parse "$BASE" 2>/dev/null || echo none)
if [ "$OT" = "none" ] || [ "$BASE_FULL" = "none" ]; then
  echo "REFUSE: could not resolve origin/$BRANCH ($OT) or base ($BASE_FULL)."; exit 1
fi
if [ "$OT" != "$BASE_FULL" ]; then
  echo "REFUSE: origin/$BRANCH is $OT, expected base $BASE_FULL — it advanced; rebase/merge first."
  exit 1
fi
for d in 0 2 4 8 16; do
  [ "$d" -gt 0 ] && { echo "retry in ${d}s..."; sleep "$d"; }
  if git -C "$WT" push origin "HEAD:$BRANCH" 2>&1; then echo "PUSHED $(git -C "$WT" rev-parse --short HEAD) -> $BRANCH"; exit 0; fi
done
echo "PUSH FAILED after retries"; exit 1
