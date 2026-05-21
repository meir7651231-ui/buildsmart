# INSP-0024 — Worker Persona Skeleton (Phase 0)

**Date:** 2026-05-21
**Branch:** claude/whats-happening-LyY9G
**Verdict:** GO ✅ (0/0/0)

## Scope
Third and final of three Phase-0 skeletons (Store ✓, Courier ✓, Worker now).
Same dashboard skeleton structure: header + verbatim section names +
"בבנייה" tag per row.

## Changes
- **`app/src/views/worker.tsx`** — full replace (~30 lines).

## Section labels (verbatim from legacy)
| emoji | title | source |
|---|---|---|
| 🔨 | המשימה הנוכחית שלך | index.html:8099 |
| ⏳ | הבאות בתור         | index.html:8101 |
| 📋 | שהגשת               | index.html:8102 |

Header text "עובד" — verbatim from role-pick-btn `<b>` at
index.html:4110.

## Intentionally omitted (later phases)
- Worker picker (2-button selector between `WORKERS[0]`/`WORKERS[1]`)
- Home summary (greeting + progress bar + 3 stats: פעילה / בתור / הוגשו)

These don't have clean verbatim section headers in the legacy — they
emerge from the `renderWorker` function dynamically. Will be wired when
state is added (later phase).

## Findings (Inspector subagent — ran before this markdown)
| Severity | Count |
|---|---|
| CRITICAL | 0 |
| MAJOR | 0 |
| MINOR | 0 |

## Rule Checks
- **R1** PASS — FAB positions untouched.
- **R2** PASS — Persona default view.
- **R3** PASS — Flat content.
- **R4** PASS — 3 separate spans per row.
- **R6/R8** PASS — Verbatim labels.
- **R7** PASS — smoke regression unaffected.

## Stuck-loop Scan
No recurring finding IDs from INSP-0017..0023.

## Phase 0 — DONE
All 3 persona skeletons (Store · Courier · Worker) now share the same
`.dash__*` block and render structured sections. Next: Phase 1 (data
files + display).
