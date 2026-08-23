#!/usr/bin/env bash
# Sub-agent registry — track every spawned agent so none is left unreaped before a phase advances.
# A "leaked" agent (spawned, never closed) means an audit/fix lane silently went missing — this turns
# that into a hard BLOCK instead of a silent gap. State lives in the worktree's git-admin dir
# (survives the worktree, never appears in `git diff`). Atomic writes, jq-validated.
# usage: registry.sh <worktree> <cmd> [args]
#   open <id> <role> <scope>  | close <id> <status> | assert-none-open | list | reset
set -uo pipefail
WT="${1:?worktree}"; CMD="${2:?cmd}"; ID="${3:-}"; A4="${4:-}"; A5="${5:-}"
GD=$(git -C "$WT" rev-parse --absolute-git-dir 2>/dev/null) || { echo "ERR: '$WT' is not a git worktree"; exit 2; }
DIR="$GD/orchestrator-state"; REG="$DIR/registry.json"; mkdir -p "$DIR"
[ -f "$REG" ] || echo '[]' > "$REG"
wr(){ local t; t=$(mktemp "$DIR/.reg.XXXXXX") && cat >"$t" && mv -f "$t" "$REG"; }
ts(){ date -u +%FT%TZ; }
case "$CMD" in
  open)
    [ -n "$ID" ] && [ -n "$A4" ] || { echo "open <id> <role> <scope>"; exit 2; }
    if jq -e --arg i "$ID" 'any(.[]; .id==$i and .state=="OPEN")' "$REG" >/dev/null; then
      echo "ERR: id '$ID' already OPEN (id collision — pick a unique id)"; exit 2; fi
    jq --arg i "$ID" --arg r "$A4" --arg s "$A5" --arg t "$(ts)" \
       '. += [{id:$i, role:$r, scope:$s, state:"OPEN", opened:$t}]' "$REG" | wr
    echo "open  $ID ($A4)";;
  close)
    [ -n "$ID" ] || { echo "close <id> <status>"; exit 2; }
    if ! jq -e --arg i "$ID" 'any(.[]; .id==$i and .state=="OPEN")' "$REG" >/dev/null; then
      echo "ERR: no OPEN row for id '$ID' (never opened, or already closed)"; exit 2; fi
    jq --arg i "$ID" --arg st "${A4:-CLOSED}" --arg t "$(ts)" \
       'map(if .id==$i and .state=="OPEN" then .state="CLOSED" | .status=$st | .closed=$t else . end)' "$REG" | wr
    echo "close $ID (${A4:-CLOSED})";;
  assert-none-open)
    open=$(jq -r '[.[] | select(.state=="OPEN")] | length' "$REG")
    if [ "$open" -gt 0 ]; then
      echo "BLOCK: $open agent(s) still OPEN (unreaped) — every spawned agent must be closed before advancing:"
      jq -r '.[] | select(.state=="OPEN") | "  OPEN  \(.id)  \(.role)  \(.scope)"' "$REG"
      exit 1
    fi
    echo "OK: no open agents ($(jq 'length' "$REG") row(s) this run)";;
  list)  cat "$REG";;
  reset) echo '[]' | wr; echo "registry reset";;
  *) echo "usage: registry.sh <wt> open|close|assert-none-open|list|reset ..."; exit 2;;
esac
