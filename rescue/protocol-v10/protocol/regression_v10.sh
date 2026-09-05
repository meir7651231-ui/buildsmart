#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  protocol/regression_v10.sh — HONEST regression for the v10 pass.
#  Closes the two code-fixable holes 8 prior passes missed:
#    V10-A  ReDoS / self-DoS — a stuck_log `ANTIPATTERN:` regex compiled with
#           Dart's BACKTRACKING RegExp (gate 103 + the generated test) could
#           HANG the hook AND CI `flutter test` forever (`(a+)+$` + a long run).
#    V10-B  whole-tree-scan SKIPS — a secret in a submodule (160000 gitlink),
#           behind a `.dart` symlink (120000), or in a git-LFS-tracked file was
#           skipped, and H3 `fed==scanned` FALSELY passed.
#
#  Pure bash; the REAL engine (`app_flutter/tool/protocol_check.dart`) is driven
#  with `dart` — the same engine the hook + CI run (no mock). Each test asserts
#  EXACTLY the named proven vector; security counter-cases (no false-positive on
#  legit input) are included. Timings prove the ReDoS vectors no longer hang.
#
#  Run:  bash protocol/regression_v10.sh   (or  --self-test  for the same thing)
# ═══════════════════════════════════════════════════════════════════════════
set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOK="$REPO_ROOT/.githooks/pre-commit"
ENGINE="$REPO_ROOT/app_flutter/tool/protocol_check.dart"
GEN="$REPO_ROOT/app_flutter/scripts/generate_stuck_regression.sh"
WORK="$(mktemp -d)"; trap 'rm -rf "$WORK"' EXIT
PASS=0; FAIL=0
ok()  { echo "  ok   $1"; PASS=$((PASS+1)); }
bad() { echo "  FAIL $1"; FAIL=$((FAIL+1)); }
chk() { if [[ "$2" == "$3" ]]; then ok "$1"; else bad "$1 (want='$3' got='$2')"; fi; }
gi()  { ( cd "$1" && git init -q && git config user.email t@t && git config user.name t \
          && git config commit.gpgsign false && git config tag.gpgsign false ); }
DART="dart"; command -v dart >/dev/null 2>&1 || DART="$HOME/flutter/bin/dart"
HAVE_DART=0; command -v "$DART" >/dev/null 2>&1 && HAVE_DART=1

echo "protocol_v10 regression — ReDoS (V10-A) + submodule/symlink/LFS skip (V10-B)"

