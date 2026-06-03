#!/bin/bash
# update_pins.sh — regenerate protocol/pins.sha256 (R6 integrity pins).
#
# The pre-commit gate `reg` (gate_engine_integrity) and the CI integrity step
# verify that each protocol-critical file matches its recorded sha256 here. Run
# this ONLY after an INTENTIONAL change to one of the pinned files, then commit
# protocol/pins.sha256 alongside that change. Format: `<sha256>␠␠<repo-rel-path>`
# (two spaces — `sha256sum --check` compatible).
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

PINNED=(
    "app_flutter/tool/protocol_check.dart"
    "app_flutter/tool/protocol_check_selftest.dart"
    "protocol/gates.tsv"
    "scripts/gen_version.sh"
    "app_flutter/scripts/generate_stuck_regression.sh"
    # K4 (v4) — integrity-pin the hooks + workflows THEMSELVES so a
    # gutted-but-executable hook or a neutered workflow fails the content-hash
    # check (not just an existence / grep -q job-name check). NOTE: .claude/*
    # (pre-tool.sh, settings.json) are HARNESS-LOCKED (writes denied at the
    # environment level) — they are documented as WALL in PROTOCOL_V4.md and are
    # NOT pinned here because this script cannot rewrite the pin on an intentional
    # change to them; their integrity is the platform's responsibility.
    ".githooks/pre-commit"
    ".githooks/pre-push"
    ".githooks/commit-msg"
    ".github/workflows/protocol-enforce.yml"
    ".github/workflows/deploy.yml"
    # v5 — pin the bash/CI regression suite so a silent edit that neuters an
    # S1-S4 assertion is integrity-detected (it is the runner/workflow half's
    # honest test; the engine half is covered by the Dart --self-test pin above).
    "protocol/regression_v5.sh"
    # v6 — pin the H1-H5 end-to-end regression suite (silent-skip class + slash-
    # laundering + logic-coupled RAN) for the same reason.
    "protocol/regression_v6.sh"
    # v7 — pin the DX friction-fix regression suite (DX1-DX6 bash-hook half).
    "protocol/regression_v7.sh"
)

OUT="$REPO_ROOT/protocol/pins.sha256"
{
    echo "# protocol/pins.sha256 — R6 integrity pins. Regenerate via scripts/update_pins.sh"
    echo "# after an INTENTIONAL change to a pinned file. <sha256>  <repo-relative-path>"
    for f in "${PINNED[@]}"; do
        if [[ -f "$f" ]]; then
            sha256sum "$f"
        else
            echo "# MISSING: $f" >&2
        fi
    done
} > "$OUT"

echo "✅ wrote $OUT"
cat "$OUT"
