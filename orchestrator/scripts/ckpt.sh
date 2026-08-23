#!/usr/bin/env bash
# Durable run checkpoint — resume + phase ordering. State lives in the worktree's git-admin dir
# (survives the worktree, never appears in `git diff`). Atomic writes, jq-validated.
# usage: ckpt.sh <worktree> <cmd> [args]
#   init "<goal>" | set <key> <value> | get <key> | phase <name> | guard <required-phase> | show
# guard exits 1 if the current phase is earlier than <required-phase> in the fixed pipeline order —
# so a later stage cannot run before an earlier one completed (resumable, order-enforced).
set -uo pipefail
WT="${1:?worktree}"; CMD="${2:?cmd}"; A3="${3:-}"; A4="${4:-}"
GD=$(git -C "$WT" rev-parse --absolute-git-dir 2>/dev/null) || { echo "ERR: '$WT' is not a git worktree"; exit 2; }
DIR="$GD/orchestrator-state"; CK="$DIR/checkpoint.json"; mkdir -p "$DIR"
ORDER="setup audit synthesize validate fix verify docs ship deploy done"
idx(){ local x i=0; for x in $ORDER; do [ "$x" = "$1" ] && { echo "$i"; return; }; i=$((i+1)); done; echo -1; }
wr(){ local t; t=$(mktemp "$DIR/.ck.XXXXXX") && cat >"$t" && mv -f "$t" "$CK"; }
need(){ [ -f "$CK" ] || { echo "ERR: no checkpoint (run init)"; exit 1; }; }
case "$CMD" in
  init)  jq -nc --arg g "$A3" --arg t "$(date -u +%FT%TZ)" '{goal:$g,phase:"setup",updated:$t}' | wr; echo "init -> $CK";;
  set)   need; [ -n "$A3" ] || { echo "set <key> <value>"; exit 2; }; jq --arg k "$A3" --arg v "$A4" '.[$k]=$v' "$CK" | wr; echo "set $A3";;
  get)   need; jq -r --arg k "$A3" '.[$k] // empty' "$CK";;
  phase) need; [ "$(idx "$A3")" -ge 0 ] || { echo "ERR: unknown phase '$A3'"; exit 2; }; pv=$(jq -r '.phase' "$CK"); jq --arg p "$A3" --arg q "$pv" --arg t "$(date -u +%FT%TZ)" '.prev=$q|.phase=$p|.updated=$t' "$CK" | wr; echo "phase $pv -> $A3";;
  guard) need; cur=$(jq -r '.phase' "$CK"); if [ "$(idx "$cur")" -ge "$(idx "$A3")" ]; then echo "OK: phase '$cur' >= '$A3'"; else echo "BLOCK: phase '$cur' < required '$A3'"; exit 1; fi;;
  show)  need; cat "$CK";;
  *) echo "usage: ckpt.sh <wt> init|set|get|phase|guard|show ..."; exit 2;;
esac