# ════════════════════════════════════════════════════════════════════════
#  V10-A — ReDoS / self-DoS is CLOSED (three guards, defense-in-depth).
# ════════════════════════════════════════════════════════════════════════
# Drive the engine --diff over a poison stuck_log + a matching lib line and
# assert it RETURNS (does not hang) and does NOT ERR. We measure wall-clock and
# fail if it took longer than a generous ceiling (a hang would blow the ceiling).
redos_run() { # <antipattern-regex>  <lib-line>  -> echoes "RC=<rc> <SEV> T=<sec>"
    local pat="$1" line="$2" T="$WORK/a.$RANDOM" rc out sev start end
    mkdir -p "$T"
    printf 'ANTIPATTERN: %s\n' "$pat" > "$T/stuck.md"
    printf '+++ b/lib/x.dart\n+%s\n' "$line" > "$T/d.diff"
    printf 'lib/x.dart\n' > "$T/names.txt"
    start=$(date +%s)
    out=$( cd "$REPO_ROOT/app_flutter" && timeout 30 "$DART" "$ENGINE" \
             --diff "$T/d.diff" --names "$T/names.txt" --stuck-log "$T/stuck.md" 2>/dev/null )
    rc=$?
    end=$(date +%s)
    sev=$(printf '%s\n' "$out" | grep -E '^(ERR|WARN)[[:space:]]+103' | head -1 | cut -f1)
    echo "RC=$rc ${sev:-NONE} T=$((end-start))"
}
guard_under() { # "RC=.. SEV T=N"  ceiling-sec  -> "OK"/"SLOW"
    local t; t=$(echo "$1" | sed -E 's/.*T=([0-9]+).*/\1/'); [[ "$t" -lt "$2" ]] && echo OK || echo "SLOW($t)"
}
if [[ "$HAVE_DART" -eq 1 ]]; then
  LONG=$(printf 'a%.0s' $(seq 1 40))
  SLIP="$(python3 -c "print('a?'*30+'a'*30)" 2>/dev/null || echo "$(printf 'a?%.0s' $(seq 1 30))$(printf 'a%.0s' $(seq 1 30))")"
  SLIPHAY=$(printf 'a%.0s' $(seq 1 29))

  # (1) the PROVEN headline vector: (a+)+$  + 40-char run.
  R=$(redos_run '(a+)+$' "const s = \"$LONG\";")
  chk "V10-A (a+)+\$ + 40-run does NOT hang (returns)"      "$(echo "$R" | grep -oE 'RC=[0-9]+')" "RC=0"
  chk "V10-A (a+)+\$ is WARN-rejected (guard 2), not ERR"   "$(echo "$R" | sed -E 's/RC=[0-9]+ ([A-Z]+).*/\1/')" "WARN"
  chk "V10-A (a+)+\$ returns FAST (< 10s, not a hang)"      "$(guard_under "$R" 10)" "OK"

  # (2) a pattern that SLIPS the static detector but still ReDoS-hangs raw Dart:
  #     guard 3 (the wall-clock isolate kill) must catch it.
  R=$(redos_run "$SLIP" "const s = \"$SLIPHAY\";")
  chk "V10-A slip pattern does NOT hang (guard 3 kill)"     "$(echo "$R" | grep -oE 'RC=[0-9]+')" "RC=0"
  chk "V10-A slip pattern is WARN (TIMED OUT), not ERR"     "$(echo "$R" | sed -E 's/RC=[0-9]+ ([A-Z]+).*/\1/')" "WARN"
  chk "V10-A slip pattern returns FAST (< 10s)"             "$(guard_under "$R" 10)" "OK"

  # (3) counter-case: a LEGIT antipattern still ERRs (no security regression).
  R=$(redos_run 'FORBIDDEN_TOK' 'var y = FORBIDDEN_TOK;')
  chk "V10-A legit antipattern still ERRs (RC 2)"           "$(echo "$R" | grep -oE 'RC=[0-9]+')" "RC=2"
  chk "V10-A legit antipattern severity is ERR"             "$(echo "$R" | sed -E 's/RC=[0-9]+ ([A-Z]+).*/\1/')" "ERR"

  # (4) counter-case: a clean tree (legit pattern, no match) stays RC 0.
  R=$(redos_run 'FORBIDDEN_TOK' 'var y = totally_fine;')
  chk "V10-A no-match legit pattern stays RC 0"             "$(echo "$R" | grep -oE 'RC=[0-9]+')" "RC=0"

  # (5) the generator emits a NON-hanging test for a poison stuck_log.
  POISON="$WORK/poison_sl.md"; printf '# t\nANTIPATTERN: (a+)+$\n' > "$POISON"
  sed "s#STUCK_LOG=\"\$REPO_ROOT/app_flutter/knowledge/stuck_log.md\"#STUCK_LOG=\"$POISON\"#" "$GEN" > "$WORK/gen.sh"
  STUCK_REGEN_OUT="$WORK/poison_test.dart" bash "$WORK/gen.sh" >/dev/null 2>&1
  chk "V10-A generated poison test contains the bounded matcher" \
      "$( [[ $(grep -c '_boundedAnyMatch' "$WORK/poison_test.dart" 2>/dev/null) -ge 1 ]] && echo yes || echo no )" "yes"
  chk "V10-A generated poison test guards catastrophic patterns" \
      "$( [[ $(grep -c '_isCatastrophic' "$WORK/poison_test.dart" 2>/dev/null) -ge 1 ]] && echo yes || echo no )" "yes"
else
  echo "  SKIP V10-A engine vectors (dart not found) — covered by --self-test in CI"
fi

