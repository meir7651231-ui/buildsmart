#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
#  bookkeep.sh — DX8 (v7): ONE command for the bookkeeping ceremony.
# ═══════════════════════════════════════════════════════════════════════════
#  The protocol's "honest dev" tax was the 4-file ritual on a code change:
#    WIRING.md (gate 24/72) · knowledge/visual_log.md (gate 116, UI only) ·
#    knowledge/mutation_log.md (gate 43/44, new helper) · STATUS.md tests/version.
#  This helper INSPECTS the staged change and, for each gate that WOULD fire,
#  auto-STUBS + STAGES the required entry (a clearly-marked TODO line the dev
#  fills in) and PRINTS a reminder for the human-judgement bits (STATUS tests:/
#  version). It does NOT remove or weaken any gate — it just makes SATISFYING
#  them one step. Re-runnable (idempotent): it never appends a second stub for
#  the same commit, and never overwrites real content you already wrote.
#
#  Usage:
#    git add <your code files>
#    bash scripts/bookkeep.sh        # stubs+stages the required bookkeeping
#    git commit -m "…"               # the hook now finds the entries
#
#  Flags:
#    --dry-run   show what WOULD be stubbed/staged, change nothing.
# ═══════════════════════════════════════════════════════════════════════════
set -euo pipefail

DRY=""
[[ "${1:-}" == "--dry-run" ]] && DRY=1

REPO_ROOT="$(git rev-parse --show-toplevel)"
FLUTTER_DIR="$REPO_ROOT/app_flutter"
cd "$FLUTTER_DIR" || { echo "❌ לא נמצא app_flutter"; exit 1; }

STAMP="$(date '+%Y-%m-%d %H:%M')"
MARKER="<!-- bookkeep-stub $STAMP -->"   # idempotency / fill-me marker

note() { echo "  • $*"; }
act()  { # <human description> <file> <content-to-append>
    local desc="$1" file="$2" content="$3"
    if [[ -n "$DRY" ]]; then note "WOULD stub+stage: $desc → ${file#"$FLUTTER_DIR"/}"; return; fi
    printf '%s\n' "$content" >> "$file"
    git add "$file"
    note "stubbed+staged: $desc → ${file#"$FLUTTER_DIR"/}  (fill in the TODO line)"
}

# ── what is staged? (repo-root-relative; we run from app_flutter) ──
STAGED=$(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
STAGED_CODE=$(printf '%s\n' "$STAGED" | grep -E "^app_flutter/lib/(screens|state|logic|data|widgets)/.*\.dart$" || true)
STAGED_UI=$(printf '%s\n'   "$STAGED" | grep -E "^app_flutter/lib/(screens|widgets)/.*\.dart$" || true)
STAGED_HELPER=$(printf '%s\n' "$STAGED" | grep -E "^app_flutter/lib/(logic|data)/.*\.dart$" || true)
STAGED_WIRING=$(printf '%s\n' "$STAGED" | grep -E "WIRING\.md$" || true)
STAGED_VLOG=$(printf '%s\n'   "$STAGED" | grep -E "knowledge/visual_log\.md$" || true)
STAGED_MUT=$(printf '%s\n'    "$STAGED" | grep -E "knowledge/mutation_log\.md$" || true)

echo ""
echo "══════════════════════════════════════════════"
echo "  bookkeep — DX8 (one-step bookkeeping)${DRY:+  [DRY-RUN]}"
echo "══════════════════════════════════════════════"

if [[ -z "$STAGED_CODE" ]]; then
    echo "  ℹ️  אין קוד lib/* staged — אין bookkeeping נדרש. (stage את הקוד קודם)"
    exit 0
fi

DID=0

# ── (1) WIRING.md — gate 24 (code change must update WIRING) + 72 ──
if [[ -z "$STAGED_WIRING" ]]; then
    if ! grep -qF "$MARKER" WIRING.md 2>/dev/null; then
        FILES_ONE_LINE=$(printf '%s\n' "$STAGED_CODE" | sed 's#^app_flutter/##' | paste -sd', ' -)
        act "WIRING row for the code change" "$FLUTTER_DIR/WIRING.md" "$(cat <<EOF

## TODO — describe this change ($STAMP) $MARKER
- Files: $FILES_ONE_LINE
- TODO: what wires to what (provider/map/screen → effect) + guard test name.
EOF
)"
        DID=1
    else
        note "WIRING.md already has a stub for this session (idempotent) — fill it in."
    fi
else
    note "WIRING.md already staged — OK (gate 24/72 satisfied)."
fi

