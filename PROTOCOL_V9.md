# Protocol v9 — eliminate the base64-laundering CLASS

The base64 image exemption was a recurring laundering liability (v7 hole; v8's
decode-and-scan re-fix introduced two NEW holes — trailing-bytes-after-valid-image
and `data:` URI literals, both proven by the final security sweep). v9 stops
patching decode-and-scan and **removes the risky exemption entirely**, killing the
whole class.

## Changes
- **V9-A — remove the image WARN exemption.** Any literal meeting the
  base64-blob / high-entropy secret criteria is now **ERR (blocks)**, not a
  downgraded WARN. Message: "inline base64/binary data is not allowed in source —
  move images to `assets/` and load them as an asset." Provider fingerprints still
  ERR. Eliminates Hole A (trailing bytes), entropy-threshold tuning, and the
  entire decode-and-scan edge-case class in one move.
- **V9-B — fix `data:` URI extraction.** The secret-extraction regexes excluded
  `:` `;` `,`, so `data:image/png;base64,<secret>` was never extracted (Hole B,
  returned NONE/RC 0). v9 strips a leading `data:[mime];base64,` before matching,
  so the payload is extracted and evaluated -> caught.

## Verification (architect-confirmed, independent)
- engine `--self-test`: **ALL PASS (v9)**.
- Hole A — trailing secret after a valid PNG -> **ERR 52** (RC 2).
- Hole B — `data:image/png;base64,<AWS key>` -> **ERR 52** (RC 2).
- `dart analyze` on the engine: **0 errors / 0 warnings** (info-only).
- whole-tree scan over the live `app_flutter/lib/` (123 files): **RC 0, fed==scanned==123, 0 ERR** — removing the exemption introduced **no false-positive** on existing legit code.

## Accepted DX cost (small, by design)
A genuine inline base64 image in source now ERRs with the "move to `assets/`"
message. Inline base64 in code is rare and an anti-pattern; real images belong in
`assets/`. Deliberate trade to close the laundering class.

## Provenance note
The engine + self-test edits were produced by a hardening pass that completed the
work but terminated before committing; the architect independently verified the
result (self-test green, both holes ERR, zero new false-positives) before
committing it here. Pins regenerated to match.

## Still open (next pass — v10), NOT base64-related
1. **ReDoS** — `stuck_log.md` ANTIPATTERN regex matched with Dart's backtracking
   `RegExp` (gate 103 + the generated regression test), no timeout/complexity
   guard -> a `(a+)+$`-style pattern can hang the hook and CI forever.
2. **whole-tree skips** — content in a submodule / behind a `.dart` symlink / in a
   git-LFS-tracked file is skipped by the scan; H3 reconciliation falsely passes.