# ════════════════════════════════════════════════════════════════════════
#  V10-B — whole-tree-scan SKIP class (submodule / symlink / LFS) is CLOSED.
#  Build a fixture repo, run the engine --tree with the mode-bearing
#  --tree-entries feed, and assert each vector FAILS CLOSED (RC 3), while a
#  benign non-scannable symlink and a clean tree do NOT false-positive.
# ════════════════════════════════════════════════════════════════════════
tree_rc() { # <entries-file>  [extra args...]  -> echoes the engine RC
    local ef="$1"; shift
    ( cd "$REPO_ROOT" && timeout 60 "$DART" "$ENGINE" --tree --tree-entries "$ef" \
        --show "git --no-replace-objects show HEAD:" "$@" >/dev/null 2>&1 ); echo $?
}
if [[ "$HAVE_DART" -eq 1 ]]; then
  # submodule (gitlink) with a secret inside.
  SUB="$WORK/sub"; mkdir -p "$SUB/lib"; gi "$SUB"
  printf 'const k = "AKIAIOSFODNN7EXAMPLE";\n' > "$SUB/lib/s.dart"
  ( cd "$SUB" && git add -A && git commit -qm s )
  M="$WORK/main"; mkdir -p "$M/lib"; gi "$M"
  printf 'const ok = "hi";\n' > "$M/lib/main.dart"
  ( cd "$M" && git -c protocol.file.allow=always submodule add -q "$SUB" vsub >/dev/null 2>&1 \
       && git add -A && git commit -qm m >/dev/null 2>&1 )
  ( cd "$M" && git -c core.quotePath=false ls-tree -r HEAD ) > "$WORK/m_entries.txt"
  RC=$( cd "$M" && timeout 60 "$DART" "$ENGINE" --tree --tree-entries "$WORK/m_entries.txt" \
          --show "git --no-replace-objects show HEAD:" >/dev/null 2>&1; echo $? )
  chk "V10-B submodule (160000 gitlink) FAILS CLOSED (RC 3)" "$RC" "3"
  RC=$( cd "$M" && timeout 60 "$DART" "$ENGINE" --tree --tree-entries "$WORK/m_entries.txt" \
          --allow-gitlink vsub --show "git --no-replace-objects show HEAD:" >/dev/null 2>&1; echo $? )
  chk "V10-B submodule allowlisted (--allow-gitlink) → RC 0" "$RC" "0"

  # OLD name-only path falsely passes (proves the hole existed) — RC 0.
  ( cd "$M" && git -c core.quotePath=false ls-tree -r --name-only HEAD ) > "$WORK/m_names.txt"
  RC=$( cd "$M" && timeout 60 "$DART" "$ENGINE" --tree --names "$WORK/m_names.txt" \
          --show "git --no-replace-objects show HEAD:" >/dev/null 2>&1; echo $? )
  chk "V10-B (proof) OLD --name-only submodule FALSELY passes (RC 0)" "$RC" "0"

  # .dart symlink masquerading as content.
  S2="$WORK/sym"; mkdir -p "$S2/lib"; gi "$S2"
  printf 'const k = "AKIAIOSFODNN7EXAMPLE";\n' > "$S2/realsecret.txt"
  ( cd "$S2/lib" && ln -sf ../realsecret.txt aliased.dart )
  printf 'const ok = "x";\n' > "$S2/lib/main.dart"
  ( cd "$S2" && git add -A && git commit -qm s >/dev/null 2>&1 )
  ( cd "$S2" && git -c core.quotePath=false ls-tree -r HEAD ) > "$WORK/s2_entries.txt"
  RC=$( cd "$S2" && timeout 60 "$DART" "$ENGINE" --tree --tree-entries "$WORK/s2_entries.txt" \
          --show "git --no-replace-objects show HEAD:" >/dev/null 2>&1; echo $? )
  chk "V10-B .dart symlink (120000) REJECTED — FAILS CLOSED (RC 3)" "$RC" "3"

  # benign NON-scannable symlink (md->md) must NOT false-positive.
  # Remove the prior fixture's aliased.dart AND the realsecret.txt it pointed at
  # (that .txt is itself secret-scannable — leaving it would gate-52 ERR the tree
  # and mask the symlink assertion).
  ( cd "$S2" && git rm -q lib/aliased.dart realsecret.txt >/dev/null 2>&1 )
  printf 'readme\n' > "$S2/README_REAL.md"
  ( cd "$S2" && ln -sf README_REAL.md README.md && git add -A && git commit -qm md >/dev/null 2>&1 )
  ( cd "$S2" && git -c core.quotePath=false ls-tree -r HEAD ) > "$WORK/s2b_entries.txt"
  RC=$( cd "$S2" && timeout 60 "$DART" "$ENGINE" --tree --tree-entries "$WORK/s2b_entries.txt" \
          --show "git --no-replace-objects show HEAD:" >/dev/null 2>&1; echo $? )
  chk "V10-B benign md->md symlink does NOT false-positive (RC 0)" "$RC" "0"

  # git-LFS pointer in a .dart blob.
  L="$WORK/lfs"; mkdir -p "$L/lib"; gi "$L"
  { echo 'version https://git-lfs.github.com/spec/v1';
    echo 'oid sha256:4d7a214614ab2935c943f9e0ff69d22eadbb8f32b1258daaa5e2ca24d17e2393';
    echo 'size 12345'; } > "$L/lib/big.dart"
  printf 'const ok = "y";\n' > "$L/lib/main.dart"
  ( cd "$L" && git add -A && git commit -qm l >/dev/null 2>&1 )
  ( cd "$L" && git -c core.quotePath=false ls-tree -r HEAD ) > "$WORK/l_entries.txt"
  RC=$( cd "$L" && timeout 60 "$DART" "$ENGINE" --tree --tree-entries "$WORK/l_entries.txt" \
          --show "git --no-replace-objects show HEAD:" >/dev/null 2>&1; echo $? )
  chk "V10-B git-LFS pointer (.dart) REJECTED — FAILS CLOSED (RC 3)" "$RC" "3"
  # LFS also caught in legacy --names mode (content-signature, no mode needed).
  ( cd "$L" && git -c core.quotePath=false ls-tree -r --name-only HEAD ) > "$WORK/l_names.txt"
  RC=$( cd "$L" && timeout 60 "$DART" "$ENGINE" --tree --names "$WORK/l_names.txt" \
          --show "git --no-replace-objects show HEAD:" >/dev/null 2>&1; echo $? )
  chk "V10-B git-LFS caught even in legacy --names mode (RC 3)" "$RC" "3"

  # clean tree (no skip vectors) stays RC 0 — no false-positive from V10-B.
  C="$WORK/clean"; mkdir -p "$C/lib"; gi "$C"
  printf 'const ok = "z";\n' > "$C/lib/main.dart"
  ( cd "$C" && git add -A && git commit -qm c >/dev/null 2>&1 )
  ( cd "$C" && git -c core.quotePath=false ls-tree -r HEAD ) > "$WORK/c_entries.txt"
  RC=$( cd "$C" && timeout 60 "$DART" "$ENGINE" --tree --tree-entries "$WORK/c_entries.txt" \
          --show "git --no-replace-objects show HEAD:" >/dev/null 2>&1; echo $? )
  chk "V10-B clean tree (no skip vectors) stays RC 0" "$RC" "0"