# ── (2) visual_log.md — gate 116 (UI change). DX5: a widget test ALSO satisfies
#        116, so only stub when there is no covering widget test AND no staged log.
if [[ -n "$STAGED_UI" ]]; then
    if [[ -n "$STAGED_VLOG" ]]; then
        note "visual_log.md already staged — OK (gate 116 satisfied)."
    else
        # Is every changed UI file already covered by a widget test? (mirror DX5)
        UNCOVERED=""
        while IFS= read -r f; do
            [[ -z "$f" ]] && continue
            rel=${f#app_flutter/}
            base=$(basename "$rel")
            classes=$(grep -hoE 'class[[:space:]]+[A-Z][A-Za-z0-9_]+[[:space:]]+extends[[:space:]]+(Stateless|Stateful|Consumer|HookConsumer|HookWidget)' "$rel" 2>/dev/null \
                        | sed -E 's/class[[:space:]]+([A-Z][A-Za-z0-9_]+).*/\1/' | sort -u)
            covered=""
            for t in test/*_test.dart; do
                [[ -f "$t" ]] || continue
                grep -qE 'testWidgets|pumpWidget' "$t" 2>/dev/null || continue
                if grep -qF "$base" "$t" 2>/dev/null; then covered=1; break; fi
                for c in $classes; do grep -qE "\b$c\b" "$t" 2>/dev/null && { covered=1; break; }; done
                [[ -n "$covered" ]] && break
            done
            [[ -z "$covered" ]] && UNCOVERED="$UNCOVERED $rel"
        done <<<"$STAGED_UI"
        if [[ -z "$UNCOVERED" ]]; then
            note "UI change is covered by a widget test — gate 116 satisfied by DX5 (no visual_log needed)."
        elif ! grep -qF "$MARKER" knowledge/visual_log.md 2>/dev/null; then
            act "visual_log entry for the UI change" "$FLUTTER_DIR/knowledge/visual_log.md" "$(cat <<EOF

## TODO — visual verify ($STAMP) $MARKER
**שינוי UI:**$UNCOVERED
- TODO: before/after, or add a widget test referencing the widget (DX5 path).
- אימות: TODO (screenshot / widget-test name).
EOF
)"
            DID=1
        else
            note "visual_log.md already has a stub for this session (idempotent) — fill it in."
        fi
    fi
fi

# ── (3) mutation_log.md — gate 43/44 (new helper logic) ──
if [[ -n "$STAGED_HELPER" ]]; then
    if [[ ! -f knowledge/mutation_log.md ]]; then
        act "mutation_log.md (was missing)" "$FLUTTER_DIR/knowledge/mutation_log.md" "# Mutation log — app_flutter"
        DID=1
    fi
    if [[ -z "$STAGED_MUT" ]]; then
        if ! grep -qF "$MARKER" knowledge/mutation_log.md 2>/dev/null; then
            HELPER_ONE_LINE=$(printf '%s\n' "$STAGED_HELPER" | sed 's#^app_flutter/##' | paste -sd', ' -)
            act "mutation_log entry for the helper change" "$FLUTTER_DIR/knowledge/mutation_log.md" "$(cat <<EOF

## TODO — mutation ($STAMP) $MARKER
- Helper(s): $HELPER_ONE_LINE
- TODO: which fault you injected + which test caught it (red→green).
EOF
)"
            DID=1
        else
            note "mutation_log.md already has a stub for this session (idempotent) — fill it in."
        fi
    else
        note "mutation_log.md already staged — OK (gate 43/44 satisfied)."
    fi
fi

# ── (4) STATUS.md — human judgement (tests:/version). REMIND, never auto-edit. ──
echo ""
echo "  📋 STATUS.md (human judgement — not auto-stubbed):"
TESTS_LINE=$(grep -oE "^tests: [0-9]+" knowledge/STATUS.md 2>/dev/null | head -1 || true)
note "${TESTS_LINE:-tests: <missing>} — if you ADDED tests, bump the \`tests:\` count (gate 33)."
note "known-failing must stay 0 unless you list names in knowledge/known_failing.txt (gate 32)."
note "version label: bump in STATUS.md only for a real release (version.g.dart is auto-generated)."

echo ""
echo "══════════════════════════════════════════════"
if [[ -n "$DRY" ]]; then
    echo "  [DRY-RUN] nothing changed. Re-run without --dry-run to stub+stage."
elif [[ "$DID" -eq 1 ]]; then
    echo "  ✅ bookkeeping stubbed + staged. FILL IN the TODO lines, then:"
    echo "     git add -u && git commit -m \"…\""
    echo "  (the stubs are clearly marked; the hook still enforces real content)"
else
    echo "  ✅ bookkeeping already satisfied for the staged change — nothing to do."
fi
echo "══════════════════════════════════════════════"