else
  echo "  SKIP V10-B engine vectors (dart not found) — covered by --self-test in CI"
fi

# ════════════════════════════════════════════════════════════════════════
#  Hook half — the per-commit V10-B gate exists and is wired.
# ════════════════════════════════════════════════════════════════════════
chk "hook defines gate_tree_modes (per-commit skip-class block)" \
    "$(grep -c 'gate_tree_modes()' "$HOOK")" "1"
chk "hook calls gate_tree_modes in the real flow" \
    "$(grep -c 'gate_tree_modes ' "$HOOK" | xargs -I{} bash -c '[[ {} -ge 1 ]] && echo yes || echo no')" "yes"
chk "hook gate_tree_modes detects 160000 gitlink" \
    "$(grep -c '160000)' "$HOOK")" "1"
chk "hook gate_tree_modes detects 120000 symlink" \
    "$( [[ $(grep -c '120000)' "$HOOK") -ge 1 ]] && echo yes || echo no )" "yes"
chk "hook gate_tree_modes detects the git-LFS pointer signature" \
    "$(grep -c 'git-lfs.github.com/spec' "$HOOK")" "1"

# Workflows feed the mode-bearing --tree-entries (drop --name-only).
chk "protocol-enforce.yml feeds --tree-entries (V10-B)" \
    "$( [[ $(grep -c -- '--tree-entries' "$REPO_ROOT/.github/workflows/protocol-enforce.yml") -ge 1 ]] && echo yes || echo no )" "yes"
chk "deploy.yml feeds --tree-entries (V10-B)" \
    "$( [[ $(grep -c -- '--tree-entries' "$REPO_ROOT/.github/workflows/deploy.yml") -ge 1 ]] && echo yes || echo no )" "yes"

echo ""
echo "  PASS=$PASS FAIL=$FAIL"
[[ "$FAIL" -eq 0 ]] && { echo "ALL PASS (v10 regression)"; exit 0; } || { echo "$FAIL FAILURE(S)"; exit 2; }
